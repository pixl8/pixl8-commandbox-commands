component {
	property name="configService" inject="configService";

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
		return configService.getSetting( "pixl8credentials.endpoint", "https://mis.pixl8.london" );
	}
}