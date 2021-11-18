PL/SQL Developer Test script 3.0
94
-- Preenche vlsaldo_refinanciado em contratos renegociados com o valor do vsldeved da renegociação
DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
    
  CURSOR cr_tbepr_renegociacao_contrato IS
     SELECT c.cdcooper, c.nrdconta, c.nrctrepr, c.vlsdeved
      FROM tbepr_renegociacao_contrato c, crapepr e, tbepr_renegociacao r
     WHERE c.cdcooper = e.cdcooper
       AND c.nrdconta = e.nrdconta
       AND c.nrctrepr = e.nrctremp
       AND r.cdcooper = c.cdcooper
       AND r.nrdconta = c.nrdconta
       AND e.idquaprc in (3, 4)
       AND e.vlsaldo_refinanciado IS NULL
       AND e.inliquid = 0       
       AND r.dtlibera IS NOT NULL
       ORDER BY c.cdcooper, c.nrdconta, c.nrctrepr, c.nrversao ASC;
  rw_tbepr_renegociacao_contrato cr_tbepr_renegociacao_contrato%ROWTYPE; 
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0104621'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0104621_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'BEGIN' ||chr(13)||chr(13), FALSE);  
  
  FOR rw_tbepr_renegociacao_contrato IN cr_tbepr_renegociacao_contrato LOOP
																		
    -- grava rollback
    gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'UPDATE crapepr SET vlsaldo_refinanciado = NULL WHERE cdcooper = ' || rw_tbepr_renegociacao_contrato.CDCOOPER || ' AND nrdconta = ' || rw_tbepr_renegociacao_contrato.NRDCONTA || ' AND nrctremp = ' || rw_tbepr_renegociacao_contrato.NRCTREPR || ';' ||chr(13)||chr(13), FALSE);

	  RISC0004.pc_gravar_saldo_refin(pr_cdcooper           => rw_tbepr_renegociacao_contrato.CDCOOPER
									                ,pr_nrdconta           => rw_tbepr_renegociacao_contrato.NRDCONTA
                                  ,pr_nrctremp           => rw_tbepr_renegociacao_contrato.NRCTREPR
                                  ,pr_devedor_calculado  => rw_tbepr_renegociacao_contrato.VLSDEVED
                                  ,pr_dscritic           => vr_dscritic);
   
  END LOOP;
  
  -- Adiciona TAG de commit rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;' ||chr(13)||chr(13), FALSE);
  
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'END' ||chr(13), FALSE);  
  
  -- Fecha o arquivo rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             --> Cooperativa conectada
                                     ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                     ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  commit;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao apagar contratos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao apagar contratos - ' || SQLERRM);
END;
