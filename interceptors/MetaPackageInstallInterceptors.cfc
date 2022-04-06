component {

	property name="packageService"  inject="provider:packageService";

// INTERCEPTION LISTENERS
	public void function onInstall( interceptData ) {
		if ( _isMetaPackage( interceptData.artifactDescriptor ?: {} ) ) {
			var job               = interceptData.job                             ?: "";
			var installArgs       = interceptData.installArgs                     ?: {};
			var cwd               = installArgs.currentWorkingDirectory           ?: "";
			var packageBoxJson    = interceptData.artifactDescriptor              ?: {};
			var packageSlug       = packageBoxJson.slug                           ?: "";
			var dependencies      = packageBoxJson[ "pixl8-meta-package" ].dependencies ?: {};
			var uninstallPackages = packageBoxJson[ "pixl8-meta-package" ].uninstallPackages ?: [];
			var defaultExcludes   = packageBoxJson[ "pixl8-meta-package" ].defaultExclude ?: [];
			var profiles          = packageBoxJson[ "pixl8-meta-package" ].profiles ?: {};
			var containerBoxJson  = packageService.readPackageDescriptorRaw( cwd );
			var containerConfig   = _readContainerMetaPackageConfig( containerBoxJson, packageSlug );
			var profileConfig     = _getProfifleConfig( containerConfig, profiles, installArgs.ID );
			var excludePackages   = _resolveExcludes( defaultExcludes, containerConfig, profileConfig );

			_installDependencies( dependencies, containerBoxJson, containerConfig, cwd, job, installArgs.ID, excludePackages );
			_uninstallPackages( uninstallPackages, containerBoxJson, cwd, job, installArgs.ID );
			_stripDependenciesFromContainerBoxJson( dependencies, containerBoxJson, containerConfig, job, installArgs.ID, excludePackages );
			_markPackageAsInstalled( containerBoxJson, packageBoxJson, installArgs );

			packageService.writePackageDescriptor( containerBoxJson, cwd );
			StructAppend( interceptData.containerBoxJson, containerBoxJson );
		}
	}

	public void function postInstall( interceptData ) {
		var installDirectory = interceptData.installDirectory ?: "";
		var packageBoxJson   = packageService.readPackageDescriptorRaw( installDirectory );

		if ( _isMetaPackage( packageBoxJson ) ) {
			_removeMetaPackageArtifacts(
				  installDirectory = installDirectory
				, cwd              = ( interceptData.installArgs.currentWorkingDirectory ?: "" )
				, packageBoxJson   = packageBoxJson
			);
		}
	}

// PRIVATE HELPERS
	private boolean function _isMetaPackage( descriptor ) {
		return ( descriptor.type ?: "" ) == "pixl8-meta-package";
	}

	private struct function _readContainerMetaPackageConfig( containerBoxJson, metaPackageSlug ) {
		var packages = containerBoxJson[ "pixl8-meta-packages" ] = containerBoxJson[ "pixl8-meta-packages" ] ?: {};
		var package  = packages[ metaPackageSlug ] = packages[ metaPackageSlug ] ?: StructNew( "linked" );

		package[ "profile"           ] = package[ "profile"           ] ?: "";
		package[ "excludePackages"   ] = package[ "excludePackages"   ] ?: [];
		package[ "installedPackages" ] = package[ "installedPackages" ] ?: [];

		return package;
	}

	private void function _installDependencies( dependencies, containerBoxJson, containerConfig, cwd, job, metaPackageId, excludePackages ) {
		var overrideVersion = "";

		if ( ListLast( arguments.metaPackageId, "@" ) == "be" ) {
			overrideVersion = "be";
		}
		if ( ListLast( arguments.metaPackageId, "@" ) == "stable" ) {
			overrideVersion = "stable";
		}

		job.start( "Installing Dependencies for meta package: [#metaPackageId#]..." );

		containerConfig.installedPackages = [];
		for( var packageId in dependencies ) {
			if ( !ArrayFindNoCase( excludePackages, packageId ) ) {
				_installPackage( packageId, dependencies[ packageId ], cwd, overrideVersion );
				ArrayAppend( containerConfig.installedPackages, packageId );
			}
		}

		job.complete( true );
	}

	private void function _uninstallPackages( packages, containerBoxJson, cwd, job, metaPackageId ) {
		var anyToRemove = false;
		for( var packageId in packages ) {
			if ( StructKeyExists( ( containerBoxJson.dependencies ?: {} ), packageId ) ) {
				if ( !anyToRemove ) {
					anyToRemove = true;
					job.start( "Removing incompatible packages with meta package: [#metaPackageId#]..." );
				}

				packageService.uninstallPackage(
					  id                      = packageId
					, currentWorkingDirectory = cwd
				);

				StructDelete( containerBoxJson.dependencies ?: {}, packageId );
				StructDelete( containerBoxJson.installPaths ?: {}, packageId );
			}
		}
		if ( anyToRemove ) {
			job.complete( true );
		}
	}

	private void function _installPackage( packageSlug, packageDetail, cwd, overrideVersion ) {
		var id = ( packageDetail contains ":" ) ? packageDetail : "#packageSlug#@#packageDetail#";

		if ( Len( Trim( arguments.overrideVersion ) ) ) {
			if ( ListLen( id, "@" ) == 2 ) {
				id = ListFirst( id, "@" ) & "@" & arguments.overrideVersion;
			} else if ( !Find( ":", id ) || ListFirst( id, ":" ) == "pixl8" ) {
				id = id & "@" & arguments.overrideVersion;
			}
		}

		packageService.installPackage(
			  id                         = id
			, save                       = false
			, saveDev                    = false
			, production                 = true
			, currentWorkingDirectory    = arguments.cwd
			, skipPresidePackageChecking = true
		);
	}

	private void function _stripDependenciesFromContainerBoxJson( dependencies, containerBoxJson, containerConfig, job, metaPackageId, excludePackages ) {
		var anyToStrip = false;

		for( var packageId in arguments.dependencies ) {
			if ( !ArrayFindNoCase( excludePackages, packageId ) ) {
				if ( StructKeyExists( ( containerBoxJson.installPaths ?: {} ), packageId ) || StructKeyExists( ( containerBoxJson.dependencies ?: {} ), packageId ) ) {
					if ( !anyToStrip ) {
						job.start( "Stripping explicit dependencies from your box.json that are now handled by the meta package [#metaPackageId#]" );
						anyToStrip = true;
					}
					job.start( "Removing explicit dependency from box.json for package [#packageId#]. This is now supplied by the meta package." );
					StructDelete( ( containerBoxJson.installPaths ?: {} ), packageId );
					StructDelete( ( containerBoxJson.dependencies ?: {} ), packageId );
					job.complete();
				}
			}
		}

		if ( anyToStrip ) {
			job.complete();
		}
	}

	private void function _markPackageAsInstalled( containerBoxJson, packageBoxJson, installArgs ) {
		var production = IsBoolean( installArgs.production ?: "" ) && installArgs.production;
		var saveProd   = IsBoolean( installArgs.save       ?: "" ) && installArgs.save;
		var saveDev    = IsBoolean( installArgs.saveDev    ?: "" ) && installArgs.saveDev;
		var save = ( production && saveProd ) || ( !production && saveDev );

		if ( save ) {
			var saveIn = production ? "dependencies" : "devDependencies";
			var slug   = packageBoxJson.slug ?: "";

			containerBoxJson[ saveIn ] = containerBoxJson[ saveIn ] ?: {};
			containerBoxJson[ saveIn ][ slug ] = _readInstallVersion( installArgs.ID ?: "" );
		}
	}

	private string function _readInstallVersion( required string packageId ) {
		if ( !Find( ":", arguments.packageId ) && Find( "@", arguments.packageId ) ) {
			return ListRest( arguments.packageId, "@" );
		}

		return arguments.packageId;
	}

	private void function _removeMetaPackageArtifacts(
		  required string installDirectory
		, required string cwd
		, required struct packageBoxJson
	) {
		var containerBoxJson = packageService.readPackageDescriptorRaw( cwd );

		DirectoryDelete( installDirectory, true );
		StructDelete( containerBoxJson.installPaths ?: {}, packageBoxJson.slug );
		packageService.writePackageDescriptor( containerBoxJson, cwd );
	}

	private struct function _getProfifleConfig( containerConfig, profiles, metaPackageId ) {
		if ( !StructCount( profiles ) ) {
			return {};
		}

		if ( !Len( Trim( containerConfig.profile ?: "" ) ) || !StructKeyExists( profiles, containerConfig.profile ) ) {
			containerConfig.profile = _promptForProfile( profiles, metaPackageId );
		}

		return profiles[ containerConfig.profile ];
	}

	private string function _promptForProfile( profiles, metaPackageId ) {
		var promptOptions = [];

		for( var profileId in profiles ) {
			ArrayAppend( promptOptions, { display=( profiles[ profileId ].title ?: profileId ), value=profileId } );
		}
		return getWirebox().getInstance( name="multiSelect" ).init( "Choose an installation profile for the [#metaPackageId#] meta package:" )
			.options( promptOptions )
			.required()
			.ask();
	}

	private array function _resolveExcludes( defaultExcludes, containerConfig, profileConfig ) {
		var alreadyInstalled   = containerConfig.installedPackages ?: [];
		var alreadyExcluded    = containerConfig.excludePackages   ?: [];
		var alwaysExcluded     = profileConfig.alwaysExclude   ?: [];
		var defaultIncludes    = profileConfig.defaultIncludes ?: [];
		var resolved           = Duplicate( alreadyExcluded );
		var allDefaultExcludes = Duplicate( defaultExcludes );
		var ignoreDefaults     = ArrayLen( alreadyExcluded ) && !ArrayLen( alreadyInstalled ); // because we already declare our own ignores and we haven't yet made an install...

		ArrayAppend( allDefaultExcludes, ( profileConfig.defaultExclude ?: [] ), true );

		if ( !ignoreDefaults ) {
			for( var package in allDefaultExcludes ) {
				if ( !ArrayFindNoCase( defaultIncludes, package ) && !ArrayFindNoCase( resolved, package ) && !ArrayFindNoCase( alreadyInstalled, package ) ) {
					ArrayAppend( resolved, package );
				}
			}
		}
		for( var package in alwaysExcluded ) {
			if ( !ArrayFindNoCase( resolved, package ) ) {
				ArrayAppend( resolved, package );
			}
		}

		containerConfig.excludePackages = resolved;

		return resolved;


	}
}