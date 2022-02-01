# nixos-urbit
[Overlay](https://nixos.org/manual/nixpkgs/stable/#chap-overlays) and [NixOS module](https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules) for [Urbit](https://urbit.org)

## Usage
One way or another you need to fetch this repo from your nix sources, and then import it and add the `overlay`
attribute to your package set. The usual way is to add it to the `overlays` list passed to nixpkgs.

When we have a NixOS module this will be done automatically.

### Using `niv`
Use `niv` to add `nixos-urbit` as a source:

```
$ niv add nixos-urbit
```

Then in the configuration for your package set:
`{ overlays = [ ... (import sources.nixos-urbit).overlay]; }`
(where ... is your other overlays).

