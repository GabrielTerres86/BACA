BEGIN
  update cecred.crapprm set DSTEXPRM = TO_DATE('31/01/2024','DD/MM/RRRR')
   where cdacesso = 'DT_LIM_CNAB240_SEM_J53';
  commit;
EXCEPTION 
  WHEN OTHERS THEN 
    ROLLBACK;  
END;