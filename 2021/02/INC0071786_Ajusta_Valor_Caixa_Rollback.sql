update crapbcx a
   set a.vldsdfin =  -12117.01
 where a.cdcooper = 13
   and a.cdagenci = 1
   and a.nrdcaixa = 6
   and a.dtmvtolt = to_date('08/12/2020', 'dd/mm/rrrr');
commit;
