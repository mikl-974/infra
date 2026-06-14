{ pkgs }:
[
  (pkgs.symlinkJoin {
    name = "element-desktop";
    paths = [ pkgs.element-desktop ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/element-desktop \
        --add-flags "--password-store=basic"
    '';
  })
]
