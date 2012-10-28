

window.imports={}

window.load=(src,args)->
   d=$.Deferred()
   helper=()->
     console.log 'helper',src,$.fn.textwidget
     imports[src]=true
     d.resolve()
   if src of imports
     helper()
     return d.promise()
   head= document.getElementsByTagName('head')[0]
   script= document.createElement('script')
   script.type= 'text/javascript'
   script.src= "#{src}"
   head.appendChild(script)

   script.onreadystatechange= () ->
     if (this.readyState == 'complete') 
       helper()
   script.onload= helper
   d.promise()

window.wait=(delay)->
  d=$.Deferred()
  cb=()=>
    d.resolve()
  setTimeout cb,delay
  d.promise()

URL='static/test/'
DELAY=5000

class Ecballium
  files:{}
  persist:{}
  loc:
    file:0
    scn:0
    step:0
    outline: 0
  state: 'init'
  logbuf:''
  skipScnOnError: true
  aliases: {}
  handlers:[]
  animate:false
  DELAY:DELAY

  #navigator: "#{navigator.appCodeName} #{navigator.appName} #{navigator.appVersion} #{navigator.cookieEnabled} #{navigator.platform} #{navigator.userAgent}";
  navigator: "#{navigator.appVersion} | #{navigator.platform}";
  
  constructor:()->
    $(document).bind 'ecb_next', (e,state)=>
      e.stopPropagation()
      @state_machine (state)
    #load modules
    
    if not window.ecb_config
      load("#{URL}config.js")
      .done ()=>
        @next('config_loaded')
    else
      @next('config_loaded')
    
    @mouse=new EcballiumMouse()
    @overlay=$('<div>')
    @overlay.css
      'z-index':1000
      'background-color':'rgba(0,0,0,0.8)'
      'position':'absolute'
      'top':0
      'left':0
      'width':'10000px'
      'height':'10000px'
    $('body').append(@overlay)
    @overlay.hide()
  
  next: (state)->
    @state=state
    $(document).trigger 'ecb_next',state

  
  state_machine: (state)->
    console.log 'state machine',state
    switch state
      when 'config_loaded' then @load_modules()
      when 'modules_loaded' then @init()
      #wait for modules loading
      when 'get_cur_step' then @get_cur_step() 
      when 'find_next_step' then @find_next_step()
      when 'step_ready' then @run_step()
      when 'step_done' then @find_next_step()
      when 'all_done'
        @post('all tests done','all tests done')
        $.cookie('ecballium',null)
      else 
        throw("unknown state #{state}")      
    
  load_modules: ()->
    ds=[]
    for i in ecb_config.modules
      ds.push load "#{URL}#{i}"
    $.when.apply(@,ds)
    .done ()=>
      @init 'modules_loaded'

  init: ()->
    wait(200)
    .done ()=>
      c=$.cookie('ecballium')
      if c and ecb_config.policy=='continue'
        @persist=JSON.parse(c)
        @next 'find_next_step'
      else
        @save_persist 
          id: Math.round(Math.random()*1e10)
        @next 'get_cur_step'
  
  save_persist:(obj)->
    if obj
      $.extend(@persist,obj)
    $.cookie( 'ecballium',JSON.stringify(@persist) )
  
  get_file: (file)->
    d=$.Deferred()
    if file not of @files
      $.get("#{URL}#{file}",null,null,'text')
      .done (data)=>
        @files[file]={'scenarios':[]}
        current_scenario=null;
        n=0;
        gather_string=false;
        curfile=@files[file]
        for i in data.split('\n').concat(['end step'])
          n+=1;
          ti=i.trim()
          if gather_string
            if ti=='"""'
              gather_string=false
            else
              current_step[data]+="#{i}\n"
            continue
    
          if ti==''
            continue
          if i[0]=='#'
            continue

          if ti[0]=='|'
            if 'data' not of current_step
              current_step['data']=[]
            current_step['data'].push(k.trim() for k in ti.slice(1,-1).split('|'))
            continue
          if ti=='"""'
            gather_string=true;
            current_step['data']=''
            continue

          #console.log 'current step',current_step,@files[file]
          if current_step
            if current_step.desc=='Examples:'
              curfile['scenarios'].slice(-1)[0].outline=[]
              outline=current_step.data
              for k in outline[1..]
                #console.log 'outline parse',k,outline
                od={}
                for l,ln in outline[0]
                  od[l]=k[ln]
                curfile['scenarios'].slice(-1)[0].outline.push(od)

            else
              curfile['scenarios'].slice(-1)[0].steps.push(current_step)
            current_step=null


          re=ti.replace /^Scenario:/,''
          if re!=ti
            current_screnario=re
            curfile['scenarios'].push({name:re.trim(),steps:[]})
            continue
          re=ti.replace /^Feature:/,''
          if re!=ti
            curfile['feature_name']=re.trim()
            continue
            
          current_step={desc:ti,line:n}
        console.log 'compiled',@files[file]
        d.resolve()
    else
      d.resolve()
    d.promise()

  find_next_step:()->
    @get_file(ecb_config.features[@loc.file])
    .done ()=>
      #check if there are another steps in scenario
      scn=@loc2scn()
      @loc.step+=1
      if @loc.step>=scn.steps.length
        @loc.step=0
        if 'outline' of scn
          @loc.outline+=1
          if @loc.outline>=scn.outline.length
            @loc.outline=0
          else
            @loc.scn-=1 #repeat scenario again
        @loc.scn+=1
        #check if there are another scenarios in file
        file=@loc2file()
        if @loc.scn>=file.scenarios.length
          @loc.scn=0
          @loc.file+=1
          #check if there are another files in config
          if @loc.file>=ecb_config.features.length
            @next 'all_done'
            return
      @save_persist
        loc:@loc
      @next 'step_ready'
      
  get_cur_step:()->
    @get_file(ecb_config.features[@loc.file])
    .done ()=>
      @next 'step_ready'
  
  loc2step:()->
    scn=@loc2scn()
    tmp=$.extend {},scn.steps[@loc.step]
    if 'outline' of scn
      outline=scn.outline[@loc.outline]
      tmp.desc=tmp.desc.replace /(<[^<>]+>)/,(v)->
        #console.log 'outline replace',outline,v.slice(1,-1)
        outline[v.slice(1,-1)]
    tmp

  loc2scn:()->
    @files[ecb_config.features[@loc.file]].scenarios[@loc.scn]

  loc2file:()->
    @files[ecb_config.features[@loc.file]]

  
  run_step:()->
    #console.log 'run_step'
    step=@loc2step()
    for i in @handlers
      #console.log 'handler',i
      m=step.desc.match i[0]
      if m 
        break
    if not m
      @post('test error',"not found step")
      return 
    try
      d=i[1].apply @,m[1..]
      @post('success','success')
    catch e
      #console.log 'exception',e
      d=@show_message(@mouse.x,@mouse.y,e.stack,'rgba(255,0,0,0.5)')
      @last_exception=e
      @post('test failed',e.stack)
      if @skipScnOnError
        @loc.step=1e10  #to be sure scenario switch
    if d and ('promise' of d)
        d.then ()=>
          @next 'step_done'
    else
      @next 'step_done'
  
  log: (msg,obj)->
    @logbuf+="#{new Date()} #{msg}\n"
    @jsonobj=obj
    @logbuf+=JSON.stringify(obj,@replacer,1)
    
    
  replacer: (key,value)->
    #console.log 'replacer',key,value,$.type value
    out=value
    if (value==window)
      out = '[window]'
    if (value==document)
      out = '[document]'
    if value and value.tagName
      v=$(value)
      out=
        tag:v[0].tagName
        attrs: [i.name,i.value] for i in v[0].attributes
    #console.log 'replacer out',out
    out
  
  post: (status,msg='')->
    if status=='all tests done'
      data=
        msg:msg
        log: @logbuf
        id: @persist.id
        navigator:@navigator
    else
      step=@loc2step()
      data=
        msg:msg
        file: ecb_config[@loc.file]
        step: step.desc
        line: step.line
        log: @logbuf
        id: @persist.id
        navigator:@navigator
    @logbuf='' 
    $.post('/test',{status:status,data:data})
    console.log '===',status,' = ',data.step,data

  assert: (cond,msg='')->
    @skipScnOnError=false
    if not cond
      throw Error(msg)

  fail: (cond,msg='')->
    @skipScnOnError=true
    if not cond
      throw Error(msg)

  dump_css: (obj,v)->
    out={}
    for i of v
      out[i] = obj.css i
      obj.css i,v[i]
    out

  show_message: (x,y,msg,color='rbga(0,0,0,0.5)')->
    x?=200
    y?=200
    old=@dump_css @overlay,'background-color':color
    @overlay.show()
    caption=$("<div>#{msg}</div>")
    $('body').append(caption)
    
    caption.css
      'z-index':1001
      'position':'absolute'
      'background-color':'white'
      'padding':'20px'
    y-=caption.outerHeight()
    caption.css
      'top':y
      'left':x
    wait(DELAY).done ()=>
      @overlay.hide()
      @overlay.css old
      caption.remove()

  register_handlers: (hs)->
    console.log 'reg hnld',hs
    @handlers=@handlers.concat hs

  register_aliases: (as)->
    $.extend @aliases,as 



