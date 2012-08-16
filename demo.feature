Feature: Demo

Scenario: Press button
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