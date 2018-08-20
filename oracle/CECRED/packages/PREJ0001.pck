CREATE OR REPLACE PACKAGE CECRED.PREJ0001 AS

/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Cal�o - Mout�S
   Data    : Maio/2017                      Ultima atualizacao: 28/05/2017

   Dados referentes ao programa:

   Frequencia: Di�ria (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de
               transfer�ncia para preju�zo

   Alteracoes:

..............................................................................*/

   TYPE typ_reg_log IS
      RECORD(valor_old crapprm.dsvlrprm%TYPE
            ,valor_new crapprm.dsvlrprm%TYPE);

    /* Pl-Table que ira chave e valor dos registros da CRAPPRM */
   TYPE typ_reg_consulta_prm IS
      RECORD(dsvlrprm crapprm.dsvlrprm%TYPE);

   TYPE typ_log           IS TABLE OF typ_reg_log          INDEX BY BINARY_INTEGER;
   TYPE typ_verifica_log  IS TABLE OF typ_log              INDEX BY BINARY_INTEGER;
   TYPE typ_consulta_prm  IS TABLE OF typ_reg_consulta_prm INDEX BY BINARY_INTEGER;

    --
    FUNCTION fn_regra_dtprevisao_prejuizo(pr_cdcooper IN crapris.cdcooper%TYPE,
                                          pr_innivris IN crapris.innivris%TYPE,
                                          pr_qtdiaatr IN crapris.qtdiaatr%TYPE,
                                          pr_dtdrisco IN crapris.dtdrisco%TYPE
                                          ) RETURN DATE;

	-- ***
    -- Fun��o para retornar Juros+60 "Data Anterior" para Empr�stimos/ financiamentos em preju�zo
    FUNCTION fn_juros60_emprej(pr_cdcooper IN  crapris.cdcooper%TYPE  --> C�digo da cooperativa
                              ,pr_nrdconta IN  crapris.nrdconta%TYPE  --> N�mero da conta
                              ,pr_nrctremp IN  crapris.nrctremp%TYPE) --> N�mero do contrato
                              RETURN NUMBER;
    
    /* Realiza a grava��o dos parametros da transferencia para prejuizo informados na tela PARTRP */
    PROCEDURE pc_grava_prm_trp(pr_dsvlrprm1   IN VARCHAR2   --> Data de inicio da vig�ncia
                              ,pr_dsvlrprm2   IN VARCHAR2   --> produto
                              ,pr_dsvlprmgl   IN VARCHAR2   --> opera��o
                              ,pr_xmllog      IN VARCHAR2   --> XML com informa��es de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic  OUT VARCHAR2    --> Descri��o da cr�tica
                              ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2    --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2);  --> Erros do processo

    /* Realiza a consulta das informacoes de parametros de transferencia para prejuizo - tela PARTRP */
    PROCEDURE pc_consulta_prm_trp(pr_dsvlrprm1   IN VARCHAR2            --> Data de inicio da vig�ncia
                                 ,pr_dsvlrprm2   IN VARCHAR2           --> produto
                                 ,pr_xmllog      IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER         --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2            --> Descri��o da cr�tica
                                 ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo

    /* Rotina de transferencia de contratos de empr�stimo - produto PP */
    PROCEDURE pc_transfere_epr_prejuizo_PP(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_idseqttl in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );

    /* Rotina de transferencia de contratos de empr�stimo - produto TR */
    PROCEDURE pc_transfere_epr_prejuizo_TR(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  )    ;

    /* Rotina de transferencia para preju�zo de contas correntes com estouro  */
/*    Procedure pc_gera_prejuizo_cc(PR_CDCOOPER IN NUMBER DEFAULT NULL
                                  ,PR_NRDCONTA IN NUMBER DEFAULT NULL
                                  ,PR_VLSDDISP in NUMBER DEFAULT NULL);*/

    /* Rotina para estornar transferencia prejuizo PP */
    PROCEDURE pc_estorno_trf_prejuizo_PP(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );

    /* Rotina para estornar transferencia prejuizo TR */
    PROCEDURE pc_estorno_trf_prejuizo_TR(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );

     /* Rotina para estornar transferencia prejuizo CC */
/*    PROCEDURE pc_estorno_trf_prejuizo_CC(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );*/

    /* rotina executada pela tela Atenda para "for�ar" o envio de empr�stimos para preju�zo */
    PROCEDURE pc_transfere_prejuizo_web (pr_nrdconta   IN VARCHAR2     --> Conta corrente
                                         ,pr_nrctremp   IN VARCHAR2     --> Contrato de emprestimo
                                         ,pr_xmllog     IN VARCHAR2     --> XML com informa��es de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER  --> C�digo da cr�tica
                                         ,pr_dscritic  OUT VARCHAR2     --> Descri��o da cr�tica
                                         ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2     --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);

     /* Rotina chamada pela Atenda para estornar (desfazer) o preju�zo */
     PROCEDURE pc_estorno_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_idtpoest   in varchar2
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2)  ;

     /* Rotina chamada pela Atenda para transferir prejuizos de CC */
/*     PROCEDURE pc_transfere_prejuizo_CC_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);    */

     PROCEDURE pc_consulta_prejuizo_web(pr_dtprejuz in varchar2
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);

      PROCEDURE pc_importa_arquivo(pr_arquivo in varchar2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

      PROCEDURE pc_tela_busca_contratos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_inprejuz in crapepr.inprejuz%type --> Indicador prejuizo
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);

      PROCEDURE pc_dispara_email_lote (pr_idtipo   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);

     PROCEDURE pc_controla_exe_job(pr_cdcritic OUT NUMBER,
                                   pr_dscritic OUT VARCHAR2);


end PREJ0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0001 AS
/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Cal�o - Mout�S
   Data    : Maio/2017                      Ultima atualizacao: 28/05/2017

   Dados referentes ao programa:

   Frequencia: Di�ria (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de
               transfer�ncia para preju�zo

   Alteracoes:

..............................................................................*/

  vr_cdcritic  NUMBER(3);
  vr_dscritic  VARCHAR2(1000);
  vr_des_reto  VARCHAR2(10);
  vr_tab_erro  gene0001.typ_tab_erro ;
  vr_index     VARCHAR2(100);
  vr_index_calculado NUMBER;
  vr_flgativo  INTEGER;
  vr_flquitado INTEGER;
  --vr_flcancel  integer;
  --gl_nrdolote  craplot.nrdolote%type;
  vr_idfraude  BOOLEAN := FALSE;
  vr_qtregist  NUMBER;
  vr_tab_dados_epr empr0001.typ_tab_dados_epr;
  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

  CURSOR c_crapris(pr_cdcooper IN NUMBER
                  ,pr_nrdconta IN NUMBER
                  ,pr_nrctremp IN NUMBER) IS
    SELECT innivris,
           dtdrisco
      FROM crapris
     WHERE crapris.cdcooper = pr_cdcooper
       AND crapris.nrdconta = pr_nrdconta
       AND crapris.nrctremp = pr_nrctremp
       AND crapris.dtrefere = rw_crapdat.dtultdma
       AND crapris.cdorigem = 3
       AND crapris.inddocto = 1;

  CURSOR c_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  r_crapepr c_crapepr%ROWTYPE;
  --
  CURSOR c_craplcr(pr_cdcooper in number) IS
    SELECT *
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = r_crapepr.cdlcremp;
  r_craplcr c_craplcr%ROWTYPE;
  --
  CURSOR c_crapcyc(pr_cdcooper IN NUMBER
                  ,pr_nrdconta IN NUMBER
                  ,pr_nrctremp IN NUMBER) IS
    SELECT 1
      FROM crapcyc
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND flgehvip = 1
       AND cdmotcin = 2; -- Altera��o SM 6
  --
  CURSOR cr_crapcop (prc_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT c.nmrescop
      FROM crapcop c
     WHERE c.cdcooper = prc_cdcooper;
  --
  FUNCTION f_valida_pagamento_abono(pr_cdcooper in number
                                   ,pr_nrdconta in number
                                   ,pr_nrctremp in number) RETURN BOOLEAN IS
    -- nova M324
    CURSOR cr_craplcm IS
      SELECT SUM(CASE WHEN c.cdhistor IN (2386) THEN c.vllanmto ELSE 0 END)
             -
             SUM(CASE WHEN c.cdhistor IN (2387) THEN c.vllanmto ELSE 0 END) valor_pago
        FROM craplcm c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND to_number(TRIM(REPLACE(c.cdpesqbb,'.',''))) = pr_nrctremp
         AND c.cdhistor in(2386,2387);
      -- nova M324
    CURSOR cr_craplem IS
      SELECT SUM(CASE WHEN c.cdhistor IN (2391) THEN c.vllanmto ELSE 0 END)
             -
             SUM(CASE WHEN c.cdhistor IN (2395) THEN c.vllanmto ELSE 0 END) valor_pago_abono
        FROM craplem c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctremp
         AND c.cdhistor IN (2391,2395);

    RESULT BOOLEAN;

  BEGIN
    RESULT := FALSE;
    FOR rw_craplcm IN cr_craplcm LOOP
      IF rw_craplcm.valor_pago > 0 THEN
        RESULT := TRUE;
      END IF;
    END LOOP;

    FOR rw_craplem IN cr_craplem LOOP
      IF rw_craplem.valor_pago_abono > 0 THEN
        RESULT := TRUE;
      END IF;
    END LOOP;

  RETURN(RESULT);
  END f_valida_pagamento_abono;
  --
  FUNCTION fn_regra_dtprevisao_prejuizo(pr_cdcooper IN crapris.cdcooper%TYPE,
                                        pr_innivris IN crapris.innivris%TYPE,
                                        pr_qtdiaatr IN crapris.qtdiaatr%TYPE,
                                        pr_dtdrisco IN crapris.dtdrisco%TYPE
                                        ) RETURN DATE IS

        vr_dttrfprj                 DATE;
        vr_dias_no_risco_H          NUMBER;
        vr_data_prevista_risco_H    DATE;
        va_qtdiaatr                 NUMBER;
        vr_data_prevista_dia_atraso DATE;

      BEGIN

        /* Busca data de movimento */
        OPEN  btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        IF pr_innivris >= 9  THEN
            -- Quantidade de dias em que est� em risco 9 - H
            vr_dias_no_risco_H := rw_crapdat.dtmvtolt - pr_dtdrisco;
            -- Calcular a quantidade de dias que ainda falta para completar os 180 dias em risco H
            vr_dias_no_risco_H := 180 - vr_dias_no_risco_H;
            -- Somar ou subtrair da data atual do sistema para ter a data prevista dos 180 dias em H
            vr_data_prevista_risco_H := rw_crapdat.dtmvtolt + vr_dias_no_risco_H;
            --
            -- Calcular a quantidade de dias que ainda falta para completar os 180 dias em atraso
            --va_qtdiaatr := 180 - nvl(rw_crapris_last.qtdiaatr,0);
            va_qtdiaatr := 180 - nvl(pr_qtdiaatr,0);
            -- Somar ou subtrair da data atual do sistema para ter a data prevista dos 180 dias em atraso
            vr_data_prevista_dia_atraso := rw_crapdat.dtmvtolt + va_qtdiaatr;

            -- Obter a maior data
            IF TO_NUMBER(TO_CHAR(vr_data_prevista_risco_H,'yyyymmdd')) >
               TO_NUMBER(TO_CHAR(vr_data_prevista_dia_atraso,'yyyymmdd')) THEN
              vr_dttrfprj := vr_data_prevista_risco_H;
            ELSE
              vr_dttrfprj := vr_data_prevista_dia_atraso;
            END IF;
            --
          /*ELSIF vr_innivris = 9 AND NVL(rw_crapris_dtprev.dttrfprj, NULL) IS NOT NULL THEN
            -- Manter a mesma data
            vr_dttrfprj := rw_crapris_dtprev.dttrfprj;*/
            --
          ELSIF pr_innivris < 9 THEN
            -- Zerar a data prevista para transferencia a prejuizo
            vr_dttrfprj := NULL;
            --
          END IF;
        --
        -- Retornar data prevista
        RETURN(vr_dttrfprj);

      END fn_regra_dtprevisao_prejuizo;
  --
  -- ***
  -- Fun��o para retornar Juros+60 "Data Anterior" para Empr�stimos/ financiamentos em preju�zo
  FUNCTION fn_juros60_emprej(pr_cdcooper IN  crapris.cdcooper%TYPE
                            ,pr_nrdconta IN  crapris.nrdconta%TYPE
                            ,pr_nrctremp IN  crapris.nrctremp%TYPE) RETURN NUMBER IS
                                                                                     
     CURSOR cr_juro60_pagos (pr_cdcooper crapris.cdcooper%TYPE
                            ,pr_nrdconta crapris.nrdconta%TYPE
                            ,pr_nrctremp crapris.nrctremp%TYPE) IS
     SELECT sum(CASE WHEN h.cdhistor IN (2473) THEN h.vllanmto
                ELSE 0 END) 
          - sum(CASE WHEN h.cdhistor IN (2474) THEN h.vllanmto
                ELSE 0 END) vllanmto
       FROM craplem h
      WHERE h.cdhistor IN(2473, 2474)
        AND cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctremp = pr_nrctremp;
     rw_juro60_pagos cr_juro60_pagos%ROWTYPE;                              
     
     -- Verifica se existe lan�amento para os hist�ricos espec�ficos
     CURSOR cr_juro60_lem (pr_cdcooper crapris.cdcooper%TYPE
                          ,pr_nrdconta crapris.nrdconta%TYPE
                           ,pr_nrctremp crapris.nrctremp%TYPE) IS
       SELECT nvl(SUM(h.vllanmto),0) vljura60
         FROM craplem h
        WHERE h.cdcooper = pr_cdcooper
          AND h.nrdconta = pr_nrdconta
          AND h.nrctremp = pr_nrctremp
          AND h.cdhistor IN(2402, 2406, 2382, 2397);         
       
     rw_juro60_lem cr_juro60_lem%ROWTYPE;     
    
   BEGIN
     -- Abre cursor cr_juro60_lem
     OPEN cr_juro60_lem(pr_cdcooper, pr_nrdconta, pr_nrctremp); 
    FETCH cr_juro60_lem
     INTO rw_juro60_lem;
    CLOSE cr_juro60_lem;
   
     -- Se existem lan�amentos para os hist�ricos espec�ficos
     IF NVL(rw_juro60_lem.vljura60,0) > 0 THEN        
    
         OPEN cr_juro60_pagos(pr_cdcooper, pr_nrdconta, pr_nrctremp); 
        FETCH cr_juro60_pagos  
         INTO rw_juro60_pagos;
        CLOSE cr_juro60_pagos; 
         --
         RETURN(rw_juro60_lem.vljura60 - nvl(rw_juro60_pagos.vllanmto, 0));
      ELSE
       RETURN(0);  -- Garante retorno zero se n�o houver valor
     END IF;
     --
   END fn_juros60_emprej;
  
   PROCEDURE pc_grava_prm_trp(pr_dsvlrprm1 IN VARCHAR2  -- Data de inicio da vig�ncia
                             ,pr_dsvlrprm2 IN VARCHAR2  -- produto
                             ,pr_dsvlprmgl IN VARCHAR2  -- Parametro geral
                             ,pr_xmllog    IN VARCHAR2            --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                             ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

   /* .............................................................................

   Programa: pc_grava_prm_trp
   Sistema : AyllosWeb
   Sigla   : PREJ
   Autor   : Jean Cal�o - Mout�S
   Data    : Maio/2017.                  Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Efetua a grava��o dos parametros de transfer�ncia para preju�zo - tela PARTRP
   Observacao: OS C�DIGOS DE CR�TICAS DESTE PROGRAMA S�O PR�PRIAS DO MESMO E S�O
               TRATADAS DIRETAMENTE NO PROGRAMA PHP.

   Alteracoes:
   ..............................................................................*/
    -- Cursores

    CURSOR cr_dados_prm(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdacesso crapprm.cdacesso%TYPE) IS
       SELECT prm.dsvlrprm
         FROM crapprm prm
        WHERE prm.cdcooper = p_cdcooper
          AND prm.nmsistem = 'CRED'
          AND prm.cdacesso = p_cdacesso;
    rw_dados_prm cr_dados_prm%ROWTYPE;

    -- Vari�veis
    vr_cdcooper         NUMBER;
    vr_nmdatela         VARCHAR2(25);
    vr_nmeacao          VARCHAR2(25);
    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);

    -- campos
    vr_dsvlprmgl        varchar2(240);

    vr_nrdrowid    ROWID;
    vr_dsorigem    VARCHAR2(100);

    vr_typ_log          typ_verifica_log;
    vr_typ_consulta_prm typ_consulta_prm;

    -- Excess�es
    vr_exc_erro   EXCEPTION;
    wchave        varchar2(24);
    wparam        varchar2(240);

    -- Inicializa pl-table para gravar os parametros
    PROCEDURE pc_grava_parametros IS
    BEGIN
        vr_typ_consulta_prm(1).dsvlrprm  := pr_dsvlrprm1;
        vr_typ_consulta_prm(2).dsvlrprm  := pr_dsvlrprm2;
        vr_typ_consulta_prm(3).dsvlrprm  := pr_dsvlprmgl;
    END;

    -- Fun��o para validar os hist�ricos
    PROCEDURE pr_valida_historico(pr_cdcooper IN     craphis.cdcooper%TYPE
                                 ,pr_cdhistor IN     craphis.cdhistor%TYPE
                                 ,pr_indebcre IN     craphis.indebcre%TYPE
                                 ,pr_cdcritic IN OUT NUMBER
                                 ,pr_dscritic    OUT VARCHAR2) IS

      -- Hist�rico
      CURSOR cr_craphis IS
        SELECT his.indebcre
          FROM craphis his
         WHERE his.cdcooper = pr_cdcooper
           AND his.cdhistor = pr_cdhistor;

      -- Vari�veis
      vr_indebcre         craphis.indebcre%TYPE;

    BEGIN

      -- Validar se o hist�rico informado � valido
      OPEN  cr_craphis;
      FETCH cr_craphis INTO vr_indebcre;
      -- Se n�o encontrou registro
      IF cr_craphis%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craphis;

        -- Retorna erro de hist�rico n�o encontrado
        pr_dscritic := 'Historico nao encontrado!';
        -- Nesta situa��o o cdcritic ira retornar o indice do campo da tela que caiu na valida��o
        pr_cdcritic := pr_cdcritic + 10; -- Erro de historico n�o encontrado

        RETURN;
      ELSE
        -- Fechar o cursor
        CLOSE cr_craphis;

        -- Se for hist�rico de cr�dito e o hist�rico n�o for de d�bito
        IF pr_indebcre = 'C' AND  vr_indebcre <> 'C' THEN

          -- Retorna erro de hist�rico n�o encontrado
          pr_dscritic := 'Historico para tarifa deve ser um historico de credito!';
          RETURN;

        -- Verifica se � um hist�rico de d�bito
        ELSIF pr_indebcre = 'D' AND  vr_indebcre <> 'D' THEN

          -- Retorna erro de hist�rico n�o encontrado
          pr_dscritic := 'Historico para tarifa deve ser um historico de debito!';
          RETURN;

        END IF;
      END IF;

      -- Limpar os parametros de cr�tica
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

    END pr_valida_historico;

   BEGIN

    -- Tratar os valores vindos da Web
    vr_dsvlprmgl  := pr_dsvlprmgl;

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscando descricao da origem do ambiente
     vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

     /*-- Validar Hist�rico transferencia valor principal
     pr_cdcritic := 51; -- C�digo do erro que ser� retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm6
                        ,pr_indebcre => 'C' -- Validar como hist�rico de cr�dito
                        ,pr_cdcritic => pr_cdcritic -- C�digo do erro que ser� retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na valida��o
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Hist�rico Estorno valor principal
     pr_cdcritic := 52; -- C�digo do erro que ser� retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm7
                        ,pr_indebcre => 'D' -- Validar como hist�rico de debito
                        ,pr_cdcritic => pr_cdcritic -- C�digo do erro que ser� retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na valida��o
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Hist�rico transferencia juros + 60
     pr_cdcritic := 53; -- C�digo do erro que ser� retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm8
                        ,pr_indebcre => 'C' -- Validar como hist�rico de cr�dito
                        ,pr_cdcritic => pr_cdcritic -- C�digo do erro que ser� retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na valida��o
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Hist�rico estorno juros + 60
     pr_cdcritic := 54; -- C�digo do erro que ser� retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm9
                        ,pr_indebcre => 'D' -- Validar como hist�rico de d�bito
                        ,pr_cdcritic => pr_cdcritic -- C�digo do erro que ser� retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na valida��o
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;*/

     -- Inicializa pl-table para gravar os parametros
     pc_grava_parametros;

     wchave := 'PARTRP_' || TO_CHAR(to_date(pr_dsvlrprm1,'dd/mm/yyyy'),'YYYYMMDD') || '_' ||
                pr_dsvlrprm2 ;

       OPEN  cr_dados_prm(vr_cdcooper, wchave ); --vr_tab_cdacesso(ind));
       FETCH cr_dados_prm INTO rw_dados_prm;

       -- Fecha o cursor
       CLOSE cr_dados_prm;

       wparam := vr_dsvlprmgl;

       BEGIN
         -- Realizar o update das informa��es
         UPDATE crapprm prm
            SET prm.dsvlrprm = wparam
          WHERE prm.cdcooper = vr_cdcooper
            AND prm.nmsistem = 'CRED'
            AND prm.cdacesso = wchave;

         -- Se nenhum registro foi atualizado
         IF SQL%ROWCOUNT = 0 THEN
           -- Faz a inser��o do parametro
           INSERT INTO crapprm(nmsistem
                              ,cdcooper
                              ,cdacesso
                              ,dstexprm
                              ,dsvlrprm)
                        VALUES('CRED'
                              ,vr_cdcooper
                              ,wchave
                              ,'Parametros Transferencia Prejuizo'
                              ,wparam);
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           pr_des_erro := 'Erro ao atualizar parametros: '||SQLERRM;
       END;

     IF vr_typ_log.EXISTS(1) THEN -- Se foi inserido algum registro
        -- Gerando Log de Consulta
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => 'OK'
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Inserido Parametrizacao transferencia prejuizo - PARTRP.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> SUCESSO/TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);

     END IF;
     -- Efetivar as informa��es
     COMMIT;

   EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer altera��es
      ROLLBACK;

      pr_dscritic := pr_des_erro;
      -- Retorno n�o OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Parametrizacao Transfer�ncia para preju�zo  - PARTRP.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfazer altera��es
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_grava_prm_partrp: '||SQLERRM;
      pr_dscritic := pr_des_erro;
      pr_nmdcampo := '';
      -- Retorno n�o OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Parametrizacao Transfer�ncia prejuizo- PARTRP.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

   END pc_grava_prm_trp;

   PROCEDURE pc_consulta_prm_trp( pr_dsvlrprm1   IN VARCHAR2  -- Data de inicio da vig�ncia
                                 ,pr_dsvlrprm2   IN VARCHAR2  -- produto
                                 ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                 ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_consulta_prm_trp
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Cal�o - Mout�S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua a consulta dos parametros de transfer�ncia para prejuizo
      Observacao: -----

      Alteracoes:

     ..............................................................................*/
     -- Cursores
     CURSOR cr_crapprm(pr_cdcooper crapprm.cdcooper%TYPE
                      ,pr_cdacesso crapprm.cdacesso%TYPE) IS
       SELECT prm.dsvlrprm, prm.cdacesso
         FROM crapprm prm
        WHERE prm.cdcooper = pr_cdcooper
          AND prm.nmsistem = 'CRED'
          AND prm.cdacesso like pr_cdacesso;

     -- Vari�veis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     vr_dsvlrprm         crapprm.dsvlrprm%TYPE;

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);

     vr_vlprm3      varchar2(4);
     vr_vlprm4      varchar2(4);
     vr_vlprm5      varchar2(4);
     vr_vlprm6      varchar2(4);
     vr_vlprm7      varchar2(4);
     vr_vlprm8      varchar2(4);
     vr_vlprm9      varchar2(4);
     vr_vlprm10     varchar2(4);
     vr_vlprm11     varchar2(4);
     vr_vlprm12     varchar2(4);
     vr_vlprm13     varchar2(4);
     vr_vlprm14     varchar2(4);
     vr_vlprm15     varchar2(4);
     vr_vlprm16     varchar2(4);
     vr_vlprm17     varchar2(4);
     vr_vlprm18     varchar2(4);
     vr_vlprm19     varchar2(4);
     vr_vlprm20     varchar2(4);
     vr_vlprm21     varchar2(4);
     vr_vlprm22     varchar2(4);
     vr_vlprm23     varchar2(4);
     vr_vlprm24     varchar2(4);
     vr_vlprm25     varchar2(4);
     vr_vlprm26     varchar2(4);
     vr_vlprm27     varchar2(4);
     vr_vlprm28     varchar2(4);
     vr_vlprm29     varchar2(4);
     vr_vlprm30     varchar2(4);
     vr_vlprm31     varchar2(4);

     -- Excess�es
     vr_exc_erro         EXCEPTION;

     wchave              varchar2(24);
     WDATA               VARCHAR2(10);

   BEGIN

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      if pr_dsvlrprm1 ='00/00/0000'
      or pr_dsvlrprm1 is null then
         wchave := 'PARTRP_%_' ||
                    pr_dsvlrprm2 ;
      else
         wchave := 'PARTRP_' || TO_CHAR(to_date(pr_dsvlrprm1,'dd/mm/yyyy'),'YYYYMMDD') || '_' ||
                    pr_dsvlrprm2 ;
      end if;

        -- Buscar o valor do parametro
        OPEN  cr_crapprm(vr_cdcooper, wchave);
        FETCH cr_crapprm INTO vr_dsvlrprm, wchave;

        -- Se n�o encontrar retorna erro
        IF cr_crapprm%NOTFOUND THEN
           pr_des_erro := 'Nao foram encontrados parametros de prejuizo para o produto: ' || pr_dsvlrprm2;
           close cr_crapprm;
           raise vr_exc_erro;
        END IF;

        -- Fechar o cursor
        CLOSE cr_crapprm;

        WDATA := SUBSTR(WCHAVE,8,8);
        WDATA := SUBSTR(WDATA,7,2) || '/' || SUBSTR(WDATA,5,2) || '/' || SUBSTR(WDATA,1,4);

        vr_vlprm3 := substr(vr_dsvlrprm,1,4);
        vr_vlprm4 := substr(vr_dsvlrprm,6,4);
        vr_vlprm5 := substr(vr_dsvlrprm,11,4);
        vr_vlprm6 := substr(vr_dsvlrprm,16,4);
        vr_vlprm7 := substr(vr_dsvlrprm,21,4);
        vr_vlprm8 := substr(vr_dsvlrprm,26,4);
        vr_vlprm9 := substr(vr_dsvlrprm,31,4);
        vr_vlprm10:= substr(vr_dsvlrprm,36,4);
        vr_vlprm11:= substr(vr_dsvlrprm,41,4);
        vr_vlprm12:= substr(vr_dsvlrprm,46,4);
        vr_vlprm13:= substr(vr_dsvlrprm,51,4);
        vr_vlprm14:= substr(vr_dsvlrprm,56,4);
        vr_vlprm15:= substr(vr_dsvlrprm,61,4);
        vr_vlprm16:= substr(vr_dsvlrprm,66,4);
        vr_vlprm17:= substr(vr_dsvlrprm,71,4);
        vr_vlprm18:= substr(vr_dsvlrprm,76,4);
        vr_vlprm19:= substr(vr_dsvlrprm,81,4);
        vr_vlprm20:= substr(vr_dsvlrprm,86,4);
        vr_vlprm21:= substr(vr_dsvlrprm,91,4);
        vr_vlprm22:= substr(vr_dsvlrprm,96,4);
        vr_vlprm23:= substr(vr_dsvlrprm,101,4);
        vr_vlprm24:= substr(vr_dsvlrprm,106,4);
        vr_vlprm25:= substr(vr_dsvlrprm,111,4);
        vr_vlprm26:= substr(vr_dsvlrprm,116,4);
        vr_vlprm27:= substr(vr_dsvlrprm,121,4);
        vr_vlprm28:= substr(vr_dsvlrprm,126,4);
        vr_vlprm29:= substr(vr_dsvlrprm,131,4);
        vr_vlprm30:= substr(vr_dsvlrprm,136,4);
        vr_vlprm31:= substr(vr_dsvlrprm,141,4);

        -- Retorno XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root>' ||
                                     '<dsvlrprm1>' ||WDATA ||'</dsvlrprm1>' ||
                                     '<dsvlrprm2>' ||pr_dsvlrprm2 ||'</dsvlrprm2>' ||
                                     '<dsvlrprm3>' ||vr_vlprm3 ||'</dsvlrprm3>' ||
                                     '<dsvlrprm4>' ||vr_vlprm4 ||'</dsvlrprm4>' ||
                                     '<dsvlrprm5>' ||vr_vlprm5 ||'</dsvlrprm5>' ||
                                     '<dsvlrprm6>' ||vr_vlprm6 ||'</dsvlrprm6>' ||
                                     '<dsvlrprm7>' ||vr_vlprm7 ||'</dsvlrprm7>' ||
                                     '<dsvlrprm8>' ||vr_vlprm8 ||'</dsvlrprm8>' ||
                                     '<dsvlrprm9>' ||vr_vlprm9 ||'</dsvlrprm9>' ||
                                     '<dsvlrprm10>'||vr_vlprm10 ||'</dsvlrprm10>' ||
                                     '<dsvlrprm11>'||vr_vlprm11 ||'</dsvlrprm11>' ||
                                     '<dsvlrprm12>'||vr_vlprm12 ||'</dsvlrprm12>' ||
                                     '<dsvlrprm13>'||vr_vlprm13 ||'</dsvlrprm13>' ||
                                     '<dsvlrprm14>'||vr_vlprm14 ||'</dsvlrprm14>' ||
                                     '<dsvlrprm15>'||vr_vlprm15 ||'</dsvlrprm15>' ||
                                     '<dsvlrprm16>'||vr_vlprm16 ||'</dsvlrprm16>' ||
                                     '<dsvlrprm17>'||vr_vlprm17 ||'</dsvlrprm17>' ||
                                     '<dsvlrprm18>'||vr_vlprm18 ||'</dsvlrprm18>' ||
                                     '<dsvlrprm19>'||vr_vlprm19 ||'</dsvlrprm19>' ||
                                     '<dsvlrprm20>'||vr_vlprm20 ||'</dsvlrprm20>' ||
                                     '<dsvlrprm21>'||vr_vlprm21 ||'</dsvlrprm21>' ||
                                     '<dsvlrprm22>'||vr_vlprm22 ||'</dsvlrprm22>' ||
                                     '<dsvlrprm23>'||vr_vlprm23 ||'</dsvlrprm23>' ||
                                     '<dsvlrprm24>'||vr_vlprm24 ||'</dsvlrprm24>' ||
                                     '<dsvlrprm25>'||vr_vlprm25 ||'</dsvlrprm25>' ||
                                     '<dsvlrprm26>'||vr_vlprm26 ||'</dsvlrprm26>' ||
                                     '<dsvlrprm27>'||vr_vlprm27 ||'</dsvlrprm27>' ||
                                     '<dsvlrprm28>'||vr_vlprm28 ||'</dsvlrprm28>' ||
                                     '<dsvlrprm29>'||vr_vlprm29 ||'</dsvlrprm29>' ||
                                     '<dsvlrprm30>'||vr_vlprm30 ||'</dsvlrprm30>' ||
                                     '<dsvlrprm31>'||vr_vlprm31 ||'</dsvlrprm31>' ||
                                     '</Root>');

      vr_dstransa := 'Buscando Parametrizacao transferencia prejuizo - PARTRP.' || wchave || ':' ||
                     vr_vlprm3 || ';' || vr_vlprm4 ||';'||vr_vlprm23 || ';' || vr_vlprm24 || ';' ||
                     vr_vlprm25|| ';' || vr_vlprm26 || ';' || vr_vlprm27|| ';' || vr_vlprm28 || ';' ||
                     vr_vlprm29|| ';' || vr_vlprm30|| ';' || vr_vlprm31;
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer altera��es
       ROLLBACK;
       pr_dscritic := pr_des_erro;
       -- Retorno n�o OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'Parametrizacao transferencia prejuizo - PARTRP.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => 0
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
       -- Desfazer altera��es
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_consulta_prm_trp: '|| SQLERRM;
       pr_dscritic := pr_des_erro;
       pr_cdcritic := 0;
       pr_nmdcampo := '';
       -- Retorno n�o OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'Parametrizacao transferencia prejuizo - PARTRP.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => 0
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_consulta_prm_trp;

   Procedure pc_bloqueio_conta_corrente(pr_cdcooper in number
                                       , pr_nrdconta in number
                                       , pr_cdorigem in number -- 1 - Conta ; 2 - Emprestimos
                                       , pr_dscritic out varchar2) is
     vr_erro exception;
    begin
      pr_dscritic := 'OK';
      -- Bloqueio cartao magnetico
      BEGIN
        UPDATE CRAPCRM
        SET    CRAPCRM.CDSITCAR = 4 -- Bloqueado
        ,      CRAPCRM.DTCANCEL = rw_crapdat.Dtmvtolt
        ,      crapcrm.dttransa = trunc(sysdate)
        WHERE  CRAPCRM.CDCOOPER = PR_CDCOOPER
        AND    CRAPCRM.NRDCONTA = PR_NRDCONTA
        AND    CRAPCRM.CDSITCAR NOT IN (3,4);
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar cartao magnetico: ' || sqlerrm;
          raise vr_erro;

      END;

     /* -- Bloqueio cartao credito
      BEGIN
        UPDATE CRAWCRD
        SET    CRAWCRD.INSITCRD = 6 -- Encerrado
        ,      CRAWCRD.Dtcancel = rw_crapdat.Dtmvtolt
        WHERE  CRAWCRD.CDCOOPER = PR_CDCOOPER
        AND    CRAWCRD.NRDCONTA = PR_NRDCONTA
        AND    CRAWCRD.INSITCRD NOT IN (5,6);
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar cartao credito: ' || sqlerrm;
          raise vr_erro;

      END;*/

      -- Bloqueio senha internet
      BEGIN
        UPDATE CRAPSNH
        SET    CRAPSNH.CDSITSNH = 2 -- Bloqueado
        ,      CRAPSNH.dtblutsh = rw_crapdat.Dtmvtolt
        ,      crapsnh.dtaltsit = rw_crapdat.Dtmvtolt
        WHERE  CRAPSNH.CDCOOPER = PR_CDCOOPER
        AND    CRAPSNH.NRDCONTA = PR_NRDCONTA
        AND    CRAPSNH.CDSITSNH = 1 -- Ativa
        and    crapsnh.tpdsenha = 1 -- Internet
        and    crapsnh.idseqttl = 1; -- primeiro titular
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar senha internet: ' || sqlerrm;
          raise vr_erro;

      END;
      -- Solicitado pela Fernanda por e-mail dia 28/03/2018
