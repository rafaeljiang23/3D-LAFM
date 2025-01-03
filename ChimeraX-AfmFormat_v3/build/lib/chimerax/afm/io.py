# vim: set expandtab shiftwidth=4 softtabstop=4:

from chimerax.core.errors import UserError
import numpy as np
import struct
from chimerax.map import Volume
from datetime import datetime
import os

def read_afm(session, path):
    if not path:
        raise UserError("Path to the AFM file was not provided.")
    
    # Normalize the path and ensure it's absolute
    path = os.path.abspath(path)
    session.logger.info(f"Attempting to read from normalized path: {path}")

    if not os.path.exists(path):
        session.logger.error(f"No such file: {path}")
        raise UserError(f"No such file: {path}")
    
    directory_path = os.path.dirname(path)
    try:
        file_list = os.listdir(directory_path)
    except PermissionError as e:
        session.logger.error(f"Permission denied when accessing directory: {directory_path}")
        raise UserError(f"Permission denied: {e}")

    session.logger.info(f"Files in directory: {file_list}")

    try:
        with open(path, 'rb') as stream:
            session.logger.info("File opened successfully")
            
            afm_extended_header_format = 'i i 2i 2i f 2f i i 2f i 36s'
            extended_header_size = struct.calcsize(afm_extended_header_format)
            extended_header_data = stream.read(extended_header_size)
            if len(extended_header_data) != extended_header_size:
                raise UserError('Unexpected end of file while reading AFM extended header.')
            
            extended_header_values = struct.unpack(afm_extended_header_format, extended_header_data)
            from chimerax.map import open_map
            models, status = open_map(session, path, format='mrc')
            session.logger.info(f"AFM file loaded successfully: {models}")
            return models, status
    except Exception as e:
        session.logger.error(f"Error reading AFM file: {e}" )
        raise UserError(f"Error reading AFM file: {e}")

