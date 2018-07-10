CREATE OR REPLACE PACKAGE CECRED.PREJ0003 AS

/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Move  C.C. para prejuízo

   Alteracoes: 27/06/2018 - P450 - Criação de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Criação de procedure para efetuar lançamentos - pc_gera_lcm_cta_prj (Daniel/AMcom)
               28/06/2018 - P450 - Criação de procedure para liquidar conta em prejuizo - pc_liquida_prejuizo_cc (Rangel/Amcom)
..............................................................................*/

 FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE)
  RETURN BOOLEAN;

 /* Rotina para inclusao de C.C. pra prejuizo */
 PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro);


/* Rotina para liquidar prejuizo de Conta Corrente*/
  PROCEDURE pc_liquida_prejuizo_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Coop conectada
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro  );


  -- calcula juros remuneratorios de uma determinada conta em cooperativa
  FUNCTION fn_calcula_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2)
  RETURN NUMBER;   --> Critica

  -- atualiza juros remuneratorios de uma determinada conta em cooperativa
  PROCEDURE pc_atualiza_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2);   --> Critica

   FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER  --> Código da Cooperativa
                           ,pr_nrdconta   IN NUMBER) --> Número da Conta
                            RETURN NUMBER;

   PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper IN NUMBER             --> Código da Cooperativa
                                   ,pr_nrdconta IN NUMBER             --> Número da conta
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

    PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER             --> Número da conta
                                 ,pr_tpope     IN VARCHAR2           --> Tipo de Operação(E-Empréstimo T-Transferência S-Saque)
                                 ,pr_cdcoperad IN NUMBER             --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER             --> Valor do Lançamento
                                 ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);        --> Erros do processo

   PROCEDURE pc_grava_prejuizo_cc(pr_cdcooper       IN crapcop.cdcooper%TYPE   --> Coop conectada
                                 ,pr_nrdconta      IN  crapass.nrdconta%TYPE  --> NR da Conta
                                 ,pr_tpope         IN VARCHAR2                --> Tipo de Operação(N-Normal F-Fraude)
                                 ,pr_cdcritic      OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                 ,pr_dscritic      OUT VARCHAR2               --> Descrição da Critica
                                 ,pr_des_erro      OUT VARCHAR2);


  PROCEDURE pc_canc_bloq_servic(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Coop conectada
                               ,pr_nrdconta       IN crapass.nrdconta%TYPE --> NR da Conta
                               ,pr_dtinc_prejuizo IN crapris.dtinictr%TYPE --> Data que entrou em prejuizo
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Critica encontrada
                               ,pr_dscritic OUT VARCHAR2 );

  PROCEDURE pc_erro_transfere_prejuizo(pr_cdcooper       IN crapcop.cdcooper%TYPE  --> Coop conectada
                                      ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE  --> Data do movimento atual
                                      ,pr_cdcritic     OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic     OUT VARCHAR2              -->Descrição Critica
                                      ,pr_tab_erro     OUT gene0001.typ_tab_erro) ;

PROCEDURE pc_ret_saldo_dia_prej ( pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Coop conectada
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Numero da conta
                                   ,pr_dtmvtolt  IN DATE                          --> Data incio do periodo do prejuizo
                                   ,pr_vldsaldo OUT NUMBER                        --> Retorna valor do saldo
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE         --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2 );
                                   
  PROCEDURE pc_transf_cc_preju_fraude(pr_nrdconta   IN NUMBER             --> Número da conta
                                     ,pr_cdcooper   IN NUMBER             --> Cooperativa conectada                                        
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_dsliquid   IN VARCHAR2           --> Lista de contratos liquidados
                                     ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML                                      
                                     ,pr_des_erro   OUT VARCHAR2);        --> Erros do processo


end PREJ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0003 AS
/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   :Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Transferencia do prejuizo de conta corrente

   Alteracoes: 27/06/2018 - P450 - Criação de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Criação de procedure para efetuar lançamentos - pc_gera_lcm_cta_prj (Daniel/AMcom)
               28/06/2018 - P450 - Contingência para contas não transferidas para prejuízo - Diego Simas - AMcom