/*      -- Cancelamento Limite de Cr�dito
      BEGIN
        UPDATE CRAPLIM
        SET    CRAPLIM.INSITLIM = 3 -- Cancelado
        ,      CRAPLIM.DTFIMVIG = rw_crapdat.Dtmvtolt
        WHERE  CRAPLIM.CDCOOPER = PR_CDCOOPER
        AND    CRAPLIM.NRDCONTA = PR_NRDCONTA
        AND    CRAPLIM.INSITLIM = 2; -- Ativa;

      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar LIMITE: ' || sqlerrm;
          raise vr_erro;

      END;*/

      BEGIN
        UPDATE CRAPMCR
        SET    CRAPMCR.DTCANCEL = rw_crapdat.Dtmvtolt
        WHERE  CRAPMCR.CDCOOPER = PR_CDCOOPER
        AND    CRAPMCR.NRDCONTA = PR_NRDCONTA
        AND    CRAPMCR.TPCTRMIF = 2;

      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar LIMITE: ' || sqlerrm;
          raise vr_erro;

      END;

      /* BEGIN
        UPDATE CRAPASS
        SET    CRAPASS.VLLIMCRE = 0
        WHERE  CRAPASS.CDCOOPER = PR_CDCOOPER
        AND    CRAPASS.NRDCONTA = PR_NRDCONTA;

      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao atualizar Conta: ' || sqlerrm;
          raise vr_erro;

      END;*/
    exception
      when vr_erro then
           pr_dscritic := 'erro na rotina de bloqueio de contas';

    end pc_bloqueio_conta_corrente;

   Procedure pc_reabrir_conta_corrente(pr_cdcooper in number
                                       , pr_nrdconta in number
                                       , pr_cdorigem in number -- 1 - Conta ; 2 - Emprestimos
                                       , pr_dtprejuz in date
                                       , pr_dscritic out varchar2) is
     vr_erro     exception;
     vr_vllimite number;

     cursor c_busca_limite(pr_cdcooper number
                          ,pr_nrdconta number
                          ,pr_dtmvtolt date) is
        select vllimite
        from   craplim
        where  cdcooper = pr_cdcooper
        and    nrdconta = pr_nrdconta
        and    INSITLIM = 3
        and    dtfimvig >= trunc(pr_dtmvtolt, 'MM')
        and    dtfimvig <= pr_dtmvtolt;

    begin
      pr_dscritic := 'OK';
      -- Desbloqueio cartao magnetico
      BEGIN
        UPDATE CRAPCRM
        SET    CRAPCRM.CDSITCAR = 2 -- Ativo
        ,      CRAPCRM.DTCANCEL = null
        ,      crapcrm.dttransa = pr_dtprejuz
        WHERE  CRAPCRM.CDCOOPER = PR_CDCOOPER
        AND    CRAPCRM.NRDCONTA = PR_NRDCONTA
        AND    CRAPCRM.CDSITCAR = 4; -- bloequeado
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao desbloquear cartao magnetico: ' || sqlerrm;
          raise vr_erro;

      END;

      -- desbloqueio senha internet
      BEGIN
        UPDATE CRAPSNH
        SET    CRAPSNH.CDSITSNH = 1 -- Ativa
        ,      CRAPSNH.Dtblutsh = null
        ,      crapsnh.dtaltsnh = pr_dtprejuz
        WHERE  CRAPSNH.CDCOOPER = PR_CDCOOPER
        AND    CRAPSNH.NRDCONTA = PR_NRDCONTA
        AND    CRAPSNH.CDSITSNH = 2 -- Cancelada
        and    crapsnh.tpdsenha = 1 -- Internet
        and    crapsnh.idseqttl = 1; -- primeiro titular
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao reativar senha internet: ' || sqlerrm;
          raise vr_erro;

      END;
       -- Solicitado pela Fernanda por e-mail dia 28/03/2018
     /* open c_busca_limite(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dtmvtolt => pr_dtprejuz);
      fetch c_busca_limite into vr_vllimite;
      close c_busca_limite;

      -- Cancelamento Limite de Cr�dito
      BEGIN
        UPDATE CRAPLIM
        SET    CRAPLIM.INSITLIM = 2 -- Ativo
        ,      CRAPLIM.DTFIMVIG = null
        ,      craplim.dtcancel = null
        ,      craplim.dtrefatu = pr_dtprejuz
        ,      craplim.vllimite = craplim.vllimite
        WHERE  CRAPLIM.CDCOOPER = PR_CDCOOPER
        AND    CRAPLIM.NRDCONTA = PR_NRDCONTA
        AND    CRAPLIM.INSITLIM = 3 -- Cancelado;
        and    craplim.dtfimvig = pr_dtprejuz
        and    craplim.dtfimvig >= trunc(pr_dtprejuz, 'MM');

      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao desbloquear LIMITE: ' || sqlerrm;
          raise vr_erro;

      END;*/

     /* begin
        update crapass
        set    vllimcre = vr_vllimite
        where  cdcooper = pr_cdcooper
        and    nrdconta = pr_nrdconta;
      exception
        when others then
          pr_dscritic := 'Erro ao atualizar LIMITE na conta: ' || sqlerrm;
          raise vr_erro;
      end;*/


    exception
      when vr_erro then
           pr_dscritic := 'erro na rotina de bloqueio de contas';

    end pc_reabrir_conta_corrente;

  PROCEDURE pc_transfere_epr_prejuizo_PP(pr_cdcooper in number
                                      ,pr_cdagenci in number
                                      ,pr_nrdcaixa in number
                                      ,pr_cdoperad in varchar2
                                      ,pr_nrdconta in number
                                      ,pr_idseqttl in number
                                      ,pr_dtmvtolt in date
                                      ,pr_nrctremp in number
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro  ) is
    /* .............................................................................

    Programa: pc_transfere_epr_prejuizo_PP
    Sistema : AyllosWeb / Rotina PC_CRPS780
    Sigla   : PREJ
    Autor   : Jean Cal�o - Mout�S
    Data    : Maio/2017.                  Ultima atualizacao: 22/01/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de contratos PP para preju�zo
    Observacao: Rotina chamada pela tela Atenda ou rotina automatica.

    Alteracoes: Identa��o do c�digo e ajustes conforme SM 6 Melhoria 324
               (Rafael Monteiro - Mout'S)

    ..............................................................................*/
    --
    CURSOR c_crappep IS
      SELECT crappep.cdcooper
            ,crappep.nrdconta
            ,crappep.nrctremp
            ,crawepr.dtlibera
            ,crawepr.tpemprst
        FROM crappep,
             crawepr
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.inliquid = 0
         AND crappep.inprejuz = 0;

    rw_crappep c_crappep%ROWTYPE;
    --
    CURSOR c_crapris (pr_cdcooper craplem.cdcooper%TYPE
                     ,pr_nrdconta craplem.nrdconta%TYPE
                     ,pr_nrctremp craplem.nrctremp%TYPE) IS

      SELECT nvl(qtdiaatr,0) + 1
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
         AND ris.dtrefere = rw_crapdat.dtmvtoan;
    --
    CURSOR cr_craplem_60 (pr_qtdiaatr IN NUMBER) IS
      SELECT NVL(SUM(lem.vllanmto),0)
        FROM craplem lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrctremp = pr_nrctremp
         AND lem.cdhistor IN (1037,1038)
         AND lem.dtmvtolt > rw_crapdat.dtmvtolt - (pr_qtdiaatr - 59);
    --
    CURSOR c_crapepr_saldo is
      SELECT vlsdeved
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;

    --Selecionar Lancamentos


    vr_vlttmupr        crapepr.vlttmupr%TYPE;
    vr_vlttjmpr        crapepr.vlttjmpr%TYPE;
    vr_vlsdeved        crapepr.vlsdeved%TYPE;
    vr_vlajsdvd        NUMBER;
    vr_vlajslan        NUMBER;
    vr_cdhistor        craplem.cdhistor%TYPE;
    vr_flgcredi        BOOLEAN;
    vr_saldo_extrato   NUMBER;
    vr_nrdolote        craplem.nrdolote%TYPE;
    vr_cdhistor1       craplem.cdhistor%TYPE;
    vr_cdhistor2       craplem.cdhistor%TYPE;
    vr_cdhistor3       craplem.cdhistor%TYPE;
    vr_cdhistor4       craplem.cdhistor%TYPE;
    vr_flgtrans        BOOLEAN;
    vr_dstransa        VARCHAR2(500);
    vr_dtcalcul        DATE;
    vr_ehmensal        BOOLEAN;
    vr_qtdiaris        INTEGER;
    vr_vljurmes        NUMBER;
    vr_diarefju        INTEGER;
    vr_mesrefju        INTEGER;
    vr_anorefju        INTEGER;
    vr_tab_crawepr     empr0001.typ_tab_crawepr;
    vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
    vr_tab_calculado   empr0001.typ_tab_calculado;
    vr_nrdrowid        ROWID;
    vr_exc_erro        EXCEPTION;
    vr_index_crawepr   VARCHAR2(30);
    vr_qtdiaatr        crapris.qtdiaatr%TYPE;
    vr_vljura60        crapris.vljura60%TYPE;

    vr_dsvlrgar VARCHAR2(32000) := '';
    vr_tipsplit gene0002.typ_split;
    vr_nmrescop crapcop.nmrescop%TYPE;

  --
  BEGIN
    -- Inicializar variaveis
    vr_flgtrans := FALSE;
    pr_des_reto := 'OK';
    vr_cdcritic := NULL;
    vr_dscritic := NULL;
    vr_flgativo := 0;

    /* Busca data de movimento */
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    FOR rw_crapcop IN cr_crapcop(pr_cdcooper) LOOP
     vr_nmrescop := rw_crapcop.nmrescop;
    END LOOP;

    vr_dsvlrgar := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdcooper => 0,pr_cdacesso => 'BLOQ_AUTO_PREJ');
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';');

    /*FOR i IN vr_tipsplit.first..vr_tipsplit.last LOOP
      IF pr_cdcooper = vr_tipsplit(i) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'N�o permitido realizar transfer�ncia para a cooperativa '||vr_nmrescop;
        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      END IF;
    END LOOP;*/

     /* Verificacao de contrato de acordo */
     -- Comentado apos solicitacao SM 6
     /* RECP0001.pc_verifica_acordo_ativo (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_cdorigem => 0
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic > 0
        OR vr_dscritic is not null THEN
           pr_des_reto := 'NOK';
           raise vr_exc_erro;
        END IF;

        IF vr_flgativo = 1 THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Transferencia para prejuizo nao permitida, emprestimo em acordo.';
         --  pr_tab_erro(PR_TAB_ERRO.FIRST).dscritic := VR_DSCRITIC;
           pr_des_reto := 'NOK';
           raise vr_exc_erro;
        END IF;*/

    /* Verificar se possui acordo na CRAPCYC com motivo igual a 2 e VIP */
    OPEN c_crapcyc(pr_cdcooper,
                   pr_nrdconta,
                   pr_nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    CLOSE c_crapcyc;

    IF nvl(vr_flgativo,0) = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, acordo possui motivo 2 -Determina��o Judicial � Preju�zo N�o';
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;

    OPEN c_crapepr(pr_cdcooper
                  ,pr_nrdconta
                  ,pr_nrctremp);
    FETCH c_crapepr INTO r_crapepr;

    IF c_crapepr%FOUND THEN
      IF r_crapepr.inprejuz = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato ja esta em prejuizo!';
        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      ELSE



        /* Tratamento Juros */
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => LAST_DAY(rw_crapdat.dtmvtolt)
                                                  ,pr_tipo => 'A'
                                                  ,pr_feriado => true
                                                  ,pr_excultdia => true );
        IF rw_crapdat.dtmvtolt > vr_dtcalcul THEN
          vr_ehmensal := TRUE;
        ELSE
          vr_ehmensal := FALSE;
        END IF;

        vr_tab_crawepr.DELETE;
        -- monta tabela de Contas e parcelas
        FOR rw_crappep in c_crappep LOOP
          vr_index_crawepr := lpad(rw_crappep.cdcooper,10,'0')||
                                   lpad(rw_crappep.nrdconta,10,'0')||
                                   lpad(rw_crappep.nrctremp,10,'0');
          vr_tab_crawepr(vr_index_crawepr).dtlibera:= rw_crappep.dtlibera;
          vr_tab_crawepr(vr_index_crawepr).tpemprst:= rw_crappep.tpemprst;
        END LOOP;

        empr0001.pc_lanca_juro_contrato(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_cdpactra => 0 -- pr_cdagencia
                                       ,pr_flnormal => true
                                       ,pr_dtvencto => rw_crapdat.dtmvtolt
                                       ,pr_ehmensal => vr_ehmensal
                                       ,pr_dtdpagto => R_crapepr.dtdpagto --rw_crapdat.dtmvtolt --crapepr.dtdpagto
                                       ,pr_tab_crawepr => vr_tab_crawepr
                                       ,pr_cdorigem => 7 -- 7 - Batch
                                       ,pr_vljurmes => vr_vljurmes
                                       ,pr_diarefju => vr_diarefju
                                       ,pr_mesrefju => vr_mesrefju
                                       ,pr_anorefju => vr_anorefju
                                       ,pr_des_reto => pr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);

        IF pr_des_reto = 'NOK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'N�o foi possivel executar lancamento de juros no processo de prejuizo.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        IF vr_vljurmes > 0   THEN
          BEGIN
            UPDATE crapepr
               SET crapepr.diarefju = vr_diarefju
                  ,crapepr.mesrefju = vr_mesrefju
                  ,crapepr.anorefju = vr_anorefju
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar CRAPEPR(1)';
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
           END;
         END IF;

         BEGIN
           UPDATE crapepr
              SET crapepr.vlsdeved = crapepr.vlsdeved + vr_vljurmes
                 ,crapepr.vljuracu = crapepr.vljuracu + vr_vljurmes
                 ,crapepr.vljurmes = crapepr.vljurmes + vr_vljurmes
                 ,crapepr.vljuratu = crapepr.vljuratu + vr_vljurmes
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND nrctremp = pr_nrctremp;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar CRAPEPR(2)';
             pr_des_reto := 'NOK';
             RAISE vr_exc_erro;
         END;

       /*  OPEN  c_crapepr_saldo;
         FETCH c_crapepr_saldo into vr_vlsdeved;
         CLOSE c_crapepr_saldo;*/
        -- Ajustar o saldo do emprestimo

        empr0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => 'CRPS780'
                                        ,pr_idorigem => 7 -- Batch
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_flgerlog => 'S'
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                        ,pr_nrparepr => 0 -- Todas
                                        ,pr_des_reto => pr_des_reto
                                        ,pr_tab_erro => vr_tab_erro
                                        ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                        ,pr_tab_calculado => vr_tab_calculado);

        IF pr_des_reto <> 'OK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'N�o foi possivel Buscar Dados Parcelas.';
          END IF;

          RAISE vr_exc_erro;
        END IF;

        vr_vlttmupr := 0;
        vr_vlttjmpr := 0;
        vr_index    := vr_tab_pgto_parcel.FIRST;
        vr_index_calculado := vr_tab_calculado.FIRST;

        IF vr_index IS NOT NULL THEN
          FOR idx IN vr_tab_pgto_parcel.first..vr_tab_pgto_parcel.last LOOP
            IF vr_tab_pgto_parcel(idx).inliquid = 0 THEN
              vr_vlttmupr := vr_vlttmupr + vr_tab_pgto_parcel(idx).vlmtapar;
              vr_vlttjmpr := vr_vlttjmpr + vr_tab_pgto_parcel(idx).vlmrapar;
            END IF;

          END LOOP;
        END IF;

        /* Procedure para obter dados de emprestimos do associado */
