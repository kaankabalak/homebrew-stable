class Minio < Formula
  # minio specific
  git_tag = "RELEASE.2019-07-10T00-34-56Z"

  desc "MinIO is an Amazon S3 compatible object storage server"
  homepage "https://github.com/minio/minio"
  url "https://github.com/minio/minio.git"
  version git_tag.gsub(%r'[^\d]+', '') + 'Z'
  revision 1

  if OS.mac?
    url "https://dl.minio.io/server/minio/release/darwin-amd64/minio.#{git_tag}"
    sha256 "5d3e35ccdb759b38eabf2cd534a7311e76b2d521a9c76d04cd22df2c74c1a652"
  elsif OS.linux?
    url "https://dl.minio.io/server/minio/release/linux-amd64/minio.#{git_tag}"
    sha256 "eb8d078a2787423dcb83ca516d5e7af194a2a8063086c435e0467ce53351c824"
  end

  bottle :unneeded
  depends_on :arch => :x86_64

  def install
    bin.install Dir.glob("minio.*").first => "minio"
  end

  test do
    (testpath/"config.json").write <<-EOS
{
        "version": "14",
        "credential": {
                "accessKey": "minio",
                "secretKey": "minio123"
        },
        "region": "us-east-1",
        "browser": "on",
        "logger": {
                "console": {
                        "level": "error",
                        "enable": true
                },
                "file": {
                        "level": "error",
                        "enable": false,
                        "filename": ""
                }
        },
        "notify": {
                "redis": {
                        "1": {
                                "enable": true,
                                "address": "127.0.0.1:6379",
                                "password": "",
                                "key": "minio_events"
                        }
                }
        }
}
EOS
    minio_io = IO.popen("#{bin}/minio --config-dir #{testpath} server #{testpath}/export", :err=>[:child, :out])
    sleep 1
    Process.kill("INT", minio_io.pid)
    assert_match("getsockopt: connection refused", minio_io.read)
  end
end
