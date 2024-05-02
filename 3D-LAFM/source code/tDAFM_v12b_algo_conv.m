%%%%%%
%%% Construct 3D-LAFM density map
%%% Input: 
%%%        1: voxels: 3D-LAFM detection stack
%%%        2: h: 3D density function
%%%        3: nf: molecular symmetry
%%% Output:
%%%        1: voxels_hs: the 3D-LAFM density map
%%%%%%


function voxels_hs= tDAFM_v12b_algo_conv(voxels, h, nf)

%% convolution
voxels_h = imfilter(voxels, h);

%% symmetry
voxels_hs = voxels_h;
if nf > 1
for i = 2:nf
    angle = (i-1)*(360/nf);
    voxels_hs = voxels_hs + imrotate(voxels_h, angle, "bicubic", "crop");
end
end
voxels_hs = voxels_hs./sum(voxels_hs(:));

end