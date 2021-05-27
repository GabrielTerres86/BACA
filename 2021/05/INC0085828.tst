PL/SQL Developer Test script 3.0
293
DECLARE

  -- Cooperativas
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE
                   ) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = NVL(pr_cdcooper, cop.cdcooper)
       AND cop.flgativo = 1;
       
  -- Data de movimento
  CURSOR cr_craplem(pr_cdcooper craplem.cdcooper%TYPE
                   ,pr_dtmvtolt craplem.dtmvtolt%TYPE
                   ) IS
    SELECT DISTINCT lcm.dtmvtolt
      FROM craplem lcm
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
     WHERE t.cdcooper   = 1
       AND t.cdoperacao = pr_cdoperac
        AND t.nrdconta   = 80097324
       AND t.dtoperacao BETWEEN trunc(pr_dtmvtolt, 'yyyy') and pr_dtmvtolt
     GROUP BY t.nrdconta;
  --
  vr_dtmvtolt crapdat.dtmvtolt%TYPE := to_date('31/12/2020', 'dd/mm/yyyy');
  vr_cdcooper crapcop.cdcooper%TYPE := NULL;  
  vr_cdoperac_pagepr NUMBER;
  vr_des_xml  CLOB;
  vr_texto_completo       VARCHAR2(32600);
  vr_dsdireto             VARCHAR2(4000);
  vr_incidente            VARCHAR2(50);
  vr_typ_saida            VARCHAR2(3);
  vr_dscritic             VARCHAR2(2000);

         -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_rollback(pr_des_dados IN VARCHAR2,
                                pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

  -- Realizar a apuração diária dos lançamentos dos históricos de pagamento de empréstimos
  PROCEDURE pc_apura_informes(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                             ,pr_dtrefere IN DATE   ) IS           -- Data de referencia
                             
    CURSOR cr_craplem(pr_cdcooper craplem.cdcooper%TYPE
                     ,pr_dtrefere craplem.dtmvtolt%TYPE
                     ) IS
                     
      select x.cdcooper
           , x.nrdconta
           , x.dtmvtolt
           , sum(x.VLLANMTO) vllanmto
        from craplem x
       where-- x.cdcooper = pr_cdcooper and --- POR DE VOLTA 
          x.cdcooper = 1   
         and x.cdhistor in (3026, 3027)
         and x.dtmvtolt = pr_dtrefere
         AND X.NRDCONTA = 80097324 
        group by x.cdcooper
           , x.nrdconta
           , x.dtmvtolt;
     
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
    
    FOR rw_craplem IN cr_craplem(pr_cdcooper
                                ,pr_dtrefere
                                ) LOOP
      BEGIN      
      -- Inserir os regitros referente aos lançamentos do dia      
      INSERT INTO TBCC_OPERACOES_DIARIAS(cdcooper, nrdconta, cdoperacao, dtoperacao, vloperacao) VALUES
         (pr_cdcooper
         ,rw_craplem.nrdconta
         ,vr_cdoperac_pagepr
         ,pr_dtrefere
         ,rw_craplem.vllanmto
         );
      pc_escreve_rollback('DELETE TBCC_OPERACOES_DIARIAS ww ' ||
                          ' WHERE ww.cdcooper =' || pr_cdcooper ||
                          ' and ww.nrdconta=' || rw_craplem.nrdconta ||
                          ' and ww.cdoperacao='|| vr_cdoperac_pagepr || 
                          ' and ww.dtoperacao=' || pr_dtrefere ||
                          ' and ww.vloperacao=' || rw_craplem.vllanmto || ';'||chr(10));
      EXCEPTION
        WHEN dup_val_on_index THEN
          BEGIN
            UPDATE TBCC_OPERACOES_DIARIAS tod
               SET tod.vloperacao = nvl(tod.vloperacao, 0) + nvl(rw_craplem.vllanmto, 0)
             WHERE tod.cdcooper   = pr_cdcooper
               AND tod.nrdconta   = rw_craplem.nrdconta
               AND tod.cdoperacao = vr_cdoperac_pagepr
               AND tod.dtoperacao = pr_dtrefere;
            pc_escreve_rollback('UPDATE TBCC_OPERACOES_DIARIAS wx ' ||
                                ' SET wx.vloperacao = nvl(wx.vloperacao, 0) - nvl('|| rw_craplem.vllanmto || ',0)' ||
                                ' WHERE wx.cdcooper =' || pr_cdcooper ||
                                ' and wx.nrdconta=' || rw_craplem.nrdconta ||
                                ' and wx.cdoperacao=' || vr_cdoperac_pagepr || 
                                ' and wx.dtoperacao=' || pr_dtrefere || ';'||chr(10));      
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
  -- Inicializar o CLOB
  dbms_output.enable(buffer_size => null);

  vr_incidente := 'INC0085828';
  vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas';
  gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir ' || vr_dsdireto || '/' || vr_incidente
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

  vr_dsdireto := vr_dsdireto || '/' || vr_incidente;

  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;

    -----------------------------------------------------------------------------------------------
    -- Buscar o código de operação para os registros de lançamento de históricos de empréstimos
    vr_cdoperac_pagepr := to_number(gene0001.fn_param_sistema('CRED',0,'CDOPERAC_HIS_PAGTO_EPR'));
    -----------------------------------------------------------------------------------------------
  FOR rw_crapcop IN cr_crapcop(vr_cdcooper
                              ) LOOP
    --
    FOR rw_craplem IN cr_craplem(rw_crapcop.cdcooper
                                ,vr_dtmvtolt
                                ) LOOP
      --
      pc_apura_informes(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_dtrefere => rw_craplem.dtmvtolt
                       );
      --
    END LOOP;
    -- Após realizar a apuração dos dados ... deve agrupar os valores na tabela crapdir
    FOR rw_apuraepr IN cr_apuraepr(rw_crapcop.cdcooper
                                  ,vr_cdoperac_pagepr
                                  ,vr_dtmvtolt
                                  ) LOOP
      BEGIN

        UPDATE crapdir dir
           SET dir.vlprepag = rw_apuraepr.vllanmto
         WHERE dir.cdcooper = rw_crapcop.cdcooper
           AND dir.nrdconta = rw_apuraepr.nrdconta
           AND dir.dtmvtolt = vr_dtmvtolt;
        --
        pc_escreve_rollback('UPDATE crapdir wdir ' ||
                            ' SET wdir.vlprepag = wdir.vlprepag - '  || nvl(rw_apuraepr.vllanmto,0) || 
                            ' WHERE wdir.cdcooper = ' ||  rw_crapcop.cdcooper ||
                            ' AND wdir.nrdconta = ' || rw_apuraepr.nrdconta ||
                            ' AND wdir.dtmvtolt = ' || vr_dtmvtolt ||';'||chr(10));
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
  pc_escreve_rollback('COMMIT;');
  pc_escreve_rollback(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_dsdireto, 'CORRECAO_INFORME_RENDIMENTOS85828_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
END;
0
0