/*        empr0001.pc_obtem_dados_empresti
                               (pr_cdcooper       => pr_cdcooper           --> Cooperativa conectada
                               ,pr_cdagenci       => pr_cdagenci           --> C�digo da ag�ncia
                               ,pr_nrdcaixa       => pr_nrdcaixa           --> N�mero do caixa
                               ,pr_cdoperad       => pr_cdoperad           --> C�digo do operador
                               ,pr_nmdatela       => 'CRPS780'             --> Nome datela conectada
                               ,pr_idorigem       => 7                     --> Indicador da origem da chamada
                               ,pr_nrdconta       => pr_nrdconta           --> Conta do associado
                               ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                               ,pr_rw_crapdat     => rw_crapdat            --> Vetor com dados de par�metro (CRAPDAT)
                               ,pr_dtcalcul       => null                  --> Data solicitada do calculo
                               ,pr_nrctremp       => nvl(pr_nrctremp,0)    --> N�mero contrato empr�stimo
                               ,pr_cdprogra       => 'CRPS780'             --> Programa conectado
                               ,pr_inusatab       => FALSE                 --> Indicador de utiliza��o da tabela
                               ,pr_flgerlog       => 'S'                    --> Gerar log S/N
                               ,pr_flgcondc       => (CASE 1                --> Mostrar emprestimos liquidados sem prejuizo
                                                        WHEN 1 THEN TRUE
                                                        ELSE FALSE END)
                               ,pr_nmprimtl       => ''                    --> Nome Primeiro Titular
                               ,pr_tab_parempctl  => ''                    --> Dados tabela parametro
                               ,pr_tab_digitaliza => ''                    --> Dados tabela parametro
                               ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                               ,pr_nrregist       => 0                     --> Numero de registros por pagina
                               ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                               ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empr�stimo
                               ,pr_des_reto       => pr_des_reto           --> Retorno OK / NOK
                               ,pr_tab_erro       => vr_tab_erro);         --> Tabela com poss�ves erros

        IF pr_des_reto = 'NOK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'N�o foi possivel obter dados de emprestimos.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
        --
        vr_index := vr_tab_dados_epr.first;
        --vr_vlsdeved := 0;
        WHILE vr_index IS NOT NULL LOOP
          vr_vlsdeved := vr_tab_dados_epr(vr_index).vlsdeved;
          \* vr_vlsdeved := vr_tab_dados_epr(vr_index).vlmtapar;
          vr_vlsdeved := vr_tab_dados_epr(vr_index).vlmrapar;
          vr_vlsdeved := (nvl(vr_tab_dados_epr(vr_index).vlsdeved,0) +
                          nvl(vr_tab_dados_epr(vr_index).vlmtapar,0) +
                          nvl(vr_tab_dados_epr(vr_index).vlmrapar,0));*\
          --vr_txjurepr := vr_tab_dados_epr(vr_index).txjuremp ;
          --vr_vlpreemp := vr_tab_dados_epr(vr_index).vlpreemp ;
          --vr_vlttmupr := vr_tab_dados_epr(vr_index).vlttmupr ;
          --vr_vlttjmpr := vr_tab_dados_epr(vr_index).vlttjmpr ;
          --R_crapepr.cdlcremp := vr_tab_dados_epr(vr_index).cdlcremp ;
          -- buscar proximo
          vr_index := vr_tab_dados_epr.next(vr_index);
        END LOOP;      */

        rati0001.pc_desativa_rating(pr_cdcooper => pr_cdcooper
                                  , pr_cdagenci => 0
                                  , pr_nrdcaixa => 0
                                  , pr_cdoperad => pr_cdoperad
                                  , pr_rw_crapdat => rw_crapdat
                                  , pr_nrdconta => pr_nrdconta
                                  , pr_tpctrrat => 90
                                  , pr_nrctrrat => pr_nrctremp
                                  , pr_flgefeti => 'S'
                                  , pr_idseqttl => 1
                                  ,pr_idorigem => 7 -- batch
                                  ,pr_inusatab => false
                                  ,pr_nmdatela => 'CRPS780'
                                  ,pr_flgerlog => 'S'
                                  ,pr_des_reto => pr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);

        IF pr_des_reto <> 'OK' THEN

          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'N�o foi possivel desativar rating.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        OPEN c_craplcr(pr_cdcooper);
        FETCH c_craplcr into r_craplcr;

        IF c_craplcr%NOTFOUND THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Linha de Credito nao Cadastrada!';
          pr_des_reto := 'NOK';
          raise vr_exc_erro;
        END IF;

        CLOSE c_craplcr;

        IF vr_tab_calculado(vr_index_calculado).vlsdeved = 0
        OR vr_tab_calculado.count = 0  THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao buscar saldos do contrato.';
          pr_des_reto := 'NOK';
          RAISE vr_exc_erro;
        ELSE
          OPEN  c_crapris(pr_cdcooper, pr_nrdconta, pr_nrctremp);
          FETCH c_crapris into vr_qtdiaatr;
          CLOSE c_crapris;

          IF  nvl(vr_qtdiaatr,0) >= 60  THEN  -- Calcular o valor dos juros a mais de 60 dias
            -- Obter valor de juros a mais de 60 dias
            OPEN cr_craplem_60 (pr_qtdiaatr => vr_qtdiaatr);
            FETCH cr_craplem_60 INTO vr_vljura60;
            CLOSE cr_craplem_60;
          END IF;

          /* open c_crapris(pr_cdcooper
                           ,pr_nrdconta
                           ,pr_nrctremp);
             fetch c_crapris into vr_vljura60;
             close c_crapris;*/
        /* Contabilizar creditos  */
          OPEN EMPR0001.cr_craplem_sld(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp);
          FETCH EMPR0001.cr_craplem_sld
            INTO vr_saldo_extrato;
          --Fechar Cursor
          CLOSE EMPR0001.cr_craplem_sld;
          --
          --FOR rw_craplem IN cr_craplem(pr_cdcooper, pr_nrdconta, pr_nrctremp) LOOP
          vr_saldo_extrato :=  ABS(NVL(vr_saldo_extrato,0));
          --END LOOP;
          -- Saldo de acordo com as parcelas
          vr_vlsdeved := vr_tab_calculado(vr_index_calculado).vlsderel;
          -- calcula a diferenca entre saldo de parcelas com o saldo da EPR
          --vr_vlajsdvd := (vr_vlsdeved - (r_crapepr.vlsdeved + vr_vljurmes));
          vr_vlajsdvd := (vr_vlsdeved - vr_saldo_extrato);

          --Se o saldo devedor for negativo
          IF nvl(vr_vlajsdvd, 0) < 0 THEN
            IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN
              /* Financiamento */
              --Historico
              vr_cdhistor := 1043;
              --Lote
              vr_nrdolote := 600009;
            ELSE
              /* Emprestimo */
              --Historico
              vr_cdhistor := 1041;
              --Lote
              vr_nrdolote := 600007;
            END IF;
            vr_flgcredi := TRUE; /* Credita */
          ELSIF nvl(vr_vlajsdvd, 0) > 0 THEN
            IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN
              /* Financiamento */
              --Historico
              vr_cdhistor := 1042;
              --Lote
              vr_nrdolote := 600008;
            ELSE
              /* Emprestimo */
              --Historico
              vr_cdhistor := 1040;
              --Lote
              vr_nrdolote := 600006;
            END IF;
            vr_flgcredi := FALSE; /* Debita */
          END IF;

          vr_vlajslan := ABS(vr_vlajsdvd);

          IF nvl(vr_vlajslan, 0) <> 0 THEN
            /* Efetuar ajuste */
            /* Cria lancamento e atualiza o lote  */
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                           ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                           ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                           ,pr_cdbccxlt => 100 --Codigo Caixa
                                           ,pr_cdoperad => pr_cdoperad --Operador
                                           ,pr_cdpactra => pr_cdagenci --Posto Atendimento
                                           ,pr_tplotmov => 5 --Tipo movimento
                                           ,pr_nrdolote => vr_nrdolote --Numero Lote
                                           ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                           ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                           ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                           ,pr_vllanmto => vr_vlajslan --Valor Lancamento
                                           ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                           ,pr_txjurepr => 0 --Taxa Juros Emprestimo
                                           ,pr_vlpreemp => 0 --Valor Emprestimo
                                           ,pr_nrsequni => 0 --Numero Sequencia
                                           ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                                           ,pr_flgincre => TRUE --Indicador Credito
                                           ,pr_flgcredi => vr_flgcredi --Credito/Debito
                                           ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                           ,pr_cdorigem => 7 -- Origem do Lan�amento
                                           ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                           ,pr_dscritic => vr_dscritic); --Descricao Erro
            --Se ocorreu err o
            IF vr_cdcritic IS NOT NULL
            OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;

          IF nvl(vr_vljura60,0) > 0 THEN
            vr_vlsdeved := vr_vlsdeved - vr_vljura60;
            --vr_tab_calculado(1).vlsderel := vr_tab_calculado(1).vlsderel - vr_vljura60;
          END IF;

          BEGIN
            UPDATE CRAPEPR
               SET  crapepr.vlprejuz  = vr_vlsdeved + nvl(vr_vljura60,0) --vr_tab_calculado(1).vlsderel + nvl(vr_vljura60,0)
                    ,crapepr.vlsdprej = vr_vlsdeved + nvl(vr_vljura60,0) --vr_tab_calculado(1).vlsderel + nvl(vr_vljura60,0)
                    ,crapepr.inprejuz = 1 /* Em prejuizo */
                    ,crapepr.inliquid = 1 /* Liquidado   */
                    ,crapepr.dtprejuz = rw_crapdat.dtmvtolt
                    ,crapepr.vlttmupr = vr_vlttmupr          /* Multa das Parcelas */
                    ,crapepr.vlttjmpr = vr_vlttjmpr          /* Juros de Mora das Parcelas */
                    ,crapepr.vlpgmupr = 0
                    ,crapepr.vlpgjmpr = 0
                    ,crapepr.vlsdeved = 0
                    ,crapepr.vlsdevat = 0
               WHERE crapepr.cdcooper = pr_cdcooper
                 AND   crapepr.nrdconta = pr_nrdconta
                 AND   crapepr.nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao ATUALIZAR tabela de emprestimos (CRAPEPR): ' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
          END;
          --
          -- Ataulizar tabela CRAPCYB
/*           BEGIN
            UPDATE CRAPCYB C
               SET C.DTPREJUZ = rw_crapdat.dtmvtolt,
                   C.VLSDPREJ = vr_vlsdeved + nvl(vr_vljura60,0), -- vr_tab_calculado(1).vlsderel + nvl(vr_vljura60,0),
                   C.FLGPREJU = 1
             WHERE C.CDCOOPER = pr_cdcooper
               AND C.CDORIGEM = 3
               AND C.NRDCONTA = pr_nrdconta
               AND C.NRCTREMP = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a crapcyb prejuizo TR '||sqlerrm;
              pr_des_reto := 'NOK';
              RAISE  vr_exc_erro;
          END;*/

          IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN /* Financiamento */
              vr_cdhistor1 := 2396;  /* 2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO */
              if vr_idfraude then
                 vr_cdhistor1 := 2400; /* 2400 - TRANSFERENCIA EMPRESTIMO SUSPEITA DE FRAUDE */
              end if;
              vr_cdhistor2 := 2411;  /* 2411 - MULTAS DE MORA SOBRE PREJUIZO */
              vr_cdhistor3 := 2397;  /* 2397 - REVERSAO JUROS +60 PP P/ PREJUIZO */
              vr_cdhistor4 := 2415;  /* 2415 - JUROS MORA SOBRE PREJUIZO */
          ELSE /* Emprestimo */
            vr_cdhistor1 := 2381;  /* 2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO */
            IF vr_idfraude THEN
              vr_cdhistor1 := 2385; /* 2385 - TRANSFERENCIA EMPRESTIMO PP SUSPEITA DE FRAUDE */
            END IF;
              vr_cdhistor2 := 2411;  /* 2411 - MULTAS DE MORA SOBRE PREJUIZO */
              vr_cdhistor3 := 2382;  /* 2382 - REVERSAO JUROS +60 PP P/ PREJUIZO */
              vr_cdhistor4 := 2415;  /* 2415 - JUROS MORA SOBRE PREJUIZO */
          END IF;

        END IF;

        -- teste de verificacao lancamento LEM
        vr_dstransa := 'Acessando grava��o da LEM, contrato: ' ||
                       pr_nrctremp || ' - Saldo: ' || vr_tab_calculado(1).vlsderel;

        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => null
                            ,pr_dsorigem => 'AYLLOS'
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => trunc(sysdate)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CRPS780'
                            ,pr_nrdconta => PR_NRDCONTA
                            ,pr_nrdrowid => VR_NRDROWID);




        IF vr_vlsdeved > 0 THEN --vr_tab_calculado(1).vlsderel > 0 then
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor1
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vlsdeved --vr_tab_calculado(1).vlsderel
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;

        IF vr_vlttmupr > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor2
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vlttmupr
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM (valor multa): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --
        IF nvl(vr_vljura60,0) > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor3
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljura60
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM (valor juros): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --
        IF vr_vlttjmpr > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor4
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vlttjmpr
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM (valor juros): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --
        /* liquidar parcelas CRAPPEP */
        BEGIN
          UPDATE CRAPPEP
             SET inliquid = 1
                ,inprejuz = 1
           WHERE crappep.cdcooper = pr_cdcooper
             AND crappep.nrdconta = pr_nrdconta
             AND crappep.nrctremp = pr_nrctremp
             AND crappep.inliquid = 0;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao ATUALIZAR tabela de Parcelas de Emprestimos (CRAPPEP): ' || SQLERRM;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
        END;

        vr_dstransa := 'Data: ' || to_char( rw_crapdat.dtmvtolt,'DD/MM/YYYY') ||
                       ' - Transferencia para prejuizo - ' ||
                       ', Conta:  ' || pr_nrdconta ||
                       ', Contrato: ' || pr_nrctremp;
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => null
                            ,pr_dsorigem => 'AYLLOS'
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => trunc(sysdate)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CRPS780'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        --vr_flgtrans := TRUE;

      END IF;

    ELSE

      vr_cdcritic := 0;
      vr_dscritic := 'Falha ao gerar o emprestimo para prejuizo. ' || sqlerrm;
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;

    IF c_crapepr%ISOPEN THEN
      CLOSE c_crapepr;
    END IF;

    -- Bloqueios da conta corrente
    pc_bloqueio_conta_corrente(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdorigem => 2 -- emprestimos
                              ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro no bloqueio da CC';
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;

    /*IF NOT vr_flgtrans THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Processo n�o foi concluido.';
      pr_tab_erro(PR_TAB_ERRO.FIRST).dscritic := vr_dscritic;
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;*/

  EXCEPTION
    WHEN vr_exc_erro then
      -- desfazer altera��es
      ROLLBACK;
      --
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      --
      pr_des_reto := 'NOK';
      -- fechar cursor principal
      IF c_crapepr%ISOPEN THEN
        CLOSE c_crapepr;
      END IF;

    WHEN OTHERS THEN
      -- desfazer altera��es
      ROLLBACK;
      -- fechar cursor principal
      IF c_crapepr%ISOPEN THEN
        CLOSE c_crapepr;
      END IF;

      vr_cdcritic := 0;
      vr_dscritic := 'Falha rotina PREJ0001.pc_transfere_epr_prejuizo_PP - '||SQLERRM;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';
  END pc_transfere_epr_prejuizo_PP;
--
  PROCEDURE pc_transfere_epr_prejuizo_TR(pr_cdcooper IN NUMBER
                                        ,pr_cdagenci IN NUMBER
                                        ,pr_nrdcaixa IN NUMBER
                                        ,pr_cdoperad IN VARCHAR2
                                        ,pr_nrdconta IN NUMBER
                                        ,pr_dtmvtolt IN DATE
                                        ,pr_nrctremp IN NUMBER
                                        ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro  ) is

   /* .............................................................................

    Programa: pc_transfere_epr_prejuizo_TR
    Sistema : AyllosWeb / Rotina PC_CRPS780
    Sigla   : PREJ
    Autor   : Jean Cal�o - Mout�S
    Data    : Maio/2017.                  Ultima atualizacao: 22/01/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de contratos TR para preju�zo
    Observacao: Rotina chamada pela tela Atenda ou rotina automatica.

    Alteracoes: 27/01/2017 - Identa��o do c�digo e ajustes conforme SM 6 M324
               (Rafael Monteiro - Mout'S)

   ..............................................................................*/
    --
    CURSOR c_busca_prx_lote(pr_cdhistor number) is
      SELECT MAX(nrdolote) nrdolote
        FROM craplot
       WHERE craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdcooper = pr_cdcooper
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = 200
         AND craplot.tplotmov = 5
         AND craplot.cdhistor = pr_cdhistor;
    --
    CURSOR c_busca_boleto IS
      SELECT tbrecup_cobranca.cdcooper
            ,tbrecup_cobranca.nrdconta_cob
            ,tbrecup_cobranca.nrcnvcob
            ,tbrecup_cobranca.nrboleto
            ,tbrecup_cobranca.nrctremp
            ,crapcob.incobran
            ,crapcob.dtvencto
            ,crapcob.vltitulo
            ,crapcob.dtdpagto
            ,crapcob.nrdocmto
       FROM tbrecup_cobranca, crapcob
      WHERE tbrecup_cobranca.cdcooper = pr_cdcooper
        AND tbrecup_cobranca.nrdconta = pr_nrdconta
        AND tbrecup_cobranca.nrctremp = pr_nrctremp
        AND crapcob.cdcooper = tbrecup_cobranca.cdcooper
        AND crapcob.nrdconta = tbrecup_cobranca.nrdconta_cob
        AND crapcob.nrcnvcob = tbrecup_cobranca.nrcnvcob
        AND crapcob.nrdocmto = tbrecup_cobranca.nrboleto
        AND crapcob.incobran in (0, 5)
       ORDER BY tbrecup_cobranca.nrboleto DESC;
    --
    CURSOR c_busca_retorno_boleto(pr_nrcnvcob NUMBER
                                 ,pr_nrdocmto NUMBER
                                 ,pr_dtdpagto DATE) IS
      SELECT 1
        FROM crapret
       WHERE crapret.cdcooper = pr_cdcooper
         AND crapret.nrdconta = pr_nrdconta
         AND crapret.nrcnvcob = pr_nrcnvcob
         AND crapret.nrdocmto = pr_nrdocmto
         AND crapret.cdocorre = 6     -- pendente de processamento
         AND crapret.dtocorre = pr_dtdpagto
         AND crapret.flcredit = 0;
    r_busca_retorno_boleto c_busca_retorno_boleto%rowtype;
    --
    CURSOR c_crapris (pr_cdcooper craplem.cdcooper%TYPE
                     ,pr_nrdconta craplem.nrdconta%TYPE
                     ,pr_nrctremp craplem.nrctremp%TYPE) IS

      SELECT vljura60
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
         AND ris.dtrefere = rw_crapdat.dtultdma;
    --
    vr_nrdolote      craplot.nrdolote%TYPE;
    vr_qtregist      NUMBER;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_vlsdeved      NUMBER;
    vr_vlttmupr      NUMBER;
    vr_vlttjmpr      NUMBER;
    vr_erro          EXCEPTION;
    vr_dstransa      VARCHAR2(500);
    vr_txjurepr      craplem.txjurepr%TYPE;
    vr_vlpreemp      craplem.vlpreemp%TYPE;
    vr_cdhistor1     NUMBER(4);
    vr_cdhistor2     NUMBER(4);
    vr_cdhistor3     NUMBER(4);
    vr_cdhistor4     NUMBER(4);
    vr_txmensal      crapepr.txmensal%TYPE;
    vr_vljura60      crapris.vljura60%TYPE;
    vr_nrdrowid      ROWID;
    vr_dsvlrgar      VARCHAR2(32000) := '';
    vr_tipsplit      gene0002.typ_split;
    vr_nmrescop      crapcop.nmrescop%TYPE;

  BEGIN
    vr_cdcritic := NULL;
    vr_dscritic := NULL;
    pr_des_reto := 'OK';
    vr_flgativo := 0;

    /* Busca data de movimento */
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    FOR rw_crapcop IN cr_crapcop(pr_cdcooper) LOOP
     vr_nmrescop := rw_crapcop.nmrescop;
    END LOOP;

    vr_dsvlrgar := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdcooper => 0,pr_cdacesso => 'BLOQ_AUTO_PREJ');
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';');

   /* FOR i IN vr_tipsplit.first..vr_tipsplit.last LOOP
      IF pr_cdcooper = vr_tipsplit(i) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'N�o permitido realizar transfer�ncia para a cooperativa '||vr_nmrescop;
        pr_des_reto := 'NOK';
        RAISE vr_erro;
      END IF;
    END LOOP; */

    /* Verifica se existe boleto em aberto ou pago, pendente de processamento, para o contrato */
    FOR r_busca_boleto in c_busca_boleto LOOP
      IF r_busca_boleto.incobran = 0 THEN -- boleto aberto
        vr_cdcritic := 0;
        vr_dscritic := 'Boleto da conta: ' || r_busca_boleto.nrdconta_cob ||
                       ', Contrato: ' || r_busca_boleto.nrctremp ||
                       ', N�mero: ' || r_busca_boleto.nrboleto ||
                       ', Vencto.: ' || to_char(r_busca_boleto.dtvencto,'dd/mm/yyyy') ||
                       ', Valor: ' || to_char(r_busca_boleto.vltitulo,'999g999g999d99') ||
                       '. Est� EM ABERTO!';

        RAISE vr_erro;
      END IF;
      --
      IF r_busca_boleto.incobran = 5 THEN -- boleto pago

          OPEN c_busca_retorno_boleto(r_busca_boleto.nrcnvcob
                                    , r_busca_boleto.nrdocmto
                                    , r_busca_boleto.dtdpagto);
          FETCH c_busca_retorno_boleto
           INTO r_busca_retorno_boleto;
          --
          IF c_busca_retorno_boleto%FOUND THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Boleto da conta: ' || r_busca_boleto.nrdconta_cob ||
                           ', Contrato: ' || r_busca_boleto.nrctremp ||
                           ', N�mero: ' || r_busca_boleto.nrboleto ||
                           ', Vencto.: ' || to_char(r_busca_boleto.dtvencto,'dd/mm/yyyy') ||
                           ', Valor: ' || to_char(r_busca_boleto.vltitulo,'999g999g999d99') ||
                           '. Est� pago, PENDENTE de processamento!';
            RAISE vr_erro;
          END IF;
          IF c_busca_retorno_boleto%ISOPEN THEN
            CLOSE c_busca_retorno_boleto;
          END IF;

      END IF;
    END LOOP;

    /* verifica se possui acordo ativo ou liquidado */
    /* recp0001.pc_verifica_situacao_acordo (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_cdorigem => 0
                                         ,pr_flgretativo => vr_flgativo
                                         ,pr_flgretquitado => vr_flquitado
                                         ,pr_flgretcancelado => vr_flcancel
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0
    OR vr_dscritic is not null THEN
      pr_des_reto := 'NOK';
      RAISE vr_erro;
    END IF;
    --
    IF vr_flgativo = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, emprestimo em acordo.';
      pr_des_reto := 'NOK';
      RAISE vr_erro;
    END IF;*/
    --
    IF vr_flquitado = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, emprestimo liquidado atrav�s de acordo.';
      RAISE vr_erro;
    END IF;

    /* Verificar se possui acordo na CRAPCYC */
    OPEN c_crapcyc(pr_cdcooper,
                   pr_nrdconta,
                   pr_nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    IF c_crapcyc%ISOPEN THEN
      CLOSE c_crapcyc;
    END IF;

    IF nvl(vr_flgativo,0) = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, acordo possui motivo 2 -Determina��o Judicial � Preju�zo N�o';
      RAISE vr_erro;
    END IF;

    /* Busca o saldo devedor atualizado da conta / contrato de empr�stimo a ser encaminhado para prejuizo */
    empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                    ,pr_cdagenci               => pr_cdagenci --> C�digo da ag�ncia
                                    ,pr_nrdcaixa               => 0 --> N�mero do caixa
                                    ,pr_cdoperad               => 1 --> C�digo do operador
                                    ,pr_nmdatela               => 'crps780'--> Nome datela conectada
                                    ,pr_idorigem               => 5       --> Indicador da origem da chamada
                                    ,pr_nrdconta               => pr_nrdconta --> Conta do associado
                                    ,pr_idseqttl               => 1 --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat             => rw_crapdat --> Vetor com dados de par�metro (CRAPDAT)
                                    ,pr_dtcalcul               => rw_crapdat.dtmvtolt --> Data solicitada do calculo
                                    ,pr_nrctremp               => pr_nrctremp  --> N�mero contrato empr�stimo
                                    ,pr_cdprogra               => 'CRPS780'   --> Programa conectado
                                    ,pr_inusatab               => false        --> Indicador de utiliza��o da tabela
                                    ,pr_flgerlog               => 'N'          --> Gerar log S/N
                                    ,pr_flgcondc               => true         --> Mostrar emprestimos liquidados sem prejuizo
                                    ,pr_nmprimtl               => ''           --> Nome Primeiro Titular
                                    ,pr_tab_parempctl          => ''           --> Dados tabela parametro
                                    ,pr_tab_digitaliza         => ''           --> Dados tabela parametro
                                    ,pr_nriniseq               => 0            --> Numero inicial da paginacao
                                    ,pr_nrregist               => 0            --> Numero de registros por pagina
                                    ,pr_qtregist               => vr_qtregist  --> Qtde total de registros
                                    ,pr_tab_dados_epr          => vr_tab_dados_epr --> Saida com os dados do empr�stimo
                                    ,pr_des_reto               => vr_des_reto  --> Retorno OK / NOK
                                    ,pr_tab_erro               => vr_tab_erro);  --> Tabela com poss�ves erros

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'N�o foi possivel obter dados de emprestimos TR.';
      END IF;
      RAISE vr_erro;
    END IF;

    vr_index := vr_tab_dados_epr.first;
    vr_vlsdeved := 0;

    WHILE vr_index IS NOT NULL LOOP

      vr_vlsdeved := vr_tab_dados_epr(vr_index).vlsdeved ;
      vr_txjurepr := vr_tab_dados_epr(vr_index).txjuremp ;
      vr_vlpreemp := vr_tab_dados_epr(vr_index).vlpreemp ;
      vr_vlttmupr := vr_tab_dados_epr(vr_index).vlttmupr ;
      vr_vlttjmpr := vr_tab_dados_epr(vr_index).vlttjmpr ;
      r_crapepr.cdlcremp := vr_tab_dados_epr(vr_index).cdlcremp ;
      -- buscar proximo
      vr_index := vr_tab_dados_epr.next(vr_index);

    END LOOP;

    /* Verifica linha de credito */
    OPEN c_craplcr(pr_cdcooper);
    FETCH c_craplcr INTO r_craplcr;

    IF c_craplcr%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Linha de Credito nao Cadastrada!';
      RAISE vr_erro;
    END IF;
    IF c_craplcr%ISOPEN THEN
      CLOSE c_craplcr;
    END IF;

    IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN /* Financiamento */
      vr_cdhistor1 := 2401;  /* 2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO */
      if vr_idfraude then
         vr_cdhistor1 := 2405; /* 2405 - TRANSFERENCIA EMP/ FIN TR SUSPEITA DE FRAUDE */
      end if;
      vr_cdhistor2 := 2411;  /* 2411 - MULTAS DE MORA SOBRE PREJUIZO */
      vr_cdhistor3 := 2406;  /* 2406 - REVERSAO JUROS +60 FINANCIAMENTO TR P/ PREJUIZO */
      vr_cdhistor4 := 2415;  /* 2415 - JUROS MORA SOBRE PREJUIZO*/
    ELSE /* Emprestimo */
        vr_cdhistor1 := 2401;  /* 2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO */
        if vr_idfraude then
           vr_cdhistor1 := 2405; /* 2405 - TRANSFERENCIA EMP/ FIN TR SUSPEITA DE FRAUDE */
        end if;
        vr_cdhistor2 := 2411;  /* 2411 - MULTAS DE MORA SOBRE PREJUIZO */
        vr_cdhistor3 := 2402;  /* 2402 - REVERSAO JUROS +60 EMPRESTIMO TR P/ PREJUIZO */
        vr_cdhistor4 := 2415;  /* 2415 - JUROS MORA SOBRE PREJUIZO*/
    end if;

    vr_txmensal := r_craplcr.txmensal;

    -- Busca pr�ximo numero de lote a ser criado
    OPEN  c_busca_prx_lote(2401);
    FETCH c_busca_prx_lote into vr_nrdolote;

    IF NOT c_busca_prx_lote%FOUND
      OR nvl(vr_nrdolote,0) = 0 THEN
      vr_nrdolote := nvl(vr_nrdolote,0) + 1;
    END IF;
    --
    IF c_busca_prx_lote%ISOPEN THEN
      CLOSE c_busca_prx_lote;
    END IF;

    vr_vljura60 := 0;

    OPEN c_crapris(pr_cdcooper
                ,pr_nrdconta
                ,pr_nrctremp);
    FETCH c_crapris INTO vr_vljura60;
    --
    IF c_crapris%ISOPEN THEN
      CLOSE c_crapris;
    END IF;

    IF nvl(vr_vljura60,0) > 0 THEN
      vr_vlsdeved := nvl(vr_vlsdeved,0) - vr_vljura60;
    END IF;
    /* Com base no registro enviado para gerar para preju�zo, cria lan�amentos na CRAPLEM */
    empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_cdbccxlt => 200
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_cdpactra => pr_cdagenci
                                   ,pr_tplotmov => 5
                                   ,pr_nrdolote => vr_nrdolote
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdhistor => vr_cdhistor1
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_vllanmto => nvl(vr_vlsdeved,0)
                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                   ,pr_txjurepr => vr_txjurepr
                                   ,pr_vlpreemp => vr_vlpreemp
                                   ,pr_nrsequni => 0
                                   ,pr_nrparepr => 0
                                   ,pr_flgincre => true
                                   ,pr_flgcredi => false
                                   ,pr_nrseqava => 0
                                   ,pr_cdorigem => 7 -- batch
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := 'Falha ao criar CRAPLEM his: '||to_char(vr_cdhistor1)||' '||
                     vr_dscritic;

      RAISE vr_erro;

    END IF;

    IF vr_vlttmupr > 0 THEN -- Multa
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdbccxlt => 200
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdpactra => pr_cdagenci
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdhistor => vr_cdhistor2
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_vllanmto => nvl(vr_vlttmupr,0)
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => vr_txjurepr
                                     ,pr_vlpreemp => vr_vlpreemp
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => true
                                     ,pr_flgcredi => false
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := 'Falha ao criar Multa - CRAPLEM his: '||to_char(vr_cdhistor2)||' '||
                       vr_dscritic;

        RAISE vr_erro;
      END IF;
    END IF; -- vr_vlttmupr >0

    IF nvl(vr_vljura60,0) > 0 THEN  -- Juros +60
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdbccxlt => 200
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdpactra => pr_cdagenci
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdhistor => vr_cdhistor3
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_vllanmto => vr_vljura60
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => vr_txjurepr
                                     ,pr_vlpreemp => vr_vlpreemp
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => true
                                     ,pr_flgcredi => false
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);


      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := 'Falha ao criar Juros +60 - CRAPLEM his: '||to_char(vr_cdhistor3)||' '||
                       vr_dscritic;

        RAISE vr_erro;
      END IF;
    END IF;
    --
    IF vr_vlttjmpr > 0 THEN -- Juros Mora
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdbccxlt => 200
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdpactra => pr_cdagenci
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdhistor => vr_cdhistor4
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_vllanmto => nvl(vr_vlttjmpr,0)
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => vr_txjurepr
                                     ,pr_vlpreemp => vr_vlpreemp
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => true
                                     ,pr_flgcredi => false
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);


      IF vr_cdcritic > 0 OR vr_dscritic is not null THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := 'Falha ao criar Juros Mora - CRAPLEM his: '||to_char(vr_cdhistor4)||' '||
                       vr_dscritic;

        RAISE vr_erro;
      END IF;
    END IF; -- vr_vlttjmpr >0

    IF pr_des_reto = 'OK' THEN
      BEGIN
         UPDATE CRAPEPR
         SET   crapepr.vlprejuz  = vr_vlsdeved + nvl(vr_vljura60,0)
            ,  crapepr.vlsdprej = vr_vlsdeved + nvl(vr_vljura60,0)
            ,  crapepr.inprejuz = 1 /* Em prejuizo */
            ,  crapepr.inliquid = 1 /* Liquidado   */
            ,  crapepr.dtprejuz = pr_dtmvtolt
            ,  crapepr.txmensal = vr_txmensal
            ,  crapepr.vlttmupr = 0          /* Multa das Parcelas */
            ,  crapepr.vlttjmpr = 0          /* Juros de Mora das Parcelas */
            ,  crapepr.vlpgmupr = 0
            ,  crapepr.vlpgjmpr = 0
           -- ,  crapepr.vlsdeved = 0
           -- ,  crapepr.vlsdevat = 0
         WHERE crapepr.cdcooper = pr_cdcooper
         AND   crapepr.nrdconta = pr_nrdconta
         AND   crapepr.nrctremp = pr_nrctremp;
      EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao ATUALIZAR tabela de emprestimos (CRAPEPR) TR: ' || sqlerrm;
           RAISE vr_erro;
      END;
      --
      -- Ataulizar tabela CRAPCYB
