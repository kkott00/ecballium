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


]

ecballium.register_aliases 
  button: 'button'
  link: 'a'