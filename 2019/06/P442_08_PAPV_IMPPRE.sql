declare
  vr_nrseqrdr number;
  idx PLS_INTEGER := 1;
  
  CURSOR cr_busca_cad(pr_cdcooper IN NUMBER) IS
    SELECT cdcooper
    FROM crapprg
    WHERE cdprogra = UPPER('imppre')
      AND cdcooper = pr_cdcooper;
  rw_busca_cad cr_busca_cad%ROWTYPE;
  
BEGIN
  -- Ajustar opções da tela
  UPDATE craptel tel 
  SET tel.cdopptel = 'I,L,E,D'
        ,tel.lsopptel = 'IMP.SAS,IMP.MAN,EXCLUIR,DETALHES'     
  WHERE upper(tel.nmdatela) = 'IMPPRE';

  -- Remover acessos de opções desativadas
  DELETE crapace ace
  WHERE upper(ace.nmdatela) = 'IMPPRE'
    AND upper(ace.cddopcao) IN('B','L','A', 'M');
     
  WHILE idx <= 17 LOOP
    OPEN cr_busca_cad(pr_cdcooper => idx);
    FETCH cr_busca_cad INTO rw_busca_cad;
    
    IF cr_busca_cad%NOTFOUND THEN
      INSERT INTO crapprg(nmsistem
                ,cdprogra
                ,dsprogra##1
                ,nrsolici
                ,nrordprg
                ,inctrprg
                ,cdrelato##1
                ,cdrelato##2
                ,cdrelato##3
                ,cdrelato##4
                ,cdrelato##5
                ,inlibprg
                ,cdcooper)
        VALUES('CRED'
          ,'IMPPRE'
          ,'CRIACAO E IMPORTACAO DE CARGAS MANUAIS'
          ,994
          ,300
          ,1
          ,0
          ,0
          ,0
          ,0
          ,0
          ,1
          ,idx);
    END IF;
    
    CLOSE cr_busca_cad;
    
    idx := idx + 1;
  END LOOP; 
  
  BEGIN
    INSERT INTO craptel(nmdatela, 
            nrmodulo, 
            cdopptel, 
            tldatela, 
            tlrestel, 
            flgteldf, 
            flgtelbl, 
            nmrotina, 
            lsopptel, 
            inacesso, 
            cdcooper, 
            idsistem, 
            idevento, 
            nrordrot, 
            nrdnivel, 
            nmrotpai, 
            idambtel)
    SELECT nmdatela, 
        nrmodulo, 
        cdopptel, 
        tldatela, 
        tlrestel, 
        flgteldf, 
        flgtelbl, 
        nmrotina, 
        lsopptel, 
        inacesso, 
        cop.cdcooper, 
        idsistem, 
        idevento, 
        nrordrot, 
        nrdnivel, 
        nmrotpai, 
        idambtel
    FROM craptel tel, crapcop cop
    WHERE cop.cdcooper <> 3 AND cop.flgativo = 1
      AND tel.cdcooper = 3
      AND tel.nmdatela = 'IMPPRE';  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;   

  -- Buscar RDR da IMPPRE
  SELECT r.nrseqrdr INTO vr_nrseqrdr
    FROM craprdr r
  WHERE r.nmprogra = 'TELA_IMPPRE';

  -- Remover ações que serão desativadas
  DELETE crapaca r
  WHERE r.nrseqrdr = vr_nrseqrdr;

  -- Criar novas ações --    
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
    VALUES(vr_nrseqrdr, 'LISTA_CARGAS_SAS','TELA_IMPPRE','pc_lista_cargas_sas','pr_nrregist,pr_nriniseq'); 
    
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
    VALUES(vr_nrseqrdr, 'EXEC_CARGA_SAS','TELA_IMPPRE','pc_proc_carga_sas','pr_skcarga,pr_cddopcao,pr_dsrejeicao');  
  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
    VALUES(vr_nrseqrdr, 'EXEC_CARGA_MANUAL','TELA_IMPPRE','pc_proc_carga_manual','pr_tpexecuc,pr_dsdiretor,pr_dsarquivo');               
  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
    VALUES(vr_nrseqrdr, 'LISTA_DETALHE_CARGAS','TELA_IMPPRE','pc_lista_hist_cargas','pr_cdcooper,pr_idcarga,pr_tpcarga,pr_indsitua,pr_dtlibera,pr_dtliberafim,pr_dtvigencia,pr_dtvigenciafim,pr_skcarga,pr_dscarga,pr_tpretorn,pr_nrregist,pr_nriniseq');  
  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
    VALUES(vr_nrseqrdr, 'EXEC_EXCLU_MANUAL','TELA_IMPPRE','pc_proc_exclu_manual','pr_tpexecuc,pr_dsdiretor,pr_dsarquivo');               
  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
    VALUES(vr_nrseqrdr, 'EXEC_BLOQ_CARGA','TELA_IMPPRE','pc_proc_bloq_carga','pr_idcarga');   

  /* Ações desativadas */               
  DELETE FROM crapaca aca
  WHERE aca.nmdeacao IN('ALTERA_CARGA','CONSULTAR_CARGA','CADPRE','GERAR_CARGA','CONSULTA_CARGA_CPA_VIGENTE');
                 
  /* Gerar permissões para os usuários */
  FOR rw_ope IN (SELECT ope.cdcooper
                       ,ope.cdoperad 
                   FROM crapope ope 
                 WHERE ope.cdsitope = 1) LOOP
    BEGIN
      IF rw_ope.cdcooper = 3 THEN
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
        VALUES ('IMPPRE', 'I', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    BEGIN
      INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
      VALUES ('IMPPRE', 'L', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    BEGIN
      INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
      VALUES ('IMPPRE', 'D', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    BEGIN
      INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
      VALUES ('IMPPRE', 'E', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
  
  COMMIT;
end;