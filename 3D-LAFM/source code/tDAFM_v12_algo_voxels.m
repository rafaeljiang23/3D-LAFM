%%%%%%
%%% Construct 3D-LAFM detection stack
%%% Input: 
%%%        1: detections_summary: detection pool, M-3 where M is the number of
%%%        detections and columns 1-3 are x, y, and z detection coordinates
%%%        2: nf: molecular symmetry
%%%        3: z_min: lowerbound detection threshold in the Z-dimension
%%%        4: z_max: upperbound detection threshold in the Z-dimension
%%%        5: x_max: upperbound detection threshold in the X-dimension
%%%        6: y_max: upperbound detection threshold in the Y-dimension
%%%        7: resolution_xy: AFM data lateral resolution 
%%%        8: voxel_xy: voxel size in the X-Y plane
%%%        9: voxel_z: voxel size in the Z dimension
%%% Output:
%%%        1: voxels: the 3D-LAFM detection stack
%%%%%%


function voxels = tDAFM_v12_algo_voxels(detections_summary, nf, z_min, z_max, x_max, y_max, resolution_xy, voxel_xy, voxel_z)
%% LAFM detections
%% prepare for detection allocation
%%% clean detections
detections3 = detections_summary;
sel = detections_summary(:, 3) < z_max & detections_summary(:, 3) > z_min; 
detections3(~sel, :) = [];
detections3(:, 1) = round(resolution_xy.* detections3(:, 1)./voxel_xy);  %0623
detections3(:, 2) = round(resolution_xy.* detections3(:, 2)./voxel_xy);  %0623
detections3(:, 3) = floor((detections3(:, 3) - z_min)./voxel_z) + 1;  %0623
bin_num_X = 2 * floor(x_max/(2*voxel_xy)) + 1;   %0623
bin_num_Y = 2 * floor(y_max/(2*voxel_xy)) + 1;   %0623
bin_num_Z = ceil((z_max - z_min)/voxel_z);

%% allocate 3D-LAFM detections
voxels = tDAFM_voxels_v4(detections3, bin_num_X, bin_num_Y, bin_num_Z, 1);
%%% apply molecular symmetry
voxels_nf = zeros(bin_num_X, bin_num_Y, bin_num_Z);
for i = 1:nf
    angle = (i-1)*(360/nf);
    voxels_nf = voxels_nf + imrotate(voxels, angle, "nearest", "crop");
end
voxels = voxels_nf;

end