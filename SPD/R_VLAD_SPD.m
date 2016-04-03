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

%Note: Please install the Manopt toolbox first (http://www.manopt.org/).
clear; clc;
 addpath('./MyKMSPD');
 load('training_set');
 load('test_set');
 mkdir('./matFiles');
 K = 16;
 N_Class = 6;

TrainSet.X = [];
for tmpClass = 1:N_Class
    for i = 1:length(training_set{tmpClass})
        X = training_set{tmpClass}{i}(:,:,:);
        TrainSet.X = cat(3, TrainSet.X,  X);
    end
end
TrainSet.X = TrainSet.X(:,:,randperm(size(TrainSet.X,3)));
TrainSet.X = TrainSet.X(:,:,1:2500);
%% Run Kmeans
[~,cluster_centers_AIRM] = RMkmeans_AIRM(reshape(TrainSet.X, size(TrainSet.X,1), size(TrainSet.X,2), []), K);
save(['./matFiles/clusters_K=' int2str(K) '_AIRM'], 'cluster_centers_AIRM');

[~,cluster_centers_Stein] = RMkmeans_Stein(reshape(TrainSet.X, size(TrainSet.X,1), size(TrainSet.X,2), []), K);
save(['./matFiles/clusters_K=' int2str(K) '_Stein'], 'cluster_centers_Stein');

[~,cluster_centers_Jeff] = RMkmeans_Jeff(reshape(TrainSet.X, size(TrainSet.X,1), size(TrainSet.X,2), []), K);
save(['./matFiles/clusters_K=' int2str(K) '_Jeff'], 'cluster_centers_Jeff');
%% Generate VLAD
tmpCNTR = 1;
for tmpClass = 1:N_Class
    tmpClass;
    for i = 1:length(training_set{tmpClass})
        X = training_set{tmpClass}{i}(:,:,:);
        signaturesPowerAIRM(:,tmpCNTR) = Compute_VLAD_AIRM(X, cluster_centers_AIRM);
        signaturesPowerStein(:,tmpCNTR) = Compute_VLAD_Stein(X, cluster_centers_Stein);
        signaturesPowerJeff(:,tmpCNTR) = Compute_VLAD_Jeff(X, cluster_centers_Jeff);
        y(tmpCNTR) = tmpClass;
        tmpCNTR = tmpCNTR + 1
    end
end
tmpCNTR = 1;
for tmpClass = 1:N_Class
    tmpClass;
    for i = 1:length(test_set{tmpClass})
        X = test_set{tmpClass}{i}(:,:,:);
        signaturesTestPowerAIRM(:,tmpCNTR) = Compute_VLAD_AIRM(X, cluster_centers_AIRM);
        signaturesTestPowerStein(:,tmpCNTR) = Compute_VLAD_Stein(X, cluster_centers_Stein);
        signaturesTestPowerJeff(:,tmpCNTR) = Compute_VLAD_Jeff(X, cluster_centers_Jeff);
        yTest(tmpCNTR) = tmpClass;
        tmpCNTR = tmpCNTR + 1
    end
end

numTest = length(yTest);
%% Classify
dist = pdist2(signaturesTestPowerAIRM' , signaturesPowerAIRM');
[~, min_loc] = min(dist, [], 2);
y_hat = y(min_loc);
acc1NN_AIRM = 100 * (1-length(find( (y_hat-yTest) ~=0 ) )/numTest)

dist = pdist2(signaturesTestPowerStein' , signaturesPowerStein');
[~, min_loc] = min(dist, [], 2);
y_hat = y(min_loc);
acc1NN_Stein = 100 * (1-length(find( (y_hat-yTest) ~=0 ) )/numTest)

dist = pdist2(signaturesTestPowerJeff' , signaturesPowerJeff');
[~, min_loc] = min(dist, [], 2);
y_hat = y(min_loc);
acc1NN_Jeffery = 100 * (1-length(find( (y_hat-yTest) ~=0 ) )/numTest)
