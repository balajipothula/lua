ngx.header["Content-Type"] = "text/html"

package.path  = package.path .. ";/webapp/lualib/?.lua"

function decodechar(c) return string.char(tonumber(c, 16)) end
 
function decodestring(s) local ds, t = string.gsub(s, "%%(%x%x)", decodechar); return ds end

local sqlite3 = require("sqlite3")
local dbfile  = "/webapp/sqlite/db/geo.db3"
local db      = sqlite3.open(dbfile, "ro")
local disable = ""
local query, record, nrows, ncols, country, sop, code_iso2, code, citycode, nor, nop, pno, rpp, href

country, sop, code_iso2, code = decodestring(ngx.var.arg_country), decodestring(ngx.var.arg_sop), ngx.var.arg_code_iso2, ngx.var.arg_code

if nil ~= tonumber(code) and tonumber(code) < 10 then citycode = "0" .. code else citycode = code end

query = [[SELECT COUNT(*) AS nor FROM city INNER JOIN region ON (city.country_code_iso2 = ']] .. code_iso2 .. [[' COLLATE NOCASE AND city.region = ']] .. citycode .. [[' AND region.country_code_iso2 = ']] .. code_iso2 .. [[' COLLATE NOCASE AND region.code = ']] .. code .. [[')]]
record, nrows = db:exec(query)
nor = tonumber(record[1][1])

pno = 1
rpp = 250
nop = nor / rpp
if 0 < nor % rpp then nop = math.ceil(nop) end
if nil ~= ngx.var.arg_pno then pno = tonumber(ngx.var.arg_pno) end

query = [[SELECT name_local AS City, population AS Population, lat AS Latitude, long AS Longitude FROM city INNER JOIN region ON (city.country_code_iso2 = ']] .. code_iso2 .. [[' COLLATE NOCASE AND city.region = ']] .. citycode .. [[' AND region.country_code_iso2 = ']] .. code_iso2 .. [[' COLLATE NOCASE AND region.code = ']] .. code .. [[') ORDER BY city.name LIMIT ((]] .. pno .. [[ - 1) * ]] .. rpp .. [[), ]] .. rpp .. [[ COLLATE NOCASE]]

record, nrows = db:exec(query)

ngx.say([[<!DOCTYPE html><html><head><meta charset='UTF-8'><title>]] .. country .. [[ - ]] .. sop .. [[ - Page:]] .. pno .. [[</title><style>body{font-family:Arial,Helvetica,Sans-Serif;font-size:16px} table{width:100%;align:center} table,th,td{border:0px solid black;border-collapse:collapse}th{padding:1px;text-align:center}td{padding:1px;text-align:left}table#tablestyle tr:nth-child(even){background-color:#BDBDBD}table#tablestyle tr:nth-child(odd){background-color:#E6E6E6} table#tablestyle th{background-color:#424949;color:#FFFFFF} .tdleft{text-align:left} .tdright{text-align:right} .tdcenter{text-align:center} a{color:lime;text-decoration:none} a:visited{color:red} a:hover{color:hotpink} a:active{color:blue} </style></head><body>]])
ngx.say([[<table id='tablestyle'><tbody>]])

if nil ~= record then
  ncols = #record 
  ngx.say([[<thead><tr><th colspan='4' class='tdcenter'>]] .. country .. [[ - ]] .. sop .. [[ - Cities Information</th></tr><tr><td colspan='4'></td></tr><tr><td colspan='4'></td></tr></thead>]])
  ngx.say([[<thead><tr>]])
  for col = 1, ncols do ngx.say([[<th>]] .. record[0][col] .. [[</th>]]) end
  ngx.say([[</tr></thead>]])
  for row = 1, nrows do
    ngx.say([[<tr>]])
    for col = 1, ncols do
      if 3 == col or 4 == col then
        ngx.say([[<td class='tdcenter'><b>]] .. string.format("%.7f", record[col][row]) .. [[</b></td>]])
      elseif 2 == col then
        ngx.say([[<td class='tdright'><b>]] .. record[col][row] .. [[</b></td>]])    
      else
        ngx.say([[<td class='tdleft'><b>]] .. record[col][row] .. [[</b></td>]]) 
      end
    end
    ngx.say([[</tr>]])
  end
  if 1 < nop then   
    ngx.say([[<tr><th class='tdcenter' colspan='4'>|]])
    for i = 1, nop do
      href = [['/city?country=]] .. country .. [[&sop=]] .. sop .. [[&code_iso2=]] .. code_iso2 .. [[&code=]] .. code .. [[&pno=]] .. i .. [[' ]]
      if i == pno then href = [['javascript:alert("You are already in page:]] .. pno .. [[");']] end
      ngx.say([[<a href=]] .. href .. [[>]] .. i .. [[</a> |]])
    end
  end
  ngx.say([[</th></tr>]])
  ngx.say([[<tr><td></td><td></td></tr>]])
  ngx.say([[<tr><th class='tdleft' colspan='2'><a href='#top' title='Go to top'>[&#8679;]</a></th><th class='tdright' colspan='2'><a href='#top' title='Go to top'>[&#8679;]</a></th></tr>]])
  else
    ngx.say([[<tr><th class='tdcenter' colspan='4'>Sorry no information..! Please click <a href='/' title='Go to Index Page'>Index Page</a></th></tr>]])
    ngx.say([[</tbody></table>]])
end

ngx.say([[</body></html>]])

if db then db:close() end --> closing database connection.
