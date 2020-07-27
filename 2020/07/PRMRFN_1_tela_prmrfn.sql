-- Created on 15/07/2020 by T0032717 
declare 
  vr_nrsolici crapprg.NRSOLICI%TYPE;
  vr_nrordprg crapprg.NRORDPRG%TYPE;
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
begin
  --RDR
  insert into craprdr (NMPROGRA, DTSOLICI)
  values ('TELA_PRMRFN', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('BUSCA_CONTAS_PRMRFN',
     NULL,
     'CREDITO.obterDadosConsultaPrmrfnWeb',
     'pr_containi,pr_contafim',
     vr_nrseqrdr);

  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('HAB_CONTA_PRMRFN',
     NULL,
     'CREDITO.inserirParamRefinContaWeb',
     'pr_nrdconta,pr_dsjustif',
     vr_nrseqrdr);

  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('DES_CONTA_PRMRFN',
     NULL,
     'CREDITO.excluirParamRefinContaWeb',
     'pr_nrdconta',
     vr_nrseqrdr);
     
  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('VALIDA_CONTA_PRMRFN',
     NULL,
     'CREDITO.validarParamRefinContaWeb',
     'pr_nrdconta',
     vr_nrseqrdr);
     
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop WHERE flgativo = 1) LOOP
    -- TEL
    insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
    values ('PRMRFN', 10, '@', 'CONTAS QUE NAO DEVEM VALIDAR ATRASO PARA REFIN', 'PRM. RFN.', 0, 1, ' ', 'ACESSO', 1, rw_crapcop.cdcooper, 1, 0, 1, 1, ' ', 2);
    
    SELECT MAX(NRSOLICI), MAX(NRORDPRG)
    INTO vr_nrsolici, vr_nrordprg
    FROM crapprg WHERE cdcooper = rw_crapcop.cdcooper ;
    
    vr_nrsolici := vr_nrsolici + 1;
    vr_nrordprg := vr_nrordprg + 1;
    
    --PRG
    insert into CRAPPRG (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
    values ('CRED', 'PRMRFN', 'CONTAS QUE NAO DEVEM VALIDAR ATRASO PARA REFIN', ' ', ' ', ' ', vr_nrsolici, vr_nrordprg, 1, 0, 0, 0, 0, 0, 1, rw_crapcop.cdcooper, null);
  END LOOP;
  COMMIT;
END;
