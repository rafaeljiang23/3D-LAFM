%% General Information
%%%% This script generates 3D-LAFM detection stacks and density maps from
%%%% (HS-)AFM single particle images. 

%%%% User should provide a raw 
%%%% single-particle image stack in the format (X-by-Y-by-N), where N
%%%% represents the number of particle images with dimensions X-by-Y.
%%%% This file should be named "data"

%%%% Pre-procesing is optional but recommanded. Image flattening (1st order
%%%% background subtraction and median subtraction)is advised. However,
%%%% operations that include bilinear or bicubic intepolation are
%%%% discouraged (e.g., esizing or rotation), as they may introduce
%%%% additional LAFM detections (local maxima). 
%%%% Additionally, user should provide alignment information detailing
%%%% the translational and rotational relationships between particle images
%%%% in the stack. This file should be named "alignment", and should have a
%%%% format of (N-by-3), where represents the number of particle images.
%%%% The three columns should encode the lateral alignment information
%%%% (unit: pixel) and the rotational alignment information (unit: degree).
%%%% Note that for a detection (x, y, a) and a set of alignment information
%%%% (dx, dy, da), the alignment operation is (x + dx, y + dy, a - da).
%%%% Since particle alignment requires expansion for sub-pixel adjustment,
%%%% a "scale_factor" parameter is required for the alignment (if no
%%%% expansion is done for alignment, "scale_factor = 1").

%%%% For a more comprehensive understanding of the workflow, users should
%%%% refer to the figures in the associated published paper.

%%%% Note: Version v12b includes additional details compared to version
%%%% v12. NO amendments or modifications have been made to the v12 code.
%% Section 1. LAFM detections
%%%% This section pick LAFM detections following the local expansion strategy
%%%% (Methods section). User should provide the following details regarding
%%%% the input data.

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
%%%% Section 1.1: This sub-section find local mixima from single particle
%%%% images (raw LAFM detections, not sub-pixel localized)

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

disp("Ready for LAFM detections extraction...")
clearvars XX YY
%% localize LAFM detections
%%%% Section 1.2: This sub-section applys the local expansion strategy to
%%%% localize the detections with sub-pixel spatial resolution, with a user
%%%% defined spatial expansion factor "scale".

%%% parameters
scale = 10;   % input local expansion LAFM detection extraction scale factor
%%%

detections_summary = tDAFM_locate_detections_v4(detections, data, scale, 1);   % unaligned LAFM detections pool
detections_summary2 = detections_summary;    % aligned LAFM detection pool

disp("LAFM detections extracted...")
%% LAFM align detections
%%%% Section 1.3: This sub-section applys the alignment information to
%%%% the 3D LAFM detections extracted from each single partilce image.

%%% parameters
% alignment = ...;   % input alignment information
                     % matrix dimension: N-3
                     % where N is the number of single-particle images,
                     % and the three columns are lateral alignment
                     % info (columns 1 and 2, unit: pixel) and
                     % rotational alignment info (column 3, unit: degree)
                     % Note that for a detection (x, y, a) and a set of
                     % alignment information (dx, dy, da), the alignment
                     % operation is (x + dx, y + dy, a - da).
                     % This line is commented for test run!!!!
                     
scale_factor = 5;  % input alignment image expansion scale
%%%

detections_summary2 = tDAFM_align_detecitons2(detections, detections_summary, alignment, scale_factor, false);
sel = detections_summary2(:, 1) > d1 | detections_summary2(:, 1) < 1 | detections_summary2(:, 2) > d2 | detections_summary2(:, 2) < 1;
detections_summary2(sel, :) = [];
num_detections = sum(~isnan(detections(:))) - sum(sel);

disp("LAFM detections aligned...")
clearvars sel

%% Section 2. 3D-LAFM detection stack construction
%%%% This section allocate the 3D-LAFM detections into a 3D volume space
%%%% where each voxel records the number of detections at that location.
%%%% The user should define a "voxel_size" parameter. Usually, different
%%%% voxel size values should be tested for the best results, while more
%%%% details about how to choose this parameter is either provided in the
%%%% paper or future updates. The user can evaluate the distribution
%%%% of the LAFM detections using a stardard Fourier Shell Correlation
%%%% (FSC) method (codes not provided here for the simplicity of the
%%%% script). We used a half-bit threshold to assess the data quanlity
%%%% (half-bit wavelength).

%%% parameters
voxel_size = 0.03;   % input voxel size
%%%

voxel_size_xy = voxel_size;
voxel_size_z = voxel_size;
x_max = resolution_xy * d1;    % unit: nm;
y_max = resolution_xy * d2;    % unit: nm;

%%% 3D-LAFM detection stack (voxels)
voxels = tDAFM_v12_algo_voxels(detections_summary2, nf, z_min, z_max, x_max, y_max, resolution_xy, voxel_size_xy, voxel_size_z);

MIJ.createImage(voxels);   % This line must be commented if MIJI is not installed!!!
disp("3D-LAFM detection stack constructed...")

%% 3D-LAFM density map construction
%%%% This section applys a 3D Gaussian density function to the 3D-LAFM
%%%% detection stack. The user should define a "sigma" value that
%%%% characterizes the width of the 3D Gaussian. We used the half-bit
%%%% wavelength assessed from the 3D-LAFM detection stack FSC as sigma by
%%%% default. In the future updates, we will test other density functions. 

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

MIJ.createImage(voxels_hs);   % This line must be commented if MIJI is not installed!!!
disp("3D-LAFM density map constructed...")