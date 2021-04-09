<cfscript>
	alerts = attributes.alerts ?: [];
	criticalCount = attributes.criticalCount ?: 0;
	warningCount = attributes.warningCount ?: 0;
</cfscript>
<!DOCTYPE html>
<html>
<head>
	<title>Package Problem(s) Report</title>

	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
	<style type="text/css">
		body {
			background-color: #f9f9f9;
		}
		.container {
			margin-top: 20px;
			background-color: white;
			padding: 30px;

			background: #F8F8F8;
			border: solid #BDBDBD 1px;
			box-shadow: 5px 5px 20px rgba(0, 0, 0, 0.5)  ;
			-webkit-box-shadow: 5px 5px 20px rgba(0, 0, 0, 0.5)  ;
			-moz-box-shadow: 5px 5px 20px rgba(0, 0, 0, 0.5)  ;
		}

		h2 {
			border-bottom: 1px solid #ddd;
			margin-bottom: 20px;
		}
	</style>
</head>
<body>
	<div class="container">
		<cfoutput>
			<h1>Package Problem(s) Report</h1>
			<p>Package checker found <strong>[#NumberFormat( criticalCount )#] critical issues</strong> and <strong>[#NumberFormat( warningCount )#] warnings</strong>. See details below.</p>
			<cfif criticalCount>
				<div class="critical-alerts-container">
					<h2>Critical alerts</h2>
					<ul class="alert-list list-unstyled">
						<cfloop array="#alerts#" item="alert" index="i">
							<cfif alert.alert_severity == "critical">
								<li class="alert alert-danger">
									<dl class="dl-horizontal">
										<dt>Package:</dt>
										<dd>
											#alert.package#
											<cfif alert.min_version == alert.max_version>
												v#alert.min_version#
											<cfelse>
												v#alert.min_version#&ndash;v#alert.max_version#
											</cfif>
										</dd>
										<cfif alert.alert_type == "dependency" && Len( alert.dependent_package )>
											<dt>Dependency:</dt>
											<dd>
												#alert.dependent_package#
												<cfif alert.dependent_min_version == alert.dependent_max_version>
													v#alert.dependent_min_version#
												<cfelse>
													v#alert.dependent_min_version#&ndash;v#alert.dependent_max_version#
												</cfif>
											</dd>
										</cfif>
									</dl>
									<dt>Description:</dt>
									<dd>#alert.description#</dd>
								</li>
							</cfif>
						</cfloop>
					</ul>
				</div>
			</cfif>

			<cfif warningCount>
				<div class="warnings-container">
					<h2>Warnings</h2>
					<ul class="alert-list">
						<cfloop array="#alerts#" item="alert" index="i">
							<cfif alert.alert_severity != "critical">
								<li class="alert alert-warning">
									<dl class="dl-horizontal">
										<dt>Package:</dt>
										<dd>
											#alert.package#
											<cfif alert.min_version == alert.max_version>
												v#alert.min_version#
											<cfelse>
												v#alert.min_version#&ndash;v#alert.max_version#
											</cfif>
										</dd>
										<cfif alert.alert_type == "dependency" && Len( alert.dependent_package )>
											<dt>Dependency:</dt>
											<dd>
												#alert.dependent_package#
												<cfif alert.dependent_min_version == alert.dependent_max_version>
													v#alert.dependent_min_version#
												<cfelse>
													v#alert.dependent_min_version#&ndash;v#alert.dependent_max_version#
												</cfif>
											</dd>
										</cfif>
										<dt>Description:</dt>
										<dd>#alert.description#</dd>
									</dl>
								</li>
							</cfif>
						</cfloop>
					</ul>
				</div>
			</cfif>
		</cfoutput>
	</div>
</body>
</html>