/*      BEGIN
        UPDATE CRAPCYB C
           SET C.DTPREJUZ = pr_dtmvtolt,
               C.VLSDPREJ = vr_vlsdeved,
               C.FLGPREJU = 1
         WHERE C.CDCOOPER = pr_cdcooper
           AND C.CDORIGEM = 3
           AND C.NRDCONTA = pr_nrdconta
           AND C.NRCTREMP = pr_nrctremp;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar a crapcyb prejuizo TR '||sqlerrm;
          RAISE vr_erro;
      END; */
      --
      /* bloqueio da conta corrente */
      pc_bloqueio_conta_corrente(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdorigem => 2
                          ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro bloqueio conta corrente';
        RAISE vr_erro;
      END IF;

    END IF;

  EXCEPTION
    WHEN vr_erro THEN
      --
      ROLLBACK;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_des_reto := 'NOK';

      IF c_crapepr%ISOPEN THEN
        CLOSE c_crapepr;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK;

      vr_cdcritic := 0;
      vr_dscritic := 'Falha rotina PREJ0001 - pc_transfere_epr_prejuizo_TR - '||SQLERRM;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_des_reto := 'NOK';

      IF c_crapepr%ISOPEN THEN
        CLOSE c_crapepr;
      END IF;

  END pc_transfere_epr_prejuizo_TR;

-- Rotina comentada devido a requisito da SM 6 melhria 324
/*Procedure pc_gera_prejuizo_cc(PR_CDCOOPER IN NUMBER DEFAULT NULL
                             ,PR_NRDCONTA IN NUMBER DEFAULT NULL
                             ,PR_VLSDDISP in NUMBER DEFAULT NULL) IS
  cursor c_busca_risco_ass is
    select t.cdcooper, t.nrdconta, t.inrisctl, t.dtrisctl, t.dtdemiss, t.cdagenci
      from crapass t
     where t.cdcooper = pr_cdcooper
       and t.nrdconta = pr_nrdconta; -- retirar ap�s o teste

  cursor c_busca_prx_lote(pr_dtmvtolt date
                         ,pr_cdcooper number
                         ,pr_cdagenci number) is
    select max(nrdolote) nrdolote
      from craplot
     where craplot.dtmvtolt = pr_dtmvtolt
       and craplot.cdcooper = pr_cdcooper
       and craplot.cdagenci = pr_cdagenci
       and craplot.cdbccxlt = 100
       and craplot.tplotmov = 1;

  cursor c_crapcyb(pr_cdcooper number
                  ,pr_nrdconta number
                  ,pr_nrctremp number) is
    select *
      from crapcyb
     where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and nrctremp = pr_nrctremp
       and cdorigem = 1;

  r_crapcyb c_crapcyb%rowtype;

  cursor c_crapcyc2(pr_cdcooper number
                  ,pr_nrdconta number
                  ,pr_nrctremp number) is
    select *
      from crapcyc
     where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and nrctremp = pr_nrctremp
       and cdorigem = 1;

  r_crapcyc c_crapcyc2%rowtype;

  cursor c_craplrt(pr_cdcooper number
                  ,pr_nrdconta number) is
    select x.txmensal
      from craplrt x
         , craplim c
     where x.cdcooper = c.cdcooper
       and x.cddlinha = c.cddlinha
       and c.cdcooper = pr_cdcooper
       and c.nrdconta = pr_nrdconta
       and c.tpctrlim = 1 --Lim. de Credito
       and c.insitlim = 2 --Ativo
     order
        by c.progress_recid desc;

  vr_txmensal              craplrt.txmensal%type;
  vr_txdiaria              craplrt.txmensal%type;
  vr_nrdolote              craplot.nrdolote%type;
  vr_erro                  exception;
  vr_dscritica             varchar2(1000);
  vr_cdcritic              integer;
  rw_crapdat               btch0001.cr_crapdat%rowtype;
  vr_des_reto              varchar2(3);
  vr_dstransa              varchar2(1000);
  VR_NRDROWID              rowid;
  vr_vlsddisp              number;
  vr_nrctremp              number;
  vr_cdhistor              number;
  vr_tab_sald         extr0001.typ_tab_saldos;

begin
  for rw_busca_risco_ass in c_busca_risco_ass loop
    open btch0001.cr_crapdat(pr_cdcooper => rw_busca_risco_ass.cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    close btch0001.cr_crapdat;

     RECP0001.pc_verifica_acordo_ativo (pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrdconta
                                           ,pr_cdorigem =>  0
                                           ,pr_flgativo => vr_flgativo
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF vr_cdcritic > 0
          OR vr_dscritic is not null THEN
             vr_des_reto := 'NOK';
             raise vr_erro;
          END IF;

          IF vr_flgativo = 1 THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Transferencia para prejuizo nao permitida, conta em acordo.';
             vr_des_reto := 'NOK';
             raise vr_erro;
          END IF;

        \* Verificar se possui acordo na CRAPCYC *\
        open c_crapcyc(pr_cdcooper, pr_nrdconta, pr_nrdconta);
        fetch c_crapcyc into vr_flgativo;
        close c_crapcyc;

        IF nvl(vr_flgativo,0) = 1 THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Transferencia para prejuizo nao permitida, conta em acordo.';
             vr_des_reto := 'NOK';
             raise vr_erro;
         END IF;

    open c_craplrt(pr_cdcooper, pr_nrdconta);
    fetch c_craplrt into vr_txmensal;
    if c_craplrt%notfound then
      close c_craplrt;
      vr_txmensal := gene0002.fn_char_para_number
                     (substr(tabe0001.fn_busca_dstextab
                            (pr_cdcooper => pr_cdcooper
                            ,pr_nmsistem => 'CRED'
                            ,pr_tptabela => 'USUARI'
                            ,pr_cdempres => 11
                            ,pr_cdacesso => 'JUROSNEGAT'
                            ,pr_tpregist => 001),1,10));
    else
      close c_craplrt;
    end if;

    vr_txdiaria := vr_txmensal / 30;

    extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper,
                                pr_rw_crapdat => rw_crapdat,
                                pr_cdagenci => 0,
                                pr_nrdcaixa => 0,
                                pr_cdoperad => 1,
                                pr_nrdconta => pr_nrdconta,
                                pr_vllimcre => 0,
                                pr_dtrefere => rw_crapdat.dtmvtolt,
                                pr_flgcrass => false, --pr_flgcrass,
                                pr_tipo_busca => 'A',
                                pr_des_reto => vr_des_reto,
                                pr_tab_sald => vr_tab_sald,
                                pr_tab_erro => vr_tab_erro);

    IF vr_des_reto <> 'OK' THEN
      IF vr_tab_erro.count() > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := 'Erro ao buscar saldo atual '||vr_tab_erro(vr_tab_erro.first).dscritic;
        vr_des_reto := 'NOK';
        RAISE vr_erro;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar saldo atual - '||sqlerrm;
        vr_des_reto := 'NOK';
        raise vr_erro;
      END IF;
    END IF;

       vr_index := vr_tab_sald.first;

       if vr_index is not null then
          vr_vlsddisp := vr_tab_sald(vr_index).vlsddisp;
       else
          vr_vlsddisp := 1;
       end if;

       IF nvl(vr_vlsddisp,0) = 0 THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Conta zerada, nao sera transferida.';
         vr_des_reto := 'NOK';
         raise vr_erro;
       END IF;

       IF nvl(vr_vlsddisp,0) > 0 THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Conta com saldo positivo, nao sera transferida.';
         vr_des_reto := 'NOK';
         raise vr_erro;
       END IF;

    -- verifica se ja existe conta corrente gerada para prejuizo... se existir, deve assumir novo numero contrato
    OPEN C_CRAPEPR(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctremp => pr_nrdconta) ;
    fetch c_crapepr into R_crapepr;
    close C_CRAPEPR;

    if nvl(r_crapepr.inprejuz,2) = 1 then
       vr_nrctremp := to_number(pr_nrdconta || '1');
    else
       vr_nrctremp := pr_nrdconta;
    end if;


    \* 1o passo: gravar tabela CRAWEPR com informa��es da Conta corrente com estouro *\
    BEGIN
      INSERT INTO CRAWEPR(NRDCONTA
                        , NRCTREMP
                        , VLEMPRST
                        , QTPREEMP
                        , VLPREEMP
                        , CDLCREMP
                        , CDFINEMP
                        , QTDIALIB
                        , DSOBSERV
                        , NRCTRLIQ##1
                        , NRCTRLIQ##2
                        , NRCTRLIQ##3
                        , NRCTRLIQ##4
                        , NRCTRLIQ##5
                        , NRCTRLIQ##6
                        , NRCTRLIQ##7
                        , NRCTRLIQ##8
                        , NRCTRLIQ##9
                        , NRCTRLIQ##10
                        , DTMVTOLT
                        , FLGIMPPR
                        , TXMINIMA
                        , TXBASPRE
                        , TXDIARIA
                        , FLGIMPNP
                        , CDCOMITE
                        , NMCHEFIA
                        , NRCTAAV1
                        , NRCTAAV2
                        , DSENDAV1##1
                        , DSENDAV1##2
                        , DSENDAV2##1
                        , DSENDAV2##2
                        , NMDAVAL1
                        , NMDAVAL2
                        , DSCPFAV1
                        , DSCPFAV2
                        , DTVENCTO
                        , CDOPERAD
                        , FLGPAGTO
                        , DTDPAGTO
                        , QTPROMIS
                        , DSCFCAV1
                        , DSCFCAV2
                        , NMCJGAV1
                        , NMCJGAV2
                        , DSNIVRIS
                        , DSNIVCAL
                        , TPDESCTO
                        , CDCOOPER
                        , DTAPROVA
                        , INSITAPR
                        , CDOPEAPR
                        , HRAPROVA
                        , PERCETOP
                        , DSOPERAC
                        , DTALTNIV
                        , IDQUAPRO
                        , DSOBSCMT
                        , DTALTPRO
                        , TPEMPRST
                        , TXMENSAL
                        , DTLIBERA
                        , FLGOKGRV
                        -- , PROGRESS_RECID
                        , QTTOLATR
                        , CDORIGEM
                        , NRCONBIR
                        , INCONCJE
                        , NRSEQRRQ
                        , NRSEQPAC
                        , INSITEST
                        , DTENVEST
                        , HRENVEST
                        , CDAGENCI
                        , HRINCLUS
                        , DTDSCORE
                        , DSDSCORE
                        , CDOPESTE
                        , FLGAPRVC
                        , DTENEFES
                        , DTREFATU)
                        --, IDCARENC
                        --, DTCARENC)
                        --, TPATUIDX)
                   VALUES(PR_NRDCONTA --NRDCONTA
                         , vr_nrctremp -- pr_NRDCONTA -- NRCTREMP
                         , abs(nvl(PR_VLSDDISP,vr_vlsddisp)) -- VLEMPRST
                         , 1 --QTPREEMP
                         , abs(nvl(PR_VLSDDISP,vr_vlsddisp)) --VLPREEMP
                         , 100 --CDLCREMP
                         , 66 --CDFINEMP
                         , 0 -- QTDIALIB
                         , 'Transferencia a prejuizo' --DSOBSERV
                         , 0 --NRCTRLIQ##1
                         , 0 --NRCTRLIQ##2
                         , 0 --NRCTRLIQ##3
                         , 0 --NRCTRLIQ##4
                         , 0 --NRCTRLIQ##5
                         , 0 --NRCTRLIQ##6
                         , 0 --NRCTRLIQ##7
                         , 0 --NRCTRLIQ##8
                         , 0 --NRCTRLIQ##9
                         , 0 --NRCTRLIQ##10
                         , rw_crapdat.dtmvtolt --DTMVTOLT
                         , 1--FLGIMPPR
                         , 1--TXMINIMA
                         , 1--TXBASPRE
                         , vr_txdiaria --TXDIARIA
                         , 0 --FLGIMPNP
                         , 0 --CDCOMITE
                         , null --NMCHEFIA
                         , 0 --NRCTAAV1
                         , 0 --NRCTAAV2
                         , 0 --DSENDAV1##1
                         , null --DSENDAV1##2
                         , 0 --DSENDAV2##1
                         , null --DSENDAV2##2
                         , null --NMDAVAL1
                         , null --NMDAVAL2
                         , 0 --DSCPFAV1
                         , 0 --DSCPFAV2
                         , rw_crapdat.dtultdia + 1 --DTVENCTO
                         , user --CDOPERAD
                         , 0 --FLGPAGTO
                         , rw_crapdat.dtultdia + 1 --DTDPAGTO
                         , 0 --QTPROMIS
                         , null --DSCFCAV1
                         , null --DSCFCAV2
                         , null --NMCJGAV1
                         , null --NMCJGAV2
                         , 'H' --DSNIVRIS
                         , null --DSNIVCAL
                         , 1 --TPDESCTO
                         , pr_cdcooper --CDCOOPER
                         , rw_crapdat.dtmvtolt --DTAPROVA
                         , 1 --INSITAPR
                         , user --CDOPEAPR
                         , to_number(TO_CHAR(SYSDATE,'SSSSS')) --HRAPROVA
                         , null -- PERCETOP --ver
                         , 'EMPRESTIMO' --DSOPERAC
                         , NULL --DTALTNIV
                         , 1 --IDQUAPRO
                         , NULL --DSOBSCMT
                         , rw_crapdat.dtmvtolt --DTALTPRO
                         , 1 --TPEMPRST
                         , vr_txmensal --TXMENSAL
                         , rw_crapdat.dtmvtolt --DTLIBERA
                         , 0 --FLGOKGRV
                         --, PROGRESS_RECID
                         , 0 --QTTOLATR
                         , 5 --CDORIGEM
                         , 0 --NRCONBIR
                         , 0 --INCONCJE
                         , 0 --NRSEQRRQ
                         , 0 --NRSEQPAC
                         , 3 --INSITEST
                         , NULL --DTENVEST
                         , 0 --HRENVEST
                         , rw_busca_risco_ass.cdagenci -- CDAGENCI
                         , to_number(TO_CHAR(SYSDATE,'SSSSS')) --HRINCLUS
                         , NULL --DTDSCORE
                         , ' ' --DSDSCORE
                         , ' ' --CDOPESTE
                         , 0 --FLGAPRVC
                         , NULL --DTENEFES
                         , RW_CRAPDAT.DTMVTOLT); --DTREFATU
                         --, 0 --IDCARENC
                         --, NULL); --DTCARENC
                         --, 0 ); --TPATUIDX)
    EXCEPTION
      WHEN OTHERS THEN
        VR_DSCRITICA := 'ERRO NA INCLUSAO TABELA CRAWEPR: ' || SQLERRM;
        RAISE VR_ERRO;
    END;

    \* 2o. passo gravar CRAPEPR *\
    BEGIN
      INSERT INTO CRAPEPR (DTMVTOLT
                         , CDAGENCI
                         , CDBCCXLT
                         , NRDOLOTE
                         , NRDCONTA
                         , NRCTREMP
                         , CDFINEMP
                         , CDLCREMP
                         , DTULTPAG
                         , NRCTAAV1
                         , NRCTAAV2
                         , QTPREEMP
                         , QTPREPAG
                         , TXJUREMP
                         , VLJURACU
                         , VLJURMES
                         , VLPAGMES
                         , VLPREEMP
                         , VLSDEVED
                         , VLEMPRST
                         , CDEMPRES
                         , INLIQUID
                         , NRCADAST
                         , QTPRECAL
                         , QTMESDEC
                         , DTINIPAG
                         , FLGPAGTO
                         , DTDPAGTO
                         , INDPAGTO
                         , VLIOFEPR
                         , VLPREJUZ
                         , VLSDPREJ
                         , INPREJUZ
                         , VLJRAPRJ
                         , VLJRMPRJ
                         , DTPREJUZ
                         , TPDESCTO
                         , CDCOOPER
                         , TPEMPRST
                         , TXMENSAL
                         , VLSERVTX
                         , VLPAGSTX
                         , VLJURATU
                         , VLAJSDEV
                         , DTREFJUR
                         , DIAREFJU
                         , FLLIQMEN
                         , MESREFJU
                         , ANOREFJU
                         , FLGDIGIT
                         , VLSDVCTR
                         , QTLCALAT
                         , QTPCALAT
                         , VLSDEVAT
                         , VLPAPGAT
                         , VLPPAGAT
                         , QTMDECAT
                       --  , PROGRESS_RECID
                         , QTTOLATR
                         , CDORIGEM
                         , VLTARIFA
                         , VLTARIOF
                         , VLTAXIOF
                         , NRCONBIR
                         , INCONCJE
                         , VLTTMUPR
                         , VLTTJMPR
                         , VLPGMUPR
                         , VLPGJMPR
                         , QTIMPCTR
                         , DTLIQUID
                         , DTULTEST
                         , DTAPGOIB
                         , IDDCARGA
                         , CDOPEORI
                         , CDAGEORI
                         , DTINSORI
                         , CDOPEEFE
                         , DTLIQPRJ
                         , VLSPRJAT
                         , DTREFATU)
           VALUES       ( RW_CRAPDAT.DTMVTOLT -- DTMVTOLT
                         , rw_busca_risco_ass.cdagenci -- CDAGENCI
                         , 100 --CDBCCXLT
                         , 600005 --NRDOLOTE
                         , pr_NRDCONTA --NRDCONTA
                         , vr_nrctremp --pr_NRDCONTA --NRCTREMP
                         , 66 --CDFINEMP
                         , 100 --CDLCREMP
                         , R_crapepr.Dtultpag --RW_CRAPDAT.DTMVTOLT --DTULTPAG
                         , 0 --NRCTAAV1
                         , 0 --NRCTAAV2
                         , 1 --QTPREEMP
                         , 0 --QTPREPAG
                         , vr_txdiaria -- VERIFICAR TXJUREMP
                         , 0 --VLJURACU
                         , 0 --VLJURMES
                         , 0 --VLPAGMES
                         , abs(nvl(PR_VLSDDISP,vr_vlsddisp)) -- VERIFICAR VLPREEMP
                         , 0 --VLSDEVED
                         , nvl(PR_VLSDDISP,vr_vlsddisp) * -1 --VLEMPRST
                         , 81 -- VERIFICAR CDEMPRES
                         , 1 --INLIQUID
                         , 0 -- VERIIFCAR --NRCADAST
                         , 0 --QTPRECAL
                         , 0 --QTMESDEC
                         , NULL --DTINIPAG
                         , 0 --FLGPAGTO
                         , RW_CRAPDAT.dtultdia + 1 --DTDPAGTO
                         , 0 --INDPAGTO
                         , 0 -- VERIFICAR --VLIOFEPR
                         , abs(nvl(PR_VLSDDISP,vr_vlsddisp)) --VLPREJUZ
                         , abs(nvl(PR_VLSDDISP,vr_vlsddisp)) --VLSDPREJ
                         , 1 --INPREJUZ
                         , 0 --VLJRAPRJ
                         , 0 --VLJRMPRJ
                         , RW_CRAPDAT.DTMVTOLT --DTPREJUZ
                         , 1 --TPDESCTO
                         , pr_cdcooper --CDCOOPER
                         , 1 --TPEMPRST
                         , vr_txmensal --TXMENSAL
                         , 0 --VLSERVTX
                         , 0 --VLPAGSTX
                         , 0 --VLJURATU
                         , 0 --VLAJSDEV
                         , NULL --DTREFJUR
                         , 0 --DIAREFJU
                         , 0 --FLLIQMEN
                         , 0 --MESREFJU
                         , 0 --ANOREFJU
                         , 0 --FLGDIGIT
                         , 0 --VLSDVCTR
                         , 0 --QTLCALAT
                         , 0 --QTPCALAT
                         , 0 --VLSDEVAT
                         , 0 --VLPAPGAT
                         , 0 --VLPPAGAT
                         , 0 --QTMDECAT
                       --  , PROGRESS_RECID
                         , 0 --QTTOLATR
                         , 7 --CDORIGEM
                         , 0 --VLTARIFA
                         , 0 --VLTARIOF
                         , 0 --VLTAXIOF
                         , 0 --NRCONBIR
                         , 0 --INCONCJE
                         , 0 --VLTTMUPR
                         , 0 --VLTTJMPR
                         , 0 --VLPGMUPR
                         , 0 --VLPGJMPR
                         , 0 --QTIMPCTR
                         , NULL --DTLIQUID
                         , NULL --DTULTEST
                         , NULL --DTAPGOIB
                         , 0 --IDDCARGA
                         , 1 --CDOPEORI
                         , 1 --CDAGEORI
                         , RW_CRAPDAT.DTULTDIA + 120 -- VERIFICAR DTINSORI
                         , USER --CDOPEEFE
                         , NULL --DTLIQPRJ
                         , 0 --VLSPRJAT
                         , RW_CRAPDAT.DTMVTOLT); --DTREFATU)
    EXCEPTION
      WHEN OTHERS THEN
        VR_DSCRITICA := 'ERRO NA INCLUSAO TABELA CRAPEPR - conta: ' || pr_nrdconta;
        RAISE VR_ERRO;
    END;

    \* 3o. passo - gravar parcela CRAPPEP *\
    BEGIN
     INSERT INTO CRAPPEP (CDCOOPER
                        , NRDCONTA
                        , NRCTREMP
                        , NRPAREPR
                        , VLPAREPR
                        , VLJURPAR
                        , VLMTAPAR
                        , VLMRAPAR
                        , VLMTZPAR
                        , DTVENCTO
                        , DTULTPAG
                        , VLPAGPAR
                        , VLPAGMTA
                        , VLPAGMRA
                        , INLIQUID
                        , VLDESPAR
                        , VLSDVPAR
                        , VLJINPAR
                        , VLPAGJIN
                        , VLSDVATU
                        , VLJURA60
                        , VLSDVSJI
                        --, PROGRESS_RECID
                        , INPREJUZ
                        , DTREFATU)
           VALUES     (   pr_CDCOOPER --CDCOOPER
                        , pr_NRDCONTA --NRDCONTA
                        , vr_nrctremp -- pr_NRDCONTA --NRCTREMP
                        , 1 --NRPAREPR
                        , abs(nvl(PR_VLSDDISP,vr_vlsddisp)) -- VERIFICAR --VLPAREPR
                        , 0 --VLJURPAR
                        , 0 --VLMTAPAR
                        , 0 --VLMRAPAR
                        , 0 --VLMTZPAR
                        , RW_CRAPDAT.dtultdia + 1 -- DTVENCTO
                        , R_crapepr.Dtultpag --NULL --DTULTPAG
                        , 0 --VLPAGPAR
                        , 0 --VLPAGMTA
                        , 0 --VLPAGMRA
                        , 1 --INLIQUID
                        , 0 --VLDESPAR
                        , nvl(PR_VLSDDISP,vr_vlsddisp) * -1 -- VERIFICAR --VLSDVPAR
                        , 0 --VLJINPAR
                        , 0 --VLPAGJIN
                        , 0 --VLSDVATU
                        , 0 --VLJURA60
                        , abs(nvl(PR_VLSDDISP,vr_vlsddisp)) --VLSDVSJI
                       --, PROGRESS_RECID
                        , 1 --INPREJUZ
                        , RW_CRAPDAT.DTMVTOLT); --DTREFATU)
    EXCEPTION
      WHEN OTHERS THEN
           VR_DSCRITICA := 'ERRO NA INCLUSAO TABELA CRAPPEP: ' || SQLERRM;
           RAISE VR_ERRO;
    END;

    -- Busca pr�ximo numero de lote a ser criado
    if gl_nrdolote is null then
      open  c_busca_prx_lote(pr_dtmvtolt => RW_CRAPDAT.DTMVTOLT
                            ,pr_cdcooper => rw_busca_risco_ass.cdcooper
                            ,pr_cdagenci => rw_busca_risco_ass.cdagenci);
      fetch c_busca_prx_lote into vr_nrdolote;
      close c_busca_prx_lote;

      vr_nrdolote := nvl(vr_nrdolote,0) + 1;
      gl_nrdolote := vr_nrdolote;
    else
      vr_nrdolote := gl_nrdolote;
    end if;

    vr_cdhistor := 2408;

    if vr_idfraude then
       vr_cdhistor := 2412;
    end if;

    \* 4o. passo - cria lan�amento LCM referente ao preju�zo *\
    empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper
                                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 , pr_cdagenci => rw_busca_risco_ass.cdagenci
                                 , pr_cdbccxlt => 100
                                 , pr_cdoperad => user
                                 , pr_cdpactra => rw_busca_risco_ass.cdagenci
                                 , pr_nrdolote => vr_nrdolote
                                 , pr_nrdconta => pr_nrdconta
                                 , pr_cdhistor => vr_cdhistor-- 2408
                                 , pr_vllanmto => abs(nvl(PR_VLSDDISP,vr_vlsddisp))
                                 , pr_nrparepr => 1
                                 , pr_nrctremp => vr_nrctremp --pr_nrdconta
                                 , pr_nrseqava => 0
                                 , pr_idlautom => 0
                                 , pr_des_reto => vr_des_reto
                                 , pr_tab_erro => vr_tab_erro );

    if vr_des_reto <> 'OK' then
      vr_dscritica := 'Erro ao gerar lancamento de conta corrente (LCM):' || vr_des_reto;
      raise vr_erro;
    end if;

    \* 5o. passo - cria lan�amento LEM referente ao preju�zo *\
    empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_busca_risco_ass.cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => rw_busca_risco_ass.cdagenci
                                   ,pr_cdbccxlt => 100
                                   ,pr_cdoperad => user
                                   ,pr_cdpactra => rw_busca_risco_ass.cdagenci
                                   ,pr_tplotmov => 4
                                   ,pr_nrdolote => 60005
                                   ,pr_nrdconta => rw_busca_risco_ass.nrdconta
                                   ,pr_cdhistor => vr_cdhistor --2408
                                   ,pr_nrctremp => vr_nrctremp --rw_busca_risco_ass.nrdconta
                                   ,pr_vllanmto => abs(nvl(PR_VLSDDISP,vr_vlsddisp))
                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                   ,pr_txjurepr => 0 -- verificar --vr_txjurepr
                                   ,pr_vlpreemp => 0 --vr_vlpreemp
                                   ,pr_nrsequni => 0
                                   ,pr_nrparepr => 0
                                   ,pr_flgincre => true
                                   ,pr_flgcredi => false
                                   ,pr_nrseqava => 0
                                   ,pr_cdorigem => 7 -- batch
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritica);

    if vr_dscritica is not null then
      vr_dscritica := 'Erro lancamento emprestimo: ' || vr_dscritica;
      raise vr_erro;
    end if;


   \* -- se possui juros
    empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_busca_risco_ass.cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => rw_busca_risco_ass.cdagenci
                                   ,pr_cdbccxlt => 100
                                   ,pr_cdoperad => user
                                   ,pr_cdpactra => rw_busca_risco_ass.cdagenci
                                   ,pr_tplotmov => 4
                                   ,pr_nrdolote => 60005
                                   ,pr_nrdconta => rw_busca_risco_ass.nrdconta
                                   ,pr_cdhistor => 2408
                                   ,pr_nrctremp => rw_busca_risco_ass.nrdconta
                                   ,pr_vllanmto => nvl(PR_VLSDDISP,vr_vlsddisp)
                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                   ,pr_txjurepr => 0 -- verificar --vr_txjurepr
                                   ,pr_vlpreemp => 0 --vr_vlpreemp
                                   ,pr_nrsequni => 0
                                   ,pr_nrparepr => 0
                                   ,pr_flgincre => true
                                   ,pr_flgcredi => false
                                   ,pr_nrseqava => 0
                                   ,pr_cdorigem => 7 -- batch
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritica);

    if vr_dscritica is not null then
      vr_dscritica := 'Erro lancamento emprestimo: ' || vr_dscritica;
      raise vr_erro;
    end if;            *\

    \* 6o passo - grava a CRAPCYB / CRAPCYC com as informa��es do emprestimo *\
    begin
      OPEN C_CRAPCYB(PR_CDCOOPER => rw_busca_risco_ass.cdcooper
                    ,PR_NRDCONTA => rw_busca_risco_ass.nrdconta
                    ,PR_NRCTREMP => rw_busca_risco_ass.nrdconta);
      fetch c_crapcyb into r_crapcyb;

      if c_crapcyb%found then
        --
        BEGIN
          UPDATE crapcyb c
             SET c.dtdbaixa = rw_crapdat.dtmvtolt
           WHERE cdcooper = rw_busca_risco_ass.cdcooper
             AND nrdconta = rw_busca_risco_ass.nrdconta
             AND nrctremp = rw_busca_risco_ass.nrdconta
             AND cdorigem = 1;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritica := 'Erro na atualiza��o da CRAPCYB: ' || sqlerrm;
            raise vr_erro;
        END;
        --
        BEGIN
          INSERT INTO crapcyb (cdcooper,cdorigem,nrdconta,nrctremp,cdagenci,cdlcremp,
                               cdfinemp,dtmvtolt,dtdbaixa,vlsdevan,vljura60,vlpreemp,
                               qtpreatr,vlprapga,vlpreapg,vldespes,vlperris,nivrisat,
                               nivrisan,dtdrisan,qtdiaris,qtdiaatr,flgrpeco,dtefetiv,
                               vlemprst,qtpreemp,qtprepag,dtdpagto,txmensal,txdiaria,
                               vlprepag,qtmesdec,dtprejuz,vlsdprej,flgjudic,flextjud,
                               flgehvip,flgpreju,flgresid,flgconsg,dtmancad,dtmanavl,
                               dtmangar,vlsdeved,flgfolha,vlsdprea,dtatufin,qtdiaaap)
                       values (r_crapcyb.cdcooper
                              ,3 -- cdorigem
                              ,r_crapcyb.nrdconta
                              ,vr_nrctremp --r_crapcyb.nrctremp
                              ,r_crapcyb.cdagenci
                              ,r_crapcyb.cdlcremp
                              ,r_crapcyb.cdfinemp
                              ,rw_crapdat.dtmvtolt --r_crapcyb.dtmvtolt -- rmm
                              ,rw_crapdat.dtmvtolt --r_crapcyb.dtdbaixa -- rmm
                              ,r_crapcyb.vlsdevan
                              ,r_crapcyb.vljura60
                              ,r_crapcyb.vlpreemp
                              ,r_crapcyb.qtpreatr
                              ,r_crapcyb.vlprapga
                              ,r_crapcyb.vlpreapg
                              ,r_crapcyb.vldespes
                              ,r_crapcyb.vlperris
                              ,r_crapcyb.nivrisat
                              ,r_crapcyb.nivrisan
                              ,r_crapcyb.dtdrisan
                              ,r_crapcyb.qtdiaris
                              ,r_crapcyb.qtdiaatr
                              ,r_crapcyb.flgrpeco
                              ,r_crapcyb.dtefetiv
                              ,r_crapcyb.vlemprst
                              ,r_crapcyb.qtpreemp
                              ,r_crapcyb.qtprepag
                              ,r_crapcyb.dtdpagto
                              ,r_crapcyb.txmensal
                              ,r_crapcyb.txdiaria
                              ,r_crapcyb.vlprepag
                              ,r_crapcyb.qtmesdec
                              ,rw_crapdat.dtmvtolt -- r_crapcyb.dtprejuz
                              ,abs(nvl(PR_VLSDDISP,vr_vlsddisp))    -- r_crapcyb.vlsdprej -- rmm
                              ,r_crapcyb.flgjudic
                              ,r_crapcyb.flextjud
                              ,r_crapcyb.flgehvip
                              ,1 --r_crapcyb.flgpreju -- rmm
                              ,r_crapcyb.flgresid
                              ,r_crapcyb.flgconsg
                              ,rw_crapdat.dtmvtolt -- r_crapcyb.dtmancad -- rmm
                              ,r_crapcyb.dtmanavl
                              ,r_crapcyb.dtmangar
                              ,r_crapcyb.vlsdeved
                              ,r_crapcyb.flgfolha
                              ,r_crapcyb.vlsdprea
                              ,r_crapcyb.dtatufin
                              ,r_crapcyb.qtdiaaap);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritica := 'Erro na inclusao da CRAPCYB: ' || sqlerrm;
            raise vr_erro;
        END;
      end if;

      close c_crapcyb;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritica := 'Erro na GERAL inclusao da CRAPCYB: ' || sqlerrm;
        raise vr_erro;
    end;

    begin
      open c_crapcyc2(pr_cdcooper => rw_busca_risco_ass.cdcooper
                    ,pr_nrdconta => rw_busca_risco_ass.nrdconta
                    ,pr_nrctremp => rw_busca_risco_ass.nrdconta);
      fetch c_crapcyc2 into r_crapcyc;
      if c_crapcyc2%found then
        insert into crapcyc ( cdcooper
                            , cdorigem
                            , nrdconta
                            , nrctremp
                            , flgjudic
                            , flextjud
                            , flgehvip
                            , cdoperad
                            , dtenvcbr
                            , dtinclus
                            , cdopeinc
                            , dtaltera
                            , cdassess
                            , cdmotcin)
                     values ( r_crapcyc.cdcooper
                            , 3 -- cdorigem
                            , r_crapcyc.nrdconta
                            , vr_nrctremp --r_crapcyc.nrctremp
                            , r_crapcyc.flgjudic
                            , r_crapcyc.flextjud
                            , r_crapcyc.flgehvip
                            , r_crapcyc.cdoperad
                            , r_crapcyc.dtenvcbr
                            , r_crapcyc.dtinclus
                            , r_crapcyc.cdopeinc
                            , r_crapcyc.dtaltera
                            , r_crapcyc.cdassess
                            , r_crapcyc.cdmotcin);
      end if;
      close c_crapcyc2;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritica := 'Erro na inclusao da CRAPCYC: ' || sqlerrm;
        raise vr_erro;
    end;

    \* 6o passo - bloqueios da conta corrente *\
    pc_bloqueio_conta_corrente(pr_cdcooper => rw_busca_risco_ass.cdcooper
                              ,pr_nrdconta => rw_busca_risco_ass.nrdconta
                              ,pr_cdorigem => 1 -- Conta
                              ,pr_dscritic => vr_dscritica);

    if vr_dscritica <> 'OK' then
      vr_dscritica := 'Erro ao efetuar bloqueios na conta corrente: ' || vr_dscritica;
      raise vr_erro;
    end if;
  end loop;
exception
  when vr_erro then
        rollback;

              vr_dstransa := 'Erro ao transferir Conta para preju�zo - Conta: ' || pr_nrdconta ||
                             ', Contrato: ' || pr_nrdconta;

             gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => '1'
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_dsorigem => 'AYLLOS'
                                  ,pr_dstransa => vr_dstransa
                                  ,pr_dttransa => trunc(sysdate)
                                  ,pr_flgtrans => 1
                                  ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'CRPS780'
                                  ,pr_nrdconta => PR_NRDCONTA
                                  ,pr_nrdrowid => VR_NRDROWID);
             -- gravar o log
             COMMIT;
  when others then
    raise_application_error(-20200,'Erro transfere prj CC: ' || sqlerrm);
end pc_gera_prejuizo_cc;*/

   PROCEDURE pc_estorno_trf_prejuizo_PP(pr_cdcooper IN NUMBER
                                       ,pr_cdagenci IN NUMBER
                                       ,pr_nrdcaixa IN NUMBER
                                       ,pr_cdoperad IN VARCHAR2
                                       ,pr_nrdconta IN NUMBER
                                       ,pr_dtmvtolt IN DATE
                                       ,pr_nrctremp IN NUMBER
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS
/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Cal�o - Mout�S
   Data    : Maio/2017                      Ultima atualizacao: 28/05/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Realizar o estorno de transfer�ncia a preju�zo

   Alteracoes: 16/03/2018 -Identa��o e ajustes de regras no estorno PP Rafael - Mout's

..............................................................................*/



    -- verifica pagamentos
    CURSOR cr_craplem(pr_dtmvtolt IN DATE) IS
      SELECT 1
      FROM   craplem t
      WHERE  cdcooper = pr_cdcooper
      AND    nrdconta = pr_nrdconta
      AND    nrctremp = pr_nrctremp
      AND    dtmvtolt >= trunc(pr_dtmvtolt,'MM')
      AND    (cdhistor NOT IN (1037   /* Juros Normais */
                              ,1038   /* Juros Normais */
                              ,1732   /* FINANCIAMENTO PRE-FIXADO TRANSFERIDO PARA PREJUIZO */
                              ,1734   /* MULTA MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                              ,1736   /* JUROS MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                              ,1731   /* EMPRESTIMO PRE-FIXADO TRANSFERIDO PARA PREJUIZO  */
                              ,1733   /* MULTA MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */
                              ,1735
                              ,2381
                              ,2397
                              ,2411
                              ,2382
                              ,2383
                              ,2396
                              ,2398
                              ,2408
                              ,2409)
        OR  (cdhistor = 2388
        AND EXISTS (SELECT 1
                      FROM craplem x
                     WHERE  x.cdcooper = t.cdcooper
                       AND x.nrdconta = t.nrdconta
                       AND x.nrctremp = t.nrctremp
                       AND x.dtmvtolt >= t.dtmvtolt
                       AND x.cdhistor = 2392 ))); -- estorno de pagamento

        vr_existePg  integer;

    CURSOR cr_craplem2(pr_dtmvtolt IN DATE) IS
      SELECT *
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.nrctremp = pr_nrctremp
         AND craplem.dtmvtolt = pr_dtmvtolt
         AND craplem.cdbccxlt = 100;
         -- and    craplem.nrdolote = 600029;

       rw_craplem cr_craplem2%rowtype;
      /*
        2409  JUROS PREJUIZO
        2422  ESTORNO JUROS PREJ
        2411  MULTA
        2423  EST MULTA
        2415  JUROS MORA
        2416  EST JUROS MORA
      */

    -- Validar se existe Juros +60 para estornoar
    CURSOR cr_lanc_lem (prc_cdcooper craplem.cdcooper%TYPE
                       ,prc_nrdconta craplem.nrdconta%TYPE
                       ,prc_nrctremp craplem.nrctremp%TYPE) IS
      SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2382) THEN c.vllanmto ELSE 0 END) -
                  SUM(CASE WHEN c.cdhistor IN (2384) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2382,
             NVL((SUM(CASE WHEN c.cdhistor IN (2397) THEN c.vllanmto ELSE 0 END) -
                  SUM(CASE WHEN c.cdhistor IN (2399) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2397,
             NVL((SUM(CASE WHEN c.cdhistor IN (2409) THEN c.vllanmto ELSE 0 END) -
                  SUM(CASE WHEN c.cdhistor IN (2422) THEN c.vllanmto ELSE 0 END)),0) sum_jratz_2409,
             NVL((SUM(CASE WHEN c.cdhistor IN (2411) THEN c.vllanmto ELSE 0 END) -
                  SUM(CASE WHEN c.cdhistor IN (2423) THEN c.vllanmto ELSE 0 END)),0) sum_jrmulta_2411,
             NVL((SUM(CASE WHEN c.cdhistor IN (2415) THEN c.vllanmto ELSE 0 END) -
                  SUM(CASE WHEN c.cdhistor IN (2416) THEN c.vllanmto ELSE 0 END)),0) sum_jrmora_2415
        FROM craplem c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.nrctremp = prc_nrctremp
         AND c.cdhistor in (2382,2384,2397,2399,2409,2422,2411,2423,2415,2416);
    --
    CURSOR cr_vlprincipal (prc_cdcooper craplem.cdcooper%TYPE
                          ,prc_nrdconta craplem.nrdconta%TYPE
                          ,prc_nrctremp craplem.nrctremp%TYPE) IS

      SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2381) THEN c.vllanmto ELSE 0 END) -
                  SUM(CASE WHEN c.cdhistor IN (2383) THEN c.vllanmto ELSE 0 END)),0) sum_empr_2381, -- Emprestimo
             NVL((SUM(CASE WHEN c.cdhistor IN (2396) THEN c.vllanmto ELSE 0 END) -
                  SUM(CASE WHEN c.cdhistor IN (2398) THEN c.vllanmto ELSE 0 END)),0) sum_fina_2396  -- Financiamento
        FROM craplem c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.nrctremp = prc_nrctremp
         AND c.cdhistor in (2381,2396,2383,2398);
    --
    -- buscar se existe contratos em Prejuizo para a conta
    CURSOR cr_crapepr (prc_cdcooper craplem.cdcooper%TYPE
                      ,prc_nrdconta craplem.nrdconta%TYPE) IS
      SELECT DISTINCT 1 existe
        FROM crapepr epr
       WHERE epr.cdcooper = prc_cdcooper
         AND epr.nrdconta = prc_nrdconta
         AND epr.inprejuz = 1
         AND epr.dtprejuz IS NOT NULL
         AND epr.cdlcremp <> 100;

    vr_cdhistor1 INTEGER;
    vr_flgtrans  BOOLEAN;
    vr_dstransa  VARCHAR2(500);
    vr_dtmvtolt  DATE;
    vr_auxvalor  NUMBER;
    vr_vljuro60  NUMBER;
    vr_cdhisatz  INTEGER;
    vr_vljratuz  NUMBER;
    vr_cdhismul  INTEGER;
    vr_vljrmult  NUMBER;
    vr_cdhismor  INTEGER;
    vr_vljrmora  NUMBER;
    vr_vlprinci  NUMBER;
    vr_nrdrowid  ROWID;
    vr_exc_erro  EXCEPTION;
    vr_existe_prejuizo NUMBER(1);

  BEGIN
    vr_flgtrans := FALSE;
    pr_des_reto := 'OK';

    /* Busca data de movimento */
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    /* Busca informa��es do empr�stimo */
    OPEN c_crapepr(pr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrctremp);
    FETCH c_crapepr INTO r_crapepr;

    IF c_crapepr%FOUND THEN
      IF f_valida_pagamento_abono(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'N�o � poss�vel fazer estorno da tranfer�ncia de preju�zo, existem pagamentos para a conta / contrato informado';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      END IF;
      --
      IF r_crapepr.inprejuz = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato n�o esta em prejuizo!';

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      ELSE
        /* Verificar se ocorreram pagamentos */
        vr_dtmvtolt := r_crapepr.Dtprejuz;

        /* open cr_craplem(vr_dtmvtolt);
          fetch cr_craplem into vr_existePg;
          close cr_craplem;

        IF NVL(vr_existePg,0) = 1 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Existem pagamentos na data atual. Operacao Cancelada!';

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

           pr_des_reto := 'NOK';
           raise vr_exc_erro;
        END IF;
        */
        /* Ativa Rating */
        RATI0001.pc_verifica_contrato_rating(pr_cdcooper =>  pr_cdcooper
                                            ,pr_cdagenci => 0
                                           , pr_nrdcaixa => 0
                                           , pr_cdoperad => pr_cdoperad
                                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           , pr_dtmvtopr => rw_crapdat.dtmvtopr
                                           , pr_nrdconta => pr_nrdconta
                                           , pr_tpctrrat => 90
                                           , pr_nrctrrat => pr_nrctremp
                                           , pr_idseqttl => 1
                                           , pr_idorigem => 7 -- Batch
                                           , pr_nmdatela => 'CRPS780'
                                           , pr_inproces => 0
                                           , pr_flgerlog => true
                                           , pr_tab_erro => vr_tab_erro
                                           , pr_des_erro => vr_des_reto
                                           , pr_dscritic => vr_dscritic);

        IF vr_des_reto <> 'OK' THEN

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao ativar Rating!';

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

             pr_des_reto := 'NOK';
        END IF;

        /* Busca Lan�amentos Empr�stimos (LEM) */
        FOR rw_craplem IN cr_craplem2(vr_dtmvtolt) LOOP
          vr_auxvalor :=0;

          IF  r_crapepr.vlprejuz > 0 AND
              rw_craplem.cdhistor IN (1732, 1731) THEN
                   vr_auxvalor := r_crapepr.vlprejuz;
          END IF;

          IF  r_crapepr.vlttmupr > 0 AND
              rw_craplem.cdhistor IN (1734, 1733) THEN
               vr_auxvalor := r_crapepr.vlttmupr;
          END IF;

          IF  r_crapepr.vlttjmpr > 0 AND
              rw_craplem.cdhistor IN (1736, 1735) THEN
               vr_auxvalor := r_crapepr.vlttjmpr;
          END IF;


        END LOOP;
        --
        -- Se for o estorno no mesmo dia da transferencia, dever� ser exclus�o
        IF r_crapepr.dtprejuz = rw_crapdat.dtmvtolt THEN
          --
          IF vr_auxvalor > 0 THEN
            BEGIN
              UPDATE craplot
                 SET craplot.nrseqdig = craplot.nrseqdig +  1
                    ,craplot.qtcompln = craplot.qtcompln -1
                    ,craplot.qtinfoln = craplot.qtinfoln -1
                    ,craplot.vlcompcr = craplot.vlcompcr + (vr_auxvalor * -1)
                    ,craplot.vlinfocr = craplot.vlinfocr + (vr_auxvalor * -1)
               WHERE craplot.cdcooper = rw_craplem.cdcooper
                 AND   craplot.cdagenci = rw_craplem.cdagenci
                 AND   craplot.cdbccxlt = rw_craplem.cdbccxlt
                 AND   craplot.nrdolote = rw_craplem.nrdolote
                 AND   craplot.dtmvtolt = rw_crapdat.dtmvtolt
                 AND   craplot.tplotmov = 5;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar lote!' || sqlerrm;
                vr_des_reto := 'NOK';
                RAISE vr_exc_erro;
            END;

          END IF;
          /* Excluir lan�amentos da CRAPLEM */
          BEGIN
             DELETE FROM CRAPLEM
              WHERE craplem.cdcooper = pr_cdcooper
                AND craplem.nrdconta = pr_nrdconta
                AND craplem.nrctremp = pr_nrctremp
                AND craplem.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplem.cdbccxlt = 100
                AND craplem.cdhistor in (2381,2382,2411,2415,2385,2396,2397,2400);
               -- and    craplem.nrdolote = 600029;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro na exclus�o dos lan�amentos!' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
          END;

        ELSE -- Se n�o for o mesmo dia, dever� gerar linhas de estorno
          OPEN c_craplcr(pr_cdcooper);
          FETCH c_craplcr INTO r_craplcr;

          IF c_craplcr%NOTFOUND THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Linha de Credito nao Cadastrada!';
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
          CLOSE c_craplcr;
          --
          -- Atualizar CYBER
          --
          BEGIN
            UPDATE crapcyb cyb
               SET cyb.vlsdevan = r_crapepr.vlsdeved
                  ,cyb.vlsdeved = r_crapepr.vlsdeved
                  ,cyb.qtprepag = r_crapepr.qtprecal
                  ,cyb.txmensal = r_crapepr.txmensal
                  ,cyb.txdiaria = r_crapepr.txjuremp
                  ,cyb.dtprejuz = null
                  ,cyb.vlsdprej = 0
                  ,cyb.vlpreemp = r_crapepr.vlpreemp
             WHERE cyb.cdcooper = pr_cdcooper
               AND cyb.nrdconta = pr_nrdconta
               AND cyb.nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Falha ao atualizar tabela CYBER! PP' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
          END;
          /*
            2381  TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
            2382  REVERSAO JUROS +60 PP P/ PREJUIZO
            2383  ESTORNO TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
            2384  ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO
            2396  TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
            2397  REVERSAO JUROS +60 PP P/ PREJUIZO
            2398  ESTORNO TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
            2399  ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO
          */
          -- Gerar Lan�amento de estorno para valor Principal
          FOR rw_vlprincipal IN cr_vlprincipal(pr_cdcooper,
                                               pr_nrdconta,
                                               pr_nrctremp) LOOP

            IF rw_vlprincipal.sum_empr_2381 > 0 THEN
              vr_cdhistor1 := 2383;
              vr_vlprinci := rw_vlprincipal.sum_empr_2381;
            ELSE
              vr_cdhistor1 := 2398;
              vr_vlprinci := rw_vlprincipal.sum_fina_2396;
            END IF;
            --
            IF vr_vlprinci > 0 THEN
              -- Realizar o lan�amento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhistor1
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vlprinci
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END LOOP;


          -- Validar estorno Juros +60
          -- Gerar Lan�amento de estorno para valor Principal
          FOR rw_lanc_lem IN cr_lanc_lem(pr_cdcooper,
                                         pr_nrdconta,
                                         pr_nrctremp) LOOP

            IF rw_lanc_lem.sum_jr60_2382 > 0 THEN
              vr_cdhistor1 := 2384;
              vr_vljuro60 := rw_lanc_lem.sum_jr60_2382;
            END IF;
            --
            IF rw_lanc_lem.sum_jr60_2397 > 0 THEN
              vr_cdhistor1 := 2399;
              vr_vljuro60 := rw_lanc_lem.sum_jr60_2397;
            END IF;
            --
            IF rw_lanc_lem.sum_jratz_2409 > 0 THEN
              vr_cdhisatz := 2422;
              vr_vljratuz := rw_lanc_lem.sum_jratz_2409;
            END IF;
            --
            IF rw_lanc_lem.sum_jrmulta_2411 > 0 THEN
              vr_cdhismul := 2423;
              vr_vljrmult := rw_lanc_lem.sum_jrmulta_2411;
            END IF;
            --
            IF rw_lanc_lem.sum_jrmora_2415 > 0 THEN
              vr_cdhismor := 2416;
              vr_vljrmora := rw_lanc_lem.sum_jrmora_2415;
            END IF;

            --
            IF vr_vljuro60 > 0 THEN
              -- Realizar o lan�amento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhistor1
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljuro60
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM PP(Juros +60): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
            --
            -- Juros Atualizado
            IF vr_vljratuz > 0 THEN
              -- Realizar o lan�amento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhisatz
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljratuz
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM PP (Juros Atualizado): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
            -- Multa
            IF vr_vljrmult > 0 THEN
              -- Realizar o lan�amento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhismul
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljrmult
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM PP (valor Multa): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
            -- Juros Mora
            IF vr_vljrmora > 0 THEN
              -- Realizar o lan�amento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhismor
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljrmora
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM PP (Juros Mora): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END LOOP;

        END IF;
          /* atualizar parcelas do emprestimo */
           BEGIN
                UPDATE CRAPPEP
                SET    crappep.inliquid = 0
                ,      crappep.inprejuz = 0
                where  crappep.cdcooper = pr_cdcooper
                and    crappep.nrdconta = pr_nrdconta
                and    crappep.nrctremp = pr_nrctremp
                and    crappep.inliquid = 1
                and    crappep.inprejuz = 1;

              EXCEPTION
                when others then
                     vr_cdcritic := 0;
                     vr_dscritic := 'Erro ao atualizar parcelas!' || sqlerrm;
                     pr_des_reto := 'NOK';
                     raise vr_exc_erro;
              END;


          /* Atualizar Emprestimo */
          BEGIN
             UPDATE CRAPEPR
                SET crapepr.vlsdeved = crapepr.vlprejuz
                   ,crapepr.vlsdevat = crapepr.vlsdprej
                   ,crapepr.vlprejuz = 0
                   ,crapepr.vlsdprej = 0
                   ,crapepr.inprejuz = 0
                   ,crapepr.inliquid = 0
                   ,crapepr.dtprejuz = null
                   ,crapepr.vlttmupr = 0
                   ,crapepr.vlttjmpr = 0
                   ,crapepr.vlpgmupr = 0
                   ,crapepr.vlpgjmpr = 0
              WHERE crapepr.cdcooper = pr_cdcooper
                AND crapepr.nrdconta = pr_nrdconta
                AND crapepr.nrctremp = pr_nrctremp
                AND crapepr.inprejuz = 1;

           EXCEPTION
             when others then
                 vr_cdcritic := 0;
                 vr_dscritic := 'Erro ao atualizar emprestimo!' || sqlerrm;
                 pr_des_reto := 'NOK';
                 raise vr_exc_erro;
           END;

           vr_dstransa := 'Data: ' || to_char( pr_dtmvtolt,'DD/MM/YYYY') ||
                          ' - Estorno de transferencia para prejuizo PP - ' ||
                          ', Conta:  ' || pr_nrdconta ||
                          ', Contrato: ' || pr_nrctremp;

           gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => null
                                ,pr_dsorigem => 'AYLLOS'
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => pr_dtmvtolt
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'CRPS780'
                                ,pr_nrdconta => PR_NRDCONTA
                                ,pr_nrdrowid => VR_NRDROWID);

            vr_flgtrans := TRUE;

       END IF;
      vr_existe_prejuizo := 0;
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper,
                                   pr_nrdconta) LOOP
        vr_existe_prejuizo := 1;
      END LOOP;

      IF vr_existe_prejuizo = 0 THEN
        rw_crapdat.dtmvtolt := R_crapepr.dtprejuz;

        pc_reabrir_conta_corrente(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_cdorigem => 3
                                 ,pr_dtprejuz => rw_crapdat.dtmvtolt
                                 ,pr_dscritic => vr_dscritic);

        IF vr_dscritic is not null AND vr_dscritic <> 'OK' then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao desbloquear conta corrente. ' || sqlerrm;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
            pr_des_reto := 'NOK';
        END IF;
      END IF;

    ELSE  -- Se n�o encontrou na tabela crapepr
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao estornar prejuizo PP: ' || sqlerrm;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                          ,pr_cdagenci => pr_cdagenci
                          ,pr_nrdcaixa => pr_nrdcaixa
                          ,pr_nrsequen => 1 --> Fixo
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic
                          ,pr_tab_erro => pr_tab_erro);
      pr_des_reto := 'NOK';
    END IF;

    CLOSE c_crapepr;

    IF NOT vr_flgtrans THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao estornar Prejuizo.';
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
     pr_des_reto := 'NOK';

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer altera��es
      ROLLBACK;
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro na rotina pc_estorno_trf_prejuizo_PP: ';
      END IF;

      -- Retorno n�o OK
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0001-Estorno transferencia.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'crps780'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;

  END pc_estorno_trf_prejuizo_PP;

   /* Rotina para estornar transferencia prejuizo TR */
