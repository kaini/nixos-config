{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  aiohttp,
  black,
  mypy,
  pytest,
  pytest-asyncio,
  pytest-cov,
  ruff,
  nix-update-script,
}:

let
  version = "0.2.0";
  hash = "sha256-sfJQApbYTtrxmzWC4P1B3pyrh0kec9FebVfPM2L3sSQ=";
in
buildPythonPackage (finalAttrs: {
  pname = "rohlik-api";
  inherit version;
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "dvejsada";
    repo = "rohlik_api_python";
    tag = "v${finalAttrs.version}";
    inherit hash;
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    aiohttp
  ];

  optional-dependencies = {
    dev = [
      black
      mypy
      pytest
      pytest-asyncio
      pytest-cov
      ruff
    ];
  };

  pythonImportsCheck = [
    "rohlik_api"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python package for Rohlik.cz API";
    homepage = "https://github.com/dvejsada/rohlik_api_python";
    changelog = "https://github.com/dvejsada/rohlik_api_python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
