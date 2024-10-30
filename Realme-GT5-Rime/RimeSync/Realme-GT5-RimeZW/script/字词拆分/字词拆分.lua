--[[
--无障碍版专用脚本
--字词拆分
--版本号: 1.1
--用途：根据当前候选,将其拆分成单个汉字并显示以下内容,分别是单字,86编码,98编码及拼音.可选,详细设置见下面

]]




require "import"
import "android.widget.*"
import "android.view.*"
import "java.io.*"
import "android.content.*"

import "script.包.文件操作.递归查找文件"
--字符串操作
import "script.包.字符串.分割字符串"
--import "script.包.字符串.中英字符串长度"
import "script.包.字符串.倒找字符串"
import "script.包.字符串.其它"
local 导入内容 = (...) --当前候选或选中文字
local 目录=tostring(service.getLuaExtDir("script"))
local 脚本名=debug.getinfo(1,"S").source:sub(2)--获取Lua脚本的完整路径
local 相对脚本名=string.sub(脚本名,#目录+1)--相对路径
local 脚本目录=string.sub(脚本名,1,倒找字符串(脚本名,"/")-1)



function 单字编码(单字,文件)
	 for 行内容 in io.lines(文件) do
     if string.find(行内容,"^"..单字) != nil && #行内容>0 then 
      return 行内容
     end 
    end
  return ""
end

function 候选编码(候选内容,文件)
	local 单字组={}
   local 中英字符串长=中英字符串长度(候选内容)
   local 内容编码=""
   for i=1, 中英字符串长 do
    单字组[i]=SubStringUTF8(候选内容,i,i)
    内容编码=内容编码..单字编码(单字组[i],文件).." "
   end
   local 内容提示=File(文件).getName()
   内容提示=string.sub(内容提示,1,#内容提示-4)
	内容编码=内容编码.."【"..内容提示.."】"
    return 内容编码
	
end

function 单字拆分(候选内容)
 local 文件组={}
 文件组=递归查找文件(File(脚本目录.."/拆分数据/"),".txt")
 local 返回内容组={}
 local 中英字符串长=中英字符串长度(候选内容)
 for i=1, 中英字符串长 do
  返回内容组[#返回内容组+1]=SubStringUTF8(候选内容,i,i)
 end
 for i=1, #文件组 do
  返回内容组[#返回内容组+1]=候选编码(候选内容,tostring(文件组[i]))
 end
 return 返回内容组
end

local 导入内容 = (...) --当前候选或选中文字
local 目录=tostring(service.getLuaExtDir("script"))
local 脚本名=debug.getinfo(1,"S").source:sub(2)--获取Lua脚本的完整路径
local 相对脚本名=string.sub(脚本名,#目录+1)--相对路径
local 脚本目录=string.sub(脚本名,1,倒找字符串(脚本名,"/")-1)


 local 按键组={}
 --第1行
 local 按键={}
 按键["label"]="字词拆分"
 按键["click"]=""
 按键["width"]=100
 按键["height"]=20
 按键组[#按键组+1]=按键
 --第2行
 local 按键={}
 按键["width"]=33
 按键组[#按键组+1]=按键
 local 按键={}
 按键["click"]="Left"
 按键["has_menu"]="Left"
 按键["width"]=33
 按键组[#按键组+1]=按键
 local 按键={}
 按键["width"]=33
 按键组[#按键组+1]=按键
 --第3行
 local 按键={}
 按键["click"]="Up"
 按键["has_menu"]="Up"
 按键["width"]=33
 按键组[#按键组+1]=按键
 local 按键={}
 按键["click"]={label="拆分", send="function",command= 相对脚本名,option= "%1$s<run>"}
 按键["width"]=33
 按键组[#按键组+1]=按键
 local 按键={}
 按键["click"]="Down"
 按键["has_menu"]="Down"
 按键["width"]=33
 按键组[#按键组+1]=按键
 --第4行
 local 按键={}
 按键["width"]=33
 按键组[#按键组+1]=按键
 local 按键={}
 按键["click"]="Right"
 按键["has_menu"]="Right"
 按键["width"]=33
 按键组[#按键组+1]=按键
 local 按键={}
 按键["width"]=33
 按键组[#按键组+1]=按键
 --第5行
 import "script.包.其它.主键盘"
 local 按键=主键盘()
 按键["width"]=100
 按键["height"]=30
 按键组[#按键组+1]=按键
 
 
service.setKeyboard{
  name="字词拆分",
  ascii_mode=0,
  width=33,
  height=50,
  keys=按键组
  }


if #导入内容>5 then
if string.sub(导入内容,#导入内容-4)=="<run>" then 
  local 内容组={}
  内容组=单字拆分(string.sub(导入内容,1,#导入内容-5))
  task(100,function() service.addCompositions(内容组) end)
end
end