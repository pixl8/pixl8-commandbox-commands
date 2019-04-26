/**
 * Register credentials for Pixl8 MIS API
 * Calls (i.e. private package management)
 *
 **/
component {

	property name="pixl8Utils" inject="Pixl8Utils@pixl8-commandbox-commands";

	/**
	 * @accessKey.hint Access key
	 **/
	function run( string accessKey="" ) {
		while( !arguments.accesskey.len() ) {
			arguments.accessKey = shell.ask( "Enter your MIS Access key: " );
		}

		pixl8Utils.storeMisCredentials( argumentCollection=arguments );

		print.greenLine( "Thank you, credentials have been set." );

		return;
	}

}