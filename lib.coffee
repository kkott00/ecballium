window.ecb.handlers=window.ecb.handlers.concat [
 [/^Find (\w+) with text "([^"]+)"/,
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

 [/^Show found item and say "([^"]+)"/,
  (say)->
    @mouse.say(say)
 ]

 [/^(\w+) animation/,
  (state)->
    @animation = if state=="Enable" then true else false
    @mouse.enable(@animation)
 ]

 [/^Highlight "([^"]+)" and say "([^"]+)"/,
  (alias,comment)->
    item=$("#{@aliases[alias]}")
    old_z=item.css 'z-index'
    old_p=item.css 'position'
    item_pos=item.first().offset()
    caption=$("<div>#{comment}</div>")
    $('body').append(caption)
    caption.css
      'z-index':1001
      'position':'absolute'
      'background-color':'white'
      'padding':'20px'
    caption.css
      'top':item_pos.top-caption.outerHeight()
      'left':item_pos.left

    @overlay.show()
    item.css 
      'z-index':1001
      'position':'relative'
    wait(1000+comment.length).done ()=>
    	@overlay.hide()
	    item.css 
	      'z-index':old_z
	      'position':old_p
	    caption.remove()
 ]


]

window.ecb.aliases.extend 
  button: 'button'
  link: 'a'