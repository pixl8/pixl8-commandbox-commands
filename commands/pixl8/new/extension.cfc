/**
 * Scaffolds a new private Pixl8 Extension
 *
 **/
component {


	/**
	 * @title.hint        Extension name
	 * @slug.hint         Extension slug (without preside-ext-)
	 * @repoUrl.hint      Repository URL (without .git)
	 * @slackChannel.hint Slack channel for build notifications, e.g. builds
	 * @directory.hint    Directory in which extension will be scaffolded
	 *
	 **/
	function run(
		  required string name
		, required string slug
		, required string repoUrl
		, required string slackChannel
		,          string directory = shell.pwd()
	) {
		if ( !_validSlug( arguments.slug ) ) {
			return _printError( "Invalid slug. Extension slug must contain alphanumerics, underscores and hyphens only." );
		}
		if ( !DirectoryExists( arguments.directory ) ) {
			return _printError( "Directory, [#arguments.directory#], does not exist" );
		}

		_unpackSkeleton( arguments.directory );
		_replacePlaceholdersWithArgs( argumentCollection=arguments );

		print.line();
		print.greenLine( "************************************************" );
		print.greenLine( "Your extension has been successfully scaffolded." );
		print.greenLine( "************************************************" );
		print.line();

		return;
	}

// PRIVATE HELPERS
	private boolean function _validSlug( required string slug ) {
		return ReFindNoCase( "^[a-z0-9-_]+$", arguments.slug );
	}

	private void function _printError( errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}

	private void function _unpackSkeleton( required string directory ) {
		var source = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "/../../../resources/extension";

		DirectoryCopy( source, arguments.directory, true );
	}

	private void function _replacePlaceholdersWithArgs(
		  required string name
		, required string slug
		, required string repoUrl
		, required string slackChannel
		, required string directory
	) {
		var filePaths = [
			  arguments.directory & "/manifest.json"
			, arguments.directory & "/box.json"
			, arguments.directory & "/.gitlab-ci.yml"
			, arguments.directory & "/README.md"
		];

		for( var filePath in filePaths ) {
			var fileContent = FileRead( filePath );

			fileContent = ReplaceNoCase( fileContent, "EXTENSIONSLUG", arguments.slug        , "all" );
			fileContent = ReplaceNoCase( fileContent, "EXTENSIONNAME", arguments.name        , "all" );
			fileContent = ReplaceNoCase( fileContent, "EXTENSIONURL" , arguments.repoUrl     , "all" );
			fileContent = ReplaceNoCase( fileContent, "BUILDCHANNEL" , arguments.slackChannel, "all" );

			FileWrite( filePath, fileContent );
		}
	}

}