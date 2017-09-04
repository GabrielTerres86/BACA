create or replace procedure cecred.pc_crps011 (pr_cdcooper in crapcop.cdcooper%type,   --> COOPERATIVA SOLICITADA
                                               pr_flgresta in pls_integer,             --> FLAG PADRÃO PARA UTILIZAÇÃO DE RESTART
                                               pr_stprogra out pls_integer,            --> SAÍDA DE TERMINO DA EXECUÇÃO
                                               pr_infimsol out pls_integer,            --> SAÍDA DE TERMINO DA SOLICITAÇÃO
                                               pr_cdcritic out crapcri.cdcritic%type,  --> CRITICA ENCONTRADA
                                               pr_dscritic out varchar2) is            --> TEXTO DE ERRO/CRITICA ENCONTRADA
  /* .............................................................................

     /*************************************************************************
        Magui: no informe de rendimentos do ano, campo saldo em 31/12/AAAA e
        alimentado com o campo CRAPDIR.VLSDAPLI. Sendo que aplicacoes RDCPOS
        tera um calculo diferente para o informe de rendimento:
        his 528(aplicacao feita) + 532(rendimento) - 533(irrf) - 534(resgate).
     *************************************************************************/

  /* .............................................................................
   Programa: PC_CRPS011                           (Antigo: Fontes/crps011.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/92.                       Ultima atualizacao: 04/09/2017

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Fazer o ajuste dos saldos anuais no ultimo processo do ano.
               Atende a solicitacao 007 (Anual de atualizacao).
               Alterado para atender a rotina anual de capital.

   Alteracoes: 08/12/94 - Alterado para acumular o total das aplicacaoes RDCA
                          no final do ano (Edson).

               20/03/95 - Alterado para tratar crapcot.qtextmfx e qtandmfx
                          (Deborah).

               21/07/95 - Alterado para alimentar o campo dtmvtolt na crapdir
                          com a data do movimento (Odair).

               18/12/95 - Alterado para utilizar rotina includes/aplicacao.i
                          (Edson).

               01/04/96 - Tratar craprpp (poupanca programada) (Odair).

               22/11/96 - Leitura do RDA calcular o saldo em funcao do tpaplica
                          acumulando no total aplicado o saldo do rdcaII (Odair)

               18/02/98 - Alterado para tratar valores abonados (Deborah).

               24/12/98 - Alterado para mover as 12 ocorrencias do vlrenrda
                          do crapcot para o crapdir (Deborah).

               22/01/99 - Alterado para mover e zerar novos campos ref IOF
                          do crapcot(Deborah).

               26/01/99 - Tratar novos campos do crapcot (Deborah).

               16/03/2000 - Tratar vlrentot no crapcot e no crapdir (Deborah).

               09/05/2002 - Calcular o saldo da poupanca programada ate o
                            final de dezembro lendo os lancamentos apos o
                            aniversario de dezembro (Deborah).

               11/04/2003 - Atualiza crapdir.vlcpmfpg (Margarete).

               28/11/2003 - Atualizar novos campos crapcot para IR (Margarete).

               09/01/2004 - Atualizacao campo crapcot.qtippmfx antes da
                            atualizacao campo crapdir.vlcpmfpg(Mirtes).

               23/06/2004 - Tratar novos campos no crapsld (Edson).

               22/09/2004 - Incluido historicos 496(CI)(Mirtes)
               16/12/2004 - Incluicos campos crapcot.vlirajus/
                                             crapdir.vlirajus(Mirtes)

               28/06/2005 - Alimentado campo cdcooper da tabela crapdir
                            (Diego).

               06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               19/06/2007 - Incluido novos campos crapdir.vlirfrdc e
                            crapdir.vlrenrdc (Elton).

               26/07/2007 - Efetuar leitura das aplicacoes RDC (David).

               05/02/2009 - Atualizar novo campo crapcot.vlpvardc (David).

               16/11/2010 - Alterada a forma de calculo do saldo de aplicacoes
                            RDCPOS (Henrique).

               14/03/2012 - Atualizar novos campos vlrencot e vlirfcot ref.
                            rendimento sobre o capital (Diego).

               02/04/2012 - Atualizacao do campo crapdir.vlcapmes com
                            crapcot.vlcapmes e novo calculo para atualizacao
                            do campo crapcot.vlpvardc (David).

               01/08/2013 - Tratamento para o Bloqueio Judicial (Ze).

               30/01/2014 - Conversão Progress >> PLSQL (Jean Michel).

               05/08/2014 - Ajuste de geração de registro anual de sobras e DIRF.
                            (Reinert)

               22/10/2015 - Totalizar o valor tarifado por conta anualmente na tabela
                            TBCOTAS_TARIFAS_PAGAS e limpar campos mensais para
                            utilização no ano seguinte. (Dionathan)

               27/06/2016 - M325 - Tributacao Juros ao Capital (Guilherme/SUPERO)
               
               04/09/2017 - M439 Modificado cursor cr_craplct para somar todos 
                            lancamentos dentro do ano (Tiago/Thiago #635669)
    ............................................................................ */

  ------------------------------- CURSORES ---------------------------------

  -- Buscar os dados da cooperativa
  cursor cr_crapcop (pr_cdcooper in craptab.cdcooper%type) is
    select crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl
      from crapcop
     where cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%rowtype;
  -- Registro para armazenar as datas atuais
  rw_crapdat         btch0001.cr_crapdat%rowtype;
  -- Busca dos dados de ufir
  cursor cr_crapmfx(pr_cdcooper crapcop.cdcooper%type,
                    pr_dtmvtolt crapdat.dtmvtolt%type) is
    select mfx.cdcooper,
           mfx.dtmvtolt,
           mfx.vlmoefix
      from crapmfx mfx
     where mfx.cdcooper = pr_cdcooper
       and mfx.dtmvtolt = pr_dtmvtolt
       and mfx.tpmoefix = 2;
  rw_crapmfx cr_crapmfx%rowtype;
  -- Busca aplicações RDCA e saldo RDCPOS
  cursor cr_craprda (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrctares in crapass.nrdconta%type) is
    select rda.cdcooper,
           rda.nrdconta,
           rda.insaqtot,
           rda.tpaplica tpaplica_rda,
           rda.vlsdrdca,
           rda.nraplica,
           rda.dtiniper,
           rda.dtfimper,
           rda.inaniver,
           rda.dtmvtolt,
           rda.rowid rowid_rda,
           dtc.tpaplica tpaplica_dtc,
           dtc.tpaplrdc,
           nvl(sum(decode(lap.cdhistor,
                          528, lap.vllanmto,
                          532, lap.vllanmto,
                          533, lap.vllanmto * -1,
                          534, lap.vllanmto * -1)), 0) vllanmto
      from craplap lap,
           crapdtc dtc,
           craprda rda
     where rda.cdcooper = pr_cdcooper
       and rda.nrdconta > pr_nrctares
       and rda.insaqtot = 0
       and lap.cdcooper (+) = rda.cdcooper
       and lap.nrdconta (+) = rda.nrdconta
       and lap.nraplica (+) = rda.nraplica
       and lap.cdhistor (+) in (528, 532, 533, 534)
       and dtc.cdcooper(+) = rda.cdcooper
       and dtc.tpaplica(+) = rda.tpaplica
     group by rda.cdcooper,
              rda.nrdconta,
              rda.insaqtot,
              rda.tpaplica,
              rda.vlsdrdca,
              rda.nraplica,
              rda.dtiniper,
              rda.dtfimper,
              rda.inaniver,
              rda.dtmvtolt,
              rda.rowid,
              dtc.tpaplica,
              dtc.tpaplrdc;
  -- Calcula provisao de aplicacoes RDC no ano
  cursor cr_craplap (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrctares in crapass.nrdconta%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select cdcooper,
           nrdconta,
           sum(decode(cdhistor,
                      474, vllanmto,
                      529, vllanmto,
                      475, vllanmto,
                      532, vllanmto,
                      463, vllanmto * -1,
                      531, vllanmto * -1,
                      0)) vllanmto_lap
      from craplap
     where cdcooper = pr_cdcooper
       and nrdconta > pr_nrctares
       and cdhistor in (474, 529, 475, 532, 463, 531)
       and dtmvtolt between trunc(pr_dtmvtolt, 'yyyy') and pr_dtmvtolt
     group by cdcooper, nrdconta;

  -- Rendimento sobre o CAPITAL
  cursor cr_craplct (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrctares in crapass.nrdconta%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    SELECT juros.cdcooper,
           juros.nrdconta,         
           '926' cdhistor_juros,
           SUM(juros.vllanmto) vllanmto_juros,
           '922' cdhistor_ir,
           SUM(ir.vllanmto) vllanmto_ir
      FROM craplct juros,
           craplct ir
     WHERE juros.cdcooper = pr_cdcooper
       AND juros.nrdconta > pr_nrctares
       AND juros.cdhistor = 926
       AND trunc(juros.dtmvtolt,'yyyy') = trunc(pr_dtmvtolt, 'yyyy') --> Dentro do ano
       -- Podendo ou não haver IR sobre os juros
       AND ir.cdcooper (+) = juros.cdcooper
       AND ir.nrdconta (+) = juros.nrdconta
       AND ir.dtmvtolt (+) = juros.dtmvtolt
       AND ir.cdhistor (+) = 922
    GROUP BY juros.cdcooper, juros.nrdconta, '926', '922';
       
  -- Calcula saldo da poupanca programada
  cursor cr_craprpp (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrctares in crapass.nrdconta%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    -- Agrupa os saldos das poupanças programadas + seus lançamentos por conta
    select rppt.cdcooper
          ,rppt.nrdconta
          ,sum(nvl(rppt.vlsdrdpp,0))+sum(nvl(rppt.vllanmto_lpp,0)) vlsdrdpp
      from( -- Busca das poupanças programadas, seu saldo e seu total de lançamentos
            select rpp.cdcooper,
                   rpp.nrdconta,
                   rpp.nrctrrpp,
                   rpp.vlsdrdpp,
                   sum(decode(lpp.cdhistor,150,lpp.vllanmto,lpp.vllanmto * -1)) vllanmto_lpp
              from craplpp lpp,
                   craprpp rpp
             where rpp.cdcooper = pr_cdcooper
               and rpp.nrdconta > pr_nrctares
               and lpp.cdcooper (+) = rpp.cdcooper
               and lpp.nrdconta (+) = rpp.nrdconta
               and lpp.nrctrrpp (+) = rpp.nrctrrpp
               and lpp.cdhistor (+) in (150, 158, 496)
               and lpp.dtrefere (+) >= add_months(trunc(pr_dtmvtolt, 'yyyy'), 12)
             group by rpp.cdcooper
                     ,rpp.nrdconta
                     ,rpp.nrctrrpp
                     ,rpp.vlsdrdpp) rppt
     group by rppt.cdcooper
             ,rppt.nrdconta;
  -- Calcula saldo dos emprestimos no final do ano
  cursor cr_crapepr (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrctares in crapass.nrdconta%type) is
    select cdcooper,
           nrdconta,
           sum(vlsdeved) vlsdeved
      from crapepr
     where cdcooper = pr_cdcooper
       and nrdconta > pr_nrctares
     group by cdcooper, nrdconta;
  -- Busca o registro de saldo dos associados
  cursor cr_crapsld(pr_cdcooper crapcop.cdcooper%type,
                    pr_nrctares crapass.nrdconta%type) is
    select sld.cdcooper,
           sld.nrdconta,
           sld.qtipamfx,
           sld.vlblqjud,
           sld.vlsdmesa,
           sld.qtsmamfx,
           sld.smposano##1,
           sld.smposano##2,
           sld.smposano##3,
           sld.smposano##4,
           sld.smposano##5,
           sld.smposano##6,
           sld.smposano##7,
           sld.smposano##8,
           sld.smposano##9,
           sld.smposano##10,
           sld.smposano##11,
           sld.smposano##12,
           sld.smespano##1,
           sld.smespano##2,
           sld.smespano##3,
           sld.smespano##4,
           sld.smespano##5,
           sld.smespano##6,
           sld.smespano##7,
           sld.smespano##8,
           sld.smespano##9,
           sld.smespano##10,
           sld.smespano##11,
           sld.smespano##12,
           sld.smblqano##1,
           sld.smblqano##2,
           sld.smblqano##3,
           sld.smblqano##4,
           sld.smblqano##5,
           sld.smblqano##6,
           sld.smblqano##7,
           sld.smblqano##8,
           sld.smblqano##9,
           sld.smblqano##10,
           sld.smblqano##11,
           sld.smblqano##12,
           sld.smnegano##1,
           sld.smnegano##2,
           sld.smnegano##3,
           sld.smnegano##4,
           sld.smnegano##5,
           sld.smnegano##6,
           sld.smnegano##7,
           sld.smnegano##8,
           sld.smnegano##9,
           sld.smnegano##10,
           sld.smnegano##11,
           sld.smnegano##12,
           sld.rowid rowid_sld,
           cot.vlabonrd,
           cot.vlabiord,
           cot.vlabonpp,
           cot.vlabiopp,
           cot.vlrenrpp,
           cot.qtrenmfx,
           cot.qtjexcmf,
           cot.qtipmmfx,
           cot.vlrenrda##1,
           cot.vlrenrda##2,
           cot.vlrenrda##3,
           cot.vlrenrda##4,
           cot.vlrenrda##5,
           cot.vlrenrda##6,
           cot.vlrenrda##7,
           cot.vlrenrda##8,
           cot.vlrenrda##9,
           cot.vlrenrda##10,
           cot.vlrenrda##11,
           cot.vlrenrda##12,
           cot.vlrentot##1,
           cot.vlrentot##2,
           cot.vlrentot##3,
           cot.vlrentot##4,
           cot.vlrentot##5,
           cot.vlrentot##6,
           cot.vlrentot##7,
           cot.vlrentot##8,
           cot.vlrentot##9,
           cot.vlrentot##10,
           cot.vlrentot##11,
           cot.vlrentot##12,
           cot.vlabnapl_ir##1,
           cot.vlabnapl_ir##2,
           cot.vlabnapl_ir##3,
           cot.vlabnapl_ir##4,
           cot.vlabnapl_ir##5,
           cot.vlabnapl_ir##6,
           cot.vlabnapl_ir##7,
           cot.vlabnapl_ir##8,
           cot.vlabnapl_ir##9,
           cot.vlabnapl_ir##10,
           cot.vlabnapl_ir##11,
           cot.vlabnapl_ir##12,
           cot.vlirabap##1,
           cot.vlirabap##2,
           cot.vlirabap##3,
           cot.vlirabap##4,
           cot.vlirabap##5,
           cot.vlirabap##6,
           cot.vlirabap##7,
           cot.vlirabap##8,
           cot.vlirabap##9,
           cot.vlirabap##10,
           cot.vlirabap##11,
           cot.vlirabap##12,
           cot.vlrenrpp_ir##1,
           cot.vlrenrpp_ir##2,
           cot.vlrenrpp_ir##3,
           cot.vlrenrpp_ir##4,
           cot.vlrenrpp_ir##5,
           cot.vlrenrpp_ir##6,
           cot.vlrenrpp_ir##7,
           cot.vlrenrpp_ir##8,
           cot.vlrenrpp_ir##9,
           cot.vlrenrpp_ir##10,
           cot.vlrenrpp_ir##11,
           cot.vlrenrpp_ir##12,
           cot.vlrirrpp##1,
           cot.vlrirrpp##2,
           cot.vlrirrpp##3,
           cot.vlrirrpp##4,
           cot.vlrirrpp##5,
           cot.vlrirrpp##6,
           cot.vlrirrpp##7,
           cot.vlrirrpp##8,
           cot.vlrirrpp##9,
           cot.vlrirrpp##10,
           cot.vlrirrpp##11,
           cot.vlrirrpp##12,
           cot.vlirrdca##1,
           cot.vlirrdca##2,
           cot.vlirrdca##3,
           cot.vlirrdca##4,
           cot.vlirrdca##5,
           cot.vlirrdca##6,
           cot.vlirrdca##7,
           cot.vlirrdca##8,
           cot.vlirrdca##9,
           cot.vlirrdca##10,
           cot.vlirrdca##11,
           cot.vlirrdca##12,
           cot.vlirajus##1,
           cot.vlirajus##2,
           cot.vlirajus##3,
           cot.vlirajus##4,
           cot.vlirajus##5,
           cot.vlirajus##6,
           cot.vlirajus##7,
           cot.vlirajus##8,
           cot.vlirajus##9,
           cot.vlirajus##10,
           cot.vlirajus##11,
           cot.vlirajus##12,
           cot.vlirfrdc##1,
           cot.vlirfrdc##2,
           cot.vlirfrdc##3,
           cot.vlirfrdc##4,
           cot.vlirfrdc##5,
           cot.vlirfrdc##6,
           cot.vlirfrdc##7,
           cot.vlirfrdc##8,
           cot.vlirfrdc##9,
           cot.vlirfrdc##10,
           cot.vlirfrdc##11,
           cot.vlirfrdc##12,
           cot.vlrenrdc##1,
           cot.vlrenrdc##2,
           cot.vlrenrdc##3,
           cot.vlrenrdc##4,
           cot.vlrenrdc##5,
           cot.vlrenrdc##6,
           cot.vlrenrdc##7,
           cot.vlrenrdc##8,
           cot.vlrenrdc##9,
           cot.vlrenrdc##10,
           cot.vlrenrdc##11,
           cot.vlrenrdc##12,
           cot.vlcapmes##1,
           cot.vlcapmes##2,
           cot.vlcapmes##3,
           cot.vlcapmes##4,
           cot.vlcapmes##5,
           cot.vlcapmes##6,
           cot.vlcapmes##7,
           cot.vlcapmes##8,
           cot.vlcapmes##9,
           cot.vlcapmes##10,
           cot.vlcapmes##11,
           cot.vlcapmes##12,
           cot.vliofepr,
           cot.vliofapl,
           cot.vliofcct,
           cot.vlbsiepr,
           cot.vlbsiapl,
           cot.vlbsicct,
           cot.vlcotant,
           cot.vldcotas,
           cot.qtantmfx,
           cot.qtcotmfx,
           cot.qtjurmfx,
           cot.rowid rowid_cot,
           ass.nrmatric,
           ass.dtdemiss
      from crapass ass,
           crapcot cot,
           crapsld sld
     where sld.cdcooper = pr_cdcooper
       and cot.cdcooper(+) = sld.cdcooper
       and cot.nrdconta(+) = sld.nrdconta
       and ass.cdcooper(+) = sld.cdcooper
       and ass.nrdconta(+) = sld.nrdconta
     order by sld.cdcooper,
              sld.nrdconta;
  -- Cursor de lançamentos de aplicação da captação
  CURSOR cr_craprac (pr_cdcooper craprac.cdcooper%TYPE
                    ,pr_nrdconta craprac.nrdconta%TYPE) IS
    SELECT rac.cdcooper,
           rac.cdprodut,
           rac.nrdconta,
           rac.nraplica
      FROM craprac rac
     WHERE rac.cdcooper = pr_cdcooper
       AND rac.nrdconta > pr_nrdconta
       AND rac.idsaqtot = 0;
  rw_craprac cr_craprac%ROWTYPE;

  -- Cursor dos lançamentos de aplicações da captação para calculo do IR
  CURSOR cr_craplac (pr_cdcooper craprac.cdcooper%TYPE
                    ,pr_nrdconta craprac.nrdconta%TYPE
                    ,pr_nraplica craprac.nraplica%TYPE) IS
    SELECT lac.cdhistor
          ,lac.vllanmto
          ,lac.dtmvtolt
      FROM craplac lac
     WHERE lac.cdcooper = pr_cdcooper
       AND lac.nrdconta = pr_nrdconta
       AND lac.nraplica = pr_nraplica;
  rw_craplac cr_craplac%ROWTYPE;

  -- Cursor dos lançamentos de aplicações da captação para calculo do IR
  CURSOR cr_craplac_ano(pr_cdcooper in crapcop.cdcooper%TYPE,
                        pr_nrctares in crapass.nrdconta%TYPE,
                        pr_dtmvtolt in crapdat.dtmvtolt%TYPE) IS
    SELECT lac.nrdconta
          ,lac.cdhistor
          ,lac.vllanmto
          ,lac.dtmvtolt
          ,cpc.cdhsprap
          ,cpc.cdhsrdap
          ,cpc.cdhsrvap
      FROM craplac lac,
           craprac rac,
           crapcpc cpc
     WHERE lac.cdcooper = pr_cdcooper
       AND lac.nrdconta > pr_nrctares
       AND rac.cdcooper = lac.cdcooper
       AND rac.nrdconta = lac.nrdconta
       AND rac.nraplica = lac.nraplica
       AND cpc.cdprodut = rac.cdprodut
       AND lac.dtmvtolt BETWEEN trunc(pr_dtmvtolt, 'yyyy') AND pr_dtmvtolt;

  rw_craplac_ano cr_craplac_ano%ROWTYPE;

  -- Cursor para busca de produto cadastrado
  CURSOR cr_crapcpc (pr_cdprodut crapcpc.cdprodut%TYPE) IS
    SELECT cpc.cdhsraap,
           cpc.cdhsnrap,
           cpc.cdhsrdap,
           cpc.cdhsirap,
           cpc.cdhsrgap,
           cpc.cdhsvtap,
           cpc.cdhsprap,
           cpc.cdhsrvap
      FROM crapcpc cpc
     WHERE cpc.cdprodut = pr_cdprodut;
  rw_crapcpc cr_crapcpc%ROWTYPE;

  -- Calculo dos Valores Pagos em Emprestimos e Financiamentos no ano
  cursor cr_craplcm (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select lcm.cdcooper,
           lcm.nrdconta,
           sum(decode(lcm.cdhistor,
                      108, lcm.vllanmto,
                      275, lcm.vllanmto,
                     1539, lcm.vllanmto,
                      393, lcm.vllanmto,
                     1706, lcm.vllanmto * -1,
                       99, lcm.vllanmto * -1,
                       0)) vllanmto_lcm
      from craplcm lcm
     where lcm.cdcooper = pr_cdcooper
       and lcm.nrdconta = pr_nrdconta
       and lcm.cdhistor in (108, 275, 1539, 393, 1706, 99)
       and lcm.dtmvtolt between trunc(pr_dtmvtolt, 'yyyy') and pr_dtmvtolt
     group by lcm.cdcooper, lcm.nrdconta;
  rw_craplcm cr_craplcm%ROWTYPE;

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra     crapprg.cdprogra%type;

  -- Tratamento de erros
  vr_cdcritic     pls_integer;
  vr_dscritic     varchar2(4000);

  -- Variaveis de saida
  vr_exc_saida    exception;
  vr_exc_fimprg   exception;

  -- Diversas
  vr_insaqtot     craprda.insaqtot%type;

  vr_totvlsdrdca  decimal(25,8)  := 0;
  vr_totvlsdeved  decimal(25,8)  := 0;
  vr_totvlsdrdpp  decimal(25,8)  := 0;
  vr_totvleprpgt  decimal(25,8)  := 0; -- Valores Pagos em Emprestimos e Financiamentos
  vr_vlrencot     decimal(25,8)  := 0;
  vr_vlirfcot     decimal(25,8)  := 0;
  vr_dupvlsdrdca  decimal(25,8)  := 0;
  vr_vlpvardc     decimal(25,8)  := 0;
  vr_sldrgttt     decimal(25,8)  := 0;
  vr_vlsdrdca     decimal(25,8)  := 0;
  vr_sldpresg     decimal(25,8)  := 0;

  -- PL/Table para armazenar os lançamentos das contas
  type typ_aplica is record (nraplica      craprda.nraplica%type,
                             insaqtot      craprda.insaqtot%type,
                             tpaplica_rda  craprda.tpaplica%type,
                             vlsdrdca      craprda.vlsdrdca%type,
                             dtiniper      craprda.dtiniper%type,
                             dtfimper      craprda.dtfimper%type,
                             inaniver      craprda.inaniver%type,
                             dtmvtolt      craprda.dtmvtolt%type,
                             rowid_rda     varchar2(20),
                             tpaplica_dtc  crapdtc.tpaplica%type,
                             tpaplrdc      crapdtc.tpaplrdc%type,
                             vllanmto      craplap.vllanmto%type);
  type typ_tab_aplica is table of typ_aplica index by varchar2(10); -- O índice será o nraplica
  -- PL/Table para armazenar a conta e a PL/Table de lançamentos das contas
  type typ_craprda is record (nrdconta        craprda.nrdconta%type,
                              vlsdeved        crapepr.vlsdeved%type,
                              vlsdrdpp        craprpp.vlsdrdpp%type,
                              dtmvtolt        craplct.dtmvtolt%type,
                              vllanmto_juros  craplct.vllanmto%type,
                              vllanmto_ir     craplct.vllanmto%type,
                              vllanmto_lap    craplap.vllanmto%type,
                              vr_aplica       typ_tab_aplica);
  type typ_tab_craprda is table of typ_craprda index by varchar2(10); -- O índice será o nrdconta
  -- O índice da pl/table é o número da conta e o número da aplicação.
  vr_ind_craprda   varchar2(10);
  vr_ind_aplica    varchar2(10);
  -- Variável para instanciar a pl/table
  vr_craprda       typ_tab_craprda;

  -- PL/Table para armazenar o saldo das aplicações
  TYPE typ_vlsldapl_aplica IS RECORD(vlsldapl    crapdir.VLSDAPLI%TYPE);
  TYPE typ_tab_vlsldapl_aplica IS TABLE OF typ_vlsldapl_aplica INDEX BY VARCHAR2(10);
  TYPE typ_vlsldapl IS RECORD(vr_vlsldapl    typ_tab_vlsldapl_aplica);
  TYPE typ_tab_vlsldapl IS TABLE OF typ_vlsldapl INDEX BY VARCHAR2(10);

  -- Variável para instanciar a pl/table
  vr_craprac       typ_tab_vlsldapl;


 -- PL/Table para armazenar a conta e a PL/Table de Emprestimos e Financiamentos
  type typ_prgepr is record (nrdconta        craprda.nrdconta%TYPE,
                             vlsdpgepr       crapepr.vlsdeved%TYPE);
  type typ_tab_pgtepr is table of typ_prgepr index by varchar2(10); -- O índice será o nrdconta

  -- Variavel para Pagamento de Emprestimos
  vr_pgtoepr       typ_tab_pgtepr;

  -- O indice da pl/table vr_craprac é o número da conta
  vr_ind_vlsldapl         varchar2(10);
  -- O indice do campo vr_vlsldapl da pl/table vr_craprac é o número da aplicação
  vr_ind_vlsldapl_aplica  varchar2(10);

  -- Indice do campo que acumula valores pagos em Emprestimos e Financiamentos
  vr_ind_pgtoepr          VARCHAR2(10);

  -- PL/Table para armazenar a provisao anterior das aplicacoes RDC
  TYPE typ_vlprvapl IS RECORD(vlprvapl crapcot.vlpvardc%TYPE);
  TYPE typ_tab_vlprvapl IS TABLE OF typ_vlprvapl INDEX BY VARCHAR2(10);

  -- Variável para instanciar a pl/table
  vr_crapcot       typ_tab_vlprvapl;

  -- Variáveis para controle de restart
  vr_nrctares crapass.nrdconta%TYPE := 0;      --> Número da conta de restart
  vr_dsrestar VARCHAR2(4000);             --> String genérica com informações para restart
  vr_inrestar INTEGER;                    --> Indicador de Restart
  -- Buscar as informações para restart e Rowid para atualização posterior
  CURSOR cr_crapres IS
    SELECT res.dsrestar
          ,res.rowid
      FROM crapres res
     WHERE res.cdcooper = pr_cdcooper
       AND res.cdprogra = vr_cdprogra;
  rw_crapres cr_crapres%ROWTYPE;

BEGIN
  -- Nome do programa
  vr_cdprogra := 'CRPS011';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS011',
                             pr_action => vr_cdprogra);
  -- Verifica se a cooperativa esta cadastrada
  open cr_crapcop(pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    -- Verificar se existe informação, e gerar erro caso não exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close btch0001.cr_crapdat;

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;

  -- Busca das informações de restart
  IF pr_flgresta = 1 THEN
    -- Tratamento e retorno de valores de restart
    btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                              ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                              ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                              ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                              ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                              ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                              ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                              ,pr_des_erro  => vr_dscritic); --> Saída de erro
    -- Se encontrou erro, gerar exceção
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  END IF;

  -- Regra de negócio do programas --

  -- Leitura de dados de ufir
  open cr_crapmfx(pr_cdcooper => pr_cdcooper,          -- codigo da cooperativa
                  pr_dtmvtolt => rw_crapdat.dtmvtolt); -- data de movimentacao atual
    fetch cr_crapmfx into rw_crapmfx;
    -- se não encontrar
    if cr_crapmfx%notfound then
      -- fechar o cursor pois efetuaremos raise
      close cr_crapmfx;
      -- montar mensagem de critica
      vr_cdcritic := 55;
      raise vr_exc_saida;
    end if;
  close cr_crapmfx;

  -- Carrega PL/Table com os lançamentos para uso no loop do cursor cr_crapsld
  for rw_craprda in cr_craprda (pr_cdcooper,
                                vr_nrctares) loop
    vr_ind_craprda := lpad(rw_craprda.nrdconta, 10, '0');
    vr_ind_aplica := lpad(rw_craprda.nraplica, 10, '0');
    vr_craprda(vr_ind_craprda).nrdconta                              := rw_craprda.nrdconta;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).nraplica     := rw_craprda.nraplica;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).insaqtot     := rw_craprda.insaqtot;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplica_rda := rw_craprda.tpaplica_rda;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).vlsdrdca     := rw_craprda.vlsdrdca;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).dtiniper     := rw_craprda.dtiniper;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).dtfimper     := rw_craprda.dtfimper;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).inaniver     := rw_craprda.inaniver;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).dtmvtolt     := rw_craprda.dtmvtolt;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).rowid_rda    := rw_craprda.rowid_rda;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplica_dtc := rw_craprda.tpaplica_dtc;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplrdc     := rw_craprda.tpaplrdc;
    vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).vllanmto     := rw_craprda.vllanmto;
  end loop;

  -- Para cada registros de aplicação de captação
  FOR rw_craprac IN cr_craprac(pr_cdcooper
                              ,vr_nrctares) LOOP

    -- Alimenta Chaves
    vr_ind_vlsldapl := lpad(rw_craprac.nrdconta, 10, '0');
    vr_ind_vlsldapl_aplica := lpad(rw_craprac.nraplica, 10, '0');

    -- Abre cursor de produtos cadastrados
    OPEN cr_crapcpc(rw_craprac.cdprodut);
    FETCH cr_crapcpc INTO rw_crapcpc;

    -- Se encontrar produto
    IF cr_crapcpc%FOUND THEN
      -- Fecha cursor
      CLOSE cr_crapcpc;

      -- Busca os lançamentos de aplicações da captação para calculo do IR
      FOR rw_craplac IN cr_craplac(rw_craprac.cdcooper
                                  ,rw_craprac.nrdconta
                                  ,rw_craprac.nraplica) LOOP

        IF rw_craplac.cdhistor = rw_crapcpc.cdhsraap OR   --> Renovação Aplicação
           rw_craplac.cdhistor = rw_crapcpc.cdhsnrap OR   --> Aplicação Recurso Novo
           rw_craplac.cdhistor = rw_crapcpc.cdhsrdap THEN --> Rendimento
          -- Soma valor de lançamento na PL/TABLE
          IF vr_craprac.EXISTS(vr_ind_vlsldapl) AND
             vr_craprac(vr_ind_vlsldapl).vr_vlsldapl.EXISTS(vr_ind_vlsldapl_aplica) THEN
            vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl :=
            NVL(vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl,0) + NVL(rw_craplac.vllanmto,0);
          ELSE
            vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl := NVL(rw_craplac.vllanmto,0);
          END IF;
        END IF;

        IF rw_craplac.cdhistor = rw_crapcpc.cdhsirap OR   --> IRRF Rendimento
           rw_craplac.cdhistor = rw_crapcpc.cdhsrgap OR   --> Resgate
           rw_craplac.cdhistor = rw_crapcpc.cdhsvtap THEN --> Vencimento
          -- Subtrai valor de lançamento na PL/TABLE
          IF  vr_craprac.EXISTS(vr_ind_vlsldapl) AND
            vr_craprac(vr_ind_vlsldapl).vr_vlsldapl.EXISTS(vr_ind_vlsldapl_aplica) THEN
            vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl :=
            NVL(vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl,0) - NVL(rw_craplac.vllanmto,0);
          ELSE
            vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl :=  (-1 *  NVL(rw_craplac.vllanmto,0));
          END IF;
        END IF;

      END LOOP;
    ELSE
      -- Fecha cursor
      CLOSE cr_crapcpc;
    END IF;

  END LOOP;

  -- Carrega pltable de Lançamentos da aplicação
  for rw_craplap in cr_craplap (pr_cdcooper,
                                vr_nrctares,
                                rw_crapdat.dtmvtolt) loop
    vr_craprda(lpad(rw_craplap.nrdconta, 10, '0')).vllanmto_lap := nvl(rw_craplap.vllanmto_lap, 0);
  end loop;

  -- Leitura de lancamento do ano vigente
  FOR rw_craplac_ano IN cr_craplac_ano(pr_cdcooper
                                      ,vr_nrctares
                                      ,rw_crapdat.dtmvtolt) LOOP

    IF rw_craplac_ano.cdhistor = rw_craplac_ano.cdhsprap OR   /* Provisão   */
      rw_craplac_ano.cdhistor = rw_craplac_ano.cdhsrdap THEN /* Rendimento */
      -- Soma valor de lançamento na PL/TABLE
      IF vr_crapcot.EXISTS(LPAD(rw_craplac_ano.nrdconta,10,'0')) THEN
        vr_crapcot(LPAD(rw_craplac_ano.nrdconta,10,'0')).vlprvapl := NVL(vr_crapcot(LPAD(rw_craplac_ano.nrdconta,10,'0')).vlprvapl,0) + NVL(rw_craplac_ano.vllanmto,0);
      ELSE
        vr_crapcot(LPAD(rw_craplac_ano.nrdconta,10,'0')).vlprvapl := NVL(rw_craplac_ano.vllanmto,0);
      END IF;
    END IF;

    IF rw_craplac_ano.cdhistor = rw_craplac_ano.cdhsrvap THEN /* Reversão */
      -- Subtrai valor de lançamento na PL/TABLE
      IF vr_crapcot.EXISTS(LPAD(rw_craplac_ano.nrdconta,10,'0')) THEN
        vr_crapcot(LPAD(rw_craplac_ano.nrdconta,10,'0')).vlprvapl := NVL(vr_crapcot(LPAD(rw_craplac_ano.nrdconta,10,'0')).vlprvapl,0) - NVL(rw_craplac_ano.vllanmto,0);
      ELSE
         vr_crapcot(LPAD(rw_craplac_ano.nrdconta,10,'0')).vlprvapl := (-1 * NVL(rw_craplac_ano.vllanmto,0));
      END IF;
    END IF;

  END LOOP;

  -- Carrega pltable de Lancamentos de cotas/capital
  for rw_craplct in cr_craplct (pr_cdcooper,
                                vr_nrctares,
                                rw_crapdat.dtmvtolt) loop
    vr_ind_craprda := lpad(rw_craplct.nrdconta, 10, '0');
    vr_craprda(vr_ind_craprda).dtmvtolt       := rw_crapdat.dtmvtolt;
    vr_craprda(vr_ind_craprda).vllanmto_juros := nvl(rw_craplct.vllanmto_juros, 0);
    vr_craprda(vr_ind_craprda).vllanmto_ir    := nvl(rw_craplct.vllanmto_ir, 0);
  end loop;
  -- Carregar pltable de Cadastro de poupanca programada.
  for rw_craprpp in cr_craprpp (pr_cdcooper,
                                vr_nrctares,
                                rw_crapdat.dtmvtolt) loop
    vr_craprda(lpad(rw_craprpp.nrdconta, 10, '0')).vlsdrdpp := nvl(rw_craprpp.vlsdrdpp, 0);
  end loop;
  -- Carregar pltable de Empréstimos
  for rw_crapepr in cr_crapepr (pr_cdcooper,
                                vr_nrctares) loop
    vr_craprda(lpad(rw_crapepr.nrdconta, 10, '0')).vlsdeved := nvl(rw_crapepr.vlsdeved, 0);
  end loop;


  -- Busca o registro de saldo dos associados e zera os totalizadores anuais
  for rw_crapsld in cr_crapsld (pr_cdcooper,
                                vr_nrctares) LOOP

    -- Tratamento das exceções
    -- Se não existir cadastro de cotas e recursos
    if rw_crapsld.rowid_cot is null then
      vr_cdcritic := 169;
      raise vr_exc_saida;
    end if;
    -- Se não existir o associado
    if rw_crapsld.nrmatric is null then
      vr_cdcritic := 251;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     ' CONTA = '||rw_crapsld.nrdconta;
      raise vr_exc_saida;
    end if;
    -- Zera variáveis para acumular o total
    vr_totvlsdrdca := 0;
    vr_vlrencot    := 0;
    vr_vlirfcot    := 0;
    -- Calcula saldo das aplicacoes RDCA e RDC no final do ano
    vr_ind_craprda := lpad(rw_crapsld.nrdconta, 10, '0');
    if vr_craprda.exists(vr_ind_craprda) then
      vr_ind_aplica := vr_craprda(vr_ind_craprda).vr_aplica.first;
    else
      vr_ind_aplica := null;
    end if;
    -- Efetuar varredura das aplicações RDCA da Conta
    while vr_ind_aplica is not null loop

      if vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplica_rda = 3 then
        -- Cálculo RDCA
        apli0001.pc_calc_aplicacao(pr_cdcooper     => pr_cdcooper,  --> COOPERATIVA
                                   pr_dtmvtolt     => rw_crapdat.dtmvtolt,  --> DATA DO MOVIMENTO
                                   pr_dtmvtopr     => rw_crapdat.dtmvtopr,  --> PRIM. DIA ÚTIL APÓS A DATA DO MOVIMENTO
                                   pr_rda_rowid    => vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).rowid_rda, --> ROWID DO REGISTRO DA TABELA CRAPRDA EM PROCESSAMENTO
                                   pr_cdprogra     => vr_cdprogra,          --> PROGRAMA CHAMADOR
                                   pr_inproces     => rw_crapdat.inproces,  --> INDICADOR DO PROCESSO
                                   pr_insaqtot     => vr_insaqtot,          --> INDICADOR DE SAQUE TOTAL
                                   pr_vlsdrdca     => vr_vlsdrdca,          --> SALDO DA APLICAÇÃO RDCA
                                   pr_sldpresg     => vr_sldpresg,          --> SALDO PARA RESGATE
                                   pr_dup_vlsdrdca => vr_dupvlsdrdca,       --> SALDO DA APLIC. RDCA P/ ROT. DUPLICADA
                                   pr_cdcritic     => vr_cdcritic,          --> CODIGO DA CRITICA DE ERRO
                                   pr_dscritic     => vr_dscritic);         --> DESCRICÃO DO ERRO ENCONTRADO
        -- Verifica se conseguiu calcular
        if vr_dscritic is not null then
          raise vr_exc_saida;
        end if;
        -- Verifica se o valor do RDCA é maior que zero
        if nvl(vr_vlsdrdca, 0) > 0   then
          vr_totvlsdrdca := vr_totvlsdrdca + vr_vlsdrdca;
        end if;
      elsif vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplica_rda = 5 then
        -- Cálculo do saldo RDCA2
        vr_vlsdrdca := vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).vlsdrdca;
        apli0001.pc_rdca2s(pr_cdcooper => pr_cdcooper, --> COOPERATIVA
                           pr_nrdconta => vr_craprda(vr_ind_craprda).nrdconta, --> NUM DA CONTA
                           pr_nraplica => vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).nraplica, --> NUM DA APLICACAO
                           pr_dtiniper => vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).dtiniper, --> DATA INICIO DO PERIODO
                           pr_dtfimper => vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).dtfimper, --> DATA FIM DO PERIODO
                           pr_inaniver => vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).inaniver, --> INDICADOR DE APLICAÇÃO
                           pr_dtmvtolt => rw_crapdat.dtmvtolt, --> DATA DE MOVIMENTO ATUAL
                           pr_dtmvtopr => rw_crapdat.dtmvtopr, --> DATA DO PROXIMO DIA
                           pr_cdprogra => vr_cdprogra,         --> PROGRAMA CHAMADOR
                           pr_vlsdrdca => vr_vlsdrdca,         --> Saldo RDCA
                           pr_sldpresg => vr_sldpresg,         --> SALDO DE RESGATE COM IR
                           pr_sldrgttt => vr_sldrgttt,         --> SALDO DE RESGATE COM IR
                           pr_cdcritic => vr_cdcritic,         --> CODIGO DA CRITICA DE ERRO
                           pr_dscritic => vr_dscritic);        --> DESCRICÃO DO ERRO ENCONTRADO
        -- Verifica se houve erro
        if vr_cdcritic <> 0 then
          raise vr_exc_fimprg;
        end if;
        -- Verifica se saldo p/ resgate é maior que zero e soma ao total
        if nvl(vr_vlsdrdca,0) > 0 then
            vr_totvlsdrdca := vr_totvlsdrdca + vr_vlsdrdca;
        end if;
      else
        if nvl(vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplrdc, 0) = 0 then
          vr_cdcritic := 346;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                         ' Conta/dv: '||to_char(vr_craprda(vr_ind_craprda).nrdconta, '9999G999G0')||
                         ' Nr.Aplicacao: '||to_char(vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).nraplica, '999G990');
          raise vr_exc_saida;
          /* VER O TRATAMENTO DO LEAVE DO PROGRESS */
        elsif vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplrdc = 1 then
          vr_totvlsdrdca := vr_totvlsdrdca + vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).vlsdrdca;
        elsif vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).tpaplrdc = 2 then
          -- calc_saldo_rdcpos (a soma é feita diretamente no cursor cr_craprda)
          if vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).vllanmto > 0 then
            vr_totvlsdrdca := vr_totvlsdrdca + vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).vllanmto;
          else
            vr_totvlsdrdca := vr_totvlsdrdca + vr_craprda(vr_ind_craprda).vr_aplica(vr_ind_aplica).vlsdrdca;
          end if;
        end if;
      end if;
      vr_ind_aplica := vr_craprda(vr_ind_craprda).vr_aplica.next(vr_ind_aplica);
    end loop;

    -- Alimenta indice da PL/TABLE
    vr_ind_vlsldapl := lpad(rw_crapsld.nrdconta, 10, '0');
    if vr_craprac.exists(vr_ind_vlsldapl) then
      vr_ind_vlsldapl_aplica := vr_craprac(vr_ind_vlsldapl).vr_vlsldapl.first;
    else
      vr_ind_vlsldapl_aplica := null;
    end if;
    -- Percorre todos os registros da conta da PL/TABLE
    WHILE vr_ind_vlsldapl_aplica IS NOT NULL LOOP

      -- Se o valor do saldo da aplicação não for negativo
      IF vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl > 0 THEN
        vr_totvlsdrdca := vr_totvlsdrdca + vr_craprac(vr_ind_vlsldapl).vr_vlsldapl(vr_ind_vlsldapl_aplica).vlsldapl;
      END IF;

      vr_ind_vlsldapl_aplica := vr_craprac(vr_ind_vlsldapl).vr_vlsldapl.next(vr_ind_vlsldapl_aplica);

    END LOOP;


    -- Pagamento de Emprestimos/Financiamentos
    IF cr_craplcm%ISOPEN THEN
      CLOSE cr_craplcm;
    END IF;
    open cr_craplcm(pr_cdcooper,
                    rw_crapsld.nrdconta,
                    rw_crapdat.dtmvtolt);
    fetch cr_craplcm into rw_craplcm;
    -- Verificar se existe informação, e gerar erro caso não exista
    if cr_craplcm%notfound then
        -- Fechar o cursor
      CLOSE cr_craplcm;
      vr_totvleprpgt := 0;
    ELSE
      vr_totvleprpgt := nvl(rw_craplcm.vllanmto_lcm, 0);
    END IF;
    IF cr_craplcm%ISOPEN THEN
      CLOSE cr_craplcm;
    END IF;


    -- Preparar informações cfme existência ou não da RDA
    if vr_craprda.exists(vr_ind_craprda) then
      vr_totvlsdeved := round(nvl(vr_craprda(vr_ind_craprda).vlsdeved, 0), 2);
      vr_totvlsdrdpp := nvl(vr_craprda(vr_ind_craprda).vlsdrdpp, 0);
      vr_vlpvardc    := greatest(nvl(vr_craprda(vr_ind_craprda).vllanmto_lap, 0), 0);
      vr_vlrencot    := nvl(vr_craprda(vr_ind_craprda).vllanmto_juros, 0);
      vr_vlirfcot    := nvl(vr_craprda(vr_ind_craprda).vllanmto_ir, 0);
    else
      vr_totvlsdeved := 0;
      vr_totvlsdrdpp := 0;
      vr_vlpvardc    := 0;
      vr_vlrencot    := 0;
      vr_vlirfcot    := 0;
    end if;

    IF vr_crapcot.exists(vr_ind_craprda) THEN
      vr_vlpvardc    := vr_vlpvardc + vr_crapcot(vr_ind_craprda).vlprvapl;
    END IF;
    -- Cria registro para declaracao do imposto de renda
    begin
      insert into crapdir
        (nrdconta,
         dtdemiss,
         vlsdccdp,
         vlttccap,
         vlsdapli,
         vlsddvem,
         qtreamfx,
         qtjaicmf,
         vlsdrdpp,
         vlrenrpp,
         dtmvtolt,
         vlabonrd,
         vlabiord,
         vlabonpp,
         vlabiopp,
         cdcooper,
         vlblqjud,
         vlcpmfpg,
         vlrenrda##1,
         vlrenrda##2,
         vlrenrda##3,
         vlrenrda##4,
         vlrenrda##5,
         vlrenrda##6,
         vlrenrda##7,
         vlrenrda##8,
         vlrenrda##9,
         vlrenrda##10,
         vlrenrda##11,
         vlrenrda##12,
         vlrentot##1,
         vlrentot##2,
         vlrentot##3,
         vlrentot##4,
         vlrentot##5,
         vlrentot##6,
         vlrentot##7,
         vlrentot##8,
         vlrentot##9,
         vlrentot##10,
         vlrentot##11,
         vlrentot##12,
         vlabnapl_ir##1,
         vlabnapl_ir##2,
         vlabnapl_ir##3,
         vlabnapl_ir##4,
         vlabnapl_ir##5,
         vlabnapl_ir##6,
         vlabnapl_ir##7,
         vlabnapl_ir##8,
         vlabnapl_ir##9,
         vlabnapl_ir##10,
         vlabnapl_ir##11,
         vlabnapl_ir##12,
         vlirabap##1,
         vlirabap##2,
         vlirabap##3,
         vlirabap##4,
         vlirabap##5,
         vlirabap##6,
         vlirabap##7,
         vlirabap##8,
         vlirabap##9,
         vlirabap##10,
         vlirabap##11,
         vlirabap##12,
         vlrenrpp_ir##1,
         vlrenrpp_ir##2,
         vlrenrpp_ir##3,
         vlrenrpp_ir##4,
         vlrenrpp_ir##5,
         vlrenrpp_ir##6,
         vlrenrpp_ir##7,
         vlrenrpp_ir##8,
         vlrenrpp_ir##9,
         vlrenrpp_ir##10,
         vlrenrpp_ir##11,
         vlrenrpp_ir##12,
         vlrirrpp##1,
         vlrirrpp##2,
         vlrirrpp##3,
         vlrirrpp##4,
         vlrirrpp##5,
         vlrirrpp##6,
         vlrirrpp##7,
         vlrirrpp##8,
         vlrirrpp##9,
         vlrirrpp##10,
         vlrirrpp##11,
         vlrirrpp##12,
         vlirrdca##1,
         vlirrdca##2,
         vlirrdca##3,
         vlirrdca##4,
         vlirrdca##5,
         vlirrdca##6,
         vlirrdca##7,
         vlirrdca##8,
         vlirrdca##9,
         vlirrdca##10,
         vlirrdca##11,
         vlirrdca##12,
         vlirajus##1,
         vlirajus##2,
         vlirajus##3,
         vlirajus##4,
         vlirajus##5,
         vlirajus##6,
         vlirajus##7,
         vlirajus##8,
         vlirajus##9,
         vlirajus##10,
         vlirajus##11,
         vlirajus##12,
         vlirfrdc##1,
         vlirfrdc##2,
         vlirfrdc##3,
         vlirfrdc##4,
         vlirfrdc##5,
         vlirfrdc##6,
         vlirfrdc##7,
         vlirfrdc##8,
         vlirfrdc##9,
         vlirfrdc##10,
         vlirfrdc##11,
         vlirfrdc##12,
         vlrenrdc##1,
         vlrenrdc##2,
         vlrenrdc##3,
         vlrenrdc##4,
         vlrenrdc##5,
         vlrenrdc##6,
         vlrenrdc##7,
         vlrenrdc##8,
         vlrenrdc##9,
         vlrenrdc##10,
         vlrenrdc##11,
         vlrenrdc##12,
         vlcapmes##1,
         vlcapmes##2,
         vlcapmes##3,
         vlcapmes##4,
         vlcapmes##5,
         vlcapmes##6,
         vlcapmes##7,
         vlcapmes##8,
         vlcapmes##9,
         vlcapmes##10,
         vlcapmes##11,
         vlcapmes##12,
         vlrencot,
         vlirfcot,
         smposano##1,
         smposano##2,
         smposano##3,
         smposano##4,
         smposano##5,
         smposano##6,
         smposano##7,
         smposano##8,
         smposano##9,
         smposano##10,
         smposano##11,
         smposano##12
        ,vlprepag -- Valores Pagos em Emprestimos e Financiamentos
         )
      values
        (rw_crapsld.nrdconta,
         rw_crapsld.dtdemiss,
         rw_crapsld.vlsdmesa,
         rw_crapsld.vlcapmes##12,
         round(vr_totvlsdrdca, 2),
         vr_totvlsdeved,
         rw_crapsld.qtrenmfx,
         rw_crapsld.qtjexcmf,
         vr_totvlsdrdpp,
         rw_crapsld.vlrenrpp,
         rw_crapdat.dtmvtolt,
         rw_crapsld.vlabonrd,
         rw_crapsld.vlabiord,
         rw_crapsld.vlabonpp,
         rw_crapsld.vlabiopp,
         pr_cdcooper,
         rw_crapsld.vlblqjud,
         rw_crapsld.qtipmmfx * rw_crapmfx.vlmoefix,
         rw_crapsld.vlrenrda##1,
         rw_crapsld.vlrenrda##2,
         rw_crapsld.vlrenrda##3,
         rw_crapsld.vlrenrda##4,
         rw_crapsld.vlrenrda##5,
         rw_crapsld.vlrenrda##6,
         rw_crapsld.vlrenrda##7,
         rw_crapsld.vlrenrda##8,
         rw_crapsld.vlrenrda##9,
         rw_crapsld.vlrenrda##10,
         rw_crapsld.vlrenrda##11,
         rw_crapsld.vlrenrda##12,
         rw_crapsld.vlrentot##1,
         rw_crapsld.vlrentot##2,
         rw_crapsld.vlrentot##3,
         rw_crapsld.vlrentot##4,
         rw_crapsld.vlrentot##5,
         rw_crapsld.vlrentot##6,
         rw_crapsld.vlrentot##7,
         rw_crapsld.vlrentot##8,
         rw_crapsld.vlrentot##9,
         rw_crapsld.vlrentot##10,
         rw_crapsld.vlrentot##11,
         rw_crapsld.vlrentot##12,
         rw_crapsld.vlabnapl_ir##1,
         rw_crapsld.vlabnapl_ir##2,
         rw_crapsld.vlabnapl_ir##3,
         rw_crapsld.vlabnapl_ir##4,
         rw_crapsld.vlabnapl_ir##5,
         rw_crapsld.vlabnapl_ir##6,
         rw_crapsld.vlabnapl_ir##7,
         rw_crapsld.vlabnapl_ir##8,
         rw_crapsld.vlabnapl_ir##9,
         rw_crapsld.vlabnapl_ir##10,
         rw_crapsld.vlabnapl_ir##11,
         rw_crapsld.vlabnapl_ir##12,
         rw_crapsld.vlirabap##1,
         rw_crapsld.vlirabap##2,
         rw_crapsld.vlirabap##3,
         rw_crapsld.vlirabap##4,
         rw_crapsld.vlirabap##5,
         rw_crapsld.vlirabap##6,
         rw_crapsld.vlirabap##7,
         rw_crapsld.vlirabap##8,
         rw_crapsld.vlirabap##9,
         rw_crapsld.vlirabap##10,
         rw_crapsld.vlirabap##11,
         rw_crapsld.vlirabap##12,
         rw_crapsld.vlrenrpp_ir##1,
         rw_crapsld.vlrenrpp_ir##2,
         rw_crapsld.vlrenrpp_ir##3,
         rw_crapsld.vlrenrpp_ir##4,
         rw_crapsld.vlrenrpp_ir##5,
         rw_crapsld.vlrenrpp_ir##6,
         rw_crapsld.vlrenrpp_ir##7,
         rw_crapsld.vlrenrpp_ir##8,
         rw_crapsld.vlrenrpp_ir##9,
         rw_crapsld.vlrenrpp_ir##10,
         rw_crapsld.vlrenrpp_ir##11,
         rw_crapsld.vlrenrpp_ir##12,
         rw_crapsld.vlrirrpp##1,
         rw_crapsld.vlrirrpp##2,
         rw_crapsld.vlrirrpp##3,
         rw_crapsld.vlrirrpp##4,
         rw_crapsld.vlrirrpp##5,
         rw_crapsld.vlrirrpp##6,
         rw_crapsld.vlrirrpp##7,
         rw_crapsld.vlrirrpp##8,
         rw_crapsld.vlrirrpp##9,
         rw_crapsld.vlrirrpp##10,
         rw_crapsld.vlrirrpp##11,
         rw_crapsld.vlrirrpp##12,
         rw_crapsld.vlirrdca##1,
         rw_crapsld.vlirrdca##2,
         rw_crapsld.vlirrdca##3,
         rw_crapsld.vlirrdca##4,
         rw_crapsld.vlirrdca##5,
         rw_crapsld.vlirrdca##6,
         rw_crapsld.vlirrdca##7,
         rw_crapsld.vlirrdca##8,
         rw_crapsld.vlirrdca##9,
         rw_crapsld.vlirrdca##10,
         rw_crapsld.vlirrdca##11,
         rw_crapsld.vlirrdca##12,
         rw_crapsld.vlirajus##1,
         rw_crapsld.vlirajus##2,
         rw_crapsld.vlirajus##3,
         rw_crapsld.vlirajus##4,
         rw_crapsld.vlirajus##5,
         rw_crapsld.vlirajus##6,
         rw_crapsld.vlirajus##7,
         rw_crapsld.vlirajus##8,
         rw_crapsld.vlirajus##9,
         rw_crapsld.vlirajus##10,
         rw_crapsld.vlirajus##11,
         rw_crapsld.vlirajus##12,
         rw_crapsld.vlirfrdc##1,
         rw_crapsld.vlirfrdc##2,
         rw_crapsld.vlirfrdc##3,
         rw_crapsld.vlirfrdc##4,
         rw_crapsld.vlirfrdc##5,
         rw_crapsld.vlirfrdc##6,
         rw_crapsld.vlirfrdc##7,
         rw_crapsld.vlirfrdc##8,
         rw_crapsld.vlirfrdc##9,
         rw_crapsld.vlirfrdc##10,
         rw_crapsld.vlirfrdc##11,
         rw_crapsld.vlirfrdc##12,
         rw_crapsld.vlrenrdc##1,
         rw_crapsld.vlrenrdc##2,
         rw_crapsld.vlrenrdc##3,
         rw_crapsld.vlrenrdc##4,
         rw_crapsld.vlrenrdc##5,
         rw_crapsld.vlrenrdc##6,
         rw_crapsld.vlrenrdc##7,
         rw_crapsld.vlrenrdc##8,
         rw_crapsld.vlrenrdc##9,
         rw_crapsld.vlrenrdc##10,
         rw_crapsld.vlrenrdc##11,
         rw_crapsld.vlrenrdc##12,
         rw_crapsld.vlcapmes##1,
         rw_crapsld.vlcapmes##2,
         rw_crapsld.vlcapmes##3,
         rw_crapsld.vlcapmes##4,
         rw_crapsld.vlcapmes##5,
         rw_crapsld.vlcapmes##6,
         rw_crapsld.vlcapmes##7,
         rw_crapsld.vlcapmes##8,
         rw_crapsld.vlcapmes##9,
         rw_crapsld.vlcapmes##10,
         rw_crapsld.vlcapmes##11,
         rw_crapsld.vlcapmes##12,
         vr_vlrencot,
         vr_vlirfcot,
         rw_crapsld.smposano##1,
         rw_crapsld.smposano##2,
         rw_crapsld.smposano##3,
         rw_crapsld.smposano##4,
         rw_crapsld.smposano##5,
         rw_crapsld.smposano##6,
         rw_crapsld.smposano##7,
         rw_crapsld.smposano##8,
         rw_crapsld.smposano##9,
         rw_crapsld.smposano##10,
         rw_crapsld.smposano##11,
         rw_crapsld.smposano##12
        ,nvl(vr_totvleprpgt,0) -- Valores Pagos em Emprestimos e Financiamentos
        );
    exception
      when others then
        vr_dscritic := 'Problema ao inserir registro na tabela CRAPDIR: ' || sqlerrm;
        raise vr_exc_saida;
    end;

    -- Atualiza informações nas cotas
    begin
      update crapcot
         set crapcot.qtipmmfx        = rw_crapsld.qtipamfx,
             crapcot.qtjaicmf        = rw_crapsld.qtjexcmf,
             crapcot.qtraimfx        = rw_crapsld.qtjurmfx,
             crapcot.qtreamfx        = rw_crapsld.qtrenmfx,
             crapcot.qtsanmfx        = rw_crapsld.qtsmamfx,
             crapcot.vlrearpp        = rw_crapsld.vlrenrpp,
             crapcot.vlrearda        = rw_crapsld.vlrenrda##1 + rw_crapsld.vlrenrda##2 + rw_crapsld.vlrenrda##3 + rw_crapsld.vlrenrda##4 +
                                       rw_crapsld.vlrenrda##5 + rw_crapsld.vlrenrda##6 + rw_crapsld.vlrenrda##7 + rw_crapsld.vlrenrda##8 +
                                       rw_crapsld.vlrenrda##9 + rw_crapsld.vlrenrda##10 + rw_crapsld.vlrenrda##11 + rw_crapsld.vlrenrda##12,
             crapcot.vlpvardc        = vr_vlpvardc,
             crapcot.vlabanrd        = rw_crapsld.vlabonrd,
             crapcot.vlabaird        = rw_crapsld.vlabiord,
             crapcot.vlabanpp        = rw_crapsld.vlabonpp,
             crapcot.vlabaipp        = rw_crapsld.vlabiopp,
             crapcot.vliofean        = rw_crapsld.vliofepr,
             crapcot.vliofaan        = rw_crapsld.vliofapl,
             crapcot.vliofcan        = rw_crapsld.vliofcct,
             crapcot.vlbiaepr        = rw_crapsld.vlbsiepr,
             crapcot.vlbiaapl        = rw_crapsld.vlbsiapl,
             crapcot.vlbiacct        = rw_crapsld.vlbsicct,
             crapcot.vlcotext        = rw_crapsld.vlcotant,
             crapcot.vlcotant        = rw_crapsld.vldcotas,
             crapcot.qtextmfx        = rw_crapsld.qtantmfx,
             crapcot.qtantmfx        = rw_crapsld.qtcotmfx,
             crapcot.vlcmicot        = 0,
             crapcot.qtjexcmf        = 0,
             crapcot.qtjurmfx        = 0,
             crapcot.qtrenmfx        = 0,
             crapcot.vlrenrpp        = 0,
             crapcot.vlrenrda##1     = 0,
             crapcot.vlrenrda##2     = 0,
             crapcot.vlrenrda##3     = 0,
             crapcot.vlrenrda##4     = 0,
             crapcot.vlrenrda##5     = 0,
             crapcot.vlrenrda##6     = 0,
             crapcot.vlrenrda##7     = 0,
             crapcot.vlrenrda##8     = 0,
             crapcot.vlrenrda##9     = 0,
             crapcot.vlrenrda##10    = 0,
             crapcot.vlrenrda##11    = 0,
             crapcot.vlrenrda##12    = 0,
             crapcot.vlrentot##1     = 0,
             crapcot.vlrentot##2     = 0,
             crapcot.vlrentot##3     = 0,
             crapcot.vlrentot##4     = 0,
             crapcot.vlrentot##5     = 0,
             crapcot.vlrentot##6     = 0,
             crapcot.vlrentot##7     = 0,
             crapcot.vlrentot##8     = 0,
             crapcot.vlrentot##9     = 0,
             crapcot.vlrentot##10    = 0,
             crapcot.vlrentot##11    = 0,
             crapcot.vlrentot##12    = 0,
             crapcot.vlabonrd        = 0,
             crapcot.vlabiord        = 0,
             crapcot.vlabonpp        = 0,
             crapcot.vlabiopp        = 0,
             crapcot.vliofepr        = 0,
             crapcot.vliofapl        = 0,
             crapcot.vliofcct        = 0,
             crapcot.vlbsiepr        = 0,
             crapcot.vlbsiapl        = 0,
             crapcot.vlbsicct        = 0,
             crapcot.vlprvrdc##1     = 0,
             crapcot.vlprvrdc##2     = 0,
             crapcot.vlprvrdc##3     = 0,
             crapcot.vlprvrdc##4     = 0,
             crapcot.vlprvrdc##5     = 0,
             crapcot.vlprvrdc##6     = 0,
             crapcot.vlprvrdc##7     = 0,
             crapcot.vlprvrdc##8     = 0,
             crapcot.vlprvrdc##9     = 0,
             crapcot.vlprvrdc##10    = 0,
             crapcot.vlprvrdc##11    = 0,
             crapcot.vlprvrdc##12    = 0,
             crapcot.vlrevrdc##1     = 0,
             crapcot.vlrevrdc##2     = 0,
             crapcot.vlrevrdc##3     = 0,
             crapcot.vlrevrdc##4     = 0,
             crapcot.vlrevrdc##5     = 0,
             crapcot.vlrevrdc##6     = 0,
             crapcot.vlrevrdc##7     = 0,
             crapcot.vlrevrdc##8     = 0,
             crapcot.vlrevrdc##9     = 0,
             crapcot.vlrevrdc##10    = 0,
             crapcot.vlrevrdc##11    = 0,
             crapcot.vlrevrdc##12    = 0,
             crapcot.vlabnapl_ir##1  = 0,
             crapcot.vlabnapl_ir##2  = 0,
             crapcot.vlabnapl_ir##3  = 0,
             crapcot.vlabnapl_ir##4  = 0,
             crapcot.vlabnapl_ir##5  = 0,
             crapcot.vlabnapl_ir##6  = 0,
             crapcot.vlabnapl_ir##7  = 0,
             crapcot.vlabnapl_ir##8  = 0,
             crapcot.vlabnapl_ir##9  = 0,
             crapcot.vlabnapl_ir##10 = 0,
             crapcot.vlabnapl_ir##11 = 0,
             crapcot.vlabnapl_ir##12 = 0,
             crapcot.vlirabap##1     = 0,
             crapcot.vlirabap##2     = 0,
             crapcot.vlirabap##3     = 0,
             crapcot.vlirabap##4     = 0,
             crapcot.vlirabap##5     = 0,
             crapcot.vlirabap##6     = 0,
             crapcot.vlirabap##7     = 0,
             crapcot.vlirabap##8     = 0,
             crapcot.vlirabap##9     = 0,
             crapcot.vlirabap##10    = 0,
             crapcot.vlirabap##11    = 0,
             crapcot.vlirabap##12    = 0,
             crapcot.vlrenrpp_ir##1  = 0,
             crapcot.vlrenrpp_ir##2  = 0,
             crapcot.vlrenrpp_ir##3  = 0,
             crapcot.vlrenrpp_ir##4  = 0,
             crapcot.vlrenrpp_ir##5  = 0,
             crapcot.vlrenrpp_ir##6  = 0,
             crapcot.vlrenrpp_ir##7  = 0,
             crapcot.vlrenrpp_ir##8  = 0,
             crapcot.vlrenrpp_ir##9  = 0,
             crapcot.vlrenrpp_ir##10 = 0,
             crapcot.vlrenrpp_ir##11 = 0,
             crapcot.vlrenrpp_ir##12 = 0,
             crapcot.vlrirrpp##1     = 0,
             crapcot.vlrirrpp##2     = 0,
             crapcot.vlrirrpp##3     = 0,
             crapcot.vlrirrpp##4     = 0,
             crapcot.vlrirrpp##5     = 0,
             crapcot.vlrirrpp##6     = 0,
             crapcot.vlrirrpp##7     = 0,
             crapcot.vlrirrpp##8     = 0,
             crapcot.vlrirrpp##9     = 0,
             crapcot.vlrirrpp##10    = 0,
             crapcot.vlrirrpp##11    = 0,
             crapcot.vlrirrpp##12    = 0,
             crapcot.vlirrdca##1     = 0,
             crapcot.vlirrdca##2     = 0,
             crapcot.vlirrdca##3     = 0,
             crapcot.vlirrdca##4     = 0,
             crapcot.vlirrdca##5     = 0,
             crapcot.vlirrdca##6     = 0,
             crapcot.vlirrdca##7     = 0,
             crapcot.vlirrdca##8     = 0,
             crapcot.vlirrdca##9     = 0,
             crapcot.vlirrdca##10    = 0,
             crapcot.vlirrdca##11    = 0,
             crapcot.vlirrdca##12    = 0,
             crapcot.vlirajus##1     = 0,
             crapcot.vlirajus##2     = 0,
             crapcot.vlirajus##3     = 0,
             crapcot.vlirajus##4     = 0,
             crapcot.vlirajus##5     = 0,
             crapcot.vlirajus##6     = 0,
             crapcot.vlirajus##7     = 0,
             crapcot.vlirajus##8     = 0,
             crapcot.vlirajus##9     = 0,
             crapcot.vlirajus##10    = 0,
             crapcot.vlirajus##11    = 0,
             crapcot.vlirajus##12    = 0,
             crapcot.vlrenrdc##1     = 0,
             crapcot.vlrenrdc##2     = 0,
             crapcot.vlrenrdc##3     = 0,
             crapcot.vlrenrdc##4     = 0,
             crapcot.vlrenrdc##5     = 0,
             crapcot.vlrenrdc##6     = 0,
             crapcot.vlrenrdc##7     = 0,
             crapcot.vlrenrdc##8     = 0,
             crapcot.vlrenrdc##9     = 0,
             crapcot.vlrenrdc##10    = 0,
             crapcot.vlrenrdc##11    = 0,
             crapcot.vlrenrdc##12    = 0,
             crapcot.vlirfrdc##1     = 0,
             crapcot.vlirfrdc##2     = 0,
             crapcot.vlirfrdc##3     = 0,
             crapcot.vlirfrdc##4     = 0,
             crapcot.vlirfrdc##5     = 0,
             crapcot.vlirfrdc##6     = 0,
             crapcot.vlirfrdc##7     = 0,
             crapcot.vlirfrdc##8     = 0,
             crapcot.vlirfrdc##9     = 0,
             crapcot.vlirfrdc##10    = 0,
             crapcot.vlirfrdc##11    = 0,
             crapcot.vlirfrdc##12    = 0,
             crapcot.vlcapmes##1     = 0,
             crapcot.vlcapmes##2     = 0,
             crapcot.vlcapmes##3     = 0,
             crapcot.vlcapmes##4     = 0,
             crapcot.vlcapmes##5     = 0,
             crapcot.vlcapmes##6     = 0,
             crapcot.vlcapmes##7     = 0,
             crapcot.vlcapmes##8     = 0,
             crapcot.vlcapmes##9     = 0,
             crapcot.vlcapmes##10    = 0,
             crapcot.vlcapmes##11    = 0,
             crapcot.vlcapmes##12    = 0
       where crapcot.rowid = rw_crapsld.rowid_cot;
    exception
      when others then
        vr_dscritic := 'Problema ao atualizar registro na tabela CRAPCOT: ' || sqlerrm;
        raise vr_exc_saida;
    end;
    -- Atualiza informações no saldo do associado
    begin
      update crapsld
         set crapsld.qtjramfx = 0,
             crapsld.qtlanano = 0,
             crapsld.qtsmamfx = 0,
             crapsld.qtipamfx = 0,
             crapsld.smposant##1  = rw_crapsld.smposano##1,
             crapsld.smposant##2  = rw_crapsld.smposano##2,
             crapsld.smposant##3  = rw_crapsld.smposano##3,
             crapsld.smposant##4  = rw_crapsld.smposano##4,
             crapsld.smposant##5  = rw_crapsld.smposano##5,
             crapsld.smposant##6  = rw_crapsld.smposano##6,
             crapsld.smposant##7  = rw_crapsld.smposano##7,
             crapsld.smposant##8  = rw_crapsld.smposano##8,
             crapsld.smposant##9  = rw_crapsld.smposano##9,
             crapsld.smposant##10 = rw_crapsld.smposano##10,
             crapsld.smposant##11 = rw_crapsld.smposano##11,
             crapsld.smposant##12 = rw_crapsld.smposano##12,
             crapsld.smnegant##1  = rw_crapsld.smnegano##1,
             crapsld.smnegant##2  = rw_crapsld.smnegano##2,
             crapsld.smnegant##3  = rw_crapsld.smnegano##3,
             crapsld.smnegant##4  = rw_crapsld.smnegano##4,
             crapsld.smnegant##5  = rw_crapsld.smnegano##5,
             crapsld.smnegant##6  = rw_crapsld.smnegano##6,
             crapsld.smnegant##7  = rw_crapsld.smnegano##7,
             crapsld.smnegant##8  = rw_crapsld.smnegano##8,
             crapsld.smnegant##9  = rw_crapsld.smnegano##9,
             crapsld.smnegant##10 = rw_crapsld.smnegano##10,
             crapsld.smnegant##11 = rw_crapsld.smnegano##11,
             crapsld.smnegant##12 = rw_crapsld.smnegano##12,
             crapsld.smblqant##1  = rw_crapsld.smblqano##1,
             crapsld.smblqant##2  = rw_crapsld.smblqano##2,
             crapsld.smblqant##3  = rw_crapsld.smblqano##3,
             crapsld.smblqant##4  = rw_crapsld.smblqano##4,
             crapsld.smblqant##5  = rw_crapsld.smblqano##5,
             crapsld.smblqant##6  = rw_crapsld.smblqano##6,
             crapsld.smblqant##7  = rw_crapsld.smblqano##7,
             crapsld.smblqant##8  = rw_crapsld.smblqano##8,
             crapsld.smblqant##9  = rw_crapsld.smblqano##9,
             crapsld.smblqant##10 = rw_crapsld.smblqano##10,
             crapsld.smblqant##11 = rw_crapsld.smblqano##11,
             crapsld.smblqant##12 = rw_crapsld.smblqano##12,
             crapsld.smespant##1  = rw_crapsld.smespano##1,
             crapsld.smespant##2  = rw_crapsld.smespano##2,
             crapsld.smespant##3  = rw_crapsld.smespano##3,
             crapsld.smespant##4  = rw_crapsld.smespano##4,
             crapsld.smespant##5  = rw_crapsld.smespano##5,
             crapsld.smespant##6  = rw_crapsld.smespano##6,
             crapsld.smespant##7  = rw_crapsld.smespano##7,
             crapsld.smespant##8  = rw_crapsld.smespano##8,
             crapsld.smespant##9  = rw_crapsld.smespano##9,
             crapsld.smespant##10 = rw_crapsld.smespano##10,
             crapsld.smespant##11 = rw_crapsld.smespano##11,
             crapsld.smespant##12 = rw_crapsld.smespano##12,
             crapsld.smposano##1  = 0,
             crapsld.smposano##2  = 0,
             crapsld.smposano##3  = 0,
             crapsld.smposano##4  = 0,
             crapsld.smposano##5  = 0,
             crapsld.smposano##6  = 0,
             crapsld.smposano##7  = 0,
             crapsld.smposano##8  = 0,
             crapsld.smposano##9  = 0,
             crapsld.smposano##10 = 0,
             crapsld.smposano##11 = 0,
             crapsld.smposano##12 = 0,
             crapsld.smnegano##1  = 0,
             crapsld.smnegano##2  = 0,
             crapsld.smnegano##3  = 0,
             crapsld.smnegano##4  = 0,
             crapsld.smnegano##5  = 0,
             crapsld.smnegano##6  = 0,
             crapsld.smnegano##7  = 0,
             crapsld.smnegano##8  = 0,
             crapsld.smnegano##9  = 0,
             crapsld.smnegano##10 = 0,
             crapsld.smnegano##11 = 0,
             crapsld.smnegano##12 = 0,
             crapsld.smblqano##1  = 0,
             crapsld.smblqano##2  = 0,
             crapsld.smblqano##3  = 0,
             crapsld.smblqano##4  = 0,
             crapsld.smblqano##5  = 0,
             crapsld.smblqano##6  = 0,
             crapsld.smblqano##7  = 0,
             crapsld.smblqano##8  = 0,
             crapsld.smblqano##9  = 0,
             crapsld.smblqano##10 = 0,
             crapsld.smblqano##11 = 0,
             crapsld.smblqano##12 = 0,
             crapsld.smespano##1  = 0,
             crapsld.smespano##2  = 0,
             crapsld.smespano##3  = 0,
             crapsld.smespano##4  = 0,
             crapsld.smespano##5  = 0,
             crapsld.smespano##6  = 0,
             crapsld.smespano##7  = 0,
             crapsld.smespano##8  = 0,
             crapsld.smespano##9  = 0,
             crapsld.smespano##10 = 0,
             crapsld.smespano##11 = 0,
             crapsld.smespano##12 = 0
       where crapsld.rowid = rw_crapsld.rowid_sld;
    exception
      when others then
        vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSLD: ' || sqlerrm;
        raise vr_exc_saida;
    end;
    -- Somente se a flag de restart estiver ativa
    IF pr_flgresta = 1 THEN
      -- Salvar informacoes no banco de dados a cada 10.000 registros processados,
      -- gravar tbm o controle de restart, pois qualquer rollback que será efetuado
      -- vai retornar a situação até o ultimo commit
      if mod(cr_crapsld%rowcount, 10000) = 0 then
        -- Atualização do controle de restart dos programas
        begin
          update crapres
             set crapres.nrdconta = rw_crapsld.nrdconta
           where rowid = rw_crapres.rowid;
        exception
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar o controle de restart: ' || sqlerrm;
            raise vr_exc_saida;
        end;
        COMMIT;
        --ROLLBACK;
      end if;
    END IF;
  end loop;

  BEGIN
    -- Atualiza o valor pago em tarifas no ano e zera as colunas para o proximo ano
    UPDATE tbcotas_tarifas_pagas ctp
       SET ctp.vlpagoanoant = ctp.vlpagomes1  + ctp.vlpagomes2  + ctp.vlpagomes3 +
                              ctp.vlpagomes4  + ctp.vlpagomes5  + ctp.vlpagomes6 +
                              ctp.vlpagomes7  + ctp.vlpagomes8  + ctp.vlpagomes9 +
                              ctp.vlpagomes10 + ctp.vlpagomes11 + ctp.vlpagomes12,
           ctp.vlpagomes1 = 0,
           ctp.vlpagomes2 = 0,
           ctp.vlpagomes3 = 0,
           ctp.vlpagomes4 = 0,
           ctp.vlpagomes5 = 0,
           ctp.vlpagomes6 = 0,
           ctp.vlpagomes7 = 0,
           ctp.vlpagomes8 = 0,
           ctp.vlpagomes9 = 0,
           ctp.vlpagomes10 = 0,
           ctp.vlpagomes11 = 0,
           ctp.vlpagomes12 = 0,
           ctp.nranolct = EXTRACT(YEAR FROM rw_crapdat.dtmvtolt) + 1
     WHERE ctp.cdcooper = pr_cdcooper;
  EXCEPTION
     WHEN OTHERS THEN
       vr_dscritic := 'Problema ao atualizar registro na tabela TBCOTAS_TARIFAS_PAGAS: ' || sqlerrm;
       RAISE vr_exc_saida;
  END;

  -- Eliminar controle de reprocesso
  btch0001.pc_elimina_restart(pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_dscritic);
  if vr_dscritic is not null then
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;

  -- Finaliza o programa com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  COMMIT;
  --ROLLBACK;
EXCEPTION
  WHEN vr_exc_fimprg then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
    --ROLLBACK;

  when vr_exc_saida then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    rollback;
  when others then
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    rollback;
END;
/
