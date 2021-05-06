-- Tempo no ambiente individual: Em torno de 12 minutos
-- INC0088744 - Retorno das sobras direcionadas a valores a devolver
DECLARE

  -- Buscar todas as contas para processamento
  CURSOR cr_crapass IS 
    SELECT t.cdcooper
         , t.nrdconta
         , t.nrcpfcgc
         , t.cdsitdct
         , (SELECT SUM(c.vllanmto)
              FROM craplcm c
             WHERE c.cdcooper = t.cdcooper 
               AND c.nrdconta = t.nrdconta
               AND c.dtmvtolt IN ('27/04/2021','16/04/2021','29/04/2021')
               AND c.cdhistor IN (2177,2178,2175,2176,2179,3028)) vlcreditado
         , (SELECT SUM(d.vllanmto)
              FROM craplcm d
             WHERE d.cdcooper = t.cdcooper 
               AND d.nrdconta = t.nrdconta
               AND d.dtmvtolt IN ('27/04/2021','16/04/2021','29/04/2021')
               AND d.cdhistor IN (2061,2062)) vldebitado
         , (SELECT SUM(e.vllanmto)
              FROM craplcm e
             WHERE e.cdcooper = t.cdcooper 
               AND e.nrdconta = t.nrdconta
               AND e.dtmvtolt IN ('27/04/2021','16/04/2021','29/04/2021')
               AND e.cdhistor IN (2719)) vlestorno -- ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO
         , (SELECT SUM(x.vlcapital)
              FROM tbcotas_devolucao x
             WHERE x.cdcooper = t.cdcooper
               AND x.nrdconta = t.nrdconta
               AND x.tpdevolucao = 4 -- Sobras Deposito demitido
            ) vldevolver
      FROM crapass t
     WHERE t.cdsitdct = 8 -- contas situação 8
       AND EXISTS (SELECT 1 
                     FROM craplcm x
                    WHERE x.cdcooper = t.cdcooper
                      AND x.nrdconta = t.nrdconta
                      AND x.dtmvtolt IN ('27/04/2021','16/04/2021','29/04/2021')
                      AND x.cdhistor IN (2177,2178,2175,2176,2179,3028))
     ORDER BY 1,2;
   
  -- Buscar o valores de lançamento da conta
  CURSOR cr_craplcm(pr_cdcooper  craplcm.cdcooper%TYPE
                   ,pr_nrdconta  craplcm.nrdconta%TYPE) IS
    SELECT t.cdhistor
         , t.vllanmto
      FROM craplcm t
     WHERE t.cdcooper = pr_cdcooper 
       AND t.nrdconta = pr_nrdconta
       AND t.dtmvtolt IN ('27/04/2021','16/04/2021','29/04/2021')
       AND t.cdhistor IN (2177,2178,2175,2176,2179,3028);
 
  -- Variáveis
  vr_dslog          CLOB;
  vr_rgretorno      LANC0001.typ_reg_retorno;
  vr_incrineg       NUMBER;
  vr_cdcritic       NUMBER;
  vr_dscritic       VARCHAR2(2000);
  vr_vlcapital      tbcotas_devolucao.vlcapital%TYPE;
  vr_dsrowid        VARCHAR2(50);
  vr_dsdirlog       VARCHAR2(100) := '/usr/coop/cecred/log';
  