class EcballiumMouse
  x:300
  y:300
  constructor:()->
    @el=$ '<div>'
    @el.css
     position:'absolute'
     top:@y
     left:@x
     'z-index':9000
     'background-color':'rgba(200,200,255,0.5)'
     #'min-width': '50px'
     'min-height': '50px'
     #'width': '50px'
     'height': '50px'
     'background-image':"url(#{URL}/mouse.png)"
     'background-repeat': "no-repeat"
     padding:'10px 10px 10px 50px'
    $('body').append(@el)
    @text=$('<div>')
    @text.css
      'background-color':'rgba(200,200,255,1)'
      padding:'10px'

  moveto:(x,y)->
    d=$.Deferred()
    @x=x-25
    @y=y-25
    @el.animate {top:@y,left:@x},100,()=>d.resolve()
    d
  movetoobj:(obj)->
    toff = obj.offset()
    #@moveto toff.left+obj.width()/2,toff.top+obj.height()/2
    @moveto toff.left+50,toff.top+obj.height()/2
  click:()->
    @el.css 
      'background-color':'rgba(50,255,50,0.5)'
    wait(200).done ()=>
      @el.css 
        'background-color':'rgba(200,200,255,0.5)'
  say:(say)->
    @text.html(say)
    @el.append(@text)
    pause=DELAY+say.length
    wait(pause).done ()=>
      @text.detach()


    
