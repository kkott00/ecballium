Feature: Press button

Scenario: Open page
  Load library simple
  Go to simple test page

Scenario: Press button
  Find button with "Big Button"
  Say "Lets press this button"
  Click found item
  Say "Wow, It works"
  Find caption with "Big Button pressed"
  Say "It looks like caption we want is here"

