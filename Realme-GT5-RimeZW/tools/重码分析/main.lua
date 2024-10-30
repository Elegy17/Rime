require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "java.io.*"
import "yaml"
--activity.setTitle('AndroLua+')
--activity.setTheme(android.R.style.Theme_Holo_Light)
--activity.setContentView(loadlayout(layout))


--activity.setTitle('AndroLua+')
dir=activity.getLuaExtDir()
--print(dir)

fs=luajava.astable(File(dir).list())
ds={}
--print(dir,dump(fs),#File(dir).list())
for k,v ipairs(fs)
  if v:find("dict.yaml$")
    table.insert(ds,v)
  end
end
table.sort(ds)
local layout={
  LinearLayout,
  orientation="vertical",
  layout_width="fill",
  layout_height="fill",
  {
    ListView,
    id="list",
    items=ds,
    layout_width="fill",
  },
}

activity.setContentView(loadlayout(layout))
function read(p)
  local f=io.open(p)
  local s=f:read("a")
  f:close()
  return s
end


list.onItemClick=function(l,v)
  activity.newActivity("check",{v.text})
end