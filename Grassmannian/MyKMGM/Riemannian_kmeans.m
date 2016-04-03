% Please cite the following paper if your are using this code:
% "More About VLAD: A Leap from Euclidean to Riemannian Manifolds", 
% Masoud Faraki, Mehrtash Harandi, and Fatih Porikli, 
% In Proc. IEEE Conference on Computer Vision and Pattern Recognition
% (CVPR), Boston, USA, 2015.

%  BibTex
% @inproceedings{faraki2015more,
%   title={More About VLAD: A Leap from Euclidean to Riemannian Manifolds},
%   author={Faraki, Masoud and Harandi, Mehrtash T and Porikli, Fatih},
%   booktitle={In Proc. IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
%   pages={4951--4960},
%   year={2015},
%   organization={IEEE}
% }

function [best_cntr,id,best_cost] = Riemannian_kmeans(X,k,fun_opt)

%----------------
if (nargin < 3)
    error('not enough inputs');
end


% Initializations
MinCostVariation = 1e-3;

if (strcmpi(fun_opt.manifold_name,'Grassmann'))
    %Grassmann manifold
    [n,p,nPoints] = size(X);
    if (isfield(fun_opt,'dist_func'))
        M.dist_func = fun_opt.dist_func;
    else
        M.dist_func = @grassmann_proj_dist;
    end
    if (isfield(fun_opt,'mean_func'))
        M.mean_fun = fun_opt.mean_func;
    else
        M.mean_fun = @grassmann_mean_proj;
    end
    M.nPoints = nPoints;
    M.n = n;
    M.p = p;
else
    error('manifold is not defined');
end

if (isfield(fun_opt,'nIter'))
    nIter = fun_opt.nIter;
else
    nIter  = 10;
end

if (isfield(fun_opt,'INIT_KMEANS_PP'))
    INIT_KMEANS_PP = fun_opt.INIT_KMEANS_PP;
else
    INIT_KMEANS_PP  = true;
end
%--------------

%center initializations
if (INIT_KMEANS_PP)
    %kmeans++ initialization
    fprintf('kmeans: initialize cluster centers using kmeans++ algorithm.\n');
    idx = plusplus_kmeans_init(X,M,k);
else
    %random initialization
    fprintf('kmeans: initialize cluster centers randomly.\n');
    idx = random_kmeans_init(M,k);
end
centers = X(:,:,idx);

%Lloyd algorithm
for iter = 1:nIter
    %assign points and compute the cost
    [currCost,minIdx] = kmeans_cost(X,M,centers);
    for tmpC1 = 1:k
        idx = find(minIdx == tmpC1);
        if (isempty(idx))
            %zombie centers
            fprintf('kmeans: a zombie cluster is detected. Randomly initialize the center of the cluster.\n');
            randVal = randperm(nPoints);
            centers(:,:,tmpC1) = X(:,:,randVal(1));
        else
        centers(:,:,tmpC1) = M.mean_fun(X(:,:,idx));
        end
    end
    if (iter == 1)        
        fprintf('kmeans: initial cost is %6.1f.\n',currCost);
    else
        cost_diff = norm(preCost - currCost) ;
        if (cost_diff < MinCostVariation)
            fprintf('kmeans: done after %d iterations due to small relative variations in cost.\n',iter);
            break ;
        else
           fprintf('kmeans: Iter#%d, cost is %6.1f.\n',iter,currCost);
        end
    end    
    preCost = currCost;
end

id = minIdx;
best_cntr = centers;
best_cost = currCost;

end


%--------------------------------------------------------------------------

function idx = random_kmeans_init(M,k)
randVal = randperm(M.nPoints);
idx = randVal(1:k);
end
%--------------------------------------------------------------------------

function idx = plusplus_kmeans_init(X,M,k)
%kmeans++ seeding
%----------------

idx = zeros(1,k);


%pick first center randomly
randVal = randperm(M.nPoints);
idx(1) = randVal(1);

for tmpC1 = 2:k
    l_thresh = rand(1);
    %computing distances between data points and centers
    l_dist = M.dist_func(X,X(:,:,idx(1:tmpC1-1)));
    if (tmpC1 > 2)
        minDistances = min(l_dist);
    else
        minDistances = l_dist;
    end
    
    l_energy = sum(minDistances);
    l_acc = cumsum(minDistances);
    [~,idx(tmpC1)] =  find(l_acc > l_thresh*l_energy,1,'first');
    
end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function [outCost,minIdx] = kmeans_cost(X,M,centers)
l_dist = M.dist_func(X,centers);
[minDist,minIdx] = min(l_dist);
outCost = sum(minDist);
end

