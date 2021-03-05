update crapbcx a
   set a.vldsdfin = 35079.01
 where a.cdcooper = 2
   and a.cdagenci = 18
   and a.nrdcaixa = 1
   and a.dtmvtolt = to_date('01/03/2021', 'dd/mm/rrrr');
commit;
