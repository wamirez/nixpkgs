{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, audioSupport ? true
, darwin
, alsa-lib

# passthru.tests.run
, runCommand
, uiua
}:

rustPlatform.buildRustPackage rec {
  pname = "uiua";
  version = "0.0.23";

  src = fetchFromGitHub {
    owner = "uiua-lang";
    repo = "uiua";
    rev = version;
    hash = "sha256-+Q/dn0pGZ3R+UlAt9stQZU1n+WITujJzTxY5dpXc+Bc=";
  };

  cargoHash = "sha256-R4jQ9Or9vh3dtqJH7nPvYM4o1h277sFUf+nC1VQl1Uk=";

  nativeBuildInputs = lib.optionals stdenv.isDarwin [
    rustPlatform.bindgenHook
  ] ++ lib.optionals audioSupport [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
  ] ++ lib.optionals (audioSupport && stdenv.isDarwin) [
    darwin.apple_sdk.frameworks.AudioUnit
  ] ++ lib.optionals (audioSupport && stdenv.isLinux) [
    alsa-lib
  ];

  buildFeatures = lib.optional audioSupport "audio";

  passthru.tests.run = runCommand "uiua-test-run" { nativeBuildInputs = [ uiua ]; } ''
    uiua init;
    diff -U3 --color=auto <(uiua run main.ua) <(echo '"Hello, World!"')
    touch $out;
  '';

  meta = {
    changelog = "https://github.com/uiua-lang/uiua/releases/tag/${src.rev}";
    description = "A stack-oriented array programming language with a focus on simplicity, beauty, and tacit code";
    longDescription = ''
      Uiua combines the stack-oriented and array-oriented paradigms in a single
      language. Combining these already terse paradigms results in code with a very
      high information density and little syntactic noise.
    '';
    homepage = "https://www.uiua.org/";
    license = lib.licenses.mit;
    mainProgram = "uiua";
    maintainers = with lib.maintainers; [ cafkafk tomasajt ];
  };
}
