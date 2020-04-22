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

		//choose admin or site
		var appType = "";

		var appTypeList = "site,webapp,rest" 

		print.line();
		print.line( "Available site templates from which to build your new site/application:" );

		print.text( " * " );
		print.yellowText( "site" );
		print.line( ": Pixl8 Website template." );

		print.text( " * " );
		print.yellowText( "webapp" );
		print.line( ":  Web applications that are purely admin based." );

		print.text( " * " );
		print.yellowText( "rest" );
		print.line( ": REST webservice application." );


		while( !listFindNoCase( appTypeList , appType) ) {
			appType = LCase(ask( "Enter site template: " ));
		}
		switch(LCase(appType)){

		case "webapp":

			var webDir = ListAppend( arguments.directory, "website", "/" );
			
			command( "preside new site" ).params(
				skeleton = "preside-skeleton-webapp"
			).run();

			break;

		
		case "rest":
			var webDir = ListAppend( arguments.directory, "website", "/" );
			

			command( "preside new site" ).params(
				skeleton = "preside-skeleton-rest"
			).run();

			break;
		
		case "site":
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
			if( FileExists( webDir & "/_buildgitignore") ) FileMove( webDir & "/_buildgitignore", arguments.directory & "/build/.gitignore" );


			FileMove( webDir & "/Dockerfile", arguments.directory & "/Dockerfile" );
			FileMove( webDir & "/docker-compose.yml", arguments.directory & "/docker-compose.yml" );
			FileMove( webDir & "/.gitlab-ci.yml", arguments.directory & "/.gitlab-ci.yml" );
			if( FileExists( webDir & "/docker-compose-dev.yml") ) FileMove( webDir & "/docker-compose-dev.yml", arguments.directory & "/docker-compose-dev.yml" );
			if( FileExists( webDir & "/docker-sync.yml") ) FileMove( webDir & "/docker-sync.yml", arguments.directory & "/docker-sync.yml" );
			if( FileExists( webDir & "/_rootgitignore") ) FileMove( webDir & "/_rootgitignore", arguments.directory & "/.gitignore" );

			break;

		}

		return;
	}

// PRIVATE HELPERS
	private void function _printError( errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}
}