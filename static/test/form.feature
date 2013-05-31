Feature: Working with form

Scenario: Open page
  Load library simple
  Go to simple test page

Scenario: Standart form
  Say "Fast filling of form"
  Find form
  Fill form
|text_input|test text|
|textarea|test text 2|
|checkbox|check|
|radio|option2|
|select|4,,5|


Scenario: Using controls
  Say "Another way to do it"
  Find text input
  Enter "My name"
  Find checkbox
  Click it
  Find radio
  Set radio to option1
  Find select
  Set select options
  |1|
  |2|
  Say "Form is done"

