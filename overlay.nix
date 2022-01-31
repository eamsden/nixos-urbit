sources: self: super:
let
  optionalList = xs: if xs == null then [ ] else xs;
  prefix = "${sources.urbit}/nix/pkgs";
  urSources = import "${sources.urbit}/nix/sources.nix";
  urbitOverlay = self: super: {
    sources = urSources;
    ca-bundle = self.callPackage "${prefix}/ca-bundle" { };
    ent = self.callPackage "${prefix}/ent" { };
    libaes_siv = self.callPackage "${prefix}/libaes_siv" { }; 
    murmur3 = self.callPackage "${prefix}/murmur3" { };
    softfloat3 = self.callPackage "${prefix}/softfloat3" { };
    herb = self.callPackage "${prefix}/herb" { };
    arvo = self.callPackage "${prefix}/arvo" { };
    ivory = self.callPackage "${prefix}/pill/ivory.nix" { };
    brass = self.callPackage "${prefix}/pill/brass.nix" { };
    solid = self.callPackage "${prefix}/pill/solid.nix" { };
    marsSources = self.callPackage "${prefix}/marsSources" { };
    urbit = self.callPackage "${prefix}/urbit" { };
    urcrypt = self.callPackage "${prefix}/urcrypt" { };
    docker-image = self.callPackage "${prefix}/docker-image" { };
    fetchGitHubLFS = self.callPackage "${sources.urbit}/nix/lib/fetch-github-lfs.nix" { stdenvNoCC = self.stdenvNoCC // { inherit (self) lib; }; };
    bootFakeShip = self.callPackage "${sources.urbit}/nix/lib/boot-fake-ship.nix" { };
    testFakeShip = self.callPackage "${sources.urbit}/nix/lib/test-fake-ship.nix" { };
  }; 
  # PR this back into urbit
  fixedArmOverlay = self: super:
    let isAarch64 = super.stdenv.hostPlatform.isAarch64;
    in super.lib.optionalAttrs isAarch64 {
      libsigsegv = super.libsigsegv.overrideAttrs (attrs: {
        preConfigure = (attrs.preConfigure or "") + ''
          sed -i 's/^CFG_FAULT=$/CFG_FAULT=fault-linux-arm.h/' configure
          '';
      });
    };
  fixedNativeOverlay = final: prev:
    let
      optionalList = xs: if xs == null then [ ] else xs;
    in {
      h2o = prev.h2o.overrideAttrs (_attrs: {
        version = final.sources.h2o.rev;
        src = final.sources.h2o;
        outputs = [ "out" "dev" "lib" ];
        meta.platforms = prev.lib.platforms.linux ++ prev.lib.platforms.darwin;
      });
      libsigsegv = prev.libsigsegv.overrideAttrs (attrs: {
        patches = optionalList attrs.patches ++ [
          "${sources.urbit}/nix/pkgs/libsigsegv/disable-stackvma_fault-linux-arm.patch"
          "${sources.urbit}/nix/pkgs/libsigsegv/disable-stackvma_fault-linux-i386.patch"
        ];
      });
      curlUrbit = prev.curlMinimal.override {
        http2Support = false;
        scpSupport = false;
        gssSupport = false;
        ldapSupport = false;
        brotliSupport = false;
      };
      lmdb = prev.lmdb.overrideAttrs (attrs: {
        patches =
          optionalList attrs.patches ++ prev.lib.optional prev.stdenv.isDarwin [
            ../pkgs/lmdb/darwin-fsync.patch
          ];
      });
    };
  urbitPkgs = self.appendOverlays [
    urbitOverlay
    #(import "${sources.urbit}/nix/overlays/arm.nix")
    fixedArmOverlay
    (import "${sources.urbit}/nix/overlays/musl.nix")
    #(import "${sources.urbit}/nix/overlays/native.nix")
    fixedNativeOverlay
  ];
in {
  secp256k1 = super.secp256k1.overrideAttrs (_old: { CC_FOR_BUILD = "${self.buildPackages.stdenv.cc}/bin/gcc"; });
  urbit = urbitPkgs.urbit;
  inherit urbitPkgs;
}
