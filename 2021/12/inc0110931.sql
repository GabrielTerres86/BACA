-- Created on 07/12/2021 by T0032717 
DECLARE
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  
  vr_idcobert  tbgar_cobertura_operacao.idcobertura%TYPE;
  vr_idcobope  crawepr.idcobope%TYPE;
  vr_vlresgat  NUMBER;
  vr_nrcpfcnpj NUMBER;
  vr_qtdiaatr  NUMBER;
  
  --Registro tipo Data
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
  CURSOR cr_principal IS
    SELECT c.cdcooper, c.nrdconta, c.nrctrepr, x.vlsdeved
      FROM tbepr_renegociacao r, tbepr_renegociacao_contrato c, tbepr_renegociacao_crawepr w, crapepr x
     WHERE c.cdcooper = r.cdcooper
       AND c.nrdconta = r.nrdconta
       AND c.nrctremp = r.nrctremp
       AND w.cdcooper = c.cdcooper
       AND w.nrdconta = c.nrdconta
       AND w.nrctremp = c.nrctrepr
       AND w.nrversao = c.nrversao
       AND x.cdcooper = w.cdcooper
       AND x.nrdconta = w.nrdconta
       AND x.nrctremp = w.nrctremp
       AND c.nrctremp_novo = 0
       AND w.idcobope > 0 
       AND idcobefe > 0
       AND x.inliquid = 0 
       AND x.inprejuz = 0
       AND NOT EXISTS (SELECT 1 
                         FROM tbgar_cobertura_operacao o 
                        WHERE o.cdcooper   = x.cdcooper
                          AND o.nrdconta   = x.nrdconta 
                          AND o.nrcontrato = x.nrctremp)
       -- olhar n�o liquidados
     ORDER BY c.cdcooper, c.nrdconta, c.nrctrepr, c.nrversao ASC;
  rw_principal cr_principal%ROWTYPE;

BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0110931'; 
  vr_nmarqbkp := 'ROLLBACK_INC0110931_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  FOR rw_principal IN cr_principal LOOP
    
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_principal.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
  
    INSERT INTO tbgar_cobertura_operacao
         (cdcooper
         ,nrdconta
         ,tpcontrato
         ,nrcontrato
         ,insituacao
         ,perminimo
         ,inaplicacao_propria
         ,inpoupanca_propria
         ,nrconta_terceiro
         ,inaplicacao_terceiro
         ,inpoupanca_terceiro
         ,inresgate_automatico
         ,qtdias_atraso_permitido)
    VALUES
         (rw_principal.cdcooper
         ,rw_principal.nrdconta
         ,90 -- tipo: emprestimo
         ,rw_principal.nrctrepr
         ,1 -- insituacao
         ,0 -- perminimo
         ,1 -- inaplicacao_propria
         ,0 -- inpoupanca_propria
         ,0 -- nrconta_terceiro
         ,0 -- inaplicacao_terceiro
         ,0 -- inpoupanca_terceiro
         ,0 -- inresgate_automatico
         ,0)-- qtdias_atraso_permitido
    RETURNING idcobertura
         INTO vr_idcobert;
    
    -- grava rollback
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'DELETE FROM tbgar_cobertura_operacao WHERE cdcooper = '||rw_principal.cdcooper||' AND nrdconta = '||rw_principal.nrdconta||' AND nrcontrato = '||rw_principal.nrctrepr||';' || chr(13), FALSE); 
    
    -- valor anterior para usar no rollback
    SELECT idcobope INTO vr_idcobope FROM crawepr WHERE cdcooper = rw_principal.cdcooper AND nrdconta = rw_principal.nrdconta AND nrctremp = rw_principal.nrctrepr;
    
    -- Atualiza idcobope
    UPDATE crawepr w SET w.idcobope = vr_idcobert WHERE w.cdcooper = rw_principal.cdcooper AND w.nrdconta = rw_principal.nrdconta AND w.nrctremp = rw_principal.nrctrepr;
    
    -- grava rollback idcobope
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'UPDATE crawepr SET idcobope = '||vr_idcobope||' WHERE cdcooper = '||rw_principal.cdcooper||' AND nrdconta = '||rw_principal.nrdconta||' AND nrctremp = '||rw_principal.nrctrepr||';' || chr(13), FALSE);     
  
    
    -- Acionar rotina de calculo de dias em atraso
    vr_qtdiaatr := empr0001.fn_busca_dias_atraso_epr(pr_cdcooper => rw_principal.cdcooper
                                                    ,pr_nrdconta => rw_principal.nrdconta
                                                    ,pr_nrctremp => rw_principal.nrctrepr
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                    ,pr_dtmvtoan => rw_crapdat.dtmvtoan);
                                                    
    vr_vlresgat := rw_principal.vlsdeved;

    -- Devolver o valor simulado de resgate
    BLOQ0001.pc_solici_cobertura_operacao(pr_idcobope => vr_idcobope
                                         ,pr_flgerlog => 1
                                         ,pr_cdoperad => '1'
                                         ,pr_idorigem => 7
                                         ,pr_cdprogra => 'ATENDA'
                                         ,pr_qtdiaatr => vr_qtdiaatr
                                         ,pr_vlresgat => vr_vlresgat
                                         ,pr_flefetiv => 'N' --retornar os valores para resgate
                                         ,pr_dscritic => vr_dscritic);

    -- Em caso de erro, deve prosseguir normalmente, considerando que n�o h� valores para resgate
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Limpar a vari�vel de cr�tica
      vr_dscritic := NULL;
      -- Zerar a vari�vel de valor de resgate
      vr_vlresgat := 0;
    END IF;
    
    -- Consulta o saldo atualizado para desbloqueio da cobertura parcial ou completa
    BLOQ0001.pc_bloqueio_garantia_atualizad(pr_idcobert => vr_idcobope
                                           ,pr_vlroriginal => rw_principal.vlsdeved
                                           ,pr_vlratualizado => vr_vlresgat
                                           ,pr_nrcpfcnpj_cobertura => vr_nrcpfcnpj
                                           ,pr_dscritic => vr_dscritic);

    -- Se o valor de desbloqueio for maior ou igual ao valor atualizado, efetua o desblqueio total
    IF rw_principal.vlsdeved >= vr_vlresgat THEN                                
       BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_idcobertura    => vr_idcobope
                                            ,pr_inbloq_desbloq => 'D'
                                            ,pr_cdoperador     => '1'
                                            ,pr_cdcoordenador_desbloq => '1'
                                            ,pr_vldesbloq      => vr_vlresgat
                                            ,pr_flgerar_log    => 'S'
                                            ,pr_atualizar_rating => 0
                                            ,pr_dscritic       => vr_dscritic);
    END IF;
    
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
                                     ,pr_flg_impri => 'N'                           --> Chamar a impress�o (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> N�mero de c�pias para impress�o
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM || ' - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
