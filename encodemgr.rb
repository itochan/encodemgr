require 'logging'
require 'open3'

LOG = "/var/log/encodemgr/encoder.log"

ENCODE_COMMAND = "HandBrakeCLI -e x264 --aencoder copy:aac -i <input> -o <output> -q 23 -X 1280 -Y 720 --decomb bob"
SOURCE_DIR = "/tank/video"
ORIGINAL_DIR = "/tank/video/encoded_ts"
ENCODED_DIR = "/tank/video/encoded"
TS_EXTENSION = %w{.ts .m2ts}

log = Logging.logger(LOG)

Dir.glob(Pathname.new(SOURCE_DIR).join("*")).each do |input|
  next unless TS_EXTENSION.include?(File.extname(input.first))
  log.info("Started: #{input}")

  begin
    ext = File.extname(input)
    output = Pathname.new(ENCODED_DIR).join(File.basename(input.sub(/#{ext}\Z/, ".mp4")))
    command = get_command(input, output)
    log.debug("Execute: #{command}")
    Open3.capture3(command) do |stdin, stdout, stderr|
      log.write(stdin)
      log.write(stdout)
      log.write(stderr)
    end
  rescue
    log.error("Fail!")
    next
  end

  log.info("Finished: #{input}")
end

def get_command(input, output)
  ENCODE_COMMAND.sub("<input>", input).sub("<output>", output)
end
