ngx.header["Content-Type"] = "text/html"

--> setting lua library package path.
package.path  = package.path .. ";/webapp/lualib/?.lua"
--> setting lua shared object   path.
package.cpath = package.cpath..";/webapp/luaso/mime/?.so;/webapp/luaso/socket/?.so"

ngx.req.read_body()
local args = ngx.req.get_post_args(1)
local no = args["no"]
local title

if nil == no then title = "B.Sc Exam Results" else title = "HT No: " .. no end

ngx.say([[<!DOCTYPE html><html lang='en' ><head><meta charset='UTF-8'><title> ]] .. title .. [[ </title><link rel='stylesheet' href='css/font-awesome.min.css' /><link rel='stylesheet' href='css/style.css' /><style>table{width:45%;align:center}table,th,td{border:1px solid black;border-collapse:collapse}th{padding:1px;text-align:center}td{padding:1px;text-align:left}table#tablestyle tr:nth-child(even){background-color:#99ccff}table#tablestyle tr:nth-child(odd){background-color:#e6f2ff} table#tablestyle th{background-color:#3399ff;color:#000000} .tdleft{text-align:left} .tdright{text-align:right} .tdcenter{text-align:center} </style></head><body>]])

ngx.say([[<div class='wrap'><div class='search'><form name='result' action='/result' method='post'> <input type='text' name='no' minlength='5' maxlength='5' class='searchTerm' placeholder='Enter Hall Ticket Number' /> <input type='submit' class='searchButton' value='&#x1F50E;' title='click to get Result' /></form></div></div>]])

ngx.say([[<br /><br /><br /><br /><br /><br /><br /><br />]])

--local db = string.sub(no, 1, 1)
local db = 1
local pm = 35

local redis    = require("redis")
local client   = redis.connect("127.0.0.1", 6379)
local pong     = client:ping()

if true == pong then
  client:select(db)
  local s = client:hgetall("s:ht:" .. no)
  local math, stat, comp, total, per, result
  math, stat, comp = tonumber(s.math), tonumber(s.stat), tonumber(s.comp)
  total = math + stat + comp
  per   = string.format("%.2f", total / 3)
  if pm <= math and pm <= stat and pm <= comp then result = "Passed" else result = "Failed" end
  ngx.say([[<div>]])
  ngx.say([[<table align='center' id='tablestyle'><tbody><thead><tr><th colspan='2' class='tdcenter'>Hall Ticket No: ]]..no..[[</th></tr></thead>]])
  ngx.say([[<tr><td class='tdright' style='width:20%;'>First Name:     </td><td class='tdleft' style='width:25%'>]] .. s.fname .. [[</td></tr>]])
  ngx.say([[<tr><td class='tdright' style='width:20%'>Last  Name:      </td><td class='tdleft' style='width:25%'>]] .. s.lname .. [[</td></tr>]])
  ngx.say([[<tr><td class='tdright' style='width:20%'>Mathematics:     </td><td class='tdleft' style='width:25%'>]] .. s.math  .. [[</td></tr>]])
  ngx.say([[<tr><td class='tdright' style='width:20%'>Statistics:      </td><td class='tdleft' style='width:25%'>]] .. s.stat  .. [[</td></tr>]])
  ngx.say([[<tr><td class='tdright' style='width:20%'>Computer Science:</td><td class='tdleft' style='width:25%'>]] .. s.comp  .. [[</td></tr>]])
  ngx.say([[<tr><td class='tdright' style='width:20%'>Total Marks:     </td><td class='tdleft' style='width:25%'>]] .. total   .. [[</td></tr>]])
  ngx.say([[<tr><td class='tdright' style='width:20%'>Percentage:      </td><td class='tdleft' style='width:25%'>]] .. per     .. [[</td></tr>]])
  ngx.say([[<tr><td class='tdright' style='width:20%'>Final Result:    </td><td class='tdleft' style='width:25%'>]] .. result  .. [[</td></tr>]])
end

ngx.say([[</tbody></table>]])
ngx.say([[</div>]])
ngx.say([[</body></html>]])

if true == pong then client:quit() end
