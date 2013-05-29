ecballiumbot.register_handlers [
 [/^Find (.+) with (.*)/,
  /^Найти (.+) c (.*)/,
  /^Find (.+)/,
  (type,par)->
    type=@A type
    par=@A par
    console.log 'find',type,par
    @ecb.found_item=$(type,@root)
    console.log 'sel',@ecb.found_item
    if par
      @ecb.found_item = @ecb.found_item.filter(":contains(#{par})")
    console.log 'sel',@ecb.found_item

    @assert @ecb.found_item.length,'Not found item'

    @mouse.movetoobj @ecb.found_item
    @done()
 ]

 [/^Click found item/,
  /^Click it/,
  /^Кликнуть на найденом/,
  ()->
    @mouse.trueClick(@ecb.found_item).done ()=>
      @done('success')
 ]

 [/^Say "([^"]+)"/,
  /^Комментарий "([^"]+)"/,
  (say)->
    @mouse.say(say).done ()=>
      @done('success')
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
    #console.log 'highlight',item.is(':visible')
    item=@ecb.found_item
    old=@mouse.dump_css item,
      'z-index':10001
      'position':'relative'
      'background-color':'white'
    item_pos=item.first().offset()
    d=@mouse.show_message item_pos.left,item_pos.top+item.outerHeight()+5,comment
    d.done ()=>
      item.css old
      @done('success')
 ]

 [/^(Check|Stop) if (.+) (are|is|aren\'t|isn\'t) (.+)/,
  /^(Проверить|Остановиться) если (.+) (-|не) (.+)/,
  (action,sel,cond,val)->
   if sel=='text'
     res = (@ecb.found_item.text()==val)
   else if sel=='value'
     res = (@ecb.found_item.value()==val)
   else
     res = (@ecb.found_item.css(@A el)==val)
   if (@A cond)=="isn't"
     res = not res
   assertion = "check for for #{sel} with value #{val}"
   if (@A action)=='Check'
     @assert(res,assertion)
   else
     @fail(res,assertion)
   @mouse.movetoobj f.first()
 ]

[ /^Switch to frame (.+)/,
    (num)->
      @console.log 'sframe',num
      @root=@window.frames[num].document
      @done('success')
 ],


 [ /^Switch to (.*)/,
   /^Переключиться на (.*)/,
   (awhere)->
      where=@A awhere
      if where in ['found item','it']
        @root=@found_item.first()
      else
        @root=$(document)
      if @root.is('iframe')
        @root=@root.contents()
      null
 ],



 [ /^Enter "([^"]+)"/,
   /^Ввести "([^"]+)"/,
   (text)->
      @ecb.found_item.val(text)
      @done('success')
 ]

 [ /^Wait ([^"]+) seconds/,
   /^Подождать ([^"]+)/,
   (sec)->
     @ecb.after_step_delay = sec*1000
     @done('success')
 ]

 [ /^Go to (.+)/,
   (url) ->
     @console.log 'gotoh',url
     where = @A url

     @onredirect=()=>
       null

     @ecb.after_step_delay = 2*1000
     @console.log 'gotoh',where
     new_link = @ecb.URL + '/' + where
     @window.location.assign( new_link )
     setTimeout ()=>
        @window.location.reload()
      ,
        300
     null
 ]

 [ /^Stop on any problem/,
   ()->
     @ecb.stop_on_any = true
     @done('success')
 ]

[ /^Run feature (.*)/,
   (f)->
     @ecb.pending_feature = f
     @done('run_feature')
]
[  /^Load library (.*)/,
   (lib)->
     @ecb.scripts.push lib
     @done('load_library')
]

[ /^Scroll to it/,
   ()->
    d = @.mouse.scrollTo @ecb.found_item
    d.complete ()=>
       @done('success')
]

[
]



]

ecballiumbot.register_aliases
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
  'image':'img'

  'фрейм':'frame'
