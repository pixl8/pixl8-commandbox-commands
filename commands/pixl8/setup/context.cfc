/**
 * Scaffolds a new private Pixl8 Extension
 *
 **/
component {

	property name="packageService"  inject="provider:packageService";

	/**
	 * @directory.hint Directory in which the project will be setup
	 *
	 **/
	function run( string directory = shell.pwd() ) {
		if ( !DirectoryExists( arguments.directory ) ) {
			return _printError( "Directory, [#arguments.directory#], does not exist" );
		}

		if ( !FileExists( arguments.directory & "/.gitlab-ci.yml" ) ) {
			return _printError( "This does not appear to be the root directory of a Pixl8 project. expected .gitlab-ci.yml to be present." );
		}


		var gitignoreFile = arguments.directory & "/.gitignore";
		var claudeMdFile  = arguments.directory & "/CLAUDE.md";
		var boxJson       = arguments.directory & "/box.json";
		var webBoxJson    = arguments.directory & "/website/box.json";

		if ( FileExists( boxJson ) ) {
			var boxJsonContent = DeserializeJson( FileRead( boxJson ) );
			if ( Len( boxJsonContent.devDependencies[ "pixl8-agent-coding-context" ] ?: "" ) ) {
				print.line( "This project already appears to have been setup. Ensuring that we have the latest version of the agent coding context installed locally..." );
				packageService.installPackage(
					  id                         = "pixl8:pixl8-agent-coding-context@stable"
					, save                       = true
					, saveDev                    = true
					, production                 = false
					, currentWorkingDirectory    = arguments.directory
				);
				return;
			}
		}

		_printWarning( "This command will ensure latest agent coding context is installed and basic project structure is setup. IF CHANGES ARE MADE TO THE REPO: THESE SHOULD BE COMMITTED AS A HOTFIX AND MERGED INTO YOUR WORKING BRANCHES ONCE COMPLETE.");
		print.line();
		print.line( "1. Installing latest agent coding context..." );

		packageService.installPackage(
			  id                         = "pixl8:pixl8-agent-coding-context@stable"
			, save                       = true
			, saveDev                    = true
			, production                 = false
			, currentWorkingDirectory    = arguments.directory
		);

		print.line();
		print.greenLine( "-> Done installing latest agent coding context." );

		print.line();
		print.line( "2. Setting up .gitignore rules..." );
		if ( !FileExists( gitignoreFile ) ) {
			FileWrite( gitignoreFile, ".claude/pixl8-agent-coding-context" );
		} else {
			if ( !(FileRead( gitignoreFile ) contains ".claude/pixl8-agent-coding-context" ) ) {
			    FileAppend( gitignoreFile, ".claude/pixl8-agent-coding-context" );
			}
		}
		print.greenLine( "-> Done installing latest agent coding context." );


		print.line();
		print.line( "3. Setting up CLAUDE.md file..." );

		var claudeMdContextInstructions = "#### Pixl8 Preside Development Context#Chr( 10 )##Chr( 10 )#For framework reference, see @.claude/pixl8-agent-coding-context/CLAUDE.md";
		if ( !FileExists( claudeMdFile ) ) {
			var projectName = ListLast( arguments.directory, "/" );
			if ( FileExists( webBoxJson ) ) {
				var webBoxJsonContent = DeserializeJson( FileRead( webBoxJson ) );
				projectName = webBoxJsonContent.name ?: projectName;
			}
			var claudeMdContent = "## #projectName##Chr( 10 )##Chr( 10 )# - **Platform:** Preside CMS on ColdBox/Lucee" & Chr( 10 ) & Chr( 10 ) & claudeMdContextInstructions;

			FileWrite( claudeMdFile, claudeMdContent );
		} else {
			var claudeMdContent = FileRead( claudeMdFile );

			if ( !(claudeMdContent contains "pixl8-agent-coding-context") ) {
				FileAppend( claudeMdFile, Chr( 10 ) & Chr( 10 ) & claudeMdContextInstructions );
			} else {
				print.line( "CLAUDE.md file already exists. Skipping context setup." );
			}
		}
		print.line();
		print.greenLine( "--------------------------------------------------" );
		print.greenLine( "-> Done installing latest agent coding context. Please check your codebase for changes and commit any changes as a hotfix." );
	}

// PRIVATE HELPERS
	private void function _printError( errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}

	private void function _printWarning( warningMessage ) {
		print.line();
		print.yellowLine( "**************************************************" );
		print.yellowLine( arguments.warningMessage );
		print.yellowLine( "**************************************************" );
		print.line();
	}
}