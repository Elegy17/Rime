--[[中文输入法 （同文无障碍版）

【颜色列表1.3】

调用方式1：
解压文件夹到rime/script (没有新建)
找到你的方案里的preset_keys所在的地方加入一行
(可能在补丁xxx.custom.yaml, 主题xxx.trime.yaml,方案xxx.schema.yaml, trime.yaml文件里)
colorlists: {label: 颜色表, send: function, command: 'colorlists.lua'}

然后找到你需要加入的按键调用long_click: colorlists
例:- {click: d, long_click: '#', key_back_color: bh2, key_text_color: th2}
- {click: d, long_click: colorlists, key_back_color: bh2, key_text_color: th2}

调用方式2：
使用群里的脚本启动器调用

2022.02.28
2022.05.27
额外说明该脚本主要的功能代码都是基于各位大佬的原始项目,非常感谢大佬们的案例代码,本人只做了一些缝合操作,由于本人代码水平非常烂有需要的凑合使用吧(能跑就行😂
]]
require "import"
import "android.widget.*"
import "android.graphics.*"
import "android.view.*"
import "android.media.MediaPlayer"
import "android.graphics.RectF"
import "android.graphics.drawable.StateListDrawable"
import "android.content.Intent"
import "android.content.*"
import "android.app.SearchManager"
import "android.net.Uri"
import "android.app.*"
import "android.os.*"
import "script/dex/flowlayout:com.nex3z.flowlayout.FlowLayout"

--import "android.view.animation.TranslateAnimation"

import "android.content.pm.PackageManager"
import "script/dex/color:com.a4455jkjh.colorpicker.view.ColorPickerView"

--屏蔽某个页面只要在下面一行删掉一个""里的内容和一个逗号即可
local colorList = { "配色", "品牌色", "代码", "色板",  "传统色", "ARGB", "拾色器", "潘通色"}



local 脚本目录=tostring(service.getLuaExtDir("script")).."/"
local 脚本路径=debug.getinfo(1,"S").source:sub(2)
local 脚本相对路径=string.sub(脚本路径,#脚本目录+1)
local 纯脚本名=File(脚本路径).getName()
local 目录=string.sub(脚本路径,1,#脚本路径-#纯脚本名)
--字符串分割
local function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end
local function readRecentListFile()
    --初次读取并分割最近使用的颜色
    local sourcefile = io.open(目录.. 'rucs.txt','r')
    local c = sourcefile:read("*all")
    c = string.lower(c)
    sourcefile:close()
    rucs = Split(c,"\n")
    --推荐至少保留8个 太少颜色值又短的情况下布局填不满
    if(#rucs > 8) then
        for i = #rucs,8,-1 do
            table.remove(rucs,i)
        end
    end
end
readRecentListFile()
local function Back() --生成功能键背景
    local bka=LuaDrawable(function(c,p,d)
        local b=d.bounds
        b=RectF(b.left,b.top,b.right,b.bottom)
        p.setColor(0xffffffff)
        c.drawRoundRect(b,0,0,p) --圆角20
    end)
    local bkb=LuaDrawable(function(c,p,d)
        local b=d.bounds
        b=RectF(b.left,b.top,b.right,b.bottom)
        p.setColor(0xffffffff)
        c.drawRoundRect(b,0,0,p)
    end)

    local stb,state=StateListDrawable(),android.R.attr.state_pressed
    stb.addState({-state},bkb)
    stb.addState({state},bka)
    return stb
end

local function Icon(k,s) --获取k功能图标，没有则返回s
    k=Key.presetKeys[k]
    return k and k.label or s
end

local function setSelectHeight(view,n)
    NumberPicker
    .getDeclaredField('mSelectionDividersDistance')
    .setAccessible(true)
    .set(view,n)
end
function 功能_脚本(路径,参数)
    Key.presetKeys.lua_Keyboard={label= "脚本", send="function", command=路径, option=参数}
    service.sendEvent("lua_Keyboard")
end
local function Bu_R(Bu,id) --生成功能键
    --local msg=Bu[2][2] --上标签
    --local label=Bu[2][3] --主标签

end

--按行保存最近使用的颜色
local function saveRecentColor()
    if #rucs ~= nil then
        local tx = ""
        for i = 1,#rucs do
            if i < #rucs then
                tx = tx .. rucs[i] .. '\n'
            else
                tx = tx .. rucs[i]
            end
        end
        io.open("/storage/emulated/0/Android/rime/script/rucs.txt","w"):write(tx):close()
    end
end

local height="240dp" --键盘高度
--主布局
local ids,layout={},
{
    LinearLayout,
    layout_height=height,
    orientation="vertical";
    layout_width=-1,
    --背景颜色
    BackgroundColor=0xfff0f0f8,
    {
        LinearLayout,
        orientation="horizontal",
        paddingTop="3dp",
        {
            TextView,
            id="title",
            layout_height=-1,
            layout_width="58dp",
            layout_height="32dp",
            text="最近",
            --最近按钮 同时提供点击返回功能节省空间
            onClick=function (){
                local 主键盘01=Config.get().getKeyboardNames()[0]--读取注册键盘组
                Key.presetKeys.lua_script_Keyboard={label= "返回", functional="false", send ="Eisu_toggle", select=主键盘01 }
                service.sendEvent("lua_script_Keyboard")
                return --退出
            },
            gravity=17,
            paddingRight="3dp",
            BackgroundColor=0xffffffff,
            textColor=0xff164a7e,
            textSize="18dp"
        },
        {
            --Gridview,
            --numColumns="5",
            HorizontalListView,
            horizontalScrollBarEnabled=false;
            id="listrecent",
            paddingLeft="3dp",
            layout_width=-1,
            layout_height="35dp",
        };
    },
    {
        LinearLayout,
        layout_height=-1,
        orientation="horizontal",
        layout_gravity="left",
        orientation="vertical";
        {
            --单选栏布局 末尾注释可以隐藏
            RadioGroup,
            id="rp",
            layout_width=-1,
            orientation="horizontal",
            {
                RadioButton,
                id="m1",
                textColor=0xff164a7e,
                paddingRight="0dp",
                layout_width="wrap_content",
                layout_weight=1,
                Text="0x",
                textSize="12dp"
            },
            {
                RadioButton,
                id="m2",
                textColor=0xff164a7e,
                paddingRight="0dp",
                Text="0xff",
                layout_width="wrap_content",
                layout_weight=1,
                textSize="12dp"
            },
            {
                RadioButton,
                id="m3",
                textColor=0xff164a7e,
                paddingRight="0dp",
                Text="#",
                layout_width="wrap_content",
                layout_weight=1,
                textSize="12dp"
            },
            {
                RadioButton,
                id="m4",
                textColor=0xff164a7e,
                paddingRight="0dp",
                Text="#ff",
                layout_width="wrap_content",
                layout_weight=1,
                textSize="12dp"
            },
            {
                RadioButton,
                id="m5",
                textColor=0xff164a7e,
                paddingRight="0dp",
                Text="ff",
                layout_width="wrap_content",
                layout_weight=1,
                textSize="12dp"
            },
            {
                RadioButton,
                id="m6",
                textColor=0xff164a7e,
                paddingRight="0dp",
                Text="无",
                checked=true,
                layout_width="wrap_content",
                layout_weight=1,
                textSize="12dp"
            },
            {
                RadioButton,
                id="m7",
                textColor=0xff164a7e,
                layout_marginRight="6dp",
                paddingRight="0dp",
                Text="()",
                layout_width="wrap_content",
                layout_weight=0,
                textSize="12dp"
            },
            {
                RadioButton,
                id="m8",
                textColor=0xff164a7e,
                layout_marginRight="6dp",
                paddingRight="0dp",
                Text="(a)",
                layout_width="wrap_content",
                layout_weight=0,
                textSize="12dp"
            },
        },
        {
            --多页布局 通过适配器动态插页 方便用户对页面增删
            LinearLayout,
            layout_height=-1,
            id="xxx",
            layout_gravity="left",
            {
                --左侧按钮的布局
                layout_width="60dp",
                layout_height=-1,
                layout_gravity="left",
                GridView,
                id="lb",
                numColumns="1";
            },
        }
    },
}
--使用分页布局 使用适配器动态插入不同的页面内容
local page = 
{
    PageView;
    layout_width="-1";
    id="hd";
    layout_height="-1";
    pages=
    {
    }
}
layout=loadlayout(layout)

--设置选中的上屏模式
rp.setOnCheckedChangeListener
{
    onCheckedChanged=function(g,c)
        mode=g.findViewById(c).Text
    end
}
local function f1()
    m2.setText("0xff")
    m4.setText("#ff")
    m5.setText("ff")
end
local function f2()
    m2.setText("-ff+0x")
    m4.setText("-ff+#")
    m5.setText("-ff")
end
--通过更改单选按钮的文本使不同页面列出不同的上屏模式
--页面颜色值统一成ffffff,ffffffff两种6,8位数据方便统一操作
--6位的有加#,0x,#ff,0xff,ff和原样 html数字rgb() 数字rgba(a)
--8位的有加#,0x,去ff加#,去ff加0x,减ff和原样 html数字rgb() 数字rgba(a)
local function setRadio(i)
    switch(colorList[i])
    case "配色"
    f1()
    case "色板"
    f1()
    case "传统色"
    f1()
    case "潘通色"
    f1()
    case "品牌色"
    f1()
    case "代码"
    f2()
    case "ARGB"
    f2()
    case "拾色器"
    f2()
end
end
--侧边按钮动态添加函数
local function insertBu()
    local Bu=
    {
        LinearLayout,
        --侧边按钮大小
        layout_height="35dp",
        layout_width=-1,
        paddingTop="3dp",
        paddingRight="3dp",
        {
            FrameLayout,
            layout_height=-1,
            layout_width=-1,
            Background=Back(),
            {
                TextView,
                gravity=17,
                layout_height=-1,
                layout_width=-1,
                textColor=0xff164a7e,
                id="bt",
                textSize="18dp"
            }
        }
    }
    local data={}
    local adp=LuaAdapter(service,data,Bu)
    --按照脚本开始的colorList循环添加分页的按钮
    lb.setAdapter(adp)
    for i = 1,8 do
        table.insert(data,{bt={Text=colorList[i],}})
    end
    --设置每个按钮打开的页面
    lb.onItemClick=function(l,v,p,i)
        --每次按钮切换页面先设置单选栏的内容
        setRadio(i)
        --local t = "#ff" .. (data[i].b.Text) .. ','
        --local t = "ff" .. (data[i].b.Text)
        switch (i)
        case 1
        hd.showPage(0)
        case 2
        hd.showPage(1)
        case 3
        hd.showPage(2)
        case 4
        hd.showPage(3)
        case 5
        hd.showPage(4)
        case 6
        hd.showPage(5)
        case 7
        hd.showPage(6)
        case 8
        hd.showPage(7)
        case 9
        hd.showPage(8)
    end
    return true
end
end
insertBu()

local item0=
{
    LinearLayout,
    layout_width=-1,
    BackgroundColor=0x00ffffff,
    paddingRight="2dp",
    {
        TextView,
        id="b",
        gravity=17,
        layout_height="32sp",
        BackgroundColor=0xff000000,
        paddingRight="2dp",
        paddingLeft="2dp",
        textColor=0xff164a7e,
        layout_width="wrap_content",
        textSize="15dp"
    }

}
local item=
{
    LinearLayout,
    layout_width=-1,
    BackgroundColor=0x00ffffff,
    paddingRight="2dp",
    {
        TextView,
        id="b",
        gravity=17,
        layout_height="32sp",
        BackgroundColor=0xff000000,
        paddingRight="2dp",
        paddingLeft="2dp",
        textColor=0xff164a7e,
        layout_width=-1,
        textSize="15dp"
    }

}
local item1=
{
    LinearLayout,
    layout_width=-1,
    BackgroundColor=0xffffffff,
    paddingRight="2dp",
    paddingBottom="2dp",
    {
        TextView,
        id="c",
        gravity=17,
        layout_height="42dp",
        BackgroundColor=0xff000000,
        textColor=0xff164a7e,
        layout_width=-1,
        textSize="15dp"
    }

}

local item2=
{
    LinearLayout,
    layout_width=-1,
    BackgroundColor=0x00ffffff,
    paddingRight="2dp",
    paddingBottom="2dp",
    {
        TextView,
        id="b",
        gravity=17,
        layout_height="32sp",
        BackgroundColor=0xff000000,
        textColor=0xff164a7e,
        --layout_width="40dp",
        layout_width=-1,
        textSize="15dp"
    }

}
local item7=
{
    LinearLayout,
    layout_width=-1,
    BackgroundColor=0xffffffff,
    --paddingRight="2dp",
    paddingBottom="2dp",
    paddingRight= "3dp",
    orientation="vertical";
    {
        TextView,
        id="t1",
        --gravity="bottom",
        layout_height="52dp",
        --layout_width="22%w",
        paddingLeft="6dp",
        layout_width=-1,
        BackgroundColor=0xffffffff,
        textColor=0xffffffff,
        textSize="20dp"
    },
    {
        TextView,
        id="t2",
        gravity="left",
        paddingLeft="6dp",
        BackgroundColor=0xffffffff,
        textColor=0xff164a7e,
        layout_width=-1,
        textSize="10dp"
    },
    {
        TextView,
        id="t3",
        gravity="left",
        paddingLeft="6dp",
        BackgroundColor=0xffffffff,
        textColor=0xff164a7e,
        layout_width=-1,
        textSize="10dp"
    },
    {
        TextView,
        id="t4",
        gravity="left",
        paddingLeft="6dp",
        paddingBottom="6dp",
        BackgroundColor=0xffffffff,
        textColor=0xff164a7e,
        layout_width=-1,
        textSize="10dp"
    },--[[
    {
    TextView,
    id="t5",
    gravity="left",
    paddingLeft="2dp",
    BackgroundColor=0xffffffff,
    textColor=0xff164a7e,
    layout_width=-1,
    textSize="10dp"
    },--]]

}

local item8=
{
    LinearLayout,
    layout_width=-1,
    BackgroundColor=0x00ffffff,
    paddingRight="2dp",
    paddingBottom="2dp",
    {
        TextView,
        id="b8",
        gravity=17,
        layout_width="50%w",
        Text="xxx",
        layout_height="32sp",
        BackgroundColor=0x00000000,
        textColor=0xff164a7e,
        textSize="15dp"
    }

}

--textview着色
local function TextFrame(view,Thickness,FrameColor,InsideColor)
    import "android.graphics.drawable.GradientDrawable"
    drawable =  GradientDrawable()  
    drawable.setShape(GradientDrawable.RECTANGLE) 
    drawable.setStroke(Thickness, FrameColor)
    drawable.setColor(InsideColor)
    view.setBackgroundDrawable(drawable)
end
--读颜色文件
local function readColor(flag)
    switch (flag)
    case 1
    local sourcefile = io.open(目录.. 'te1.txt','r')
    local c = sourcefile:read("*all")
    sourcefile:close()
    return Split(c,",")
    case 2
    return Split("#ffff0000,#ffffff00,#ff00ff00,#ff00ffff,#ff0000ff,#ffff00ff,#ffe60012,#fffff100,#ff009944,#ff00a0e9,#ff1d2088,#ffe4007f,#ffffffff,#ffeeeeee,#ffe5e5e5,#ffdcdcdc,#ffd2d2d2,#ffc9c9c9,#ffbfbfbf,#ffb5b5b5,#ffaaaaaa,#ffa0a0a0,#ff959595,#ff898989,#ff7d7d7d,#ff707070,#ff626262,#ff535353,#ff434343,#ff313131,#ff1b1b1b,#ff000000,,,,,#fff29b76,#ffec6941,#ffe60012,#ffa40000,#ff7d0000,#ffd1c0a5,#fff6b37f,#fff19149,#ffeb6100,#ffa84200,#ff7f2d00,#ffa6937c,#fffacd89,#fff8b551,#fff39800,#ffac6a00,#ff834e00,#ff7e6b5a,#fffff899,#fffff45c,#fffff100,#ffb7aa00,#ff8a8000,#ff59493f,#ffcce198,#ffb3d465,#ff8fc31f,#ff638c0b,#ff486a00,#ff362e2b,#ffacd598,#ff80c269,#ff22ac38,#ff097c25,#ff005e15,#ffcfa972,#ff89c997,#ff32b16c,#ff009944,#ff007130,#ff00561f,#ffb28850,#ff84ccc9,#ff13b5b1,#ff009e96,#ff00736d,#ff005752,#ff996c33,#ff7ecef4,#ff00b7ee,#ff00a0e9,#ff0075a9,#ff005982,#ff81511c,#ff88abda,#ff448aca,#ff0068b7,#ff004986,#ff003567,#ff6a3906,#ff8c97cb,#ff556fb5,#ff00479d,#ff002e73,#ff001c58,,#ff8f82bc,#ff5f52a0,#ff1d2088,#ff100964,#ff03004c,,#ffaa89bd,#ff8957a1,#ff601986,#ff440062,#ff31004a,,#ffc490bf,#ffae5da1,#ff920783,#ff6a005f,#ff500047,,#fff19ec2,#ffea68a2,#ffe4007f,#ffa4005b,#ff7e0043,,#fff29c9f,#ffeb6877,#ffe5004f,#ffa40035,#ff7d0022,,",",")
    case 3
    local sourcefile = io.open(目录.. 'z.txt','r')
    local c = sourcefile:read("*all")
    sourcefile:close()
    return Split(c,",")
    case 4
    local sourcefile = io.open(目录.. 'brandcolors.txt','r')
    local c = sourcefile:read("*all")
    sourcefile:close()
    return Split(c,",")
end

end

local function GetRandomNumList(len)
    local rsList = {}
    for i = 1,len do
        table.insert(rsList,i)
    end
    local num,tmp
    for i = 1,len do
        num = math.random(1,len)
        tmp = rsList[i]
        rsList[i] = rsList[num]
        rsList[num] = tmp
    end
    return rsList
end
local function num2hexstr(value)
    return string.format('%02X', (value))
end
--rgb(255,255,255)转#ffffff
local function color2hex(color)
    local hex = '#'
    if(color:match("%(%d+,%d+,%d+,%d+%.*%d*%)") ~= nil) then 
        local tr,tg,tb,ta = color:match("%((%d+),(%d+),(%d+),(%d+%.*%d*)%)")
        if tonumber(ta) <= 1 then
            hex = hex .. num2hexstr(math.floor(ta*255)) .. num2hexstr(tr) .. num2hexstr(tg) .. num2hexstr(tb)
        else
            hex = hex .. num2hexstr(ta) .. num2hexstr(tr) .. num2hexstr(tg) .. num2hexstr(tb)
        end
    else
        local tr,tg,tb = color:match("%((%d+),(%d+),(%d+)%)")
        hex = hex .. num2hexstr(tr) .. num2hexstr(tg) .. num2hexstr(tb)

    end
    return hex
end
--分页读取品牌色文件,数据过多,一次载入流式布局会卡几秒
--可自行精简brandcolors.txt或者优化算法(自动翻页代码感觉体验不是很好)
local function readColor2(nPage)
    local ix = 1
    local tempData = {}
    for c in io.lines("/storage/emulated/0/Android/rime/script/brandcolors.txt")
        if ix >= nPage*100 and ix < (nPage+1)*100 then
            table.insert(tempData,c)
        end
        ix = ix+1
    end
    return tempData
end

local function dp2px(dpValue)
    return math.floor(service.getResources().getDisplayMetrics().density*dpValue)
end
local function argb2rgb(hex)
end
--#ffffff 转 rgb(255,255,255)
local function hex2rgb(hex)
    if(string.sub(hex, 1, 3) == "0x") then
        hex = string.gsub(hex,"0x","#")
    end
    local len = string.len(hex)
    if(len == 6 or len == 8) then
        hex = '#' .. hex
    end
    len = string.len(hex)
    local color 
    if(len == 7) then
        color = {
            r = tonumber(tonumber(string.sub(hex, 2, 3),16)),
            g = tonumber(tonumber(string.sub(hex, 4, 5),16)),
            b = tonumber(tonumber(string.sub(hex, 6, 7),16)),
        }
    else 
        --argb近似强制转换rgb,不需要的删掉下面部分把注释部分打开即可
        if (len == 9) then
            local a0 = string.format("%.1f",(tonumber(string.sub(hex, 2, 3),16)/255))
            local r0 = tonumber(tonumber(string.sub(hex, 4, 5),16))
            local g0 = tonumber(tonumber(string.sub(hex, 6, 7),16))
            local b0 = tonumber(tonumber(string.sub(hex, 8, 9),16))
            color = {
                r = tointeger(((1 - a0) * 255) + (a0 * r0)), 
                g = tointeger(((1 - a0) * 255) + (a0 * g0)),
                b = tointeger(((1 - a0) * 255) + (a0 * b0)),
                --r = tonumber(tonumber(string.sub(hex, 4, 5),16)) * a,
                --g = tonumber(tonumber(string.sub(hex, 6, 7),16)) * a,
                --b = tonumber(tonumber(string.sub(hex, 8, 9),16)) * a,
            }
        end
    end
    return '(' .. color.r .. ',' .. color.g ..',' .. color.b .. ')'
end
--#ffffffff 转 rgb(255,255,255,1)
local function hex2rgba(hex)
    if(string.sub(hex, 1, 3) == "0x") then
        hex = string.gsub(hex,"0x","#")
    end
    local len = string.len(hex)
    if(len == 6 or len == 8) then
        hex = '#' .. hex
    end
    len = string.len(hex)
    local color 
    if(len == 7) then
        color = {
            r = tonumber(tonumber(string.sub(hex, 2, 3),16)),
            g = tonumber(tonumber(string.sub(hex, 4, 5),16)),
            b = tonumber(tonumber(string.sub(hex, 6, 7),16)),
            a = 1
        }
    else 
        --#aarrggbb转(r,g,b,a)) 以html标准 alpha通道只有0-1 十六进制是0-255 无法一一对应 这里只提供近似转换,或者直接返回1 或不返回a值 请自行选择
        if (len == 9) then
            color = {
                r = tonumber(tonumber(string.sub(hex, 4, 5),16)),
                g = tonumber(tonumber(string.sub(hex, 6, 7),16)),
                b = tonumber(tonumber(string.sub(hex, 8, 9),16)),
                a = string.format("%.1f",(tonumber(string.sub(hex, 2, 3),16)/255)),
            }
        end
    end

    return '(' .. color.r .. ',' .. color.g ..',' .. color.b .. ',' .. color.a .. ')'
end

--将不同格式的颜色值转换成布局用的格式
local function decodeColor(t)
    if(t:match("#([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])$") ~= nil or t:match("#([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])$") ~= nil) then
        return t
    else
        if(t:match("0x([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])$") ~= nil or t:match("0x([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])$") ~= nil) then
            local shit = string.gsub(t,"0x","#")
            return shit
        else
            if(t:match("[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$") ~= nil or t:match("[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$") ~= nil) then
                return "#" .. t
            else
                if(t:match("%(%d+,%d+,%d+,%d+%.*%d*%)") ~= nil) or (t:match("%(%d+,%d+,%d+%)") ~= nil) then
                    t = color2hex(t)
                    return t
                end
            end

        end

    end 
end


--最近颜色列表处理
local function recentList()
    local data={}
    local adp=LuaAdapter(service,data,item0)
    listrecent.setAdapter(adp)
    table.clear(data)
    adp.clear()
    for i = 1,#rucs do
        table.insert(data,{
            b={
                Text = (rucs[i]),--:match("#(%S+)"),
                BackgroundColor=Color.parseColor(decodeColor(rucs[i])),
            }, 
        })
    end
    listrecent.onItemClick=function(l,v,p,i)
        --local t = "#ff" .. (data[i].b.Text) .. ','
        local t = data[i].b.Text
        service.commitText(t)
        if i > 1 then
            local x = rucs[i]
            table.remove(rucs,i)
            table.insert(rucs,1,t)
            recentList()
            saveRecentColor()
        end
        return true
    end
end
--将颜色按单选的选择处理后上屏并返回最终格式,使插入到最近使用颜色栏的颜色格式可以是多种,最近使用栏点击上屏效果也是上次使用的格式不再受到单选栏的影响
local function commitColor(t)
    print(t)
    t = string.lower(t)
    switch(mode)
    case "0x"
    t = "0x" .. t
    case "-ff+0x"
    if(#t) == 8 then
        t = "0x" .. string.sub(t,3,-1)
    end
    case "#"
    t = "#" .. t
    case "-ff+#"
    if(#t) == 8 then
        t = "#" .. string.sub(t,3,-1)
    end
    case "-ff"
    if(#t) == 8 then
        t = string.sub(t,3,-1)
    end
    case "0xff"
    if(#t) == 6 then
        t = "0xff" .. t
    end
    case "#ff"
    if(#t) == 6 then
        t = "#ff" .. t
    end
    case "ff"
    if(#t) == 6 then
        t = "ff" .. t
    end
    case "无"
    t = t
    case "()"
    t = hex2rgb(t)
    case "(a)"
    t = hex2rgba(t)
end
--上屏的同时返回转换后的文字 以供按钮显示
service.commitText(t)
return t
end
local function page5Setting()
    local 颜色=""
    local r=255
    local g=255
    local b=255
    local a=255
    function hex2argb(hex)
        hex = hex:gsub("#","")
        if(#hex) ==8 then
            return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8))
        else
            return 255, tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
        end

    end
    --读取剪切板第一条 匹配到颜色就设置本页显示
    local Clip=service.getClipBoard()
    local rK = {"^0x%S+$","^#%S+$"}
    if Clip[0]:find(rK[2]) ~= nil then
        alpha.Progress,red.Progress,green.Progress,blue.Progress=hex2argb(Clip[0])
        status.Text=Clip[0] .." 点击上屏"
        status.BackgroundColor=Color.parseColor(Clip[0])
        r=red.Progress
        g=green.Progress
        b=blue.Progress
        a=alpha.Progress
    else
        if Clip[0]:find(rK[1]) ~= nil then
            local t =(Clip[0]):gsub("0x",'#')
            alpha.Progress,red.Progress,green.Progress,blue.Progress=hex2argb(t)
            status.Text=t .." 点击上屏"
            status.BackgroundColor=Color.parseColor(t)
            r=red.Progress
            g=green.Progress
            b=blue.Progress
            a=alpha.Progress
        else 
            red.Progress=255
            green.Progress=255
            blue.Progress=255
            alpha.Progress=255
        end
    end
    red.ProgressDrawable.setColorFilter(PorterDuffColorFilter(0xFFFB7299,PorterDuff.Mode.SRC_ATOP))
    red.Thumb.setColorFilter(PorterDuffColorFilter(0xFFFB7299,PorterDuff.Mode.SRC_ATOP))
    green.ProgressDrawable.setColorFilter(PorterDuffColorFilter(0xff46c16d,PorterDuff.Mode.SRC_ATOP))
    green.Thumb.setColorFilter(PorterDuffColorFilter(0xff46c16d,PorterDuff.Mode.SRC_ATOP))
    blue.ProgressDrawable.setColorFilter(PorterDuffColorFilter(0xff21b0ff,PorterDuff.Mode.SRC_ATOP))
    blue.Thumb.setColorFilter(PorterDuffColorFilter(0xff21b0ff,PorterDuff.Mode.SRC_ATOP))
    alpha.ProgressDrawable.setColorFilter(PorterDuffColorFilter(0xFF888888,PorterDuff.Mode.SRC_ATOP))
    alpha.Thumb.setColorFilter(PorterDuffColorFilter(0xFF888888,PorterDuff.Mode.SRC_ATOP))

    red.setOnSeekBarChangeListener
    {
        onProgressChanged=function(v,i)
            r=i
            颜色='('.. r .. ',' .. g .. ',' .. b .. ',' .. a .. ')'--string.format("%02x%02x%02x%02x",a,r,g,b)
            status.Text=颜色
            status.BackgroundColor=Color.parseColor(color2hex(颜色))
        end
    }
    green.setOnSeekBarChangeListener
    {
        onProgressChanged=function(v,i)
            g=i
            颜色='('.. r .. ',' .. g .. ',' .. b .. ',' .. a .. ')'--string.format("%02x%02x%02x%02x",a,r,g,b)
            --颜色=string.format("%02x%02x%02x%02x",a,r,g,b)
            status.Text=颜色
            status.BackgroundColor=Color.parseColor(color2hex(颜色))
        end
    }
    blue.setOnSeekBarChangeListener
    {
        onProgressChanged=function(v,i)
            b=i
            --颜色=string.format("%02x%02x%02x%02x",a,r,g,b)
            颜色='('.. r .. ',' .. g .. ',' .. b .. ',' .. a .. ')'--string.format("%02x%02x%02x%02x",a,r,g,b)
            status.Text=颜色
            status.BackgroundColor=Color.parseColor(color2hex(颜色))
        end
    }
    alpha.setOnSeekBarChangeListener
    {
        onProgressChanged=function(v,i)
            a=i
            --颜色=string.format("%02x%02x%02x%02x",a,r,g,b)
            颜色='('.. r .. ',' .. g .. ',' .. b .. ',' .. a .. ')'--string.format("%02x%02x%02x%02x",a,r,g,b)
            status.Text=颜色
            status.BackgroundColor=Color.parseColor(color2hex(颜色))
        end
    }


    bt2.onClick=function()
        if 颜色~="" then
            --page5Setting()
            red.Progress=255
            green.Progress=255
            blue.Progress=255
            alpha.Progress=255
            --service.commitText("0x"..颜色)
        end
    end

    status.onClick=function()
        if 颜色~="" then
            --service.commitText(颜色)
            颜色 = 颜色:match("%(%d+,%d+,%d+,%d+%)")
            颜色 = string.sub(color2hex(颜色),2,-1)
            local tc = commitColor(颜色)
            if(#rucs > 8) then
                table.remove(rucs,8)
            end
            table.insert(rucs,1,tc)
            --table.insert(rucs,1,'#'..string.lower(颜色))
            recentList()
            saveRecentColor()
        end
    end
end


local function alpback()
    local bai=Paint()
    bai.setColor(0xffffffff)
    bai.setStrokeWidth(1)

    local hui=Paint()
    hui.setColor(0xFFACACAC)
    hui.setStrokeWidth(1)

    local abg = LuaDrawable(function(c,p,d)
        if (c ~= nil) then
            local w = d.getBounds().width()/10
            local h = d.getBounds().height()/10
            heng = {0,w+w,w+w,w+w,w+w}
            shu = {0,h+h,h+h,h+h,h+h}

            c.translate(0,0)
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end
            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(w,-(h*9))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,hui)
            end

            c.translate(0,-(h*7))
            for i2 = 1,#shu do
                c.translate(0,shu[i2])
                c.drawRect(0,0,w,h,bai)
            end
        end

    end)
    return abg
end

local function page6Setting()
    local 初始颜色 = 0xffffffff
    local Clip=service.getClipBoard()
    local rK = {"^0x%S+$","^#%S+$"}
    if Clip[0]:find(rK[2]) ~= nil then
        初始颜色 = Color.parseColor(Clip[0])
    else
        if Clip[0]:find(rK[1]) ~= nil then
            local t =(Clip[0]):gsub("0x",'#')
            初始颜色 = Color.parseColor(t)
        end
    end
    color_view.setColor(初始颜色)

    color_img.setBackgroundColor(初始颜色)

    color_view.setOnColorChangedListener
    {
        onColorChanged=function(n)
            color_img.setBackgroundColor(n)
            local a = string.format("%02x",Color.alpha(n))
            local r = string.format("%02x",Color.red(n))
            local g = string.format("%02x",Color.green(n))
            local b = string.format("%02x",Color.blue(n))
            color_hex.Text = "#"..string.lower(a..r..g..b)
            color_rgba.Text = hex2rgba(color_hex.Text)
        end
    }

    color_img.onClick = function(v)
        --local str = string.gsub(color_hex.Text,"#","0x")
        local tc = commitColor(string.sub((color_hex.Text),2,-1))
        if(#rucs > 8) then
            table.remove(rucs,8)
        end
        table.insert(rucs,1,tc)
        recentList()
        saveRecentColor()
        --service.sendEvent("Keyboard_default")
    end
    --[[
    color_hex.onClick = function(v)
    --service.commitText((v.Text):match("#(%S+)"))
    local tc = commitColor((v.Text):match("#(%S+)"))
    if(#rucs > 8) then
    table.remove(rucs,8)
    end
    table.insert(rucs,1,tc)
    recentList()
    saveRecentColor()
    --service.sendEvent("Keyboard_default")
    end

    color_rgba.onClick = function(v)
    local t = v.Text
    --service.commitText(str)
    local tc = commitColor(t)
    --service.sendEvent("Keyboard_default")
    end
    --]]
end


recentList()
local function page1Setting()
    local data={}
    local adp=LuaAdapter(service,data,item)
    local pageData = readColor(1)
    list1.setAdapter(adp)
    table.clear(data)
    adp.clear()
    local k = GetRandomNumList(#pageData)
    for i = 1,#pageData do
        table.insert(data,{
            b={
                Text = (pageData[i]):match("#ff(%S+)"),
                BackgroundColor=Color.parseColor(pageData[i]),
                --Text = (pageData[k[i]]):match("#ff(%S+)"),
                --BackgroundColor=Color.parseColor(pageData[k[i]]),
            }, 
        })
    end
    list1.onItemClick=function(l,v,p,i)
        --local t = "#ff" .. (data[i].b.Text) .. ','
        local t =  (data[i].b.Text)
        --local t = "ff" .. (data[i].b.Text)
        --service.commitText(t)
        local tc = commitColor(t)
        if(#rucs > 8) then
            table.remove(rucs,8)
        end
        table.insert(rucs,1,tc)
        recentList()
        saveRecentColor()
        return true
    end
end

local function page2Setting()
    local data2={}
    local adp2=LuaAdapter(service,data2,item2)
    local pageData = readColor(2)
    listps.setAdapter(adp2)
    table.clear(data2)
    adp2.clear()
    for i = 1,#pageData do
        if pageData[i] ~= '' then
            table.insert(data2,{
                b={
                    --Text = (pageData[i]):match("#ff(%S+)"),
                    BackgroundColor=Color.parseColor(pageData[i]),
                },
            })
        else
            table.insert(data2,{
                b={
                    Text = '',
                    BackgroundColor=Color.parseColor("#fff0f0f8"),
                },
            })
        end
    end
    listps.onItemClick=function(l,v,p,i)
        --local t = "#ff" .. (data[i].b.Text) .. ','
        --local t =  (data2[i].b.Text)
        --local t = "ff" .. (data2[i].b.Text)
        local t = string.sub(pageData[i],4,-1)
        --service.commitText(t)
        local tc = commitColor(t)
        if(#rucs > 8) then
            table.remove(rucs,8)
        end
            table.insert(rucs,1,tc)
            recentList()
            saveRecentColor()
        return true
    end
end

local function page3Setting()
    local data3={}
    local adp3=LuaAdapter(service,data3,item1)
    local pageData = readColor(3)
    listcl.setAdapter(adp3)
    table.clear(data3)
    adp3.clear()
    for i = 1,#pageData do
        table.insert(data3,{
            c={
                Text = (pageData[i]):gsub("#ff","\n"),
                --Text = (pageData[i]):gsub(",#ff","\n"),
                BackgroundColor=Color.parseColor((pageData[i]):match("(#ff%S+)")),
            }, 
        })
    end
    listcl.onItemClick=function(l,v,p,i)
        local t =  (data3[i].c.Text):match("\n(%S+)")
        --local t = "ff" .. (data3[i].c.Text):match("\n(%S+)")
        local tc = commitColor(t)
        --service.commitText(t)
        if(#rucs > 8) then
            table.remove(rucs,8)
        end
        table.insert(rucs,1,tc)
        recentList()
        saveRecentColor()
        return true
    end
end
local function page7Setting()
    local data7={}
    local adp7=LuaAdapter(service,data7,item7)
    lists.setAdapter(adp7)
    table.clear(data7)
    adp7.clear()
    local hcolor = {"#6667AB","#939597","#F5DF4D","#0F4C81","#FF6F61","#5F4B8B","#88B04B","#F7CAC9","#92A8D1","#955251","#B565A7","#009B77","#E2492F","#CB6586","#45B5AA","#F0C05A","#5A5B9F","#9B1B30","#DECDBE","#53B0AE","#E2583E","#7BC4C4","#BF1932","#C74375","#98B2D1",}
    local ptYear = {2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2016,2017,2018,2019,2020,2021,2021,2022}
    local colorName = {"Very Peri","Ultimate Gray","Illuminating","Classic Blue","Living Coral","Ultra Violet","Greenery","Rose Quartz","Serenity","Marsala","Radiant Orchid","Emerald","Tangerine Tango","Honeysuckle","Turquoise","Mimosa","Blue Iris","Chili Pepper","SAND DOLLAR","BLUE TURQUOISE","TIGERLILY","AQUA SKY","TRUE RED","FUCHSIA ROSE","CERULEAN BLUE",}
    for i = 25,1,-1 do
        table.insert(data7,{
            t1={
                Text = tostring(ptYear[i]),
                BackgroundColor=Color.parseColor(hcolor[i]),
            }, 
            t2={
                Text = "PANTONE®",
                BackgroundColor=Color.parseColor(hcolor[i]),
            },
            t3={
                Text = colorName[i],
                BackgroundColor=Color.parseColor(hcolor[i]),
            },
            t4={
                Text = hcolor[i],
                BackgroundColor=Color.parseColor(hcolor[i]),
            },
        })
    end

    lists.onItemClick=function(l,v,p,i)
        local t =  (data7[i].t4.Text):match("#(%S+)")
        --service.commitText(t)
        local tc = commitColor(t)
        if(#rucs > 8) then
            table.remove(rucs,8)
        end
        table.insert(rucs,1,tc)
        recentList()
        saveRecentColor()
        return true
    end
end
local nPage = 0
local function page8Setting()
    local pageData = readColor2(nPage)
    local c = {}
    for i=1,#pageData do
        local tempData = Split(pageData[i],",")
        for j = 1,#tempData do
            if tempData[j]:find("#") == nil then
                --小标题和颜色分别插入不同的布局
                c=
                {
                    LinearLayout;
                    layout_width="-1";
                    id="背景";
                    {
                        TextView;
                        textColor="0xFF1f497d";
                        layout_marginTop="6dp",
                        layout_marginBottom="4dp",
                        padding="2dp";
                        textSize="12sp";
                        Text=tempData[j];
                        onClick=function()
                        end
                    };
                };
            else
                if #(tempData[j]) == 7 then

                    c=
                    {
                        LinearLayout;
                        id="背景";
                        {
                            TextView;
                            textColor="0xFFff0000";
                            BackgroundColor=Color.parseColor(tempData[j]);
                            padding="8dp";
                            layout_marginLeft="2dp";
                            layout_marginRight="2dp";
                            layout_width="30dp";
                            gravity="center";
                            layout_height="30dp";
                            textSize="12sp";
                            onClick=function()
                                local t = string.sub(tempData[j],2,-1)
                                --service.commitText(temp) 
                                local tc = commitColor(t)
                                if(#rucs > 8) then
                                    table.remove(rucs,8)
                                end
                                table.insert(rucs,1,tc)
                                recentList()
                                saveRecentColor()
                            end
                        };
                    };

                end
            end


            listbd.addView(loadlayout(c))
        end
    end
    local function 自动翻页(nPage)--默认下翻,无参数

        page8Setting()
        -- 更新布局(nPage)

    end




    local x1,x2,x3= 0,0,0
    function sco.onTouch(a,esv)
        x3 = os.clock()
        local 间隔时间1=(x3-x1)*10000
        if 间隔时间1>2 x1=x3 end
        local y=sco.getScrollY()
        if y == 0 then
        end
        local childView = sco.getChildAt(0)
        if y > childView.getHeight()-sco.getHeight()-10 then
            x2 = os.clock()
            local 间隔时间=(x2-x1)*10000
            if 间隔时间>3 then
                nPage = nPage + 1
                自动翻页(nPage)
            end
        end
    end


end
local function page4Setting()

    local c16 = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
    local dColor = ""
    --displayColorFromClip()
    local cr1,cr2,cg1,cg2,cb1,cb2,ca1,ca2 = 'f','f','f','f','f','f','f','f'

    function r1.OnValueChangedListener(v,o,n)
        cr1 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        tColor.setText(dColor)
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
    end

    function r2.OnValueChangedListener(v,o,n)
        cr2 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
        tColor.setText(dColor)
    end

    function g1.OnValueChangedListener(v,o,n)
        cg1 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
        tColor.setText(dColor)
    end

    function g2.OnValueChangedListener(v,o,n)
        cg2 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
        tColor.setText(dColor)
    end

    function b1.OnValueChangedListener(v,o,n)
        cb1 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
        tColor.setText(dColor)
    end

    function b2.OnValueChangedListener(v,o,n)
        cb2 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
        tColor.setText(dColor)
    end

    function a1.OnValueChangedListener(v,o,n)
        ca1 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
        tColor.setText(dColor)
    end
    local function letter2num(letter)
        letter = string.lower(letter)
        local n = string.byte(letter) 
        if(n >= 97) then
            return n - 87
        else
            return n - 48
        end
    end
    function a2.OnValueChangedListener(v,o,n)
        ca2 = c16[tonumber(n+1)]
        dColor = '#' .. ca1 .. ca2 .. cr1 .. cr2 .. cg1 .. cg2 .. cb1 .. cb2 
        TextFrame(tColor,3,0x00000000,Color.parseColor(dColor))
        tColor.setText(dColor)
    end
    local field=NumberPicker.getDeclaredField('mSelectionDivider').setAccessible(true)
    local function setDividerColor(view,color)
        field.get(view)
        .setColorFilter(PorterDuffColorFilter(color,PorterDuff.Mode.SRC_ATOP))
        return view
    end
    local function snp(rt,n)
        rt.setMaxValue(15);
        rt.setDisplayedValues(c16)
        rt.setMinValue(0);
        rt.setValue(n);
        rt.setTextSize(40)
        --rt.setWrapSelectorWheel(true)
        rt.setSelectionDividerHeight(4)
        setDividerColor(rt,0xffeeeeee)
        --rt.setDescendantFocusability(DatePicker.FOCUS_BLOCK_DESCENDANTS);
        --rt.setDividerColor(Color.RED)
    end
    local function displayColorFromClip()
        --读取剪切板首个数据 匹配成功为颜色值则作为初始值
        --lua不支持{n}的写法 严谨写法^0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$ ..
        local Clip=service.getClipBoard()
        local rK = {"^0x%S+$","^#%S+$"}
        if Clip[0]:find(rK[2]) ~= nil then
            tColor.setText(Clip[0])
            color_hex.setText(Clip[0])
            TextFrame(tColor,3,0x00000000,Color.parseColor(Clip[0]))
            ca1,ca2,cr1,cr2,cg1,cg2,cb1,cb2 = Clip[0]:match("#([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])")
            snp(r1,letter2num(cr1))
            snp(r2,letter2num(cr2))
            snp(g1,letter2num(cg1))
            snp(g2,letter2num(cg2))
            snp(b1,letter2num(cb1))
            snp(b2,letter2num(cb2))
            snp(a1,letter2num(ca1))
            snp(a2,letter2num(ca2))
        else
            if Clip[0]:find(rK[1]) ~= nil then
                tColor.setText(Clip[0])
                local t =(Clip[0]):gsub("0x",'#')
                color_hex.setText(t)
                TextFrame(tColor,3,0x00000000,Color.parseColor(t))
                ca1,ca2,cr1,cr2,cg1,cg2,cb1,cb2 = t:match("#([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])")
                snp(r1,letter2num(cr1))
                snp(r2,letter2num(cr2))
                snp(g1,letter2num(cg1))
                snp(g2,letter2num(cg2))
                snp(b1,letter2num(cb1))
                snp(b2,letter2num(cb2))
                snp(a1,letter2num(ca1))
                snp(a2,letter2num(ca2))
            else
                snp(r1,15)
                snp(r2,15)
                snp(g1,15)
                snp(g2,15)
                snp(b1,15)
                snp(b2,15)
                snp(a1,15)
                snp(a2,15)
            end
        end
    end
    local function onScrollStateChange(view, scrollState) 
        switch (scrollState) 
        case OnScrollListener.SCROLL_STATE_FLING
        print("up")
        case OnScrollListener.SCROLL_STATE_IDLE
        case OnScrollListener.SCROLL_STATE_TOUCH_SCROLL
    end
end




displayColorFromClip()
local 配色组=Config.get().getColorScheme()--Config.get().getColorKeys()

--print(配色组)
tColor.onClick = function(v)
    local tc = commitColor((v.Text):match("#(%S+)"))
    --service.commitText((v.Text):match("#(%S+)"))
    --service.commitText(v.Text)
    if(#rucs > 8) then
        table.remove(rucs,8)
    end
    if v.Text ~= "-ColorList-" then
        if(#rucs > 8) then
            table.remove(rucs,8)
        end
        table.insert(rucs,1,tc)
        recentList()
        saveRecentColor()
    end
    --service.sendEvent("Keyboard_default")
end
end
--adp2.notifyDataSetChanged()
local function updatePages()
    for k=1,#colorList do
        local pageData = {}
        local data1={}
        switch (colorList[k])
        case "配色"
        page1Setting()
        case "色板"
        page2Setting()
        case "传统色"
        page3Setting()
        case "代码"
        page4Setting()
        case "ARGB"
        page5Setting()
        case "拾色器"
        page6Setting()
        case "潘通色"
        page7Setting()
        case "品牌色"
        page8Setting()
    end
end
end
--每个页面的布局
local function setPages()
    local page1 =
    {
        GridView,
        id="list1",
        numColumns="5";
        paddingTop="3dp",
        verticalSpacing="2dp",
        layout_width=906
    };
    local page2 =
    {
        GridView,
        id="listcl",
        numColumns="5";
        paddingTop="3dp",
        layout_width=906
    };
    local page3 =
    {
        GridView,
        id="listps",
        --verticalSpacing="10dp",
        numColumns="6";
        paddingTop="3dp",
        layout_width=906
    };
    local page4 =
    {
        LinearLayout,
        paddingTop="3dp";
        orientation="vertical";
        {
            TextView,
            id="tColor",
            layout_height="40dp",
            layout_width="-1",
            text="-ColorList-",
            gravity="center",
            paddingLeft="2dp",
            paddingRight="2dp",
            --BackgroundColor=0xffffffff,
            textColor=0xff164a7e,
            textSize="14dp"
        },
        {
            LinearLayout,
            paddingTop="3dp";
            orientation="horizontal";
            {
                TextView,
                layout_height="20dp",
                layout_width="45dp",
                text="R",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
            {
                TextView,
                layout_height="20dp",
                layout_width="40dp",
                text="R",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
            {
                TextView,
                layout_height="20dp",
                layout_width="40dp",
                text="G",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
            {
                TextView,
                layout_height="20dp",
                layout_width="40dp",
                text="G",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
            {
                TextView,
                layout_height="20dp",
                layout_width="40dp",
                text="B",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
            {
                TextView,
                layout_height="20dp",
                layout_width="40dp",
                text="B",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
            {
                TextView,
                layout_height="20dp",
                layout_width="40dp",
                text="A",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
            {
                TextView,
                layout_height="20dp",
                layout_width="45dp",
                text="A",
                gravity="center",
                paddingLeft="2dp",
                paddingRight="2dp",
                --BackgroundColor=0xffffffff,
                textColor=0xff164a7e,
                textSize="14dp"
            },
        };
        {
            paddingTop="3dp";
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                layout_width="45dp",
                --BackgroundColor=0xffffffff,
                id="r1",
                {
                    TextView;
                };
            };
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                id="r2",
                layout_width="40dp";
                --BackgroundColor=0xffffffff,
                {
                    TextView;
                };
            };
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                id="g1",
                layout_width="40dp";
                --BackgroundColor=0xffffffff,
                {
                    TextView;
                };
            };
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                id="g2",
                layout_width="40dp";
                --BackgroundColor=0xffffffff,
                {
                    TextView;
                };
            };
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                id="b1",
                layout_width="40dp";
                --BackgroundColor=0xffffffff,
                {
                    TextView;
                };
            };
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                id="b2",
                layout_width="40dp";
                --BackgroundColor=0xffffffff,
                {
                    TextView;
                };
            };
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                id="a1",
                layout_width="40dp";
                --BackgroundColor=0xffffffff,
                {
                    TextView;
                };
            };
            LinearLayout,
            orientation="horizontal",
            {
                NumberPicker,
                id="a2",
                layout_width="45dp";
                --BackgroundColor=0xffffffff,
                {
                    TextView;
                };
            };
        };
    };
    local page5 =
    {

        LinearLayout,
        orientation="vertical";
        --paddingTop="3dp";
        {
            GridLayout;
            padding="10dp";
            layout_width=-1;
            {
                TextView;
                text="R";
                paddingTop="3dp";
            };
            {
                SeekBar;
                id="red";
                max=255;
                layout_width=-1;
                layout_height="30dp";
            };
            {
                TextView;
                text="G";
                paddingTop="3dp";
            };
            {
                SeekBar;
                id="green";
                max=255;
                layout_width=-1;
                layout_height="30dp";
            };
            {
                TextView;
                text="B";
                paddingTop="3dp";
            };
            {
                SeekBar;
                id="blue";
                max=255;
                layout_width=-1;
                layout_height="30dp";
            };
            {
                TextView;
                text="A";
                paddingTop="3dp";
            };
            {
                SeekBar;
                id="alpha";
                max=255;
                progress=255;
                layout_width=-1;
                layout_height="30dp";
            };
            rowCount="4",
            columnCount="2";
            layout_width=-1;
        };
        {
            LinearLayout,
            orientation="horizontal";
            layout_gravity="center";
            {
                TextView;
                text=" (点击上屏)";
                id="status";
                BackgroundColor=0xffffffff;
                gravity="center",
                layout_width="240dp"; 
                layout_height="40dp";
            };
            {
                Button;
                id="bt2";
                text="重置",
                layout_width="80dp";
                textColor=0xff164a7e;
                BackgroundColor=0xffffffff;
                layout_height="40dp";
            };
        };

    }
    local page6 =
    {
        LinearLayout,
        layout_width="fill",
        layout_height=height,

        {
            ColorPickerView,
            id="color_view",
            layout_width="70%w",
            layout_height="wrap",
        },
        {
            LinearLayout,
            paddingTop="8dp",
            orientation="vertical",
            {
                LinearLayout,
                layout_width="100dp",
                layout_height="50dp",
                layout_margin="2dp",
                Background=alpback(),
                {
                    View,
                    id="color_img",
                    background="#ff00a2ff",
                },
            },
            {
                TextView,
                id="color_hex",
                layout_margin="2dp",
                gravity="center",
                text="#ffffffff",
                textSize="17dp",
                textColor=0xff164a7e;
            },
            {
                TextView,
                id="color_rgba",
                layout_margin="2dp",
                gravity="center",
                text="(255,255,255,255)",
                textSize="17dp",
                textColor=0xff164a7e;
            },
        },
    }
    local page7 =
    {
        GridView,
        id="lists",
        numColumns="2",
        layout_width="fill",
        layout_height="15%h",
        paddingTop="3dp",
        BackgroundColor=0xffffffff,
    }
    local page8 =
    {
        ScrollView;
        layout_height=height;
        layout_width=width;
        id="sco",
        {
            FlowLayout,
            layout_width="fill",
            layout_height="fill",
            layout_marginLeft="3dp";
            layout_marginTop="6dp",
            MinChildSpacing="5dp";
            ChildSpacing="10dp",
            RowSpacing="10dp",
            id="listbd",
        },



    };
    --动态插页
    xxx.addView(loadlayout(page),ViewGroup.LayoutParams(-1,-1))
    local pageList = {}
    for k=1,#colorList do
        switch (colorList[k])
        case "配色"
        table.insert(pageList,loadlayout(page1))
        case "色板"
        table.insert(pageList,loadlayout(page3))
        case "传统色"
        table.insert(pageList,loadlayout(page2))
        case "代码"
        table.insert(pageList,loadlayout(page4))
        case "ARGB"
        table.insert(pageList,loadlayout(page5))
        case "拾色器"
        table.insert(pageList,loadlayout(page6))
        case "潘通色"
        table.insert(pageList,loadlayout(page7))
        case "品牌色"
        table.insert(pageList,loadlayout(page8))
    end
end
local adp0 = ArrayPageAdapter(pageList)
hd.setAdapter(adp0)

updatePages()

--页面变化处理
hd.addOnPageChangeListener(PageView.OnPageChangeListener{
    onPageScrolled=function( position, positionOffset, positionOffsetPixels)
    end,
    onPageScrollStateChanged=function( state)

    end,
    onPageSelected=function( position)
        setRadio(position + 1)
    end
});
--多次打开使用本脚本个别机型可能会占用过量内存,按一下部署即可
--占用问题哪位大佬懂的来指点一下吧
System.gc()
    end

    setPages()


    --隐藏单选栏
    --rp.setVisibility(View.GONE)


    service.setKeyboard(layout)
