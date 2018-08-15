CREATE OR REPLACE PACKAGE CECRED.EMPR9999 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR9999
  --  Sistema  : Rotinas focando nas funcionalidades genericas
  --  Sigla    : EMPR
  --  Autor    : Pedro Cruz (GFT)
  --  Data     : Julho/2018.                   Ultima atualizacao: 26/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas gen�ricas dos sistemas Oracle
  --
  -- Altera��o : 19/07/2018 - Implementa��o da rotina pc_retorna_inss_consignavel (Robson/GFT)
  --
  --             20/07/2018 - Implementa��o da rotina pc_retorna_desc_inss (Robson/GFT)
  --
  --             24/07/2018 - altera��o da indenta��o da rotina pc_busca_numero_contrato (Robson/GFT)
  --
  --             24/07/2018 - altera��o do fechamento do cursor da rotina pc_retorna_inss_consignavel (Robson/GFT)
  --
  --             25/07/2018 - Revis�o do separador do campo pr_dsctrliq de ";" para "," pa pc_proc_qualif_operacao (Andrew Albuquerque - GFT)
  --
  --             26/07/2018 Revis�o das regras de qualifica��o (Andrew Albuquerque - GFT)
  --
  --             31/07/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                        - pc_pagar_emprestimo_prejuizo;
  --                        - pc_pagar_emprestimo_tr;
  --                        - pc_pagar_emprestimo_folha;
  --                        - pc_pagar_emprestimo_pp;
  -- 
  --             15/08/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                        - pc_pagar_emprestimo_pos
  
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_busca_numero_contrato(pr_cdcooper     IN tbepr_consignado_contrato.cdcooper%TYPE        --> Codigo da cooperativa
                                    ,pr_nrdconta     IN tbepr_consignado_contrato.nrdconta%TYPE        --> Conta do Associado
                                    ,pr_nrctremp     IN tbepr_consignado_contrato.nrctremp%TYPE Default 0 --> N�mero do Contrato
                                    ----------------- > OUT < ----------------------
                                    ,pr_existenr     OUT INTEGER                                     --> 1 (Verdadeiro) 0 (Falso) para se existe contrato/ proposta
                                    ,pr_cdcritic     OUT INTEGER                                       --> C�digo da cr�tica
                                    ,pr_dscritic     OUT VARCHAR2                                      --> Descri��o da cr�tica
                                    );

  -- Trazer a qualificao da operacao Na altera�ao e inclusao de proposta. (migra��o progress: b1wgen0002.p/proc_qualif_operacao)
  PROCEDURE pc_proc_qualif_operacao( pr_cdcooper IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapepr.cdagenci%TYPE --> C�digo da ag�ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                    ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Codigo do operador
                                    ,pr_nmdatela IN craplgm.nmdatela%TYPE -->
                                    ,pr_idorigem IN NUMBER
                                    ,pr_nrdconta IN crapepr.nrdconta%TYPE
                                    ,pr_dsctrliq IN VARCHAR2
                                    ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE
                                    ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE
                  -------------------------------- OUT ---------------------------
                                    ,pr_idquapro OUT INTEGER
                                    ,pr_dsquapro OUT VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER            --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2               --> Descricao da critica
                                   );
  PROCEDURE pc_retorna_inss_consignavel( pr_cdcooper IN crapepr.cdcooper%TYPE  --> Cooperativa conectada
                                        ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Conta do Associado
                                        -------------------------------- OUT ---------------------------
                                        ,pr_inconsignavel OUT tbgen_tipo_beneficio_inss.inconsignavel%TYPE
                                        ,pr_cdcritic      OUT INTEGER              --> Codigo da critica
                                        ,pr_dscritic      OUT VARCHAR2             --> Descricao da critica
                                        );

 PROCEDURE pc_retorna_desc_inss( pr_cdbeninss  IN tbgen_tipo_beneficio_inss.cdbeninss%TYPE --> Cooperativa conectada
                               -------------------------------- OUT ---------------------------
                                ,pr_dsbeninss OUT tbgen_tipo_beneficio_inss.dsbeninss%TYPE
                                ,pr_cdcritic  OUT INTEGER   --> Codigo da critica
                                ,pr_dscritic  OUT VARCHAR2  --> Descricao da critica
                               );

-- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
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
  

  -- Realizar o calculo e pagamento de preju�zo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
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
                                        ,pr_vliofcpl  IN crapepr.vliofcpl%TYPE        -- Valor do IOF complementar
                                        ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                        ,pr_dscritic OUT VARCHAR2);                   -- Descri��o da cr�tica

  -- Realizar o calculo e pagamento de folha de pagamento
  PROCEDURE pc_pagar_emprestimo_folha(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                     ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
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


  -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                      ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                      ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
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
                                      ,pr_dscritic OUT VARCHAR2);                 -- Descri��o da cr�tica



   PROCEDURE pc_pagar_emprestimo_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                    ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
                                    ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE
                                    ,pr_vlemprst  IN crapepr.vlemprst%TYPE    
                                    ,pr_txmensal  IN crapepr.txmensal%TYPE 
                                    ,pr_dtprivencto IN crawepr.dtdpagto%TYPE
                                    ,pr_vlsprojt    IN crapepr.vlsprojt%TYPE
                                    ,pr_qttolar    IN crapepr.qttolatr%TYPE
                                    ,pr_nrparcel    IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                    ,pr_vlsdeved    IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                    ,pr_vlsdevat    IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                    ,pr_idorigem    IN NUMBER                       -- Indicador da origem
                                    ,pr_nmtelant    IN VARCHAR2                     -- Nome da tela
                                    ,pr_cdoperad    IN VARCHAR2                     -- C�digo do operador
                                    ,pr_idvlrmin OUT NUMBER                       -- Indica que houve critica do valor minimo
                                    ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                    ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                    ,pr_dscritic OUT VARCHAR2);                   -- Descri��o da cr�tica
                                      

END EMPR9999;
/
create or replace package body cecred.EMPR9999 as

