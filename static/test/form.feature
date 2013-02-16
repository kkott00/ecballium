Feature: Demo

Scenario: Press button
  Go to simple test page
  Find header with "Demo page"
  Highlight and say "Test is about to start"
  Find button with "Big Button"
  Say "Lets press this button"
  Click found item
  Say "Wow, It works"
  Find caption with "Big Button pressed"
  Say "It looks like caption we want is here"
  Say "I want to do it again for all buttons here"

Scenario: Press several same buttons
  Find button with "<button>"
  Click found item
  Find caption with "<out>"
  Say "And again..."
  
  Examples:
  | button   | out                | 
  | Button 1 | Button 1 pressed   |
  | Button 2 | Button 2 pressed   |
  | Button 3 | Button 3 pressed   |

Scenario: Clean up
  Find link with "Reset"
  Click found item

Scenario: Failed checks
  Say "But what happens if something is wrong?"
  Find button with "Big Button"
  Click found item
  Find caption with "Big Button pressed"
  Check if text is "Big Button clicked"
  Find button with "Button 1"
  Click found item
  Find caption with "Button 1 pressed"
  Stop if text is "Button 1 clicked"
  Find button with "Button 2"
  Click found item

Scenario: Animation, guides and screncasts
  Say "I want to show something to user"
  Find button
  Highlight and say "I can highlight any elements just like these buttons"

Scenario: Bye-bye
  Say "It is all...Thank you"
