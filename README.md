Ecballium
=========
Fully client-side BDD framework

# Getting started

This framework is intended for two main tasks:
* To test if you web application works as expected.
* To make animated guide or screencast for your web application.

# How it works

1. Describe your test in human readable form 
It is easy even if you are non-programmer persons. 
<pre>
    Feature: Demo
    
    Scenario: Press button
      Find button with text "Big Button"
      Click found item
      Check if there is caption "Big Button pressed"
</pre>
2. Save you scenario to folder where _ecballium_ is deployed (for example as _simple.feature_).
3. Open URL `http://www.yoursite.com/test/launcher#simple`  
**Important** For the first time your browser will ask you to allow popup from this site.  
If you use steps only from _standart library_ then it is enough.
4. If you want to do something special (something out of standard library scope).
You may need to describe your own steps using Javascript or Coffeescript (e.g. file _simple.js_).
<pre>
ecballium.register_handlers([
    [ /^Some special step (.*)/, 
      function(par) {
        do_something(par)
        this.done('success');
      }]);
ecballium.register_aliases({
    'special element link': '#special_element a',
  });
</pre>
Another useful thing here are _aliases_. Ther allow to define CSS selectors for test sentences.


# Why it is better
# ... than Jasmine
In Jasmine test code and test description are mixed but my main aim is to divide test description and test implementation.  
Also Jasmine works inside application context but better test is when you are outside just like real user.

# ... than SeleniumHQ
You don't need create infrastructure for test launching just put test description and test implementation like ordinary static files. In distinction to this Ecballium's tests can be launched via special URL remotely or from shell script.  
Selenium has limited access to application context in browser. It is difficult to launch JS code in application context to get object from browser context or to get event from application side. In addition to that test code is implemented using Python, Java or something else but application language mainly is JS.  
Together with what selenium always has problem with browser drivers and it drives to additional bugfixing of testcode.
Unlike Selenium Ecballium's test always run in browser context and distinction between browsers are easier than problem in browser driver.


***

License: LGPL v.3