require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "layout"
import "cjson"
--activity.setTitle('AndroLua+')
--activity.setTheme(android.R.style.Theme_Holo_Light)
activity.setContentView(loadlayout(layout))
local path=activity.getLuaExtPath("data.json")
local data=cjson.decode(io.readall(path))
local adapter=list.adapter
adapter.clear()
local schema=data.schema
local key=data.key
local char=data.text
local t={}
for k,v pairs(schema)
  table.insert(t,k)
end
table.sort(t)
for k,v ipairs(t)
    adapter.add(schema[v].name)
end

function getallkey(t)
  local n=0
  for k,v pairs(t)
    n=v+n
  end
  return n
end
function getallchar(t)
  local n=0
  for k,v pairs(t)
    n=v*tonumber(k)+n
  end
  return n
end


list.onItemClick=function(l,v,i,p)
  local kn=tointeger(getallkey(key[t[p]]))
  local cn=tointeger(getallchar(char[t[p]]))
  local tm=schema[t[p]].time
 local sec = tm//1000
 local min= sec//60
 local hour= min//60
 local day=hour//24
 sec=sec%60
 min=min%60
 hour=hour%60

  activity.newActivity("showkey",{v.text,HashMap(key[t[p]]),kn,string.format([[
按键次数:%d
输入字数:%d
使用时间:%s]],kn,cn,string.format("%d %d:%d:%d",day,hour,min,sec))})
end