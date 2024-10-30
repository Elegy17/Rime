require "import"
import "java.io.File"
import "com.osfans.trime.*" --载入包
import "yaml"

--每日一句,新内容加入到此变量中
local 随机一句组,随机一句大全={},[[

明月楼高休独倚，酒入愁肠，化作相思泪。
多情自古空余恨，好梦由来最易醒。
羌管悠悠霜满地，人不寐，将军白发征夫泪。
衣带渐宽终不悔，为依消得人憔悴。
无可奈何花落去，似曾相识燕归来。
满目山河空念远，落花风雨更伤春。
天涯地角有穷时，只有相思无尽处。
从别后，忆相逢，几回魂梦与君同。
会挽雕弓如满月，西北望，射天狼。
一川烟草，满城风絮，梅子黄时雨。
纸上得来终觉浅，绝知此事要躬行。
花开堪折直须折，莫待无花空折枝。
落红不是无情物，化作春泥更护花。
行到水穷处，坐看云起时。
横眉冷对千夫指，俯首甘为孺子牛。
及时当勉励，岁月不待人。
南风知我意，吹梦到西洲。
万一禅关砉然破，美人如玉剑如虹。
近水楼台先得月，向阳花木易为春。
羌笛何须怨杨柳，春风不度玉门关。
春江潮水连海平，海上明月共潮生。
此情可待成追忆，只是当时已惘然。
文章千古事，得失寸心知。
海上生明月，天涯共此时。
此心安处是吾乡。
不近人情，举世皆畏途；不察物情，一生俱梦境。
细看来，不是杨花，点点是离人泪。
有理言自壮，负屈声必高。
砌下梨花一堆雪，明年谁此凭阑干。
遍身罗绮者，不是养蚕人。
海日生残夜，江春入旧年。
胡人吹笛戍楼间，楼上萧条海月闲。
醉卧不知白日暮，有时空望孤云高。
天涯芳草迷归路，病叶还禁一夜霜。
云散月明谁点缀？天容海色本澄清。
莫道弦歌愁远谪，青山明月不曾空。
海到尽头天作岸，山登绝顶我为峰。
杨花榆荚无才思，惟解漫天作雪飞。
雨后复斜阳，关山阵阵苍。
水性虽能流不导则不通，人性虽能智不教则不达。
我寄愁心与明月，随君直到夜郎西。
君不见，黄河之水天上来，奔流到海不复回。
岁寒，然后知松柏之后凋也。
万缕千丝终不改，任他随聚随分。
江水流春去欲尽，江潭落月复西斜。
武帝宫中人去尽，年年春色为谁来。
人生飘忽百年内，且须酣畅万古情。
同来望月人何处？风景依稀似去年。
今夕复何夕，共此灯烛光。
燐灯三千燃长夜，烛照天门千山雪。
年年岁岁花相似，岁岁年年人不同。
江上春山远，山下暮云长。
问君何事轻离别，一年能几团圞月。
斜阳外，寒鸦万点，流水绕孤村。
待到黄昏月上时，依旧柔肠断。
蜚鸟尽，良弓藏；狡兔死，走狗烹。
一重山，两重山。山远天高烟水寒，相思枫叶丹。
沾衣欲湿杏花雨，吹面不寒杨柳风。
梧桐叶上三更雨，叶叶声声是别离。
伤心桥下春波绿，曾是惊鸿照影来。
春水碧于天，画船听雨眠。
浮生若梦，为欢几何？
水晶帘动微风起，满架蔷薇一院香。
云母屏风烛影深，长河渐落晓星沉。
星垂平野阔，月涌大江流。
乱山残雪夜，孤烛异乡人。
梅花雪，梨花月，总相思。
枝上柳绵吹又少。天涯何处无芳草。
醉后不知天在水，满船清梦压星河。
一别如斯，落尽梨花月又西。
知我者，谓我心忧；不知我者，谓我何求。
大漠沙如雪，燕山月似钩。
取次花丛懒回顾，半缘修道半缘君。
数人世相逢，百年欢笑，能得几回又。
一道残阳铺水中，半江瑟瑟半江红。
一日不见兮，思之如狂。
时人不识凌云木，直待凌云始道高。
慎终如始，则无败事。
善者不辩，辩者不善。
执今之道，以御今之有。
天之道，损有余而补不足；人之道，损不足以奉有余。
哀莫大于心死，而人死亦次之。
相呴以湿，相濡以沫，不如相忘于江湖。
狗不以善吠为良，人不以善言为贤。
无奈夜长人不寐，数声和月到帘栊。
巧者劳而知者忧，无能者无所求。
来世不可待，往世不可追。
一尺之棰，日取其半，万世不竭。
欲多则心散，心散则志衰，志衰则思不达。
爱人者人恒爱之，敬人者人恒敬之。
人必自侮，然后人侮之。
以若所为，求若所欲，犹缘木而求鱼。
君子不蔽人之美，不言人之恶。
以人言善我，必以人言罪我。
谁无暴风劲雨时，守得云开见月明。
高山仰止，景行行止，虽不能至，心向往之。
心似双丝网，中有千千结。
生尽欢，死无憾。
不要以为世界上的人，都在关心你的事。
人生实在是太有限了，不可能对谁都亲切。
爱自己是终身浪漫的开始。
勿作枝想、勿作叶想、勿作花想、勿作实想。
若不给自己设限，则人生中就没有限制你发挥的藩篱。
以诚感人者，人亦诚而应。
蚁穴虽小，溃之千里。
大多数人想要改造这个世界，但却罕有人想改造自己。
任何的限制，都是从自己的内心开始的。
人之所以能，是相信能。
与其临渊羡鱼，不如退而结网。
拿望远镜看别人，拿放大镜看自己。
你的眼中，明暗交杂，一笑生花。
长月黄昏后，伫立露沾衣；莫问我为谁，我自待伊人。
岁月极美，在于它必然的流逝；春花、秋月、夏日、冬雪。
那天，我听到了种子破土的声音，又细微又坚定。
你背对太阳，就只能看到自己的影子。
此后如竟没有炬火，我便是唯一的光。
历史的发展是不以人的意志为转移的。
道德用于律己，而非用来责人。
一万年太久，只争朝夕。
你可以期待太阳从东方升起 ，而风却随心所欲地从四面八方吹来。
欲买桂花同载酒，终不似，少年游。
雷起云涌，盼雨留你于此；雷轻云疏，无雨我亦陪你。
我曾踏月而来，只因你在山中。
]]

  for a in string.gmatch(随机一句大全,"(.-)\n") do
    if a~="" then
     随机一句组[#随机一句组+1]=a
    end
  end --for结束

参数=(...)

local 输入法目录=tostring(service.getLuaExtDir("")).."/"
local 目录=tostring(service.getLuaExtDir("script"))
local 脚本路径=debug.getinfo(1,"S").source:sub(2)--获取Lua脚本的完整路径
local 脚本相对路径=string.sub(脚本路径,#目录+1)
local 纯脚本名=File(脚本路径).getName()
local 脚本目录=string.sub(脚本路径,1,#脚本路径-#纯脚本名)

local 当前键盘名=纯脚本名:sub(1,-5)

local function 取默认键盘()
  local 默认键盘,键盘=".default",{}
  local 主题组=Config.get()
  local 当前主题0=主题组.getTheme()
  local 主题文件=输入法目录..当前主题0..".yaml"
  local yaml组 = yaml.load(io.readall(主题文件))
  local 首键盘=yaml组["style"]["keyboards"][1]
  if 默认键盘==首键盘 then
    local 键盘1=Config.get().getKeyboard(默认键盘)--读取指定键盘配置项
    键盘=luajava.astable(键盘1)
  else
    local 键盘1=Config.get().getKeyboard(首键盘)--读取指定键盘配置项
    if File(脚本目录..首键盘..".lua").isFile()==false then
      LuaUtil.copyDir(脚本目录..默认键盘..".lua",脚本目录..首键盘..".lua")
    end
    键盘=luajava.astable(键盘1)
  end
  return 键盘
end--function

local 键盘=取默认键盘()

local function java随机整数(最大数)
 local 随机数种子 =Random()
 local 随机整数=随机数种子.nextInt(最大数)+1
 return 随机整数
end--function java随机整数

local 随机一句 = 随机一句组[java随机整数(#随机一句组)]

local n=#键盘.keys
for i=0,n-1 do
 --print(键盘.keys[i].click)
 local 单个按键信息=键盘.keys[i]["click"]
 if 单个按键信息 ~= nil then
 if string.lower(单个按键信息)=="space" then
   键盘.keys[i].hint=随机一句
 end--if
 if string.lower(单个按键信息)=="lua_keys" then
   键盘.keys[i].hint=随机一句
 end--if
 
 end
end --for结束

--设置键盘第一个键长按启动脚本
--键盘["keys"][0]["long_click"]="_Keyboard_script"


return 键盘