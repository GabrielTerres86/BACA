DECLARE
  --
  CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT decode(epr.idfiniof, 1, (epr.vlemprst - nvl(epr.vltarifa,0) - nvl(epr.vliofepr,0)), epr.vlemprst) vlemprst
      FROM crapepr epr 
     WHERE epr.cdcooper = pr_cdcooper 
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  CURSOR cr_principal IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
    FROM   crapepr epr 
    WHERE (epr.cdcooper = 10 AND epr.nrdconta = 39993  AND epr.nrctremp = 31608)
    OR    (epr.cdcooper = 13 AND epr.nrdconta = 512400 AND epr.nrctremp = 142238)
    OR    (epr.cdcooper =  7 AND epr.nrdconta = 112720 AND epr.nrctremp = 62032)
    OR    (epr.cdcooper = 13 AND epr.nrdconta = 396583 AND epr.nrctremp = 138127);
  rw_principal cr_principal%ROWTYPE;  
  
  vr_exc_erro     EXCEPTION;
  
  -- VARIÁVEIS
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg     NUMBER;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(2000);
  
  vr_nrseqdig     NUMBER;
  
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_progress_recid craplcm.progress_recid%TYPE;
  
BEGIN 

  -- Lancamento para INC0102308
  OPEN cr_crapepr(pr_cdcooper => 10
                 ,pr_nrdconta => 39993
                 ,pr_nrctremp => 31608);
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;

  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => 10   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(10).dtmvtolt   -- Data 
                                ,pr_cdagenci => 1             -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 8456          -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => 15   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => rw_crapepr.vlemprst   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE          -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- CRAPLCM - Inserir lançamento referente a taxas cobradas indevidamente
  LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => datascooperativa(10).dtmvtolt
                                    ,pr_cdagenci    => 1
                                    ,pr_cdbccxlt    => 100
                                    ,pr_nrdolote    => 8456
                                    ,pr_nrdconta    => 39993
                                    ,pr_nrdocmto    => vr_nrseqdig
                                    ,pr_cdhistor    => 15
                                    ,pr_nrseqdig    => vr_nrseqdig
                                    ,pr_vllanmto    => rw_crapepr.vlemprst
                                    ,pr_nrdctabb    => 39993
                                    ,pr_nrctachq    => 39993
                                    ,pr_dtrefere    => datascooperativa(10).dtmvtolt
                                    ,pr_hrtransa    => GENE0002.fn_busca_time()
                                    ,pr_cdoperad    => '1' -- Super usuário
                                    ,pr_cdcooper    => 10
                                    ,pr_nrdctitg    => LPAD(39993,8,'0')
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_incrineg    => vr_incrineg
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
  
  -- Se apresentou erro na geração do lançamento
  IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
    RAISE vr_exc_erro;
  END IF;
  
  -----------------------------------------------------------------------------------------------------------------------------------------------

  -- Lancamento para INC0102308
  OPEN cr_crapepr(pr_cdcooper => 13
                 ,pr_nrdconta => 512400
                 ,pr_nrctremp => 142238);
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;
      
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => 13   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(13).dtmvtolt   -- Data 
                                ,pr_cdagenci => 1             -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 8456          -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => 15   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => rw_crapepr.vlemprst   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE          -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- CRAPLCM - Inserir lançamento referente a taxas cobradas indevidamente
  LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => datascooperativa(13).dtmvtolt
                                    ,pr_cdagenci    => 1
                                    ,pr_cdbccxlt    => 100
                                    ,pr_nrdolote    => 8456
                                    ,pr_nrdconta    => 512400
                                    ,pr_nrdocmto    => vr_nrseqdig
                                    ,pr_cdhistor    => 15
                                    ,pr_nrseqdig    => vr_nrseqdig
                                    ,pr_vllanmto    => rw_crapepr.vlemprst
                                    ,pr_nrdctabb    => 512400
                                    ,pr_nrctachq    => 512400
                                    ,pr_dtrefere    => datascooperativa(13).dtmvtolt
                                    ,pr_hrtransa    => GENE0002.fn_busca_time()
                                    ,pr_cdoperad    => '1' -- Super usuário
                                    ,pr_cdcooper    => 13
                                    ,pr_nrdctitg    => LPAD(512400,8,'0')
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_incrineg    => vr_incrineg
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
  
  -- Se apresentou erro na geração do lançamento
  IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
    RAISE vr_exc_erro;
  END IF;
  
  -----------------------------------------------------------------------------------------------------------------------------------------------

  -- Lancamento para INC0102308
  OPEN cr_crapepr(pr_cdcooper => 7
                 ,pr_nrdconta => 112720
                 ,pr_nrctremp => 62032);
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;
      
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => 7   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(7).dtmvtolt   -- Data 
                                ,pr_cdagenci => 1             -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 8456          -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => 15   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => rw_crapepr.vlemprst   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE          -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- CRAPLCM - Inserir lançamento referente a taxas cobradas indevidamente
  LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => datascooperativa(7).dtmvtolt
                                    ,pr_cdagenci    => 1
                                    ,pr_cdbccxlt    => 100
                                    ,pr_nrdolote    => 8456
                                    ,pr_nrdconta    => 112720
                                    ,pr_nrdocmto    => vr_nrseqdig
                                    ,pr_cdhistor    => 15
                                    ,pr_nrseqdig    => vr_nrseqdig
                                    ,pr_vllanmto    => rw_crapepr.vlemprst
                                    ,pr_nrdctabb    => 112720
                                    ,pr_nrctachq    => 112720
                                    ,pr_dtrefere    => datascooperativa(7).dtmvtolt
                                    ,pr_hrtransa    => GENE0002.fn_busca_time()
                                    ,pr_cdoperad    => '1' -- Super usuário
                                    ,pr_cdcooper    => 7
                                    ,pr_nrdctitg    => LPAD(112720,8,'0')
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_incrineg    => vr_incrineg
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
  
  -- Se apresentou erro na geração do lançamento
  IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
    RAISE vr_exc_erro;
  END IF;
  
  -----------------------------------------------------------------------------------------------------------------------------------------------
  
  -- Lancamento para INC0102308
  OPEN cr_crapepr(pr_cdcooper => 13
                 ,pr_nrdconta => 396583
                 ,pr_nrctremp => 138127);
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;
      
  -- Manter o lote do lançamento
  LANC0001.pc_inclui_altera_lote(pr_cdcooper => 13   -- Codigo Cooperativa
                                ,pr_dtmvtolt => datascooperativa(13).dtmvtolt   -- Data 
                                ,pr_cdagenci => 1             -- Codigo Agencia
                                ,pr_cdbccxlt => 100           -- Codigo Caixa
                                ,pr_nrdolote => 8456          -- Numero Lote
                                ,pr_tplotmov => 1             -- Tipo movimento
                                ,pr_cdoperad => '1'           -- Operador
                                ,pr_cdhistor => 15   -- Codigo Historico
                                ,pr_dtmvtopg => NULL          -- Data Pagamento Emprestimo
                                ,pr_vllanmto => rw_crapepr.vlemprst   -- Valor Lancamento
                                ,pr_flgincre => TRUE          -- Incremento
                                ,pr_flgcredi => TRUE          -- Credito
                                ,pr_nrseqdig => vr_nrseqdig   -- Numero Sequencia
                                ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                ,pr_dscritic => vr_dscritic); -- Descricao Erro

  -- Se ocorreu erro
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- CRAPLCM - Inserir lançamento referente a taxas cobradas indevidamente
  LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => datascooperativa(13).dtmvtolt
                                    ,pr_cdagenci    => 1
                                    ,pr_cdbccxlt    => 100
                                    ,pr_nrdolote    => 8456
                                    ,pr_nrdconta    => 396583
                                    ,pr_nrdocmto    => vr_nrseqdig
                                    ,pr_cdhistor    => 15
                                    ,pr_nrseqdig    => vr_nrseqdig
                                    ,pr_vllanmto    => rw_crapepr.vlemprst
                                    ,pr_nrdctabb    => 396583
                                    ,pr_nrctachq    => 396583
                                    ,pr_dtrefere    => datascooperativa(13).dtmvtolt
                                    ,pr_hrtransa    => GENE0002.fn_busca_time()
                                    ,pr_cdoperad    => '1' -- Super usuário
                                    ,pr_cdcooper    => 13
                                    ,pr_nrdctitg    => LPAD(396583,8,'0')
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_incrineg    => vr_incrineg
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
  
  -- Se apresentou erro na geração do lançamento
  IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
    RAISE vr_exc_erro;
  END IF;
  
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0105894'; 
  vr_nmarqbkp := 'ROLLBACK_INC0105894_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  FOR rw_principal IN cr_principal LOOP
    -- grava rollback
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'DELETE FROM craplcm WHERE cdcooper = '||rw_principal.cdcooper||' AND nrdconta = '||rw_principal.nrdconta||' AND cdhistor = 15;' || chr(13), FALSE); 
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
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 

EXCEPTION
  WHEN vr_exc_erro THEN
    -- Se foi retornado apenas código
    IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    ROLLBACK;
    
    -- Retornar erro
    raise_application_error(-20001,vr_dscritic);

  WHEN OTHERS THEN
    ROLLBACK;
    
    -- Retornar erro
    raise_application_error(-20000,'Erro ao incluir lançamentos: '||SQLERRM);
END;
