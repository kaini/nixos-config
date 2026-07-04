{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:

let
  rohlik-api = python3Packages.callPackage ../rohlik-api {};
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rohlik-mcp";
  version = "0.4.0";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "dvejsada";
    repo = "rohlik-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3G2AqkqPQSdn9e4sJYQrbRUbeosaIzlQ2o4XGrIpQNY=";
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
