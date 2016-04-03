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

function outMean = grassmann_mean_proj(X,w)
%this function computes the weighted mean of a set of points 
%{X_i}_{i=1}^{nPoints} on G(p,n).

[n,p,nPoints] = size(X);
if (nargin < 2)
    w = ones(1,nPoints);
end
tmpBig = zeros(n,n);
for tmpC1 = 1:nPoints
    tmpBig = tmpBig + w(tmpC1)*X(:,:,tmpC1)*X(:,:,tmpC1)';
end
[outMean,~,~] = svds(tmpBig,p);
end
