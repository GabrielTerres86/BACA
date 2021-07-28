-- project/prj0023567 / parametros

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpctrlim'
 WHERE a.nmdeacao = 'EXEC_CARGA_MANUAL';
/
 
COMMIT;
/
