# vim: set expandtab shiftwidth=4 softtabstop=4:

from chimerax.core.errors import UserError
import numpy as np
import struct
from chimerax.map import Volume
from datetime import datetime
import os

def read_afm(session, path):
    """
    Read AFM data from a file and create models.
    
    Parameters:
    - session: The current ChimeraX session.
    - path: Path to the AFM file.
    """
    directory_path = "/Users/macbook/Desktop/AFMformat/"
    file_list = os.listdir(directory_path)
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
        
