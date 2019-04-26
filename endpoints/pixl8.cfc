/**
*********************************************************************************
* Copyright Since 2014 CommandBox by Ortus Solutions, Corp
* www.coldbox.org | www.ortussolutions.com
********************************************************************************
* @author Brad Wood, Luis Majano, Denny Valliant
*
* I am the file endpoint.  I get packages from a local file.
*/
component accessors="true" implements="commandbox.system.endpoints.IEndpoint" {

	property name="consoleLogger"    inject="logbox:logger:console";
	property name="pixl8Utils"       inject="pixl8Utils@pixl8-commandbox-commands";
	property name="misPackageClient" inject="misPackageClient@pixl8-commandbox-commands";
	property name="semanticVersion"  inject="provider:semanticVersion@semver";
	property name="artifactService"  inject="ArtifactService";
	property name='wirebox'          inject='wirebox';
	property name="endpointService"  inject="endpointService";
	property name="fileResolver"     inject="commandbox.system.endpoints.file";

	property name="namePrefixes" type="string";

	function init() {
		setNamePrefixes( 'pixl8' );

		return this;
	}

	public string function resolvePackage( required string package, boolean verbose=false ) {
		var job        = wirebox.getInstance( 'interactiveJob' );
		var slug 	   = parseSlug( arguments.package );
		var artifactSlug = "pixl8:#slug#";
		var version    = parseVersion( arguments.package );
		var strVersion = semanticVersion.parseVersion( version );

		if( semanticVersion.isExactVersion( version ) && artifactService.artifactExists( artifactSlug, version ) && strVersion.preReleaseID != 'snapshot' ) {
			job.addLog( "Package found in local artifacts!");
			return fileResolver.resolvePackage( artifactService.getArtifactPath( artifactSlug, version ), arguments.verbose );
		}

		job.addLog( "Verifying package '#slug#' in MIS, please wait..." );
		var packageDetails = misPackageClient.resolvePackage( slug, version );

		if( artifactService.artifactExists( artifactSlug, version ) || strVersion.preReleaseID == 'snapshot' ) {
			job.addLog( "Package found in local artifacts!");

			return fileResolver.resolvePackage( artifactService.getArtifactPath( artifactSlug, version ), arguments.verbose );

		} else {
			var endpointData = endpointService.resolveEndpoint( packageDetails.downloadUrl, 'fakePath', slug, version );

			job.addLog( "Deferring to [#endpointData.endpointName#] endpoint for ForgeBox entry [#slug#]..." );

			var packagePath = endpointData.endpoint.resolvePackage( endpointData.package, arguments.verbose );

			job.addLog( "Storing download in artifact cache..." );

			// Store it locally in the artfact cache
			artifactService.createArtifact( artifactSlug, version, packagePath );

			return packagePath;
		}
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


	/**
	* Parses just the slug portion out of an endpoint ID
	* @package The full endpointID like foo@1.0.0
	*/
	public function parseSlug( required string package ) {
		var matches = REFindNoCase( "^([a-zA-Z][\w\-\.]*(?:\@(?!stable\b)(?!be\b)[a-zA-Z][\w\-]*)?)(?:\@(.+))?$", package, 1, true );
		if ( arrayLen( matches.len ) < 2 ) {
			throw(
				type = "endpointException",
				message = "Invalid slug detected.  Slugs can only contain letters, numbers, underscores, and hyphens. They may also be prepended with an @ sign for private packages"
			);
		}
		return mid( package, matches.pos[ 2 ], matches.len[ 2 ] );
	}

	/**
	* Parses just the version portion out of an endpoint ID
	* @package The full endpointID like foo@1.0.0
	*/
	public function parseVersion( required string package ) {
		var version = 'stable';
		// foo@1.0.0
		var matches = REFindNoCase( "^([a-zA-Z][\w\-\.]*(?:\@(?!stable\b)(?!be\b)[a-zA-Z][\w\-]*)?)(?:\@(.+))?$", package, 1, true );
		if ( matches.pos.len() >= 3 && matches.pos[ 3 ] != 0 ) {
			// Note this can also be a semver range like 1.2.x, >2.0.0, or 1.0.4-2.x
			// For now I'm assuming it's a specific version
			version = mid( package, matches.pos[ 3 ], matches.len[ 3 ] );
		}
		return version;
	}

}
