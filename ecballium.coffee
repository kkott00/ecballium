

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
   script.src= src
   head.appendChild(script)

   script.onreadystatechange= () ->
     if (this.readyState == 'complete') 
       helper()
   script.onload= helper
   d.promise()

window.wait=(delay)->
  d=$.Deferred()
  cb=()=>
    console.log 'wait done',delay
    d.resolve()
  setTimeout cb,delay
  d.promise()




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
  DELAY:5000
  REPEAT_TIME:5
  DELAY_FOR_REPEAT:1000
  root:$(document)
  URL:''

  #navigator: "#{navigator.appCodeName} #{navigator.appName} #{navigator.appVersion} #{navigator.cookieEnabled} #{navigator.platform} #{navigator.userAgent}";
  navigator: "#{navigator.appVersion} | #{navigator.platform}";
  constructor:(opts)->
    $.extend @,opts
    if ecb_config and ecb_config.URL
      @URL=ecb_config.URL 
    console.log 'URL',@URL
    $(document).bind 'ecb_next', (e,state)=>
      console.log 'ecb_next',state
      e.stopPropagation()
      @state_machine (state)
    #load modules
    if not window.ecb_config
      load("#{@URL}config.js")
      .done ()=>
        @next('config_loaded')
    else
      @next('config_loaded')
  
  next: (state)->
    console.log 'next',state,@
    @state=state
    $(document).trigger 'ecb_next',state

  
  state_machine: (state,e)->
    console.log 'state machine',state
    switch state
      when 'config_loaded'
        @load_modules()
      when 'modules_loaded'
        if ecb_config and ecb_config.mode=='passive' then return;
        @init()
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
      ds.push load "#{@URL}#{i}"
    $.when.apply(@,ds)
    .done ()=>
      @init 'modules_loaded'

  init: ()->
    @DELAY=ecb_config.DELAY

    $('.log').draggable
      handle:'.header'

    $(document).bind 'ecballium.run_on_target_done', (data)=>
      @run_on_targe_done()


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
      $.get("#{@URL}#{file}",null,null,'text')
      .done (data)=>
        @files[file]=@compile_gerkhin(data)
        console.log 'compiled',@files[file]
        d.resolve()
    else
      d.resolve()
    d.promise()
  
  compile_gerkhin: (data)->
    current_scenario=null;
    n=0;
    gather_string=false;
    curfile={'scenarios':[]}
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
    curfile
  
  inject: ()->
    @frame=$('iframe').contents()
    fh=@frame.find('head')
    scr=fh.find('script[x-injected]')
    if scr.length==0
      fh.append('<script x-injected="" src="static/test/ecballiumbot.js"></script>')
    null



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

  on_scenario_change: ()->
    @root=$(document)


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


  ex_step:(step)->
    for i in @handlers
      #console.log 'handler',i
      for j in i.slice(0,-1)
        #console.log 'handler_re',j,step.desc
        m=step.match j
        if m
          break
      if m
        break
    if not m
      @post('test error',"not found step")
      return
    try
      d=i.slice(-1)[0].apply @,m[1..]
      @post('success','success')
    catch e
      throw e
      #console.log 'exception',e
      #d=@show_message(100,100,"<pre>#{e.stack}</pre>",'rgba(255,0,0,0.5)')
      @last_exception=e
      @post('test failed',e.stack)
      if @skipScnOnError
        @loc.step=1e10  #to be sure scenario switch
    return d

  run_step:()->
    #console.log 'run_step'
    step=@loc2step().desc
    d=@ex_step step
    console.log 'run_step',d
    if d and ('then' of d)
        #d.done ()=>
        #  console.log 'd done'
        d.done ()=>
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
    #$.post('/test',{status:status,data:JSON.stringify data,null,1})
    console.log '===',status,' = ',data.step,data
    li=$('<dt>')
    li.html("<b>#{status}</b>&nbsp;#{data.step}\n<div class='colapsible hidden'><code>#{data.msg}</code></div>")
    $('.log dl').append(li)
    li.find('.colapsible').click ()->
      $(this).toggleClass("hidden");
 
  assert: (cond,msg='')->
    @skipScnOnError=false
    if not cond
      throw Error(msg)

  fail: (cond,msg='')->
    @skipScnOnError=true
    if not cond
      throw Error(msg)


  register_handlers: (hs)->
    console.log 'reg hnld',hs
    @handlers=@handlers.concat hs

  register_aliases: (as)->
    $.extend @aliases,as

  A: (al)->
    m=al.match /^"(.*)"$/
    if m
      return m[1]
    out = if al of @aliases then @aliases[al] else al

  S: (al)->
    out = @A al
    out = if 'apply' of out then out.apply @ else out

  run_on_target: (fun,args)->
    $(frame).contents().trigger 'ecballium.run_on_target'
    @awaiting_cb=@.Deferred()
    @awaiting_cb.promise()

  run_on_target: (data)->
    @awaiting_cb.resolve(data)
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
