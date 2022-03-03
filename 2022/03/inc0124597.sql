DECLARE
  CURSOR cr_principal IS
    SELECT e.cdcooper, e.nrdconta, e.nrctremp, e.vlsdeved
      FROM crapepr e, crapass a 
     WHERE e.cdcooper = a.cdcooper
       AND e.nrdconta = a.nrdconta 
       AND e.cdcooper = 9
       AND e.inliquid = 0
       AND a.cdagenci = 28
       AND e.vlsdeved > e.vlsdevat
       AND e.tpemprst = 1;
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_devedor(pr_cdcooper INTEGER
                   ,pr_nrdconta INTEGER
                   ,pr_nrctremp INTEGER) IS
    SELECT SUM(p.vlsdvatu) vlsdvatu
      FROM crappep p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp
       AND p.inliquid = 0;
  
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(2000);
  vr_exc_erro     EXCEPTION;
    
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  
  vr_vlsdvatu crappep.vlsdvatu%TYPE;
BEGIN 
  
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0124597'; 
  vr_nmarqbkp := 'ROLLBACK_INC0124597_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  FOR rw_principal IN cr_principal LOOP
    OPEN cr_devedor(pr_cdcooper => rw_principal.cdcooper
                   ,pr_nrdconta => rw_principal.nrdconta
                   ,pr_nrctremp => rw_principal.nrctremp);
    FETCH cr_devedor INTO vr_vlsdvatu;
    CLOSE cr_devedor;
    
    UPDATE crapepr SET vlsdeved = nvl(vr_vlsdvatu, 0) WHERE cdcooper = rw_principal.cdcooper AND nrdconta = rw_principal.nrdconta AND nrctremp = rw_principal.nrctremp;
    
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'UPDATE crapepr ' || chr(13) || 
                          '     SET vlsdeved = ' || REPLACE(rw_principal.vlsdeved, ',', '.') || chr(13) ||
                          '   WHERE cdcooper = ' || rw_principal.cdcooper || chr(13) ||
                          '     AND nrdconta = ' || rw_principal.nrdconta || chr(13) ||
                          '     AND nrctremp = ' || rw_principal.nrctremp || '; ' ||chr(13)||chr(13), FALSE); 
  END LOOP;
  
  
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
  
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             
                                     ,pr_cdprogra  => 'ATENDA'                      
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                
                                     ,pr_dsxml     => vr_dados_rollback             
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp 
                                     ,pr_flg_impri => 'N'                           
                                     ,pr_flg_gerar => 'S'                           
                                     ,pr_flgremarq => 'N'                           
                                     ,pr_nrcopias  => 1                             
                                     ,pr_des_erro  => vr_dscritic);                 
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
EXCEPTION
  WHEN vr_exc_erro THEN

    IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN

      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    ROLLBACK;
    
    raise_application_error(-20001,vr_dscritic);

  WHEN OTHERS THEN
    ROLLBACK;
    
    raise_application_error(-20000,'Erro ao incluir lançamentos: '||SQLERRM);
end;
