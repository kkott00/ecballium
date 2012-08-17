window.ecb.handlers=window.ecb.handlers.concat [
 [/^Find (\w+) with text "([^"]+)"/,
  (el,text)->
   @found_item=$("#{@aliases[el]}:contains(#{text})").first()
   @assert @found_item.length!=0,'Element not found'
   
   @mouse.movetoobj @found_item
   @log "find",$.makeArray @found_item
 ]

 [/^Click found item/,
  ()->
    @found_item.click()
 ]

 [/^(\w+) animation/,
  (state)->
    @animation = if state=="Enable" then true else false
 ]


]

window.ecb.aliases.extend 
  button: 'button'
  link: 'a'