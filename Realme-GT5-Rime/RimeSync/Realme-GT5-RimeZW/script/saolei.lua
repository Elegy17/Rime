
--[[

【扫雷复刻v0.1】

调用方式1：
解压文件夹到rime/script (没有新建)
找到你的方案里的preset_keys所在的地方加入一行
(可能在补丁xxx.custom.yaml, 主题xxx.trime.yaml,方案xxx.schema.yaml, trime.yaml文件里)
saolei: {label: "扫雷", send: function, command: 'saolei.lua'}

然后找到你需要加入的按键调用long_click: saolei
例:- {click: d, long_click: '#', key_back_color: bh2, key_text_color: th2}
↓↓
- {click: d, long_click: saolei, key_back_color: bh2, key_text_color: th2}

调用方式2：
使用群里的脚本启动器调用

该脚本主要的功能代码都是基于搜索复制粘贴
声明本脚本基于<能跑就行>原则运行 不存在维护升级
]]
require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "com.androlua.LuaDrawable"
import "android.graphics.Paint"
import "android.graphics.PixelFormat"
import "script/dex/GlideTool:com.bumptech.glide.Glide"
local scriptPath=tostring(service.getLuaExtDir("script")).."/"
local 脚本路径=debug.getinfo(1,"S").source:sub(2)
local 脚本相对路径=string.sub(脚本路径,#scriptPath+1)
local 纯脚本名=File(脚本路径).getName()
local 目录=string.sub(脚本路径,1,#脚本路径-#纯脚本名)
local layout =
{
	LinearLayout;
	orientation="vertical";
	--layout_height="fill";
	layout_width="fill";
	--Gravity="center",
	id="xfcd",
	{
		LinearLayout;
		orientation="horizontal",
		background=scriptPath .. "/res/bgt.png",
		layout_width="fill";
		{
			ImageView,
			id="logo",
			layout_height="23dp",
			layout_width="23dp",
			layout_margin="5dp",
			layout_marginLeft="6dp",

			src=scriptPath .. "/res/minesweeper.png",
		},
		{
			TextView,
			text="扫雷",
			layout_width="50%w",
			textColor="#ffffffff",
			layout_marginTop="8dp",
			layout_weight="6",
		},
		{
			--TextView,
			ImageView,
			id="closex",
			layout_height="20dp",
			layout_margin="8dp",
			layout_width="20dp",
			layout_marginRight="9dp",
			src=scriptPath .. "/res/cl.png",
		},
	},
	{
		LinearLayout;
		orientation="horizontal",
		layout_width="fill";
		paddingLeft="3dp",
		paddingTop="3dp",
		paddingBottom="3dp",
		background="#ffd2d2d2",
		{
			TextView,
			layout_marginLeft="3dp",
			text="游戏(G)",
			background="#ffd2d2d2",
			id="menu1",
		},
		{
			TextView,
			layout_marginLeft="6dp",
			text="帮助(H)",
			id="menu2",
		},
	},
	{
		LinearLayout;
		orientation="vertical";
		layout_width="fill";
		background=scriptPath .. "/res/背景.png",
		padding="3dp",
		{
			LinearLayout;
			orientation="horizontal",
			background="#ffbbbbbb",
			layout_width="fill";
			background=scriptPath .. "/res/bg2.png",
			layout_margin="3dp",
			padding="3dp",
			{
				LinearLayout;
				orientation="horizontal",
				layout_marginLeft="10%w",
				{
					ImageView,
					id="num1",
					layout_height="23dp",
					layout_width="13dp",
					layout_gravity="left",
					src=scriptPath .. "/res/0.png",
				},
				{
					ImageView,
					id="num2",
					layout_height="23dp",
					layout_width="13dp",
					layout_gravity="left",
					src=scriptPath .. "/res/0.png",
				},
				{
					ImageView,
					id="num3",
					layout_height="23dp",
					layout_width="13dp",
					layout_gravity="left",
					src=scriptPath .. "/res/0.png",
				},
			},
			{
				ImageView,
				id="new1",
				layout_height="24dp",
				layout_width="24dp",
				layout_marginLeft="25%w",
				layout_marginRight="25%w",
				layout_gravity="center",
				src=scriptPath .. "/res/face.png",
			},
			{
				LinearLayout;
				orientation="horizontal",
				layout_width="35%w";
				{
					ImageView,
					id="ti1",
					layout_height="23dp",
					layout_width="13dp",
					layout_gravity="right",
					src=scriptPath .. "/res/0.png",
				},
				{
					ImageView,
					id="ti2",
					layout_height="23dp",
					layout_width="13dp",
					layout_gravity="right",
					src=scriptPath .. "/res/0.png",
				},
				{
					ImageView,
					id="ti3",
					layout_gravity="right",
					layout_height="23dp",
					layout_width="13dp",
					src=scriptPath .. "/res/0.png",
				},
			},
		},
		{
			GridView,
			numColumns=15,
			layout_margin="3dp",
			background=scriptPath .. "/res/bg3.png",
			padding="3dp",
			layout_width=w,
			scrollBarSize=0;
			id="grid",
		},
		{
			TextView,
			id="tstv",
		},
	},
}
local layout = loadlayout(layout)
local wmManager = service.getApplicationContext().getSystemService(Context.WINDOW_SERVICE)
local params = WindowManager.LayoutParams()

if Build.VERSION.SDK_INT >= 26 then
	params.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
elseif Build.VERSION.SDK_INT >= 23 then
	params.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
else
	params.type = WindowManager.LayoutParams.TYPE_PHONE
end
params.format = PixelFormat.RGBA_8888
params.width = WindowManager.LayoutParams.FILL_PARENT
params.height = WindowManager.LayoutParams.WRAP_CONTENT
params.gravity = Gravity.BOTTOM--|Gravity.RIGHT  --弹出显示位置
params.flags = --WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
-- WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
-- WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM--输入法焦点
WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL--不与输入法交互--FLAG_WATCH_OUTSIDE_TOUCH
| WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED--启动硬件加速
| WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED--锁屏界面隐藏
params.dimAmount = -1
params.alpha = 1
params.softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
| WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN
local w=(service.width)--*0.8
if 全局变量_悬浮窗==nil or 全局变量_悬浮窗==false then
	全局变量_悬浮窗=true
	wmManager.addView(layout,params)--插入布局,显示悬浮窗
	service.sendEvent("Hide")
end


local item={
	ImageView,
	layout_width=w/15,
	layout_height=w/15,
	src=scriptPath .. "/res/m9.png",
	id="tv",
}
local data={}
local adp=LuaAdapter(service,data,item)
grid.setAdapter(adp)

local minesCount = 50
local row=15
local col=15
local counts ={}
function splitNum(str)
	local result = {}
	for i = 1, string.len(str) do
		table.insert(result,tonumber(string.sub(str,i,i)))
	end
	return result
end
function setNumPict(minesNum)
	if #minesNum == 2 then
		local numPath = scriptPath .. "/res/0.png"
		Glide.with(this).load(numPath).into(num1)
		numPath = scriptPath .. "/res/" .. tonumber(minesNum[1]) .. ".png"
		Glide.with(this).load(numPath).into(num2)
		numPath = scriptPath .. "/res/" .. tonumber(minesNum[2]) .. ".png"
		Glide.with(this).load(numPath).into(num3)

	elseif #minesNum == 3
		local numPath = scriptPath .. "/res/" .. tonumber(minesNum[1]) .. ".png"
		Glide.with(this).load(numPath).into(num1)
		numPath = scriptPath .. "/res/" .. tonumber(minesNum[2]) .. ".png"
		Glide.with(this).load(numPath).into(num2)
		numPath = scriptPath .. "/res/" .. tonumber(minesNum[3]) .. ".png"
		Glide.with(this).load(numPath).into(num3)
	else
		local numPath = scriptPath .. "/res/0.png"
		Glide.with(this).load(numPath).into(num1)
		numPath = scriptPath .. "/res/0.png"
		Glide.with(this).load(numPath).into(num2)
		numPath = scriptPath .. "/res/" .. tonumber(minesNum[1]) .. ".png"
		Glide.with(this).load(numPath).into(num3)

	end
end
function creatRanNum()
	local tb = {}
	while #tb < minesCount do 
		local istrue = false
		local num = math.random( 1,row*col )
		if #tb ~= nil then
			for i = 1 ,#tb do
				if tb[i] == num then
					istrue = true
				end
			end
		end
		if istrue == false then
			table.insert( tb, num )
		end
	end
	return tb
end
local mClikFlags = {}
function initMinesClickFlags()
	table.clear(mClikFlags)
	for i=1,row do
		local t = {}
		for j=1,col do
			table.insert(t,0)
		end
		table.insert(mClikFlags,t)
	end
end
--初始化:清空雷表 点击状态表 埋雷 计设置初始雷数图片  算雷数 
function init()
	table.clear(counts)
	initMinesClickFlags()
	local mines = creatRanNum()
	local minesNum = splitNum(minesCount)
	setNumPict(minesNum)
	for i=1,col do
		local t = {}
		for j=1,row do
			local n = 0
			local str = ""
			for k=1,minesCount do
				n = n + 1
				local x = 0
				local y = 0
				--第一行小于15 整除等于0行lua数组从1开始,所以第二行x+1 
				if mines[k] < row + 1 then
					x = 1
					y = mines[k]
				else
					x = (mines[k]//col) +1
					y = mines[k]%col
					--行末取余会等于0 重新在末尾位置赋值
					if y == 0 then
						y = 15
					end
				end
				if i == x and j == y then 
					--print("mines[i]:" .. mines[k] .. "x:" .. x .. "y:" .. y)
					table.insert(t,10)
					break
				end
			end
			if n == minesCount then
				table.insert(t,0)
			end
		end
		table.insert(counts,t)
	end
	calcNeiboLei();
	fresh()
end
function fresh()
	adp.clear()
	table.clear(data)
	for i=1,col do
		for j=1,row do
			if counts[i][j] == 10 and mClikFlags[i][j] == 1 then

				table.insert(data,{tv=scriptPath .. "/res/m12.png"})
			elseif counts[i][j] == 10 and mClikFlags[i][j] == 0 then
				table.insert(data,{tv=scriptPath .. "/res/m9.png"})
			elseif counts[i][j] == 0 and mClikFlags[i][j] == 0 then
				table.insert(data,{tv=scriptPath .. "/res/m9.png"})
			elseif counts[i][j] == 0 and mClikFlags[i][j] == 1 then
				table.insert(data,{tv=scriptPath .. "/res/m13.png"})
			elseif mClikFlags[i][j] == 1
				switch tonumber(counts[i][j])
				case 0
				table.insert(data,{tv=scriptPath .. "/res/m13.png"})
				case 1
				table.insert(data,{tv=scriptPath .. "/res/m1.png"})
				case 2
				table.insert(data,{tv=scriptPath .. "/res/m2.png"})
				case 3
				table.insert(data,{tv=scriptPath .. "/res/m3.png"})
				case 4
				table.insert(data,{tv=scriptPath .. "/res/m4.png"})
				case 5
				table.insert(data,{tv=scriptPath .. "/res/m5.png"})
				case 6
				table.insert(data,{tv=scriptPath .. "/res/m6.png"})
				case 7
				table.insert(data,{tv=scriptPath .. "/res/m7.png"})
				case 8
				table.insert(data,{tv=scriptPath .. "/res/m8.png"})

			end
		elseif mClikFlags[i][j] == 2
			table.insert(data,{tv=scriptPath .. "/res/flag.png"})
		else
			table.insert(data,{tv=scriptPath .. "/res/m9.png"})
		end
	end
end

adp.notifyDataSetChanged()
end


function block_open(_i, _j) 
	local block = counts[_i][_j]
	if block == 0 then
		mClikFlags[_i][_j] = 1
		--打开计雷数为0的方格
		--遍历九宫格内的方格
		for i = _i - 1, _i + 1 do
			for j = _j - 1,_j + 1 do
				--判断是否越界and跳过已打开的方格and非雷
				if (i > 0 and j > 0 and i < row+1 and j < col+1 and mClikFlags[i][j] == 0 and counts[i][j] ~=10) then
					--递归打开方格函数
					block_open(i, j)
				end
			end
		end
	else 
		--打开计雷数不为0的方格
		mClikFlags[_i][_j] = 1
	end

end
function ifFirstClick()
	local ct = 0
	for i=1,row do
		for j=1,col do
			if mClikFlags[i][j] == 1 then
				ct = ct + 1
			end
		end
	end
	return ct 
end
grid.onItemClick = function (l,v,p,s)
	local clickPosX = 1
	local clickPosY = 1
	if s < row+1 then
		clickPosX = 1
		clickPosY = s
	else
		clickPosX = (s// row) +1
		clickPosY = s%row
		--最右边
		if clickPosY == 0 then
			clickPosX = (s// row) 
			clickPosY = 15
		end
	end
	if mClikFlags[clickPosX][clickPosY] == 0 then
		mClikFlags[clickPosX][clickPosY] = 1
		checkWin()
		if counts[clickPosX][clickPosY] == 10 then
			if ifFirstClick() == 1 then

				local rx= math.random(1,row)
				local ry = math.random(1,col)
				while counts[rx][ry] == 10 do
					rx= math.random(1,row)
					ry = math.random(1,col)
				end
				counts[clickPosX][clickPosY] = 0
				counts[rx][ry] = 10
				calcNeiboLei()
				fresh()
			else
				LoseGame()
			end
		else
			block_open(clickPosX, clickPosY)
		end
	elseif mClikFlags[clickPosX][clickPosY] == 2 then
		mClikFlags[clickPosX][clickPosY] = 0 
		local markMines = checkMark()
		local minesNum = splitNum(minesCount - markMines)
		setNumPict(minesNum)
		fresh()
	elseif mClikFlags[clickPosX][clickPosY] == 4 then
	end
	fresh()
	return true
end
function checkMark()
	local markMines = 0
	for i=1,row do
		for j=1,col do
			if mClikFlags[i][j] == 2 and markMines <= minesCount then
				markMines = markMines + 1
			end
		end
	end
	return markMines
end
grid.onItemLongClick = function (l,v,p,s)
	local clickPosX = 1
	local clickPosY = 1
	if s < row+1 then
		clickPosX = 1
		clickPosY = s
	else
		clickPosX = (s// row) +1
		clickPosY = s%row
		--最右边
		if clickPosY == 0 then
			clickPosX = (s// row) 
			clickPosY = 15
		end
	end
	if mClikFlags[clickPosX][clickPosY] == 0 then
		mClikFlags[clickPosX][clickPosY] = 2
	elseif mClikFlags[clickPosX][clickPosY] == 2 then
		mClikFlags[clickPosX][clickPosY] = 0
	end
	local markMines = checkMark()
	local minesNum = splitNum(minesCount - markMines)
	setNumPict(minesNum)
	fresh()
	return true
end
function calcNeiboLei()
	local count = 0
	for i=1,row do
		for j=1,col do
			count=0
			if(counts[i][j]==10) then 
				continue
			end
			if(i>1 and j>1 and counts[i-1][j-1]==10) then
				count = count +1
			end
			if(i>1 and counts[i-1][j]==10) then 
				count = count +1
			end
			if(i>1 and j<15 and counts[i-1][j+1]==10) then
				count = count +1
			end
			if(j>1 and counts[i][j-1]==10) then 
				count = count +1
			end
			if(j<15 and counts[i][j+1]==10) then 
				count = count +1
			end
			if(i<15 and j>1 and counts[i+1][j-1]==10) then
				count = count +1
			end
			if(i<15 and counts[i+1][j]==10) then
				count = count +1
			end
			if(i<15 and j<15 and counts[i+1][j+1]==10) then
				count = count +1
			end

			counts[i][j]=count
		end
	end
end
init()
new1.onClick = function (v)
	init()
	local newGamePath= scriptPath .. "/res/face.png"
	Glide.with(this).load(newGamePath).into(new1)
end

function checkWin()
	local notClick = 0
	for i=1,row do
		for j=1,col do
			if mClikFlags[i][j]== 1 then
				if counts[i][j] == 10 then
					return
				end
			elseif mClikFlags[i][j]== 0 then
				notClick = notClick + 1
			end
		end
	end
	if notClick == minesCount then
		local winGamePath= scriptPath .. "/res/wingame.png"
		Glide.with(this).load(winGamePath).into(new1)
		print("你赢了！")
		for i=1,row do
			for j=1,col do
				if mClikFlags[i][j]== 0 then
					mClikFlags[i][j]= 4
				end
			end
		end
	end
end

function LoseGame()
	for i=1,row do
		for j=1,col do
			mClikFlags[i][j] = 1
		end
	end
	local loseGamePath= scriptPath .. "/res/losegame.png"
	Glide.with(this).load(loseGamePath).into(new1)
end
--end
closex.onClick=function (v)
	wmManager.removeView(layout)
	全局变量_悬浮窗 = nil
end
local xc1,yc1
local xc3,yc3
local mm_c_1
function xfcd.OnTouchListener(v,e)
	local ljpe = e.getAction()
	switch(ljpe)
	case MotionEvent.ACTION_DOWN
	xc1,yc1 = e.getRawX(),e.getRawY()
	xc3,yc3 = params.x,params.y
	mm_c_1 = true
	case MotionEvent.ACTION_MOVE
	local xf1,yf1 = xc3+(e.getRawX()-xc1),yc3-(e.getRawY()-yc1)
	if !(mm_u_1) and ((e.getRawX()-xc1)>0 or (e.getRawY()-yc1)>0) then
		mm_c_1 = nil
	end
	params.x = xf1
	params.y = yf1
	wmManager.updateViewLayout(layout,params)
	case MotionEvent.ACTION_UP
	if ((e.getRawX()-xc1)==0 or (e.getRawY()-yc1)==0) then
	end
end
return true
end--窗口移动
local addMinesDlg_layout=
{
	LinearLayout,
	layout_width="fill",
	layout_height="fill",
	--Gravity="center",
	background="#ffffffff",
	id="Dialog1",
	{
		LinearLayout,
		{
			EditText,
			hint="输入雷数",
			singleLine=true,--禁止换行输入
			inputType="number",
			layout_marginLeft="16dp",
			id="edit",
		},
		{
			Button,
			padding="2dp",
			text="确定",
			id="submitDlg",
		}, 
		{
			Button,
			padding="2dp",
			text="随机雷数",
			id="ranMines",
		}, 
		{
			Button,
			layout_width="wrap",
			padding="2dp",
			text="关闭",
			id="rmDlg",
		}, 
	},
}
local addMinesDlg = loadlayout(addMinesDlg_layout)
submitDlg.onClick=function (v)
	if ifFirstClick() == 0 then
		local t_minesCount = tonumber((edit.getText().toString()))
		if t_minesCount <5 or t_minesCount > 224 then
			print("设置雷数不在范围内")
		else
			minesCount = t_minesCount
			wmManager.removeView(addMinesDlg)
			init()
		end
	else
		print("游戏已经开始不能设置雷数")
		wmManager.removeView(addMinesDlg)
	end
	service.sendEvent("Hide")
end
ranMines.onClick=function (v)
	if ifFirstClick() == 0 then
		minesCount = math.random( 5,150)
		wmManager.removeView(addMinesDlg)

		service.sendEvent("Hide")
		init()
	else
		print("游戏已经开始不能设置雷数")
		wmManager.removeView(addMinesDlg)
	end
end
rmDlg.onClick=function (v)
	wmManager.removeView(addMinesDlg)
	service.sendEvent("Hide")
end
menu2.onClick=function (v)
	print("帮助个锤子 没有帮助")
end
menu1.onClick=function (v)
	wmManager.addView(addMinesDlg,params)
	edit.setText(tostring(minesCount))
	--print("假装菜单")
end
edit.onClick=function (v)
	edit.setText("")
end
