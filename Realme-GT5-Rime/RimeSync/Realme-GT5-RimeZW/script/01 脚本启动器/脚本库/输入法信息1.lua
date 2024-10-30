--[[中文输入法（同文无障碍版）

脚本名称：输入法信息
功能：上屏输入法相关信息
版本：1.6
作者：风之漫舞 bj19490007@163.com(不一定及时看到)
改写：星乂尘 1416165041@qq.com

2020.11.27
]]
require "import"
import "android.os.Build"
import "yaml"
import "com.osfans.trime.Rime"
import "com.osfans.trime.Config"

local function app()
  local pm,pkg=service.getPackageManager(),service.getPackageName()
  local Info=pm.getPackageInfo(pkg,0)
  local info=pm.getApplicationInfo(pkg,0)
  return {
    --pkg=pkg,
    name=info.loadLabel(pm),
    --icon=info.loadIcon(pm),
    update=os.date("%y-%m-%d %H:%M",Info.lastUpdateTime//1000),
    ver=Info.versionName}
end
app=app()

local 主题文件=service.getLuaExtDir().."/"..Config.get().getTheme()..".yaml"
local yaml组=yaml.load(io.readall(主题文件))
local 当前主题=yaml组["name"]

local 速度=service.getSpeed()
速度=速度>0 and 速度 or "暂无统计信息"

local t={"▂▂▂▂▂▂▂▂",
  "📟输入法："..app.name,
  "🖍版本名："..app.ver,
  "📌最近更新："..app.update,
  "🖊方案ID："..Rime.getSchemaId(),
  "🖋方案名："..Rime.getSchemaName(),
  "🎦当前主题："..当前主题,
  "📠打字速度："..速度,
  "✒RIME版本："..Rime.get_librime_version(),
  --"✒RIME版本："..Rime.get_version(),
  "⌨OpenCC版本："..Rime.get_opencc_version(),
  "📄Trime版本："..Rime.get_trime_version(),
  "📱设备型号："..Build.MODEL,
  "🚪SDK版本："..Build.VERSION.SDK,
  "🎴系统版本："..Build.VERSION.RELEASE
}
t=table.concat(t,"\n")

task(99,function()
  service.addCompositions({t})
end)
