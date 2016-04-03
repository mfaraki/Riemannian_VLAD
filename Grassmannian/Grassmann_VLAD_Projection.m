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
clear; clc;
addpath('./MyKMGM');
load('./matFiles/Split1Inds');
Subs_dir = '.\Seq_Geassmann\';
Subs_name = dir([Subs_dir '*.mat']);
%% Generate train data for Kmeans
if ~exist('./matFiles/TrainSet_10.mat')
    Subs_name_train = Subs_name(trainIndsAll);
    TrainSet.X = [];
    for tmpS=1:length(Subs_name_train)
        load([Subs_dir Subs_name_train(tmpS).name]);
        randN = randperm(size(Set.X,3) , 10);
        TrainSet.X = cat(3 , TrainSet.X , Set.X(:,:,randN));
    end
    save('./matFiles/TrainSet_10','-v7.3','TrainSet');
else
    load('./matFiles/TrainSet_10');
end
%% Run Kmeans
if ~exist('./matFiles/clusters_K16_Projection.mat')
    [n, p , nPoints] =  size(TrainSet.X);
    rand_inds = randperm(nPoints);
    TrainSet.X = TrainSet.X(:,:,rand_inds);
    fun_opt.manifold_name = 'Grassmann';
    fun_opt.dist_func = @grassmann_proj_dist;
    fun_opt.mean_fun = @grassmann_mean_proj;
    fun_opt.INIT_KMEANS_PP = false;
    [cluster_centers,~,~] = Riemannian_kmeans(TrainSet.X, 16, fun_opt);
    save('./matFiles/clusters_K16_Projection', 'cluster_centers');
else
    load('./matFiles/clusters_K16_Projection');
end
%% Generate VLAD
[d,p,~] = size(cluster_centers);
signaturesALLPower_Proj = zeros(d*p*16, length(Subs_name));

for tmpS=1:length(Subs_name)
    tmpS
    load([Subs_dir Subs_name(tmpS).name]);
    sigPower = Compute_VLAD_Projection(Set.X, cluster_centers);
    signaturesALLPower_Proj(:,tmpS) = sigPower;
    yAll(tmpS) = Set.y;
end
save( ['./matFiles/signaturesVLAD_Power_All_Projection_K=16'], '-v7.3', 'signaturesALLPower_Proj', 'yAll');
%% Classify
signaturesAll = signaturesALLPower_Proj;

dist_vec = pdist(signaturesAll');
dist = squareform(dist_vec);
clear dist_vec;

y = yAll(trainIndsAll);
yTest = yAll(testIndsAll);
numTest = length(yTest);
signatures = signaturesAll(:,trainIndsAll);
signaturesTest = signaturesAll(:,testIndsAll);

tmp_dist = dist(testIndsAll,trainIndsAll);
[~, min_loc] = min(tmp_dist, [], 2);
y_hat = y(min_loc);

acc1NN_Projection = 100 * (1-length(find( (y_hat-yTest) ~=0 ) )/numTest)

libSVM_STR = '-q -B 0.5 -s 3 -c 100';
%linear SVM
SVM_model = liblinear_train(y', sparse(signatures)' ,libSVM_STR);
[~, accuracy, ~] = liblinear_predict(yTest', sparse(signaturesTest)', SVM_model);
accSVM_Projection = accuracy(1)
%%