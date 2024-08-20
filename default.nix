{
  lib,
  buildNpmPackage,
  importNpmLock,
  unzip,
  vscodium,
  vscode-extensions,
  ...
}:
let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
in
buildNpmPackage {
  pname = packageJson.name;

  inherit (packageJson) version;

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ unzip ];

  npmDeps = importNpmLock { npmRoot = ./.; };

  inherit (importNpmLock) npmConfigHook;

  buildPhase =
    let
      extensions = "${vscodium}/lib/vscode/resources/app/extensions";
    in
    ''
      npx babel ${extensions}/css-language-features/server/dist/node \
        --out-dir lib/css-language-server/node/

      npx babel ${extensions}/html-language-features/server/dist/node \
        --out-dir lib/html-language-server/node/

      npx babel ${extensions}/json-language-features/server/dist/node \
        --out-dir lib/json-language-server/node/

      # npx babel ${extensions}/markdown-language-features/server/dist/node \
      #   --out-dir lib/markdown-language-server/node/
      # mv lib/markdown-language-server/node/workerMain.js lib/markdown-language-server/node/main.js

      cp -r ${vscode-extensions.dbaeumer.vscode-eslint}/share/vscode/extensions/dbaeumer.vscode-eslint/server/out \
      lib/eslint-language-server
    '';
}
