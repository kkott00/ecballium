ecballium.register_handlers [
 [/^Find (.+) with text "([^"]+)"/,
  (el,text)->
   @found_item=$("#{@aliases[el]}:contains(#{text})").first()
   @assert @found_item.length!=0,'Element not found'
   
   @log "find",$.makeArray @found_item
   @mouse.movetoobj @found_item
   
 ]

 [/^Click found item/,
  ()->
    @found_item.click()
    @mouse.click()
 ]

 [/^Say "([^"]+)"/,
  (say)->
    @mouse.say(say)
 ]

 [/^(\w+) animation/,
  (state)->
    @animation = if state=="Enable" then true else false
    @mouse.enable(@animation)
 ]

 [/^Highlight (.+) and say "([^"]+)"/,
  (alias,comment)->
    item=$("#{@aliases[alias]}")
    old=@dump_css item,
      'z-index':1001
      'position':'relative'
      'background-color':'white'
    item_pos=item.first().offset()
    d=@show_message item_pos.left,item_pos.top,comment
    d.done ()=>
	    item.css old
 ]


 [/^(Check|Fail) if (.+) (don\'t have|doesn\'t'have|have|has) (.+) "([^"]+)"/,
  /^(Проверить|Остановиться) если (.+) (имеет|не имеет) (.+) "([^"]+)"/,
  (action,el,cond,sel,val)->
   if sel=='text'
     f=$("#{@A el}:contains(#{val})")
     res=(f.length==1)
   else
     f=$("#{@A el}").first()
     res=(f.css()==val)
   console.log(f.length)
   if (@A cond)=="don't have"
     res=not res
   assertion="check for #{@A cond} failed for #{el} with value #{val}"
   if (@A action)=='checking'
     @assert(res,assertion)
   else
     @fail(res,assertion)
   @mouse.movetoobj f.first()
 ]

]

ecballium.register_aliases 
  'has':'have'
  "doesn't have":"don't have"
  'имеет':'have'
  'не имеет':"don't have"
  'Проверить':'Check'
  'Остановиться':'Fail'

  button: 'button'
  link: 'a'