defmodule HubGateway.Helpers.LogUploaderTest do
  use ExUnit.Case
  alias HubGateway.Helpers.LogUploader
  import Mock

  test "log_uploader performs log uploading call as expected" do
    ident = "test-ident"
    tmp_srcfile = Path.join([System.tmp_dir(), "#{System.system_time(:second)}.hub-gateway"])
    tmp_dstfile = Path.join([System.tmp_dir(), "#{ident}.tar.gz"])
    content = "just a tst content for log file"
    File.write!(tmp_srcfile, content)

    with_mock HTTPoison, [post: fn _, _, _ -> :ok end] do
      assert :ok = LogUploader.upload(ident, tmp_srcfile, "faketoken")
      assert File.exists?(tmp_srcfile)
      refute File.exists?(tmp_dstfile)
      File.rm!(tmp_srcfile)
    end
  end
end
