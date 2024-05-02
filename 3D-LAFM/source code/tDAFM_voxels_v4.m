%%%%%%
%%% Allocate detections into the 3D-LAFM detection volume space
%%% Input: 
%%%        1: detections3: detection pool, M-3 where M is the number of
%%%        detections and columns 1-3 are x, y, and z detection coordinates
%%%        2: bin_num_X: total bin numbers in dimension X
%%%        3: bin_num_Y: total bin numbers in dimension Y
%%%        4: bin_num_Z: total bin numbers in dimension Z
%%%        5: showprogress: a flag to show progress. Default: 1
%%% Output:
%%%        1: voxels: the 3D-LAFM detection stack
%%%%%%

function voxels = tDAFM_voxels_v4(detections3, bin_num_X, bin_num_Y, bin_num_Z, showprogress)
voxels = zeros(bin_num_X, bin_num_Y, bin_num_Z);
[num_detections, ~] = size(detections3);
for i = 1:num_detections
    if showprogress
        i + "/" + num_detections
    end
    try
        voxels(detections3(i, 1), detections3(i, 2), detections3(i, 3)) = voxels(detections3(i, 1), detections3(i, 2), detections3(i, 3)) + 1;
    catch ME
        warning("value out of range");
    end
end
end