PROCEDURE pc_estorno_trf_prejuizo_TR(pr_cdcooper in number
                                    ,pr_cdagenci in number
                                    ,pr_nrdcaixa in number
                                    ,pr_cdoperad in varchar2
                                    ,pr_nrdconta in number
                                    ,pr_dtmvtolt in date
                                    ,pr_nrctremp in number
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS
/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Cal�o - Mout�S
   Data    : Maio/2017                      Ultima atualizacao: 28/05/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Realizar o estorno de transfer�ncia a preju�zo

   Alteracoes: 21/05/2018 - Identa��o e ajustes de regras no estorno TR
               (Rafael - Mout's)

..............................................................................*/


  -- verifica pagamentos
  CURSOR cr_craplem(pr_dtmvtolt in date) is
    SELECT 1
      FROM craplem
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND nrctremp = pr_nrctremp
      AND dtmvtolt >= trunc(pr_dtmvtolt,'MM')
      AND cdhistor not in (349, 1036,1037,2401,2411,2381,2397, 2410,2404,2406,2409, 2403); /* Transferencia para prejuizo */
  --
  CURSOR cr_craplem2(pr_dtmvtolt in date) IS
    SELECT *
      FROM craplem
     WHERE craplem.cdcooper = pr_cdcooper
       AND craplem.nrdconta = pr_nrdconta
       AND craplem.nrctremp = pr_nrctremp
       AND craplem.dtmvtolt = pr_dtmvtolt
       AND craplem.cdbccxlt = 200;

  rw_craplem cr_craplem2%rowtype;
  --
  -- Validar se existe Juros +60 para estornoar
  CURSOR cr_lanc_lem (prc_cdcooper craplem.cdcooper%TYPE
                     ,prc_nrdconta craplem.nrdconta%TYPE
                     ,prc_nrctremp craplem.nrctremp%TYPE) IS
    SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2402) THEN c.vllanmto ELSE 0 END) -
                SUM(CASE WHEN c.cdhistor IN (2404) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2402,
           NVL((SUM(CASE WHEN c.cdhistor IN (2406) THEN c.vllanmto ELSE 0 END) -
                SUM(CASE WHEN c.cdhistor IN (2407) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2406,
           NVL((SUM(CASE WHEN c.cdhistor IN (2409) THEN c.vllanmto ELSE 0 END) -
                SUM(CASE WHEN c.cdhistor IN (2422) THEN c.vllanmto ELSE 0 END)),0) sum_jratz_2409,
           NVL((SUM(CASE WHEN c.cdhistor IN (2411) THEN c.vllanmto ELSE 0 END) -
                SUM(CASE WHEN c.cdhistor IN (2423) THEN c.vllanmto ELSE 0 END)),0) sum_jrmulta_2411,
           NVL((SUM(CASE WHEN c.cdhistor IN (2415) THEN c.vllanmto ELSE 0 END) -
                SUM(CASE WHEN c.cdhistor IN (2416) THEN c.vllanmto ELSE 0 END)),0) sum_jrmora_2415
      FROM craplem c
     WHERE c.cdcooper = prc_cdcooper
       AND c.nrdconta = prc_nrdconta
       AND c.nrctremp = prc_nrctremp
       AND c.cdhistor in (2402,2404,2406,2407,2409,2422,2411,2423,2415,2416);
  --
  CURSOR cr_vlprincipal (prc_cdcooper craplem.cdcooper%TYPE
                        ,prc_nrdconta craplem.nrdconta%TYPE
                        ,prc_nrctremp craplem.nrctremp%TYPE) IS

    SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2401,2405) THEN c.vllanmto ELSE 0 END) -
                SUM(CASE WHEN c.cdhistor IN (2403) THEN c.vllanmto ELSE 0 END)),0) sum_empr_2401 -- Emprestimo

      FROM craplem c
     WHERE c.cdcooper = prc_cdcooper
       AND c.nrdconta = prc_nrdconta
       AND c.nrctremp = prc_nrctremp
       AND c.cdhistor in (2401,2405,2403);
     --
   CURSOR cr_crapepr (prc_cdcooper craplem.cdcooper%TYPE
                        ,prc_nrdconta craplem.nrdconta%TYPE) IS
     SELECT DISTINCT 1 existe
       FROM crapepr epr
      WHERE epr.cdcooper = prc_cdcooper
        AND epr.nrdconta = prc_nrdconta
        AND epr.inprejuz = 1
        AND epr.dtprejuz IS NOT NULL
        AND epr.cdlcremp <> 100;

  vr_flgtrans        BOOLEAN;
  vr_exc_erro        EXCEPTION;
  vr_auxvalor        NUMBER;
  vr_dstransa        VARCHAR2(200);
  vr_nrdrowid        ROWID;
  vr_dtmvtolt        DATE;
  vr_cdhistor1       integer;
  vr_vljuro60        NUMBER;
  vr_vlprinci        NUMBER;
  vr_existe_prejuizo NUMBER(1);
  vr_cdhisatz        INTEGER;
  vr_vljratuz        NUMBER;
  vr_cdhismul        INTEGER;
  vr_vljrmult        NUMBER;
  vr_cdhismor        INTEGER;
  vr_vljrmora        NUMBER;
  vr_existePg        INTEGER;

