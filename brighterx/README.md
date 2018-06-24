# Brighterx [![Hex version](https://img.shields.io/hexpm/v/brighterx.svg "Hex version")](https://hex.pm/packages/brighterx) ![Hex downloads](https://img.shields.io/hexpm/dt/brighterx.svg "Hex downloads") [![Build Status](https://semaphoreci.com/api/v1/techgaun/brighterx/branches/master/badge.svg)](https://semaphoreci.com/techgaun/brighterx) [![Coverage Status](https://coveralls.io/repos/github/Brightergy/brighterx/badge.svg?branch=master)](https://coveralls.io/github/Brightergy/brighterx?branch=master)

> Elixir client for BrighterLink API

## Installation

Add brighterx to your list of dependencies in `mix.exs`:

        def deps do
          [{:brighterx, github: "Brightergy/brighterx"}]
        end

Or from hex:

        def deps do
          [{:brighterx, "~> 0.0.3"}]
        end

Ensure you list `brighterx` in application dependency in your mix.exs file.

        [applications: [:brighterx]]

## Usage

You can use the functions in `Brighterx.Api` for making requests to RESTful api of BrighterLink. There are shorthand functions that wrap the common get requests on the Brighterlink resources. Right now, we do not yet offer authentication via username and password so you will need to use jwt token. Please export your jwt token as `JWT` environment variable.

### Examples

```elixir
Brighterx.Api.create(Brighterx.Resources.Device, %{name: "Test Thermostat", identifier: "00:01", facility_id: 1, type: "thermostat"})

Brighterx.Api.find(Brighterx.Resources.Company, [params: %{name: "Brightergy"}])

Brighterx.Api.update(Brighterx.Resources.Device, 1, %{name: "7th floor south"})

Brighterx.Api.get_company(1)

Brighterx.Api.get_company("Brightergy")
```

### Overriding Environment

You can override the default environment by exporting the environment variable `BRIGHTERX_ENV` which can be set one of `dev`, `stage` or `prod`. This takes precedence over the `Mix.env`.
