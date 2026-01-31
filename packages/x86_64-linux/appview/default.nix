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
    clientdir = lib.snowfall.fs.get-file "./client";
    lexicondir = lib.snowfall.fs.get-file "./lexicons";

    npmDeps = importNpmLock {
    	npmRoot = lib.snowfall.fs.get-file "./appview";
    };

    npmConfigHook = importNpmLock.npmConfigHook;

    npmFlags = [ "--legacy-peer-deps" ];

    nodejs = nodejs_22;

    dontNpmBuild = true;

    nativeBuildInputs = [makeWrapper];

    preBuild = ''
      cp -r --no-preserve=mode ${lib.snowfall.fs.get-file "./client"} ./client
      cp -r --no-preserve=mode ${lib.snowfall.fs.get-file "./lexicons"} ./lexicons
      npx --offline lex gen-server --yes ./client/generated/server ./lexicons || echo "lex failed with $?"
    '';

    postInstall = ''
      # cp -r --no-preserve=mode ./client $out/lib/node_modules/guestbook-appview/client
      makeWrapper ${nodejs_22}/bin/node $out/bin/guestbook-appview --add-flags $out/lib/node_modules/guestbook-appview/node_modules/.bin/tsx --add-flags watch --add-flags "--env-file=.env" --add-flags $out/lib/node_modules/guestbook-appview/index.ts
    '';
  }
