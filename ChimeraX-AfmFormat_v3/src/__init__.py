# vim: set expandtab shiftwidth=4 softtabstop=4:
from chimerax.core.errors import UserError
from chimerax.core.toolshed import BundleAPI


# Subclass from chimerax.core.toolshed.BundleAPI and
# override the method for opening and saving files,
# inheriting all other methods from the base class.
class _MYAFMAPI(BundleAPI):

    api_version = 1

    # Implement provider methods for opening and saving files
    @staticmethod
    def run_provider(session, name, mgr):
        # 'run_provider' is called by a manager to invoke the 
        # functionality of the provider.  Since the "data formats"
        # manager never calls run_provider (all the info it needs
        # is in the Provider tag), we know that only the "open
        # command" or "save command" managers will call this
        # function, and customize it accordingly.
        #
        # The 'name' arg will be the same as the 'name' attribute
        # of your Provider tag, and mgr will be the corresponding
        # Manager instance
        #
        # For the "open command" manager, this method must return
        # a chimerax.open_command.OpenerInfo subclass instance.
        # For the "save command" manager, this method must return
        # a chimerax.save_command.SaverInfo subclass instance.
        #
        # The "open command" manager is also session.open_command,
        # and likewise the "save command" manager is
        # session.save_command.  We therefore decide what to do
        # by testing our 'mgr' argument...
        if mgr == session.open_command:
            from chimerax.open_command import OpenerInfo
            class AFMOpenerInfo(OpenerInfo):
                def open(self, session, data, path, **kw):
                    # The 'open' method is called to open a file,
                    # and must return a (list of models created,
                    # status message) tuple.
                    from .io import read_afm
                    try:
                        return read_afm(session, data)
                    except Exception as e:
                        session.logger.error("Failed to open AFM file: {}".format(str(e)))
                        raise UserError("Failed to open AFM file due to: {}".format(str(e)))

            return AFMOpenerInfo()

# Create the ``bundle_api`` object that ChimeraX expects.
bundle_api = _MYAFMAPI()
