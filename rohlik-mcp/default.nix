{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:

let
  rohlik-api = python3Packages.callPackage ../rohlik-api {};
  version = "0.4.0";
  hash = "sha256-3G2AqkqPQSdn9e4sJYQrbRUbeosaIzlQ2o4XGrIpQNY=";
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rohlik-mcp";
  inherit version;
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "dvejsada";
    repo = "rohlik-mcp";
    tag = "v${finalAttrs.version}";
    inherit hash;
  };

  build-system = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  dependencies = with python3Packages; [
    fastmcp
    rohlik-api
  ];

  optional-dependencies = with python3Packages; {
    dev = [
      black
      mypy
      pytest
      pytest-asyncio
      ruff
    ];
  };

  pythonImportsCheck = [
    "rohlik_mcp"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial MCP server for Rohlik.cz Delivery Service";
    homepage = "https://github.com/dvejsada/rohlik-mcp";
    changelog = "https://github.com/dvejsada/rohlik-mcp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "rohlik-mcp";
  };
})
