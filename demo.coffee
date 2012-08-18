ecballium.register_handlers [
 [/^Check if (.+) has text "([^"]+)"/,
  (alias,out)->
   f=$("#{@aliases[alias]}:contains(#{out})")
   console.log(f.length)
   @assert(f.length==1,'No such caption')
   @mouse.movetoobj f.first()
 ]
 [/^Fail if (.+) has text "([^"]+)"/,
  (alias,out)->
   f=$("#{@aliases[alias]}:contains(#{out})")
   console.log(f.length)
   @fail(f.length==1,'No such caption')
   @mouse.movetoobj f.first()
 ]
]

ecballium.register_aliases
  caption: 'p.caption'
  'first paragraph':'div.desc'