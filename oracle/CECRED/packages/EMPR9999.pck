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
  ---------------------------------------------------------------------------------------------------------------
  /* Tratamento de erro */
  vr_exc_erro EXCEPTION;

  /* Descrição e código da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

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
           AND e.Nrctremp = pr_nrctremp
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

  BEGIN
    /* descriçao e código da critica */
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
            -- SE LIMITE OU LIMITE/ADP
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

      /* Se contrato a liquidar já é um refinanciamento, força
       qualificaçao mínima como "Renegociaçao" Reginaldo (AMcom) - Mar/2018 */
      IF rw_crapepr.idquaprc > 1 THEN
        vr_qtdias_atraso := GREATEST(vr_qtdias_atraso, 5);
      END IF;

      vr_indice_epr := vr_vet_liquida.next(vr_indice_epr);
    END LOOP;

    IF vr_auxdias_atraso < vr_qtdias_atraso THEN
      vr_auxdias_atraso := vr_qtdias_atraso;
    END IF;

    -- De 0 a 4 dias de atraso - Renovaçao de Crédito
    IF vr_auxdias_atraso < 5 THEN
      pr_idquapro := 2;
      pr_dsquapro := 'Renovacao de credito';
    -- De 5 a 60 dias de atraso - Renegociaçao de Crédito
    ELSIF vr_auxdias_atraso > 4 and vr_auxdias_atraso < 61 THEN
      pr_idquapro := 3;
      pr_dsquapro := 'Renegociacao de credito';
    -- Igual ou acima de 61 dias - Composiçao de dívida
    ELSIF  vr_auxdias_atraso >= 61 THEN
      pr_idquapro := 4;
      pr_dsquapro := 'Composicao da divida';
    END IF;

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

END EMPR9999;
/
