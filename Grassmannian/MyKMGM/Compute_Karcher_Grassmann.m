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

function X = Compute_Karcher_Grassmann(A)

[d,p,N] = size(A);
S = zeros(d);

for tmpN=1:N
    S = S + A(:,:,tmpN) * A(:,:,tmpN)';
end

[V,D] = eig(S);
D = diag(D);
[~, Ind] = sort(D,'descend');
X = V(:,Ind(1:p));
