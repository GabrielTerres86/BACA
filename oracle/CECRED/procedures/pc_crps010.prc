CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS010" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                                ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                                ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                                ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                                ,pr_dscritic OUT VARCHAR2) IS
BEGIN

/* .............................................................................

 Programa: pc_crps010                          Antigo: Fontes/crps010.p
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Deborah/Edson
 Data    : Janeiro/92.                         Ultima atualizacao: 19/06/2017
 Dados referentes ao programa:

 Frequencia: Mensal (Batch - Background).
 Objetivo  : Atende a solicitacao 004 (mensal - relatorios)
             Emite: relatorio geral de atendimento - matriz (014) e
                    resumo mensal do capital (031).

 Alteracoes: 05/07/94 - Alterado literal cruzeiros reais para reais.

             01/08/94 - Alteracoes para o controle do recadastramento.

             30/08/94 - Alterado o layout do resumo mensal do capital,
                        desprezar os associados com data de eliminacao,
                        ler tabela com o valor do capital eliminado (Edson).

             14/03/95 - Alterado para ler a tabela VALORBAIXA somente quando
                        for final de trimestre (Edson).

             21/03/95 - Alterado para na geracao do relatorio 031, listar
                        somente quando for final de trimestre listar capital
                        em moeda fixa, correcao monetaria do exercicio e
                        correcao monetaria do mes. (Odair).

             10/04/95 - Alterado para emitir resumo por agencia da quantida-
                        de de associados e inclusao das rotinas crps010_1.p e
                        crps010_2.p (Edson).

             19/04/95 - Alterado para modificar o label do relatorio geral de
                        atendimento acrescendo os campos vledvmto e
                        dtedvmto  (Odair).

             11/10/95 - Alterado para incluir a data de adimissao na empresa
                        para agencia 14 (Odair).

             27/11/95 - Alterado para incluir a data de admissao na empresa
                        para a agencia 15. (Odair).

             19/11/96 - Alterar a mascara do campo nrctremp (Odair).

             03/04/97 - Alterado a qtd de vias do relatorio 31 (Deborah).

             22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             18/09/98 - Mudar tratamento de impressao (Deborah).

           02/10/2003 - Mudar o formulario para 132dm no crrl014_99 (Ze).

           05/05/2004 - Tratar eliminados (Edson).

           08/12/2004 - Incluido campos Data Ult.Prestacao Paga/
                        Ult.Valor Pago/Vlr.Provisao Emprestimo e Nivel
                        (Mirtes/Evandro)
                      - Gerar relatorio 398 (Evandro).

           20/05/2005 - Gerar relatorio 421 (Evandro).

           20/06/2005 - Acrescentado campo inmatric na TEMP-TABLE
                        w_demitidos (Diego).

           07/07/2005 - Gerar relatorio 426 (Evandro).

           18/08/2005 - Detalhar admitidos de cada PAC no rel 031 (Evandro).

           14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

           28/03/2006 - Retirar verificacao do crapvia, para copia dos
                        relatorios para o servidor Web (Junior).

           21/11/2006 - Melhoria de performance (Evandro).

           07/04/2008 - Alterado o formato do campo "qtpreemp" de "z9" para
                        "zz9" e da variável "rel_qtprepag" de "z9" para
                        "zz9".
                      - Ajustado posicionamento do campo "qtpreemp" e
                        variável "rel_qtprepag" nas colunas
                        do form - Kbase IT Solutions - Paulo Ricardo Maciel.

           09/06/2008 - Incluído a chave de acesso (craphis.cdcooper =
                        glb_cdcooper) no "find" da tabela CRAPHIS.
                      - Kbase IT Solutions - Paulo Ricardo Maciel.

                      - Incluir relacao dos debitos a serem efetuados de
                        capital a integralizar no final do relatorio 031
                        (Gabriel).

           16/10/2008 - Incluido campo com valor de Desconto de Titulos no
                        relatorio 398 (Elton).

           01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

           11/12/2008 - Acerto para o Desconto de Titulos (Evandro).

           11/03/2009 - Alterar formato do campo crapass.vledvmto (Gabriel).

           05/05/2009 - Ajustes na leitura de desconto de titulos(Guilherme).

           10/06/2010 - Incluido tratamento para pagamento atraves de TAA
                        (Elton).

           27/04/2012 - Substituido o campo crapepr.qtprepag por crapepr.qtprecal.
                        (David Kruger).

           12/03/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

           11/11/2013 - Ajustes nos relatórios 398 e 426 para não gerar o PDF (Marcos-Supero)

           28/10/2013 - Alterado totalizador de 99 para 999. (Reinert)

           05/11/2013 - Zerado valor das variáveis aux_vlprovisao e
                        aux_nivelrisco na procedure
                        verifica_lancamentos_emprestimos devido os valores
                        estarem se repetindo de maneira erronea. (Reinert)

          07/02/2014 - Correção na formação do campo Total Geral (Marcos - Supero)

          17/02/2014 - Alterado FIND da crapvia para trazer registros do
                       PA 999.(Gabriel)

          29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                       posicoes (Tiago/Gielow SD137074).

          01/04/2015 - Projeto de separação contábeis de PF e PJ. Considerar
                       Pessoa Administrativa (inpessoa = 3) como PJ
                       (Andre Santos - SUPERO).

          08/05/2015 - Ajuster a geração do arquivo de capital, utilizando a
                       data+1 para os dados de reversão e alterando o separador
                       dos valores para vírgula. ( Renato - Supero)

          23/07/2015 - Ajustar a geração do arquivo de capital, para considerar
                       apenas valores ativos ( Renato - Supero )

          21/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                       (Carlos Rafael Tanholi).

   		  28/09/2016 - Alteração do diretório para geração de arquivo contábil.
                       P308 (Ricardo Linhares).                            

		  24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			           crapass, crapttl, crapjur 
					  (Adriano - P339).                     

          19/06/2017 - Ajuste devido a inclusao do novo tipo de situacao da conta
  				             "Desligamento por determinação do BACEN" 
							        ( Jonata - RKAM P364).                              

   ............................................................................. */
   DECLARE

     /* Tipos e registros da pc_crps010 */

     -- Definicao do tipo de informacoes dos borderos de desconto de titulos
     TYPE typ_reg_craptdb_det IS
     RECORD (cdbandoc craptdb.cdbandoc%TYPE
            ,nrdctabb craptdb.nrdctabb%TYPE
            ,nrcnvcob craptdb.nrcnvcob%TYPE
            ,nrdconta craptdb.nrdconta%TYPE
            ,nrdocmto craptdb.nrdocmto%TYPE
            ,vltitulo craptdb.vltitulo%TYPE
            ,insittit craptdb.insittit%TYPE
            ,vr_rowid VARCHAR2(30));

     -- Definicao do tipo de tabela para as informacoes dos borderos de desconto de titulos
     TYPE typ_tab_craptdb_det IS
       TABLE OF typ_reg_craptdb_det
       INDEX BY PLS_INTEGER;

     TYPE typ_reg_craptdb IS
     RECORD(tab_craptdb typ_tab_craptdb_det);

     TYPE typ_tab_craptdb IS
       TABLE OF typ_reg_craptdb
       INDEX BY PLS_INTEGER; -- Numero da conta

     -- Definicao do tipo de registro para tabela cotas
     TYPE typ_reg_crapcot IS
     RECORD (qtcotmfx crapcot.qtcotmfx%TYPE
            ,vlcmicot crapcot.vlcmicot%TYPE
            ,vlcmmcot crapcot.vlcmmcot%TYPE
            ,vldcotas crapcot.vldcotas%TYPE
            ,qtprpgpl crapcot.qtprpgpl%TYPE);

     -- Definicao do tipo de tabela para as cotas
     TYPE typ_tab_crapcot IS
       TABLE OF typ_reg_crapcot
       INDEX BY PLS_INTEGER;

     -- Definicao do tipo de registro de titulares da conta
     TYPE typ_reg_crapttl IS
     RECORD (cdempres crapttl.cdempres%TYPE
            ,cdturnos crapttl.cdturnos%TYPE);

     -- Definicao do tipo de tabela para titulares da conta
     TYPE typ_tab_crapttl IS
       TABLE OF typ_reg_crapttl
       INDEX BY VARCHAR2(20);

     -- Definicao do tipo de registro dos lancamentos de emprestimo
     TYPE typ_reg_craplem IS
     RECORD (dtmvtolt craplem.dtmvtolt%TYPE
            ,vllanmto craplem.vllanmto%TYPE);

     -- Definicao do tipo de tabela dos lancamentos de emprestimo
     TYPE typ_tab_craplem IS
       TABLE OF typ_reg_craplem
       INDEX BY VARCHAR2(20);

     -- Definicao do tipo de registro para os saldos
     TYPE typ_reg_crapsld IS
     RECORD (vlsmstre##1 crapsld.vlsmstre##1%TYPE
            ,vlsmstre##2 crapsld.vlsmstre##2%TYPE
            ,vlsmstre##3 crapsld.vlsmstre##3%TYPE
            ,vlsmstre##4 crapsld.vlsmstre##4%TYPE
            ,vlsmstre##5 crapsld.vlsmstre##5%TYPE
            ,vlsmstre##6 crapsld.vlsmstre##6%TYPE);

     -- Definicao do tipo de tabela dos lancamentos de emprestimo
     TYPE typ_tab_crapsld IS
       TABLE OF typ_reg_crapsld
       INDEX BY PLS_INTEGER;

     -- Definicao do tipo de tabela para Totais das linhas de credito
     TYPE typ_tab_totlcred  IS
       TABLE OF NUMBER
       INDEX BY PLS_INTEGER;

     -- Definicao do tipo de registro para demitidos
     TYPE typ_reg_demitidos IS
     RECORD (cdagenci crapass.cdagenci%TYPE    --Agencia
            ,nrdconta crapass.nrdconta%TYPE    --conta/dv
            ,cdmotdem crapass.cdmotdem%TYPE    --Codigo Motivo Demissao
            ,inmatric crapass.inmatric%TYPE);  --Matricula 1=original/2=duplicada-transferida

     -- Definicao do tipo de tabela para demitidos
     TYPE typ_tab_demitidos IS
       TABLE OF typ_reg_demitidos
       INDEX BY VARCHAR2(20);

     -- Definicao do tipo de registro para duplicados
     TYPE typ_reg_duplicados IS
     RECORD (cdagenci crapass.cdagenci%TYPE    --Agencia
            ,nrdconta crapass.nrdconta%TYPE);    --conta/dv

     -- Definicao do tipo de tabela para duplicados
     TYPE typ_tab_duplicados IS
       TABLE OF typ_reg_duplicados
       INDEX BY VARCHAR2(15);

     --Definicao do tipo de registro de debitos de capital a integralizar
     TYPE typ_reg_debitos IS
     RECORD (cdagenci crapass.cdagenci%TYPE    --Agencia
            ,nrdconta crapass.nrdconta%TYPE    --conta/dv
            ,nmprimtl crapass.nmprimtl%TYPE    --Nome Titular
            ,dtadmiss crapass.dtadmiss%TYPE    --Data Admissao
            ,dtrefere crapsdc.dtrefere%TYPE    --Data do Debito
            ,vllanmto crapsdc.vllanmto%TYPE    --Valor Lancamento
            ,tplanmto VARCHAR2(15));           --Tipo do Lancamento

     --Definicao do tipo de tabela de debitos
     TYPE typ_tab_debitos IS
       TABLE OF typ_reg_debitos
       INDEX BY VARCHAR2(15);

     --Definicao do tipo de tabela auxiliar de emprestimos
     TYPE typ_tab_crawepr IS
       TABLE OF VARCHAR2(2)
       INDEX BY VARCHAR2(20);

     --Definicao do tipo de registro para nivel calculo
     TYPE typ_reg_craptab IS
     RECORD (vl_provisao NUMBER(15,2)
            ,vl_nivelrisco INTEGER);

     --Definicao do tipo de tabela para nivel calculo
     TYPE typ_tab_craptab IS
       TABLE OF typ_reg_craptab
       INDEX BY VARCHAR2(2);

    --Definicao do tipo de registro para motivos demissao
     TYPE typ_reg_craptab_motivo IS
       TABLE OF VARCHAR2(100)
       INDEX BY PLS_INTEGER;

    --Definicao do tipo de registro para os totalizadores
     TYPE typ_reg_tot IS
       TABLE OF NUMBER
       INDEX BY PLS_INTEGER;

     --Definicao do tipo de registro para associados
     TYPE typ_reg_crapass IS
       RECORD (nmprimtl crapass.nmprimtl%type
              ,nrfonres VARCHAR2(20)
              ,nrtelefo craptfc.nrtelefo%type
              ,nrmatric crapass.nrmatric%type);
     --Definicao do tipo de tabela para associados
     TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;

     -- PL Table para armazenar valores totais por PF e PJ
     TYPE typ_reg_total IS
       RECORD(dup_qtcotist_ati NUMBER DEFAULT 0
             ,dup_qtcotist_dem NUMBER DEFAULT 0
             ,dup_qtcotist_exc NUMBER DEFAULT 0
             ,res_vlcapcrz_ati NUMBER DEFAULT 0
             ,res_vlcapcrz_dem NUMBER DEFAULT 0
             ,res_vlcapcrz_exc NUMBER DEFAULT 0
             ,res_vlcapcrz_tot NUMBER DEFAULT 0
             ,sub_vlcapcrz_ati NUMBER DEFAULT 0
             ,sub_vlcapcrz_dem NUMBER DEFAULT 0
             ,sub_vlcapcrz_exc NUMBER DEFAULT 0
             ,sub_vlcapcrz_tot NUMBER DEFAULT 0
             ,res_qtcotist_ati NUMBER DEFAULT 0
             ,res_qtcotist_dem NUMBER DEFAULT 0
             ,res_qtcotist_exc NUMBER DEFAULT 0
             ,res_qtcotist_tot NUMBER DEFAULT 0);

     -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
     TYPE typ_tab_total IS
       TABLE OF typ_reg_total
       INDEX BY PLS_INTEGER;

     -- Instancia e indexa por agencia os valores de capital subscrito menos o procap de pessoa fisica
     TYPE typ_tab_vlcapage_fis IS
       TABLE OF NUMBER INDEX BY PLS_INTEGER;

     -- Instancia e indexa por agencia os valores de capital subscrito menos o procap de pessoa juridica
     TYPE typ_tab_vlcapage_jur IS
       TABLE OF NUMBER
       INDEX BY PLS_INTEGER;

     -- Instancia e indexa por agencia os valores de capital a integralizar de pessoa fisica
     TYPE typ_tab_vlcapctz_fis IS
       TABLE OF NUMBER INDEX BY PLS_INTEGER;

     -- Instancia e indexa por agencia os valores de capital a integralizar de pessoa juridica
     TYPE typ_tab_vlcapctz_jur IS
       TABLE OF NUMBER
       INDEX BY PLS_INTEGER;

     -- Instancia e indexa por agencia e tipo de pessoas o valor do procapcred
     TYPE typ_tab_tot_pcap_fis IS
       TABLE OF NUMBER
       INDEX BY PLS_INTEGER;

     -- Instancia e indexa por agencia e tipo de pessoas o valor do procapcred
     TYPE typ_tab_tot_pcap_jur IS
       TABLE OF NUMBER
       INDEX BY PLS_INTEGER;

     /* Vetores de memória */
     vr_tab_totlcred       typ_tab_totlcred;
     vr_tab_demitidos      typ_tab_demitidos;
     vr_tab_duplicados     typ_tab_duplicados;
     vr_tab_debitos        typ_tab_debitos;
     vr_tab_crapttl        typ_tab_crapttl;
     vr_tab_craptdb        typ_tab_craptdb;
     vr_tab_crapcot        typ_tab_crapcot;
     vr_tab_crappla        typ_reg_tot;
     vr_tab_crapalt        typ_reg_tot;
     vr_tab_craplim        typ_reg_tot;
     vr_tab_crapcdb        typ_reg_tot;
     vr_tab_craphis        typ_reg_tot;
     vr_tab_crapsld        typ_tab_crapsld;
     vr_tab_craplem        typ_tab_craplem;
     vr_tab_crawepr        typ_tab_crawepr;
     vr_tab_craptab        typ_tab_craptab;
     vr_tab_crapass        typ_tab_crapass;
     vr_tab_crapsdc        typ_reg_tot;
     vr_tab_craptab_motivo typ_reg_craptab_motivo;
     vr_typ_tab_total      typ_tab_total;
     vr_tab_vlcapage_fis   typ_tab_vlcapage_fis;
     vr_tab_vlcapage_jur   typ_tab_vlcapage_jur;
     vr_tab_vlcapctz_fis   typ_tab_vlcapctz_fis;
     vr_tab_vlcapctz_jur   typ_tab_vlcapctz_jur;
     vr_tab_tot_pcap_fis   typ_tab_tot_pcap_fis;
     vr_tab_tot_pcap_jur   typ_tab_tot_pcap_fis;

     /* Vetores de memória de agencias */
     vr_tab_age_qtassmes_adm typ_reg_tot;
     vr_tab_age_qtcotist_ati typ_reg_tot;
     vr_tab_age_qtcotist_dem typ_reg_tot;
     vr_tab_age_qtcotist_exc typ_reg_tot;
     vr_tab_tot_nrassmag     typ_reg_tot;
     vr_tab_tot_vlsmtrag     typ_reg_tot;
     vr_tab_tot_vlsmmes1     typ_reg_tot;
     vr_tab_tot_vlsmmes2     typ_reg_tot;
     vr_tab_tot_vlsmmes3     typ_reg_tot;
     vr_tab_tot_vlcaptal     typ_reg_tot;
     vr_tab_tot_nrdplaag     typ_reg_tot;
     vr_tab_tot_vlprepla     typ_reg_tot;
     vr_tab_tot_qtnrecad     typ_reg_tot;
     vr_tab_tot_qtadmiss     typ_reg_tot;
     vr_tab_tot_qtjrecad     typ_reg_tot;
     vr_tab_tot_qtctremp     typ_reg_tot;
     vr_tab_tot_vlpreemp     typ_reg_tot;
     vr_tab_tot_vlsdeved     typ_reg_tot;
     vr_tab_tot_vljurmes     typ_reg_tot;
     vr_tab_tot_qtassemp     typ_reg_tot;
     vr_tab_rel_qttotmot     typ_reg_tot;

     -- variáveis para controle de arquivos
     vr_dircon VARCHAR2(200);
     vr_arqcon VARCHAR2(200);
     vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos'; 
     vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
     vc_cdtodascooperativas INTEGER := 0;       

     /* Cursores da pc_crps010 */

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
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

     --Tipo de dado para receber as datas da tabela crapdat
     rw_crapdat btch0001.rw_crapdat%TYPE;

     --Selecionar informacoes dos limites de credito
     CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
       SELECT craplcr.cdlcremp
             ,craplcr.dslcremp
       FROM  craplcr craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
       AND   craplcr.cdlcremp = pr_cdlcremp;
     rw_craplcr cr_craplcr%ROWTYPE;

     --Selecionar as agencias
     CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE) IS
       SELECT crapage.cdagenci
             ,crapage.nmresage
       FROM crapage crapage
       WHERE crapage.cdcooper = pr_cdcooper
       ORDER BY crapage.cdagenci;

     --Selecionar informecoes dos saldos dos associados
     CURSOR cr_crapsld (pr_cdcooper IN crapass.cdcooper%TYPE) IS
       SELECT  crapsld.nrdconta
              ,crapsld.vlsmstre##1
              ,crapsld.vlsmstre##2
              ,crapsld.vlsmstre##3
              ,crapsld.vlsmstre##4
              ,crapsld.vlsmstre##5
              ,crapsld.vlsmstre##6
       FROM crapsld crapsld
       WHERE crapsld.cdcooper = pr_cdcooper;

     --Selecionar informacoes dos associados e saldos das contas
     CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT  crapass.cdagenci
              ,crapass.nrdconta
              ,crapass.vllimcre
              ,crapass.tpextcta
              ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa -- Tratando pessoa administrativa como PJ
              ,crapass.cdmotdem
              ,crapass.dtnasctl
              ,crapass.inmatric
              ,crapass.dtadmiss
              ,crapass.dtelimin
              ,crapass.tplimcre
              ,crapass.indnivel
              ,crapass.nrmatric
              ,crapass.dtadmemp
              ,crapass.vledvmto
              ,crapass.dtedvmto
              ,crapass.dtultlcr
              ,SubStr(crapass.nmprimtl,1,35) nmprimtl
              ,crapass.nrramemp
              ,TO_CHAR(NULL) NRFONRES  -- Retorna NULL, pois é necssário que o campo exista no select
              ,crapass.dtdemiss
              ,crapass.cdsitdct
              ,crapass.cdtipcta
              ,crapass.nrcpfcgc
              ,crapass.nrdctitg
              ,crapass.tpvincul
       FROM crapass crapass
       WHERE  crapass.cdcooper = pr_cdcooper
       AND    crapass.cdagenci = pr_cdagenci;

     -- Selecionar informacoes dos associados
     CURSOR cr_crapass_carga (pr_cdcooper IN crapass.cdcooper%TYPE) IS
       SELECT /*+ INDEX (crapass crapass##crapass7) */
              crapass.nrdconta
             ,crapass.nmprimtl
             ,TO_CHAR(NULL) NRFONRES  -- Retorna NULL, pois é necssário que o campo exista no select
             ,crapass.nrmatric
         FROM crapass crapass
        WHERE  crapass.cdcooper = pr_cdcooper;

     -- Selecionar informacoes dos titulares da conta
     CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
                       ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
       SELECT crapttl.cdcooper
             ,crapttl.nrdconta
             ,crapttl.cdempres
             ,crapttl.cdturnos
       FROM crapttl crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
       AND   crapttl.idseqttl = pr_idseqttl;
     rw_crapttl cr_crapttl%ROWTYPE;

     -- Selecionar informacoes dos titulares da conta
     CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                       ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
       SELECT crapjur.cdempres
       FROM crapjur crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
       AND   crapjur.nrdconta = pr_nrdconta;


     -- Selecionar as informacoes das cotas dos associados
     CURSOR cr_crapcot (pr_cdcooper IN crapcot.cdcooper%TYPE) IS
       SELECT crapcot.nrdconta
             ,crapcot.qtcotmfx
             ,crapcot.vlcmicot
             ,crapcot.vlcmmcot
             ,crapcot.vldcotas
             ,crapcot.qtprpgpl
       FROM crapcot crapcot
       WHERE crapcot.cdcooper = pr_cdcooper;

     -- Selecionar informacoes de subscricao do capital dos associados
     CURSOR cr_crapsdc (pr_cdcooper IN crapsdc.cdcooper%TYPE
                       ,pr_nrdconta IN crapsdc.nrdconta%TYPE) IS
       SELECT crapsdc.cdcooper
             ,crapsdc.dtrefere
             ,crapsdc.nrdconta
             ,crapsdc.tplanmto
             ,crapsdc.vllanmto
             ,Decode(crapsdc.tplanmto,1,'CAPITAL INICIAL',2,'PLANO') dslanmto
       FROM crapsdc crapsdc
       WHERE crapsdc.cdcooper = pr_cdcooper
       AND   crapsdc.nrdconta = pr_nrdconta
       AND   crapsdc.dtdebito IS NULL
       AND   crapsdc.indebito = 0;

     -- Selecionar informacoes de subscricao do capital dos associados
     CURSOR cr_crapsdc_existe (pr_cdcooper IN crapsdc.cdcooper%TYPE) IS
       SELECT crapsdc.nrdconta
       FROM crapsdc crapsdc
       WHERE crapsdc.cdcooper = pr_cdcooper
       AND   crapsdc.dtdebito IS NULL
       AND   crapsdc.indebito = 0;

     -- Selecionar informacoes dos planos
     CURSOR cr_crappla (pr_cdcooper IN crappla.cdcooper%TYPE) IS
       SELECT  crappla.nrdconta
              ,crappla.vlprepla
       FROM crappla crappla
       WHERE crappla.cdcooper = pr_cdcooper
       AND   crappla.tpdplano = 1
       AND   crappla.cdsitpla = 1
       ORDER BY CDCOOPER, NRDCONTA, CDSITPLA, TPDPLANO, DTCANCEL DESC, NRCTRPLA DESC, PROGRESS_RECID;

     -- Selecionar informacoes historico de alteracoes crapass
     CURSOR cr_crapalt (pr_cdcooper IN crapalt.cdcooper%TYPE) IS
       SELECT crapalt.nrdconta
       FROM crapalt crapalt
       WHERE  crapalt.cdcooper = pr_cdcooper
       AND    crapalt.tpaltera = 1;
     rw_crapalt cr_crapalt%ROWTYPE;

     -- Selecionar informacoes dos emprestimos
     CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
       SELECT /*+ INDEX (crapepr crapepr##crapepr2) */
              crapepr.vlsdeved
             ,crapepr.nrdconta
             ,crapepr.nrctremp
             ,crapepr.cdlcremp
             ,crapepr.dtmvtolt
             ,crapepr.vlemprst
             ,crapepr.dtultpag
             ,crapepr.cdcooper
             ,crapepr.cdagenci
             ,crapepr.vlpreemp
             ,crapepr.qtpreemp
             ,crapepr.qtprecal
             ,crapepr.vljurmes
             ,crapepr.cdfinemp
             ,crapepr.txjuremp
             ,crapepr.inliquid
       FROM crapepr crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
       AND   crapepr.nrdconta = pr_nrdconta;

     -- Selecionar informacoes do cadastro auxiliar dos emprestimos
     CURSOR cr_crawepr (pr_cdcooper IN crapepr.cdcooper%TYPE) IS
       SELECT  crawepr.nrdconta
              ,crawepr.nrctremp
              ,LTrim(RTrim(crawepr.dsnivcal)) dsnivcal
       FROM crawepr crawepr
       WHERE crawepr.cdcooper = pr_cdcooper;

     -- Selecionar informacoes dos lancamentos do emprestimos
     CURSOR cr_craplem (pr_cdcooper IN crapepr.cdcooper%TYPE) IS
       SELECT craplem.nrdconta
             ,craplem.nrctremp
             ,max(craplem.dtmvtolt) keep (dense_rank last order by craplem.dtmvtolt) dtmvtolt
             ,sum(craplem.vllanmto) keep (dense_rank last order by craplem.dtmvtolt) vllanmto
       FROM craplem craplem
       WHERE craplem.cdcooper = pr_cdcooper
       AND EXISTS (SELECT 1 from craphis
                   WHERE craphis.cdcooper = craplem.cdcooper
                   AND   craphis.cdhistor = craplem.cdhistor
                   AND   craphis.indebcre = 'C')
       GROUP BY craplem.nrdconta,craplem.nrctremp;

     -- Selecionar os dados da tabela Generica
     CURSOR cr_craptab (pr_cdcooper   craptab.cdcooper%TYPE
                       ,pr_nmsistem   craptab.nmsistem%TYPE
                       ,pr_tptabela   craptab.tptabela%TYPE
                       ,pr_cdempres   craptab.cdempres%TYPE
                       ,pr_cdacesso   craptab.cdacesso%TYPE) IS
       SELECT  LTrim(RTrim(SubStr(craptab.dstextab,9,2))) dsnivcal
              ,GENE0002.fn_char_para_number(SUBSTR(craptab.dstextab,1,5)) vl_provisao
              ,GENE0002.fn_char_para_number(SUBSTR(craptab.dstextab,12,2)) vl_nivelrisco
       FROM craptab  craptab
       WHERE craptab.cdcooper = pr_cdcooper
       AND   UPPER(craptab.nmsistem) = pr_nmsistem
       AND   UPPER(craptab.tptabela) = pr_tptabela
       AND   craptab.cdempres = pr_cdempres
       AND   UPPER(craptab.cdacesso) = pr_cdacesso;

     -- Selecionar os dados da tabela Generica para motivos demissao
     CURSOR cr_craptab_motivo (pr_cdcooper IN craptab.cdcooper%TYPE
                              ,pr_nmsistem IN craptab.nmsistem%TYPE
                              ,pr_tptabela IN craptab.tptabela%TYPE
                              ,pr_cdempres IN craptab.cdempres%TYPE
                              ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
       SELECT craptab.tpregist
             ,SubStr(craptab.dstextab,1,100) dstextab
       FROM craptab craptab
       WHERE craptab.cdcooper = pr_cdcooper
       AND   UPPER(craptab.nmsistem) = pr_nmsistem
       AND   UPPER(craptab.tptabela) = pr_tptabela
       AND   craptab.cdempres = pr_cdempres
       AND   UPPER(craptab.cdacesso) = pr_cdacesso;

     -- Selecionar informacoes do bordero desconto cheque
     CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
                       ,pr_dtlibera IN crapcdb.dtlibera%TYPE
                       ,pr_insitchq IN crapcdb.insitchq%TYPE) IS
       SELECT  /*+ INDEX (crapcdb crapcdb##crapcdb3) */
               crapcdb.nrdconta
              ,Nvl(Sum(Nvl(crapcdb.vlcheque,0)),0) vlcheque
       FROM crapcdb
       WHERE crapcdb.cdcooper = pr_cdcooper
       AND   crapcdb.dtlibera > pr_dtlibera
       AND   crapcdb.insitchq = pr_insitchq
       AND   crapcdb.dtdevolu IS NULL
       GROUP BY crapcdb.nrdconta;

     -- Selecionar informacoes dos borderos de desconto de titulos
     CURSOR cr_craptdb (pr_cdcooper IN crapcob.cdcooper%TYPE
                       ,pr_dtpagto  IN craptdb.dtdpagto%TYPE) IS
       SELECT /*+ INDEX (craptdb craptdb##craptdb2) */
              craptdb.cdbandoc
             ,craptdb.nrdctabb
             ,craptdb.nrcnvcob
             ,craptdb.nrdconta
             ,craptdb.nrdocmto
             ,craptdb.vltitulo
             ,craptdb.insittit
             ,craptdb.rowid
       ,rownum
       FROM craptdb craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
       AND   (craptdb.insittit = 2 OR craptdb.insittit = 4)
       AND  ((craptdb.dtvencto >= pr_dtpagto AND craptdb.insittit = 4)
        OR   (craptdb.dtdpagto =  pr_dtpagto AND craptdb.insittit = 2));

     -- Selecionar informacoes dos boletos de cobranca
     CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                       ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                       ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                       ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                       ,pr_nrdconta IN crapcob.nrdconta%TYPE
                       ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
       SELECT crapcob.indpagto
       FROM crapcob crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
       AND   crapcob.cdbandoc = pr_cdbandoc
       AND   crapcob.nrdctabb = pr_nrdctabb
       AND   crapcob.nrcnvcob = pr_nrcnvcob
       AND   crapcob.nrdconta = pr_nrdconta
       AND   crapcob.nrdocmto = pr_nrdocmto;
     rw_crapcob cr_crapcob%ROWTYPE;

     -- Selecionar informacoes dos limites dos associados
     CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE) IS
       SELECT /*+ INDEX (craplim craplim##craplim1) */
              craplim.nrdconta
             ,Nvl(Sum(Nvl(craplim.vllimite,0)),0) vllimite
       FROM  craplim craplim
       WHERE craplim.cdcooper = pr_cdcooper
       AND   craplim.tpctrlim = 1
       AND   craplim.insitlim = 2
       GROUP BY craplim.nrdconta;

     -- Selecionar Codigo Historico de Creditos
     CURSOR cr_craphis (pr_cdcooper IN crapcop.cdcooper%type) IS
       SELECT craphis.cdhistor
       FROM craphis
       WHERE craphis.cdcooper = pr_cdcooper
       AND craphis.indebcre = 'C';

     /* Variaveis Locais da pc_crps010 */
     vr_dtultpagto DATE;
     vr_vlultpagto NUMBER;
     vr_vlprovisao NUMBER;
     vr_nivelrisco INTEGER;

     /* variaveis para o fontes/idade.p */
     vr_nrdeanos   INTEGER;
     vr_nrdmeses   INTEGER;
     vr_dsdidade   VARCHAR2(100);
     vr_cdempres   INTEGER:= 0;

     --Variaveis de Datas
     vr_dtmvtolt  DATE;

     --Variaveis de controle do programa
     vr_cdprogra     VARCHAR2(10);
     vr_cdcritic     NUMBER:= 0;
     vr_desconto     NUMBER:= 0;
     vr_desctitu     NUMBER:= 0;
     vr_des_erro     VARCHAR2(4000);
     vr_nom_arquivo  VARCHAR2(100);
     vr_nom_direto   VARCHAR2(400);
     vr_rel_dsagenci VARCHAR2(400);
     vr_flgfirst     BOOLEAN;
     vr_flgnvpag     BOOLEAN;
     vr_regexist     BOOLEAN;
     vr_flgclob      BOOLEAN;
     vr_fisrtemp     BOOLEAN;
     vr_cdagenci     crapage.cdagenci%TYPE;
     vr_nmresage     crapage.nmresage%TYPE;

     -- Variavel para controle de PL-TABLE - PROCAP
     vr_ind_first VARCHAR2(100);
     vr_ind_last VARCHAR2(100);
     vr_first VARCHAR2(100);
     vr_last  VARCHAR2(100);

     -- Variaveis dos Relatorios
     vr_rel_dsdacstp     VARCHAR2(3);
     vr_rel_dslimcre     VARCHAR2(2);
     vr_rel_vlsmtrag     NUMBER:= 0;
     vr_vlsdeved         NUMBER:= 0;
     vr_vlpreemp         NUMBER:= 0;
     vr_qtctremp         NUMBER:= 0;
     vr_tot_qtassati     NUMBER:= 0;
     vr_tot_qtassdem     NUMBER:= 0;
     vr_tot_qtassexc     NUMBER:= 0;
     vr_tot_qtasexpf     NUMBER:= 0;
     vr_tot_qtasexpj     NUMBER:= 0;
     vr_rel_vlcaptal     crapcot.vldcotas%TYPE;
     vr_rel_vlcppctl     crapcot.vldcotas%TYPE;
     vr_rel_vlcapctz     crapcot.vldcotas%TYPE;
     vr_rel_vlproctl     crapcot.vldcotas%TYPE;
     vr_rel_qtprpgpl     INTEGER:= 0;
     vr_res_vlcapcrz_ati NUMBER:= 0;
     vr_res_vlcapmfx_ati NUMBER:= 0;
     vr_res_vlcmicot_ati NUMBER:= 0;
     vr_res_vlcmmcot_ati NUMBER:= 0;
     vr_res_vlcapcrz_dem NUMBER:= 0;
     vr_res_vlcapmfx_dem NUMBER:= 0;
     vr_res_vlcmicot_dem NUMBER:= 0;
     vr_res_vlcmmcot_dem NUMBER:= 0;
     vr_res_qtcotist_ati NUMBER:= 0;
     vr_res_qtcotist_dem NUMBER:= 0;
     vr_tot_lancamen     INTEGER:= 0;
     vr_tot_vllanmto     NUMBER:= 0;
     vr_sub_vlcapcrz_ati NUMBER:= 0;
     vr_sub_vlcapcrz_tot NUMBER:= 0;
     vr_sub_vlcapcrz_dem NUMBER:= 0;
     vr_sub_vlcapcrz_exc NUMBER:= 0;
     vr_rel_vlprepla     NUMBER:= 0;
     vr_rel_qtpreapg     NUMBER:= 0;
     vr_rel_dsmsgrec     VARCHAR2(100);
     vr_dtadmemp         VARCHAR2(10);
     vr_dsprefix         CONSTANT VARCHAR2(15) := 'REVERSAO ';

     -- Variaveis utilizadas na rotina pc_busca_resumo_capital
     vr_rel_nomemes1     VARCHAR2(09);
     vr_rel_nomemes2     VARCHAR2(09);
     vr_rel_nomemes3     VARCHAR2(09);
     vr_res_qtassati     NUMBER:= 0;
     vr_res_qtassdem     NUMBER:= 0;
     vr_res_qtassmes     NUMBER:= 0;
     vr_res_qtdemmes_ati NUMBER:= 0;
     vr_res_qtdemmes_dem NUMBER:= 0;
     vr_res_qtassbai     NUMBER:= 0;
     vr_res_qtdesmes_ati NUMBER:= 0;
     vr_res_qtdesmes_dem NUMBER:= 0;
     vr_res_vlcapcrz_exc NUMBER:= 0;
     vr_res_vlcmicot_exc NUMBER:= 0;
     vr_res_vlcmmcot_exc NUMBER:= 0;
     vr_res_vlcapmfx_exc NUMBER:= 0;
     vr_res_qtcotist_exc NUMBER:= 0;
     vr_res_vlcapcrz_tot NUMBER:= 0;
     vr_res_vlcmicot_tot NUMBER:= 0;
     vr_res_vlcmmcot_tot NUMBER:= 0;
     vr_res_vlcapmfx_tot NUMBER:= 0;
     vr_res_qtcotist_tot NUMBER:= 0;

     -- Totalizadores
     vr_rel_vlsmmes1     crapsld.vlsmstre##1%TYPE;
     vr_rel_vlsmmes2     crapsld.vlsmstre##1%TYPE;
     vr_rel_vlsmmes3     crapsld.vlsmstre##1%TYPE;
     vr_dup_qtcotist_ati INTEGER:= 0;
     vr_dup_qtcotist_dem INTEGER:= 0;
     vr_dup_qtcotist_exc INTEGER:= 0;
     vr_tot_capagefis    NUMBER:= 0;
     vr_tot_capagejur    NUMBER:= 0;
     vr_tot_vlcapctz_fis NUMBER:= 0;
     vr_tot_vlcapctz_jur NUMBER:= 0;
     vr_totativo         NUMBER;
     vr_vlativos         NUMBER;
     vr_tot_pcapcred_fis NUMBER:= 0;
     vr_tot_pcapcred_jur NUMBER:= 0;
     vr_tab_craplct      PCAP0001.typ_tab_craplct;
     vr_typ_tab_ativos   PCAP0001.typ_tab_ativos;


     -- Variaveis de indice para as tabelas de memoria
     vr_index_demitidos  VARCHAR2(20);
     vr_index_duplicados VARCHAR2(15);
     vr_index_debitos    VARCHAR2(15);
     vr_index_crapttl    VARCHAR2(20);
     vr_index_craplem    VARCHAR2(20);
     vr_index_crawepr    VARCHAR2(20);
     vr_index_craptdb    NUMBER(10);


     -- Variável para armazenar as informações em XML
     vr_des_xml   CLOB;
     vr_cod_chave INTEGER;
     vr_des_chave VARCHAR2(400);

     -- Variavel para o rowtype da crapsld
     rw_crapsld crapsld%ROWTYPE;

     --Variavel para arquivo de dados
     vr_input_file utl_file.file_type;

     -- Variaveis de Excecao
     vr_dscritic   VARCHAR2(4000);
     vr_exc_undo   EXCEPTION;
     vr_exc_fimprg EXCEPTION;
     vr_exc_saida  EXCEPTION;
     vr_exc_pula   EXCEPTION;

     -- Procedure para limpar os dados das tabelas de memoria
     PROCEDURE pc_limpa_tabela IS
     BEGIN
       -- Tabelas de memoria para melhora performance
       vr_tab_totlcred.DELETE;
       vr_tab_demitidos.DELETE;
       vr_tab_duplicados.DELETE;
       vr_tab_debitos.DELETE;
       vr_tab_age_qtassmes_adm.DELETE;
       vr_tab_tot_nrassmag.DELETE;
       vr_tab_tot_vlsmtrag.DELETE;
       vr_tab_tot_vlsmmes1.DELETE;
       vr_tab_tot_vlsmmes2.DELETE;
       vr_tab_tot_vlsmmes3.DELETE;
       vr_tab_tot_vlcaptal.DELETE;
       vr_tab_age_qtcotist_ati.DELETE;
       vr_tab_age_qtcotist_dem.DELETE;
       vr_tab_age_qtcotist_exc.DELETE;
       vr_tab_tot_nrdplaag.DELETE;
       vr_tab_tot_vlprepla.DELETE;
       vr_tab_tot_qtnrecad.DELETE;
       vr_tab_tot_qtadmiss.DELETE;
       vr_tab_tot_qtjrecad.DELETE;
       vr_tab_tot_qtctremp.DELETE;
       vr_tab_tot_vlpreemp.DELETE;
       vr_tab_tot_vlsdeved.DELETE;
       vr_tab_tot_vljurmes.DELETE;
       vr_tab_tot_qtassemp.DELETE;
       vr_tab_rel_qttotmot.DELETE;
       vr_typ_tab_total.DELETE;
       vr_tab_vlcapage_fis.DELETE;
       vr_tab_vlcapage_jur.DELETE;
       vr_tab_vlcapctz_fis.DELETE;
       vr_tab_vlcapctz_jur.DELETE;

       -- Tabelas para melhorar performance
       vr_tab_craptdb.DELETE;
       vr_tab_crapcot.DELETE;
       vr_tab_crapttl.DELETE;
       vr_tab_crappla.DELETE;
       vr_tab_crapalt.DELETE;
       vr_tab_craplem.DELETE;
       vr_tab_crawepr.DELETE;
       vr_tab_craptab.DELETE;
       vr_tab_craplim.DELETE;
       vr_tab_crapcdb.DELETE;
       vr_tab_crapsld.DELETE;
       vr_tab_crapsdc.DELETE;
       vr_tab_crapass.DELETE;
       vr_tab_craphis.DELETE;
       vr_tab_craptab_motivo.DELETE;
       vr_tab_tot_pcap_fis.DELETE;
       vr_tab_tot_pcap_fis.DELETE;

     EXCEPTION
       WHEN OTHERS THEN
         -- Variavel de erro recebe erro ocorrido
         vr_des_erro:= 'Erro ao limpar tabelas de memória. Rotina pc_crps010.pc_limpa_tabela. '||sqlerrm;
         -- Sair do programa
         RAISE vr_exc_saida;
     END;

     -- Inicializar tabelas de memoria por tipo de pessoa
     PROCEDURE pc_inicializa_tabela (pr_cdagenci crapage.cdagenci%TYPE) IS
     BEGIN
       -- Zerar vetores de memória de agencias */
       vr_tab_age_qtassmes_adm(pr_cdagenci):= 0;
       vr_tab_age_qtcotist_ati(pr_cdagenci):= 0;
       vr_tab_age_qtcotist_dem(pr_cdagenci):= 0;
       vr_tab_age_qtcotist_exc(pr_cdagenci):= 0;
       vr_tab_tot_nrassmag(pr_cdagenci):= 0;
       vr_tab_tot_vlsmtrag(pr_cdagenci):= 0;
       vr_tab_tot_vlsmmes1(pr_cdagenci):= 0;
       vr_tab_tot_vlsmmes2(pr_cdagenci):= 0;
       vr_tab_tot_vlsmmes3(pr_cdagenci):= 0;
       vr_tab_tot_vlcaptal(pr_cdagenci):= 0;
       vr_tab_tot_nrdplaag(pr_cdagenci):= 0;
       vr_tab_tot_vlprepla(pr_cdagenci):= 0;
       vr_tab_tot_qtnrecad(pr_cdagenci):= 0;
       vr_tab_tot_qtadmiss(pr_cdagenci):= 0;
       vr_tab_tot_qtjrecad(pr_cdagenci):= 0;
       vr_tab_tot_qtctremp(pr_cdagenci):= 0;
       vr_tab_tot_vlpreemp(pr_cdagenci):= 0;
       vr_tab_tot_vlsdeved(pr_cdagenci):= 0;
       vr_tab_tot_vljurmes(pr_cdagenci):= 0;
       vr_tab_tot_qtassemp(pr_cdagenci):= 0;

       -- Inicializar totalizador de motivos para relatorio 421
       FOR idx IN 1..vr_tab_rel_qttotmot.count() LOOP
         vr_tab_rel_qttotmot(idx):= 0;
       END LOOP;

     EXCEPTION
       WHEN OTHERS THEN
         -- Variavel de erro recebe erro ocorrido
         vr_des_erro:= 'Erro ao limpar zerar tabela de memória. Rotina pc_crps010.pc_inicializa_tabela. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     -- Escrever no arquivo CLOB
     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
     BEGIN
       -- Escrever no arquivo XML
       dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
     END;

     -- Verificar os emprestimos do associado
     PROCEDURE pc_verifica_lancto_emprestimo (pr_nrdconta   IN craplem.nrdconta%TYPE
                                             ,pr_nrctremp   IN craplem.nrctremp%TYPE
                                             ,pr_vlsdeved   IN crapepr.vlsdeved%TYPE
                                             ,pr_dtultpagto OUT DATE
                                             ,pr_vlultpagto OUT NUMBER
                                             ,pr_vlprovisao OUT NUMBER
                                             ,pr_nivelrisco OUT NUMBER
                                             ,pr_des_erro   OUT VARCHAR2) IS
     BEGIN
       -- Inicializar variavel de erro
       pr_des_erro:= NULL;
       -- Atribuir nulo para data ultimo pagamento
       pr_dtultpagto:= NULL;
       -- Atribuir zero para valor ultimo pagamento
       pr_vlultpagto:= 0;
       -- Atribuir zero para valor provisao
       pr_vlprovisao:= 0;
       -- Atribuir zero para nivel risco
       pr_nivelrisco:= 0;

       -- Montar o indice para consultar tabela de memoria de lancamentos
       vr_index_craplem:= LPad(pr_nrdconta,10,'0')||LPad(pr_nrctremp,10,'0');
       -- Verificar se existe lancamento para o contrato
       IF vr_tab_craplem.EXISTS(vr_index_craplem) THEN
          pr_dtultpagto:= vr_tab_craplem(vr_index_craplem).dtmvtolt;
          pr_vlultpagto:= vr_tab_craplem(vr_index_craplem).vllanmto;
       END IF;

       /* calcular o valor da provisao e pegar o nivel de risco */

       -- Montar indice para pesquisa na tabela de memória
       vr_index_crawepr:= LPad(pr_nrdconta,10,'0')||LPad(pr_nrctremp,10,'0');

       -- Verificar se o contrato está na tabela de memória
       IF vr_tab_crawepr.EXISTS(vr_index_crawepr) THEN
          -- Leitura dos niveis de risco
          IF vr_tab_craptab.EXISTS(vr_tab_crawepr(vr_index_crawepr)) THEN
             -- Retonar valor da provisao
             pr_vlprovisao:= (pr_vlsdeved * vr_tab_craptab(vr_tab_crawepr(vr_index_crawepr)).vl_provisao) / 100;
             -- Retonar nivel de risco
             pr_nivelrisco:= vr_tab_craptab(vr_tab_crawepr(vr_index_crawepr)).vl_nivelrisco;
          END IF;
       END IF;

     EXCEPTION
       WHEN OTHERS THEN
         pr_des_erro:= 'Erro ao verificar lancamentos emprestimos. Rotina pc_verifica_lancto_emprestimo. '||SQLERRM;
     END;

     -- Geração do relatório de resumo do capital (crrl031)
     PROCEDURE pc_crps010_2 (pr_des_erro OUT VARCHAR2) IS

     /* ..........................................................................
     Programa: pc_crps010_2                        Antigo: Fontes/crps010_2.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Abril/95.                           Ultima atualizacao: 01/04/2015

     Dados referentes ao programa:

     Frequencia: Mensal (Batch - Background).
     Objetivo  : Rotina do resumo do capital.
                 Emite resumo mensal do capital (031).

     Alteracoes: 05/05/2004 - Tratar eliminados (Edson).

                 18/08/2005 - Detalhar os admitidos de cada PAC;
                              Mudado o termo "AGENCIA" por "PAC" (Evandro).

                 14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 22/07/2008 - Alterado para listar debitos a serem efetuados de
                             (Gabriel).

                 18/03/2013 - Migração Progress -> Oracle - Alisson (AMcom)

                 01/04/2015 - Projeto de separação contábeis de PF e PJ
                              (Andre Santos - SUPERO).

     ............................................................................. */

        -- Variaveis auxiliares dos relatorios
        vr_int_vlcapcrz_ati NUMBER:= 0;
        vr_int_vlcapcrz_dem NUMBER:= 0;
        vr_int_vlcapcrz_exc NUMBER:= 0;
        vr_int_vlcapcrz_tot NUMBER:= 0;
        vr_tcs_vlcapcrz_ati NUMBER:= 0;
        vr_tcs_vlcapcrz_dem NUMBER:= 0;
        vr_tcs_vlcapcrz_exc NUMBER:= 0;
        vr_tcs_vlcapcrz_tot NUMBER:= 0;
        vr_dup_qtcotist_tot NUMBER:= 0;
        -- Quantidade total de Cotas por PF e PJ
        vr_dup_qtcottot_fis NUMBER:= 0;
        vr_dup_qtcottot_jur NUMBER:= 0;
        vr_tcs_vlcapati_fis NUMBER:= 0;
        vr_tcs_vlcapdem_fis NUMBER:= 0;
        vr_tcs_vlcapexc_fis NUMBER:= 0;
        vr_tcs_vlcaptot_fis NUMBER:= 0;
        vr_tcs_vlcapati_jur NUMBER:= 0;
        vr_tcs_vlcapdem_jur NUMBER:= 0;
        vr_tcs_vlcapexc_jur NUMBER:= 0;
        vr_tcs_vlcaptot_jur NUMBER:= 0;

     BEGIN
        -- Inicializar variavel de erro
        pr_des_erro:= NULL;
        -- Busca do diretório base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        /* Gerar arquivo com todos os PACs */

        -- Determinar o nome do arquivo que será gerado
        vr_nom_arquivo := 'crrl031';
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl031><totais>');

        -- Se os meses forem: JAN/FEV/ABR/MAIO/JUL/AGO/OUT ou NOV
        IF To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')) IN (1,2,4,5,7,8,10,11) THEN
           --Zerar variaveis
           vr_res_vlcmicot_ati:= 0;
           vr_res_vlcmicot_dem:= 0;
           vr_res_vlcmicot_exc:= 0;
           vr_res_vlcmicot_tot:= 0;
           vr_res_vlcapmfx_ati:= 0;
           vr_res_vlcapmfx_dem:= 0;
           vr_res_vlcapmfx_exc:= 0;
           vr_res_vlcapmfx_tot:= 0;
           vr_res_vlcmmcot_ati:= 0;
           vr_res_vlcmmcot_dem:= 0;
           vr_res_vlcmmcot_exc:= 0;
           vr_res_vlcmmcot_tot:= 0;
        END IF;

        --Totalizar quantidade cotistas somando ativos, demitidos e excluidos
        vr_dup_qtcotist_tot:= Nvl(vr_dup_qtcotist_ati,0) +
                              Nvl(vr_dup_qtcotist_dem,0) +
                              Nvl(vr_dup_qtcotist_exc,0);

        --Totalizar quantidade cotistas somando ativos, demitidos e excluidos por PF
        vr_dup_qtcottot_fis:= Nvl(vr_typ_tab_total(1).dup_qtcotist_ati,0) +
                              Nvl(vr_typ_tab_total(1).dup_qtcotist_dem,0) +
                              Nvl(vr_typ_tab_total(1).dup_qtcotist_exc,0);

        --Totalizar quantidade cotistas somando ativos, demitidos e excluidos por PJ
        vr_dup_qtcottot_jur:= Nvl(vr_typ_tab_total(2).dup_qtcotist_ati,0) +
                              Nvl(vr_typ_tab_total(2).dup_qtcotist_dem,0) +
                              Nvl(vr_typ_tab_total(2).dup_qtcotist_exc,0);

        -- Atribuir valores de capital ativos, demitidos, excluidos e total
        vr_int_vlcapcrz_ati:= Nvl(vr_res_vlcapcrz_ati,0);
        vr_int_vlcapcrz_dem:= Nvl(vr_res_vlcapcrz_dem,0);
        vr_int_vlcapcrz_exc:= Nvl(vr_res_vlcapcrz_exc,0);
        vr_int_vlcapcrz_tot:= Nvl(vr_res_vlcapcrz_tot,0);
        -- Atribuir valores aos totalizadores
        vr_tcs_vlcapcrz_ati:= Nvl(vr_res_vlcapcrz_ati,0) + Nvl(vr_sub_vlcapcrz_ati,0);
        vr_tcs_vlcapcrz_dem:= Nvl(vr_res_vlcapcrz_dem,0) + Nvl(vr_sub_vlcapcrz_dem,0);
        vr_tcs_vlcapcrz_exc:= Nvl(vr_res_vlcapcrz_exc,0) + Nvl(vr_sub_vlcapcrz_exc,0);
        vr_tcs_vlcapcrz_tot:= Nvl(vr_res_vlcapcrz_tot,0) + Nvl(vr_sub_vlcapcrz_tot,0);
        -- Atribuir valores aos totalizadores por PF
        vr_tcs_vlcapati_fis:= Nvl(vr_typ_tab_total(1).res_vlcapcrz_ati,0) + Nvl(vr_typ_tab_total(1).sub_vlcapcrz_ati,0);
        vr_tcs_vlcapdem_fis:= Nvl(vr_typ_tab_total(1).res_vlcapcrz_dem,0) + Nvl(vr_typ_tab_total(1).sub_vlcapcrz_dem,0);
        vr_tcs_vlcapexc_fis:= Nvl(vr_typ_tab_total(1).res_vlcapcrz_exc,0) + Nvl(vr_typ_tab_total(1).sub_vlcapcrz_exc,0);
        vr_tcs_vlcaptot_fis:= Nvl(vr_typ_tab_total(1).res_vlcapcrz_tot,0) + Nvl(vr_typ_tab_total(1).sub_vlcapcrz_tot,0);
        -- Atribuir valores aos totalizadores por PJ
        vr_tcs_vlcapati_jur:= Nvl(vr_typ_tab_total(2).res_vlcapcrz_ati,0) + Nvl(vr_typ_tab_total(2).sub_vlcapcrz_ati,0);
        vr_tcs_vlcapdem_jur:= Nvl(vr_typ_tab_total(2).res_vlcapcrz_dem,0) + Nvl(vr_typ_tab_total(2).sub_vlcapcrz_dem,0);
        vr_tcs_vlcapexc_jur:= Nvl(vr_typ_tab_total(2).res_vlcapcrz_exc,0) + Nvl(vr_typ_tab_total(2).sub_vlcapcrz_exc,0);
        vr_tcs_vlcaptot_jur:= Nvl(vr_typ_tab_total(2).res_vlcapcrz_tot,0) + Nvl(vr_typ_tab_total(2).sub_vlcapcrz_tot,0);

        -- Montar tag com total capital ativo e inativo para arquivo XML
        pc_escreve_xml('
        <tot1>
           <ci_at>'||to_char(vr_int_vlcapcrz_ati,'fm9999g999g999g999g990d00')||'</ci_at>
           <ci_in>'||to_char(vr_int_vlcapcrz_dem,'fm9999g999g999g999g990d00')||'</ci_in>
           <ci_ex>'||to_char(vr_int_vlcapcrz_exc,'fm9999g999g999g999g990d00')||'</ci_ex>
           <ci_tot>'||to_char(vr_int_vlcapcrz_tot,'fm9999g999g999g999g990d00')||'</ci_tot>
           <ci_at_fis>'||to_char(vr_typ_tab_total(1).res_vlcapcrz_ati,'fm9999g999g999g999g990d00')||'</ci_at_fis>
           <ci_in_fis>'||to_char(vr_typ_tab_total(1).res_vlcapcrz_dem,'fm9999g999g999g999g990d00')||'</ci_in_fis>
           <ci_ex_fis>'||to_char(vr_typ_tab_total(1).res_vlcapcrz_exc,'fm9999g999g999g999g990d00')||'</ci_ex_fis>
           <ci_tot_fis>'||to_char(vr_typ_tab_total(1).res_vlcapcrz_tot,'fm9999g999g999g999g990d00')||'</ci_tot_fis>
           <ci_at_jur>'||to_char(vr_typ_tab_total(2).res_vlcapcrz_ati,'fm9999g999g999g999g990d00')||'</ci_at_jur>
           <ci_in_jur>'||to_char(vr_typ_tab_total(2).res_vlcapcrz_dem,'fm9999g999g999g999g990d00')||'</ci_in_jur>
           <ci_ex_jur>'||to_char(vr_typ_tab_total(2).res_vlcapcrz_exc,'fm9999g999g999g999g990d00')||'</ci_ex_jur>
           <ci_tot_jur>'||to_char(vr_typ_tab_total(2).res_vlcapcrz_tot,'fm9999g999g999g999g990d00')||'</ci_tot_jur>
           <cai_at>'||to_char(vr_sub_vlcapcrz_ati,'fm9999g999g999g999g990d00')||'</cai_at>
           <cai_in>'||to_char(vr_sub_vlcapcrz_dem,'fm9999g999g999g999g990d00')||'</cai_in>
           <cai_ex>'||to_char(vr_sub_vlcapcrz_exc,'fm9999g999g999g999g990d00')||'</cai_ex>
           <cai_tot>'||to_char(vr_sub_vlcapcrz_tot,'fm9999g999g999g999g990d00')||'</cai_tot>
           <cai_at_fis>'||to_char(vr_typ_tab_total(1).sub_vlcapcrz_ati,'fm9999g999g999g999g990d00')||'</cai_at_fis>
           <cai_in_fis>'||to_char(vr_typ_tab_total(1).sub_vlcapcrz_dem,'fm9999g999g999g999g990d00')||'</cai_in_fis>
           <cai_ex_fis>'||to_char(vr_typ_tab_total(1).sub_vlcapcrz_exc,'fm9999g999g999g999g990d00')||'</cai_ex_fis>
           <cai_tot_fis>'||to_char(vr_typ_tab_total(1).sub_vlcapcrz_tot,'fm9999g999g999g999g990d00')||'</cai_tot_fis>
           <cai_at_jur>'||to_char(vr_typ_tab_total(2).sub_vlcapcrz_ati,'fm9999g999g999g999g990d00')||'</cai_at_jur>
           <cai_in_jur>'||to_char(vr_typ_tab_total(2).sub_vlcapcrz_dem,'fm9999g999g999g999g990d00')||'</cai_in_jur>
           <cai_ex_jur>'||to_char(vr_typ_tab_total(2).sub_vlcapcrz_exc,'fm9999g999g999g999g990d00')||'</cai_ex_jur>
           <cai_tot_jur>'||to_char(vr_typ_tab_total(2).sub_vlcapcrz_tot,'fm9999g999g999g999g990d00')||'</cai_tot_jur>
           <tcs_at>'||to_char(vr_tcs_vlcapcrz_ati,'fm9999g999g999g999g990d00')||'</tcs_at>
           <tcs_in>'||to_char(vr_tcs_vlcapcrz_dem,'fm9999g999g999g999g990d00')||'</tcs_in>
           <tcs_ex>'||to_char(vr_tcs_vlcapcrz_exc,'fm9999g999g999g999g990d00')||'</tcs_ex>
           <tcs_tot>'||to_char(vr_tcs_vlcapcrz_tot,'fm9999g999g999g999g990d00')||'</tcs_tot>
           <tcs_at_fis>'||to_char(vr_tcs_vlcapati_fis,'fm9999g999g999g999g990d00')||'</tcs_at_fis>
           <tcs_in_fis>'||to_char(vr_tcs_vlcapdem_fis,'fm9999g999g999g999g990d00')||'</tcs_in_fis>
           <tcs_ex_fis>'||to_char(vr_tcs_vlcapexc_fis,'fm9999g999g999g999g990d00')||'</tcs_ex_fis>
           <tcs_tot_fis>'||to_char(vr_tcs_vlcaptot_fis,'fm9999g999g999g999g990d00')||'</tcs_tot_fis>
           <tcs_at_jur>'||to_char(vr_tcs_vlcapati_jur,'fm9999g999g999g999g990d00')||'</tcs_at_jur>
           <tcs_in_jur>'||to_char(vr_tcs_vlcapdem_jur,'fm9999g999g999g999g990d00')||'</tcs_in_jur>
           <tcs_ex_jur>'||to_char(vr_tcs_vlcapexc_jur,'fm9999g999g999g999g990d00')||'</tcs_ex_jur>
           <tcs_tot_jur>'||to_char(vr_tcs_vlcaptot_jur,'fm9999g999g999g999g990d00')||'</tcs_tot_jur>
           <cot_at>'||to_char(vr_res_qtcotist_ati,'fm999g990')||'</cot_at>
           <cot_in>'||to_char(vr_res_qtcotist_dem,'fm999g990')||'</cot_in>
           <cot_ex>'||to_char(vr_res_qtcotist_exc,'fm999g990')||'</cot_ex>
           <cot_tot>'||to_char(vr_res_qtcotist_tot,'fm999g990')||'</cot_tot>
           <cot_at_fis>'||to_char(vr_typ_tab_total(1).res_qtcotist_ati,'fm999g990')||'</cot_at_fis>
           <cot_in_fis>'||to_char(vr_typ_tab_total(1).res_qtcotist_dem,'fm999g990')||'</cot_in_fis>
           <cot_ex_fis>'||to_char(vr_typ_tab_total(1).res_qtcotist_exc,'fm999g990')||'</cot_ex_fis>
           <cot_tot_fis>'||to_char(vr_typ_tab_total(1).res_qtcotist_tot,'fm999g990')||'</cot_tot_fis>
           <cot_at_jur>'||to_char(vr_typ_tab_total(2).res_qtcotist_ati,'fm999g990')||'</cot_at_jur>
           <cot_in_jur>'||to_char(vr_typ_tab_total(2).res_qtcotist_dem,'fm999g990')||'</cot_in_jur>
           <cot_ex_jur>'||to_char(vr_typ_tab_total(2).res_qtcotist_exc,'fm999g990')||'</cot_ex_jur>
           <cot_tot_jur>'||to_char(vr_typ_tab_total(2).res_qtcotist_tot,'fm999g990')||'</cot_tot_jur>
           <mat_at>'||to_char(vr_dup_qtcotist_ati,'fm999g990')||'</mat_at>
           <mat_in>'||to_char(vr_dup_qtcotist_dem,'fm999g990')||'</mat_in>
           <mat_ex>'||to_char(vr_dup_qtcotist_exc,'fm999g990')||'</mat_ex>
           <mat_tot>'||to_char(vr_dup_qtcotist_tot,'fm999g990')||'</mat_tot>
           <mat_at_fis>'||to_char(vr_typ_tab_total(1).dup_qtcotist_ati,'fm999g990')||'</mat_at_fis>
           <mat_in_fis>'||to_char(vr_typ_tab_total(1).dup_qtcotist_dem,'fm999g990')||'</mat_in_fis>
           <mat_ex_fis>'||to_char(vr_typ_tab_total(1).dup_qtcotist_exc,'fm999g990')||'</mat_ex_fis>
           <mat_tot_fis>'||to_char(vr_dup_qtcottot_fis,'fm999g990')||'</mat_tot_fis>
           <mat_at_jur>'||to_char(vr_typ_tab_total(2).dup_qtcotist_ati,'fm999g990')||'</mat_at_jur>
           <mat_in_jur>'||to_char(vr_typ_tab_total(2).dup_qtcotist_dem,'fm999g990')||'</mat_in_jur>
           <mat_ex_jur>'||to_char(vr_typ_tab_total(2).dup_qtcotist_exc,'fm999g990')||'</mat_ex_jur>
           <mat_tot_jur>'||to_char(vr_dup_qtcottot_jur,'fm999g990')||'</mat_tot_jur>
        </tot1>');

        -- Montar tag com total capital ativo e inativo para arquivo XML
        pc_escreve_xml('
        <tot2>
           <assoc_mes_ant_at>'||to_char(vr_res_qtassati,'fm999g990')||'</assoc_mes_ant_at>
           <assoc_mes_ant_in>'||to_char(vr_res_qtassdem,'fm999g990')||'</assoc_mes_ant_in>
           <adm_mes_at>'||to_char(vr_res_qtassmes,'fm999g990')||'</adm_mes_at>
           <assoc_transf_at>'||to_char(vr_res_qtdemmes_ati,'fm999g990')||'</assoc_transf_at>
           <assoc_transf_in>'||to_char(vr_res_qtdemmes_dem,'fm999g990')||'</assoc_transf_in>
           <assoc_exc_in>'||to_char(vr_res_qtassbai,'fm999g990')||'</assoc_exc_in>
           <assoc_read_at>'||to_char(vr_res_qtdesmes_ati,'fm999g990')||'</assoc_read_at>
           <assoc_read_in>'||to_char(vr_res_qtdesmes_dem,'fm999g990')||'</assoc_read_in>
           <assoc_final_at>'||to_char(vr_tot_qtassati,'fm999g990')||'</assoc_final_at>
           <assoc_final_in>'||to_char(vr_tot_qtassdem,'fm999g990')||'</assoc_final_in>
        </tot2>');

        -- Finalizar agrupador de totais e inicia de agencias
        pc_escreve_xml('</totais><agencias>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP

           -- Se existir cotistas para a agencia
           IF vr_tab_age_qtcotist_ati.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_age_qtcotist_dem.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_age_qtassmes_adm.EXISTS(rw_crapage.cdagenci) THEN

              -- Verificar se tem todas as informacoes nulas
              IF vr_tab_age_qtcotist_ati(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_age_qtcotist_dem(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_age_qtassmes_adm(rw_crapage.cdagenci) <> 0 THEN

                 -- Montar tag da conta para arquivo XML
                 pc_escreve_xml('
                 <agencia>
                    <dsagenci>'||LPad(rw_crapage.cdagenci,3,'0')||' - '||rw_crapage.nmresage||'</dsagenci>
                    <ati>'||vr_tab_age_qtcotist_ati(rw_crapage.cdagenci)||'</ati>
                    <ina>'||vr_tab_age_qtcotist_dem(rw_crapage.cdagenci)||'</ina>
                    <adm>'||vr_tab_age_qtassmes_adm(rw_crapage.cdagenci)||'</adm>
                 </agencia>');
              END IF;
           END IF;

        END LOOP;

        -- Finalizar agrupador agencias e iniciar o de pacs
        pc_escreve_xml('</agencias><pacs tot_lancamen="'||To_Char(vr_tot_lancamen,'fm999g990')||
                       '" tot_vllanmto="'||To_Char(vr_tot_vllanmto,'fm999g999g990d00')||'">');

        -- Processar tabela de memoria de debitos
        vr_des_chave:= vr_tab_debitos.FIRST;
        -- Enquanto o registro nao for nulo
        WHILE vr_des_chave IS NOT NULL LOOP
           -- Montar tag da conta para arquivo XML
           pc_escreve_xml('
           <pac>
              <cdagenci>'||vr_tab_debitos(vr_des_chave).cdagenci||'</cdagenci>
              <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_debitos(vr_des_chave).nrdconta))||'</nrdconta>
              <nmprimtl><![CDATA['||vr_tab_debitos(vr_des_chave).nmprimtl||']]></nmprimtl>
              <dtadmiss>'||To_Char(vr_tab_debitos(vr_des_chave).dtadmiss,'DD/MM/YYYY')||'</dtadmiss>
              <dtrefere>'||To_Char(vr_tab_debitos(vr_des_chave).dtrefere,'DD/MM/YYYY')||'</dtrefere>
              <vllanmto>'||to_char(vr_tab_debitos(vr_des_chave).vllanmto,'fm999g999g990d00')||'</vllanmto>
              <tplanmto>'||vr_tab_debitos(vr_des_chave).tplanmto||'</tplanmto>
           </pac>');
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_debitos.NEXT(vr_des_chave);
        END LOOP;

        -- Finalizar agrupador recadastro e relatorio
        pc_escreve_xml('</pacs></crrl031>');

        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl031'          --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl031.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 4                   --> Número de cópias
                                   ,pr_flg_gerar => 'N'                 --> gerar PDF
                                   ,pr_des_erro  => vr_des_erro);       --> Saída com erro
        -- Testar se houve erro
        IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_saida;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

     EXCEPTION
        WHEN vr_exc_saida THEN
           pr_des_erro:= vr_des_erro;
        WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório pc_crps010_2. '||sqlerrm;
     END;


     -- Geração do relatório 421
     PROCEDURE pc_crps010_3 (pr_des_erro OUT VARCHAR2) IS
     /* ..........................................................................
     Programa: pc_crps010_3                        Antigo: Fontes/crps010_3.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Evandro
     Data    : Maio/2005.                          Ultima atualizacao: 21/02/2013

     Dados referentes ao programa:

     Frequencia: Mensal.
     Objetivo  : Gerar relatorio 421.

     Alteracoes: 20/06/2005 - Alterado para mostrar no relatorio a quantidade de
                              contas duplicadas (Diego).

                 04/07/2005 - Imprimir o relatorio 421 em duplex (Edson).

                 27/07/2005 - Alterado glb_nrcopias para 2 (Diego).

                 12/08/2005 - Gerar um arquivo detalhado, com as contas de cada
                              motivo, para Leticia - VIACREDI (Evandro).

                 20/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).

                 14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 18/03/2008 - Alterado envio de email para BO b1wgen0011
                              (Sidnei - Precise)

                 21/02/2013 - Alterado o format do label "Quantidade" e do
                              label "Total de saidas de socios do Pac"
                              (Daniele).

                 18/03/2013 - Migração Progress -> Oracle - Alisson (AMcom)

     ............................................................................. */

        -- Cursores desse relatorio

        -- Selecionar as informacoes da agencia
        CURSOR cr_crapage2 (pr_cdcooper IN crapage.cdcooper%TYPE
                           ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
           SELECT crapage.cdagenci
                 ,crapage.nmresage
             FROM crapage crapage
            WHERE crapage.cdcooper = pr_cdcooper
              AND crapage.cdagenci = pr_cdagenci;
        rw_crapage2 cr_crapage2%ROWTYPE;

        -- Variaveis de Controle
        vr_cdmotdem     NUMBER;
        vr_rel_qtmotdem NUMBER;
        vr_rel_qtdempac NUMBER;
        vr_rel_qttotdup NUMBER;
        vr_dsmotdem     VARCHAR2(100);
        vr_rel_nmmesref VARCHAR2(20);

        -- Variaveis de Email
        vr_email_dest VARCHAR2(400);

        -- Variavel de Arquivo Texto
        vr_input_file utl_file.file_type;
        vr_nmarqtxt   VARCHAR2(100):= 'crrl421.txt';

        -- Variavel de Exceção
        vr_exc_erro EXCEPTION;

     BEGIN
        -- Inicializar variavel de erro
        pr_des_erro:= NULL;
        -- Busca do diretório base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        /* Gerar arquivo com todos os PACs */

        -- Determinar o nome do arquivo que será gerado
        vr_nom_arquivo := 'crrl421';
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicializar variaveis de totalizador
        vr_rel_qtmotdem:= 0;
        vr_rel_qtdempac:= 0;
        vr_rel_qttotdup:= 0;
        -- Nome mes referencia recebe descricao do mes da data atual
        vr_rel_nmmesref:= GENE0001.vr_vet_nmmesano(To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')))
                          ||'/'||To_Char(rw_crapdat.dtmvtolt,'YYYY');

        -- Inicilizar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl421>'||
                       '<motivos ref="'||vr_rel_nmmesref||'">');

        -- Tenta abrir o arquivo de dados em modo gravacao
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                ,pr_des_erro => vr_des_erro);  --> Erro

        IF vr_des_erro IS NOT NULL THEN
           -- Levantar Excecao
           RAISE vr_exc_saida;
        END IF;

        -- Escrever o cabecalho no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file             --> Handle do arquivo aberto
                                      ,pr_des_text  => 'PA;MOTIVO;CONTA/DV');  --> Texto para escrita

        -- Processar tabela de memoria de demitidos
        vr_des_chave:= vr_tab_demitidos.FIRST;
        -- Enquanto o registro nao for nulo
        WHILE vr_des_chave IS NOT NULL LOOP
           -- Atribuir o codigo do motivo
           vr_cdmotdem:= vr_tab_demitidos(vr_des_chave).cdmotdem;

           -- Se estivermos processando o primeiro registro do vetor ou mudou a AGENCIA
           IF vr_des_chave = vr_tab_demitidos.FIRST OR
              vr_tab_demitidos(vr_des_chave).cdagenci <> vr_tab_demitidos(vr_tab_demitidos.PRIOR(vr_des_chave)).cdagenci THEN
              -- Selecionar informacoes das agencias
              OPEN cr_crapage2 (pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => vr_tab_demitidos(vr_des_chave).cdagenci);
              -- Posicionar no proximo registro
              FETCH cr_crapage2 INTO rw_crapage2;
              -- Se nao encontrar
              IF cr_crapage2%NOTFOUND THEN
                 rw_crapage2.cdagenci:= vr_tab_demitidos(vr_des_chave).cdagenci;
                 rw_crapage2.nmresage:= 'NAO ENCONTRADA';
              END IF;
              --Fechar Cursor
              CLOSE cr_crapage2;
           END IF;

           -- Se estivermos processando o primeiro registro do vetor ou mudou o MOTIVO ou Agencia
           IF vr_des_chave = vr_tab_demitidos.FIRST OR
              vr_tab_demitidos(vr_des_chave).cdmotdem <> vr_tab_demitidos(vr_tab_demitidos.PRIOR(vr_des_chave)).cdmotdem OR
              vr_tab_demitidos(vr_des_chave).cdagenci <> vr_tab_demitidos(vr_tab_demitidos.PRIOR(vr_des_chave)).cdagenci THEN
              -- Zerar a quantidade de demitidos no pac
              vr_rel_qtmotdem:= 0;
           END IF;

           -- Escrever os detalhes no arquivo de dados
           gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file             --> Handle do arquivo aberto
                                         ,pr_des_text  => vr_tab_demitidos(vr_des_chave).cdagenci||';'||
                                                          vr_tab_demitidos(vr_des_chave).cdmotdem||';'||
                                                          gene0002.fn_mask_conta(vr_tab_demitidos(vr_des_chave).nrdconta));  --> Texto para escrita

           -- Se for uma conta duplicada
           IF vr_tab_demitidos(vr_des_chave).inmatric = 2 THEN
              -- Acumular quantidade total duplicadas
              vr_rel_qttotdup:= Nvl(vr_rel_qttotdup,0) + 1;
           END IF;

           -- Acumular totais motivos demissao
           vr_rel_qtmotdem:= Nvl(vr_rel_qtmotdem,0) + 1;
           -- Acumular totais demitidos do pac
           vr_rel_qtdempac:= Nvl(vr_rel_qtdempac,0) + 1;

           -- Se este for o ultimo registro do vetor ou mudou MOTIVO ou Agencia
           IF vr_des_chave = vr_tab_demitidos.LAST OR
              vr_tab_demitidos(vr_des_chave).cdmotdem <> vr_tab_demitidos(vr_tab_demitidos.NEXT(vr_des_chave)).cdmotdem OR
              vr_tab_demitidos(vr_des_chave).cdagenci <> vr_tab_demitidos(vr_tab_demitidos.NEXT(vr_des_chave)).cdagenci THEN

              -- Verificar se existe o motivo da demissao
              IF vr_tab_craptab_motivo.EXISTS(vr_cdmotdem) THEN
                 -- Atribuir a descricao do motivo
                 vr_dsmotdem:= vr_tab_craptab_motivo(vr_cdmotdem);
              END IF;

              -- Acumular totais por motivo
              IF vr_tab_rel_qttotmot.EXISTS(vr_cdmotdem) THEN
                 vr_tab_rel_qttotmot(vr_cdmotdem):= vr_tab_rel_qttotmot(vr_cdmotdem) + Nvl(vr_rel_qtmotdem,0);
              ELSE
                 vr_tab_rel_qttotmot(vr_cdmotdem):= Nvl(vr_rel_qtmotdem,0);
              END IF;

              -- Escreve o total DO motivo no XML
              pc_escreve_xml('<motivo>
                             <cdagenci>'||rw_crapage2.cdagenci||'</cdagenci>
                             <nmresage>'||rw_crapage2.nmresage||'</nmresage>
                             <dsmotdem>'||vr_cdmotdem||' - '||vr_dsmotdem||'</dsmotdem>
                             <qtmotdem>'||vr_rel_qtmotdem||'</qtmotdem>
                             </motivo>');

              -- Zerar a quantidade de demitidos no pac
              vr_rel_qtmotdem:= 0;
           END IF;

           -- Se este for o ultimo registro do vetor, ou da AGENCIA
           IF vr_des_chave = vr_tab_demitidos.LAST OR vr_tab_demitidos(vr_des_chave).cdagenci <> vr_tab_demitidos(vr_tab_demitidos.NEXT(vr_des_chave)).cdagenci THEN
              -- Zerar a quantidade de demitidos no pac
              vr_rel_qtdempac:= 0;
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_demitidos.NEXT(vr_des_chave);
        END LOOP;

        -- Finalizar agrupador de agencias e Iniciar agrupador de totais por motivo
        pc_escreve_xml('</motivos><total_motivos ref="'||vr_rel_nmmesref||'"
                       dup="'||To_Char(nvl(vr_rel_qttotdup,0),'fm999g999g990')||'">');
        -- Percorrer todos os motivos
        FOR idx IN 1..vr_tab_rel_qttotmot.count() LOOP
           -- Verificar se existe o motivo da demissao
           IF vr_tab_craptab_motivo.EXISTS(idx) THEN
              -- Atribuir a descricao do motivo
              vr_dsmotdem:= vr_tab_craptab_motivo(idx);
           END IF;
           -- Montar tag da conta para arquivo XML
           pc_escreve_xml('<tot_motivo>
                           <tot_dsmotdem>'||idx||' - '||vr_dsmotdem||'</tot_dsmotdem>
                           <tot_qttotmot>'||vr_tab_rel_qttotmot(idx)||'</tot_qttotmot>
                           </tot_motivo>');
        END LOOP;

        -- Finalizar agrupador total motivos e criar total geral e duplicadas
        pc_escreve_xml('</total_motivos></crrl421>');

        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl421'          --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl421.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 80                 --> colunas
                                   ,pr_sqcabrel  => 4                  --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '80d'             --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 2                   --> Número de cópias
                                   ,pr_flg_gerar => 'N'                 --> gerar PDF
                                   ,pr_des_erro  => vr_des_erro);       --> Saída com erro

        -- Testar se houve erro
        IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_saida;
        END IF;
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

        -- Fechar Arquivo dados
        BEGIN
           gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        EXCEPTION
           WHEN OTHERS THEN
           -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
           vr_des_erro := 'Problema ao fechar o arquivo <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;
           RAISE vr_exc_saida;
        END;

        -- Enviar email se for viacredi
        IF pr_cdcooper = 1 THEN
           -- Recuperar emails de destino
           vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL421_DETALHADO');
           -- Verificar se nao existe email cadastrado
           IF vr_email_dest IS NULL THEN
              -- Montar mensagem de erro
              vr_des_erro:= 'Não foi encontrado destinatário para relatório 421.';
              -- Levantar Exceção
              RAISE vr_exc_saida;
           END IF;

          /* Envio do arquivo detalhado via e-mail */
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => vr_cdprogra
                                    ,pr_des_destino     => vr_email_dest
                                    ,pr_des_assunto     => 'RELATORIO 421 - DETALHADO'
                                    ,pr_des_corpo       => NULL
                                    ,pr_des_anexo       => vr_nom_direto||'/'||vr_nmarqtxt
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_des_erro);
          -- Se ocorreu algum erro
          IF vr_des_erro IS NOT NULL  THEN
             RAISE vr_exc_saida;
          END IF;
        END IF;

     EXCEPTION
       WHEN vr_exc_saida THEN
         pr_des_erro:= vr_des_erro;
       WHEN vr_exc_erro THEN
         pr_des_erro:= vr_des_erro;
       WHEN OTHERS THEN
         pr_des_erro:= 'Erro ao imprimir relatório pc_crps010_3. '||sqlerrm;
     END;


     -- Geração do relatório 426
     PROCEDURE pc_crps010_4 (pr_des_erro OUT VARCHAR2) IS

     /* ..........................................................................

     Programa: pc_crps010_4                      Antigo: Fontes/crps010_4.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Evandro
     Data    : Julho/2005.                       Ultima atualizacao: 03/12/2013

     Dados referentes ao programa:

     Frequencia: Mensal.
     Objetivo  : Gerar relatorio 426.

     Alteracoes: 20/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).

                 14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 19/03/2013 - Migração Progress -> Oracle - Alisson (AMcom)

                 13/09/2013 - Substituida impressao de telefones da ass pela tfc. (Reinert)

                 07/10/2013 - Nova forma de chamar as agências, de PAC agora
                              a escrita será PA (André Euzébio - Supero).

                 11/11/2013 - Remover flag de impressão (Marcos-Supero)

                 28/10/2013 - Alterado totalizador de 99 para 999. (Reinert)

                 04/11/2013 - Alterado find da craptfc pelo for first. (Reinert)

     ............................................................................ */
        -- Cursores da Rotina

        -- Selecionar informacoes das Cotas
        CURSOR cr_crapcot (pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
           SELECT  crapcot.vldcotas
             FROM crapcot crapcot
            WHERE crapcot.cdcooper = pr_cdcooper
              AND crapcot.nrdconta = pr_nrdconta;
        rw_crapcot cr_crapcot%ROWTYPE;

        -- Selecionar informacoes das Transferencias
        CURSOR cr_craptrf (pr_cdcooper IN craptrf.cdcooper%TYPE
                          ,pr_nrdconta IN craptrf.nrdconta%TYPE) IS
           SELECT  craptrf.nrdconta
             FROM craptrf craptrf
            WHERE craptrf.cdcooper = pr_cdcooper
              AND craptrf.nrsconta = pr_nrdconta;
        rw_craptrf cr_craptrf%ROWTYPE;

        CURSOR cr_craptfc (pr_cdcooper IN craptrf.cdcooper%TYPE
                          ,pr_nrdconta IN craptrf.nrdconta%TYPE
                          ,pr_tptelefo IN craptfc.tptelefo%TYPE) IS
           SELECT F.nrdddtfc,
                  F.nrtelefo,
                  F.tptelefo
             FROM craptfc f
            WHERE f.progress_recid = (SELECT min(f1.progress_recid)
                                        FROM craptfc f1
                                       WHERE F1.cdcooper = pr_cdcooper
                                         AND F1.nrdconta = pr_nrdconta
                                         AND F1.tptelefo = pr_tptelefo);
        rw_craptfc cr_craptfc%rowtype;

        -- Variaveis tipo registro para associado
        rw_crapass   crapass%ROWTYPE;
        rw_crabass   crapass%ROWTYPE;
        -- Variavel de Controle
        vr_cdcritic  INTEGER:= 0;
        -- Número do telefone do associado
        vr_nrfonres  VARCHAR2(20);
		-- Número do telefone do associado
        vr_nrfonemp  VARCHAR2(20);
        -- Variavel de Exceção
        vr_exc_erro  EXCEPTION;

     BEGIN
        -- Inicializar variavel de erro
        pr_des_erro:= NULL;
        -- Busca do diretório base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

       -- Processar todos os registros dos maiores depositantes
       vr_des_chave := vr_tab_duplicados.FIRST;
       --Enquanto o registro nao for nulo
       WHILE vr_des_chave IS NOT NULL LOOP

          -- Determinar o codigo da agencia
          vr_cdagenci:= vr_tab_duplicados(vr_des_chave).cdagenci;

          -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
          IF vr_des_chave = vr_tab_duplicados.FIRST OR vr_tab_duplicados(vr_des_chave).cdagenci <> vr_tab_duplicados(vr_tab_duplicados.PRIOR(vr_des_chave)).cdagenci THEN
             -- Nome base do arquivo é crrl426
             vr_nom_arquivo := 'crrl426_'||To_Char(vr_cdagenci,'fm009');

             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_des_xml, TRUE);
             dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
             -- Inicilizar as informações do XML com a agencia
             pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl426>'||
                            '<agencia cdagenci="'||vr_cdagenci||'"><contas>');
          END IF;

          /* Validar Informacoes */

          -- Inicializar codigo da critica
          vr_cdcritic:= 0;

          -- Selecionar informacoes do associado
          IF NOT vr_tab_crapass.EXISTS(vr_tab_duplicados(vr_des_chave).nrdconta) THEN
             -- Codigo da critica
             vr_cdcritic:= 9;
             rw_crapass.nrdconta:= vr_tab_duplicados(vr_des_chave).nrdconta;
          ELSE
             rw_crapass.nrdconta:= vr_tab_duplicados(vr_des_chave).nrdconta;
             rw_crapass.nmprimtl:= vr_tab_crapass(rw_crapass.nrdconta).nmprimtl;
             rw_crapass.nrmatric:= vr_tab_crapass(rw_crapass.nrdconta).nrmatric;
          END IF;

          -- Selecionar informacoes das cotas
          OPEN cr_crapcot (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
          -- Posicionar no proximo registro
          FETCH cr_crapcot INTO rw_crapcot;
          -- Se nao encontrar
          IF cr_crapcot%NOTFOUND THEN
             -- Codigo da critica
             vr_cdcritic:= 169;
          END IF;
          -- Fechar Cursor
          CLOSE cr_crapcot;

          -- Selecionar informacoes de Transferencia
          OPEN cr_craptrf (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
          -- Posicionar no proximo registro
          FETCH cr_craptrf INTO rw_craptrf;
          -- Se nao encontrar
          IF cr_craptrf%NOTFOUND THEN
             -- Codigo da critica
             vr_cdcritic:= 124;
          END IF;
          -- Fechar Cursor
          CLOSE cr_craptrf;

          -- Selecionar informacoes da Conta de Transferencia
          IF NOT vr_tab_crapass.EXISTS(rw_craptrf.nrdconta) THEN
             -- Codigo da critica
             vr_cdcritic:= 9;
             rw_crabass.nrdconta:= rw_craptrf.nrdconta;
          ELSE
             rw_crabass.nrdconta:= rw_craptrf.nrdconta;
             rw_crabass.nmprimtl:= vr_tab_crapass(rw_craptrf.nrdconta).nmprimtl;
             rw_crabass.nrmatric:= vr_tab_crapass(rw_craptrf.nrdconta).nrmatric;
          END IF;

          vr_nrfonres         := NULL;
          vr_nrfonemp := NULL;

          -- Buscar telefone do associado Residencial
          OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta
                         ,pr_tptelefo => 1); -- Residencial
          FETCH cr_craptfc
          INTO rw_craptfc;
          IF cr_craptfc%NOTFOUND THEN
             CLOSE cr_craptfc;
          ELSE
             vr_nrfonres := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
             CLOSE cr_craptfc;
          END IF;

          -- Buscar telefone do associado comercial
          OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta
                         ,pr_tptelefo => 3); -- Comercial
          FETCH cr_craptfc
          INTO rw_craptfc;
          IF cr_craptfc%NOTFOUND THEN
             CLOSE cr_craptfc;
          ELSE
             vr_nrfonemp := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
             CLOSE cr_craptfc;
          END IF;

          -- Verificar se o nome do titular é o mesmo
          IF rw_crapass.nmprimtl = rw_crabass.nmprimtl THEN
             -- Codigo da critica
             vr_cdcritic:= 123;
          END IF;

          -- Se não tiver erro
          IF vr_cdcritic = 0 THEN
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
                   ('<conta>
                        <nrdconta>'||LTrim(gene0002.fn_mask_conta(rw_crapass.nrdconta))||'</nrdconta>
                        <nmprimtl><![CDATA['||substr(rw_crapass.nmprimtl,1,21)||']]></nmprimtl>
                        <nrfonres>'||vr_nrfonres||'</nrfonres>
                        <nrfonemp>'||vr_nrfonemp||'</nrfonemp>
                        <vldcotas>'||To_Char(rw_crapcot.vldcotas,'fm999g999g990d00')||'</vldcotas>
                        <nrmatric>'||LTrim(gene0002.fn_mask_matric(rw_crabass.nrmatric))||'</nrmatric>
                        <nrdconta_trf>'||LTrim(gene0002.fn_mask_conta(rw_craptrf.nrdconta))||'</nrdconta_trf>
                        <nmprimtl_ori><![CDATA['||substr(rw_crabass.nmprimtl,1,19)||']]></nmprimtl_ori>
                     </conta>');
          END IF;

          -- Se este for o ultimo registro do vetor, ou da agência
          IF vr_des_chave = vr_tab_duplicados.LAST OR vr_tab_duplicados(vr_des_chave).cdagenci <> vr_tab_duplicados(vr_tab_duplicados.NEXT(vr_des_chave)).cdagenci THEN

             -- Finalizar o agrupador de contas, agencia e do relatorio
             pc_escreve_xml('</contas></agencia></crrl426>');

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                        ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                        ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                        ,pr_dsxmlnode => '/crrl426/agencia/contas/conta' --> Nó base do XML para leitura dos dados
                                        ,pr_dsjasper  => 'crrl426.jasper'    --> Arquivo de layout do iReport
                                        ,pr_dsparams  => NULL                --> Sem parametros
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                        ,pr_qtcoluna  => 132                 --> 132 colunas
                                        ,pr_sqcabrel  => 5                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                        ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                        ,pr_flg_gerar => 'N'                 --> gerar PDF
                                        ,pr_des_erro  => vr_des_erro);       --> Saída com erro

             -- Testar se houve erro
             IF vr_des_erro IS NOT NULL THEN
                -- Gerar exceção
                RAISE vr_exc_saida;
             END IF;
             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_des_xml);
             dbms_lob.freetemporary(vr_des_xml);

          END IF;

          -- Buscar o próximo registro da tabela
          vr_des_chave := vr_tab_duplicados.NEXT(vr_des_chave);

       END LOOP;

     EXCEPTION
       WHEN vr_exc_saida THEN
         pr_des_erro:= vr_des_erro;
       WHEN vr_exc_erro THEN
         pr_des_erro:= vr_des_erro;
       WHEN OTHERS THEN
         pr_des_erro:= 'Erro ao imprimir relatório pc_crps010_4. '||sqlerrm;
     END;


     -- Geracao do relatorio 398
     PROCEDURE pc_imprime_crrl398 (pr_des_erro OUT VARCHAR2) IS

        /* Cursores internos da procedure */

        -- Selecionar informacoes dos saldos
        CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
           SELECT crapsld.nrdconta
                 ,crapsld.vlsddisp
             FROM crapsld
            WHERE crapsld.cdcooper = pr_cdcooper
              AND crapsld.vlsddisp < 0;

        -- Variaveis Locais
        vr_limite       NUMBER:= 0;
        vr_limite_conta NUMBER:= 0;
        vr_totgeral     NUMBER:= 0;

        -- Variavel de Exceção
        vr_exc_erro EXCEPTION;

     BEGIN
        -- Inicializar variavel de erro
        pr_des_erro:= NULL;
        -- Busca do diretório base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        -- Determinar o nome do arquivo que será gerado
        vr_nom_arquivo := 'crrl398';
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl398><linhas>');
        -- Processar todos os registros das linhas de credito
        vr_cod_chave := vr_tab_totlcred.FIRST;
        -- Enquanto o registro nao for nulo
        WHILE vr_cod_chave IS NOT NULL LOOP
           -- Selecionar informacoes da linha de credito
           OPEN cr_craplcr (pr_cdcooper => pr_cdcooper
                           ,pr_cdlcremp => vr_cod_chave);
           -- Posicionar no proximo registro
           FETCH cr_craplcr INTO rw_craplcr;
           -- Fechar Cursor
           CLOSE cr_craplcr;

           -- Escrever informacoes da linha de credito no arquivo XML
           pc_escreve_xml('<linha>
                              <cdlcremp>'||rw_craplcr.cdlcremp||'</cdlcremp>
                              <dslcremp>'||rw_craplcr.dslcremp||'</dslcremp>
                              <vllcredi>'||To_Char(vr_tab_totlcred(vr_cod_chave),'fm999g999g990d00')||'</vllcredi>
                           </linha>');

           -- Acumular o limite no total geral
           vr_totgeral:= Nvl(vr_totgeral,0) + Nvl(vr_tab_totlcred(vr_cod_chave),0);
           -- Buscar o próximo registro da tabela
           vr_cod_chave := vr_tab_totlcred.NEXT(vr_cod_chave);
        END LOOP;
        -- Finalizar a tag de linhas e iniciar de saldos
        pc_escreve_xml('</linhas><saldos>');

        /*-- Cheque especial --*/

        -- Zerar Valor do limite
        vr_limite:= 0;
        --Processar todos os saldos dos associados
        FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP
           -- Zerar valor saldo devedor
           vr_vlsdeved:= 0;
           -- Zerar valor limite conta
           vr_limite_conta:= 0;
           -- Verificar o limite do associado
           IF vr_tab_craplim.EXISTS(rw_crapsld.nrdconta) THEN
              -- Acumular limite da conta
              vr_limite_conta:= vr_tab_craplim(rw_crapsld.nrdconta);
           END IF;
           -- Saldo devedor recebe o saldo da conta multiplicado por -1
           vr_vlsdeved:= rw_crapsld.vlsddisp * -1;
           -- Se o saldo devedor maior limite da conta
           IF vr_vlsdeved > vr_limite_conta THEN
              --Diminuir o limite da conta do saldo devedor
               vr_vlsdeved:= vr_vlsdeved - vr_limite_conta;
           ELSE
              -- Zerar saldo devedor
              vr_vlsdeved:= 0;
           END IF;
           -- Acumular o valor do limite
           vr_limite:= vr_limite + vr_vlsdeved;
        END LOOP; --rw_crapsld

        -- Total geral recebe limite + desconto + titulos
        vr_totgeral:= Nvl(vr_totgeral,0) + Nvl(vr_limite,0)   +
                      Nvl(vr_desconto,0) + Nvl(vr_desctitu,0);
        -- Escrever informacoes dos saldos no arquivo XML
        pc_escreve_xml('<limite>'  ||To_Char(vr_limite,  'fm999g999g990d00')||'</limite>
                          <desconto>'||To_Char(vr_desconto,'fm999g999g990d00')||'</desconto>
                          <desctitu>'||To_Char(vr_desctitu,'fm999g999g990d00')||'</desctitu>
                          <total>'   ||To_Char(vr_totgeral,'fm999g999g999g990d00')||'</total></saldos></crrl398>');

        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl398/linhas/linha' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl398.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 80                  --> colunas
                                   ,pr_sqcabrel  => 3                   --> Sequencia do Relatorio
                                   ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_flg_gerar => 'N'                 --> gerar PDF
                                   ,pr_des_erro  => vr_des_erro);       --> Saída com erro

        -- Testar se houve erro
        IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
            RAISE vr_exc_saida;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

     EXCEPTION
       WHEN vr_exc_erro THEN
         pr_des_erro:= vr_des_erro;
       WHEN OTHERS THEN
         pr_des_erro:= 'Erro ao imprimir relatório crrl398. '||sqlerrm;
     END;


     -- Geração do relatório de resumo geral
     PROCEDURE pc_imprime_crrl014_total (pr_des_erro OUT VARCHAR2) IS

        /* Cursores Locais */

        CURSOR cr_crapvia (pr_cdcooper IN crapvia.cdcooper%TYPE
                          ,pr_cdrelato IN crapvia.cdrelato%TYPE
                          ,pr_cdagenci IN crapvia.cdagenci%TYPE) IS
           SELECT crapvia.nrcopias
             FROM crapvia crapvia
            WHERE crapvia.cdcooper = pr_cdcooper
              AND crapvia.cdrelato = pr_cdrelato
              AND crapvia.cdagenci = pr_cdagenci;
        rw_crapvia cr_crapvia%ROWTYPE;

        /* Variaveis Locais */
        vr_nmformul VARCHAR2(10); -- Nome do formulário para impressão
        vr_nrcopias INTEGER;      -- Quantidade de Copias
        -- Variavel de Exceção
        vr_exc_erro EXCEPTION;

     BEGIN
        -- Inicializar variavel de erro
        pr_des_erro:= NULL;
        -- Busca do diretório base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        /* Gerar arquivo com todos os PACs */

        -- Determinar o nome do arquivo que será gerado
        vr_nom_arquivo := 'crrl014_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl014_tot'||
                       ' mes1="'||vr_rel_nomemes1||
                       '" mes2="'||vr_rel_nomemes2||
                       '" mes3="'||vr_rel_nomemes3||'"><planos>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP

           -- Se existir associados e planos para a agencia
           IF vr_tab_tot_nrdplaag.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_vlprepla.EXISTS(rw_crapage.cdagenci) THEN

              --Verificar se tem informacao senao pula
              IF vr_tab_tot_nrdplaag(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_vlprepla(rw_crapage.cdagenci) <> 0 THEN

                 --Montar tag da conta para arquivo XML
                 pc_escreve_xml('<p1>
                                    <p_nmresage>'||rw_crapage.nmresage||'</p_nmresage>
                                    <p_assoc>'||vr_tab_tot_nrdplaag(rw_crapage.cdagenci)||'</p_assoc>
                                    <p_capital>'||nvl(vr_tab_tot_vlprepla(rw_crapage.cdagenci),0)||'</p_capital>
                                 </p1>');
              END IF;
           END IF;

        END LOOP;

        -- Finalizar agrupador de planos e iniciar parte2
        pc_escreve_xml('</planos><saldos>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
           -- Se existir associados e planos para a agencia
           IF vr_tab_tot_nrassmag.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_vlsmtrag.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_vlsmmes1.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_vlsmmes2.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_vlsmmes3.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_vlcaptal.EXISTS(rw_crapage.cdagenci) THEN

              -- Verificar se tem informacao senao pula
              IF vr_tab_tot_nrassmag(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_vlsmtrag(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_vlsmmes1(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_vlsmmes2(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_vlsmmes3(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_vlcaptal(rw_crapage.cdagenci) <> 0 THEN

                 -- Montar tag da conta para arquivo XML
                 pc_escreve_xml('<s1>
                                    <s_nmresage>'||rw_crapage.nmresage||'</s_nmresage>
                                    <s_assoc>'||vr_tab_tot_nrassmag(rw_crapage.cdagenci)||'</s_assoc>
                                    <s_media>'||to_char(vr_tab_tot_vlsmtrag(rw_crapage.cdagenci),'fm999g999g990d00')||'</s_media>
                                    <s_mes1>'||to_char(vr_tab_tot_vlsmmes1(rw_crapage.cdagenci),'fm999g999g990d00')||'</s_mes1>
                                    <s_mes2>'||to_char(vr_tab_tot_vlsmmes2(rw_crapage.cdagenci),'fm999g999g990d00')||'</s_mes2>
                                    <s_mes3>'||to_char(vr_tab_tot_vlsmmes3(rw_crapage.cdagenci),'fm999g999g990d00')||'</s_mes3>
                                    <s_cap>'||to_char(vr_tab_tot_vlcaptal(rw_crapage.cdagenci),'fm999g999g990d00')||'</s_cap>
                                 </s1>');
              END IF;
           END IF;
        END LOOP;

        -- Finalizar agrupador de planos e iniciar de abertura
        pc_escreve_xml('</saldos><emprestimos>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
           -- Se existir associados e planos para a agencia
           IF vr_tab_tot_qtassemp.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_qtassemp(rw_crapage.cdagenci) <> 0 THEN

              -- Montar tag da conta para arquivo XML
              pc_escreve_xml('<e1>
                                 <e_nmresage>'||rw_crapage.nmresage||'</e_nmresage>
                                 <e_assoc>'||vr_tab_tot_qtassemp(rw_crapage.cdagenci)||'</e_assoc>
                                 <e_contrato>'||vr_tab_tot_qtctremp(rw_crapage.cdagenci)||'</e_contrato>
                                 <e_juros>'||to_char(vr_tab_tot_vljurmes(rw_crapage.cdagenci),'fm999g999g990d00')||'</e_juros>
                                 <e_prestacao>'||to_char(vr_tab_tot_vlpreemp(rw_crapage.cdagenci),'fm999g999g990d00')||'</e_prestacao>
                                 <e_saldo>'||to_char(vr_tab_tot_vlsdeved(rw_crapage.cdagenci),'fm999g999g990d00')||'</e_saldo>
                              </e1>');
           END IF;
        END LOOP;

        -- Finalizar tab emprestimos e iniciar agrupador recadastro
        pc_escreve_xml('</emprestimos><recadastros>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP

           -- Se existir associados e planos para a agencia
           IF vr_tab_tot_qtjrecad.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_qtnrecad.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_qtadmiss.EXISTS(rw_crapage.cdagenci) THEN

              -- Verificar se tem informacao senao pula
              IF vr_tab_tot_qtjrecad(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_qtnrecad(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_qtadmiss(rw_crapage.cdagenci) <> 0 THEN

                 -- Montar tag da conta para arquivo XML
                 pc_escreve_xml('<r1>
                                    <r_nmresage>'||rw_crapage.nmresage||'</r_nmresage>
                                    <r_feito>'||vr_tab_tot_qtjrecad(rw_crapage.cdagenci)||'</r_feito>
                                    <r_afazer>'||to_char(vr_tab_tot_qtnrecad(rw_crapage.cdagenci),'fm999g999g999g999')||'</r_afazer>
                                    <r_adm>'||to_char(vr_tab_tot_qtadmiss(rw_crapage.cdagenci),'fm999g999g999g999')||'</r_adm>
                                 </r1>');
              END IF;
           END IF;
        END LOOP;

        -- Finalizar agrupador recadastro e relatorio
        pc_escreve_xml('</recadastros></crrl014_tot>');

        -- Selecionar informacoes da Quantidade de vias por PAC
        OPEN cr_crapvia (pr_cdcooper => pr_cdcooper
                        ,pr_cdrelato => 14
                        ,pr_cdagenci => 999);
        -- Posicionar no proximo registro
        FETCH cr_crapvia INTO rw_crapvia;
        -- Se nao encontrar
        IF cr_crapvia%NOTFOUND THEN
           -- Nome do formulário para impressão recebe NULL
           vr_nmformul:= NULL;
           -- Qdade copiar recebe 1
           vr_nrcopias:= 1;
        ELSE
           -- Nome do formulário para impressão recebe 132dm
           vr_nmformul:= '132dm';
           -- Qdade copiar recebe qdade encontrada
           vr_nrcopias:= rw_crapvia.nrcopias;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapvia;

        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl014_tot'       --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl014_total.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => vr_nmformul         --> Nome do formulário para impressão
                                   ,pr_nrcopias  => vr_nrcopias         --> Número de cópias
                                   ,pr_flg_gerar => 'N'                 --> gerar PDF
                                   ,pr_des_erro  => vr_des_erro);       --> Saída com erro

        -- Testar se houve erro
        IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_saida;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

     EXCEPTION
       WHEN vr_exc_erro THEN
         pr_des_erro:= vr_des_erro;
       WHEN OTHERS THEN
         pr_des_erro:= 'Erro ao imprimir relatório crrl014_total. '||sqlerrm;
     END;


     -- Geracao de arquivo AAMMDD_CAPITAL.txt
     PROCEDURE pc_gera_arq_capital (pr_des_erro OUT VARCHAR2) IS

        -- Variavel
        vr_nmarqtxt   VARCHAR2(100);
        vr_setlinha   VARCHAR2(4000);
        vr_typ_saida  VARCHAR2(4000);

        -- Diretório micros
        vr_dir_micros VARCHAR2(100);
        vr_dscomand   VARCHAR2(1000);


        -- Total geral de capital subscrito por PF e PJ
        vr_tot_capfis NUMBER := 0;
        vr_tot_capjur NUMBER := 0;

        -- Variavel de Exceção
        vr_exc_erro EXCEPTION;

     BEGIN

        -- Arquivo gerado somente no processo mensal
        IF TRUNC(rw_crapdat.dtmvtopr,'MM') <> TRUNC(rw_crapdat.dtmvtolt,'MM') THEN

           -- Verificar forma de buscar os valores de procap por tipo de pessoa e agencia
           -- Valor Total recebe Valor Total Subscrito - total dos valores ativos(PROCAP)
           vr_tot_capfis := vr_tot_capagefis;
           vr_tot_capjur := vr_tot_capagejur;

           -- Busca o caminho padrao do arquivo no unix + /integra
           vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'contab');

           -- Determinar o nome do arquivo baseado no ano, mes e dia da data movimento
           vr_nmarqtxt:=  TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_CAPITAL.txt';

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

           -- Se o valor total é maior que zero
           IF NVL(vr_tot_capfis,0) > 0 THEN

             /*** Montando as informacoes de PESSOA FISICA ***/
             -- Montando o cabecalho das contas do dia atual
             vr_setlinha := '70'||                                                                                   --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                             --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                             --> Data DDMMAA
                            gene0002.fn_mask(6112, pr_dsforma => '9999')||','||                                      --> Conta Origem
                            gene0002.fn_mask(6135, pr_dsforma => '9999')||','||                                      --> Conta Destino
                            TRIM(TO_CHAR(vr_tot_capfis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                      --> Fixo
                            '"COTAS CAPITAL COOPERADOS PESSOA FISICA"';                                              --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapage_fis.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapage_fis.FIRST()..vr_tab_vlcapage_fis.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapage_fis.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapage_fis(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

             -- Montando o cabecalho para fazer a reversao das
             -- conta para estornar os valores caso necessario
             vr_setlinha := '70'||                                                                                  --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                            --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                            --> Data DDMMAA
                            gene0002.fn_mask(6135, pr_dsforma => '9999')||','||                                     --> Conta Destino
                            gene0002.fn_mask(6112, pr_dsforma => '9999')||','||                                     --> Conta Origem
                            TRIM(TO_CHAR(vr_tot_capfis,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Valor Total
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                     --> Fixo
                            '"'||vr_dsprefix||'COTAS CAPITAL COOPERADOS PESSOA FISICA"';                                             --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapage_fis.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapage_fis.FIRST()..vr_tab_vlcapage_fis.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapage_fis.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapage_fis(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
           END IF; -- Se maior que zero

           -- Se o valor total é maior que zero
           IF NVL(vr_tot_capjur,0) > 0 THEN

             /*** Montando as informacoes de PESSOA JURIDICA ***/
             -- Montando o cabecalho das contas do dia atual
             vr_setlinha := '70'||                                                                                   --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                             --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                             --> Data DDMMAA
                            gene0002.fn_mask(6112, pr_dsforma => '9999')||','||                                      --> Conta Origem
                            gene0002.fn_mask(6136, pr_dsforma => '9999')||','||                                      --> Conta Destino
                            TRIM(TO_CHAR(vr_tot_capjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                      --> Fixo
                            '"COTAS CAPITAL COOPERADOS PESSOA JURIDICA"';                                            --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapage_jur.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapage_jur.FIRST()..vr_tab_vlcapage_jur.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapage_jur.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapage_jur(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

             -- Montando o cabecalho para fazer a reversao das
             -- conta para estornar os valores caso necessario
             vr_setlinha := '70'||                                                                                   --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                             --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                             --> Data DDMMAA
                            gene0002.fn_mask(6136, pr_dsforma => '9999')||','||                                      --> Conta Destino
                            gene0002.fn_mask(6112, pr_dsforma => '9999')||','||                                      --> Conta Origem
                            TRIM(TO_CHAR(vr_tot_capjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                      --> Fixo
                           '"'||vr_dsprefix||'COTAS CAPITAL COOPERADOS PESSOA JURIDICA"';                                             --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapage_jur.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapage_jur.FIRST()..vr_tab_vlcapage_jur.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapage_jur.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapage_jur(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
           END IF; -- Se maior que zero

           -- Se o valor total é maior que zero
           IF NVL(vr_tot_vlcapctz_fis,0) > 0 THEN

             /*** Montando as informacoes de PESSOA FISICA ***/
             -- Montando o cabecalho das contas do dia atual
             vr_setlinha := '70'||                                                                                         --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                   --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                   --> Data DDMMAA
                            gene0002.fn_mask(6139, pr_dsforma => '9999')||','||                                            --> Conta Origem
                            gene0002.fn_mask(6122, pr_dsforma => '9999')||','||                                            --> Conta Destino
                            TRIM(TO_CHAR(vr_tot_vlcapctz_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                            --> Fixo
                            '"COTAS CAPITAL A INTEGRALIZAR DE COOPERADOS PESSOA FISICA"';                                  --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapctz_fis.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapctz_fis.FIRST()..vr_tab_vlcapctz_fis.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapctz_fis.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapctz_fis(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapctz_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

             -- Montando o cabecalho para fazer a reversao das
             -- conta para estornar os valores caso necessario
             vr_setlinha := '70'||                                                                                        --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                  --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                  --> Data DDMMAA
                            gene0002.fn_mask(6122, pr_dsforma => '9999')||','||                                           --> Conta Destino
                            gene0002.fn_mask(6139, pr_dsforma => '9999')||','||                                           --> Conta Origem
                            TRIM(TO_CHAR(vr_tot_vlcapctz_fis,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Valor Total
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                           --> Fixo
                            '"'||vr_dsprefix||'COTAS CAPITAL A INTEGRALIZAR DE COOPERADOS PESSOA FISICA"';                                 --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapctz_fis.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapctz_fis.FIRST()..vr_tab_vlcapctz_fis.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapctz_fis.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapctz_fis(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapctz_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
           END IF; -- Se maior que zero

           -- Se o valor total é maior que zero
           IF NVL(vr_tot_vlcapctz_jur,0) > 0 THEN

             /*** Montando as informacoes de PESSOA JURIDICA ***/
             -- Montando o cabecalho das contas do dia atual
             vr_setlinha := '70'||                                                                                         --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                   --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                   --> Data DDMMAA
                            gene0002.fn_mask(6140, pr_dsforma => '9999')||','||                                            --> Conta Origem
                            gene0002.fn_mask(6122, pr_dsforma => '9999')||','||                                            --> Conta Destino
                            TRIM(TO_CHAR(vr_tot_vlcapctz_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                            --> Fixo
                            '"COTAS CAPITAL A INTEGRALIZAR DE COOPERADOS PESSOA JURIDICA"';                                --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapctz_jur.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapctz_jur.FIRST()..vr_tab_vlcapctz_jur.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapctz_jur.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapctz_jur(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapctz_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

             -- Montando o cabecalho para fazer a reversao das
             -- conta para estornar os valores caso necessario
             vr_setlinha := '70'||                                                                                         --> Informacao inicial
                            TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                   --> Data AAMMDD do Arquivo
                            TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                   --> Data DDMMAA
                            gene0002.fn_mask(6122, pr_dsforma => '9999')||','||                                            --> Conta Destino
                            gene0002.fn_mask(6140, pr_dsforma => '9999')||','||                                            --> Conta Origem
                            TRIM(TO_CHAR(vr_tot_vlcapctz_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                            gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                            --> Fixo
                           '"'||vr_dsprefix||'COTAS CAPITAL A INTEGRALIZAR DE COOPERADOS PESSOA JURIDICA"';                                 --> Descricao

             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             -- Verifica se existe valores
             IF vr_tab_vlcapctz_jur.COUNT > 0 THEN
               -- Repetir os valores para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tab_vlcapctz_jur.FIRST()..vr_tab_vlcapctz_jur.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tab_vlcapctz_jur.EXISTS(vr_idx_agencia) THEN
                     -- Se o valor é maior que zero
                     IF vr_tab_vlcapctz_jur(vr_idx_agencia) > 0 THEN
                       -- Montar linha para gravar no arquivo
                       vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlcapctz_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
           END IF; -- Se maior que zero

           -- Se o valor total é maior que zero
           IF NVL(vr_tot_pcapcred_fis,0) > 0 THEN

              /*** Montando as informacoes de PESSOA FISICA ***/
              -- Montando o cabecalho das contas do dia atual
              vr_setlinha := '70'||                                                                                         --> Informacao inicial
                             TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                   --> Data AAMMDD do Arquivo
                             TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                   --> Data DDMMAA
                             gene0002.fn_mask(6114, pr_dsforma => '9999')||','||                                            --> Conta Destino
                             gene0002.fn_mask(6137, pr_dsforma => '9999')||','||                                            --> Conta Origem
                             TRIM(TO_CHAR(vr_tot_pcapcred_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                             gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                            --> Fixo
                             '"COTAS PROCAPCRED COOPERADOS PESSOA FISICA"';                                                 --> Descricao

              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto para escrita

              -- Verifica se existe valores
              IF vr_tab_tot_pcap_fis.COUNT > 0 THEN
                -- Repetir os valores para cada conta, ou seja, duplicado
                FOR repete IN 1..2 LOOP
                  -- Gravas as informacoes de valores por agencia
                  FOR vr_idx_agencia IN vr_tab_tot_pcap_fis.FIRST()..vr_tab_tot_pcap_fis.LAST() LOOP
                    -- Verifica se existe a informacao
                    IF vr_tab_tot_pcap_fis.EXISTS(vr_idx_agencia) THEN
                      -- Se o valor é maior que zero
                      IF vr_tab_tot_pcap_fis(vr_idx_agencia) > 0 THEN
                        -- Montar linha para gravar no arquivo
                        vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_pcap_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

              -- Montando o cabecalho para fazer a reversao das
              -- conta para estornar os valores caso necessario
              vr_setlinha := '70'||                                                                                         --> Informacao inicial
                             TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                   --> Data AAMMDD do Arquivo
                             TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                   --> Data DDMMAA
                             gene0002.fn_mask(6137, pr_dsforma => '9999')||','||                                            --> Conta Destino
                             gene0002.fn_mask(6114, pr_dsforma => '9999')||','||                                            --> Conta Origem
                             TRIM(TO_CHAR(vr_tot_pcapcred_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                             gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                            --> Fixo
                             '"'||vr_dsprefix||'COTAS PROCAPCRED COOPERADOS PESSOA FISICA"';                                --> Descricao

              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto para escrita

              -- Verifica se existe valores
              IF vr_tab_tot_pcap_fis.COUNT > 0 THEN
                -- Repetir os valores para cada conta, ou seja, duplicado
                FOR repete IN 1..2 LOOP
                  -- Gravas as informacoes de valores por agencia
                  FOR vr_idx_agencia IN vr_tab_tot_pcap_fis.FIRST()..vr_tab_tot_pcap_fis.LAST() LOOP
                    -- Verifica se existe a informacao
                    IF vr_tab_tot_pcap_fis.EXISTS(vr_idx_agencia) THEN
                      -- Se o valor é maior que zero
                      IF vr_tab_tot_pcap_fis(vr_idx_agencia) > 0 THEN
                        -- Montar linha para gravar no arquivo
                        vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_pcap_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

           END IF;


           -- Se o valor total é maior que zero
           IF NVL(vr_tot_pcapcred_jur,0) > 0 THEN

              /*** Montando as informacoes de PESSOA JURIDICA ***/
              -- Montando o cabecalho das contas do dia atual
              vr_setlinha := '70'||                                                                                         --> Informacao inicial
                             TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                   --> Data AAMMDD do Arquivo
                             TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                   --> Data DDMMAA
                             gene0002.fn_mask(6114, pr_dsforma => '9999')||','||                                            --> Conta Destino
                             gene0002.fn_mask(6138, pr_dsforma => '9999')||','||                                            --> Conta Origem
                             TRIM(TO_CHAR(vr_tot_pcapcred_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                             gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                            --> Fixo
                             '"COTAS PROCAPCRED COOPERADOS PESSOA JURIDICA"';                                               --> Descricao

              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto para escrita

              -- Verifica se existe valores
              IF vr_tab_tot_pcap_jur.COUNT > 0 THEN
                -- Repetir os valores para cada conta, ou seja, duplicado
                FOR repete IN 1..2 LOOP
                  -- Gravas as informacoes de valores por agencia
                  FOR vr_idx_agencia IN vr_tab_tot_pcap_jur.FIRST()..vr_tab_tot_pcap_jur.LAST() LOOP
                    -- Verifica se existe a informacao
                    IF vr_tab_tot_pcap_jur.EXISTS(vr_idx_agencia) THEN
                      -- Se o valor é maior que zero
                      IF vr_tab_tot_pcap_jur(vr_idx_agencia) > 0 THEN
                        -- Montar linha para gravar no arquivo
                        vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_pcap_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

              -- Montando o cabecalho para fazer a reversao das
              -- conta para estornar os valores caso necessario
              vr_setlinha := '70'||                                                                                         --> Informacao inicial
                             TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                   --> Data AAMMDD do Arquivo
                             TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                   --> Data DDMMAA
                             gene0002.fn_mask(6138, pr_dsforma => '9999')||','||                                            --> Conta Destino
                             gene0002.fn_mask(6114, pr_dsforma => '9999')||','||                                            --> Conta Origem
                             TRIM(TO_CHAR(vr_tot_pcapcred_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                             gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                            --> Fixo
                             '"'||vr_dsprefix||'COTAS PROCAPCRED COOPERADOS PESSOA JURIDICA"';                              --> Descricao

              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto para escrita

              -- Verifica se existe valores
              IF vr_tab_tot_pcap_jur.COUNT > 0 THEN
                -- Repetir os valores para cada conta, ou seja, duplicado
                FOR repete IN 1..2 LOOP
                  -- Gravas as informacoes de valores por agencia
                  FOR vr_idx_agencia IN vr_tab_tot_pcap_jur.FIRST()..vr_tab_tot_pcap_jur.LAST() LOOP
                    -- Verifica se existe a informacao
                    IF vr_tab_tot_pcap_jur.EXISTS(vr_idx_agencia) THEN
                      -- Se o valor é maior que zero
                      IF vr_tab_tot_pcap_jur(vr_idx_agencia) > 0 THEN
                        -- Montar linha para gravar no arquivo
                        vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_tot_pcap_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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

           END IF;

           -- Fechar Arquivo
           BEGIN
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
           EXCEPTION
              WHEN OTHERS THEN
                 -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
                 vr_des_erro := 'Problema ao fechar o arquivo <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;
                 RAISE vr_exc_erro;
           END;

          -- Busca o diretório para contabilidade
          vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
          vr_dircon := vr_dircon || vc_dircon;
          vr_arqcon:=  TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CAPITAL.txt';          

          -- Executa comando UNIX para converter arq para Dos
           vr_dscomand := 'ux2dos '||vr_nom_direto||'/'||vr_nmarqtxt||' > '||
                                    vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

           -- Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_dscomand
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_des_erro);
           IF vr_typ_saida = 'ERR' THEN
             RAISE vr_exc_erro;
           END IF;

        END IF; -- Fim do IF de validacao Mensal

     EXCEPTION
        WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
        WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao gerar arquivo AAMMDD_CAPITAL.txt para contabilidade. '||SQLERRM;
     END;

   ---------------------------------------
   -- Inicio Bloco Principal pc_crps010
   ---------------------------------------

   BEGIN
      -- Atribuir o nome do programa que está executando
      vr_cdprogra:= 'CRPS010';

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS010'
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
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE btch0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
         CLOSE btch0001.cr_crapdat;

         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdcritic => vr_cdcritic);

      -- Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
         -- Sair do programa
         RAISE vr_exc_saida;
      END IF;

      -- Zerar tabelas de memoria auxiliar
      pc_limpa_tabela;

      -- Carregar tabela de memoria de titulares da conta
      FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                   ,pr_idseqttl => 1) LOOP
         -- Montar o indice para o vetor de telefone
         vr_index_crapttl:= LPad(rw_crapttl.cdcooper,10,'0')||
                            LPad(rw_crapttl.nrdconta,10,'0');
         vr_tab_crapttl(vr_index_crapttl).cdempres:=  rw_crapttl.cdempres;
         vr_tab_crapttl(vr_index_crapttl).cdturnos:=  rw_crapttl.cdturnos;
      END LOOP;

      -- Carregar tabela de memoria de informacoes dos borderos de desconto de titulos
      FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                  ,pr_dtpagto  => rw_crapdat.dtmvtolt) LOOP
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).cdbandoc := rw_craptdb.cdbandoc;
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrdctabb := rw_craptdb.nrdctabb;
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrcnvcob := rw_craptdb.nrcnvcob;
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrdconta := rw_craptdb.nrdconta;
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrdocmto := rw_craptdb.nrdocmto;
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).vltitulo := rw_craptdb.vltitulo;
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).insittit := rw_craptdb.insittit;
         vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).vr_rowid := rw_craptdb.rowid;
      END LOOP;

      -- Carregar tabela de memoria de informacoes de cotas
      FOR rw_crapcot IN cr_crapcot (pr_cdcooper => pr_cdcooper) LOOP
         -- Quantidade de cotas em moeda fixa
         vr_tab_crapcot(rw_crapcot.nrdconta).qtcotmfx:= rw_crapcot.qtcotmfx;
         -- Correcao monetária a incorporar nas cotas
         vr_tab_crapcot(rw_crapcot.nrdconta).vlcmicot:= rw_crapcot.vlcmicot;
         -- Correcao monetaria do mes sobre a cota
         vr_tab_crapcot(rw_crapcot.nrdconta).vlcmmcot:= rw_crapcot.vlcmmcot;
         -- Valor das Cotas
         vr_tab_crapcot(rw_crapcot.nrdconta).vldcotas:= rw_crapcot.vldcotas;
         -- Quantidade de prestacoes pagas
         vr_tab_crapcot(rw_crapcot.nrdconta).qtprpgpl:= rw_crapcot.qtprpgpl;
      END LOOP;

      -- Carregar tabela de memoria do plano de contas
      FOR rw_crappla IN cr_crappla (pr_cdcooper => pr_cdcooper) LOOP
         -- Se a conta ja existir na tabela ignora
         IF NOT vr_tab_crappla.EXISTS(rw_crappla.nrdconta) THEN
            vr_tab_crappla(rw_crappla.nrdconta):= rw_crappla.vlprepla;
         END IF;
      END LOOP;

      -- Carregar tabela de memoria de historico alteracoes crapass
      FOR rw_crapalt IN cr_crapalt (pr_cdcooper => pr_cdcooper) LOOP
         -- Se a conta ja existir na tabela ignora
         vr_tab_crapalt(rw_crapalt.nrdconta):= 0;
      END LOOP;

      -- Carregar tabela de memoria de lancamentos de emprestimos
      FOR rw_craplem IN cr_craplem (pr_cdcooper => pr_cdcooper) LOOP
         -- Montar indice para tabela memoria
         vr_index_craplem:= LPad(rw_craplem.nrdconta,10,'0')||LPad(rw_craplem.nrctremp,10,'0');
         vr_tab_craplem(vr_index_craplem).vllanmto:= rw_craplem.vllanmto;
         vr_tab_craplem(vr_index_craplem).dtmvtolt:= rw_craplem.dtmvtolt;
      END LOOP;

      -- Carregar tabela de memoria de historico alteracoes crapass
      FOR rw_crawepr IN cr_crawepr (pr_cdcooper => pr_cdcooper) LOOP
         -- Montar indice para tabela memoria
         vr_index_crawepr:= LPad(rw_crawepr.nrdconta,10,'0')||LPad(rw_crawepr.nrctremp,10,'0');
         vr_tab_crawepr(vr_index_crawepr):= rw_crawepr.dsnivcal;
      END LOOP;

      -- Carregar tabela de memoria de nivel de risco
      FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                   ,pr_nmsistem => 'CRED'
                                   ,pr_tptabela => 'GENERI'
                                   ,pr_cdempres => 0
                                   ,pr_cdacesso => 'PROVISAOCL') LOOP
         -- Atribuir valor da provisao para a tabela de memoria
         vr_tab_craptab(rw_craptab.dsnivcal).vl_provisao:= rw_craptab.vl_provisao;
         -- Atribuir valor do nivel de risco para a tabela de memoria
         vr_tab_craptab(rw_craptab.dsnivcal).vl_nivelrisco:= rw_craptab.vl_nivelrisco;
      END LOOP;

      -- Carregar tabela de memoria com motivos de demissao
      FOR rw_craptab IN cr_craptab_motivo (pr_cdcooper => pr_cdcooper
                                          ,pr_nmsistem => 'CRED'
                                          ,pr_tptabela => 'GENERI'
                                          ,pr_cdempres => 0
                                          ,pr_cdacesso => 'MOTIVODEMI') LOOP
         -- Atribuir valor da provisao para a tabela de memoria
         vr_tab_craptab_motivo(rw_craptab.tpregist):= rw_craptab.dstextab;
      END LOOP;

      -- Carregar tabela de memoria com limites dos associados
      FOR rw_craplim IN cr_craplim (pr_cdcooper => pr_cdcooper) LOOP
         -- Atribuir valor do limite para a tabela de memoria
         vr_tab_craplim(rw_craplim.nrdconta):= rw_craplim.vllimite;
      END LOOP;

      -- Carregar tabela de memoria de cadastro de borderos
      FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => pr_cdcooper
                                   ,pr_dtlibera => rw_crapdat.dtmvtolt
                                   ,pr_insitchq => 2) LOOP
         -- Atribuir valor para a tabela de memnoriaAcumular valor desconto
         vr_tab_crapcdb(rw_crapcdb.nrdconta):= Nvl(rw_crapcdb.vlcheque,0);
      END LOOP;

      -- Carregar tabela de memoria de saldos dos associados
      FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsmstre##1:= rw_crapsld.vlsmstre##1;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsmstre##2:= rw_crapsld.vlsmstre##2;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsmstre##3:= rw_crapsld.vlsmstre##3;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsmstre##4:= rw_crapsld.vlsmstre##4;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsmstre##5:= rw_crapsld.vlsmstre##5;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsmstre##6:= rw_crapsld.vlsmstre##6;
      END LOOP;

      -- Carregar tabela de memoria de subscricao de capital
      FOR rw_crapsdc IN cr_crapsdc_existe (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapsdc(rw_crapsdc.nrdconta):= 0;
      END LOOP;

      -- Carregar tabela de memoria de associados
      FOR rw_crapass IN cr_crapass_carga (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
         vr_tab_crapass(rw_crapass.nrdconta).nrfonres:= NULL;
         vr_tab_crapass(rw_crapass.nrdconta).nrmatric:= rw_crapass.nrmatric;
      END LOOP;

      -- Carregar Historicos de Credito
      FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craphis(rw_craphis.cdhistor):= 0;
      END LOOP;

      -- Buscar as informacoes do procap
      PCAP0001.pc_busca_procap_ativos(pr_cdcooper => pr_cdcooper
                                     ,pr_totativo => vr_totativo
                                     ,pr_vlativos => vr_vlativos
                                     ,pr_tab_craplct => vr_tab_craplct
                                     ,pr_typ_tab_ativos => vr_typ_tab_ativos
                                     ,pr_dscritic =>  vr_dscritic);

      -- Se ocorrer algum erro aborta a geração
      IF vr_dscritic IS NOT NULL THEN
         -- Envio do log de erro
         RAISE vr_exc_saida;
      END IF;

      -- Inicializando registro de memoria para carregar
      -- as informa de PF e PJ
      FOR idx IN 1..2 LOOP
         vr_typ_tab_total(idx).dup_qtcotist_ati := 0;
         vr_typ_tab_total(idx).dup_qtcotist_dem := 0;
         vr_typ_tab_total(idx).dup_qtcotist_exc := 0;
         vr_typ_tab_total(idx).dup_qtcotist_ati := 0;
         vr_typ_tab_total(idx).dup_qtcotist_dem := 0;
         vr_typ_tab_total(idx).dup_qtcotist_exc := 0;
         vr_typ_tab_total(idx).res_vlcapcrz_ati := 0;
         vr_typ_tab_total(idx).res_vlcapcrz_dem := 0;
         vr_typ_tab_total(idx).res_vlcapcrz_exc := 0;
         vr_typ_tab_total(idx).res_vlcapcrz_tot := 0;
         vr_typ_tab_total(idx).sub_vlcapcrz_ati := 0;
         vr_typ_tab_total(idx).sub_vlcapcrz_dem := 0;
         vr_typ_tab_total(idx).sub_vlcapcrz_exc := 0;
         vr_typ_tab_total(idx).sub_vlcapcrz_tot := 0;
         vr_typ_tab_total(idx).res_qtcotist_ati := 0;
         vr_typ_tab_total(idx).res_qtcotist_dem := 0;
         vr_typ_tab_total(idx).res_qtcotist_exc := 0;
         vr_typ_tab_total(idx).res_qtcotist_tot := 0;
      END LOOP;



      -- Determinar a data do movimento voltando 2 meses e pegando o dia 1 desse mes
      vr_dtmvtolt:= Trunc(Add_Months(rw_crapdat.dtmvtolt,-2),'MM');

      -- Busca do diretório base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      /*  Monta nome dos meses no qual se referem as medias  */
      pc_crps010_1(pr_cdcooper         => pr_cdcooper
                  ,pr_cdprogra         => 'PC_'||vr_cdprogra
                  ,pr_dtmvtolt         => rw_crapdat.dtmvtolt
                  ,pr_rel_nomemes1     => vr_rel_nomemes1
                  ,pr_rel_nomemes2     => vr_rel_nomemes2
                  ,pr_rel_nomemes3     => vr_rel_nomemes3
                  ,pr_res_qtassati     => vr_res_qtassati
                  ,pr_res_qtassdem     => vr_res_qtassdem
                  ,pr_res_qtassmes     => vr_res_qtassmes
                  ,pr_res_qtdemmes_ati => vr_res_qtdemmes_ati
                  ,pr_res_qtdemmes_dem => vr_res_qtdemmes_dem
                  ,pr_res_qtassbai     => vr_res_qtassbai
                  ,pr_res_qtdesmes_ati => vr_res_qtdesmes_ati
                  ,pr_res_qtdesmes_dem => vr_res_qtdesmes_dem
                  ,pr_res_vlcapcrz_exc => vr_res_vlcapcrz_exc
                  ,pr_res_vlcapexc_fis => vr_typ_tab_total(1).res_vlcapcrz_exc
                  ,pr_res_vlcapexc_jur => vr_typ_tab_total(2).res_vlcapcrz_exc
                  ,pr_res_vlcmicot_exc => vr_res_vlcmicot_exc
                  ,pr_res_vlcmmcot_exc => vr_res_vlcmmcot_exc
                  ,pr_res_vlcapmfx_exc => vr_res_vlcapmfx_exc
                  ,pr_res_qtcotist_exc => vr_res_qtcotist_exc
                  ,pr_res_qtcotexc_fis => vr_typ_tab_total(1).res_qtcotist_exc
                  ,pr_res_qtcotexc_jur => vr_typ_tab_total(2).res_qtcotist_exc
                  ,pr_res_vlcapcrz_tot => vr_res_vlcapcrz_tot
                  ,pr_res_vlcaptot_fis => vr_typ_tab_total(1).res_vlcapcrz_tot
                  ,pr_res_vlcaptot_jur => vr_typ_tab_total(2).res_vlcapcrz_tot
                  ,pr_res_vlcmicot_tot => vr_res_vlcmicot_tot
                  ,pr_res_vlcmmcot_tot => vr_res_vlcmmcot_tot
                  ,pr_res_vlcapmfx_tot => vr_res_vlcapmfx_tot
                  ,pr_res_qtcotist_tot => vr_res_qtcotist_tot
                  ,pr_res_qtcottot_fis => vr_typ_tab_total(1).res_qtcotist_tot
                  ,pr_res_qtcottot_jur => vr_typ_tab_total(2).res_qtcotist_tot
                  ,pr_tot_qtassati     => vr_tot_qtassati
                  ,pr_tot_qtassdem     => vr_tot_qtassdem
                  ,pr_tot_qtassexc     => vr_tot_qtassexc
                  ,pr_tot_qtasexpf     => vr_tot_qtasexpf
                  ,pr_tot_qtasexpj     => vr_tot_qtasexpj
                  ,pr_cdcritic         => vr_cdcritic
                  ,pr_des_erro         => vr_des_erro);

      -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

      -- Se ocorreu erro
      IF vr_des_erro IS NOT NULL THEN
         --Sair do programa
         RAISE vr_exc_saida;
      END IF;

      -- Zerar variavel de desconto
      vr_desconto:= 0;
      -- Zerar variavel de desconto de titulos
      vr_desctitu:= 0;

      --Selecionar e percorrer todas as Agencias da Cooperativa
      FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP

         -- Atribuir codigo da agencia
         vr_cdagenci:= rw_crapage.cdagenci;
         -- Atribuir nome resumido da agencia
         vr_nmresage:= rw_crapage.nmresage;
         -- Atribuir codigo + nome para o relatorio
         vr_rel_dsagenci:= To_Char(rw_crapage.cdagenci,'fm999')||' - '||rw_crapage.nmresage;

         -- Inicializar totalizadores por agencia
         pc_inicializa_tabela (vr_cdagenci);

         -- Inicializa variavel primeiro associado da agencia
         vr_flgfirst:= TRUE;

         -- Zerar Código da empresa
         vr_cdempres:= 0;
         -- Atribuir false para clob criado
         vr_flgclob:= FALSE;

         -- Determinar o nome do arquivo para impressao
         vr_nom_arquivo:= 'crrl014_'||To_Char(vr_cdagenci,'fm009');

         -- Pesquisar todos os associados
         FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => vr_cdagenci) LOOP

            -- Bloco necessário para controle de loop
            BEGIN
               -- Se for pessoa fisica
               IF rw_crapass.inpessoa = 1 THEN

                  -- Montar indice para buscar titulares da conta
                  vr_index_crapttl:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapass.nrdconta,10,'0');
                  -- Selecionar informacoes dos titulares da conta

                  IF vr_tab_crapttl.EXISTS(vr_index_crapttl) THEN
                     -- Codigo da empresa recebe o codigo da empresa do titular da conta
                     vr_cdempres:= vr_tab_crapttl(vr_index_crapttl).cdempres;
                  ELSE
                     -- Codigo da empresa recebe zero
                     vr_cdempres:= 0;
                  END IF;
               ELSE
                  -- Selecionar informacoes dos titulares da conta
                  FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => rw_crapass.nrdconta) LOOP
                     -- Codigo da empresa recebe o codigo da empresa do titular da conta
                     vr_cdempres:= rw_crapjur.cdempres;
                  END LOOP;
               END IF;

               /* Se foi demitido no mes corrente */
               IF rw_crapass.dtdemiss  IS NOT NULL AND
                  To_Char(rw_crapass.dtdemiss,'YYYYMM') = To_Char(rw_crapdat.dtmvtolt,'YYYYMM') THEN

                  -- Determinar o indice para o novo registro
                  vr_index_demitidos:= LPad(rw_crapass.cdagenci,5,'0')||
                                       LPad(rw_crapass.cdmotdem,5,'0')||
                                       LPad(rw_crapass.nrdconta,10,'0');

                  --Gravar registro na tabela de memoria
                  vr_tab_demitidos(vr_index_demitidos).cdagenci:= rw_crapass.cdagenci;
                  vr_tab_demitidos(vr_index_demitidos).nrdconta:= rw_crapass.nrdconta;
                  vr_tab_demitidos(vr_index_demitidos).inmatric:= rw_crapass.inmatric;

                  /* Quem nao possui motivo recebe motivo = 1 na temp-table */
                  IF rw_crapass.cdmotdem = 0 THEN
                     vr_tab_demitidos(vr_index_demitidos).cdmotdem:= 1;
                  ELSE
                     vr_tab_demitidos(vr_index_demitidos).cdmotdem:= rw_crapass.cdmotdem;
                  END IF;
               END IF;

               /* se for uma conta duplicada e nao demitida */
               IF rw_crapass.inmatric = 2 AND rw_crapass.dtdemiss IS NULL THEN
                  -- Calcular a quantidade de meses e anos
                  CADA0001.pc_busca_idade (pr_dtnasctl => rw_crapass.dtnasctl
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_nrdeanos => vr_nrdeanos
                                          ,pr_nrdmeses => vr_nrdmeses
                                          ,pr_dsdidade => vr_dsdidade
                                          ,pr_des_erro => vr_des_erro);

                  -- Se ocorreu erro
                  IF vr_des_erro IS NOT NULL THEN
                     -- Levantar Excecao
                     RAISE vr_exc_saida;
                  END IF;

                  /* se tiver mais de 16 anos */
                  IF vr_nrdeanos > 16   THEN
                     -- Determinar o indice para o novo registro
                     vr_index_duplicados:= LPad(rw_crapass.cdagenci,5,'0')||LPad(rw_crapass.nrdconta,10,'0');
                     -- Incluir na tabela de duplicados
                     vr_tab_duplicados(vr_index_duplicados).cdagenci:= rw_crapass.cdagenci;
                     vr_tab_duplicados(vr_index_duplicados).nrdconta:= rw_crapass.nrdconta;
                  END IF;
               END IF;

               /* Admitidos do PAC no mes - Resumo Mensal do Capital */
               IF To_Char(rw_crapass.dtadmiss,'YYYYMM') = To_Char(rw_crapdat.dtmvtolt,'YYYYMM') THEN

                  -- Se ja existir a agencia no vetor
                  IF vr_tab_age_qtassmes_adm.EXISTS(rw_crapass.cdagenci) THEN
                     -- Incrementar contador
                     vr_tab_age_qtassmes_adm(rw_crapass.cdagenci):= vr_tab_age_qtassmes_adm(rw_crapass.cdagenci) + 1;
                  ELSE
                     -- Iniciar contador com 1
                     vr_tab_age_qtassmes_adm(rw_crapass.cdagenci):= 1;
                  END IF;
               END IF;

               -- Verificar se existe saldo para associado
               IF vr_tab_crapsld.EXISTS(rw_crapass.nrdconta) THEN
                  -- Atribuir valores do semestre para variaveis
                  rw_crapsld.vlsmstre##1:= vr_tab_crapsld(rw_crapass.nrdconta).vlsmstre##1;
                  rw_crapsld.vlsmstre##2:= vr_tab_crapsld(rw_crapass.nrdconta).vlsmstre##2;
                  rw_crapsld.vlsmstre##3:= vr_tab_crapsld(rw_crapass.nrdconta).vlsmstre##3;
                  rw_crapsld.vlsmstre##4:= vr_tab_crapsld(rw_crapass.nrdconta).vlsmstre##4;
                  rw_crapsld.vlsmstre##5:= vr_tab_crapsld(rw_crapass.nrdconta).vlsmstre##5;
                  rw_crapsld.vlsmstre##6:= vr_tab_crapsld(rw_crapass.nrdconta).vlsmstre##6;
               ELSE
                  -- Montar mensagem de critica
                  vr_cdcritic:= 10;
                  vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  -- Levantar Excecao
                  RAISE vr_exc_saida;
               END IF;

               -- Verificar o mes atual para acumular valor semestre
               CASE To_Number(To_Char(rw_crapdat.dtmvtolt,'MM'))
                  WHEN 1 THEN
                     --Atribuir valores encontrados
                     vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##1;
                     vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##6;
                     vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##5;
                  WHEN 2 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##2;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##1;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##6;
                  WHEN 3 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##3;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##2;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##1;
                  WHEN 4 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##4;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##3;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##2;
                  WHEN 5 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##5;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##4;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##3;
                  WHEN 6 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##6;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##5;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##4;
                  WHEN 7 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##1;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##6;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##5;
                  WHEN 8 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##2;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##1;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##6;
                  WHEN 9 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##3;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##2;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##1;
                  WHEN 10 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##4;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##3;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##2;
                  WHEN 11 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##5;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##4;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##3;
                  WHEN 12 THEN
                    --Atribuir valores encontrados
                    vr_rel_vlsmmes1:= rw_crapsld.vlsmstre##6;
                    vr_rel_vlsmmes2:= rw_crapsld.vlsmstre##5;
                    vr_rel_vlsmmes3:= rw_crapsld.vlsmstre##4;
               END CASE;

               -- Descricao dac recebe situacao conta + tipo conta
               vr_rel_dsdacstp:= To_Char(rw_crapass.cdsitdct,'fm9') ||To_Char(rw_crapass.cdtipcta,'fm09');
               -- Valor da media do semestre recebe mes1 + mes2 + mes3 / 3
               vr_rel_vlsmtrag:= (Nvl(vr_rel_vlsmmes1,0) + Nvl(vr_rel_vlsmmes2,0) + Nvl(vr_rel_vlsmmes3,0)) / 3;

               -- Se o tipo de limite for Capital
               IF rw_crapass.tplimcre = 1 THEN
                  vr_rel_dslimcre:= 'CP';
                  -- Se o tipo de limite for Saldo Medio
               ELSIF rw_crapass.tplimcre = 2 THEN
                  vr_rel_dslimcre:= 'SM';
               ELSE
                  -- Limite Recebe null
                  vr_rel_dslimcre:= NULL;
               END IF;

               -- Atribuir false para flag nova pagina
               vr_flgnvpag:= FALSE;

               -- Verificar se a tabela já contem a agencia
               IF vr_tab_tot_nrassmag.EXISTS(rw_crapass.cdagenci) THEN
                  --Incrementar total assinantes da agencia
                  vr_tab_tot_nrassmag(rw_crapass.cdagenci):= vr_tab_tot_nrassmag(rw_crapass.cdagenci) + 1;
                  --Acumular total do semestre com o valor calculado
                  vr_tab_tot_vlsmtrag(rw_crapass.cdagenci):= vr_tab_tot_vlsmtrag(rw_crapass.cdagenci) + Nvl(vr_rel_vlsmtrag,0);
                  --Acumular total do mes 1
                  vr_tab_tot_vlsmmes1(rw_crapass.cdagenci):= vr_tab_tot_vlsmmes1(rw_crapass.cdagenci) + Nvl(vr_rel_vlsmmes1,0);
                  --Acumular total do mes 2
                  vr_tab_tot_vlsmmes2(rw_crapass.cdagenci):= vr_tab_tot_vlsmmes2(rw_crapass.cdagenci) + Nvl(vr_rel_vlsmmes2,0);
                  --Acumular total do mes 3
                  vr_tab_tot_vlsmmes3(rw_crapass.cdagenci):= vr_tab_tot_vlsmmes3(rw_crapass.cdagenci) + Nvl(vr_rel_vlsmmes3,0);
               ELSE
                  vr_tab_tot_nrassmag(rw_crapass.cdagenci):= 1;
                  --Acumular total do semestre com o valor calculado
                  vr_tab_tot_vlsmtrag(rw_crapass.cdagenci):= Nvl(vr_rel_vlsmtrag,0);
                  --Acumular total do mes 1
                  vr_tab_tot_vlsmmes1(rw_crapass.cdagenci):= Nvl(vr_rel_vlsmmes1,0);
                  --Acumular total do mes 2
                  vr_tab_tot_vlsmmes2(rw_crapass.cdagenci):= Nvl(vr_rel_vlsmmes2,0);
                  --Acumular total do mes 3
                  vr_tab_tot_vlsmmes3(rw_crapass.cdagenci):= Nvl(vr_rel_vlsmmes3,0);
               END IF;

               /*  Le registro de cotas  */
               IF NOT vr_tab_crapcot.EXISTS(rw_crapass.nrdconta) THEN
                  -- Montar mensagem de critica
                  vr_cdcritic:= 169;
                  vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  -- Levantar Exceção
                  RAISE vr_exc_saida;
               ELSE
                  --Valor do capital recebe valor das cotas
                  vr_rel_vlcaptal:= vr_tab_crapcot(rw_crapass.nrdconta).vldcotas;
                  --Quantidade de parcelas pagas recebe parcelas pagas das cotas
                  vr_rel_qtprpgpl:= vr_tab_crapcot(rw_crapass.nrdconta).qtprpgpl;
                  --Acumular valor total capital da agencia
                  IF vr_tab_tot_vlcaptal.EXISTS(rw_crapass.cdagenci) THEN
                    vr_tab_tot_vlcaptal(rw_crapass.cdagenci):= vr_tab_tot_vlcaptal(rw_crapass.cdagenci) + Nvl(vr_rel_vlcaptal,0);
                  ELSE
                    vr_tab_tot_vlcaptal(rw_crapass.cdagenci):= Nvl(vr_rel_vlcaptal,0);
                  END IF;
               END IF;

               /* Acumula dados para o resumo mensal do capital */

               -- Se a data de demissao estiver nula
               IF rw_crapass.dtdemiss IS NULL THEN
                  -- Incrementar Valor capital ativo com o valor do capital
                  vr_res_vlcapcrz_ati:= Nvl(vr_res_vlcapcrz_ati,0) + Nvl(vr_rel_vlcaptal,0);
                  -- Incrementar Valor capital ativo com o valor do capital por PF e PJ
                  vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_ati := vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_ati  + Nvl(vr_rel_vlcaptal,0);
                  -- Incrementar Valor capital moeda fixa com o qdade cotas
                  vr_res_vlcapmfx_ati:= Nvl(vr_res_vlcapmfx_ati,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).qtcotmfx,0);
                  -- Incrementar Valor correcao monetaria a incorporar com o valor da correcao a incorporar das cotas
                  vr_res_vlcmicot_ati:= Nvl(vr_res_vlcmicot_ati,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmicot,0);
                  -- Incrementar Valor correcao monetaria mes com o valor da correcao mes das cotas
                  vr_res_vlcmmcot_ati:= Nvl(vr_res_vlcmmcot_ati,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmmcot,0);

                  -- Se a matricula for original
                  IF rw_crapass.inmatric = 1 THEN
                     -- Incrementa Quantidade cotistas ativos
                     vr_res_qtcotist_ati:= Nvl(vr_res_qtcotist_ati,0) + 1;
                     -- Incrementa Quantidade cotistas ativos por PF e PJ
                     vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_ati := vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_ati + 1;
                     -- Incrementa a quantidade de cotistas ativos da agencia
                     IF vr_tab_age_qtcotist_ati.EXISTS(rw_crapass.cdagenci) THEN
                       vr_tab_age_qtcotist_ati(rw_crapass.cdagenci):= vr_tab_age_qtcotist_ati(rw_crapass.cdagenci)+1;
                     ELSE
                       vr_tab_age_qtcotist_ati(rw_crapass.cdagenci):= 1;
                     END IF;
                  ELSE
                     -- Incrementar quantidade cotistas ativos duplicados
                     vr_dup_qtcotist_ati:= Nvl(vr_dup_qtcotist_ati,0) + 1;
                     -- Incrementar quantidade cotistas ativos duplicados separdados por PF e PJ
                     vr_typ_tab_total(rw_crapass.inpessoa).dup_qtcotist_ati := vr_typ_tab_total(rw_crapass.inpessoa).dup_qtcotist_ati + 1;
                  END IF;
               ELSIF rw_crapass.dtelimin IS NULL THEN  --Data de eliminacao for nula
                  -- Incrementar Valor capital demitido com o valor do capital
                  vr_res_vlcapcrz_dem:= Nvl(vr_res_vlcapcrz_dem,0) + Nvl(vr_rel_vlcaptal,0);
                  -- Incrementar Valor capital demitido com o valor do capital por PF e PJ
                  vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_dem := vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_dem +  Nvl(vr_rel_vlcaptal,0);
                  -- Incrementar Valor capital moeda fixa com o qdade cotas
                  vr_res_vlcapmfx_dem:= Nvl(vr_res_vlcapmfx_dem,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).qtcotmfx,0);
                  -- Incrementar Valor correcao monetaria a incorporar com o valor da correcao a incorporar das cotas
                  vr_res_vlcmicot_dem:= Nvl(vr_res_vlcmicot_dem,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmicot,0);
                  -- Incrementar Valor correcao monetaria mes com o valor da correcao mes das cotas
                  vr_res_vlcmmcot_dem:= Nvl(vr_res_vlcmmcot_dem,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmmcot,0);

                  -- Se a matricula for original
                  IF rw_crapass.inmatric = 1 THEN
                     -- Incrementa Quantidade cotistas demitidos
                     vr_res_qtcotist_dem:= Nvl(vr_res_qtcotist_dem,0) + 1;
                     -- Incrementa Quantidade cotistas demitidos por PF e PJ
                     vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_dem := vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_dem + 1;
                     -- Incrementa a quantidade de cotistas demitidos da agencia
                     IF vr_tab_age_qtcotist_dem.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_age_qtcotist_dem(rw_crapass.cdagenci):= vr_tab_age_qtcotist_dem(rw_crapass.cdagenci)+1;
                     ELSE
                        vr_tab_age_qtcotist_dem(rw_crapass.cdagenci):= 1;
                     END IF;
                  ELSE
                     -- Incrementar quantidade cotistas demitidos duplicados
                     vr_dup_qtcotist_dem:= Nvl(vr_dup_qtcotist_dem,0) + 1;
                     -- Incrementar quantidade cotistas demitidos duplicados separados por PF e PJ
                     vr_typ_tab_total(rw_crapass.inpessoa).dup_qtcotist_dem := vr_typ_tab_total(rw_crapass.inpessoa).dup_qtcotist_dem + 1;
                  END IF;
               ELSE
                  -- Incrementar Valor capital excluido com o valor do capital
                  vr_res_vlcapcrz_exc:= Nvl(vr_res_vlcapcrz_exc,0) + Nvl(vr_rel_vlcaptal,0);
                  -- Incrementar Valor capital excluido com o valor do capital por PF e PJ
                  vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_exc := vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_exc + Nvl(vr_rel_vlcaptal,0);
                  -- Incrementar Valor capital moeda fixa com o qdade cotas
                  vr_res_vlcapmfx_exc:= Nvl(vr_res_vlcapmfx_exc,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).qtcotmfx,0);
                  -- Incrementar Valor correcao monetaria a incorporar com o valor da correcao a incorporar das cotas
                  vr_res_vlcmicot_exc:= Nvl(vr_res_vlcmicot_exc,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmicot,0);
                  -- Incrementar Valor correcao monetaria mes com o valor da correcao mes das cotas
                  vr_res_vlcmmcot_exc:= Nvl(vr_res_vlcmmcot_exc,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmmcot,0);

                  -- Se a matricula for original
                  IF rw_crapass.inmatric = 1 THEN
                     -- Incrementa Quantidade cotistas demitidos
                     vr_res_qtcotist_exc:= Nvl(vr_res_qtcotist_exc,0) + 1;
                     -- Incrementa Quantidade cotistas demitidos por PF e PJ
                     vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_exc := vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_exc + 1;
                     -- Incrementa a quantidade de cotistas demitidos da agencia

                     IF vr_tab_age_qtcotist_exc.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_age_qtcotist_exc(rw_crapass.cdagenci):= vr_tab_age_qtcotist_exc(rw_crapass.cdagenci)+1;
                     ELSE
                        vr_tab_age_qtcotist_exc(rw_crapass.cdagenci):= 1;
                     END IF;
                  ELSE
                     -- Incrementar quantidade cotistas excluidos duplicados
                     vr_dup_qtcotist_exc:= Nvl(vr_dup_qtcotist_exc,0) + 1;
                     -- Incrementar quantidade cotistas excluidos duplicados separados por PF e PJ
                     vr_typ_tab_total(rw_crapass.inpessoa).dup_qtcotist_exc := vr_typ_tab_total(rw_crapass.inpessoa).dup_qtcotist_exc + 1;
                  END IF;
               END IF;

               -- Acumular valor do capital total
               vr_res_vlcapcrz_tot:= Nvl(vr_res_vlcapcrz_tot,0) + Nvl(vr_rel_vlcaptal,0);

               -- Acumular valor do capital total por PF e PJ
               vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_tot := vr_typ_tab_total(rw_crapass.inpessoa).res_vlcapcrz_tot + Nvl(vr_rel_vlcaptal,0);

               -- Inicializa
               vr_rel_vlcppctl := 0;
               vr_rel_vlproctl := 0;

               -- Verifica se existe procap
               IF vr_tab_craplct.COUNT() > 0 THEN

                  -- Monta o indice inicial de agencia e conta para pesquisa
                  vr_ind_first := LPAD(rw_crapass.cdagenci,5,'0')||
                                  LPAD(rw_crapass.nrdconta,10,'0')||
                                  '00000000'||'0000000000';
                  -- Monta o indice final de agencia e conta para pesquisa
                  vr_ind_last  := LPAD(rw_crapass.cdagenci,5,'0')||
                                  LPAD(rw_crapass.nrdconta,10,'0')||
                                  '99999999'||'9999999999';

                  -- Busca o proximo indice maior a chave inicial montada
                  vr_first := vr_tab_craplct.NEXT(vr_ind_first);

                  -- Busca o registro anterior a chave final montada
                  vr_last := vr_tab_craplct.PRIOR(vr_ind_last);

                  IF (vr_first IS NOT NULL AND vr_last IS NULL) OR -- Se o indice inicial esta preenchido e o final null
                     (vr_first IS NULL AND vr_last IS NOT NULL) OR -- Se o indice final esta preenchido e o inicial null
                     (vr_last < vr_first) THEN -- Se ambos os indice estiverem preenchido, verifica se o final eh menor que o inicial

                     -- Somente grava o valor do capital total subscrito
                     vr_rel_vlcppctl := Nvl(vr_rel_vlcaptal,0);

                  ELSE

                     -- Acumula o valor do procap ativo do associado
                     LOOP
                        vr_rel_vlproctl := vr_rel_vlproctl + vr_tab_craplct(vr_first).vllanmto;

                        -- Finaliza quando o indice inicial for igual ao final
                        EXIT WHEN vr_last = vr_first;
                        -- Proximo registro
                        vr_first := vr_tab_craplct.NEXT(vr_first);
                     END LOOP;

                     -- Guarda as informacoes de total capital por agencia. Dados para Contabilidade
                     IF rw_crapass.inpessoa = 1 THEN

                        IF vr_tab_tot_pcap_fis.EXISTS(rw_crapass.cdagenci) THEN
                           vr_tab_tot_pcap_fis(rw_crapass.cdagenci) := vr_tab_tot_pcap_fis(rw_crapass.cdagenci) + vr_rel_vlproctl;
                        ELSE
                           vr_tab_tot_pcap_fis(rw_crapass.cdagenci) := vr_rel_vlproctl;
                        END IF;

                        vr_tot_pcapcred_fis := vr_tot_pcapcred_fis + vr_rel_vlproctl;
                     ELSE

                        IF vr_tab_tot_pcap_jur.EXISTS(rw_crapass.cdagenci) THEN
                           vr_tab_tot_pcap_jur(rw_crapass.cdagenci) := vr_tab_tot_pcap_jur(rw_crapass.cdagenci) + vr_rel_vlproctl;
                        ELSE
                           vr_tab_tot_pcap_jur(rw_crapass.cdagenci) := vr_rel_vlproctl;
                        END IF;

                        vr_tot_pcapcred_jur := vr_tot_pcapcred_jur + vr_rel_vlproctl;
                     END IF;

                     -- Grava o valor do capital total subscrito - Procap Ativo
                     vr_rel_vlcppctl := Nvl(vr_rel_vlcaptal,0) - Nvl(vr_rel_vlproctl,0);

                  END IF;

               ELSE -- Se nao existe procap
                  -- Somente grava o valor do capital total subscrito
                  vr_rel_vlcppctl := Nvl(vr_rel_vlcaptal,0);
               END IF;

               -- Se a data de demissao estiver nula
               IF rw_crapass.dtdemiss IS NULL THEN
                 -- Guarda as informacoes de total capital por agencia. Dados para Contabilidade
                 IF rw_crapass.inpessoa = 1 THEN
                    -- Verifica se existe valor para agencia corrente de pessoa fisica
                    IF vr_tab_vlcapage_fis.EXISTS(rw_crapass.cdagenci) THEN
                       -- Soma os valores por agencia de pessoa fisica
                       vr_tab_vlcapage_fis(rw_crapass.cdagenci) := vr_tab_vlcapage_fis(rw_crapass.cdagenci) + Nvl(vr_rel_vlcppctl,0);
                    ELSE
                       -- Inicializa o array com o valor inicial de pessoa fisica
                        vr_tab_vlcapage_fis(rw_crapass.cdagenci) := Nvl(vr_rel_vlcppctl,0);
                    END IF;
                    -- Gravando as informacoe para gerar o valor total capital de pessoa fisica
                    vr_tot_capagefis := vr_tot_capagefis + Nvl(vr_rel_vlcppctl,0);
                 ELSE
                    -- Verifica se existe valor para agencia corrente de pessoa juridica
                    IF vr_tab_vlcapage_jur.EXISTS(rw_crapass.cdagenci) THEN
                       -- Soma os valores por agencia de pessoa juridica
                       vr_tab_vlcapage_jur(rw_crapass.cdagenci) := vr_tab_vlcapage_jur(rw_crapass.cdagenci) + Nvl(vr_rel_vlcppctl,0);
                    ELSE
                       -- Inicializa o array com o valor inicial de pessoa juridica
                       vr_tab_vlcapage_jur(rw_crapass.cdagenci) :=  Nvl(vr_rel_vlcppctl,0);
                    END IF;
                    -- Gravando as informacoe para gerar o valor total capital de pessoa juridica
                    vr_tot_capagejur := vr_tot_capagejur + Nvl(vr_rel_vlcppctl,0);
                 END IF;
               END IF;

               -- Acumular valor capital em moeda fixa total
               vr_res_vlcapmfx_tot:= Nvl(vr_res_vlcapmfx_tot,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).qtcotmfx,0);
               -- Acumular valor correcao monetaria a incorporar total
               vr_res_vlcmicot_tot:= Nvl(vr_res_vlcmicot_tot,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmicot,0);
               -- Acumular valor correcao monetaria mes total
               vr_res_vlcmmcot_tot:= Nvl(vr_res_vlcmmcot_tot,0) + Nvl(vr_tab_crapcot(rw_crapass.nrdconta).vlcmmcot,0);

               --Se for matricula Original
               IF rw_crapass.inmatric = 1 THEN
                 -- Incrementar Quantidade cotistas total
                 vr_res_qtcotist_tot:= vr_res_qtcotist_tot + 1;
                 -- Incrementar Quantidade cotistas total por PF e PJ
                 vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_tot := vr_typ_tab_total(rw_crapass.inpessoa).res_qtcotist_tot + 1;
               END IF;

               /*  Le registro do plano de subscricao de capital  */

               -- Verificar se a conta possui subscricao antes de selecionar tudo
               IF vr_tab_crapsdc.EXISTS(rw_crapass.nrdconta) THEN
                  -- Selecionar informacoes da subscricao
                  FOR rw_crapsdc IN cr_crapsdc (pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => rw_crapass.nrdconta) LOOP
                     -- Se a data de demissao for nula
                     IF rw_crapass.dtdemiss IS NULL THEN
                        -- Montar indice para tabela debitos
                        vr_index_debitos:= LPad(rw_crapass.cdagenci,5,'0')||LPad(rw_crapass.nrdconta,10,'0');
                        -- Inserir informacoes na tabela de memoria de debitos
                        vr_tab_debitos(vr_index_debitos).cdagenci:= rw_crapass.cdagenci;
                        vr_tab_debitos(vr_index_debitos).nrdconta:= rw_crapass.nrdconta;
                        vr_tab_debitos(vr_index_debitos).nmprimtl:= rw_crapass.nmprimtl;
                        vr_tab_debitos(vr_index_debitos).dtadmiss:= rw_crapass.dtadmiss;
                        vr_tab_debitos(vr_index_debitos).dtrefere:= rw_crapsdc.dtrefere;
                        vr_tab_debitos(vr_index_debitos).vllanmto:= rw_crapsdc.vllanmto;
                        vr_tab_debitos(vr_index_debitos).tplanmto:= rw_crapsdc.dslanmto;
                        -- Acumular quantidade lancamentos
                        vr_tot_lancamen:= Nvl(vr_tot_lancamen,0) + 1;
                        -- Acumular o valor total dos lancamentos
                        vr_tot_vllanmto:= Nvl(vr_tot_vllanmto,0) + Nvl(rw_crapsdc.vllanmto,0);
                        -- Acumular valor capital ativo subscrito
                        vr_sub_vlcapcrz_ati:= Nvl(vr_sub_vlcapcrz_ati,0) + Nvl(rw_crapsdc.vllanmto,0);
                        --Acumular valor capital ativo subscrito por PF e PJ
                        vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_ati := vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_ati + Nvl(rw_crapsdc.vllanmto,0);
                        -- Acumular valor capital total subscrito
                        vr_sub_vlcapcrz_tot:= Nvl(vr_sub_vlcapcrz_tot,0) + Nvl(rw_crapsdc.vllanmto,0);
                        -- Acumular valor capital total subscrito por PF e PJ
                        vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_tot := vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_tot + Nvl(rw_crapsdc.vllanmto,0);
                     ELSE
                        -- Data de eliminacao for nula
                        IF rw_crapass.dtelimin IS NULL THEN
                           -- Acumular Valor capital subscrito demitido
                           vr_sub_vlcapcrz_dem:= Nvl(vr_sub_vlcapcrz_dem,0) + Nvl(rw_crapsdc.vllanmto,0);
                           -- Acumular Valor capital subscrito demitido por PF e PJ
                           vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_dem := vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_dem + Nvl(rw_crapsdc.vllanmto,0);
                           -- Acumular valor capital subscrito total
                           vr_sub_vlcapcrz_tot:= Nvl(vr_sub_vlcapcrz_tot,0) + Nvl(rw_crapsdc.vllanmto,0);
                           -- Acumular valor capital subscrito total por PF e PJ
                           vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_tot := vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_tot + Nvl(rw_crapsdc.vllanmto,0);
                        ELSE
                           -- Acumular Valor capital subscrito excluido
                           vr_sub_vlcapcrz_exc:= Nvl(vr_sub_vlcapcrz_exc,0) + Nvl(rw_crapsdc.vllanmto,0);
                           -- Acumular Valor capital subscrito excluido por PF e PJ
                           vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_exc := vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_exc + Nvl(rw_crapsdc.vllanmto,0);
                           -- Acumular valor capital subscrito total
                           vr_sub_vlcapcrz_tot:= Nvl(vr_sub_vlcapcrz_tot,0) + Nvl(rw_crapsdc.vllanmto,0);
                           -- Acumular valor capital subscrito total por PF e PJ
                           vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_tot := vr_typ_tab_total(rw_crapass.inpessoa).sub_vlcapcrz_tot + Nvl(rw_crapsdc.vllanmto,0);
                        END IF;
                     END IF;

                     -- Grava as informacoes para calcular o valor do capital subscrito menos o procap quando existir
                     vr_rel_vlcppctl := Nvl(rw_crapsdc.vllanmto,0) - Nvl(vr_rel_vlproctl,0);
                     -- Grava as informacoes para calcular o valor do capital a integralizar
                     vr_rel_vlcapctz := Nvl(rw_crapsdc.vllanmto,0);

                     -- Se a data de demissao for nula
                     IF rw_crapass.dtdemiss IS NULL THEN
                       -- Guarda as informacoes de total capital por agencia. Dados para Contabilidade
                       IF rw_crapass.inpessoa = 1 THEN
                          -- Verifica se existe valor para agencia corrente de pessoa fisica
                          IF vr_tab_vlcapage_fis.EXISTS(rw_crapass.cdagenci) THEN
                             -- Soma os valores por agencia de pessoa fisica
                             vr_tab_vlcapage_fis(rw_crapass.cdagenci) := vr_tab_vlcapage_fis(rw_crapass.cdagenci) + Nvl(vr_rel_vlcppctl,0);
                          ELSE
                             -- Inicializa o array com o valor inicial de pessoa fisica
                             vr_tab_vlcapage_fis(rw_crapass.cdagenci) := Nvl(vr_rel_vlcppctl,0);
                          END IF;
                          -- Gravando as informacoe para gerar o valor total capital de pessoa fisica
                          vr_tot_capagefis := vr_tot_capagefis + Nvl(vr_rel_vlcppctl,0);

                          -- Dados para contabilidade. Informacao de Capital a Integralizar
                          IF vr_tab_vlcapctz_fis.EXISTS(rw_crapass.cdagenci) THEN
                             vr_tab_vlcapctz_fis(rw_crapass.cdagenci) := vr_tab_vlcapctz_fis(rw_crapass.cdagenci) + Nvl(vr_rel_vlcapctz,0);
                          ELSE
                             vr_tab_vlcapctz_fis(rw_crapass.cdagenci) := Nvl(vr_rel_vlcapctz,0);
                          END IF;
                          vr_tot_vlcapctz_fis := vr_tot_vlcapctz_fis + Nvl(vr_rel_vlcapctz,0);

                       ELSE
                          -- Verifica se existe valor para agencia corrente de pessoa juridica
                          IF vr_tab_vlcapage_jur.EXISTS(rw_crapass.cdagenci) THEN
                             -- Soma os valores por agencia de pessoa juridica
                             vr_tab_vlcapage_jur(rw_crapass.cdagenci) := vr_tab_vlcapage_jur(rw_crapass.cdagenci) + Nvl(vr_rel_vlcppctl,0);
                          ELSE
                             -- Inicializa o array com o valor inicial de pessoa juridica
                             vr_tab_vlcapage_jur(rw_crapass.cdagenci) := Nvl(vr_rel_vlcppctl,0);
                          END IF;
                          -- Gravando as informacoe para gerar o valor total capital de pessoa juridica
                          vr_tot_capagejur := vr_tot_capagejur + Nvl(vr_rel_vlcppctl,0);

                          --Dados para contabilidade. Informacao de Capital a Integralizar
                          IF vr_tab_vlcapctz_jur.EXISTS(rw_crapass.cdagenci) THEN
                             vr_tab_vlcapctz_jur(rw_crapass.cdagenci) := vr_tab_vlcapctz_jur(rw_crapass.cdagenci) + Nvl(vr_rel_vlcapctz,0);
                          ELSE
                             vr_tab_vlcapctz_jur(rw_crapass.cdagenci) := Nvl(vr_rel_vlcapctz,0);
                          END IF;
                          vr_tot_vlcapctz_jur := vr_tot_vlcapctz_jur + Nvl(vr_rel_vlcapctz,0);

                       END IF;
                     END IF; -- rw_crapass.dtdemiss IS NULL

                  END LOOP;
               END IF;

               /*  Le registro de planos  */

               IF NOT vr_tab_crappla.EXISTS(rw_crapass.nrdconta) THEN
                  -- Valor da prestacao do plano recebe 0
                  vr_rel_vlprepla:= 0;
               ELSE
                  -- Valor da prestacao do plano recebe valor encontrado
                  vr_rel_vlprepla:= vr_tab_crappla(rw_crapass.nrdconta);
                  -- Incrementar numero planos de capitalizacao da agencia
                  IF vr_tab_tot_nrdplaag.EXISTS(rw_crapass.cdagenci) THEN
                     vr_tab_tot_nrdplaag(rw_crapass.cdagenci):= vr_tab_tot_nrdplaag(rw_crapass.cdagenci) + 1;
                  ELSE
                     vr_tab_tot_nrdplaag(rw_crapass.cdagenci):= 1;
                  END IF;

                  -- Acumular o valor dos planos de capitalizacao da agencia
                  IF vr_tab_tot_vlprepla.EXISTS(rw_crapass.cdagenci) THEN
                     vr_tab_tot_vlprepla(rw_crapass.cdagenci):= vr_tab_tot_vlprepla(rw_crapass.cdagenci) + Nvl(vr_rel_vlprepla,0);
                  ELSE
                     vr_tab_tot_vlprepla(rw_crapass.cdagenci):= Nvl(vr_rel_vlprepla,0);
                  END IF;
               END IF;

               -- Atribuir nulo para a descricao do registro
               vr_rel_dsmsgrec:= NULL;

               -- Se a data de demissao for nula
               IF rw_crapass.dtdemiss IS NULL THEN

                  -- Se encontrou registro na tabela de memoria
                  IF vr_tab_crapalt.EXISTS(rw_crapass.nrdconta) THEN
                     -- Acumula quantidade recadastrada da agencia
                     IF vr_tab_tot_qtjrecad.EXISTS(vr_cdagenci) THEN
                        vr_tab_tot_qtjrecad(vr_cdagenci):= vr_tab_tot_qtjrecad(vr_cdagenci) + 1;
                     ELSE
                        vr_tab_tot_qtjrecad(vr_cdagenci):= 1;
                     END IF;

                  ELSE

                     -- Marcar a descricao do registro para recadastro
                     vr_rel_dsmsgrec:= '*RECADASTRAR*';

                     -- Se a data de admissao < data movimento atual
                     IF rw_crapass.dtadmiss < vr_dtmvtolt THEN
                        -- Incrementar a quantidade de recadastros da agencia
                        IF vr_tab_tot_qtnrecad.EXISTS(vr_cdagenci) THEN
                           vr_tab_tot_qtnrecad(vr_cdagenci):= vr_tab_tot_qtnrecad(vr_cdagenci) + 1;
                        ELSE
                           vr_tab_tot_qtnrecad(vr_cdagenci):= 1;
                        END IF;
                     ELSE
                        -- Incrementar a quantidade de admitidos da agencia
                        IF vr_tab_tot_qtadmiss.EXISTS(vr_cdagenci) THEN
                           vr_tab_tot_qtadmiss(vr_cdagenci):= vr_tab_tot_qtadmiss(vr_cdagenci) + 1;
                        ELSE
                           vr_tab_tot_qtadmiss(vr_cdagenci):= 1;
                        END IF;
                     END IF;

                  END IF;
               END IF;

               -- Se for o primeiro registro
               IF vr_flgfirst THEN
                  -- Atribuir true para criacao clob da agencia
                  vr_flgclob:= TRUE;
                  -- Atribuir false para flag primeiro associado da agencia
                  vr_flgfirst:= FALSE;
                  -- Inicializar o CLOB
                  dbms_lob.createtemporary(vr_des_xml, TRUE);
                  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
                  -- Inicilizar as informações do XML
                  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl014><agencias>'||
                                 '<agencia cdagenci="'||vr_cdagenci||'" nmresage="'|| vr_nmresage ||'"><contas>');
               END IF;

               -- Se For agencia 14 ou 15
               IF rw_crapass.cdagenci IN (14,15) THEN
                  -- Data de admissao na empresa recebe valor encontrado
                  vr_dtadmemp:= To_Char(rw_crapass.dtadmemp,'DD/MM/YYYY');
               ELSE
                  -- Data de admissao na empresa recebe nulo
                  vr_dtadmemp:= NULL;
               END IF;

               -- Verificar se o valor das prestacoes é zero
               -- Enviar nulo para nao imprimir no arquivo
               IF Nvl(vr_rel_vlprepla,0) = 0 THEN
                  vr_rel_vlprepla:= NULL;
               END IF;

               -- Verificar se a quantidade de parcelas pagas é zero
               IF Nvl(vr_rel_qtprpgpl,0) = 0 THEN
                  vr_rel_qtprpgpl:= NULL;
               END IF;

               -- Escrever detalhe no xml
               pc_escreve_xml('<conta>
                             <nrdconta>'||LTrim(gene0002.fn_mask_conta(rw_crapass.nrdconta))||'</nrdconta>
                             <dsdacstp>'||vr_rel_dsdacstp||'</dsdacstp>
                             <nmprimtl><![CDATA['||substr(rw_crapass.nmprimtl,1,33)||']]></nmprimtl>
                             <dtadmemp>'||vr_dtadmemp||'</dtadmemp>
                             <vlsmtrag>'||to_char(vr_rel_vlsmtrag,'fm999g999g990d00')||'</vlsmtrag>
                             <vlsmmes1>'||to_char(vr_rel_vlsmmes1,'fm99999g999g990d00')||'</vlsmmes1>
                             <vlsmmes2>'||to_char(vr_rel_vlsmmes2,'fm99999g999g990d00')||'</vlsmmes2>
                             <vlsmmes3>'||to_char(vr_rel_vlsmmes3,'fm99g999g999g990d00')||'</vlsmmes3>
                             <indnivel>'||rw_crapass.indnivel||'</indnivel>
                             <dsmsgrec>'||vr_rel_dsmsgrec||'</dsmsgrec>
                             <nrmatric>'||To_Char(rw_crapass.nrmatric,'fm999g990')||'</nrmatric>
                             <vledvmto>'||to_char(rw_crapass.vledvmto,'fm999g999g990d00')||'</vledvmto>
                             <dtedvmto>'||To_Char(rw_crapass.dtedvmto,'DD/MM/YYYY')||'</dtedvmto>
                             <cdempres>'||To_Char(vr_cdempres,'fm999')||'</cdempres>
                             <dtultlcr>'||To_Char(rw_crapass.dtultlcr,'DD/MM/YYYY')||'</dtultlcr>
                             <dslimcre>'||vr_rel_dslimcre||'</dslimcre>
                             <vllimcre>'||To_Char(rw_crapass.vllimcre,'fm99g999g990d00')||'</vllimcre>
                             <vlprepla>'||To_Char(vr_rel_vlprepla,'fm9999g999g990d00')||'</vlprepla>
                             <vlcaptal>'||To_Char(vr_rel_vlcaptal,'fm99g999g999g990d00')||'</vlcaptal>
                             <qtprpgpl>'||To_Char(vr_rel_qtprpgpl,'fm999')||'</qtprpgpl>');

               /*  Leitura dos contratos de emprestimos  */

               -- Atribuir false para existencia emprestimo
               vr_regexist:= FALSE;
               vr_fisrtemp:= TRUE;
               --Zerar variaveis
               vr_vlsdeved:= 0;
               vr_vlpreemp:= 0;
               vr_qtctremp:= 0;

               -- Selecionar contratos de emprestimo do associado
               FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapass.nrdconta) LOOP

                  -- Criar bloco para controle fluxo
                  BEGIN
                     -- Se o valor do saldo devedor do emprestimo for zero
                     IF rw_crapepr.vlsdeved = 0 THEN
                        -- Acumular o valor dos juros do mes da agencia
                        IF vr_tab_tot_vljurmes.EXISTS(rw_crapass.cdagenci) THEN
                           vr_tab_tot_vljurmes(rw_crapass.cdagenci):= vr_tab_tot_vljurmes(rw_crapass.cdagenci) +
                                                                      Nvl(rw_crapepr.vljurmes,0);
                        ELSE
                           vr_tab_tot_vljurmes(rw_crapass.cdagenci):= Nvl(rw_crapepr.vljurmes,0);
                        END IF;
                        -- levantar excecao e ir para proximo emprestimo
                        RAISE vr_exc_pula;
                     END IF;

                     -- Se for o primeiro emprestimo
                     IF vr_fisrtemp THEN

                        -- Inicializar o agrupador de emprestimos
                        pc_escreve_xml('<emprestimos>');

                        -- Atribuir false para flag primeiro emprestimo
                        vr_fisrtemp:= FALSE;
                     END IF;

                     -- Mudar flag para indicar existe emprestimo
                     vr_regexist:= TRUE;
                     -- Acumular saldo devedor
                     vr_vlsdeved:= Nvl(vr_vlsdeved,0) + Nvl(rw_crapepr.vlsdeved,0);
                     -- Acumular valor prestacoes do emprestimo
                     vr_vlpreemp:= Nvl(vr_vlpreemp,0) + Nvl(rw_crapepr.vlpreemp,0);
                     -- Acumular qtdade contratos de emprestimo
                     vr_qtctremp:= Nvl(vr_qtctremp,0) + 1;
                     -- Quantidade prestacoes a pagar recebe qde prestacoes do emprestimo - qde prestacoes calculadas
                     vr_rel_qtpreapg:= Nvl(rw_crapepr.qtpreemp,0) - Nvl(rw_crapepr.qtprecal,0);

                     -- Se o valor calculado for negativo entao zera
                     IF vr_rel_qtpreapg < 0 THEN
                        vr_rel_qtpreapg:= 0;
                     END IF;

                     -- Acumular a quantidade de contratos da agencia
                     IF vr_tab_tot_qtctremp.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_tot_qtctremp(rw_crapass.cdagenci):= vr_tab_tot_qtctremp(rw_crapass.cdagenci) + 1;
                     ELSE
                        vr_tab_tot_qtctremp(rw_crapass.cdagenci):= 1;
                     END IF;

                     -- Acumular o valor das prestacoes dos emprestimos da agencia
                     IF vr_tab_tot_vlpreemp.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_tot_vlpreemp(rw_crapass.cdagenci):= vr_tab_tot_vlpreemp(rw_crapass.cdagenci) + Nvl(rw_crapepr.vlpreemp,0);
                     ELSE
                        vr_tab_tot_vlpreemp(rw_crapass.cdagenci):= Nvl(rw_crapepr.vlpreemp,0);
                     END IF;

                     -- Acumular o valor do saldo devedor dos emprestimos da agencia
                     IF vr_tab_tot_vlsdeved.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_tot_vlsdeved(rw_crapass.cdagenci):= vr_tab_tot_vlsdeved(rw_crapass.cdagenci) + Nvl(rw_crapepr.vlsdeved,0);
                     ELSE
                        vr_tab_tot_vlsdeved(rw_crapass.cdagenci):= Nvl(rw_crapepr.vlsdeved,0);
                     END IF;

                     -- Acumular o valor dos juros dos emprestimos da agencia
                     IF vr_tab_tot_vljurmes.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_tot_vljurmes(rw_crapass.cdagenci):= vr_tab_tot_vljurmes(rw_crapass.cdagenci) + Nvl(rw_crapepr.vljurmes,0);
                     ELSE
                       vr_tab_tot_vljurmes(rw_crapass.cdagenci):= Nvl(rw_crapepr.vljurmes,0);
                     END IF;

                     -- Verificar os lancamentos de emprestimo
                     pc_verifica_lancto_emprestimo(pr_nrdconta   => rw_crapepr.nrdconta
                                                  ,pr_nrctremp   => rw_crapepr.nrctremp
                                                  ,pr_vlsdeved   => rw_crapepr.vlsdeved
                                                  ,pr_dtultpagto => vr_dtultpagto
                                                  ,pr_vlultpagto => vr_vlultpagto
                                                  ,pr_vlprovisao => vr_vlprovisao
                                                  ,pr_nivelrisco => vr_nivelrisco
                                                  ,pr_des_erro   => vr_des_erro);

                     -- Se retornou erro
                     IF vr_des_erro IS NOT NULL THEN
                        -- Levantar Excecao
                        RAISE vr_exc_saida;
                     END IF;

                     -- Escrever detalhe no xml
                     pc_escreve_xml
                        ('<emprestimo>
                          <nrctremp>'||LTrim(gene0002.fn_mask_contrato(rw_crapepr.nrctremp))||'</nrctremp>
                          <cdfinemp>'||To_Char(rw_crapepr.cdfinemp,'fm990')||'</cdfinemp>
                          <cdlcremp>'||To_Char(rw_crapepr.cdlcremp,'fm9990')||'</cdlcremp>
                          <dtmvtolt>'||To_Char(rw_crapepr.dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>
                          <qtpreemp>'||To_Char(rw_crapepr.qtpreemp,'fm990')||'</qtpreemp>
                          <txjuremp>'||To_Char(rw_crapepr.txjuremp,'fm990d0000000')||'</txjuremp>
                          <vlemprst>'||To_Char(rw_crapepr.vlemprst,'fm99999g999g990d00')||'</vlemprst>
                          <vlpreemp>'||To_Char(rw_crapepr.vlpreemp,'fm99g999g999g990d00')||'</vlpreemp>
                          <vlsdeved>'||rw_crapepr.vlsdeved||'</vlsdeved>
                          <qtpreapg>'||To_Char(vr_rel_qtpreapg,'fm990')||'</qtpreapg>
                          <dtultpagto>'||To_Char(vr_dtultpagto,'DD/MM/YYYY')||'</dtultpagto>
                          <vlultpagto>'||To_Char(vr_vlultpagto,'fm99g999g990d00')||'</vlultpagto>
                          <vlprovisao>'||To_Char(vr_vlprovisao,'fm99g999g999g990d00')||'</vlprovisao>
                          <nivelrisco>'||vr_nivelrisco||'</nivelrisco>
                          </emprestimo>');

                     /*--- Dados para o relatorio 398 ---*/

                     -- Se o emprestimo estiver ativo e o saldo devedor > 0
                     IF rw_crapepr.inliquid = 0 AND rw_crapepr.vlsdeved > 0 THEN
                       --Verificar na tabela de memoria de totais se a linha existe
                       IF vr_tab_totlcred.EXISTS(rw_crapepr.cdlcremp) THEN
                         --Acumular valor do limite de credito
                         vr_tab_totlcred(rw_crapepr.cdlcremp):= vr_tab_totlcred(rw_crapepr.cdlcremp) + Nvl(rw_crapepr.vlsdeved,0);
                       ELSE
                         --Acumular valor do limite de credito
                         vr_tab_totlcred(rw_crapepr.cdlcremp):= Nvl(rw_crapepr.vlsdeved,0);
                       END IF;
                     END IF;

                  EXCEPTION
                     WHEN vr_exc_pula THEN
                        NULL;
                     WHEN OTHERS THEN
                        vr_des_erro:= 'Erro ao processar contratos de emprestimo. Rotina pc_crps010. '||SQLERRM;
                  END;
               END LOOP; -- rw_crapepr

               -- Se existe registro de emprestimo
               IF vr_regexist THEN

                  -- Incrementa totalizador de associados com emprestimo na agencia
                  IF vr_tab_tot_qtassemp.EXISTS(rw_crapass.cdagenci) THEN
                     vr_tab_tot_qtassemp(rw_crapass.cdagenci):= vr_tab_tot_qtassemp(rw_crapass.cdagenci) + 1;
                  ELSE
                     vr_tab_tot_qtassemp(rw_crapass.cdagenci):= 1;
                  END IF;

                  -- Finalizar agrupador de emprestimos e Incluir informacao que houve emprestimos
                  pc_escreve_xml('</emprestimos><controle>1</controle>');
               ELSE
                  -- Incluir informacao que nao houve emprestimos
                  pc_escreve_xml('<controle>0</controle>');
               END IF;

               -- Finalizar o agrupador de conta
               pc_escreve_xml('</conta>');

               /*-- Desconto de Cheques - rel 398 --*/

               IF vr_tab_crapcdb.EXISTS(rw_crapass.nrdconta) THEN
                  -- Acumular valor desconto
                  vr_desconto:= Nvl(vr_desconto,0) + vr_tab_crapcdb(rw_crapass.nrdconta);
               END IF;

               /*-- Desconto de Titulos - rel 398 --*/

               IF vr_tab_craptdb.EXISTS(rw_crapass.nrdconta) THEN

                  vr_index_craptdb := vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb.first;
                  WHILE vr_index_craptdb IS NOT NULL LOOP
                     -- Selecionar informacoes dos boletos de cobranca
                     OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                                     ,pr_cdbandoc => vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).cdbandoc
                                     ,pr_nrdctabb => vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).nrdctabb
                                     ,pr_nrcnvcob => vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).nrcnvcob
                                     ,pr_nrdconta => vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).nrdconta
                                     ,pr_nrdocmto => vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).nrdocmto);
                     -- Posicionar no primeiro registro
                     FETCH cr_crapcob INTO rw_crapcob;
                     -- Se nao encontrou registro
                     IF cr_crapcob%NOTFOUND THEN
                        -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 --
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                   || vr_cdprogra || ' --> '
                                                                   || 'Titulo em desconto nao encontrado'
                                                                   || ' no crapcob - ROWID(craptdb) = '
                                                                   || vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).vr_rowid );
                     ELSE
                        -- Ignorar registro se oes titulo estiver pago
                        -- e o indicador de pagto for caixa/Internetbank/TAA
                        IF (vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).insittit = 2  AND (rw_crapcob.indpagto IN (1,3,4))) THEN
                           NULL;
                        ELSE
                           -- Acumular valor desconto titulos
                           vr_desctitu:= Nvl(vr_desctitu,0) + Nvl(vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb(vr_index_craptdb).vltitulo,0);
                        END IF;
                     END IF;
                     --Fechar Cursor
                     CLOSE cr_crapcob;
                     vr_index_craptdb := vr_tab_craptdb(rw_crapass.nrdconta).tab_craptdb.next(vr_index_craptdb);
                  END LOOP;
               END IF;

            EXCEPTION
               WHEN vr_exc_pula THEN
                  NULL;
               WHEN OTHERS THEN
                  vr_des_erro:= 'Erro ao selecionar associado. '||SQLERRM;
                  -- Levantar Excecao
                  RAISE vr_exc_saida;
            END;
         END LOOP; --rw_crapass

         -- Se criou o clob anteriormente
         IF vr_flgclob THEN

            -- Finalizar o agrupador de contas e agencia e inicia o totalizador
            pc_escreve_xml
               ('</contas></agencia><totais><total>
                 <pc_assoc>'||To_Char(vr_tab_tot_nrdplaag(vr_cdagenci),'fm999g999g990')||'</pc_assoc>
                 <pc_plano>'||To_Char(vr_tab_tot_vlprepla(vr_cdagenci),'fm99g999g999g990d00')||'</pc_plano>
                 <sm_assoc>'||To_Char(vr_tab_tot_nrassmag(vr_cdagenci),'fm999g999g990')||'</sm_assoc>
                 <sm_media>'||To_Char(vr_tab_tot_vlsmtrag(vr_cdagenci),'fm99g999g999g990d00')||'</sm_media>
                 <sm_nmmes1>'||vr_rel_nomemes1||'</sm_nmmes1>
                 <sm_nmmes2>'||vr_rel_nomemes2||'</sm_nmmes2>
                 <sm_nmmes3>'||vr_rel_nomemes3||'</sm_nmmes3>
                 <sm_mes1>'||To_Char(vr_tab_tot_vlsmmes1(vr_cdagenci),'fm99g999g999g990d00')||'</sm_mes1>
                 <sm_mes2>'||To_Char(vr_tab_tot_vlsmmes2(vr_cdagenci),'fm99g999g999g990d00')||'</sm_mes2>
                 <sm_mes3>'||To_Char(vr_tab_tot_vlsmmes3(vr_cdagenci),'fm99g999g999g990d00')||'</sm_mes3>
                 <sm_capital>'||To_Char(vr_tab_tot_vlcaptal(vr_cdagenci),'fm99g999g999g990d00')||'</sm_capital>
                 <emp_assoc>'||To_Char(vr_tab_tot_qtassemp(vr_cdagenci),'fm999g999g990')||'</emp_assoc>
                 <emp_contrato>'||To_Char(vr_tab_tot_qtctremp(vr_cdagenci),'fm999g999g990')||'</emp_contrato>
                 <emp_juros>'||To_Char(vr_tab_tot_vljurmes(vr_cdagenci),'fm99g999g999g990d00')||'</emp_juros>
                 <emp_prest>'||To_Char(vr_tab_tot_vlpreemp(vr_cdagenci),'fm99g999g999g990d00')||'</emp_prest>
                 <emp_saldo>'||To_Char(vr_tab_tot_vlsdeved(vr_cdagenci),'fm99g999g999g990d00')||'</emp_saldo>
                 <rec_feito>'||To_Char(vr_tab_tot_qtjrecad(vr_cdagenci),'fm999g999g990')||'</rec_feito>
                 <rec_fazer>'||To_Char(vr_tab_tot_qtnrecad(vr_cdagenci),'fm999g999g990')||'</rec_fazer>
                 <rec_adm>'||To_Char(vr_tab_tot_qtadmiss(vr_cdagenci),'fm999g999g990')||'</rec_adm>
               </total></totais></agencias></crrl014>');

            -- Efetuar solicitação de geração de relatório --
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                       ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl014/agencias/agencia/contas/conta' --> Nó base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl014.jasper'    --> Arquivo de layout do iReport
                                       ,pr_dsparams  => NULL                --> Sem parametros
                                       ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                       ,pr_qtcoluna  => 132                 --> 132 colunas
                                       ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_1.i}
                                       ,pr_cdrelato  => NULL                --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                       ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                       ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                       ,pr_nrcopias  => 1                   --> Número de cópias a imprimir
                                       ,pr_flg_gerar => 'N'                 --> gerar PDF
                                       ,pr_des_erro  => vr_des_erro);       --> Saída com erro

            -- Testar se houve erro
            IF vr_des_erro IS NOT NULL THEN
               -- Gerar exceção
               RAISE vr_exc_saida;
            END IF;

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

         END IF;
      END LOOP; --vr_tab_crapage

      -- Executar procedure geração resumo geral
      pc_imprime_crrl014_total(pr_des_erro => vr_des_erro);

      -- Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;

      -- Executar procedure geração resumo do capital (crrl031)
      pc_crps010_2 (pr_des_erro => vr_des_erro);

      -- Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
         -- Levantar Exceção
         RAISE vr_exc_saida;
      END IF;

      -- Executar procedure geração relatorio 421
      pc_crps010_3 (pr_des_erro => vr_des_erro);

      -- Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
         -- Levantar Exceção
         RAISE vr_exc_saida;
      END IF;

      -- Executar procedure geração relatorio 426
      pc_crps010_4 (pr_des_erro => vr_des_erro);

      -- Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_saida;
      END IF;

      -- Executar procedure geração relatorio 398
      pc_imprime_crrl398 (pr_des_erro => vr_des_erro);

      -- Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
         -- Levantar Exceção
         RAISE vr_exc_saida;
      END IF;

      -- Gera Arq AAMMDD_CAPITAL.txt - Dados para Contabilidade
      pc_gera_arq_capital(pr_des_erro => vr_des_erro);

      --Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_saida;
      END IF;

      -- Zerar tabela de memoria auxiliar
      pc_limpa_tabela;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informacoes no banco de dados
   COMMIT;

   EXCEPTION
      WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas código
         IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
            -- Buscar a descrição
            vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;

         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_des_erro );
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         -- Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
         -- Se foi retornado apenas código
         IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
            -- Buscar a descrição
            vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;

         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_des_erro;

         -- Efetuar rollback
         ROLLBACK;

         -- Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

      WHEN OTHERS THEN
         -- Retornar texto do erro
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;

         -- Efetuar rollback
         ROLLBACK;

         -- Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

   END;
END pc_crps010;
/