BEGIN
  vr_flgtrans := FALSE;
  pr_des_reto := 'OK';

  /* Busca data de movimento */
  open  btch0001.cr_crapdat(pr_cdcooper);
  fetch btch0001.cr_crapdat into rw_crapdat;
  close btch0001.cr_crapdat;

  /* Busca informa��es do empr�stimo */
  OPEN C_CRAPEPR(pr_cdcooper
                ,pr_nrdconta
                ,pr_nrctremp);
  FETCH C_CRAPEPR INTO r_crapepr;

  IF C_CRAPEPR%FOUND THEN
    IF f_valida_pagamento_abono(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctremp => pr_nrctremp) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'N�o � poss�vel fazer estorno da tranfer�ncia de preju�zo, existem pagamentos para a conta / contrato informado';

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';
      raise vr_exc_erro;
    END IF;
    IF R_crapepr.inprejuz = 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Contrato n�o esta em prejuizo!';

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';
      raise vr_exc_erro;
    ELSE
      /* Verificar se ocorreram pagamentos */
      vr_dtmvtolt := R_crapepr.dtprejuz;

      /* Busca Lan�amentos Empr�stimos (LEM) */
      FOR rw_craplem in cr_craplem2(vr_dtmvtolt) LOOP
        vr_auxvalor :=0;
        IF r_crapepr.vlprejuz > 0 AND rw_craplem.cdhistor IN (349, 2401,2408,2411) THEN
          vr_auxvalor := r_crapepr.vlprejuz;
        END IF;
      END LOOP;
      --
      IF r_crapepr.dtprejuz = rw_crapdat.dtmvtolt THEN
        /* Atualiza o lote */
        IF vr_auxvalor > 0 THEN
          BEGIN
            UPDATE CRAPLOT
               SET craplot.nrseqdig = craplot.nrseqdig +  1
                  ,craplot.qtcompln = craplot.qtcompln -1
                  ,craplot.qtinfoln = craplot.qtinfoln -1
                  ,craplot.vlcompcr = craplot.vlcompcr + (vr_auxvalor * -1)
                  ,craplot.vlinfocr = craplot.vlinfocr + (vr_auxvalor * -1)
             WHERE craplot.cdcooper = rw_craplem.cdcooper
               AND craplot.cdagenci = rw_craplem.cdagenci
               AND craplot.cdbccxlt = rw_craplem.cdbccxlt
               AND craplot.nrdolote = rw_craplem.nrdolote
               AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
               AND craplot.tplotmov = 5;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar lote!' || SQLERRM;
              pr_des_reto := 'NOK';
              raise vr_exc_erro;
          END;
        END IF;
        /* Excluir lan�amentos da CRAPLEM */
        BEGIN
           DELETE FROM CRAPLEM
            WHERE  craplem.cdcooper = pr_cdcooper
              AND craplem.nrdconta  = pr_nrdconta
              AND craplem.nrctremp  = pr_nrctremp
              AND craplem.dtmvtolt  = rw_crapdat.dtmvtolt
            --and    craplem.cdbccxlt = 200
              AND craplem.cdhistor in (2401, 2402, 2411, 2415, 2405, 2406);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro na exclus�o dos lan�amentos!' || sqlerrm;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
        END;
      ELSE -- Ent�o gerar hist�rico de estorno
        --
        OPEN c_craplcr(pr_cdcooper);
        FETCH c_craplcr INTO r_craplcr;

        IF c_CRAPLCR%NOTFOUND THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Linha de Credito nao Cadastrada!';
          pr_des_reto := 'NOK';
          raise vr_exc_erro;
        END IF;
        CLOSE c_craplcr;

        -- Gerar Lan�amento de estorno para valor Principal
        FOR rw_vlprincipal IN cr_vlprincipal(pr_cdcooper,
                                             pr_nrdconta,
                                             pr_nrctremp) LOOP

          IF rw_vlprincipal.sum_empr_2401 > 0 THEN
            vr_cdhistor1 := 2403;
            vr_vlprinci := rw_vlprincipal.sum_empr_2401;
          END IF;
          --
          IF vr_vlprinci > 0 THEN
            -- Realizar o lan�amento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => pr_cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_cdpactra => pr_cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => vr_cdhistor1
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => vr_vlprinci
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => 0
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
        --
        -- Validar estorno Juros +60
        -- Gerar Lan�amento de estorno para valor Principal
        FOR rw_lanc_lem IN cr_lanc_lem(pr_cdcooper,
                                 pr_nrdconta,
                                 pr_nrctremp) LOOP

          IF rw_lanc_lem.sum_jr60_2402 > 0 THEN
            vr_cdhistor1 := 2404;
            vr_vljuro60 := rw_lanc_lem.sum_jr60_2402;
          END IF;
          --
          IF rw_lanc_lem.sum_jr60_2406 > 0 THEN
            vr_cdhistor1 := 2407;
            vr_vljuro60 := rw_lanc_lem.sum_jr60_2406;
          END IF;
          --
          IF rw_lanc_lem.sum_jratz_2409 > 0 THEN
            vr_cdhisatz := 2422;
            vr_vljratuz := rw_lanc_lem.sum_jratz_2409;
          END IF;
          --
          IF rw_lanc_lem.sum_jrmulta_2411 > 0 THEN
            vr_cdhismul := 2423;
            vr_vljrmult := rw_lanc_lem.sum_jrmulta_2411;
          END IF;
          --
          IF rw_lanc_lem.sum_jrmora_2415 > 0 THEN
            vr_cdhismor := 2416;
            vr_vljrmora := rw_lanc_lem.sum_jrmora_2415;
          END IF;
          --
          IF vr_vljuro60 > 0 THEN
            -- Realizar o lan�amento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor1
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljuro60
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM TR (Juros +60): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Juros Atualizado
          IF vr_vljratuz > 0 THEN
            -- Realizar o lan�amento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhisatz
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljratuz
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM TR (Juros Atualizado): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Multa
          IF vr_vljrmult > 0 THEN
            -- Realizar o lan�amento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhismul
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljrmult
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM TR (valor Multa): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Juros Mora
          IF vr_vljrmora > 0 THEN
            -- Realizar o lan�amento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhismor
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljrmora
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM TR (Juros Mora): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
        --
        BEGIN
          UPDATE crapcyb cyb
             SET cyb.vlsdevan = r_crapepr.vlsdeved
                ,cyb.vlsdeved = r_crapepr.vlsdeved
                ,cyb.qtprepag = r_crapepr.qtprecal
                ,cyb.txmensal = r_crapepr.txmensal
                ,cyb.txdiaria = r_crapepr.txjuremp
                ,cyb.dtprejuz = null
                ,cyb.vlsdprej = 0
                ,cyb.vlpreemp = r_crapepr.vlpreemp
           WHERE cyb.cdcooper = pr_cdcooper
             AND cyb.nrdconta = pr_nrdconta
             AND cyb.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Falha ao atualizar tabela CYBER! PP' || sqlerrm;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
        END;
      END IF; -- Fim Condi��o do dia

      /* Atualizar Emprestimo */
      BEGIN
         UPDATE CRAPEPR
            SET
               -- crapepr.vlsdeved = crapepr.vlprejuz
               -- ,crapepr.vlsdevat = crapepr.vlsdprej
                crapepr.vlprejuz = 0
               ,crapepr.vlsdprej = 0
               ,crapepr.inprejuz = 0
               ,crapepr.inliquid = 0
               ,crapepr.dtprejuz = null
               ,crapepr.vlttmupr = 0
               ,crapepr.vlttjmpr = 0
               ,crapepr.vlpgmupr = 0
               ,crapepr.vlpgjmpr = 0
          where crapepr.cdcooper = pr_cdcooper
          and   crapepr.nrdconta = pr_nrdconta
          and   crapepr.nrctremp = pr_nrctremp
          and   crapepr.inprejuz = 1;

       EXCEPTION
         when others then
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar emprestimo!' || sqlerrm;
             pr_des_reto := 'NOK';
             raise vr_exc_erro;
       END;

       vr_dstransa := 'Data: ' || to_char( pr_dtmvtolt,'DD/MM/YYYY') ||
                      ' - Estorno de transferencia para prejuizo TR - ' ||
                      ', Conta:  ' || pr_nrdconta ||
                      ', Contrato: ' || pr_nrctremp;

       gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dscritic => null
                           ,pr_dsorigem => 'AYLLOS'
                           ,pr_dstransa => vr_dstransa
                           ,pr_dttransa => pr_dtmvtolt
                           ,pr_flgtrans => 1
                           ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => 'CRPS780'
                           ,pr_nrdconta => PR_NRDCONTA
                           ,pr_nrdrowid => VR_NRDROWID);
       vr_flgtrans := TRUE;

    END IF;

    vr_existe_prejuizo := 0 ;
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper,
                                 pr_nrdconta) LOOP
      vr_existe_prejuizo := 1;
    END LOOP;
    --
    IF vr_existe_prejuizo = 0 THEN
      rw_crapdat.dtmvtolt := R_crapepr.dtprejuz;

      pc_reabrir_conta_corrente(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdorigem => 3
                               ,pr_dtprejuz => rw_crapdat.dtmvtolt
                               ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL AND vr_dscritic <> 'OK' THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao desbloquear conta corrente. ' || sqlerrm;

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

          pr_des_reto := 'NOK';
       END IF;
    END IF;
  ELSE
    vr_cdcritic := 0;
    vr_dscritic := 'Erro ao estornar prejuizo emprestimo TR: ' || sqlerrm;

    gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_nrdcaixa => pr_nrdcaixa
                         ,pr_nrsequen => 1 --> Fixo
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic
                         ,pr_tab_erro => pr_tab_erro);

    pr_des_reto := 'NOK';
  END IF;

  CLOSE c_crapepr;

  IF NOT vr_flgtrans THEN
    vr_cdcritic := 0;
    vr_dscritic := 'Erro ao estornar Prejuizo.';

    gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);

    pr_des_reto := 'NOK';

  END IF;
EXCEPTION
   WHEN vr_exc_erro THEN
       -- Desfazer altera��es
       ROLLBACK;
       if vr_dscritic is null then
          vr_dscritic := 'Erro na rotina pc_estorno_trf_prejuizo_TR: ';
       end if;

       -- Retorno n�o OK
       GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dscritic => vr_dscritic
                           ,pr_dsorigem => 'INTRANET'
                           ,pr_dstransa => 'PREJ0001-Estorno transferencia.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => 'crps780'
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
END pc_estorno_trf_prejuizo_TR;

