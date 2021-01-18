/**
 * I am a utitlity component to take preside source code and make documentation out of it
 */
component {

	variables.NEWLINE    = Chr( 10 );
	variables.DOUBLELINE = NEWLINE & NEWLINE;
	variables.INDENT     = "    ";

	/**
	 * Creates CFC service layer documentation
	 *
	 * @componentPath.hint Component path used to instantiate the component, e.g. "preside.system.presideobjects.PresideObjectService"
	 *
	 */
	public struct function createCFCDocumentation(
		  required string  componentPath
		, required string  docsPath
		,          numeric navigationOrder = 0
		,          string  docTempReplace  = ""
	) {
		var returnStruct = { success=true };

		try {
			var meta = GetComponentMetaData( arguments.componentPath );
		} catch (any e) {
			// TODO if multiple level extends
			return { success=false };
		}

		var doc          = CreateObject( "java", "java.lang.StringBuffer" );
		var functionDoc  = CreateObject( "java", "java.lang.StringBuffer" );
		var objName      = ListLast( arguments.componentPath, "." );
		var pageName     = LCase( objName );
		var pageDir      = arguments.docsPath & "/" & pageName;
		var pageFile     = pageDir & "/index.markdown";
		var singleton    = IsBoolean( meta.singleton ?: "" ) && meta.singleton;
		var fullPath     = "";
		var extended     = false;

		if ( !DirectoryExists( pageDir ) ) {
			DirectoryCreate( pageDir );
		}

		returnStruct.filename = pageName;
		returnStruct.title    = meta.displayName ?: objName;

		doc.append( _mdMeta( title=returnStruct.title, id=returnStruct.filename, parent="Services", navOrder=arguments.navigationOrder ) );

		doc.append( DOUBLELINE & _mdTitle( "Overview", 2 ) & DOUBLELINE );

		if ( Len( Trim( meta.hint ?: "" ) ) ) {
			doc.append( DOUBLELINE & _parseHint( meta.hint ) );
		}

		if ( ( listFirst( arguments.componentPath, '.' ) eq "docs" ) and !isEmpty( arguments.docTempReplace ) ) {
			fullPath = replace( arguments.componentPath, 'docs.temp.', arguments.docTempReplace );
			extended = true;
		} else {
			fullPath = arguments.componentPath;
		}

		doc.append( DOUBLELINE );
		doc.append( '<div class="table-responsive"><table class="table table-condensed">' );
		doc.append( "<tr><th>Full path</th><td>" & fullPath & "</td></tr>" );
		doc.append( "<tr><th>Wirebox ref</th><td>" & objName & "</td></tr>" );
		doc.append( "<tr><th>Singleton</th><td>" & ( singleton ? 'Yes' : 'No' ) & "</td></tr>" );

		if ( extended ) {
			doc.append( "<tr><th>Extended</th><td>Yes</td></tr>" );
		}

		doc.append( '</table></div>' );

		if ( ( meta.functions ?: [] ).len() ) {
			doc.append( DOUBLELINE & _mdTitle( "Public API Methods", 2) );

			for( var fun in meta.functions ){
				if ( ( fun.access ?: "" ) == "public" && ( IsBoolean( fun.autodoc ?: true ) && ( fun.autodoc ?: true ) ) && fun.name != "init" ) {
					doc.append( NEWLINE & "* [#fun.name#()](###LCase( fun.name )#)" );

					functionDoc.append( _createFunctionDoc( fun, LCase( objName ), arguments.docsPath & "/#pageName#" ) );
				}
			}

			doc.append( DOUBLELINE & "---" & DOUBLELINE & functionDoc );
		}

		FileWrite( pageFile, doc.toString() );

		return returnStruct;
	}

	/**
	 * Creates CFC decorator documentation
	 *
	 */
	public struct function createDecoratorDocumentation(
		  required string  componentPath
		, required string  docsPath
		,          numeric navigationOrder = 0
	) {
		var returnStruct = { success=true };
		var meta         = GetComponentMetaData( arguments.componentPath );
		var doc          = CreateObject( "java", "java.lang.StringBuffer" );
		var functionDoc  = CreateObject( "java", "java.lang.StringBuffer" );
		var objName      = ListLast( arguments.componentPath, "." );
		var pageName     = LCase( objName );
		var pageDir      = arguments.docsPath & "/" & pageName;
		var pageFile     = pageDir & "/index.markdown";
		var fullPath     = "";
		var extended     = false;

		if ( !DirectoryExists( pageDir ) ) {
			DirectoryCreate( pageDir );
		}

		returnStruct.filename = pageName;
		returnStruct.title    = meta.displayName ?: objName;

		doc.append( _mdMeta( title=returnStruct.title, id=returnStruct.filename, parent="Decorators", navOrder=arguments.navigationOrder ) );

		doc.append( DOUBLELINE & _mdTitle( "Overview", 2 ) & DOUBLELINE );

		if ( Len( Trim( meta.hint ?: "" ) ) ) {
			doc.append( DOUBLELINE & _parseHint( meta.hint ) );
		}

		if ( ( listFirst( arguments.componentPath, '.' ) eq "docs" ) ) {
			fullPath = replace( arguments.componentPath, 'docs.temp.', "app." );
			extended = true;
		} else {
			fullPath = arguments.componentPath;
		}

		doc.append( '<div class="table-responsive"><table class="table table-condensed">' );
		doc.append( "<tr><th>Full path</th><td>" & fullPath & "</td></tr>" );
		doc.append( "<tr><th>Wirebox ref</th><td>" & objName & "</td></tr>" );

		if ( extended ) {
			doc.append( "<tr><th>Extended</th><td>Yes</td></tr>" );
		}

		doc.append( '</table></div>' );

		if ( ( meta.functions ?: [] ).len() ) {
			doc.append( DOUBLELINE & _mdTitle( "Public API Methods", 2) );

			for( var fun in meta.functions ){
				if ( ( fun.access ?: "" ) == "public" && ( IsBoolean( fun.autodoc ?: true ) && ( fun.autodoc ?: true ) ) && fun.name != "init" ) {
					doc.append( NEWLINE & "* [#fun.name#()](###LCase( fun.name )#)" );

					functionDoc.append( _createFunctionDoc( fun, LCase( objName ), arguments.docsPath & "/#pageName#" ) );
				}
			}

			doc.append( DOUBLELINE & "---" & DOUBLELINE & functionDoc );
		}

		FileWrite( pageFile, doc.toString() );

		return returnStruct;
	}

	/**
	 * Returns a string containing the reStructuredText documentation
	 * for the given preside object
	 *
	 * @componentPath.hint Component path used to instantiate the component, e.g. "preside.system.preside-objects.page"
	 *
	 */
	public struct function createPresideObjectDocumentation(
		  required string  componentPath
		, required string  docsPath
		,          numeric navigationOrder = 0
		,          string  docTempReplace  = ""
	) {
		var returnStruct = { success=true };

		try {
			var meta = GetComponentMetaData( arguments.componentPath );
		} catch (any e) {
			// TODO if multiple level extends
			return { success=false };
		}

		var doc          = CreateObject( "java", "java.lang.StringBuffer" );
		var apiList      = CreateObject( "java", "java.lang.StringBuffer" );
		var objName      = ListLast( arguments.componentPath, "." );
		var pageName     = LCase( objName );
		var pageDir      = arguments.docsPath & "/" & pageName;
		var pageFile     = pageDir & "/presideobject.markdown";
		var fullPath     = Replace( arguments.componentPath, "preside.system.", "" );
		var extended     = false;
		var isPageType   = findNoCase( "page-type", arguments.componentPath ) ? true : false;

		if ( !DirectoryExists( pageDir ) ) {
			DirectoryCreate( pageDir );
		}

		returnStruct.filename = pageName;
		returnStruct.title    = meta.displayName ?: objName;

		doc.append( _mdMeta( title=returnStruct.title, id=returnStruct.filename, parent="Objects", navOrder=arguments.navigationOrder ) );
		doc.append( NEWLINE & _mdTitle( "Overview" ) & DOUBLELINE );

		if ( Len( Trim( meta.hint ?: "" ) ) ) {
			doc.append( _parseHint( meta.hint ) & DOUBLELINE );
		}

		if ( ( listFirst( arguments.componentPath, '.' ) eq "docs" ) and !isEmpty( arguments.docTempReplace ) ) {
			fullPath = replace( fullPath, 'docs.temp.', arguments.docTempReplace );
			extended = true;
		}

		fullPath = Replace( fullPath, ".", "/", "all" );

		doc.append( '<div class="table-responsive"><table class="table table-condensed">' );
		doc.append( "<tr><th>Object name</th><td> " & ListLast( arguments.componentPath, "." )  & "</td></tr>" );
		doc.append( "<tr><th>Table name</th><td>  " & ListLast( arguments.componentPath, "." )  & "</td></tr>" );
		doc.append( "<tr><th>Path</th><td>  " & "/" & fullPath & ".cfc" & "</td></tr>" );
		doc.append( "<tr><th>Page type</th><td>" & ( isPageType ? 'Yes' : 'No' ) & "</td></tr>" );

		if ( extended ) {
			doc.append( "<tr><th>Extended</th><td>Yes</td></tr>" );
		}

		doc.append( '</table></div>' );

		doc.append( DOUBLELINE & _mdTitle( "Properties" ) & DOUBLELINE );
		doc.append( "```cfc" & NEWLINE );

		var objectProperties = _parsePresideObjectPropertiesAsCode( arguments.componentPath );
		if ( isEmpty( objectProperties ) ) {
			return { success=false };
		}
		doc.append( objectProperties );
		doc.append( NEWLINE & "```" );

		if ( ( meta.functions ?: [] ).len() ) {
			var functionDocs = "";

			for( var fun in meta.functions ){
				if ( ( fun.access ?: "" ) == "public" && ( IsBoolean( fun.autodoc ?: true ) && ( fun.autodoc ?: true ) ) ) {
					apiList.append( NEWLINE & "* [#fun.name#()](###LCase( fun.name )#)" );

					functionDocs &= _createFunctionDoc( fun, LCase( objName ), pageDir );
				}
			}

			if ( functionDocs.len() ) {
				doc.append( DOUBLELINE & _mdTitle( "Public API Methods" ) );
				doc.append( apiList & DOUBLELINE & "---" & DOUBLELINE );
				doc.append( functionDocs );
			}
		}

		FileWrite( pageFile, doc.toString() );

		return returnStruct;
	}


	/**
	 * Takes a Preside XML Form path and writes an .rst file to the passed folder.
	 * Returns a structure with information about the operation and parsed file.
	 *
	 * @xmlFilePath.hint  Full path to the XML file
	 * @docDirectory.hint Full directory path for the location of the rst file
	 */
	public struct function writeXmlFormDocumentation( required string xmlFilePath, required string docDirectory, numeric navigationOrder=0 ) output=true {
		var returnStruct       = { success=true };
		var fileContent        = FileRead( arguments.xmlFilePath );
		var documentationMatch = ReFind( "<!--.*!autodoc(.*?)-->", fileContent, 1, true );

		if ( !documentationMatch.len.len() == 2 || !documentationMatch.len[2] ) {
			var documentation = replace( listLast( arguments.xmlFilePath, "\/" ), '.xml', '' );
		} else {
			var documentation = Trim( Mid( fileContent, documentationMatch.pos[2], documentationMatch.len[2] ) );
		}

		var parentDir     = listGetAt( arguments.xmlFilePath, listLen( arguments.xmlFilePath, '\/' )-1, '\/' );
		var title         = ListFirst( replace( listLast( arguments.xmlFilePath, "\/" ), '.xml', '' ), Chr(10) & Chr(13) );
		var description   = ListRest( documentation, Chr(10) & Chr(13) );
		var relativePath  = Replace( Replace( xmlFilePath, "\", "/", "all" ), ExpandPath( "/preside/system" ), "" );
		var dotPath       = Replace( ReReplace( ReReplace( relativePath, "^/forms/", "" ), "\.xml$", "" ), "/", ".", "all" );
		var source        = ReReplace( fileContent, "<!--.*!autodoc(.*?)-->", "" );

		if ( parentDir eq "forms" ) {
			parentDir = "";
		}

		source = ReReplace( source, "\n", "`$$$", "all" );
		source = ListToArray( source, "`" );
		for( var i=1; i <= source.len(); i++ ){
			var line = source[i];
			if ( line != "$$$" ) {
				source[i] = line;
			}
		}
		source = ArrayToList( source, NEWLINE );
		source = Replace( source, "$$$", "", "all" );
		source = Replace( source, Chr(9), INDENT, "all" );

		returnStruct.filename  = LCase( ReReplace( ( !isEmpty( parentDir ) ? parentDir : title ), "\W", " ", "all" ) );
		returnStruct.title     = title;
		returnStruct.parentDir = parentDir;

		var doc = CreateObject( "java", "java.lang.StringBuffer" );

		doc.append( _mdMeta( title=title, id=returnStruct.filename, parent="Forms", navOrder=arguments.navigationOrder ) & NEWLINE );

		doc.append( description & DOUBLELINE );

		doc.append( '<div class="table-responsive"><table class="table table-condensed">' );
		doc.append( "<tr><th>File path</th><td>" & relativePath & "</td></tr>" );
		doc.append( "<tr><th>Form ID</th><td>" & dotPath & "</td></tr>" );
		doc.append( '</table></div>' & DOUBLELINE );

		doc.append( "```xml" & NEWLINE );
		doc.append( source & NEWLINE );
		doc.append( "```" );

		var fileDir  = arguments.docDirectory & "/#returnStruct.parentDir#/";
		var filePath = fileDir & "#title#.markdown";

		if ( !DirectoryExists( fileDir ) ) {
			DirectoryCreate( fileDir );
		}

		FileWrite( filePath, doc.toString() );

		return returnStruct;

	}

// PRIVATE METHODS
	private string function _mdTitle( required string title, string level=2 ) {
		return RepeatString( '##', arguments.level ) & " " & arguments.title & NEWLINE;
	}

	private string function _mdMeta( required string title, required string id, boolean hasChildren=false, string parent="", numeric navOrder=0, boolean excludeFromNav=true ) {
		var metaText = "";

		metaText &= "---#NEWLINE#";
		metaText &= "layout: page#NEWLINE#";
		metaText &= "title: ""#arguments.title#""#NEWLINE#";
		metaText &= "grand_parent: Reference#NEWLINE#";

		if ( !isEmpty( arguments.parent ) ) {
			metaText &= "parent: #arguments.parent##NEWLINE#";
		}

		if ( arguments.hasChildren ) {
			metaText &= "has_children: true#NEWLINE#";
		}

		if ( arguments.excludeFromNav ) {
			metaText &= "nav_exclude: true#NEWLINE#";
		} else if ( arguments.navOrder > 0 ) {
			metaText &= "nav_order: #arguments.navOrder##NEWLINE#";
		}

		metaText &= "---#NEWLINE#";

		return metaText;
	}

	private string function _parseHint( required string hint ) {
		var parsed = Trim( hint );

		parsed = Replace( parsed, "\n", NEWLINE, "all" );
		parsed = Replace( parsed, "\t", INDENT, "all" );

		return parsed;
	}

	private string function _createFunctionDoc( required struct fun, required string objectName, required string docsDirectory ) {
		var functionDoc        = CreateObject( "java", "java.lang.StringBuffer" );
		var argumentsDoc       = _createArgumentsDoc( fun.parameters );
		var argsRenderedInHint = false;
		var functionTitle      = fun.name & "()";

		functionDoc.append( NEWLINE & _mdTitle( functionTitle, 2 ) & NEWLINE );
		functionDoc.append( NEWLINE & "```cfc" );
		functionDoc.append( NEWLINE & _createFunctionSignature( fun ) );
		functionDoc.append( NEWLINE & "```" );

		if ( Len( Trim( fun.hint ?: "" ) ) ) {
			var hint = _parseHint( fun.hint );
			if ( FindNoCase( "${arguments}", hint ) ) {
				hint = ReplaceNoCase( hint, "${arguments}", argumentsDoc );
				argsRenderedInHint = true;
			}
			functionDoc.append( DOUBLELINE & hint );
		}

		if ( !argsRenderedInHint ) {
			functionDoc.append( DOUBLELINE & argumentsDoc );
		}

		functionDoc.append( DOUBLELINE & "[Back to API methods list](##public-api-methods){: .fs-2}" & DOUBLELINE & "---" & DOUBLELINE );

		return functionDoc;
	}

	private string function _createArgumentsDoc( required array args ) {
		if ( !args.len() ) {
			return "";
		}

		var argsDoc = _mdTitle( "Arguments", 4 ) & DOUBLELINE;
		var tableData = [];

		for( var arg in args ) {
			var def = _parseArgumentDefault( arg );
			tableData.append({
				  Name        = arg.name
				, Type        = arg.type
				, Description = arg.hint ?: ""
				, Required    = YesNoFormat( arg.required ) & ( ( def != "*none*" ) ? " (default=#def#)" : "" )
			});
		}
		argsDoc &= _createTable( tableData, [ "Name", "Type", "Required", "Description" ] );


		return argsDoc;
	}

	private string function _createFunctionSignature( required struct fun ) {
		var signature     = "public #fun.returnType# function #fun.name#(";
		var delim         = "  ";
		var maxArgTypeLen = 0;
		var maxArgNameLen = 0;
		var maxRequiredLen = 0;

		for( var arg in fun.parameters ) {
			maxArgTypeLen = arg.type.len() > maxArgTypeLen ? arg.type.len() : maxArgTypeLen;
			maxArgNameLen = arg.name.len() > maxArgNameLen ? arg.name.len() : maxArgNameLen;
			if ( arg.required ) {
				maxRequiredLen = 8;
			}
		}

		for( var arg in fun.parameters ) {
			signature &= NEWLINE & INDENT & delim;
			if ( arg.required ) {
				signature &= "required ";
			} else if ( maxRequiredLen ) {
				signature &= RepeatString( " ", maxRequiredLen+1 );
			}

			signature &= LJustify( arg.type, maxArgTypeLen ) & " " & LJustify( arg.name, maxArgNameLen );
			signature  = trim( signature );

			var default = _parseArgumentDefault( arg );
			if ( default != "*none*" ) {
				signature &= ' = ' & default;
			}

			delim = ", ";
		}

		if ( fun.parameters.len() ) {
			signature &= NEWLINE;
		}

		signature &= ")";


		return signature;
	}

	private string function _createTable( required array tableData, required array cols ) {
		var colLengths = [];
		var table      = '<div class="table-responsive"><table class="table"><thead><tr>';
		var colCount   = arguments.cols.len();

		for( var col in cols ) {
			table &= "<th>#col#</th>";
		}
		table &= "</tr></thead><tbody>";

		for( var n=1; n <= arguments.tableData.len(); n++ ) {
			table &= "<tr>";
			for( var i=1; i <= colCount; i++ ){
				var colValue = arguments.tableData[n][ arguments.cols[i] ];
				table &= "<td>#colValue#</td>";
			}
			table &= "</tr>";
		}

		table &= "</tbody></table></div>";

		return table;
	}

	private string function _parseArgumentDefault( required struct arg ) {
		if ( arg.keyExists( "default" ) && arg.default != "[runtime expression]" ) {
			if ( IsBoolean( arg.default ) || IsNumeric( arg.default ) ) {
				return arg.default;
			}

			return '"#arg.default#"';
		} else if ( arg.keyExists( "docdefault" ) ) {
			return arg.docdefault;
		}

		return "*none*";
	}

	private string function _parsePresideObjectPropertiesAsCode( required string componentPath ) {
		var filePath            = "/" & Replace( arguments.componentPath, ".", "/", "all" ) & ".cfc";
		var fileContent         = FileRead( filePath );
		var lines               = ListToArray( ReReplace( fileContent, "\n", "`$$$", "all" ), "`" );
		var props               = [];
		var prevLineWasProperty = false;

		for( var line in lines ){
			line = Trim( Replace( line, "$$$", "" ) );
			if ( prevLineWasProperty && line == "" ) {
				props.append( "$$$" );
			}

			prevLineWasProperty = ReFindNoCase( "^property\s.*$", line );
			if ( prevLineWasProperty ) {
				props.append( line );
			}
		}

		props = ArrayToList( props, NEWLINE );
		props = Replace( props, "$$$", "", "all" );

		return props;
	}
}