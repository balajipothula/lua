ngx.header["Content-Type"] = "text/html"

math.randomseed(os.time())
function bingo ()
     local set, temp = {}, {}
     repeat
          e = math.random(1, 25)
          if not temp[e] then table.insert(set, e) temp[e] = true end
     until(#set == 25)
     return set
end

set = bingo()

ngx.say([[<!DOCTYPE html> <html> <head> <title>balaji.network</title> <style> table, th, td { border: 1px solid black; border-collapse: collapse; } th, td { padding: 5px; text-align: center; } </style> </head> <body style='font-family: arial, sans-serif;'> <table align='center' style='width:12%'> <tr> <th colspan='5'><a href='https://bingo.balaji.network' title='Click to generate new BINGO.' style='background-color:#FFFFFF;color:#000000;text-decoration:none'>BINGO</a></th> </tr> <tr>]])

for i = 1, #set do ngx.say([[<td>]]..set[i]..[[</td>]]) if i % 5 == 0 and i % 25 ~= 0 then ngx.say([[</tr><tr>]]) end end

ngx.say([[</tr> </table> </body> </html>]])
