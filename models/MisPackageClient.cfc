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

	public struct function publish( required string filePath ) {
		var accessKey   = pixl8Utils.getMisCredentials();
		var endpoint    = pixl8Utils.getMisEndpoint();
		var result      = "";

		if ( !accessKey.len() ) {
			throw( "No access credentials have been setup for MIS. Use the 'pixl8 mis setcredentials' command to register your credentials.", 'endpointException' );
		}
		if ( !endpoint.len() ) {
			throw( "No endpoint has been registered for the pixl8 package provider. Use the 'pixl8 mis setendpoint' command to register your endpoint.", 'endpointException' );
		}

		http url="#endpoint.reReplace( "/^", "" )#/api/forgebox/publish/" method="POST" timeout=30 username=accessKey result="result" throwonerror=true {
			httpparam type="file" file=arguments.filePath name="packagefile";
		}

		return DeserializeJson( result.filecontent );
	}

}