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

function dist_p = grassmann_proj_dist(SY1,SY2)

MIN_THRESH = 1e-6;

same_flag = false;
if (nargin < 2)
    SY2 = SY1;
    same_flag = true;
end
p = size(SY1,2);


[~,~,number_sets1] = size(SY1);
[~,~,number_sets2] = size(SY2);

dist_p = zeros(number_sets2,number_sets1);

if (same_flag)
    %SY1 = SY2
    for tmpC1 = 1:number_sets1
        Y1 = SY1(:,:,tmpC1);
        for tmpC2 = tmpC1:number_sets2
            tmpMatrix = Y1'* SY2(:,:,tmpC2);
            tmpProjection_Kernel_Val = 2*p - 2*norm(tmpMatrix, 'fro')^2;
            if (tmpProjection_Kernel_Val < MIN_THRESH)
                tmpProjection_Kernel_Val = 0;
            elseif (tmpProjection_Kernel_Val > 2*p)
                tmpProjection_Kernel_Val = 2*p;
            end
            dist_p(tmpC2,tmpC1) = tmpProjection_Kernel_Val;
            dist_p(tmpC1,tmpC2) = dist_p(tmpC2,tmpC1);
        end
    end
else
    for tmpC1 = 1:number_sets1
        Y1 = SY1(:,:,tmpC1);
        for tmpC2 = 1:number_sets2
            tmpMatrix = Y1'* SY2(:,:,tmpC2);
            tmpProjection_Kernel_Val = 2*p - 2*norm(tmpMatrix, 'fro')^2;
            if (tmpProjection_Kernel_Val < MIN_THRESH)
                tmpProjection_Kernel_Val = 0;
            elseif (tmpProjection_Kernel_Val > 2*p)
                tmpProjection_Kernel_Val = 2*p;
            end
            dist_p(tmpC2,tmpC1) = tmpProjection_Kernel_Val;
        end
    end
end


end
