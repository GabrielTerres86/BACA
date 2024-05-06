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
  
  aux_cdacesso  crapprm.cdacesso%TYPE;
  vr_existeprm	NUMBER;
  
BEGIN

  OPEN cr_crapbat('VERAPIGRVMB3');
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
  VALUES (aux_cdpartar_add, 'VERAPIGRVMB3 - Versão API SOA Gravames (1 = v1 / 2 = v2)', 2, 13);

  INSERT INTO cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  VALUES ('VERAPIGRVMB3', 'VERAPIGRVMB3 - Versão API SOA Gravames (1 = v1 / 2 = v2)', ' ', 2, aux_cdpartar_add);
 
  FOR rw_crapdat IN cr_crapdat LOOP
    INSERT INTO cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
    VALUES (aux_cdpartar_add, rw_crapdat.cdcooper,  '1');
  END LOOP;
  
  aux_cdacesso := 'URI_ALIENA_GRAVAME_V2';

  SELECT COUNT(1)
  INTO   vr_existeprm
  FROM   CECRED.CRAPPRM
  WHERE  CDACESSO = aux_cdacesso
  AND    NMSISTEM = 'CRED';
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND NMSISTEM = 'CRED';
	COMMIT;
  
  END IF;
  
  INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'URI v2 para Alienação do GRAVAME','/osb-soa/GarantiaVeiculoRestService/v2/EfetivarAlienacaoGravames');

  aux_cdacesso := 'URI_CANCELA_GRAVAME_V2';

  SELECT COUNT(1)
  INTO   vr_existeprm
  FROM   CECRED.CRAPPRM
  WHERE  CDACESSO = aux_cdacesso
  AND    NMSISTEM = 'CRED';
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND NMSISTEM = 'CRED';
	COMMIT;
  
  END IF;
  
  INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'URI v2 para Cancelamento do GRAVAME','/osb-soa/GarantiaVeiculoRestService/v2/EfetivarCancelamentoGravames');
  
  aux_cdacesso := 'URI_BAIXA_GRAVAME_V2';

  SELECT COUNT(1)
  INTO   vr_existeprm
  FROM   CECRED.CRAPPRM
  WHERE  CDACESSO = aux_cdacesso
  AND    NMSISTEM = 'CRED';
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND NMSISTEM = 'CRED';
	COMMIT;
  
  END IF;
  
  INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'URI v2 para Baixa do GRAVAME','/osb-soa/GarantiaVeiculoRestService/v2/EfetivarDesalienacaoGravames');
  
  aux_cdacesso := 'URI_CONSULTA_GRAVAME_V2';

  SELECT COUNT(1)
  INTO   vr_existeprm
  FROM   CECRED.CRAPPRM
  WHERE  CDACESSO = aux_cdacesso
  AND    NMSISTEM = 'CRED';
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND NMSISTEM = 'CRED';
	COMMIT;
  
  END IF;
  
  INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'URI v2 para Consulta do GRAVAME','/osb-soa/GarantiaVeiculoRestService/v2/ObterSituacaoGravames'); 
  
  COMMIT;

EXCEPTION  
  WHEN OTHERS THEN
    ROLLBACK;    
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM); 
END;