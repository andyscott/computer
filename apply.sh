#!/usr/bin/env bash

nix build --impure
./result/sw/bin/darwin-rebuild switch --flake .#default --impure