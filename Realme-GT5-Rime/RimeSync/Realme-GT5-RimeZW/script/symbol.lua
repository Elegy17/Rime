--[[

仿大厂样式的符号键盘
作者：6486449j
版本：2.0

changelog 2.0
添加了最近使用功能
添加了自适配主题颜色与背景图片、功能
合并了 陈勇 的字体读取、部分符号的添加与订正

]]--
require "import"
import "android.widget.*"
import "android.view.*"
import "android.graphics.RectF"
import "android.graphics.drawable.StateListDrawable"
import "java.io.File"
import "java.math.BigInteger"

import "android.os.*"
import "com.osfans.trime.*"
import "yaml"
import "android.graphics.Typeface"

--键盘高度
local keyboard_height="300dp"
pcall(function()
  keyboard_height=service.getLastKeyboardHeight()
end)
--键盘宽度
local keyboard_width=service.getWidth()

--底部按键高度
local bomBtmHeight=150
local bomBtmWidth=250

--功能键区域宽度
local funbtnWidth=250

local symBtnBorder=true
local tabBtnBorder=true
local funBtnBorder=true

--功能键颜色与边框的默认颜色
local funBtnColor=0xffc4c9ca
local funBtnBorderColor=0xff777777

--底部按键边框的默认颜色
local tabBtnColor=0xffffffff
local tabBtnBorderColor=0xff777777
local cliedTabBtnColor=0xffc4c9ca

--符号列表的按键的默认颜色
local symBtnColor=0xffffffff
local symBtnBorderColor=0xff777777
local cliedSymbtnColor=0xffc4c9ca

local maxRntSymbol=20

