ecballium.register_handlers [
 [/^Find (.*) "([^"]*)"/,
  /^Найти (.*) "([^"]*)"/
  (el,text)->
    sel=@A el
    if sel.apply
      @found_item=sel.apply @,text
    else
      if text==''
        @found_item=$("#{sel}")
      else
        @found_item=$("#{sel}:contains(#{text})")
    @assert @found_item.length!=0,'Element not found'
   
    @log "find",$.makeArray @found_item
    @mouse.movetoobj @found_item.first()
   
 ]

 [/^Click found item/,
  /^Кликнуть на найденом/,
  ()->
    @found_item.click()
    @mouse.click()
 ]

 [/^Say "([^"]+)"/,
  /^Комментарий "([^"]+)"/,
  (say)->
    @mouse.say(say)
 ]

 [/^(\w+) animation/,
  /^(\w+) анимацию/,
  (state)->
    @animation = if state=="Enable" then true else false
    @mouse.enable(@animation)
 ]

 [/^Highlight and say "([^"]+)"/,
  /^Выделить и добавить комментарий "([^"]+)"/,
  (comment)->
    item=@found_item
    old=@dump_css item,
      'z-index':10001
      'position':'relative'
      'background-color':'white'
    item_pos=item.first().offset()
    d=@show_message item_pos.left,item_pos.top+item.outerHeight()+5,comment
    d.done ()=>
	    item.css old
 ]


 [/^(Check|Fail) if (.+) (are|is|aren\'t|isn\'t) (.+)/,
  /^(Проверить|Остановиться) если (.+) (-|не) (.+)/,
  (action,sel,cond,val)->
   if sel=='text'
     res=(@found_item.text()==val)
   else
     res=(@found_item.css(@A el)==val)
   if (@A cond)=="isn't"
     res=not res
   assertion="check for for #{sel} with value #{val}"
   if (@A action)=='Check'
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

  'button': 'button'
  'link': 'a'
  "ссылку":'link'
  "кнопку":'button'
  "anything with text": ''
  "все с текстом": ''

  "are":'is'
  "aren't":"isn't"
  '-':'is'
  'не':"isn't"