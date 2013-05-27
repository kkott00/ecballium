Feature: Press button

Scenario: Open page
  Go to simple test page

Scenario: Press button
  Find header with "Demo page"
  Highlight and say "Test is about to start"
  Find button with "Big Button"
  Say "Lets press this button"
  Click found item
  Say "Wow, It works"
  Find caption with "Big Button pressed"
  Say "It looks like caption we want is here"

