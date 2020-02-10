/**
 * Auto generate the docs for any project
 *
 **/
component {

	property name="pixl8docs" inject="Pixl8Docs@pixl8-commandbox-commands";

	/**
	 * @directory.hint    Project's directory where docs will be generated
	 *
	 **/
	function run( string directory = shell.pwd() ) {
		if ( !directoryExists( "#arguments.directory#docs/" ) ) {
			return _printError( "Directory [#arguments.directory#docs] does not exist" );
		}

		var applicationFolderExist     = false;
		var applicationFolderDirectory = "";
		var createdDocs                = {};

		if ( directoryExists( "#arguments.directory#website" ) ) {
			applicationFolderExist     = _checkApplicationFolderExist( directory="#arguments.directory#website/" );
			applicationFolderDirectory = "#arguments.directory#website/application/";
		} else {
			applicationFolderExist     = _checkApplicationFolderExist( directory=arguments.directory );
			applicationFolderDirectory = "#arguments.directory#application/";
		}

		if ( applicationFolderExist and !isEmpty( applicationFolderDirectory ) ) {
			_generateDocs( applicationFolderDirectory, arguments.directory, "services", 1 );
			_generateDocs( applicationFolderDirectory, arguments.directory, "preside-objects", 2 );
			_generateDocs( applicationFolderDirectory, arguments.directory, "forms", 3 );
		}

		print.line();
		print.greenLine( "*****************************************************" );
		print.greenLine( "Your project's docs has been successfully generated." );
		print.greenLine( "*****************************************************" );
		print.line();

		return;
	}

// PRIVATE HELPERS
	private void function _printError( required string errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}

	private boolean function _checkApplicationFolderExist( required string directory ) {
		if ( directoryExists( "#arguments.directory#application/" ) ) {
			return true;
		}

		return false;
	}

	private void function _generateDocs(
		  required string  appFolderDirectory
		, required string  projectDirectory
		, required string  directoryName
		,          numeric navOrder = 1
	) {
		var cfcFiles = DirectoryList( "#arguments.appFolderDirectory##arguments.directoryName#", true, "path", "*.cfc" );

		if ( arguments.directoryName eq "forms" ) {
			cfcFiles = DirectoryList( "#arguments.appFolderDirectory##arguments.directoryName#", true, "path", "*.xml" );
		}

		var apiDocsPath      = "#arguments.projectDirectory#docs/reference/#arguments.directoryName#";
		var directoryDocPath = "#arguments.projectDirectory#docs/reference/#arguments.directoryName#/index.markdown";
		var createdDocs      = {};

		if ( DirectoryExists( apiDocsPath ) ) {
			DirectoryDelete( apiDocsPath, true );
		}
		DirectoryCreate( apiDocsPath );

		var indexDoc = CreateObject( "java", "java.lang.StringBuffer" );

		indexDoc.append( "---" & Chr(10) );
		indexDoc.append( "layout: page" & Chr(10) );
		indexDoc.append( "title: #ucFirst( replace( arguments.directoryName, 'preside-', '' ) )#" & Chr(10) );
		indexDoc.append( "nav_order: #arguments.navOrder#" & Chr(10) );
		indexDoc.append( "parent: Reference" & Chr(10) );

		if ( arguments.directoryName neq "forms" ) {
			indexDoc.append( "has_children: true" & Chr(10) );
		}

		indexDoc.append( "---" & Chr(10) & Chr(10) );
		indexDoc.append( "## #ucFirst( replace( arguments.directoryName, 'preside-', '' ) )#" & Chr(10) );

		var fileCounter = 1;
		arraySort( cfcFiles, "text" );

		for( var file in cfcFiles ) {
			var componentPath = "";
			var meta          = {};

			componentPath = Replace( file, arguments.appFolderDirectory, "website/application/" );

			if ( arguments.directoryName neq "forms" ) {
				componentPath = ReReplace( componentPath, "\.cfc$", "" );
				componentPath = ListChangeDelims( componentPath, ".", "\/" );
			}

			try {
				if ( arguments.directoryName neq "forms" ) {
					meta = GetComponentMetaData( componentPath );
				}

				if ( IsBoolean( meta.autodoc ?: "false" ) && ( meta.autodoc ?: true ) ) {
					var result = { success=false };

					switch( arguments.directoryName ) {
						case "services":
							result = pixl8docs.createCFCDocumentation( componentPath, apiDocsPath, fileCounter );
							break;
						case "preside-objects":
							result = pixl8docs.createPresideObjectDocumentation( componentPath, apiDocsPath, fileCounter );
							break;
						case "forms":
							result = pixl8docs.writeXmlFormDocumentation( componentPath, apiDocsPath, fileCounter );
							break;
					}

					if ( result.success ) {
						createdDocs[ result.filename ] = { title = result.title };
						fileCounter ++;

						if ( !isEmpty( result.parentDir ?: "" ) ) {
							createdDocs[ result.filename ].parentDir = result.parentDir;
						}
					}
				}
			} catch (any e) {
				print.boldWhiteOnRedLine( e.message ?: "" ).line();
			}
		}

		if ( arguments.directoryName eq "forms" ) {
			var contentDocs = CreateObject( "java", "java.lang.StringBuffer" );
			var outputDocs  = {};
			var sortedDocs  = structSort( createdDocs, "textnocase", "asc", "TITLE" );

			for( var doc in sortedDocs ){
				if ( structKeyExists( outputDocs, createdDocs[doc].parentdir ) ) {
					outputDocs[ createdDocs[doc].parentdir ].append( doc );
				} else {
					outputDocs[ createdDocs[doc].parentdir ] = [ doc ];
				}
			}

			for ( var item in outputDocs ) {
				var itemName = reReplace( item, "[^a-z0-9]", " ", "all" );

				indexDoc.append( "* [#ucFirst( itemName )#](###replace( itemName, " ", "-" )#)" & Chr(10) );
				contentDocs.append( Chr(10) & "###### " & ucFirst( itemName ) & "" & Chr(10) & Chr(10) );

				for ( var doc in outputDocs[item] ) {
					contentDocs.append( "* [#doc#](/reference/forms/#doc#.html)" & Chr(10) );
				}

				contentDocs.append( Chr(10) & "[Back to form group list](##forms){: .fs-2}" & Chr(10) & Chr(10) & "---" & Chr(10) );
			}

			indexDoc.append( Chr(10) & "---" & Chr(10) & contentDocs );
		}

		FileWrite( directoryDocPath, indexDoc.toString() );
	}

}