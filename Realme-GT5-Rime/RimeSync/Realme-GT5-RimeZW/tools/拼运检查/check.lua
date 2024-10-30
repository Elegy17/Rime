require "import"
import "android.widget.*"
import "android.view.*"
import "yaml"

import "regex"
local g=[[([^/]+)/([^/]+)/([^/]*)/]]
local gu="^\\U%%(%d)"
local gl="^\\L%%(%d)"
function checkpinyin(algebra,t)
  algebra=algebra or {}
  local r={t}
  for k,v ipairs(algebra)
    local p,f,t=v.p,v.f,v.t
    if p==nil
      continue
    end

    t=t:gsub("%$","%%")
    if p=="xform"
      for kk,vv ipairs(r)
        r[kk]=regex.gsub(vv,f,t)
      end
     elseif p=="xlit"
      for kk=1,#r
        for n=1,#f
          r[kk]=regex.gsub(r[kk],f:sub(n,n),t:sub(n,n))
        end
      end
     elseif p=="derive"
      local m=#r
      for n=1,m
        local vv=r[n]
        local l=t:match(gl)
        if l then
          local rr,ss=vv:gsub(f,function(...)
            local arg={...}
            return string.lower(arg[l])
          end)
          if ss>0
            table.insert(r,rr)
          end
          continue
        end
        local l=t:match(gu)

        if l then
          local rr,ss=vv:gsub(f,function(...)
            -- print("up",f,l,...)
            local arg={...}
            return string.upper(arg[tointeger(l)])
          end)
          if ss>0
            table.insert(r,rr)
          end
          continue
        end
        local rr,ss=regex.gsub(vv,f,t)
        if ss>0
          table.insert(r,rr)
        end
      end
     elseif p=="abbrev"
      local m=#r
      for n=1,m
        local vv=r[n]
        local rr,ss=regex.gsub(vv,f,t)
        if ss>0
          table.insert(r,1,rr)
        end
      end
    end
  end
  return r
end

function check(path)
  activity.title=path
  local g2="\n[^\t\n ]+\t([^\t\n]+)"

  local content = yaml.load(io.readall(activity.getLuaExtPath(path)))
  local dict=content.translator.dictionary
  dict=io.readall(activity.getLuaExtPath(dict..".dict.yaml"))
  local dt={}
  local cc={}
  for d string.gmatch(dict,g2)
    for p string.gmatch(d,"[^ ]+")
      if not cc[p]
        cc[p]=true
        table.insert(dt,p)
      end
    end
  end
  table.sort(dt)

  --print(table.concat(dt," "))
  local algebra=content.speller.algebra
  local r={}
  local as={}
  if algebra==nil
    print("无拼运规则")
    return
  end
  for k,v ipairs(algebra)
    local p,f,t=v:match(g)
    if p==nil
      continue
    end
    local a={}
    a.t=t
    a.f=f
    a.p=p
    print(p,f,t)
    table.insert(as,a)
  end
  for k,v ipairs(dt)

    r[v]=checkpinyin(as,v)

  end
  local py={}

  for k,v pairs(r)

    print(k,dump(v))
    for kk,vv ipairs(v)
      if vv:find("%d")
        continue
        end
      local p=py[vv] or {}
      table.insert(p,k)
      py[vv]=p
    end
  end
  print(dump(py))
end