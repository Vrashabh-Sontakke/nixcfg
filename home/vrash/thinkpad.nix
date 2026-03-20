{ pkgs, ... }: {
	imports = [ ./home.nix ../common ];

	home.packages = with pkgs; [
		deskflow
	];
}
