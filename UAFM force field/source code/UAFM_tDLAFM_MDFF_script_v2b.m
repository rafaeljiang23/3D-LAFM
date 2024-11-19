%% General Information
%%%% This script constructs 3D-LAFM force fields from the 3D-LAFM density
%%%% maps for the molecular dynamics flexible fitting (MDFF) of the
%%%% molecule of interest into the 3D-LAFM density data.

%%%% User should provide a '.afm' file that records the 3D-LAFM density
%%%% data and a '.mrc' file that records the pseudo-density generated from 
%%%% Chimera based on the PDB structure of the molecule. Alignment of the
%%%% pseudo-density and the 3D-LAFM density should be done in Chimera.

%%%% For a more comprehensive understanding of the workflow, users should
%%%% refer to the figures in the associated published paper.

%%%% Note: Version v2b includes additional details compared to version
%%%% v2. NO amendments or modifications have been made to the v2 code.
%% Section 1. Access density files
%%%% This section accesses the '.mrc' file and the '.afm' file. Alignment
%%%% of the density data should be done in Chimera.

%%% parameters
nf = 3;   % molecular symmetry
%%%
%% access PDB .mrc file 
%%%% Section 1.1: This sub-section accesses the pseudo-density data 
%%%% generated from Chimera based on the PDB structure of the molecule

%%% parameters
% filename_mrc = "1avr_A5_afm_aligned2.mrc";    % this line is commented for test run!!!!
%%% 

% [map1,s1,hdr1,extraHeader1]= ReadMRC(filename_mrc);    % this line is commented for test run!!!!

%% access 3D-LAFM density map .afm file (from decoder)
%%%% Section 1.2: This section accessess the '.afm' file directly from the
%%%% '.afm' file decoder. User should run the decoder MatLab script 
%%%% "afm_decoder_v1" before running this sub-section. 
%%%% Codes for the decoder is not included here for the simplicity of this
%%%% script.

% map2 = P;    % this line is commented for test run!!!!
% s2 = s;    % this line is commented for test run!!!!
%% Section 2. Process PDB mrc file (map1) and 3D-LAFM density map (map2)
%%%% This section pre-process '.mrc' file and '.afm' density files before
%%%% integrating them to generate the MDFF force field. 
%%%% This section requires NO user input.

%%% resize map1 (map1b) to match map2 voxel size
s2.pixA = double(s.CELLA(1))./double(s.NC);
scale = s1.pixA/s2.pixA;
sz1 = size(map1);
sz2 = size(map2);
sz1 = sz1 * scale;
sz1 = floor(sz1./2)*2 + 1;
map1b = imresize3(map1, sz1);

%%% generate a new map2 (map2b) to match map1 dimension
map2b = zeros(sz1);
map2b((sz1(1) - sz2(1))/2+1: (sz1(1) - sz2(1))/2+sz2(1), ...
    (sz1(2) - sz2(2))/2+1: (sz1(2) - sz2(2))/2+sz2(2), ...
    end - sz2(3) + 1:end) = imrotate3(map2,-90,[0 0 1]);
map2b = map2b./max(map2b(:));

%%% downsize both maps if necessary, map1c and map2c
downsize = 1;
map1c = imresize3(map1b, downsize);
map2c = imresize3(map2b, downsize);
sz = size(map1c);
map1c = nfold(map1c, nf);

%% Section 3. Apply background threshold to both maps
%%%% This section applys a background value "background" to both maps to
%%%% threshold out the background densities before integrating them to 
%%%% generate the MDFF force field. User should estimate the background
%%%% value from Chimera.


%%% parameters
background = 0.02;
%%%



sel = mean(map1c, 3) > background;
sel2 = map1c.*0;
map3 = mean(map1c, 3);   % generate map3 from map1c Z-projection
                         % this map captures the 2D cross-section of the
                         % protein atomic model
map3(map3 > background) = background;
map3b = map1c.*0;
for i = 1:sz(3)
    sel2(:, :, i) = sel;
    map3b(:, :, i) = map3;
end
map2d = map2c.*sel2;     % generate map2d from map2c to match the protein
                         % atomic model 2D cross-section

%% Section 4. Integrating map3b (PDB mrc) and map2d (3D-LAFM)
%%%% This section integrate the background thresholded density files and
%%%% generate a force field "map_UAFM", that can be used for MDFF of the 
%%%% molecule into the 3D-LAFM density data. 
%%%% User should convert the final output "map_UAFM" to a '.mrc' file to
%%%% be used for MDFF using NAMD/VMD. Details about this conversion can be
%%%% found in the Methods section of the paper.


map_UAFM = map3b + map2d;

map_UAFM(map_UAFM < 0) = 0;
im_empty = map_UAFM == 0;
map_UAFM(all(im_empty,[2, 3]), :, :) = [];
map_UAFM(:, all(im_empty,[1, 3]),: ) = [];
map_UAFM(:, :, all(im_empty,[1, 2])) = [];

%%% AFM force field UAFM (map_UAFM)
map_UAFM = map_UAFM./max(map_UAFM(:));
MIJ.createImage(map_UAFM);

%%% The UAFM map (3D volume matrix) should be converted to a '.mrc' file to
%%% be used for MDFF using NAMD/VMD. Details about this conversion can be
%%% found in the Methods section
%% helper function

%%%%%%
%%% molecular symmetry average
%%% Input: 
%%%        1: in: input file
%%%        2: nf: molecular symmetry
%%% Output:
%%%        1: out: molecular symmetry averaged file
%%%%%%

function out = nfold(in, nf)
out = in;
for i = 2:nf
    out = out + imrotate(in, (i-1)*360/nf, "bicubic", "crop");
end
out = out ./ nf;
end