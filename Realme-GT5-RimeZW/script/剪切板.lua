--[[
两排-自定义剪切板5.0.6


<b>用法二</b>
第①步 将 脚本文件解压放置 Android/rime/script 文件夹内,
默认脚本路径为Android/rime/script/自定义剪切板/自定义剪切板.lua

第②步 向主题方案中加入按键
以 XXX.trime.yaml主题方案为例
找到以下节点preset_keys,加入以下内容

preset_keys:
  lua_script_cvv: {label: 剪切板, functional: false, send: function, command: "自定义剪切板/自定义剪切板.lua", option: "default"}
向该主题方案任意键盘按键中加入上述按键既可

]]




require "import"
import "android.widget.*"
import "android.view.*"
import "android.graphics.RectF"
import "android.media.MediaPlayer"
import "android.graphics.drawable.StateListDrawable"
import "java.io.File"
import "android.text.Html"
import "android.os.*"
import "com.kuaima.input.*" --载入包
import "android.graphics.Typeface"
import "android.content.Context" 
import "android.speech.tts.*"
import "yaml"
import "java.math.BigInteger"


local 输入法目录=tostring(service.getLuaExtDir("")).."/"
local 脚本目录=tostring(service.getLuaExtDir("script")).."/"
local 脚本路径=debug.getinfo(1,"S").source:sub(2)--获取Lua脚本的完整路径
local 纯脚本名=File(脚本路径).getName()
local 目录=string.sub(脚本路径,1,#脚本路径-#纯脚本名)
local 脚本相对路径=string.sub(脚本路径,#脚本目录+1)
local 脚本相对目录=string.sub(脚本相对路径,1,-#纯脚本名-1)
local 主题组=Config.get()
local 当前主题0=主题组.getTheme()
local 主题文件=输入法目录.."build/"..当前主题0..".yaml"
local yaml组 = yaml.load(io.readall(主题文件))
local 标题高度="0dp" --0dp为隐藏标题
local 版本号="5.0.6"
local 标题=纯脚本名:sub(1,-5) .. 版本号
local clipMaxNum = Function.getPref(this).getString("clipboard_size", "120")


if File(输入法目录 .. "script/功能键.lua").exists() then
  import "script.功能键"
end

if File(输入法目录 .. "script/自动状态栏.lua").exists() then
  import "script.自动状态栏"
end


--用于清空词条
local 文件=tostring(service.getLuaDir("")).."/clipboard.json"

local Clip=service.getClipBoard()

local func_fresh = nil
local func_ss = nil

-- 辅助函数------------开始------------

--长按连续按键
local ButLongclick=(function(key)
  local height=0
  return {onTouch=function(v,e)
      local a=e.getAction()
      if a==0 --按下
        service.sendEvent(key)
        height=v.getHeight()
      elseif a==1 --抬指
        ti.stop()
      elseif a==2 --滑动
        if tick[1]
          local y=e.getY()
          if e.getX()<1 or y<1 or y>height
            ti.stop()
          end
        end
      end
      end,onLongClick=function()
        ti=Ticker()
        ti.Period=80
        ti.onTick=function ()
          service.sendEvent(key)
        end
        ti.start()
      return true
  end}
end)

--转为整数
local function toint(n)
    local s = tostring(n)
    local i, j = s:find('%.')
    if i then
        return tonumber(s:sub(1, i-1))
    else
        return n
    end
end

--导入模块
function 导入模块(模块,内容)
   dofile_信息表=nil
   dofile_信息表={}
   dofile_信息表.上级脚本=脚本路径
   dofile_信息表.上级脚本所在目录=目录
   dofile_信息表.上级脚本相对路径=脚本相对路径
   dofile_信息表.纯脚本名= 纯脚本名:sub(1,-5)
   dofile_信息表.内容=内容
   dofile(目录..模块)--导入模块
end

function rippleDrawable(color)
  import"android.content.res.ColorStateList"
  return activity.Resources.getDrawable(activity.obtainStyledAttributes({android.R.attr.selectableItemBackground--[[Borderless]]}).getResourceId(0,0)).setColor(ColorStateList(int[0].class{int{}},int{color or 0x20000000}))
end

--线性渐变
function gradientDrawable(orientation,colors)
  import"android.graphics.drawable.GradientDrawable"
  return GradientDrawable(GradientDrawable.Orientation[orientation],colors)
end

--注册剪切板添加广播
import "android.content.BroadcastReceiver"
import "android.content.IntentFilter"
import "com.androlua.LuaBroadcastReceiver"
function 剪切板添加广播()
  br=LuaBroadcastReceiver(LuaBroadcastReceiver.OnReceiveListener{
    onReceive=function(context, intent)
      if intent.getAction()=="com.nirenr.talkman.ACTION_ADD_CLIPBOARD" then
        if intent.getStringExtra("com.nirenr.talkman.EXTRA_TEXT_DATA")~="" or intent.getStringExtra("com.nirenr.talkman.EXTRA_TEXT_DATA")~=nil then
          func_fresh()
        end --intent.getStringExtra
      end --intent.getAction
    end --function(conte
  })
  --动态注册广播接收者
  filter=IntentFilter()
  filter.addAction("com.nirenr.talkman.ACTION_ADD_CLIPBOARD")
  filter.setPriority(Integer.MAX_VALUE)
  --开启广播接收
  service.registerReceiver(br,filter)
  全_br = true
end
  
--清理剪切板
local function clipClean()
  -- print("clip clean...")
  local 清理正则组={
  "^http%S*$", --清理纯链接
  }
  local zs = 0
  --倒序循环
  for i=#Clip-1, 0, -1 do
    --过长删除
    if #Clip[i] > 1000 then
      zs = zs + 1
      Clip.remove(i)
    end
    
    --正则清理
    for j=1, #清理正则组 do
      if string.find(Clip[i], 清理正则组[j]) ~= nil then
        zs = zs + 1
        Clip.remove(i)
      end
    end
  end
  print("共清理" .. zs .. "条数据")
  func_fresh()
end


-- 辅助函数------------结束------------

-- 字体设置------------开始------------

local vibeFont=Typeface.DEFAULT
local 字体文件 = tostring(service.getLuaDir("")).."/fonts/Candidate.otf"
if File(字体文件).exists()==true then
  vibeFont=Typeface.createFromFile(字体文件)
end--if File(字体文件)

-- 字体设置------------结束------------

-- 自动背景颜色和背景图片------------开始------------

local 背景颜色 = nil
--图片路径
local bgpic_path=目录.."bg.jpg"
local 当前配色ID=Config.get().getColorScheme()
local 当前配色背景 = yaml组["preset_color_schemes"][当前配色ID]["keyboard_back_color"]
local 当前配色背景颜色 = toint(当前配色背景)
if 当前配色背景颜色 != nil then
  --背景颜色
  背景颜色 = "0x" .. BigInteger(tostring(当前配色背景颜色), 10).toString(16)
elseif 当前配色背景 != nil and File(bgpic_path).isFile()==false then
  --说明是背景图片
  bgpic_path = 输入法目录 .. "backgrounds/" .. 当前配色背景
end

-- 自动背景颜色和背景图片------------结束------------

-- 搜索功能------------开始------------

--优先级
-- 参数 >>  状态栏  >>  选中文本 >>  上次上屏 
-- 这里不考虑启动参数
local 预搜索内容=""
local isSearch = false
local function getSearchStr()
  if Rime.RimeGetInput()~="" then
    预搜索内容 = Rime.getComposingText()  --当前候选
  else
    预搜索内容 = service.getCurrentInputConnection().getSelectedText(0)--取编辑框选中内容,部分app内无效
  end
  if 预搜索内容 == "" or 预搜索内容 == nil then
    预搜索内容 = Rime.getCommitText() --己上屏文字
  end
end
--解除下面注释则启动立刻进行搜索
--getSearchStr()
if 预搜索内容 != "" and  预搜索内容 != nil then
  isSearch = true
end
-- 搜索功能------------结束------------



local num = 0 --当前选择的序号
local str = "" --当前选择的内容
local arrNo={} --内容序号数组，里面保存Clip的位置序号
local function getNumStr(p)
  num = arrNo[p+1]
  str = Clip[num]
end


--生成功能键背景
local function Back() 
  local bka=LuaDrawable(function(c,p,d)
  local b=d.bounds
  b=RectF(b.left,b.top,b.right,b.bottom)
  p.setColor(0x50000000)
  c.drawRoundRect(b,10,10,p) --圆角20
  end)
  local bkb=LuaDrawable(function(c,p,d)
  local b=d.bounds
  b=RectF(b.left,b.top,b.right,b.bottom)
  p.setColor(0x50000000)  --0x49d3d7da
  c.drawRoundRect(b,20,20,p)
  end)

local stb,state=StateListDrawable(),android.R.attr.state_pressed
  stb.addState({-state},bkb)
  stb.addState({state},bka)
  return stb
end

--获取k功能图标，没有则返回s
local function Icon(k,s) 
  k=Key.presetKeys[k]
  return k and k.label or s
end

--生成功能键
local function Bu_R(id) 
  local ta={TextView,
  gravity=17,
  Background=Back(),
  layout_height=-1,
  layout_width=-1,
  layout_weight=1,
  layout_margin="1dp", --
  layout_marginTop="2dp",
  layout_marginBottom="2dp",
  textColor=0xffFEFEFE,
  textSize="18dp"}

  if id==1 then
    ta.text=Icon("⌫","⌫")
    ta.textSize="18dp" --字体大小设置为22dp
    ta.OnTouchListener=ButLongclick("BackSpace")
    ta.OnLongClickListener=ButLongclick("BackSpace")
  elseif id==2 then
    ta.text="␣"
    ta.textSize="18dp"
    ta.OnTouchListener=ButLongclick("space")
    ta.OnLongClickListener=ButLongclick("space")
  elseif id==3 then
    ta.text=Icon("⏎","⏎")
    ta.textSize="18dp"
    ta.onClick=function()
      service.sendEvent("Return")
    end
    ta.OnLongClickListener={onLongClick=function() return true end}
  elseif id==4 then
    ta.text=Icon("Back","Back") --返回
    ta.textSize="15dp"
    ta.onClick=function()
      service.setKeyboard(".default")
      pcall(function()
      --pcall里防报错
        恢复状态栏()
      end)
    end
    ta.OnLongClickListener={onLongClick=function()
      service.setKeyboard(".default")
      pcall(function()
      --pcall里防报错
        恢复状态栏()
      end)
      return true
    end}
  elseif id==5 then
    ta.text=Icon("Tab","Tab")
    ta.textSize="15dp"
    ta.onClick=function()
      service.sendEvent("Tab")
    end
    ta.OnLongClickListener={onLongClick=function() return true end}
  elseif id==6 then
    ta.text="帮助"
    ta.onClick=function()
      导入模块("帮助模块.text",帮助内容)
    end
    ta.OnLongClickListener={onLongClick=function() return true end}
  elseif id==7 then
    ta.text=Icon("☑","☑")
    ta.textSize="15dp"
    ta.onClick=function()
      if 功能_全选 != nil then
        功能_全选()
      else
        print('【全选】功能需要"功能键.lua"的支持！请确保"script/包/键盘操作/功能键.lua]文件存在"')
      end
    end
  elseif id==8 then
    ta.text=Icon("❐","❐")
    ta.textSize="15dp"
    ta.onClick=function()
      if 功能_复制 != nil then
        功能_复制()
      else
        print('【复制】功能需要"功能键.lua"的支持！请确保"script/包/键盘操作/功能键.lua]文件存在"')
      end
      --必须要有延时
      -- task(80,function func_fresh() end)
    end
  elseif id==9 then
    ta.text=Icon("✂","✂")
    ta.textSize="15dp"
    ta.onClick=function()
      if 功能_剪切 != nil then
        功能_剪切()
      else
        print('【剪切】功能需要"功能键.lua"的支持！请确保"script/功能键.lua]文件存在"')
      end
      --必须要有延时
      -- task(80,function func_fresh() end)
    end
  elseif id==10 then
    ta.id = "ss" --ss: 搜索
    if isSearch then
      ta.text=Icon("全部","全部")
    else
      ta.text=Icon("🔍","🔍")
    end
    ta.textSize="15dp"
    ta.onClick=function()
      if isSearch then
        isSearch = false
        func_ss("搜索")
      else
        isSearch = true
        func_ss("全部")
      end
      getSearchStr()
      func_fresh()
    end
--  elseif id==11 then
--    ta.text=Icon("短语","短语")
--    ta.textSize="18dp"
--    ta.onClick=function()
--      if 功能_脚本 != nil then
--        功能_脚本(脚本相对目录.."自定义短语板.lua","剪切板")
--      else
--        print('【脚本】功能需要"功能键.lua"的支持！请确保"script/包/键盘操作/功能键.lua]文件存在"')
--      end
--    end
  elseif id==12 then
    ta.text=Icon("↺","↺")
    ta.textSize="18dp"
    ta.onClick=function()
      service.sendEvent("undo")
    end
    ta.OnLongClickListener={onLongClick=function()
      --长按行首
      service.sendEvent("Home")
      return true
    end}
  elseif id==13 then
    ta.text=Icon("↻","↻")
    ta.textSize="18dp"
    ta.onClick=function()
      service.sendEvent("redo")
    end
    ta.OnLongClickListener={onLongClick=function()
      --长按行尾
      service.sendEvent("End")
      return true
    end}
  elseif id==14 then
    ta.text="←"
    ta.textSize="15dp"
    ta.OnTouchListener=ButLongclick("Left")
    ta.OnLongClickListener=ButLongclick("Left")
  elseif id==15 then
    ta.text="↓"
    ta.textSize="15dp"
    ta.OnTouchListener=ButLongclick("Down")
    ta.OnLongClickListener=ButLongclick("Down")
  elseif id==16 then
    ta.text="↑"
    ta.textSize="15dp"
    ta.OnTouchListener=ButLongclick("Up")
    ta.OnLongClickListener=ButLongclick("Up")
  elseif id==17 then
    ta.text="→"
    ta.textSize="15dp"
    ta.OnTouchListener=ButLongclick("Right")
    ta.OnLongClickListener=ButLongclick("Right")
  elseif id==18 then
    ta.text="清理"
    ta.textSize="15dp"
    ta.onClick=function()
      clipClean()
    end
    ta.OnLongClickListener={onLongClick=function()
      return true
    end}
  end
  return ta
end

local 默认高度=service.getLastKeyboardHeight()
if 默认高度<300 then 默认高度=300 end
if lua高度 != nil and lua高度 != "" then
  默认高度 = lua高度
end


--主界面布局
local ids,layout={},{AbsoluteLayout,
    --键盘高度
    layout_height=默认高度,
    layout_width=-1,
    --背景颜色
    BackgroundColor=背景颜色,
    {TextView,
        id="title",
        layout_height=标题高度, --标题栏高度20
        layout_width=-1,
        text="•帮助说明",
        gravity="center",
        paddingLeft="2dp",
        paddingRight="2dp",
        singleLine="true",
        BackgroundColor=0x49d3d7da,
        },
    
                               
    {LinearLayout,
        orientation=0,--水平布局
        layout_height=-1,
        {LinearLayout,
            orientation=1,--垂直布局
            layout_weight=1,
            layout_height=-1,
        {GridView, --列表控件
            id="list",
            numColumns=2, --显示列数
            layout_width=-1,
            layout_weight=1},  
                        
            {LinearLayout,
            layout_marginTop=标题高度,
            orientation=0,--水平布局
            layout_width=-1,
            layout_height="42dp", --水平按键高度
            Bu_R(4),--返回
            Bu_R(7),--全选
            Bu_R(8),--复制
            Bu_R(9),--剪切
            --Bu_R(12),--撤消
            --Bu_R(13),--重做
            Bu_R(10),--搜索
            Bu_R(1),--删除
            --Bu_R(2),--空格           
            Bu_R(3),--回车            
            },  
                              
        },                                           
    }
}

layout=loadlayout(layout,ids)

--剪切板内容框
local data,item={},{LinearLayout,
  layout_width=-1,
  padding="2dp",
  gravity=3|17,

  {TextView,
  id="TV_b",
  gravity=3|17,
  paddingLeft="2dp",
  MaxLines=3,   --最大显示行数
  layout_margin="0dp",
  background=Back(),
--  BackgroundColor=0x50000000,
  width="240dp",
  Height="42dp", 
--  MinHeight="60dp",   --最小高度
  Typeface=vibeFont,
  textColor=0xFFe6e3d8,
  textSize="10dp"}}

local adp=LuaAdapter(service,data,item)
ids.list.Adapter=adp


local function fresh()
  -- print("fresh")
  table.clear(data)
  table.clear(arrNo)
  local 正则式 = ""
  if isSearch then
    for i=0,#Clip-1 do
      local m=utf8.find(Clip[i],预搜索内容)
      if m~=nil then
        table.insert(arrNo,i)
      end
    end
    ids.title.setText(标题.."(搜索到"..#arrNo.."条) \""..预搜索内容.."\" 相关内容")
    正则式 = "(\n*[^\n]*)([^\n]*"..预搜索内容.."[^\n]*)(\n*[^\n]*)"
  else
    for i=0,#Clip-1 do
      arrNo[i+1] = i
    end
    ids.title.setText(标题.."("..#arrNo.. "/" .. clipMaxNum ..")")
    正则式 = "(\n*[^\n]*)(\n*[^\n]*)(\n*[^\n]*)"
  end
  for i=1,#arrNo do
    local v=Clip[arrNo[i]]
    local a,b,c=v:match(正则式)
    a=table.concat{utf8.sub(a or "",1,99),utf8.sub(b or "",1,99),utf8.sub(c or "",1,99)}
    a=a:gsub(".",{
      ["<"]="&lt;",
      [">"]="&gt;",
    })
    a=string.gsub(a,"\n","<br>")
    if isSearch then
      a=string.gsub(a,预搜索内容,"<font color=#00ff00>" .. 预搜索内容 .. "</font>")
    end
    table.insert(data,{TV_a=Html.fromHtml("</big><font><b>"..tostring(arrNo[i] + 1)..". </b></font></big>"),TV_b=Html.fromHtml(a)})
  end
  if #arrNo == 0 then
    if isSearch then
      table.insert(data,{TV_a=Html.fromHtml("</big><font><b>"..tostring(1)..". </b></font></big>"),TV_b=Html.fromHtml("未搜索到【" .. "<font color=#00ff00>" .. 预搜索内容 .. "</font>" .. "】相关内容")})
    else
      table.insert(data,{TV_a=Html.fromHtml("</big><font><b>"..tostring(1)..". </b></font></big>"),TV_b=Html.fromHtml("剪切板中无内容！")})
    end
  end
  adp.notifyDataSetChanged()
  func_ss = ids.ss.setText --刷新以后id会重置
end

ids.list.onItemClick=function(l,v,p)
  getNumStr(p)
  service.commitText(str)
end

ids.list.onItemLongClick=function(l,v,p)
  getNumStr(p)
  pop=PopupMenu(service,v)
  menu=pop.Menu
  menu.add("🔝置顶词条").onMenuItemClick=function(ae)
    Clip.remove(num)
    Clip.add(0,str)
    service.getSystemService(Context.CLIPBOARD_SERVICE).setText(str)
    --fresh() 监听了剪切板事件，自动会刷新
  end
  menu.add("👀查看词条").onMenuItemClick=function(ae)
    local lay={TextView,
    padding="16dp",
    MaxLines=20,
    textIsSelectable=true,
    text=str,
    textColor=0xff232323,
    textSize="15dp"}
    LuaDialog(service)
    .setTitle(string.format("%s.  预览/操作（%s）",num+1,utf8.len(str)))
    .setView(loadlayout(lay))
    .setButton("置顶",function()
      if p>0 then
        Clip.remove(num)
        Clip.add(0,str)
        service.getSystemService(Context.CLIPBOARD_SERVICE).setText(str)
        --fresh() 监听了剪切板事件，自动会刷新
      end
    end)
    .setButton2("删除",function()
      Clip.remove(num)
      fresh()
      JsonUtil.save(File(文件), Clip) --刷新剪切板json文件
    end)
    .setButton3("取消",function()
      dialog.dismiss()
    end)
    .show()
  end
  menu.add("🗑️删除词条").onMenuItemClick=function(ae)
    Clip.remove(num)
    fresh()
    JsonUtil.save(File(文件), Clip) --刷新剪切板json文件
  end
--  menu.add("🈹分割词条").onMenuItemClick=function(ae)
--    导入模块("分词工具.text",str)
--  end
  menu.add("🚮清空词条").onMenuItemClick=function(ae)
    pcall(function()
    --pcall里防报错
      恢复状态栏()
    end)
    io.open(文件,"w"):write("[\n]"):close()
    local 输入法实例=Trime.getService()
    输入法实例.loadClipboard()
    print("数据已清除")
    service.setKeyboard(".default")
  end
--  menu.add("📤上传云端").onMenuItemClick=function(ae)
--    导入模块("推送剪切板到云端.text",str)
--  end
  menu.add("📝添加短语").onMenuItemClick=function(ae)
    print(str.."添加成功")
    local Phrase=service.getPhrase()
    Phrase.add(0,str)
    local Phrase_nr="[\n"
    for i=0,#Phrase-1 do
      Phrase0=Phrase[i]:gsub("\\","\\\\")
      Phrase0=Phrase0:gsub("/","\\/")
      Phrase0=Phrase0:gsub("\"","\\\"")
      Phrase0=Phrase0:gsub("\n","\\n")
      Phrase0=Phrase0:gsub("\t","\\t")
      Phrase_nr=Phrase_nr.."    \""..Phrase0.."\",\n"
    end
    Phrase_nr=Phrase_nr:sub(1,-3).."\n]"
    io.open(输入法目录.."phrase.json","w"):write(Phrase_nr):close()
  end
  menu.add("📋一键加词").onMenuItemClick=function(ae)
    Clip.remove(num)
    Clip.add(0,str)
    fresh()  
--    导入模块("一键加词自动编码(定长).text",str)
    导入模块("一键加词.lua",str)
  end
  menu.add("🗣语音播报").onMenuItemClick=function(ae)
    service.speak(str)--文本转声音
  end
  pop.show()
  return true
end




fresh()
func_fresh = fresh
if 全_br == nil then
  剪切板添加广播()
end
service.setKeyboard(layout)

pcall(function()
  --pcall里防报错
  隐藏状态栏(layout)
end)

-- 默认视频和默认背景图------------开始------------

--视频路径
local bgmv_path=目录.."bg.mp4"
--视频文件不存在则终止脚本
if File(bgmv_path).isFile()==true then
  pcall(function()
    local play=MediaPlayer()
    play.setDataSource(bgmv_path)
    --循环播放
    play.setLooping(true)
    play.prepare()
    --音量设为0
    play.setVolume(0,0)
  
    local video=loadlayout{SurfaceView,
      --添加背景色，避免看不清按键
      --BackgroundColor=0x55ffffff,
      --线性渐变，"TL_BR"为topleft bottomright
      backgroundDrawable=gradientDrawable("TL_BR",{0x99FBE0B5,0x99E5EED9,0x99F3F5F8}),--背景色
      layout_width=-1,
      layout_height=-1
      }
    layout.addView(video,0) --把视频布局放到layout的第一个，也就是显示在最底层
    
    video.getHolder().addCallback({
      surfaceCreated=function(holder)
        play.start()
        play.setDisplay(holder)
      end,
      surfaceDestroyed=function()
        --界面关闭，释放播放器
        play.release()
    end})
  end)
elseif File(bgpic_path).isFile()==true then
  local pic=loadlayout{ImageView,
    --添加背景色，避免看不清按键
    --BackgroundColor=0x55ffffff,
    --线性渐变，"TL_BR"为topleft bottomright
    backgroundDrawable=gradientDrawable("TL_BR",{0x99FBE0B5,0x99E5EED9,0x99F3F5F8}),--背景色
    src=bgpic_path,
    --adjustViewBounds="true",--保持长宽比
    scaleType="fitXY",--横向纵向缩放
    layout_width=-1,
    layout_height=-1}
  layout.addView(pic,0) --把视频布局放到layout的第一个，也就是显示在最底层
end


-- 默认视频和默认背景图------------结束------------


