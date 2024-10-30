
require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "java.io.File"

local layout=
{
	LinearLayout;
	layout_width='match_parent';
	layout_height='match_parent';
	orientation="horizontal",
	background='#ffffffff';
	{
		FrameLayout,
		id="fl",
		{
			GridView,
			id="grid1";
			layout_width="240dp";
			layout_height="240dp";
			numColumns=4,
			verticalSpacing="10dp",
			padding="8dp",
			horizontalSpacing="10dp",
			background="#ffb8a898",
		},
	},
	{
		LinearLayout;
		orientation="vertical";
		{
			TextView;
			layout_width="wrap_content";
			layout_height="50dp";
			layout_marginLeft="4dp";
			layout_marginRight="4dp";
			gravity="center";
			text="Score:";
		},

		{
			TextView;
			id="score";
			layout_width="wrap_content";
			layout_height="50dp";
			layout_marginLeft="4dp";
			layout_marginRight="4dp";
			gravity="center";
			text="Score:";
		},

		{
			TextView;
			layout_width="wrap_content";
			layout_height="50dp";
			gravity="center";
			text="Best:";
		},

		{
			TextView;
			id="best";
			layout_width="wrap_content";
			layout_height="50dp";
			gravity="center";
		},

		{
			Button;
			layout_width="wrap_content";
			layout_height="40dp";
			layout_columnSpan="4";
			onClick="reset";
			text="reset";
			id="bn";
		},
	},
}

local item={
	CardView,
	radius="8",
	layout_width="46dp",
	layout_height="46dp",
	background="#cdc4b4",
	CardElevation="0",
	id="tv",
}
layout=loadlayout(layout)
local nmap = {}
local data={}
local adp=LuaAdapter(service,data,item)
grid1.setAdapter(adp)
for i=1,16 do
	table.insert(data,{tv="2"})
end
adp.notifyDataSetChanged()
local cvs = {}
function CreateCV(x,y,color)
	local x=x or 0
	local y=y or 0
	local color=color or "#7f7f7f7f"
	local cv=loadlayout({
		CardView,
		layout_height="46dp",
		layout_width="46dp",
		radius="8",
		background=color,
		id="c2",
		CardElevation="0",
		{
			TextView,
			text="2",
			id="t2",
			textSize="18",
			layout_gravity='center',
		},
	})
	fl.addView(cv)
	t2.getPaint().setFakeBoldText(true)
	cv.setX(x)
	cv.setY(y)
	table.insert(cvs,cv)
	return #cvs
end
function autoMove(v,direction,step)
	import "android.view.animation.DecelerateInterpolator"
	import "android.view.animation.Animation"
	import "android.animation.ObjectAnimator"
	local step = step or 1
	switch direction
	case 1
	平移动画 = ObjectAnimator.ofFloat(v, "Y",{v.getY(), v.getY() - 153*step})
	case 2
	平移动画 = ObjectAnimator.ofFloat(v, "Y",{v.getY(), v.getY() + 153*step})
	case 3
	平移动画 = ObjectAnimator.ofFloat(v, "X",{v.getX(), v.getX() - 160})
	case 4
	平移动画 = ObjectAnimator.ofFloat(v, "X",{v.getX(), v.getX() + 160})
end
平移动画.setRepeatCount(0)--设置动画重复次数，这里-1代表无限
--平移动画.setRepeatMode(Animation.REVERSE)--循环模式
平移动画.setInterpolator(DecelerateInterpolator())--设置插值器
平移动画.setDuration(250)--设置动画时间
平移动画.start()--开始动画
end
function rand2()
	local r1 = {math.random(1,4) ,math.random(1,4)}
	local x = CreateCV(22+(160)*(r1[1]-1),22+(153)*(r1[2]-1))
	nmap[r1[1]][r1[2]] = 2
	--print(x)
	MoveView(cvs[x])