--符号
local symbol_icons={"最近", "中文","英文","数学","角标","序号","音标","平假","片假", "谚文","箭头","特殊","拼音","注音","竖标","部首","俄文","希腊","拉丁","制表", "土文", "藏文"}
local symbols={
  {},
  {"，","。","？","！","～","、","：","＃","；","％","＊","——","……","＆","·","￥","（","）","‘","’","“","”","[","]","『","』","〔","〕","｛","｝","【","】","‖","〖","〗","《","》","「","」","｜","〈","〉","«","»","‹","›"},
  {".","@", "~", "-", ",", ":", "*","?","!","_","#","/","=","+","﹉","&","^",";","%","…","$","(",")","\\","..","<",">","|","·","¥","[","]","\"","{","}","–","'","€","¡","¿","`","´","＂","＇","£","¢","฿","♀","♂"},
  [[=+-·/×÷^＞＜≥≤≮≯≡≠≈≒±√³√π%‰％℅½⅓⅔¼¾∶∵∴∷㏒㏑∫∬∭∮∯∰∂∑∏∈∉∅⊂⊃⊆⊇⊄⊅⊊⊈⫋⫌∀∃∩∪∧∨⊙⊕∥⊥⌒∟∠△⊿∝∽∞≌°℃℉㎎㎏μm㎜㎝㎞㎡m³㏄㏕]],
  [[º⁰¹²³⁴⁵⁶⁷⁸⁹ⁱ⁺⁻⁼⁽⁾ˣʸⁿᶻˢ₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ₐₑₒₓᵧₔᴬᴮᶜᴰᴱᶠᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾᶞᴿᵀᵁᵛᵂᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘᵛʷˣʸᶻ]],
  [[①②③④⑤⑥⑦⑧⑨⑩❶❷❸❹❺❻❼❽❾❿⒈⒉⒊⒋⒌⒍⒎⒏⒐⒑⑴⑵⑶⑷⑸⑹⑺⑻⑼⑽㈠㈡㈢㈣㈤㈥㈦㈧㈨㈩壹贰叁肆伍陆柒捌玖拾佰仟萬億ⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩⅪⅫ]],
  {"ɑː","ɔ:","ɜː","i:","u:","ʌ","ɒ","ə","ɪ","ʊ","e","æ","eɪ","aɪ","ɔɪ","ɪə","eə","ʊə","əʊ","aʊ","p","t","k","f","θ","s","b","d","g","v","ð","z","ʃ","h","ts","tʃ","j","tr","ʒ","r","dz","dʒ","dr","w","m","n","ŋ","l"},  [[あいうえおぁぃぅぇぉかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどっなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもやゆよゃゅょらりるれろわをんゎ]],
  [[アイウエオァィゥェォカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドッナニヌネノハヒフヘホバビブベボパピプペポマミムメモヤユヨャュョラリルレロワヲンヮ]],
  {"ㅏ ","ㅐ ","ㅑ ","ㅒ ","ㅓ ","ㅔ ","ㅕ ","ㅖ ","ㅗ ","ㅘ ","ㅙ ","ㅚ ","ㅛ ","ㅜ ","ㅝ ","ㅞ ","ㅟ ","ㅠ ","ㅡ ","ㅢ ","ㅣ","ㄱ ","ㄷ ","ㅂ"," ㅅ"," ㅈ","ㄲ ","ㄸ ","ㅃ ","ㅆ ","ㅉ","ㅋ ","ㅌ ","ㅍ"," ㅊ ","ㄴ","ㅁ ","ㄹ ","ㅎ ","ㅇ",},
  [[→←↑↓↖↗↙↘↔↕⇞⇟⇆⇅⇔⇕↰↱↲↴↶↷↺↻↜↝↞↟↠↡➺➻➼➳➽➸➹➷⇎➠↣☞☜☟⇦⇧⇨⇩⇪➩➪➫➬➯➱➮➭➠➡➢➣➤➥➦➧➨]],
  [[△▽○◇□☆▷◁♤♡♢♧▲▼●◆■★▶◀♠♥♦♣囍☼☽☺◐☑√✔㏂☀☾♂☹◑×✕✘☚☛㏘▪•‥…▁▂▃▄▅▆▇█∷※░▒▓▏▎▍▌▋▊▉♩♪♫♬§〼◎¤۞℗®©♭♯♮‖¶卍卐▬〓℡™㏇☌☍☋☊㉿◮◪◔◕@㈱№♈♉♊♋♌♎♏♐♑♓♒♍☰☱☲☳☯☴☵☶☷*＊✲❈❉✿❀❃❁☸✖✚✪❤ღ❦❧₪✎✍📝✌☁☂☃☄♨☇☈☡➷⊹✉☏☢☣☠☮〄➹☩ஐ☎✈〠۩✙✟☤☥☦☧☨☫☬♟♙♜♖♞♘♝♗♛♕♚♔✄✁✃❥✪☒❅✣✰⚀⚁⚂⚃⚄⚅]],
  [[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜü]],
  [[ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ]],
  [[︐︑︒︓︔︕︖︵︶︷︸︹︺︿﹀︽︾﹁﹂﹃﹄︻︼︗︘_¯＿￣﹏﹋﹍﹉﹎﹊¦︴¡¿^ˇ¨ˊ]],
  [[丨亅丿乛一乙乚丶八勹匕冫卜厂刀刂儿二匚阝丷几卩冂力冖凵人亻入十厶亠匸讠廴又艹屮彳巛川辶寸大飞干工弓廾广己彐彑巾口马门宀女犭山彡尸饣士扌氵纟巳土囗兀夕小忄幺弋尢夂子贝比灬长车歹斗厄方风父戈卝户火旡见斤耂毛木肀牛牜爿片攴攵气欠犬日氏礻手殳水瓦尣王韦文毋心牙爻曰月爫支止爪白癶歺甘瓜禾钅立龙矛皿母目疒鸟皮生石矢示罒田玄穴疋业衤用玉耒艸臣虫而耳缶艮虍臼米齐肉色舌覀页先行血羊聿至舟衣竹自羽糸糹貝采镸車辰赤辵豆谷見角克里卤麦身豕辛言邑酉豸走足青靑雨齿長非阜金釒隶門靣飠鱼隹風革骨鬼韭面首韋香頁音髟鬯鬥高鬲馬黄鹵鹿麻麥鳥魚鼎黑黽黍黹鼓鼠鼻齊齒龍龠]],
  [[абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]],
  [[ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρστυφχψω]],
  [[ÀÁÂÃÄÅĀÆÇÈÉÊËĒÌÍÎÏĪÐÑÒÓÔÕÖŌØŒÙÚÛÜŪÝŸÞŠàáâãäåæçèéêëēìíîǐïīðñòóõǒôöōøœùúǔûüūýþšÿ]],
  [[┝┞┟┠┡┢═╞╟╡╢╪┭┮┯┰┱┲║╤╥╧╨╫┥┦┧┨┩┪┽┾┿╀╁╂┵┶┷┸┹┺╄╅╆╇╈╉┈┉┊┋╃╊┍┑┕┙┎┒┖┚╒╕╘╛╓╖╙╜┄┅┆┇┌┬┐├┼┤└┴┘┏┳┓┣╋┫┗┻┛╔╦╗╠╬╣╚╩╝]],
  [[ᐁᐂᐃᐄᐅᐆᐇᐈᐉᐊᐋᐒᐓᐜᐷᐶᐵᐴᐳᑄᑅᑌᑍᑏᑎᑒᑓᑔᑞᑡᑫᑬᑭᑮᑯᑱᑰᑳᑴᑷᒎᒏᒑᒠᒢᒡᒤᒥᒦᓀᓂᓁᓃᓄᓉᓋᓔᓖᓙᓛᓳᓻᓵᓲᓰᔂᓿᓾᗤᗥᗦᘑᘗᘜᘲᙀᙁ]],
  {"྅","ཽ","༒","ྀ","ི","༄༅","༽","༼","ཨོཾ","།","ྈ","ༀ","༂","༃","༆","༇","༈","༉","༊","༓","༔","༕","༖","༗","༙","༜","༴","༵","༶","༷","༺","༻","༾","༿","ི",",ུ","ེ","ོ","་","།","ྲ","ྱ","༡","༢","༣","༤","༥","༦","༧","༨","༩","༠"}
}
--输入法数据路径
local rimePath=tostring(service.getLuaExtDir("")).."/"

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

