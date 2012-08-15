window.handlers=window.handlers.concat [
 [/^Find (\w+) with text "([^"]+)"/,
  (el,text)->
   sels=
     button: 'button'
   @found_item=$("#{sels[el]}:contains(#{text})")
   
   @log "find",$.makeArray @found_item
 ]

 [/^Click found item/,
  ()->
   @found_item.click()
 ]

]