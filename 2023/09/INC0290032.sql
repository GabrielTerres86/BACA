DECLARE
  
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nr_regs        INTEGER := 0;
  
  vr_conta       cecred.GENE0002.typ_split;
  vr_reg_conta   cecred.GENE0002.typ_split;

  vr_cdcooper cecred.crapcop.cdcooper%TYPE;
  vr_nrdconta cecred.crawepr.nrdconta%TYPE;
  vr_nrctremp cecred.crawepr.nrctremp%TYPE;
  vr_innivris cecred.crawepr.dsnivori%TYPE;
  vr_progress cecred.crapass.progress_recid%TYPE;
  vr_tpctrato cecred.tbrisco_operacoes.tpctrato%TYPE;
    
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
  
  CURSOR cr_rollback(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                    ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE
                    ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
    SELECT a.inrisco_inclusao, w.dsnivori, a.tpctrato, a.nrdconta, a.nrctremp
      FROM cecred.tbrisco_operacoes a 
         , cecred.crawepr w
     WHERE w.cdcooper(+) = a.cdcooper
       AND w.nrdconta(+) = a.nrdconta
       AND w.nrctremp(+) = a.nrctremp
       AND a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND a.nrctremp = pr_nrctremp;
  rw_rollback cr_rollback%ROWTYPE;
           
BEGIN
  
  vr_nmdireto := cecred.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISCO';
  vr_nmarqrbk := 'ROLLBACK_INC0290032_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
  vr_dados_rollback := NULL;

  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     
  
  vr_conta := cecred.GENE0002.fn_quebra_string(pr_string  => '3;1609147;100144;A|' ||
                                                             '3;1565151;100117;A|' ||
                                                             '3;1496022;100077;A|' ||
                                                             '3;435876;211426;A|' ||
                                                             '3;435876;211488;A|' ||
                                                             '3;435876;211487;A|' ||
                                                             '3;435876;211491;A|' ||
                                                             '3;435876;211472;A|' ||
                                                             '3;435876;211506;A|' ||
                                                             '3;435876;211489;A|' ||
                                                             '3;435876;210183;A|' ||
                                                             '3;435876;210145;A|' ||
                                                             '3;435876;211514;A|' ||
                                                             '3;435876;211532;A|' ||
                                                             '3;435876;210332;A|' ||
                                                             '3;435876;210297;A|' ||
                                                             '3;435876;211490;A|' ||
                                                             '3;435876;210318;A|' ||
                                                             '3;1924508;100107;A|' ||
                                                             '3;1807561;100146;A|' ||
                                                             '3;1491303;100076;A|' ||
                                                             '3;435878;211503;A|' ||
                                                             '3;435878;211052;A|' ||
                                                             '3;435878;210319;A|' ||
                                                             '3;435878;210328;A|' ||
                                                             '3;435878;210583;A|' ||
                                                             '3;435878;210300;A|' ||
                                                             '3;435878;211209;A|',
                                               pr_delimit => '|');
  
  IF vr_conta.COUNT > 0 THEN
    FOR vr_idx_lst IN 1 .. vr_conta.COUNT - 1 LOOP
      vr_reg_conta := cecred.GENE0002.fn_quebra_string(pr_string  => vr_conta(vr_idx_lst),
                                                       pr_delimit => ';');
                                                       
      vr_nrdconta := NULL;
      vr_cdcooper := vr_reg_conta(1);
      vr_progress := vr_reg_conta(2);
      vr_nrctremp := vr_reg_conta(3);
      vr_innivris := vr_reg_conta(4);
      
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_progress => vr_progress);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        vr_nrdconta := rw_crapass.nrdconta;
        
        OPEN cr_rollback(pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => vr_nrdconta
                        ,pr_nrctremp => vr_nrctremp);
        FETCH cr_rollback INTO rw_rollback;
        vr_tpctrato := rw_rollback.tpctrato;
        CLOSE cr_rollback;
        
        UPDATE cecred.tbrisco_operacoes a 
           SET a.inrisco_inclusao = risc0004.fn_traduz_nivel_risco(vr_innivris)
         WHERE a.cdcooper = vr_cdcooper
           AND a.nrdconta = rw_crapass.nrdconta
           AND a.nrctremp = vr_nrctremp
           AND a.tpctrato = vr_tpctrato;

        IF vr_tpctrato = 90 THEN
          UPDATE cecred.crawepr e
             SET e.dsnivori = vr_innivris
           WHERE e.cdcooper = vr_cdcooper
             AND e.nrdconta = rw_crapass.nrdconta 
             AND e.nrctremp = vr_nrctremp;
        END IF;

        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE cecred.tbrisco_operacoes o ' || chr(13) || 
                                '   SET o.inrisco_inclusao = '|| rw_rollback.inrisco_inclusao || chr(13) ||
                                ' WHERE o.cdcooper = ' || vr_cdcooper  || chr(13) ||
                                '   AND o.nrdconta = ' || vr_nrdconta  || chr(13) ||
                                '   AND o.nrctremp = ' || vr_nrctremp  || chr(13) ||
                                '   AND o.tpctrato = 90;' ||chr(13)||chr(13), FALSE);    
        
        IF vr_tpctrato = 90 THEN
          gene0002.pc_escreve_xml(vr_dados_rollback
                                 ,vr_texto_rollback
                                 ,'UPDATE cecred.crawepr e ' || chr(13) || 
                                  '   SET e.dsnivori = ' || rw_rollback.dsnivori || chr(13) ||
                                  ' WHERE e.cdcooper = ' || vr_cdcooper  || chr(13) ||
                                  '   AND e.nrdconta = ' || vr_nrdconta  || chr(13) ||
                                  '   AND e.nrctremp = ' || vr_nrctremp  || ';' ||chr(13)||chr(13), FALSE);   
        END IF;
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
