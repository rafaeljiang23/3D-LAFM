
%% LAFM detections
%%% parameters
nf = 3;   %%% molecular symmetry
resolution_xy = 0.25;   % resolution in xy dimension (input data), unit: nm/pixel
z_min = -0.5;   % maximum z detection, unit: nm
z_max = 1.5;    % minimum z detection, unit: nm
% data = ...;    % input raw (HS-)AFM single-particle frames, 
                 % matrix dimension: X-Y-N
                 % where X, Y are image dimensions (unit: pixel), and
                 % N is the number of single-particle images
%%%

%% prepare for LAFM detection localization
%%% find local maxima from images
[d1, d2, d3] = size(data);
detections = zeros(d1, d2, d3);

for i = 1:d3
    frame = data(:, :, i);
    frame = reshape(frame, d1, d2);
    frame_max = imregionalmax(frame,4);    % LAFM detections should be local maxima
                                           % Users have the option to
                                           % use different regional maxima
                                           % threshold values: '8' and '4'
                                           % '8' is more restricted than
                                           % '4'
                                    
    dectections_h = frame.*frame_max;
    dectections_h(frame_max==0) = nan;
    detections(:, :, i) = dectections_h;
end
clearvars frame frame_max dectections_h i

%%% crop bad pixels
xy_crop_ratio = 0.9;
[XX,YY,~] = meshgrid(1:d2, 1:d1,1:d3);
xy_radius = min(d1, d2)/2;
xy_radius = xy_crop_ratio * xy_radius;
sel_radius = (XX - d2/2).^2 + (YY - d1/2) .^2 < xy_radius.^2;
detections(detections > z_max | detections < z_min) = nan;
detections = detections .* sel_radius;
detections(~sel_radius) = nan;
num_detections = sum(~isnan(detections(:)));

"Ready for LAFM detections extraction..."
clearvars XX YY
%% localize LAFM detections
%%% parameters
scale = 10;   % input local expansion LAFM detection extraction scale factor
%%%

detections_summary = tDAFM_locate_detections_v4(detections, data, scale, 1);   % unaligned LAFM detections pool
detections_summary2 = detections_summary;    % aligned LAFM detection pool

"LAFM detections extracted..."
%% LAFM align detections
%%% parameters
% alignment = ...;   % input alignment information
                     % matrix dimension: N-3
                     % where N is the number of single-particle images,
                     % and the three columns are lateral alignment
                     % info (columns 1 and 2, unit: pixel) and
                     % rotational alignment info (column 3, unit: degree)
                     
scale_factor = 5;  % input alignment image expansion scale
%%%

detections_summary2 = tDAFM_align_detecitons2(detections, detections_summary, alignment, scale_factor, false);
sel = detections_summary2(:, 1) > d1 | detections_summary2(:, 1) < 1 | detections_summary2(:, 2) > d2 | detections_summary2(:, 2) < 1;
detections_summary2(sel, :) = [];
num_detections = sum(~isnan(detections(:))) - sum(sel);
"LAFM detections aligned..."
clearvars sel

%% 3D-LAFM detection stack construction
%%% parameters
voxel_size = 0.03;   % input voxel size
%%%

voxel_size_xy = voxel_size;
voxel_size_z = voxel_size;
x_max = resolution_xy * d1;    % unit: nm;
y_max = resolution_xy * d2;    % unit: nm;

%%% 3D-LAFM detection stack (voxels)
voxels = tDAFM_v12_algo_voxels(detections_summary2, nf, z_min, z_max, x_max, y_max, resolution_xy, voxel_size_xy, voxel_size_z);

MIJ.createImage(voxels);
"3D-LAFM detection stack constructed..."

%% 3D-LAFM density map construction
%%% parameters
sigma = 1.2;   % 3D Gaussian density function sigma 
               % Recommanded value: the half-bit wavelength value
               % of 3D-LAFM detection stack
%%%

sigma_xy_A = sigma;
sigma_z_A = sigma;
sigma_xy = sigma_xy_A * 0.1/voxel_size_xy;
sigma_z = sigma_z_A * 0.1/voxel_size_z;

%%% 3D Gaussian density function
h = make_3D_LAFM_kernel1a(sigma_xy, sigma_z);  %% shape: gauss z; psf: gauss xyz

%%% 3D-LAFM density map (voxels_hs)
voxels_hs = tDAFM_v12b_algo_conv(voxels, h, nf);

MIJ.createImage(voxels_hs);
"3D-LAFM density map constructed..."