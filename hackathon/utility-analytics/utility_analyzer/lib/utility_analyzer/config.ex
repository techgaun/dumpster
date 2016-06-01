defmodule UtilityAnalyzer.Config do
  def src_dir, do: Application.get_env(:utility_analyzer, :src_dir)
  def dest_dir, do: Application.get_env(:utility_analyzer, :dest_dir)
  def result_dir, do: Application.get_env(:utility_analyzer, :result_dir)
  def tmp_dir, do: Application.get_env(:utility_analyzer, :tmp_dir)
end
