# vim: set expandtab shiftwidth=4 softtabstop=4:

from chimerax.core.errors import UserError
import numpy as np
import struct

def read_afm(session, path):
    """
    Read AFM data from a file and create models.
    
    Parameters:
    - session: The current ChimeraX session.
    - path: Path to the AFM file.
    """
    try:
        with open(path, 'rb') as stream:
            # Since ChimeraX already has built-in support for MRC files,
            # we may not need to implement a custom reader if the AFM file
            # is fully compatible with the MRC format.
            # First, read and parse the custom extended header
            afm_extended_header_format = 'i i 2i 2i f 2f i i 2f i 36s'
            extended_header_size = struct.calcsize(afm_extended_header_format)
            extended_header_data = stream.read(extended_header_size)
            if len(extended_header_data) != extended_header_size:
                raise UserError('Unexpected end of file while reading AFM extended header.')
            
            # Unpack values from the extended header
            extended_header_values = struct.unpack(afm_extended_header_format, extended_header_data)
            
            # Unpack values from the extended header
            afmrnpar, afmrsym, afmrnx, afmrny, afmrlx, afmrly, afmrresz, \
            afmrsvx, afmrsvy, afmdexp, afmdndet, afmvres, afmpres, \
            afmpdftyp, _ = extended_header_values
            # Process the extended header values if needed
            # Now read the main volume data using ChimeraX's open_map function
            from chimerax.map import open_map
            models, status = open_map(session, path, format='mrc')
            return models, status
    except Exception as e:
        raise UserError(f"Error reading AFM file: {e}")
    
    
    
def save_afm(session, path, models, **kwargs):
    """Save models to an AFM file with a custom extended header."""
    # Assuming models is a list containing a single Volume item...
    model_to_save = session.models.list(model_id=model_id)
    if not models:
        raise UserError("No models provided for saving.")
    volume_model = models[0]
    
    # Extract grid data from the volume model
    grid_data = volume_model.data
    if not isinstance(grid_data, ArrayGridData):
        raise UserError("Unsupported volume data type for AFM saving.")
    
    # Convert grid data to a numpy array if it isn't already one
    volume_data = grid_data.full_matrix()
    
    from chimerax.map_data import ArrayGridData
    
    # Implement saving here if the AFM file has a custom format.
    # Prepare the extended header data.
    # The values should be obtained from your models or session, or be a constant
    afmrnpar = 171  # number of raw frames
    afmrsym = 3     # raw single-particle AFM frames
    afmrnx = 64     # raw single-particle size in x
    afmrny = 64     # raw single-particle size in y
    afmrlx = 160    # raw size in x in angstroms
    afmrly = 160    # raw size in y in angstroms
    afmrresz = 0.25 # estimated resolution in z
    afmrsvx = 6.0000003e-04 # data acquisition speed in x
    afmrsvy = 1.7999999e-06 # data acquisition speed in y
    afmdexp = 15    # interpolation expansion scale
    afmdndet = 35971 # total count LAFM detections
    afmvres = 1.1000000 # resolution of detection stack V
    afmpres = 1.4000000 # resolution of density map P
    afmpdftyp = 0   # density function type

    extra_space = b'\x00' * 36
    
    afm_values = (
    afmrnpar, afmrsym, 
    afmrnx, afmrny,   
    afmrlx, afmrly, afmrresz, 
    afmrsvx, afmrsvy, afmdexp,  
    afmdndet, afmvres, afmpres, 
    afmpdftyp, extra_space)

    # Format string for the AFM extended header
    afm_extended_header_format = 'i i 2i 2i f 2f i i 2f i 36s'
    
    # Pack AFM data into bytes
    afm_extended_header_bytes = struct.pack(afm_extended_header_format, *afm_values)
    
    extended_header_array = np.frombuffer(afm_extended_header_bytes, dtype=np.uint8)
    
    # Open the file for writing in binary mode
    with open(path, 'wb') as file:
        # Write the extended header
        file.write(afm_extended_header_bytes)

        # Write the actual volume data
        # You will need to convert volume_data to the correct byte format
        volume_data_bytes = volume_data.tobytes()
        file.write(volume_data_bytes)

    session.logger.info(f"AFM file saved to {path}")
    
    
