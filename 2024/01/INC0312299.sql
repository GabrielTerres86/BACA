DECLARE
  
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  
  vr_conta       cecred.GENE0002.typ_split;
  vr_reg_conta   cecred.GENE0002.typ_split;
  
  vr_cdcooper cecred.crapcop.cdcooper%TYPE;
  vr_nrdconta cecred.crawepr.nrdconta%TYPE;
  vr_nrctremp cecred.crawepr.nrctremp%TYPE;
  vr_innivris cecred.crawepr.dsnivori%TYPE;
  vr_innivris_rb cecred.crawepr.dsnivori%TYPE;
  vr_progress cecred.crapass.progress_recid%TYPE;
    
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta 
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := cecred.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISCO/INC0312299';
  vr_nmarqrbk := 'ROLLBACK_INC0312299_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
  vr_dados_rollback := NULL;

  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     
  
  vr_conta := cecred.GENE0002.fn_quebra_string(pr_string  => '9;1168063;101031;C;F|'||
                                                             '14;1543491;147433;B;D|'||
                                                             '14;1463605;147776;D;E'
                                                             ,
                                               pr_delimit => '|');
                                             
  IF vr_conta.COUNT > 0 THEN
    FOR vr_idx_lst IN 1 .. vr_conta.COUNT LOOP
      vr_reg_conta := cecred.GENE0002.fn_quebra_string(pr_string  => vr_conta(vr_idx_lst),
                                                       pr_delimit => ';');
  
      vr_cdcooper := vr_reg_conta(1);
      vr_progress := vr_reg_conta(2);
      vr_nrdconta := NULL;
      vr_nrctremp := vr_reg_conta(3);
      vr_innivris := vr_reg_conta(4);
      vr_innivris_rb := vr_reg_conta(5);
      
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_progress => vr_progress);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        vr_nrdconta := rw_crapass.nrdconta;
        UPDATE cecred.tbrisco_operacoes a 
           SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
         WHERE a.cdcooper = vr_cdcooper
           AND a.nrdconta = vr_nrdconta
           AND a.nrctremp = vr_nrctremp
           AND a.tpctrato = 90;
      
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE cecred.tbrisco_operacoes o ' || chr(13) || 
                                '   SET o.inrisco_rating = '|| risc0004.fn_traduz_nivel_risco(vr_innivris_rb) || chr(13) ||
                                ' WHERE o.cdcooper = ' || vr_cdcooper  || chr(13) ||
                                '   AND o.nrdconta = ' || vr_nrdconta  || chr(13) ||
                                '   AND o.nrctremp = ' || vr_nrctremp  || chr(13) ||
                                '   AND o.tpctrato = 90;' ||chr(13)||chr(13), FALSE);    
      END IF;
      CLOSE cr_crapass;
      
    END LOOP;
  END IF;
  
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
