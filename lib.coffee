ecballium.register_handlers [
 [/^Find (.+) with (.*)/,
  /^Найти (.+) c (.*)/,
  /^Find (.+)/,
  (type,par)->
    type=@A type
    par=@A par
    console.log 'find',type,par
    @found_item=@root.find(type)
    console.log 'sel',@found_item
    if par
      @found_item = @found_item.filter(":contains(#{par})")
    console.log 'sel',@found_item

    @assert @found_item.length,'Not found item'

    @run_on_target ()->
      console.log 'i am on target',@
      @mouse.movetoobj @ecb.found_item
      @done()
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

 [ /^Switch to (.*)/,
   /^Переключиться на (.*)/,
   (awhere)->
      where=@A awhere
      if where=='found item'
        @root=@found_item.first()
      else
        @root=$(document)
      if @root.is('iframe')
        @root=@root.contents()
      null
 ]

 [ /^Enter "([^"]+)"/,
   /^Ввести "([^"]+)"/,
   (text)->
      @found_item.val(text)
      return
 ]

 [ /^Wait ([^"]+) seconds/,
   /^Подождать ([^"]+)/,
   (sec)->
     wait(parseInt(sec)*1000).done ()=>
       return
 ]

 [ /Go to (.+)/,
   (url) ->
     where = @A url
     @W.location.href=where
     
     #$('iframe').attr('src',where)

     d=wait(5000)
     d.done ()=>

       @inject()
       @root=@frame

     wait(6000)
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
  "frame":"iframe"

  "are":'is'
  "aren't":"isn't"
  '-':'is'
  'не':"isn't"

  'найденный элемент':'found item'
  'документ':'document'

  'header': 'h1, h2, h3, h4, h5'
