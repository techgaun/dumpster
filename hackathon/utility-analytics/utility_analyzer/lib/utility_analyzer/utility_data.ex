defmodule UtilityAnalyzer.UtilityData do
  defstruct account_num: nil,
            customer_name: nil,
            service_address: nil,
            date: nil,
            amount: nil,
            prev_amount: nil,
            last_payment_date: nil,
            due_date: nil,
            amount_breakdown: %{},
            seasonal_use: nil,
            meters: [],
            yearly_usage: %{},
            usage_details: %{},
            service_type: nil,
            service_details: %{electric: [], gas: []}
end
