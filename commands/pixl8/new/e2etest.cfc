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

		if ( DirectoryExists( arguments.directory & "/test" ) ) {
			return _printError( "Directory, [#arguments.directory#]/test already exists." );
		}

		command( "install" ).params(
			  id   = "pixl8:pixl8-e2e-test-skeleton"
			, save = false
		).run();

		print.line();
		print.greenLine( "**************************************************" );
		print.greenLine( "Your E2E test has been successfully scaffolded." );
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