---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR9999
  --  Sistema  : Rotinas focando nas funcionalidades genericas
  --  Sigla    : EMPR
  --  Autor    : Pedro Cruz (GFT)
  --  Data     : Julho/2018.                   Ultima atualizacao: 26/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas gen�ricas dos sistemas Oracle
  --
  -- Altera��o : 19/07/2018 - Implementa��o da rotina pc_retorna_inss_consignavel (Robson/GFT)
  --
  --             20/07/2018 - Implementa��o da rotina pc_retorna_desc_inss (Robson/GFT)
  --
  --             25/07/2018 - Revis�o do separador do campo pr_dsctrliq de ";" para "," pa pc_proc_qualif_operacao (Andrew Albuquerque - GFT)
  --
  --             26/07/2018 Revis�o das regras de qualifica��o (Andrew Albuquerque - GFT)
  -- 
   --             31/07/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                        - pc_pagar_emprestimo_prejuizo;
  --                        - pc_pagar_emprestimo_tr;
  --                        - pc_pagar_emprestimo_folha;
  --                        - pc_pagar_emprestimo_pp;
  --
  --             15/08/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                         - pc_pagar_emprestimo_pos

  ---------------------------------------------------------------------------------------------------------------
  /* Tratamento de erro */
  vr_exc_erro EXCEPTION;

  /* Descri��o e c�digo da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  
   -- Constante com o nome do programa
  vr_cdprogra     CONSTANT VARCHAR2(8) := 'RECP0001';
  vr_dsarqlog     CONSTANT VARCHAR2(10):= 'acordo.log';


  PROCEDURE pc_busca_numero_contrato(pr_cdcooper     IN tbepr_consignado_contrato.cdcooper%TYPE        --> Codigo da cooperativa
                                    ,pr_nrdconta     IN tbepr_consignado_contrato.nrdconta%TYPE        --> Conta do Associado
                                    ,pr_nrctremp     IN tbepr_consignado_contrato.nrctremp%TYPE Default 0 --> N�mero do Contrato
                                    ----------------- > OUT < ----------------------
                                    ,pr_existenr     OUT INTEGER                                     --> 1 (Verdadeiro) 0 (Falso) para se existe contrato/ proposta
                                    ,pr_cdcritic     OUT INTEGER                                       --> C�digo da cr�tica
                                    ,pr_dscritic     OUT VARCHAR2                                      --> Descri��o da cr�tica
                                    ) IS
    /*.............................................................................
         programa: pc_busca_numero_contrato
         sistema :
         sigla   : cred
         autor   : Pedro Cruz (GFT)
         data    : Junho/2018                         ultima atualizacao:

         dados referentes ao programa:

         frequencia: sempre que for chamado.
         objetivo  : procedure para buscar se j� existe o n�mero de contrato/ proposta na base de dados

         alteracoes:
    ............................................................................. */
       --Cursor utilizado para verificar se existe Contrato ATIVO com o N�mero de contrato Recebido (CRAPEPR) nessa cooperativa + Conta;
   CURSOR cr_contratoativo(pr_cdcooper IN CRAPEPR.cdcooper%TYPE,
                           pr_nrdconta IN CRAPEPR.nrdconta%TYPE,
                           pr_nrctremp IN CRAPEPR.nrctremp%TYPE) IS
   SELECT nrdconta
         ,cdcooper
         ,nrctremp
   FROM CRAPEPR
   WHERE cdcooper = pr_cdcooper
   AND nrdconta   = pr_nrdconta
   AND nrctremp   = pr_nrctremp
   UNION
   SELECT nrdconta
         ,cdcooper
         ,nrctremp
   FROM TBEPR_CONSIGNADO_CONTRATO C
   WHERE cdcooper = pr_cdcooper
   AND nrdconta   = pr_nrdconta
   AND nrctremp   = pr_nrctremp
   UNION
   SELECT nrdconta
         ,cdcooper
         ,nrctremp
   FROM CRAWEPR
   WHERE cdcooper = pr_cdcooper
   AND nrdconta   = pr_nrdconta
   AND nrctremp   = pr_nrctremp
   UNION
   SELECT nrdconta
         ,cdcooper
         ,nrcontra
          nrctremp
   FROM CRAPMCR
   WHERE cdcooper = pr_cdcooper
   AND nrdconta   = pr_nrdconta
   AND nrcontra   = pr_nrctremp;

   rw_contratoativo cr_contratoativo%ROWTYPE;

  BEGIN
    vr_cdcritic := null;
    vr_dscritic := '';

    OPEN cr_contratoativo(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp);
    FETCH cr_contratoativo INTO rw_contratoativo;

    --Se Existir Proposta e/ou Contrato, deve retornar 1 = N�mero de Contrato Existe e n�o pode Ser Usado.
    --Com isso ser� enviado e a FIS ir� cancelar essa solicita��o e gerar uma nova com outro n�mero
    IF cr_contratoativo%NOTFOUND THEN
      pr_existenr := 0;
    ELSE
      pr_existenr := 1;
    END IF;

    CLOSE cr_contratoativo;

  EXCEPTION
  WHEN OTHERS THEN
    /* quando nao possuir uma cr�tica predefina para um codigo de retorno, estabelece um texto gen�rico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'falha ao buscar se numero do contrato/ proposta existe: ' || sqlerrm;
    /*  fecha a procedure */
  END pc_busca_numero_contrato;

  -- Trazer a qualificao da operacao Na altera�ao e inclusao de proposta. (migra��o progress: b1wgen0002.p/proc_qualif_operacao)
  PROCEDURE pc_proc_qualif_operacao( pr_cdcooper IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapepr.cdagenci%TYPE --> C�digo da ag�ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                    ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Codigo do operador
                                    ,pr_nmdatela IN craplgm.nmdatela%TYPE -->
                                    ,pr_idorigem IN NUMBER
                                    ,pr_nrdconta IN crapepr.nrdconta%TYPE
                                    ,pr_dsctrliq IN VARCHAR2
                                    ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE
                                    ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE
                  -------------------------------- OUT ---------------------------
                                    ,pr_idquapro OUT INTEGER
                                    ,pr_dsquapro OUT VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER            --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2               --> Descricao da critica
                                   ) IS
  /*.............................................................................
       programa:  pc_proc_qualif_operacao
       sistema :
       sigla   : cred
       autor   : Andrew Albuquerque (GFT)
       data    : 14/06/2018                         ultima atualizacao: 10/07/2018

       dados referentes ao programa:

       frequencia: sempre que for chamado.
       objetivo  : Trazer a qualificacao da operacao na inclusao e alteracao da proposta.
                   Migracao Progress->Oracle da b1wgen0002.p/proc_qualif_operacao

       alteracoes:
  --               10/07/2018 Revis�o da proc_qualif_operacao x vers�o de PROD da b1wgen0002.p, onde foram alteradas
                              as regras de qualifica��o (Andrew Albuquerque - GFT)
  --
  --               25/07/2018 Revis�o do separador do campo pr_dsctrliq de ";" para "," (Andrew Albuquerque - GFT)
  --
  --               26/07/2018 Revis�o das regras de qualifica��o (Andrew Albuquerque - GFT)
  ............................................................................. */

  --CURSORES
  CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                    ,pr_nrdconta IN crapepr.nrdconta%TYPE
                    ,pr_nrctremp IN crapepr.nrctremp%TYPE
                    ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
    WITH t_risco as
         (SELECT crapris.qtdiaatr
                ,crapris.cdcooper
                ,crapris.nrdconta
                ,crapris.nrctremp
                ,crapris.dtrefere
            FROM crapris
           WHERE crapris.cdcooper = pr_cdcooper
             AND crapris.dtrefere = pr_dtrefere
             AND crapris.inddocto = 1
             AND crapris.nrdconta = pr_nrdconta
             AND crapris.nrctremp = pr_nrctremp
             AND crapris.cdorigem = 3)
    SELECT r.dtrefere
          ,r.qtdiaatr
          ,e.idquaprc
         FROM t_risco r
         RIGHT JOIN crapepr e
        ON r.cdcooper = e.cdcooper
       AND r.nrdconta = e.nrdconta
       AND r.nrctremp = e.nrctremp
     WHERE e.inliquid = 0
       AND e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp
           ;
  rw_crapepr cr_crapepr%ROWTYPE;

  CURSOR cr_crapris (pr_cdcooper IN crapris.cdcooper%TYPE
                    ,pr_nrdconta IN crapris.nrdconta%TYPE
                    ,pr_dtrefere IN crapris.dtrefere%TYPE
                    ,pr_nrctremp IN crapris.nrctremp%TYPE) IS
    SELECT ris.nrctremp
          ,ris.nrdconta
          ,ris.cdcooper
          ,ris.dtrefere
          ,ris.cdmodali
          ,ris.inddocto
          ,ris.cdorigem
          ,ris.qtdiaatr
          ,DECODE(ris.nrctremp,ris.nrdconta,1,0) AS indestouroconta
      FROM crapris ris
     WHERE ris.cdcooper = pr_cdcooper
       AND ris.nrdconta = pr_nrdconta
       AND ris.dtrefere = pr_dtrefere
       AND ris.inddocto = 1
       AND ris.cdorigem = 1
       AND ris.cdmodali in (101,201)
       AND ris.nrctremp = pr_nrctremp;
  rw_crapris cr_crapris%ROWTYPE;

  CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE
                    ,pr_nrdconta craplim.nrdconta%TYPE
                    ,pr_nrctrlim craplim.nrctrlim%TYPE) IS
    SELECT 1
      FROM craplim
     WHERE craplim.cdcooper = pr_cdcooper
       AND craplim.nrdconta = pr_nrdconta
       AND craplim.nrctrlim = pr_nrctrlim
       AND craplim.tpctrlim = 1
       AND craplim.insitlim = 2;
  rw_craplim cr_craplim%ROWTYPE;

  /* descri�ao e c�digo da critica */
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(4000);

  -- variaveis para montar os contratos � partir da dsctrliq
  vr_split gene0002.typ_split;
  vr_indice_epr varchar2(200);

  -- Variaveis Auxiliares do Processo
  vr_emp_a_liq crapepr.nrctremp%TYPE;
  vr_qtdias_atraso INTEGER := 0;
  vr_auxdias_atraso INTEGER := 0;

  -- Monta o registro de data
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_dtmvtoan crapdat.dtmvtoan%TYPE;

  TYPE typ_vet_liquida IS TABLE OF NUMBER
       INDEX BY PLS_INTEGER;
  vr_vet_liquida typ_vet_liquida;

  BEGIN
    /* descri�ao e c�digo da critica */
    vr_cdcritic := null;
    vr_dscritic := '';

    -- Busca a data corrente para a cooperativa.
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    /* Se Mes do Dia diferente do Mes do dia de ontem,
       assume dada do ultimo dia do mes anterior */
    IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtoan, 'MM')THEN
      vr_dtmvtoan := rw_crapdat.dtultdma;
    ELSE
      vr_dtmvtoan := rw_crapdat.dtmvtoan;
    END IF;

    vr_vet_liquida.delete;
    -- obtem os contratos com base no pr_dsctrliq
    IF trim(pr_dsctrliq) IS NOT NULL THEN
      vr_split := gene0002.fn_quebra_string(pr_string => pr_dsctrliq
                                           ,pr_delimit => ',');
      --> Carregar temptable como os numeros de contrato
      IF vr_split.count > 0 THEN
        FOR i IN vr_split.first..vr_split.last LOOP
          vr_vet_liquida(vr_split(i)) := vr_split(i);
        END LOOP;
      END IF;
    END IF;

    --> para cada contrato na lista recebida.
    vr_indice_epr := vr_vet_liquida.first;
    WHILE vr_indice_epr IS NOT NULL LOOP
      vr_emp_a_liq := vr_vet_liquida(vr_indice_epr);

      vr_auxdias_atraso := 0;

      -- Buscar os registros de Risco
      OPEN cr_crapris(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtrefere => vr_dtmvtoan
                     ,pr_nrctremp => vr_emp_a_liq);
      FETCH cr_crapris INTO rw_crapris;
      IF cr_crapris%FOUND THEN
        CLOSE cr_crapris;
        -- Se For um Estouro de Limite de Conta, � o n�mero da conta que vir� no vetor,
        -- e � ele que est� gravado no campo nrctremp da tabela de risco.
        -- ADP
        IF (rw_crapris.inddocto = 1 AND
            rw_crapris.cdorigem = 1 AND
            rw_crapris.cdmodali = 101 AND
            rw_crapris.indestouroconta = 1) THEN
          vr_qtdias_atraso := rw_crapris.qtdiaatr;
        -- LIMITE OU LIMITE/ADP
        ELSE
          OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrlim => vr_emp_a_liq);
          IF cr_craplim%FOUND THEN
            CLOSE cr_craplim;
            -- SE LIMITE ou LIMITE/ADP
            IF (rw_crapris.inddocto = 1 AND
                rw_crapris.cdorigem = 1 AND
                rw_crapris.cdmodali = 201 AND
                rw_crapris.indestouroconta = 0) OR
               (rw_crapris.inddocto = 1 AND
                rw_crapris.cdorigem = 1 AND
                rw_crapris.cdmodali = 101 AND
                rw_crapris.indestouroconta = 0) THEN
              vr_qtdias_atraso := rw_crapris.qtdiaatr;
            END IF;
          END IF;
          CLOSE cr_craplim;
        END IF;
      END IF;
      CLOSE cr_crapris;

      -- Verificando para Empr�stimos
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => vr_emp_a_liq
                     ,pr_dtrefere => vr_dtmvtoan);
      FETCH cr_crapepr INTO rw_crapepr;

      IF cr_crapepr%FOUND and rw_crapepr.qtdiaatr IS NOT NULL  THEN
        vr_qtdias_atraso := rw_crapepr.qtdiaatr;
      END IF;
      CLOSE cr_crapepr;

      /* Se contrato a liquidar j� � um refinanciamento, for�a
       qualifica�ao m�nima como "Renegocia�ao" Reginaldo (AMcom) - Mar/2018 */
      IF rw_crapepr.idquaprc > 1 THEN
        vr_qtdias_atraso := GREATEST(vr_qtdias_atraso, 5);
      END IF;

      vr_indice_epr := vr_vet_liquida.next(vr_indice_epr);
    END LOOP;

    IF vr_auxdias_atraso < vr_qtdias_atraso THEN
      vr_auxdias_atraso := vr_qtdias_atraso;
    END IF;

    -- De 0 a 4 dias de atraso - Renova�ao de Cr�dito
    IF vr_auxdias_atraso < 5 THEN
      pr_idquapro := 2;
      pr_dsquapro := 'Renovacao de credito';
    -- De 5 a 60 dias de atraso - Renegocia�ao de Cr�dito
    ELSIF vr_auxdias_atraso > 4 and vr_auxdias_atraso < 61 THEN
      pr_idquapro := 3;
      pr_dsquapro := 'Renegociacao de credito';
    -- Igual ou acima de 61 dias - Composi�ao de d�vida
    ELSIF  vr_auxdias_atraso >= 61 THEN
      pr_idquapro := 4;
      pr_dsquapro := 'Composicao da divida';
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
    /* busca valores de critica predefinidos */
    IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      /* busca a descri�ao da cr�tica baseado no c�digo */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma cr�tica predefina para um codigo de retorno, estabele um texto gen�rico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'erro geral na rotina pc_proc_qualif_operacao: ' || sqlerrm;
    /*  fecha a procedure */
  END pc_proc_qualif_operacao;

  PROCEDURE pc_retorna_inss_consignavel( pr_cdcooper  IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_nrdconta  IN crapepr.nrdconta%TYPE
                                          -------------------------------- OUT ---------------------------
                                         ,pr_inconsignavel OUT tbgen_tipo_beneficio_inss.inconsignavel%TYPE
                                         ,pr_cdcritic      OUT INTEGER            --> Codigo da critica
                                         ,pr_dscritic      OUT VARCHAR2           --> Descricao da critica
                                        ) IS
  /*.............................................................................
       programa:  pc_retorna_inss_consignavel
       sistema :
       sigla   : cred
       autor   : Robson Nunes (GFT)
       data    : 19/06/2018                         ultima atualizacao: 19/07/2018

       dados referentes ao programa:

       frequencia: sempre que for chamado.
       objetivo  : retornar se o beneficio pertence a INSS

       alteracoes:
  --
  ............................................................................. */

  --CURSORES
    CURSOR  cr_retorna_inss_consig(pr_cdcooper IN crapepr.cdcooper%TYPE
                                  ,pr_nrdconta  IN crapepr.nrdconta%TYPE) is
     SELECT crapttl.cdcooper
            ,crapttl.nrdconta
            ,cbi.nrespeci
            ,cbi.nrbenefi
            ,ins.dsbeninss
            ,ins.inconsignavel
      FROM crapttl
           INNER JOIN CRAPASS S
            ON s.cdcooper = crapttl.cdcooper
         AND s.nrdconta = crapttl.nrdconta
           INNER JOIN crapemp emp
            ON emp.cdcooper = crapttl.cdcooper
         AND emp.cdempres = crapttl.cdempres
           INNER JOIN crapcbi cbi
             ON cbi.cdcooper = crapttl.cdcooper
         AND cbi.nrdconta = crapttl.nrdconta
            INNER JOIN tbgen_tipo_beneficio_inss ins
             ON cbi.nrespeci = ins.cdbeninss
          WHERE emp.tpmodcon = 3 -- FIXO
             AND crapttl.cdcooper = pr_cdcooper
             AND crapttl.nrdconta = pr_nrdconta
             AND crapttl.idseqttl = 1 -- 1 TITULAR DA CONTA.
             ORDER BY crapttl.idseqttl; -- empresa 81

         rw_retorna_inss_consig cr_retorna_inss_consig%ROWTYPE;
   BEGIN

    OPEN cr_retorna_inss_consig(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                );

     FETCH cr_retorna_inss_consig INTO rw_retorna_inss_consig;

   IF cr_retorna_inss_consig%NOTFOUND THEN
      vr_cdcritic:='';
      vr_dscritic:='Informa��o de INSS Consign�vel n�o encontrada.';
      raise vr_exc_erro;
      CLOSE cr_retorna_inss_consig;
   ELSE
    CLOSE cr_retorna_inss_consig;
     pr_inconsignavel := rw_retorna_inss_consig.inconsignavel;
   END IF;

   EXCEPTION
    WHEN vr_exc_erro THEN
    /* busca valores de critica predefinidos */
    IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      /* busca a descri�ao da cr�tica baseado no c�digo */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma cr�tica predefina para um codigo de retorno, estabele um texto gen�rico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'erro geral na rotina pc_retorna_inss_consignavel: ' || sqlerrm;

    /*  fecha a procedure */
   END pc_retorna_inss_consignavel;

  PROCEDURE pc_retorna_desc_inss ( pr_cdbeninss  IN tbgen_tipo_beneficio_inss.cdbeninss%TYPE --> Codigo beneficio inss
                                  -------------------------------- OUT ---------------------------
                                  ,pr_dsbeninss OUT tbgen_tipo_beneficio_inss.dsbeninss%TYPE --> Descri��o beneficio inss
                                  ,pr_cdcritic  OUT INTEGER            --> Codigo da critica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descricao da critica
                                 ) IS
     /*.............................................................................
         programa:  pc_retorna_desc_inss
         sistema :
         sigla   : cred
         autor   : Robson Nunes (GFT)
         data    : 20/06/2018                         ultima atualizacao: 20/07/2018

         dados referentes ao programa: retorna a descri��o do beneficio inss

         frequencia: sempre que for chamado.
         objetivo  :

         alteracoes:
    --
    ............................................................................. */

    CURSOR  cr_retorna_desc_benef_inss( pr_cdbeninss  IN tbgen_tipo_beneficio_inss.cdbeninss%TYPE) IS
    SELECT ins.dsbeninss
      FROM tbgen_tipo_beneficio_inss ins
     WHERE ins.cdbeninss = pr_cdbeninss;

     rw_retorna_desc_benef_inss cr_retorna_desc_benef_inss%ROWTYPE;

  BEGIN

   pr_dsbeninss := '';

   OPEN cr_retorna_desc_benef_inss(pr_cdbeninss => pr_cdbeninss);
   FETCH cr_retorna_desc_benef_inss INTO rw_retorna_desc_benef_inss;

   IF cr_retorna_desc_benef_inss%FOUND THEN
     pr_dsbeninss:= rw_retorna_desc_benef_inss.dsbeninss;
   END IF;

   CLOSE cr_retorna_desc_benef_inss;

  EXCEPTION

    WHEN vr_exc_erro THEN
    /* busca valores de critica predefinidos */
    IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      /* busca a descri�ao da cr�tica baseado no c�digo */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma cr�tica predefina para um codigo de retorno, estabele um texto gen�rico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'Erro geral na rotina pc_retorna_desc_inss: ' || sqlerrm;

  END pc_retorna_desc_inss;


-- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
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


    -----------------------------------------------------------------------
    -- Chamar rotina de c�lculo externa
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
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_TR: '||SQLERRM;

      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
  END pc_pagar_emprestimo_tr;

  
  -- Realizar o calculo e pagamento de preju�zo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
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
                                        ,pr_vliofcpl  IN crapepr.vliofcpl%TYPE        -- Valor do IOF complementar
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
      vr_vlpagmto := NVL(pr_vlsdprej,0) + NVL(pr_vlttmupr,0) + NVL(pr_vlttjmpr,0) - NVL(pr_vlpgmupr,0) - NVL(pr_vlpgjmpr,0);
      GOTO GERAR_ABONO_LEM;
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

    IF vr_vlapagar > 0 THEN

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
           AND epr.nrctremp = pr_nrctremp
           AND epr.dtliquid IS NULL;

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
     IF UPPER(pr_nmtelant) <> 'BLQPREJU' THEN 
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci         --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 100                 --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> C�digo do Operador
                                      ,pr_cdpactra => pr_cdagenci         --> P.A. da transa��o
                                      ,pr_nrdolote => 650001              --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta         --> N�mero da conta
                                      ,pr_cdhistor => 384                 --> Codigo historico
                                      ,pr_vllanmto => pr_vltotpag - nvl(pr_vliofcpl,0)        --> Valor do debito
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
    END IF; -- Lan�amento conta corrente   

     IF NVL(pr_vliofcpl,0) > 0 THEN
       IF UPPER(pr_nmtelant) <> 'BLQPREJU' THEN
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci         --> C�digo da ag�ncia
                                        ,pr_cdbccxlt => 100                 --> N�mero do caixa
                                        ,pr_cdoperad => pr_cdoperad         --> C�digo do Operador
                                        ,pr_cdpactra => pr_cdagenci         --> P.A. da transa��o
                                        ,pr_nrdolote => 650001              --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta         --> N�mero da conta
                                        ,pr_cdhistor => 2313                --> Codigo historico
                                        ,pr_vllanmto => pr_vliofcpl         --> Valor do debito
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
              pr_dscritic := 'Erro ao criar o lancamento de IOF na conta corrente.';
             END IF;
            RAISE vr_exc_erro;
          END IF;
        END IF; --Lan�amento na conta corrente   

      -- Lan�amento na conta corrente
       IF UPPER(pr_nmtelant) = 'BLQPREJU' THEN
         
       PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => pr_nrdconta,
                                      pr_cdoperad => pr_cdoperad,
                                      pr_vlrlanc  => pr_vltotpag - nvl(pr_vliofcpl,0) + nvl(pr_vliofcpl,0) ,
                                      pr_dtmvtolt => pr_crapdat.dtmvtolt,
                                       
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);                             

     -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        -- Se possui algum erro na tabela de erros
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
         RAISE vr_exc_erro;
     END IF;
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
    -- INICIO PARA O LAN�AMENTO DE ABONO NA CRAPLEM
    ------------------------------------------------------------------------------------------------------------
    /***********/   <<GERAR_ABONO_LEM>>   /***********/
    ------------------------------------------------------------------------------------------------------------

    IF NVL(pr_inliqaco,'N') = 'S' THEN

      IF vr_vlpagmto > 0 THEN

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
                                     ,pr_cdorigem => 1                 -- Origem do Lan�amento
                                     ,pr_cdcritic => vr_cdcritic       -- Codigo Erro
                                     ,pr_dscritic => vr_dscritic);     -- Descricao Erro

      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza a informa��o do empr�stimo
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

      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PREJUIZO: '||SQLERRM;

      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
  END pc_pagar_emprestimo_prejuizo;

  
   -- Realizar o calculo e pagamento de folha de pagamento
  PROCEDURE pc_pagar_emprestimo_folha  (pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                          ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                          ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                          ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
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
    IF UPPER(pr_nmtelant) <> 'BLQPREJU' THEN     
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
   END IF; -- Lan�amento na conta corrente  
    
    --Lan�amento conta transitoria
    IF UPPER(pr_nmtelant) = 'BLQPREJU' THEN
         
       PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper  => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_cdoperad => pr_cdoperad,
                                     pr_vlrlanc  => pr_vltotpag ,
                                     pr_dtmvtolt => pr_crapdat.dtmvtolt,
                                       
                                     pr_cdcritic => vr_cdcritic,
                                     pr_dscritic => vr_dscritic);                             

     -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        -- Se possui algum erro na tabela de erros
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
         RAISE vr_exc_erro;
     END IF;
   END IF; --Lan�amento conta transitoria
   
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero

      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_FOLHA: '||SQLERRM;

      /** DESFAZER A TRANSA��O **/
      ROLLBACK TO SAVE_EPR_FOLHA;
      /**************************/
  END pc_pagar_emprestimo_folha;
 

   -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
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
                                              NVL(vr_tab_pagto_compe(idx).vlmrapar,0) +
                                              NVL(vr_tab_pagto_compe(idx).vliofcpl,0) ;

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
                         NVL(vr_tab_pgto_parcel(idx).vlmrapar,0) +
                         NVL(vr_tab_pgto_parcel(idx).vliofcpl,0) ;

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

      -- VERIFICAR NOVAMENTE SE O VALOR DO AJUSTE � MAIOR QUE ZERO
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
      END IF; -- fim IF nvl(vr_vlajuste, 0) > 0
    END IF; -- FIM nvl(vr_vlajuste, 0) > 0

  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero

      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PP: '||SQLERRM;

      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
  END pc_pagar_emprestimo_pp;
  
  
  -- Realizar o calculo e pagamento de Emprestimo POS
  PROCEDURE pc_pagar_emprestimo_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- C�digo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- N�mero da Conta
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- C�digo da agencia
                                   ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                   ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- N�mero do contrato de empr�stimo
                                   ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE
                                   ,pr_vlemprst  IN crapepr.vlemprst%TYPE    
                                   ,pr_txmensal  IN crapepr.txmensal%TYPE 
                                   ,pr_dtprivencto IN crawepr.dtdpagto%TYPE
                                   ,pr_vlsprojt    IN crapepr.vlsprojt%TYPE
                                   ,pr_qttolar    IN crapepr.qttolatr%TYPE
                                   ,pr_nrparcel    IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                   ,pr_vlsdeved    IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                   ,pr_vlsdevat    IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
                                   ,pr_idorigem    IN NUMBER                       -- Indicador da origem
                                   ,pr_nmtelant    IN VARCHAR2                     -- Nome da tela
                                   ,pr_cdoperad    IN VARCHAR2                     -- C�digo do operador
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

 

   --Tabelas de Memoria para Pagamentos das Parcelas Emprestimo
   vr_tab_pgto_parcel  EMPR0001.typ_tab_pgto_parcel;
   vr_tab_calculado    EMPR0001.typ_tab_calculado;
   vr_tab_parcelas_pos EMPR0011.typ_tab_parcelas;
   
   vr_tab_price EMPR0011.typ_tab_price;
   
   vr_index_pos PLS_INTEGER;


    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
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

    -----------------------------------------------------------------------------------------------
    -- Buscar as parcelas do contrato
    -----------------------------------------------------------------------------------------------


       

      -- Busca as parcelas para pagamento
      EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
  							                             ,pr_cdprogra => vr_cdprogra
                                             ,pr_flgbatch => TRUE
                                             ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                             ,pr_dtmvtoan => pr_crapdat.dtmvtoan
                                             ,pr_nrdconta => pr_nrdconta        -- rw_crapepr.nrdconta
                                             ,pr_nrctremp => pr_nrctremp        --rw_crapepr.nrctremp
                                             ,pr_dtefetiv => pr_crapdat.dtmvtolt--rw_crapepr.dtmvtolt
                                             ,pr_cdlcremp => pr_cdlcremp        --rw_crapepr.cdlcremp
                                             ,pr_vlemprst => pr_vlemprst        --rw_crapepr.vlemprst
                                             ,pr_txmensal => pr_txmensal        --rw_crapepr.txmensal
                                             ,pr_dtdpagto => pr_dtprivencto     --rw_crapepr.dtprivencto
                                             ,pr_vlsprojt => pr_vlsprojt        --rw_crapepr.vlsprojt
                                             ,pr_qttolatr => pr_qttolar         --rw_crapepr.qttolatr
                                             ,pr_tab_parcelas => vr_tab_parcelas_pos
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            -- Gera Log
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                          ' - Conta =  ' || TO_CHAR(pr_nrdconta, 'FM9999G999G9') ||
                                                          ' - Contrato = ' || TO_CHAR(pr_nrctremp, 'FM99G999G999'));
            RAISE vr_exc_saida;
          END IF;
          
          
          
          -- Limpa PLTable
          vr_tab_price.DELETE;
          
          -- Carregar as variveis de retorno
          vr_index_pos := vr_tab_parcelas_pos.FIRST;
          WHILE vr_index_pos IS NOT NULL LOOP
            -- Chama pagamento da parcela
            EMPR0011.pc_gera_pagto_pos(pr_cdcooper  =>  pr_cdcooper--rw_crapepr.cdcooper
									                            ,pr_cdprogra =>  vr_cdprogra
                                              ,pr_dtcalcul  => pr_crapdat.dtmvtolt
                                              ,pr_nrdconta  => pr_nrdconta--rw_crapepr.nrdconta
                                              ,pr_nrctremp  => pr_nrctremp--rw_crapepr.nrctremp
                                              ,pr_nrparepr  => vr_tab_parcelas_pos(vr_index_pos).nrparepr
                                              ,pr_vlpagpar  => vr_tab_parcelas_pos(vr_index_pos).vlatrpag
                                              ,pr_idseqttl  => 1
                                              ,pr_cdagenci  => pr_cdagenci---rw_crapepr.cdagenci
                                              ,pr_cdpactra  => pr_cdagenci--rw_crapepr.cdagenci
                                              ,pr_nrdcaixa  => 0
                                              ,pr_cdoperad  => '1'
                                              ,pr_nrseqava  => 0
                                              ,pr_idorigem  => 7 -- BATCH
                                              ,pr_nmdatela  => pr_nmtelant
                                              ,pr_tab_price => vr_tab_price
                                              ,pr_cdcritic  => vr_cdcritic
                                              ,pr_dscritic  => vr_dscritic);
            -- Se houve erro
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Proximo index
            vr_index_pos := vr_tab_parcelas_pos.NEXT(vr_index_pos);
          END LOOP;



  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      pr_dscritic := vr_dscritic;    
      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_POS: '||SQLERRM;

      /** DESFAZER A TRANSA��O **/
      ROLLBACK;
      /**************************/
  END pc_pagar_emprestimo_pos;

END EMPR9999;
/