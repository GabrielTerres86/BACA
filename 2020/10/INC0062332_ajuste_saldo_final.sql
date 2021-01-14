update crapbcx a
   set a.vldsdfin = 9413.66
 where a.cdcooper = 1
   and a.cdagenci = 15
   and a.nrdcaixa = 3
   and a.dtmvtolt = to_date('18/09/2020', 'dd/mm/rrrr');
commit;
