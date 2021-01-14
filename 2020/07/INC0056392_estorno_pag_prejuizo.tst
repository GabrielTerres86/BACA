PL/SQL Developer Test script 3.0
574
-- Created on 24/07/2020 by F0032386 
declare 

  vr_dtlanct_estorno DATE := to_date('22/07/2020','DD/MM/RRRR');
  vr_cdcritic             NUMBER(3);
  vr_dscritic             VARCHAR2(1000);
  vr_excerro              EXCEPTION;
  
  vr_nmcooper             VARCHAR2(2000);
  vr_nrdconta             NUMBER;
  vr_nrctremp             NUMBER;
  vr_tipo                 VARCHAR2(2000);
  
  TYPE typ_linhas IS TABLE OF varchar2(4000)
  INDEX BY PLS_INTEGER;
  
  vr_tab_linha  typ_linhas;          
  vr_tab_campos gene0002.typ_split;
  
  CURSOR cr_acordo  (pr_cdcooper   NUMBER,
                     pr_nrdconta   NUMBER,
                     pr_nrctremp   NUMBER) IS
    SELECT a.nracordo,a.cdsituacao
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c
     WHERE a.nracordo = c.nracordo      
       AND a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND c.nrctremp = pr_nrctremp;
  
  rw_acordo cr_acordo%ROWTYPE;
  
  CURSOR cr_crapepr_2(pr_nmrescop VARCHAR2,
                      pr_nrdconta NUMBER,
                      pr_nrctremp NUMBER) IS
    SELECT e.*,
           decode(e.tpemprst,0,'TR',1,'PP',2,'POS') idtipo  
      FROM crapepr e,
           crapcop c
     WHERE e.cdcooper = c.cdcooper
       AND c.nmrescop = pr_nmrescop
       AND e.inprejuz = 1
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp; 
  rw_crapepr_2 cr_crapepr_2%ROWTYPE;
  
  CURSOR cr_craplem (pr_cdcooper NUMBER,
                     pr_nrdconta NUMBER,
                     pr_nrctremp NUMBER,
                     pr_dtmvtolt DATE) IS
    SELECT l.*
      FROM craplem l
     WHERE l.cdcooper = pr_cdcooper
       AND l.dtmvtolt >= pr_dtmvtolt
       AND l.cdhistor = 2702
       AND l.nrdconta = pr_nrdconta
       AND l.nrctremp = pr_nrctremp; 
  rw_craplem cr_craplem%ROWTYPE;
  
  
  CURSOR cr_crapepr IS
    SELECT e.*,
           decode(e.tpemprst,0,'TR',1,'PP',2,'POS') idtipo  
      FROM crapepr e
     WHERE e.cdcooper = 1
       AND e.inprejuz = 1
       AND e.nrdconta = 2444810
       AND e.nrctremp = 95215; 

