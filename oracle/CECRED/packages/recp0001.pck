CREATE OR REPLACE PACKAGE CECRED.RECP0001 IS

  -- Verifica se existe contrato de acordo na situacao informada
  PROCEDURE pc_verifica_situacao_acordo(pr_cdcooper         IN crapepr.cdcooper%TYPE -- Codigo da Cooperativa
                                       ,pr_nrdconta         IN crapepr.nrdconta%TYPE -- Numero da Conta
                                       ,pr_nrctremp         IN crapepr.nrctremp%TYPE -- Numero do contrato
                                       ,pr_flgretativo     OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretquitado   OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretcancelado OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_cdcritic        OUT INTEGER               -- Codigo de criticia
                                       ,pr_dscritic        OUT VARCHAR2);            -- Descricao da critica

  -- Verifica se existe contrato de acordo ativo
  PROCEDURE pc_verifica_acordo_ativo(pr_cdcooper  IN crapepr.cdcooper%TYPE  -- C�digo da Cooperativa
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE  -- N�mero da Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE  -- N�mero do contrato
                                    ,pr_flgativo OUT INTEGER                -- [0 - NAO ATIVO] / [1 - ATIVO]
                                    ,pr_cdcritic OUT INTEGER                -- C�digo de cr�ticia
                                    ,pr_dscritic OUT VARCHAR2);             -- Descri��o da cr�tica
  
  -- Retorna valor bloqueado em acordos
  PROCEDURE pc_ret_vlr_bloq_acordo(pr_cdcooper  IN crapepr.cdcooper%TYPE           -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapepr.nrdconta%TYPE           -- N�mero da Conta
                                  ,pr_vlblqaco OUT tbrecup_acordo.vlbloqueado%TYPE -- Retorna o valor bloqueado
                                  ,pr_cdcritic OUT INTEGER                         -- C�digo de cr�ticia
                                  ,pr_dscritic OUT VARCHAR2);                      -- Descri��o da cr�tica
    
  -- Efetuar o calculo do lan�amento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_conta(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                   ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                   ,pr_cdoperad  IN VARCHAR2                     -- C�digo do cooperado
                                   ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                   ,pr_vlsddisp  IN NUMBER                       -- Valor do saldo dispon�vel
                                   ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                   ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                   ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                   ,pr_dscritic OUT VARCHAR2 );                  -- Descri��o da cr�tica
                                   
  -- Realizar o calculo e pagamento de preju�zo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                        ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo                              
                                        ,pr_tpemprst  IN crapepr.tpemprst%TYPE        -- Tipo do empr�stimo
                                        ,pr_vlprejuz  IN crapepr.vlprejuz%TYPE        -- Valor do preju�zo
                                        ,pr_vlsdprej  IN crapepr.vlsdprej%TYPE        -- Saldo do preju�zo
                                        ,pr_vlsprjat  IN crapepr.vlsprjat%TYPE        -- Saldo anterior do preju�zo
                                        ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE        -- Valor da presta��o do empr�stimo
                                        ,pr_vlttmupr  IN crapepr.vlttmupr%TYPE        -- Valor total da multa do preju�zo
                                        ,pr_vlpgmupr  IN crapepr.vlpgmupr%TYPE        -- Valor pago da multa do preju�zo
                                        ,pr_vlttjmpr  IN crapepr.vlttjmpr%TYPE        -- Valor total dos juros do preju�zo
                                        ,pr_vlpgjmpr  IN crapepr.vlpgjmpr%TYPE        -- Valor pago dos juros do preju�zo
                                        ,pr_cdoperad  IN VARCHAR2                     -- C�digo do cooperado
                                        ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                        ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                        ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                        ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                        ,pr_dscritic OUT VARCHAR2);                   -- Descri��o da cr�tica
                                        
                                        
  -- Realizar o calculo e pagamento de folha de pagamento
  PROCEDURE pc_pagar_emprestimo_folha(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                     ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo 
                                     ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                     ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                     ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- C�digo da linha de cr�dito do empr�stimo
                                     ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                     ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                     ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                     ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                     ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                     ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empr�stimo
                                     ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do �ltimo pagamento
                                     ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                     ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                     ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                     ,pr_cdoperad  IN VARCHAR2                     -- C�digo do operador
                                     ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                     ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                     ,pr_dscritic OUT VARCHAR2);                   -- Descri��o da cr�tica
  
  -- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                  ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- C�digo da linha de cr�dito do empr�stimo
                                  ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                  ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                  ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                  ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empr�stimo
                                  ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do �ltimo pagamento
                                  ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                  ,pr_idorigem  IN NUMBER                       -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                     -- C�digo do operador
                                  ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                  ,pr_dscritic OUT VARCHAR2);                   -- Descri��o da cr�tica
                                  
  -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE         -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE         -- N�mero da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE         -- C�digo da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE   -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE         -- N�mero do contrato de empr�stimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE  -- N�mero do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE         -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE         -- Valor anterior do saldo devedor
                                  ,pr_vlparcel  IN NUMBER                        -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                  ,pr_idorigem  IN NUMBER                        -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                      -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                      -- C�digo do operador
                                  ,pr_idvlrmin OUT NUMBER                        -- Indica que houve critica do valor minimo
                                  ,pr_vltotpag OUT NUMBER                        -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                        -- C�digo de cr�ticia
                                  ,pr_dscritic OUT VARCHAR2);                    -- Descri��o da cr�tica
   
  -- Efetuar o calculo do lan�amento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- N�mero da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- C�digo da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE -- Datas da cooperativa
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- N�mero do contrato de empr�stimo 
                                        ,pr_nracordo  IN NUMBER                      -- N�mero do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- C�digo do operador
                                        ,pr_vlparcel  IN NUMBER                      -- Valor pago do boleto do acordo
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_nmtelant  IN VARCHAR2                    -- Nome da tela 
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- C�digo de cr�ticia
                                        ,pr_dscritic OUT VARCHAR2);                  -- Descri��o da cr�tica
                                                                                     
  -- Realizar o pagamentos do acordo                                                 
  PROCEDURE pc_pagar_contrato_acordo(pr_nracordo  IN tbrecup_acordo.nracordo%TYPE          -- N�mero do acordo
                                    ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                    ,pr_vlparcel  IN NUMBER                                -- Valor do boleto pago
                                    ,pr_cdoperad  IN VARCHAR2                              -- C�digo do operador
                                    ,pr_idorigem  IN NUMBER                                -- Indica a origem
                                    ,pr_nmtelant  IN VARCHAR2                              -- Tela
                                    ,pr_vltotpag OUT NUMBER                                -- Retornar o valor total dos pagamentos realizados
                                    ,pr_cdcritic OUT NUMBER                                -- Retorno de critica/erro
                                    ,pr_dscritic OUT VARCHAR2);                            -- Retorno de critica/erro

