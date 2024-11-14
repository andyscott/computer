#!/usr/bin/env bash

nix build .
./result/sw/bin/darwin-rebuild switch --flake .