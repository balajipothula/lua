ngx.header["Content-Type"] = "text/html"

--> setting lua library package path.
package.path  = package.path .. ";/webapp/lualib/?.lua"

local sqlite3 = require("sqlite3")
local dbfile  = "/webapp/sqlite/db/geo.db3"
local db      = sqlite3.open(dbfile, "ro")
local query, record, nrows, name, code_iso2, tdcount, i1

--> getting td tag count.
local function gettdcount(nrows)
  local rem = math.fmod(nrows, 5)
  if 0 == rem then return nrows else return nrows + (5 - rem) end
end

ngx.say([[<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Geo Info</title><style>body{font-family:Arial,Helvetica,Sans-Serif;font-size:16px}table{width:100%;align:center} table,th,td{border:0px solid black;border-collapse:collapse} th{padding:1px;text-align:left} td{padding:1px;text-align:left} table#tablestyle td{background-color:#F4F6F7} table#tablestyle th{background-color:#424949;color:#FFFFFF} .tdleft{text-align:left} .tdright{text-align:right} .tdcenter{text-align:center} a{color:green;text-decoration:none} a:visited{color:red} a:hover{color:hotpink} a:active{color:blue} </style></head><body>]])
ngx.say([[<table id='tablestyle'><tbody>]])
ngx.say([[<thead><tr><th colspan='5' class='tdcenter'>Please select country</th></tr><tr><td colspan='5'></td></tr><tr><td colspan='5'></td></tr></thead>]])
for dec = 65, 90 do
  i1 = string.char(dec)
  -- selecting country name based on alphabetical index.
  query = [[SELECT name, code_iso2 FROM ]] .. i1 .. [[_country_name_dst_asc]]
--query = [[SELECT name, lower(code_iso2) AS code_iso2 FROM country WHERE name IS NOT NULL AND code_iso2 IS NOT NULL AND name LIKE ']] .. i1 .. [[%' ORDER BY name ASC]]
  record, nrows = db:exec(query)
  if nil ~= record then
    tdcount = gettdcount(nrows)
    ngx.say([[<thead><tr><th colspan='5'>]] .. i1 .. [[</th></tr></thead>]])
    ngx.say([[<tr>]])
    for row = 1, tdcount do
      if row <= nrows then
        name, code_iso2 = record[1][row], record[2][row]
        ngx.say([[<td class='tdleft'><a target='_blank' title='Click for "]] .. name .. [[" infomation' href='/country?code_iso2=]] .. code_iso2 .. [['><b>]] .. name .. [[</b></a></td>]])
        if 0 == math.fmod(row, 5) then ngx.say([[</tr><tr>]]) end
      else
        ngx.say([[<td class='tdleft'></td>]])
      end
    end
    ngx.say([[</tr>]])
  end
end
ngx.say([[<tr><td></td><td></td></tr>]])
ngx.say([[<tr><th class='tdleft' colspan='3'><a href='#top' title='Go to top'>[&#8679;]</a></th><th class='tdright' colspan='3'><a href='#top' title='Go to top'>[&#8679;]</a></th></tr>]])
ngx.say([[</tbody></table>]])
ngx.say([[</body></html>]])

if db then db:close() end --> closing database connection.
