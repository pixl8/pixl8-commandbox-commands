/**
 * Checks for package compatibility issues in your application
 *
 **/
component {

	property name="misPackageClient" inject="misPackageClient@pixl8-commandbox-commands";

	/**
	 * @reportFile Full path to the report file to generate - no file is generated if there are no problems
	 *
	 */
	function run( required string reportFile ) {
		var fullPath = shell.pwd();
		var packages = [];
		var boxJsonFiles = DirectoryList(
			  path    = fullPath
			, recurse = true
			, listinfo = "path"
			, filter = "*box.json"
			, type   = "file"
		);

		for( var filePath in boxJsonFiles ) {
			try {
				var packageInfo = DeserializeJson( FileRead( filePath ) );
				packages.append({
					  id      = packageInfo.slug
					, version = packageInfo.version
				});
			} catch( any e ) {}
		}

		if ( !ArrayLen( packages ) ) {
			return;
		}

		var result = misPackageClient.checkPackages( packages );

		if ( IsBoolean( result.ok ?: "" ) && result.ok || !IsArray( result.alerts ?: "" ) || !ArrayLen( result.alerts ) ) {
			print.line( '{ "result":"ok" }' );
		} else {
			var criticalCount = 0;
			var warningCount = 0;
			for( var alert in result.alerts ) {
				if ( alert.alert_severity == "critical" ) {
					criticalCount++;
				} else {
					warningCount++;
				}
			}
			var reportContent = "";
			var resultString  = criticalCount ? "critical" : "warning";
			savecontent variable="reportContent" {
				module template="_helpers/packageReport.cfm" alerts=result.alerts criticalCount=criticalCount warningCount=warningCount;
			}
			FileWrite( arguments.reportFile, Trim( reportContent ) );

			print.line( '{ "result":"#resultString#", "reportFile":"#arguments.reportFile#" }' );
		}

		return;
	}

}