--  re_crapepr cr_crapepr%ROWTYPE;

  PROCEDURE pc_estorno_pagamento_b (pr_cdcooper IN NUMBER
                                   ,pr_nrdconta   IN NUMBER  -- Conta corrente
                                   ,pr_nrctremp IN NUMBER  -- contrato
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_idtipo   IN varchar2
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   )IS

     /* .............................................................................

      Programa: pc_estorno_prejuizo_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Calão - Mout´S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua o estorno de transferencias de contratos PP e TR para prejuízo
      Observacao: Rotina chamada pela tela Atenda / Prestações, botão "Desfazer Prejuízo"
                  Também é chamada pela tela ESTPRJ (Estorno de prejuízos).

      Alteracoes:

     ..............................................................................*/
     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_cddepart    number(3);
     vr_inprejuz    integer;

     -- Excessões
     vr_exc_erro         EXCEPTION;
     vr_des_reto             VARCHAR2(10);
     vr_tab_erro             gene0001.typ_tab_erro ;
     vr_cdcritic             NUMBER(3);
     vr_dscritic             VARCHAR2(1000);
  
     
     rw_crapdat              btch0001.cr_crapdat%rowtype;

  CURSOR cr_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;

     cursor c_busca_abono is
        select 1
        from   craplem lem
        where  lem.cdcooper = vr_cdcooper
        and    lem.nrdconta = pr_nrdconta
        and    lem.nrctremp = pr_nrctremp
        and    lem.dtmvtolt > rw_crapdat.dtultdma
        and    lem.dtmvtolt <= rw_crapdat.dtultdia
        and    lem.cdhistor = 2391
        and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.nrparepr = lem.nrdocmto
                             and t.cdhistor = 2395); -- abono


        vr_existe_abono integer := 0;

  BEGIN

    vr_cdcooper  := pr_cdcooper;  
    vr_nmdatela  := 'ESTPRJ';
    vr_cdagenci  := 1;
    vr_nrdcaixa  := 100;
    vr_idorigem  := 7;
    vr_cdoperad  := 1;
  
  
    open cr_crapope;
    fetch cr_crapope into vr_cddepart;
    close cr_crapope;

    /* Busca data de movimento */
    open btch0001.cr_crapdat(vr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    close btch0001.cr_crapdat;

    /*Busca informações do emprestimo */
    open cr_crapepr(pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta
                     , pr_nrctremp => pr_nrctremp);

    fetch cr_crapepr into rw_crapepr;
    if cr_crapepr%found then
       vr_inprejuz := rw_crapepr.inprejuz;
    end if;
    close cr_crapepr;

    if to_char(pr_dtmvtolt,'yyyymm') < to_char(rw_crapdat.dtmvtolt,'yyyymm') then
       pr_dscritic := 'Impossivel fazer estorno do contrato, pois este pagamento/abono foi feito antes do mes vigente';
       raise vr_exc_erro;
    end if;

    /* Verifica se possui abono ativo, não pode efetuar o estorno do pagamento */
    open c_busca_abono;
    fetch c_busca_abono into vr_existe_abono;
    close c_busca_abono;

    if nvl(vr_existe_abono,0) = 1 then
       if pr_idtipo not in ('PA','TA','CA') then
         pr_dscritic := 'Não é permitido efetuar o estorno do pagamento pois existe um lançamento de abono.';
         raise vr_exc_erro;
       end if;
    end if;

    /* Gerando Log de Consulta */
    vr_dstransa := 'PREJ0002-Efetuando estorno da transferencia para prejuizo, Cooper: ' || vr_cdcooper ||
                    ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                     || rw_crapepr.tpemprst || ', Data: ' || pr_dtmvtolt || ', indicador: ' || pr_idtipo ;


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
    
    if nvl(vr_inprejuz,2) = 1 then
      PREJ0002.pc_estorno_pagamento(pr_cdcooper => vr_cdcooper
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                           ,pr_tab_erro => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic := 0;
          pr_dscritic := 'Não foi possivel executar estorno do Pagamento do Prejuízo.';
        END IF;
        RAISE vr_exc_erro;
      END IF;
    ELSE
       pr_dscritic := 'Contrato não está em prejuízo !';
       raise vr_exc_erro;
    END IF;

    vr_dstransa := 'PREJ0002-Estorno da transferência para prejuizo, referente contrato: ' || pr_nrctremp ||', realizada com sucesso.';
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
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;
      if pr_dscritic is null then
         pr_dscritic := 'Erro na rotina pc_estorno_prejuizo: ';
      end if;
      pr_dscritic := pr_dscritic;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0002-Estorno transferencia para prejuizo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      pr_dscritic := 'Erro geral na rotina pc_estorno_prejuizo: '|| SQLERRM;
      pr_dscritic := pr_dscritic;
      pr_cdcritic := 0;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'PREJ0002-Estorno da Transferência Prejuízo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
  END pc_estorno_pagamento_b;

BEGIN
  
vr_tab_linha(vr_tab_linha.count) := 'ACREDICOOP;208493;497567;329,43;Baca;329,43;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'ACREDICOOP;90069;224449;156,47;Baca;156,47;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'ACREDICOOP;454664;222629;208,31;Baca;208,31;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'ACREDICOOP;409022;221654;29,12;Baca;29,12;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'ACREDICOOP;704466;234216;1.000,00;Baca;0;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'ACREDICOOP;704466;217622;1.000,00;Baca;1.000,00;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'CIVIA;228672;6627;487,8;Baca;487,8;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'CIVIA;294233;46122;109,27;Baca;109,27;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'CIVIA;237132;241403;1.800,01;Baca;1.800,01;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'CIVIA;79839;16308;472,76;Baca;472,76;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDCREA;219827;26046;500;Baca;500;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDCREA;211370;3900;300;Baca;300;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;22357;15238;662,59;Baca;662,59;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;291633;20416;1.400,23;Baca;1.400,23;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;22357;24274;53,7;Baca;53,7;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;126586;21408;331,31;Baca;331,31;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;108790;22038;282,37;Baca;282,37;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;46370;636301;156,72;Baca;156,72;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;207063;12377;115,45;Baca;115,45;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;39969;46685;418,44;Baca;418,44;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;246999;13741;4.516,45;Baca;4516,45;Estorno Prejuizo - 2386 e 2182 - Despesa de acordo';
vr_tab_linha(vr_tab_linha.count) := 'CREVISC;57169;12170;302,48;Baca;302,48;Estorno Prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'CREVISC;103594;16787;142,29;Baca;142,29;Estorno Prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'EVOLUA;46523;3728;97,41;Baca;;Estorno Prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'TRANSPOCRED;37940;14276;215,68;Baca;215,68;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'TRANSPOCRED;97020;97020;380,35;Baca;380,35;Estorno Prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'TRANSPOCRED;20877;382;2.500,00;Baca;2500;Estorno Prejuizo - 2386 / Precisa realizar abono';
vr_tab_linha(vr_tab_linha.count) := 'TRANSPOCRED;122793;122793;63,86;Baca;63,86;';
vr_tab_linha(vr_tab_linha.count) := 'UNILOS;49476;222084;151,87;Baca;151,87;Estorno Prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'UNILOS;38369;210831;7.427,00;Baca;7.427,00;Estorno Prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'UNILOS;38369;283;1.000,00;Baca;1000;Estorno Prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'UNILOS;38369;211394;11.573,00;Baca;11.573,00;Não é possivel fazer estorno, tem lançamento de abono';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2444810;95215;375,97;baca;375,97;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7254563;548472;561,17;baca;561,17;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9175466;908768;102,37;baca;102,37;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9175466;908776;102,37;baca;102,37;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2617951;437218;215,1;baca;215,1;Estorno prejuizo -2386';

vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6395376;718467;229,45;baca;229,45;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7977336;1002517;443,02;baca;443,02;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2444151;890825;152,54;baca;152,54;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;4091370;644649;140,6;baca;140,6;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6716350;120179;192,96;baca;192,96;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;80023525;464402;320,9;baca;320,9;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;831719;933386;1.346,54;baca;1.346,54;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6869602;486628;275,9;baca;275,9;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9456996;1390535;803,51;baca;803,51;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6301045;401383;334,87;baca;334,87;Estorno prejuizo -2386';
--vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6301045;401383;334,87;baca;334,87;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6590420;189480;565,46;baca;565,46;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6813461;80125;202,08;baca;202,08;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2562200;1180447;903,82;baca;903,82;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6377025;278468;374,75;baca;374,75;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2500965;747635;260,14;baca;260,14;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7518919;740606;627,48;baca;627,48;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2771403;642305;770,52;baca;770,52;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8871949;813104;207,95;baca;207,95;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6465250;276369;327,17;baca;327,17;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7183208;21358;320,63;baca;320,63;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7127154;23863;179,47;baca;179,47;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8575843;999108;98,35;baca;98,35;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7000456;373577;1.293,90;baca;1.293,90;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8575843;999106;98,35;baca;98,35;Estorno prejuizo -2386';
--vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8450250;1113796;263,5;baca;263,5;Estorno prejuizo -2386'; --> ja regularizada
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2195925;639579;406,51;baca;406,51;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6206905;583152;238,66;baca;238,66;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;80059856;641772;234,99;baca;234,99;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2552485;205638;108,98;baca;108,98;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;4034600;635375;235,65;baca;235,65;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7788258;134650;104,54;baca;104,54;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6939988;204507;752,38;baca;752,38;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9358137;1123101;349,13;baca;349,13;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2379392;809694;401,88;baca;401,88;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7513968;681775;253,09;baca;253,09;Estorno prejuizo -2386';
--vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7513968;681775;253,09;baca;253,09;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8366349;854230;74,67;baca;42,73;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8366349;854221;74,67;baca;31,94;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2202026;894041;541,79;baca;541,79;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3997480;750070;292,8;baca;292,8;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7995830;745472;650;baca;650;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6309330;908908;375,24;baca;375,24;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3566846;754220;251,39;baca;251,39;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8645850;828574;159,03;baca;159,03;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6039839;844874;452,02;baca;452,02;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3012280;11205;254,8;baca;254,8;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8054444;1088107;343,64;baca;343,64;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3149331;807236;193,87;baca;193,87;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6925820;456760;300;baca;300;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6190006;41721;190,34;baca;190,34;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6846874;402527;123,73;baca;123,73;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6846874;402528;118,12;baca;118,12;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3162567;33106;175,23;baca;175,23;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2664291;604617;206,27;baca;206,27;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7908750;111631;141,15;baca;141,15;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2798476;1137222;268,02;baca;268,02;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6720145;895515;423,48;baca;423,48;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7247729;171271;258,51;baca;258,51;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2866250;345501;685,67;baca;685,67;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6562361;260187;240,23;baca;240,23;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6414249;673891;401,99;baca;401,99;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7464398;652840;107,75;baca;107,75;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6364896;6364896;280,88;baca;280,88;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7489030;146415;299,49;baca;299,49;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;80035744;162781;452,88;baca;452,88;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2065460;760607;110,81;baca;110,81;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2065460;69018;110,81;baca;110,81;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3964914;38344;502,29;baca;502,29;Estorno prejuizo -2386';
--vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3964914;38344;482,7;baca;482,7;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6996302;333567;170,37;baca;170,37;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7560044;232050;205,9;baca;205,9;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3886891;774709;198,73;baca;198,73;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8111430;1153013;195,85;baca;195,85;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7730586;943343;1.210,18;baca;1.210,18;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3585069;884312;424,73;baca;424,73;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2345285;217828;251,83;baca;251,83;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6872441;452787;353,45;baca;353,45;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8751099;973870;199,95;baca;199,95;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8751099;805670;199,95;baca;199,95;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6786545;403668;385,77;baca;385,77;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3616045;110900;245,24;baca;245,24;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3905110;404738;297,85;baca;297,85;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9033173;889210;149,01;baca;149,01;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9571825;1416982;105,26;baca;105,26;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6580688;38315;101,57;baca;101,57;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6666477;68569;108,67;baca;108,67;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8399670;180262;241,14;baca;241,14;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6519008;1034054;974,14;baca;974,14;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2805057;277748;211,45;baca;211,45;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8510903;549639;268,96;baca;268,96;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8019215;797717;1.175,35;baca;1175,35;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8974829;853666;254,4;baca;254,4;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7447728;512573;808,83;baca;808,83;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8016640;384123;254,75;baca;254,75;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8317186;1040803;187,7;baca;187,7;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6736882;455000;1.079,86;baca;1079,86;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7622694;93212;300;baca;300;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7401779;1654415;129,35;baca;129,35;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6265677;174344;231,79;baca;231,79;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2960222;39441;109,18;baca;109,18;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9716890;1347777;245,44;baca;245,44;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;10094644;1653651;280;baca;280;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7403445;7403445;142,09;baca;142,09;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7566662;1356761;219,96;baca;219,96;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7482388;1109742;1.562,00;baca;1562;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9497102;1196794;1.312,69;baca;1312,69;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;979066;181398;243,86;baca;243,86;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8062412;528280;294,43;baca;294,43;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7030355;7030355;139,2;baca;417,6;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7614365;598114;211,14;baca;211,14;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8976023;1030493;383,76;baca;383,76;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;930121;610161;576,49;baca;576,49;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3812650;1128887;269,92;baca;269,92;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9956280;1530544;261,14;baca;261,14;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7793650;1145045;177,15;baca;177,15;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6679692;1024436;500,84;baca;500,84;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2199904;130468;1.000,00;baca;1000;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7910355;424939;210,18;baca;210,18;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6374840;630589;135,72;baca;135,72;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7802471;1596296;1.358,93;baca;1358,93;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9399992;1000258;286,06;baca;286,06;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9167935;1222907;650;baca;650;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6865941;1223439;3.000,00;baca;3.000,00;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7286031;111532;749,76;baca;749,76;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7117884;132701;300;baca;300;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6829171;262296;300;baca;300;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3983790;536992;3.000,00;baca;3000;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2746131;761254;623,01;Baca;623,01;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;4084144;1587106;250;Baca;250;Estorno prejuizo - 2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2625679;1494011;3.000,00;Baca;3000;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;173819;64505;175,48;baca;175,48;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;3850625;117113;154,09;baca;154,09;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;73423;32967;227,8;baca;227,8;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;323837;57432;338,65;baca;338,65;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;308625;57568;199,51;baca;199,51;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;79855;24751;248,98;baca;248,98;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;228818;228818;75,37;baca;75,37;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;382396;89539;206,47;baca;206,47;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;3076245;58966;500;baca;500;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;2958147;8713;730;baca;730;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;125458;67240;261,87;baca;261,87;Estorno prejuizo -2386';
vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7286031;111532;749,76;baca;749,76;Estorno prejuizo -2386';

FOR i IN vr_tab_linha.first..vr_tab_linha.count-1 LOOP
  
  vr_tab_campos := gene0002.fn_quebra_string(pr_string => vr_tab_linha(i), 
                                             pr_delimit => ';');
                                             
                            
  vr_nmcooper := vr_tab_campos(1);
  vr_nrdconta := vr_tab_campos(2);
  vr_nrctremp := vr_tab_campos(3);
  vr_tipo     := vr_tab_campos(5);
  
  IF upper(vr_tipo) = 'BACA' THEN
    OPEN cr_crapepr_2(pr_nmrescop => vr_nmcooper,
                      pr_nrdconta => vr_nrdconta,
                      pr_nrctremp => vr_nrctremp);
    FETCH cr_crapepr_2 INTO rw_crapepr_2;                    
    IF cr_crapepr_2%NOTFOUND THEN
      dbms_output.put_line('NAO ENCONTRADO -->'||vr_tab_linha(i));  
      CLOSE cr_crapepr_2;
      continue;
    ELSE      
      dbms_output.put_line(vr_tab_linha(i));   
      CLOSE cr_crapepr_2;
      
      OPEN cr_craplem (pr_cdcooper => rw_crapepr_2.cdcooper,
                       pr_nrdconta => rw_crapepr_2.nrdconta,
                       pr_nrctremp => rw_crapepr_2.nrctremp,
                       pr_dtmvtolt => vr_dtlanct_estorno);
      FETCH cr_craplem INTO rw_craplem;
      IF cr_craplem%FOUND THEN
        CLOSE cr_craplem;
        dbms_output.put_line('NAO ENCONTRADO -->'||vr_tab_linha(i));  
        continue; 
      ELSE
        CLOSE cr_craplem;
      END IF;  
    END IF;
    
    rw_acordo := NULL;
    OPEN cr_acordo  (pr_cdcooper   => rw_crapepr_2.cdcooper,
                     pr_nrdconta   => rw_crapepr_2.nrdconta,
                     pr_nrctremp   => rw_crapepr_2.nrctremp);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;
    
    BEGIN
      UPDATE tbrecup_acordo a  
         SET a.cdsituacao = 3 -- mudar para cancelado temporariamente
       WHERE a.nracordo = rw_acordo.nracordo;  
    END;
        
    pc_estorno_pagamento_b (pr_cdcooper => rw_crapepr_2.cdcooper
                           ,pr_nrdconta => rw_crapepr_2.nrdconta
                           ,pr_nrctremp => rw_crapepr_2.nrctremp
                           ,pr_dtmvtolt => vr_dtlanct_estorno
                           ,pr_idtipo   => rw_crapepr_2.idtipo  
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                                     );

    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_excerro;
    END IF; 
    
     BEGIN
      UPDATE tbrecup_acordo a  
         SET a.cdsituacao = rw_acordo.cdsituacao -- voltar para o valor original
       WHERE a.nracordo = rw_acordo.nracordo;  
    END;
  
  
  END IF;
      
  
END LOOP;
  COMMIT;
  
  
EXCEPTION
   WHEN vr_excerro THEN    
     ROLLBACK; 
     raise_application_error(-20500,vr_cdcritic ||'-'||vr_dscritic);
end;
0
6
pr_dtmvtolt
rw_crapdat.dtmvtolt
pr_nrdconta
r_craplem.nrdocmto
pr_nrctremp
pr_nrdolote
