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

		var existingFiles = DirectoryList( arguments.directory, true, "path" );
		if ( existingFiles.len() ) {
			return _printError( "Directory, [#arguments.directory#] is not empty." );
		}

		// scaffold the static dir
		command( "pixl8 new static" ).run();

		// create and scaffold the website dir
		var webDir = ListAppend( arguments.directory, "website", "/" );
		DirectoryCreate( webDir );
		shell.cd( webDir );

		command( "preside new site" ).params(
			skeleton = "pixl8:pixl8-website-skeleton"
		).run();

		shell.cd( arguments.directory );

		DirectoryCreate( arguments.directory & "/build" );
		FileWrite(  arguments.directory & "/build/.gitignore", "*
!.gitignore
" );
		FileMove( webDir & "/Dockerfile", arguments.directory & "/Dockerfile" );
		FileMove( webDir & "/docker-compose.yml", arguments.directory & "/docker-compose.yml" );
		FileMove( webDir & "/.gitlab-ci.yml", arguments.directory & "/.gitlab-ci.yml" );

		return;
	}

// PRIVATE HELPERS
	private void function _printError( errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}
}