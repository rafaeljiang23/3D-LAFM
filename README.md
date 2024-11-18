# 3D-LAFM
This is a workflow to construct 3D-LAFM density maps, build 3D-LAFM-MDFF force fields (UAFM), and encode/decode '.afm' (AFM1) files from (HS-)AFM experiments. The codes are developed in BIO-AFM-LAB at Weill Cornell Medicine under the supervision of Professor Simon Scheuring.

Developer: Yining Jiang, Zhaokun Wang

Publication: XXXXX

User should email to the corresponding author of the paper for details about this work: Professor Simon Scheuring (sis2019@med.cornell.edu)

NOTE: Any usage of the codes should cite the publication mentioned above.

## System requirements:
1. Operating system for code development : macOS Big Sur Version 11.7.8
2. Software for code development: MATLAB (MathWorks) 2023b, Python 3.9.6
3. Additional add-ons: MIJI
4. Non-standard hardware: N/A

## Installation instructions: 
1. The codes require installation of MATLAB (MathWorks) 2023b. An installation guide can be found at: https://www.mathworks.com/help/install/.
2. MIJI is recommanded (not required) for visualizing data. An installation guide can be found at: https://www.mathworks.com/matlabcentral/fileexchange/47545-mij-running-imagej-and-fiji-within-matlab. If MIJI is not installed, user should comment out any code that uses MIJI for visualization (lines starting sith "MIJ.xxx").
3. The codes require installation of Python 3.9.6.
4. The installation should take less than one hour on a "normal" desktop computer.

## General instructions:
These codes comprise of four parts:
### 1. 3D-LAFM 
Note: These codes are developed to construct 3D-LAFM detection stack (voxels) 3D-LAFM density maps (voxels_hs) from (HS-)AFM data.
#### Main scripts:
1. tDLAFM_script_v12b.m (tDLAFM_script_v12b.m provides more details about tDLAFM_script_v12.m, No modifications or amendments have been made to the code) 
#### Helper functions:
1. tDAFM_voxels_v4.m
2. tDAFM_v12b_algo_conv.m
3. tDAFM_v12_algo_voxels.m
4. tDAFM_locate_detections_v4.m
5. tDAFM_align_detecitons2.m
6. make_3D_LAFM_kernel1a.m

#### Instruction
User should run the main scripts. Operation details are provided within the scripts.

### 2. AFM1 format
Note: These codes are developed to encode or decode '.afm' (AFM1) file. The '.afm' (AFM1) file encodes 3D-LAFM density maps (voxels_hs), where file format detials should be found in the "Methods" section of the manuscript.
#### Main scripts:
1. afm_decoder_v1.m
2. afm_encoder_v1.m

#### Helper functions:
N/A

#### Instruction
User should run the main scripts. Operation details are provided within the scripts.

### 3. ChimeraX-AfmFormat_v2
Note: These codes are developed to allow direct access to '.afm' file using ChimeraX (UCSF).
Note: ChimeraX-AfmFormat (original version) has a bug for Windows system, which has been solved in version 2.
#### Main scripts:
N/A

#### Helper functions:
N/A

#### Instruction
User should download the entire bundle (ChimeraX-AfmFormat_v2) and the UCSF ChimeraX software. Operation details are provided in the "Methods" sections of the manuscript and its supplementary materials file. 

### 4. UAFM force field
Note: These codes are developed to construct AFM force field UAFM for 3D-LAFM-MDFF simulations
#### Main scripts:
1. UAFM_tDLAFM_MDFF_script_v2b.m  (UAFM_tDLAFM_MDFF_script_v2b.m provides more details about UAFM_tDLAFM_MDFF_script_v2.m, No modifications or amendments have been made to the code) 

#### Helper functions:
N/A

#### Instruction
User should run the main scripts. Operation details are provided within the scripts.

## Demo (Test data)
Test data for each part (if applicable) is provided as a 'test_input.mat' file. Essential output files could be found in 'test_output.mat' files.
The test files enable users to work on 3D-LAFM density construction from HS-AFM single-particle images of A5 molecules (64x64x171), and subsequently use the density to encode a '.afm' file for visualization and analysis in ChimeraX as well as to build UAFM force field for 3D-LAFM-MDFF. 
Details about 3D-LAFM-MDFF could be found in the "Methods" sections of the manuscript and its supplementary materials file. Details about MDFF could be found at: https://www.ks.uiuc.edu/Research/mdff/method.html.
These tests are expected to run for less than one hour for demo on a "normal" desktop computer following the instructions provided in the main scripts, except for 3D-LAFM-MDFF setups and simulations. 

## Instruction for use
User should construct raw AFM single-particle image stack from flattened AFM data, which should be read in MATLAB as the 'data' variable, and provide the alignment information, which should be read in MATLAB as the 'alignment' variable. Details about the input data dimensions and requirements are provided in the main scripts. User should record the (HS-)AFM experimental details for '.afm' file encoding. User should generate pseudo-density '.mrc' files from PDB structures, which shall be used in MATLAB for UAFM construction.
User should adjust the parameters in the main scripts accourding to the nature of their proteins of interest.
