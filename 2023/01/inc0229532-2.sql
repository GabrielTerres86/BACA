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
  
  vr_nmdireto := cecred.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0229532';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    vr_nmarqrbk := 'ROLLBACK_'||rw_crapcop.nmrescop||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
    vr_dados_rollback := NULL;

    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     

    cecred.gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Programa para rollback das informacoes'||chr(13), FALSE);
    
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      OPEN cr_crapepr(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_nrdconta => rw_principal.nrdconta
                     ,pr_nrctremp => rw_principal.nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      IF cr_crapepr%FOUND THEN
        vr_inrisco_refin := rw_crapepr.inrisco_refin;
        CLOSE cr_crapepr;
      ELSE
        CLOSE cr_crapepr;
        CONTINUE;
      END IF;
      
      BEGIN 
        UPDATE cecred.crapepr 
           SET inrisco_refin = rw_principal.inrisco_acordo 
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrdconta = rw_principal.nrdconta
           AND nrctremp = rw_principal.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar cecred.crapepr - Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || SQLERRM);
      END;
      
      cecred.gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE cecred.crapepr e ' || chr(13) || 
                              '   SET e.inrisco_refin = '|| vr_inrisco_refin || chr(13) ||
                              ' WHERE e.cdcooper = ' || rw_crapcop.cdcooper  || chr(13) ||
                              '   AND e.nrdconta = ' || rw_principal.nrdconta  || chr(13) ||
                              '   AND e.nrctremp = ' || rw_principal.nrctremp  || ';' ||chr(13)||chr(13), FALSE);    

    END LOOP;
    
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
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);    
END;
