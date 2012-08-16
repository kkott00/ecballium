window.handlers=window.handlers.concat [
 [/^Find (\w+) with text "([^"]+)"/,
  (el,text)->
   sels=
     button: 'button'
   @found_item=$("#{sels[el]}:contains(#{text})")
   @assert @found_item.length!=0,'Element not found'
   
   @log "find",$.makeArray @found_item
 ]

 [/^Click found item/,
  ()->
   @found_item.click()
 ]

]