require "import"
import "android.widget.*"
import "android.view.*"
import "keyboard"
activity.setContentView(keyboard)


keys={
  "1","2","3","4","5","6","7","8","9","0",
  "q","w","e","r","t","y","u","i","o","p",
  "a","s","d","f","g","h","j","k","l",";",
  "z","x","c","v","b","n","m",",",".","/",
  "Up","Down","Left","Right","PageUp","PageDown","\\","Space","BackSpace","Enter",
}

name,ks,kn,tj=...
activity.title=name
tv.text=tj
ks=luajava.astable(ks)
kk=kn/26
for k,v pairs(ks)
  kk=math.max(kk,v)
end
local adapter=LuaAdapter(activity,{
  TextView,
  id="tv",
  textSize=16,
  layout_height="55dp",
  layout_width="fill",
  gravity="center"
})
--print(ks)
adapter2=list.adapter
for k,v pairs(keys)
  --  print(ks[v])
  local ts=18
  if #v>1
    ts=12
    end
  adapter.add{
    tv={
      text=v,
      textSize=ts,
      backgroundColor=0xff7f00|(tointeger(0xff*(ks[v] or 0)/kk)*0x1000000)
    }
  }
  if ks[v]
    adapter2.add(string.format("%s:    \t%5d    \t%.02f%%",v,ks[v] or 0,(ks[v] or 0)/kn*100))
  end
end
grid.adapter=adapter