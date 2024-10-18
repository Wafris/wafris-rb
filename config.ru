require "rack"
require "rack/reloader"

use Rack::Reloader, 0  # 0 means reload on every request

# Encoding defaults
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "./lib/wafris/middleware"

run Wafris::Middleware.new
