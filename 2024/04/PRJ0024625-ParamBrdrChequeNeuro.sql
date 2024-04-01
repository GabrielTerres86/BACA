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
     
  rw_crapbat cr_crapbat%ROWTYPE;
  rw_crapdat cr_crapdat%ROWTYPE;
  aux_cdpartar_add  crappat.cdpartar%TYPE;
  aux_cdpartar_del  crappat.cdpartar%TYPE;
  
BEGIN
  
  OPEN cr_crapbat('HABNEUROBDRCHQF');
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
  VALUES (aux_cdpartar_add, 'HABNEUROBDRCHQPF - Habilita Neurotech para Bordero Cheque PF (S/N)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('HABNEUROBDRCHQF', 'HABNEUROBDRCHQPF - Habilita Neurotech para Bordero Cheque PF (S/N)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  'N');
  END LOOP;  
  
  OPEN cr_crapbat('HABNEUROBDRCHQJ');
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
  VALUES (aux_cdpartar_add, 'HABNEUROBDRCHQPJ - Habilita Neurotech para Bordero Cheque PJ (S/N)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('HABNEUROBDRCHQJ', 'HABNEUROBDRCHQPJ - Habilita Neurotech para Bordero Cheque PJ (S/N)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  'N');
  END LOOP;  
  
  OPEN cr_crapbat('NOVOIDPROD_BC');
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
  VALUES (aux_cdpartar_add, 'NOVOIDPRODUTO_BC - Bordero Cheque', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('NOVOIDPROD_BC', 'NOVOIDPRODUTO_BC - Bordero Cheque', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  '21');
  END LOOP;
  
  COMMIT;

EXCEPTION  
  WHEN OTHERS THEN
    ROLLBACK;    
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM); 
END;