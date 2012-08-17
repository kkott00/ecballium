Feature: Demo

Scenario: Press button
  Highlight "button" and say "I can highlight any elements just like this buttons"
  Find button with text "Big Button"
  Click found item
  Check if there is caption "Big Button pressed"

Scenario: Press several same buttons
  Find button with text "<button>"
  Click found item
  Check if there is caption "<out>"
  
  Examples:
  | button   | out                | 
  | Button 1 | Button 1 pressed   |
  | Button 2 | Button 2 pressed   |
  | Button 3 | Button 3 pressed   |

Scenario: Clean up
  Find link with text "Reset"
  Click found item

Scenario: Failed checks
  Find button with text "Big Button"
  Click found item
  Check if there is caption "Big Button clicked"
  Find button with text "Button 1"
  Click found item
  Fail if there is caption "Button 1 clicked"
  Find button with text "Button 2"
  Click found item

Scenario: Animation, guides and screncasts
  Highlight "button" and say "I can highlight any elements just like these buttons"