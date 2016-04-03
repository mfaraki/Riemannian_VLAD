function minLBP = RotLBP(LBPCode, NeighborPoints)
%% For a basic LBP code, this function is to get its rotation invariance
%  corresponding code
%  Copyright 2009 by Guoying Zhao & Matti Pietikainen
%  Matlab version was Created by Xiaohua Huang
% If you have any problems, please feel to contact Guoying Zhao and Xiaohua Huang.
% huang.xiaohua@ee.oulu.fi
%%
minLBP = LBPCode;
for p = 1 : NeighborPoints - 1
    tempCode = bitor(bitshift(LBPCode, -1 * p), bitshift(bitand(LBPCode, (uint8(2 ^ p) - 1)), (NeighborPoints - p)));
    if tempCode < minLBP
        minLBP = tempCode;
    end
end