ecballium.register_handlers [
 [/^Find (.*) "([^"]*)"/,
  /^Найти (.*) "([^"]*)"/
  (el,text)->
    tloc = ()=>
      count +=1
      @found_item = if req then @root.find(req) else sel.apply @,[text]
      if count < @REPEAT_TIME and @found_item.length == 0
        return wait( @DELAY_FOR_REPEAT ).done ()=>
                 tloc()
      @assert @found_item.length!=0,'Element not found'
      @log "find",$.makeArray @found_item
      @mouse.movetoobj @found_item.first()

    sel=@A el
    count = 0
    if not sel.apply
      req = if text=='' then "#{sel}" else "#{sel}:contains(#{text})"
    return tloc()
 ]

 [/^Click found item/,
  /^Кликнуть на найденом/,
  ()->
    @mouse.trueClick(@found_item)
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
    console.log 'highlight',item.is(':visible')
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

 [ /^Swith to (.*)/,
   /^Переключиться на (.*)/,
   (awhere)->
      where=@A awhere
      if where=='found_item'
        @root=@found_item.first()
      else
        @root=$(document)
      null
 ]

 [ /^Enter "([^"]+)"/,
   /^Ввести "([^"]+)"/,
   (text)->
      @found_item.val(text)
      return
 ]

 [ /^Wait ([^"]+)/,
   /^Подождать ([^"]+)/,
   (sec)->
     wait(parseInt(sec)*1000).done ()=>
       return
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
  "ссылку":'a'
  "кнопку":'button'
  "anything with text": ''
  "все с текстом": ''

  "are":'is'
  "aren't":"isn't"
  '-':'is'
  'не':"isn't"

  'найденный элемент':'found_item'
  'документ':'document'