end
function printTable()
local str = ""
for i=1,4 do
for j=1,4 do
str = str .. nmap[i][j] .. '-'
end
str = str .. "\n"
end
print(str)
end
function MoveView(v)
	v.onTouch=function(v,event)--手势滑动
		if event.getAction()==MotionEvent.ACTION_DOWN then
			downX = event.getRawX()
			downY = event.getRawY()
			--[[
			local vTree = v.getParent()
			local leaves = vTree.getChildCount()
			for u=1,leaves do
			local vL= vTree.getChildAt(u)
			local vT= vL.getChildAt(0)
			local iY = ((vL.getY()-22)/153) + 1
			local iX = ((vL.getX()-22)/160) + 1

			--print("x:" .. iX .. "-y:" .. iY)
			nmap[iX][iY] = vT.text
			end
			--]]
		elseif event.getAction()==MotionEvent.ACTION_MOVE
			--[[
			moveX = event.getRawX()
			moveY = event.getRawY()
			--v.setX(v.getX() + (moveX - downX))
			--v.setY(v.getY() + (moveY - downY))
			tx = v.getX() + (moveX - downX)
			ty = v.getY() + (moveY - downY)
			--v.setX(tx)
			--v.setY(ty)
			downX = moveX
			downY = moveY
			--]]
		elseif event.getAction()==MotionEvent.ACTION_UP
			upX = event.getRawX()
			upY = event.getRawY()
			local tMoveX = math.abs(upX - downX)
			local tMoveY = math.abs(upY - downY)
			------print("upX:" .. upX)
			--左右横向移动比竖向移动多的识别为横向
			if tMoveX >15 and tMoveY < tMoveX then
				if upX-downX>0 then
					--右
					local vTree = v.getParent()
					local leaves = vTree.getChildCount()
					for i=1,leaves do
						local vL= vTree.getChildAt(i)
						local iY = ((vL.getY()-22)/153) + 1
						local iX = ((vL.getX()-22)/160) + 1
						if iX < 4 then
							autoMove(vTree.getChildAt(i),4)
						end
						if i == 1 then
							rand2()
						end
					end
				elseif upX-downX<0 then
					--左
					local vTree = v.getParent()
					local leaves = vTree.getChildCount()
					for i=1,leaves do
						local vL= vTree.getChildAt(i)
						local iY = ((vL.getY()-22)/153) + 1
						local iX = ((vL.getX()-22)/160) + 1
						if iX > 1 then
							autoMove(vTree.getChildAt(i),3)
						end
						if i == 1 then
							rand2()
						end
					end
					--autoMove(v,3)
				end
			elseif tMoveY > 15 and tMoveX < tMoveY
				if upY-downY>0 then
				
					--下
					local vTree = v.getParent()
					local leaves = vTree.getChildCount()
					for i=1,leaves do
						local vL= vTree.getChildAt(i)
						local iY = ((vL.getY()-22)/153) + 1
						local iX = ((vL.getX()-22)/160) + 1
						if iY < 4then
							autoMove(vTree.getChildAt(i),2)
						end
						
					
						if i == 1 then
							rand2()
						end
					end
				elseif upY-downY<0 then
					--上
					local vTree = v.getParent()
					local leaves = vTree.getChildCount()
					for i=1,leaves do
						local vL= vTree.getChildAt(i)
						local iY = ((vL.getY()-22)/153) + 1
						local iX = ((vL.getX()-22)/160) + 1
						if iY > 1 then
							autoMove(vTree.getChildAt(i),1)
						end
						if i == 1 then
							rand2()
						end
					end
				end
			end
			--print("x:" .. tx .. "-y:" .. ty)
		end
		return true
	end
end
function dp2px(dpValue)
	local scale = this.getResources().getDisplayMetrics().density
	return (dpValue * scale)
end
function init()
	local r1 = {math.random(1,4) ,math.random( 1,4),math.random( 1,4),math.random( 1,4)}
	--local tpx = dp2px(59)
	--print(tpx)
	CreateCV(22+(160)*(r1[1]-1),22+(153)*(r1[2]-1))
	CreateCV(22+(160)*(r1[3]-1),22+(153)*(r1[4]-1))
	for i=1,4 do
		local t = {}
		for j=1,4 do
			table.insert(t,0)
		end
		table.insert(nmap,t)
	end
	nmap[r1[1]][r1[2]] = 2
	nmap[r1[3]][r1[4]] = 2
	MoveView(cvs[1])
	MoveView(cvs[2])
	--print("" .. r1[1] .. "-" .. r1[2])
	--CreateCV(r2[1],r2[2])
end
init()
function reset(v)
end
service.setKeyboard(layout)


