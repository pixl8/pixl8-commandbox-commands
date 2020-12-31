component extends="testbox.system.BaseSpec" {

	function run( testResults, testBox ) {
		describe( "tests()", function() {
			it( "should all pass", function() {
				expect( true ).toBe( true );
			} );
		} );
	}
}