CREATE OR REPLACE PACKAGE CECRED.RECP0001 IS

  -- Verifica se existe contrato de acordo na situacao informada
  PROCEDURE pc_verifica_situacao_acordo(pr_cdcooper         IN crapepr.cdcooper%TYPE -- Codigo da Cooperativa
                                       ,pr_nrdconta         IN crapepr.nrdconta%TYPE -- Numero da Conta
                                       ,pr_nrctremp         IN crapepr.nrctremp%TYPE -- Numero do contrato
                                       ,pr_cdorigem         IN crapepr.cdorigem%TYPE -- Codigo da Origem
                                       ,pr_flgretativo     OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretquitado   OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretcancelado OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_cdcritic        OUT INTEGER               -- Codigo de criticia
                                       ,pr_dscritic        OUT VARCHAR2);            -- Descricao da critica

  -- Verifica se existe contrato de acordo ativo
  PROCEDURE pc_verifica_acordo_ativo(pr_cdcooper  IN crapepr.cdcooper%TYPE  -- Código da Cooperativa
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE  -- Número da Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE  -- Número do contrato
                                    ,pr_cdorigem  IN crapepr.cdorigem%TYPE -- Codigo da Origem
                                    ,pr_flgativo OUT INTEGER                -- [0 - NAO ATIVO] / [1 - ATIVO]
                                    ,pr_cdcritic OUT INTEGER                -- Código de críticia
                                    ,pr_dscritic OUT VARCHAR2);             -- Descrição da crítica
  
  -- Retorna valor bloqueado em acordos
  PROCEDURE pc_ret_vlr_bloq_acordo(pr_cdcooper  IN crapepr.cdcooper%TYPE           -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapepr.nrdconta%TYPE           -- Número da Conta
                                  ,pr_vlblqaco OUT tbrecup_acordo.vlbloqueado%TYPE -- Retorna o valor bloqueado
                                  ,pr_cdcritic OUT INTEGER                         -- Código de críticia
                                  ,pr_dscritic OUT VARCHAR2);                      -- Descrição da crítica
    
  -- Efetuar o calculo do lançamento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_conta(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                   ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                   ,pr_cdoperad  IN VARCHAR2                     -- Código do cooperado
                                   ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                   ,pr_vlsddisp  IN NUMBER                       -- Valor do saldo disponível
                                   ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                   ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                   ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                   ,pr_dscritic OUT VARCHAR2 );                  -- Descrição da crítica
                                   
  -- Realizar o calculo e pagamento de prejuízo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                        ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo                              
                                        ,pr_tpemprst  IN crapepr.tpemprst%TYPE        -- Tipo do empréstimo
                                        ,pr_vlprejuz  IN crapepr.vlprejuz%TYPE        -- Valor do prejuízo
                                        ,pr_vlsdprej  IN crapepr.vlsdprej%TYPE        -- Saldo do prejuízo
                                        ,pr_vlsprjat  IN crapepr.vlsprjat%TYPE        -- Saldo anterior do prejuízo
                                        ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE        -- Valor da prestação do empréstimo
                                        ,pr_vlttmupr  IN crapepr.vlttmupr%TYPE        -- Valor total da multa do prejuízo
                                        ,pr_vlpgmupr  IN crapepr.vlpgmupr%TYPE        -- Valor pago da multa do prejuízo
                                        ,pr_vlttjmpr  IN crapepr.vlttjmpr%TYPE        -- Valor total dos juros do prejuízo
                                        ,pr_vlpgjmpr  IN crapepr.vlpgjmpr%TYPE        -- Valor pago dos juros do prejuízo
                                        ,pr_cdoperad  IN VARCHAR2                     -- Código do cooperado
                                        ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                        ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                        ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                        ,pr_vliofcpl  IN crapepr.vliofcpl%TYPE        -- Valor do IOF complementar
                                        ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                        ,pr_dscritic OUT VARCHAR2);                   -- Descrição da crítica
                                        
                                        
  -- Realizar o calculo e pagamento de folha de pagamento
  PROCEDURE pc_pagar_emprestimo_folha(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                     ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo 
                                     ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                     ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                     ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- Código da linha de crédito do empréstimo
                                     ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                     ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                     ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                     ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                     ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                     ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empréstimo
                                     ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do último pagamento
                                     ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                     ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                     ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                     ,pr_cdoperad  IN VARCHAR2                     -- Código do operador
                                     ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                     ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                     ,pr_dscritic OUT VARCHAR2);                   -- Descrição da crítica
  
  -- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                  ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- Código da linha de crédito do empréstimo
                                  ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                  ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                  ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                  ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empréstimo
                                  ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do último pagamento
                                  ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                  ,pr_idorigem  IN NUMBER                       -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                     -- Código do operador
                                  ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                  ,pr_dscritic OUT VARCHAR2);                   -- Descrição da crítica
                                  
  -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE         -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE         -- Número da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE         -- Código da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE   -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE         -- Número do contrato de empréstimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE  -- Número do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE         -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE         -- Valor anterior do saldo devedor
                                  ,pr_vlparcel  IN NUMBER                        -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                  ,pr_idorigem  IN NUMBER                        -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                      -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                      -- Código do operador
                                  ,pr_idvlrmin OUT NUMBER                        -- Indica que houve critica do valor minimo
                                  ,pr_vltotpag OUT NUMBER                        -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                        -- Código de críticia
                                  ,pr_dscritic OUT VARCHAR2);                    -- Descrição da crítica
   
  -- Efetuar o calculo do lançamento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- Número da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- Código da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE -- Datas da cooperativa
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- Número do contrato de empréstimo 
                                        ,pr_nracordo  IN NUMBER                      -- Número do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- Código do operador
                                        ,pr_vlparcel  IN NUMBER                      -- Valor pago do boleto do acordo
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_nmtelant  IN VARCHAR2                    -- Nome da tela 
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- Código de críticia
                                        ,pr_dscritic OUT VARCHAR2);                  -- Descrição da crítica
                                                                                     
  -- Realizar o pagamentos do acordo                                                 
  PROCEDURE pc_pagar_contrato_acordo(pr_nracordo  IN tbrecup_acordo.nracordo%TYPE          -- Número do acordo
                                    ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                    ,pr_vlparcel  IN NUMBER                                -- Valor do boleto pago
                                    ,pr_cdoperad  IN VARCHAR2                              -- Código do operador
                                    ,pr_idorigem  IN NUMBER                                -- Indica a origem
                                    ,pr_nmtelant  IN VARCHAR2                              -- Tela
                                    ,pr_vltotpag OUT NUMBER                                -- Retornar o valor total dos pagamentos realizados
                                    ,pr_cdcritic OUT NUMBER                                -- Retorno de critica/erro
                                    ,pr_dscritic OUT VARCHAR2);                            -- Retorno de critica/erro

 -- Gera histórico de alteração CRAPCYC
 PROCEDURE pc_gerar_historico_cdmotcin(pr_cdcooper  IN tbrecup_acordo.cdcooper%TYPE         
                                      ,pr_nrdconta  IN tbrecup_acordo.nrdconta%TYPE 
                                      ,pr_nrctremp  IN tbrecup_acordo_contrato.nrctremp%TYPE                               
                                      ,pr_cdorigem  IN tbrecup_acordo_contrato.cdorigem%TYPE                              
                                      ,pr_cdmotcin  IN tbrecup_acordo_contrato.cdmotcin%TYPE                                 
                                      ,pr_flgehvip  IN tbrecup_acordo_contrato.flgehvip%TYPE                                                               
                                      ,pr_dscritic OUT VARCHAR2                               
                                      ,pr_cdcritic OUT NUMBER       -- Retorno de critica/erro
                                    );  

 -- Consistir alteração CRAPCYC
 PROCEDURE pc_consistir_alt_cdmotcin(pr_cdcooper  IN tbrecup_acordo.cdcooper%TYPE         
                                      ,pr_nrdconta  IN tbrecup_acordo.nrdconta%TYPE 
                                      ,pr_nrctremp  IN tbrecup_acordo_contrato.nrctremp%TYPE                               
                                      ,pr_cdorigem  IN tbrecup_acordo_contrato.cdorigem%TYPE                              
                                      ,pr_cdmotcin  IN tbrecup_acordo_contrato.cdmotcin%TYPE                                 
                                      ,pr_flgehvip  IN tbrecup_acordo_contrato.flgehvip%TYPE                                                               
                                      ,pr_dscritic OUT VARCHAR2                               
                                      ,pr_cdcritic OUT NUMBER       -- Retorno de critica/erro
                                    );   