BEGIN
  
  vr_dslog := '----- REGISTRO DE LANÇAMENTOS -----'||CHR(10);
  
  -- Escrever arquivo de log
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_dslog
                               ,pr_caminho  => vr_dsdirlog
                               ,pr_arquivo  => 'logSobras.txt'
                               ,pr_flappend => 'N'
                               ,pr_des_erro => vr_dscritic);
  
  -- Percorrer todas as contas a serem processadas
  FOR dados IN cr_crapass LOOP
  
    vr_dslog := '--> COOP: '||dados.cdcooper||' -> '||dados.nrdconta||CHR(10);
    vr_dslog := vr_dslog||'    * VL.Crédito..: '||dados.vlcreditado||CHR(10);
    vr_dslog := vr_dslog||'    * VL.Débito...: '||dados.vldebitado||CHR(10);
    vr_dslog := vr_dslog||'    * VL.Estorno..: '||dados.vlestorno||CHR(10);
    vr_dslog := vr_dslog||'    * VL.Devolver.: '||dados.vldevolver||CHR(10);
    
    -- Se a conta não possui valores a devolver 
    IF NVL(dados.vldevolver,0) = 0 THEN
      vr_dslog := vr_dslog||'  ### Sem valores a devolver.'||CHR(10);
      
      -- Escrever arquivo de log
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_dslog
                                   ,pr_caminho  => vr_dsdirlog
                                   ,pr_arquivo  => 'logSobras.txt'
                                   ,pr_flappend => 'S'
                                   ,pr_des_erro => vr_dscritic);
      
      CONTINUE; -- Não processa nenhuma devolução
    END IF;
    
    SAVEPOINT lancar_valores_conta;
    
    -- Se o valor debitado for maior que zero - NÃO DEVE LANÇAR VALOR DE ESTORNO
    IF NVL(dados.vldebitado,0) > 0 THEN
      -- Buscar os lançamentos de conta, para serem creditados
      FOR lancto IN cr_craplcm(dados.cdcooper, dados.nrdconta) LOOP
    
        -- Realizar o lançamento de crédito na conta
        lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => datascooperativa(dados.cdcooper).dtmvtolt
                                          ,pr_cdagenci    => 1
                                          ,pr_cdbccxlt    => 100  
                                          ,pr_nrdolote    => 8005
                                          ,pr_nrdconta    => dados.nrdconta
                                          ,pr_nrdocmto    => '8005'||lancto.cdhistor
                                          ,pr_cdhistor    => lancto.cdhistor 
                                          ,pr_vllanmto    => lancto.vllanmto
                                          ,pr_nrdctabb    => dados.nrdconta
                                          ,pr_cdpesqbb    => 'REVERCAO DE VALORES A DEVOLVER - CONTAS SIT. 8'
                                          ,pr_hrtransa    => gene0002.fn_busca_time
                                          ,pr_cdoperad    => '1' -- Super Usuário
                                          ,pr_dsidenti    => ' '
                                          ,pr_cdcooper    => dados.cdcooper
                                          ,pr_nrdctitg    => LPAD(dados.nrdconta,8,'0')
                                          ,pr_inprolot    => 1 -- A rotina irá processar os dados do lote
                                          ,pr_tplotmov    => 2
                                          ,pr_tab_retorno => vr_rgretorno
                                          ,pr_incrineg    => vr_incrineg
                                          ,pr_cdcritic    => vr_cdcritic
                                          ,pr_dscritic    => vr_dscritic);
               
        -- Em caso de erro                           
        IF vr_dscritic IS NOT NULL THEN
          vr_dslog := vr_dslog||'  ### ERRO: '||vr_dscritic||CHR(10);
          
          -- Desfaz os lançamentos da conta
          ROLLBACK TO lancar_valores_conta;
          
          -- Escrever arquivo de log
          gene0002.pc_clob_para_arquivo(pr_clob     => vr_dslog
                                       ,pr_caminho  => vr_dsdirlog
                                       ,pr_arquivo  => 'logSobras.txt'
                                       ,pr_flappend => 'S'
                                       ,pr_des_erro => vr_dscritic);
          
          -- Encerra lançamentos para a conta
          EXIT; 
        END IF;
                                       
      END LOOP;
    END IF;
    
    -- Se ocorreu erro ao inserir lançamentos
    IF vr_dscritic IS NOT NULL THEN
      -- Limpar erros
      vr_dscritic := NULL;
      
      CONTINUE; -- Pula para a próxima conta
    END IF;
    
    -- Realizar a atualização dos valores a devolver
    BEGIN
      UPDATE tbcotas_devolucao t
         SET t.vlcapital = (t.vlcapital - dados.vldevolver)
       WHERE t.cdcooper = dados.cdcooper
         AND t.nrdconta = dados.nrdconta
         AND t.tpdevolucao = 4
        RETURNING rowid, t.vlcapital INTO vr_dsrowid,vr_vlcapital;
         
      -- Se o valor ficou zerado
      IF vr_vlcapital <= 0 THEN
        -- Deve excluir o registro de devolução
        DELETE tbcotas_devolucao
         WHERE ROWID = vr_dsrowid;
      END IF;
            
    EXCEPTION
      WHEN OTHERS THEN
        vr_dslog := vr_dslog||'  ### ERRO AO ATUALIZAR TBCOTAS_DEVOLUCAO: '||vr_dscritic||CHR(10);
        
        -- Desfaz os lançamentos da conta
        ROLLBACK TO lancar_valores_conta;
        
        -- Escrever arquivo de log
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_dslog
                                     ,pr_caminho  => vr_dsdirlog
                                     ,pr_arquivo  => 'logSobras.txt'
                                     ,pr_flappend => 'S'
                                     ,pr_des_erro => vr_dscritic);
        
        -- Pular para o próximo registro
        CONTINUE;
    END;
    
    -- Escrever arquivo de log
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_dslog
                                 ,pr_caminho  => vr_dsdirlog
                                 ,pr_arquivo  => 'logSobras.txt'
                                 ,pr_flappend => 'S'
                                 ,pr_des_erro => vr_dscritic);
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao executar script: '||SQLERRM);
      ROLLBACK;
END;
