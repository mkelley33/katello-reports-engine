Feature: report unique instances

  The spacewalk-splice-tool will populate a mongo database with client check-in's from 
  a satellite server.  Report Filters are used to define how the mongo database is queried.
  The "db" is refering to the mongo checkin_service db, marketing_product_usage collection.

  The report should only display one row in the table for each unique 'instance_identifier'.
  

  Scenario Outline: execute a filter
    Given there is one unique instance in the db  "<populate>"
    When I define a filter "<name>" starting at "<f_start>" ending at "<f_end>" with entitlement_status "<status>" and inactive "<inactive>"
    Then when I execute the filter, the report should have this number of rows "<result>"

    Scenarios: no matches
      | populate | name        | f_start       | f_end         | status                          | inactive |  result |
      | 1        | basic       | 2013-05-01    | 2013-06-01    | Current,Invalid,Insufficient  | false    |  1      |