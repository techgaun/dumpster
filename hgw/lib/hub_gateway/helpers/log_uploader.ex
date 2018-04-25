defmodule HubGateway.Helpers.LogUploader do
  @moduledoc """
  Pass the identifier and log stream and this will make a request to backend API
  """

  def upload(ident, log, token) do
    tmpfile = Path.join([System.tmp_dir(), "#{ident}.tar.gz"])
    File.write!(tmpfile, log)
    url = "#{Application.get_env(:hub_gateway, :api_server)}/devices/#{ident}/log-upload"

    multipart_opts = {
      :multipart,
      [{:file, tmpfile, [{"Content-Type", "application/gzip"}]}]
    }
    HTTPoison.post(url, multipart_opts, [{"Authorization", "Bearer #{token}"}])
    File.rm!(tmpfile)
  end
end
