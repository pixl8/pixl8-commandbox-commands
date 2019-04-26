/**
 * Register credentials for Pixl8 MIS API
 * Calls (i.e. private package management)
 *
 **/
component {

	property name="pixl8Utils" inject="Pixl8Utils@pixl8-commandbox-commands";

	/**
	 * @endpoint.hint Endpoint, e.g. https://mis.pixl8.london, or a local address for testing
	 **/
	function run( string endpoint="" ) {
		while( !arguments.endpoint.len() ) {
			arguments.endpoint = shell.ask( "Enter your MIS endpoint (i.e. https://mis.pixl8.london): " );
		}

		pixl8Utils.storeMisEndpoint( argumentCollection=arguments );

		print.greenLine( "Thank you, endpoint has been set." );

		return;
	}

}