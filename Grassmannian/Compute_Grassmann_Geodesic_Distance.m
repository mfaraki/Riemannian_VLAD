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