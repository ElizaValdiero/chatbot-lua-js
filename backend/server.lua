package.path = package.path .. ";./shared/?.lua"
local socket = require("socket")
local faq = require("faq")

function buscarResposta(mensagem)
  local msg = mensagem:lower()

  for _, item in ipairs(faq) do
    if msg:find(item.pergunta) then
      return item.resposta
    end
  end

  return "Não entendi sua dúvida. Tente perguntar sobre horário, preço, cancelamento ou contato."
end

local server = assert(socket.bind("127.0.0.1", 8080))
print("Servidor rodando em http://localhost:8080")

while true do
  local client = server:accept()
  client:settimeout(5)

  local content_length = 0
  while true do
    local line = client:receive("*l")
    if not line or line == "" then break end
    local len = line:match("Content%-Length: (%d+)")
    if len then content_length = tonumber(len) end
  end

  local body = ""
  if content_length > 0 then
    body = client:receive(content_length) or ""
  end

  local mensagem = body:match('"message"%s*:%s*"(.-)"%s*}') or ""

  local resposta = buscarResposta(mensagem)

  local json = '{"reply":"' .. resposta .. '"}'

  client:send("HTTP/1.1 200 OK\r\n")
  client:send("Content-Type: application/json\r\n")
  client:send("Access-Control-Allow-Origin: *\r\n")
  client:send("Access-Control-Allow-Methods: POST, OPTIONS\r\n")
  client:send("Access-Control-Allow-Headers: Content-Type\r\n")
  client:send("Content-Length: " .. #json .. "\r\n")
  client:send("\r\n")
  client:send(json)

  client:close()
end