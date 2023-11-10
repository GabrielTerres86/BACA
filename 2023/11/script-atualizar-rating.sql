DECLARE
  
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nr_regs        INTEGER := 0;

  vr_inrisco_refin cecred.crapepr.inrisco_refin%TYPE;
  
  vr_cdcooper cecred.crapcop.cdcooper%TYPE;
  vr_nrdconta cecred.crawepr.nrdconta%TYPE;
  vr_nrctremp cecred.crawepr.nrctremp%TYPE;
  vr_innivris cecred.crawepr.dsnivori%TYPE;
  vr_progress cecred.crapass.progress_recid%TYPE;
    
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta 
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper, c.nmrescop
      FROM cecred.crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN INTEGER) IS
    SELECT o.nrdconta, o.nrctremp, c.inrisco_acordo
      FROM cecred.tbrecup_acordo a 
          ,cecred.tbrecup_acordo_contrato c 
          ,cecred.crapepr e
          ,cecred.crapdat d
          ,cecred.tbrisco_central_ocr o
     WHERE a.cdcooper = pr_cdcooper
       AND c.nracordo = a.nracordo
       AND e.cdcooper = a.cdcooper
       AND e.nrdconta = a.nrdconta
       AND e.nrctremp = c.nrctremp
       AND d.cdcooper = a.cdcooper
       AND o.cdcooper = a.cdcooper
       AND o.nrdconta = a.nrdconta
       AND o.nrctremp = c.nrctremp
       AND a.cdsituacao = 1
       AND c.inrisco_acordo <> e.inrisco_refin
       AND c.inrisco_acordo < 10
       AND o.dtrefere = d.dtmvcentral
       AND o.inrisco_melhora IS NULL;
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_crapepr(pr_cdcooper IN INTEGER
                   ,pr_nrdconta IN INTEGER
                   ,pr_nrctremp IN INTEGER) IS
    SELECT e.inrisco_refin
      FROM cecred.crapepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := cecred.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0294149';
  vr_nmarqrbk := 'ROLLBACK_INC0294149_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
  vr_dados_rollback := NULL;

  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     
  
  vr_cdcooper := 14;
  vr_nrdconta := NULL;
  vr_nrctremp := 129413;
  vr_innivris := 'C';
  vr_progress := 1721353;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    vr_nrdconta := rw_crapass.nrdconta;
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris),
           a.inrisco_inclusao = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.tbrisco_operacoes o ' || chr(13) || 
                            '   SET o.inrisco_rating = '|| risc0004.fn_traduz_nivel_risco('E') || chr(13) ||
                            '      ,o.inrisco_inclusao = '|| risc0004.fn_traduz_nivel_risco('C') || chr(13) ||
                            ' WHERE o.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND o.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND o.nrctremp = ' || vr_nrctremp  || chr(13) ||
                            '   AND o.tpctrato = 90;' ||chr(13)||chr(13), FALSE);    
    
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.crawepr e ' || chr(13) || 
                            '   SET e.dsnivori = ''E'''|| chr(13) ||
                            ' WHERE e.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND e.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND e.nrctremp = ' || vr_nrctremp  || ';' ||chr(13)||chr(13), FALSE);   
  END IF;
  CLOSE cr_crapass;
  
  vr_cdcooper := 13;
  vr_nrdconta := NULL;
  vr_nrctremp := 312314;
  vr_innivris := 'C';
  vr_progress := 1727740;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    vr_nrdconta := rw_crapass.nrdconta;
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
          ,a.inrisco_inclusao = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.tbrisco_operacoes o ' || chr(13) || 
                            '   SET o.inrisco_rating = '|| risc0004.fn_traduz_nivel_risco('F') || chr(13) ||
                            '      ,o.inrisco_inclusao = '|| risc0004.fn_traduz_nivel_risco('C') || chr(13) ||
                            ' WHERE o.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND o.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND o.nrctremp = ' || vr_nrctremp  || chr(13) ||
                            '   AND o.tpctrato = 90;' ||chr(13)||chr(13), FALSE);    
    
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.crawepr e ' || chr(13) || 
                            '   SET e.dsnivori = ''F'''|| chr(13) ||
                            ' WHERE e.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND e.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND e.nrctremp = ' || vr_nrctremp  || ';' ||chr(13)||chr(13), FALSE);   
  END IF;
  CLOSE cr_crapass;
  
  vr_cdcooper := 13;
  vr_nrdconta := NULL;
  vr_nrctremp := 316167;
  vr_innivris := 'B';
  vr_progress := 598054;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    vr_nrdconta := rw_crapass.nrdconta;
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
          ,a.inrisco_inclusao = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.tbrisco_operacoes o ' || chr(13) || 
                            '   SET o.inrisco_rating = '|| risc0004.fn_traduz_nivel_risco('C') || chr(13) ||
                            '      ,o.inrisco_inclusao = '|| risc0004.fn_traduz_nivel_risco('A') || chr(13) ||
                            ' WHERE o.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND o.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND o.nrctremp = ' || vr_nrctremp  || chr(13) ||
                            '   AND o.tpctrato = 90;' ||chr(13)||chr(13), FALSE);    
    
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.crawepr e ' || chr(13) || 
                            '   SET e.dsnivori = ''C'''|| chr(13) ||
                            ' WHERE e.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND e.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND e.nrctremp = ' || vr_nrctremp  || ';' ||chr(13)||chr(13), FALSE);   
  END IF;
  CLOSE cr_crapass;
  
  vr_cdcooper := 1;
  vr_nrdconta := NULL;
  vr_nrctremp := 7248967;
  vr_innivris := 'A';
  vr_progress := 24068;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    vr_nrdconta := rw_crapass.nrdconta;
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
          ,a.inrisco_inclusao = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.tbrisco_operacoes o ' || chr(13) || 
                            '   SET o.inrisco_rating = '|| risc0004.fn_traduz_nivel_risco('E') || chr(13) ||
                            '      ,o.inrisco_inclusao = '|| risc0004.fn_traduz_nivel_risco('E') || chr(13) ||
                            ' WHERE o.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND o.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND o.nrctremp = ' || vr_nrctremp  || chr(13) ||
                            '   AND o.tpctrato = 90;' ||chr(13)||chr(13), FALSE);    
    
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE cecred.crawepr e ' || chr(13) || 
                            '   SET e.dsnivori = ''E'''|| chr(13) ||
                            ' WHERE e.cdcooper = ' || vr_cdcooper  || chr(13) ||
                            '   AND e.nrdconta = ' || vr_nrdconta  || chr(13) ||
                            '   AND e.nrctremp = ' || vr_nrctremp  || ';' ||chr(13)||chr(13), FALSE);   
  END IF;
  CLOSE cr_crapass;
  
  cecred.gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  cecred.gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
               
  cecred.GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             
                                            ,pr_cdprogra  => 'ATENDA'                      
                                            ,pr_dtmvtolt  => trunc(SYSDATE)                
                                            ,pr_dsxml     => vr_dados_rollback             
                                            ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqrbk 
                                            ,pr_flg_impri => 'N'                           
                                            ,pr_flg_gerar => 'S'                           
                                            ,pr_flgremarq => 'N'                           
                                            ,pr_nrcopias  => 1                             
                                            ,pr_des_erro  => vr_dscritic);                 
          
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
    
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);    
END;
