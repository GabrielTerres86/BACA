DECLARE

  CURSOR cr_cop IS
    SELECT cdcooper 
      FROM cecred.crapcop 
     WHERE flgativo = 1;
  rw_cop cr_cop%ROWTYPE;
  
  CURSOR cr_email(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
    SELECT e.dsendereco_email 
      FROM cecred.tbgen_inconsist_email_grp e 
     WHERE e.idinconsist_grp = 5
       AND e.cdcooper = pr_cdcooper;
  rw_email cr_email%ROWTYPE;
  
  vr_idinconsist cecred.tbgen_inconsist_grp.idinconsist_grp%TYPE;
BEGIN
  
  INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) values ('CRED', 0, 'PROCESS_CARTAO_VIP', 'Processa VIP junto com cartoes (1), processar na crps310 (0)', '1');
  
  INSERT INTO cecred.tbgen_inconsist_grp
    (idinconsist_grp,
     nminconsist_grp,
     tpconfig_email,
     dsassunto_email,
     tpperiodicidade_email)
  VALUES
    ((SELECT MAX(idinconsist_grp) + 1 FROM cecred.tbgen_inconsist_grp),
     'Carga de Central de Risco Ailos+',
     2,
     'Erro na carga de Central de Risco',
     1)
  RETURNING idinconsist_grp INTO vr_idinconsist;

  FOR rw_cop IN cr_cop LOOP
    INSERT INTO cecred.tbgen_inconsist_acesso_grp
      (cdcooper, idinconsist_grp, cddepart)
    VALUES
      (rw_cop.cdcooper, vr_idinconsist, 20);
  
    INSERT INTO cecred.tbgen_inconsist_acesso_grp
      (cdcooper, idinconsist_grp, cddepart)
    VALUES
      (rw_cop.cdcooper, vr_idinconsist, 4);
    
    INSERT INTO cecred.tbgen_inconsist_email_grp
      (cdcooper, idinconsist_grp, dsendereco_email)
    VALUES
      (rw_cop.cdcooper, vr_idinconsist, 'recuperacaodecredito@ailos.coop.br');
    
  END LOOP;
  
  COMMIT;

END;
