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
            meter_number: nil,
            current_reading: nil,
            prev_reading: nil,
            current_usage: nil,
            reading_type: nil,
            yearly_usage: %{},
            usage_details: %{}
end
