BEGIN
  
UPDATE CECRED.crapaca a
   SET a.lstparam = a.lstparam || ', PR_DTCTRMISTA'
 WHERE a.nmpackag = 'TELA_SEGPRE'
   AND a.nmdeacao = 'SEGPRE_ALTERAR';
COMMIT;
END;
