/**
 * @singleton
 *
 */
component {

	property name="pixl8Utils" inject="pixl8Utils@pixl8-commandbox-commands";

	public struct function resolvePackage( required string slug, required string version ) {
		var accessKey   = pixl8Utils.getMisCredentials();
		var endpoint    = pixl8Utils.getMisEndpoint();
		var result      = "";

		if ( !accessKey.len() ) {
			throw( "No access credentials have been setup for MIS. Use the 'pixl8 mis setcredentials' command to register your credentials.", 'endpointException' );
		}
		if ( !endpoint.len() ) {
			throw( "No endpoint has been registered for the pixl8 package provider. Use the 'pixl8 mis setendpoint' command to register your endpoint.", 'endpointException' );
		}

		http url="#endpoint.reReplace( "/^", "" )#/api/forgebox/package/#arguments.slug#/" method="GET" timeout=30 username=accessKey result="result" throwonerror=true {
			if ( Len( Trim( arguments.version ) ) ) {
				httpparam name="version" type="url" value=arguments.version;
			}
		}

		return DeserializeJson( result.filecontent );
	}

	public struct function publish( required string directory, required string storagePath ) {
		var accessKey   = pixl8Utils.getMisCredentials();
		var endpoint    = pixl8Utils.getMisEndpoint();
		var result      = "";
		var boxjson     = FileRead( arguments.directory & "/box.json" );
		var changelog   = "";
		var readme      = "";

		if ( !accessKey.len() ) {
			throw( "No access credentials have been setup for MIS. Use the 'pixl8 mis setcredentials' command to register your credentials.", 'endpointException' );
		}
		if ( !endpoint.len() ) {
			throw( "No endpoint has been registered for the pixl8 package provider. Use the 'pixl8 mis setendpoint' command to register your endpoint.", 'endpointException' );
		}

		var readmeFiles = [ "README.md", "README.MD" ];
		var changelogFiles = [ "changelog.txt", "CHANGELOG.md", "CHANGELOG.MD" ];

		for( var filename in readmeFiles ) {
			if ( FileExists( arguments.directory & "/#filename#" ) ) {
				readme = FileRead( arguments.directory & "/#filename#" );
				break;
			}
		}
		for( var filename in changelogFiles ) {
			if ( FileExists( arguments.directory & "/#filename#" ) ) {
				changelog = FileRead( arguments.directory & "/#filename#" );
				break;
			}
		}

		http url="#endpoint.reReplace( "/^", "" )#/api/forgebox/publish/" method="POST" timeout=30 username=accessKey result="result" {
			httpparam type="formfield" name="boxjson"     value=boxjson;
			httpparam type="formfield" name="storagepath" value=arguments.storagePath;
			httpparam type="formfield" name="readme"      value=readme;
			httpparam type="formfield" name="changelog"   value=changelog;
		}

		return DeserializeJson( result.filecontent );
	}

}