CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS175(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  BEGIN

  /* .............................................................................

   Programa: pc_crps175                     Antigo: Fontes/crps175.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/96.                    Ultima atualizacao: 05/09/2018

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular o rendimento mensal e liquido das aplicacoes RDCA2
               e listar o resumo mensal.
               Ordem do programa na solicitacao: 4
               Relatorio 138 e 560.

   Alteracoes: 17/02/98 - Alterado para guardar no crapcot o valor abonado
                          (Deborah).

               03/03/98 - Acerto na alteracao anterior (Deborah).

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               26/01/99 - Tratar IOF e abono (Deborah).

               07/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               29/04/2002 - Nova maneira de pegar a taxa (Margarete).

               15/12/2003 - Incluir total de IRRF (Margarete).

               28/01/2004 - Nao atualizar campos de abono da cpmf (Margarete).

               19/04/2004 - Atualizar novos campos craprda (Margarete).

               24/05/2004 - Listar base de cpmf a recuperar (Margarete).

               05/07/2004 - Quando saque na carencia atualizacao vlslfmes
                            errada (Margarete).

               22/09/2004 - Incluidos historicos 494/495(CI)(Mirtes)

               07/10/2004 - Quando saque total nao esta zerando saldo
                            do final do mes (Margarete).

              16/12/2004 - Incluido historico 876(Ajuste IR)(Mirtes)

              28/12/2004 - Alinhados os campos no relatorio (Evandro).

              01/09/2005 - Tratar leitura do craprda (Margarete).

              07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                           "fontes/iniprg.p" por causa da "glb_cdcooper"
                           (Evandro).

              15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

              26/07/2006 - Campo vlslfmes passa a ser vlsdextr. E o
                            vlslfmes passa a ser o valor exato da poupanca
                            na contabilidade no ultimo dia do mes (Magui).

              28/11/2006 - Melhoria de performance (Evandro).

              11/07/2007 - Incluido na leitura do craplap para emissao do
                           relatorio os historicos possiveis (Magui).

              03/12/2007 - Substituir chamada da include rdca2s pela
                           b1wgen0004a.i (Sidnei - Precise).

              10/12/2008 - Utilizar procedure "acumula_aplicacoes" (David).

              11/05/2010 - Incluido relatorio crrl560 - Relacao Detalhada das
                           Aplicacoes (Elton).

              26/08/2010 - Inserir na crapprb a somatoria das aplicacoes.
                           Tarefa 34647 (Henrique).

*** Nao esquecer mais: campo vlsdextr criado para os extratos trimestrais.
                       O valor ali nao confere 100% com os da contabilidade.
                       Porque se a aplicacao estiver em carencia nao pode ter
                       rendimento ainda.

              26/11/2010 - Retirar da sol 3 ordem 7 e colocar na sol 83
                           ordem 4.E na CECRED sol 83 e ordem 5 (Magui).

              26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                           (Guilherme)

              13/01/2012 - Melhorar desempenho (Gabriel).

              25/07/2012 - Ajustes para Oracle (Evandro).

              01/04/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

              09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                           o restart (Marcos-Supero)

              04/11/2013 - Elimitar a vr_lsaplica (Gabriel).

              24/07/2014 - Incluido as colunas dtsdfmea e vlslfmea na CRAPRDA
                           (Andrino - RKAM)
              
              09/01/2015 - Inclusao das contas (1330497,1828762,2171805,2244993)
                           na PLTABLE(vr_tab_craplap) conforme chamado 240937
                           (Carlos Rafael Tanholi) 
                           
              25/03/2015 - Projeto de separação contábeis de PF e PJ.
                           (Andre Santos - SUPERO)
                           
              03/08/2015 - Não exibir no arquivo informações de agencias com valor 
                           zero. Conforme chamado 315716. ( Renato - Supero )

              13/06/2016 - Ajustado leitura da contas bloqueadas para utilizar a rotina padrao
                           e o cursor da craptab para utilizar o indice na pesquisa
                           (Douglas - Chamado 454248)
                           
             28/09/2016 - Alteração do diretório para geração de arquivo contábil.
                          P308 (Ricardo Linhares).    
                          
             17/03/2017 - Remover linhas de reversão das contas de resultado e incluir
                          lançamentos de novos históricos para o arquivo Radar ou Matera (Jonatas - Supero)                
                                                  
             14/08/2018 - Inclusão da Aplicação Programada
                          Proj. 411.2 (CIS Corporate)
                           
             05/09/2018 - Correção do cursor cr_craplpp - UNION ALL (Proj. 411.2 - CIS Corporate).             
             
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps175 */

       --Definicao do tipo de registro para tabela detalhes
       TYPE typ_reg_detalhe IS
         RECORD (tpaplica INTEGER
                ,cdagenci INTEGER
                ,nrdconta INTEGER
                ,nraplica INTEGER
                ,dtaplica DATE
                ,vlaplica NUMBER
                ,vlrgtmes NUMBER
                ,vlsldrdc NUMBER
                ,txaplica NUMBER
                ,nmprimtl crapass.nmprimtl%TYPE);
                
       -- PL Table para armazenar valores totais por PF e PJ
       TYPE typ_reg_total IS
         RECORD(qtaplati NUMBER DEFAULT 0
               ,qtaplmes NUMBER DEFAULT 0
               ,vlsdapat NUMBER DEFAULT 0
               ,vlaplmes NUMBER DEFAULT 0               
               ,vlresmes NUMBER DEFAULT 0               
               ,vlsaques NUMBER DEFAULT 0               
               ,qtrenmfx NUMBER DEFAULT 0               
               ,vlrenmes NUMBER DEFAULT 0               
               ,vlprvmes NUMBER DEFAULT 0               
               ,vlprvlan NUMBER DEFAULT 0                              
               ,vlajuprv NUMBER DEFAULT 0               
               ,vlrirrf  NUMBER DEFAULT 0
               ,vlrirab  NUMBER DEFAULT 0
               ,vlirajrg NUMBER DEFAULT 0
               ,bsabcpmf NUMBER DEFAULT 0);

       --Definicao dos tipos de tabelas de memoria
       TYPE typ_tab_bndes IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       TYPE typ_tab_detalhe IS TABLE OF typ_reg_detalhe INDEX BY VARCHAR2(25);
       TYPE typ_tab_iof IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
       TYPE typ_tab_total IS TABLE OF typ_reg_total INDEX BY PLS_INTEGER;
       
       -- Instancia e indexa por agencia as aplicacoes rdca 60 ativas de pessoa fisica
       TYPE typ_tab_vlrdcage_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       vr_typ_tab_vlrdcage_fis typ_tab_vlrdcage_fis;
    
       -- Instancia e indexa por agencia as aplicacoes rdca 60 ativas de pessoa juridica
       TYPE typ_tab_vlrdcage_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       vr_typ_tab_vlrdcage_jur typ_tab_vlrdcage_jur;
       
       -- Instancia e indexa por agencia as previsoes mensais de pessoa fisica
       TYPE typ_tab_tot_vlprvfis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       vr_tab_tot_vlprvfis typ_tab_tot_vlprvfis;
       
       -- Instancia e indexa por agencia as previsoes mensais de pessoa juridica
       TYPE typ_tab_tot_vlprvjur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       vr_tab_tot_vlprvjur typ_tab_tot_vlprvjur;
       
       -- Instancia e indexa por agencia os ajustes de previsoes mensais de pessoa fisica
       TYPE typ_tab_tot_vlajusprv_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       vr_tab_tot_vlajusprv_fis typ_tab_tot_vlajusprv_fis;
       
       -- Instancia e indexa por agencia os ajustes de previsoes mensais de pessoa juridica
       TYPE typ_tab_tot_vlajusprv_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       vr_tab_tot_vlajusprv_jur typ_tab_tot_vlajusprv_jur;       
       
       --Definicao das tabelas de memoria
       vr_tab_bndes      typ_tab_bndes;
       vr_tab_detalhe    typ_tab_detalhe;
       vr_tab_craplap    typ_tab_bndes;
       vr_tab_crapage    typ_tab_bndes;
       vr_tab_abiof      typ_tab_iof;
       vr_tab_total typ_tab_total;

       --Definicao das tabelas de memoria da apli0001.pc_acumula_aplicacoes
       vr_tab_acumula    APLI0001.typ_tab_acumula_aplic;
       vr_tab_tpregist   APLI0001.typ_tab_tpregist;
       vr_tab_erro       GENE0001.typ_tab_erro;
       vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
       vr_tab_craplpp    APLI0001.typ_tab_craplpp;
       vr_tab_craplrg    APLI0001.typ_tab_craplpp;
       vr_tab_resgate    APLI0001.typ_tab_resgate;
       vr_split_histor   GENE0002.typ_split;

       --Cursores da rotina crps175

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
       --Selecionar informacoes dos associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT  crapass.cdagenci
                ,crapass.nrdconta
                ,crapass.nmprimtl
         FROM crapass crapass
         WHERE  crapass.cdcooper = pr_cdcooper
         ORDER BY crapass.nrdconta ASC;
       rw_crapass cr_crapass%ROWTYPE;
       --Selecionar informacoes dos associados
       CURSOR cr_crapass_agencia (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT  crapass.cdagenci
                ,crapass.nrdconta
         FROM crapass crapass
         WHERE  crapass.cdcooper = pr_cdcooper;

       --Selecionar Informacoes das agencias
       CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE
                         ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
         SELECT crapage.cdagenci
               ,crapage.nmresage
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper
         AND   crapage.cdagenci = pr_cdagenci;
       rw_crapage cr_crapage%ROWTYPE;
       --Selecionar informacoes dos lancamentos das aplicacoes rdca
       CURSOR cr_craplap (pr_cdcooper IN craplap.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplap.dtmvtolt%TYPE) IS
         SELECT craplap.nrdconta
         FROM  craplap craplap
         WHERE craplap.cdcooper = pr_cdcooper
         AND   craplap.dtmvtolt = pr_dtmvtolt
         AND   craplap.cdhistor = 180;
       --Selecionar informacoes dos lancamentos das aplicacoes rdca
       CURSOR cr_craplap_histor (pr_cdcooper IN craplap.cdcooper%TYPE
                                ,pr_dtmvtolt IN craplap.dtmvtolt%TYPE
                                ,pr_cdhistor IN craplap.cdhistor%TYPE) IS
         SELECT craplap.nrdconta
               ,crapass.inpessoa
               ,craplap.nraplica
               ,craplap.nrdolote
               ,craplap.cdhistor
               ,craplap.vllanmto
         FROM  craplap craplap
              ,crapass crapass
         WHERE craplap.cdcooper = crapass.cdcooper
         AND   craplap.nrdconta = crapass.nrdconta
         AND   craplap.cdcooper = pr_cdcooper
         AND   craplap.dtmvtolt = pr_dtmvtolt
         AND   craplap.cdhistor = pr_cdhistor;

       --Selecionar informacoes das aplicacoes rdca
       CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE
                         ,pr_tpaplica IN craprda.tpaplica%TYPE
                         ,pr_insaqtot IN craprda.insaqtot%TYPE
                         ,pr_cdageass IN craprda.cdageass%TYPE
                         ,pr_nrdconta IN craprda.nrdconta%TYPE) IS
         SELECT craprda.dtcalcul
               ,craprda.insaqtot
               ,craprda.nrdconta
               ,craprda.cdagenci
               ,crapass.inpessoa
               ,craprda.nraplica
               ,craprda.flgctain
               ,craprda.vlabcpmf
               ,craprda.vlaplica
               ,craprda.vlrgtacu
               ,craprda.qtrgtmfx
               ,craprda.qtaplmfx
               ,craprda.dtmvtolt
               ,craprda.vlabdiof
               ,craprda.vlabiord
               ,craprda.vlslfmes
               ,craprda.cdageass
               ,craprda.vlsdextr
               ,craprda.dtsdfmes
               ,craprda.tpaplica
               ,craprda.rowid
         FROM craprda craprda
             ,crapass crapass
         WHERE craprda.cdcooper = crapass.cdcooper
         AND   craprda.nrdconta = crapass.nrdconta
         AND   craprda.cdcooper = pr_cdcooper
         AND   craprda.tpaplica = pr_tpaplica
         AND   craprda.insaqtot = pr_insaqtot
         AND   craprda.cdageass = pr_cdageass
         AND   craprda.nrdconta = pr_nrdconta;
       --Selecionar informacoes das aplicacoes rdca
       CURSOR cr_craprda_histor (pr_cdcooper IN craprda.cdcooper%TYPE
                                ,pr_nrdconta IN craprda.nrdconta%TYPE
                                ,pr_nraplica IN craprda.nraplica%TYPE) IS
         SELECT craprda.insaqtot
               ,craprda.nrdconta
               ,crapass.inpessoa
               ,crapass.cdagenci
               ,craprda.nraplica
               ,craprda.flgctain
         FROM craprda craprda
             ,crapass crapass
         WHERE craprda.cdcooper = crapass.cdcooper
         AND   craprda.nrdconta = crapass.nrdconta
         AND   craprda.cdcooper = pr_cdcooper
         AND   craprda.nrdconta = pr_nrdconta
         AND   craprda.nraplica = pr_nraplica;
      rw_craprda_histor cr_craprda_histor%ROWTYPE;
      -- Cursor genérico de parametrização */
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_dstextab IN craptab.dstextab%TYPE) IS
        SELECT craptab.dstextab
              ,craptab.tpregist
        FROM craptab craptab
        WHERE craptab.cdcooper = pr_cdcooper
          AND UPPER(craptab.nmsistem) = UPPER(pr_nmsistem)
          AND UPPER(craptab.tptabela) = UPPER(pr_tptabela)
          AND craptab.cdempres = pr_cdempres
          AND UPPER(craptab.cdacesso) = UPPER(pr_cdacesso)
          AND craptab.dstextab = pr_dstextab;

      --Selecionar quantidade de saques em poupanca nos ultimos 6 meses
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
        SELECT lpp.nrdconta                   -- LPP naturalmente apenas as Poupanças antigas
              ,lpp.nrctrrpp
              ,Count(*) qtlancmto
        FROM craplpp lpp
        WHERE lpp.cdcooper = pr_cdcooper
        AND   lpp.cdhistor IN (158,496)
        AND   lpp.dtmvtolt > pr_dtmvtolt
        GROUP BY lpp.nrdconta,lpp.nrctrrpp
        HAVING Count(*) > 3
        UNION ALL
        SELECT rac.nrdconta
              ,rac.nrctrrpp
              ,Count(*) qtlancmto
        FROM crapcpc cpc, craprac rac, craplac lac
        WHERE rac.cdcooper = pr_cdcooper
        AND   rac.nrctrrpp > 0                 -- Apenas apl. programadas
        AND   cpc.cdprodut = rac.cdprodut
        AND   rac.cdcooper = lac.cdcooper
        AND   rac.nrdconta = lac.nrdconta
        AND   rac.nraplica = lac.nraplica 
        AND   lac.cdhistor in (cpc.cdhsrgap)
        AND   lac.dtmvtolt > pr_dtmvtolt       
        GROUP BY rac.nrdconta,rac.nrctrrpp        
        HAVING Count(*) > 3;

      --Contar a quantidade de resgates das contas
      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE) IS
        --Aqui
        SELECT craplrg.nrdconta,craplrg.nraplica,Count(*) qtlancmto
        FROM craplrg craplrg
        WHERE craplrg.cdcooper = pr_cdcooper
        AND   craplrg.tpaplica = 4
        AND   craplrg.inresgat = 0
        GROUP BY craplrg.nrdconta
                ,craplrg.nraplica;

      --Selecionar informacoes dos lancamentos de resgate
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,craplrg.tpaplica
              ,craplrg.tpresgat
              ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
        FROM craplrg craplrg
        WHERE craplrg.cdcooper  = pr_cdcooper
        AND   craplrg.dtresgat <= pr_dtresgat
        AND   craplrg.inresgat  = 0
        AND   craplrg.tpresgat  = 1
        GROUP BY craplrg.nrdconta
                ,craplrg.nraplica
                ,craplrg.tpaplica
                ,craplrg.tpresgat;

       --Variaveis Locais

       vr_res_qtaplati   INTEGER:= 0;
       vr_res_qtaplati_a INTEGER:= 0;
       vr_res_qtaplati_n INTEGER:= 0;
       vr_res_qtaplmes   INTEGER:= 0;
       vr_res_qtaplmes_a INTEGER:= 0;
       vr_res_qtaplmes_n INTEGER:= 0;
       vr_res_vlsdapat   NUMBER:= 0;
       vr_res_vlsdapat_a NUMBER:= 0;
       vr_res_vlsdapat_n NUMBER:= 0;
       vr_res_vlaplmes   NUMBER:= 0;
       vr_res_vlaplmes_a NUMBER:= 0;
       vr_res_vlaplmes_n NUMBER:= 0;
       vr_res_vlresmes   NUMBER:= 0;
       vr_res_vlresmes_a NUMBER:= 0;
       vr_res_vlresmes_n NUMBER:= 0;
       vr_res_vlrenmes   NUMBER:= 0;
       vr_res_vlrenmes_a NUMBER:= 0;
       vr_res_vlrenmes_n NUMBER:= 0;
       vr_res_vlrirrf    NUMBER:= 0;
       vr_res_vlrirrf_a  NUMBER:= 0;
       vr_res_vlrirrf_n  NUMBER:= 0;
       vr_res_vlrirab    NUMBER:= 0;
       vr_res_vlrirab_a  NUMBER:= 0;
       vr_res_vlrirab_n  NUMBER:= 0;
       vr_res_vlprvmes   NUMBER:= 0;
       vr_res_vlprvmes_a NUMBER:= 0;
       vr_res_vlprvmes_n NUMBER:= 0;
       vr_res_vlprvlan   NUMBER:= 0;
       vr_res_vlprvlan_a NUMBER:= 0;
       vr_res_vlprvlan_n NUMBER:= 0;
       vr_res_vlajuprv   NUMBER:= 0;
       vr_res_vlajuprv_a NUMBER:= 0;
       vr_res_vlajuprv_n NUMBER:= 0;
       vr_res_vlsaques   NUMBER:= 0;
       vr_res_vlsaques_a NUMBER:= 0;
       vr_res_vlsaques_n NUMBER:= 0;
       vr_res_bsabcpmf   NUMBER:= 0;
       vr_res_bsabcpmf_a NUMBER:= 0;
       vr_res_bsabcpmf_n NUMBER:= 0;
       vr_res_qtrenmfx   NUMBER:= 0;
       vr_res_qtrenmfx_a NUMBER:= 0;
       vr_res_qtrenmfx_n NUMBER:= 0;
       vr_res_vlirajrg_a NUMBER:= 0;
       vr_res_vlirajrg_n NUMBER:= 0;
       vr_res_vlirajrg   NUMBER:= 0;
       vr_rd2_txaplica   NUMBER:= 0;
       vr_qtrenmfx       NUMBER:= 0;
       vr_percenir       NUMBER:= 0;
       vr_dtmvtolt       DATE;
       vr_dtmvtopr       DATE;
       vr_dtinimes       DATE;
       vr_dtfimmes       DATE;
       vr_dtutdmes       DATE;
       vr_data           DATE;
       vr_flgdomes       BOOLEAN;
       vr_vltotrda       CRAPRDA.VLSDRDCA%TYPE;
       vr_vlsdextr       CRAPRDA.VLSDEXTR%TYPE;
       vr_vlslfmes       CRAPRDA.VLSLFMES%TYPE;
       vr_txaplica       CRAPLAP.TXAPLICA%TYPE;
       vr_txaplmes       CRAPLAP.TXAPLMES%TYPE;
       vr_vlretorn       CRAPRDA.VLSLFMES%TYPE;
       vr_contador       INTEGER:= 0;
       vr_cdcritic       INTEGER:= 0;
       vr_qtdfaxir       INTEGER:= 0;
       vr_listahis       VARCHAR2(4000);
       vr_dscritic       VARCHAR2(4000);
       vr_typ_saida      VARCHAR2(4000);
       vr_dscomand       VARCHAR2(1000);
       vr_dstitulo       VARCHAR2(100);

       -- Controle de arquivos
       vr_dircon VARCHAR2(200);
       vr_arqcon VARCHAR2(200);


       -- Valores utilizados para contabilidade
       vr_tot_vlprvfis        NUMBER:= 0;
       vr_tot_vlprvjur        NUMBER:= 0;
       vr_tot_vlajusprv_fis   NUMBER:= 0;
       vr_tot_vlajusprv_jur   NUMBER:= 0;       

       vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS175'; -- Codigo do programa
       vr_retorno        VARCHAR2(3);

       --Variavel para receber valor data inicio e fim para calculo taxa rdcpos.
       vr_dstextab_rdcpos craptab.dstextab%TYPE;
       vr_dtinitax     DATE;    --> Data de inicio da utilizacao da taxa de poupanca.
       vr_dtfimtax     DATE;    --> Data de fim da utilizacao da taxa de poupanca.

       --Variaveis de Retorno da Procedure pc_acumula_aplicacoes
       vr_vlsdrdca NUMBER:= 0;  --> Saldo da aplicação
       
       -- Constante destinada a guardar o valor do prefixo para a mensagem de cabecalho da reversao
       vr_dsprefix      VARCHAR2(15) := 'REVERSAO ';

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_craprda VARCHAR2(20);
       vr_index_craplpp VARCHAR2(20);
       vr_index_craplrg VARCHAR2(20);
       vr_index_resgate VARCHAR2(25);
       vr_index_detalhe VARCHAR2(25);
       vr_index_split   VARCHAR2(20);
       vr_index_bndes   INTEGER;
       vr_nmarqtxt       VARCHAR2(100);                  --> Nome do arquivo TXT
       vr_input_file     UTL_FILE.file_type;             --> Handle Utl File
       vr_setlinha       VARCHAR2(400);                  --> Linhas do arquivo
       vr_tot_rdcagefis  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Fisicas
       vr_tot_rdcagejur  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Juridica

       -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;
       vr_des_chave   VARCHAR2(400);

       --Variavel para arquivo de dados e xml
       vr_nom_direto  VARCHAR2(400);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis de Excecao
       vr_exc_undo  EXCEPTION;
       vr_exc_erro  EXCEPTION;
       vr_exc_fim   EXCEPTION;
       vr_exc_pula  EXCEPTION;
       vr_exc_fimprg EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_bndes.DELETE;
         vr_tab_detalhe.DELETE;
         vr_tab_craplap.DELETE;
         vr_tab_crapage.DELETE;
         vr_tab_craplpp.DELETE;
         vr_tab_craplrg.DELETE;
         vr_tab_resgate.DELETE;
         vr_tab_tpregist.DELETE;
         vr_tab_conta_bloq.DELETE;
         vr_tab_total.DELETE;
         vr_typ_tab_vlrdcage_fis.DELETE;
         vr_typ_tab_vlrdcage_jur.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps175.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;

       --Inicializar a tabela de memoria de iof
       PROCEDURE pc_inicializa_tabela_iof IS
       BEGIN
         --Inicializar todas as posicoes do varray com 0.
         FOR idx IN 1..12 LOOP
           vr_tab_abiof(idx):= 0;
         END LOOP;
       END;

       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

       --Geração do relatório crrl138
       PROCEDURE pc_imprime_crrl138 (pr_des_erro OUT VARCHAR2) IS

         --Variaveis auxiliares dos relatorios

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= NULL;
         -- Busca do diretório base da cooperativa
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl138';
         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl138><reg>');
         pc_escreve_xml('<res>
                  <res_qtaplati_a>'||To_Char(vr_res_qtaplati_a,'fm999g990')||'</res_qtaplati_a>
                  <res_qtaplati_n>'||To_Char(vr_res_qtaplati_n,'fm999g990')||'</res_qtaplati_n>
                  <res_qtaplati>'  ||To_Char(vr_res_qtaplati,'fm999g990')||'</res_qtaplati>
                  <tot_qtatifis>'  ||To_Char(nvl(vr_tab_total(1).qtaplati, 0),'fm999g990') || '</tot_qtatifis>
                  <tot_qtatijur>'  ||To_Char(nvl(vr_tab_total(2).qtaplati, 0), 'fm999g990') || '</tot_qtatijur>
                  <res_qtaplmes_a>'||To_Char(vr_res_qtaplmes_a,'fm999g990')||'</res_qtaplmes_a>
                  <res_qtaplmes_n>'||To_Char(vr_res_qtaplmes_n,'fm999g990')||'</res_qtaplmes_n>
                  <res_qtaplmes>'  ||To_Char(vr_res_qtaplmes,'fm999g990')||'</res_qtaplmes>
                  <tot_qtmesfis>'  ||To_Char(nvl(vr_tab_total(1).qtaplmes, 0),'fm999g990') || '</tot_qtmesfis>
                  <tot_qtmesjur>'  ||To_Char(nvl(vr_tab_total(2).qtaplmes, 0), 'fm999g990') || '</tot_qtmesjur>
                  <res_vlsdapat_a>'||To_Char(vr_res_vlsdapat_a,'fm99g999g999g990d00')||'</res_vlsdapat_a>
                  <res_vlsdapat_n>'||To_Char(vr_res_vlsdapat_n,'fm99g999g999g990d00')||'</res_vlsdapat_n>
                  <res_vlsdapat>'  ||To_Char(vr_res_vlsdapat,'fm99g999g999g990d00')||'</res_vlsdapat>
                  <tot_sdapatfis>' ||To_Char(nvl(vr_tab_total(1).vlsdapat, 0),'fm99g999g999g990d00') || '</tot_sdapatfis>
                  <tot_sdapatjur>' ||To_Char(nvl(vr_tab_total(2).vlsdapat, 0), 'fm99g999g999g990d00') || '</tot_sdapatjur>
                  <res_vlaplmes_a>'||To_Char(vr_res_vlaplmes_a,'fm99g999g999g990d00')||'</res_vlaplmes_a>
                  <res_vlaplmes_n>'||To_Char(vr_res_vlaplmes_n,'fm99g999g999g990d00')||'</res_vlaplmes_n>
                  <res_vlaplmes>'  ||To_Char(vr_res_vlaplmes,'fm99g999g999g990d00')||'</res_vlaplmes>
                  <tot_aplmesfis>' ||To_Char(nvl(vr_tab_total(1).vlaplmes, 0),'fm99g999g999g990d00') || '</tot_aplmesfis>
                  <tot_aplmesjur>' ||To_Char(nvl(vr_tab_total(2).vlaplmes, 0), 'fm99g999g999g990d00') || '</tot_aplmesjur>
                  <res_vlresmes_a>'||To_Char(vr_res_vlresmes_a,'fm99g999g999g990d00')||'</res_vlresmes_a>
                  <res_vlresmes_n>'||To_Char(vr_res_vlresmes_n,'fm99g999g999g990d00')||'</res_vlresmes_n>
                  <res_vlresmes>'  ||To_Char(vr_res_vlresmes,'fm99g999g999g990d00')||'</res_vlresmes>
                  <tot_resmesfis>' ||To_Char(nvl(vr_tab_total(1).vlresmes, 0),'fm99g999g999g990d00') || '</tot_resmesfis>
                  <tot_resmesjur>' ||To_Char(nvl(vr_tab_total(2).vlresmes, 0), 'fm99g999g999g990d00') || '</tot_resmesjur>
                  <res_vlrenmes_a>'||To_Char(vr_res_vlrenmes_a,'fm99g999g999g990d00')||'</res_vlrenmes_a>
                  <res_vlrenmes_n>'||To_Char(vr_res_vlrenmes_n,'fm99g999g999g990d00')||'</res_vlrenmes_n>
                  <res_vlrenmes>'  ||To_Char(vr_res_vlrenmes,'fm99g999g999g990d00')||'</res_vlrenmes>
                  <tot_renmesfis>' ||To_Char(nvl(vr_tab_total(1).vlrenmes, 0),'fm99g999g999g990d00') || '</tot_renmesfis>
                  <tot_renmesjur>' ||To_Char(nvl(vr_tab_total(2).vlrenmes, 0), 'fm99g999g999g990d00') || '</tot_renmesjur>
                  <res_vlprvmes_a>'||To_Char(vr_res_vlprvmes_a,'fm99g999g999g990d00')||'</res_vlprvmes_a>
                  <res_vlprvmes_n>'||To_Char(vr_res_vlprvmes_n,'fm99g999g999g990d00')||'</res_vlprvmes_n>
                  <res_vlprvmes>'  ||To_Char(vr_res_vlprvmes,'fm99g999g999g990d00')||'</res_vlprvmes>
                  <tot_prvmesfis>' ||To_Char(nvl(vr_tab_total(1).vlprvmes, 0),'fm99g999g999g990d00') || '</tot_prvmesfis>
                  <tot_prvmesjur>' ||To_Char(nvl(vr_tab_total(2).vlprvmes, 0), 'fm99g999g999g990d00') || '</tot_prvmesjur>
                  <res_vlprvlan_a>'||To_Char(vr_res_vlprvlan_a,'fm99g999g999g990d00')||'</res_vlprvlan_a>
                  <res_vlprvlan_n>'||To_Char(vr_res_vlprvlan_n,'fm99g999g999g990d00')||'</res_vlprvlan_n>
                  <res_vlprvlan>'  ||To_Char(vr_res_vlprvlan,'fm99g999g999g990d00')||'</res_vlprvlan>
                  <tot_prvlanfis>' ||To_Char(nvl(vr_tab_total(1).vlprvlan, 0),'fm99g999g999g990d00') || '</tot_prvlanfis>
                  <tot_prvlanjur>' ||To_Char(nvl(vr_tab_total(2).vlprvlan, 0), 'fm99g999g999g990d00') || '</tot_prvlanjur>
                  <res_vlajuprv_a>'||To_Char(vr_res_vlajuprv_a,'fm99g999g999g990d00')||'</res_vlajuprv_a>
                  <res_vlajuprv_n>'||To_Char(vr_res_vlajuprv_n,'fm99g999g999g990d00')||'</res_vlajuprv_n>
                  <res_vlajuprv>'  ||To_Char(vr_res_vlajuprv,'fm99g999g999g990d00')||'</res_vlajuprv>
                  <tot_ajuprvfis>' ||To_Char(nvl(vr_tab_total(1).vlajuprv, 0),'fm99g999g999g990d00') || '</tot_ajuprvfis>
                  <tot_ajuprvjur>' ||To_Char(nvl(vr_tab_total(2).vlajuprv, 0), 'fm99g999g999g990d00') || '</tot_ajuprvjur>
                  <res_vlsaques_a>'||To_Char(vr_res_vlsaques_a,'fm99g999g999g990d00')||'</res_vlsaques_a>
                  <res_vlsaques_n>'||To_Char(vr_res_vlsaques_n,'fm99g999g999g990d00')||'</res_vlsaques_n>
                  <res_vlsaques>'  ||To_Char(vr_res_vlsaques,'fm99g999g999g990d00')||'</res_vlsaques>
                  <tot_saquesfis>' ||To_Char(nvl(vr_tab_total(1).vlsaques, 0),'fm99g999g999g990d00') || '</tot_saquesfis>
                  <tot_saquesjur>' ||To_Char(nvl(vr_tab_total(2).vlsaques, 0), 'fm99g999g999g990d00') || '</tot_saquesjur>
                  <res_qtrenmfx_a>'||To_Char(vr_res_qtrenmfx_a,'fm99g999g999g990d0000')||'</res_qtrenmfx_a>
                  <res_qtrenmfx_n>'||To_Char(vr_res_qtrenmfx_n,'fm99g999g999g990d0000')||'</res_qtrenmfx_n>
                  <res_qtrenmfx>'  ||To_Char(vr_res_qtrenmfx,'fm99g999g999g990d0000')||'</res_qtrenmfx>
                  <tot_renmfxfis>' ||To_Char(nvl(vr_tab_total(1).qtrenmfx, 0),'fm99g999g999g990d0000') || '</tot_renmfxfis>
                  <tot_renmfxjur>' ||To_Char(nvl(vr_tab_total(2).qtrenmfx, 0), 'fm99g999g999g990d0000') || '</tot_renmfxjur>
                  <res_vlrirrf_a>' ||To_Char(vr_res_vlrirrf_a,'fm99g999g999g990d00')||'</res_vlrirrf_a>
                  <res_vlrirrf_n>' ||To_Char(vr_res_vlrirrf_n,'fm99g999g999g990d00')||'</res_vlrirrf_n>
                  <res_vlrirrf>'   ||To_Char(vr_res_vlrirrf,'fm99g999g999g990d00')||'</res_vlrirrf>
                  <tot_irrffis>'   ||To_Char(nvl(vr_tab_total(1).vlrirrf, 0),'fm99g999g999g990d00') || '</tot_irrffis>
                  <tot_irrfjur>'   ||To_Char(nvl(vr_tab_total(2).vlrirrf, 0), 'fm99g999g999g990d00') || '</tot_irrfjur>
                  <res_vlrirab_a>' ||To_Char(vr_res_vlrirab_a,'fm99g999g999g990d00')||'</res_vlrirab_a>
                  <res_vlrirab_n>' ||To_Char(vr_res_vlrirab_n,'fm99g999g999g990d00')||'</res_vlrirab_n>
                  <res_vlrirab>'   ||To_Char(vr_res_vlrirab,'fm99g999g999g990d00')||'</res_vlrirab>
                  <tot_rirabfis>'  ||To_Char(nvl(vr_tab_total(1).vlrirab, 0),'fm99g999g999g990d00') || '</tot_rirabfis>
                  <tot_rirabjur>'  ||To_Char(nvl(vr_tab_total(2).vlrirab, 0), 'fm99g999g999g990d00') || '</tot_rirabjur>
                  <res_vlirajrg_a>'||To_Char(vr_res_vlirajrg_a,'fm99g999g999g990d00')||'</res_vlirajrg_a>
                  <res_vlirajrg_n>'||To_Char(vr_res_vlirajrg_n,'fm99g999g999g990d00')||'</res_vlirajrg_n>
                  <res_vlirajrg>'  ||To_Char(vr_res_vlirajrg,'fm99g999g999g990d00')||'</res_vlirajrg>
                  <tot_irajrgfis>' ||To_Char(nvl(vr_tab_total(1).vlirajrg, 0),'fm99g999g999g990d00') || '</tot_irajrgfis>
                  <tot_irajrgjur>' ||To_Char(nvl(vr_tab_total(2).vlirajrg, 0), 'fm99g999g999g990d00') || '</tot_irajrgjur>
                  <res_bsabcpmf_a>'||To_Char(vr_res_bsabcpmf_a,'fm99g999g999g990d00')||'</res_bsabcpmf_a>
                  <res_bsabcpmf_n>'||To_Char(vr_res_bsabcpmf_n,'fm99g999g999g990d00')||'</res_bsabcpmf_n>
                  <res_bsabcpmf>'  ||To_Char(vr_res_bsabcpmf,'fm99g999g999g990d00')||'</res_bsabcpmf>
                  <tot_bsabcpmffis>' ||To_Char(nvl(vr_tab_total(1).bsabcpmf, 0),'fm99g999g999g990d00') || '</tot_bsabcpmffis>
                  <tot_bsabcpmfjur>' ||To_Char(nvl(vr_tab_total(2).bsabcpmf, 0), 'fm99g999g999g990d00') || '</tot_bsabcpmfjur>
                </res>');

         --Finalizar agrupador recadastro e relatorio
         pc_escreve_xml('</reg></crrl138>');

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl138/reg/res'  --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl138.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Sem parametros
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_dscritic);       --> Saída com erro  */
         -- Testar se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_dscritic;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl138. '||sqlerrm;
       END;


       --Geração do relatório crrl560
       PROCEDURE pc_imprime_crrl560 (pr_des_erro OUT VARCHAR2) IS

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= NULL;
         -- Busca do diretório base da cooperativa
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl560';
         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl560><agencias>');

         -- Processar todos os registros dos maiores depositantes
         vr_des_chave := vr_tab_detalhe.FIRST;
         --Enquanto o registro nao for nulo
         WHILE vr_des_chave IS NOT NULL LOOP

           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_detalhe.FIRST OR vr_tab_detalhe(vr_des_chave).cdagenci <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave)).cdagenci THEN
             --Selecionar dados da agencia
             OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => vr_tab_detalhe(vr_des_chave).cdagenci);
             --Posicionar no proximo registro
             FETCH cr_crapage INTO rw_crapage;
             --Fechar Cursor
             CLOSE cr_crapage;
             pc_escreve_xml('<agencia cdagenci="'||rw_crapage.cdagenci||'" nmresage="'||rw_crapage.nmresage||'">');
           END IF;
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
                 ('<conta>
                    <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_detalhe(vr_des_chave).nrdconta))||'</nrdconta>
                    <nmprimtl>'||substr(vr_tab_detalhe(vr_des_chave).nmprimtl,1,32)||'</nmprimtl>
                    <nraplica>'||To_Char(vr_tab_detalhe(vr_des_chave).nraplica,'999g990')||'</nraplica>
                    <dtaplica>'||To_Char(vr_tab_detalhe(vr_des_chave).dtaplica,'DD/MM/YYYY')||'</dtaplica>
                    <vlaplica>'||To_Char(vr_tab_detalhe(vr_des_chave).vlaplica,'fm999g999g990d00')||'</vlaplica>
                    <vlrgtmes>'||To_Char(vr_tab_detalhe(vr_des_chave).vlrgtmes,'fm999g999g990d00')||'</vlrgtmes>
                    <vlsldrdc>'||To_Char(vr_tab_detalhe(vr_des_chave).vlsldrdc,'fm999g999g990d00')||'</vlsldrdc>
                    <txaplica>'||To_Char(vr_tab_detalhe(vr_des_chave).txaplica,'fm990d000000')||'</txaplica>
                 </conta>');
           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_detalhe.LAST OR vr_tab_detalhe(vr_des_chave).cdagenci <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave)).cdagenci THEN
             -- Finalizar o agrupador de agencia
             pc_escreve_xml('</agencia>');
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_detalhe.NEXT(vr_des_chave);
         END LOOP;

         --Finalizar agrupador recadastro e relatorio
         pc_escreve_xml('</agencias></crrl560>');

         --Montar o titulo do relatorio somente se existir detalhe
         IF vr_tab_detalhe.COUNT > 0 THEN
           vr_dstitulo:= 'APLICACOES TIPO '||to_char(vr_tab_detalhe(vr_tab_detalhe.FIRST).tpaplica,'fm99')||' - RDCA30';
         ELSE--> Enviar null
           vr_dstitulo:= 'APLICACOES TIPO ?? - RDCA30';
         END IF;
         
         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl560/agencias/agencia/conta' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl560.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => 'PR_DSTITULO##'||vr_dstitulo  --> Titulo do relatório
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_dscritic);       --> Saída com erro  */
         -- Testar se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_dscritic;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl560. '||sqlerrm;
       END;
     ---------------------------------------
     -- Inicio Bloco Principal pc_crps175
     ---------------------------------------
     BEGIN

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         vr_cdcritic:= 651;
         -- Montar mensagem de critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_erro;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;
       
       -- Inicializa a Pl-Table que separa as informações por PF e PJ
       FOR idx IN 1..2 LOOP
          vr_tab_total(idx).qtaplati := 0;
          vr_tab_total(idx).qtaplmes := 0;
          vr_tab_total(idx).vlsdapat := 0;
          vr_tab_total(idx).vlaplmes := 0;
          vr_tab_total(idx).vlresmes := 0;
          vr_tab_total(idx).vlsaques := 0;
          vr_tab_total(idx).qtrenmfx := 0;
          vr_tab_total(idx).vlrenmes := 0;
          vr_tab_total(idx).vlprvmes := 0;
          vr_tab_total(idx).vlprvlan := 0;
          vr_tab_total(idx).vlajuprv := 0;
          vr_tab_total(idx).vlrirrf  := 0;
          vr_tab_total(idx).vlrirab  := 0;
          vr_tab_total(idx).vlirajrg := 0;
          vr_tab_total(idx).bsabcpmf := 0;
       END LOOP;

       --Atribuir a data de inicio como o ultimo dia do mes anterior
       vr_dtinimes:= rw_crapdat.dtultdma;
       --Atribuir a data de fim como o primeiro dia do mes seguinte
       vr_dtfimmes:= rw_crapdat.dtpridms;
       --Inicializar variavel de critica
       vr_cdcritic:= 0;
       --Montar lista de Historicos
       vr_listahis:= '178,494,179,180,181,182,183,495,862,876,871';
       --Atribuir data do ultimo dia util do mes anterior
       vr_dtutdmes:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => rw_crapdat.dtultdma
                                                ,pr_tipo     => 'A'
												,pr_feriado  => true
                                                ,pr_excultdia => true);

       --Carregar tabela de memoria de lancamentos aplicacoes rdca
       FOR rw_craplap IN cr_craplap (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => vr_dtutdmes) LOOP
         vr_tab_craplap(rw_craplap.nrdconta):= 0;
       END LOOP;

       /* Devido INC0032174 - as provisões do dia 31/01/2019 não foram realizados, forçar com as provisões do dia 31/12/2018.
          Pode ser removido apos programa rodar no dia 28/02/2019 */
       if extract(month from rw_crapdat.dtmvtolt) = 2 and extract(year from rw_crapdat.dtmvtolt) = 2019 then 
         vr_dtutdmes:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => to_date('31/12/2018','dd/mm/rrrr')
                                                  ,pr_tipo     => 'A'
                                                  ,pr_feriado  => true
                                                  ,pr_excultdia => true);

         --Carregar tabela de memoria de lancamentos aplicacoes rdca
         FOR rw_craplap IN cr_craplap (pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => vr_dtutdmes) LOOP
           vr_tab_craplap(rw_craplap.nrdconta):= 0;
         END LOOP;
       END IF;

       --Implementacao chamado 240937
       IF pr_cdcooper = 1 THEN --apenas para cooperativa 1
         --validacao da existencia das contas na PLTABLE
         
         IF NOT vr_tab_craplap.EXISTS(1330497) THEN
            vr_tab_craplap(1330497) := 0;            
         END IF;

         IF NOT vr_tab_craplap.EXISTS(1828762) THEN
            vr_tab_craplap(1828762) := 0;            
         END IF;

         IF NOT vr_tab_craplap.EXISTS(2171805) THEN
            vr_tab_craplap(2171805) := 0;            
         END IF;

         IF NOT vr_tab_craplap.EXISTS(2244993) THEN
            vr_tab_craplap(2244993) := 0;            
         END IF;
       
       END IF;
       -- fim implementacao chamado 240937
       
       --Carregar tabela de memoria de taxas
       --Selecionar os tipos de registro da tabela generica
       FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                   ,pr_nmsistem => 'CRED'
                                   ,pr_tptabela => 'GENERI'
                                   ,pr_cdempres => 3
                                   ,pr_cdacesso => 'SOMAPLTAXA'
                                   ,pr_dstextab => 'SIM') LOOP
         --Atribuir valor para tabela memoria
         vr_tab_tpregist(rw_craptab.tpregist):= rw_craptab.tpregist;
       END LOOP;

       --Carregar tabela de memoria de contas bloqueadas
       TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                 ,pr_tab_cta_bloq => vr_tab_conta_bloq);

       --Carregar tabela de memoria de lancamentos na poupanca
       FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180) LOOP
         --Montar indice para acessar tabela
         vr_index_craplpp:= LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
         --Atribuir quantidade encontrada de cada conta ao vetor
         vr_tab_craplpp(vr_index_craplpp):= rw_craplpp.qtlancmto;
       END LOOP;

       --Carregar tabela de memoria com total de resgates na poupanca
       FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper) LOOP
         --Montar Indice para acesso quantidade lancamentos de resgate
         vr_index_craplrg:= LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
         --Popular tabela de memoria
         vr_tab_craplrg(vr_index_craplrg):= rw_craplrg.qtlancmto;
       END LOOP;

       --Carregar tabela de memoria de agencias dos associados
       FOR rw_crapass IN cr_crapass_agencia (pr_cdcooper => pr_cdcooper) LOOP
         --Adicionar agencia do associado na tabela de memoria
         vr_tab_crapage(rw_crapass.nrdconta):= rw_crapass.cdagenci;
       END LOOP;

       --Carregar tabela de memória com total resgatado por conta e aplicacao
       FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                    ,pr_dtresgat => vr_dtmvtopr) LOOP
         --Montar indice para selecionar total dos resgates na tabela auxiliar
         vr_index_resgate:= LPad(rw_craplrg.nrdconta,10,'0')||
                            LPad(rw_craplrg.tpaplica,05,'0')||
                            LPad(rw_craplrg.nraplica,10,'0');
         --Popular a tabela de memoria com a soma dos lancamentos de resgate
         vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
         vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
       END LOOP;

       --Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
       vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                            ,pr_nmsistem => 'CRED'
                                                                            ,pr_tptabela => 'CONFIG'
                                                                            ,pr_cdempres => 0
                                                                            ,pr_cdacesso => 'PERCIRAPLI'
                                                                            ,pr_tpregist => 0));

       --Selecionar informacoes da data de inicio e fim da taxa para calculo da APLI0001.pc_provisao_rdc_pos
       vr_dstextab_rdcpos:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsistem => 'CRED'
                                                      ,pr_tptabela => 'USUARI'
                                                      ,pr_cdempres => 11
                                                      ,pr_cdacesso => 'MXRENDIPOS'
                                                      ,pr_tpregist => 1);
        -- Se não encontrar
       IF vr_dstextab_rdcpos IS NULL THEN
         -- Utilizar datas padrão
         vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
         vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
       ELSE
         --Atribuir as datas encontradas
         vr_dtinitax := to_date(gene0002.fn_busca_entrada(1, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
         vr_dtfimtax := to_date(gene0002.fn_busca_entrada(2, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
       END IF;

       --Verificar as faixas de IR
       APLI0001.pc_busca_faixa_ir_rdca (pr_cdcooper => pr_cdcooper);
       --Buscar a quantidade de faixas de ir
       vr_qtdfaxir:= APLI0001.vr_faixa_ir_rdca.Count;

       --Pesquisar todos os associados
       OPEN cr_crapass (pr_cdcooper => pr_cdcooper);
       LOOP
         --Posicionar no proximo registro
         FETCH cr_crapass INTO rw_crapass;
         --Sair quando nao encontrar registro
         EXIT WHEN cr_crapass%NOTFOUND;

         --Ignorar registro se nao existir lancamento aplicacao
         IF vr_tab_craplap.EXISTS(rw_crapass.nrdconta) THEN
           --Zerar variaveis
           vr_vltotrda:= 0;

           --Executar rotina para acumular aplicacoes
           APLI0001.pc_acumula_aplicacoes (pr_cdcooper        => pr_cdcooper             --> Cooperativa
                                          ,pr_cdprogra        => vr_cdprogra             --> Nome do programa chamador
                                          ,pr_nrdconta        => rw_crapass.nrdconta     --> Nro da conta da aplicação RDCA
                                          ,pr_nraplica        => 0                       --> Nro da Aplicacao (0=todas)
                                          ,pr_tpaplica        => 3                       --> Tipo de Aplicacao
                                          ,pr_vlaplica        => 0                       --> Valor da Aplicacao
                                          ,pr_cdperapl        => 0                       --> Codigo Periodo Aplicacao
                                          ,pr_percenir        => vr_percenir             --> % IR para Calculo Poupanca
                                          ,pr_qtdfaxir        => vr_qtdfaxir             --> Quantidade de faixas de IR
                                          ,pr_tab_tpregist    => vr_tab_tpregist         --> Tipo de Registro para loop craptab (performance)
                                          ,pr_tab_craptab     => vr_tab_conta_bloq       --> Tipo de tabela de Conta Bloqueada (performance)
                                          ,pr_tab_craplpp     => vr_tab_craplpp          --> Tipo de tabela com lancamento poupanca (performance)
                                          ,pr_tab_craplrg     => vr_tab_craplrg          --> Tipo de tabela com resgates (performance)
                                          ,pr_tab_resgate     => vr_tab_resgate          --> Tabela com a soma dos resgates por conta e aplicacao
                                          ,pr_tab_crapdat     => rw_crapdat              --> Dados da tabela de datas
                                          ,pr_cdagenci_assoc  => rw_crapass.cdagenci     --> Agencia do associado
                                          ,pr_nrdconta_assoc  => rw_crapass.nrdconta     --> Conta do associado
                                          ,pr_dtinitax        => vr_dtinitax             --> Data Inicial da Utilizacao da taxa da poupanca
                                          ,pr_dtfimtax        => vr_dtfimtax             --> Data Final da Utilizacao da taxa da poupanca
                                          ,pr_vlsdrdca        => vr_vltotrda             --> Valor Saldo Aplicacao (OUT)
                                          ,pr_txaplica        => vr_txaplica             --> Taxa Maxima de Aplicacao (OUT)
                                          ,pr_txaplmes        => vr_txaplmes             --> Taxa Minima de Aplicacao (OUT)
                                          ,pr_retorno         => vr_retorno              --> Descricao de erro ou sucesso OK/NOK
                                          ,pr_tab_acumula     => vr_tab_acumula          --> Aplicacoes do Associado
                                          ,pr_tab_erro        => vr_tab_erro);           --> Saida com erros

           IF vr_retorno = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
             IF vr_tab_erro.COUNT > 0 THEN
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapass.nrdconta;
             ELSE
               vr_cdcritic:= 0;
               vr_dscritic := 'Retorno "NOK" na apli0001.pc_acumula_aplicacoes e sem informação na pr_tab_erro, Conta: '||rw_crapass.nrdconta||' Aplica: 0';
             END IF;
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Se o total da aplicacao for menor ou i zero
           IF vr_vltotrda <= 0 THEN
             --Zerar valor total rda
             vr_vltotrda:= 0;
           END IF;

           --Percorrer indicadores de saque total
           FOR vr_contador IN 0..1 LOOP
             --Selecionar informacoes das aplicacoes rdca
             FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper
                                          ,pr_tpaplica => 5
                                          ,pr_insaqtot => vr_contador
                                          ,pr_cdageass => rw_crapass.cdagenci
                                          ,pr_nrdconta => rw_crapass.nrdconta) LOOP
               --Bloco para controle fluxo
               BEGIN
                 --Zerar variaveis
                 vr_qtrenmfx:= 0;
                 vr_cdcritic:= 0;
                 vr_vlsdextr:= 0;
                 vr_vlslfmes:= 0;
                 vr_flgdomes:= FALSE;

                 --Se a data de calculo estiver entre o inicio e fim do mes
                 IF rw_craprda.dtcalcul > vr_dtinimes AND
                    rw_craprda.dtcalcul < vr_dtfimmes THEN
                   --Flag do mes recebe true
                   vr_flgdomes:= TRUE;
                 END IF;

                 --Se nao for saque total
                 IF rw_craprda.insaqtot = 0 THEN

                   --Executar rotina de calculo da provisao mensal da aplicacao
                   APLI0001.pc_calc_provisao_mensal_rdca2 (pr_cdcooper => pr_cdcooper
                                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                          ,pr_nrdconta => rw_craprda.nrdconta
                                                          ,pr_nraplica => rw_craprda.nraplica
                                                          ,pr_vltotrda => vr_vltotrda
                                                          ,pr_vlsdrdca => vr_vlsdrdca     --OUT
                                                          ,pr_txaplica => vr_rd2_txaplica --OUT
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_des_erro => vr_dscritic);


                   --Se ocorreu erro
                   IF (vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL) AND vr_cdcritic <> 427 THEN
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                   ELSIF vr_cdcritic = 427 THEN
                      -- Envio centralizado de log de erro
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                 || vr_cdprogra || ' --> '
                                                                 || vr_dscritic );
                                                                 
                      vr_dscritic := NULL;
                      vr_cdcritic := NULL;
                     
                      continue;
                   ELSE
                     vr_dscritic := NULL;
                     vr_cdcritic := NULL;
                   END IF;

                   /*  Acumula dados para o resumo  */

                   --Incrementar qdade planos ativos
                   vr_res_qtaplati:= Nvl(vr_res_qtaplati,0) + 1;
                   -- Atribuir valores para Pl-Table separando por PF e PJ
                   vr_tab_total(rw_craprda.inpessoa).qtaplati := vr_tab_total(rw_craprda.inpessoa).qtaplati + 1;
                   --Somar saldo aplicacao no Valor do saldo dos titulos ativos
                   vr_res_vlsdapat:= Nvl(vr_res_vlsdapat,0) + Nvl(vr_vlsdrdca,0);
                   -- Atribuir valores para Pl-Table separando por PF e PJ
                   vr_tab_total(rw_craprda.inpessoa).vlsdapat := vr_tab_total(rw_craprda.inpessoa).vlsdapat + Nvl(vr_vlsdrdca,0);
                   --Valor do saldo no final do mes recebe saldo da aplicacao
                   vr_vlslfmes:= Nvl(vr_vlsdrdca,0);
                   --Se a conta estiver inativa
                   IF rw_craprda.flgctain = 1 THEN
                     --Incrementar quantidade planos ativos novos
                     vr_res_qtaplati_n:= Nvl(vr_res_qtaplati_n,0) + 1;
                     --Acumular valor saldo aplicacao novos
                     vr_res_vlsdapat_n:= Nvl(vr_res_vlsdapat_n,0) + Nvl(vr_vlsdrdca,0);
                   ELSE
                     --Incrementar quantidade planos ativos antigos
                     vr_res_qtaplati_a:= Nvl(vr_res_qtaplati_a,0) + 1;
                     --Acumular valor saldo aplicacao antigos
                     vr_res_vlsdapat_a:= Nvl(vr_res_vlsdapat_a,0) + Nvl(vr_vlsdrdca,0);
                   END IF;
                   -- Guarda as informacoes de aplicacao rdca 60 ativas por agencia. Dados para Contabilidade
                   IF rw_craprda.inpessoa = 1 THEN
                      -- Verifica se existe valor para agencia corrente de pessoa fisica
                      IF vr_typ_tab_vlrdcage_fis.EXISTS(rw_craprda.cdageass) THEN
                         -- Soma os valores por agencia de pessoa fisica
                         vr_typ_tab_vlrdcage_fis(rw_craprda.cdageass) := vr_typ_tab_vlrdcage_fis(rw_craprda.cdageass) + Nvl(vr_vlsdrdca,0);
                      ELSE
                         -- Inicializa o array com o valor inicial de pessoa fisica
                         vr_typ_tab_vlrdcage_fis(rw_craprda.cdageass) := Nvl(vr_vlsdrdca,0);
                      END IF;
                      -- Gravando as informacoe para gerar o valor total de aplicacao rdca 60 ativas de pessoa fisica
                      vr_tot_rdcagefis := vr_tot_rdcagefis + Nvl(vr_vlsdrdca,0);
                   ELSE
                      -- Verifica se existe valor para agencia corrente de pessoa juridica
                      IF vr_typ_tab_vlrdcage_jur.EXISTS(rw_craprda.cdageass) THEN
                         -- Soma os valores por agencia de pessoa juridica
                         vr_typ_tab_vlrdcage_jur(rw_craprda.cdageass) := vr_typ_tab_vlrdcage_jur(rw_craprda.cdageass) + Nvl(vr_vlsdrdca,0);
                      ELSE
                         -- Inicializa o array com o valor inicial de pessoa juridica
                         vr_typ_tab_vlrdcage_jur(rw_craprda.cdageass) := Nvl(vr_vlsdrdca,0);
                      END IF;

                      -- Gravando as informacoe para gerar o valor total de aplicacao rdca 60 ativas de pessoa juridica
                      vr_tot_rdcagejur := vr_tot_rdcagejur + Nvl(vr_vlsdrdca,0);
                    END IF;
                   --Se o valor do abono de cpmf diferente zero
                   IF rw_craprda.vlabcpmf <> 0 THEN
                     --Valor extrato recebe valor aplicado menos resgatado
                     vr_vlsdextr:= Nvl(rw_craprda.vlaplica,0) - Nvl(rw_craprda.vlrgtacu,0);
                   ELSE
                     --Valor extrato recebe valor saldo aplicacao
                     vr_vlsdextr:= Nvl(vr_vlsdrdca,0);
                   END IF;
                 ELSE
                   --Se nao for do mes entao pula
                   IF NOT vr_flgdomes THEN
                     --Levantar excecao
                     RAISE vr_exc_pula;
                   ELSE
                     --Rendimento liquido recebe resgates menos aplicado em moeda fixa
                     vr_qtrenmfx:= Nvl(rw_craprda.qtrgtmfx,0) - Nvl(rw_craprda.qtaplmfx,0);
                     --Acumular no Rendimento liquido acumulado o rendimento calculado
                     vr_res_qtrenmfx:= Nvl(vr_res_qtrenmfx,0) + Nvl(vr_qtrenmfx,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda.inpessoa).qtrenmfx := vr_tab_total(rw_craprda.inpessoa).qtrenmfx + Nvl(vr_qtrenmfx,0);
                     --Zerar valor saldo extrato
                     vr_vlsdextr:= 0;
                     --Se a conta estiver inativa
                     IF rw_craprda.flgctain = 1 THEN
                       --Incrementar quantidade Rendimento liquido acumulado (novos)
                       vr_res_qtrenmfx_n:= Nvl(vr_res_qtrenmfx_n,0) + Nvl(vr_qtrenmfx,0);
                     ELSE
                       --Incrementar quantidade Rendimento liquido acumulado (antigos)
                       vr_res_qtrenmfx_a:= Nvl(vr_res_qtrenmfx_a,0) + Nvl(vr_qtrenmfx,0);
                     END IF;
                   END IF;
                 END IF;

                 --Se a data do movimento for maior que o inicio do mes e menor que o final do mes
                 IF rw_craprda.dtmvtolt > vr_dtinimes AND
                    rw_craprda.dtmvtolt < vr_dtfimmes THEN
                   --Incrementar a quantidade aplicacoes no mes
                   vr_res_qtaplmes:= Nvl(vr_res_qtaplmes,0) + 1;
                   -- Atribuir valores para Pl-Table separando por PF e PJ
                   vr_tab_total(rw_craprda.inpessoa).qtaplmes := vr_tab_total(rw_craprda.inpessoa).qtaplmes + 1;
                   --Acumular valor aplicado no mes
                   vr_res_vlaplmes:= Nvl(vr_res_vlaplmes,0) + Nvl(rw_craprda.vlaplica,0);
                   -- Atribuir valores para Pl-Table separando por PF e PJ
                   vr_tab_total(rw_craprda.inpessoa).vlaplmes := vr_tab_total(rw_craprda.inpessoa).vlaplmes + Nvl(rw_craprda.vlaplica,0);
                   --Valor saldo extrato recebe aplicacao menos resgatado
                   vr_vlsdextr:= Nvl(rw_craprda.vlaplica,0) - Nvl(rw_craprda.vlrgtacu,0);
                   --Se a conta estiver inativa
                   IF rw_craprda.flgctain = 1 THEN
                     --Incrementar quantidade planos mes novos
                     vr_res_qtaplmes_n:= Nvl(vr_res_qtaplmes_n,0) + 1;
                     --Acumular valor saldo aplicacao mes novos
                     vr_res_vlaplmes_n:= Nvl(vr_res_vlaplmes_n,0) + Nvl(rw_craprda.vlaplica,0);
                   ELSE
                     --Incrementar quantidade planos mes antigos
                     vr_res_qtaplmes_a:= Nvl(vr_res_qtaplmes_a,0) + 1;
                     --Acumular valor saldo aplicacao mes antigos
                     vr_res_vlaplmes_a:= Nvl(vr_res_vlaplmes_a,0) + Nvl(rw_craprda.vlaplica,0);
                   END IF;
                 END IF;
                 --Se a quantidade Rendimento liquido diferente zero ou valor abono iof diferente zero
                 IF Nvl(vr_qtrenmfx,0) <> 0 OR Nvl(rw_craprda.vlabdiof,0) <> 0 THEN
                   --Limpar a tabela de memoria de iof
                   pc_inicializa_tabela_iof;
                   --Atualizar a tabela de memoria correspondente ao mes com o valor do abono do iof
                   vr_tab_abiof(To_Number(To_Char(vr_dtmvtolt,'MM'))):= rw_craprda.vlabdiof;
                   --Atualizar as cotas para a conta do associado
                   BEGIN
                     UPDATE crapcot SET crapcot.qtrenmfx     = Nvl(crapcot.qtrenmfx,0) + Nvl(vr_qtrenmfx,0)
                                       ,crapcot.vlabiord     = Nvl(crapcot.vlabiord,0) + Nvl(rw_craprda.vlabdiof,0)
                                       ,crapcot.vlrentot##1  = Nvl(crapcot.vlrentot##1,0) + vr_tab_abiof(1)
                                       ,crapcot.vlrentot##2  = Nvl(crapcot.vlrentot##2,0) + vr_tab_abiof(2)
                                       ,crapcot.vlrentot##3  = Nvl(crapcot.vlrentot##3,0) + vr_tab_abiof(3)
                                       ,crapcot.vlrentot##4  = Nvl(crapcot.vlrentot##4,0) + vr_tab_abiof(4)
                                       ,crapcot.vlrentot##5  = Nvl(crapcot.vlrentot##5,0) + vr_tab_abiof(5)
                                       ,crapcot.vlrentot##6  = Nvl(crapcot.vlrentot##6,0) + vr_tab_abiof(6)
                                       ,crapcot.vlrentot##7  = Nvl(crapcot.vlrentot##7,0) + vr_tab_abiof(7)
                                       ,crapcot.vlrentot##8  = Nvl(crapcot.vlrentot##8,0) + vr_tab_abiof(8)
                                       ,crapcot.vlrentot##9  = Nvl(crapcot.vlrentot##9,0) + vr_tab_abiof(9)
                                       ,crapcot.vlrentot##10 = Nvl(crapcot.vlrentot##10,0) + vr_tab_abiof(10)
                                       ,crapcot.vlrentot##11 = Nvl(crapcot.vlrentot##11,0) + vr_tab_abiof(11)
                                       ,crapcot.vlrentot##12 = Nvl(crapcot.vlrentot##12,0) + vr_tab_abiof(12)
                     WHERE crapcot.cdcooper = pr_cdcooper
                     AND   crapcot.nrdconta = rw_craprda.nrdconta;
                     --Se nao atualizou nenhum registro (erro)
                     IF SQL%ROWCOUNT = 0 THEN
                       -- Montar mensagem de critica
                       vr_cdcritic:= 169;
                       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                       vr_dscritic := vr_dscritic||' CONTA = '||rw_craprda.nrdconta;
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                     END IF;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_dscritic:= 'Erro ao atualizar a tabela crapcot. Rotina pc_crps175: '||SQLERRM;
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                   END;
                   --Acumular o Total abonado de iod na aplicacao
                   rw_craprda.vlabiord:= Nvl(rw_craprda.vlabiord,0) + Nvl(rw_craprda.vlabdiof,0);
                   --Zerar valor abono iof
                   rw_craprda.vlabdiof:= 0;
                 END IF;

                 --Atualizar tabela cadastro aplicacoes
                 BEGIN
                    UPDATE craprda SET craprda.dtsdfmea = vr_dtmvtolt
                                      ,craprda.vlslfmea = vr_vlslfmes
                                      ,craprda.vlabiord = rw_craprda.vlabiord
                                      ,craprda.vlabdiof = rw_craprda.vlabdiof
                                      ,craprda.vlsdextr = vr_vlsdextr
                                      ,craprda.dtsdfmes = vr_dtmvtolt
                                      ,craprda.vlslfmes = vr_vlslfmes
                    WHERE craprda.ROWID = rw_craprda.ROWID
                    RETURNING craprda.vlabiord
                             ,craprda.vlabdiof
                             ,craprda.vlsdextr
                             ,craprda.dtsdfmes
                             ,craprda.vlslfmes
                    INTO     rw_craprda.vlabiord
                            ,rw_craprda.vlabdiof
                            ,rw_craprda.vlsdextr
                            ,rw_craprda.dtsdfmes
                            ,rw_craprda.vlslfmes;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic:= 'Erro ao atualizar a tabela craprda. Rotina pc_crps175: '||SQLERRM;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END;

                 --Acumular Abonos adiantados a recuperar
                 vr_res_bsabcpmf:= Nvl(vr_res_bsabcpmf,0) + Nvl(rw_craprda.vlabcpmf,0);
                 -- Atribuir valores para Pl-Table separando por PF e PJ
                 vr_tab_total(rw_craprda.inpessoa).bsabcpmf := vr_tab_total(rw_craprda.inpessoa).bsabcpmf + Nvl(rw_craprda.vlabcpmf,0);
                 --Acumular valor do retorno
                 vr_vlretorn:= Nvl(vr_vlretorn,0) + Nvl(rw_craprda.vlslfmes,0);

                 --Se existir a conta na tabela bndes
                 IF vr_tab_bndes.EXISTS(rw_craprda.nrdconta) THEN
                   --Acumular valor aplicado para a conta
                   vr_tab_bndes(rw_craprda.nrdconta):= vr_tab_bndes(rw_craprda.nrdconta) + Nvl(rw_craprda.vlslfmes,0);
                 ELSE
                   --Atribuir valor aplicado para a conta
                   vr_tab_bndes(rw_craprda.nrdconta):= Nvl(rw_craprda.vlslfmes,0);
                 END IF;

                 --Se a conta estiver inativa
                 IF rw_craprda.flgctain = 1 THEN
                   --Acumular Abonos adiantados a recuperar (novos)
                   vr_res_bsabcpmf_n:= Nvl(vr_res_bsabcpmf_n,0) + Nvl(rw_craprda.vlabcpmf,0);
                 ELSE
                   --Acumular Abonos adiantados a recuperar (antigos)
                   vr_res_bsabcpmf_a:= Nvl(vr_res_bsabcpmf_a,0) + Nvl(rw_craprda.vlabcpmf,0);
                 END IF;
                 --Se nao for resgate total
                 IF rw_craprda.insaqtot = 0 THEN
                   --Montar indice para buscar tabela memoria de detalhe
                   vr_index_detalhe:= LPad(rw_craprda.cdageass,05,'0')||
                                      LPad(rw_craprda.nrdconta,10,'0')||
                                      LPad(rw_craprda.nraplica,10,'0');
                   --Se nao existir entao cria
                   IF NOT vr_tab_detalhe.EXISTS(vr_index_detalhe) THEN
                     vr_tab_detalhe(vr_index_detalhe).tpaplica:= rw_craprda.tpaplica;
                     vr_tab_detalhe(vr_index_detalhe).cdagenci:= rw_craprda.cdageass;
                     vr_tab_detalhe(vr_index_detalhe).nrdconta:= rw_craprda.nrdconta;
                     vr_tab_detalhe(vr_index_detalhe).nraplica:= rw_craprda.nraplica;
                     vr_tab_detalhe(vr_index_detalhe).dtaplica:= rw_craprda.dtmvtolt;
                     vr_tab_detalhe(vr_index_detalhe).vlaplica:= rw_craprda.vlaplica;
                     vr_tab_detalhe(vr_index_detalhe).vlrgtmes:= 0;
                     vr_tab_detalhe(vr_index_detalhe).vlsldrdc:= rw_craprda.vlslfmes;
                     vr_tab_detalhe(vr_index_detalhe).txaplica:= vr_rd2_txaplica;
                     vr_tab_detalhe(vr_index_detalhe).nmprimtl:= rw_crapass.nmprimtl;
                   END IF;

                 END IF;
               EXCEPTION
                 WHEN vr_exc_pula THEN NULL;
               END;
             END LOOP;  --rw_craprda
           END LOOP; --loop 0..1
         END IF;

       END LOOP; --rw_crapass
       --Fechar Cursor
       CLOSE cr_crapass;

       --Se o valor retorno diferente zero
       IF vr_vlretorn <> 0  THEN
         --Inserir Prazo de retorno para bndes
         BEGIN
           INSERT INTO crapprb (crapprb.cdcooper
                               ,crapprb.dtmvtolt
                               ,crapprb.nrdconta
                               ,crapprb.cdorigem
                               ,crapprb.cddprazo
                               ,crapprb.vlretorn)
           VALUES              (3
                               ,vr_dtmvtolt
                               ,rw_crapcop.nrctactl
                               ,5
                               ,90
                               ,vr_vlretorn);
         EXCEPTION
           WHEN OTHERS THEN
           --Montar mensagem de erro
           vr_dscritic:= 'Erro ao atualizar a tabela crapprb. Rotina pc_crps175: '||SQLERRM;
           --Levantar Excecao
           RAISE vr_exc_erro;
         END;
       END IF;

       --Percorrer tabela bndes e atualizar crapprb
       vr_index_bndes:= vr_tab_bndes.FIRST;
       WHILE vr_index_bndes IS NOT NULL LOOP
         --Se o valor da aplicacao maior zero
         IF  vr_tab_bndes(vr_index_bndes) > 0  THEN
           --Inserir Prazo de retorno para bndes
           BEGIN
             INSERT INTO crapprb (crapprb.cdcooper
                                 ,crapprb.dtmvtolt
                                 ,crapprb.nrdconta
                                 ,crapprb.cdorigem
                                 ,crapprb.cddprazo
                                 ,crapprb.vlretorn)
             VALUES              (pr_cdcooper
                                 ,vr_dtmvtolt
                                 ,vr_index_bndes --Indice=nrdconta
                                 ,5
                                 ,0
                                 ,vr_tab_bndes(vr_index_bndes));
           EXCEPTION
             WHEN OTHERS THEN
             --Montar mensagem de erro
             vr_dscritic:= 'Erro ao atualizar a tabela crapprb para bndes. Rotina pc_crps175: '||SQLERRM;
             --Levantar Excecao
             RAISE vr_exc_erro;
           END;
         END IF;
         --Encontrar o proximo indice da tabela
         vr_index_bndes:= vr_tab_bndes.NEXT(vr_index_bndes);
       END LOOP;

       -- Quebrar string historico da consulta pelo delimitador ','
       vr_split_histor:= gene0002.fn_quebra_string(vr_listahis, ',');

       --Percorrer todos os dias entre data inicial +1 e data final -1
       vr_data:= vr_dtinimes+1;
       WHILE vr_data <= (vr_dtfimmes-1) LOOP
         --Se o array conter registros
         IF vr_split_histor.Count > 0 THEN
           --Montar indice para o split
           vr_index_split:= vr_split_histor.FIRST;
           WHILE vr_index_split IS NOT NULL LOOP
             --selecionar informacoes dos lancamentos das aplicacoes rdca
             FOR rw_craplap IN cr_craplap_histor (pr_cdcooper => pr_cdcooper
                                                 ,pr_dtmvtolt => vr_data
                                                 ,pr_cdhistor => vr_split_histor(vr_index_split)) LOOP
               --Montar indice para tabela memoria aplicacoes
               vr_index_craprda:= LPad(rw_craplap.nrdconta,10,'0')||LPad(rw_craplap.nraplica,10,'0');

               --Se nao existir aplicacao rdca entao ignora
               OPEN cr_craprda_histor (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_craplap.nrdconta
                                      ,pr_nraplica => rw_craplap.nraplica);
               --Posicionar no proximo registro
               FETCH cr_craprda_histor INTO rw_craprda_histor;
               --Se encontrou registro
               IF cr_craprda_histor%FOUND THEN
                 --Se nao for saque total
                 IF rw_craprda_histor.insaqtot = 0 THEN
                   --Montar indice para tabela detalhe
                   vr_index_detalhe:= LPad(vr_tab_crapage(rw_craplap.nrdconta),05,'0')||
                                      LPad(rw_craplap.nrdconta,10,'0')||
                                      LPad(rw_craplap.nraplica,10,'0');
                 ELSE
                   vr_index_detalhe:= NULL;
                 END IF;

                 --Se for conta inativa
                 IF rw_craprda_histor.flgctain = 1 THEN
                   --Se for historico de resgate
                   CASE rw_craplap.cdhistor
                     WHEN 178 THEN
                       --Acumular valor resgate mes novos
                       vr_res_vlresmes_n:= Nvl(vr_res_vlresmes_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 494 THEN
                       --Acumular valor resgate mes novos
                       vr_res_vlresmes_n:= Nvl(vr_res_vlresmes_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 179 THEN --rendimento
                       --Acumular rendimentos no mes novos
                       vr_res_vlrenmes_n:= Nvl(vr_res_vlrenmes_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 180 THEN
                       --Acumular valor provisoes no mes
                       vr_res_vlprvmes_n:= Nvl(vr_res_vlprvmes_n,0) + Nvl(rw_craplap.vllanmto,0);
                       --Se o lote for 8380
                       IF rw_craplap.nrdolote = 8380 THEN
                         --Acumular valor provisao lancamento novo
                         vr_res_vlprvlan_n:= Nvl(vr_res_vlprvlan_n,0) + Nvl(rw_craplap.vllanmto,0);
                       END IF;
                     WHEN 181 THEN
                       --Acumular ajuste da provisao novo
                       vr_res_vlajuprv_n:= Nvl(vr_res_vlajuprv_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 182 THEN
                       --Diminuir ajuste da provisao novo
                       vr_res_vlajuprv_n:= Nvl(vr_res_vlajuprv_n,0) - Nvl(rw_craplap.vllanmto,0);
                     WHEN 183 THEN
                       --Acumular valores de saque novo
                       vr_res_vlsaques_n:= Nvl(vr_res_vlsaques_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 495 THEN
                       --Acumular valores de saque novo
                       vr_res_vlsaques_n:= Nvl(vr_res_vlsaques_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 862 THEN
                       --Acumular valor irrf
                       vr_res_vlrirrf_n:= Nvl(vr_res_vlrirrf_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 876 THEN  /* Ajuste IR Resgate */
                       --Acumular valor ajuste IR resgate
                       vr_res_vlirajrg_n:= Nvl(vr_res_vlirajrg_n,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 871 THEN
                       --Acumular valor ajuste IR resgate
                       vr_res_vlrirab_n:= Nvl(vr_res_vlrirab_n,0) + Nvl(rw_craplap.vllanmto,0);
                   END CASE;
                 ELSE
                   CASE rw_craplap.cdhistor
                     --Se for historico de resgate
                     WHEN 178 THEN
                       --Acumular valor resgate mes antigos
                       vr_res_vlresmes_a:= Nvl(vr_res_vlresmes_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 494 THEN
                       --Acumular valor resgate mes antigos
                       vr_res_vlresmes_a:= Nvl(vr_res_vlresmes_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 179 THEN --rendimento
                       --Acumular rendimentos no mes antigos
                       vr_res_vlrenmes_a:= Nvl(vr_res_vlrenmes_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 180 THEN
                       --Acumular valor provisoes no mes antigos
                       vr_res_vlprvmes_a:= Nvl(vr_res_vlprvmes_a,0) + Nvl(rw_craplap.vllanmto,0);
                       --Se o lote for 8380
                       IF rw_craplap.nrdolote = 8380 THEN
                         --Acumular valor provisao lancamento antigos
                         vr_res_vlprvlan_a:= Nvl(vr_res_vlprvlan_a,0) + Nvl(rw_craplap.vllanmto,0);
                       END IF;
                     WHEN 181 THEN
                       --Acumular ajuste da provisao antigos
                       vr_res_vlajuprv_a:= Nvl(vr_res_vlajuprv_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 182 THEN
                       --Diminuir ajuste da provisao antigos
                       vr_res_vlajuprv_a:= Nvl(vr_res_vlajuprv_a,0) - Nvl(rw_craplap.vllanmto,0);
                     WHEN 183 THEN
                       --Acumular valores de saque antigos
                       vr_res_vlsaques_a:= Nvl(vr_res_vlsaques_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 495 THEN
                       --Acumular valores de saque antigos
                       vr_res_vlsaques_a:= Nvl(vr_res_vlsaques_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 862 THEN
                       --Acumular valor irrf antigos
                       vr_res_vlrirrf_a:= Nvl(vr_res_vlrirrf_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 876 THEN  /* Ajuste IR Resgate */
                       --Acumular valor ajuste IR resgate antigos
                       vr_res_vlirajrg_a:= Nvl(vr_res_vlirajrg_a,0) + Nvl(rw_craplap.vllanmto,0);
                     WHEN 871 THEN
                       --Acumular valor ajuste IR resgate antigos
                       vr_res_vlrirab_a:= Nvl(vr_res_vlrirab_a,0) + Nvl(rw_craplap.vllanmto,0);
                   END CASE;
                 END IF;

                 CASE rw_craplap.cdhistor
                   --Se o historico for de resgate
                   WHEN 178 THEN
                     --Acumular valor resgatado mes
                     vr_res_vlresmes:= Nvl(vr_res_vlresmes,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlresmes := vr_tab_total(rw_craprda_histor.inpessoa).vlresmes + Nvl(rw_craplap.vllanmto,0);
                     --Se existir a conta e aplicacao na tabela de detalhe
                     IF vr_tab_detalhe.EXISTS(vr_index_detalhe) THEN
                       --Acumular valor resgatado mes
                       vr_tab_detalhe(vr_index_detalhe).vlrgtmes:= Nvl(vr_tab_detalhe(vr_index_detalhe).vlrgtmes,0) +
                                                                   Nvl(rw_craplap.vllanmto,0);
                     END IF;
                   WHEN 494 THEN
                     --Acumular valor resgatado mes
                     vr_res_vlresmes:= Nvl(vr_res_vlresmes,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlresmes := vr_tab_total(rw_craprda_histor.inpessoa).vlresmes + Nvl(rw_craplap.vllanmto,0);
                     --Se existir a conta e aplicacao na tabela de detalhe
                     IF vr_tab_detalhe.EXISTS(vr_index_detalhe) THEN
                       --Acumular valor resgatado mes
                       vr_tab_detalhe(vr_index_detalhe).vlrgtmes:= Nvl(vr_tab_detalhe(vr_index_detalhe).vlrgtmes,0) +
                                                                   Nvl(rw_craplap.vllanmto,0);
                     END IF;
                   WHEN 179 THEN  --rendimento
                     --Acumular rendimentos no mes
                     vr_res_vlrenmes:= Nvl(vr_res_vlrenmes,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlrenmes := vr_tab_total(rw_craprda_histor.inpessoa).vlrenmes + Nvl(rw_craplap.vllanmto,0);
                   WHEN 180 THEN  --PROVIS.RDCA60

                     --Acumular valor provisoes no mes
                     vr_res_vlprvmes:= Nvl(vr_res_vlprvmes,0) + Nvl(rw_craplap.vllanmto,0);

                     IF rw_craprda_histor.inpessoa = 1 THEN
                        
                        IF vr_tab_tot_vlprvfis.EXISTS(rw_craprda_histor.cdagenci) THEN
                           vr_tab_tot_vlprvfis(rw_craprda_histor.cdagenci) := vr_tab_tot_vlprvfis(rw_craprda_histor.cdagenci) + Nvl(rw_craplap.vllanmto,0);
                        ELSE
                           vr_tab_tot_vlprvfis(rw_craprda_histor.cdagenci) := Nvl(rw_craplap.vllanmto,0);
                        END IF;

                        vr_tot_vlprvfis := vr_tot_vlprvfis + Nvl(rw_craplap.vllanmto,0);

                     ELSE

                        IF vr_tab_tot_vlprvjur.EXISTS(rw_craprda_histor.cdagenci) THEN
                           vr_tab_tot_vlprvjur(rw_craprda_histor.cdagenci) := vr_tab_tot_vlprvjur(rw_craprda_histor.cdagenci) + Nvl(rw_craplap.vllanmto,0);
                        ELSE
                           vr_tab_tot_vlprvjur(rw_craprda_histor.cdagenci) := Nvl(rw_craplap.vllanmto,0);
                        END IF;

                        vr_tot_vlprvjur := vr_tot_vlprvjur + Nvl(rw_craplap.vllanmto,0);
                     END IF;

                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlprvmes := vr_tab_total(rw_craprda_histor.inpessoa).vlprvmes + Nvl(rw_craplap.vllanmto,0);

                     --Se o lote for 8380
                     IF rw_craplap.nrdolote = 8380 THEN
                       --Acumular valor provisao lancamento
                       vr_res_vlprvlan:= Nvl(vr_res_vlprvlan,0) + Nvl(rw_craplap.vllanmto,0);
                       -- Atribuir valores para Pl-Table separando por PF e PJ
                       vr_tab_total(rw_craprda_histor.inpessoa).vlprvlan := vr_tab_total(rw_craprda_histor.inpessoa).vlprvlan + Nvl(rw_craplap.vllanmto,0);
                     END IF;
                   WHEN 181 THEN  --Ajuste provisao (Credito)
                     --Acumular ajuste da provisao
                     vr_res_vlajuprv:= Nvl(vr_res_vlajuprv,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlajuprv := vr_tab_total(rw_craprda_histor.inpessoa).vlajuprv + Nvl(rw_craplap.vllanmto,0);
                   WHEN 182 THEN  --Ajuste provisao (Debito)
                     --Diminuir ajuste da provisao
                     vr_res_vlajuprv:= Nvl(vr_res_vlajuprv,0) - Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlajuprv := vr_tab_total(rw_craprda_histor.inpessoa).vlajuprv - Nvl(rw_craplap.vllanmto,0);
                     
                     IF rw_craprda_histor.inpessoa = 1 THEN
                        
                        IF vr_tab_tot_vlajusprv_fis.EXISTS(rw_craprda_histor.cdagenci) THEN
                           vr_tab_tot_vlajusprv_fis(rw_craprda_histor.cdagenci) := vr_tab_tot_vlajusprv_fis(rw_craprda_histor.cdagenci) + Nvl(rw_craplap.vllanmto,0);
                        ELSE
                           vr_tab_tot_vlajusprv_fis(rw_craprda_histor.cdagenci) := Nvl(rw_craplap.vllanmto,0);
                        END IF;

                        vr_tot_vlajusprv_fis := vr_tot_vlajusprv_fis + Nvl(rw_craplap.vllanmto,0);

                     ELSE

                        IF vr_tab_tot_vlajusprv_jur.EXISTS(rw_craprda_histor.cdagenci) THEN
                           vr_tab_tot_vlajusprv_jur(rw_craprda_histor.cdagenci) := vr_tab_tot_vlajusprv_jur(rw_craprda_histor.cdagenci) + Nvl(rw_craplap.vllanmto,0);
                        ELSE
                           vr_tab_tot_vlajusprv_jur(rw_craprda_histor.cdagenci) := Nvl(rw_craplap.vllanmto,0);
                        END IF;

                        vr_tot_vlajusprv_jur := vr_tot_vlajusprv_jur + Nvl(rw_craplap.vllanmto,0);
                     END IF;
                     
                     
                   WHEN 183 THEN  --SAQ.S/REND.60
                     --Acumular valores de saque
                     vr_res_vlsaques:= Nvl(vr_res_vlsaques,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlsaques := vr_tab_total(rw_craprda_histor.inpessoa).vlsaques + Nvl(rw_craplap.vllanmto,0);
                     IF vr_tab_detalhe.EXISTS(vr_index_detalhe) THEN
                       --Acumular valor resgatado mes
                       vr_tab_detalhe(vr_index_detalhe).vlrgtmes:= Nvl(vr_tab_detalhe(vr_index_detalhe).vlrgtmes,0) +
                                                                   Nvl(rw_craplap.vllanmto,0);
                     END IF;
                   WHEN 495 THEN  --SAQ.S/REND.60
                     --Acumular valores de saque
                     vr_res_vlsaques:= Nvl(vr_res_vlsaques,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlsaques := vr_tab_total(rw_craprda_histor.inpessoa).vlsaques + Nvl(rw_craplap.vllanmto,0);
                     IF vr_tab_detalhe.EXISTS(vr_index_detalhe) THEN
                       --Acumular valor resgatado mes
                       vr_tab_detalhe(vr_index_detalhe).vlrgtmes:= Nvl(vr_tab_detalhe(vr_index_detalhe).vlrgtmes,0) +
                                                                   Nvl(rw_craplap.vllanmto,0);
                     END IF;
                   WHEN 862 THEN  --DB.IRRF
                     --Acumular valor irrf
                     vr_res_vlrirrf:= Nvl(vr_res_vlrirrf,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlrirrf := vr_tab_total(rw_craprda_histor.inpessoa).vlrirrf + Nvl(rw_craplap.vllanmto,0);
                   WHEN 876 THEN  --AJT RGT IR-60
                     --Acumular valor ajuste IR resgate
                     vr_res_vlirajrg:= Nvl(vr_res_vlirajrg,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlirajrg := vr_tab_total(rw_craprda_histor.inpessoa).vlirajrg + Nvl(rw_craplap.vllanmto,0);
                   WHEN 871 THEN  --IR ABONO APL.
                     --Acumular valor ajuste IR resgate
                     vr_res_vlrirab:= Nvl(vr_res_vlrirab,0) + Nvl(rw_craplap.vllanmto,0);
                     -- Atribuir valores para Pl-Table separando por PF e PJ
                     vr_tab_total(rw_craprda_histor.inpessoa).vlrirab := vr_tab_total(rw_craprda_histor.inpessoa).vlrirab + Nvl(rw_craplap.vllanmto,0);
                 END CASE;
               END IF;
               --Fechar Cursor
               CLOSE cr_craprda_histor;
             END LOOP; --rw_craplap
             --Encontrar proximo registro do split
             vr_index_split:= vr_split_histor.NEXT(vr_index_split);
           END LOOP; --vr_split_his.Count
         END IF; --vr_split_his.Count > 0
         --Incrementar a data de inicio para o loop
         vr_data:= vr_data+1;
       END LOOP; --vr_data

       --Executar procedure geração relatorio crrl138
       pc_imprime_crrl138 (pr_des_erro => vr_dscritic);
       --Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_erro;
       END IF;

       --Executar procedure geração relatorio crrl560
       pc_imprime_crrl560 (pr_des_erro => vr_dscritic);
       --Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_erro;
       END IF;
       
       -------------------------------------------------
       -- Inicio de geracao de arquivo AAMMDD_RDCA60.txt
       -------------------------------------------------

       -- Arquivo gerado somente no processo mensal e quando não for CECRED
       IF TRUNC(rw_crapdat.dtmvtopr,'MM') <> TRUNC(rw_crapdat.dtmvtolt,'MM') AND pr_cdcooper <> 3 THEN


          -- Busca o caminho padrao do arquivo no unix + /integra
          vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => 'contab');

          -- Determinar o nome do arquivo baseado no ano, mes e dia da data movimento
          vr_nmarqtxt:=  TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_RDCA60.txt';

          -- Tenta abrir o arquivo de log em modo gravacao
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretório do arquivo
                                  ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                  ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);  --> Erro
          IF vr_dscritic IS NOT NULL THEN
             -- Levantar Excecao
             RAISE vr_exc_erro;
          END IF;

          /*** Montando as informacoes de PESSOA FISICA ***/

          -- Se valor total maior que zero
          IF NVL(vr_tot_rdcagefis,0) > 0 THEN

            -- Montando o cabecalho das contas do dia atual
            vr_setlinha := '70'||                                                                                      --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                           gene0002.fn_mask(4237, pr_dsforma => '9999')||','||                                         --> Conta Origem
                           gene0002.fn_mask(4271, pr_dsforma => '9999')||','||                                         --> Conta Destino
                           TRIM(TO_CHAR(vr_tot_rdcagefis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                           '"SALDO TOTAL DE TITULOS ATIVOS RDCA 60 - COOPERADOS PESSOA FISICA"';                     --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita

            -- Verifica se existe valores       
            IF vr_typ_tab_vlrdcage_fis.COUNT > 0 THEN
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_typ_tab_vlrdcage_fis.FIRST()..vr_typ_tab_vlrdcage_fis.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_typ_tab_vlrdcage_fis.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se existe a informacao
                    IF vr_typ_tab_vlrdcage_fis(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrdcage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      -- Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';       
                END LOOP;
              END LOOP; -- fim repete
            END IF;

            -- Montando o cabecalho para fazer a reversao das
            -- conta para estornar os valores caso necessario
            vr_setlinha := '70'||                                                                                     --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                               --> Data DDMMAA
                           gene0002.fn_mask(4271, pr_dsforma => '9999')||','||                                        --> Conta Destino
                           gene0002.fn_mask(4237, pr_dsforma => '9999')||','||                                        --> Conta Origem
                           TRIM(TO_CHAR(vr_tot_rdcagefis,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                        --> Fixo
                           '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS ATIVOS RDCA 60 - COOPERADOS PESSOA FISICA"';                    --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
            
            -- Verifica se existe valores       
            IF vr_typ_tab_vlrdcage_fis.COUNT > 0 THEN               
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP 
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_typ_tab_vlrdcage_fis.FIRST()..vr_typ_tab_vlrdcage_fis.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_typ_tab_vlrdcage_fis.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se valor é maior que zero
                    IF vr_typ_tab_vlrdcage_fis(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrdcage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      -- Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';
                END LOOP;
              END LOOP; -- fim repete
            END IF;
          END IF; -- Se valor maior que zero
          
          /*** Montando as informacoes de PESSOA JURIDICA ***/

          -- Se valor total maior que zero
          IF NVL(vr_tot_rdcagejur,0) > 0 THEN
            -- Montando o cabecalho das contas do dia atual
            vr_setlinha := '70'||                                                                                      --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                           gene0002.fn_mask(4237, pr_dsforma => '9999')||','||                                         --> Conta Origem
                           gene0002.fn_mask(4272, pr_dsforma => '9999')||','||                                         --> Conta Destino
                           TRIM(TO_CHAR(vr_tot_rdcagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                           '"SALDO TOTAL DE TITULOS ATIVOS RDCA 60 - COOPERADOS PESSOA JURIDICA"';                     --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita

            -- Verifica se existe valores
            IF vr_typ_tab_vlrdcage_jur.COUNT > 0 THEN
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP 
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_typ_tab_vlrdcage_jur.FIRST()..vr_typ_tab_vlrdcage_jur.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_typ_tab_vlrdcage_jur.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se existe a informacao
                    IF vr_typ_tab_vlrdcage_jur(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrdcage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      --Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';
                END LOOP;
              END LOOP; -- Fim repete
            END IF;

            -- Montando o cabecalho para fazer a reversao das
            -- conta para estornar os valores caso necessario
            vr_setlinha := '70'||                                                                                      --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                --> Data DDMMAA
                           gene0002.fn_mask(4272, pr_dsforma => '9999')||','||                                         --> Conta Destino
                           gene0002.fn_mask(4237, pr_dsforma => '9999')||','||                                         --> Conta Origem
                           TRIM(TO_CHAR(vr_tot_rdcagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                           '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS ATIVOS RDCA 60 - COOPERADOS PESSOA JURIDICA"';                     --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
            
            -- Verifica se existe valores
            IF vr_typ_tab_vlrdcage_jur.COUNT > 0 THEN
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP 
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_typ_tab_vlrdcage_jur.FIRST()..vr_typ_tab_vlrdcage_jur.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_typ_tab_vlrdcage_jur.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se o valor é maior que zero
                    IF vr_typ_tab_vlrdcage_jur(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrdcage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      -- Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrit
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';
                END LOOP;
              END LOOP; -- fim repete
            END IF;
          END IF; -- Se valor maior que zero
          
          /*** Montando as informacoes de PESSOA FISICA ***/
          
          -- Se valor total maior que zero
          IF NVL(vr_tot_vlprvfis,0) > 0 THEN
            -- Montando o cabecalho das contas do dia atual
            vr_setlinha := '70'||                                                                                     --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                               --> Data DDMMAA
                           gene0002.fn_mask(8054, pr_dsforma => '9999')||','||                                        --> Conta Origem
                           gene0002.fn_mask(8116, pr_dsforma => '9999')||','||                                        --> Conta Destino
                           TRIM(TO_CHAR(vr_tot_vlprvfis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                        --> Fixo
                           '"PROVISAO DO MES - RDCA 60 COOPERADOS PESSOA FISICA"';                                    --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita

            -- Verifica se existe valores       
            IF vr_tab_tot_vlprvfis.COUNT > 0 THEN
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP 
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_tab_tot_vlprvfis.FIRST()..vr_tab_tot_vlprvfis.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_tab_tot_vlprvfis.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se o valor maior que zero
                    IF vr_tab_tot_vlprvfis(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_vlprvfis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      -- Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';       
                END LOOP;
              END LOOP; -- fim repete
            END IF;
          END IF; -- Se valor maior que zero       
          
          
          /*** Montando as informacoes de PESSOA JURIDICA ***/

          -- Se valor total maior que zero
          IF NVL(vr_tot_vlprvjur,0) > 0 THEN
            -- Montando o cabecalho das contas do dia atual
            vr_setlinha := '70'||                                                                                     --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                               --> Data DDMMAA
                           gene0002.fn_mask(8055, pr_dsforma => '9999')||','||                                        --> Conta Origem
                           gene0002.fn_mask(8116, pr_dsforma => '9999')||','||                                        --> Conta Destino
                           TRIM(TO_CHAR(vr_tot_vlprvjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                        --> Fixo
                           '"PROVISAO DO MES - RDCA 60 COOPERADOS PESSOA JURIDICA"';                                  --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita

            -- Verifica se existe valores
            IF vr_tab_tot_vlprvjur.COUNT > 0 THEN
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP  
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_tab_tot_vlprvjur.FIRST()..vr_tab_tot_vlprvjur.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_tab_tot_vlprvjur.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se valor maior que zero
                    IF vr_tab_tot_vlprvjur(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_vlprvjur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      --Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';
                END LOOP;
              END LOOP; -- fim repete
            END IF;
          END IF; -- Se valor maior que zero
          
          --Histórico 182
          -- Se valor total maior que zero
          IF NVL(vr_tot_vlajusprv_fis,0) > 0 THEN
            -- Montando o cabecalho das contas do dia atual
            vr_setlinha := '70'||                                                                                     --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                               --> Data DDMMAA
                           gene0002.fn_mask(8116, pr_dsforma => '9999')||','||                                        --> Conta Origem
                           gene0002.fn_mask(8054, pr_dsforma => '9999')||','||                                        --> Conta Destino
                           TRIM(TO_CHAR(vr_tot_vlajusprv_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                        --> Fixo
                           '"AJUSTE DE PROVISAO RDCA60 – PESSOA FISICA"';                                    --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita

            -- Verifica se existe valores       
            IF vr_tab_tot_vlajusprv_fis.COUNT > 0 THEN
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP 
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_tab_tot_vlajusprv_fis.FIRST()..vr_tab_tot_vlajusprv_fis.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_tab_tot_vlajusprv_fis.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se o valor maior que zero
                    IF vr_tab_tot_vlajusprv_fis(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_vlajusprv_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      -- Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';       
                END LOOP;
              END LOOP; -- fim repete
            END IF;
          END IF; -- Se valor maior que zero       
          
          
          /*** Montando as informacoes de PESSOA JURIDICA ***/

          -- Se valor total maior que zero
          IF NVL(vr_tot_vlajusprv_jur,0) > 0 THEN
            -- Montando o cabecalho das contas do dia atual
            vr_setlinha := '70'||                                                                                     --> Informacao inicial
                           TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                           TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                               --> Data DDMMAA
                           gene0002.fn_mask(8116, pr_dsforma => '9999')||','||                                        --> Conta Origem
                           gene0002.fn_mask(8055, pr_dsforma => '9999')||','||                                        --> Conta Destino
                           TRIM(TO_CHAR(vr_tot_vlajusprv_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                           gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                        --> Fixo
                           '"AJUSTE DE PROVISAO RDCA60 – PESSOA JURIDICA"';                                  --> Descricao

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita

            -- Verifica se existe valores
            IF vr_tab_tot_vlajusprv_jur.COUNT > 0 THEN
              -- imprimir os valores para cada conta, ou seja, em duplicidade
              FOR repete IN 1..2 LOOP  
                -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_tab_tot_vlajusprv_jur.FIRST()..vr_tab_tot_vlajusprv_jur.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_tab_tot_vlajusprv_jur.EXISTS(vr_idx_agencia) THEN
                    -- Verifica se valor maior que zero
                    IF vr_tab_tot_vlajusprv_jur(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := TO_CHAR(vr_idx_agencia, 'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_vlajusprv_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      --Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';
                END LOOP;
              END LOOP; -- fim repete
            END IF;
          END IF; -- Se valor maior que zero


          --Fechar Arquivo
          BEGIN
             gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          EXCEPTION
             WHEN OTHERS THEN
             -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
             vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;
             RAISE vr_exc_erro;
          END;
          
          -- Busca o diretório para contabilidade
          vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
          vr_arqcon:=  TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_RDCA60.txt';
          
          -- Executa comando UNIX para converter arq para Dos
          vr_dscomand := 'ux2dos ' || vr_nom_direto ||'/'||vr_nmarqtxt||' > ' ||
                                      vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_dscomand
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);
          IF vr_typ_saida = 'ERR' THEN
            RAISE vr_exc_erro;
          END IF;
        
       END IF;
       
       -------------------------------------------------
       -- Fim de geracao de arquivo AAMMDD_RDCA60.txt
       -------------------------------------------------

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_fimprg THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Se foi gerada critica para envio ao log
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
          END IF;
          -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
          btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);
          -- Efetuar commit pois gravaremos o que foi processo até então
          COMMIT;
       WHEN vr_exc_erro THEN

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Retornar texto do erro
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

         -- Efetuar rollback
         ROLLBACK;

       WHEN OTHERS THEN
         -- Efetuar rollback
         ROLLBACK;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Retornar texto do erro
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;

     END;
   END pc_crps175;
/
