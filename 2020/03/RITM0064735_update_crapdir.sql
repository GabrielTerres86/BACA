DECLARE

  -- Cooperativas
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE
                   ) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = NVL(pr_cdcooper, cop.cdcooper)
       AND cop.flgativo = 1;
       
  -- Data de movimento
  CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%TYPE
                   ,pr_dtmvtolt craplcm.dtmvtolt%TYPE
                   ) IS
    SELECT DISTINCT lcm.dtmvtolt
      FROM craplcm lcm
     WHERE lcm.cdcooper  = pr_cdcooper
       AND lcm.dtmvtolt >= trunc(pr_dtmvtolt, 'yyyy')
     ORDER BY lcm.dtmvtolt;
  
  -- Calculo dos Valores Pagos em Emprestimos e Financiamentos no ano
  CURSOR cr_apuraepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_cdoperac IN NUMBER
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                    ) IS
    SELECT t.nrdconta
         , SUM(t.vloperacao)  vllanmto
      FROM cecred.tbcc_operacoes_diarias t
     WHERE t.cdcooper   = pr_cdcooper
       AND t.cdoperacao = pr_cdoperac
       -- AND t.nrdconta   = 9136401 -- RETIRAR
       AND t.dtoperacao BETWEEN trunc(pr_dtmvtolt, 'yyyy') and pr_dtmvtolt
     GROUP BY t.nrdconta;
  --
  vr_dtmvtolt crapdat.dtmvtolt%TYPE := to_date('31/12/2019', 'dd/mm/yyyy');
  vr_cdcooper crapcop.cdcooper%TYPE := NULL;
  vr_cdoperac_pagepr NUMBER;
  -- Realizar a apuração diária dos lançamentos dos históricos de pagamento de empréstimos
  PROCEDURE pc_apura_informes(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                             ,pr_dtrefere IN DATE   ) IS           -- Data de referencia
                             
    CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%TYPE
                     ,pr_dtrefere craplcm.dtmvtolt%TYPE
                     ) IS
      SELECT lcm.cdcooper
           , lcm.nrdconta
           , lcm.dtmvtolt
           -- RITM0064735
           ,sum(decode(lcm.cdhistor/*, 108, lcm.vllanmto*/
                                   ,2332, lcm.vllanmto
                                   ,2333, lcm.vllanmto
                                   /*, 275, lcm.vllanmto*/
                                   ,  92, lcm.vllanmto
                                   , 384, lcm.vllanmto
                                   /*,1706, lcm.vllanmto * -1*/
                                   , 317, lcm.vllanmto * -1
                                   /*,1539, lcm.vllanmto*/
                                   ,2336, lcm.vllanmto
                                   ,2337, lcm.vllanmto
                                   , 394, lcm.vllanmto
                                   ,1715, lcm.vllanmto * -1
                                   ,2370, lcm.vllanmto
                                   ,2372, lcm.vllanmto
                                   ,2374, lcm.vllanmto
                                   ,2376, lcm.vllanmto
                                   ,2386, lcm.vllanmto
                                   ,2387, lcm.vllanmto * -1
                                   ,0
                                   )) vllanmto
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         -- RITM0064735
         AND lcm.cdhistor IN(/*108,*/ 2332, 2333, /*275,*/ 92, 384 -- Pagamento
                            /*,1706*/, 317                -- Estorno Pagamento
                            /*,1539*/, 2336, 2337, 394    -- Pagamento Aval
                            ,1715                     -- Estorno Pagamento Aval
                            ,2370, 2372               -- Pagamento de Mora
                            ,2374, 2376               -- Pagamento de Mora Aval
                            ,2386                     -- Recuperação de Prejuízo
                            ,2387                     -- Estorno recuperação de Prejuízo
                            )
         AND lcm.dtmvtolt = pr_dtrefere
       GROUP BY lcm.cdcooper
           , lcm.nrdconta
           , lcm.dtmvtolt;
    -- ROTINA CRIADA COM PRAGMA AUTONOMO PARA QUE O COMMIT DA MESMA NÃO AFETE ROTINAS CHAMADORAS.
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    ---------------> VARIAVEIS <-----------------
    -- Variaveis de erro    
    vr_cdcritic        crapcri.cdcritic%TYPE;
    vr_dscritic        VARCHAR2(4000);
    -- Variáveis de Excecao
    vr_exc_erro        EXCEPTION;
    -- Variáveis
    vr_cdoperac_pagepr   NUMBER;
    
    -- Variaveis de controle de erro e modulo - 31/08/2018 - REQ0011727
    vr_dsparame  VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro  VARCHAR2  (100) := 'PAGA0002.pc_apura_lcm_his_emprestimo'; -- Rotina e programa 
    
  BEGIN
    -- Incluido nome do módulo logado - 31/08/2018 - REQ0011727
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro );        
    vr_dsparame := 'pr_cdcooper:'  || pr_cdcooper || 
                   ',pr_dtrefere:' || pr_dtrefere;         
    
    -- Buscar o código de operação para os registros
    vr_cdoperac_pagepr := to_number(gene0001.fn_param_sistema('CRED',0,'CDOPERAC_HIS_PAGTO_EPR'));
    
    FOR rw_craplcm IN cr_craplcm(pr_cdcooper
                                ,pr_dtrefere
                                ) LOOP
      BEGIN      
      -- Inserir os regitros referente aos lançamentos do dia
      INSERT INTO TBCC_OPERACOES_DIARIAS(cdcooper, nrdconta, cdoperacao, dtoperacao, vloperacao) VALUES
         (pr_cdcooper
         ,rw_craplcm.nrdconta
         ,vr_cdoperac_pagepr
         ,pr_dtrefere
         ,rw_craplcm.vllanmto
         );
      EXCEPTION
        WHEN dup_val_on_index THEN
          BEGIN
            UPDATE TBCC_OPERACOES_DIARIAS tod
               SET tod.vloperacao = nvl(tod.vloperacao, 0) + nvl(rw_craplcm.vllanmto, 0)
             WHERE tod.cdcooper   = pr_cdcooper
               AND tod.nrdconta   = rw_craplcm.nrdconta
               AND tod.cdoperacao = vr_cdoperac_pagepr
               AND tod.dtoperacao = pr_dtrefere;
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log 
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
              -- Ajuste log da critica
              vr_cdcritic := 1034;   
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                              ||'TBCC_OPERACOES_DIARIAS:'
                              ||' cdcooper:'||pr_cdcooper
                              ||', cdoperac:'||vr_cdoperac_pagepr
                              ||', dtoperac:'||pr_dtrefere
                              ||'. '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        -- Trata Erro - 31/08/2018 - REQ0011727
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
          -- Ajuste log da critica
          vr_cdcritic := 1034;   
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                          ||'TBCC_OPERACOES_DIARIAS:'
                          ||' cdcooper:'||pr_cdcooper
                          ||', cdoperac:'||vr_cdoperac_pagepr
                          ||', dtoperac:'||pr_dtrefere
                          ||'. '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Efetivar os dados gerados
      COMMIT;
    END LOOP;
    
    -- Limpa nome do módulo logado - 31/08/2018 - REQ0011727
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL ); 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Controlar geração de log   
      paga0002.pc_log(pr_dscritic    => vr_dscritic
                     ,pr_cdcritic    => vr_cdcritic
                     );  
      -- Desfazer alterações pendentes
      ROLLBACK;
      -- Efetuar montagem de e-mail
      gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper
                                ,pr_cdprogra    => 'PAGA0002'
                                ,pr_des_destino => gene0001.fn_param_sistema('CRED',pr_cdcooper, 'ERRO_EMAIL_JOB')
                                ,pr_des_assunto => 'Apuração Auto Atendimento – Coop '||pr_cdcooper
                                ,pr_des_corpo   => 'Olá, <br><br>'
                                                || 'Foram encontrados problemas durante o processo de apuração '
                                                || 'dos valores de Históricos dos Lançamentos de Empréstimos. <br> '
                                                || 'Erro encontrado:<br>'||SQLERRM
                                ,pr_des_anexo   => ''
                                ,pr_flg_enviar  => 'N'
                                ,pr_des_erro    => vr_dscritic);
      -- Gravar a solictação do e-mail para envio posterior
      COMMIT;  
      
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
      -- Efetuar retorno do erro não tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     vr_nmrotpro     || 
                     '. ' || SQLERRM ||
                     '. ' || vr_dsparame; 
      -- Controlar geração de log   
      paga0002.pc_log(pr_dscritic    => vr_dscritic
                     ,pr_cdcritic    => vr_cdcritic
                     );   
      -- Desfazer alterações pendentes
      ROLLBACK;
      -- Acerto do código do programa - 31/08/2018 - REQ0011727
      -- Efetuar montagem de e-mail
      gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper
                                ,pr_cdprogra    => 'PAGA0002' -- 'SOBR0001.pc_apura_juros_capital'
                                ,pr_des_destino => gene0001.fn_param_sistema('CRED',pr_cdcooper, 'ERRO_EMAIL_JOB')
                                ,pr_des_assunto => 'Apuração Auto Atendimento – Coop '||pr_cdcooper
                                ,pr_des_corpo   => 'Olá, <br><br>'
                                                || 'Foram encontrados problemas durante o processo de apuração '
                                                || 'dos valores de Históricos dos Lançamentos de Empréstimos. <br> '
                                                || 'Erro encontrado:<br>'||SQLERRM
                                ,pr_des_anexo   => ''
                                ,pr_flg_enviar  => 'N'
                                ,pr_des_erro    => vr_dscritic);
      -- Gravar a solictação do e-mail para envio posterior
      COMMIT;
  END pc_apura_informes;
  --
