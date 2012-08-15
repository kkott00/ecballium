window.imports={}
window.handlers=[]

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

wait=(delay)->
  d=$.Deferred()
  cb=()=>
    d.resolve()
  setTimeout cb,delay
  d.promise()



class Ecballium

  URL:'/static/test/'
  files:{}
  persist:{}
  loc:
    file:0
    scn:0
    step:0
  state: 'init'
  logbuf:''
  
  constructor:()->
    $(document).bind 'ecb_next', (unused,state)=>
      @state_machine (state)
    #load modules
    load("#{@URL}config.js")
    .done ()=>
      for i in ecb_config.modules
        load "#{@URL}#{i}"

    @next('init')
  
  next: (state)->
    @state=state
    $(document).trigger 'ecb_next',state


  state_machine: (state)->
    console.log 'state machine',state
    if state=='init'
      #wait for modules loading
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
    else if state=='get_cur_step'
      @get_cur_step() 
    else if state=='find_next_step'
      @find_next_step()
    else if state=='step_ready'
      @run_step()
    else if state=='step_done'
      @find_next_step()
    else 
      throw("unknown state #{state}")      
     
       
  save_persist:(obj)->
    if obj
      $.extend(@persist,obj)
    $.cookie( 'ecballium',JSON.stringify(@persist) )
  
  get_file: (file)->
    d=$.Deferred()
    if @files[file]
      d.resolve()
    $.get("#{@URL}#{file}")
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
  
        if i==''
          continue
        if i[0]=='#'
          continue
        re=ti.replace /^Scenario:/,''
        if re!=ti
          current_screnario=re
          curfile['scenarios'].push({name:re.trim(),steps:[]})
          continue
        re=ti.replace /^Feature:/,''
        if re!=ti
          curfile['feature_name']=re.trim()
          continue
        
        if ti[0]=='|'
          if 'data' not of current_step
            current_step['data']=[]
          current_step['data'].push([k.trim() for k in ti.split('|')])
          continue
        if ti=='"""'
          gather_string=true;
          current_step['data']=''
          continue
            
        console.log 'current step',current_step,@files[file]
        if current_step
          if current_step.step=='Examples:'
            curfile['scenarios'].slice(-1)[0].outline=current_step.data
          else
            curfile['scenarios'].slice(-1)[0].steps.push(current_step)
          
        current_step={desc:ti,line:n}
      console.log 'compiled',@files[file]
      d.resolve()
    d.promise()

  find_next_step:()->
    @get_file(ecb_config.features[@loc.file])
    .done ()=>
      @loc.step+=1
      @save_persist
        loc:@loc
      @next 'step_ready'
      
  get_cur_step:()->
    @get_file(ecb_config.features[@loc.file])
    .done ()=>
      @next 'step_ready'
  
  loc2step:()->
    @files[ecb_config.features[@loc.file]].scenarios[@loc.scn].steps[@loc.step]
  
  run_step:()->
    console.log 'run_step'
    step=@loc2step()
    for i in handlers
      console.log 'handler',i
      m=step.desc.match i[0]
      if m 
        break
    if not m
      @post('test error',"not found step")
      return 
    try
      i[1].apply @,m[1..]
      @post('success','success')
    catch e
      console.log(e)
      @last_exception=e
      @post('test failed',e.stack)
    @next 'find_next_step'
  
  log: (msg,obj)->
    @logbuf+="#{new Date()} #{msg}\n"
    @jsonobj=obj
    @logbuf+=JSON.stringify(obj,@replacer,1)
    
    
  replacer: (key,value)->
    console.log 'key',key,value
    if (value==window)
      return '[window]'
    if (value==document)
      return '[document]'
    if value and value.tagName
      v=$(value)
      out=
        tag:v[0].tagName
        attrs:v[0].attributes
      return out
    console.log 'value',value
    value
  
  post: (status,msg)->
    step=@loc2step()
    data=
      msg:msg
      file: ecb_config[@loc.file]
      step: step.desc
      line: step.line
      log: @logbuf
      id: @persist.id
    @logbuf='' 
    $.post('/test',{status:status,data:data})


$ ->
  window.ecballium = new Ecballium()
      
# I just leave it here

`
/*!
 * jQuery Cookie Plugin
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2011, Klaus Hartl
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/GPL-2.0
 */
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