Feature: Demo

Scenario: Press button
  Stop on any problem
  Go to simple test page
  Find header with "Demo page"
  Highlight and say "Test is about to start"
  Find button "Big Button"
  Say "Lets press this button"
  Click found item
  Say "Wow, It works"
  Find caption "Big Button pressed"
  Say "It looks like caption we want is here"
  Say "I want to do it again for all buttons here"

Scenario: Press several same buttons
  Find button "<button>"
  Click found item
  Find caption "<out>"
  Say "And again..."
  
  Examples:
  | button   | out                | 
  | Button 1 | Button 1 pressed   |
  | Button 2 | Button 2 pressed   |
  | Button 3 | Button 3 pressed   |

Scenario: Clean up
  Find link "Reset"
  Click found item

Scenario: Failed checks
  Say "But what happens if something is wrong?"
  Find button "Big Button"
  Click found item
  Check if text is "Big Button clicked"
  Find button "Button 1"
  Click found item
  Fail if text is "Button 1 clicked"
  Find button "Button 2"
  Click found item

Scenario: Animation, guides and screncasts
  Say "I want to show something to user"
  Find button ""
  Highlight and say "I can highlight any elements just like these buttons"

Scenario: Bye-bye
  Say "It is all...Thank you"