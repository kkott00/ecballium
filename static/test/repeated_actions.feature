Feature: Repeated actions

Scenario: Open page
  Go to simple test page

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

