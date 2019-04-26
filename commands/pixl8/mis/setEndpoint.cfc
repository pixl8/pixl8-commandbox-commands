/**
 * Register credentials for Pixl8 MIS API
 * Calls (i.e. private package management)
 *
 **/
component {

	property name="pixl8Utils" inject="Pixl8Utils@pixl8-commandbox-commands";

	/**
	 * @endpoint.hint Endpoint, i.e URL with no trailing slash
	 **/
	function run( string endpoint="" ) {
		while( !arguments.endpoint.len() ) {
			arguments.endpoint = shell.ask( "Enter your MIS endpoint (i.e. URL with no trailling slash): " );
		}

		pixl8Utils.storeMisEndpoint( argumentCollection=arguments );

		print.greenLine( "Thank you, endpoint has been set." );

		return;
	}

}