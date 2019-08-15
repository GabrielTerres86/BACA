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
  -- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
  --
  -- Alteração : 19/07/2018 - Implementação da rotina pc_retorna_inss_consignavel (Robson/GFT)
  --
  --             20/07/2018 - Implementação da rotina pc_retorna_desc_inss (Robson/GFT)
  --
  --             24/07/2018 - alteração da indentação da rotina pc_busca_numero_contrato (Robson/GFT)
  --
  --             24/07/2018 - alteração do fechamento do cursor da rotina pc_retorna_inss_consignavel (Robson/GFT)
  --
  --             25/07/2018 - Revisão do separador do campo pr_dsctrliq de ";" para "," pa pc_proc_qualif_operacao (Andrew Albuquerque - GFT)
  --
  --             26/07/2018 Revisão das regras de qualificação (Andrew Albuquerque - GFT)
  --
  --             31/07/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                        - pc_pagar_emprestimo_prejuizo;
  --                        - pc_pagar_emprestimo_tr;
  --                        - pc_pagar_emprestimo_folha;
  --                        - pc_pagar_emprestimo_pp;
  --
  --             15/08/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                        - pc_pagar_emprestimo_pos
  --
  --             14/12/2018 - P298.2 - Inclusão da proposta Pós fixado no simulador (Andre Clemer - Supero)
  --                        - pc_busca_dominio;
  --
  --             13/05/2019 - PJ298.2. - Ajustado para pagar multa e juros de emprestimo em prejuizo (Rafael Faria - Supero)
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Trazer a qualificao da operacao Na alteraçao e inclusao de proposta. (migração progress: b1wgen0002.p/proc_qualif_operacao)
  PROCEDURE pc_proc_qualif_operacao( pr_cdcooper IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapepr.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
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

  --> Grava migracao de emprestimo
  PROCEDURE pc_grava_migra_empr (pr_cdcooper  IN tbepr_migracao_empr.cdcooper%type --> Código da cooperativa
                                ,pr_nrdconta  IN tbepr_migracao_empr.nrdconta%type --> Numero da conta
                                ,pr_nrctremp  IN tbepr_migracao_empr.nrctremp%type --> Numero do emprestimo
                                ,pr_dtmvtolt  IN tbepr_migracao_empr.dtmvtolt%type --> Data de migracao
                                ,pr_nrctrnov  IN tbepr_migracao_empr.nrctrnov%type --> Numero do emprestimo migrado
                                ,pr_dscritic  OUT VARCHAR2);                       --> Retorno de Erro
                                
 PROCEDURE pc_verifica_empr_migrado(pr_cdcooper IN tbepr_migracao_empr.cdcooper%TYPE
                                    ,pr_nrdconta IN tbepr_migracao_empr.nrdconta%TYPE
                                    ,pr_nrctrnov IN tbepr_migracao_empr.nrctrnov%TYPE
                                    ,pr_tpempmgr IN NUMBER DEFAULT 0 -- (0-Migrado, 1-Antigo)
                                    ,pr_nrctremp OUT tbepr_migracao_empr.nrctremp%TYPE
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2);
 
                                
 PROCEDURE pc_verifica_empr_migrado_web(pr_cdcooper IN tbepr_migracao_empr.cdcooper%TYPE
                                      ,pr_nrdconta IN tbepr_migracao_empr.nrdconta%TYPE
                                      ,pr_nrctrnov IN tbepr_migracao_empr.nrctrnov%TYPE
                                      ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic     OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic     OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo     OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro     OUT VARCHAR2) ; --> Erros do processo

-- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo
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


  -- Realizar o calculo e pagamento de prejuízo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
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
                                        ,pr_vlrabono  IN NUMBER DEFAULT 0            -- Valor do abono concedido (aplicado somente a contratos em prejuízo P637)
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


  -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                      ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                      ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo
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
                                      ,pr_dscritic OUT VARCHAR2);                 -- Descrição da crítica



   -- Realizar o calculo e pagamento de Emprestimo POS
 PROCEDURE pc_pagar_emprestimo_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                   ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                   ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo
                                   ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE
                                   ,pr_vlemprst  IN crapepr.vlemprst%TYPE
                                   ,pr_txmensal  IN crapepr.txmensal%TYPE
                                   ,pr_dtprivencto IN crawepr.dtdpagto%TYPE
																	 ,pr_dtmvtolt  IN crapepr.dtmvtolt%TYPE
                                   ,pr_vlsprojt    IN crapepr.vlsprojt%TYPE
                                   ,pr_qttolar    IN crapepr.qttolatr%TYPE
                                   ,pr_nrparcel    IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                   ,pr_vlsdeved    IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                   ,pr_vlsdevat    IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
																	 ,pr_vlrpagar    IN NUMBER
                                   ,pr_idorigem    IN NUMBER                       -- Indicador da origem
                                   ,pr_nmtelant    IN VARCHAR2                     -- Nome da tela
                                   ,pr_cdoperad    IN VARCHAR2                     -- Código do operador
                                   ,pr_idvlrmin OUT NUMBER                       -- Indica que houve critica do valor minimo
                                   ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                   ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                   ,pr_dscritic OUT VARCHAR2);                   -- Descrição da crítica

  PROCEDURE pc_busca_dominio(pr_nmdominio IN tbepr_dominio_campo.nmdominio%TYPE --> Nome do domínio
                            ,pr_xmllog    IN VARCHAR2                           --> XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER                       --> Código da crítica
                            ,pr_dscritic  OUT VARCHAR2                          --> Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2                          --> Nome do campo com erro
                            ,pr_des_erro  OUT VARCHAR2                          --> Erros do processo
                             );


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
  -- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
  --
  -- Alteração : 19/07/2018 - Implementação da rotina pc_retorna_inss_consignavel (Robson/GFT)
  --
  --             20/07/2018 - Implementação da rotina pc_retorna_desc_inss (Robson/GFT)
  --
  --             25/07/2018 - Revisão do separador do campo pr_dsctrliq de ";" para "," pa pc_proc_qualif_operacao (Andrew Albuquerque - GFT)
  --
  --             26/07/2018 Revisão das regras de qualificação (Andrew Albuquerque - GFT)
  --
   --             31/07/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                        - pc_pagar_emprestimo_prejuizo;
  --                        - pc_pagar_emprestimo_tr;
  --                        - pc_pagar_emprestimo_folha;
  --                        - pc_pagar_emprestimo_pp;
  --
  --             15/08/2018 - Pagamento de Emprestimos/Financiamentos (Rangel Decker / AMcom)
  --                         - pc_pagar_emprestimo_pos
  --
  --
  --             27/12/2018 - Alteração no tratamento para contas corrente em prejuízo (verificar através
  -- 						              da função PREJ0003.fn_verifica_preju_conta ao invés de usar o "pr_nmdatela").
  --													P450 - Reginaldo/AMcom         
  --
  --             14/12/2018 - P298.2 - Inclusão da proposta Pós fixado no simulador (Andre Clemer - Supero)
  --                        - pc_busca_dominio;
  --
  --             17/04/2019 - Remoção de chamada equivocada da procedure "PREJ0003.pc_gera_debt_cta_prj" no
  --                          bloco de processamento de IOF pago da procedure "pc_pagar_emprestimo_prejuizo".
  --                          P450 - Reginaldo/AMcom
  --
  ---------------------------------------------------------------------------------------------------------------
  /* Tratamento de erro */
  vr_exc_erro EXCEPTION;

  /* Descrição e código da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

   -- Constante com o nome do programa
  vr_cdprogra     CONSTANT VARCHAR2(8) := 'RECP0001';
  vr_dsarqlog     CONSTANT VARCHAR2(10):= 'acordo.log';


  PROCEDURE pc_busca_numero_contrato(pr_cdcooper     IN crapepr.cdcooper%TYPE        --> Codigo da cooperativa
                                    ,pr_nrdconta     IN crapepr.nrdconta%TYPE        --> Conta do Associado
                                    ,pr_nrctremp     IN crapepr.nrctremp%TYPE Default 0 --> Número do Contrato
                                    ----------------- > OUT < ----------------------
                                    ,pr_existenr     OUT INTEGER                                     --> 1 (Verdadeiro) 0 (Falso) para se existe contrato/ proposta
                                    ,pr_cdcritic     OUT INTEGER                                       --> Código da crítica
                                    ,pr_dscritic     OUT VARCHAR2                                      --> Descrição da crítica
                                    ) IS
    /*.............................................................................
         programa: pc_busca_numero_contrato
         sistema :
         sigla   : cred
         autor   : Pedro Cruz (GFT)
         data    : Junho/2018                         ultima atualizacao:

         dados referentes ao programa:

         frequencia: sempre que for chamado.
         objetivo  : procedure para buscar se já existe o número de contrato/ proposta na base de dados

         alteracoes:
    ............................................................................. */
       --Cursor utilizado para verificar se existe Contrato ATIVO com o Número de contrato Recebido (CRAPEPR) nessa cooperativa + Conta;
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
   /* tabela ainda nao liberada
   SELECT nrdconta
         ,cdcooper
         ,nrctremp
   FROM TBEPR_CONSIGNADO_CONTRATO C
   WHERE cdcooper = pr_cdcooper
   AND nrdconta   = pr_nrdconta
   AND nrctremp   = pr_nrctremp
   UNION*/
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

    --Se Existir Proposta e/ou Contrato, deve retornar 1 = Número de Contrato Existe e não pode Ser Usado.
    --Com isso será enviado e a FIS irá cancelar essa solicitação e gerar uma nova com outro número
    IF cr_contratoativo%NOTFOUND THEN
      pr_existenr := 0;
    ELSE
      pr_existenr := 1;
    END IF;

    CLOSE cr_contratoativo;

  EXCEPTION
  WHEN OTHERS THEN
    /* quando nao possuir uma crítica predefina para um codigo de retorno, estabelece um texto genérico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'falha ao buscar se numero do contrato/ proposta existe: ' || sqlerrm;
    /*  fecha a procedure */
  END pc_busca_numero_contrato;

  -- Trazer a qualificao da operacao Na alteraçao e inclusao de proposta. (migração progress: b1wgen0002.p/proc_qualif_operacao)
  PROCEDURE pc_proc_qualif_operacao( pr_cdcooper IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapepr.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
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
  --               10/07/2018 Revisão da proc_qualif_operacao x versão de PROD da b1wgen0002.p, onde foram alteradas
                              as regras de qualificação (Andrew Albuquerque - GFT)
  --
  --               25/07/2018 Revisão do separador do campo pr_dsctrliq de ";" para "," (Andrew Albuquerque - GFT)
  --
  --               26/07/2018 Revisão das regras de qualificação (Andrew Albuquerque - GFT)
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
  
  /* descriçao e código da critica */
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(4000);

  -- variaveis para montar os contratos à partir da dsctrliq
  vr_split gene0002.typ_split;
  vr_indice_epr varchar2(200);

  -- Variaveis Auxiliares do Processo
  vr_emp_a_liq crapepr.nrctremp%TYPE;
  vr_qtdias_atraso INTEGER := 0;
  vr_auxdias_atraso INTEGER := 0;
  vr_nrcontrato     crapepr.nrctremp%TYPE;

  -- Monta o registro de data
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_dtmvtoan crapdat.dtmvtoan%TYPE;

  TYPE typ_vet_liquida IS TABLE OF NUMBER
       INDEX BY PLS_INTEGER;
  vr_vet_liquida typ_vet_liquida;

	TYPE typ_des_qualif IS TABLE OF VARCHAR(50)
	     INDEX BY PLS_INTEGER;
	vr_vet_qualif typ_des_qualif;

  BEGIN
    /* descriçao e código da critica */
    vr_cdcritic := null;
    vr_dscritic := '';
    pr_idquapro := 1;
		
		vr_vet_qualif(1) := 'Operacao Normal';
		vr_vet_qualif(2) := 'Renovacao de credito';
		vr_vet_qualif(3) := 'Renegociacao de credito';
		vr_vet_qualif(4) := 'Composicao de divida';
		vr_vet_qualif(5) := 'Cessao de cartao';

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
          -- Numero do Contrato do refinanciamento
          vr_nrcontrato := TO_NUMBER(REPLACE(REPLACE(vr_split(i),',',''),'.',''));
          vr_vet_liquida(vr_nrcontrato) := vr_nrcontrato;
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
        -- Se For um Estouro de Limite de Conta, é o número da conta que virá no vetor,
        -- e é ele que está gravado no campo nrctremp da tabela de risco.
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
			
      IF cr_crapris%ISOPEN THEN
        CLOSE cr_crapris;
      END IF;

      -- Verificando para Empréstimos
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => vr_emp_a_liq
                     ,pr_dtrefere => vr_dtmvtoan);
      FETCH cr_crapepr INTO rw_crapepr;

      IF cr_crapepr%FOUND and rw_crapepr.qtdiaatr IS NOT NULL  THEN
        vr_qtdias_atraso := rw_crapepr.qtdiaatr;
      END IF;
      CLOSE cr_crapepr;

      vr_indice_epr := vr_vet_liquida.next(vr_indice_epr);

    IF vr_auxdias_atraso < vr_qtdias_atraso THEN
      vr_auxdias_atraso := vr_qtdias_atraso;
    END IF;

    -- De 0 a 4 dias de atraso - Renovaçao de Crédito
    IF vr_auxdias_atraso < 5 THEN
      pr_idquapro := 2;
    -- De 5 a 60 dias de atraso - Renegociaçao de Crédito
    ELSIF vr_auxdias_atraso > 4 and vr_auxdias_atraso < 61 THEN
      pr_idquapro := 3;
    -- Igual ou acima de 61 dias - Composiçao de dívida
    ELSIF  vr_auxdias_atraso >= 61 THEN
      pr_idquapro := 4;
    END IF;

    IF pr_idquapro < rw_crapepr.idquaprc THEN
      pr_idquapro := rw_crapepr.idquaprc;
    END IF;
  END LOOP;
		
  pr_dsquapro := vr_vet_qualif(pr_idquapro);
  
  EXCEPTION
    WHEN vr_exc_erro THEN
    /* busca valores de critica predefinidos */
    IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      /* busca a descriçao da crítica baseado no código */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma crítica predefina para um codigo de retorno, estabele um texto genérico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'erro geral na rotina pc_proc_qualif_operacao: ' || sqlerrm;
    /*  fecha a procedure */
  END pc_proc_qualif_operacao;
