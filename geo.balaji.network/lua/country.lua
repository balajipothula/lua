ngx.header["Content-Type"] = "text/html"

--> setting lua library package path.
package.path  = package.path .. ";/webapp/lualib/?.lua"

local sqlite3 = require("sqlite3")
local dbfile  = "/webapp/sqlite/db/geo.db3"
local db      = sqlite3.open(dbfile, "ro")
local disable = ""
local query, record, nrows, ncols, code_iso2, country, sop, code, href

code_iso2 = ngx.var.arg_code_iso2

if nil == code_iso2 then return ngx.redirect("/") end

query = [[SELECT name AS Country_Name, code_iso2 AS Country_Code_ISO2, code_iso3 AS Country_Code_ISO3, tld AS Top_Level_Domain, fips AS FIPS_County_Code, numeric_iso AS UN_Code, geo_name_id AS Country_Geo_Code, e164 AS E164_Country_Code, telephone_code AS Telephone_Code, continent AS Continent, capital AS Capital, time_zone AS Time_Zone, currency AS Currency, language_codes AS Language_Codes, languages AS Languages, area_km_2 AS Area_in_KM_Square, internet_hosts AS Internet_Hosts, internet_users AS Internet_Users, mobile_users AS Mobile_Users, landline_users AS Landline_Users, gdp AS GDP_in_Dollars FROM country WHERE code_iso2 = ']] .. code_iso2 .. [[' COLLATE NOCASE]] --> selecting country info from country table.
record, nrows = db:exec(query)

if nil == record then return ngx.redirect("/") end

country = record[1][1]

ngx.say([[<!DOCTYPE html><html><head><meta charset='UTF-8'><title>]] .. country .. [[</title><style>body{font-family:Arial,Helvetica,Sans-Serif;font-size:16px}table{width:100%;align:center}table,th,td{border:1px solid black;border-collapse:collapse}th{padding:1px;text-align:center}td{padding:1px;text-align:left}table#tablestyle tr:nth-child(even){background-color:#BDBDBD}table#tablestyle tr:nth-child(odd){background-color:#E6E6E6} table#tablestyle th{background-color:#424949;color:#FFFFFF} .tdleft{text-align:left} .tdright{text-align:right} .tdcenter{text-align:center} a{color:green;text-decoration:none} a:visited{color:red} a:hover{color:hotpink} a:active{color:blue} </style></head><body>]])

if nil ~= record then
  ncols = #record
  ngx.say([[<table id='tablestyle'><tbody><thead><tr><th colspan='2' class='tdcenter'>]] .. country .. [[ - Information</th></tr></thead>]])
  for row = 1, nrows do
    for col = 1, ncols do
      ngx.say([[<tr><td class='tdright' style='width: 15%'><b>]] .. record[0][col] .. [[:</b></td><td class='tdleft' style='width: 85%;'><b>]] .. record[col][row] .. [[</b></td></tr>]])
    end
  end
else
  return ngx.redirect("/")
end

query = [[SELECT DISTINCT name AS State_or_Province, code AS State_or_Province_Code FROM region WHERE country_code_iso2 = ']] .. code_iso2 .. [[' COLLATE NOCASE ORDER BY name]] --> selecting states or provinces from region table.
record, nrows = db:exec(query)
if nil ~= record then
  ngx.say([[<tr><td class='tdright'><b>States_or_Provinces:</b></td><td>]])
  for row = 1, nrows do
    sop, code = record[1][row], record[2][row]
    href = [['/city?country=]] .. country .. [[&sop=]] .. sop .. [[&code_iso2=]] .. code_iso2 .. [[&code=]] .. code .. [[']]
    if nil == tonumber(code) then href = [['javascript:alert(" ]] .. sop .. [[ information unavailable..!");']] end
    ngx.say([[<a target='_blank' href=]] .. href .. [[><b>]] .. sop .. [[,</b></a>]])
  end
  ngx.say([[</td></tr>]])
end

ngx.say([[</tbody></table>]])
ngx.say([[</body></html>]])

if db then db:close() end --> closing database connection.
