declare
  vr_nrseqrdr number;
BEGIN

  -- Ajustar opções da tela
  UPDATE craptel tel 
     SET tel.cdopptel = 'I,M,E,D'
        ,tel.lsopptel = 'IMP.SAS,IMP.MAN,EXCLUIR,DETALHES'     
  WHERE upper(tel.nmdatela) = 'IMPPRE';

  -- Remover acessos de opções desativadas
  DELETE crapace ace
   WHERE upper(ace.nmdatela) = 'IMPPRE'
     AND upper(ace.cddopcao) IN('B','L','A');
     
 
    INSERT INTO crapprg
               (cdcooper,
               nmsistem, 
               cdprogra, 
               dsprogra##1, 
               dsprogra##2, 
               dsprogra##3, 
               dsprogra##4, 
               nrsolici, 
               nrordprg, 
               inctrprg, 
               cdrelato##1, 
               cdrelato##2, 
               cdrelato##3, 
               cdrelato##4, 
               cdrelato##5, 
               inlibprg, 
               qtminmed)
    SELECT cop.cdcooper,
           nmsistem, 
           cdprogra, 
           dsprogra##1, 
           dsprogra##2, 
           dsprogra##3, 
           dsprogra##4, 
           994, 
           300, 
           inctrprg, 
           cdrelato##1, 
           cdrelato##2, 
           cdrelato##3, 
           cdrelato##4, 
           cdrelato##5, 
           inlibprg, 
           qtminmed
      FROM crapprg prg, crapcop cop
     WHERE cop.cdcooper <> 3 AND cop.flgativo = 1
       AND prg.cdcooper = 3
       AND prg.cdprogra = 'IMPPRE';     
       
  
      INSERT INTO craptel
           (nmdatela, 
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


  -- Migrar acessos das opções I para M e D   
  INSERT INTO crapace (nmdatela, 
                       cddopcao, 
                       cdoperad, 
                       nmrotina, 
                       cdcooper, 
                       nrmodulo, 
                       idevento, 
                       idambace)
  SELECT ace.nmdatela
        ,'M'
        ,ace.cdoperad
        ,ace.nmrotina
        ,ace.cdcooper
        ,ace.nrmodulo
        ,ace.idevento
        ,ace.idambace
    FROM crapace ace    
   WHERE upper(ace.nmdatela) = 'IMPPRE'
     AND upper(ace.cddopcao) = 'I';

  INSERT INTO crapace(nmdatela, 
                      cddopcao, 
                      cdoperad, 
                      nmrotina, 
                      cdcooper, 
                      nrmodulo, 
                      idevento, 
                      idambace) 
  SELECT ace.nmdatela
        ,'D'
        ,ace.cdoperad
        ,ace.nmrotina
        ,ace.cdcooper
        ,ace.nrmodulo
        ,ace.idevento
        ,ace.idambace
    FROM crapace ace    
   WHERE upper(ace.nmdatela) = 'IMPPRE'
     AND upper(ace.cddopcao) = 'I';   

  -- Buscar RDR da IMPPRE
  SELECT r.nrseqrdr INTO vr_nrseqrdr
    FROM craprdr r
   WHERE r.nmprogra = 'TELA_IMPPRE';

  -- Remover ações que serão desativadas
  DELETE crapaca r
   WHERE r.nrseqrdr = vr_nrseqrdr;

  -- Criar novas ações --    
	INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'LISTA_CARGAS_SAS','TELA_IMPPRE','pc_lista_cargas_sas','');  
	INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'EXEC_CARGA_SAS','TELA_IMPPRE','pc_proc_carga_sas','pr_skcarga,pr_cddopcao,pr_dsrejeicao');  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'EXEC_CARGA_MANUAL','TELA_IMPPRE','pc_proc_carga_manual','pr_tpexecuc,pr_dsdiretor,pr_dsarquivo');               
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'LISTA_DETALHE_CARGAS','TELA_IMPPRE','pc_lista_hist_cargas','pr_cdcooper,pr_tpcarga,pr_indsitua,pr_dtlibera,pr_skcarga,pr_dscarga,pr_tpretorn,pr_nrregist,pr_nriniseq');                              
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'EXEC_EXCLU_MANUAL','TELA_IMPPRE','pc_proc_exclu_manual','pr_tpexecuc,pr_dsdiretor,pr_dsarquivo');               
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'EXEC_BLOQ_CARGA','TELA_IMPPRE','pc_proc_bloq_carga','pr_idcarga');   

  /* Ações desativadas */               
  DELETE 
    FROM crapaca aca
   WHERE aca.nmdeacao IN('ALTERA_CARGA','CONSULTAR_CARGA','CADPRE','GERAR_CARGA','CONSULTA_CARGA_CPA_VIGENTE');
                 
  commit;
end;
