window.ecb.handlers=window.ecb.handlers.concat [
 [/^Check if there is caption "([^"]+)"/,
  (out)->
   f=$("p.caption:contains(#{out})")
   console.log(f.length)
   @assert(f.length==1,'No such caption')
   @mouse.movetoobj f.first()
 ]
 [/^Fail if there is caption "([^"]+)"/,
  (out)->
   f=$("p.caption:contains(#{out})")
   console.log(f.length)
   @fail(f.length==1,'No such caption')
   @mouse.movetoobj f.first()
 ]
]

window.ecb.aliases.extend 
  caption: 'p.caption'
  'first paragraph':'div.desc'