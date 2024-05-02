%%% convert 3D-LAFM density data matrix P into an MRC/AFM1 data
%% parameters
%%%
% User should adjust the variables in this section for the input
% density data and specify the output .afm file name
%%%

% input density data
data = voxels_hs;

% output file
filename = "test_A5_encoder_v1";

% raw data
scan_nm = 66;  % raw AFM data image size, unit: pixel
scan_v = 0.1;  % raw AFM data image acquisition speed, unit: s/frame
mol_sym = 3;  % molecular symmtery;
% detection stack
dv = 0.3;  % voxel size, unit: A
n = 171*3;  %  number of particles;
par_pix = 64;  % particle image size, unit: pixel
par_nm = 16;  % particle scan size, unit: nm
scale_exp = 15;  % image local bicubic expansion scale
N = 35971;  % total count of LAFM detections
rv = 1.1;   % 3D-LAFM detection stack resolution, unit: angstrom;
% density map
rp = 1.4;   % 3D-LAFM density map resolution, unit: angstrom;
dft_code = 0;   % density function code, default 0 for 3D gaussian N~(0,rv);

%% access the 3D-LAFM density datå
P = data;   % 3D-LAFM density map
sz = size(P);
%% construct the MRC/AFM1 header struct s
%%%
% Details about the variables should be found in the Methods section of the
% manuscript
%%%

s = struct;
% write the next 10 rows in float32 format (ct 10)
s.NC = int32(sz(1));
s.NR = int32(sz(2));
s.NS = int32(sz(3));
s.MODE = int32(2);
s.NCSTART = int32(-floor(sz(1)/2));
s.NRSTART = int32(-floor(sz(2)/2));
s.NSSTART = int32(-floor(sz(3)/2));
s.MX = int32(sz(1));
s.MY = int32(sz(2));
s.MZ = int32(sz(3));

% write the next 6 rows in float32 format (ct 16)
s.CELLA = single(dv.*sz);
s.CELLB = single([90 90 90]);

% write the next 3 rows in int32 format (ct 19)
s.MAPC = int32(1);
s.MAPR = int32(2);
s.MAPS = int32(3);

% write the next 3 rows in float32 format (ct 22)
s.DMIN = single(min(P(:)));
s.DMAX = single(max(P(:)));
s.DMEAN = single(mean(P(:)));

% write the next 4 rows in int32 format (ct 26)
s.ISPG = int32(1);
s.NSYMBT = int32(16);   % rows 25-40
s.AFMRNPAR = int32(n);
s.AFMRSYM = int32(mol_sym);

% write the next 1 row in char format (ct 27)
s.EXTTYP = 'AFM1';

% write the next 3 rows in int32 format (ct 30)
s.NVERSION = int32(20140);
s.AFMRNX = int32(par_pix);
s.AFMRNY = int32(par_pix);


% write the next 3 rows in float32 format (ct 36)
s.AFMRLX = single(par_nm*10);
s.AFMRLY = single(par_nm*10);
s.AFMRRESZ = single(par_nm*10/par_pix);
s.AFMRSVY = single(scan_v/scan_nm);   %construction
s.AFMRSVX = single(s.AFMRSVY/(2*scan_nm));   %construction
s.AFMDEXP = single(scale_exp);

% write the next 1 row in int32 format (ct 37)
s.AFMDNDET = int32(N);

% write the next 2 rows in float32 format (ct 39)
s.AFMVRES = single(rv);
s.AFMPRES = single(rp);

% write the next 1 row in int32 format (ct 40)
s.AFMPDFTYP = int32(dft_code);

% write the next 1 row in int32 format (ct 49)
s.EXTRA = int32([0;0;0;0;0;0;0;0;0]);  % EMPTY rows

% read the next 3 rows in float32 format (ct 52)
s.ORIGINi = single(0);
s.ORIGINj = single(0);
s.ORIGINk = single(0);

% write the next 1 row in char format (ct 53)
s.MAP = 'MAP ';

% read the next 1 row in int32 format (ct 54)
s.MACHST = int32(16708);

% read the next 1 row in float32 format (ct 55)
s.RMS = single(std(P(:)));

% write the next 1 row in int32 format (ct 56)
s.NLABL = int32(3);

% read the next 200 rows in char format (ct 256)
a0 = '                                                                                ';
label1 = 'BIO-AFM-LAB, AFM encoder v1';
label2 = 'doi:';
label3 = char(datetime);
a1 = a0;
a1(1:numel(label1)) = label1;
a2 = a0;
a2(1:numel(label2)) = label2;
a3 = a0;
a3(1:numel(label3)) = label3;
a = [a1; a2; a3];
for i = 4:10
a = [a; a0];
end
s.LABL = a;  % EMPTY rows

%% MRC/AFM1 file header struct writer
%%% open mrc file
f = fopen(filename + ".afm", "w");

%%% write the header
% write Word 1-56
ss = struct2cell(s);
for i = 1:numel(ss)-1
    value = cell2mat(ss(i));
    for j = 1:numel(value)
        a = value(j);
        fwrite(f, a, class(value));
    end
end

% write Word 57-256 10 * 80 char text labels
value = cell2mat(ss(end));
for j = 1:10
    a = value(j, :);
    fwrite(f, a, class(value));
end
%%% write the volume data
a = reshape(P, [s.NC*s.NR*s.NS, 1]);
fwrite(f, a, '*float32');
"AFM file encoded..."

%%% close mrc file
fclose(f);
