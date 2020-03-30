/**
 * Scaffolds a new private Pixl8 Extension
 *
 **/
component {


	/**
	 * @directory.hint Directory in which extension will be scaffolded
	 *
	 **/
	function run( string directory = shell.pwd() ) {
		if ( !DirectoryExists( arguments.directory ) ) {
			return _printError( "Directory, [#arguments.directory#], does not exist" );
		}

		if ( DirectoryExists( arguments.directory & "/static" ) ) {
			return _printError( "Directory, [#arguments.directory#]/static already exists." );
		}

		command( "install" ).params(
			  id   = "pixl8:pixl8-static-skeleton"
			, save = false
		).run();

		print.line();
		print.greenLine( "**************************************************" );
		print.greenLine( "Your static site has been successfully scaffolded." );
		print.greenLine( "**************************************************" );
		print.line();

		return;
	}

// PRIVATE HELPERS
	private void function _printError( errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}
}