-- Rotina comentada devido a requisito da SM 6 melhria 324
  /* Rotina para estornar transferencia prejuizo CC */
  /*PROCEDURE pc_estorno_trf_prejuizo_CC(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro) IS

          rw_crapdat btch0001.cr_crapdat%rowtype;

          vr_erro                  exception;
          vr_dscritic              varchar2(1000);
          vr_cdcritic              integer;
          vr_nrdrowid              rowid;

     cursor c_busca_prx_lote(pr_dtmvtolt date
                         ,pr_cdcooper number
                         ,pr_cdagenci number) is
        select max(nrdolote) nrdolote
          from craplot
         where craplot.dtmvtolt = pr_dtmvtolt
           and craplot.cdcooper = pr_cdcooper
           and craplot.cdagenci = pr_cdagenci
           and craplot.cdbccxlt = 100
           and craplot.tplotmov = 1;


          vr_nrdolote number;

        begin

          open btch0001.cr_crapdat(pr_cdcooper);
          fetch btch0001.cr_crapdat into rw_crapdat;
          close btch0001.cr_crapdat;

          open c_crapepr(pr_cdcooper, pr_nrdconta, pr_nrdconta);
          fetch c_crapepr into r_crapepr;
          close c_crapepr;

          if nvl(r_crapepr.inprejuz,0) = 0 then
              vr_dscritic := 'N�o � permitido estorno, conta corrente n�o est� em preju�zo: ' || pr_nrdconta;
                raise vr_erro;
          end if;
          --
          IF f_valida_pagamento_abono(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrdconta) THEN
             vr_cdcritic := 0;
             vr_dscritic := 'N�o � poss�vel fazer estorno da tranfer�ncia de preju�zo, existem pagamentos para a conta / contrato informado';
             gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => 1
                                  ,pr_nrsequen => 1 --> Fixo
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_erro => pr_tab_erro);
             pr_des_reto := 'NOK';
             raise vr_erro;

           END IF;
          if r_crapepr.dtprejuz = rw_crapdat.dtmvtolt then
              \* 1) Excluir Lancamento LEM *\
              BEGIN
                delete from craplem t
                where t.cdcooper = pr_cdcooper
                and   t.nrdconta = pr_nrdconta
                and   t.nrctremp = pr_nrdconta
                --and   t.cdhistor in (1036, 1037, 2408)
                and   t.cdhistor in (2408,2411,2415,2412)
                and   t.dtmvtolt = pr_dtmvtolt;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao CRAPLEM, cooper: ' || pr_cdcooper ||
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro;
              END;
              \* excluir lancamento LCM *\
              BEGIN
                delete from craplcm t
                where t.cdcooper = pr_cdcooper
                and   t.nrdconta = pr_nrdconta
                --and   t.cdhistor in (350, 2408, 37, 323)
                and   t.cdhistor in (2408,2412)
                and   t.cdbccxlt = 100
                and   t.dtmvtolt = pr_dtmvtolt;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao CRAPLCM, cooper: ' || pr_cdcooper ||
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro ;
              END;

              \* excluir crappep *\
              BEGIN
                delete from crappep t
                where t.cdcooper = pr_cdcooper
                and t.nrdconta = pr_nrdconta
                and t.nrctremp = pr_nrdconta;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao crappep, cooper: ' || pr_cdcooper ||
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro  ;
              END;

              \* excluir crapepr *\
              BEGIN
                delete from crapepr t
                where t.cdcooper = pr_cdcooper
                and t.nrdconta = pr_nrdconta
                and t.nrctremp = pr_nrdconta;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao crapepr, cooper: ' || pr_cdcooper ||
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro   ;
              END;

              \* excluir crawepr *\
              BEGIN
                delete from crawepr t
                where t.cdcooper = pr_cdcooper
                and t.nrdconta = pr_nrdconta
                and t.nrctremp = pr_nrdconta;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao crawepr, cooper: ' || pr_cdcooper ||
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro;

              END;

              \* excluir crapcyb *\
              BEGIN
                delete from crapcyb t
                where t.cdcooper = pr_cdcooper
                and t.nrdconta = pr_nrdconta
                and t.nrctremp = pr_nrdconta
                and t.cdorigem = 3;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao crapcyb, cooper: ' || pr_cdcooper ||
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro;

              END;

               \* excluir crapcyc *\
              BEGIN
                delete from crapcyc t
                where t.cdcooper = pr_cdcooper
                and t.nrdconta = pr_nrdconta
                and t.nrctremp = pr_nrdconta
                and t.cdorigem = 3;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao crapcyc, cooper: ' || pr_cdcooper ||
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro;

              END;
          else
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => pr_cdagenci
                                                   ,pr_cdbccxlt => 100
                                                   ,pr_cdoperad => '1'
                                                   ,pr_cdpactra => pr_cdagenci
                                                   ,pr_tplotmov => 5
                                                   ,pr_nrdolote => 600029
                                                   ,pr_nrdconta => pr_nrdconta
                                                   ,pr_cdhistor => 2410
                                                   ,pr_nrctremp => pr_nrdconta
                                                   ,pr_vllanmto => R_crapepr.vlprejuz
                                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                                   ,pr_txjurepr => 0
                                                   ,pr_vlpreemp => 0
                                                   ,pr_nrsequni => 0
                                                   ,pr_nrparepr => 0
                                                   ,pr_flgincre => true
                                                   ,pr_flgcredi => false
                                                   ,pr_nrseqava => 0
                                                   ,pr_cdorigem => 7 -- batch
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

                      if vr_dscritic is not null then
                          vr_dscritic := 'Ocorreu erro ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
                          pr_des_reto := 'NOK';
                          raise vr_erro;
                       end if;

              -- cria lancamento LCM
                   if gl_nrdolote is null then
                      open  c_busca_prx_lote(pr_dtmvtolt => RW_CRAPDAT.DTMVTOLT
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdagenci => pr_cdagenci);
                      fetch c_busca_prx_lote into vr_nrdolote;
                      close c_busca_prx_lote;

                      vr_nrdolote := nvl(vr_nrdolote,0) + 1;
                      gl_nrdolote := vr_nrdolote;
                    else
                      vr_nrdolote := gl_nrdolote;
                    end if;

                    empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper
                                       , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       , pr_cdagenci => pr_cdagenci
                                       , pr_cdbccxlt => 100
                                       , pr_cdoperad => user
                                       , pr_cdpactra => pr_cdagenci
                                       , pr_nrdolote => vr_nrdolote
                                       , pr_nrdconta => pr_nrdconta
                                       , pr_cdhistor => 2410
                                       , pr_vllanmto => R_crapepr.vlprejuz
                                       , pr_nrparepr => 1
                                       , pr_nrctremp => pr_nrdconta
                                       , pr_nrseqava => 0
                                       , pr_idlautom => 0
                                       , pr_des_reto => vr_des_reto
                                       , pr_tab_erro => vr_tab_erro );

                if vr_des_reto <> 'OK' then
                   vr_dscritic := 'Erro ao gerar lancamento de conta corrente (LCM):' || vr_des_reto;
                   pr_des_reto := 'NOK';
                   raise vr_erro;
                end if;

                begin
                  update crapepr
                  set    vlsdprej = 0
                  ,      dtprejuz = null
                  where  cdcooper= pr_cdcooper
                  and    nrdconta = pr_nrdconta
                  and    nrctremp = pr_nrdconta;

                exception
                  when others then
                      vr_dscritic := 'Erro ao atualizar Emprestimos :' || vr_des_reto;
                      pr_des_reto := 'NOK';
                      raise vr_erro;

                end;

                begin
                  update crapcyb
                    set  vlsdprej = 0
                         ,flgpreju = 0
                         ,dtprejuz = null
                         ,vlsdeved = R_crapepr.vlprejuz
                  where  cdcooper= pr_cdcooper
                  and    nrdconta = pr_nrdconta
                  and    nrctremp = pr_nrdconta
                  and    cdorigem = 3;
                exception
                  when others then
                      vr_dscritic := 'Erro ao atualizar Cadastro Cyber :' || vr_des_reto;
                      pr_des_reto := 'NOK';
                      raise vr_erro;
                end;

                begin
                  update crapcyb
                    set  dtmancad = rw_crapdat.dtmvtolt
                         ,dtdbaixa = null
                  where  cdcooper= pr_cdcooper
                  and    nrdconta = pr_nrdconta
                  and    nrctremp = pr_nrdconta
                  and    cdorigem = 1;
                exception
                  when others then
                      vr_dscritic := 'Erro ao atualizar Cadastro Cyber :' || vr_des_reto;
                      pr_des_reto := 'NOK';
                      raise vr_erro;
                end;
          end if;

         open  btch0001.cr_crapdat(pr_cdcooper);
         fetch btch0001.cr_crapdat into rw_crapdat;
         close btch0001.cr_crapdat;

         rw_crapdat.dtmvtolt := R_crapepr.dtprejuz;

          -- voltar parametros conta corrente
          pc_reabrir_conta_corrente(  pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_cdorigem => 1
                                      ,pr_dtprejuz => rw_crapdat.dtmvtolt
                                      ,pr_dscritic => vr_dscritic);

           if  vr_dscritic is not null
           and vr_dscritic <> 'OK' then

                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao desbloquear conta corrente. ' || sqlerrm;

                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => 1
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

                pr_des_reto := 'NOK';
           end if;

    exception
       when vr_erro then
                     -- Desfazer altera��es
           ROLLBACK;
           if vr_dscritic is null then
              vr_dscritic := 'Erro na rotina pc_estorno_trf_prejuizo_CC: ';
           end if;

           -- Retorno n�o OK
           GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => 'PROCESSO'
                               ,pr_dscritic => vr_dscritic
                               ,pr_dsorigem => 'INTRANET'
                               ,pr_dstransa => 'PREJ0001-Estorno transferencia CC.'
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 0 --> ERRO/FALSE
                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => 'crps780'
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
          -- Commit do LOG
          COMMIT;
       when others then
          ROLLBACK;
           if vr_dscritic is null then
              vr_dscritic := 'Erro geral rotina pc_estorno_trf_prejuizo_CC: ' || sqlerrm;
           end if;

           -- Retorno n�o OK
           GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => 'PROCESSO'
                               ,pr_dscritic => vr_dscritic
                               ,pr_dsorigem => 'INTRANET'
                               ,pr_dstransa => 'PREJ0001-Estorno transferencia CC.'
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 0 --> ERRO/FALSE
                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => 'crps780'
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
          -- Commit do LOG
          COMMIT;
    end pc_estorno_trf_prejuizo_cc;*/

  PROCEDURE pc_transfere_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                      ,pr_nrctremp   IN VARCHAR2  -- contrato
                                      ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

    /* .............................................................................

    Programa: pc_transfere_prejuizo_web
    Sistema : AyllosWeb
    Sigla   : PREJ
    Autor   : Jean Cal�o - Mout�S
    Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua a transferencia de contratos PP e TR para preju�zo (for�a o envio)
    Observacao: Rotina chamada pela tela Atenda / Presta��es, bot�o "Transferir para preju�zo"

    Alteracoes: 31/01/2018 - Identa��o e Altera��es referente a SM 6 M324
                (Rafael Monteiro - Mout'S)

   ..............................................................................*/
   -- Vari�veis
   vr_cdcooper NUMBER;
   vr_nmdatela VARCHAR2(25);
   vr_nmeacao  VARCHAR2(25);
   vr_cdagenci VARCHAR2(25);
   vr_nrdcaixa VARCHAR2(25);
   vr_idorigem VARCHAR2(25);
   vr_cdoperad VARCHAR2(25);
   vr_nrdrowid ROWID;
   vr_dsorigem VARCHAR2(100);
   vr_dstransa VARCHAR2(500);
   vr_cddepart NUMBER(3);
   vr_tpemprst INTEGER;
   vr_inprejuz INTEGER;
   -- Excess�es
   vr_exc_erro EXCEPTION;

   CURSOR cr_crapope is
     SELECT t.cddepart
       FROM crapope t
      WHERE t.cdoperad = vr_cdoperad;

  BEGIN
    -- define como operacao de fraude (para assumir hist�ricos de opera��o de fraude)
    vr_idfraude := true;

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    OPEN cr_crapope;
    FETCH cr_crapope INTO vr_cddepart;
    CLOSE cr_crapope;

    /* Busca data de movimento */
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    /*Busca informa��es do emprestimo */
    OPEN c_crapepr(pr_cdcooper => vr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrctremp => pr_nrctremp);

    FETCH c_crapepr INTO r_crapepr;
    IF c_crapepr%FOUND THEN
       vr_tpemprst := r_crapepr.tpemprst;
       vr_inprejuz := r_crapepr.inprejuz;
    ELSE
       vr_tpemprst := NULL;
    END IF;
    CLOSE c_crapepr;

    -- Comentado de acordo com nova regra SM 6 M324
    /* RECP0001.pc_verifica_acordo_ativo (pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_cdorigem => 0
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic > 0
        OR vr_dscritic is not null THEN
           pr_des_erro := 'Erro ao verificar acordo: ' || vr_dscritic;
           raise vr_exc_erro;
        END IF;

        IF vr_flgativo = 1 THEN
           pr_des_erro := 'Transferencia para prejuizo nao permitida, emprestimo em acordo.';
           raise vr_exc_erro;
        END IF;*/

      /* Verificar se possui acordo na CRAPCYC */
    OPEN c_crapcyc(vr_cdcooper, pr_nrdconta, pr_nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    CLOSE c_crapcyc;

    IF nvl(vr_flgativo,0) = 1 THEN
      pr_des_erro := 'Transferencia para prejuizo nao permitida, acordo possui motivo 2 -Determina��o Judicial � Preju�zo N�o';
      RAISE vr_exc_erro;
    END IF;


    /* Gerando Log de Consulta */
    vr_dstransa := 'PREJ0001-realizando transferencia para prejuizo, Cooper: ' || vr_cdcooper ||
                    ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                     || r_crapepr.tpemprst || ' Data: ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY');

    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => 'INTRANET'
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;

    IF nvl(vr_inprejuz,2) = 0 THEN
      IF nvl(vr_tpemprst,2) = 1 THEN -- Contrato PP
        pc_transfere_epr_prejuizo_PP(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_idseqttl => 1
                                    ,pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);

      ELSE -- Contrato TR
        pc_transfere_epr_prejuizo_TR(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);

      END IF;
    ELSE
       pr_des_erro := 'Transferencia para prejuizo ja realizada para este contrato!';
       RAISE vr_exc_erro;
    END IF;

    IF vr_des_reto <> 'OK' THEN
      pr_des_erro := 'Erro na transferencia para prejuizo: ' || vr_tab_erro(vr_tab_erro.first).dscritic;
      RAISE vr_exc_erro;
    END IF;

    vr_dstransa := 'PREJ0001-Transfer�ncia para prejuizo, referente contrato: ' || pr_nrctremp ||
                   ', realizada com sucesso.';
    -- Gerando Log de Consulta
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer altera��es
      ROLLBACK;
      IF pr_des_erro IS NULL THEN
        pr_des_erro := 'Erro na rotina pc_transfere_prejuizo: ';
      END IF;
      pr_dscritic := pr_des_erro;
      -- Retorno n�o OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0001-Transferencia for�ada para prejuizo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Desfazer altera��es
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_transfere_prejuizo: '|| SQLERRM;
      pr_dscritic := pr_des_erro;
      pr_cdcritic := 0;
      pr_nmdcampo := '';
      -- Retorno n�o OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'PREJ0001-Transfer�ncia Preju�zo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_transfere_prejuizo_web;

   PROCEDURE pc_estorno_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_idtpoest   in varchar2
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_estorno_prejuizo_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Cal�o - Mout�S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua o estorno de transferencias de contratos PP e TR para preju�zo
      Observacao: Rotina chamada pela tela Atenda / Presta��es, bot�o "Desfazer Preju�zo"
                  Tamb�m � chamada pela tela ESTPRJ (Estorno de preju�zos).

      Alteracoes:

     ..............................................................................*/
     -- Vari�veis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_cddepart    number(3);
     vr_tpemprst    integer;
     vr_inprejuz    integer;

     -- Excess�es
     vr_exc_erro         EXCEPTION;

     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;


     cursor cr_craplem(pr_dtmvtolt in date) is
        select 1
        from   craplem t
        where  cdcooper = vr_cdcooper
        and    nrdconta = pr_nrdconta
        and    nrctremp = pr_nrctremp
        and    dtmvtolt >= trunc(pr_dtmvtolt,'MM')
        and  cdhistor not in (1037   /* Juros Normais */
                               ,1038   /* Juros Normais */
                               ,1732   /* FINANCIAMENTO PRE-FIXADO TRANSFERIDO PARA PREJUIZO */
                               ,1734   /* MULTA MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                               ,1736   /* JUROS MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                               ,1731   /* EMPRESTIMO PRE-FIXADO TRANSFERIDO PARA PREJUIZO  */
                               ,1733   /* MULTA MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */
                               ,1735
                               ,2381
                               ,2397
                               ,2411
                               ,2382
                               ,2383
                               ,2396
                               ,2398
                               ,2401
                               ,2403
                               ,2408
                               ,2409
                               ,2410)
         and nvl((select sum(vllanmto)
                   from  craplem lem
                  where  lem.cdcooper = t.cdcooper
                    and  lem.nrdconta = t.nrdconta
                    and  lem.nrctremp = t.nrctremp
                    and  lem.dtmvtolt >= trunc(pr_dtmvtolt,'MM')
                    and  lem.cdhistor = 2388)   ,0) -
              nvl((select sum(vllanmto)
                   from  craplem lem
                  where  lem.cdcooper = t.cdcooper
                    and  lem.nrdconta = t.nrdconta
                    and  lem.nrctremp = t.nrctremp
                    and  lem.dtmvtolt >= trunc(pr_dtmvtolt,'MM')
                    and  lem.cdhistor = 2392)   ,0) > 0; /* JUROS MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */
      --
    CURSOR cr_trsn_antigo(prc_cdcooper IN craplem.cdcooper%TYPE
                         ,prc_nrdconta IN craplem.nrdconta%TYPE
                         ,prc_nrctremp IN craplem.nrctremp%TYPE) IS
      SELECT 1 existe
        FROM craplem lem
       WHERE lem.cdcooper = prc_cdcooper
         AND lem.nrdconta = prc_nrdconta
         AND lem.nrctremp = prc_nrctremp
         AND lem.cdhistor = 349;
    vr_existePg integer;
    vr_trsn_antigo NUMBER(1);

   BEGIN

     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);


      open cr_crapope;
      fetch cr_crapope into vr_cddepart;
      close cr_crapope;

      --if vr_cddepart not in (3,9,20) then
      --   pr_des_erro := 'Acesso n�o permitido ao usu�rio!';
      --   raise vr_exc_erro;
      --end if;
      /* Busca data de movimento */
      open btch0001.cr_crapdat(vr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;

      vr_trsn_antigo := 0;
      FOR rw_trsn_antigo IN cr_trsn_antigo(vr_cdcooper,
                                           pr_nrdconta,
                                           pr_nrctremp)LOOP
        vr_trsn_antigo := rw_trsn_antigo.existe;

      END LOOP;

      IF vr_trsn_antigo >= 1 THEN
        pr_des_erro := 'Estorno n�o permitido, a transfer�ncia deste contrato foi realizado no modelo antigo';
        RAISE vr_exc_erro;
      END IF;

      /*Busca informa��es do emprestimo */
      open c_crapepr(pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp);

      fetch c_crapepr into r_crapepr;
      if c_crapepr%found then
         vr_tpemprst := r_crapepr.tpemprst;
         vr_inprejuz := r_crapepr.inprejuz;
      else
         vr_tpemprst := null;
      end if;
      close c_crapepr;

      if to_char(r_crapepr.dtprejuz,'yyyymm') < to_char(rw_crapdat.dtmvtolt,'yyyymm') then
         pr_des_erro := 'Impossivel fazer estorno do contrato, pois este contrato foi feito antes do mes vigente';
         raise vr_exc_erro;
      end if;

      /* verifica se houve pagamentos */
      open cr_craplem(rw_crapdat.dtmvtolt);
      fetch cr_craplem into vr_existePg;
      close cr_craplem;

      if nvl(vr_existePg,0) = 1 then
         pr_des_erro := 'Existe Pagamento ou abono ativo para a conta: ' || pr_nrdconta || ', contrato: ' || pr_nrctremp;
         raise vr_exc_erro;
      end if;

      /* Gerando Log de Consulta */
      vr_dstransa := 'PREJ0001-Efetuando estorno da transferencia para prejuizo, Cooper: ' || vr_cdcooper ||
                      ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                       || r_crapepr.tpemprst || ' Data: ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY');


      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;

      IF nvl(vr_inprejuz,2) = 1 THEN
         /*if pr_nrdconta = pr_nrctremp then -- estorno de conta corrente
            pc_estorno_trf_prejuizo_CC(pr_cdcooper => vr_cdcooper
                                          ,pr_cdagenci => vr_cdagenci
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                          ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);
         else*/
        IF nvl(vr_tpemprst,2) = 1 THEN
          pc_estorno_trf_prejuizo_PP(pr_cdcooper => vr_cdcooper
                                   , pr_cdagenci => vr_cdagenci
                                   , pr_nrdcaixa => vr_nrdcaixa
                                   , pr_cdoperad => vr_cdoperad
                                   , pr_nrdconta => pr_nrdconta
                                   , pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                   , pr_nrctremp => pr_nrctremp
                                   , pr_des_reto => vr_des_reto
                                   , pr_tab_erro => vr_tab_erro);

        ELSIF nvl(vr_tpemprst, 2) = 0 THEN
          pc_estorno_trf_prejuizo_TR(pr_cdcooper => vr_cdcooper
                                   , pr_cdagenci => vr_cdagenci
                                   , pr_nrdcaixa => vr_nrdcaixa
                                   , pr_cdoperad => vr_cdoperad
                                   , pr_nrdconta => pr_nrdconta
                                   , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   , pr_nrctremp => pr_nrctremp
                                   , pr_des_reto => vr_des_reto
                                   , pr_tab_erro => vr_tab_erro);
        END IF;
      ELSE
         pr_des_erro := 'Contrato n�o est� em preju�zo !';
         raise vr_exc_erro;
      END IF;

      if vr_des_reto <> 'OK' then
        IF vr_tab_erro.count() > 0 THEN
          -- Atribui cr�ticas �s variaveis
          --vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_des_erro := vr_tab_erro(vr_tab_erro.first).dscritic;
          RAISE vr_exc_erro;
        ELSE
          --vr_cdcritic := 0;
          --vr_dscritic := 'Erro ao Estornar Pagamento '||sqlerrm;
          --raise vr_erro;
         pr_des_erro := 'Erro no estorno da transferencia de prejuizo, ver log!';
         raise vr_exc_erro;
        END IF;

      end if;

      vr_dstransa := 'PREJ0001-Estorno da transfer�ncia para prejuizo, referente contrato: ' || pr_nrctremp ||
                     ', realizada com sucesso.';
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer altera��es
       ROLLBACK;
       if pr_des_erro is null then
          pr_des_erro := 'Erro na rotina pc_estorno_prejuizo: ';
       end if;
       pr_dscritic := pr_des_erro;
       -- Retorno n�o OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => 'INTRANET'
                           ,pr_dstransa => 'PREJ0001-Estorno transferencia para prejuizo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       if pr_dscritic like '%Existe Pagamento%'
       and pr_idtpoest = 'L' -- estorno em lote
       then
          null;
       else
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       end if;
     WHEN OTHERS THEN
       -- Desfazer altera��es
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_estorno_prejuizo: '|| SQLERRM;
       pr_dscritic := pr_des_erro;
       pr_cdcritic := 0;
       pr_nmdcampo := '';
       -- Retorno n�o OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'PREJ0001-Estorno da Transfer�ncia Preju�zo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


   END pc_estorno_prejuizo_web;

  -- Rotina comentada devido a requisito da SM 6 melhria 324
  /*PROCEDURE pc_transfere_prejuizo_CC_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     \* .............................................................................

      Programa: pc_transfere_prejuizo_cc_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Cal�o - Mout�S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua a transferencia de contas correntes para preju�zo (for�a o envio)
      Observacao: Rotina chamada pela tela Atenda / Ocorrencias / Prejuizo, bot�o "Preju�zo"

      Alteracoes:

     ..............................................................................*\
     -- Vari�veis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(100);
     vr_cddepart    number(3);
     vr_tpemprst    integer;
     vr_inprejuz    integer;

     -- Excess�es
     vr_exc_erro         EXCEPTION;

     vr_tab_sald         extr0001.typ_tab_saldos;
     vr_tab_erro         gene0001.typ_tab_erro;
     vr_index            float;
     vr_des_reto         varchar2(5);

     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;

     cursor cr_crapsld(pr_cdcooper number
                      ,pr_nrdconta number) is
        select t.vlsddisp
        from   crapsld t
        where  t.cdcooper = pr_cdcooper
        and    t.nrdconta = pr_nrdconta;

    cursor c_crapcyc(pr_cdcooper number
                    ,pr_nrdconta number
                    ,pr_nrctremp number) is
      select *
        from crapcyc
       where cdcooper = pr_cdcooper
         and nrdconta = pr_nrdconta
         and nrctremp = pr_nrctremp
         and cdorigem = 1
         and flgehvip = 1;

         r_crapcyc c_crapcyc%rowtype;

     vr_vlsddisp number;
   BEGIN

     -- vindo pela transferencia for�ada (tela PREJU), assumir o hist�rico de fraude
     vr_idfraude := true;
     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

      open cr_crapope;
      fetch cr_crapope into vr_cddepart;
      close cr_crapope;

      --if vr_cddepart not in (3,9,20) then
      --   pr_des_erro := 'Acesso n�o permitido ao usu�rio!';
      --   raise vr_exc_erro;
      --end if;
      \* Busca data de movimento *\
      open btch0001.cr_crapdat(vr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;

      \*Busca informa��es do emprestimo *\
      open c_crapepr(pr_cdcooper => vr_cdcooper
                       , pr_nrdconta => pr_nrdconta
                       , pr_nrctremp => pr_nrdconta);

      fetch c_crapepr into r_crapepr;
      if c_crapepr%found then
         vr_tpemprst := r_crapepr.tpemprst;
         vr_inprejuz := r_crapepr.inprejuz;
      else
         vr_tpemprst := null;
         vr_inprejuz := 0;
      end if;
      close c_crapepr;

      \* Gerando Log de Consulta *\
      vr_dstransa := 'PREJ0001-Realizando transferencia (CC) para prejuizo, Conta: ' || pr_nrdconta ||
                      ', indprejuz: ' ||vr_inprejuz || ', vr_tpemprst: ' || vr_tpemprst ;

      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;

      -- verifica se conta � VIP
      open c_crapcyc(pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrdconta );

      fetch c_crapcyc into r_crapcyc;
      if c_crapcyc%found then
         pr_des_erro := 'Conta marcada como VIP (com acordo), nao sera transferida.';
         close c_crapcyc;
         vr_dstransa := 'PREJ0001-conta marcada como VIP';

      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;

         raise vr_exc_erro;
      end if;
      close c_crapcyc;

       extr0001.pc_obtem_saldo_dia(pr_cdcooper => vr_cdcooper,
                                     pr_rw_crapdat => rw_crapdat,
                                     pr_cdagenci => vr_cdagenci,
                                     pr_nrdcaixa => vr_nrdcaixa,
                                     pr_cdoperad => vr_cdoperad,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_vllimcre => 0,
                                     pr_dtrefere => rw_crapdat.dtmvtolt,
                                     pr_flgcrass => false, --pr_flgcrass,
                                     pr_tipo_busca => 'A',
                                     pr_des_reto => vr_des_reto,
                                     pr_tab_sald => vr_tab_sald,
                                     pr_tab_erro => vr_tab_erro);

       IF vr_des_reto <> 'OK' THEN
         IF vr_tab_erro.count() > 0 THEN -- RMM
            -- Atribui cr�ticas �s variaveis
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            pr_des_erro := 'Erro ao buscar saldo atual '||vr_tab_erro(vr_tab_erro.first).dscritic;
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic := 0;
            pr_des_erro := 'Erro ao buscar saldo atual - '||sqlerrm;
            raise vr_exc_erro;
          END IF;
       END IF;

       vr_index := vr_tab_sald.first;

       if vr_index is not null then
          vr_vlsddisp := vr_tab_sald(vr_index).vlsddisp;
       else
          vr_vlsddisp := 1;
       end if;


            IF nvl(vr_vlsddisp,0) = 0 THEN
                pr_des_erro := 'Conta zerada, nao sera transferida.';
                raise vr_exc_erro;
            END IF;

            IF nvl(vr_vlsddisp,0) > 0 THEN
                pr_des_erro := 'Conta com saldo positivo, nao sera transferida.';
                raise vr_exc_erro;
            END IF;

             pc_gera_prejuizo_CC(pr_cdcooper => vr_cdcooper
                               , pr_nrdconta => pr_nrdconta
                               , PR_VLSDDISP => vr_vlsddisp);


      if vr_des_reto <> 'OK' then
         pr_des_erro := 'Erro na transferencia para prejuizo, ver log!';
         raise vr_exc_erro;
      end if;

      vr_dstransa := 'PREJ0001-Transfer�ncia de CC para prejuizo, referente conta: ' || pr_nrdconta ||
                     ', realizada com sucesso.';
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer altera��es
       ROLLBACK;
       if pr_des_erro is null then
          pr_des_erro := 'Erro na rotina pc_transfere_prejuizo_cc: ';
       end if;
       pr_dscritic := pr_des_erro;
       -- Retorno n�o OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => 'INTRANET'
                           ,pr_dstransa => 'PREJ0001-Transferencia for�ada para prejuizo (CC).'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN OTHERS THEN
       -- Desfazer altera��es
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_transfere_prejuizo_cc: '|| SQLERRM;
       pr_dscritic := pr_des_erro;
       pr_cdcritic := 0;
       pr_nmdcampo := '';
       -- Retorno n�o OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'PREJ0001-Transfer�ncia Preju�zo (CC).'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


   END pc_transfere_prejuizo_cc_web;*/


   PROCEDURE pc_consulta_prejuizo_web(pr_dtprejuz in varchar2
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_consulta_prejuizo_web
     Sistema : Rotinas referentes a transferencia para prejuizo
     Sigla   : PREJ
     Autor   : Jean Cal�o (Mout�S)
     Data    : Jun/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os estornos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor dos estornos
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_dtprejuz crapepr.dtprejuz%type
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%type) IS
       SELECT *
         FROM crapepr epr
        WHERE epr.cdcooper = pr_cdcooper
          AND epr.dtprejuz = nvl(pr_dtprejuz, epr.dtprejuz)
          AND epr.nrdconta = decode(pr_nrdconta, 0, epr.nrdconta, pr_nrdconta)
          AND epr.nrctremp = decode(pr_nrctremp, 0, epr.nrctremp, pr_nrctremp)
          AND epr.inprejuz = 1
          AND epr.cdlcremp <> 100;

        rw_crapepr cr_crapepr%rowtype;

      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_contador      PLS_INTEGER := 0;
      vr_idtipo        varchar2(2);
      vr_dstipo        varchar2(25);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_dstransa        varchar2(200);
      vr_dsorigem    VARCHAR2(100);
      vr_nrdrowid    ROWID;
      vr_vlemprst    NUMBER := 0;
    BEGIN

     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);



     vr_dstransa := 'Consulta prejuizo: ' || pr_dtprejuz || ', conta: ' ||
                     pr_nrdconta || ', contrato: ' || pr_nrctremp;

      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => PR_NRDCONTA
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;


      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => vr_cdcooper,
                                   pr_dtprejuz => to_date(pr_dtprejuz,'DD/MM/YYYY'),
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp) LOOP

         if rw_crapepr.tpemprst = 1 then
             vr_idtipo := 'PP';
             vr_dstipo := 'Empr�stimo PP';
             vr_vlemprst := rw_crapepr.vlprejuz;
          end if;

          if rw_crapepr.tpemprst = 0 then
             vr_idtipo := 'TR';
             vr_dstipo := 'Empr�stimo TR';
             vr_vlemprst := rw_crapepr.vlprejuz;
          end if;

          if  rw_crapepr.nrdconta = rw_crapepr.nrctremp
          and rw_crapepr.cdlcremp = 100 then
             vr_idtipo := 'CC';
             vr_dstipo := 'Conta corrente';
             vr_vlemprst := rw_crapepr.vlsdprej;
          end if;

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtprejuz', pr_tag_cont => to_char(rw_crapepr.dtprejuz,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapepr.nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => vr_vlemprst, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idtipo', pr_tag_cont => vr_idtipo, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstipo', pr_tag_cont => vr_dstipo, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_tbepr_estorno */

      IF vr_contador <= 0 THEN
        vr_dscritic := 'Nao existe prejuizo gerado para a conta informada.';
        RAISE vr_exc_saida;

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_consultar_estornos: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

         -- gravar LOG de teste

     vr_dstransa := 'Consulta prejuizo: ' || pr_dtprejuz || ', conta: ' ||
                     pr_nrdconta || ', contrato: ' || pr_nrctremp;

      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => PR_NRDCONTA
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;

    END;

  END pc_consulta_prejuizo_web;

  PROCEDURE pc_importa_arquivo(pr_arquivo in varchar2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)    IS
    /* Rotina: pc_importa_arquivo
       Autor:  Jean (Mout�s)
       Data:   25/07/2017
       Objetivo: Importa arquivo CSV com contas / contratos para transferir para preju�zo


    */
    vr_nm_arquivo varchar2(2000);
    vr_nm_arqlog  varchar2(2000);

    vr_handle_arq utl_file.file_type;
    vr_handle_log utl_file.file_type;

    vr_linha_arq     varchar2(2000);
    vr_linha_arq_log varchar2(2000);

    vr_nrlinha   number;
    vr_nrdconta  number;
    vr_nrctremp  number;
    vr_tipoprej  varchar2(2);
    vr_cdcooper  number;
    vr_cdcooperx varchar2(10);
    vr_nrdcontax varchar2(10);
    vr_nrctrempx varchar2(10);
    vr_tipoprejx varchar2(10);
    vr_indice    number;
    vr_indiceant number;

    vr_cdcritic  number;
    vr_des_erro  varchar2(2000);

    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);
    vr_nmeacao          varchar2(25);
    vr_nmdatela         varchar2(25);

    vr_tpemprst         integer;
    vr_inprejuz         integer;

    vr_rw_crapdat btch0001.rw_crapdat%type;
    vr_qtregist   number;
    vr_index      number;
    vr_tab_erro gene0001.typ_tab_erro;
    vr_endarqui varchar2(100);

    vr_exc_erro exception;
  BEGIN


     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     vr_endarqui:= gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => '/preju/');

    IF pr_arquivo is null then
        vr_nm_arquivo := vr_endarqui || '/prejuizo.csv';
    else
       vr_nm_arquivo := pr_arquivo;
    END IF;

    open btch0001.cr_crapdat(pr_cdcooper => 1);
    fetch btch0001.cr_crapdat into vr_rw_crapdat;
    close btch0001.cr_crapdat;


    vr_nm_arqlog  := vr_endarqui || '/prejuizo_log';

    /* verificar se o arquivo existe */
    if not gene0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) then
      vr_des_erro := 'Erro rotina pc_gera_arq_saldo_devedor - Arquivo: '  || vr_nm_arquivo || ', inexistente!' ;
      pr_cdcritic := 3;
      raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de importa��o */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo
                            ,pr_tipabert => 'R' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_arq --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
      vr_des_erro := 'Rotina pc_gera_arq_saldo_devedor: Erro abertura arquivo importa�ao!' ||
                     sqlerrm;
      pr_cdcritic := 4;
      raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de LOG */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog
                            ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_log --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
       vr_des_erro := 'Rotina pc_gera_arq_saldo_devedor: Erro abertura arquivo LOG!' || sqlerrm;
       pr_cdcritic := 6;
       raise vr_exc_erro;
    end if;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                           pr_des_text => 'Inicio da geracao Arquivo LOG');

    /* Processar linhas do arquivo */
    vr_nrlinha := 1;


      BEGIN
        LOOP
         -- exit when vr_nrlinha = 1019;

          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_arq,
                                       pr_des_text => vr_linha_arq);

          -- valida a partir da linha 2, linha 1 � cabe�alho
          if vr_nrlinha >= 2 then
            -- busca cooperativa
            vr_indice    := instr(vr_linha_arq, ';');
            vr_cdcooperx := substr(vr_linha_arq, 1, vr_indice - 1);
            vr_indiceant := vr_indice;
            vr_cdcooper  := to_number(rtrim(vr_cdcooperx));

            --busca tipo
            vr_indice    := instr(vr_linha_arq, ';', vr_indice + 1);
            vr_tipoprejx  := substr(vr_linha_arq,
                                   vr_indiceant + 1,
                                   vr_indice - vr_indiceant - 1);
            vr_indiceant := vr_indice;
            vr_tipoprej  := rtrim(vr_tipoprejx);

            --busca conta
            vr_indice    := instr(vr_linha_arq, ';', vr_indice + 1);
            vr_nrdcontax  := substr(vr_linha_arq,
                                   vr_indiceant + 1,
                                   vr_indice - vr_indiceant - 1);
            vr_indiceant := vr_indice;
            vr_nrdconta  := to_number(rtrim(vr_nrdcontax));

            --busca contrato
            vr_indice := instr(vr_linha_arq, ';', vr_indice + 1);

            if vr_indice = 0 then
              vr_indice := length(vr_linha_arq) + 1;
            end if;
            vr_nrctrempx := substr(vr_linha_arq,
                                  vr_indiceant + 1,
                                  vr_indice - vr_indiceant - 1);
            vr_nrctrempx := replace(vr_nrctrempx,chr(13),null);

            vr_nrctremp := to_number(rtrim(vr_nrctrempx));

            if vr_nrctremp is null then
              vr_des_erro := 'Erro no arquivo, campo n�mero do contrato n�o est� preenchido!';
              pr_cdcritic := 7;
              raise vr_exc_erro;
            end if;

            -- valida campos do arquivo de importa�ao

            if vr_cdcooper is null then
              vr_des_erro := 'cooperativa n�o informada!';
              pr_cdcritic := 8;
              raise vr_exc_erro;
            end if;

            if vr_nrdconta is null then
              vr_des_erro := 'Conta n�o informada!';
              pr_cdcritic := 9;
              raise vr_exc_erro;
            end if;

            if vr_nrctremp is null then
              vr_des_erro := 'Contrato n�o informado!';
              pr_cdcritic := 10;
              raise vr_exc_erro;
            end if;

            /*if vr_tipoprej = 'CC' then
               open c_crapepr(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => vr_nrdconta
                             ,pr_nrctremp => vr_nrctremp);
               fetch c_crapepr into r_crapepr;
                if c_crapepr%found then
                   vr_inprejuz := 1;
                else
                   vr_inprejuz := 0;
                end if;
                close c_crapepr;

                if vr_inprejuz = 0 then
                   pc_transfere_prejuizo_CC_web(pr_nrdconta => vr_nrdconta
                                              , pr_xmllog => pr_xmllog
                                              , pr_cdcritic => pr_cdcritic
                                              , pr_dscritic => pr_dscritic
                                              , pr_retxml => pr_retxml
                                              , pr_nmdcampo => pr_nmdcampo
                                              , pr_des_erro => vr_des_erro);

                   if vr_des_erro is not null then
                      pr_des_erro := 'Erro ao transferir conta para prejuizo! Conta:' ||
                                       vr_nrdconta || ', cooperativa: ' || vr_cdcooper ;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                               pr_des_text => pr_des_erro);

                   else
                        commit;
                   end if;
               else
                  pr_des_erro := 'Transferencia ja efetuada para esta conta corrente! Conta:' ||
                                   vr_nrdconta || ', cooperativa: ' || vr_cdcooper ;
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                           pr_des_text => pr_des_erro);
               end if;
            end if;*/

            if vr_tipoprej = 'EP' then
               /*Busca informa��es do emprestimo */
                open c_crapepr(pr_cdcooper => vr_cdcooper
                             , pr_nrdconta => vr_nrdconta
                             , pr_nrctremp => vr_nrctremp);

                fetch c_crapepr into r_crapepr;
                if c_crapepr%found then
                   vr_tpemprst := r_crapepr.tpemprst;
                   vr_inprejuz := r_crapepr.inprejuz;
                else
                   vr_tpemprst := null;
                end if;
                close c_crapepr;

                if nvl(vr_inprejuz,2) = 0 then

                   if nvl(vr_tpemprst,2) = 1 then
                      pc_transfere_epr_prejuizo_PP(pr_cdcooper => vr_cdcooper
                                               , pr_cdagenci => vr_cdagenci
                                               , pr_nrdcaixa => vr_nrdcaixa
                                               , pr_cdoperad => vr_cdoperad
                                               , pr_nrdconta => vr_nrdconta
                                               , pr_idseqttl => 1
                                               , pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                               , pr_nrctremp => vr_nrctremp
                                               , pr_des_reto => vr_des_reto
                                               , pr_tab_erro => vr_tab_erro);

                   else
                      if nvl(vr_tpemprst, 2) = 0 then
                         pc_transfere_epr_prejuizo_TR(pr_cdcooper => vr_cdcooper
                                                   , pr_cdagenci => vr_cdagenci
                                                   , pr_nrdcaixa => vr_nrdcaixa
                                                   , pr_cdoperad => vr_cdoperad
                                                   , pr_nrdconta => vr_nrdconta
                                                   , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   , pr_nrctremp => vr_nrctremp
                                                   , pr_des_reto => vr_des_reto
                                                   , pr_tab_erro => vr_tab_erro);
                       end if;
                   end if;
                   commit;
                else
                   pr_des_erro := 'Transferencia para prejuizo ja realizada para este contrato! Conta:' ||
                                   vr_nrdconta || ', contrato: ' || vr_nrctremp || ', cooperativa: ' ||
                                   vr_cdcooper ;
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                           pr_des_text => pr_des_erro);
                end if;

            end if;

          end if;
          vr_nrlinha := vr_nrlinha + 1;
        END LOOP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Fim das linhas do arquivo
          NULL;
      END;

    -- Fecha arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    commit;
  EXCEPTION

    WHEN vr_exc_erro THEN
        pr_des_erro := vr_des_erro;
        pr_dscritic := pr_cdcritic || 'Erro na PREJ0001 verifique o arquivo de LOG: ' || PR_DES_ERRO ;

        pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      raise_application_error(-20150,
                              'erro na rotina PREJ0001.pc_importa_arquivo: ' ||
                              sqlerrm);

  END pc_importa_arquivo;