END RECP0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RECP0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RECP0001
  --  Sistema  : Rotinas gen�ricas com foco no Sistema de Acordos
  --  Sigla    : RECP
  --  Autor    : Renato Darosci / James Prust Junior
  --  Data     : Setembro/2016.                   Ultima atualizacao: 22/02/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas gen�ricas dos sistemas Oracle
  --
  -- Altera��o : 14/09/2016 - Cria��o da rotina - Renato Darosci/Supero
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
  ---------------------------------------------------------------------------------------------------------------
  
  -- Constante com o nome do programa
  vr_cdprogra     CONSTANT VARCHAR2(8) := 'RECP0001';
  vr_dsarqlog     CONSTANT VARCHAR2(10):= 'acordo.log';
  
  -- Fun��o para verificar se o c�digo de cr�tica faz parte da lista de c�digos de cr�ticas do valor m�nimo
  FUNCTION fn_erro_valor_minimo(pr_tab_erro IN OUT GENE0001.typ_tab_erro) RETURN BOOLEAN IS
    
    -- VARI�VEIS
    vr_dsvlrprm     crapprm.dsvlrprm%TYPE;
    vr_dstabprm     GENE0002.typ_split;
    
  
  BEGIN
    
    -- Buscar o parametro 
    vr_dsvlrprm := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'CRITICA_VLR_MIN_PARCEL');
                                            
    -- N�o retornar valor 
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
          -- Se encontrar o c�digo da critica na lista de c�digos de cr�ticas 
          -- referente ao pagamento do valor m�nimo da parcela
          RETURN TRUE;
        END IF;      
      END LOOP;
    END IF;
    
    -- Se n�o encontrar o c�digo retornar FALSE para tratar como exception
    RETURN FALSE;    
    
  EXCEPTION 
    WHEN OTHERS THEN
      -- Em caso de erro n�o previsto... substitui o erro retornado
      pr_tab_erro(pr_tab_erro.FIRST).cdcritic := 0;
      pr_tab_erro(pr_tab_erro.FIRST).dscritic := 'Erro na FN_ERRO_VALOR_MINIMO: '||SQLERRM;
      -- RETORNA FALSE PARA QUE SEJA REALIZADO O RAISE NO PROGRAMA      
      RETURN FALSE;
  END fn_erro_valor_minimo;  
  
  
  -- Rotina independente para gera��o de LOGS e envio de e-mail de erro
  PROCEDURE pc_gera_log_mail(pr_cdcooper   IN NUMBER                      -- C�digo da cooperativa
                            ,pr_nrdconta   IN NUMBER                      -- N�mero da conta
                            ,pr_nracordo   IN NUMBER                      -- N�mero do acordo
                            ,pr_nrctremp   IN NUMBER DEFAULT 0            -- N�mero do contrato de empr�stimo
                            ,pr_dscritic   IN VARCHAR2                    -- Descri��o da cr�tica
                            ,pr_dsmodule   IN VARCHAR2 DEFAULT NULL) IS   -- Descri��o do m�dulo
                            
    -- ROTINA PRAGMA PARA EVITAR COMMIT INDESEJADO
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    -- CONSTANTES
    vr_dsdemail     CONSTANT VARCHAR2(50) := 'estrategiadecobranca@cecred.coop.br'; -- Email de destino
    vr_dsassunt     CONSTANT VARCHAR2(10) := 'ACORDO';
    
    -- VARI�VEIS
    vr_dsdcorpo     VARCHAR2(4000);
    vr_dsrefere     VARCHAR2(100); -- Ira indicar o Acordo/Conta/Contrato do erro
    vr_dsmodule     VARCHAR2(100);
    vr_des_erro     VARCHAR2(1000);
    
  BEGIN
    
    -- Montar a string indicando a referencia do erro
    vr_dsrefere := '['||pr_nracordo||'/'||pr_nrdconta||'/'||pr_nrctremp||']';
    
    -- Se informou m�dulo
    IF pr_dsmodule IS NOT NULL THEN
      vr_dsmodule := '['||UPPER(pr_dsmodule)||']';
    END IF;
  
    -- Em caso de erro ser� gerado o log e prosseguir� ao pr�ximo pagamento
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => vr_dsarqlog 
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  ACORDO '|| vr_dsrefere || ' - ' ||
                                                  'ERRO: ' || pr_dscritic || ' '||vr_dsmodule||'.');
    
    -- MONTAR O CORPO DA MENSAGEM
    vr_dsdcorpo := 'N�o foi poss�vel efetuar o cr�dito do boleto do acordo na conta corrente, '||
                   'conforme dados abaixo. Favor verificar: <br>'||
                   'Cooperativa: '||pr_cdcooper||'<br>'||
                   'Conta: '||pr_nrdconta||'<br>'||
                   'Acordo: '||pr_nracordo||'<br><br>'||
                   'Para maiores detalhes, consulte o log de pagamento de acordos (LOGTEL).';
    
    -- Realizar a solicita��o do envio do e-mail
    gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                              ,pr_cdprogra        => 'RECP0001'
                              ,pr_des_destino     => vr_dsdemail
                              ,pr_des_assunto     => vr_dsassunt
                              ,pr_des_corpo       => vr_dsdcorpo
                              ,pr_des_anexo       => NULL
                              ,pr_des_erro        => vr_des_erro);
                              
    --Se ocorreu algum erro
    IF vr_des_erro IS NOT NULL  THEN
      -- Em caso de erro ser� gerado o log e prosseguir� ao pr�ximo pagamento
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
      -- Em caso de erro ser� gerado o log e prosseguir� ao pr�ximo pagamento
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3 -- Erro n�o tratato
                                ,pr_nmarqlog     => vr_dsarqlog 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  ACORDO '|| vr_dsrefere || ' - ' ||
                                                    'ERRO: ' || SQLERRM || ' '||vr_dsmodule||'.');
                                                    
      -- EFetua commit do mesmo modo, visto que � apenas para validar a sess�o PRAGMA
      COMMIT;
  END pc_gera_log_mail;
  
  -- Verifica se existe contrato de acordo na situacao informada
  PROCEDURE pc_verifica_situacao_acordo(pr_cdcooper         IN crapepr.cdcooper%TYPE -- Codigo da Cooperativa
                                       ,pr_nrdconta         IN crapepr.nrdconta%TYPE -- Numero da Conta
                                       ,pr_nrctremp         IN crapepr.nrctremp%TYPE -- Numero do contrato
                                       ,pr_flgretativo     OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretquitado   OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_flgretcancelado OUT INTEGER               -- 0 - NAO / 1 - SIM
                                       ,pr_cdcritic        OUT INTEGER               -- Codigo de criticia
                                       ,pr_dscritic        OUT VARCHAR2) IS          -- Descricao da critica
    -- CURSORES
    CURSOR cr_tbrecup(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                     ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                     ,pr_nrctremp tbrecup_acordo_contrato.nrctremp%TYPE) IS
      SELECT tba.cdsituacao
        FROM tbrecup_acordo_contrato tbac
           , tbrecup_acordo tba
       WHERE tba.nracordo = tbac.nracordo
         AND (tbac.nrctremp = pr_nrctremp OR pr_nrctremp = 0)
         AND tba.nrdconta   = pr_nrdconta
         AND tba.cdcooper   = pr_cdcooper;

  BEGIN
    pr_flgretativo     := 0;
    pr_flgretquitado   := 0;
    pr_flgretcancelado := 0;

    FOR rw_tbrecup IN cr_tbrecup(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp) LOOP

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
  PROCEDURE pc_verifica_acordo_ativo(pr_cdcooper  IN crapepr.cdcooper%TYPE -- C�digo da Cooperativa
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE -- N�mero da Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE -- N�mero do contrato
                                    ,pr_flgativo OUT INTEGER               -- [0 - NAO ATIVO] / [1 - ATIVO]
                                    ,pr_cdcritic OUT INTEGER               -- C�digo de cr�ticia
                                    ,pr_dscritic OUT VARCHAR2) IS          -- Descri��o da cr�tica
    -- VARIAVEIS
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(1000);
    vr_exc_erro       EXCEPTION;
    vr_flgretquitado   INTEGER;
    vr_flgretcancelado INTEGER;
    
  BEGIN
    
    RECP0001.pc_verifica_situacao_acordo(pr_cdcooper        => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp        => pr_nrctremp
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
  PROCEDURE pc_ret_vlr_bloq_acordo(pr_cdcooper  IN crapepr.cdcooper%TYPE           -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapepr.nrdconta%TYPE           -- N�mero da Conta
                                  ,pr_vlblqaco OUT tbrecup_acordo.vlbloqueado%TYPE -- Retorna o valor bloqueado
                                  ,pr_cdcritic OUT INTEGER                         -- C�digo de cr�ticia
                                  ,pr_dscritic OUT VARCHAR2) IS                    -- Descri��o da cr�tica
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
  
  
  -- Efetuar o calculo do lan�amento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_conta(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                   ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                   ,pr_cdoperad  IN VARCHAR2                     -- C�digo do cooperado
                                   ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                   ,pr_vlsddisp  IN NUMBER                       -- Valor do saldo dispon�vel
                                   ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                   ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                   ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                   ,pr_dscritic OUT VARCHAR2 ) IS                -- Descri��o da cr�tica
    
    -- VARI�VEIS
    vr_vllanmto       craplcm.vllanmto%TYPE;   -- Valor de Lancamento
    vr_des_reto       VARCHAR2(10);
    vr_tab_erro       GENE0001.typ_tab_erro;
    
    -- EXCEPTION
    vr_exc_erro       EXCEPTION;
    
  BEGIN
    
    -- Verificar se o valor disponivel j� foi regularizado
    IF pr_vlsddisp >= 0 THEN
      pr_vltotpag := 0; -- Indica que nenhum valor foi pago na conta
      RETURN;
    END IF;
    
    /** SAVEPOINT PARA CONTROLE DA TRANSA��O **/
    SAVEPOINT SAVE_CONTRATO_CONTA;
    /******************************************/
    
    -----------------------------------------------------------------------------------------------
    -- Efetuar o calculo do valor do estouro de conta para descontar da parcela paga
    -- N�o � necess�rio que seja realizado o lan�amento em conta pois o valor j� est� creditado
    -- na mesma, devido ao recebimento do valor do boleto pago
    -----------------------------------------------------------------------------------------------
    -- Se o valor da parcela for maior que o valor a ser pago
    IF pr_vlparcel > ABS(pr_vlsddisp) THEN
      -- Ir� pagar a parcela toda
      vr_vllanmto := ABS(pr_vlsddisp);
    -- Se o valor da parcela for menor ou igual ao valor a ser pago
    ELSE
      -- Ir� pagar o total do boleto 
      vr_vllanmto := pr_vlparcel;
    END IF;

    -- Retornar o valor lan�ado
    pr_vltotpag := vr_vllanmto;
        
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_CONTRATO_CONTA;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_CONTA: '||SQLERRM;
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_CONTRATO_CONTA;
      /**************************/
  END pc_pagar_contrato_conta;
  
  
  -- Realizar o calculo e pagamento de preju�zo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                        ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo                               
                                        ,pr_tpemprst  IN crapepr.tpemprst%TYPE        -- Tipo do empr�stimo
                                        ,pr_vlprejuz  IN crapepr.vlprejuz%TYPE        -- Valor do preju�zo
                                        ,pr_vlsdprej  IN crapepr.vlsdprej%TYPE        -- Saldo do preju�zo
                                        ,pr_vlsprjat  IN crapepr.vlsprjat%TYPE        -- Saldo anterior do preju�zo
                                        ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE        -- Valor da presta��o do empr�stimo
                                        ,pr_vlttmupr  IN crapepr.vlttmupr%TYPE        -- Valor total da multa do preju�zo
                                        ,pr_vlpgmupr  IN crapepr.vlpgmupr%TYPE        -- Valor pago da multa do preju�zo
                                        ,pr_vlttjmpr  IN crapepr.vlttjmpr%TYPE        -- Valor total dos juros do preju�zo
                                        ,pr_vlpgjmpr  IN crapepr.vlpgjmpr%TYPE        -- Valor pago dos juros do preju�zo
                                        ,pr_cdoperad  IN VARCHAR2                     -- C�digo do cooperado
                                        ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                        ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                        ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                        ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                        ,pr_dscritic OUT VARCHAR2) IS                 -- Descri��o da cr�tica
  
    -- Buscar o valor total de lan�amentos referente ao pagamento do preju�zo original
    CURSOR cr_craplem(pr_cdhistor  craplem.cdhistor%TYPE) IS
      SELECT SUM(lem.vllanmto) vllanmto
        FROM craplem  lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrctremp = pr_nrctremp
         AND lem.cdhistor = pr_cdhistor;
        
    -- VARI�VEIS
    vr_dtprmutl     DATE; -- Data do primeiro dia �til do m�s
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
    
    /** SAVEPOINT PARA CONTROLE DA TRANSA��O **/
    SAVEPOINT SAVE_EPR_PREJUIZO;
    /******************************************/
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------        
    IF pr_nmtelant = 'COMPEFORA' THEN
      -- Busca o primeiro dia �til do m�s 
      vr_dtprmutl := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => TRUNC(pr_crapdat.dtmvtolt,'MM'));
        
      -- Verifica se � o primeiro dia �til no mes
      IF pr_crapdat.dtmvtolt = vr_dtprmutl THEN
        -- Calcular o valor do ajuste
        vr_vlajuste := pr_vlsdprej - pr_vlsprjat;
          
        -- Se por um motivo n�o previsto o valor do ajuste for menor que zero, considerar zero
        IF NVL(vr_vlajuste, 0) < 0 THEN
          vr_vlajuste := 0;
        END IF;
          
        -- Se o valor do ajuste calculado � maior que zero
        IF NVL(vr_vlajuste, 0) > 0 THEN
          
          -- Lan�a o cr�dito em C/C e atualiza o lote
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_crapdat.dtmvtolt     --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci     --> C�digo da ag�ncia
                                        ,pr_cdbccxlt => 100             --> N�mero do caixa
                                        ,pr_cdoperad => pr_cdoperad     --> C�digo do Operador
                                        ,pr_cdpactra => pr_cdagenci     --> P.A. da transa��o
                                        ,pr_nrdolote => 600032          --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta     --> N�mero da conta
                                        ,pr_cdhistor => 2012            --> Codigo historico 2012 - AJUSTE BOLETO
                                        ,pr_vllanmto => vr_vlajuste     --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparcel     --> N�mero parcelas empr�stimo
                                        ,pr_nrctremp => pr_nrctremp     --> N�mero do contrato de empr�stimo
                                        ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);   --> Tabela com poss�ves erros
          
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
          
          -- O valor a ser pago da parcela ser� o valor da parcela acrescido do valor do ajuste
          vr_vlpagmto := NVL(vr_vlpagmto,0) + nvl(vr_vlajuste, 0);
        END IF; -- FIM NVL(vr_vlajuste, 0) > 0
      END IF; -- FIM pr_dtmvtolt = vr_dtprmutl
    END IF; -- FIM pr_nmtelant = 'COMPEFORA'
    ------------------------------------------------------------------------------------------------------------
    -- FIM DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------        

    -- Se for liquida��o do acordo, deve pagar o valor total do preju�zo
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      vr_vlpagmto := pr_vlsdprej;
    END IF;

    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LAN�AMENTO DE PAGAMENTO DO PREJUIZO ORIGINAL
    ------------------------------------------------------------------------------------------------------------        
    -- Limpar a vari�vel
    vr_vllamlem := NULL;
    
    -- Carregar os valores
    vr_vlpgmupr := pr_vlpgmupr;
    vr_vlpgjmpr := pr_vlpgjmpr;
    vr_vlsdprej := pr_vlsdprej;
    
    -- Buscar o valor total de lan�amentos referente ao pagamento do preju�zo original
    OPEN  cr_craplem(382); 
    FETCH cr_craplem INTO vr_vllamlem;
    CLOSE cr_craplem;
      
    -- Garantir que vari�vel n�o esteja null
    vr_vllamlem := NVL(vr_vllamlem,0);
      
    -- Guardar o valor a pagar no valor do boleto
    vr_vlapagar := vr_vlpagmto;
      
    -- Se o valor do boleto � maior que o prejuizo a pagar, acrescidos dos juros e multas
    IF (vr_vlapagar > ((pr_vlprejuz + pr_vlttmupr + pr_vlttjmpr) - vr_vllamlem )) THEN 
      -- Define o valor total como o valor a ser pago
      vr_vlapagar := ((pr_vlprejuz + pr_vlttmupr + pr_vlttjmpr) - vr_vllamlem );
    END IF;
      
    ------------------------------------------------------------------------------------------------------------------   
    -- Caso o valor do lan�amento for menor ou igual a 0, significa que o pagamento do prejuizo original jah foi pago
    -- ENTAO DEVERA PULAR PARA O PAGAMENTO DE JUROS DE PREJUIZO (((2� ETAPA)))
    ------------------------------------------------------------------------------------------------------------------   
    IF vr_vlapagar <= 0 THEN
      GOTO SEGUNDA_ETAPA;
    END IF;
    
    -- Atualiza o valor para pagamento decrementando o valor a pagar
    vr_vlpagmto := vr_vlpagmto - vr_vlapagar;
    
    -- ROTINA PARA EFETUAR O LAN�AMENTO
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
                                   ,pr_cdorigem => 1                 -- Origem do Lan�amento
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
    
    -- Inicializa as vari�veis dos valores a serem pagos
    vr_vlpgmupr := NULL;
    vr_vlpgjmpr := NULL;
    vr_vlsdprej := NULL;

    -- Se for o tipo de empr�stimo 1
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
      -- Atualizar valor do saldo do Preju�zo
      vr_vlsdprej := pr_vlsdprej - vr_vlapagar;
    END IF;   
    
    /***** Atualiza a informa��o do empr�stimo *****/
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
    
    -- Deve atualizar os valores recebidos por parametro -- DESTE PONTO EM DIANTE UTILIZAR AS VARI�VEIS
    --vr_vlpgmupr := NVL(vr_vlpgmupr,pr_vlpgmupr);
    --vr_vlpgjmpr := NVL(vr_vlpgjmpr,pr_vlpgjmpr);
    vr_vlsdprej := NVL(vr_vlsdprej,pr_vlsdprej);
        
    ------------------------------------------------------------------------------------------------------------
    -- FIM PARA O LAN�AMENTO DE PAGAMENTO DO PREJUIZO ORIGINAL
    ------------------------------------------------------------------------------------------------------------
      
    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LAN�AMENTO DE PAGAMENTO DE JUROS  -->  (((2� ETAPA)))  <--
    ------------------------------------------------------------------------------------------------------------
    /***********/   <<SEGUNDA_ETAPA>>   /***********/
    ------------------------------------------------------------------------------------------------------------
    
    -- Se n�o h� mais valores dispon�vel para pagamentos
    IF vr_vlpagmto > 0 THEN
    
      -- Limpar a vari�vel
      vr_vllamlem := NULL;
        
      -- Buscar o valor disponivel para efetuar o pagamento de juros do prejuizo      
      OPEN  cr_craplem(390); 
      FETCH cr_craplem INTO vr_vllamlem;
      CLOSE cr_craplem;
      
      -- Garantir que vari�vel n�o esteja null
      vr_vllamlem := NVL(vr_vllamlem,0);

      -- Guardar o valor a pagar com o valor restante ds pagamentos anteriores
      vr_vlapagar := vr_vlpagmto;
    
      -- 05/10/2016 - REMOVIDO o "+ pr_vlttmupr + pr_vlttjmpr" porque estes valores j� foram pagos
    
      -- Se o valor disponivel para pagamento � maior que o saldo do prejuizo.. mais taxas
      IF vr_vlapagar > vr_vlsdprej THEN 
        vr_vlapagar := vr_vlsdprej;
      END IF;
    
      -- Verifica se encontrou valor a pagar
      IF vr_vlapagar <= 0 THEN
        -- Caso entrar na condi��o j� foi pago todo o prejuizo do emprestimo
        RETURN;
      END IF;
    
      -- ROTINA PARA EFETUAR O LAN�AMENTO
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
                                     ,pr_cdorigem => 1                 -- Origem do Lan�amento
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
    
      -- Limpa a vari�vel de data
      vr_dtliquid := NULL;
    
      -- Se o valor do preju�zo � maior que o saldo a pagar                                
      IF vr_vlsdprej > vr_vlapagar THEN
        vr_vlsdprej := vr_vlsdprej - vr_vlapagar;
      ELSE
        vr_vlsdprej := 0; -- Zera o preju�zo
        vr_dtliquid := pr_crapdat.dtmvtolt; -- Seta a data de liquida��o
      END IF;
    
      -- Atualiza a informa��o do empr�stimo
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
    -- FIM PARA O LAN�AMENTO DE PAGAMENTO DE JUROS
    ------------------------------------------------------------------------------------------------------------
    
    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LAN�AMENTO DE DEBITO DO PAGAMENTO DE PREJUIZO  -->  (((3� ETAPA)))  <--
    ------------------------------------------------------------------------------------------------------------
    IF pr_vltotpag > 0 THEN
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci         --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 100                 --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> C�digo do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transa��o
                                      ,pr_nrdolote => 650001              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> N�mero da conta
                                      ,pr_cdhistor => 384                 --> Codigo historico
                                      ,pr_vllanmto => pr_vltotpag         --> Valor do debito
                                      ,pr_nrparepr => pr_nrparcel         --> N�mero parcelas empr�stimo
                                      ,pr_nrctremp => 0                   --> N�mero do contrato de empr�stimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com poss�ves erros
      
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
    END IF;    
    
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EPR_PREJUIZO;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PREJUIZO: '||SQLERRM;
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EPR_PREJUIZO;
      /**************************/
  END pc_pagar_emprestimo_prejuizo;
  
  
  -- Realizar o calculo e pagamento de folha de pagamento
  PROCEDURE pc_pagar_emprestimo_folha(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                     ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo 
                                     ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                     ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                     ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- C�digo da linha de cr�dito do empr�stimo
                                     ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                     ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                     ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                     ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                     ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                     ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empr�stimo
                                     ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do �ltimo pagamento
                                     ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                     ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                     ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                     ,pr_cdoperad  IN VARCHAR2                     -- C�digo do operador
                                     ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                     ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                     ,pr_dscritic OUT VARCHAR2) IS                 -- Descri��o da cr�tica
      
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
     
    -- Buscar dados da linha de cr�dito do empr�stimo
    CURSOR cr_craplcr IS
      SELECT lcr.txdiaria
        FROM craplcr  lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr    cr_craplcr%ROWTYPE;
  
    -- VARI�VEIS
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
    
    -- Vari�veis para calculo do saldo devedor
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
    -- Se n�o retornou valor
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
    
    -- Se indicar o uso da tabela de taxa de juros e empr�stimo n�o estiver liquidado
    IF vr_inusatab AND pr_inliquid = 0 THEN
      -- Buscar a linha de credito
      OPEN  cr_craplcr;
      FETCH cr_craplcr INTO rw_craplcr;
      
      -- Se n�o encontrar informa��es da Linha de Cr�dito
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        -- Sen�o encontrou a linha de credito devera sair da procedure e fazer o proximo pagamento
        pr_cdcritic := 356;
        pr_dscritic := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Utiliza a taxa de juros di�ria da linha de cr�dito
        vr_txdjuros := rw_craplcr.txdiaria;
        CLOSE cr_craplcr;
      END IF;
    ELSE
      -- Utiliza a taxa de juros do empr�stimo
      vr_txdjuros := pr_txjuremp;
    END IF;
    
    /** SAVEPOINT PARA CONTROLE DA TRANSA��O **/
    SAVEPOINT SAVE_EPR_FOLHA;
    /******************************************/
    
    ----------------------------------------------------------------------- 
    -- Chamar rotina de c�lculo externa
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
    
    -- Verifica se houve retorno de cr�tica
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
                                      ,pr_cdagenci => pr_cdagenci         --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 100                 --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> C�digo do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transa��o
                                      ,pr_nrdolote => 600032              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> N�mero da conta
                                      ,pr_cdhistor => 2012                --> Codigo historico 2012 - AJUSTE BOLETO
                                      ,pr_vllanmto => vr_vlajuste         --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel         --> N�mero parcelas empr�stimo
                                      ,pr_nrctremp => pr_nrctremp         --> N�mero do contrato de empr�stimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com poss�ves erros
              
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
     
        -- O Valor do pagamento dever� considerar tamb�m o valor do ajuste
        vr_vldpagto := NVL(vr_vldpagto,0) + nvl(vr_vlajuste, 0);
      
      END IF; -- FIM nvl(vr_vlajuste, 0) > 0 
    END IF;   
    ------------------------------------------------------------------------------------------------------------
    -- FIM DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------ 
    
    -- Se for liquida��o do acordo, deve pagar o valor total
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
   
    -- Verifica se houve retorno de cr�tica
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
    -- 2             50,00               30,00                 0 - N�o Pago
    --
    -----------------------------------------------------------------------------------------------        
    
    -- Atualizar o valor conforme o c�lculo da 120 
    pr_vltotpag := NVL(vr_vldebtot,0);
    
    -- Percorrer os avisos do contrato
    FOR rw_crapavs IN cr_crapavs LOOP
      
      -- Se o valor do estouro ou diferen�a for menor ou igual que o valor total de d�bito
      IF rw_crapavs.vlestdif <= NVL(vr_vldebtot,0) THEN
        -- Quando pagar o valor total...
        vr_vlestdif := 0;
        vr_vldebtot := NVL(vr_vldebtot,0) - rw_crapavs.vlestdif;
        vr_vldebito := rw_crapavs.vldebito + rw_crapavs.vlestdif;
        vr_insitavs := 1;
        vr_flgproce := 1;        
      ELSE
        -- Quando pagar uma parte do valor....
        vr_vlestdif := NVL(vr_vldebtot,0) - rw_crapavs.vlestdif; -- ATEN��O: Este campo � gravado NEGATIVO
        vr_vldebito := rw_crapavs.vldebito + NVL(vr_vldebtot,0);
        vr_vldebtot := 0;
        vr_insitavs := 0;
        vr_flgproce := 0;
      END IF;
      
      -- Atualiza��o do aviso
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
                                  ,pr_cdagenci => pr_cdagenci   --> C�digo da ag�ncia
                                  ,pr_cdbccxlt => 100           --> N�mero do caixa
                                  ,pr_cdoperad => pr_cdoperad   --> C�digo do Operador
                                  ,pr_cdpactra => pr_cdagenci   --> P.A. da transa��o
                                  ,pr_nrdolote => 650001        --> Numero do Lote
                                  ,pr_nrdconta => pr_nrdconta   --> N�mero da conta
                                  ,pr_cdhistor => 275           --> Codigo historico
                                  ,pr_vllanmto => pr_vltotpag   --> Valor do credito
                                  ,pr_nrparepr => pr_nrparcel   --> N�mero parcelas empr�stimo
                                   ,pr_nrctremp => 0             --> N�mero do contrato de empr�stimo
                                  ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                  ,pr_tab_erro => vr_tab_erro); --> Tabela com poss�ves erros
              
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
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EPR_FOLHA;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_FOLHA: '||SQLERRM;
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EPR_FOLHA;
      /**************************/
  END pc_pagar_emprestimo_folha;
  
  -- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                  ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE        -- C�digo da linha de cr�dito do empr�stimo
                                  ,pr_inliquid  IN crapepr.inliquid%TYPE        -- Indicador de liquidado
                                  ,pr_qtprepag  IN crapepr.qtprepag%TYPE        -- Quantidade de prestacoes pagas
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                  ,pr_vljuracu  IN crapepr.vljuracu%TYPE        -- Valor dos juros acumulados
                                  ,pr_txjuremp  IN crapepr.txjuremp%TYPE        -- Taxa de juros do empr�stimo
                                  ,pr_dtultpag  IN crapepr.dtultpag%TYPE        -- Data do �ltimo pagamento
                                  ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                  ,pr_idorigem  IN NUMBER                       -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                     -- C�digo do operador
                                  ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                  ,pr_dscritic OUT VARCHAR2) IS                 -- Descri��o da cr�tica
           
    -- Buscar dados da linha de cr�dito do empr�stimo
    CURSOR cr_craplcr IS
      SELECT lcr.txdiaria
        FROM craplcr  lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr    cr_craplcr%ROWTYPE;
  
    -- VARI�VEIS
    vr_dstextab     craptab.dstextab%TYPE;
    vr_inusatab     BOOLEAN;
    vr_vldpagto     NUMBER := pr_vlparcel;
    vr_vlajuste     NUMBER := 0;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    
    -- Vari�veis para calculo do saldo devedor
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
    -- Se n�o retornou valor
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
    
    -- Se indicar o uso da tabela de taxa de juros e empr�stimo n�o estiver liquidado
    IF vr_inusatab AND pr_inliquid = 0 THEN
      -- Buscar a linha de credito
      OPEN  cr_craplcr;
      FETCH cr_craplcr INTO rw_craplcr;
      
      -- Se n�o encontrar informa��es da Linha de Cr�dito
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        -- Sen�o encontrou a linha de credito devera sair da procedure e fazer o proximo pagamento
        pr_cdcritic := 356;
        pr_dscritic := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Utiliza a taxa de juros di�ria da linha de cr�dito
        vr_txdjuros := rw_craplcr.txdiaria;
        CLOSE cr_craplcr;
      END IF;
    ELSE
      -- Utiliza a taxa de juros do empr�stimo
      vr_txdjuros := pr_txjuremp;
    END IF;
    
    /** SAVEPOINT PARA CONTROLE DA TRANSA��O **/
    SAVEPOINT SAVE_EMPRESTIMO_TR;
    /******************************************/
    
    ----------------------------------------------------------------------- 
    -- Chamar rotina de c�lculo externa
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
    
    -- Verifica se houve retorno de cr�tica
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
                                      ,pr_cdagenci => pr_cdagenci         --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 100                 --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> C�digo do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transa��o
                                      ,pr_nrdolote => 600032              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> N�mero da conta
                                      ,pr_cdhistor => 2012                --> Codigo historico 2012 - AJUSTE BOLETO
                                      ,pr_vllanmto => vr_vlajuste         --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel         --> N�mero parcelas empr�stimo
                                      ,pr_nrctremp => pr_nrctremp         --> N�mero do contrato de empr�stimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com poss�ves erros
              
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
     
        -- O Valor do pagamento dever� considerar tamb�m o valor do ajuste
        vr_vldpagto := NVL(vr_vldpagto,0) + nvl(vr_vlajuste, 0);
      
      END IF; -- FIM nvl(vr_vlajuste, 0) > 0 
    END IF;   
    ------------------------------------------------------------------------------------------------------------
    -- FIM DO TRATAMENTO DA COMPEFORA
    ------------------------------------------------------------------------------------------------------------ 
    
    -- Se for liquida��o do acordo
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      -- deve pagar o valor total
      vr_vldpagto := vr_vlsdeved;    
      
    -- Se o valor a pagar for maior que o saldo devedor
    ELSIF vr_vldpagto > vr_vlsdeved THEN
      -- Ir� fazer o lan�amento do saldo devedor 
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
    
    -- Verifica se houve retorno de cr�tica
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PC_GERA_LANCAMENTO_EPR_TR: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EMPRESTIMO_TR;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_TR: '||SQLERRM;
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EMPRESTIMO_TR;
      /**************************/
  END pc_pagar_emprestimo_tr;
  
  
  -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo 
                                  ,pr_nracordo  IN tbrecup_acordo.nracordo%TYPE -- N�mero do acordo
                                  ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                  ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                  ,pr_vlsdevat  IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                  ,pr_vlparcel  IN NUMBER                       -- Valor pago do boleto do acordo
                                  ,pr_inliqaco  IN VARCHAR2 DEFAULT 'N'         -- Indica que deve realizar a liquida��o do acordo
                                  ,pr_idorigem  IN NUMBER                       -- Indicador da origem
                                  ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela 
                                  ,pr_cdoperad  IN VARCHAR2                     -- C�digo do operador
                                  ,pr_idvlrmin OUT NUMBER                       -- Indica que houve critica do valor minimo
                                  ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                  ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                  ,pr_dscritic OUT VARCHAR2) IS                 -- Descri��o da cr�tica
    
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
                       ,craplem.vllanmto))
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN (1040, 1041, 1042, 1043);
        
    -- VARI�VEIS
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
    
    -- Fun��o para retornar o ultimo dia util anterior
    FUNCTION fn_dia_util_anterior(pr_data IN DATE) RETURN DATE IS
    
    BEGIN

      /* Pega o ultimo dia util anterior ao parametro */
      RETURN(gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_data-1   --> Data do movimento
                                        ,pr_tipo     => 'A'));      --> Tipo de busca (P = pr�ximo, A = anterior)
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na FN_DIA_UTIL_ANTERIOR '||SQLERRM;
        RAISE vr_exc_erro;
    END fn_dia_util_anterior;
    
  BEGIN
    
    /** SAVEPOINT PARA CONTROLE DA TRANSA��O **/
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
        -- Atribui cr�ticas �s variaveis
        pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao consultar pagamento de parcelas';
      END IF;
      -- Gera exce��o
      RAISE vr_exc_erro;
    END IF;      
    
    -- Caso o saldo devedor total do empr�stimo for menor que o valor pago no boleto 
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
        
      -- Buscar como data anterior o dia �til anterior a data de movimento anterior da base
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
          -- Atribui cr�ticas �s variaveis
          pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao consultar pagamento de parcelas COMPEFORA';
        END IF;
        -- Gera exce��o
        RAISE vr_exc_erro;
      END IF; 
        
      -- Se encontrar registros
      IF vr_tab_pagto_compe.COUNT() > 0 THEN
        -- Percorrer todos os registros retornados nas tabelas de mem�ria
        FOR idx IN vr_tab_pagto_compe.FIRST..vr_tab_pagto_compe.LAST LOOP
          -- IR� CALCULAR O VALOR DE TODAS AS PARCELAS
          vr_tab_pagto_compe(idx).vlpagpar := NVL(vr_tab_pagto_compe(idx).vlatupar,0) +
                                              NVL(vr_tab_pagto_compe(idx).vlmtapar,0) +
                                              NVL(vr_tab_pagto_compe(idx).vlmrapar,0);
               
        END LOOP;
      END IF;
    END IF; -- COMPEFORA
    
    -- Caso o saldo devedor total do empr�stimo for menor que o valor pago no boleto OU
    -- estiver realizando a quita��o do acordo
    IF NVL(pr_inliqaco,'N') = 'S' THEN
      -- Devemos considerar somente o valor para pagar o saldo devedor.
      vr_vldpagto := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved;
    END IF;
    
    -- O saldo para pagamento � o valor da parcela
    vr_vldsaldo := vr_vldpagto;
    
    -- Se encontrar registros -- IR� CALCULAR O VALOR DAS PARCELAS A SEREM PAGAS
    IF vr_tab_pgto_parcel.COUNT() > 0 THEN
      -- Percorrer todos os registros retornados nas tabelas de mem�ria
      FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
        
        -- Se ainda possui saldo para pagar
        IF vr_vldsaldo > 0 THEN
          -- Calcula o valor da parcela
          vr_vlpagpar := NVL(vr_tab_pgto_parcel(idx).vlatupar,0) +
                         NVL(vr_tab_pgto_parcel(idx).vlmtapar,0) +
                         NVL(vr_tab_pgto_parcel(idx).vlmrapar,0);
          
          -- SE ESTIVER EXECUTANDO PELA COMPEFORA DEVE CALCULAR O VALOR DO AJUSTE
          IF pr_nmtelant = 'COMPEFORA' THEN 
            -- SE ENCONTRAR O REGISTRO COM OS VALORES DA COMPEFORA
            IF vr_tab_pagto_compe.EXISTS(idx) THEN
              -- A diferenca do campo "vlatrpag" de ontem e de hoje, dever� ser lan�amento como ajuste.
              vr_vlajuste := vr_vlajuste + (NVL(vr_vlpagpar,0) - NVL(vr_tab_pagto_compe(idx).vlpagpar,0));
              
              -- O ajuste deve ser considerado no saldo para pagamentob 
              vr_vldsaldo := vr_vldsaldo + (NVL(vr_vlpagpar,0) - NVL(vr_tab_pagto_compe(idx).vlpagpar,0));
            END IF;  
          END IF; -- COMPEFORA
                    
          -- Se o saldo para pagar � maior que o valor da parcela
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
          -- N�o ir� pagar valor algum da parcela
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
      
      -- O Valor do pagamento dever� considerar tamb�m o valor do ajuste
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
        -- SE O ERRO INDICAR ERRO DE PAGAMENTO DO VALOR M�NIMO, DEVE
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
          
          -- Indica a ocorrencia de critica do valor m�nimo para a rotina chamadora
          pr_idvlrmin := 1;
          
          -- Limpar informa��es de erros
          vr_tab_erro.DELETE();
          pr_cdcritic := NULL;
          pr_dscritic := NULL;
        ELSE
          -- Atribui cr�ticas �s variaveis
          pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          -- Gera exce��o
          RAISE vr_exc_erro;
        END IF;
      ELSE
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao gerar pagamento de parcelas';
        -- Gera exce��o
        RAISE vr_exc_erro;
      END IF;
    END IF;
      
    -- Inicializa o parametro
    pr_vltotpag := 0;
    
    -- Percorrer a tabela de mem�ria de parcelas pagas, somando o total de valores pagos 
    IF vr_tab_pgto_parcel.COUNT() > 0 THEN
      -- Percorrer todos os registros
      FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
        -- Verifica se a parcela foi paga
        IF NVL(vr_tab_pgto_parcel(idx).inpagmto,0) = 1 THEN
          pr_vltotpag := pr_vltotpag + NVL(vr_tab_pgto_parcel(idx).vlpagpar,0);
        END IF;
      END LOOP;
    END IF;
    
    
    -- REALIZAR O LAN�AMENTO DO AJUSTE CALCULADO NA COMPEFORA
    IF nvl(vr_vlajuste, 0) > 0 THEN
      
      -- Buscar o valor de lan�amento dos historicos de ajuste
      OPEN  cr_craplem;
      FETCH cr_craplem INTO vr_vllanlem;
      
      -- Se n�o encontrar registro
      IF cr_craplem%NOTFOUND THEN
        vr_vllanlem := 0;
      END IF;
      
      -- FEchar cursor
      CLOSE cr_craplem;
      
      -- Realiza o ajuste de lan�amento
      vr_vlajuste := vr_vlajuste + NVL(vr_vllanlem,0);
      
      -- Lanca em C/C e atualiza o lote
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                    ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                    ,pr_cdagenci => pr_cdagenci         --> C�digo da ag�ncia
                                    ,pr_cdbccxlt => 100                 --> N�mero do caixa
                                    ,pr_cdoperad => pr_cdoperad         --> C�digo do Operador
                                    ,pr_cdpactra => pr_cdagenci         --> P.A. da transa��o
                                    ,pr_nrdolote => 600032              --> Numero do Lote
                                    ,pr_nrdconta => pr_nrdconta         --> N�mero da conta
                                    ,pr_cdhistor => 2012                --> Codigo historico 2012 - AJUSTE BOLETO
                                    ,pr_vllanmto => vr_vlajuste         --> Valor da parcela emprestimo
                                    ,pr_nrparepr => pr_nrparcel         --> N�mero parcelas empr�stimo
                                    ,pr_nrctremp => pr_nrctremp         --> N�mero do contrato de empr�stimo
                                    ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro);       --> Tabela com poss�ves erros
              
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
     
    END IF; -- FIM nvl(vr_vlajuste, 0) > 0 
     
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EMPRESTIMO_PP;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PP: '||SQLERRM;
      
      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EMPRESTIMO_PP;
      /**************************/
  END pc_pagar_emprestimo_pp;
  
  
  -- Efetuar o calculo do lan�amento a ser creditado na conta corrente
  PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- N�mero da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- C�digo da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE -- Datas da cooperativa
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- N�mero do contrato de empr�stimo 
                                        ,pr_nracordo  IN NUMBER                      -- N�mero do acordo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- C�digo do operador
                                        ,pr_vlparcel  IN NUMBER                      -- Valor pago do boleto do acordo
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_nmtelant  IN VARCHAR2                    -- Nome da tela 
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- C�digo de cr�ticia
                                        ,pr_dscritic OUT VARCHAR2) IS                -- Descri��o da cr�tica
  
    -- Buscar os dados do contrato atrelado ao acordo e que ser� pago
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
        FROM crapepr  epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr   cr_crapepr%ROWTYPE;
    
    -- VARI�VEIS
    vr_vlpagmto     NUMBER := pr_vlparcel;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    
    -- EXCEPTIONS
    vr_exp_erro     EXCEPTION;
    
  BEGIN  
    
    -- Buscar dados do contrato 
    OPEN  cr_crapepr;
    FETCH cr_crapepr INTO rw_crapepr;
    
    -- Se o contrato n�o for encontrado
    IF cr_crapepr%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_crapepr;
      
      -- Deve retornar erro de execu��o
      pr_cdcritic := 0;
      pr_dscritic := 'Contrato '||TRIM(GENE0002.fn_mask_contrato(pr_nrctremp))||
                     ' do acordo n�o foi encontrado para a conta '||
                     TRIM(GENE0002.fn_mask_conta(pr_nrdconta))||'.';
      RAISE vr_exp_erro;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_crapepr;
        
    -- Verificar se o contrato j� est� LIQUIDADO   OU
    -- Se o contrato de PREJUIZO j� foi TOTALMENTE PAGO
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

        -- Pagar empr�stimo TR
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
        
        -- Pagar empr�stimo PP
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
      -- Deve retornar erro de execu��o
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retornar total pago como zero
      pr_vltotpag := 0;
      -- Deve retornar erro de execu��o
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_EMPRESTIMO: '||SQLERRM;
  END pc_pagar_contrato_emprestimo;
  
  
  -- Realizar o pagamentos do acordo
  PROCEDURE pc_pagar_contrato_acordo(pr_nracordo  IN tbrecup_acordo.nracordo%TYPE          -- N�mero do acordo
                                    ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                    ,pr_vlparcel  IN NUMBER                                -- Valor do boleto pago
                                    ,pr_cdoperad  IN VARCHAR2                              -- C�digo do operador
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
              , cyb.vlsdeved DESC  -- 3. Caso haja empate, ent�o, considerar primeiro o contrato com maior saldo devedor
              , cyb.nrctremp ASC;  -- 4. Caso os saldos devedores tamb�m sejam iguais, considerar o contrato de menor n�mero
    
    -- REGISTROS
    vr_tab_saldos     EXTR0001.typ_tab_saldos;
    
    -- VARI�VEIS
    vr_vlsddisp       NUMBER;
    vr_vltotpag       NUMBER;
    vr_idxsaldo       NUMBER;
    vr_des_erro       VARCHAR2(1000);
    vr_tab_erro       GENE0001.typ_tab_erro;
    vr_vlparcel       NUMBER := pr_vlparcel; -- ir� trabalhar com a vari�vel, n�o com o parametro
    vr_cdcritic       NUMBER;
    vr_dscritic       VARCHAR2(1000);
    vr_fldespes       BOOLEAN; -- Indica que deve lan�ar o valor como despesa
    vr_flbloque       BOOLEAN; -- Indica que deve lan�ar a sobra como valor bloqueado
    vr_flagerro       BOOLEAN; -- Indica que o processamento de pagamento de acordo apresentou cr�tica
    vr_idvlrmin       NUMBER := 0; -- Indica que houve critica do valor minimo
    
    -- EXCEPTIONS
    vr_exc_erro       EXCEPTION;
    
  BEGIN      
    
    -- Buscar os dados do acordo
    OPEN  cr_acordo;
    FETCH cr_acordo INTO rw_acordo;
    
    -- Se o acordo n�o for encontrado
    IF cr_acordo%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_acordo;  
    
      pr_dscritic := 'Acordo n�mero '||pr_nracordo||' n�o foi encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_acordo;
      
    -- Buscar o CRAPDAT da cooperativa
    OPEN  BTCH0001.cr_crapdat(rw_acordo.cdcooper); 
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
        
    -- Se n�o encontrar registro na CRAPDAT
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
    
    -- Se n�o encontrar registro na CRAPASS
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
      pr_dscritic := 'N�o foi retornado saldo dia da conta.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se o acordo disp�e de saldo bloqueado
    IF NVL(rw_acordo.vlbloqueado,0) > 0 THEN
      
      -- Valor do boleto ser� o valor pago do boleto + saldo bloqueado do acordo
      vr_vlparcel := nvl(vr_vlparcel,0) + rw_acordo.vlbloqueado;
      
      -- Gera o lan�amento na conta para descontar o saldo bloqueado
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper                  --> Cooperativa conectada
                                    ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt --> Movimento atual
                                    ,pr_cdagenci => rw_crapass.cdagenci          --> C�digo da ag�ncia
                                    ,pr_cdbccxlt => 100                          --> N�mero do caixa
                                    ,pr_cdoperad => pr_cdoperad                  --> C�digo do Operador
                                    ,pr_cdpactra => rw_crapass.cdagenci          --> P.A. da transa��o
                                    ,pr_nrdolote => 650001                       --> Numero do Lote
                                    ,pr_nrdconta => rw_acordo.nrdconta           --> N�mero da conta
                                    ,pr_cdhistor => 2194                         --> Codigo historico 2194 - CR.DESB.ACORD
                                    ,pr_vllanmto => rw_acordo.vlbloqueado        --> Valor da parcela emprestimo
                                    ,pr_nrparepr => pr_nrparcel                  --> N�mero parcelas empr�stimo
                                    ,pr_nrctremp => 0                            --> N�mero do contrato de empr�stimo
                                    ,pr_des_reto => vr_des_erro                  --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro);                --> Tabela com poss�ves erros
    
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
        -- Alterar a situa��o do acordo para cancelado
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
      O sistema Ayllos dever� cadastrar o(s) contrato(s) do acordo como CIN quando identificar o pagamento da 
      entrada ou primeira parcela (do acordo). Caso o contrato j� esteja marcado como CIN, o sistema dever� 
      sobrescrever a marca��o.
    ----------------------------------------------------------------------------------------------------------*/
    -- Se for o pagamentos da primeira parcela
    IF pr_nrparcel = 0 THEN
      -- Percorre todos os contratos do acordo 
      FOR rw_acordo_contrato IN cr_acordo_contrato LOOP
        BEGIN
          UPDATE crapcyc 
             SET flgehvip = 1
               , cdmotcin = 1
               , dtaltera = BTCH0001.rw_crapdat.dtmvtolt
           WHERE cdcooper = rw_acordo_contrato.cdcooper
             AND cdorigem = rw_acordo_contrato.cdorigem
             AND nrdconta = rw_acordo_contrato.nrdconta
             AND nrctremp = rw_acordo_contrato.nrctremp;
             
          -- Se n�o encontrou registro para alterar
          IF SQL%ROWCOUNT = 0 THEN
            -- Dever� realizar a inclus�o do registro
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
                               ,rw_acordo_contrato.cdorigem  -- cdorigem
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
              
            -- Em caso de erro ser� gerado o log e prosseguir� ao pr�ximo pagamento
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper
                            ,pr_nrdconta => rw_acordo_contrato.nrdconta
                            ,pr_nracordo => pr_nracordo
                            ,pr_nrctremp => rw_acordo_contrato.nrctremp
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsmodule => 'ATUALIZACAO_CIN');
        END;
      END LOOP;
    END IF;  
    
    -- Inicializa os flags, indicando que n�o h� erros de processamento
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
        
          -- Indicar que houve cr�tica ao processar o pagamento de estouro de conta
          vr_flagerro := TRUE;
          
          -- Em caso de erro ser� gerado o log e prosseguir� ao pr�ximo pagamento
          pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper
                          ,pr_nrdconta => rw_acordo_contrato.nrdconta
                          ,pr_nracordo => pr_nracordo
                          ,pr_nrctremp => rw_acordo_contrato.nrctremp
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
          
          -- Voltar ao Loop para processar o pr�ximo pagamento
          CONTINUE;
          
        END IF;                     
        
        -- Diminuir o valor pago do boleto com o lan�amento efetuado na conta corrente
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
           
          -- Indicar que houve erro ao processar pagamento de empr�stimo
          vr_flagerro := TRUE;
        
          -- Em caso de erro ser� gerado o log e prosseguir� ao pr�ximo pagamento
          pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper
                          ,pr_nrdconta => rw_acordo_contrato.nrdconta
                          ,pr_nracordo => pr_nracordo
                          ,pr_nrctremp => rw_acordo_contrato.nrctremp
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsmodule => 'PAGAR_CONTRATO_EMPRESTIMO');
          
          -- Voltar ao Loop para processar o pr�ximo pagamento
          CONTINUE;
        END IF;   
        
        -- Se houver ocorrencia de critica de valor m�nimo
        IF NVL(vr_idvlrmin,0) = 1 THEN
          -- Indicar que houve critica ao processar pagamento de empr�stimo
          vr_flagerro := TRUE;
        END IF;
        
        -- Diminuir o valor pago do boleto com o lan�amento efetuado na conta corrente
        vr_vlparcel := vr_vlparcel - NVL(vr_vltotpag,0);
        -----------------------------------------------------------------------------------------------
        
        -- Somar o valor pago ao montante total de pagamentos
        pr_vltotpag := NVL(pr_vltotpag,0) + NVL(vr_vltotpag,0);
        -----------------------------------------------------------------------------------------------
      END IF;
        
      -- Deve sair do loop quando n�o houver mais saldo disponivel para pagamentos --
      EXIT WHEN vr_vlparcel <= 0;
      -------------------------------------------------------------------------------
      
    END LOOP;  -- cr_acordo_contrato
    
    -- Se sobrou valor de pagamento - Deve verificar se deve lan�ar como despesa ou como valor bloqueado
    IF vr_vlparcel > 0 THEN
    
      -- Se o acordo possui apenas estouro de conta
      IF rw_acordo.qtestour > 0 AND rw_acordo.qtempres = 0 THEN
        -- N�o deve lan�ar despesa, nem saldo bloqueado, pois o valor j� est� creditado na conta
        vr_flbloque := FALSE;
        vr_fldespes := FALSE;
      ELSE
        -- Verificar se houve erro no processamento do estouro de conta e/ou empr�stimo
        IF vr_flagerro THEN
          -- Caracteriza como saldo bloqueado, pois algum valor n�o pode ser debitado
          vr_flbloque := TRUE;
          vr_fldespes := FALSE;
        ELSE
          -- Caracteriza como despesa, pois todos os valores foram debitados, mas houve sobra
          vr_flbloque := FALSE;
          vr_fldespes := TRUE;
        END IF;
        
      END IF;
      
      -- Se for para lan�ar a sobra como SALDO BLOQUEADO
      IF vr_flbloque THEN
        -- Realiza o lan�amento do saldo bloqueado na conta corrente do cooperado
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper           --> Cooperativa conectada
                                      ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => rw_crapass.cdagenci          --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 100                          --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad                  --> C�digo do Operador
                                      ,pr_cdpactra => rw_crapass.cdagenci          --> P.A. da transa��o
                                      ,pr_nrdolote => 650001                       --> Numero do Lote
                                      ,pr_nrdconta => rw_acordo.nrdconta           --> N�mero da conta
                                      ,pr_cdhistor => 2193                         --> Codigo historico 2193 - DEBITO BLOQUEIO ACORDOS
                                      ,pr_vllanmto => vr_vlparcel                  --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel                  --> N�mero parcelas empr�stimo
                                      ,pr_nrctremp => 0                            --> N�mero do contrato de empr�stimo
                                      ,pr_des_reto => vr_des_erro                  --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);                --> Tabela com poss�ves erros
        
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
      
        -- Alterar o valor bloqueado no acordo, com o valor lan�ado
        BEGIN
          -- Alterar a situa��o do acordo para cancelado
          UPDATE tbrecup_acordo 
             SET vlbloqueado = NVL(vlbloqueado,0) + NVL(vr_vlparcel,0)
           WHERE nracordo = pr_nracordo;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar acordo: '||SQLERRM;
            RAISE vr_exc_erro;   
        END;
        
        -- Adicionar o valor lan�ado no bloqueado ao total pago... pois o devido destino ao valor j� foi dado
        pr_vltotpag := NVL(pr_vltotpag,0) + NVL(vr_vlparcel,0);
      END IF; -- FIM vr_flbloque
              
      -- Se for para lan�ar a sobra como DESPESA
      IF vr_fldespes THEN
        -- Criar o lan�amento de despesa em conta corrente
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper           --> Cooperativa conectada
                                      ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => rw_crapass.cdagenci          --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 100                          --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad                  --> C�digo do Operador
                                      ,pr_cdpactra => rw_crapass.cdagenci          --> P.A. da transa��o
                                      ,pr_nrdolote => 650001                       --> Numero do Lote
                                      ,pr_nrdconta => rw_acordo.nrdconta           --> N�mero da conta
                                      ,pr_cdhistor => 2182                         --> Codigo historico 2182 - PAGAMENTO DAS DESPESAS ACORDO
                                      ,pr_vllanmto => vr_vlparcel                  --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparcel                  --> N�mero parcelas empr�stimo
                                      ,pr_nrctremp => 0                            --> N�mero do contrato de empr�stimo
                                      ,pr_des_reto => vr_des_erro     --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);   --> Tabela com poss�ves erros
        
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
        
        -- Adicionar o valor lan�ado no como despesa ao total pago... pois o devido destino ao valor j� foi dado
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
   
END RECP0001;
/
