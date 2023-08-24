BEGIN
  
UPDATE CECRED.crapaca a
   SET a.lstparam = a.lstparam || ', PR_NRAPOLIC'
 WHERE a.nmpackag = 'TELA_SEGPRE'
   AND a.nmdeacao = 'SEGPRE_CONSULTAR';
COMMIT;
END;