END RECP0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RECP0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RECP0001
  --  Sistema  : Rotinas genéricas com foco no Sistema de Acordos
  --  Sigla    : RECP
  --  Autor    : Renato Darosci / James Prust Junior
  --  Data     : Setembro/2016.                   Ultima atualizacao: 13/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
  --
  -- Alteração : 14/09/2016 - Criação da rotina - Renato Darosci/Supero
  --
  --             21/09/2016 - Adicionada a rotina PC_VERIFICA_ACORDO_ATIVO - (Jean)
  --
  --             10/01/2017 - Ajuste pc_pagar_emprestimo_prejuizo para gerar corretamente o lancamento de debito
  --                          na conta corrente do cooperado - PRJ302 - Acordos (Odirlei-AMcom)
  --
  --             14/02/2017 - Criacao pc_verifica_situacao_acordo. (Jaison/James - PRJ302)
  --
  --             22/02/2017 - Alteracao para passar pr_nrparcel na pc_cria_lancamento_cc. (Jaison/James)
  --
  --             27/09/2017 - Ajuste para atender SM 3 do projeto 210.2 (Daniel)
  --
  --             02/10/2017 - Tratamento no update da tabela CRAPCYC para tratamento da origem 2. (Heitor - Mouts) - Chamado 760624.
  --
  --             13/03/2018 - Chamado 806202 - ALterado update CRAPCYC para não atualizar motivos 2 e 7.
  --
  --             02/04/2018 - Gravar usuario cyber quando efetuado pagamento da primeira parcela. Chamado 868775 (Heitor - Mouts)
  -- 
  ---------------------------------------------------------------------------------------------------------------
  
  -- Constante com o nome do programa
  vr_cdprogra     CONSTANT VARCHAR2(8) := 'RECP0001';
  vr_dsarqlog     CONSTANT VARCHAR2(10):= 'acordo.log';
  
  -- Função para verificar se o código de crítica faz parte da lista de códigos de críticas do valor mínimo
  FUNCTION fn_erro_valor_minimo(pr_tab_erro IN OUT GENE0001.typ_tab_erro) RETURN BOOLEAN IS
    
    -- VARIÁVEIS
    vr_dsvlrprm     crapprm.dsvlrprm%TYPE;
    vr_dstabprm     GENE0002.typ_split;
    
  
  BEGIN
    
    -- Buscar o parametro 
    vr_dsvlrprm := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'CRITICA_VLR_MIN_PARCEL');
                                            
    -- Não retornar valor 
    IF vr_dsvlrprm IS NULL THEN
      -- Retorna false 
      RETURN FALSE;
    END IF;
    
    -- Faz o split dos parametros retornados
    vr_dstabprm := GENE0002.fn_quebra_string(vr_dsvlrprm, ',');
    
    -- Verifica se a quebra de registro foi realizada
    IF vr_dstabprm.count() > 0 THEN
      -- Percore o array 
      FOR idx IN 1..vr_dstabprm.count() LOOP
        IF vr_dstabprm(idx) = pr_tab_erro(pr_tab_erro.FIRST()).cdcritic THEN
          -- Se encontrar o código da critica na lista de códigos de críticas 
          -- referente ao pagamento do valor mínimo da parcela
          RETURN TRUE;
        END IF;      
      END LOOP;
    END IF;
    
    -- Se não encontrar o código retornar FALSE para tratar como exception
    RETURN FALSE;    
    
  EXCEPTION 
    WHEN OTHERS THEN
      -- Em caso de erro não previsto... substitui o erro retornado
      pr_tab_erro(pr_tab_erro.FIRST).cdcritic := 0;
      pr_tab_erro(pr_tab_erro.FIRST).dscritic := 'Erro na FN_ERRO_VALOR_MINIMO: '||SQLERRM;
      -- RETORNA FALSE PARA QUE SEJA REALIZADO O RAISE NO PROGRAMA      
      RETURN FALSE;
  END fn_erro_valor_minimo;  
  
  
  -- Rotina independente para geração de LOGS e envio de e-mail de erro
  PROCEDURE pc_gera_log_mail(pr_cdcooper   IN NUMBER                      -- Código da cooperativa
                            ,pr_nrdconta   IN NUMBER                      -- Número da conta
                            ,pr_nracordo   IN NUMBER                      -- Número do acordo
                            ,pr_nrctremp   IN NUMBER DEFAULT 0            -- Número do contrato de empréstimo
                            ,pr_dscritic   IN VARCHAR2                    -- Descrição da crítica
                            ,pr_dsmodule   IN VARCHAR2 DEFAULT NULL) IS   -- Descrição do módulo
                            
    -- ROTINA PRAGMA PARA EVITAR COMMIT INDESEJADO
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    -- CONSTANTES
    vr_dsdemail     CONSTANT VARCHAR2(50) := 'estrategiadecobranca@cecred.coop.br'; -- Email de destino
    vr_dsassunt     CONSTANT VARCHAR2(10) := 'ACORDO';
    
    -- VARIÁVEIS
    vr_dsdcorpo     VARCHAR2(4000);
    vr_dsrefere     VARCHAR2(100); -- Ira indicar o Acordo/Conta/Contrato do erro
    vr_dsmodule     VARCHAR2(100);
    vr_des_erro     VARCHAR2(1000);
    
  BEGIN
    
    -- Montar a string indicando a referencia do erro
    vr_dsrefere := '['||pr_nracordo||'/'||pr_nrdconta||'/'||pr_nrctremp||']';
    
    -- Se informou módulo
    IF pr_dsmodule IS NOT NULL THEN
      vr_dsmodule := '['||UPPER(pr_dsmodule)||']';
    END IF;
  
    -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => vr_dsarqlog 
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  ACORDO '|| vr_dsrefere || ' - ' ||
                                                  'ERRO: ' || pr_dscritic || ' '||vr_dsmodule||'.');
    
    -- MONTAR O CORPO DA MENSAGEM
    vr_dsdcorpo := 'Não foi possível efetuar o crédito do boleto do acordo na conta corrente, '||
                   'conforme dados abaixo. Favor verificar: <br>'||
                   'Cooperativa: '||pr_cdcooper||'<br>'||
                   'Conta: '||pr_nrdconta||'<br>'||
                   'Acordo: '||pr_nracordo||'<br><br>'||
                   'Para maiores detalhes, consulte o log de pagamento de acordos (LOGTEL).';
    
    -- Realizar a solicitação do envio do e-mail
    gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                              ,pr_cdprogra        => 'RECP0001'
                              ,pr_des_destino     => vr_dsdemail
                              ,pr_des_assunto     => vr_dsassunt
                              ,pr_des_corpo       => vr_dsdcorpo
                              ,pr_des_anexo       => NULL
                              ,pr_des_erro        => vr_des_erro);
                              
    --Se ocorreu algum erro
    IF vr_des_erro IS NOT NULL  THEN
      -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_dsarqlog 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  ACORDO '|| vr_dsrefere || ' - ' ||
                                                    'ERRO no envio de email: '||vr_des_erro||' '||vr_dsmodule||'.');
    END IF;
    
    -- Commita os dados
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3 -- Erro não tratato
                                ,pr_nmarqlog     => vr_dsarqlog 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  ACORDO '|| vr_dsrefere || ' - ' ||
                                                    'ERRO: ' || SQLERRM || ' '||vr_dsmodule||'.');
                                                    
      -- EFetua commit do mesmo modo, visto que é apenas para validar a sessão PRAGMA
      COMMIT;
  END pc_gera_log_mail;
  
  -- Verifica se existe contrato de acordo na situacao informada
  PROCEDURE pc_verifica_situacao_acordo(pr_cdcooper         IN crapepr.cdcooper%TYPE -- Codigo da Cooperativa
                                       ,pr_nrdconta         IN crapepr.nrdconta%TYPE -- Numero da Conta
                                       ,pr_nrctremp         IN crapepr.nrctremp%TYPE -- Numero do contrato
                                       ,pr_cdorigem         IN crapepr.cdorigem%TYPE -- Codigo da Origem
                                       ,pr_flgretativo     OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretquitado   OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretcancelado OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_cdcritic        OUT INTEGER               -- Codigo de criticia
                                       ,pr_dscritic        OUT VARCHAR2) IS          -- Descricao da critica
    -- CURSORES
    CURSOR cr_tbrecup(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                     ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                     ,pr_nrctremp tbrecup_acordo_contrato.nrctremp%TYPE
                     ,pr_cdorigem tbrecup_acordo_contrato.cdorigem%TYPE) IS
      SELECT tba.cdsituacao
        FROM tbrecup_acordo_contrato tbac
           , tbrecup_acordo tba
       WHERE tba.nracordo = tbac.nracordo
         AND (tbac.nrctremp = pr_nrctremp OR pr_nrctremp = 0)
         AND (DECODE(tbac.cdorigem,2,3,tbac.cdorigem) = pr_cdorigem OR pr_cdorigem = 0)
         AND tba.nrdconta   = pr_nrdconta
         AND tba.cdcooper   = pr_cdcooper;

  BEGIN
    pr_flgretativo     := 0;
    pr_flgretquitado   := 0;
    pr_flgretcancelado := 0;

    FOR rw_tbrecup IN cr_tbrecup(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_cdorigem => pr_cdorigem) LOOP

      -- Se estiver ATIVO
      IF rw_tbrecup.cdsituacao = 1 THEN
         pr_flgretativo := 1;
      END IF;

      -- Se estiver QUITADO
      IF rw_tbrecup.cdsituacao = 2 THEN
         pr_flgretquitado := 1;
      END IF;

      -- Se estiver CANCELADO
      IF rw_tbrecup.cdsituacao = 3 THEN
         pr_flgretcancelado := 1;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na RECP0001.PC_VERIFICA_SITUACAO_ACORDO: ' || SQLERRM;

  END pc_verifica_situacao_acordo;
  
  -- Verifica se existe contrato de acordo ativo
  PROCEDURE pc_verifica_acordo_ativo(pr_cdcooper  IN crapepr.cdcooper%TYPE -- Código da Cooperativa
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE -- Número da Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE -- Número do contrato
                                    ,pr_cdorigem  IN crapepr.cdorigem%TYPE -- Codigo da Origem
                                    ,pr_flgativo OUT INTEGER               -- [0 - NAO ATIVO] / [1 - ATIVO]
                                    ,pr_cdcritic OUT INTEGER               -- Código de críticia
                                    ,pr_dscritic OUT VARCHAR2) IS          -- Descrição da crítica
    -- VARIAVEIS
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(1000);
    vr_exc_erro       EXCEPTION;
    vr_flgretquitado   INTEGER;
    vr_flgretcancelado INTEGER;
    
  BEGIN
    
    RECP0001.pc_verifica_situacao_acordo(pr_cdcooper        => pr_cdcooper
                                        ,pr_nrdconta        => pr_nrdconta
                                        ,pr_nrctremp        => pr_nrctremp
                                        ,pr_cdorigem        => pr_cdorigem
                                        ,pr_flgretativo     => pr_flgativo
                                        ,pr_flgretquitado   => vr_flgretquitado
                                        ,pr_flgretcancelado => vr_flgretcancelado
                                        ,pr_cdcritic        => vr_cdcritic
                                        ,pr_dscritic        => vr_dscritic);
    -- Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na RECP0001.PC_VERIFICA_ACORDO_ATIVO: ' || SQLERRM;
  END pc_verifica_acordo_ativo;
  
  
  -- Retorna valor bloqueado em acordos
  PROCEDURE pc_ret_vlr_bloq_acordo(pr_cdcooper  IN crapepr.cdcooper%TYPE           -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapepr.nrdconta%TYPE           -- Número da Conta
                                  ,pr_vlblqaco OUT tbrecup_acordo.vlbloqueado%TYPE -- Retorna o valor bloqueado
                                  ,pr_cdcritic OUT INTEGER                         -- Código de críticia
                                  ,pr_dscritic OUT VARCHAR2) IS                    -- Descrição da crítica
    -- CURSORES
    CURSOR cr_tbrecup(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                     ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE) IS
    SELECT NVL(SUM(acordo.vlbloqueado),0) AS vlbloqueado
      FROM tbrecup_acordo acordo
     WHERE acordo.cdsituacao = 1
       AND acordo.nrdconta = pr_nrdconta
       AND acordo.cdcooper = pr_cdcooper;

    rw_tbrecup cr_tbrecup%ROWTYPE;

    -- EXCEPTION
    vr_exc_erro       EXCEPTION;
    
  BEGIN
    
    -- Valor default
    pr_vlblqaco := 0;
  
    OPEN cr_tbrecup(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_tbrecup INTO rw_tbrecup;

    IF cr_tbrecup%NOTFOUND THEN
      pr_vlblqaco := 0; -- Nao ha valores bloqueados
    ELSE
      pr_vlblqaco := rw_tbrecup.vlbloqueado; -- Valor total bloqueado por acordos
    END IF;

    CLOSE cr_tbrecup;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na RECP0001.PC_RET_VLR_BLOQ_ACORDO: ' || SQLERRM;
  END pc_ret_vlr_bloq_acordo;
  
  
  -- Efetuar o calculo do lançamento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_conta(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                   ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                   ,pr_cdoperad  IN VARCHAR2                     -- Código do cooperado
                                   ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                   ,pr_vlsddisp  IN NUMBER                       -- Valor do saldo disponível
                                   ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                   ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                   ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                   ,pr_dscritic OUT VARCHAR2 ) IS                -- Descrição da crítica
    
    -- VARIÁVEIS
    vr_vllanmto       craplcm.vllanmto%TYPE;   -- Valor de Lancamento
    vr_des_reto       VARCHAR2(10);
    vr_tab_erro       GENE0001.typ_tab_erro;
    
    -- EXCEPTION
    vr_exc_erro       EXCEPTION;
    
  BEGIN
    
    -- Verificar se o valor disponivel já foi regularizado
    IF pr_vlsddisp >= 0 THEN
      pr_vltotpag := 0; -- Indica que nenhum valor foi pago na conta
      RETURN;
    END IF;
    
    /** SAVEPOINT PARA CONTROLE DA TRANSAÇÃO **/
    SAVEPOINT SAVE_CONTRATO_CONTA;
    /******************************************/
    
    -----------------------------------------------------------------------------------------------
    -- Efetuar o calculo do valor do estouro de conta para descontar da parcela paga
    -- Não é necessário que seja realizado o lançamento em conta pois o valor já está creditado
    -- na mesma, devido ao recebimento do valor do boleto pago
    -----------------------------------------------------------------------------------------------
    -- Se o valor da parcela for maior que o valor a ser pago
    IF pr_vlparcel > ABS(pr_vlsddisp) THEN
      -- Irá pagar a parcela toda
      vr_vllanmto := ABS(pr_vlsddisp);
    -- Se o valor da parcela for menor ou igual ao valor a ser pago
    ELSE
      -- Irá pagar o total do boleto 
      vr_vllanmto := pr_vlparcel;
    END IF;

    -- Retornar o valor lançado
    pr_vltotpag := vr_vllanmto;
        
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_CONTRATO_CONTA;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_CONTA: '||SQLERRM;
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_CONTRATO_CONTA;
      /**************************/
  END pc_pagar_contrato_conta;
  
  
  -- Realizar o calculo e pagamento de prejuízo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                        ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo                               
                                        ,pr_tpemprst  IN crapepr.tpemprst%TYPE        -- Tipo do empréstimo
                                        ,pr_vlprejuz  IN crapepr.vlprejuz%TYPE        -- Valor do prejuízo
                                        ,pr_vlsdprej  IN crapepr.vlsdprej%TYPE        -- Saldo do prejuízo
                                        ,pr_vlsprjat  IN crapepr.vlsprjat%TYPE        -- Saldo anterior do prejuízo
                                        ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE        -- Valor da prestação do empréstimo
                                        ,pr_vlttmupr  IN crapepr.vlttmupr%TYPE        -- Valor total da multa do prejuízo
                                        ,pr_vlpgmupr  IN crapepr.vlpgmupr%TYPE        -- Valor pago da multa do prejuízo
                                        ,pr_vlttjmpr  IN crapepr.vlttjmpr%TYPE        -- Valor total dos juros do prejuízo
                                        ,pr_vlpgjmpr  IN crapepr.vlpgjmpr%TYPE        -- Valor pago dos juros do prejuízo
                                        ,pr_cdoperad  IN VARCHAR2                     -- Código do cooperado
                                        ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                        ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                        ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                        ,pr_vliofcpl  IN crapepr.vliofcpl%TYPE        -- Valor do IOF complementar
                                        ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                        ,pr_dscritic OUT VARCHAR2) IS                 -- Descrição da crítica
  
    -- Buscar o valor total de lançamentos referente ao pagamento do prejuízo original
    CURSOR cr_craplem(pr_cdhistor  craplem.cdhistor%TYPE) IS
      SELECT SUM(lem.vllanmto) vllanmto
        FROM craplem  lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrctremp = pr_nrctremp
         AND lem.cdhistor = pr_cdhistor;
        
    -- VARIÁVEIS
    vr_dtprmutl     DATE; -- Data do primeiro dia útil do mês
    vr_vlpagmto     NUMBER := pr_vlparcel;
    vr_vlajuste     NUMBER;
    vr_vllamlem     NUMBER;
    vr_vlapagar     NUMBER;
    vr_des_reto     VARCHAR2(10);
    vr_tab_erro     GENE0001.typ_tab_erro;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    
    vr_vlpgmupr     crapepr.vlpgmupr%TYPE;
    vr_vlpgjmpr     crapepr.vlpgjmpr%TYPE;
    vr_vlsdprej     crapepr.vlsdprej%TYPE;
    vr_dtliquid     crapepr.dtliquid%TYPE;
    
    -- EXCEPTIONS
    vr_exc_erro     EXCEPTION;
  
  BEGIN
    
    /** SAVEPOINT PARA CONTROLE DA TRANSAÇÃO **/
    SAVEPOINT SAVE_EPR_PREJUIZO;
    /******************************************/
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------        
    IF pr_nmtelant = 'COMPEFORA' THEN
      -- Busca o primeiro dia útil do mês 
      vr_dtprmutl := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => TRUNC(pr_crapdat.dtmvtolt,'MM'));
        
      -- Verifica se é o primeiro dia útil no mes
      IF pr_crapdat.dtmvtolt = vr_dtprmutl THEN
        -- Calcular o valor do ajuste
        vr_vlajuste := pr_vlsdprej - pr_vlsprjat;
          
        -- Se por um motivo não previsto o valor do ajuste for menor que zero, considerar zero
        IF NVL(vr_vlajuste, 0) < 0 THEN
          vr_vlajuste := 0;
        END IF;
          
        -- Se o valor do ajuste calculado é maior que zero
        IF NVL(vr_vlajuste, 0) > 0 THEN
          
          -- Lança o crédito em C/C e atualiza o lote
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_crapdat.dtmvtolt     --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci     --> Código da agência
                                        ,pr_cdbccxlt => 100             --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                        ,pr_cdpactra => pr_cdagenci     --> P.A. da transação
                                        ,pr_nrdolote => 600032          --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                        ,pr_cdhistor => 2012            --> Codigo historico 2012 - AJUSTE BOLETO
                                        ,pr_vllanmto => vr_vlajuste     --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparcel     --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                        ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
          
          -- Se ocorreu erro
          IF vr_des_reto <> 'OK' THEN
            -- Se possui algum erro na tabela de erros
            IF vr_tab_erro.COUNT() > 0 THEN
              pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              pr_cdcritic := 0;
              pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
            END IF;
            RAISE vr_exc_erro;
          END IF;
          
          -- O valor a ser pago da parcela será o valor da parcela acrescido do valor do ajuste
          vr_vlpagmto := NVL(vr_vlpagmto,0) + nvl(vr_vlajuste, 0);
        END IF; -- FIM NVL(vr_vlajuste, 0) > 0
      END IF; -- FIM pr_dtmvtolt = vr_dtprmutl
    END IF; -- FIM pr_nmtelant = 'COMPEFORA'
    ------------------------------------------------------------------------------------------------------------
    -- FIM DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------        

    -- Se for liquidação do acordo, deve pagar o valor total do prejuízo
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      vr_vlpagmto := NVL(pr_vlsdprej,0) + NVL(pr_vlttmupr,0) + NVL(pr_vlttjmpr,0) - NVL(pr_vlpgmupr,0) - NVL(pr_vlpgjmpr,0);
      GOTO GERAR_ABONO_LEM;
    END IF;

    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LANÇAMENTO DE PAGAMENTO DO PREJUIZO ORIGINAL
    ------------------------------------------------------------------------------------------------------------        
    -- Limpar a variável
    vr_vllamlem := NULL;
    
    -- Carregar os valores
    vr_vlpgmupr := pr_vlpgmupr;
    vr_vlpgjmpr := pr_vlpgjmpr;
    vr_vlsdprej := pr_vlsdprej;
    
    -- Buscar o valor total de lançamentos referente ao pagamento do prejuízo original
    OPEN  cr_craplem(382); 
    FETCH cr_craplem INTO vr_vllamlem;
    CLOSE cr_craplem;
      
    -- Garantir que variável não esteja null
    vr_vllamlem := NVL(vr_vllamlem,0);
      
    -- Guardar o valor a pagar no valor do boleto
    vr_vlapagar := vr_vlpagmto;
      
    -- Se o valor do boleto é maior que o prejuizo a pagar, acrescidos dos juros e multas
    IF (vr_vlapagar > ((pr_vlprejuz + pr_vlttmupr + pr_vlttjmpr) - vr_vllamlem )) THEN 
      -- Define o valor total como o valor a ser pago
      vr_vlapagar := ((pr_vlprejuz + pr_vlttmupr + pr_vlttjmpr) - vr_vllamlem );
    END IF;
      
    ------------------------------------------------------------------------------------------------------------------   
    -- Caso o valor do lançamento for menor ou igual a 0, significa que o pagamento do prejuizo original jah foi pago
    -- ENTAO DEVERA PULAR PARA O PAGAMENTO DE JUROS DE PREJUIZO (((2º ETAPA)))
    ------------------------------------------------------------------------------------------------------------------   
    IF vr_vlapagar <= 0 THEN
      GOTO SEGUNDA_ETAPA;
    END IF;
    
    -- Atualiza o valor para pagamento decrementando o valor a pagar
    vr_vlpagmto := vr_vlpagmto - vr_vlapagar;
    
    -- ROTINA PARA EFETUAR O LANÇAMENTO
    EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper       -- Codigo Cooperativa
                                   ,pr_dtmvtolt => pr_crapdat.dtmvtolt       -- Data Emprestimo
                                   ,pr_cdagenci => pr_cdagenci       -- Codigo Agencia
                                   ,pr_cdbccxlt => 100               -- Codigo Caixa
                                   ,pr_cdoperad => pr_cdoperad       -- Operador
                                   ,pr_cdpactra => pr_cdagenci       -- Posto Atendimento
                                   ,pr_tplotmov => 5                 -- Tipo movimento
                                   ,pr_nrdolote => 650002            -- Numero Lote
                                   ,pr_nrdconta => pr_nrdconta       -- Numero da Conta
                                   ,pr_cdhistor => 382               -- Codigo Historico
                                   ,pr_nrctremp => pr_nrctremp       -- Numero Contrato
                                   ,pr_vllanmto => vr_vlapagar       -- Valor Lancamento
                                   ,pr_dtpagemp => pr_crapdat.dtmvtolt -- Data Pagamento Emprestimo
                                   ,pr_txjurepr => 0                 -- Taxa Juros Emprestimo
                                   ,pr_vlpreemp => pr_vlpreemp       -- Valor Emprestimo
                                   ,pr_nrsequni => 0                 -- Numero Sequencia
                                   ,pr_nrparepr => 0                 -- Numero Parcelas Emprestimo
                                   ,pr_flgincre => TRUE              -- Indicador Credito
                                   ,pr_flgcredi => TRUE              -- Credito
                                   ,pr_nrseqava => 0                 -- Pagamento: Sequencia do avalista
                                   ,pr_cdorigem => 1                 -- Origem do Lançamento
                                   ,pr_cdcritic => vr_cdcritic       -- Codigo Erro
                                   ,pr_dscritic => vr_dscritic);     -- Descricao Erro
       
    -- Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    -- Acumula o valor de pagamento realizado
    pr_vltotpag := NVL(pr_vltotpag,0) + vr_vlapagar;
    
    -- Inicializa as variáveis dos valores a serem pagos
    vr_vlpgmupr := NULL;
    vr_vlpgjmpr := NULL;
    vr_vlsdprej := NULL;

    -- Se for o tipo de empréstimo 1
    IF pr_tpemprst = 1 THEN
      -- 1o Valor de Multa
      IF (pr_vlttmupr - pr_vlpgmupr) >= vr_vlapagar THEN   
        vr_vlpgmupr := pr_vlpgmupr + vr_vlapagar;
        vr_vlapagar := 0; -- Zera o valor a pagar pois usou todo o saldo
      ELSE  
        -- Recalcular o saldo
        vr_vlapagar := vr_vlapagar - (pr_vlttmupr - pr_vlpgmupr);
        vr_vlpgmupr := pr_vlpgmupr + (pr_vlttmupr - pr_vlpgmupr);
      END IF; 
        
      -- Se ainda possui saldo para pagamento
      IF vr_vlapagar > 0 THEN
        -- 2o Valor de Multa
        IF (pr_vlttjmpr - pr_vlpgjmpr) >= vr_vlapagar THEN
          vr_vlpgjmpr := pr_vlpgjmpr + vr_vlapagar;
          vr_vlapagar := 0; -- Zera o valor a pagar pois usou todo o saldo
        ELSE
          vr_vlapagar := vr_vlapagar - (pr_vlttjmpr - pr_vlpgjmpr);
          vr_vlpgjmpr := pr_vlpgjmpr + (pr_vlttjmpr - pr_vlpgjmpr);
        END IF;
      END IF;
          
      -- Se ainda possui saldo para pagamento
      IF vr_vlapagar > 0 THEN
        -- 3o Valor em Prejuizo
        vr_vlsdprej := pr_vlsdprej - vr_vlapagar;
      END IF;
    ELSE 
      -- Atualizar valor do saldo do Prejuízo
      vr_vlsdprej := pr_vlsdprej - vr_vlapagar;
    END IF;   
    
    /***** Atualiza a informação do empréstimo *****/
    BEGIN
        
      UPDATE crapepr epr
         SET epr.vlpgmupr = NVL(vr_vlpgmupr,epr.vlpgmupr)
           , epr.vlpgjmpr = NVL(vr_vlpgjmpr,epr.vlpgjmpr)
           , epr.vlsdprej = NVL(vr_vlsdprej,epr.vlsdprej)
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao atualizar emprestimo (1a. Etapa): '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    /***********************************************/
    
    -- Deve atualizar os valores recebidos por parametro -- DESTE PONTO EM DIANTE UTILIZAR AS VARIÁVEIS
    --vr_vlpgmupr := NVL(vr_vlpgmupr,pr_vlpgmupr);
    --vr_vlpgjmpr := NVL(vr_vlpgjmpr,pr_vlpgjmpr);
    vr_vlsdprej := NVL(vr_vlsdprej,pr_vlsdprej);
        
    ------------------------------------------------------------------------------------------------------------
    -- FIM PARA O LANÇAMENTO DE PAGAMENTO DO PREJUIZO ORIGINAL
    ------------------------------------------------------------------------------------------------------------
      
    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LANÇAMENTO DE PAGAMENTO DE JUROS  -->  (((2º ETAPA)))  <--
    ------------------------------------------------------------------------------------------------------------
    /***********/   <<SEGUNDA_ETAPA>>   /***********/
    ------------------------------------------------------------------------------------------------------------
    
    -- Se não há mais valores disponível para pagamentos
    IF vr_vlpagmto > 0 THEN
    
      -- Limpar a variável
      vr_vllamlem := NULL;
        
      -- Buscar o valor disponivel para efetuar o pagamento de juros do prejuizo      
      OPEN  cr_craplem(390); 
      FETCH cr_craplem INTO vr_vllamlem;
      CLOSE cr_craplem;
      
      -- Garantir que variável não esteja null
      vr_vllamlem := NVL(vr_vllamlem,0);

      -- Guardar o valor a pagar com o valor restante ds pagamentos anteriores
      vr_vlapagar := vr_vlpagmto;
    
      -- 05/10/2016 - REMOVIDO o "+ pr_vlttmupr + pr_vlttjmpr" porque estes valores já foram pagos
    
      -- Se o valor disponivel para pagamento é maior que o saldo do prejuizo.. mais taxas
      IF vr_vlapagar > vr_vlsdprej THEN 
        vr_vlapagar := vr_vlsdprej;
      END IF;
    
      -- Verifica se encontrou valor a pagar
      IF vr_vlapagar <= 0 THEN
        -- Caso entrar na condição já foi pago todo o prejuizo do emprestimo
        RETURN;
      END IF;
    
      -- ROTINA PARA EFETUAR O LANÇAMENTO
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper       -- Codigo Cooperativa
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt       -- Data Emprestimo
                                     ,pr_cdagenci => pr_cdagenci       -- Codigo Agencia
                                     ,pr_cdbccxlt => 100               -- Codigo Caixa
                                     ,pr_cdoperad => pr_cdoperad       -- Operador
                                     ,pr_cdpactra => pr_cdagenci       -- Posto Atendimento
                                     ,pr_tplotmov => 5                 -- Tipo movimento
                                     ,pr_nrdolote => 650002            -- Numero Lote
                                     ,pr_nrdconta => pr_nrdconta       -- Numero da Conta
                                     ,pr_cdhistor => 391               -- Codigo Historico
                                     ,pr_nrctremp => pr_nrctremp       -- Numero Contrato
                                     ,pr_vllanmto => vr_vlapagar       -- Valor Lancamento
                                     ,pr_dtpagemp => pr_crapdat.dtmvtolt       -- Data Pagamento Emprestimo
                                     ,pr_txjurepr => 0                 -- Taxa Juros Emprestimo
                                     ,pr_vlpreemp => pr_vlpreemp       -- Valor Emprestimo
                                     ,pr_nrsequni => 0                 -- Numero Sequencia
                                     ,pr_nrparepr => 0                 -- Numero Parcelas Emprestimo
                                     ,pr_flgincre => TRUE              -- Indicador Credito
                                     ,pr_flgcredi => TRUE              -- Credito
                                     ,pr_nrseqava => 0                 -- Pagamento: Sequencia do avalista
                                     ,pr_cdorigem => 1                 -- Origem do Lançamento
                                     ,pr_cdcritic => vr_cdcritic       -- Codigo Erro
                                     ,pr_dscritic => vr_dscritic);     -- Descricao Erro
       
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
    
      -- Acumula o valor de pagamento realizado
      pr_vltotpag := NVL(pr_vltotpag,0) + vr_vlapagar;
    
      -- Limpa a variável de data
      vr_dtliquid := NULL;
    
      -- Se o valor do prejuízo é maior que o saldo a pagar                                
      IF vr_vlsdprej > vr_vlapagar THEN
        vr_vlsdprej := vr_vlsdprej - vr_vlapagar;
      ELSE
        vr_vlsdprej := 0; -- Zera o prejuízo
        vr_dtliquid := pr_crapdat.dtmvtolt; -- Seta a data de liquidação
      END IF;
    
      -- Atualiza a informação do empréstimo
      BEGIN
        
        UPDATE crapepr epr
           SET epr.vlsdprej = NVL(vr_vlsdprej,epr.vlsdprej)
             , epr.dtliquid = NVL(vr_dtliquid,epr.dtliquid)
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar emprestimo (2a. Etapa): '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    
    END IF;
    ------------------------------------------------------------------------------------------------------------
    -- FIM PARA O LANÇAMENTO DE PAGAMENTO DE JUROS
    ------------------------------------------------------------------------------------------------------------
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LANÇAMENTO DE DEBITO DO PAGAMENTO DE PREJUIZO  -->  (((3º ETAPA)))  <--
    ------------------------------------------------------------------------------------------------------------
    IF pr_vltotpag > 0 THEN
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                      ,pr_cdbccxlt => 100                 --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> Código do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transação
                                      ,pr_nrdolote => 650001              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> Número da conta
                                      ,pr_cdhistor => 384                 --> Codigo historico
                                      ,pr_vllanmto => pr_vltotpag - nvl(pr_vliofcpl,0)        --> Valor do debito
                                      ,pr_nrparepr => pr_nrparcel         --> Número parcelas empréstimo
                                      ,pr_nrctremp => 0                   --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
      
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
        END IF;
        RAISE vr_exc_erro;
      END IF;  
         
      IF NVL(pr_vliofcpl,0) > 0 THEN
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                        ,pr_cdbccxlt => 100                 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad         --> Código do Operador
                                        ,pr_cdpactra => pr_cdagenci         --> P.A. da transação
                                        ,pr_nrdolote => 650001              --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta         --> Número da conta
                                        ,pr_cdhistor => 2313                --> Codigo historico
                                        ,pr_vllanmto => pr_vliofcpl         --> Valor do debito
                                        ,pr_nrparepr => pr_nrparcel         --> Número parcelas empréstimo
                                        ,pr_nrctremp => 0                   --> Número do contrato de empréstimo
                                        ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
            
          -- Se ocorreu erro
          IF vr_des_reto <> 'OK' THEN
            -- Se possui algum erro na tabela de erros
            IF vr_tab_erro.COUNT() > 0 THEN
              pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              pr_cdcritic := 0;
              pr_dscritic := 'Erro ao criar o lancamento de IOF na conta corrente.';
            END IF;
            RAISE vr_exc_erro;
          END IF;  
          
          -- Insere registro de pagamento de IOF na tbgen_iof_lancamento
          tiof0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                               , pr_nrdconta     => pr_nrdconta
                               , pr_dtmvtolt     => pr_crapdat.dtmvtolt
                               , pr_tpproduto    => 1 -- Emprestimo
                               , pr_nrcontrato   => pr_nrctremp
                               , pr_idlautom     => null
                               , pr_dtmvtolt_lcm => pr_crapdat.dtmvtolt
                               , pr_cdagenci_lcm => pr_cdagenci
                               , pr_cdbccxlt_lcm => 100
                               , pr_nrdolote_lcm => 650001
                               , pr_nrseqdig_lcm => 1
                               , pr_vliofpri     => 0
                               , pr_vliofadi     => 0
                               , pr_vliofcpl     => pr_vliofcpl
                               , pr_flgimune     => 0
                               , pr_cdcritic     => vr_cdcritic 
                               , pr_dscritic     => vr_dscritic);
          
          if vr_dscritic is not null then
             raise vr_exc_erro;
          end if;
          
      END IF;
         
    END IF;    
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LANÇAMENTO DE ABONO NA CRAPLEM
    ------------------------------------------------------------------------------------------------------------
    /***********/   <<GERAR_ABONO_LEM>>   /***********/
    ------------------------------------------------------------------------------------------------------------
    
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      
      IF vr_vlpagmto > 0 THEN 
      
      -- ROTINA PARA EFETUAR O LANÇAMENTO
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper       -- Codigo Cooperativa
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt       -- Data Emprestimo
                                     ,pr_cdagenci => pr_cdagenci       -- Codigo Agencia
                                     ,pr_cdbccxlt => 100               -- Codigo Caixa
                                     ,pr_cdoperad => pr_cdoperad       -- Operador
                                     ,pr_cdpactra => pr_cdagenci       -- Posto Atendimento
                                     ,pr_tplotmov => 5                 -- Tipo movimento
                                     ,pr_nrdolote => 650002            -- Numero Lote
                                     ,pr_nrdconta => pr_nrdconta       -- Numero da Conta
                                     ,pr_cdhistor => 383               -- Codigo Historico
                                     ,pr_nrctremp => pr_nrctremp       -- Numero Contrato
                                     ,pr_vllanmto => vr_vlpagmto       -- Valor Lancamento
                                     ,pr_dtpagemp => pr_crapdat.dtmvtolt       -- Data Pagamento Emprestimo
                                     ,pr_txjurepr => 0                 -- Taxa Juros Emprestimo
                                     ,pr_vlpreemp => pr_vlpreemp       -- Valor Emprestimo
                                     ,pr_nrsequni => 0                 -- Numero Sequencia
                                     ,pr_nrparepr => 0                 -- Numero Parcelas Emprestimo
                                     ,pr_flgincre => TRUE              -- Indicador Credito
                                     ,pr_flgcredi => TRUE              -- Credito
                                     ,pr_nrseqava => 0                 -- Pagamento: Sequencia do avalista
                                     ,pr_cdorigem => 1                 -- Origem do Lançamento
                                     ,pr_cdcritic => vr_cdcritic       -- Codigo Erro
                                     ,pr_dscritic => vr_dscritic);     -- Descricao Erro
         
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      -- Atualiza a informação do empréstimo
      BEGIN
        
        UPDATE crapepr epr
           SET epr.vlsdprej = 0
             , epr.vlpgmupr = pr_vlttmupr
             , epr.vlpgjmpr = pr_vlttjmpr
             , epr.dtliquid = pr_crapdat.dtmvtolt
             , epr.vliofcpl = epr.vliofcpl - nvl(pr_vliofcpl,0)
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar emprestimo (GERACAO ABONO): '||SQLERRM;
        RAISE vr_exc_erro;
      END;
        
      END IF;  
      
    END IF;    
    
    
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EPR_PREJUIZO;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PREJUIZO: '||SQLERRM;
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EPR_PREJUIZO;
      /**************************/
  END pc_pagar_emprestimo_prejuizo;
  
  
  -- Realizar o calculo e pagamento de folha de pagamento
  PROCEDURE pc_pagar_emprestimo_folha(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                     ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo 
                                     ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                     ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                     ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- Código da linha de crédito do empréstimo
                                     ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                     ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                     ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                     ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                     ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                     ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empréstimo
                                     ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do último pagamento
                                     ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                     ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                     ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                     ,pr_cdoperad  IN VARCHAR2                     -- Código do operador
                                     ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                     ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                     ,pr_dscritic OUT VARCHAR2) IS                 -- Descrição da crítica
      
    -- Buscar os avisos criados
    CURSOR cr_crapavs IS 
      SELECT avs.rowid    dsrowid
           , avs.insitavs
           , avs.flgproce
           , avs.vllanmto
           , avs.vldebito
           , (avs.vllanmto - avs.vldebito) vlestdif 
        FROM crapavs   avs
       WHERE avs.cdcooper = pr_cdcooper
         AND avs.nrdconta = pr_nrdconta
         AND avs.nrdocmto = pr_nrctremp
         AND avs.tpdaviso = 1
         AND avs.cdhistor = 108           
         AND avs.insitavs = 0
       ORDER BY avs.dtmvtolt;  
     
    -- Buscar dados da linha de crédito do empréstimo
    CURSOR cr_craplcr IS
      SELECT lcr.txdiaria
        FROM craplcr  lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr    cr_craplcr%ROWTYPE;
  
    -- VARIÁVEIS
    vr_dstextab     craptab.dstextab%TYPE;
    vr_inusatab     BOOLEAN;
    vr_vldpagto     NUMBER := pr_vlparcel;
    vr_vlajuste     NUMBER := 0;
    
    -- retornos da procedure pc_crps120_1
    vr_insitavs     crapavs.insitavs%TYPE;
    vr_vldebtot     crapavs.vldebito%TYPE;
    vr_vlestdif     crapavs.vlestdif%TYPE;
    vr_flgproce     crapavs.flgproce%TYPE;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    
    -- Variáveis para calculo do saldo devedor
    vr_vldebito     NUMBER;
    vr_diapagto     NUMBER;
    vr_txdjuros     NUMBER;
    vr_qtprecal     NUMBER;
    vr_vlprepag     NUMBER(14,2);
    vr_vljurmes     NUMBER(11,2);
    vr_qtprepag     crapepr.qtprepag%type;
    vr_vljuracu     crapepr.vljuracu%type;
    vr_vlsdeved     crapepr.vlsdeved%type;
    vr_dtultpag     crapepr.dtultpag%type;
    
    vr_des_reto     VARCHAR2(10);
    vr_tab_erro     GENE0001.typ_tab_erro;
    
    -- EXCEPTION
    vr_exc_erro     EXCEPTION;
  
  BEGIN
    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    -- Se não retornou valor
    IF vr_dstextab IS NULL THEN
      vr_inusatab := FALSE;
    ELSE
      IF SUBSTR(vr_dstextab,1,1) = '0' THEN
        vr_inusatab := FALSE;
      ELSE
        vr_inusatab := TRUE;
      END IF;
    END IF;
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO Calculo do Saldo Devedor
    ------------------------------------------------------------------------------------------------------------      
    vr_diapagto := 0;
    vr_qtprepag := pr_qtprepag;      
    vr_vljuracu := pr_vljuracu;
    vr_vlsdeved := pr_vlsdeved;
    vr_dtultpag := pr_dtultpag;
    
    -- Se indicar o uso da tabela de taxa de juros e empréstimo não estiver liquidado
    IF vr_inusatab AND pr_inliquid = 0 THEN
      -- Buscar a linha de credito
      OPEN  cr_craplcr;
      FETCH cr_craplcr INTO rw_craplcr;
      
      -- Se não encontrar informações da Linha de Crédito
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        -- Senão encontrou a linha de credito devera sair da procedure e fazer o proximo pagamento
        pr_cdcritic := 356;
        pr_dscritic := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Utiliza a taxa de juros diária da linha de crédito
        vr_txdjuros := rw_craplcr.txdiaria;
        CLOSE cr_craplcr;
      END IF;
    ELSE
      -- Utiliza a taxa de juros do empréstimo
      vr_txdjuros := pr_txjuremp;
    END IF;
    
    /** SAVEPOINT PARA CONTROLE DA TRANSAÇÃO **/
    SAVEPOINT SAVE_EPR_FOLHA;
    /******************************************/
    
    ----------------------------------------------------------------------- 
    -- Chamar rotina de cálculo externa
    EMPR0001.pc_leitura_lem(pr_cdcooper    => pr_cdcooper
                           ,pr_cdprogra    => vr_cdprogra
                           ,pr_rw_crapdat  => pr_crapdat
                           ,pr_nrdconta    => pr_nrdconta
                           ,pr_nrctremp    => pr_nrctremp
                           ,pr_dtcalcul    => NULL
                           ,pr_diapagto    => vr_diapagto
                           ,pr_txdjuros    => vr_txdjuros
                           ,pr_qtprepag    => vr_qtprepag
                           ,pr_qtprecal    => vr_qtprecal
                           ,pr_vlprepag    => vr_vlprepag
                           ,pr_vljuracu    => vr_vljuracu
                           ,pr_vljurmes    => vr_vljurmes
                           ,pr_vlsdeved    => vr_vlsdeved
                           ,pr_dtultpag    => vr_dtultpag
                           ,pr_cdcritic    => vr_cdcritic
                           ,pr_des_erro    => vr_dscritic);
    
    -- Verifica se houve retorno de crítica
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PC_LEITURA_LEM: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ------------------------------------------------------------------------------------------------------------
    -- FIM Calculo do Saldo Devedor
    ------------------------------------------------------------------------------------------------------------ 
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------        
    IF pr_nmtelant = 'COMPEFORA' THEN 
      -- Calcular o valor do ajuste
      vr_vlajuste := vr_vlsdeved - pr_vlsdevat;
             
      -- Valor do ajuste
      IF nvl(vr_vlajuste, 0) > 0 THEN
        -- Lanca em C/C e atualiza o lote
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                      ,pr_cdbccxlt => 100                 --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> Código do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transação
                                      ,pr_nrdolote => 600032              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> Número da conta
                                      ,pr_cdhistor => 2012                --> Codigo historico 2012 - AJUSTE BOLETO
                                      ,pr_vllanmto => vr_vlajuste         --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel         --> Número parcelas empréstimo
                                      ,pr_nrctremp => pr_nrctremp         --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
              
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
     
        -- O Valor do pagamento deverá considerar também o valor do ajuste
        vr_vldpagto := NVL(vr_vldpagto,0) + nvl(vr_vlajuste, 0);
      
      END IF; -- FIM nvl(vr_vlajuste, 0) > 0 
    END IF;   
    ------------------------------------------------------------------------------------------------------------
    -- FIM DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------ 
    
    -- Se for liquidação do acordo, deve pagar o valor total
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      vr_vldpagto := vr_vlsdeved;
    END IF;
    
    -----------------------------------------------------------------------------------------------
    -- Ajustar a procedure pc_crps120_1 para quando for debitar o emprestimo de acordo
    -- o parametro pr_vldaviso devera receber o saldo devedor do contrato
    -- * Fazer condicao em cima do nome da tela, verificar como eh melhor      
    ----------------------------------------------------------------------------------------------- 
    -- Chama a rotina PC_CRPS120_1
    pc_crps120_1(pr_cdcooper => pr_cdcooper
                ,pr_cdprogra => vr_cdprogra
                ,pr_cdoperad => pr_cdoperad
                ,pr_crapdat  => pr_crapdat
                ,pr_nrdconta => pr_nrdconta
                ,pr_nrctremp => pr_nrctremp
                ,pr_nrdolote => 8453
                ,pr_inusatab => vr_inusatab         --> Indicador se utilizar a tabela de juros
                ,pr_vldaviso => NULL                --> Valor de aviso
                ,pr_vlsalliq => vr_vldpagto         --> Valor de saldo liquido
                ,pr_dtintegr => pr_crapdat.dtmvtolt --> Data de integracao
                ,pr_cdhistor => 95                  --> Cod do historico
                -- OUT
                ,pr_insitavs => vr_insitavs         --> Retorna situacao do aviso
                ,pr_vldebito => vr_vldebtot         --> Retorna do valor de debito
                ,pr_vlestdif => vr_vlestdif         --> Ret vlr estouro ou diferenca
                ,pr_flgproce => vr_flgproce         --> Ret indicativo de processamento
                ,pr_cdcritic => vr_cdcritic         --> Critica encontrada
                ,pr_dscritic => vr_dscritic);       --> Texto de erro/critica encontrada
   
    -- Verifica se houve retorno de crítica
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro PC_CRPS120_1: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    -----------------------------------------------------------------------------------------------
    -- Precisamos atualizar os avisos dos emprestimos que estao pendente de pagamento, exemplo:
    --  
    -- VALOR PAGO NO BOLETO: R$ 80,00
    --
    -- CODIGO        VALOR DO AVISO      VALOR DEBITADO        SITUACAO
    -- 1             50,00               50,00                 1 - Pago        
    -- 2             50,00               30,00                 0 - Não Pago
    --
    -----------------------------------------------------------------------------------------------        
    
    -- Atualizar o valor conforme o cálculo da 120 
    pr_vltotpag := NVL(vr_vldebtot,0);
    
    -- Percorrer os avisos do contrato
    FOR rw_crapavs IN cr_crapavs LOOP
      
      -- Se o valor do estouro ou diferença for menor ou igual que o valor total de débito
      IF rw_crapavs.vlestdif <= NVL(vr_vldebtot,0) THEN
        -- Quando pagar o valor total...
        vr_vlestdif := 0;
        vr_vldebtot := NVL(vr_vldebtot,0) - rw_crapavs.vlestdif;
        vr_vldebito := rw_crapavs.vldebito + rw_crapavs.vlestdif;
        vr_insitavs := 1;
        vr_flgproce := 1;        
      ELSE
        -- Quando pagar uma parte do valor....
        vr_vlestdif := NVL(vr_vldebtot,0) - rw_crapavs.vlestdif; -- ATENÇÃO: Este campo é gravado NEGATIVO
        vr_vldebito := rw_crapavs.vldebito + NVL(vr_vldebtot,0);
        vr_vldebtot := 0;
        vr_insitavs := 0;
        vr_flgproce := 0;
      END IF;
      
      -- Atualização do aviso
      BEGIN
        UPDATE crapavs 
           SET crapavs.insitavs = vr_insitavs
             , crapavs.vlestdif = vr_vlestdif
             , crapavs.flgproce = vr_flgproce
             , crapavs.vldebito = vr_vldebito
         WHERE ROWID = rw_crapavs.dsrowid;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar avisos: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP; -- cr_crapavs
      
    -----------------------------------------------------------------------------------------------
    -- Debita em conta corrente o total pago do emprestimo
    -----------------------------------------------------------------------------------------------
    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                  ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --> Movimento atual
                                  ,pr_cdagenci => pr_cdagenci   --> Código da agência
                                  ,pr_cdbccxlt => 100           --> Número do caixa
                                  ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                  ,pr_cdpactra => pr_cdagenci   --> P.A. da transação
                                  ,pr_nrdolote => 650001        --> Numero do Lote
                                  ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                  ,pr_cdhistor => 275           --> Codigo historico
                                  ,pr_vllanmto => pr_vltotpag   --> Valor do credito
                                  ,pr_nrparepr => pr_nrparcel   --> Número parcelas empréstimo
                                   ,pr_nrctremp => 0             --> Número do contrato de empréstimo
                                  ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                  ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
              
    -- Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      -- Se possui algum erro na tabela de erros
      IF vr_tab_erro.COUNT() > 0 THEN
        pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
      END IF;
      RAISE vr_exc_erro;
    END IF;
  
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EPR_FOLHA;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_FOLHA: '||SQLERRM;
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EPR_FOLHA;
      /**************************/
  END pc_pagar_emprestimo_folha;
  
  -- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                  ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- Código da linha de crédito do empréstimo
                                  ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                  ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                  ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                  ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empréstimo
                                  ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do último pagamento
                                  ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                  ,pr_idorigem  IN NUMBER                       -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                     -- Código do operador
                                  ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                  ,pr_dscritic OUT VARCHAR2) IS                 -- Descrição da crítica
           
    -- Buscar dados da linha de crédito do empréstimo
    CURSOR cr_craplcr IS
      SELECT lcr.txdiaria
        FROM craplcr  lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr    cr_craplcr%ROWTYPE;
  
    -- VARIÁVEIS
    vr_dstextab     craptab.dstextab%TYPE;
    vr_inusatab     BOOLEAN;
    vr_vldpagto     NUMBER := pr_vlparcel;
    vr_vlajuste     NUMBER := 0;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    
    -- Variáveis para calculo do saldo devedor
    vr_diapagto     NUMBER;
    vr_txdjuros     NUMBER;
    vr_qtprecal     NUMBER;
    vr_vlprepag     NUMBER(14,2);
    vr_vljurmes     NUMBER(11,2);
    vr_qtprepag     crapepr.qtprepag%type;
    vr_vljuracu     crapepr.vljuracu%type;
    vr_vlsdeved     crapepr.vlsdeved%type;
    vr_dtultpag     crapepr.dtultpag%type;
    
    vr_des_reto     VARCHAR2(10);
    vr_tab_erro     GENE0001.typ_tab_erro;
    
    -- EXCEPTION
    vr_exc_erro     EXCEPTION;
  
  BEGIN
    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    -- Se não retornou valor
    IF vr_dstextab IS NULL THEN
      vr_inusatab := FALSE;
    ELSE
      IF SUBSTR(vr_dstextab,1,1) = '0' THEN
        vr_inusatab := FALSE;
      ELSE
        vr_inusatab := TRUE;
      END IF;
    END IF;
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO Calculo do Saldo Devedor
    ------------------------------------------------------------------------------------------------------------      
    vr_diapagto := 0;
    vr_qtprepag := pr_qtprepag;      
    vr_vljuracu := pr_vljuracu;
    vr_vlsdeved := pr_vlsdeved;
    vr_dtultpag := pr_dtultpag;
    
    -- Se indicar o uso da tabela de taxa de juros e empréstimo não estiver liquidado
    IF vr_inusatab AND pr_inliquid = 0 THEN
      -- Buscar a linha de credito
      OPEN  cr_craplcr;
      FETCH cr_craplcr INTO rw_craplcr;
      
      -- Se não encontrar informações da Linha de Crédito
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        -- Senão encontrou a linha de credito devera sair da procedure e fazer o proximo pagamento
        pr_cdcritic := 356;
        pr_dscritic := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Utiliza a taxa de juros diária da linha de crédito
        vr_txdjuros := rw_craplcr.txdiaria;
        CLOSE cr_craplcr;
      END IF;
    ELSE
      -- Utiliza a taxa de juros do empréstimo
      vr_txdjuros := pr_txjuremp;
    END IF;
    
    /** SAVEPOINT PARA CONTROLE DA TRANSAÇÃO **/
    SAVEPOINT SAVE_EMPRESTIMO_TR;
    /******************************************/
    
    ----------------------------------------------------------------------- 
    -- Chamar rotina de cálculo externa
    EMPR0001.pc_leitura_lem(pr_cdcooper    => pr_cdcooper
                           ,pr_cdprogra    => vr_cdprogra
                           ,pr_rw_crapdat  => pr_crapdat
                           ,pr_nrdconta    => pr_nrdconta
                           ,pr_nrctremp    => pr_nrctremp
                           ,pr_dtcalcul    => NULL
                           ,pr_diapagto    => vr_diapagto
                           ,pr_txdjuros    => vr_txdjuros
                           ,pr_qtprepag    => vr_qtprepag
                           ,pr_qtprecal    => vr_qtprecal
                           ,pr_vlprepag    => vr_vlprepag
                           ,pr_vljuracu    => vr_vljuracu
                           ,pr_vljurmes    => vr_vljurmes
                           ,pr_vlsdeved    => vr_vlsdeved
                           ,pr_dtultpag    => vr_dtultpag
                           ,pr_cdcritic    => vr_cdcritic
                           ,pr_des_erro    => vr_dscritic);
    
    -- Verifica se houve retorno de crítica
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PC_LEITURA_LEM: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ------------------------------------------------------------------------------------------------------------
    -- FIM Calculo do Saldo Devedor
    ------------------------------------------------------------------------------------------------------------ 
        
    ------------------------------------------------------------------------------------------------------------
    -- INICIO DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------        
    IF pr_nmtelant = 'COMPEFORA' THEN 
      -- Calcular o valor do ajuste
      vr_vlajuste := vr_vlsdeved - pr_vlsdevat;
             
      -- Valor do ajuste
      IF nvl(vr_vlajuste, 0) > 0 THEN
        -- Lanca em C/C e atualiza o lote
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                      ,pr_cdbccxlt => 100                 --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> Código do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transação
                                      ,pr_nrdolote => 600032              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> Número da conta
                                      ,pr_cdhistor => 2012                --> Codigo historico 2012 - AJUSTE BOLETO
                                      ,pr_vllanmto => vr_vlajuste         --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel         --> Número parcelas empréstimo
                                      ,pr_nrctremp => pr_nrctremp         --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
              
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
     
        -- O Valor do pagamento deverá considerar também o valor do ajuste
        vr_vldpagto := NVL(vr_vldpagto,0) + nvl(vr_vlajuste, 0);
      
      END IF; -- FIM nvl(vr_vlajuste, 0) > 0 
    END IF;   
    ------------------------------------------------------------------------------------------------------------
    -- FIM DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------ 
    
    -- Se for liquidação do acordo
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      -- deve pagar o valor total
      vr_vldpagto := vr_vlsdeved;    
      
    -- Se o valor a pagar for maior que o saldo devedor
    ELSIF vr_vldpagto > vr_vlsdeved THEN
      -- Irá fazer o lançamento do saldo devedor 
      vr_vldpagto := vr_vlsdeved;
    END IF;
    
    -----------------------------------------------------------------------------------------------
    -- Efetuar o pagamento de emprestimo do TR
    -----------------------------------------------------------------------------------------------
    EMPR0007.pc_gera_lancamento_epr_tr(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_vllanmto => vr_vldpagto
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_idorigem => pr_idorigem
                                      ,pr_nmtelant => pr_nmtelant
                                      ,pr_vltotpag => pr_vltotpag
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve retorno de crítica
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PC_GERA_LANCAMENTO_EPR_TR: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EMPRESTIMO_TR;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_TR: '||SQLERRM;
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EMPRESTIMO_TR;
      /**************************/
  END pc_pagar_emprestimo_tr;
  
  
  -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- Número do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                  ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquidação do acordo
                                  ,pr_idorigem  IN NUMBER                       -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                     -- Código do operador
                                  ,pr_idvlrmin OUT NUMBER                       -- Indica que houve critica do valor minimo
                                  ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                  ,pr_dscritic OUT VARCHAR2) IS                 -- Descrição da crítica
    
    -- CURSORES
    --Selecionar Lancamentos
    CURSOR cr_craplem IS
      SELECT SUM(DECODE(craplem.cdhistor
                       ,1043
                       ,craplem.vllanmto * -1
                       ,1041
                       ,craplem.vllanmto * -1
                       ,1040
                       ,craplem.vllanmto
                       ,1042
                       ,craplem.vllanmto
                       ,2311
                       ,craplem.vllanmto * -1
                       ,2312
                       ,craplem.vllanmto * -1))
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN (1040, 1041, 1042, 1043, 2311, 2312);
        
    -- VARIÁVEIS
    vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
    vr_tab_pagto_compe empr0001.typ_tab_pgto_parcel;
    vr_tab_calculado   empr0001.typ_tab_calculado;
    vr_tab_calc_compe  empr0001.typ_tab_calculado;
    
    vr_dtdatmvt        DATE;
    vr_dtdatoan        DATE;
    vr_vldpagto        NUMBER := pr_vlparcel;
    vr_vlpagpar        NUMBER;
    vr_vldsaldo        NUMBER;
    vr_vlajuste        NUMBER := 0;
    vr_vllanlem        NUMBER := 0;
    
    vr_des_reto        VARCHAR2(10);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- EXCEPTION
    vr_exc_erro        EXCEPTION;
    
    -- Função para retornar o ultimo dia util anterior
    FUNCTION fn_dia_util_anterior(pr_data IN DATE) RETURN DATE IS
    
    BEGIN

      /* Pega o ultimo dia util anterior ao parametro */
      RETURN(gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_data-1   --> Data do movimento
                                        ,pr_tipo     => 'A'));      --> Tipo de busca (P = próximo, A = anterior)
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na FN_DIA_UTIL_ANTERIOR '||SQLERRM;
        RAISE vr_exc_erro;
    END fn_dia_util_anterior;
    
  BEGIN
    
    /** SAVEPOINT PARA CONTROLE DA TRANSAÇÃO **/
    SAVEPOINT SAVE_EMPRESTIMO_PP;
    /******************************************/
  
    -----------------------------------------------------------------------------------------------
    -- Buscar as parcelas do contrato
    -----------------------------------------------------------------------------------------------
    EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper        => pr_cdcooper
                                   ,pr_cdagenci        => pr_cdagenci
                                   ,pr_nrdcaixa        => 1
                                   ,pr_cdoperad        => pr_cdoperad
                                   ,pr_nmdatela        => pr_nmtelant
                                   ,pr_idorigem        => pr_idorigem
                                   ,pr_nrdconta        => pr_nrdconta
                                   ,pr_idseqttl        => 1
                                   ,pr_dtmvtolt        => pr_crapdat.dtmvtolt
                                   ,pr_flgerlog        => 'N'
                                   ,pr_nrctremp        => pr_nrctremp
                                   ,pr_dtmvtoan        => pr_crapdat.dtmvtoan
                                   ,pr_nrparepr        => 0
                                   ,pr_des_reto        => vr_des_reto
                                   ,pr_tab_erro        => vr_tab_erro
                                   ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                   ,pr_tab_calculado   => vr_tab_calculado);

    -- Verificar o retorno de erros
    IF vr_des_reto <> 'OK' THEN
      -- Se possui algum erro na tabela de erros
      IF vr_tab_erro.count() > 0 THEN
        -- Atribui críticas às variaveis
        pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao consultar pagamento de parcelas';
      END IF;
      -- Gera exceção
      RAISE vr_exc_erro;
    END IF;      
    
    -- Caso o saldo devedor total do empréstimo for menor que o valor pago no boleto 
    IF vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved < vr_vldpagto THEN
      -- Devemos considerar somente o valor para pagar o saldo devedor.
      vr_vldpagto := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved;
    END IF;
    
    -- Inicializa o valor do ajuste 
    vr_vlajuste := 0;  
    
    ------------------------------------------------------------------------------------------------------------
    -- BUSCAR OS VALORES RETROATIVOS DEVIDO AO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------        
    IF pr_nmtelant = 'COMPEFORA' THEN 
      
      -- Utiliza a data anterior como data de movimento
      vr_dtdatmvt := pr_crapdat.dtmvtoan;
        
      -- Buscar como data anterior o dia útil anterior a data de movimento anterior da base
      vr_dtdatoan := fn_dia_util_anterior(vr_dtdatmvt);
        
      -- Chamar novamente a procedure "pc_busca_pgto_parcelas" e passar nas datas "dtmvtolt, dtmvtoan" o dia anterior
      EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper        => pr_cdcooper
                                     ,pr_cdagenci        => pr_cdagenci
                                     ,pr_nrdcaixa        => 1
                                     ,pr_cdoperad        => pr_cdoperad
                                     ,pr_nmdatela        => pr_nmtelant
                                     ,pr_idorigem        => pr_idorigem
                                     ,pr_nrdconta        => pr_nrdconta
                                     ,pr_idseqttl        => 1
                                     ,pr_dtmvtolt        => vr_dtdatmvt -- Data com base no dia anterior
                                     ,pr_flgerlog        => 'N'
                                     ,pr_nrctremp        => pr_nrctremp
                                     ,pr_dtmvtoan        => vr_dtdatoan -- Data com base no dia anterior
                                     ,pr_nrparepr        => 0
                                     ,pr_des_reto        => vr_des_reto
                                     ,pr_tab_erro        => vr_tab_erro
                                     ,pr_tab_pgto_parcel => vr_tab_pagto_compe
                                     ,pr_tab_calculado   => vr_tab_calc_compe);
        
      -- Verificar o retorno de erros
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.count() > 0 THEN
          -- Atribui críticas às variaveis
          pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao consultar pagamento de parcelas COMPEFORA';
        END IF;
        -- Gera exceção
        RAISE vr_exc_erro;
      END IF; 
        
      -- Se encontrar registros
      IF vr_tab_pagto_compe.COUNT() > 0 THEN
        -- Percorrer todos os registros retornados nas tabelas de memória
        FOR idx IN vr_tab_pagto_compe.FIRST..vr_tab_pagto_compe.LAST LOOP
          -- IRÁ CALCULAR O VALOR DE TODAS AS PARCELAS
          vr_tab_pagto_compe(idx).vlpagpar := NVL(vr_tab_pagto_compe(idx).vlatupar,0) +
                                              NVL(vr_tab_pagto_compe(idx).vlmtapar,0) +
                                              NVL(vr_tab_pagto_compe(idx).vlmrapar,0) +
                                              NVL(vr_tab_pagto_compe(idx).vliofcpl,0) ;
               
        END LOOP;
      END IF;
    END IF; -- COMPEFORA
    
    -- Caso o saldo devedor total do empréstimo for menor que o valor pago no boleto OU
    -- estiver realizando a quitação do acordo
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      -- Devemos considerar somente o valor para pagar o saldo devedor.
      vr_vldpagto := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved;
    END IF;
    
    -- O saldo para pagamento é o valor da parcela
    vr_vldsaldo := vr_vldpagto;
    
    -- Se encontrar registros -- IRÁ CALCULAR O VALOR DAS PARCELAS A SEREM PAGAS
    IF vr_tab_pgto_parcel.COUNT() > 0 THEN
      -- Percorrer todos os registros retornados nas tabelas de memória
      FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
        
        -- Se ainda possui saldo para pagar
        IF vr_vldsaldo > 0 THEN
          -- Calcula o valor da parcela
          vr_vlpagpar := NVL(vr_tab_pgto_parcel(idx).vlatupar,0) +
                         NVL(vr_tab_pgto_parcel(idx).vlmtapar,0) +
                         NVL(vr_tab_pgto_parcel(idx).vlmrapar,0) +
                         NVL(vr_tab_pgto_parcel(idx).vliofcpl,0) ;
          
          -- SE ESTIVER EXECUTANDO PELA COMPEFORA DEVE CALCULAR O VALOR DO AJUSTE
          IF pr_nmtelant = 'COMPEFORA' THEN 
            -- SE ENCONTRAR O REGISTRO COM OS VALORES DA COMPEFORA
            IF vr_tab_pagto_compe.EXISTS(idx) THEN
              -- A diferenca do campo "vlatrpag" de ontem e de hoje, deverá ser lançamento como ajuste.
              vr_vlajuste := vr_vlajuste + (NVL(vr_vlpagpar,0) - NVL(vr_tab_pagto_compe(idx).vlpagpar,0));
              
              -- O ajuste deve ser considerado no saldo para pagamentob 
              vr_vldsaldo := vr_vldsaldo + (NVL(vr_vlpagpar,0) - NVL(vr_tab_pagto_compe(idx).vlpagpar,0));
            END IF;  
          END IF; -- COMPEFORA
                    
          -- Se o saldo para pagar é maior que o valor da parcela
          IF vr_vldsaldo > vr_vlpagpar THEN
            vr_vldsaldo := vr_vldsaldo - vr_vlpagpar;
          ELSE 
            -- Utiliza todo o saldo restante
            vr_vlpagpar := vr_vldsaldo;
            vr_vldsaldo := 0;
          END IF;
          
          -- Indica o valor a ser pago da parcela
          vr_tab_pgto_parcel(idx).vlpagpar := vr_vlpagpar;
        ELSE 
          -- Não irá pagar valor algum da parcela
          vr_tab_pgto_parcel.DELETE(idx);
          -- Se encontrar a parcela da COMPE
          IF vr_tab_pagto_compe.EXISTS(idx) THEN
            vr_tab_pagto_compe.DELETE(idx);
          END IF;
        END IF;
        
      END LOOP;
    END IF;
      
    -- Valor do ajuste -- Quando o processamento se der pela COMPEFORA
    IF nvl(vr_vlajuste, 0) > 0 THEN
      
      -- O Valor do pagamento deverá considerar também o valor do ajuste
      vr_vldpagto := NVL(vr_vldpagto,0) + nvl(vr_vlajuste, 0);
      
    END IF; -- FIM nvl(vr_vlajuste, 0) > 0 
 
    ------------------------------------------------------------------------------------------------------------
    -- FIM DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------ 
    
    -- Inicializa o indicador retornado
    pr_idvlrmin := 0;
    
    -----------------------------------------------------------------------------------------------
    -- Efetuar o pagamento das parcelas
    -----------------------------------------------------------------------------------------------
    EMPR0001.pc_gera_pagamentos_parcelas(pr_cdcooper        => pr_cdcooper
                                        ,pr_cdagenci        => pr_cdagenci
                                        ,pr_nrdcaixa        => 1
                                        ,pr_cdoperad        => pr_cdoperad
                                        ,pr_nmdatela        => pr_nmtelant
                                        ,pr_idorigem        => pr_idorigem
                                        ,pr_cdpactra        => pr_cdagenci
                                        ,pr_nrdconta        => pr_nrdconta
                                        ,pr_idseqttl        => 1
                                        ,pr_dtmvtolt        => pr_crapdat.dtmvtolt
                                        ,pr_flgerlog        => 'S'
                                        ,pr_nrctremp        => pr_nrctremp
                                        ,pr_dtmvtoan        => pr_crapdat.dtmvtoan
                                        ,pr_totatual        => vr_vldpagto
                                        ,pr_totpagto        => 0 --- ?????
                                        ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                        ,pr_des_reto        => vr_des_reto
                                        ,pr_tab_erro        => vr_tab_erro);
                                           
    IF vr_des_reto <> 'OK' THEN
      -- Se possui algum erro na tabela de erros
      IF vr_tab_erro.count() > 0 THEN
        -------------------------------------------------------------
        -- SE O ERRO INDICAR ERRO DE PAGAMENTO DO VALOR MÍNIMO, DEVE
        -- CONTINUAR NORMALMENTE - SEM EFETUAR RAISE
        -------------------------------------------------------------
        IF FN_ERRO_VALOR_MINIMO(vr_tab_erro) THEN
          -- GERAR LOG REFERENTE AO VALOR MINIMO - Apenas para registro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo normal
                                    ,pr_nmarqlog     => vr_dsarqlog 
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' -->  ACORDO ['||pr_nracordo||'/'||pr_nrdconta||'/'||pr_nrctremp||'] - ' ||
                                                        'ERRO: ' || vr_tab_erro(vr_tab_erro.first).dscritic || ' [VALOR_MINIMO].');
          
          -- Indica a ocorrencia de critica do valor mínimo para a rotina chamadora
          pr_idvlrmin := 1;
          
          -- Limpar informações de erros
          vr_tab_erro.DELETE();
          pr_cdcritic := NULL;
          pr_dscritic := NULL;
        ELSE
          -- Atribui críticas às variaveis
          pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          -- Gera exceção
          RAISE vr_exc_erro;
        END IF;
      ELSE
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao gerar pagamento de parcelas';
        -- Gera exceção
        RAISE vr_exc_erro;
      END IF;
    END IF;
      
    -- Inicializa o parametro
    pr_vltotpag := 0;
    
    -- Percorrer a tabela de memória de parcelas pagas, somando o total de valores pagos 
    IF vr_tab_pgto_parcel.COUNT() > 0 THEN
      -- Percorrer todos os registros
      FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
        -- Verifica se a parcela foi paga
        IF NVL(vr_tab_pgto_parcel(idx).inpagmto,0) = 1 THEN
          pr_vltotpag := pr_vltotpag + NVL(vr_tab_pgto_parcel(idx).vlpagpar,0);
        END IF;
      END LOOP;
    END IF;
    
    
    -- REALIZAR O LANÇAMENTO DO AJUSTE CALCULADO NA COMPEFORA
    IF nvl(vr_vlajuste, 0) > 0 THEN
      
      -- Buscar o valor de lançamento dos historicos de ajuste
      OPEN  cr_craplem;
      FETCH cr_craplem INTO vr_vllanlem;
      
      -- Se não encontrar registro
      IF cr_craplem%NOTFOUND THEN
        vr_vllanlem := 0;
      END IF;
      
      -- FEchar cursor
      CLOSE cr_craplem;
      
      -- Realiza o ajuste de lançamento
      vr_vlajuste := vr_vlajuste + NVL(vr_vllanlem,0);
      
      -- VERIFICAR NOVAMENTE SE O VALOR DO AJUSTE É MAIOR QUE ZERO
      IF nvl(vr_vlajuste, 0) > 0 THEN
      
        -- Lanca em C/C e atualiza o lote
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                      ,pr_cdbccxlt => 100                 --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> Código do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transação
                                      ,pr_nrdolote => 600032              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> Número da conta
                                      ,pr_cdhistor => 2012                --> Codigo historico 2012 - AJUSTE BOLETO
                                      ,pr_vllanmto => vr_vlajuste         --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel         --> Número parcelas empréstimo
                                      ,pr_nrctremp => pr_nrctremp         --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
              
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
      END IF; -- fim IF nvl(vr_vlajuste, 0) > 0
    END IF; -- FIM nvl(vr_vlajuste, 0) > 0 
     
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EMPRESTIMO_PP;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PP: '||SQLERRM;
      
      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EMPRESTIMO_PP;
      /**************************/
  END pc_pagar_emprestimo_pp;
  
  
  -- Efetuar o calculo do lançamento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- Número da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- Código da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE -- Datas da cooperativa
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- Número do contrato de empréstimo 
                                        ,pr_nracordo  IN NUMBER                      -- Número do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- Código do operador
                                        ,pr_vlparcel  IN NUMBER                      -- Valor pago do boleto do acordo
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_nmtelant  IN VARCHAR2                    -- Nome da tela 
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- Código de críticia
                                        ,pr_dscritic OUT VARCHAR2) IS                -- Descrição da crítica
  
    -- Buscar os dados do contrato atrelado ao acordo e que será pago
    CURSOR cr_crapepr IS
      SELECT epr.cdlcremp
           , epr.tpemprst
           , epr.flgpagto
           , epr.inliquid
           , epr.inprejuz
           , epr.qtprepag
           , epr.vlsdeved
           , epr.vlsdevat
           , epr.txjuremp
           , epr.vljuracu
           , epr.vlprejuz
           , epr.vlsdprej
           , epr.vlsprjat
           , epr.vlpreemp
           , epr.vlttmupr
           , epr.vlpgmupr
           , epr.vlttjmpr
           , epr.vlpgjmpr
           , epr.dtultpag
           , epr.vliofcpl
        FROM crapepr  epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr   cr_crapepr%ROWTYPE;
    
    -- VARIÁVEIS
    vr_vlpagmto     NUMBER := pr_vlparcel;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    
    -- EXCEPTIONS
    vr_exp_erro     EXCEPTION;
    
  BEGIN  
    
    -- Buscar dados do contrato 
    OPEN  cr_crapepr;
    FETCH cr_crapepr INTO rw_crapepr;
    
    -- Se o contrato não for encontrado
    IF cr_crapepr%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_crapepr;
      
      -- Deve retornar erro de execução
      pr_cdcritic := 0;
      pr_dscritic := 'Contrato '||TRIM(GENE0002.fn_mask_contrato(pr_nrctremp))||
                     ' do acordo não foi encontrado para a conta '||
                     TRIM(GENE0002.fn_mask_conta(pr_nrdconta))||'.';
      RAISE vr_exp_erro;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_crapepr;
        
    -- Verificar se o contrato já está LIQUIDADO   OU
    -- Se o contrato de PREJUIZO já foi TOTALMENTE PAGO
    IF (rw_crapepr.inliquid = 1 AND rw_crapepr.inprejuz = 0)  OR
       (rw_crapepr.inprejuz = 1 AND rw_crapepr.vlsdprej <= 0) THEN
      pr_vltotpag := 0; -- Indicar que nenhum valor foi pago para este contrato
      RETURN; -- Retornar da rotina
    END IF;
        
    -- Inicializa o indicador
    pr_idvlrmin := 0;
    
    -- Pagamento de Prejuizo
    IF rw_crapepr.inprejuz = 1 THEN
      
      -- Realizar a chamada da rotina para pagamento de prejuizo
      pc_pagar_emprestimo_prejuizo(pr_cdcooper => pr_cdcooper         
                                  ,pr_nrdconta => pr_nrdconta         
                                  ,pr_cdagenci => pr_cdagenci         
                                  ,pr_crapdat  => pr_crapdat
                                  ,pr_nrctremp => pr_nrctremp 
                                  ,pr_tpemprst => rw_crapepr.tpemprst
                                  ,pr_vlprejuz => rw_crapepr.vlprejuz 
                                  ,pr_vlsdprej => rw_crapepr.vlsdprej 
                                  ,pr_vlsprjat => rw_crapepr.vlsprjat 
                                  ,pr_vlpreemp => rw_crapepr.vlpreemp 
                                  ,pr_vlttmupr => rw_crapepr.vlttmupr
                                  ,pr_vlpgmupr => rw_crapepr.vlpgmupr 
                                  ,pr_vlttjmpr => rw_crapepr.vlttjmpr 
                                  ,pr_vlpgjmpr => rw_crapepr.vlpgjmpr
                                  ,pr_nracordo => pr_nracordo 
                                  ,pr_nrparcel => pr_nrparcel
                                  ,pr_cdoperad => pr_cdoperad         
                                  ,pr_vlparcel => vr_vlpagmto
                                  ,pr_nmtelant => pr_nmtelant
                                  ,pr_vliofcpl => rw_crapepr.vliofcpl
                                  ,pr_vltotpag => pr_vltotpag -- Retorno do total pago       
                                  ,pr_cdcritic => vr_cdcritic         
                                  ,pr_dscritic => vr_dscritic);       
    
      -- Se retornar erro da rotina
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exp_erro;
      END IF;
    
    -- Folha de Pagamento
    ELSIF rw_crapepr.flgpagto = 1 THEN 
      
      -- Realizar a chamada da rotina para pagamento de prejuizo
      pc_pagar_emprestimo_folha(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_crapdat  => pr_crapdat
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_nracordo => pr_nracordo
                               ,pr_nrparcel => pr_nrparcel
                               ,pr_cdlcremp => rw_crapepr.cdlcremp
                               ,pr_inliquid => rw_crapepr.inliquid
                               ,pr_qtprepag => rw_crapepr.qtprepag
                               ,pr_vlsdeved => rw_crapepr.vlsdeved
                               ,pr_vlsdevat => rw_crapepr.vlsdevat
                               ,pr_vljuracu => rw_crapepr.vljuracu
                               ,pr_txjuremp => rw_crapepr.txjuremp
                               ,pr_dtultpag => rw_crapepr.dtultpag
                               ,pr_vlparcel => vr_vlpagmto
                               ,pr_nmtelant => pr_nmtelant
                               ,pr_cdoperad => pr_cdcooper
                               ,pr_vltotpag => pr_vltotpag
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
      
      -- Se retornar erro da rotina
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exp_erro;
      END IF;
                 
    -- Pagamento Normal
    ELSE    
      
      -- Emprestimo TR
      IF rw_crapepr.tpemprst = 0 THEN

        -- Pagar empréstimo TR
        pc_pagar_emprestimo_tr(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_crapdat  => pr_crapdat
                              ,pr_nrctremp => pr_nrctremp
                              ,pr_nracordo => pr_nracordo
                              ,pr_nrparcel => pr_nrparcel
                              ,pr_cdlcremp => rw_crapepr.cdlcremp
                              ,pr_inliquid => rw_crapepr.inliquid
                              ,pr_qtprepag => rw_crapepr.qtprepag
                              ,pr_vlsdeved => rw_crapepr.vlsdeved
                              ,pr_vlsdevat => rw_crapepr.vlsdevat
                              ,pr_vljuracu => rw_crapepr.vljuracu
                              ,pr_txjuremp => rw_crapepr.txjuremp
                              ,pr_dtultpag => rw_crapepr.dtultpag
                              ,pr_vlparcel => vr_vlpagmto
                              ,pr_idorigem => pr_idorigem
                              ,pr_nmtelant => pr_nmtelant
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_vltotpag => pr_vltotpag
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
        -- Se retornar erro da rotina
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
          RAISE vr_exp_erro;
        END IF;
      
      -- Emprestimo PP
      ELSIF rw_crapepr.tpemprst = 1 THEN
        
        -- Pagar empréstimo PP
        pc_pagar_emprestimo_pp(pr_cdcooper => pr_cdcooper         
                              ,pr_nrdconta => pr_nrdconta         
                              ,pr_cdagenci => pr_cdagenci         
                              ,pr_crapdat  => pr_crapdat          
                              ,pr_nrctremp => pr_nrctremp         
                              ,pr_nracordo => pr_nracordo         
                              ,pr_nrparcel => pr_nrparcel
                              ,pr_vlsdeved => rw_crapepr.vlsdeved 
                              ,pr_vlsdevat => rw_crapepr.vlsdevat 
                              ,pr_vlparcel => vr_vlpagmto         
                              ,pr_idorigem => pr_idorigem         
                              ,pr_nmtelant => pr_nmtelant         
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_idvlrmin => pr_idvlrmin
                              ,pr_vltotpag => pr_vltotpag         
                              ,pr_cdcritic => vr_cdcritic         
                              ,pr_dscritic => vr_dscritic);       
        
       -- Se retornar erro da rotina
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
          RAISE vr_exp_erro;
        END IF;
      
      END IF;
    END IF;   
  
  EXCEPTION
    WHEN vr_exp_erro THEN
      -- Retornar total pago como zero
      pr_vltotpag := 0;
      -- Deve retornar erro de execução
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retornar total pago como zero
      pr_vltotpag := 0;
      -- Deve retornar erro de execução
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_EMPRESTIMO: '||SQLERRM;
  END pc_pagar_contrato_emprestimo;
  
  
  -- Realizar o pagamentos do acordo
  PROCEDURE pc_pagar_contrato_acordo(pr_nracordo  IN tbrecup_acordo.nracordo%TYPE          -- Número do acordo
                                    ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                    ,pr_vlparcel  IN NUMBER                                -- Valor do boleto pago
                                    ,pr_cdoperad  IN VARCHAR2                              -- Código do operador
                                    ,pr_idorigem  IN NUMBER                                -- Indica a origem
                                    ,pr_nmtelant  IN VARCHAR2                              -- Tela
                                    ,pr_vltotpag OUT NUMBER                                -- Retornar o valor total dos pagamentos realizados
                                    ,pr_cdcritic OUT NUMBER                                -- Retorno de critica/erro
                                    ,pr_dscritic OUT VARCHAR2) IS                          -- Retorno de critica/erro
  
    -- Buscar dados de cooperativa e conta do acordo
    CURSOR cr_acordo IS
      SELECT acd.cdcooper
           , acd.nrdconta
           , SUM(DECODE(aco.cdorigem,1,1,0)) qtestour  -- Quantidade de estouros de conta do acordo
           , SUM(DECODE(aco.cdorigem,1,0,1)) qtempres  -- Quantidade de emprestimos do acordo
           , acd.vlbloqueado
        FROM tbrecup_acordo_contrato  aco
           , tbrecup_acordo           acd
       WHERE aco.nracordo = acd.nracordo
         AND acd.nracordo = pr_nracordo
       GROUP BY acd.cdcooper
              , acd.nrdconta
              , acd.vlbloqueado;
    rw_acordo  cr_acordo%ROWTYPE;
    
    -- Buscar os dados do cooperado
    CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci
           , ass.vllimcre
        FROM crapass  ass
       WHERE ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = pr_cdcooper;
    rw_crapass   cr_crapass%ROWTYPE;
    
    -- Buscar todos os contratos que estao amarrados no acordo
    CURSOR cr_acordo_contrato IS
      SELECT aco.cdcooper
           , aco.nrdconta
           , acc.cdorigem 
           , acc.nrctremp
        FROM crapass                  ass
           , crapcyb                  cyb
           , tbrecup_acordo_contrato  acc
           , tbrecup_acordo           aco
       WHERE ass.cdcooper = aco.cdcooper
         AND ass.nrdconta = aco.nrdconta
         AND cyb.cdcooper = aco.cdcooper
         AND cyb.nrdconta = aco.nrdconta
         AND cyb.nrctremp = acc.nrctremp
         AND cyb.cdorigem = acc.cdorigem          
         AND acc.nracordo = aco.nracordo
         AND aco.nracordo = pr_nracordo
       ORDER BY acc.cdorigem       -- 1. Efetuar pagamento do estouro de conta corrente
              , cyb.qtdiaatr DESC  -- 2. Efetuar pagamento do contrato com maior tempo de atraso
              , cyb.vlsdeved DESC  -- 3. Caso haja empate, então, considerar primeiro o contrato com maior saldo devedor
              , cyb.nrctremp ASC;  -- 4. Caso os saldos devedores também sejam iguais, considerar o contrato de menor número
    
    -- REGISTROS
    vr_tab_saldos     EXTR0001.typ_tab_saldos;
    
    -- VARIÁVEIS
    vr_vlsddisp       NUMBER;
    vr_vltotpag       NUMBER;
    vr_idxsaldo       NUMBER;
    vr_des_erro       VARCHAR2(1000);
    vr_tab_erro       GENE0001.typ_tab_erro;
    vr_vlparcel       NUMBER := pr_vlparcel; -- irá trabalhar com a variável, não com o parametro
    vr_cdcritic       NUMBER;
    vr_dscritic       VARCHAR2(1000);
    vr_fldespes       BOOLEAN; -- Indica que deve lançar o valor como despesa
    vr_flbloque       BOOLEAN; -- Indica que deve lançar a sobra como valor bloqueado
    vr_flagerro       BOOLEAN; -- Indica que o processamento de pagamento de acordo apresentou crítica
    vr_idvlrmin       NUMBER := 0; -- Indica que houve critica do valor minimo
    
    --IOF
    vr_vliofpri NUMBER;
    vr_vliofadi NUMBER;
    vr_vliofcpl NUMBER;
    vr_vltaxa_iof_principal VARCHAR2(20);
    vr_qtdiaiof NUMBER;
    vr_flgimune PLS_INTEGER;
    vr_dscatbem VARCHAR2(100);
    vr_cdlcremp NUMBER;
	  
   -- Cursor para bens do contrato: 
    /*Faz o order by dscatbem pois "CASA" e "APARTAMENTO" reduzem as 3 aliquotas de IOF (principal, adicional e complementar) a zero.
    Já "MOTO" reduz apenas as alíquotas de IOF principal e complementar..
    Dessa forma, se tiver um bem que seja CASA ou APARTAMENTO, não precisa mais verificar os outros bens..*/
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS      
      SELECT b.dscatbem, t.cdlcremp
      FROM crapepr t
      INNER JOIN crapbpr b ON b.nrdconta = t.nrdconta AND b.cdcooper = t.cdcooper AND b.nrctrpro = t.nrctremp
      WHERE t.cdcooper = pr_cdcooper
            AND t.nrdconta = pr_nrdconta
            AND t.nrctremp = pr_nrctremp
            AND upper(b.dscatbem) IN ('APARTAMENTO', 'CASA', 'MOTO')
      ORDER BY upper(b.dscatbem) ASC;
    rw_crapbpr cr_crapbpr%ROWTYPE;

    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS      
      SELECT dtdpagto
      FROM crapepr
      WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta
            AND nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;      
    
    -- EXCEPTIONS
    vr_exc_erro       EXCEPTION;
    
  BEGIN      
    
    -- Buscar os dados do acordo
    OPEN  cr_acordo;
    FETCH cr_acordo INTO rw_acordo;
    
    -- Se o acordo não for encontrado
    IF cr_acordo%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_acordo;  
    
      pr_dscritic := 'Acordo número '||pr_nracordo||' não foi encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_acordo;
      
    -- Buscar o CRAPDAT da cooperativa
    OPEN  BTCH0001.cr_crapdat(rw_acordo.cdcooper); 
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
        
    -- Se não encontrar registro na CRAPDAT
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    
      pr_dscritic := 'Erro ao buscar datas da cooperativa('||rw_acordo.cdcooper||').';
      RAISE vr_exc_erro;
    END IF;
        
    -- Fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
    
    -- Buscar os dados do cooperado
    OPEN  cr_crapass(rw_acordo.cdcooper
                    ,rw_acordo.nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Se não encontrar registro na CRAPASS
    IF cr_crapass%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_crapass; 
    
      pr_dscritic := 'Erro ao buscar dados da conta do cooperado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_crapass;
    
    -- Limpar tabela saldos
    vr_tab_saldos.DELETE;
      
    -- Limpar a variavel  
    vr_vlsddisp := 0;
    
    -- Obter Saldo do Dia
    EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_acordo.cdcooper
                               ,pr_rw_crapdat => BTCH0001.rw_crapdat
                               ,pr_cdagenci   => rw_crapass.cdagenci
                               ,pr_nrdcaixa   => 100
                               ,pr_cdoperad   => pr_cdoperad
                               ,pr_nrdconta   => rw_acordo.nrdconta
                               ,pr_vllimcre   => rw_crapass.vllimcre
                               ,pr_dtrefere   => BTCH0001.rw_crapdat.dtmvtolt
                               ,pr_des_reto   => vr_des_erro
                               ,pr_tab_sald   => vr_tab_saldos
                               ,pr_tipo_busca => 'A'
                               ,pr_tab_erro   => vr_tab_erro);
    
    -- Se retornar erro 
    IF vr_des_erro <> 'OK' THEN
      pr_dscritic := 'Erro ao obter saldo: '||vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se encontrou saldo
    IF vr_tab_saldos.COUNT() > 0 THEN
      -- Guardar indice inicial da tabela de saldos
      vr_idxsaldo := vr_tab_saldos.FIRST;
      -- Saldo Disponivel na conta corrente - Descontando o valor pago do boleto
      vr_vlsddisp         := NVL(vr_tab_saldos(vr_idxsaldo).vlsddisp, 0) - nvl(vr_vlparcel,0);
    ELSE 
      pr_dscritic := 'Não foi retornado saldo dia da conta.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se o acordo dispõe de saldo bloqueado
    IF NVL(rw_acordo.vlbloqueado,0) > 0 THEN
      
      -- Valor do boleto será o valor pago do boleto + saldo bloqueado do acordo
      vr_vlparcel := nvl(vr_vlparcel,0) + rw_acordo.vlbloqueado;
      
      -- Gera o lançamento na conta para descontar o saldo bloqueado
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper                  --> Cooperativa conectada
                                    ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt --> Movimento atual
                                    ,pr_cdagenci => rw_crapass.cdagenci          --> Código da agência
                                    ,pr_cdbccxlt => 100                          --> Número do caixa
                                    ,pr_cdoperad => pr_cdoperad                  --> Código do Operador
                                    ,pr_cdpactra => rw_crapass.cdagenci          --> P.A. da transação
                                    ,pr_nrdolote => 650001                       --> Numero do Lote
                                    ,pr_nrdconta => rw_acordo.nrdconta           --> Número da conta
                                    ,pr_cdhistor => 2194                         --> Codigo historico 2194 - CR.DESB.ACORD
                                    ,pr_vllanmto => rw_acordo.vlbloqueado        --> Valor da parcela emprestimo
                                    ,pr_nrparepr => pr_nrparcel                  --> Número parcelas empréstimo
                                    ,pr_nrctremp => 0                            --> Número do contrato de empréstimo
                                    ,pr_des_reto => vr_des_erro                  --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro);                --> Tabela com possíves erros
    
      -- Se ocorreu erro
      IF vr_des_erro <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
        END IF;
        RAISE vr_exc_erro;
      END IF;
      
      -- ZERAR O VALOR BLOQUEADO NA TABELA DE ACORDO
      BEGIN
        -- Alterar a situação do acordo para cancelado
        UPDATE tbrecup_acordo 
           SET vlbloqueado = 0
         WHERE nracordo = pr_nracordo;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao zerar saldo bloqueado: '||SQLERRM;
          RAISE vr_exc_erro;   
      END;
            
    END IF; -- Fim saldo bloqueado do acordo   
    
    /* ---------------------------------------------------------------------------------------------------------
      O sistema Ayllos deverá cadastrar o(s) contrato(s) do acordo como CIN quando identificar o pagamento da 
      entrada ou primeira parcela (do acordo). Caso o contrato já esteja marcado como CIN, o sistema deverá 
      sobrescrever a marcação.
    ----------------------------------------------------------------------------------------------------------*/
    -- Se for o pagamentos da primeira parcela
    IF pr_nrparcel = 0 THEN
      -- Percorre todos os contratos do acordo 
      FOR rw_acordo_contrato IN cr_acordo_contrato LOOP
        BEGIN
          UPDATE crapcyc 
             SET flgehvip = 1
               , cdmotcin = decode(cdmotcin,2,cdmotcin,7,cdmotcin,1)
               , dtaltera = BTCH0001.rw_crapdat.dtmvtolt
			   , cdoperad = 'cyber'
           WHERE cdcooper = rw_acordo_contrato.cdcooper
             AND cdorigem = DECODE(rw_acordo_contrato.cdorigem,2,3,rw_acordo_contrato.cdorigem)
             AND nrdconta = rw_acordo_contrato.nrdconta
             AND nrctremp = rw_acordo_contrato.nrctremp;
             
          -- Se não encontrou registro para alterar
          IF SQL%ROWCOUNT = 0 THEN
            -- Deverá realizar a inclusão do registro
            INSERT INTO crapcyc(cdcooper
                               ,cdorigem
                               ,nrdconta
                               ,nrctremp
                               ,cdoperad
                               ,dtinclus
                               ,cdopeinc
                               ,dtaltera
                               ,flgehvip
                               ,cdmotcin)
                        VALUES (rw_acordo_contrato.cdcooper  -- cdcooper
                               ,DECODE(rw_acordo_contrato.cdorigem,2,3,rw_acordo_contrato.cdorigem)  -- cdorigem
                               ,rw_acordo_contrato.nrdconta  -- nrdconta
                               ,rw_acordo_contrato.nrctremp  -- nrctremp
                               ,pr_cdoperad                  -- cdoperad
                               ,BTCH0001.rw_crapdat.dtmvtolt -- dtinclus
                               ,pr_cdoperad                  -- cdopeinc
                               ,BTCH0001.rw_crapdat.dtmvtolt -- dtaltera
                               ,1                            -- flgehvip
                               ,1);                          -- cdmotcin
           
          END IF; -- IF SQL%ROWCOUNT = 0 

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPCYC: '||SQLERRM;
              
            -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper
                            ,pr_nrdconta => rw_acordo_contrato.nrdconta
                            ,pr_nracordo => pr_nracordo
                            ,pr_nrctremp => rw_acordo_contrato.nrctremp
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsmodule => 'ATUALIZACAO_CIN');
        END;
      END LOOP;
    END IF;  
    
    -- Inicializa os flags, indicando que não há erros de processamento
    vr_flagerro := FALSE;
    
    -- Percorrer os contratos do acordo, conforme a regra de pagamentos
    FOR rw_acordo_contrato IN cr_acordo_contrato LOOP
        
      -- Se a origem estiver indicando ESTOURO DE CONTA
      IF rw_acordo_contrato.cdorigem = 1 THEN
                
        -- Chamar procedure para regularizar o valor do estouro de conta
        pc_pagar_contrato_conta(pr_cdcooper => rw_acordo_contrato.cdcooper
                               ,pr_nrdconta => rw_acordo_contrato.nrdconta
                               ,pr_cdagenci => rw_crapass.cdagenci
                               ,pr_crapdat  => BTCH0001.rw_crapdat
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nracordo => pr_nracordo
                               ,pr_vlsddisp => vr_vlsddisp
                               ,pr_vlparcel => vr_vlparcel
                               ,pr_vltotpag => vr_vltotpag
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
         
        -- Verifica ocorrencia de erro                   
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        
          -- Indicar que houve crítica ao processar o pagamento de estouro de conta
          vr_flagerro := TRUE;
          
          -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
          pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper
                          ,pr_nrdconta => rw_acordo_contrato.nrdconta
                          ,pr_nracordo => pr_nracordo
                          ,pr_nrctremp => rw_acordo_contrato.nrctremp
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
          
          -- Voltar ao Loop para processar o próximo pagamento
          CONTINUE;
          
        END IF;                     
        
        -- Diminuir o valor pago do boleto com o lançamento efetuado na conta corrente
        vr_vlparcel := vr_vlparcel - NVL(vr_vltotpag,0);
        -----------------------------------------------------------------------------------------------
        
        -- Somar o valor pago ao montante total de pagamentos
        pr_vltotpag := NVL(pr_vltotpag,0) + NVL(vr_vltotpag,0);
        -----------------------------------------------------------------------------------------------
        
      -- Se a origem estiver indicando EMPRESTIMO
      ELSIF rw_acordo_contrato.cdorigem in (2,3) THEN
        
        -- Chamar procedure para regularizar o valor do emprestimo
        pc_pagar_contrato_emprestimo(pr_cdcooper => rw_acordo_contrato.cdcooper
                                    ,pr_nrdconta => rw_acordo_contrato.nrdconta
                                    ,pr_nrctremp => rw_acordo_contrato.nrctremp
                                    ,pr_nracordo => pr_nracordo
                                    ,pr_nrparcel => pr_nrparcel
                                    ,pr_cdagenci => rw_crapass.cdagenci
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_crapdat  => BTCH0001.rw_crapdat
                                    ,pr_vlparcel => vr_vlparcel
                                    ,pr_idorigem => pr_idorigem
                                    ,pr_nmtelant => pr_nmtelant
                                    ,pr_idvlrmin => vr_idvlrmin
                                    ,pr_vltotpag => vr_vltotpag
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
        
        -- Verifica ocorrencia de erro                   
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
           
          -- Indicar que houve erro ao processar pagamento de empréstimo
          vr_flagerro := TRUE;
        
          -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
          pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper
                          ,pr_nrdconta => rw_acordo_contrato.nrdconta
                          ,pr_nracordo => pr_nracordo
                          ,pr_nrctremp => rw_acordo_contrato.nrctremp
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsmodule => 'PAGAR_CONTRATO_EMPRESTIMO');
          
          -- Voltar ao Loop para processar o próximo pagamento
          CONTINUE;
        END IF;   
        
        -- Se houver ocorrencia de critica de valor mínimo
        IF NVL(vr_idvlrmin,0) = 1 THEN
          -- Indicar que houve critica ao processar pagamento de empréstimo
          vr_flagerro := TRUE;
        END IF;
        
        -- Diminuir o valor pago do boleto com o lançamento efetuado na conta corrente
        vr_vlparcel := vr_vlparcel - NVL(vr_vltotpag,0);
        -----------------------------------------------------------------------------------------------
        
        -- Novo cálculo de IOF
        vr_dscatbem := NULL;
        vr_cdlcremp := NULL;
        
        --Verifica o primeiro bem do contrato para saber se tem isenção de alíquota
        OPEN cr_crapbpr(pr_cdcooper => rw_acordo_contrato.cdcooper
                       ,pr_nrdconta => rw_acordo_contrato.nrdconta
                       ,pr_nrctremp => rw_acordo_contrato.nrctremp);
        FETCH cr_crapbpr INTO rw_crapbpr;
        IF cr_crapbpr%FOUND THEN
          vr_dscatbem := rw_crapbpr.dscatbem;
          vr_cdlcremp := rw_crapbpr.cdlcremp;
        END IF;
        CLOSE cr_crapbpr;
        
        --Dias de atraso
        OPEN cr_crapepr(pr_cdcooper => rw_acordo_contrato.cdcooper
                       ,pr_nrdconta => rw_acordo_contrato.nrdconta
                       ,pr_nrctremp => rw_acordo_contrato.nrctremp);
        FETCH cr_crapepr INTO rw_crapepr;
        IF cr_crapepr%FOUND THEN
          vr_qtdiaiof := rw_crapepr.dtdpagto - BTCH0001.rw_crapdat.dtmvtolt;
        ELSE
          vr_qtdiaiof := 0;
        END IF;
        CLOSE cr_crapepr;
                              
        --Calcula o IOF
        TIOF0001.pc_calcula_valor_iof_epr(pr_cdcooper => rw_acordo_contrato.cdcooper             --> Código da cooperativa referente ao contrato de empréstimos
                                          ,pr_nrdconta => rw_acordo_contrato.nrdconta            --> Número da conta referente ao empréstimo
                                          ,pr_nrctremp => rw_acordo_contrato.nrctremp            --> Número do contrato de empréstimo
                                          ,pr_vlemprst => vr_vlparcel                            --> Valor do empréstimo para efeito de cálculo
                                          ,pr_dscatbem => vr_dscatbem                            --> Descrição da categoria do bem, valor default NULO 
                                          ,pr_cdlcremp => vr_cdlcremp                            --> Linha de crédito do empréstimo
                                          ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt           --> Data do movimento
                                          ,pr_qtdiaiof => vr_qtdiaiof                            --> Quantidade de dias em atraso
                                          ,pr_vliofpri => vr_vliofpri                            --> Valor do IOF principal
                                          ,pr_vliofadi => vr_vliofadi                            --> Valor do IOF adicional
                                          ,pr_vliofcpl => vr_vliofcpl                            --> Valor do IOF complementar
                                          ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal    --> Valor da Taxa do IOF Principal
                                          ,pr_flgimune => vr_flgimune                            --> Possui imunidade tributária
                                          ,pr_dscritic => vr_dscritic);                          --> Descrição da crítica
                                                
        IF NVL(vr_dscritic, ' ') <> ' ' THEN
				   RAISE vr_exc_erro;
			  END IF;
			  
			  --Imunidade....
        IF vr_flgimune > 0 THEN
          vr_vliofpri := 0;
          vr_vliofadi := 0;
          vr_vliofcpl := 0;
        ELSE
          vr_vliofcpl := NVL(vr_vliofcpl, 0);
        END IF;
        
        -- Somar o valor pago ao montante total de pagamentos
        pr_vltotpag := NVL(pr_vltotpag,0) + NVL(vr_vltotpag,0) + vr_vliofcpl;
        -----------------------------------------------------------------------------------------------
      END IF;
        
      -- Deve sair do loop quando não houver mais saldo disponivel para pagamentos --
      EXIT WHEN vr_vlparcel <= 0;
      -------------------------------------------------------------------------------
      
    END LOOP;  -- cr_acordo_contrato
    
    -- Se sobrou valor de pagamento - Deve verificar se deve lançar como despesa ou como valor bloqueado
    IF vr_vlparcel > 0 THEN
    
      -- Se o acordo possui apenas estouro de conta
      IF rw_acordo.qtestour > 0 AND rw_acordo.qtempres = 0 THEN
        -- Não deve lançar despesa, nem saldo bloqueado, pois o valor já está creditado na conta
        vr_flbloque := FALSE;
        vr_fldespes := FALSE;
      ELSE
        -- Verificar se houve erro no processamento do estouro de conta e/ou empréstimo
        IF vr_flagerro THEN
          -- Caracteriza como saldo bloqueado, pois algum valor não pode ser debitado
          vr_flbloque := TRUE;
          vr_fldespes := FALSE;
        ELSE
          -- Caracteriza como despesa, pois todos os valores foram debitados, mas houve sobra
          vr_flbloque := FALSE;
          vr_fldespes := TRUE;
        END IF;
        
      END IF;
      
      -- Se for para lançar a sobra como SALDO BLOQUEADO
      IF vr_flbloque THEN
        -- Realiza o lançamento do saldo bloqueado na conta corrente do cooperado
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper           --> Cooperativa conectada
                                      ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => rw_crapass.cdagenci          --> Código da agência
                                      ,pr_cdbccxlt => 100                          --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad                  --> Código do Operador
                                      ,pr_cdpactra => rw_crapass.cdagenci          --> P.A. da transação
                                      ,pr_nrdolote => 650001                       --> Numero do Lote
                                      ,pr_nrdconta => rw_acordo.nrdconta           --> Número da conta
                                      ,pr_cdhistor => 2193                         --> Codigo historico 2193 - DEBITO BLOQUEIO ACORDOS
                                      ,pr_vllanmto => vr_vlparcel                  --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel                  --> Número parcelas empréstimo
                                      ,pr_nrctremp => 0                            --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_erro                  --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);                --> Tabela com possíves erros
        
        -- Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
      
        -- Alterar o valor bloqueado no acordo, com o valor lançado
        BEGIN
          -- Alterar a situação do acordo para cancelado
          UPDATE tbrecup_acordo 
             SET vlbloqueado = NVL(vlbloqueado,0) + NVL(vr_vlparcel,0)
           WHERE nracordo = pr_nracordo;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar acordo: '||SQLERRM;
            RAISE vr_exc_erro;   
        END;
        
        -- Adicionar o valor lançado no bloqueado ao total pago... pois o devido destino ao valor já foi dado
        pr_vltotpag := NVL(pr_vltotpag,0) + NVL(vr_vlparcel,0);
      END IF; -- FIM vr_flbloque
              
      -- Se for para lançar a sobra como DESPESA
      IF vr_fldespes THEN
        -- Criar o lançamento de despesa em conta corrente
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper           --> Cooperativa conectada
                                      ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => rw_crapass.cdagenci          --> Código da agência
                                      ,pr_cdbccxlt => 100                          --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad                  --> Código do Operador
                                      ,pr_cdpactra => rw_crapass.cdagenci          --> P.A. da transação
                                      ,pr_nrdolote => 650001                       --> Numero do Lote
                                      ,pr_nrdconta => rw_acordo.nrdconta           --> Número da conta
                                      ,pr_cdhistor => 2182                         --> Codigo historico 2182 - PAGAMENTO DAS DESPESAS ACORDO
                                      ,pr_vllanmto => vr_vlparcel                  --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel                  --> Número parcelas empréstimo
                                      ,pr_nrctremp => 0                            --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_erro     --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
        
        -- Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
        
        -- Adicionar o valor lançado no como despesa ao total pago... pois o devido destino ao valor já foi dado
        pr_vltotpag := NVL(pr_vltotpag,0) + NVL(vr_vlparcel,0);
      END IF;  -- FIM vr_fldespes
     
    END IF; -- FIM vr_vlparcel > 0
    

  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero     
    WHEN OTHERS THEN 
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_ACORDO: '||SQLERRM; 
  END pc_pagar_contrato_acordo;

 -- Gera histórico de alteração CRAPCYC
 PROCEDURE pc_gerar_historico_cdmotcin(pr_cdcooper  IN tbrecup_acordo.cdcooper%TYPE         
                                      ,pr_nrdconta  IN tbrecup_acordo.nrdconta%TYPE 
                                      ,pr_nrctremp  IN tbrecup_acordo_contrato.nrctremp%TYPE                               
                                      ,pr_cdorigem  IN tbrecup_acordo_contrato.cdorigem%TYPE                              
                                      ,pr_cdmotcin  IN tbrecup_acordo_contrato.cdmotcin%TYPE                                 
                                      ,pr_flgehvip  IN tbrecup_acordo_contrato.flgehvip%TYPE                                                               
                                      ,pr_dscritic OUT VARCHAR2                               
                                      ,pr_cdcritic OUT NUMBER       -- Retorno de critica/erro
                                    ) IS                          
  
    -- Buscar dados acordo
    /*
    CURSOR cr_acordo IS
      select A.rowid 
        from tbrecup_acordo_contrato a, 
             tbrecup_acordo b
       where a.nracordo = b.nracordo
         and b.cdcooper = pr_cdcooper
         and b.nrdconta = pr_nrdconta
         and a.nrctremp = pr_nrctremp
         and a.cdorigem = pr_cdorigem;
    */ 

    -- EXCEPTIONS
    vr_exc_erro       EXCEPTION;   

  BEGIN      
    --FOR rw_acordo in cr_acordo LOOP
      --
      IF pr_cdmotcin NOT IN (1,2,7) THEN
        --
        /*
        BEGIN
          UPDATE tbrecup_acordo_contrato
             SET cdmotcin = pr_cdmotcin,
                 flgehvip = pr_flgehvip
           WHERE ROWID = rw_acordo.rowid; 
        EXCEPTION
           WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro UPDATE tbrecup_acordo_contrato: '||SQLERRM;             
        END;
        */
        
        BEGIN
          UPDATE crapcyc
             SET cdmotant = pr_cdmotcin,
                 flvipant = pr_flgehvip
           WHERE cdcooper = pr_cdcooper
             and nrdconta = pr_nrdconta
             and nrctremp = pr_nrctremp
             and cdorigem = pr_cdorigem; 
        EXCEPTION
           WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro UPDATE crapcyc: '||SQLERRM;             
        END;
        --
      END IF;
      --
    --END LOOP;

  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_cdcritic := 0;    
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na pc_gerar_historico_cdmotcin: '||SQLERRM; 
  END pc_gerar_historico_cdmotcin;  
  
 -- Consistir alteração CRAPCYC
 PROCEDURE pc_consistir_alt_cdmotcin(pr_cdcooper  IN tbrecup_acordo.cdcooper%TYPE         
                                    ,pr_nrdconta  IN tbrecup_acordo.nrdconta%TYPE 
                                    ,pr_nrctremp  IN tbrecup_acordo_contrato.nrctremp%TYPE                               
                                    ,pr_cdorigem  IN tbrecup_acordo_contrato.cdorigem%TYPE                              
                                    ,pr_cdmotcin  IN tbrecup_acordo_contrato.cdmotcin%TYPE                                 
                                    ,pr_flgehvip  IN tbrecup_acordo_contrato.flgehvip%TYPE                                                               
                                    ,pr_dscritic OUT VARCHAR2                               
                                    ,pr_cdcritic OUT NUMBER       -- Retorno de critica/erro
                                    ) IS                          

    -- Buscar dados acordo
    CURSOR cr_acordo IS
      select b.cdsituacao
        from tbrecup_acordo_contrato a, 
             tbrecup_acordo b
       where b.cdsituacao = 1
         and a.nracordo = b.nracordo
         and b.cdcooper = pr_cdcooper
         and b.nrdconta = pr_nrdconta
         and a.nrctremp = pr_nrctremp
         and a.cdorigem = pr_cdorigem;

    vr_cdsituacao tbrecup_acordo.cdsituacao%type;

    CURSOR cr_crapcyc IS
      select c.flvipant flgehvip
           , c.cdmotant cdmotcin
        from crapcyc c
       where c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.nrctremp = pr_nrctremp
         and c.cdorigem = pr_cdorigem;

    rw_crapcyc cr_crapcyc%rowtype;

    -- EXCEPTIONS
    vr_exc_erro       EXCEPTION;   
    
  BEGIN
    open cr_crapcyc;
    fetch cr_crapcyc into rw_crapcyc;
    if cr_crapcyc%notfound then
      close cr_crapcyc;
      pr_cdcritic := 0;
      pr_dscritic := 'Registro nao encontrado na tabela crapcyc!';
      raise vr_exc_erro;
    else
      close cr_crapcyc;
    end if;
    
    open cr_acordo;
    fetch cr_acordo into vr_cdsituacao;
    if cr_acordo%notfound then
      vr_cdsituacao := 0;
    else
      vr_cdsituacao := 1;
    end if;
    close cr_acordo;

    IF nvl(pr_cdmotcin,0) IN (2,7) THEN
       pr_cdcritic := NULL;
       pr_dscritic := NULL;
    ELSIF rw_crapcyc.flgehvip = 1 and rw_crapcyc.cdmotcin = 1 THEN
      IF vr_cdsituacao = 1 THEN
         IF pr_cdmotcin <> 1 THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Acordo Ativo. Motivo CIN sera alterado para: 1 ';  
         END IF;
      ELSE
         IF pr_flgehvip = 1 THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Acordo nao esta Ativo. Motivo CIN sera desabilitado.';               
         END IF;
      END IF;
    ELSIF rw_crapcyc.flgehvip = 1 and rw_crapcyc.cdmotcin <> 1 THEN
      IF vr_cdsituacao = 1 THEN
         IF pr_cdmotcin <> 1 THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Acordo Ativo. Motivo CIN sera alterado para: 1 ';  
         END IF;
      ELSE
         IF pr_flgehvip = 1 THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Acordo nao esta Ativo. Motivo CIN sera alterado para: '||rw_crapcyc.cdmotcin;               
         END IF;
      END IF;
    ELSIF  rw_crapcyc.flgehvip = 0 THEN 
      IF vr_cdsituacao = 1 THEN
         IF pr_cdmotcin <> 1 THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Acordo Ativo. Motivo CIN sera alterado para: 1 ';  
         END IF;
      ELSE
         IF pr_flgehvip = 1 THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Acordo nao esta Ativo. Motivo CIN sera desabilitado.';               
         END IF;
      END IF;        
    END IF;
  EXCEPTION
    WHEN  vr_exc_erro THEN
      null;
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na pc_consistir_alt_cdmotcin: '||SQLERRM; 
  END pc_consistir_alt_cdmotcin; 
   
END RECP0001;
/
