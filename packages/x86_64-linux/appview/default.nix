{
  lib,
  writeScriptBin,
  buildNpmPackage,
  nodejs_22,
  makeWrapper,
  importNpmLock,
  ...
}:  let
    package-json = lib.importJSON (lib.snowfall.fs.get-file "./appview/package.json");
in
  buildNpmPackage {
    pname = "guestbook-appview";
	inherit (package-json) version;
	
    src = lib.snowfall.fs.get-file "./appview";

    npmDeps = importNpmLock {
    	npmRoot = lib.snowfall.fs.get-file "./appview";
    };

    npmConfigHook = importNpmLock.npmConfigHook;

    # npmFlags = [ "--ignore-scripts" ];

    nodejs = nodejs_22;

    dontNpmBuild = true;

    nativeBuildInputs = [makeWrapper];

    postInstall = ''
      makeWrapper ${nodejs_22}/bin/node $out/bin/guestbook-appview --add-flags $out/lib/node_modules/guestbook-appview/node_modules/.bin/tsx --add-flags watch --add-flags "--env-file=.env" --add-flags $out/lib/node_modules/guestbook-appview/index.ts
    '';
  }
