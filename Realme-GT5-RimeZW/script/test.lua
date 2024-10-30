require "import"
import "android.widget.*"
import "android.view.*"
import "android.graphics.RectF"
import "android.graphics.drawable.StateListDrawable"
import "java.io.File"

import "android.os.*"
import "com.osfans.trime.*"


local keyboard_height="300dp"
pcall(function()
  keyboard_height=service.getLastKeyboardHeight()
end)

local layout_ids

local layout={
  LinearLayout,
  id="main",
  layout_height=keyboard_height
  }
layout=loadlayout(layout, layout_ids)

layout_ids.main.onTouch=function(event)
  
end