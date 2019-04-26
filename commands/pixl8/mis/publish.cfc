/**
 * Register credentials for Pixl8 MIS API
 * Calls (i.e. private package management)
 *
 **/
component {

	property name="misPackageClient" inject="misPackageClient@pixl8-commandbox-commands";

	/**
	 * @packageZipFile.hint Zipped archive of the package to publish
	 **/
	function run( required string packageZipFile ) {
		var fullPath = resolvePath( arguments.packageZipFile );

		if ( !FileExists( fullPath ) ) {
			throw( "Package file not found! [#fullPath#]" );
		}
		if ( !IsZipFile( fullPath ) ) {
			throw( "Package file is not a zip file! [#fullPath#]" );
		}

		var result = misPackageClient.publish( fullPath );

		if ( result.success ) {
			print.greenLine( result.message );
		} else {
			print.redLine( result.message );
		}


		return;
	}

}