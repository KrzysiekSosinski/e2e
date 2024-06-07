Feature: ngfp-host page content test

  @smoke
  Scenario Outline: As a user of ngfp web application I need to make sure that all designed elements are displayed on the page
    Given I am on the "ngfp-host" page
    Then the element: "<element>" is visible on the page

    Examples:
      | element            |
      | Flight list header |
      | Sort dropdown      |
      | Filter Flights     |
      | Schedule tab       |
      | Plan tab           |
      | Flight tab         |
      | Add Flight         |
      | Upload flight      |
      | Schedule send      |
      | Sort drop down     |
      | Color mode button  |
      | Refresh button     |

  @smoke
  Scenario: As a user of ngfp web application I need to make sure clicking add Flights button brings Add Flight dialog
    Given I am on the "ngfp-host" page
    When I click the "Add Flight" button
    Then the element: "Add Flight dialog" is visible on the page

  @smoke
  Scenario Outline: As a user of ngfp web application I need to make sure that Add Flight dialog contains all elements as designed
    Given I am on the "ngfp-host" page
    When I click the "Add Flight" button
    Then the element: "<element>" is visible on the page

    Examples:
      | element           |
      | Flight designator |
      | POD               |
      | POA               |
      | STD               |
      | Send OFP          |
      | Edit OFP          |
      | Create            |

  @smoke
  Scenario: As a user of ngfp web application I need to make sure that flights are displayed in the flights list
    Given I am on the "ngfp-host" page
    Then the "Flight list" should equal the following:
      | R2222 | EPGD | EPWA | PLANNED |
      | BO777 | EPGD | EKCH | PLANNED |

  @smoke
  Scenario: As a user of ngfp web application I need to make sure that new added flight is present on the flights list
    Given I am on the "ngfp-host" page
    When I click the "Add Flight" button
    And I fill in the "Flight designator input" input with "12345"
    And I fill in the "POD input" input with "EPGD"
    And I fill in the "POA input" input with "EPWA"
    And I fill in the "ETD input" input with "12:00"
    And I fill in the "Departure date input" input with "3/25/2024"
    And I select the "B777" "aircraft selection" from the "Aircraft drop down"
    And the "Send OFP after FLight creation" check box should be checked
    And the "Edit OFP Request" check box should not be checked
    When I click the "Create" button
    Then the "Flight list" should equal the following:
      | R2222 | EPGD | EPWA | PLANNED |

  @smoke
  Scenario: As a user of ngfp web application I need to make sure that I can edit OFP request before sending
    Given I am on the "ngfp-host" page
    When I click the "Add Flight" button
    And I check the "Edit OFP Request" check box
    And I click the "Create" button
    Then the element: "Edit OFP Request window" is visible on the page

  @smoke
  Scenario: As a user of ngfp web application I need to make sure that details are displayed
    Given I am on the "ngfp-host" page
    When  I click the "Open flight by identifier" link with parameter "R2222"
    Then the element: "Flight detail" with value "R2222" is visible on the page
    Then the element: "Flight detail" with value "EPGD" is visible on the page
    Then the element: "Flight detail" with value "EPWA" is visible on the page


