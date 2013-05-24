Feature: Checks

Scenario: Open page
  Go to simple test page


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
