DECLARE

  vr_nrsolici crapprg.NRSOLICI%TYPE;
  vr_nrordprg crapprg.NRORDPRG%TYPE;
  vr_cdcooper crapcop.cdcooper%TYPE := 0;
  
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop c
     WHERE c.FLGATIVO = 1;

  CURSOR cr_crapprg(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT *
      FROM cecred.crapprg p
     WHERE p.CDPROGRA IN ('CRPS576', 'CRPS577', 'CRPS634', 'CRPS627', 'CRPS641', 'CRPS516', 'CRPS280', 'CRPS660', 'CRPS573')
       AND cdcooper = pr_cdcooper
    ORDER BY NRSOLICI, NRORDPRG;
BEGIN

  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.buscarGePorConta';
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.calcularEndividamentoGE';
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.buscarEndividamentoGe';
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.calcularJurosEmprestimo';
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.criarJobJurosEmprestimos';
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.pc_crps573_1_tbrisco';
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.pc_crps573_tbrisco';
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.pc_crps660_tbrisco';
  EXECUTE IMMEDIATE 'DROP PROCEDURE CECRED.PC_CRPS280_I_FABA';
  EXECUTE IMMEDIATE 'DROP PROCEDURE CECRED.PC_CRPS516_FABA';
  EXECUTE IMMEDIATE 'DROP PROCEDURE CECRED.PC_JOB_CENTRALRISCO_OCR_odirlei';
  EXECUTE IMMEDIATE 'DROP PROCEDURE CADASTRO.obterMensagemGrpEcon';
  EXECUTE IMMEDIATE 'DROP PROCEDURE CECRED.gerarRelatoriosContabeisTbriscoRis';
  EXECUTE IMMEDIATE 'DROP PACKAGE CECRED.RISC0004_ODIRLEI';
  EXECUTE IMMEDIATE 'DROP PACKAGE CECRED.RISC0003_ODIRLEI';
  EXECUTE IMMEDIATE 'DROP PACKAGE CECRED.TELA_CONTAS_GRUPO_ECONOMICO';
  EXECUTE IMMEDIATE 'DROP PACKAGE CECRED.GECO0001';
  EXECUTE IMMEDIATE 'DROP PACKAGE CECRED.RISC0001_nova_central';
  
  EXECUTE IMMEDIATE 'DROP TRIGGER CECRED.TRG_CC_GRUPO_ECONOMICO_ID';
  EXECUTE IMMEDIATE 'DROP TRIGGER CECRED.TRG_CC_GRUPO_ECONOMICO_INTEGID';
  EXECUTE IMMEDIATE 'DROP TRIGGER CECRED.TRG_CRAPGRP_PROGRESS_RECID';
  
  UPDATE craptel SET FLGTELBL = 0 WHERE nmdatela = 'FORMGE';
  
  UPDATE crapprm SET dsvlrprm = 1 WHERE cdacesso = 'EXECUTAR_CARGA_CENTRAL';
  
  vr_nmdireto := cecred.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISCO';
  vr_nmarqrbk := 'ROLLBACK_VIRADA_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
  vr_dados_rollback := NULL;

  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     

  cecred.gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    
  FOR rw_crapcop IN cr_crapcop LOOP
    
    vr_nrsolici := 0;
    vr_nrordprg := 0;

    FOR rw_crapprg IN cr_crapprg(pr_cdcooper => rw_crapcop.cdcooper) LOOP
    
      IF vr_nrordprg >= 9 THEN
        vr_nrordprg := 0;
      ELSE
        vr_nrordprg := vr_nrordprg + 1;
      END IF;
      
      vr_nrsolici := TO_NUMBER( '9' || NVL(vr_nrordprg,0) || LPAD(rw_crapprg.nrsolici,3,'0') );

      UPDATE cecred.crapprg p
         SET p.NRSOLICI = vr_nrsolici
           , p.INLIBPRG = 2
       WHERE p.CDCOOPER = rw_crapcop.cdcooper
         AND p.CDPROGRA = rw_crapprg.cdprogra;
         
      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE cecred.crapprg o ' || chr(13) || 
                              '   SET o.NRSOLICI = ' || rw_crapprg.nrsolici || chr(13) ||
                              '      ,o.INLIBPRG = ' || rw_crapprg.inlibprg || chr(13) ||
                              ' WHERE o.CDCOOPER = ' || rw_crapcop.cdcooper || chr(13) ||
                              '   AND o.CDPROGRA = ' || rw_crapprg.cdprogra || chr(13) || ';' || chr(13) || chr(13), FALSE);    
         
    END LOOP;                        
  END LOOP;
  
  gene0002.pc_escreve_xml(vr_dados_rollback
                         ,vr_texto_rollback
                         ,'UPDATE cecred.craptel SET FLGTELBL = 1 WHERE nmdatela = ''FORMGE'';'                 || chr(13) || 
                          'UPDATE cecred.crapprm SET dsvlrprm = 1 WHERE cdacesso = ''EXECUTAR_CARGA_CENTRAL'';' || chr(13) ||
                          'UPDATE cecred.crapprg a SET a.nrsolici = 76, a.inlibprg = 1 WHERE a.nmsistem = ''CRED'' AND a.cdprogra = ''CRPS656'' AND a.cdcooper = 3;' || chr(13) ||
                           chr(13), FALSE);  
  
  cecred.gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT; END;'||chr(13), FALSE);
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
  
  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCONTAB_PROCESSA_CONTABIL');
    sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCENTRALRISCO_OCR');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('Erro no drop JBCONTAB_PROCESSA_CONTABIL: ' || SQLERRM);
  END;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
END;
