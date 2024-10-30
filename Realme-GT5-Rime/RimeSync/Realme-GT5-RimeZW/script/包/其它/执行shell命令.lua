require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"


function exec(cmd,sh,su)
  cmd=tostring(cmd)
  if sh==true then
    cmd=io.open(cmd):read("*a")
  end
  if su==0 then
    p=io.popen(string.format('%s',cmd))
   else
    p=io.popen(string.format('%s',"su -c "..cmd))
  end
  local s=p:read("*a")
  p:close()
  return s
end
--exec("路径或者命令",true,0)
--传入第一个变量是sh脚本路径或者shell命令
--如果第一个变量是sh脚本路径，那么第二个传入true，如果不是，则传入false
--第三个变量代表是否以root权限执行，传入0，代表不以root权限执行




--返回信息=exec(activity.getLuaDir("shell.sh"),true,0)  --不以root权限执行工作目录下的shell.sh文件
--返回信息=exec("am start -n com.tencent.mm/.plugin.offline.ui.WalletOfflineCoinPurseUI",false,1)  --以root权限执行shell命令
