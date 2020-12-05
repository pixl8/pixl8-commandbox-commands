/**
 * Register credentials for Pixl8 MIS API
 * Calls (i.e. private package management)
 *
 **/
component {

	property name="misPackageClient" inject="misPackageClient@pixl8-commandbox-commands";

	/**
	 * @directory.hint   Root directory of the package to publish (should contain box.json)
	 * @storagepath.hint Relative storage path to Pixl8 private s3 store of the package artifact
	 **/
	function run( required string directory, required string storagePath ) {
		var fullPath = resolvePath( arguments.directory );

		if ( !DirectoryExists( fullPath ) ) {
			throw( "Package file not found! [#fullPath#]" );
		}
		if ( !FileExists( fullPath & "/box.json" ) ) {
			throw( "No box.json found at! [fullPath & ""/box.json""]" );
		}

		var result = misPackageClient.publish( fullPath, storagePath );

		if ( result.success ) {
			print.greenLine( result.message );
		} else {
			print.redLine( result.message );
		}


		return;
	}

}