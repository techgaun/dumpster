# dogma config to override some settings

use Mix.Config
alias Dogma.Rule

config :dogma,
  rule_set: Dogma.RuleSet.All,
  exclude: [
    ~r(\Apriv/|\Atest/),
  ],
  override: [
    %Rule.ModuleDoc{enabled: false},
    %Rule.LineLength{enabled: false},
    %Rule.ComparisonToBoolean{enabled: false},
    %Rule.FunctionArity{enabled: false},
    %Rule.InterpolationOnlyString{enabled: false},
    %Rule.InfixOperatorPadding{enabled: false}
  ]
