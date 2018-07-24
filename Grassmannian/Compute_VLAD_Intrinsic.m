function [RPower, RIn] = Compute_VLAD_Intrinsic(inSub, clusterCenters)
[d,p,K] = size(clusterCenters);
T = size(inSub,3);
V = zeros(d-p,p,K);

%D = Compute_Grassmann_Projection_Distance(inSub,clusterCenters);
D = grassmann_proj_dist(inSub,clusterCenters); 
[~,min_loc] = min(D, [], 1);
for t = 1:T                   
    [A,~] = Grassmann_Log( clusterCenters(:,:,min_loc(t)) , inSub(:,:,t));
    V(:,:,min_loc(t)) = V(:,:,min_loc(t)) + A ;     
end

alfa = 0.5;
R = V(:);
R = sign(R) .* abs(R).^ alfa;
R = R ./norm(R,2);
RPower = R;

for i=1:K
    if  norm(V(:,:,i),2) ~= 0
        V(:,:,i) = V(:,:,i) ./ norm(V(:,:,i),2);
    end
end
R = V(:);
R = R ./norm(R,2);
RIn = R;
