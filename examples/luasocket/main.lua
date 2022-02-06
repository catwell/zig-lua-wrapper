-- wrap with pcall because otherwise errors won't be displayed
local ok, err = pcall(function()
  local io = require "io"
  local http = require "socket.http"
  local ltn12 = require "ltn12"
  http.request {
    url = "http://example.com",
    sink = ltn12.sink.file(io.stdout)
  }
end)

if not ok then
  io.stderr:write(err)
  io.stderr:write("\n")
  os.exit(1)
end
