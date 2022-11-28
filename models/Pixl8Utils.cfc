component {
	property name="configService" inject="configService";
	property name="misPackageClient" inject="misPackageClient@pixl8-commandbox-commands";
	property name="endPointService"  inject="endPointService";

	function init() {
		return this;
	}

	public void function storeMisCredentials( required string accessKey ) {
		configService.setSetting( "pixl8credentials.accesskey", arguments.accessKey );
	}

	public string function getMisCredentials() {
		return configService.getSetting( "pixl8credentials.accesskey", "" );
	}

	public void function storeMisEndpoint( required string endpoint ) {
		configService.setSetting( "pixl8credentials.endpoint", arguments.endpoint );
	}

	public string function getMisEndpoint() {
		return configService.getSetting( "pixl8credentials.endpoint", "" );
	}

	public struct function getLatestPackageVersionReport(
		  required string  packageSlug
		, required string  currentVersion
		,          boolean limitToHotfixes = false
	) {
		var provider            = "forgebox";
		var cleanCurrentVersion = "";
		var resolvedVersion     = "";
		var versionToResolve    = "stable";

		if ( ListFirst( currentVersion, ":" ) == "pixl8" ) {
			provider = "pixl8";
			cleanCurrentVersion = ListFirst( ListLast( currentVersion, "@" ), "+" );
		} else if ( reFindNoCase( "^[0-9]+\.[0-9]+.[0-9+]", currentVersion ) ) {
			cleanCurrentVersion = ListFirst( currentVersion, "+" );
		} else {
			return { skipped=true, reason="Skipping [#packageSlug#] check, [#currentVersion#] not a provider we support." }
		}

		if ( ListLen( cleanCurrentVersion, "." ) != 3 ) {
			return { skipped=true, reason="Skipping [#packageSlug#] check, [#cleanCurrentVersion#] not a pattern we recognise." }
		}

		if ( limitToHotfixes ) {
			versionToResolve = "#ListFirst( cleanCurrentVersion, "." )#.#ListGetAt( cleanCurrentVersion, 2, "." )#";
		}

		var resolvedReport = {};
		switch( provider ) {
			case "pixl8":
				resolvedReport = misPackageClient.resolvePackage( packageSlug, versionToResolve );
			break;
			case "forgebox":
				resolvedReport = endpointService.getEndpoint( "forgebox" ).findSatisfyingVersion( packageSlug, versionToResolve );
			break;
		}
		var resolvedVersion = ListFirst( resolvedReport.version ?: "", "+" );

		if ( ListLen( resolvedVersion, "." ) < 3 ) {
			return { skipped=true, reason="Skipping [#packageSlug#] check, resolved version [#resolvedVersion#] not expected semver string." }
		} else if ( ListLen( resolvedVersion, "." ) > 3 ) {
			resolvedVersion = ReReplace( resolvedVersion, "^([0-9]+\.[0-9]+\.[0-9]+)\..*$", "\1" );
		}

		var changed = resolvedVersion != cleanCurrentVersion;
		if ( provider == "pixl8" ) {
			resolvedVersion = "pixl8:#packageSlug#@#resolvedVersion#";
		}

		return {
			  changed    = changed
			, oldVersion = cleanCurrentVersion
			, newVersion = resolvedVersion
		}
	}
}