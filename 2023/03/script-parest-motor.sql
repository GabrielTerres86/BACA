DECLARE

  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM cecred.crapbat
     WHERE cdbattar = pr_cdbattar;
     
  CURSOR cr_crapdat IS
     SELECT DISTINCT cdcooper 
       FROM cecred.crapdat
      WHERE dtmvcentral IS NOT NULL  
      order by cdcooper;
      
  CURSOR cr_crapprm IS
    SELECT nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid, SUBSTR(cdacesso, 7, 1 ) produto 
     FROM crapprm c 
    WHERE c.cdacesso LIKE ('MOTOR_%');
    
    rw_crapprm cr_crapprm%ROWTYPE;       
    rw_crapbat cr_crapbat%ROWTYPE;
    rw_crapdat cr_crapdat%ROWTYPE;
    aux_cdpartar_add  crappat.cdpartar%TYPE;
    aux_cdpartar_del  crappat.cdpartar%TYPE;
  
BEGIN
  OPEN cr_crapbat('JSON1_APAGA_ARQ');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    
    BEGIN
      DELETE FROM cecred.crapbat WHERE cdcadast = aux_cdpartar_del;
      DELETE FROM cecred.crappat WHERE cdpartar = aux_cdpartar_del;
      DELETE FROM cecred.crappco WHERE cdpartar = aux_cdpartar_del;
  
      COMMIT;
     EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          raise_application_error(-20003,'Erro ao excluir registro na crapbat: '||SQLERRM);
    END;
  END IF;
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM cecred.crappat;
 
  aux_cdpartar_add := aux_cdpartar_add + 1;
 
  INSERT INTO cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  VALUES (aux_cdpartar_add, 'JSON0001 - Apagar arquivo ao final da comunicação (1-Ligado/0-Desligado)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('JSON1_APAGA_ARQ', 'JSON0001 - Apagar arquivo ao final da comunicação (1-Ligado/0-Desligado)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  '0');
  END LOOP;
  
  FOR rw_crapprm IN cr_crapprm  LOOP
        
     insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
     values (rw_crapprm.nmsistem, rw_crapprm.cdcooper, 'MOTOR_PF_'||rw_crapprm.produto, rw_crapprm.dstexprm, '1');
       
     insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
     values (rw_crapprm.nmsistem, rw_crapprm.cdcooper, 'MOTOR_PJ_'||rw_crapprm.produto, rw_crapprm.dstexprm, '1');
        
  END LOOP;
   
  UPDATE cecred.crapaca 
     SET lstparam = 'pr_tlcooper,pr_flgativo,pr_tpprodut,pr_incomite,pr_contigen,pr_anlautom,pr_nmregmpf,pr_nmregmpj,pr_qtsstime,pr_qtmeschq,pr_qtmeschqal11,pr_qtmeschqal12,pr_qtmesest,pr_qtmesemp,pr_incalris,pr_neurotechpf,pr_neurotechpj,pr_motorpf,pr_motorpj'
   WHERE nmdeacao = 'PAREST_ALTERA_PARAM';
        
  COMMIT;

EXCEPTION  
  WHEN OTHERS THEN
    ROLLBACK;    
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM); 
END;