-- Realizar o calculo e pagamento de Emprestimo TR
  PROCEDURE pc_pagar_emprestimo_tr(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo
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


    -----------------------------------------------------------------------
    -- Chamar rotina de cálculo externa
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
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_TR: '||SQLERRM;

      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK;
      /**************************/
  END pc_pagar_emprestimo_tr;


  -- Realizar o calculo e pagamento de prejuízo
  PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                        ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                        ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
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
                                        ,pr_vlrabono  IN NUMBER DEFAULT 0            -- Valor do abono concedido (aplicado somente a contratos em prejuízo P637)
                                        ,pr_nmtelant  IN VARCHAR2                     -- Nome da tela
                                        ,pr_vliofcpl  IN crapepr.vliofcpl%TYPE        -- Valor do IOF complementar
                                        ,pr_vltotpag OUT NUMBER                       -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                        ,pr_dscritic OUT VARCHAR2) IS                 -- Descrição da crítica

    /* ..........................................................................
      Programa : pc_pagar_emprestimo_prejuizo
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : 
      Data     :                             Ultima atualizacao: 17/04/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamada
      Objetivo  : Realizar o calculo e pagamento de prejuízo
          
      Alteração : 29/11/2018 - Ajustado para gerar lanc. hist 384 na tabela de prejuizo detalhe, 
                               para pagamentos com conta em prejuiz CC. PRJ450 - Regulatorio (Odirlei-AMcom)
							    
									27/12/2018 - Alteração no tratamento para contas corrente em prejuízo (verificar através
									             da função PREJ0003.fn_verifica_preju_conta ao invés de usar o "pr_nmdatela").
															 P450 - Reginaldo/AMcom
                  23/04/2019 - Alteração no programa, foi incluido a pck pc_crps780_1 
                               P637 - Gilberto/Supero.
    ..........................................................................*/
    -- VARIÁVEIS
    vr_dtprmutl     DATE; -- Data do primeiro dia útil do mês
    vr_vlajuste     NUMBER;
    vr_vlpagmto     NUMBER := pr_vlparcel;
    vr_vltotpgt     NUMBER := 0; -- PJ637
    vr_vlabono      NUMBER := pr_vlrabono;
    vr_des_reto     VARCHAR2(10);
    vr_tab_erro     GENE0001.typ_tab_erro;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);

    -- EXCEPTIONS
    vr_exc_erro     EXCEPTION;
    -- Busca saldo de liquidação Prejuizo
    CURSOR cr_crapepr IS
      SELECT -- PRJ637 -> Valor saldo prej liquida
            (epr.vlsdprej +  -- saldo devedor atualizado
               (nvl(epr.vltiofpr,0) - nvl(epr.vlpiofpr,0)) + -- valor residual IOF
               (nvl(epr.vlttmupr,0) - nvl(epr.vlpgmupr,0)) + -- valor residual de multa
               (nvl(epr.vlttjmpr,0) - nvl(epr.vlpgjmpr,0))) vlsdprjliq 
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
  BEGIN
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

    ------------------------------------------------------------------------------------------------------------
    -- INICIO PARA O LANÇAMENTO DE PAGAMENTO DO PREJUIZO ORIGINAL
    ----------------------------- := -------------------------------------------------------------------------------
    if pr_inliqaco = 'S' and vr_vlpagmto = 0 then 
      --vr_vlabono := pr_vlsdprej;
      OPEN  cr_crapepr;
      FETCH cr_crapepr INTO vr_vlabono;
      CLOSE cr_crapepr;
    else
      vr_vlabono := pr_vlrabono;
          end if;
    pc_crps780_1(pr_cdcooper =>  pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp,
                                 pr_vlpagmto => vr_vlpagmto,
                  pr_vldabono => vr_vlabono,
                  pr_cdagenci => pr_cdagenci,
                                 pr_cdoperad => pr_cdoperad,
                  pr_vltotpgt => vr_vltotpgt,
                                 pr_cdcritic => vr_cdcritic,
                                 pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
         RAISE vr_exc_erro;
     ELSE
       pr_vltotpag := vr_vltotpgt + vr_vlabono;
      END IF;
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero

      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PREJUIZO: '||SQLERRM;

      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK;
      /**************************/
  END pc_pagar_emprestimo_prejuizo;


   -- Realizar o calculo e pagamento de folha de pagamento
  PROCEDURE pc_pagar_emprestimo_folha  (pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                          ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                          ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                          ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo
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

		vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo

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

		-- Verifica se a conta corrente está em prejuízo - Reginaldo/AMcom
		vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

    -----------------------------------------------------------------------------------------------
    -- Debita em conta corrente o total pago do emprestimo
    -----------------------------------------------------------------------------------------------
    IF NOT vr_prejuzcc THEN
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
    ELSE
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
   END IF; --Lançamento conta transitoria

  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero

      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK;
      /**************************/
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_FOLHA: '||SQLERRM;

      /** DESFAZER A TRANSAÇÃO **/
      ROLLBACK TO SAVE_EPR_FOLHA;
      /**************************/
  END pc_pagar_emprestimo_folha;


   -- Realizar o calculo e pagamento de Emprestimo PP
  PROCEDURE pc_pagar_emprestimo_pp(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                  ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                  ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo
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

		vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo

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

			-- Verifica se a conta corrente está em prejuízo - Reginaldo/AMcom
			vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

      -- VERIFICAR NOVAMENTE SE O VALOR DO AJUSTE É MAIOR QUE ZERO
      IF nvl(vr_vlajuste, 0) > 0 AND NOT vr_prejuzcc THEN
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
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PP: '||SQLERRM;
  END pc_pagar_emprestimo_pp;


  -- Realizar o calculo e pagamento de Emprestimo POS
  PROCEDURE pc_pagar_emprestimo_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE        -- Código da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE        -- Número da Conta
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE        -- Código da agencia
                                   ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  -- Datas da cooperativa
                                   ,pr_nrctremp  IN crapepr.nrctremp%TYPE        -- Número do contrato de empréstimo
                                   ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE
                                   ,pr_vlemprst  IN crapepr.vlemprst%TYPE
                                   ,pr_txmensal  IN crapepr.txmensal%TYPE
                                   ,pr_dtprivencto IN crawepr.dtdpagto%TYPE
																	 ,pr_dtmvtolt  IN crapepr.dtmvtolt%TYPE
                                   ,pr_vlsprojt    IN crapepr.vlsprojt%TYPE
                                   ,pr_qttolar    IN crapepr.qttolatr%TYPE
                                   ,pr_nrparcel    IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                   ,pr_vlsdeved    IN crapepr.vlsdeved%TYPE        -- Valor do saldo devedor
                                   ,pr_vlsdevat    IN crapepr.vlsdevat%TYPE        -- Valor anterior do saldo devedor
																	 ,pr_vlrpagar    IN NUMBER
                                   ,pr_idorigem    IN NUMBER                       -- Indicador da origem
                                   ,pr_nmtelant    IN VARCHAR2                     -- Nome da tela
                                   ,pr_cdoperad    IN VARCHAR2                     -- Código do operador
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



   --Tabelas de Memoria para Pagamentos das Parcelas Emprestimo
   vr_tab_parcelas_pos EMPR0011.typ_tab_parcelas;
	 vr_tab_calculado    empr0011.typ_tab_calculado;

   vr_tab_price EMPR0011.typ_tab_price;

   vr_index_pos PLS_INTEGER;
	 
	 vr_vlrpagar NUMBER := pr_vlrpagar;
	 vr_vlparcel NUMBER;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

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
    pr_vltotpag := 0;

      -- Busca as parcelas para pagamento
      EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
  							                             ,pr_cdprogra => vr_cdprogra
                                             ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                             ,pr_dtmvtoan => pr_crapdat.dtmvtoan
                                             ,pr_nrdconta => pr_nrdconta        -- rw_crapepr.nrdconta
                                             ,pr_nrctremp => pr_nrctremp        --rw_crapepr.nrctremp
                                             ,pr_dtefetiv => pr_dtmvtolt        --rw_crapepr.dtmvtolt
                                             ,pr_cdlcremp => pr_cdlcremp        --rw_crapepr.cdlcremp
                                             ,pr_vlemprst => pr_vlemprst        --rw_crapepr.vlemprst
                                             ,pr_txmensal => pr_txmensal        --rw_crapepr.txmensal
                                             ,pr_dtdpagto => pr_dtprivencto     --rw_crapepr.dtprivencto
                                             ,pr_vlsprojt => pr_vlsprojt        --rw_crapepr.vlsprojt
                                             ,pr_qttolatr => pr_qttolar         --rw_crapepr.qttolatr
                                             ,pr_tab_parcelas => vr_tab_parcelas_pos
																						 ,pr_tab_calculado => vr_tab_calculado
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
          WHILE vr_index_pos IS NOT NULL AND vr_vlrpagar > 0 LOOP
            -- Chama pagamento da parcela
						
						IF vr_vlrpagar >= vr_tab_parcelas_pos(vr_index_pos).vlatrpag THEN
							vr_vlparcel := vr_tab_parcelas_pos(vr_index_pos).vlatrpag;
						ELSE
							vr_vlparcel := vr_vlrpagar;
						END IF;
						
            EMPR0011.pc_gera_pagto_pos(pr_cdcooper  =>  pr_cdcooper--rw_crapepr.cdcooper
									                   ,pr_cdprogra =>  vr_cdprogra
                                     ,pr_dtcalcul  => pr_crapdat.dtmvtolt
                                     ,pr_nrdconta  => pr_nrdconta--rw_crapepr.nrdconta
                                     ,pr_nrctremp  => pr_nrctremp--rw_crapepr.nrctremp
                                     ,pr_nrparepr  => vr_tab_parcelas_pos(vr_index_pos).nrparepr
                                     ,pr_vlpagpar  => vr_vlparcel
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
						
						vr_vlrpagar := vr_vlrpagar - vr_vlparcel;
						pr_vltotpag := pr_vltotpag + vr_vlparcel;
          END LOOP;
  EXCEPTION
    WHEN  vr_exc_erro THEN
      pr_vltotpag := 0; -- retornar zero
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_vltotpag := 0; -- retornar zero
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_POS: '||SQLERRM;
  END pc_pagar_emprestimo_pos;

    --> Grava migracao de emprestimo
  PROCEDURE pc_grava_migra_empr (pr_cdcooper  IN tbepr_migracao_empr.cdcooper%type --> Código da cooperativa
                                ,pr_nrdconta  IN tbepr_migracao_empr.nrdconta%type --> Numero da conta
                                ,pr_nrctremp  IN tbepr_migracao_empr.nrctremp%type --> Numero do emprestimo
                                ,pr_dtmvtolt  IN tbepr_migracao_empr.dtmvtolt%type --> Data de migracao
                                ,pr_nrctrnov  IN tbepr_migracao_empr.nrctrnov%type --> Numero do emprestimo migrado
                                ,pr_dscritic  OUT VARCHAR2)IS                      --> Retorno de Erro
            
    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;

  BEGIN
    -- Insere a tabela de log
    BEGIN
      insert into tbepr_migracao_empr
                 (cdcooper 
                 ,nrdconta 
                 ,nrctremp 
                 ,dtmvtolt 
                 ,nrctrnov)
           values(pr_cdcooper 
                 ,pr_nrdconta 
                 ,pr_nrctremp 
                 ,pr_dtmvtolt 
                 ,pr_nrctrnov);

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbepr_migracao_empr '||SQLERRM;
        RAISE vr_exc_erro;
    END;

  EXCEPTION
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_dscritic := 'Erro na execucao do programa graca migracao emprestimo - '|| SQLERRM;
  END pc_grava_migra_empr;   
  
  --> Rotina responsavel por validar se o emprestimo foi migrado
  PROCEDURE pc_verifica_empr_migrado(pr_cdcooper IN tbepr_migracao_empr.cdcooper%TYPE
                                    ,pr_nrdconta IN tbepr_migracao_empr.nrdconta%TYPE
                                    ,pr_nrctrnov IN tbepr_migracao_empr.nrctrnov%TYPE
                                    ,pr_tpempmgr IN NUMBER DEFAULT 0 -- (0-Migrado, 1-Antigo)
                                    ,pr_nrctremp OUT tbepr_migracao_empr.nrctremp%TYPE
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2) IS
  BEGIN                                        
    /* ..........................................................................
      Programa : pc_verifica_empr_migrado
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Rafael Faria (Supero)
      Data     : Outubro/2018.                   Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamada
      Objetivo  : Verificar se o emprestimo foi migrado
          
      Alteração : 
    ..........................................................................*/
    DECLARE
      -- Variáveis para tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Buscar emprestimos migrados tanto o migrado como original conforme paremetro
      -- se for pr_tpempmgr=0 ele busca atraves do migrado para retornar o original
      -- se for pr_tpempmgr=1 ele busca atraves do original para retornar o migrado
      CURSOR cr_migrado IS
        SELECT decode(pr_tpempmgr,0,e.nrctremp,e.nrctrnov) nrctremp
          FROM tbepr_migracao_empr e
         WHERE e.cdcooper = pr_cdcooper
           AND e.nrdconta = pr_nrdconta
           AND ((e.nrctrnov = pr_nrctrnov and pr_tpempmgr=0) OR 
                (e.nrctremp = pr_nrctrnov and pr_tpempmgr=1));
      rw_migrado cr_migrado%ROWTYPE;

    BEGIN
      
      OPEN cr_migrado;
      FETCH cr_migrado INTO rw_migrado;
      CLOSE cr_migrado;  
      
      -- retorna o numero do emprestimo conforme parametro antigo/novo
      pr_nrctremp := nvl(rw_migrado.nrctremp,0);
      
    EXCEPTION
      WHEN OTHERS THEN      
        -- Erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
    END;
  END pc_verifica_empr_migrado;
  
  PROCEDURE pc_verifica_empr_migrado_web(pr_cdcooper IN tbepr_migracao_empr.cdcooper%TYPE
                                        ,pr_nrdconta IN tbepr_migracao_empr.nrdconta%TYPE
                                        ,pr_nrctrnov IN tbepr_migracao_empr.nrctrnov%TYPE
                                        ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                                        ,pr_cdcritic     OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic     OUT VARCHAR2 --> Descricao da critica
                                        ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo     OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro     OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_verifica_empr_migrado_web
    Sistema : Ayllos Web
    Autor   : Rafael Faria (Supero)
    Data    : Outubro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para retornar emprestimo migrado

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis
      vr_nrctremp NUMBER;

    BEGIN

      -- Carrega os dados
      pc_verifica_empr_migrado(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctrnov => pr_nrctrnov
                              ,pr_nrctremp => vr_nrctremp
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        raise vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrctremp'
                            ,pr_tag_cont => vr_nrctremp
                            ,pr_des_erro => vr_dscritic);


    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina verifica empr migrado: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_verifica_empr_migrado_web;
  
  PROCEDURE pc_busca_dominio(pr_nmdominio IN tbepr_dominio_campo.nmdominio%TYPE --> Nome do domínio
                            ,pr_xmllog    IN VARCHAR2                           --> XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER                       --> Código da crítica
                            ,pr_dscritic  OUT VARCHAR2                          --> Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2                          --> Nome do campo com erro
                            ,pr_des_erro  OUT VARCHAR2                          --> Erros do processo
                             ) IS
      /* .............................................................................
        Programa: pc_busca_dominio
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Andre Clemer - Supero
        Data    : Dezembro/18.                    Ultima atualizacao: --/--/----
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
      
        Objetivo  : Retornar lista as opções do domínio enviado
      
        Observacao: -----
      
        Alteracoes:
      ..............................................................................*/

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(4000); --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variáveis para armazenar as informações em XML
      vr_des_xml CLOB;
      -- Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_texto_completo VARCHAR2(32600);

      -- Tabela que receberá as opções do domínio
      vr_tab_dominios gene0010.typ_tab_dominio;

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                              ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      END;

  BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levanta exceção
          RAISE vr_exc_saida;
      END IF;

      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      -- Busca as opções do domínio
      gene0010.pc_retorna_dominios(pr_nmmodulo     => 'EPR' --> Nome do modulo(TB<EPR>_DOMINIO_CAMPO)
                                  ,pr_nmdomini     => pr_nmdominio --> Nome do dominio
                                  ,pr_tab_dominios => vr_tab_dominios --> retorna os dados dos dominios
                                  ,pr_dscritic     => vr_dscritic --> retorna descricao da critica
                                   );

      IF vr_tab_dominios.count > 0 THEN

          pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');

          FOR i IN vr_tab_dominios.first .. vr_tab_dominios.last LOOP

              dbms_output.put_line(vr_tab_dominios(i).cddominio || ' - ' || vr_tab_dominios(i).dscodigo);
              pc_escreve_xml('<inf>' || '<nmdominio>' || pr_nmdominio || '</nmdominio>' || '<cddominio>' || vr_tab_dominios(i)
                             .cddominio || '</cddominio>' || '<dscodigo>' || vr_tab_dominios(i).dscodigo ||
                             '</dscodigo>' || '</inf>');

          END LOOP;

          pc_escreve_xml('</dados></root>', TRUE);

          pr_retxml := xmltype.createxml(vr_des_xml);

      ELSE

          vr_dscritic := 'Nenhuma opcao encontrada para o dominio informado: ' || pr_nmdominio;
          RAISE vr_exc_saida;

      END IF;

  EXCEPTION
      WHEN vr_exc_saida THEN
          IF vr_cdcritic <> 0 THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
          END IF;

          pr_des_erro := 'NOK';
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                         pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
          pr_des_erro := 'NOK';
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                         pr_dscritic || '</Erro></Root>');

  END pc_busca_dominio;

END EMPR9999;
/