..............................................................................*/

  -- clob para conter o dados do excel/csv
   vr_clobarq   CLOB;
   vr_texto_completo  VARCHAR2(32600);
   vr_mailprej  VARCHAR2(1000);

   -- Código do programa
   vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'PREJ0003';
   vr_exc_saida exception;

   vr_cdcritic  NUMBER(3);
   vr_dscritic  VARCHAR2(1000);


  -- Verifica se a conta está em prejuízo
  FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                  , pr_nrdconta craplcm.nrdconta%TYPE)
    RETURN BOOLEAN AS vr_conta_em_prejuizo BOOLEAN;

    CURSOR cr_conta IS
    SELECT ass.inprejuz
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

    vr_inprejuz  crapass.inprejuz%TYPE;
  BEGIN
    OPEN cr_conta;
    FETCH cr_conta INTO vr_inprejuz;
    CLOSE cr_conta;

    vr_conta_em_prejuizo := vr_inprejuz = 1;

    RETURN vr_conta_em_prejuizo;
  END fn_verifica_preju_conta;


  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB,
                                pr_des_dados IN VARCHAR2,
                                pr_fecha_arq IN BOOLEAN DEFAULT FALSE) IS
   BEGIN
      gene0002.pc_escreve_xml(pr_clobdado, vr_texto_completo, pr_des_dados, pr_fecha_arq);
   END;


  PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS
    /* .............................................................................

    Programa: pc_transfere_prejuizo_cc
    Sistema :
    Sigla   : PREJ
    Autor   : Rangel Decker  AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de prejuizo de conta corrente.

    Alteracoes: 21/06/2018 - Popular a tabela TBCC_PREJUIZO quando a conta é transferida para prejuízo.
                            Quantidade de dias em atraso
                            Valor saldo prejuízo Rangel Decker (AMcom)

                28/06/2018 - P450 - Contingência para contas não transferidas para prejuízo - Diego Simas - AMcom

    ..............................................................................*/

    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
      SELECT t.dstextab
      FROM craptab t
      WHERE t.cdcooper = pr_cdcooper
      AND t.nmsistem = 'CRED'
      AND t.tptabela = 'USUARI'
      AND t.cdempres = 11
      AND t.cdacesso = 'RISCOBACEN'
      AND t.tpregist = 000;

     rw_tab cr_tab%ROWTYPE;

    --Busca contas correntes que estão na situação de prejuizo
    CURSOR cr_crapris (pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE,
                       pr_dtmvtolt      crapris.dtrefere%TYPE
                      -- pr_valor_arrasto crapris.vldivida%TYPE
                       ) IS

      SELECT  ris.nrdconta,
              pr_dtmvtolt  dtinc_prejuizo,
              ris.dtdrisco,
              pass.cdsitdct,
              ris.vldivida,
              ris.dtrefere,
              ris.qtdiaatr
       FROM crapris ris,
             crapass pass
       WHERE pass.inprejuz = 0
       AND   ris.cdcooper  = pass.cdcooper
       AND   ris.nrdconta  = pass.nrdconta
       AND   ris.cdcooper  = pr_cdcooper
       AND   ris.inddocto  = 1
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.cdorigem  = 1    -- Conta Corrente
       AND   ris.innivris  = 9    -- Situação H
       AND  (pr_dtmvtolt - ris.dtdrisco) >= 180  -- dias_risco
       AND   ris.qtdiaatr >=180 -- dias_atraso
      /* AND   ris.nrdconta  not in (SELECT epr.nrdconta
                                   FROM   crapepr epr
                                   WHERE epr.cdcooper = ris.cdcooper
                                   AND   epr.nrdconta = ris.nrdconta
                                   AND   epr.inprejuz = 1
                                   AND   epr.cdlcremp = 100)
       AND  ris.nrdconta  not in   (SELECT cyc.nrdconta
                                    FROM   crapcyc cyc
                                    WHERE cyc.cdcooper = ris.cdcooper
                                    AND   cyc.nrdconta = ris.nrdconta
                                    AND   cyc.cdmotcin = 2)*/
       AND   ris.dtrefere =  pr_dtrefere;
       --AND   ris.vldivida > pr_valor_arrasto; -- Materialidade

       rw_crapris  cr_crapris%ROWTYPE;


      vr_des_erro  VARCHAR2(1000);
      rw_crapdat   btch0001.cr_crapdat%ROWTYPE;



      vr_dtrefere_aux  DATE;

      --
      vr_nrdocmto  NUMBER;
      vr_diasrisco NUMBER:= 0;

     vr_tab_erro cecred.gene0001.typ_tab_erro;
     vr_possui_erro   BOOLEAN :=FALSE;

  BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;


      --Verificar data
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utilizar o final do mês como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
      ELSE
          -- Utilizar a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
      END IF;


    --Transfere as contas em prejuizo para a tabela HIST...
    FOR rw_crapris IN cr_crapris(pr_cdcooper
                                ,vr_dtrefere_aux
                                ,rw_crapdat.dtmvtolt
                                --,vr_valor_arrasto
                                ) LOOP

        pc_grava_prejuizo_cc(pr_cdcooper       => pr_cdcooper,
                             pr_nrdconta       => rw_crapris.nrdconta,
                             pr_tpope          => 'N',
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic,
                             pr_des_erro => vr_des_erro);


        -- Testar se houve erro
        IF vr_des_erro <>'OK' THEN

          BEGIN
             vr_possui_erro:=TRUE;

          -- ASSUNTO: Atenção! Houve erro na transferência para prejuízo.
          -- EMAIL: recuperacaodecredito@cecred.coop.br
          -- ARQUIVO ANEXO DEVE CONTER: cooperativa, conta, risco, dias no risco,
          --                            dias de atraso e motivo pelo qual a conta
          --                            não foi transferida.
          -- 'Erro na transferecia de prejuizo (Transferencia Automatica).'

          vr_diasrisco := rw_crapdat.dtmvtolt - rw_crapris.dtdrisco;

          -- Escreve linha CSV
          pc_escreve_clob(vr_clobarq, pr_cdcooper ||';' -- Cooperativa
                        ||gene0002.fn_mask(rw_crapris.nrdconta,'z.zzz.zz9')||';' -- Conta
                        ||'H'||';' -- Risco
                        ||to_char(vr_diasrisco)||';' -- Dias no Risco
                        ||to_char(rw_crapris.qtdiaatr)||';' -- Dias de Atraso
                        ||'Erro na transferecia de prejuizo (Transferencia Automatica).'||vr_dscritic||';' -- Motivo
                        ||chr(13));

          END;


        END IF;

    END LOOP;


    IF vr_possui_erro = TRUE THEN

        pc_erro_transfere_prejuizo(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic,
                                   pr_tab_erro => vr_tab_erro);
    END IF;



  END pc_transfere_prejuizo_cc;
