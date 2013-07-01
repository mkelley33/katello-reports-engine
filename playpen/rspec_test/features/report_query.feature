Feature: report query

  The spacewalk-splice-tool will populate a mongo database with client check-in's from 
  a satellite server.  Report Filters are used to define how the mongo database is queried.
  There may be 100 check-in's for a particular instance in the date range specified in the query, however only the 
  latest checkin will be used. Once the latest checkin is found... status is applied
  

  Scenario Outline: execute a filter
    Given there is a populated database where the last checkin is Current "<populate>"
    When I define several filters "<name>" starting at "<f_start>" ending at "<f_end>" with entitlement_status "<status>" and inactive "<inactive>"
    Then when I execute the filters, the report should have this number of rows "<result>"

    Scenarios: no matches
      | populate | name        | f_start       | f_end         | status                        | inactive |  result |
      | 1        | basic       | 2013-05-01    | 2013-06-01    | Current,Invalid,Insufficient  | false    |  1      |
      | 1        | basic       | 2013-05-01    | 2013-06-01    | Invalid,Insufficient          | false    |  0      |
      | 1        | basic       | 2013-05-01    | 2013-06-01    | Invalid                       | false    |  0      |
      | 1        | basic       | 2013-05-01    | 2013-06-01    | Insufficient                  | false    |  0      |