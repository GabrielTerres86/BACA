UPDATE craptel t
  SET t.cdopptel = t.cdopptel ||',H'
     ,t.lsopptel = t.lsopptel ||',GERAR 3026'
 WHERE t.nmdatela = 'RISCO'
;
COMMIT;
