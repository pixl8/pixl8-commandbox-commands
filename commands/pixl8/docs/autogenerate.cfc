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
		} else if ( directoryExists( "#arguments.directory#application" ) ) {
			applicationFolderExist     = _checkApplicationFolderExist( directory=arguments.directory );
			applicationFolderDirectory = "#arguments.directory#application/";
		} else {
			applicationFolderDirectory = "#arguments.directory#";
		}

		if ( !isEmpty( applicationFolderDirectory ) ) {
			_generateDocs( applicationFolderDirectory, arguments.directory, "services"       , 1 );
			_generateDocs( applicationFolderDirectory, arguments.directory, "preside-objects", 2 );
			_generateDocs( applicationFolderDirectory, arguments.directory, "forms"          , 3 );

			if ( directoryExists( "#applicationFolderDirectory#decorators" ) ) {
				_generateDocs( applicationFolderDirectory, arguments.directory, "decorators"     , 4 );
			}
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

		if ( fileExists( "#arguments.directory#box.json" ) ) {
			return true;
		}

		return false;
	}

	private void function _checkAndCreateDir( required string directory ) {
		if ( DirectoryExists( arguments.directory ) ) {
			DirectoryDelete( arguments.directory, true );
		}
		DirectoryCreate( arguments.directory );
	}

	private void function _checkAndRemoveDir( required string directory ) {
		if ( DirectoryExists( arguments.directory ) ) {
			DirectoryDelete( arguments.directory, true );
		}
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

		if ( arguments.directoryName eq "helpers" ) {
			cfcFiles = DirectoryList( "#arguments.appFolderDirectory##arguments.directoryName#", true, "path", "*.cfm" );
		}

		var tempPath         = "#arguments.projectDirectory#docs/temp";
		var refDocsPath      = "#arguments.projectDirectory#docs/reference/#arguments.directoryName#";
		var directoryDocPath = "#arguments.projectDirectory#docs/reference/#arguments.directoryName#/index.markdown";
		var createdDocs      = {};
		var projectAppPath   = replace( arguments.appFolderDirectory, arguments.projectDirectory, '' );

		_checkAndCreateDir( refDocsPath );
		_checkAndCreateDir( tempPath );

		var indexDoc = CreateObject( "java", "java.lang.StringBuffer" );

		indexDoc.append( "---" & Chr(10) );
		indexDoc.append( "layout: page" & Chr(10) );
		indexDoc.append( "title: #ucFirst( replace( arguments.directoryName, 'preside-', '' ) )#" & Chr(10) );
		indexDoc.append( "nav_order: #arguments.navOrder#" & Chr(10) );
		indexDoc.append( "parent: Reference" & Chr(10) );
 		indexDoc.append( "has_children: true" & Chr(10) );
		indexDoc.append( "---" & Chr(10) & Chr(10) );
		indexDoc.append( "## #ucFirst( replace( arguments.directoryName, 'preside-', '' ) )#" & Chr(10) );

		var fileCounter = 1;
		arraySort( cfcFiles, "text" );

		for( var file in cfcFiles ) {
			var componentPath = "";
			var meta          = {};
			var filePath      = Replace( file, arguments.appFolderDirectory, projectAppPath );

			if ( arguments.directoryName neq "forms" ) {
				componentPath = ReReplace( filePath, "\.(cfc|cfm)$", "" );
				componentPath = ListChangeDelims( componentPath, ".", "\/" );
			} else {
				componentPath = filePath;
			}

			try {
				if ( arguments.directoryName neq "forms" ) {
					meta = GetComponentMetaData( componentPath );
				}

				if ( IsBoolean( meta.autodoc ?: "false" ) && ( meta.autodoc ?: true ) ) {
					var result = { success=false };

					switch( arguments.directoryName ) {
						case "services":
							result = pixl8docs.createCFCDocumentation( componentPath, refDocsPath, fileCounter );
							break;
						case "preside-objects":
							result = pixl8docs.createPresideObjectDocumentation( componentPath, refDocsPath );
							break;
						case "forms":
							result = pixl8docs.writeXmlFormDocumentation( componentPath, refDocsPath, fileCounter );
							break;
					}

					if ( result.success ) {
						fileCounter ++;
						var modifiedFilename = reReplace( result.filename, '\W', '-', 'all' );
						if ( structKeyExists( createdDocs, modifiedFilename ) ) {
							createdDocs[ modifiedFilename ].append( { title=result.title, parentDir=result.parentDir ?: "" } );
						} else {
							createdDocs[ modifiedFilename ] = [ { title=result.title, parentDir=result.parentDir ?: "" } ];
						}
					}
				}
			} catch (any e) {
				var tempSubDir = "";
				switch( arguments.directoryName ) {
					case "services":
						tempSubDir = "services";
						break;
					case "preside-objects":
						var objectCfcParentFolder = listGetAt( filePath, listLen( filePath, '/' )-1, '/' );

						tempSubDir = "preside-objects#( objectCfcParentFolder eq "preside-objects" ) ? '' : '/#objectCfcParentFolder#'#";
						break;
					case "decorators":
						tempSubDir = "decorators";
						break;
				}

				if ( !isEmpty( tempSubDir ) ) {
					if ( !DirectoryExists( "#tempPath#/#tempSubDir#" ) ) {
						DirectoryCreate( "#tempPath#/#tempSubDir#" );
					}

					var fileContent  = "";
					var tempFilePath = "#tempPath#/#tempSubDir#/#listLast( filePath, '\/' )#";
					var result       = { success=false };

					componentPath = Replace( tempFilePath, arguments.projectDirectory, '' );
					componentPath = ReReplace( componentPath, "\.cfc$", "" );
					componentPath = ListChangeDelims( componentPath, ".", "\/" );

					switch( arguments.directoryName ) {
						case "services":
							var replacedPath = replace( projectAppPath, '/', '.', 'all' );
							var originalFileContent = FileRead(filePath);

							if ( findNoCase( 'preside.', originalFileContent ) ) {
								fileContent = replace( originalFileContent, 'preside.', replacedPath );
								fileContent = replace( fileContent, '.application.', '.preside.' );
							} else {
								fileContent = replace( originalFileContent, 'app.', replacedPath );
							}
							fileContent = ReReplaceNoCase( originalFileContent, " implements=""[a-z0-9_\-\.,\s]+""", "" );

							FileWrite( tempFilePath, fileContent );

							result = pixl8docs.createCFCDocumentation( componentPath, refDocsPath, fileCounter, replacedPath );
							if ( !result.success ) {
								print.yellowLine( "Failed to generate documentation for #componentPath#. Could not generate metadata" );
							}
							break;
						case "preside-objects":
							fileContent = reReplace( FileRead(filePath), 'extends=".*"\s{\n', '{#Chr(10)#' );
							FileWrite( tempFilePath, fileContent );

							result = pixl8docs.createPresideObjectDocumentation( componentPath, refDocsPath, 0, projectAppPath );
							break;
						case "decorators":
							fileContent = reReplace( FileRead(filePath), 'extends=".*"\s{\n', '{#Chr(10)#' );
							FileWrite( tempFilePath, fileContent );

							result = pixl8docs.createDecoratorDocumentation( componentPath, refDocsPath, 0, projectAppPath );
							break;
					}

					if ( result.success ) {
						createdDocs[ reReplace( result.filename, '\W', '-', 'all' ) ] = [ { title = result.title } ];
						fileCounter ++;
					}
				} else {
					print.redLine( e.message ?: "" ).line();
				}
			}
		}

		FileWrite( directoryDocPath, indexDoc.toString() );
		_checkAndRemoveDir( tempPath );
	}

}