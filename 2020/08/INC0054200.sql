DECLARE
  CURSOR cr_crapepr IS
    SELECT e.cdcooper
          ,e.nrdconta
          ,e.nrctremp
      FROM crapepr e
     WHERE e.vlsdevat = 0
       AND e.inprejuz = 1
       AND e.inliquid = 0;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                            ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);      
    BEGIN
        -- Primeiro garantimos que o diretorio exista
        IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN

          -- Efetuar a criação do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

          -- Adicionar permissão total na pasta
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

        END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;    
  END;   
BEGIN
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas'
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas/INC0054200'
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0054200'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0054200_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
  FOR rw_crapepr IN cr_crapepr LOOP
    UPDATE crapepr 
       SET inliquid = 1
     WHERE cdcooper = rw_crapepr.cdcooper
       AND nrdconta = rw_crapepr.nrdconta
       AND nrctremp = rw_crapepr.nrctremp;
    
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'UPDATE crapepr ' || chr(13) || 
                            '   SET inliquid = 0' ||
                            ' WHERE cdcooper = ' || rw_crapepr.cdcooper || chr(13) ||
                            '   AND nrdconta = ' || rw_crapepr.nrdconta || chr(13) ||
                            '   AND nrctremp = ' || rw_crapepr.nrctremp || '; ' ||chr(13)||chr(13), FALSE);     
    
  END LOOP;  
  -- Adiciona TAG de commit rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
        
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
    raise_application_error(-20100, 'Erro ao atualizar liquidacao de contratos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao atualizar liquidacao de contratos - ' || SQLERRM);
END;