local function toDexStr(n)
  n=toint(n)
  local str=""
  if n != nil then
    str = "0x" .. BigInteger(tostring(n), 10).toString(16)
  end
  return str
end

--传入十进制数，补全为十六进制八位数(填上F直到满八位)
local function completeCorVal(v)
  local vs=string.gsub(toDexStr(v), "0x", "")
  --print(vs)
  vs=string.upper(vs)
  while string.len(vs)<8
    vs="F" .. vs
  end
  vs="0x" .. vs
  --print(vs)
  return tonumber(vs, F)
end

local function transpColor(c)
  local str=string.gsub(tostring(c), "0xFF", "")
  str="0x88" .. str
  return(toint(str))
  
end

local 主题组=Config.get()
local 当前主题0=主题组.getTheme()
local 主题文件=rimePath.."build/"..当前主题0..".yaml"
local yaml组 = yaml.load(io.readall(主题文件))

local bgpic_path=rimePath.."bg.jpg"
local 当前配色ID=Config.get().getColorScheme()
local 当前配色背景 = yaml组["preset_color_schemes"][当前配色ID]["keyboard_back_color"]
if 当前配色背景==nil then
  当前配色背景 = yaml组["preset_color_schemes"][当前配色ID]["back_color"]
end
local 当前配色背景颜色 = completeCorVal(当前配色背景)

local 当前按键背景 = yaml组["preset_color_schemes"][当前配色ID]["key_back_color"]
if 当前按键背景==nil then
  当前按键背景 = yaml组["preset_color_schemes"][当前配色ID]["back_color"]
end
local 当前按键背景颜色 = completeCorVal(当前按键背景)

if 当前配色背景颜色 != nil then
  --背景颜色
  --print(toDexStr(当前按键背景颜色))
  symBtnColor=当前配色背景颜色
  tabBtnColor=当前按键背景颜色

  funBtnColor=当前按键背景颜色
  cliedTabBtnColor=当前配色背景颜色
 elseif 当前配色背景 != nil and File(bgpic_path).isFile()==false then
  --说明是背景图片
  bgpic_path = rimePath .. "backgrounds/" .. 当前配色背景
end

--[[
if File(bgpic_path).isFile() then
  symBtnColor=transpColor(symBtnColor)
  tabBtnColor=transpColor(tabBtnColor)

  funBtnColor=transpColor(funBtnColor)
  cliedTabBtnColor=transpColor(cliedTabBtnColor)
  
end
]]--

