defmodule UtilityAnalyzer.Watcher do
  import UtilityAnalyzer.Config
  use ExFSWatch, dirs: src_dir

  @doc """
  callback when the process needs to be stopped
  """
  def callback(:stop) do
    :ok
  end

  @doc """
  callback for file addition event
  """
  def callback(file_path, [:modified, :closed]) do
    if Path.extname(file_path) === ".pdf" do
      UtilityAnalyzer.start_worker(file_path)
    end
  end

  @doc """
  callback for all other events we don't care about
  [:renamed, :isdir, :undefined]
  """
  def callback(_file_path, _evt) do
    :ok
  end
end
