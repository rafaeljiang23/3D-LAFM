%%% decide the MRC/AFM1 data and record the variables into a matlab 
% struct file: 's'
%% parameters
% input .afm file name
filename = "test_A5_encoder_v1.afm";

%% open mrc file
f = fopen(filename, "r");
s = struct;

%% read the header
% read the first 10 rows in int32 format (ct 10)
a = fread(f,10,'*int32');
s.NC = a(1);
s.NR = a(2);
s.NS = a(3);
s.MODE = a(4);
s.NCSTART = a(5);
s.NRSTART = a(6);
s.NSSTART = a(7);
s.MX= a(8);
s.MY = a(9);
s.MZ = a(10);

% read the next 6 rows in float32 format (ct 16)
a = fread(f,6,'*float32');
s.CELLA = a(1:3);
s.CELLB = a(4:6);

% read the next 3 rows in int32 format (ct 19)
a = fread(f,3,'*int32');
s.MAPC = a(1);
s.MAPR = a(2);
s.MAPS = a(3);

% read the next 3 rows in float32 format (ct 22)
a = fread(f,3,'*float32');
s.DMIN = a(1);
s.DMAX = a(2);
s.DMEAN = a(3);

% read the next 4 rows in int32 format (ct 26)
a = fread(f,4,'*int32');
s.ISPG = a(1);
s.NSYMBT = a(2);
s.AFMRNPAR = a(3);
s.AFMRSYM = a(4);

% read the next 1 row in char format (ct 27)
a = fread(f,4,'*char');
s.EXTTYP = a';

% read the next 3 rows in int32 format (ct 30)
a = fread(f,3,'*int32');
s.NVERSION = a(1);
s.AFMRNX = a(2);
s.AFMRNY = a(3);


% read the next 3 rows in float32 format (ct 36)
a = fread(f,6,'*float32');
s.AFMRLX = a(1);
s.AFMRLY = a(2);
s.AFMRRESZ = a(3);
s.AFMRSVX = a(4);
s.AFMRSVY = a(5);
s.AFMDEXP = a(6);

% read the next 1 row in int32 format (ct 37)
a = fread(f,1,'*int32');
s.AFMDNDET = a(1);

% read the next 2 rows in float32 format (ct 39)
a = fread(f,2,'*float32');
s.AFMVRES = a(1);
s.AFMPRES = a(2);

% read the next 1 row in int32 format (ct 40)
a = fread(f,1,'*int32');
s.AFMPDFTYP = a(1);

% read the next 1 row in int32 format (ct 49)
a = fread(f,9,'*int32');
s.EXTRA = a;  % EMPTY rows

% read the next 3 rows in float32 format (ct 52)
a = fread(f,3,'*float32');
s.ORIGINi = a(1);
s.ORIGINj = a(2);
s.ORIGINk = a(3);

% read the next 1 row in char format (ct 53)
a = fread(f,4,'*char');
s.MAP = a';

% read the next 1 row in int32 format (ct 54)
a = fread(f,1,'*int32');
s.MACHST = a(1);

% read the next 1 row in float32 format (ct 55)
a = fread(f,1,'*float32');
s.RMS = a(1);

% read the next 1 row in int32 format (ct 56)
a = fread(f,1,'*int32');
s.NLABL = a(1);

% read the next 200 rows in char format (ct 256)
a = [];
for i = 1:10
a = [a; fread(f,80,'*char')'];
end
s.LABL = a;  % EMPTY rows

%% read the volume data
% read the volume data in float32 format
frewind(f);
fread(f, 256, "int32");
[a, ct] = fread(f,s.NC*s.NR*s.NS,'*float32');
P = reshape(a, [s.NC, s.NR, s.NS]);
% MIJ.createImage(P);

fread(f, 1, "*char")
if feof(f)
    "AFM file decoded..."
else
    warning("Error in file length...");
end

%% close mrc file
fclose(f);