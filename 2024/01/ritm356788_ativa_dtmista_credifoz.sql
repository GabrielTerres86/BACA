Begin
  update tbseg_parametros_prst p set p.dtctrmista = to_date('01/01/2024','dd/mm/yyyy') where p.CDCOOPER = 11 and p.TPCUSTEI = 1 and p.nrapolic = '000000077001236';
  commit;
End;
