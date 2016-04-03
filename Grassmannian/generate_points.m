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
dataset_dir = '.\imgdb\';
seq_names = dir([dataset_dir '*.mat']);
addpath('./STLBP_Matlab');
block_size_r = 15;
block_size_c = block_size_r;
block_size_t = 15;
delta_spatial = 5;
delta_temporal = 5;

inner_delta_temporal = 2;
inner_block_size = 5;

FxRadius = 1;
FyRadius = 1;
TInterval = 2;
TimeLength = 2;
BorderLength = 1;
bBilinearInterpolation = 1;
Bincount = 59;
NeighborPoints = [8 8 8];
% uniform patterns for neighboring points with 8
U8File = importdata('UniformLBP8.txt');
BinNum = U8File(1, 1);
nDim = U8File(1, 2); %dimensionality of uniform patterns
Code = U8File(2 : end, :);
clear U8File;
mkdir('./Seq_Geassmann');
for tmpSeq = 1:length(seq_names)    
    tmpSeq
    load([dataset_dir seq_names(tmpSeq).name]);
    I = subv;
    block_ind = 1;  
    Set.X = []; Set.y = [];
    for rScan=1:delta_spatial:1+50-block_size_r
        temp1 = rScan:rScan + block_size_r - 1;
        for cScan=1:delta_spatial:1+50-block_size_c
            temp2 = cScan:cScan + block_size_c - 1;
            for tScan=1:delta_temporal:1+50-block_size_t
                temp3 = tScan:tScan + block_size_t - 1;
                block = I( temp1 , temp2 , temp3); 
                inner_block_ind = 1;
                X = [];
                for iScan=1:inner_delta_temporal:1+block_size_t-inner_block_size
                    temp4 = iScan:iScan + inner_block_size - 1;
                    inner_block = block(:,:,temp4);
                    Histogram = LBPTOP(inner_block, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength, bBilinearInterpolation, Bincount, Code);                
                    X(:,inner_block_ind) = Histogram(:);
                    inner_block_ind = inner_block_ind + 1;
                end
                [U,D,V] = svd(X);
                Set.X(:,:,block_ind) = U(:,1:6);
                block_ind = block_ind + 1;
            end
        end
    end    
    Set.y = class_id;
    save(['./Seq_Geassmann/' seq_names(tmpSeq).name],'-v7.3','Set');    
end
