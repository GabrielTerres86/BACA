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

  OPEN cr_crapbat('HABNEUROCONSIG');
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
  
  OPEN cr_crapbat('HABNEURORENEG');
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
  
  OPEN cr_crapbat('HABNEURORENEGPJ');
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
  
  OPEN cr_crapbat('HABNEUROIMOB');
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
  
  OPEN cr_crapbat('HABNEUROIMOBPJ');
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
  VALUES (aux_cdpartar_add, 'HABNEUROCONSIG - Habilita Neurotech para Empréstimo Consignado (S/N)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('HABNEUROCONSIG', 'HABNEUROCONSIG - Habilita Neurotech para Empréstimo Consignado (S/N)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  'N');
  END LOOP;
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM cecred.crappat;
  aux_cdpartar_add := aux_cdpartar_add + 1;
  
  INSERT INTO cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  VALUES (aux_cdpartar_add, 'HABNEURORENEG - Habilita Neurotech para Renegociacao PF (S/N)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('HABNEURORENEG', 'HABNEURORENEG - Habilita Neurotech para Renegociacao PF (S/N)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  'N');
  END LOOP;
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM cecred.crappat;
  aux_cdpartar_add := aux_cdpartar_add + 1;
 
  INSERT INTO cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  VALUES (aux_cdpartar_add, 'HABNEURORENEGPJ - Habilita Neurotech para Renegociacao PJ (S/N)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('HABNEURORENEGPJ', 'HABNEURORENEGPJ - Habilita Neurotech para Renegociacao PJ (S/N)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  'N');
  END LOOP;
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM cecred.crappat;
  aux_cdpartar_add := aux_cdpartar_add + 1;

  INSERT INTO cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  VALUES (aux_cdpartar_add, 'HABNEUROIMOB - Habilita Neurotech para Imobiliario PF (S/N)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('HABNEUROIMOB', 'HABNEUROIMOB - Habilita Neurotech para Imobiliario PF (S/N)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  'N');
  END LOOP;
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM cecred.crappat;
  aux_cdpartar_add := aux_cdpartar_add + 1;

  INSERT INTO cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  VALUES (aux_cdpartar_add, 'HABNEUROIMOBPJ - Habilita Neurotech para Imobiliario PJ (S/N)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('HABNEUROIMOBPJ', 'HABNEUROIMOBPJ - Habilita Neurotech para Imobiliario PJ (S/N)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  'N');
  END LOOP;
  
  COMMIT;

EXCEPTION  
  WHEN OTHERS THEN
    ROLLBACK;    
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM); 
END;