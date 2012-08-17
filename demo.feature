Feature: Demo

Scenario: Press button
  Highlight "first paragraph" and say "Test is about to start"
  Find button with text "Big Button"
  Say "Lets press this button"
  Click found item
  Say "Wow, It works"
  Check if there is caption "Big Button pressed"
  Say "It looks like caption we want is here"
  Say "I want to do it again for all buttons here"

Scenario: Press several same buttons
  Find button with text "<button>"
  Click found item
  Check if there is caption "<out>"
  Say "And again..."
  
  Examples:
  | button   | out                | 
  | Button 1 | Button 1 pressed   |
  | Button 2 | Button 2 pressed   |
  | Button 3 | Button 3 pressed   |

Scenario: Clean up
  Find link with text "Reset"
  Click found item

Scenario: Failed checks
  Say "But what happens if something is wrong?"
  Find button with text "Big Button"
  Click found item
  Check if there is caption "Big Button clicked"
  Find button with text "Button 1"
  Click found item
  Fail if there is caption "Button 1 clicked"
  Find button with text "Button 2"
  Click found item

Scenario: Animation, guides and screncasts
  Say "I want to show something to user"
  Highlight "button" and say "I can highlight any elements just like these buttons"

Scenario: Bye-bye
  Say "It is all..."