BEGIN
    -----------------------------------------------------------------------------------------------
    -- Buscar o código de operação para os registros de lançamento de históricos de empréstimos
    vr_cdoperac_pagepr := to_number(gene0001.fn_param_sistema('CRED',0,'CDOPERAC_HIS_PAGTO_EPR'));
    -----------------------------------------------------------------------------------------------
  FOR rw_crapcop IN cr_crapcop(vr_cdcooper
                              ) LOOP
    --
    FOR rw_craplcm IN cr_craplcm(rw_crapcop.cdcooper
                                ,vr_dtmvtolt
                                ) LOOP
      --
      pc_apura_informes(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_dtrefere => rw_craplcm.dtmvtolt
                       );
      --
    END LOOP;
    -- Após realizar a apuração dos dados ... deve agrupar os valores na tabela crapdir
    FOR rw_apuraepr IN cr_apuraepr(rw_crapcop.cdcooper
                                  ,vr_cdoperac_pagepr
                                  ,vr_dtmvtolt
                                  ) LOOP
      BEGIN
        --
        UPDATE crapdir dir
           SET dir.vlprepag = rw_apuraepr.vllanmto
         WHERE dir.cdcooper = rw_crapcop.cdcooper
           AND dir.nrdconta = rw_apuraepr.nrdconta
           AND dir.dtmvtolt = vr_dtmvtolt;
        --
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro: ' || rw_apuraepr.nrdconta || ' - ' || SQLERRM);
          ROLLBACK;
      END;
      --
      COMMIT;
      --
    END LOOP;
    --
  END LOOP;
  --
END;
