BEGIN 

UPDATE CECRED.crapaca a
   SET a.lstparam = a.lstparam || ', PR_QTMESSOCIO'
 WHERE a.nmdeacao = 'SEGPRE_ALTERAR';
 
COMMIT;
END;