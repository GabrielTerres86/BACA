UPDATE crapatr a
   SET a.dtfimatr = TO_DATE('11/12/2019','DD/MM/RRRR')
     , a.dtinsexc = TO_DATE('11/12/2019','DD/MM/RRRR')
     , a.cdopeexc = '1'
     , a.cdageexc = 999
 WHERE a.cdcooper = 11
   AND a.nrdconta = 344834;

COMMIT;
