% Author:
% - Masoud Faraki (masoud.faraki@nicta.com.au)
%
% This file is provided without any warranty of
% fitness for any purpose. You can redistribute
% this file and/or modify it under the terms of
% the GNU General Public License (GPL) as published
% by the Free Software Foundation, either version 3
% of the License or (at your option) any later version.

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

function outDist = Compute_Grassmann_Geodesic_Distance(Set1,Set2)

simFlag = false;
if (nargin < 2)
    Set2 = Set1;
    simFlag = true;
end

l1 = size(Set1,3);
l2 = size(Set2,3);
outDist = zeros(l2,l1);



if (simFlag)
    for tmpC1 = 1:l1
        X = Set1(:,:,tmpC1);
        for tmpC2 = tmpC1+1:l2
            Y = Set2(:,:,tmpC2);
            outDist(tmpC2,tmpC1) = local_geodesic(X,Y);
            if  (outDist(tmpC2,tmpC1) < 1e-10)
                outDist(tmpC2,tmpC1) = 0.0;
            end
            outDist(tmpC1,tmpC2) = outDist(tmpC2,tmpC1);
        end
    end
    
else
    for tmpC1 = 1:l1
        X = Set1(:,:,tmpC1);
        for tmpC2 = 1:l2
            Y = Set2(:,:,tmpC2);
            outDist(tmpC2,tmpC1) = local_geodesic(X,Y);
            if  (outDist(tmpC2,tmpC1) < 1e-10)
                outDist(tmpC2,tmpC1) = 0.0;
            end
        end
    end
end


end

function outG = local_geodesic(oS1,oS2)
%Computing subspaces
pA_Cos = svd(oS1'*oS2);
theta = acos(pA_Cos);
%Geodesic distance is sqrt(sigma(theta_i^2))
outG = sum(theta.^2);
end