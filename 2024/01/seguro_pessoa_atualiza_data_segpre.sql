begin
  update tbseg_parametros_prst p
   set p.dtinivigencia = TO_DATE('27/11/2007',' DD/MM/RRRR')
      ,p.dtfimvigencia = TO_DATE('27/11/2007',' DD/MM/RRRR')
 where p.cdcooper = 16
   and p.cdsegura = 514
   and p.tpcustei = 1
   and p.nrapolic = '000000077001236';
   commit;
end;
/
