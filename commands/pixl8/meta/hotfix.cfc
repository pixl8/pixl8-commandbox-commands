/**
 * Run a hotfix update on a meta package
 * Checking for all latest hotfixes of packages
 *
 **/
component {

	property name="JSONService" inject="JSONService";
	property name="pixl8Utils"  inject="pixl8Utils@pixl8-commandbox-commands";

	function run( directory=shell.pwd() ) {
		var fullPath = resolvePath( arguments.directory ) & "box.json";

		if ( !FileExists( fullPath ) ) {
			throw( "No box.json found at [#fullPath#]!" );
		}
		var boxJson = DeserializeJson( FileRead( fullPath ) );

		if ( !StructKeyExists( boxJson, "pixl8-meta-package" ) ) {
			print.yellowLine( "Package does not appear to be a pixl8 meta package. Nothing to do." );
		}

		var depsToCheck = boxJson[ "pixl8-meta-package" ].dependencies ?: {};
		var changesMade = false;

		print.greenLine( "Checking [#NumberFormat( StructCount( depsToCheck ) )#] dependencies for hotfix updates..." );

		for( var depId in depsToCheck ) {
			var upgradeReport = pixl8Utils.getLatestPackageVersionReport(
				  packageSlug     = depId
				, currentVersion  = depsToCheck[ depId ]
				, limitToHotfixes = true
			);

			if ( ( upgradeReport.skipped ?: false ) ) {
				print.yellowLine( "--> " & upgradeReport.reason );
				continue;
			}

			if ( ( upgradeReport.changed ?: false ) ) {
				print.yellowLine( "--> Upgrading [#depId#] from [#upgradeReport.oldVersion#] to [#upgradeReport.newVersion#]" );
				depsToCheck[ depId ] = upgradeReport.newVersion;
				changesMade = true;
			}
		}

		if ( changesMade ) {
			JSONService.writeJSONFile( fullPath, boxJson );
			print.greenLine( "All done! Changes made to your local box.json path. Commit to complete." );
		} else {
			print.greenLine( "All done! No changes made." );
		}

		return;
	}

}