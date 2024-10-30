require "import"
import "android.content.*" 


function 文本分享(内容,包名,活动)
text=内容
intent=Intent(Intent.ACTION_SEND); 
intent.setType("text/plain"); 
intent.putExtra(Intent.EXTRA_SUBJECT, "分享"); 
intent.putExtra(Intent.EXTRA_TEXT, text); 
intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
  if 包名!=nil and 活动!=nil then
  componentName =ComponentName(包名,活动);
  intent.setComponent(componentName)
  end
service.startActivity(Intent.createChooser(intent,"分享到:")); 
end

--文本分享("内容","com.fooview.android.fooview","com.fooview.android.fooview.FooWorkflowStarter")