# I just leave it here

`
(function($) {
    $.cookie = function(key, value, options) {

        // key and at least value given, set cookie...
        if (arguments.length > 1 && (!/Object/.test(Object.prototype.toString.call(value)) || value === null || value === undefined)) {
            options = $.extend({}, options);

            if (value === null || value === undefined) {
                options.expires = -1;
            }

            if (typeof options.expires === 'number') {
                var days = options.expires, t = options.expires = new Date();
                t.setDate(t.getDate() + days);
            }

            value = String(value);

            return (document.cookie = [
                encodeURIComponent(key), '=', options.raw ? value : encodeURIComponent(value),
                options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
                options.path    ? '; path=' + options.path : '',
                options.domain  ? '; domain=' + options.domain : '',
                options.secure  ? '; secure' : ''
            ].join(''));
        }

        // key and possibly options given, get cookie...
        options = value || {};
        var decode = options.raw ? function(s) { return s; } : decodeURIComponent;

        var pairs = document.cookie.split('; ');
        for (var i = 0, pair; pair = pairs[i] && pairs[i].split('='); i++) {
            if (decode(pair[0]) === key) return decode(pair[1] || ''); // IE saves cookies with empty string as "c; ", e.g. without "=" as opposed to EOMB, thus pair[1] may be undefined
        }
        return null;
    };
})(jQuery);
`



$ ->
  window.ecballium = new Ecballium()
