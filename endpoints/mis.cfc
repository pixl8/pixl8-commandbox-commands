/**
*********************************************************************************
* Copyright Since 2014 CommandBox by Ortus Solutions, Corp
* www.coldbox.org | www.ortussolutions.com
********************************************************************************
* @author Brad Wood, Luis Majano, Denny Valliant
*
* I am the file endpoint.  I get packages from a local file.
*/
component accessors="true" implements="commandbox.system.endpoints.IEndpoint" singleton {

	property name="consoleLogger"    inject="logbox:logger:console";
	property name="pixl8Utils"       inject="pixl8Utils@pixl8-commandbox-commands";
	property name="misPackageClient" inject="misPackageClient@pixl8-commandbox-commands";
	property name="httpsResolver"    inject="commandbox.system.endpoints.HTTPS";
	property name="httpResolver"     inject="commandbox.system.endpoints.HTTP";
	property name="fileResolver"     inject="commandbox.system.endpoints.file";

	property name="namePrefixes" type="string";

	function init() {
		setNamePrefixes( 'mis' );

		return this;
	}

	public string function resolvePackage( required string package, boolean verbose=false ) {
		var packageDetails = misPackageClient.resolvePackage( arguments.package );

		switch( ListFirst( packageDetails.downloadUrl ?: "", ":" ) ) {
			case "https":
				return httpsResolver.resolvePackage( argumentCollection=arguments, package=packageDetails.downloadUrl );
			case "http":
				return httpResolver.resolvePackage( argumentCollection=arguments, package=packageDetails.downloadUrl );
			case "file":
				return fileResolver.resolvePackage( argumentCollection=arguments, package=packageDetails.downloadUrl );
		}

		throw( "There was an error resolving a download URL for your package [#arguments.package#]. Package details: [#SerializeJson( packageDetails )#]", 'endpointException' );
	}

	/**
	* Determines the name of a package based on its ID if there is no box.json
	*/
	public function getDefaultName( required string package ) {
		return arguments.package.listLast( "/" );
	}

	public function getUpdate( required string package, required string version, boolean verbose=false ) {
		consoleLogger.info( "not implemented!" );

		return false;
	}

}
