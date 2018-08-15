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
  
  PROCEDURE pc_busca_numero_contrato(pr_cdcooper     IN tbepr_consignado_contrato.cdcooper%TYPE        --> Codigo da cooperativa
                                    ,pr_nrdconta     IN tbepr_consignado_contrato.nrdconta%TYPE        --> Conta do Associado
                                    ,pr_nrctremp     IN tbepr_consignado_contrato.nrctremp%TYPE Default 0 --> Número do Contrato
                                    ----------------- > OUT < ----------------------
                                    ,pr_existenr     OUT INTEGER                                     --> 1 (Verdadeiro) 0 (Falso) para se existe contrato/ proposta
                                    ,pr_cdcritic     OUT INTEGER                                       --> Código da crítica
                                    ,pr_dscritic     OUT VARCHAR2                                      --> Descrição da crítica
                                    );

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

  PROCEDURE pc_busca_numero_contrato(pr_cdcooper     IN tbepr_consignado_contrato.cdcooper%TYPE        --> Codigo da cooperativa
                                    ,pr_nrdconta     IN tbepr_consignado_contrato.nrdconta%TYPE        --> Conta do Associado
                                    ,pr_nrctremp     IN tbepr_consignado_contrato.nrctremp%TYPE Default 0 --> Número do Contrato
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
      vr_dscritic:='Informação de INSS Consignável não encontrada.';
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
      /* busca a descriçao da crítica baseado no código */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma crítica predefina para um codigo de retorno, estabele um texto genérico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'erro geral na rotina pc_retorna_inss_consignavel: ' || sqlerrm;
    
    /*  fecha a procedure */   
   END pc_retorna_inss_consignavel;
   
  PROCEDURE pc_retorna_desc_inss ( pr_cdbeninss  IN tbgen_tipo_beneficio_inss.cdbeninss%TYPE --> Codigo beneficio inss
                                  -------------------------------- OUT --------------------------- 
                                  ,pr_dsbeninss OUT tbgen_tipo_beneficio_inss.dsbeninss%TYPE --> Descrição beneficio inss
                                  ,pr_cdcritic  OUT INTEGER            --> Codigo da critica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descricao da critica
                                 ) IS
     /*.............................................................................
         programa:  pc_retorna_desc_inss
         sistema :
         sigla   : cred
         autor   : Robson Nunes (GFT)
         data    : 20/06/2018                         ultima atualizacao: 20/07/2018

         dados referentes ao programa: retorna a descrição do beneficio inss

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
      /* busca a descriçao da crítica baseado no código */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma crítica predefina para um codigo de retorno, estabele um texto genérico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'Erro geral na rotina pc_retorna_desc_inss: ' || sqlerrm;
    
  END pc_retorna_desc_inss;


END EMPR9999;
/
