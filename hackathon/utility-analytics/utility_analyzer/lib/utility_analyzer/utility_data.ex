defmodule UtilityAnalyzer.UtilityData do
  defstruct account_num: nil,
            customer_name: nil,
            service_address: nil,
            zipcode: nil,
            statement_date: nil,
            amount: nil,
            prev_amount: nil,
            last_payment_date: nil,
            due_date: nil,
            delinquent_date: nil,
            delinquent_amount: nil,
            amount_breakdown: %{},
            meter_readings: [],
            yearly_usage: %{},  # not important right now
            usage_summary: %{},
            usage_details: %{},
            tariff: nil, #eg. 3m Large General, etc.
            secondary_tariff: nil
end