PROCEDURE pc_tela_busca_contratos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_inprejuz in crapepr.inprejuz%type --> Indicador prejuizo
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_busca_contratos
     Sistema : Rotinas referentes aos contratos de prejuizo
     Sigla   : LIMI
     Autor   : Jean Calao
     Data    : Agosto/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Buscar todos os contratos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/

    DECLARE
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                        pr_nrdconta IN crapepr.nrdconta%TYPE) IS
        SELECT nrctremp,
               dtmvtolt,
               vlemprst,
               qtpreemp,
               vlpreemp,
               cdlcremp,
               cdfinemp
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           and crapepr.inprejuz = pr_inprejuz
           AND ((crapepr.vlsdeved > 0
            and  pr_inprejuz = 0) -- contratos ativos
            or  (crapepr.vlsdeved <= 0
            and  pr_inprejuz = 1)); --contratos em prejuizo

      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      vr_contador      PLS_INTEGER := 0;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Busca todos os emprestimos de acordo com o numero da conta
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => NVL(vr_cdcooper,16),
                                   pr_nrdconta => pr_nrdconta) LOOP

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(rw_crapepr.dtmvtolt,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtpreemp', pr_tag_cont => rw_crapepr.qtpreemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => rw_crapepr.vlemprst, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlpreemp', pr_tag_cont => rw_crapepr.vlpreemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdlcremp', pr_tag_cont => rw_crapepr.cdlcremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdfinemp', pr_tag_cont => rw_crapepr.cdfinemp, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_craplem */

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;


        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PREJ0001.pc_tela_busca_contratos: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;

  END pc_tela_busca_contratos;

  PROCEDURE pc_dispara_email_lote (pr_idtipo   IN VARCHAR2  -- Conta corrente
                                  ,pr_nrctremp IN VARCHAR2  -- contrato
                                  ,pr_xmllog   IN VARCHAR2            --> XML com informa��es de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS

    vr_conteudo   VARCHAR2(4000);
    vr_dscritic   VARCHAR2(4000);
    vr_email_dest VARCHAR2(1000);

    -- Variaveis padrao
    vr_cdcooper  NUMBER;
    vr_cdoperad  VARCHAR2(100);
    vr_nmdatela  VARCHAR2(100);
    vr_nmeacao   VARCHAR2(100);
    vr_cdagenci  VARCHAR2(100);
    vr_nrdcaixa  VARCHAR2(100);
    vr_idorigem  VARCHAR2(100);
    vr_contador  PLS_INTEGER := 0;

    CURSOR c01(pr_cdcooper NUMBER) IS
      SELECT lgm.dscritic
        FROM craplgm lgm
       WHERE lgm.cdcooper = lgm.cdcooper
         AND lgm.dttransa = trunc(SYSDATE)
         AND lgm.dscritic LIKE '%Pagamento%';


  BEGIN
    --
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    vr_conteudo := 'Existem erros na rotina de estorno em lote de prejuizo, conforme criticas abaixo: <br> ' ||
                  'Para essas contas, n�o foi estornado a tranfer�ncia a preju�zo<br>' ;
    vr_contador := 0;
    --
    FOR r01 IN c01(vr_cdcooper) LOOP
      vr_conteudo := vr_conteudo || r01.dscritic || '<br>';
      vr_contador := vr_contador + 1;
    END LOOP;

    vr_dscritic := NULL;
    IF vr_contador > 0 THEN
       --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                ,pr_cdprogra        => 'PREJ0001'
                                ,pr_des_destino     => ''
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB: Estorno em Lote'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
    END IF;
  END pc_dispara_email_lote;
  --

  PROCEDURE pc_controla_exe_job(pr_cdcritic OUT NUMBER,
                                pr_dscritic OUT VARCHAR2) IS
    --
    -- Cursor
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper <> 3;
    --
    -- Variaveis

    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_dthoje   DATE := TRUNC(SYSDATE);
    vr_infimsol INTEGER;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_cdprogra VARCHAR2(40) := 'PC_CONTROLA_EXE_JOB';
    vr_nomdojob VARCHAR2(40) := 'JBP_TRANSFERENCIA_PREJU';
    vr_dserro   VARCHAR2(10000);
    vr_dstexto  VARCHAR2(2000);
    vr_titulo   VARCHAR2(1000);
    vr_destinatario_email VARCHAR2(500);
    vr_idprglog   tbgen_prglog.idprglog%TYPE;
    vr_exc_erro   EXCEPTION;
    vr_dtmvtolt DATE;
    vr_flgerlog    BOOLEAN := FALSE;
    vr_dsvlrgar  VARCHAR2(32000) := '';
    vr_tipsplit  gene0002.typ_split;
    vr_permite_trans NUMBER(1);
    vr_tab_erro  gene0001.typ_tab_erro;
    --
    PROCEDURE pc_controla_log_batch(pr_cdcooper IN NUMBER,
                                    pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      --> Controlar gera��o de log de execu��o dos jobs
      BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
    END pc_controla_log_batch;

  BEGIN
    vr_dscritic := NULL;

    FOR rw_crapcop IN cr_crapcop LOOP

      vr_cdcooper := rw_crapcop.cdcooper;
      --
      vr_dsvlrgar := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdcooper => 0,pr_cdacesso => 'BLOQ_AUTO_PREJ');
      vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';');
      vr_permite_trans := 1;
      FOR i IN vr_tipsplit.first..vr_tipsplit.last LOOP
        IF vr_cdcooper = vr_tipsplit(i) THEN
          vr_permite_trans := 0;
        END IF;
      END LOOP;
      --
      IF vr_permite_trans = 1 THEN
        --
      pc_controla_log_batch(pr_cdcooper => vr_cdcooper,
                            pr_dstiplog => 'I',
                            pr_dscritic => vr_dscritic);
      --
      gene0004.pc_executa_job( pr_cdcooper => vr_cdcooper   --> Codigo da cooperativa
                              ,pr_fldiautl => 1   --> Flag se deve validar dia util
                              ,pr_flproces => 1   --> Flag se deve validar se esta no processo
                              ,pr_flrepjob => 1   --> Flag para reprogramar o job
                              ,pr_flgerlog => 1   --> indicador se deve gerar log
                              ,pr_nmprogra => vr_cdprogra --> Nome do programa que esta sendo executado no job
                              ,pr_dscritic => vr_dserro);

      -- se nao retornou critica chama rotina
      IF trim(vr_dserro) IS NULL THEN

        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat  INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        --Verifica o dia util da cooperativa e caso nao for pula a coop
        vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => vr_cdcooper
                                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                                  ,pr_tipo      => 'A');

        IF vr_dtmvtolt <> rw_crapdat.dtmvtolt THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Data da cooperativa diferente da data atual.';
           RAISE vr_exc_erro;
        END IF;

        pc_crps780(pr_cdcooper => vr_cdcooper,
                   pr_nmdatela => 'job',
                   pr_infimsol => vr_infimsol,
                   pr_cdcritic => vr_cdcritic,
                   pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

          -- Abrir chamado - Texto para utilizar na abertura do chamado e no email enviado
          vr_dstexto := to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_nomdojob || ' --> ' ||
                       'Erro na execucao do programa. Critica: ' || nvl(vr_dscritic,' ');

          -- Parte inicial do texto do chamado e do email
          vr_titulo := '<b>Abaixo os erros encontrados no job ' || vr_nomdojob || '</b><br><br>';

          -- Buscar e-mails dos destinatarios do produto cyber
          vr_destinatario_email := gene0001.fn_param_sistema('CRED',vr_cdcooper,'CYBER_RESPONSAVEL');

          cecred.pc_log_programa( PR_DSTIPLOG      => 'E'           --> Tipo do log: I - in�cio; F - fim; O - ocorr�ncia
                                 ,PR_CDPROGRAMA    => vr_nomdojob   --> Codigo do programa ou do job
                                 ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 -- Parametros para Ocorrencia
                                 ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                                 ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 ,pr_dsmensagem    => vr_dstexto    --> dscritic
                                 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execu��o
                                 ,pr_flabrechamado => 1             --> Abrir chamado (Sim=1/Nao=0)
                                 ,pr_texto_chamado => vr_titulo
                                 ,pr_destinatario_email => vr_destinatario_email
                                 ,pr_flreincidente => 1             --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
                                 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

           RAISE vr_exc_erro;
        END IF;
				
				-- Executa apenas na mensal
				IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtopr, 'MM') THEN
					-- Calcula e debita da corrente corrente em preju�zo os juros remunerat�rios
					CECRED.PREJ0003.pc_calc_juro_prejuizo_mensal(pr_cdcooper => vr_cdcooper
																										,pr_cdcritic =>vr_cdcritic
																										,pr_dscritic =>vr_dscritic);
				END IF;

        -- Resgata cr�ditos bloqueados em contas em preju�zo n�o movimentados h� mais de X dias
        CECRED.PREJ0003.pc_resgata_cred_bloq_preju(pr_cdcooper => vr_cdcooper
				                                          , pr_cdcritic => vr_cdcritic
																									, pr_dscritic => vr_dscritic);
																									
				-- Efetua o pagamento autom�tico do preju�zo com os cr�ditos dispon�veis para opera��es na conta corrente																					
			  CECRED.PREJ0003.pc_pagar_prejuizo_cc_autom(pr_cdcooper => vr_cdcooper
                                                  ,pr_cdcritic =>vr_cdcritic
                                                  ,pr_dscritic =>vr_dscritic
                                                  ,pr_tab_erro =>vr_tab_erro );

        -- Processa liquida��o do preju�zo para contas corrente que tiveram todo o saldo de preju�zo pago                                                  																									
				CECRED.PREJ0003.pc_liquida_prejuizo_cc(pr_cdcooper => vr_cdcooper
                                                  ,pr_cdcritic =>vr_cdcritic
                                                  ,pr_dscritic =>vr_dscritic
                                                  ,pr_tab_erro =>vr_tab_erro );

        -- Transfere contas corrente para preju�zo
        CECRED.PREJ0003.pc_transfere_prejuizo_cc(pr_cdcooper => vr_cdcooper
                                                  ,pr_cdcritic =>vr_cdcritic
                                                  ,pr_dscritic =>vr_dscritic
                                                  ,pr_tab_erro =>vr_tab_erro );

        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

          -- Abrir chamado - Texto para utilizar na abertura do chamado e no email enviado
          vr_dstexto := to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_nomdojob || ' --> ' ||
                       'Erro na execucao do programa. Critica: ' || nvl(vr_dscritic,' ');

          -- Parte inicial do texto do chamado e do email
          vr_titulo := '<b>Abaixo os erros encontrados no job ' || vr_nomdojob || '</b><br><br>';

          -- Buscar e-mails dos destinatarios do produto cyber
          vr_destinatario_email := gene0001.fn_param_sistema('CRED',vr_cdcooper,'CYBER_RESPONSAVEL');

          cecred.pc_log_programa( PR_DSTIPLOG      => 'E'           --> Tipo do log: I - in�cio; F - fim; O - ocorr�ncia
                                 ,PR_CDPROGRAMA    => vr_nomdojob   --> Codigo do programa ou do job
                                 ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 -- Parametros para Ocorrencia
                                 ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                                 ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 ,pr_dsmensagem    => vr_dstexto    --> dscritic
                                 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execu��o
                                 ,pr_flabrechamado => 1             --> Abrir chamado (Sim=1/Nao=0)
                                 ,pr_texto_chamado => vr_titulo
                                 ,pr_destinatario_email => vr_destinatario_email
                                 ,pr_flreincidente => 1             --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
                                 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

           RAISE vr_exc_erro;
        END IF;


      ELSE
        -- N�o retornar o erro - Chamado 831545 - 16/01/2018
        IF vr_dserro NOT LIKE '%Processo noturno nao finalizado para cooperativa%' THEN
          vr_cdcritic := 0;
          vr_dscritic := vr_dserro;
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --
      pc_controla_log_batch(pr_cdcooper => vr_cdcooper,
                            pr_dstiplog => 'F',
                            pr_dscritic => vr_dscritic);
      END IF;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      GENE0001.pc_gera_erro(pr_cdcooper => nvl(vr_cdcooper,3)
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 100
                           ,pr_nrsequen => 1 /** Sequencia **/
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

      --vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      pr_cdcritic := 0;
      pr_dscritic := NULL;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcooper => vr_cdcooper,
                            pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);

      cecred.pc_internal_exception(pr_cdcooper => nvl(vr_cdcooper,3),
                                   pr_compleme => vr_dscritic);

      ROLLBACK;

    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => nvl(vr_cdcooper,3),
                                   pr_compleme => vr_dscritic);

      --pr_dscritic := vr_dscritic;

      -- Erro
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro na rotina pc_gera_dados_cyber. '||sqlerrm;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      GENE0001.pc_gera_erro(pr_cdcooper => nvl(vr_cdcooper,3)
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 100
                           ,pr_nrsequen => 1 /** Sequencia **/
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

      --vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcooper => vr_cdcooper,
                            pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);
      ROLLBACK;

  END pc_controla_exe_job;




END PREJ0001;
/
