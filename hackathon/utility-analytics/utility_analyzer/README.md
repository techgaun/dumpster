# UtilityAnalyzer

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add utility_analyzer to your list of dependencies in `mix.exs`:

        def deps do
          [{:utility_analyzer, "~> 0.0.1"}]
        end

  2. Ensure utility_analyzer is started before your application:

        def application do
          [applications: [:utility_analyzer]]
        end

## Configuration

You can place all the files to be parsed in `{PROJECT_ROOT}/files/src`. You can also drop new files as you go in that directory.

## Usage

```
mix run --no-halt
```
