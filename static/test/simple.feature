Feature: Demo

Scenario: Hello
  Go to simple test page
  Find header with "Demo page"
  Highlight and say "Test is about to start"

Scenario: Press button
  Run feature press_button

Scenario: Press several same buttons
  Run feature repeated_actions

Scenario: Failed checks
  Run feature checks

Scenario: Animation, guides and screncasts
  Run feature highlight


Scenario: Bye-bye
  Say "It is all...Thank you"
