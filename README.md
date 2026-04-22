# Nix Flake Usage Notes

## Running Packages with Flakes

To run a package (e.g., fastfetch) with the modern Nix CLI and flakes:

```sh
nix shell nixpkgs#fastfetch
```

This does not require setting NIX_PATH or using legacy nix-shell. This is the recommended way for all flake-based workflows.

## Legacy Commands (nix-shell, nixos-build-vms)

Classic commands like `nix-shell -p ...` and `nixos-build-vms network.nix` require NIX_PATH to be set, even if you use flakes elsewhere. If you see errors about `<nixpkgs>` not being found, set NIX_PATH in your shell:

```sh
export NIX_PATH="nixpkgs=$(nix eval --raw nixpkgs#path)"
```

Or use the `-I` flag:

```sh
nixos-build-vms -I nixpkgs=$(nix eval --raw nixpkgs#path) network.nix
```

## Summary
- Use `nix shell nixpkgs#pkg` for flake-native workflows.
- Set NIX_PATH or use `-I` for legacy commands that use `<nixpkgs>`.
