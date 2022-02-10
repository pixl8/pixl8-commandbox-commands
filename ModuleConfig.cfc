component {
	public any function configure() {
		interceptors = [
			{ class="#moduleMapping#.interceptors.MetaPackageInstallInterceptors" }
		];

		return;
	}
}