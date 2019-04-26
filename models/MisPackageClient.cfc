/**
 * @singleton
 *
 */
component {

	property name="pixl8Utils" inject="pixl8Utils@pixl8-commandbox-commands";

	public struct function resolvePackage( required string package ) {
		var accessKey   = pixl8Utils.getMisCredentials();
		var endpoint    = pixl8Utils.getMisEndpoint();
		var packageSlug = ListFirst( arguments.package, "@" );
		var version     = ListRest( arguments.package, "@" );
		var result      = "";

		if ( !accessKey.len() ) {
			throw( "No access credentials have been setup for MIS. Use the 'pixl8 mis setcredentials' command to register your credentials.", 'endpointException' );
		}

		http url="#endpoint.reReplace( "/^", "" )#/api/forgebox/package/#packageSlug#/" method="GET" timeout=30 username=accessKey result="result" throwonerror=true {
			if ( Len( Trim( version ) ) ) {
				httpparam name="version" type="url" value=version;
			}
		}

		return DeserializeJson( result.filecontent );
	}

}