local fontColorConf=yaml组["preset_color_schemes"][当前配色ID]["key_text_color"]
if fontColorConf==nil then
  fontColorConf=yaml组["preset_color_schemes"][当前配色ID]["candidate_text_color"]
end

if fontColorConf==nil then
  fontColorConf=yaml组["preset_color_schemes"][当前配色ID]["text_color"]
end

if fontColorConf==nil then
  fontColorConf=0xffffffff
end

--print(fontColorConf)
local fontColor=completeCorVal(fontColorConf)
--print(toDexStr(fontColor))

--储存最近使用符号的文件路径
local recentSymbolPath=rimePath.."recent_symbol.txt"

local rntSymbol={}

--判断文件是否存在
if not File(recentSymbolPath).exists()
  File(recentSymbolPath).createNewFile()
end

local function revertTable(t)
  local tmp={}
  for i in ipairs(t)
    table.insert(tmp, i)
  end
  return tmp
end

--插入最近符号
local function insertRntSymbol(s)
  local j=0
  for i, k in ipairs(rntSymbol) do
    j=j+1
    if k==s
      table.remove(rntSymbol, j)
    end
  end
  table.insert(rntSymbol, 1, s)
end

--更新最近符号
local function genRntSymbol()
  symbols[1]=rntSymbol
end

--从文本文件中读取最近符号
for s in io.lines(recentSymbolPath) do
  table.insert(rntSymbol, tostring(s))
end

genRntSymbol()

--生成储存在文本文件里的带回车的字符串
local function genRntSybFileStr()
  local str=""
  for i,k in ipairs(rntSymbol) do
    str=str..k.."\n"
  end
  return str
end

local currSelect=1

local layout_ids={}

local curr_tab_id="tab"..tostring(currSelect)
local last_tab_id=""

--获取k功能图标，没有返回s
local function icon(k,s)
  k=Key.presetKeys[k]
  return k and k.label or s
end

--生成背景
local function background(color, borderColor)
  local background=LuaDrawable(function(canvas, paint, drawable)
    local b=drawable.bounds
    --paint.setColor(color)
    canvas.drawColor(color)
    paint.setColor(borderColor)
    paint.setStrokeWidth(2)
    canvas.drawLine(b.left, b.top, b.left, b.bottom, paint)
    canvas.drawLine(b.left, b.top, b.right, b.top, paint)
    canvas.drawLine(b.right, b.top, b.right, b.bottom, paint)
    canvas.drawLine(b.left, b.bottom, b.right, b.bottom, paint)
  end)

  return background
end

local function bg_effect(color, clickedColor, borderColor)
  local state_1=background(color, borderColor)
  local state_2=background(clickedColor, borderColor)

  local bg=StateListDrawable()
  bg.addState({-android.R.attr.state_pressed},state_1)
  bg.addState({android.R.attr.state_pressed},state_2)
  return bg
end

local vibeFont=Typeface.DEFAULT
local 字体文件 = service.getLuaDir().."/fonts/symbol.ttf"
if File(字体文件).exists() then
  vibeFont=Typeface.createFromFile(字体文件)
end--if File(字体文件)

local data={}
local item={
  LinearLayout,
  layout_height=150,
  layout_width=-1,
  gravity="center",
  {
    TextView,
    id="text",
    layout_width=-1,
    layout_height=-1,
    textColor=fontColor,
    gravity="center",
    textSize="16dp",
    Typeface=vibeFont,
    background=background(symBtnColor,symBtnBorderColor)
}}
local adp=LuaAdapter(service, data, item)

