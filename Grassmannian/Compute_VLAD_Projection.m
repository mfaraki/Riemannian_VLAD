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

function [RPower] = Compute_VLAD_Projection(inSub, clusterCenters)
[d,p,K] = size(clusterCenters);
T = size(inSub,3);
V = zeros(d,p,K);
D = grassmann_proj_dist(inSub,clusterCenters);

for t = 1:T                
    [dist,b] = min(D(:,t)); 
    X = clusterCenters(:,:,b);
    Y =  inSub(:,:,t);
    
     dS = (eye(d) - X*X' ) * (Y * Y' * X);
     
     tmp_mat = (dS / norm(dS , 'fro')) * sqrt(dist);

    V(:,:,b) = V(:,:,b) + tmp_mat ;     
end

alfa = 0.5;
R = V(:);
R = sign(R) .* abs(R).^ alfa;
R = R ./norm(R,2);
RPower = R;
