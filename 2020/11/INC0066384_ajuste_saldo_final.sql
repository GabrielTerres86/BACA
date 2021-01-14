update crapbcx a
   set a.vldsdfin = 2016.39
 where a.cdcooper = 5
   and a.cdagenci = 13
   and a.nrdcaixa = 3
   and a.dtmvtolt = to_date('14/10/2020', 'dd/mm/rrrr');
commit;