--

 PROCEDURE pc_grava_prejuizo_cc(pr_cdcooper       IN crapcop.cdcooper%TYPE   --> Coop conectada
                                ,pr_nrdconta      IN  crapass.nrdconta%TYPE  --> NR da Conta
                                ,pr_tpope         IN VARCHAR2                --> Tipo de Operação(N-Normal F-Fraude)
                                ,pr_cdcritic      OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic      OUT VARCHAR2               --> Descrição da Critica
                                ,pr_des_erro      OUT VARCHAR2) IS

  --Busca valor de limite de credito do associado
    CURSOR cr_crapass  (pr_cdcooper  crapass.cdcooper%TYPE,
                        pr_nrdconta  crapass.nrdconta%TYPE) IS

     SELECT  a.vllimcre
     FROM crapass a
     WHERE a.cdcooper = pr_cdcooper
     AND a.nrdconta   = pr_nrdconta;

     rw_crapass  cr_crapass%ROWTYPE;

    --Busca os lançamentos de debito 38 e 37 e 57 para conta em prejuizo
    CURSOR cr_crapsld  (pr_cdcooper  crapsld.cdcooper%TYPE,
                        pr_nrdconta  crapsld.nrdconta%TYPE) IS

     SELECT  s.vljuresp
             ,h.cdhistor
             ,h.dshistor
             ,s.nrdconta
     FROM crapsld s,
          craphis h,
          crapass a
     WHERE s.cdcooper = pr_cdcooper
     AND s.nrdconta   = pr_nrdconta
     AND h.cdcooper   = s.cdcooper
     AND h.cdhistor   IN (38,37,57)
     AND a.cdcooper   = s.cdcooper
     AND a.nrdconta   = s.nrdconta
     AND s.vljuresp > 0;

     rw_crapsld  cr_crapsld%ROWTYPE;

    --Busca contas correntes que estão na situação de prejuizo
    CURSOR cr_crapris (pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_nrdconta      crapris.nrdconta%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE,
                       pr_dtmvtolt      crapris.dtrefere%TYPE,
                       pr_valor_arrasto crapris.vldivida%TYPE ) IS

      SELECT  pr_dtmvtolt  dtinc_prejuizo,
              ris.dtdrisco,
              pass.cdsitdct,
              ris.vldivida,
              ris.dtrefere,
              ris.qtdiaatr
       FROM  crapris ris,
             crapass pass
       WHERE pass.inprejuz = 0
       AND   ris.cdcooper  = pass.cdcooper
       AND   ris.nrdconta  = pass.nrdconta
       AND   ris.cdcooper  = pr_cdcooper
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.cdorigem  = 1    -- Conta Corrente
       AND   ris.innivris  = 9    -- Situação H
       AND  (pr_dtmvtolt - ris.dtdrisco) >= 180  -- dias_risco
       AND   ris.qtdiaatr >=180 -- dias_atraso
       AND   ris.nrdconta  not in (SELECT epr.nrdconta
                                   FROM   crapepr epr
                                   WHERE epr.cdcooper = ris.cdcooper
                                   AND   epr.nrdconta = ris.nrdconta
                                   AND   epr.inprejuz = 1
                                   AND   epr.cdlcremp = 100)
       AND  ris.nrdconta  not in   (SELECT cyc.nrdconta
                                    FROM   crapcyc cyc
                                    WHERE cyc.cdcooper = ris.cdcooper
                                    AND   cyc.nrdconta = ris.nrdconta
                                    AND   cyc.cdmotcin = 2)
       AND   ris.dtrefere =  pr_dtrefere
       AND   ris.vldivida > pr_valor_arrasto; -- Materialidade

    rw_crapris  cr_crapris%ROWTYPE;

    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
      SELECT t.dstextab
      FROM craptab t
      WHERE t.cdcooper = pr_cdcooper
      AND t.nmsistem = 'CRED'
      AND t.tptabela = 'USUARI'
      AND t.cdempres = 11
      AND t.cdacesso = 'RISCOBACEN'
      AND t.tpregist = 000;

     rw_tab cr_tab%ROWTYPE;
      --Variaveis de critica
      vr_cdcritic  NUMBER(3);
      vr_dscritic  VARCHAR2(1000);
      vr_des_erro  VARCHAR2(1000);

      --Variavel de exceção
      vr_exc_saida exception;

     --Data da cooperativa
     rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

     vr_valor_arrasto  crapris.vldivida%TYPE;

     -- Variáveis de CPMF
      vr_dtinipmf DATE;
      vr_dtfimpmf DATE;
      vr_txcpmfcc NUMBER(12,6);
      vr_txrdcpmf NUMBER(12,6);
      vr_indabono INTEGER;
      vr_dtiniabo DATE;

      --Variaveis para lançamentos de débito
      vr_rw_craplot  LANC0001.cr_craplot%ROWTYPE;
      vr_tab_retorno LANC0001.typ_reg_retorno; -- REcord com dados retornados pela "pc_gerar_lancamento_conta"
      vr_incrineg   PLS_INTEGER;

      --Tipo da tabela de saldos
      vr_tab_saldo EXTR0001.typ_tab_saldos;

     --Variaveis dos saldos
      vr_vlsddisp  NUMBER:= 0;
      vr_dtrefere_aux  DATE;
      vr_tab_erro cecred.gene0001.typ_tab_erro;

  BEGIN

      pr_des_erro:='OK';
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

     -- Recupera parâmetro da TAB089
      OPEN cr_tab(pr_cdcooper);
      FETCH cr_tab INTO rw_tab;
     -- CLOSE cr_tab;

      -- Se não encontrar
      IF cr_tab%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_tab;
        vr_valor_arrasto :=0;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_tab;
         -- Materialidade(Arrasto)
         vr_valor_arrasto := TO_NUMBER(replace(substr(rw_tab.dstextab, 3, 9), '.', ','));
      END IF;


      --Verificar data
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utilizar o final do mês como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
      ELSE
          -- Utilizar a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
      END IF;

     -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
     FETCH cr_crapass INTO rw_crapass;
     -- Se não encontrar
     IF cr_crapass%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
       CLOSE cr_crapass;
       -- Montar mensagem de critica
       vr_cdcritic:= 651;
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE cr_crapass;
     END IF;

      -- Procedimento padrão de busca de informações de CPMF
      gene0005.pc_busca_cpmf(pr_cdcooper   => pr_cdcooper
                             ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                             ,pr_dtinipmf  => vr_dtinipmf
                             ,pr_dtfimpmf  => vr_dtfimpmf
                             ,pr_txcpmfcc  => vr_txcpmfcc
                             ,pr_txrdcpmf  => vr_txrdcpmf
                             ,pr_indabono  => vr_indabono
                             ,pr_dtiniabo  => vr_dtiniabo
                             ,pr_cdcritic  => vr_cdcritic
                             ,pr_dscritic  => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
          -- Gerar raise
          RAISE vr_exc_saida;
      END IF;


       --Gerar lançamentos para historico 37 e 38 e 57 e atualizar a situação de lançamento
       --automatico para 2 (Pago)
       FOR rw_crapsld IN cr_crapsld(pr_cdcooper,
                                    pr_nrdconta  ) LOOP
             BEGIN
                   --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
                   LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => 1    --rw_craplot.cdagenci
                                                     , pr_cdbccxlt => 100  --rw_craplot.cdbccxlt
                                                     , pr_nrdolote => 8450 --rw_craplot.nrdolote
                                                     , pr_cdhistor => rw_crapsld.cdhistor
                                                     , pr_dtmvtolt => rw_crapdat.dtmvtolt--rw_craplot.dtmvtolt
                                                     , pr_nrdconta => rw_crapsld.nrdconta
                                                     , pr_nrdctabb => rw_crapsld.nrdconta
                                                     , pr_nrdctitg => GENE0002.FN_MASK(rw_crapsld.nrdconta, '99999999')
                                                     , pr_nrdocmto => '999999'||TO_CHAR(rw_crapsld.cdhistor)
                                                     --, pr_nrseqdig => Nvl(rw_craplot.nrseqdig,0) + 1
                                                     , pr_vllanmto => rw_crapsld.vljuresp
                                                     , pr_cdcooper => pr_cdcooper
                                                     , pr_cdcoptfn => 0
                                                     , pr_vldoipmf => TRUNC(rw_crapsld.vljuresp * vr_txcpmfcc,2)

                                                     , pr_inprolot => 1
                                                     , pr_tplotmov => 1
                                                     , pr_tab_retorno => vr_tab_retorno
                                                     , pr_incrineg => vr_incrineg
                                                     , pr_cdcritic => vr_cdcritic
                                                     , pr_dscritic => vr_dscritic
                                                     );

                    IF vr_dscritic IS NOT NULL
                      AND vr_incrineg = 0 THEN -- Erro de sistema/BD
                       RAISE vr_exc_saida;
                    END IF;

                  END;


                  BEGIN

                    UPDATE craplau lau
                    SET   lau.insitlau = 2
                    WHERE lau.cdcooper = pr_cdcooper
                    AND lau.nrdconta = rw_crapsld.nrdconta
                    AND lau.cdhistor in (37,38,57)
                    AND lau.insitlau = 1;

                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_dscritic := 'Erro ao atualizar a tabela craplau. '||SQLERRM;
                       --Sair do programa
                       RAISE vr_exc_saida;
                   END;

          END LOOP;

          --Transfere conta para prejuizo
       BEGIN
             -- Verificar Saldo do cooperado
             extr0001.pc_obtem_saldo_dia(pr_cdcooper =>  pr_cdcooper,
                                         pr_rw_crapdat => rw_crapdat,
                                         pr_cdagenci => 1,
                                         pr_nrdcaixa => 0,
                                         pr_cdoperad => '1',
                                         pr_nrdconta => pr_nrdconta,
                                         pr_vllimcre => rw_crapass.vllimcre,
                                         pr_dtrefere => rw_crapdat.dtmvtolt,
                                         pr_flgcrass => FALSE,
                                         pr_tipo_busca => 'A', -- Tipo Busca(A-dtmvtoan)
                                         pr_des_reto => vr_des_erro,
                                         pr_tab_sald => vr_tab_saldo,
                                         pr_tab_erro => vr_tab_erro);

               --Se ocorreu erro
               IF vr_des_erro = 'NOK' THEN
                -- Tenta buscar o erro no vetor de erro
                IF vr_tab_erro.COUNT > 0 THEN
                  vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapsld.nrdconta;
                ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapsld.nrdconta;
                END IF;

              IF vr_cdcritic <> 0 THEN
                vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' Conta: '||rw_crapsld.nrdconta;
              END IF;

              --Levantar Excecao
              RAISE vr_exc_saida;
            ELSE
              vr_dscritic:= NULL;
            END IF;
            --Verificar o saldo retornado
            IF vr_tab_saldo.Count = 0 THEN
              --Montar mensagem erro
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
              --Levantar Excecao
              RAISE vr_exc_saida;
            ELSE
              vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                             nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
            END IF;
        END;


       OPEN cr_crapris( pr_cdcooper      => pr_cdcooper
                       ,pr_nrdconta      => pr_nrdconta
                       ,pr_dtrefere      => vr_dtrefere_aux
                       ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                       ,pr_valor_arrasto => vr_valor_arrasto );

       FETCH cr_crapris INTO rw_crapris;
       -- Se não encontrar
       IF cr_crapris%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapris;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapris;
       END IF;

       BEGIN
         INSERT INTO TBCC_PREJUIZO(cdcooper
                                  ,nrdconta
                                  ,dtinclusao
                                  ,cdsitdct_original
                                  ,vldivida_original
                                  ,qtdiaatr
                                  ,VLSDPREJ)
         VALUES (pr_cdcooper,
                 pr_nrdconta,
                 rw_crapris.dtinc_prejuizo,
                 rw_crapris.cdsitdct,
                 vr_vlsddisp,
                 rw_crapris.qtdiaatr,
                 vr_vlsddisp);


        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:=0;
            vr_dscritic := 'Erro insert TBCC_PREJUIZO:'||SQLERRM;
          RAISE vr_exc_saida;

       END;

       BEGIN
         UPDATE crapass pass
         SET pass.cdsitdct = 2, -- 2-Em Prejuizo
             pass.inprejuz = 1
         WHERE pass.cdcooper = pr_cdcooper
         AND   pass.nrdconta = pr_nrdconta;

       EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:=0;
            vr_dscritic := 'Erro update CRAPASS:'||SQLERRM;
          RAISE vr_exc_saida;

       END;


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';

   --   ROLLBACK;

  END   pc_grava_prejuizo_cc;

 PROCEDURE pc_canc_bloq_servic(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Coop conectada
                               ,pr_nrdconta       IN crapass.nrdconta%TYPE --> NR da Conta
                               ,pr_dtinc_prejuizo IN crapris.dtinictr%TYPE --> Data que entrou em prejuizo
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Critica encontrada
                               ,pr_dscritic OUT VARCHAR2 ) IS


   --Numero de contrato de limite de credito ativo
   CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                        pr_nrdconta craplim.nrdconta%TYPE   ) IS
      SELECT  lim.nrctrlim
      FROM craplim lim
      WHERE lim.cdcooper = pr_cdcooper
      AND   lim.nrdconta = pr_nrdconta
      AND   lim.insitlim = 2;

    rw_craplim  cr_craplim%ROWTYPE;

    --Cartões magneticos ativos
    CURSOR  cr_crapcrm  (pr_cdcooper crapcrm.cdcooper%TYPE,
                         pr_nrdconta crapcrm.nrdconta%TYPE) IS
     SELECT crm.nrcartao
     FROM crapcrm crm
     WHERE crm.cdcooper = pr_cdcooper
     AND  crm.nrdconta  = pr_nrdconta
     AND  crm.cdsitcar  = 2;

    rw_crapcrm  cr_crapcrm%ROWTYPE;


    vr_tab_msg_confirm cada0003.typ_tab_msg_confirma;
    vr_tab_erro cecred.gene0001.typ_tab_erro;
    vr_des_erro  VARCHAR2(1000);

    vr_cdcritic  NUMBER(3);
    vr_dscritic  VARCHAR2(1000);
    vr_des_reto VARCHAR2(100);
  BEGIN
        --Cancela Internet Banking
         CADA0003.pc_cancelar_senha_internet(pr_cdcooper =>pr_cdcooper                 --Cooperativa
                                             ,pr_cdagenci => 0                          --Agência
                                             ,pr_nrdcaixa => 0                          --Caixa
                                             ,pr_cdoperad => '1'                        --Operador
                                             ,pr_nmdatela => 'PC_CANCELAR_SENHA_INTERNET' --Nome da tela
                                             ,pr_idorigem => 1                          --Origem
                                             ,pr_nrdconta => pr_nrdconta                --Conta
                                             ,pr_idseqttl => 1                          --Sequência do titular
                                             ,pr_dtmvtolt => pr_dtinc_prejuizo          --Data de movimento
                                             ,pr_inconfir => 3                          --Controle de confirmação
                                             ,pr_flgerlog => 0                          --Gera log
                                             ,pr_tab_msg_confirma => vr_tab_msg_confirm
                                             ,pr_tab_erro => vr_tab_erro--Registro de erro
                                             ,pr_des_erro => vr_des_erro);            --Saida OK/NOK

            --Se Ocorreu erro
           IF vr_des_erro <> 'OK' THEN

              --Se possuir erro na tabela
              IF vr_tab_erro.COUNT > 0 THEN

                --Mensagem Erro
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;

              ELSE
                --Mensagem Erro
                vr_dscritic:= 'Erro na pc_cancelar_senha_internet.';
              END IF;

           END IF;

           --Verifica se existe contrato de limite ativo para conta
           OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta );
           FETCH cr_craplim
           INTO rw_craplim;
           -- Se não encontrar
           IF cr_craplim%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craplim;
           ELSE
             --Cancelamento Limite de Credito
           LIMI0002.pc_cancela_limite_credito(pr_cdcooper   => pr_cdcooper                -- Cooperativa
                                               ,pr_cdagenci   => 0                          -- Agência
                                               ,pr_nrdcaixa   => 0                          -- Caixa
                                               ,pr_cdoperad   => '1'                        -- Operador
                                               ,pr_nrdconta   => pr_nrdconta                -- Conta do associado
                                               ,pr_nrctrlim   => rw_craplim.nrctrlim          -- Contrato de Rating
                                               ,pr_inadimp    => 1                          -- 1-Inadimplência 0-Normal
                                               ,pr_cdcritic   => vr_cdcritic                -- Retorno OK / NOK
                                               ,pr_dscritic   => vr_dscritic);              -- Erros do processo


            --Se Ocorreu erro
           IF  vr_cdcritic <>0  OR  vr_dscritic <> ' '  THEN

              --Se possuir erro na tabela
              IF vr_tab_erro.COUNT > 0 THEN

                --Mensagem Erro
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;

              ELSE
                --Mensagem Erro
                vr_dscritic:= 'Erro na pc_cancelar_senha_internet.';
              END IF;

             pr_cdcritic := vr_cdcritic;
             pr_dscritic := vr_dscritic;

           END IF;

           CLOSE cr_craplim;
         END IF;


           --Verifica se existe cartao ativo para a conta
           OPEN cr_crapcrm(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta);
           FETCH cr_crapcrm
           INTO rw_crapcrm;
           -- Se não encontrar

           IF cr_crapcrm%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapcrm;
           ELSE
            -- Bloqueio cartão magnetico
            /*
                cada0004.pc_bloquear_cartao_magnetico( pr_cdcooper => pr_cdcooper, --> Codigo da cooperativa
                                                       pr_cdagenci => 0,  --> Codigo de agencia
                                                       pr_nrdcaixa => 0, --> Numero do caixa
                                                       pr_cdoperad => '1',  --> Codigo do operador
                                                       pr_nmdatela => 'ATENDA', --> Nome da tela
                                                       pr_idorigem => 1,               --> Identificado de origem
                                                                  pr_nrdconta => pr_nrdconta,  --> Numero da conta
                                                                  pr_idseqttl => 1,  --> sequencial do titular
                                                                  pr_dtmvtolt => pr_dtinc_prejuizo,              --> Data do movimento
                                                                  pr_nrcartao => rw_crapcrm.nrcartao, --> Numero do cartão
                                                                  pr_flgerlog => 'S',                 --> identificador se deve gerar log S-Sim e N-Nao
                                                                    ------ OUT ------
                                                                  pr_cdcritic  => vr_cdcritic,
                                                                  pr_dscritic  => vr_dscritic,
                                                                  pr_des_reto  => vr_des_reto);--> OK ou NOK

                */IF vr_des_reto <> 'OK' THEN
                   pr_cdcritic := vr_cdcritic;
                   pr_dscritic := vr_dscritic;
                END IF;

              CLOSE cr_crapcrm;
        END IF ;


  END pc_canc_bloq_servic;

  PROCEDURE pc_erro_transfere_prejuizo(pr_cdcooper       IN crapcop.cdcooper%TYPE  --> Coop conectada
                                      ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE  --> Data do movimento atual
                                      ,pr_cdcritic       OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic       OUT VARCHAR2              -->Descrição Critica
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS
    -- diretorio de geracao do relatorio
     vr_nom_direto  VARCHAR2(100);
     -- clob para conter o dados do excel/csv
     vr_clobarq   CLOB;
     vr_texto_completo  VARCHAR2(32600);
  BEGIN

    -- Diego Simas (AMcom) Contingência para a não transferência de prejuízo
    -- Se por algum erro de processamento não houve transferência de prejuízo
    -- Cria arquivo com as contas para mandar por email para a recuperação de crédito
    -- Email: recuperacaodecredito@cecred.coop.br
    -- INÍCIO

    -- Busca do diretório base da cooperativa para CSV
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    --Montar cabeçalho arquivo csv
    dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);
    vr_texto_completo := 0;
    pc_escreve_clob(vr_clobarq,'Cooperativa; Conta; Risco; Dias no Risco; Dias de atraso; Motivo'||chr(13));

    vr_mailprej := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => pr_cdcooper, pr_cdacesso => 'PREJ0003_EMAILS_PREJU' );

    pc_escreve_clob(vr_clobarq,chr(13),true);

    -- Submeter a geração do arquivo txt puro
    gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                 --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                 --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt         --> Data do movimento atual
                                       ,pr_dsxml     => vr_clobarq                  --> Arquivo XML de dados
                                       ,pr_cdrelato  => 'preju'                     --> Código do relatório
                                       ,pr_dsarqsaid => vr_nom_direto||'/salvar/'|| --> Arquivo final com o path
                                          'preju'||pr_dtmvtolt||'.csv'
                                       ,pr_flg_gerar => 'N'                         --> Geraçao na hora
                                       ,pr_flgremarq => 'N'                         --> Após cópia, remover arquivo de origem
                                       ,pr_dsmailcop => vr_mailprej                 --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => 'Atencao! Houve erro na '
                                          ||'transferencia para prejuizo'           --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => '<p><b>Em anexo a este '    --> HTML corpo do email que enviará o arquivo
                                          ||'e-mail, segue a lista de contas que'
                                          ||' nao foram transferidas para'
                                          ||' prejuizo</b></p>'
                                       ,pr_des_erro  => pr_dscritic);               --> Saída com erro

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_clobarq);
    dbms_lob.freetemporary(vr_clobarq);
    -- Testar se houve erro
    IF pr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;

    -- FIM
    -- Diego Simas (AMcom) Contingência para a não transferência de prejuízo


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);


  END pc_erro_transfere_prejuizo;



  PROCEDURE pc_liquida_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                  ,pr_dscritic OUT VARCHAR2
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS


 /* .............................................................................

    Programa: pc_liquida_prejuizo_cc
    Sistema :
    Sigla   : PREJ
    Autor   : Rangel Decker  AMcom
    Data    : Junho/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :Alteração do Tipo de Conta em prejuízo liquidado

    Alteracoes:
    ..............................................................................*/


  CURSOR cr_conta_liquida (pr_cdooper  IN tbcc_prejuizo.cdcooper%TYPE) IS
   SELECT  tbprj.nrdconta,
           tbprj.cdsitdct_original
   FROM tbcc_prejuizo tbprj
   WHERE tbprj.cdcooper = pr_cdcooper
   AND   tbprj.dtliquidacao IS NULL
   AND  (tbprj.vlsdprej +
         tbprj.vljuprej +  0 + 0) = 0;


  vr_cdcritic  NUMBER(3);
  vr_dscritic  VARCHAR2(1000);
  vr_des_erro  VARCHAR2(1000);
  vr_exc_saida exception;
  vr_sldconta NUMBER;
  vr_nmdcampo VARCHAR2(100);
 -- vr_des_erro VARCHAR2(100);
 vr_xmllog VARCHAR2(100);

 vr_retxml XMLType;

 BEGIN

    --Transfere as contas em prejuizo para a tabela HIST...
    FOR rw_conta_liquida IN cr_conta_liquida(pr_cdcooper) LOOP
          BEGIN
            UPDATE tbcc_prejuizo tbprj
            SET tbprj.dtliquidacao = TRUNC(SYSDATE)
            WHERE tbprj.cdcooper = pr_cdcooper
            AND   tbprj.nrdconta  = rw_conta_liquida.nrdconta;


            EXCEPTION
             WHEN OTHERS THEN
                vr_cdcritic :=99999;
                vr_dscritic := 'Erro ao atualizar a tabela crapass. '||SQLERRM;

                 --Sair do programa
                 RAISE vr_exc_saida;
            END;


          BEGIN

            UPDATE crapass a
            SET a.inprejuz    = 0,
                a.cdsitdct    = rw_conta_liquida.cdsitdct_original
            WHERE a.cdcooper  = pr_cdcooper
            AND   a.nrdconta  = rw_conta_liquida.nrdconta;

            EXCEPTION
             WHEN OTHERS THEN
                vr_cdcritic :=99999;
                vr_dscritic := 'Erro ao atualizar a tabela crapass. '||SQLERRM;

                 --Sair do programa
                 RAISE vr_exc_saida;
            END;

            vr_sldconta:= fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_conta_liquida.nrdconta  );

            IF vr_sldconta > 0 THEN


              pc_gera_lcm_cta_prj(pr_cdcooper  => pr_cdcooper               --> Código da Cooperativa
                                 ,pr_nrdconta  => rw_conta_liquida.nrdconta --> Número da conta
                                 ,pr_tpope     => 'T'                       --> Tipo de Operação(E-Empréstimo T-Transferência S-Saque)
                                 ,pr_cdcoperad => 1                         --> Código do Operador
                                 ,pr_vlrlanc   => vr_sldconta               --> Valor do Lançamento
                                 ,pr_xmllog    => vr_xmllog             --> XML com informações de LOG
                                 ,pr_cdcritic  => vr_cdcritic           --> Código da crítica
                                 ,pr_dscritic  => vr_dscritic           --> Descrição da crítica
                                 ,pr_retxml    => vr_retxml             --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  => vr_nmdcampo           --> Nome do campo com erro
                                 ,pr_des_erro  => vr_des_erro) ;

              IF   vr_cdcritic <> 0 THEN

                 RAISE vr_exc_saida;
              END IF;

            END IF;

    END LOOP;



    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);




 END  pc_liquida_prejuizo_cc;



 -- atualiza juros remuneratorios de uma determinada conta em cooperativa
  FUNCTION fn_calcula_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                      ,pr_nrdconta IN NUMBER          --> Conta
                                      ,pr_dscritic OUT VARCHAR2)    --> Critica
  RETURN NUMBER AS vr_vljuprat NUMBER;

    -- cursores
    CURSOR cr_tbcc_prejuizo (pr_cdcooper   NUMBER
                            ,pr_nrdconta   NUMBER) IS

    SELECT * FROM tbcc_prejuizo
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND dtliquidacao IS NULL;

    rw_tbcc_prejuizo cr_tbcc_prejuizo%ROWTYPE;

    -- variaveis
    vr_pctaxpre             NUMBER  :=0;

    -- Variaveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;

    vr_dstextab             craptab.dstextab%TYPE;
   BEGIN
     -- procura um registro de prejuizo não liquidado
     OPEN cr_tbcc_prejuizo(pr_cdcooper, pr_nrdconta);
     FETCH cr_tbcc_prejuizo INTO rw_tbcc_prejuizo;

     -- se tivermos um registro ainda no liquidado...
     IF cr_tbcc_prejuizo%FOUND THEN
        -- captura valor de juros remuneratório da cooperativa
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPREST'
                                                 ,pr_tpregist => 01);

        IF TRIM(vr_dstextab) IS NULL THEN
          CLOSE cr_tbcc_prejuizo;
          vr_cdcritic := 55;
          RAISE vr_exc_erro;
        ELSE
          vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,6)),0);
        END IF;

       vr_vljuprat := (((rw_tbcc_prejuizo.vlsdprej + rw_tbcc_prejuizo.vljuprej) / 100) * vr_pctaxpre);
     ELSE
       vr_vljuprat := -1; -- nenhum registro de prejuizo encontrado
     END IF;

     CLOSE cr_tbcc_prejuizo;

     RETURN vr_vljuprat;
   EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       -- Variavel de erro recebe erro ocorrido
       IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na PREJ0003.fn_calcula_juros_preju_cc --> ' || SQLERRM;

  END fn_calcula_juros_preju_cc;

 -- atualiza juros remuneratorios de uma determinada conta em cooperativa
  PROCEDURE pc_atualiza_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2) IS   --> Critica
    -- cursores

    -- variaveis
    vr_vljuprat             NUMBER := 0; -- valor do juros prejuizo atualizado

    -- Variaveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;

  BEGIN
    BEGIN
      vr_vljuprat := PREJ0003.fn_calcula_juros_preju_cc(pr_cdcooper
                                                      , pr_nrdconta
                                                      , pr_dscritic);

      UPDATE tbcc_prejuizo SET vljuprej = vr_vljuprat
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND dtliquidacao IS NULL;
    EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro de prejuizo. '||
                        SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
        RAISE vr_exc_erro;
    END;
  EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       -- Variavel de erro recebe erro ocorrido
       IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na PREJ0003.pc_atualiza_juros_remunera --> ' || SQLERRM;

  END pc_atualiza_juros_preju_cc;

  FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                         ,pr_nrdconta   IN NUMBER) --> Número da Conta
                          RETURN NUMBER IS
  BEGIN

    /* .............................................................................

    Programa: fn_sld_conta_prejuizo
    Sistema : Ayllos
    Autor   : Daniel Silva - AMcom
    Data    : Junho/2018                 Ultima atualizacao:

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Retornar o saldo da contra transitória
    Alteracoes:
    ..............................................................................*/

    DECLARE

      -- Busca Saldo
      CURSOR cr_sld IS
        SELECT (select nvl(SUM(decode(his.indebcre, 'D', tr.vllanmto*-1, tr.vllanmto)), 0)
                  from tbcc_prejuizo_lancamento tr
                     , craphis his
                 where tr.cdcooper = pr_cdcooper
                   and tr.nrdconta = pr_nrdconta
                   and tr.dtmvtolt = (select dtmvtolt from crapdat where cdcooper = tr.cdcooper)
                   and tr.cdhistor = his.cdhistor
                   and tr.cdcooper = his.cdcooper)
                /*+
               (select nvl(SUM(\*sld.vlblqprj*\sld.vlblqjud),0) vlsaldo
                  from crapsld sld
                 where sld.cdcooper = &pr_cdcooper
                   and sld.nrdconta = &pr_nrdconta
                   and sld.vlblqjud > 0) VLSALDO*/
           FROM DUAL;
      vr_sld NUMBER := 0;
    BEGIN
      -- Busca da quantidade
      OPEN cr_sld;
      FETCH cr_sld
       INTO vr_sld;
      CLOSE cr_sld;
      -- Retornar quantidade encontrada
      RETURN vr_sld;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_sld_cta_prj;

  PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper IN NUMBER             --> Código da Cooperativa
                                   ,pr_nrdconta IN NUMBER             --> Número da conta
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS

    /* .............................................................................

        Programa: pc_consulta_sld_cta_prj
        Sistema : CECRED
        Sigla   : PREJ
        Autor   : Daniel/AMcom
        Data    : Junho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar saldo de conta em Prejuízo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML


      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'saldo',
                             pr_tag_cont => fn_sld_cta_prj(pr_cdcooper
                                                          ,pr_nrdconta),
                             pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    END pc_consulta_sld_cta_prj;

    PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER             --> Número da conta
                                 ,pr_tpope     IN VARCHAR2           --> Tipo de Operação(E-Empréstimo T-Transferência S-Saque)
                                 ,pr_cdcoperad IN NUMBER             --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER             --> Valor do Lançamento
                                 ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS      --> Erros do processo

/* .............................................................................

        Programa: pc_gera_lcm_cta_prj
        Sistema : CECRED
        Sigla   : PREJ
        Autor   : Daniel/AMcom
        Data    : Junho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para efetuar lançamento em conta Prejuízo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/

      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_incrineg      INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;

      -- Outras
      vr_vlrlanc      NUMBER     := 0;
      vr_nrseqdig     NUMBER     := 0;
      vr_nrdocmto     NUMBER(25) := 0;
      vr_nrdocmto_prj NUMBER(25) := 0;
      vr_cdhistor     NUMBER(5);

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      --vr_nrdrowid ROWID;
      ---------->> CURSORES <<--------
    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END) dtmvtoan
         , dat.dtultdma
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END)-5 dtdelreg
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

    BEGIN

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      -- Se não encontrar calendário
      IF cr_dat%NOTFOUND THEN
        CLOSE cr_dat;
        -- Montar mensagem de critica
        vr_cdcritic  := 794;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_dat;
      END IF;


      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- Consiste saldo com valor do parâmetro
      vr_vlrlanc := fn_sld_cta_prj(vr_cdcooper
                                  ,pr_nrdconta);

      IF vr_vlrlanc < pr_vlrlanc THEN
        pr_cdcritic := 0;
        pr_dscritic := 'A conta'||pr_nrdconta||' não possui saldo para esta operação!';
        RAISE vr_exc_saida;
      END IF;

      -- Consite tipo de operação
      IF pr_tpope NOT IN('T','S') THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Informe uma operação válida: (T-Transferência S-Saque)';
        RAISE vr_exc_saida;
      ELSE
        -- Identifica HISTORICO
        IF pr_tpope = 'T' THEN
          vr_cdhistor := 99; -- *** FALTA DEFINIÇÃO ***
        ELSIF pr_tpope = 'S' THEN
          vr_cdhistor := 98; -- *** FALTA DEFINIÇÃO ***
        END IF;

        -- Buscar Documento TBCC_PREJUIZO_LANCAMENTO
        BEGIN
          SELECT nvl(MAX(t.nrdocmto)+1, 1)
            INTO vr_nrdocmto_prj
            FROM tbcc_prejuizo_lancamento t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.cdhistor = vr_cdhistor
             AND t.dtmvtolt = rw_dat.dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro Buscar Documento TBCC_PREJUIZO_LANCAMENTO';
          RAISE vr_exc_saida;
        END;

        -- Buscar Documento CRAPLCM
        BEGIN
          SELECT NVL(MAX(lcm.nrdocmto)+1, 1)
            INTO vr_nrdocmto
            FROM craplcm lcm
           WHERE lcm.cdcooper = pr_cdcooper
             AND lcm.nrdconta = pr_nrdconta
             AND lcm.dtmvtolt = rw_dat.dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro Buscar Documento CRAPLCM';
          RAISE vr_exc_saida;
        END;
      END IF;

      -- Efetua lancamento de crédito na CRAPLCM(LANC0001)
      -- Buscar sequence
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(SYSDATE, 'DD/MM/RRRR')||';'||
                                '1;100;650010');

      LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_dat.dtmvtolt
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 650010
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdocmto => vr_nrdocmto
                                        ,pr_cdoperad => pr_cdcoperad
                                        ,pr_nrdctabb => pr_nrdconta
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_dtrefere => rw_dat.dtmvtolt
                                        ,pr_vllanmto => pr_vlrlanc
                                        ,pr_cdhistor => 2720
                                        -- OUTPUT --
                                        ,pr_tab_retorno => vr_tab_retorno
                                        ,pr_incrineg => vr_incrineg
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_incrineg = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir lançamento (LANC0001)';
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Efetua lancamento de débito na contra transitória
      BEGIN
        INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                            ,cdagenci
                                            ,nrdconta
                                            ,cdhistor
                                            ,nrdocmto
                                            ,vllanmto
                                            ,dthrtran
                                            ,cdoperad
                                            ,cdcooper
                                            ,dtliberacao)
                                      VALUES(rw_dat.dtmvtolt  -- dtmvtolt
                                            ,1                -- cdagenci
                                            ,100              -- nrdconta
                                            ,vr_cdhistor      -- cdhistor
                                            ,vr_nrdocmto_prj  -- nrdocmto
                                            ,pr_vlrlanc       -- vllanmto
                                            ,rw_dat.dtmvtolt  -- dthrtran
                                            ,pr_cdcoperad     -- cdoperad
                                            ,pr_cdcooper      -- cdcooper
                                            ,rw_dat.dtmvtolt); -- dtliberacao
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro insert TBCC_PREJUIZO_LANCAMENTO:'||SQLERRM;
          RAISE vr_exc_saida;
      END;
      --
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gera_lcm_cta_prj;

PROCEDURE pc_ret_saldo_dia_prej ( pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Coop conectada
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Numero da conta
                                   ,pr_dtmvtolt  IN DATE                          --> Data incio do periodo do prejuizo
                                   ,pr_vldsaldo OUT NUMBER                        --> Retorna valor do saldo
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE         --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2 ) is
    /* .............................................................................

    Programa: pc_ret_saldo_dia_prej
    Sistema :
    Sigla   : PREJ
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar saldo do dia do prejuizo

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----
    --> Buscar saldo anterior
    CURSOR cr_crapsda( pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE,
                       pr_dtmvtolt IN DATE ) IS
      SELECT sda.vlblqjud
        FROM crapsda sda
       WHERE sda.cdcooper = pr_cdcooper
         AND sda.nrdconta = pr_nrdconta
         AND sda.dtmvtolt = pr_dtmvtolt;
    rw_crapsda cr_crapsda%ROWTYPE;

    ---->> VARIAVEIS <<-----
     vr_cdcritic    NUMBER(3);
     vr_dscritic    VARCHAR2(1000);
     vr_exc_erro    EXCEPTION;

     rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
     vr_vldsaldo    NUMBER;


  BEGIN

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;


    IF pr_dtmvtolt = rw_crapdat.dtmvtolt THEN
      vr_vldsaldo  := prej0003.fn_sld_cta_prj(pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => pr_nrdconta);

    ELSE
      --> Buscar saldo anterior
      OPEN cr_crapsda( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtmvtolt => pr_dtmvtolt);
      FETCH cr_crapsda INTO rw_crapsda;
      IF cr_crapsda%NOTFOUND THEN
        CLOSE cr_crapsda;
        vr_dscritic := 'Não há saldo para o dia '||to_char(pr_dtmvtolt,'DD/MM/RRRR');
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapsda;
        vr_vldsaldo := rw_crapsda.vlblqjud;
      END IF;

    END IF;

    pr_vldsaldo := vr_vldsaldo;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao retornar saldo: ' ||SQLERRM;

  END pc_ret_saldo_dia_prej;
  --
  
  PROCEDURE pc_transf_cc_preju_fraude(pr_nrdconta   IN NUMBER             --> Número da conta
                                     ,pr_cdcooper   IN NUMBER             --> Cooperativa conectada                                        
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_dsliquid   IN VARCHAR2           --> Lista de contratos liquidados
                                     ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML                                      
                                     ,pr_des_erro   OUT VARCHAR2) is      --> Erros do processo
                                    
    /* .............................................................................                                     
    Programa: pc_transf_cc_preju_fraude
    Sistema :
    Sigla   : PREJ
    Autor   : Heckmann - AMcom
    Data    : Julho/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Transferir a conta corrente fraude para prejuízo

    Alteracoes:

    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    vr_desmsg  varchar2(1000);         --> Utilizada para informar se a transação funcionou ou não

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posição no XML
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrdrowid ROWID;

    ---->> CURSORES <<-----
    
  begin
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    begin
      pr_des_erro := 'OK';
      vr_desmsg   := 'Transferido a conta corrente fraude para prejuízo';
      pc_grava_prejuizo_cc(pr_cdcooper
                          ,pr_nrdconta
                          ,'F'
                          ,pr_cdcritic
                          ,pr_dscritic
                          ,pr_des_erro); 
                         
     
      if pr_des_erro = 'NOK' then
        vr_desmsg := pr_dscritic; 
      end if;
       
    exception
    when others then

      pr_cdcritic := vr_cdcritic;
      vr_desmsg   := 'Erro ao transferir a conta corrente fraude para prejuízo! ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      
      rollback;
    end;
      

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- CAMPOS
      -- Insere o campo para retorno a tela
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'vr_desmsg',
                               pr_tag_cont => vr_desmsg,
                               pr_des_erro => vr_dscritic); 
     
    BEGIN   
      --Grava log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Transferido a conta corrente fraude para prejuízo'
                          ,pr_dttransa => SYSDATE--pr_dtmvtolt
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => 1--pr_idseqttl
                          ,pr_nmdatela => 'CONTRATO'--pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END;       

    EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    
  end pc_transf_cc_preju_fraude;
  --

END PREJ0003;
/
