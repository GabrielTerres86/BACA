CREATE OR REPLACE PACKAGE cecred.sspc0002 AS
 
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: SSPC0002
  --  Autor   : Andrino Carlos de Souza Junior
  --  Data    : Novembro/2015                     Ultima Atualizacao: 14/05/2019
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente ao processo de envio de boletos de cobranca ao Serasa
  -- 
  --  Alteracoes: 
  /*
  14/05/2019 - inc0011296 Na rotina pc_negativa_serasa, corrigida a validação de cobrança em protesto (Carlos)
  ---------------------------------------------------------------------------------------------------------------*/

  -- Rotina para alterar o indicador do Serasa para envio do boleto
  -- ao Serasa no proximo processo
    PROCEDURE pc_negativa_serasa(pr_cdcooper IN crapcob.cdcooper%TYPE
                                , --> Codigo da cooperativa
                                 pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                , --> Numero do convenio de cobranca. 
                                 pr_nrdconta IN crapcob.nrdconta%TYPE
                                , --> Numero da conta/dv do associado. 
                                 pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                , --> Numero do documento(boleto) 
                                 pr_nrremass IN INTEGER
                                , --> Numero da Remessa
                                 pr_cdoperad IN crapope.cdoperad%TYPE
                                , --> Codigo do operador
                                 pr_cdcritic OUT PLS_INTEGER
                                , --> Código da crítica
                                 pr_dscritic OUT VARCHAR2); --> Descrição da crítica
                               
  -- Rotina para alterar o indicador do Serasa para envio do boleto
  -- ao Serasa no proximo processo
    PROCEDURE pc_cancelar_neg_serasa(pr_cdcooper IN crapcob.cdcooper%TYPE
                                    , --> Codigo da cooperativa
                                     pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                    , --> Numero do convenio de cobranca. 
                                     pr_nrdconta IN crapcob.nrdconta%TYPE
                                    , --> Numero da conta/dv do associado. 
                                     pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                    , --> Numero do documento(boleto) 
                                     pr_nrremass IN INTEGER
                                    , --> Numero da Remessa
                                     pr_cdoperad IN crapope.cdoperad%TYPE
                                    , --> Codigo do operador
                                     pr_cdcritic OUT PLS_INTEGER
                                    , --> Código da crítica
                                     pr_dscritic OUT VARCHAR2); --> Descrição da crítica

  -- Rotina para buscar o parametro de negativacao da Serasa
    PROCEDURE pc_busca_param_negativ(pr_cdcooper             IN tbcobran_param_negativacao.cdcooper%TYPE
                                    ,pr_cduf_sacado          IN tbcobran_param_exc_neg_serasa.dsuf%TYPE
                                    , -- Codigo da UF do Sacado
                                     pr_qtminimo_negativacao OUT tbcobran_param_negativacao.qtminimo_negativacao%TYPE
                                    ,pr_qtmaximo_negativacao OUT tbcobran_param_negativacao.qtmaximo_negativacao%TYPE
                                    ,pr_vlminimo_boleto      OUT tbcobran_param_negativacao.vlminimo_boleto%TYPE
                                    ,pr_dstexto_dias         OUT VARCHAR2
                                    ,pr_dscritic             OUT VARCHAR2);

  PROCEDURE pc_altera_neg_serasa(pr_flserasa IN INTEGER --> Negativar: 0-Nao / 1-Sim
                                ,pr_flposbol IN INTEGER --> Possui boleto em aberto: 0-Nao / 1-Sim
                                ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_verifica_boleto_aberto(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                     ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    FUNCTION fn_retorna_modalidade(flcooexp crapceb.flcooexp%TYPE
                                  ,flceeexp crapceb.flceeexp%TYPE) RETURN VARCHAR2;

  -- Rotina para impressao do termo de abertura e termo de cancelamento
  PROCEDURE pc_imprimir_termo(pr_nrdconta IN crapass.nrdconta%TYPE --> Numedo da conta
                             ,pr_nmdtest1 IN VARCHAR2 --> Nome da testemunha 1
                             ,pr_cpftest1 IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 1
                             ,pr_nmdtest2 IN VARCHAR2 --> Nome da testemunha 2
                             ,pr_cpftest2 IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 2
                             ,pr_nrconven IN crapceb.nrconven%TYPE --> Numero do convenio
                             ,pr_tpimpres IN PLS_INTEGER --> 1-Termo de Abertura, 2-Termo de Encerramento, 3-Termo de Cancelamento Protesto
                             ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    -- Rotina para impressao do termo de abertura e termo de cancelamento
    PROCEDURE pc_imprimir_termo_reciproci(pr_nrdconta            IN crapass.nrdconta%TYPE --> Numedo da conta
                                         ,pr_nmdtest1            IN VARCHAR2 --> Nome da testemunha 1
                                         ,pr_cpftest1            IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 1
                                         ,pr_nmdtest2            IN VARCHAR2 --> Nome da testemunha 2
                                         ,pr_cpftest2            IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 2
                                         ,pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE DEFAULT 0
                                         ,pr_tpimpres            IN PLS_INTEGER --> 1-Termo de Abertura, 2-Termo de Encerramento, 3-Termo de Cancelamento Protesto
                                         ,pr_xmllog              IN VARCHAR2 --> XML com informacoes de LOG
                                         ,pr_cdcritic            OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic            OUT VARCHAR2 --> Descricao da critica
                                         ,pr_retxml              IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo            OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro            OUT VARCHAR2); --> Erros do processo

END sspc0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.sspc0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: SSPC0002
  --  Autor   : Andrino Carlos de Souza Junior
  --  Data    : Novembro/2015                     Ultima Atualizacao: 13/03/2016
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente ao processo de envio de boletos de cobranca ao Serasa
  --
  --  Alteracoes: 18/02/2016 - Incluido filtro de reciprocidade para geração do termo de convenio.
  --                           (Reinert)
  --              
  --              13/03/2016 - Ajustes decorrente a mudança de algumas rotinas da PAGA0001 
    --                     para a COBR0006 em virtude da conversão das rotinas de arquivos CNAB
    --               (Andrei - RKAM).
  --              
  --              27/09/2017 - Ajuste para validar se o convenio permite negativar no serasa ao invés de 
  --                           verificar se o boleto permite (Douglas - Chamado 754911)
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina para alterar o indicador do Serasa para envio do boleto
  -- ao Serasa no proximo processo
    PROCEDURE pc_negativa_serasa(pr_cdcooper IN crapcob.cdcooper%TYPE
                                , --> Codigo da cooperativa
                                 pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                , --> Numero do convenio de cobranca. 
                                 pr_nrdconta IN crapcob.nrdconta%TYPE
                                , --> Numero da conta/dv do associado. 
                                 pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                , --> Numero do documento(boleto) 
                                 pr_nrremass IN INTEGER
                                , --> Numero da Remessa
                                 pr_cdoperad IN crapope.cdoperad%TYPE
                                , --> Codigo do operador
                                 pr_cdcritic OUT PLS_INTEGER
                                , --> Código da crítica
                                 pr_dscritic OUT VARCHAR2) IS
        --> Descrição da crítica

    -- Cursor sobre o boleto do parametro
    CURSOR cr_crapcob IS
            SELECT crapcob.rowid
                  ,crapceb.flserasa
                  ,crapcob.inserasa
                  ,crapcob.flgdprot
                  ,crapcob.qtdiaprt
                  ,crapcob.vltitulo
                  ,crapcob.dtvencto
                  ,crapcob.nrinssac
                  ,crapcob.insitcrt
                  ,crapcco.cdagenci
                  ,crapcco.cdbccxlt
                  ,crapcco.nrdolote
                  ,crapcco.nrconven
              FROM crapcco
                  ,crapcob
                  ,crapceb
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.nrcnvcob = pr_nrcnvcob
         AND crapcob.nrdconta = pr_nrdconta
         AND crapcob.nrdocmto = pr_nrdocmto
         AND crapceb.cdcooper = crapcob.cdcooper
         AND crapceb.nrdconta = crapcob.nrdconta
         AND crapceb.nrconven = crapcob.nrcnvcob
         AND crapcco.cdcooper = crapcob.cdcooper
         AND crapcco.nrconven = crapcob.nrcnvcob;
    rw_crapcob cr_crapcob%ROWTYPE;
       
    -- Cursor sobre os dados da cooperativa
    CURSOR cr_crapcop IS
            SELECT cdbcoctl
                  ,cdagectl
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Cursor sobre os parametros de negativacao
    CURSOR cr_parneg IS
            SELECT qtminimo_negativacao
                  ,vlminimo_boleto
                  ,hrenvio_arquivo
        FROM tbcobran_param_negativacao
       WHERE cdcooper = pr_cdcooper;
    rw_parneg cr_parneg%ROWTYPE;
    
    -- Busca os dados do sacado
    CURSOR cr_crapsab(pr_nrinssac crapsab.nrinssac%TYPE) IS
      SELECT cdufsaca
        FROM crapsab a
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;

    -- Cursor de excecao   
    CURSOR cr_exc_neg(pr_cdunidade_federacao tbcobran_param_exc_neg_serasa.dsuf%TYPE) IS
      SELECT qtminimo_negativacao
        FROM tbcobran_param_exc_neg_serasa a
       WHERE dsuf = pr_cdunidade_federacao
               AND indexcecao = 2;

    -- Monta o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       
    -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_dsincons VARCHAR2(10000);
        vr_des_erro VARCHAR2(10);

    -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
    -- Variaveis gerais
    vr_cdbandoc crapcob.cdbandoc%TYPE; --Codigo do banco/caixa.
    vr_nrdctabb crapcob.nrdctabb%TYPE; --Numero da conta base no banco.
        vr_tab_lcm  paga0001.typ_tab_lcm_consolidada; -- Tabela de lancamentos para cobranda da tarifa
    
  BEGIN

    -- Busca a data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Busca os dados da cooperativa
    OPEN cr_crapcop;
        FETCH cr_crapcop
            INTO rw_crapcop;
    CLOSE cr_crapcop;

    -- Abre o cursor de boletos
    OPEN cr_crapcob;
        FETCH cr_crapcob
            INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      CLOSE cr_crapcob;
      vr_dscritic := 'Boleto informado nao existe. Favor verificar!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcob;
    
    -- Busca os dados do passado
    OPEN cr_crapsab(rw_crapcob.nrinssac);
        FETCH cr_crapsab
            INTO rw_crapsab;
    CLOSE cr_crapsab;
    
    -- Busca os parametros de negativacao
    OPEN cr_parneg;
        FETCH cr_parneg
            INTO rw_parneg;
    IF cr_parneg%NOTFOUND THEN
      CLOSE cr_parneg;
      vr_dscritic := 'Parametro de negativacao nao cadastrado. Informe a cooperativa!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_parneg;
    
    -- Busca os parametros de excecao dos dias
    IF rw_crapsab.cdufsaca IS NOT NULL THEN
      OPEN cr_exc_neg(rw_crapsab.cdufsaca);
            FETCH cr_exc_neg
                INTO rw_parneg.qtminimo_negativacao;
      CLOSE cr_exc_neg;
    END IF;
    
    -- Se nao permite inclusao no Serasa
    IF rw_crapcob.flserasa = 0 THEN
      vr_dsincons := 'Convenio do boleto nao permite inclusao na Serasa.';
    ELSIF rw_crapcob.vltitulo < rw_parneg.vlminimo_boleto THEN
            vr_dsincons := 'Valor do boleto inferior ao minimo de R$ ' ||
                           to_char(rw_parneg.vlminimo_boleto, 'FM999G999G990D00') ||
                     '. Solicitacao nao permitida!';
    ELSIF rw_crapcob.dtvencto >= rw_crapdat.dtmvtolt THEN
      vr_dsincons := 'Boleto ainda nao venceu. Solicitacao nao permitida!';
    ELSIF rw_crapcob.dtvencto + rw_parneg.qtminimo_negativacao > rw_crapdat.dtmvtolt THEN
      vr_dsincons := 'Vencimento deve ser superior a ' || rw_parneg.qtminimo_negativacao ||
                     ' dias corridos!';
    ELSIF rw_crapcob.inserasa IN (1, 2) THEN
      -- 1-Pendente de envio, 2-Solicitacao Enviada
      vr_dsincons := 'Solicitacao de inclusao ja foi enviada a Serasa.';
    ELSIF rw_crapcob.inserasa IN (3, 4) THEN
      -- 3-Pendente de envio Cancel, 2-Solicitacao Cancel Enviada
      vr_dsincons := 'Solicitacao de cancelamento ja foi enviada a Serasa.';      
    ELSIF rw_crapcob.inserasa = 5 THEN
      -- Negativado
      vr_dsincons := 'Boleto ja negativado na Serasa.';
    ELSIF rw_crapcob.inserasa = 7 THEN
      -- Acao Judicial
      vr_dsincons := 'Boleto ja negativado na Serasa (Acao Judicial).';
    ELSIF rw_crapcob.flgdprot = 1 AND rw_crapcob.insitcrt IN (1,2,3,5) THEN
      -- Titulo está em PROTESTO
      vr_dsincons := 'Boleto esta em processo de Protesto' || 
                     ' - Solicitacao de negativacao nao pode ser executada.';
    END IF;
    
    -- Se possuir mensagem de erro, gera inconsistencia
    IF vr_dsincons IS NOT NULL THEN
      -- So vai gerar mensagem se for via remessa, pois via processo on-line gera a mensagem 
      -- para o usuario no mesmo momento
      IF pr_nrremass > 0 THEN
        --Prepara retorno cooperado
                cobr0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                  ,pr_cdocorre => 92 /* Ocorrencia Serasa*/ --Codigo Ocorrencia
                                                  ,pr_cdmotivo => 'S1' /* "Pedido de Inclusao no Serasa Nao Permitido para o Titulo" */ --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                                  ,pr_cdoperad => nvl(pr_cdoperad, '1') --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                                  ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
                IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        
        -- Limpa a temp table
        vr_tab_lcm.delete;
        -- Efetua a cobranca da tarifa
                paga0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => rw_crapcob.rowid --ROWID da cobranca
                                                   ,pr_cdocorre            => 92 --Codigo Ocorrencia
                                                   ,pr_tplancto            => 'T' --Tipo Lancamento
                                                   ,pr_vltarifa            => 0 --Valor Tarifa
                                                   ,pr_cdhistor            => 0 --Codigo Historico
                                                   ,pr_cdmotivo            => 'S1' --Codigo motivo
                                            ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                                   ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                                   ,pr_dscritic            => vr_dscritic); --Descricao Critica
        --Se ocorreu erro
                IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
      END IF;
        
        IF vr_tab_lcm.exists(vr_tab_lcm.first) THEN
          -- Efetua o pagamento da tarifa
                    paga0001.pc_realiza_lancto_cooperado(pr_cdcooper            => pr_cdcooper --Codigo Cooperativa
                                                        ,pr_dtmvtolt            => rw_crapdat.dtmvtolt --Data Movimento
                                                        ,pr_cdagenci            => rw_crapcob.cdagenci --Codigo Agencia
                                                        ,pr_cdbccxlt            => rw_crapcob.cdbccxlt --Codigo banco caixa
                                                        ,pr_nrdolote            => rw_crapcob.nrdolote --Numero do Lote
                                                        ,pr_cdpesqbb            => rw_crapcob.nrconven --Codigo Convenio
                                                        ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                                        ,pr_dscritic            => vr_dscritic --Descricao Critica
                                                        ,pr_tab_lcm_consolidada => vr_tab_lcm); --Tabela Lancamentos
          --Se ocorreu erro
                    IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
      END IF;
        END IF;
      END IF;
      pr_dscritic := vr_dsincons;
    ELSE
      -- Muda a situacao do boleto para envio para o Serasa
      BEGIN
        UPDATE crapcob
           SET inserasa = 1
         WHERE cdcooper = pr_cdcooper
           AND nrcnvcob = pr_nrcnvcob
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto
                RETURNING cdbandoc, nrdctabb INTO vr_cdbandoc, vr_nrdctabb;
      EXCEPTION
        WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao alterar situacao SERASA na tabela CRAPCOB: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Inserir historico de mudanca de situacao
            paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                         ,pr_cdoperad => nvl(pr_cdoperad, '1')
                                         ,pr_dtmvtolt => trunc(SYSDATE)
                                         , -- Rotina nao utiliza esta data
                                          pr_dsmensag => 'Serasa - Solicitacao de negativacao'
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      --Prepara retorno cooperado
            cobr0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                              ,pr_cdocorre => 93 /* Negativacao Serasa */ --Codigo Ocorrencia
                                              ,pr_cdmotivo => 'S1' /* "Solicitado negativacao Serasa" */ --Codigo Motivo
                                         ,pr_vltarifa => 0
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                              ,pr_cdoperad => nvl(pr_cdoperad, '1') --Codigo Operador
                                         ,pr_nrremass => pr_nrremass --Numero Remessa
                                              ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                         ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se Ocorreu erro
            IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      -- Efetua a cobranca da tarifa
            paga0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => rw_crapcob.rowid --ROWID da cobranca
                                               ,pr_cdocorre            => 93 --Codigo Ocorrencia
                                               ,pr_tplancto            => 'T' --Tipo Lancamento
                                               ,pr_vltarifa            => 0 --Valor Tarifa
                                               ,pr_cdhistor            => 0 --Codigo Historico
                                               ,pr_cdmotivo            => 'S1' --Codigo motivo
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                               ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                               ,pr_dscritic            => vr_dscritic); --Descricao Critica
      --Se ocorreu erro
            IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
        
      -- Insere no historico de mudanca de situacao
      BEGIN
        INSERT INTO tbcobran_his_neg_serasa
          (cdcooper    
          ,cdbandoc    
          ,nrdctabb    
          ,nrcnvcob    
          ,nrdconta    
          ,nrdocmto    
          ,nrsequencia 
          ,dhhistorico 
          ,inserasa    
          ,cdoperad)
        VALUES
          (pr_cdcooper    
          ,vr_cdbandoc    
          ,vr_nrdctabb    
          ,pr_nrcnvcob    
          ,pr_nrdconta    
          ,pr_nrdocmto
                    ,(SELECT nvl(MAX(nrsequencia), 0) + 1
                       FROM tbcobran_his_neg_serasa
                                            WHERE cdcooper = pr_cdcooper
                                              AND cdbandoc = vr_cdbandoc
                                              AND nrdctabb = vr_nrdctabb
                                              AND nrcnvcob = pr_nrcnvcob
                                              AND nrdconta = pr_nrdconta
                                              AND nrdocmto = pr_nrdocmto)
          ,SYSDATE
          ,1
                    ,nvl(pr_cdoperad, '1'));
      EXCEPTION
        WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir na tbcobran_his_neg_serasa: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Verifica se o horario atual eh maior que o parametrizado
            IF rw_parneg.hrenvio_arquivo < to_char(SYSDATE, 'SSSSS') AND pr_nrremass = 0 THEN
        pr_dscritic := 'Acao sera realizada no proximo dia util';
      END IF;
     
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_negativa_serasa: ' || SQLERRM;
      ROLLBACK;

  END;

  -- Rotina para alterar o indicador do Serasa para envio do boleto
  -- ao Serasa no proximo processo
    PROCEDURE pc_cancelar_neg_serasa(pr_cdcooper IN crapcob.cdcooper%TYPE
                                    , --> Codigo da cooperativa
                                     pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                    , --> Numero do convenio de cobranca. 
                                     pr_nrdconta IN crapcob.nrdconta%TYPE
                                    , --> Numero da conta/dv do associado. 
                                     pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                    , --> Numero do documento(boleto) 
                                     pr_nrremass IN INTEGER
                                    , --> Numero da Remessa
                                     pr_cdoperad IN crapope.cdoperad%TYPE
                                    , --> Codigo do operador
                                     pr_cdcritic OUT PLS_INTEGER
                                    , --> Código da crítica
                                     pr_dscritic OUT VARCHAR2) IS
        --> Descrição da crítica

    -- Cursor sobre o boleto do parametro
    CURSOR cr_crapcob IS
            SELECT ROWID
                  ,flserasa
                  ,inserasa
        FROM crapcob
       WHERE cdcooper = pr_cdcooper
         AND nrcnvcob = pr_nrcnvcob
         AND nrdconta = pr_nrdconta
         AND nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;
       
    -- Cursor sobre os dados da cooperativa
    CURSOR cr_crapcop IS
            SELECT cdbcoctl
                  ,cdagectl
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Cursor sobre os parametros da Serasa
    CURSOR cr_param IS
            SELECT hrenvio_arquivo FROM tbcobran_param_negativacao WHERE cdcooper = pr_cdcooper;
      
    -- Monta o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       
    -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_dsincons VARCHAR2(10000);
        vr_des_erro VARCHAR2(10);

    -- Tratamento de erros
        vr_exc_saida EXCEPTION;

    -- Variaveis gerais
        vr_cdbandoc        crapcob.cdbandoc%TYPE; --Codigo do banco/caixa.
        vr_nrdctabb        crapcob.nrdctabb%TYPE; --Numero da conta base no banco.
    vr_hrenvio_arquivo tbcobran_param_negativacao.hrenvio_arquivo%TYPE; --Hora maxima do envio do arquivos
        vr_tab_lcm         paga0001.typ_tab_lcm_consolidada; -- Tabela de lancamentos para cobranda da tarifa

  BEGIN

    -- Busca a data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Busca os dados da cooperativa
    OPEN cr_crapcop;
        FETCH cr_crapcop
            INTO rw_crapcop;
    CLOSE cr_crapcop;

    -- Busca a hora maxima de envio do arquivo
    OPEN cr_param;
        FETCH cr_param
            INTO vr_hrenvio_arquivo;
    CLOSE cr_param;

    -- Abre o cursor de boletos
    OPEN cr_crapcob;
        FETCH cr_crapcob
            INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      CLOSE cr_crapcob;
      vr_dscritic := 'Boleto informado nao existe. Favor verificar!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcob;
    
    -- Se nao permite cancelar a inclusao no Serasa
        IF rw_crapcob.inserasa = 0 THEN
            -- Nao negativado
      vr_dsincons := 'Boleto nao foi enviado ao Serasa.';
        ELSIF rw_crapcob.inserasa IN (3, 4) THEN
            -- Pendente Envio Sol. Cancel / Solicitacao Cancel. Enviada
      vr_dsincons := 'Solicitacao de cancelamento ja foi enviada ao Serasa. Nova solicitacao nao permitida.';
        ELSIF rw_crapcob.inserasa = 6 THEN
            -- Recusada na Serasa
      vr_dsincons := 'Solicitacao de inclusao na Serasa foi rejeitada. O mesmo ja nao se encontra na Serasa!';
    END IF;
    
    -- Se possuir mensagem de erro, gera inconsistencia
    IF vr_dsincons IS NOT NULL THEN
      -- So vai gerar mensagem se for via remessa, pois via processo on-line gera a mensagem 
      -- para o usuario no mesmo momento
      IF pr_nrremass > 0 THEN
        --Prepara retorno cooperado
                cobr0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                  ,pr_cdocorre => 92 /* Ocorrencia Serasa */ --Codigo Ocorrencia
                                                  ,pr_cdmotivo => 'S2' /* "Pedido de Cancelamento de Inclusao no Serasa Nao Permitido para o Titulo" */ --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                                  ,pr_cdoperad => nvl(pr_cdoperad, '1') --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                                  ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
                IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

        -- Efetua a cobranca da tarifa
                paga0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => rw_crapcob.rowid --ROWID da cobranca
                                                   ,pr_cdocorre            => 92 --Codigo Ocorrencia
                                                   ,pr_tplancto            => 'T' --Tipo Lancamento
                                                   ,pr_vltarifa            => 0 --Valor Tarifa
                                                   ,pr_cdhistor            => 0 --Codigo Historico
                                                   ,pr_cdmotivo            => 'S2' --Codigo motivo
                                            ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                                   ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                                   ,pr_dscritic            => vr_dscritic); --Descricao Critica
        --Se ocorreu erro
                IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
      END IF;

      END IF;
      pr_dscritic := vr_dsincons;
    ELSE
      -- Muda a situacao do boleto para pendente de envio de cancelamento para a Serasa
      BEGIN
        UPDATE crapcob
                   SET inserasa = decode(inserasa, 1, 0, 3) -- Pendente envio cancelamento
         WHERE cdcooper = pr_cdcooper
           AND nrcnvcob = pr_nrcnvcob
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto
                RETURNING cdbandoc, nrdctabb INTO vr_cdbandoc, vr_nrdctabb;
      EXCEPTION
        WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao alterar situacao SERASA na tabela CRAPCOB: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Inserir historico de mudanca de situacao
      paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid,
                                    pr_cdoperad => nvl(pr_cdoperad,'1'),
                                    pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                    pr_dsmensag => 'Solicitacao de cancelamento de negativacao do boleto',
                                    pr_des_erro => vr_des_erro,
                                    pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      --Prepara retorno cooperado
            cobr0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                              ,pr_cdocorre => 94 /* Cancelar Negativacao Serasa */ --Codigo Ocorrencia
                                              ,pr_cdmotivo => 'S1' /* Solicitado cancel. negativacao Serasa */ --Codigo Motivo
                                         ,pr_vltarifa => 0
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                              ,pr_cdoperad => nvl(pr_cdoperad, '1') --Codigo Operador
                                         ,pr_nrremass => pr_nrremass --Numero Remessa
                                              ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                         ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se Ocorreu erro
            IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      -- Efetua a cobranca da tarifa
            paga0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => rw_crapcob.rowid --ROWID da cobranca
                                               ,pr_cdocorre            => 94 --Codigo Ocorrencia
                                               ,pr_tplancto            => 'T' --Tipo Lancamento
                                               ,pr_vltarifa            => 0 --Valor Tarifa
                                               ,pr_cdhistor            => 0 --Codigo Historico
                                               ,pr_cdmotivo            => 'S1' --Codigo motivo
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                               ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                               ,pr_dscritic            => vr_dscritic); --Descricao Critica
      --Se ocorreu erro
            IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      
      BEGIN
        INSERT INTO tbcobran_his_neg_serasa
          (cdcooper    
          ,cdbandoc
          ,nrdctabb    
          ,nrcnvcob    
          ,nrdconta    
          ,nrdocmto    
          ,nrsequencia 
          ,dhhistorico 
          ,inserasa    
          ,cdoperad)
        VALUES
          (pr_cdcooper    
          ,vr_cdbandoc    
          ,vr_nrdctabb    
          ,pr_nrcnvcob    
          ,pr_nrdconta    
          ,pr_nrdocmto
                    ,(SELECT nvl(MAX(nrsequencia), 0) + 1
                       FROM tbcobran_his_neg_serasa
                                            WHERE cdcooper = pr_cdcooper
                                              AND cdbandoc = vr_cdbandoc
                                              AND nrdctabb = vr_nrdctabb
                                              AND nrcnvcob = pr_nrcnvcob
                                              AND nrdconta = pr_nrdconta
                                              AND nrdocmto = pr_nrdocmto)
          ,SYSDATE
                    ,decode(rw_crapcob.inserasa
                           ,1
                           ,0
                           , -- Nao esta no Serasa
                                        3) -- Pendente envio cancelamento
                    ,nvl(pr_cdoperad, '1'));
      EXCEPTION
        WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir na tbcobran_his_neg_serasa: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Verifica se o horario atual eh maior que o parametrizado
            IF vr_hrenvio_arquivo IS NOT NULL AND vr_hrenvio_arquivo < to_char(SYSDATE, 'SSSSS') AND
               pr_nrremass = 0 AND rw_crapcob.inserasa <> 1 THEN
                -- Se for 1 ja muda para NAO ESTA NO SERASA AUTOMATICAMENTE
        pr_dscritic := 'Acao sera realizada no proximo dia util';
      END IF;
    
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_cancelar_neg_serasa: ' || SQLERRM;
      ROLLBACK;

  END;

  -- Rotina para buscar o parametro de negativacao da Serasa
    PROCEDURE pc_busca_param_negativ(pr_cdcooper             IN tbcobran_param_negativacao.cdcooper%TYPE
                                    ,pr_cduf_sacado          IN tbcobran_param_exc_neg_serasa.dsuf%TYPE
                                    , -- Codigo da UF do Sacado
                                     pr_qtminimo_negativacao OUT tbcobran_param_negativacao.qtminimo_negativacao%TYPE
                                    ,pr_qtmaximo_negativacao OUT tbcobran_param_negativacao.qtmaximo_negativacao%TYPE
                                    ,pr_vlminimo_boleto      OUT tbcobran_param_negativacao.vlminimo_boleto%TYPE
                                    ,pr_dstexto_dias         OUT VARCHAR2
                                    ,pr_dscritic             OUT VARCHAR2) IS
    -- Cursor para buscar os dados do parametro
    CURSOR cr_param IS
            SELECT qtminimo_negativacao
                  ,qtmaximo_negativacao
                  ,vlminimo_boleto
        FROM tbcobran_param_negativacao
       WHERE cdcooper = pr_cdcooper;
    
    -- Cursor de excecao   
    CURSOR cr_exc_neg IS
            SELECT qtminimo_negativacao
                  ,qtmaximo_negativacao
        FROM tbcobran_param_exc_neg_serasa a
       WHERE dsuf = pr_cduf_sacado
               AND indexcecao = 2;

    -- Cursor com todas as excecoes
    CURSOR cr_exc_neg_2 IS
            SELECT dsuf
                  ,qtminimo_negativacao
        FROM tbcobran_param_exc_neg_serasa
       WHERE indexcecao = 2;
       
        vr_excecao BOOLEAN := FALSE;
  BEGIN
    -- Abre o cursor de parametros da Serasa
    OPEN cr_param;
        FETCH cr_param
            INTO pr_qtminimo_negativacao
                ,pr_qtmaximo_negativacao
                ,pr_vlminimo_boleto;
    -- Se nao encontrar, atribui valores por padrao
    IF cr_param%NOTFOUND THEN
      pr_qtminimo_negativacao := 5;
      pr_qtmaximo_negativacao := 15;
      pr_vlminimo_boleto      := 20;
    END IF;
    CLOSE cr_param;
    
    -- Abre o cursor de excecoes da UF do sacado
    OPEN cr_exc_neg;
        FETCH cr_exc_neg
            INTO pr_qtminimo_negativacao
                ,pr_qtmaximo_negativacao;
    CLOSE cr_exc_neg;
    
    -- Se a UF for nula, deve-se enviar a mensagem
    IF TRIM(pr_cduf_sacado) IS NULL THEN
            pr_dstexto_dias := '(Limitado de ' || pr_qtminimo_negativacao || ' a ' || pr_qtmaximo_negativacao ||
                         ' dias)';
      FOR rw_exc_neg_2 IN cr_exc_neg_2 LOOP
        -- Se for a primeira vez, deve-se colocar o texto padrao
        IF NOT vr_excecao THEN
                    pr_dstexto_dias := pr_dstexto_dias || ' - Exceto o(s) estado(s) do ';
                    vr_excecao      := TRUE;
        ELSE
                    pr_dstexto_dias := pr_dstexto_dias || '; ';
        END IF;

        -- Incrementa a UF
                pr_dstexto_dias := pr_dstexto_dias || rw_exc_neg_2.dsuf || '-' ||
                                   rw_exc_neg_2.qtminimo_negativacao || ' dias';
        
      END LOOP;
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em pc_busca_param_negativ: ' || SQLERRM;
          
  END;                                   

  PROCEDURE pc_altera_neg_serasa(pr_flserasa IN INTEGER --> Negativar: 0-Nao / 1-Sim
                                ,pr_flposbol IN INTEGER --> Possui boleto em aberto: 0-Nao / 1-Sim
                                ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_neg_serasa
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para manipular os dados referente ao Serasa.

    Alteracoes: 
      29/08/2018 - Vitor Shimada Assanuma (GFT) - Inclusão da regra para que quando a cob estiver em um bordero não rejeitado, não deixar retirar
                     a instrução de Negativação Serasa.
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      BEGIN
        INSERT INTO tbcobran_his_cnv_serasa
                    (cdcooper, nrdconta, nrconven, dhhistorico, cdoperad, insituacao)
        VALUES
                    (vr_cdcooper, pr_nrdconta, pr_nrconven, SYSDATE, vr_cdoperad, pr_flserasa);
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao alterar dados (tbcobran_his_cnv_serasa): ' || SQLERRM;
        RAISE vr_exc_saida;
      END;
      
      -- Se foi setado para habilitar
      IF pr_flserasa = 1 THEN

        BEGIN
          UPDATE crapcob 
             SET flserasa = 1 
           WHERE cdcooper = vr_cdcooper 
             AND nrdconta = pr_nrdconta 
             AND nrcnvcob = pr_nrconven 
             AND incobran = 0 
                       AND cddespec IN (1, 2, 3); -- (01-DM,02-DS,03-NP)
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados (crapcob): ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

      -- Se existir boletos em aberto e for 
      ELSIF pr_flposbol = 1 THEN

        BEGIN
          UPDATE crapcob cob
             SET cob.flserasa = 0 
           WHERE cob.cdcooper = vr_cdcooper 
             AND cob.nrdconta = pr_nrdconta 
             AND cob.nrcnvcob = pr_nrconven 
             AND cob.incobran = 0 
             AND cob.inserasa IN (0,6)
             AND cob.cddespec IN (1,2,3) -- (01-DM,02-DS,03-NP)
             AND NOT EXISTS (
               SELECT 1 FROM craptdb tdb -- Verifica se a cobrança está em um bordero não rejeitado
                 INNER JOIN crapbdt bdt ON tdb.cdcooper = bdt.cdcooper AND tdb.nrborder = bdt.nrborder
               WHERE tdb.cdcooper = cob.cdcooper 
                 AND tdb.nrdconta = cob.nrdconta
                 AND tdb.nrcnvcob = cob.nrcnvcob 
                 AND tdb.nrdocmto = cob.nrdocmto
                 AND bdt.insitbdt <> 5
             );
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados (crapcob): ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_altera_neg_serasa;

  PROCEDURE pc_verifica_boleto_aberto(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                     ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_verifica_boleto_aberto
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar se existe boleto em aberto.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do boleto
      CURSOR cr_crapcob(pr_cdcooper IN crapcob.cdcooper%TYPE
                       ,pr_nrdconta IN crapcob.nrdconta%TYPE
                       ,pr_nrconven IN crapcob.nrcnvcob%TYPE) IS 
        SELECT 1
            FROM crapcob 
           WHERE crapcob.cdcooper = pr_cdcooper
             AND crapcob.nrdconta = pr_nrdconta
             AND crapcob.nrcnvcob = pr_nrconven 
             AND crapcob.incobran = 0 
                   AND crapcob.cddespec IN (1, 2, 3); -- (01-DM,02-DS,03-NP)
      rw_crapcob cr_crapcob%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;

    BEGIN
      -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

      -- Efetua a busca do registro
      OPEN cr_crapcob(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
            FETCH cr_crapcob
                INTO rw_crapcob;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapcob%FOUND;
      -- Fecha cursor
      CLOSE cr_crapcob;
      
      -- Se achou
      IF vr_blnfound THEN
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<boleto possui="1" />');
      ELSE
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<boleto possui="0" />');
      END IF;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Dados>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_verifica_boleto_aberto;

  -- Rotina para impressao do termo de abertura e termo de cancelamento
  PROCEDURE pc_imprimir_termo(pr_nrdconta IN crapass.nrdconta%TYPE --> Numedo da conta
                             ,pr_nmdtest1 IN VARCHAR2 --> Nome da testemunha 1
                             ,pr_cpftest1 IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 1
                             ,pr_nmdtest2 IN VARCHAR2 --> Nome da testemunha 2
                             ,pr_cpftest2 IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 2
                             ,pr_nrconven IN crapceb.nrconven%TYPE --> Numero do convenio
                             ,pr_tpimpres IN PLS_INTEGER --> 1-Termo de Abertura, 2-Termo de Encerramento, 3-Termo de Cancelamento Protesto
                             ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
    /* .............................................................................

    Programa: pc_imprimir_termo
    Sistema : Ayllos Web
    Autor   : Andrino Souza
    Data    : Janeiro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para retornar os dados para o termo de abertura e termo de encerramento

    Alteracoes: -11/03/2016 - Adptação para envio da cláusula de Reciprocidade conforme
                              indicadores selecionados. (Marcos-Supero)
    ..............................................................................*/

      -- Cursor sobre o convenio
      CURSOR cr_crapceb(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT b.nmextcop || ' - ' || b.nmrescop nmcooper
                  ,gene0002.fn_mask_cpf_cnpj(b.nrdocnpj, 2) cnpjcoop
                  ,gene0002.fn_mask_cpf_cnpj(f.nrcpfcgc, f.inpessoa) nrcpfcgc
                  ,i.dsendere || decode(greatest(0, i.nrendere), 0, '', ', ' || i.nrendere) || ' - ' ||
                   i.nmbairro dsendere
                  ,i.nmcidade
                  ,i.cdufende
                  ,gene0002.fn_mask_cep(i.nrcepend) nrcepend
                  ,to_char(e.nrconven, 'fm999G999G990') nrcnvcob
                  ,'D+' || e.qtdfloat qtdfloat
                  ,decode(nvl(e.flcooexp, 0), 1, 'Cooperado Emite e Expede', ' ') flcooexp
                  ,decode(nvl(e.flceeexp, 0), 1, 'Cooperativa Emite e Expede', ' ') flceeexp
                  ,decode(e.flserasa, '1', 'Sim', 'Não') flserasa
                  ,decode(e.flprotes, 1, 'Sim', 'Não') flprotes
                  , -- Conforme e-mail da Patricia, devera sempre ser sim para protesto
                   ' Banco ' || lpad(b.cdbcoctl, 4, '0') || ' Ag./Coop. ' || b.cdagectl || ' Conta ' ||
                   gene0002.fn_mask_conta(e.nrdconta) contadeb
                  ,f.nmprimtl
                  ,b.nmextcop
                  ,e.qtdecprz + 1 || ' dias' dsdecurs
                  ,initcap(g.nmcidade) || '/' || g.cdufdcop || ', ' || to_char(h.dtmvtolt, 'DD') || ' de ' ||
                   to_char(h.dtmvtolt, 'month', 'nls_date_language=portuguese') || 'de ' ||
                   to_char(h.dtmvtolt, 'yyyy') || '.' dsdata
                  ,d.flrecipr
                  ,e.idrecipr
                  ,decode(nvl(d.insrvprt, 0), 0, 'Nenhum', 1, 'IEPTB', 2, 'BB') insrvprt
                  ,e.cdcooper
                  ,e.nrdconta
                  ,e.nrconven
                  ,f.cdagenci
                  ,f.nrcpfcgc nrcpfcgc_sem_mask
              FROM crapenc i
                  ,crapdat h
                  ,crapage g
                  ,crapass f
                  ,crapcco d
                  ,crapcop b
                  ,crapceb e
         WHERE b.cdcooper = e.cdcooper
           AND e.cdcooper = pr_cdcooper
           AND e.nrdconta = pr_nrdconta
           AND e.nrconven = pr_nrconven
           AND d.cdcooper = e.cdcooper
           AND d.nrconven = e.nrconven
           AND f.cdcooper = e.cdcooper
           AND f.nrdconta = e.nrdconta
           AND g.cdcooper = f.cdcooper
           AND g.cdagenci = f.cdagenci
           AND h.cdcooper = e.cdcooper
           AND i.cdcooper = f.cdcooper
           AND i.nrdconta = f.nrdconta
           AND i.idseqttl = 1
               AND i.tpendass = decode(f.inpessoa, 1, 10, 9);
      rw_crapceb cr_crapceb%ROWTYPE;
      
      -- Busca do prazo e dos indicadores da reciprocidade
      CURSOR cr_recipro(pr_idcalculo IN tbrecip_calculo.idcalculo_reciproci%TYPE) IS
            SELECT rca.qtdmes_retorno_reciproci || ' (' ||
                   decode(rca.qtdmes_retorno_reciproci, 3, 'três', 6, 'seis', 9, 'nove', 'doze') || ')' qtdmes_retorno_reciproci
              ,rind.nmindicador
          FROM tbrecip_calculo        rca
              ,tbrecip_indica_calculo rica
              ,tbrecip_indicador      rind
         WHERE rca.idcalculo_reciproci = pr_idcalculo
           AND rca.idcalculo_reciproci = rica.idcalculo_reciproci
               AND rica.idindicador = rind.idindicador;
      
      -- Cursor sobre os representantes
      CURSOR cr_crapavt(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT nvl(TRIM(a.nmdavali), b.nmprimtl) nmrepres
                  ,a.dsproftl
              FROM crapass b
                  ,crapavt a
         WHERE a.cdcooper = pr_cdcooper
               AND a.nrdconta = pr_nrdconta
           AND a.tpctrato = 6
               AND b.cdcooper(+) = a.cdcooper
               AND b.nrdconta(+) = a.nrdctato;

      -- Cria o registro de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Tratamento de erros
        vr_exc_saida EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
        vr_tab_erro gene0001.typ_tab_erro;
      vr_des_reto VARCHAR2(10);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_xml_temp    VARCHAR2(32726) := '';
      vr_clob        CLOB;
      vr_existe      BOOLEAN := FALSE;
      vr_cpftest1    VARCHAR2(15);
      vr_cpftest2    VARCHAR2(15);
        vr_nom_direto  VARCHAR2(200); --> Diretório para gravação do arquivo
        vr_dsjasper    VARCHAR2(100); --> nome do jasper a ser usado
        vr_nmarqim     VARCHAR2(50); --> nome do arquivo PDF
			vr_xml_recipro VARCHAR2(32767); --> informações da reciprocidade
      vr_qrcode      VARCHAR2(32767); --> QR Code enviado para o XML
      vr_cdtipdoc    VARCHAR2(32767); --> Tipo do documento a ser usado no QR Code
    
  BEGIN
      -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Abre o cursor de data
      OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      
      -- Monta documento XML de Dados
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><adesao>');
      
      OPEN cr_crapceb(vr_cdcooper);
        FETCH cr_crapceb
            INTO rw_crapceb;
      IF cr_crapceb%NOTFOUND THEN
        CLOSE cr_crapceb;
        vr_dscritic := 'Convenio informado inexistente!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapceb;

      -- Formata a mascara do CPF da testemunha 1
        IF nvl(pr_cpftest1, 0) = 0 THEN
        vr_cpftest1 := NULL;
      ELSE
            vr_cpftest1 := gene0002.fn_mask_cpf_cnpj(pr_cpftest1, 1);
      END IF;
      
      -- Formata a mascara do CPF da testemunha 2
        IF nvl(pr_cpftest2, 0) = 0 THEN
        vr_cpftest2 := NULL;
      ELSE
            vr_cpftest2 := gene0002.fn_mask_cpf_cnpj(pr_cpftest2, 1);
      END IF;
      
      /* Somente para o termo de adesão com Reciprocidade */
        IF pr_tpimpres = 1 AND rw_crapceb.flrecipr = 1 AND rw_crapceb.idrecipr > 0 THEN
        /* Também iremos buscar o prazo da reciprocidade e os indicadores selecionados */
        FOR rw_recipro IN cr_recipro(rw_crapceb.idrecipr) LOOP
          -- No primeiro registro enviamos também o prazo
          IF vr_xml_recipro IS NULL THEN
            -- Inicializamos a tag
                    vr_xml_recipro := '<reciprocidade inreproc="yes" qtmesretorno="' ||
                                      rw_recipro.qtdmes_retorno_reciproci || '">' || chr(10);
          END IF;
          -- Em todos os registros enviar o indicador atual
                vr_xml_recipro := vr_xml_recipro || '<indicador><nmindicador>' || rw_recipro.nmindicador ||
                                  '</nmindicador></indicador>' || chr(10);
        END LOOP;
        /* Se há informação de reciprocidade */
        IF vr_xml_recipro IS NOT NULL THEN
          -- Finalizamos a tag
                vr_xml_recipro := vr_xml_recipro || '</reciprocidade>' || chr(10);
        END IF;
			END IF;
      
      -- Definir o TIPO DE DOCUMENTO de acordo com o layout.
      -- OBS.: Verificar os códigos de cancelamento. Por enquanto está igual adesão.
        IF (nvl(pr_tpimpres, 1) = 1) THEN
            -- Se for Adesao
            IF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 11) THEN
          vr_cdtipdoc := 106; -- PF
            ELSIF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 14) THEN
          vr_cdtipdoc := 115; -- PJ
        END IF;
        ELSE
            -- Cancelamento
            IF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 11) THEN
          vr_cdtipdoc := 106; -- PF
            ELSIF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 14) THEN
          vr_cdtipdoc := 115; -- PJ
        END IF;
      END IF;
      
      -- Gera Pendencia de digitalizacao do documento
        digi0001.pc_grava_pend_digitalizacao(pr_cdcooper => vr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_idseqttl => 1
                                          ,pr_nrcpfcgc => rw_crapceb.nrcpfcgc_sem_mask
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_tpdocmto => CASE
                                                                WHEN vr_cdtipdoc = 106 THEN
                                                                 25
                                                                ELSE
                                                                 32
                                                            END -- Termo de Adesao do protesto - 106(PF)/115(PJ)
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_nrseqdoc => pr_nrconven
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

        vr_qrcode := rw_crapceb.cdcooper || '_' || rw_crapceb.cdagenci || '_' ||
                     TRIM(gene0002.fn_mask_conta(rw_crapceb.nrdconta)) || '_' || 0 || '_' ||
                     rw_crapceb.nrconven || '_' || 0 || '_' || vr_cdtipdoc; -- 
             
      -- Escreve os dados principais
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<cooperativa>' || chr(10) || '<nmcooper>' ||
                                                     rw_crapceb.nmcooper || '</nmcooper>' || chr(10) ||
                                                     '<cnpjcoop>' || rw_crapceb.cnpjcoop || '</cnpjcoop>' ||
                                                     chr(10) || '</cooperativa>' || chr(10) || '<dsqrcode>' ||
                                                     vr_qrcode || '</dsqrcode>' || chr(10) || '<cooperado>' ||
                                                     chr(10) || '<nmprimtl>' || rw_crapceb.nmprimtl ||
                                                     '</nmprimtl>' || chr(10) || '<nrcpfcgc>' ||
                                                     rw_crapceb.nrcpfcgc || '</nrcpfcgc>' || chr(10) ||
                                                     '<dsendere>' || rw_crapceb.dsendere || '</dsendere>' ||
                                                     chr(10) || '<nmcidade>' || rw_crapceb.nmcidade ||
                                                     '</nmcidade>' || chr(10) || '<cdufende>' ||
                                                     rw_crapceb.cdufende || '</cdufende>' || chr(10) ||
                                                     '<nrcepend>' || rw_crapceb.nrcepend || '</nrcepend>' ||
                                                     chr(10) || '<nrcnvcob>' || rw_crapceb.nrcnvcob ||
                                                     '</nrcnvcob>' || chr(10) || '<flcooexp>' ||
                                                     rw_crapceb.flcooexp || '</flcooexp>' || chr(10) ||
                                                     '<flceeexp>' || rw_crapceb.flceeexp || '</flceeexp>' ||
                                                     chr(10) || '<qtdfloat>' || rw_crapceb.qtdfloat ||
                                                     '</qtdfloat>' || chr(10) || '<flserasa>' ||
                                                     rw_crapceb.flserasa || '</flserasa>' || chr(10) ||
                                                     '<flprotes>' || rw_crapceb.flprotes || '</flprotes>' ||
                                                     chr(10) || '<insrvprt>' || rw_crapceb.insrvprt ||
                                                     '</insrvprt>' || chr(10) || '<dsdecurs>' ||
                                                     rw_crapceb.dsdecurs || '</dsdecurs>' || chr(10) ||
                                                     '<nmextcop>' || rw_crapceb.nmextcop || '</nmextcop>' ||
                                                     chr(10) || '<dsdata>' || rw_crapceb.dsdata || '</dsdata>' ||
                                                     chr(10) || '<contadeb>' || rw_crapceb.contadeb ||
                                                     '</contadeb>' || chr(10) || '</cooperado>' || chr(10));
      -- Se houver reciprocidade
      IF vr_xml_recipro IS NOT NULL THEN
        -- Enviamos ao xml do relatório
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => vr_xml_recipro);
      END IF;
                                                   
      -- Escreve os dados de testemunhas e representantes
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<testemunhas>' || chr(10) || '<nmdtest1>' || pr_nmdtest1 ||
                                                     '</nmdtest1>' || chr(10) || '<cpftest1>' || vr_cpftest1 ||
                                                     '</cpftest1>' || chr(10) || '<nmdtest2>' || pr_nmdtest2 ||
                                                     '</nmdtest2>' || chr(10) || '<cpftest2>' || vr_cpftest2 ||
                                                     '</cpftest2>' || chr(10) || '</testemunhas>' || chr(10) ||
                                                     '<representantes>' || chr(10));
      -- Efetua loop sobre os representantes
      FOR rw_crapavt IN cr_crapavt(vr_cdcooper) LOOP
        vr_existe := TRUE;
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<representante>' || chr(10) || '<nmrepres>' ||
                                                         rw_crapavt.nmrepres || '</nmrepres>' || chr(10) ||
                                                         '<dsproftl>' || rw_crapavt.dsproftl || '</dsproftl>' ||
                                                         chr(10) || '</representante>' || chr(10));
      END LOOP;
      
      -- Se nao existir representante, apenas insere a TAG de inexistente
      IF NOT vr_existe THEN
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<representante/>' || chr(10));
      END IF;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</representantes>' || chr(10) || '</adesao>'
                             ,pr_fecha_xml      => TRUE);

      -- Verifica o tipo que devera ser impresso
        IF pr_tpimpres = 1 THEN
            -- Se for Adesao
        vr_dsjasper := 'termo_adesao_cob_reg.jasper';
            vr_nmarqim  := '/TermoAbertura_' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
        ELSIF pr_tpimpres = 2 THEN
            -- Se for cancelamento
        vr_dsjasper := 'termo_cancel_cob_reg.jasper';
            vr_nmarqim  := '/TermoCancelamento' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
        ELSE
            -- Se for cancelamento do protesto
        vr_dsjasper := 'termo_cancel_protesto.jasper';
            vr_nmarqim  := '/TermoCancelamento' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
      END IF;
      
      -- Solicita geracao do PDF
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper
                                   ,pr_cdprogra  => 'ATENDA'
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_clob
                                   ,pr_dsxmlnode => '/adesao'
                                   ,pr_dsjasper  => vr_dsjasper
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_direto || vr_nmarqim
                                   ,pr_cdrelato  => 684
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 80
                                   ,pr_sqcabrel  => 1
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => ' '
                                   ,pr_nrcopias  => 1
                                   ,pr_nrvergrl  => 1
                                   ,pr_parser    => 'R'
                                   ,pr_des_erro  => vr_dscritic);

      -- copia contrato pdf do diretorio da cooperativa para servidor web
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_nom_direto || vr_nmarqim
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob); 

      -- Criar XML de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqim ||
                                       '</nmarqpdf>');
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_negativa_serasa: ' || SQLERRM;
      ROLLBACK;
      -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END;

    FUNCTION fn_retorna_modalidade(flcooexp crapceb.flcooexp%TYPE
                                  ,flceeexp crapceb.flceeexp%TYPE) RETURN VARCHAR2 IS
    BEGIN
        IF flcooexp = 1 AND flceeexp = 1 THEN
            RETURN 'Cooperativa (CEE) e Cooperado (COO) emitem e expedem';
        ELSIF flceeexp = 1 THEN
            RETURN 'Cooperativa emite e expede (CEE)';
        ELSIF flcooexp = 1 THEN
            RETURN 'Cooperado emite e expede (COO)';
        ELSE
            RETURN '';
        END IF;
  END;

    -- Rotina para impressao do termo de abertura e termo de cancelamento
    PROCEDURE pc_imprimir_termo_reciproci(pr_nrdconta            IN crapass.nrdconta%TYPE --> Numedo da conta
                                         ,pr_nmdtest1            IN VARCHAR2 --> Nome da testemunha 1
                                         ,pr_cpftest1            IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 1
                                         ,pr_nmdtest2            IN VARCHAR2 --> Nome da testemunha 2
                                         ,pr_cpftest2            IN crapass.nrcpfcgc%TYPE --> Cpf da testemunha 2
                                         ,pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE DEFAULT 0
                                         ,pr_tpimpres            IN PLS_INTEGER --> 1-Termo de Abertura, 2-Termo de Encerramento, 3-Termo de Cancelamento Protesto
                                         ,pr_xmllog              IN VARCHAR2 --> XML com informacoes de LOG
                                         ,pr_cdcritic            OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic            OUT VARCHAR2 --> Descricao da critica
                                         ,pr_retxml              IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo            OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro            OUT VARCHAR2) IS
        --> Erros do processo
        /* .............................................................................
        
        Programa: pc_imprimir_termo_reciproci
        Sistema : Ayllos Web
        Autor   : Augusto (Supero)
        Data    : Setembro/2018                 Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para retornar os dados para o termo de abertura e termo de encerramento
        
        Alteracoes: -11/03/2016 - Adptação para envio da cláusula de Reciprocidade conforme
                                  indicadores selecionados. (Marcos-Supero)
        ..............................................................................*/
    
        -- Cursor sobre o convenio
        CURSOR cr_crapceb(pr_cdcooper            crapcop.cdcooper%TYPE
                         ,pr_idcalculo_reciproci crapceb.idrecipr%TYPE) IS
            SELECT b.nmextcop || ' - ' || b.nmrescop nmcooper
                  ,gene0002.fn_mask_cpf_cnpj(b.nrdocnpj, 2) cnpjcoop
                  ,gene0002.fn_mask_cpf_cnpj(f.nrcpfcgc, f.inpessoa) nrcpfcgc
                  ,i.dsendere || decode(greatest(0, i.nrendere), 0, '', ', ' || i.nrendere) || ' - ' ||
                   i.nmbairro dsendere
                  ,i.nmcidade
                  ,i.cdufende
                  ,gene0002.fn_mask_cep(i.nrcepend) nrcepend
                  ,'D+' || e.qtdfloat qtdfloat
                  , -- Conforme e-mail da Patricia, devera sempre ser sim para protesto
                   ' Banco ' || lpad(b.cdbcoctl, 4, '0') || ' Ag./Coop. ' || b.cdagectl || ' Conta ' ||
                   gene0002.fn_mask_conta(e.nrdconta) contadeb
                  ,f.nmprimtl
                  ,b.nmextcop
                  ,initcap(g.nmcidade) || '/' || g.cdufdcop || ', ' || to_char(h.dtmvtolt, 'DD') || ' de ' ||
                   to_char(h.dtmvtolt, 'month', 'nls_date_language=portuguese') || 'de ' ||
                   to_char(h.dtmvtolt, 'yyyy') || '.' dsdata
                  ,d.flrecipr
                  ,e.idrecipr
                  ,decode(nvl(d.insrvprt, 0), 0, 'Nenhum', 1, 'IEPTB', 2, 'BB') insrvprt
                  ,e.cdcooper
                  ,e.nrdconta
                  ,f.cdagenci
                  ,f.nrcpfcgc nrcpfcgc_sem_mask
                  ,nvl(c.vldesconto_concedido_coo, 0) || '%' vldesconto_concedido_coo
                  ,nvl(c.vldesconto_concedido_cee, 0) || '%' vldesconto_concedido_cee
                  ,nvl(c.vldesconto_adicional_coo, 0) || '%' vldesconto_adicional_coo
                  ,nvl(c.vldesconto_adicional_cee, 0) || '%' vldesconto_adicional_cee
                  ,'Periodo do desconto: ' || nvl(c.qtdmes_retorno_reciproci, 0) ||
                   ' mes(es), contado(s) da aprovação da Cooperativa' qtdmes_retorno_reciproci
                  ,'Periodo do desconto: ' || nvl(c.idfim_desc_adicional_coo, 0) ||
                   ' mes(es), contado(s) da aprovação da Cooperativa' idfim_desc_adicional_coo
                  ,'Periodo do desconto: ' || nvl(c.idfim_desc_adicional_cee, 0) ||
                   ' mes(es), contado(s) da aprovação da Cooperativa' idfim_desc_adicional_cee
              FROM crapenc         i
                  ,crapdat         h
                  ,crapage         g
                  ,crapass         f
                  ,crapcco         d
                  ,crapcop         b
                  ,crapceb         e
                  ,tbrecip_calculo c
             WHERE b.cdcooper = e.cdcooper
               AND e.cdcooper = pr_cdcooper
               AND e.nrdconta = pr_nrdconta
               AND e.idrecipr = pr_idcalculo_reciproci
               AND d.cdcooper = e.cdcooper
               AND d.nrconven = e.nrconven
               AND f.cdcooper = e.cdcooper
               AND f.nrdconta = e.nrdconta
               AND g.cdcooper = f.cdcooper
               AND g.cdagenci = f.cdagenci
               AND h.cdcooper = e.cdcooper
               AND i.cdcooper = f.cdcooper
               AND i.nrdconta = f.nrdconta
               AND i.idseqttl = 1
               AND c.idcalculo_reciproci = e.idrecipr
               AND i.tpendass = decode(f.inpessoa, 1, 10, 9);
        rw_crapceb cr_crapceb%ROWTYPE;
    
        -- Busca do prazo e dos indicadores da reciprocidade
        CURSOR cr_recipro(pr_idcalculo IN tbrecip_calculo.idcalculo_reciproci%TYPE) IS
            SELECT rca.qtdmes_retorno_reciproci || ' (' ||
                   decode(rca.qtdmes_retorno_reciproci, 3, 'três', 6, 'seis', 9, 'nove', 'doze') || ')' qtdmes_retorno_reciproci
                  ,rind.nmindicador
              FROM tbrecip_calculo        rca
                  ,tbrecip_indica_calculo rica
                  ,tbrecip_indicador      rind
             WHERE rca.idcalculo_reciproci = pr_idcalculo
               AND rca.idcalculo_reciproci = rica.idcalculo_reciproci
               AND rica.idindicador = rind.idindicador;
    
        -- Cursor sobre os representantes
        CURSOR cr_crapavt(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT nvl(TRIM(a.nmdavali), b.nmprimtl) nmrepres
                  ,a.dsproftl
              FROM crapass b
                  ,crapavt a
             WHERE a.cdcooper = pr_cdcooper
               AND a.nrdconta = pr_nrdconta
               AND a.tpctrato = 6
               AND b.cdcooper(+) = a.cdcooper
               AND b.nrdconta(+) = a.nrdctato;
    
        -- Cursor sobre os convenios
        CURSOR cr_convenios(pr_cdcooper            crapceb.cdcooper%TYPE
                           ,pr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE
                           ,pr_nrdconta            crapass.nrdconta%TYPE) IS
        
            SELECT crapceb.nrconven
                  ,crapcco.dsorgarq
                  ,crapceb.insitceb
                  ,crapceb.flgregon
                  ,crapceb.flgpgdiv
                  ,crapceb.qtdfloat
                  ,'Modalidade: ' ||
                   fn_retorna_modalidade(nvl(crapceb.flcooexp, 0), nvl(crapceb.flceeexp, 0)) modalidade
                  ,decode(crapceb.flserasa, '1', 'Sim', 'Não') flserasa
                  ,decode(crapceb.flprotes, 1, 'Sim', 'Não') flprotes
                  ,crapceb.insrvprt
                  ,crapceb.qtlimmip
                  ,crapceb.qtlimaxp
                  ,crapceb.qtdecprz
                  ,crapceb.inarqcbr
                  ,crapceb.inenvcob
                  ,crapceb.cddemail
                  ,crapceb.flgcebhm
                  ,(SELECT COUNT(1)
                      FROM crapcob
                     WHERE crapcob.cdcooper = pr_cdcooper
                       AND crapcob.nrdconta = pr_nrdconta
                       AND crapcob.nrcnvcob = crapceb.nrconven) AS qtbolcob
              FROM crapceb
                  ,crapcco
             WHERE crapcco.cdcooper = crapceb.cdcooper
               AND crapcco.nrconven = crapceb.nrconven
               AND crapceb.idrecipr = pr_idcalculo_reciproci
               AND crapceb.cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
        rw_convenios cr_convenios%ROWTYPE;
    
        -- Cria o registro de data
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_tab_erro gene0001.typ_tab_erro;
        vr_des_reto VARCHAR2(10);
    
        -- Variaveis de log
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis
        vr_xml_temp    VARCHAR2(32726) := '';
        vr_clob        CLOB;
        vr_existe      BOOLEAN := FALSE;
        vr_cpftest1    VARCHAR2(15);
        vr_cpftest2    VARCHAR2(15);
        vr_nom_direto  VARCHAR2(200); --> Diretório para gravação do arquivo
        vr_dsjasper    VARCHAR2(100); --> nome do jasper a ser usado
        vr_nmarqim     VARCHAR2(50); --> nome do arquivo PDF
        vr_xml_recipro VARCHAR2(32767); --> informações da reciprocidade
        vr_cdtipdoc    VARCHAR2(32767); --> Tipo do documento a ser usado no QR Code
    
    BEGIN
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Abre o cursor de data
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        --busca diretorio padrao da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_nmsubdir => 'rl');
    
        -- Monta documento XML de Dados
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><adesao>');
    
        OPEN cr_crapceb(vr_cdcooper, pr_idcalculo_reciproci);
        FETCH cr_crapceb
            INTO rw_crapceb;
        IF cr_crapceb%NOTFOUND THEN
            CLOSE cr_crapceb;
            vr_dscritic := 'Convenio informado inexistente!';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapceb;
    
        -- Formata a mascara do CPF da testemunha 1
        IF nvl(pr_cpftest1, 0) = 0 THEN
            vr_cpftest1 := NULL;
        ELSE
            vr_cpftest1 := gene0002.fn_mask_cpf_cnpj(pr_cpftest1, 1);
        END IF;
    
        -- Formata a mascara do CPF da testemunha 2
        IF nvl(pr_cpftest2, 0) = 0 THEN
            vr_cpftest2 := NULL;
        ELSE
            vr_cpftest2 := gene0002.fn_mask_cpf_cnpj(pr_cpftest2, 1);
        END IF;
    
        /* Somente para o termo de adesão com Reciprocidade */
        IF pr_tpimpres = 1 AND rw_crapceb.flrecipr = 1 AND rw_crapceb.idrecipr > 0 THEN
            /* Também iremos buscar o prazo da reciprocidade e os indicadores selecionados */
            FOR rw_recipro IN cr_recipro(rw_crapceb.idrecipr) LOOP
                -- No primeiro registro enviamos também o prazo
                IF vr_xml_recipro IS NULL THEN
                    -- Inicializamos a tag
                    vr_xml_recipro := '<reciprocidade inreproc="yes" qtmesretorno="' ||
                                      rw_recipro.qtdmes_retorno_reciproci || '">' || chr(10);
                END IF;
                -- Em todos os registros enviar o indicador atual
                vr_xml_recipro := vr_xml_recipro || '<indicador><nmindicador>' || rw_recipro.nmindicador ||
                                  '</nmindicador></indicador>' || chr(10);
            END LOOP;
            /* Se há informação de reciprocidade */
            IF vr_xml_recipro IS NOT NULL THEN
                -- Finalizamos a tag
                vr_xml_recipro := vr_xml_recipro || '</reciprocidade>' || chr(10);
            END IF;
        END IF;
    
        -- Definir o TIPO DE DOCUMENTO de acordo com o layout.
        -- OBS.: Verificar os códigos de cancelamento. Por enquanto está igual adesão.
        IF (nvl(pr_tpimpres, 1) = 1) THEN
            -- Se for Adesao
            IF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 11) THEN
                vr_cdtipdoc := 106; -- PF
            ELSIF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 14) THEN
                vr_cdtipdoc := 115; -- PJ
            END IF;
        ELSE
            -- Cancelamento
            IF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 11) THEN
                vr_cdtipdoc := 106; -- PF
            ELSIF (length(REPLACE(REPLACE(REPLACE(rw_crapceb.nrcpfcgc, '-', ''), '.', ''), '/', '')) = 14) THEN
                vr_cdtipdoc := 115; -- PJ
            END IF;
        END IF;
    
        -- Gera Pendencia de digitalizacao do documento
        digi0001.pc_grava_pend_digitalizacao(pr_cdcooper => vr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_idseqttl => 1
                                            ,pr_nrcpfcgc => rw_crapceb.nrcpfcgc_sem_mask
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_tpdocmto => CASE
                                                                WHEN vr_cdtipdoc = 106 THEN
                                                                 25
                                                                ELSE
                                                                 32
                                                            END -- Termo de Adesao do protesto - 106(PF)/115(PJ)
                                            ,pr_cdoperad => vr_cdoperad
                                            ,pr_nrseqdoc => pr_idcalculo_reciproci
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
    
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
    
        -- Escreve os dados principais
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<cooperativa>' || chr(10) || '<nmcooper>' ||
                                                     rw_crapceb.nmcooper || '</nmcooper>' || chr(10) ||
                                                     '<cnpjcoop>' || rw_crapceb.cnpjcoop || '</cnpjcoop>' ||
                                                     chr(10) || '</cooperativa>' || chr(10) || '<cooperado>' ||
                                                     chr(10) || '<nmprimtl>' || rw_crapceb.nmprimtl ||
                                                     '</nmprimtl>' || chr(10) || '<nrcpfcgc>' ||
                                                     rw_crapceb.nrcpfcgc || '</nrcpfcgc>' || chr(10) ||
                                                     '<dsendere>' || rw_crapceb.dsendere || '</dsendere>' ||
                                                     chr(10) || '<nmcidade>' || rw_crapceb.nmcidade ||
                                                     '</nmcidade>' || chr(10) || '<cdufende>' ||
                                                     rw_crapceb.cdufende || '</cdufende>' || chr(10) ||
                                                     '<nrcepend>' || rw_crapceb.nrcepend || '</nrcepend>' ||
                                                     chr(10) ||'<qtdfloat>' || rw_crapceb.qtdfloat ||
                                                     '</qtdfloat>' || chr(10) || chr(10) || '<insrvprt>' ||
                                                     rw_crapceb.insrvprt || '</insrvprt>' || chr(10) ||
                                                     '<nmextcop>' || rw_crapceb.nmextcop || '</nmextcop>' ||
                                                     chr(10) || '<dsdata>' || rw_crapceb.dsdata || '</dsdata>' ||
                                                     chr(10) || '<contadeb>' || rw_crapceb.contadeb ||
                                                     '</contadeb>' || chr(10) || '</cooperado>' || chr(10));
        -- Se houver reciprocidade
        IF vr_xml_recipro IS NOT NULL THEN
            -- Enviamos ao xml do relatório
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => vr_xml_recipro);
        END IF;
    
        -- Escreve os dados do desconto
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<desconto>' || chr(10) || '<concedido_coo>' ||
                                                     rw_crapceb.vldesconto_concedido_coo || '</concedido_coo>' ||
                                                     chr(10) || '<concedido_cee>' ||
                                                     rw_crapceb.vldesconto_concedido_cee || '</concedido_cee>' ||
                                                     chr(10) || '<adicional_coo>' ||
                                                     rw_crapceb.vldesconto_adicional_coo || '</adicional_coo>' ||
                                                     chr(10) || '<adicional_cee>' ||
                                                     rw_crapceb.vldesconto_adicional_cee || '</adicional_cee>' ||
                                                     chr(10) || '<fim_adicional_coo>' ||
                                                     rw_crapceb.idfim_desc_adicional_coo ||
                                                     '</fim_adicional_coo>' || chr(10) ||
                                                     '<fim_adicional_cee>' ||
                                                     rw_crapceb.idfim_desc_adicional_cee ||
                                                     '</fim_adicional_cee>' || chr(10) || '<fim_contrato>' ||
                                                     rw_crapceb.qtdmes_retorno_reciproci || '</fim_contrato>' ||
                                                     chr(10) || '</desconto>' || chr(10));
    
        -- Escreve os dados de testemunhas e representantes
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<testemunhas>' || chr(10) || '<nmdtest1>' || pr_nmdtest1 ||
                                                     '</nmdtest1>' || chr(10) || '<cpftest1>' || vr_cpftest1 ||
                                                     '</cpftest1>' || chr(10) || '<nmdtest2>' || pr_nmdtest2 ||
                                                     '</nmdtest2>' || chr(10) || '<cpftest2>' || vr_cpftest2 ||
                                                     '</cpftest2>' || chr(10) || '</testemunhas>' || chr(10) ||
                                                     '<representantes>' || chr(10));
        -- Efetua loop sobre os representantes
        FOR rw_crapavt IN cr_crapavt(vr_cdcooper) LOOP
            vr_existe := TRUE;
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<representante>' || chr(10) || '<nmrepres>' ||
                                                         rw_crapavt.nmrepres || '</nmrepres>' || chr(10) ||
                                                         '<dsproftl>' || rw_crapavt.dsproftl || '</dsproftl>' ||
                                                         chr(10) || '</representante>' || chr(10));
        END LOOP;
    
        -- Se nao existir representante, apenas insere a TAG de inexistente
        IF NOT vr_existe THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<representante/>' || chr(10));
        END IF;
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</representantes>' || chr(10)
                               ,pr_fecha_xml      => TRUE);
    
        -- Escreve os dados dos convenios
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<convenios>' || chr(10));
    
        -- Efetua loop sobre os convenios
        FOR rw_convenios IN cr_convenios(vr_cdcooper, pr_idcalculo_reciproci, pr_nrdconta) LOOP
            vr_existe := TRUE;
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<convenio>' || chr(10) || '<nrconven>' ||
                                                         rw_convenios.nrconven || '</nrconven>' || chr(10) ||
                                                         '<qtdecprz>' || rw_convenios.qtdecprz ||
                                                         '</qtdecprz>' || chr(10) || '<qtdfloat>' ||
                                                         rw_convenios.qtdfloat || '</qtdfloat>' || chr(10) ||
                                                         '<modalidade>' || rw_convenios.modalidade ||
                                                         '</modalidade>' || chr(10) || '<flserasa>' ||
                                                         rw_convenios.flserasa || '</flserasa>' || chr(10) ||
                                                         '<flprotes>' || rw_convenios.flprotes ||
                                                         '</flprotes>' || chr(10) || '</convenio>' || chr(10));
        
        END LOOP;
    
        -- Se nao existir convenio, apenas insere a TAG de inexistente        
        IF NOT vr_existe THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<convenios/>' || chr(10));
        END IF;
    
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</convenios>' || chr(10) || '</adesao>'
                               ,pr_fecha_xml      => TRUE);
    
        -- Verifica o tipo que devera ser impresso
        IF pr_tpimpres = 1 THEN
            -- Se for Adesao
            vr_dsjasper := 'termo_adesao_cob_reg_novo.jasper';
            vr_nmarqim  := '/TermoAbertura_' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
        ELSIF pr_tpimpres = 2 THEN
            -- Se for cancelamento
            vr_dsjasper := 'termo_cancel_cob_reg.jasper';
            vr_nmarqim  := '/TermoCancelamento' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
        ELSE
            -- Se for cancelamento do protesto
            vr_dsjasper := 'termo_cancel_protesto.jasper';
            vr_nmarqim  := '/TermoCancelamento' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
        END IF;
    
        -- Solicita geracao do PDF
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper
                                   ,pr_cdprogra  => 'ATENDA'
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_clob
                                   ,pr_dsxmlnode => '/adesao'
                                   ,pr_dsjasper  => vr_dsjasper
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_direto || vr_nmarqim
                                   ,pr_cdrelato  => 684
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 80
                                   ,pr_sqcabrel  => 1
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => ' '
                                   ,pr_nrcopias  => 1
                                   ,pr_parser    => 'R'
                                   ,pr_nrvergrl  => 1
                                   ,pr_des_erro  => vr_dscritic);
    
        -- copia contrato pdf do diretorio da cooperativa para servidor web
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_nom_direto || vr_nmarqim
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
    
        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);
    
        -- Criar XML de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqim ||
                                       '</nmarqpdf>');
    EXCEPTION
        WHEN vr_exc_saida THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            ROLLBACK;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral em pc_negativa_serasa: ' || SQLERRM;
            ROLLBACK;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END;

END sspc0002;
/