--生成侧边功能键
local function getFunKeys()
  local funbtnHeight=(keyboard_height-bomBtmHeight)/4
  local layout={LinearLayout,
    Orientation=1,
    layout_padding=0,
    layout_width="fill",
    {Button,
      id="back",
      text=icon("Keyboard_default", "返回"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      onClick=function()
        local str=genRntSybFileStr()
        io.open(recentSymbolPath,"w"):write(str):close()
        service.sendEvent("Keyboard_default")
      end,
      --layout_margin=-14,
      background=background(funBtnColor,funBtnBorderColor)
    },
    {Button,
      text=icon("space", "空格"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      --layout_margin=-14,
      onClick=function()

        service.sendEvent("space")
      end,
      background=background(funBtnColor,funBtnBorderColor)
    },
    {Button,
      text=icon("BackSpace","退格"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      --layout_margin=-14,
      onClick=function()
        service.sendEvent("BackSpace")
      end,
      background=background(funBtnColor,funBtnBorderColor)
    },
    {Button,
      text=icon("Return", "回车"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      --layout_margin=-14,
      onClick=function()
        service.sendEvent("Return")
      end,
      background=background(funBtnColor,funBtnBorderColor)
    }
  }
  return layout
end

--生成符号列表
local function genContentList()
  table.clear(data)
  local tmp_sym=symbols[currSelect]
  if type(tmp_sym)=="string" then
    local temp={}
    for a in utf8.gmatch(tostring(tmp_sym),"%S")
      table.insert(temp,a)
    end
    tmp_sym=temp
  end
  for i in ipairs(tmp_sym)
    table.insert(data,{
      text={
        Text=tostring(tmp_sym[i]),
      },
    })
  end
end

--生成底部按键
local function getBottomKeys()
  local layout={HorizontalScrollView,
    {LinearLayout,
      Orientation=0,
      layout_padding=0
    }
  }
  for i in ipairs(symbol_icons)
    local btn={Button,
      id="tab"..tostring(i),
      text=tostring(symbol_icons[i]),
      layout_width=bomBtmWidth,
      layout_height=bomBtmHeight,
      textColor=fontColor,
      Typeface=vibeFont,
      background=background(tabBtnColor, tabBtnBorderColor),
      onClick=function()
        last_tab_id=curr_tab_id
        curr_tab_id="tab"..tostring(i)
        --print(curr_tab_id)
        currSelect=i
        if i==1
          genRntSymbol()
        end
        genContentList()
        adp.notifyDataSetChanged()

        if curr_tab_id ~= last_tab_id then
          if curr_tab_id~="" then
            layout_ids[curr_tab_id].setBackground(background(cliedTabBtnColor,tabBtnBorderColor))
            --print("clicked")
          end
          if last_tab_id~="" then
            layout_ids[last_tab_id].setBackground(background(tabBtnColor,tabBtnBorderColor))
          end
        end
        layout_ids.list.smoothScrollToPosition(0)
      end
    }

    table.insert(layout[2], btn)
  end

  return layout
end

--主布局
local layout = {
  FrameLayout,
  layout_height=keyboard_height,
  layout_width=-1,
  BackgroundColor=symBtnColor,
  {LinearLayout,
    id="main",
    orientation=1,
    {LinearLayout,
      id="se",
      orientation=1,
      layout_height=keyboard_height-bomBtmHeight,
      {LinearLayout,
        layout_width="match_parent",
        Orientation=0,
        {GridView,
          id="list",
          numColumns=4,
          layout_width=keyboard_width-funbtnWidth},
        getFunKeys()
      }
    },
    getBottomKeys()
  }
}
layout=loadlayout(layout, layout_ids)

genContentList()

layout_ids.list.Adapter=adp

layout_ids.list.onItemClick=function(l,v,p,i)
  local s=data[p+1].text.Text
  insertRntSymbol(s)
  service.commitText(s)
end

if curr_tab_id~="" then
  layout_ids[curr_tab_id].setBackground(background(cliedTabBtnColor,tabBtnBorderColor))
  --print("clicked")
end

service.setKeyboard(layout)

local function gradientDrawable(orientation,colors)
  import"android.graphics.drawable.GradientDrawable"
  return GradientDrawable(GradientDrawable.Orientation[orientation],colors)
end

local 脚本目录=tostring(service.getLuaExtDir("script")).."/"
local 脚本路径=debug.getinfo(1,"S").source:sub(2)--获取Lua脚本的完整路径
local 纯脚本名=File(脚本路径).getName()
local 目录=string.sub(脚本路径,1,#脚本路径-#纯脚本名)

--视频路径
local bgmv_path=rimePath.."bg.mp4"
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