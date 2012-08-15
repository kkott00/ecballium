window.handlers=window.handlers.concat [
 [/^Check if there is caption "([^"]+)"/,
  (out)->
   f=$("p.caption:contains(#{out})")
   console.log(f.length)
   @assert(f.length==1,'No caption on button')
 ]
]