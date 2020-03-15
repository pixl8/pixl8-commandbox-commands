/**
 * Scaffold basic structure of the docs for any project
 *
 **/
component {

	/**
	 * @directory.hint    Directory in which docs will be scaffolded
	 *
	 **/
	function run( string directory = "#shell.pwd()#docs" ) {
		if ( DirectoryExists( arguments.directory ) ) {
			return _printError( "Directory [#arguments.directory#] already existed" );
		}

		_unpackSkeleton( arguments.directory );
		_replacePlaceholdersWithArgs( argumentCollection=arguments );

		print.line();
		print.greenLine( "*****************************************************" );
		print.greenLine( "Your docs structure has been successfully scaffolded." );
		print.greenLine( "*****************************************************" );
		print.line();

		return;
	}

// PRIVATE HELPERS
	private void function _printError( errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}

	private void function _unpackSkeleton( required string directory ) {
		var source = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "/../../../resources/docs";

		DirectoryCopy( source, arguments.directory, true );
		FileWrite( arguments.directory & "/.gitignore", "_site
.sass-cache
.jekyll-cache
.jekyll-metadata
vendor
Gemfile.lock
" );
	}

	private void function _replacePlaceholdersWithArgs(
		  required string name = ListLast( shell.pwd(), "\/" )
		, required string directory
	) {
		var filePaths = [
			  arguments.directory & "/index.markdown"
			, arguments.directory & "/about.markdown"
			, arguments.directory & "/_config.yml"
		];

		for( var filePath in filePaths ) {
			var fileContent = FileRead( filePath );

			fileContent = ReplaceNoCase( fileContent, "PROJECTNAME", arguments.name, "all" );

			FileWrite( filePath, fileContent );
		}
	}

}