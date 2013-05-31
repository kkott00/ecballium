

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
  
  state: 'init'
  logbuf:''
  skipScnOnError: true
  animate:false
  DELAY:5000
  REPEAT_TIME:5
  DELAY_FOR_REPEAT:1000
  root:$(document)
  window:window

  #navigator: "#{navigator.appCodeName} #{navigator.appName} #{navigator.appVersion} #{navigator.cookieEnabled} #{navigator.platform} #{navigator.userAgent}";
  navigator: "#{navigator.appVersion} | #{navigator.platform}";
  constructor:(opts)->
    $.extend @,opts
    @scripts = []
    @loc = 
      file:0
      scn:0
      step:0
      outline: 0

    console.log '****   new ecb',@loc.step,@scripts
    if not window.dbg_ecbs
      window.dbg_ecbs = []
    window.dbg_ecbs.push(@)


    @URL='/'+(window.location.pathname.split('/').slice(1,-1)).join('/')
    if not @hash
      @hash = window.location.hash.slice(1);
    if @hash == ''
      @hash = 'console'
    console.log 'URL',@URL
    $(this).on 'ecb_next', (e,state)=>
      console.log 'ecb_next_trigger',state
      e.stopImmediatePropagation()
      @state_machine state

    path = window.location.pathname.replace 'launcher.html','stub.html'
    @W=opener;
    @frame=$ @W.document

    @scripts.push @hash
    if @par
      @scripts = @scripts.concat @par.scripts

    if @console
      @file = @compile_gerkhin @console.text
    else
      @file = @get_file @hash

    wait(1000).done ()=> #debug delay
      @init()

  next: (state)->
    console.log 'next',state
    @state=state
    $(this).trigger 'ecb_next',state

  
  state_machine: (state,e)->
    console.log 'state machine',state
    switch state
      #wait for modules loading
      when 'find_next_step' then @find_next_step()
      when 'step_ready' 
        if @inject() 
          @run_step()
        else
          # wait until injection comleted
          wait(@DELAY/2+10).done ()=>
            @next('step_ready')
      when 'step_done' then @find_next_step()
      when 'feature_done'
        if @par
          @par.last_child = @par.child
          @par.child = undefined
          @par.next('step_done')
        else
          @post('all tests done','all tests done')
        #$.cookie('ecballium',null)
      else 
        throw("unknown state #{state}")      

  init: ()->
    if not @par
      window.addEventListener "message"
        ,(e)=>    
          @run_on_target_done(null,e.data)
        ,false



    #wait(200)
    #.done ()=>
    #  @next 'get_cur_step'
    ###
    load('lib.js').done ()=>
      load(@hash+'.js').done ()=>
        @get_file(@hash).done ()=>
          @next 'step_ready'
    ###
    @next 'step_ready'
 
  get_file: (file)->
    $.get("#{@URL}/#{file}.feature",null,null,'text')
    .done (data)=>
      if not @par
        $('textarea.editor').val(data)
      @file = @compile_gerkhin(data)
      console.log 'compiled',@file
  
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
          gather_string = false
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
  
  inject_script: (name)->
    try
      fh=@frame.find('head')
      script= document.createElement('script')
      script.type= 'text/javascript'
      script.src= "#{@URL}/#{name}.js"
      fh[0].appendChild(script)
      $(script).attr('x-injected','')
    catch e
      console.log("script #{name} not found")

  inject: ()->
    @frame=$(@W.document)
    fh = @frame.find('head')
    scr = fh.find('script[x-injected]')
    if scr.length==0
      @inject_script('ecballiumbot')
      wait(2010).done ()=>
        @W.ecballiumbot.ecb = @
        @inject_script 'lib'
        for i in @scripts
          @inject_script i

      return false
    return true



  find_next_step:()->
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
      file=@file
      if @loc.scn>=file.scenarios.length
        @next 'feature_done'
        return
    @next 'step_ready'

  on_scenario_change: ()->
    @root=$(document)

  loc2step:()->
    scn=@loc2scn()
    tmp=$.extend {},scn.steps[@loc.step]
    if 'outline' of scn
      outline = scn.outline[@loc.outline]
      tmp.desc = tmp.desc.replace /(<[^<>]+>)/,(v)->
        #console.log 'outline replace',outline,v.slice(1,-1)
        outline[v.slice(1,-1)]
    tmp

  loc2scn:()->
    @file.scenarios[@loc.scn]

  run_step:()->
    @current_step = @loc2step()
    step = @current_step.desc
    console.log 'run_step',step,@file,@loc.step
    @post('pre')
    @W.postMessage step,"#{@W.location.protocol}//#{@W.location.host}"

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
        navigator:@navigator
    else if status=='pre'
      step=@loc2step()
      li=$("<dt class='pre_msg'>#{step.desc}</dt>")
      $('.log dl').append(li)
      return
    else
      step=@loc2step()
      data=
        msg:msg
        file: @hash
        step: step.desc
        line: step.line
        log: @logbuf
        navigator:@navigator

    @logbuf=''
    #$.post('/test',{status:status,data:JSON.stringify data,null,1})
    console.log '===',status,' = ',data.step,data
    msg_el = "#{status}&nbsp;#{data.step}"
    if data.msg
      msg_el+="<div class='colapsible hidden'><pre>#{data.msg}</pre></div>"
    li=$("<dt class='status_#{status}'>#{msg_el}</dt>")
    $('.log dl dt.pre_msg').remove()
    $('.log dl').append(li)
    li.find('.colapsible').click ()->
      $(this).toggleClass("hidden");
 

  run_on_target_done: (data,status)->
    console.log 'run_on_target_done',status
    if @child
      @child.run_on_target_done(data,status)
      return
    
    if status=='redirected'
      @post('success')
      wait(@DELAY/2).done ()=>  #wait until page reloaded
        @next 'step_done'  
    else if status=='failed'
      @post('failed',ecballium.last_exception.stack)
      if not @stop_on_any
        @next 'step_done'
    else if status=='error'
      @post('failed',ecballium.last_exception.stack)
      @loc.step = 1e10
      if not @stop_on_any
        @next 'step_done'
    else if status=='run_feature'
      @post('success')
      @run_feature @pending_feature
    else if status=='load_library'
      @post('success')
      @inject_script @scripts.slice(-1)[0]
      wait(@DELAY/2).done ()=>
        @next 'step_done'
    else
      @post('success')
      if @after_step_delay
        debugger;
        wait(@after_step_delay).done ()=>
          @next 'step_done'
        @after_step_delay = null
      else
        @next 'step_done'

  run_feature: (f)->
    @child = new Ecballium 
      'par':@
      'hash':f

$ ->
  window.ecballium = new Ecballium()
  $('button.run_script').on 'click',()->
    console.log $('textarea.editor').val()
    ecballium.child =  new Ecballium
      'par':ecballium
      'console':
        'text':$('textarea.editor').val()

