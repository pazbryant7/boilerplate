{
  description = "Full-stack dev environment (replaces Mason toolchain)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # ── lua ──────────────────────────────
            stylua
            selene
            luaPackages.luacheck
            lua-language-server

            # ── web dev (js/ts) ─────────────────
            nodejs-slim
            nodePackages.typescript-language-server
            tailwindcss-language-server
            vscode-langservers-extracted # eslint/json/css/html LSPs
            oxfmt # oxc formatter, replaces prettier
            superhtml # HTML validator/formatter/LSP

            # ── docker ───────────────────────────
            dockerfile-language-server-nodejs # verify name w/ `nix search`
            docker-compose-language-service

            # ── bash ─────────────────────────────
            shfmt
            shellcheck
            shellharden
            nodePackages.bash-language-server # verify namespace w/ `nix search`

            # ── golang ───────────────────────────
            go
            gopls
            gofumpt
            gotools # provides goimports

            # ── python ───────────────────────────
            ruff
            basedpyright

            # ── c ────────────────────────────────
            clang-tools # bundles clangd + clang-format

            # ── nix ──────────────────────────────
            nil
            statix
            nixfmt

            # ── language agnostic ────────────────
            typos
          ];

          shellHook = ''
            corepack enable
            echo "⚡ Dev environment ready"
            echo "Node.js: $(node --version)"
            echo "Go:      $(go version)"

            if [ -z "$IN_NIX_ZSH" ]; then
              export IN_NIX_ZSH=1
              exec zsh
            fi

          '';
        };

        formatter = pkgs.nixfmt-tree;
      }
    );
}
