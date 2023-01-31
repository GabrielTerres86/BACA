DECLARE

CURSOR cr_crapprm IS
  SELECT nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid, SUBSTR(cdacesso, 7, 1 ) produto 
   FROM crapprm c 
  WHERE c.cdacesso LIKE ('MOTOR_%');
  
rw_crapprm cr_crapprm%ROWTYPE;

BEGIN
  
  FOR rw_crapprm IN cr_crapprm  LOOP
        
     INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
     VALUES (rw_crapprm.nmsistem, rw_crapprm.cdcooper, 'MOTOR_PF_'||rw_crapprm.produto, rw_crapprm.dstexprm, '1');
       
     INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
     VALUES (rw_crapprm.nmsistem, rw_crapprm.cdcooper, 'MOTOR_PJ_'||rw_crapprm.produto, rw_crapprm.dstexprm, '1');     
     
     DELETE crapprm c
      WHERE c.cdacesso = 'MOTOR_' ||rw_crapprm.produto;
        
  END LOOP;
       
  UPDATE cecred.crapaca 
     SET lstparam = 'pr_tlcooper,pr_flgativo,pr_tpprodut,pr_incomite,pr_contigen,pr_anlautom,pr_nmregmpf,pr_nmregmpj,pr_qtsstime,pr_qtmeschq,pr_qtmeschqal11,pr_qtmeschqal12,pr_qtmesest,pr_qtmesemp,pr_incalris,pr_neurotechpf,pr_neurotechpj,pr_motorpf,pr_motorpj'
   WHERE nmdeacao = 'PAREST_ALTERA_PARAM';
        
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;





