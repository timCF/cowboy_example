#!/bin/bash
mix compile.protocols
elixir --erl "+K true +A 32" -pa _build/dev/consolidated/ -S mix run --no-halt