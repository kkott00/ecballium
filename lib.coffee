window.ecb.handlers=window.ecb.handlers.concat [
 [/^Find (\w+) with text "([^"]+)"/,
  (el,text)->
   @found_item=$("#{@aliases[el]}:contains(#{text})")
   @assert @found_item.length!=0,'Element not found'
   
   @log "find",$.makeArray @found_item
 ]

 [/^Click found item/,
  ()->
   @found_item.click()
 ]

]

window.ecb.aliases.extend 
  button: 'button'
  link: 'a'