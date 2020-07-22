
UPDATE crapatr a
   SET a.dtfimatr = TO_DATE('12/01/2020','DD/MM/RRRR')
     , a.dtinsexc = TO_DATE('12/01/2020','DD/MM/RRRR')
     , a.cdopeexc = '1'
     , a.cdageexc = 999
 where a.nrdconta=168769 and a.cdcooper=7 and 
a.progress_recid in (753129,789102,770616,808102,789101,826914,808101,848090,826913,867947,848089,885963,976940,763800);

COMMIT;
