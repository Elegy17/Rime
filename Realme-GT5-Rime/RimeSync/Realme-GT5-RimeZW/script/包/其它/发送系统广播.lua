require "import"
function 监听广播(c,a)
  import "android.content.Intent"
  import "android.content.IntentFilter"
  import "android.content.BroadcastReceiver"
  when type(c)=="string" c={c}
  local b=BroadcastReceiver{onReceive=function(a1,b1)
      local c1=function(a66)
        if not a66
          local a99=b1.getExtras().keySet().iterator()
          local a88={}
          while(a99.hasNext())
            local a77=a99.next()
            a88[a77]=b1.getExtra(a77)
          end
          return a88
         else
          return b1.getExtra(tostring(a66))
        end
      end
      a(a1,b1,c1)
    end}
  for k,v in pairs(c)
    service.registerReceiver(b, IntentFilter(v))
  end
end

function 发送广播(tab1,tab2)
  import "android.content.Intent"
  import "android.content.IntentFilter"
  import "android.content.BroadcastReceiver"
  when type(tab1)=="string" tab1={tab1}
  for k1,v1 in pairs(tab1)
    local intent= Intent(v1)
    for k,v in pairs(tab2)
      intent.putExtra(tostring(k), v)
    end
    service.sendBroadcast(intent)
  end
end


--[[
dofile(tostring(service.getLuaExtDir("script")).."/包/其它/发送系统广播.lua")
发送广播("com.fooview.android.fooview",{Share=图片组[p+1]}) --Share是Key，可以有多个Key
--]]