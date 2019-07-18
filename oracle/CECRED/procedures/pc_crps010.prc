CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS010(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
                                             ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo Agencia 
                                             ,pr_idparale IN crappar.idparale%TYPE  --> Indicador de processoparalelo
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código crítica
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Descrição crítica
BEGIN

/* .............................................................................

 Programa: pc_crps010                          Antigo: Fontes/crps010.p
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Deborah/Edson
 Data    : Janeiro/92.                         Ultima atualizacao: 06/08/2018
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
                      
          05/12/2017 - Ajuste no tratamento para apresentar a contabilização dos motivos de demissão
                      (Jonata - RKAM P364).

          27/12/2017 - #806757 Incluídos os logs de trace dos erros nas principais exceptions others (Carlos)
          
          06/02/2018 - #842836 Inclusão do hint FULL no cursor cr_craplem para melhoria de performance (Carlos)
          
          02/07/2018 - Projeto Revitalização Sistemas - Transformação do programa
			           em paralelo por Agência - Andreatta (MOUTs)
          
		  01/08/2018 - Remoção de Hint com problema de lentidão - Andreatta (MOUTs)
      
      06/08/2018 - Inclusao de maiores detalhes nos logs de erros - Andreatta (MOUTs) 
          
      25/06/2019 - Remover lancamentos de segregacao/reversao para contas PF/PJ.
                   Apos atualizacao do plano de contas, nao e mais necessaria realizar essa segregacao.
                   Solicitacao Contabilidade - Heitor (Mouts)

   ............................................................................. */
   DECLARE
     
     --- ################################ Variáveis ################################# ----
   
     -- variáveis para controle de arquivos
     vr_dircon VARCHAR2(200);
     vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos'; 
     vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
     vc_cdtodascooperativas INTEGER := 0; 
     
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
     vr_cdprogra     CONSTANT VARCHAR2(10) := 'CRPS010';
     vr_cdcritic     NUMBER:= 0;
     vr_desconto     NUMBER:= 0;
     vr_desctitu     NUMBER:= 0;
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
     vr_res_vlcapcrz_exc_age NUMBER:= 0;
     vr_res_vlcmicot_exc NUMBER:= 0;
     vr_res_vlcmmcot_exc NUMBER:= 0;
     vr_res_vlcapmfx_exc NUMBER:= 0;     
     vr_res_qtcotist_exc NUMBER:= 0;
     vr_res_qtcotist_exc_age NUMBER:= 0;
     vr_res_vlcapcrz_tot NUMBER:= 0;
     vr_res_vlcapcrz_tot_age NUMBER:= 0;
     vr_res_vlcmicot_tot NUMBER:= 0;
     vr_res_vlcmmcot_tot NUMBER:= 0;
     vr_res_vlcapmfx_tot NUMBER:= 0;
     vr_res_qtcotist_tot NUMBER:= 0;
     vr_res_qtcotist_tot_age NUMBER:= 0;

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
     vr_tot_pcapcred_fis NUMBER:= 0;
     vr_tot_pcapcred_jur NUMBER:= 0;
     --
     vr_totativo         NUMBER;
     vr_vlativos         NUMBER;

     -- Variável para armazenar as informações em XML
     vr_clob_xml   CLOB;
     vr_text_xml   VARCHAR2(32767);
     vr_cod_chave INTEGER;
     vr_des_chave VARCHAR2(400);
     vr_flg_gerar CONSTANT VARCHAR2(1) := 'N';

     -- Variavel para o rowtype da crapsld
     rw_crapsld crapsld%ROWTYPE;

     --Variavel para arquivo de dados     
     vr_clob_arq   CLOB;
     vr_text_arq   VARCHAR2(32767);

     -- Variaveis de Excecao
     vr_dscritic   VARCHAR2(4000);
     vr_exc_saida  EXCEPTION;
     vr_exc_pula   EXCEPTION;
     
     -- ID para o paralelismo
     vr_idparale      integer;
     -- Qtde parametrizada de Jobs
     vr_qtdjobs       number;
     -- Job name dos processos criados
     vr_jobname       varchar2(30);
     -- Bloco PLSQL para chamar a execução paralela do pc_crps750
     vr_dsplsql       varchar2(4000);
    
     -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
     vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
     vr_idlog_ini_ger tbgen_prglog.idprglog%type;
     vr_idlog_ini_par tbgen_prglog.idprglog%type;
     vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
     vr_qterro        number := 0; 
   
     --- ################################ Tipos e Registros de memória ################################# ----

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
       INDEX BY PLS_INTEGER;
     
     -- Definicao do tipo de registro de titulares da conta PJ
     TYPE typ_reg_crapjur IS
     RECORD (cdempres crapjur.cdempres%TYPE);
            
     -- Definicao do tipo de tabela para titulares da conta PJ
     TYPE typ_tab_crapjur IS
       TABLE OF typ_reg_crapjur
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

     -- Definicao do tipo de tabela auxiliar de emprestimos
     TYPE typ_reg_crapepr IS
     RECORD (cdageass  crapass.cdagenci%TYPE
            ,nrdconta  crapepr.nrdconta%type
            ,nrctremp  crapepr.nrctremp%type
            ,vlsdeved  crapepr.vlsdeved%type
            ,cdlcremp  crapepr.cdlcremp%type
            ,dtmvtolt  crapepr.dtmvtolt%type
            ,vlemprst  crapepr.vlemprst%type
            ,dtultpag  crapepr.dtultpag%type
            ,cdcooper  crapepr.cdcooper%type
            ,cdagenci  crapepr.cdagenci%type
            ,vlpreemp  crapepr.vlpreemp%type
            ,qtpreemp  crapepr.qtpreemp%type
            ,qtprecal  crapepr.qtprecal%type
            ,vljurmes  crapepr.vljurmes%type
            ,cdfinemp  crapepr.cdfinemp%type
            ,txjuremp  crapepr.txjuremp%type
            ,inliquid  crapepr.inliquid%type
            ,dsnivcal  crawepr.dsnivcal%type
            ,dtmvtlem  craplem.dtmvtolt%type
            ,vllanlem  craplem.vllanmto%type);   
     TYPE typ_tab_crapepr IS
       TABLE OF typ_reg_crapepr
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
     vr_tab_crapjur        typ_tab_crapjur;
     vr_tab_craptdb        typ_tab_craptdb;
     vr_tab_crapcot        typ_tab_crapcot;
     vr_tab_crappla        typ_reg_tot;
     vr_tab_crapalt        typ_reg_tot;
     vr_tab_craplim        typ_reg_tot;
     vr_tab_crapcdb        typ_reg_tot;
     vr_tab_crapepr        typ_tab_crapepr;
     vr_tab_craptab        typ_tab_craptab;
     vr_tab_crapsdc        typ_reg_tot;
     vr_tab_craptab_motivo typ_reg_craptab_motivo;
     vr_typ_tab_total      typ_tab_total;
     
     vr_tab_vlcapage_fis   typ_tab_vlcapage_fis;
     vr_tab_vlcapage_jur   typ_tab_vlcapage_jur;
     vr_tab_vlcapctz_fis   typ_tab_vlcapctz_fis;
     vr_tab_vlcapctz_jur   typ_tab_vlcapctz_jur;
     vr_tab_tot_pcap_fis   typ_tab_tot_pcap_fis;
     vr_tab_tot_pcap_jur   typ_tab_tot_pcap_jur;

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

     -- Vetores de pltables externas
     vr_tab_craplct      PCAP0001.typ_tab_craplct;
     vr_typ_tab_ativos   PCAP0001.typ_tab_ativos;

     -- Variaveis de indice para as tabelas de memoria
     vr_index_demitidos  VARCHAR2(20);
     vr_index_duplicados VARCHAR2(15);
     vr_index_debitos    VARCHAR2(15);
     vr_index_crapepr    VARCHAR2(20);
     vr_index_craptdb    NUMBER(10);

     
     --- ################################ CURSORES ################################# ----

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
     CURSOR cr_crapage (pr_cdcooper crapage.cdcooper%TYPE
                       ,pr_cdagenci crapage.cdagenci%TYPE              DEFAULT 0
                       ,pr_cdprogra tbgen_batch_controle.cdprogra%TYPE DEFAULT 0 
                       ,pr_qterro   number                             DEFAULT 0
                       ,pr_dtmvtolt tbgen_batch_controle.dtmvtolt%TYPE DEFAULT NULL) IS
       SELECT crapage.cdagenci
             ,crapage.nmresage
         FROM crapage crapage
        WHERE crapage.cdcooper = pr_cdcooper
          AND crapage.cdagenci = decode(pr_cdagenci,0,crapage.cdagenci,pr_cdagenci)
          AND (pr_qterro = 0 or
              (pr_qterro > 0 and exists (select 1
                                           from tbgen_batch_controle
                                          where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                            and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                            and tbgen_batch_controle.tpagrupador = 1
                                            and tbgen_batch_controle.cdagrupador = crapage.cdagenci
                                            and tbgen_batch_controle.insituacao  = 1
                                            and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt))) 
        ORDER BY crapage.cdagenci;

     --Selecionar informacoes dos saldos dos associados
     CURSOR cr_crapsld (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
       SELECT  crapsld.nrdconta
              ,crapsld.vlsddisp
              ,crapsld.vlsmstre##1
              ,crapsld.vlsmstre##2
              ,crapsld.vlsmstre##3
              ,crapsld.vlsmstre##4
              ,crapsld.vlsmstre##5
              ,crapsld.vlsmstre##6
       FROM crapsld crapsld
           ,crapass crapass
       WHERE crapsld.cdcooper = crapass.cdcooper
         AND crapsld.nrdconta = crapass.nrdconta
         AND crapsld.cdcooper = pr_cdcooper
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);
     -- Definicao do tipo de tabela dos lancamentos de saldos
     TYPE typ_tab_crapsld IS
       TABLE OF cr_crapsld%ROWTYPE
       INDEX BY PLS_INTEGER;   
     vr_tab_crapsld typ_tab_crapsld;     

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
              ,RPAD(' ',20,' ') idxemprt
         FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
        ORDER BY crapass.cdagenci,crapass.nrdconta;
     -- Definicao do tipo de tabela para associados     
     TYPE vr_typ_tab_crapass_bulk IS TABLE OF cr_crapass%ROWTYPE INDEX BY PLS_INTEGER;
     rw_crapass vr_typ_tab_crapass_bulk;
     TYPE vr_typ_tab_crapass IS TABLE OF cr_crapass%ROWTYPE INDEX BY VARCHAR2(15);
     vr_tab_crapass vr_typ_tab_crapass;
     vr_idx_crapass VARCHAR2(15);
     
     -- Selecionar informacoes dos titulares da conta
     CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
       SELECT crapttl.nrdconta
             ,crapttl.cdempres
             ,crapttl.cdturnos
         FROM crapttl crapttl
             ,crapass crapass
        WHERE crapttl.cdcooper = crapass.cdcooper
          AND crapttl.nrdconta = crapass.nrdconta
          AND crapttl.cdcooper = pr_cdcooper
          AND crapttl.idseqttl = pr_idseqttl
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);
     rw_crapttl cr_crapttl%ROWTYPE;

     -- Selecionar informacoes dos titulares da conta
     CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT crapjur.nrdconta
             ,crapjur.cdempres
         FROM crapjur crapjur
             ,crapass crapass
        WHERE crapjur.cdcooper = crapass.cdcooper
          AND crapjur.nrdconta = crapass.nrdconta
          AND crapjur.cdcooper = pr_cdcooper
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

     -- Selecionar as informacoes das cotas dos associados
     CURSOR cr_crapcot (pr_cdcooper IN crapcot.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT crapcot.nrdconta
             ,crapcot.qtcotmfx
             ,crapcot.vlcmicot
             ,crapcot.vlcmmcot
             ,crapcot.vldcotas
             ,crapcot.qtprpgpl
        FROM crapcot crapcot
            ,crapass crapass
        WHERE crapcot.cdcooper = crapass.cdcooper
          AND crapcot.nrdconta = crapass.nrdconta
          AND crapcot.cdcooper = pr_cdcooper
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

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
     CURSOR cr_crapsdc_existe (pr_cdcooper IN crapsdc.cdcooper%TYPE
                              ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT crapsdc.nrdconta
         FROM crapsdc crapsdc
             ,crapass crapass
        WHERE crapass.cdcooper = crapsdc.cdcooper
          AND crapass.nrdconta = crapsdc.nrdconta
          AND crapsdc.cdcooper = pr_cdcooper
          AND crapsdc.dtdebito IS NULL
          AND crapsdc.indebito = 0
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

     -- Selecionar informacoes dos planos
     CURSOR cr_crappla (pr_cdcooper IN crappla.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT crappla.nrdconta
             ,crappla.vlprepla
         FROM crappla crappla
             ,crapass crapass
        WHERE crapass.cdcooper = crappla.cdcooper
          AND crapass.nrdconta = crappla.nrdconta
          AND crappla.cdcooper = pr_cdcooper
          AND crappla.tpdplano = 1
          AND crappla.cdsitpla = 1
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
        ORDER BY crappla.NRDCONTA, crappla.CDSITPLA, crappla.TPDPLANO, crappla.DTCANCEL DESC, crappla.NRCTRPLA DESC, crappla.PROGRESS_RECID;

     -- Selecionar informacoes historico de alteracoes crapass
     CURSOR cr_crapalt (pr_cdcooper IN crapalt.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT crapalt.nrdconta
         FROM crapalt crapalt
             ,crapass crapass
        WHERE crapass.cdcooper = crapalt.cdcooper
          AND crapass.nrdconta = crapalt.nrdconta
          AND crapalt.cdcooper = pr_cdcooper
          AND crapalt.tpaltera = 1
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);
     rw_crapalt cr_crapalt%ROWTYPE;

     -- Selecionar informacoes dos emprestimos
     CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_cdagenci IN crapepr.cdagenci%TYPE) IS
       SELECT crapass.cdagenci cdageass
             ,crapepr.nrdconta
             ,crapepr.nrctremp
             ,crapepr.vlsdeved
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
             ,LTrim(RTrim(crawepr.dsnivcal)) dsnivcal
             ,to_date(NULL) dtmvtlem
             ,0 vllanlem
         FROM crapass crapass
             ,crawepr crawepr 
             ,crapepr crapepr
        WHERE crapepr.cdcooper = pr_cdcooper
          AND crapepr.cdcooper = crawepr.cdcooper
          AND crapepr.nrdconta = crawepr.nrdconta
          AND crapepr.nrctremp = crawepr.nrctremp
          AND crapepr.cdcooper = crapass.cdcooper
          AND crapepr.nrdconta = crapass.nrdconta
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
        ORDER BY crapepr.nrdconta,crapepr.nrctremp;          
     -- Definicao do tipo de tabela para propostas     
     TYPE vr_typ_tab_crapepr_bulk IS TABLE OF cr_crapepr%ROWTYPE INDEX BY PLS_INTEGER;
     rw_crapepr_bulk vr_typ_tab_crapepr_bulk; 
     
     -- Selecionar informacoes dos lancamentos do emprestimos
     CURSOR cr_craplem (pr_cdcooper IN crapepr.cdcooper%TYPE
                       --,pr_dslsthis IN VARCHAR2
                       ) IS
       SELECT /*+ FULL(craplem) */
              craplem.nrdconta
             ,craplem.nrctremp
             ,max(craplem.dtmvtolt) keep (dense_rank last order by craplem.dtmvtolt) dtmvtolt
             ,sum(craplem.vllanmto) keep (dense_rank last order by craplem.dtmvtolt) vllanmto
         FROM craplem craplem
        WHERE craplem.cdcooper = pr_cdcooper
          AND EXISTS (SELECT 1 
                        FROM craphis
                       WHERE craphis.cdcooper = craplem.cdcooper
                         AND craphis.cdhistor = craplem.cdhistor
                         AND craphis.indebcre = 'C')
       GROUP BY craplem.nrdconta,craplem.nrctremp;          
     -- Definicao do tipo de tabela para lançamentos     
     TYPE vr_typ_tab_craplem_bulk IS TABLE OF cr_craplem%ROWTYPE INDEX BY PLS_INTEGER;
     rw_craplem_bulk vr_typ_tab_craplem_bulk;
     
     /* Quando execução paralela, a query acima foi pre-gravada na tabela temporária */
     CURSOR cr_craplem_work(pr_cdcooper    crapepr.cdcooper%TYPE
                           ,pr_cdagenci    crapass.cdagenci%TYPE
                           ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                           ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                           ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT wrk.nrdconta
             ,wrk.nrctremp
             ,wrk.dtvencto dtmvtolt
             ,wrk.vltitulo vllanmto
         FROM tbgen_batch_relatorio_wrk wrk
             ,crapass ass
        WHERE wrk.cdcooper    = pr_cdcooper   
          AND wrk.cdprograma  = pr_cdprograma 
          AND wrk.dsrelatorio = pr_dsrelatorio
          AND wrk.dtmvtolt    = pr_dtmvtolt
          AND wrk.cdcooper = ass.cdcooper
          AND wrk.nrdconta = ass.nrdconta
          AND ass.cdagenci = pr_cdagenci; 

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

     -- Selecionar informacoes do bordero desconto cheque
     CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
                       ,pr_dtlibera IN crapcdb.dtlibera%TYPE
                       ,pr_insitchq IN crapcdb.insitchq%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT  /*+ INDEX (crapcdb crapcdb##crapcdb3) */
               crapcdb.nrdconta
              ,Nvl(Sum(Nvl(crapcdb.vlcheque,0)),0) vlcheque
         FROM crapcdb
             ,crapass
        WHERE crapass.cdcooper = crapcdb.cdcooper
          AND crapass.nrdconta = crapcdb.nrdconta
          AND crapcdb.cdcooper = pr_cdcooper
          AND crapcdb.dtlibera > pr_dtlibera
          AND crapcdb.insitchq = pr_insitchq
          AND crapcdb.dtdevolu IS NULL
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
       GROUP BY crapcdb.nrdconta;

     -- Selecionar informacoes dos borderos de desconto de titulos
     CURSOR cr_craptdb (pr_cdcooper IN crapcob.cdcooper%TYPE
                       ,pr_dtpagto  IN craptdb.dtdpagto%TYPE
                       ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
       SELECT craptdb.cdbandoc
             ,craptdb.nrdctabb
             ,craptdb.nrcnvcob
             ,craptdb.nrdconta
             ,craptdb.nrdocmto
             ,craptdb.vltitulo
             ,craptdb.insittit
             ,craptdb.rowid
             ,rownum
         FROM craptdb craptdb
             ,crapass crapass
        WHERE crapass.cdcooper = craptdb.cdcooper
          AND crapass.nrdconta = craptdb.nrdconta
          AND craptdb.cdcooper = pr_cdcooper
          AND (craptdb.insittit = 2 OR craptdb.insittit = 4)
          AND((craptdb.dtvencto >= pr_dtpagto AND craptdb.insittit = 4)
             OR(craptdb.dtdpagto =  pr_dtpagto AND craptdb.insittit = 2))
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

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
     
     -- Carregar motivos de demissão
     CURSOR cr_motivo IS
       SELECT A.CDMOTIVO
             ,A.DSMOTIVO
        FROM TBCOTAS_MOTIVO_DESLIGAMENTO A;
     
     -- Selecionar informacoes dos limites dos associados
     CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
       SELECT /*+ INDEX (craplim craplim##craplim1) */
              craplim.nrdconta
             ,Nvl(Sum(Nvl(craplim.vllimite,0)),0) vllimite
         FROM craplim craplim
             ,crapass crapass
        WHERE crapass.cdcooper = craplim.cdcooper
          AND crapass.nrdconta = craplim.nrdconta
          AND craplim.cdcooper = pr_cdcooper
          AND craplim.tpctrlim = 1
          AND craplim.insitlim = 2
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
        GROUP BY craplim.nrdconta;
        
     -- Dados das tabela de trabalho de dados TAB_TOTAL
     cursor cr_work_total(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                         ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                         ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                         ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT cdagenci
             ,to_number(gene0002.fn_busca_entrada(01,dscritic,';'),'fm999g999g999g999g990d00') age_qtassmes_adm
             ,to_number(gene0002.fn_busca_entrada(02,dscritic,';'),'fm999g999g999g999g990d00') age_qtcotist_ati
             ,to_number(gene0002.fn_busca_entrada(03,dscritic,';'),'fm999g999g999g999g990d00') age_qtcotist_dem
             ,to_number(gene0002.fn_busca_entrada(04,dscritic,';'),'fm999g999g999g999g990d00') age_qtcotist_exc
             ,to_number(gene0002.fn_busca_entrada(05,dscritic,';'),'fm999g999g999g999g990d00') tot_nrassmag
             ,to_number(gene0002.fn_busca_entrada(06,dscritic,';'),'fm999g999g999g999g990d00') tot_vlsmtrag
             ,to_number(gene0002.fn_busca_entrada(07,dscritic,';'),'fm999g999g999g999g990d00') tot_vlsmmes1
             ,to_number(gene0002.fn_busca_entrada(08,dscritic,';'),'fm999g999g999g999g990d00') tot_vlsmmes2
             ,to_number(gene0002.fn_busca_entrada(09,dscritic,';'),'fm999g999g999g999g990d00') tot_vlsmmes3
             ,to_number(gene0002.fn_busca_entrada(10,dscritic,';'),'fm999g999g999g999g990d00') tot_vlcaptal
             ,to_number(gene0002.fn_busca_entrada(11,dscritic,';'),'fm999g999g999g999g990d00') tot_nrdplaag
             ,to_number(gene0002.fn_busca_entrada(12,dscritic,';'),'fm999g999g999g999g990d00') tot_vlprepla
             ,to_number(gene0002.fn_busca_entrada(13,dscritic,';'),'fm999g999g999g999g990d00') tot_qtnrecad
             ,to_number(gene0002.fn_busca_entrada(14,dscritic,';'),'fm999g999g999g999g990d00') tot_qtadmiss
             ,to_number(gene0002.fn_busca_entrada(15,dscritic,';'),'fm999g999g999g999g990d00') tot_qtjrecad
             ,to_number(gene0002.fn_busca_entrada(16,dscritic,';'),'fm999g999g999g999g990d00') tot_qtctremp
             ,to_number(gene0002.fn_busca_entrada(17,dscritic,';'),'fm999g999g999g999g990d00') tot_vlpreemp
             ,to_number(gene0002.fn_busca_entrada(18,dscritic,';'),'fm999g999g999g999g990d00') tot_vlsdeved
             ,to_number(gene0002.fn_busca_entrada(19,dscritic,';'),'fm999g999g999g999g990d00') tot_vljurmes
             ,to_number(gene0002.fn_busca_entrada(20,dscritic,';'),'fm999g999g999g999g990d00') tot_qtassemp
             ,to_number(gene0002.fn_busca_entrada(21,dscritic,';'),'fm999g999g999g999g990d00') vlcapage_fis
             ,to_number(gene0002.fn_busca_entrada(22,dscritic,';'),'fm999g999g999g999g990d00') vlcapage_jur
             ,to_number(gene0002.fn_busca_entrada(23,dscritic,';'),'fm999g999g999g999g990d00') vlcapctz_fis
             ,to_number(gene0002.fn_busca_entrada(24,dscritic,';'),'fm999g999g999g999g990d00') vlcapctz_jur
             ,to_number(gene0002.fn_busca_entrada(25,dscritic,';'),'fm999g999g999g999g990d00') tot_pcap_fis
             ,to_number(gene0002.fn_busca_entrada(26,dscritic,';'),'fm999g999g999g999g990d00') tot_pcap_jur
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt 
        ORDER BY cdagenci; 
        
     -- Dados das tabela de trabalho de dados TYP_TAB_TOTAL
     cursor cr_work_typ_total(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                             ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                             ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                             ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT dschave
             ,sum(to_number(gene0002.fn_busca_entrada(01,dscritic,';'),'fm999g999g999g999g990d00')) dup_qtcotist_ati
             ,sum(to_number(gene0002.fn_busca_entrada(02,dscritic,';'),'fm999g999g999g999g990d00')) dup_qtcotist_dem
             ,sum(to_number(gene0002.fn_busca_entrada(03,dscritic,';'),'fm999g999g999g999g990d00')) dup_qtcotist_exc
             ,sum(to_number(gene0002.fn_busca_entrada(04,dscritic,';'),'fm999g999g999g999g990d00')) res_vlcapcrz_ati
             ,sum(to_number(gene0002.fn_busca_entrada(05,dscritic,';'),'fm999g999g999g999g990d00')) res_vlcapcrz_dem
             ,sum(to_number(gene0002.fn_busca_entrada(06,dscritic,';'),'fm999g999g999g999g990d00')) res_vlcapcrz_exc
             ,sum(to_number(gene0002.fn_busca_entrada(07,dscritic,';'),'fm999g999g999g999g990d00')) res_vlcapcrz_tot
             ,sum(to_number(gene0002.fn_busca_entrada(08,dscritic,';'),'fm999g999g999g999g990d00')) sub_vlcapcrz_ati
             ,sum(to_number(gene0002.fn_busca_entrada(09,dscritic,';'),'fm999g999g999g999g990d00')) sub_vlcapcrz_dem
             ,sum(to_number(gene0002.fn_busca_entrada(10,dscritic,';'),'fm999g999g999g999g990d00')) sub_vlcapcrz_exc
             ,sum(to_number(gene0002.fn_busca_entrada(11,dscritic,';'),'fm999g999g999g999g990d00')) sub_vlcapcrz_tot
             ,sum(to_number(gene0002.fn_busca_entrada(12,dscritic,';'),'fm999g999g999g999g990d00')) res_qtcotist_ati
             ,sum(to_number(gene0002.fn_busca_entrada(13,dscritic,';'),'fm999g999g999g999g990d00')) res_qtcotist_dem
             ,sum(to_number(gene0002.fn_busca_entrada(14,dscritic,';'),'fm999g999g999g999g990d00')) res_qtcotist_exc
             ,sum(to_number(gene0002.fn_busca_entrada(15,dscritic,';'),'fm999g999g999g999g990d00')) res_qtcotist_tot
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt
        GROUP BY dschave 
        ORDER BY dschave; 
     
     -- Dados das tabela de trabalho de dados vr_tab_debitos
     cursor cr_work_tab_debitos(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                               ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                               ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                               ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT dschave
             ,cdagenci
             ,nrdconta
             ,gene0002.fn_busca_entrada(01,dscritic,';') nmprimtl
             ,gene0002.fn_busca_entrada(02,dscritic,';') dtadmiss
             ,gene0002.fn_busca_entrada(03,dscritic,';') dtrefere
             ,to_number(gene0002.fn_busca_entrada(04,dscritic,';'),'fm999g999g999g999g990d00') vllanmto
             ,gene0002.fn_busca_entrada(05,dscritic,';') tplanmto
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt
        ORDER BY dschave; 
     
     -- Dados das tabela de trabalho de dados vr_tab_demitidos
     cursor cr_work_tab_demitidos(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                                 ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                                 ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                                 ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT dschave
             ,cdagenci
             ,nrdconta
             ,gene0002.fn_busca_entrada(01,dscritic,';') cdmotdem
             ,gene0002.fn_busca_entrada(02,dscritic,';') inmatric
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt
        ORDER BY dschave; 
     
     -- Dados das tabela de trabalho de dados vr_tab_totlcred
     cursor cr_work_tab_totlcred(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                                ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                                ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                                ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT dschave
             ,sum(vlacumul) vlacumul
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt
        GROUP BY dschave
        ORDER BY dschave; 
     
     -- Dados das tabela de trabalho de dados vr_tab_duplicados
     cursor cr_work_tab_duplicados(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                                  ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                                  ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                                  ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT dschave
             ,cdagenci
             ,nrdconta
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt
        ORDER BY dschave;   
        
     -- Dados dos totais gerais
     cursor cr_work_total_geral(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                               ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                               ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                               ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT SUM(to_number(gene0002.fn_busca_entrada(01,dscritic,';'),'fm999g999g999g999g990d00')) vr_dup_qtcotist_ati
             ,SUM(to_number(gene0002.fn_busca_entrada(02,dscritic,';'),'fm999g999g999g999g990d00')) vr_dup_qtcotist_dem
             ,SUM(to_number(gene0002.fn_busca_entrada(03,dscritic,';'),'fm999g999g999g999g990d00')) vr_dup_qtcotist_exc
             ,SUM(to_number(gene0002.fn_busca_entrada(04,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_vlcapcrz_ati
             ,SUM(to_number(gene0002.fn_busca_entrada(05,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_vlcapcrz_dem
             ,SUM(to_number(gene0002.fn_busca_entrada(06,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_vlcapcrz_exc_age
             ,SUM(to_number(gene0002.fn_busca_entrada(07,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_vlcapcrz_tot_age
             ,SUM(to_number(gene0002.fn_busca_entrada(08,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_qtcotist_ati
             ,SUM(to_number(gene0002.fn_busca_entrada(09,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_qtcotist_dem
             ,SUM(to_number(gene0002.fn_busca_entrada(10,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_qtcotist_exc_age
             ,SUM(to_number(gene0002.fn_busca_entrada(11,dscritic,';'),'fm999g999g999g999g990d00')) vr_res_qtcotist_tot_age
             ,SUM(to_number(gene0002.fn_busca_entrada(12,dscritic,';'),'fm999g999g999g999g990d00')) vr_sub_vlcapcrz_ati
             ,SUM(to_number(gene0002.fn_busca_entrada(13,dscritic,';'),'fm999g999g999g999g990d00')) vr_sub_vlcapcrz_dem
             ,SUM(to_number(gene0002.fn_busca_entrada(14,dscritic,';'),'fm999g999g999g999g990d00')) vr_sub_vlcapcrz_exc
             ,SUM(to_number(gene0002.fn_busca_entrada(15,dscritic,';'),'fm999g999g999g999g990d00')) vr_sub_vlcapcrz_tot
             ,SUM(to_number(gene0002.fn_busca_entrada(16,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_lancamen
             ,SUM(to_number(gene0002.fn_busca_entrada(17,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_vllanmto
             ,SUM(to_number(gene0002.fn_busca_entrada(18,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_capagefis   
             ,SUM(to_number(gene0002.fn_busca_entrada(19,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_capagejur   
             ,SUM(to_number(gene0002.fn_busca_entrada(20,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_vlcapctz_fis
             ,SUM(to_number(gene0002.fn_busca_entrada(21,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_vlcapctz_jur
             ,SUM(to_number(gene0002.fn_busca_entrada(22,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_pcapcred_fis
             ,SUM(to_number(gene0002.fn_busca_entrada(23,dscritic,';'),'fm999g999g999g999g990d00')) vr_tot_pcapcred_jur
             ,SUM(to_number(gene0002.fn_busca_entrada(24,dscritic,';'),'fm999g999g999g999g990d00')) vr_desconto
             ,SUM(to_number(gene0002.fn_busca_entrada(25,dscritic,';'),'fm999g999g999g999g990d00')) vr_desctitu
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt; 
      
     --- ################################ SubRotinas ################################# ----
     
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
       vr_tab_vlcapage_fis(pr_cdagenci):= 0;
       vr_tab_vlcapage_jur(pr_cdagenci):= 0;
       vr_tab_vlcapctz_fis(pr_cdagenci):= 0;
       vr_tab_vlcapctz_jur(pr_cdagenci):= 0;
       vr_tab_tot_pcap_fis(pr_cdagenci):= 0;
       vr_tab_tot_pcap_jur(pr_cdagenci):= 0;
       -- Inicializar totalizador de motivos para relatorio 421
       vr_tab_rel_qttotmot.delete();
     EXCEPTION
       WHEN OTHERS THEN
         -- Variavel de erro recebe erro ocorrido
         vr_dscritic:= 'Erro ao limpar zerar tabela de memória. Rotina pc_crps010.pc_inicializa_tabela. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     -- Verificar os emprestimos do associado
     PROCEDURE pc_verifica_lancto_emprestimo (pr_idx_crapepr IN VARCHAR2
                                             ,pr_vlsdeved    IN crapepr.vlsdeved%TYPE
                                             ,pr_dtultpagto OUT DATE
                                             ,pr_vlultpagto OUT NUMBER
                                             ,pr_vlprovisao OUT NUMBER
                                             ,pr_nivelrisco OUT NUMBER
                                             ,pr_des_erro   OUT VARCHAR2) IS
     
     BEGIN
       -- Atribuir nulo para data ultimo pagamento
       pr_dtultpagto:= null;
       -- Atribuir zero para valor ultimo pagamento
       pr_vlultpagto:= 0;
       -- Atribuir zero para valor provisao
       pr_vlprovisao:= 0;
       -- Atribuir zero para nivel risco
       pr_nivelrisco:= 0;

       -- Verificar se existe lancamento para o contrato
       pr_dtultpagto := vr_tab_crapepr(pr_idx_crapepr).dtmvtlem;
       pr_vlultpagto := vr_tab_crapepr(pr_idx_crapepr).vllanlem;
       
       /* calcular o valor da provisao e pegar o nivel de risco */
       IF vr_tab_craptab.EXISTS(vr_tab_crapepr(pr_idx_crapepr).dsnivcal) THEN
         -- Retonar valor da provisao
         pr_vlprovisao := (pr_vlsdeved * vr_tab_craptab(vr_tab_crapepr(pr_idx_crapepr).dsnivcal).vl_provisao) / 100;
         -- Retonar nivel de risco
         pr_nivelrisco := vr_tab_craptab(vr_tab_crapepr(pr_idx_crapepr).dsnivcal).vl_nivelrisco;
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         pr_des_erro:= 'Erro ao verificar lancamentos emprestimos. Rotina pc_verifica_lancto_emprestimo. '||SQLERRM;
     END;
     
     -- Monta nome dos meses e inicializa resumo do capital.
     PROCEDURE PC_CRPS010_1 (pr_dtmvtolt         IN crapdat.dtmvtolt%TYPE  --Data da utilizacao atual
                            ,pr_rel_nomemes1     OUT VARCHAR2  --Nome do mes 1
                            ,pr_rel_nomemes2     OUT VARCHAR2  --Nome do mes 2
                            ,pr_rel_nomemes3     OUT VARCHAR2  --Nome do mes 3
                            ,pr_cdcritic         OUT NUMBER -- Código de critica
                            ,pr_des_erro         OUT VARCHAR2) IS --Mensagem de Erro

    BEGIN
    /* ..........................................................................

       Programa: pc_crps010_1                        Antigo: fontes/crps010_1.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Abril/95.                           Ultima atualizacao: 21/06/2016

       Dados referentes ao programa:

       Frequencia: Mensal (Batch - Background).
       Objetivo  : Monta nome dos meses e inicializa resumo do capital.

       Alteracoes: 09/04/2001 - Tratar a tabela de VALORBAIXA somente nos meses
                                6 e 12 (Deborah).

                   14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   12/03/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

                   21/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                                SD 470740.(Carlos Rafael Tanholi).     
                  
                   05/01/2017 - Ajustado para não parar o processo em caso de parâmetro
                                nulo. (Rodrigo - 586601)   
    ............................................................................. */
      DECLARE

        --Variaveis Locais
        vr_dscritic     VARCHAR2(4000);

      BEGIN
        --Encontrar o mes do movimento e determinar os meses
        CASE To_Number(To_Char(pr_dtmvtolt,'MM'))
          WHEN 1 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(01);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(12);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(11);
          WHEN 2 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(02);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(01);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(12);
          WHEN 3 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(03);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(02);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(01);
          WHEN 4 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(04);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(03);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(02);
          WHEN 5 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(05);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(04);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(03);
          WHEN 6 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(06);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(05);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(04);
          WHEN 7 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(07);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(06);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(05);
          WHEN 8 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(08);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(07);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(06);
          WHEN 9 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(09);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(08);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(07);
          WHEN 10 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(10);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(09);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(08);
          WHEN 11 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(11);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(10);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(09);
          WHEN 12 THEN
           pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(12);
           pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(11);
           pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(10);
        END CASE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := nvl(pr_cdcritic,0);
          pr_des_erro := vr_dscritic;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro na rotina pc_crps010_1. '||SQLERRM;
      END;
    END PC_CRPS010_1;
    
    -- Monta nome dos meses e inicializa resumo do capital.
    PROCEDURE PC_INIC_CAPITAL(pr_cdcooper         IN crapcop.cdcooper%TYPE  --Código da Cooperativa
                             ,pr_dtmvtolt         IN crapdat.dtmvtolt%TYPE  --Data da utilizacao atual
                             ,pr_res_qtassati     OUT NUMBER --Qtdade Associados mes anterior ativos
                             ,pr_res_qtassdem     OUT NUMBER --Qtdade Associados mes anterior demitidos
                             ,pr_res_qtassmes     OUT NUMBER --Qtdade Associados adimitidos
                             ,pr_res_qtdemmes_ati OUT NUMBER --Qtdade Associados mes ativo
                             ,pr_res_qtdemmes_dem OUT NUMBER --Qtdade Associados mes demitido
                             ,pr_res_qtassbai     OUT NUMBER --Qtdade Associados baixados
                             ,pr_res_qtdesmes_ati OUT NUMBER --Qtdade de Desdemissoes ativo
                             ,pr_res_qtdesmes_dem OUT NUMBER --Qtdade de Desdemissoes demitido
                             ,pr_res_vlcapcrz_exc OUT NUMBER --Valor Capital
                             ,pr_res_vlcapexc_fis OUT NUMBER --Valor Capital por PF
                             ,pr_res_vlcapexc_jur OUT NUMBER --Valor Capital por PJ                                                  
                             ,pr_res_vlcmicot_exc OUT NUMBER --Valor Cota CMI
                             ,pr_res_vlcmmcot_exc OUT NUMBER --Valor cota CMM
                             ,pr_res_vlcapmfx_exc OUT NUMBER --Valor Capital moeda fixa
                             ,pr_res_qtcotist_exc OUT NUMBER --Quantidade Cotistas Excluidos
                             ,pr_res_qtcotexc_fis OUT NUMBER --Quantidade Cotistas Excluidos por PF
                             ,pr_res_qtcotexc_jur OUT NUMBER --Quantidade Cotistas Excluidos por PJ                                                  
                             ,pr_res_vlcapcrz_tot OUT NUMBER --Valor Capital Total
                             ,pr_res_vlcaptot_fis OUT NUMBER --Valor Capital Total por PF
                             ,pr_res_vlcaptot_jur OUT NUMBER --Valor Capital Total por PJ
                             ,pr_res_vlcmicot_tot OUT NUMBER --Valor Cota CMI Total
                             ,pr_res_vlcmmcot_tot OUT NUMBER --Valor Cota CMM Total
                             ,pr_res_vlcapmfx_tot OUT NUMBER --Valor Capital moeda fixa Total
                             ,pr_res_qtcotist_tot OUT NUMBER --Quantidade Total Cotistas
                             ,pr_res_qtcottot_fis OUT NUMBER --Quantidade Total Cotistas por PF
                             ,pr_res_qtcottot_jur OUT NUMBER --Quantidade Total Cotistas por PJ
                             ,pr_tot_qtassati     OUT NUMBER --Total associados ativos
                             ,pr_tot_qtassdem     OUT NUMBER --Total associados demitidos
                             ,pr_tot_qtassexc     OUT NUMBER --Total associados excluidos
                             ,pr_tot_qtasexpf     OUT NUMBER --Total associados excluidos
                             ,pr_tot_qtasexpj     OUT NUMBER --Total associados excluidos
                             ,pr_cdcritic         OUT NUMBER -- Código de critica
                             ,pr_des_erro         OUT VARCHAR2) IS --Mensagem de Erro
     BEGIN
     /* ..........................................................................
    
        Programa: PC_INIC_CAPITAL                     
        Sistema : Conta-Corrente - Cooperativa de Credito
        Sigla   : CRED
        Autor   : Deborah/Edson
        Data    : Abril/95.                           Ultima atualizacao: 
    
        Dados referentes ao programa:
    
        Frequencia: Mensal (Batch - Background).
        Objetivo  : Inicializa resumo do capital.
    
        Alteracoes: 
        
     ............................................................................. */
       DECLARE
    
         --Selecionar informacoes das Matriculas
         CURSOR cr_crapmat (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
           SELECT crapmat.cdcooper
                 ,crapmat.qtassati
                 ,crapmat.qtassdem
                 ,crapmat.qtassmes
                 ,crapmat.qtdemmes
                 ,crapmat.qtdesmes
                 ,crapmat.qtassbai
                 ,crapmat.qtasbxpf
                 ,crapmat.qtasbxpj
           FROM crapmat crapmat
           WHERE crapmat.cdcooper = pr_cdcooper
           ORDER BY crapmat.progress_recid ASC;
         rw_crapmat cr_crapmat%ROWTYPE;
    
         --Variaveis Locais
         vr_dscritic     VARCHAR2(4000);
         -- Guardar registro dstextab
         vr_dstextab craptab.dstextab%TYPE;
         vr_flgfound BOOLEAN := TRUE;
    
       BEGIN
         --Selecionar a primeira matricula
         OPEN cr_crapmat (pr_cdcooper => pr_cdcooper);
         --Posicionar no primeiro registro
         FETCH cr_crapmat INTO rw_crapmat;
         --Se nao encontrou
         IF cr_crapmat%NOTFOUND THEN
           --Fechar Cursor
           CLOSE cr_crapmat;
           -- Montar mensagem de critica
           pr_cdcritic := 71;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 71);
           RAISE vr_exc_saida;
         ELSE
           --Fechar Cursor
           CLOSE cr_crapmat;
           --Qtdade Associados mes anterior ativos recebe valor encontrado
           pr_res_qtassati:= rw_crapmat.qtassati;
           --Qtdade Associados mes anterior demitidos recebe valor encontrado
           pr_res_qtassdem:= rw_crapmat.qtassdem;
           --Qtdade Associados adimitidos rece valor encontrado
           pr_res_qtassmes:= rw_crapmat.qtassmes;
           --Qtdade Associados mes ativo recebe valor encontrado
           pr_res_qtdemmes_ati:= rw_crapmat.qtdemmes;
           --Qtdade Associados mes demitido recebe valor encontrado
           pr_res_qtdemmes_dem:= rw_crapmat.qtdemmes;
           --Qtdade Associados baixados recebe valor encontrado
           pr_res_qtassbai:= rw_crapmat.qtassbai;
           --Qtdade de Desdemissoes ativo recebe valor encontrado
           pr_res_qtdesmes_ati:= rw_crapmat.qtdesmes;
           --Qtdade de Desdemissoes demitido recebe valor encontrado
           pr_res_qtdesmes_dem:= rw_crapmat.qtdesmes;
           --Total associados ativos recebe associados ativos + associados mes - desassociados - demitidos
           pr_tot_qtassati:= Nvl(rw_crapmat.qtassati,0) + Nvl(rw_crapmat.qtassmes,0) +
                             Nvl(rw_crapmat.qtdesmes,0) - Nvl(rw_crapmat.qtdemmes,0);
           --Total associados demitidos recebe demitidos + demitidos mes - desdemitidos mes - baixados
           pr_tot_qtassdem:= Nvl(rw_crapmat.qtassdem,0) + Nvl(rw_crapmat.qtdemmes,0) -
                             Nvl(rw_crapmat.qtdesmes,0) - Nvl(rw_crapmat.qtassbai,0);
           --Total associados excluidos recebe baixados
           pr_tot_qtassexc:= rw_crapmat.qtassbai;
           --Total de associados PF excluidos recebe baixados
           pr_tot_qtasexpf:= rw_crapmat.qtasbxpf;
           --Total de associados PJ excluidos recebe baixados
           pr_tot_qtasexpj:= rw_crapmat.qtasbxpj;
         END IF;
    
         --Se o mes de atualização for Junho ou Dezembro
         IF To_Number(To_Char(pr_dtmvtolt,'MM')) IN (6,12) THEN
    
            -- Buscar configuração na tabela
            TABE0001.pc_busca_craptab(pr_cdcooper => pr_cdcooper
                                     ,pr_nmsistem => 'CRED'
                                     ,pr_tptabela => 'GENERI'
                                     ,pr_cdempres => 0
                                     ,pr_cdacesso => 'VALORBAIXA'
                                     ,pr_tpregist => 0
                                     ,pr_flgfound => vr_flgfound
                                     ,pr_dstextab => vr_dstextab);
            
            --Se nao encontrou entao
            IF NOT vr_flgfound THEN
              -- Montar mensagem de critica
              pr_cdcritic := 409;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 409);
              RAISE vr_exc_saida;
            ELSE
              --Valor Capital recebe valor tabela
              pr_res_vlcapcrz_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,001,016));
              --Valor Cota CMI recebe valor tabela
              pr_res_vlcmicot_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,018,016));
              --Valor cota CMM recebe valor tabela
              pr_res_vlcmmcot_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,035,016));
              --Valor Capital moeda fixa recebe valor tabela
              pr_res_vlcapmfx_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,052,016));
              --Valor Capital recebe valor tabela por PF
              pr_res_vlcapexc_fis:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,069,016));
              --Valor Capital recebe valor tabela por PJ
              pr_res_vlcapexc_jur:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,086,016));           
              --Quantidade Cotistas excluidos recebe total associados excluidos
              pr_res_qtcotist_exc:= pr_tot_qtassexc;
              --Quantidade Cotistas excluidos recebe total associados excluidos por PF
              pr_res_qtcotexc_fis:= pr_tot_qtasexpf;
              --Quantidade Cotistas excluidos recebe total associados excluidos por PJ
              pr_res_qtcotexc_jur:= pr_tot_qtasexpj;
              --Valor Capital Total recebe valor capital excluido
              pr_res_vlcapcrz_tot:= pr_res_vlcapcrz_exc;
              --Valor Capital Total recebe valor capital excluido por PF
              pr_res_vlcaptot_fis:= pr_res_vlcapexc_fis;
              --Valor Capital Total recebe valor capital excluido por PJ
              pr_res_vlcaptot_jur:= pr_res_vlcapexc_jur;
              --Valor Cota CMI Total recebe valor cmicot excluido
              pr_res_vlcmicot_tot:= pr_res_vlcmicot_exc;
              --Valor Cota CMM Total recebe valor cmmcot excluido
              pr_res_vlcmmcot_tot:= pr_res_vlcmmcot_exc;
              --Valor Capital moeda fixa Total recebe valor capital moeda fixa excluido
              pr_res_vlcapmfx_tot:= pr_res_vlcapmfx_exc;
              --Quantidade Total Cotistas recebe total associados excluidos
              pr_res_qtcotist_tot:= pr_tot_qtassexc;
              --Quantidade Total Cotistas recebe total associados excluidos por PF
              pr_res_qtcottot_fis:= pr_tot_qtasexpf;
              --Quantidade Total Cotistas recebe total associados excluidos por PJ
              pr_res_qtcottot_jur:= pr_tot_qtasexpj;
            END IF;
         ELSE
           --Valor Capital recebe zero
           pr_res_vlcapcrz_exc:= 0;
           --Valor Capital recebe zero por PF
           pr_res_vlcapexc_fis:= 0;
           --Valor Capital recebe zero por PJ
           pr_res_vlcapexc_jur:= 0;        
           --Valor Cota CMI recebe zero
           pr_res_vlcmicot_exc:= 0;
           --Valor cota CMM recebe zero
           pr_res_vlcmmcot_exc:= 0;
           --Valor Capital moeda fixa recebe zero
           pr_res_vlcapmfx_exc:= 0;
           --Quantidade Cotistas excluidos recebe zero
           pr_res_qtcotist_exc:= 0;
           --Quantidade Cotistas excluidos recebe zero por PF        
           pr_res_qtcotexc_fis:= 0;
           --Quantidade Cotistas excluidos recebe zero por PJ
           pr_res_qtcotexc_jur:= 0;
           --Valor Capital Total recebe zero
           pr_res_vlcapcrz_tot:= 0;
           --Valor Capital Total recebe zero por PF
           pr_res_vlcaptot_fis:= 0;
           --Valor Capital Total recebe zero por PJ
           pr_res_vlcaptot_jur:= 0;
           --Valor Cota CMI Total recebe zero
           pr_res_vlcmicot_tot:= 0;
           --Valor Cota CMM Total recebe zero
           pr_res_vlcmmcot_tot:= 0;
           --Valor Capital moeda fixa Total recebe zero
           pr_res_vlcapmfx_tot:= 0;
           --Quantidade Total Cotistas recebe zero
           pr_res_qtcotist_tot:= 0;
           --Quantidade Total Cotistas recebe zero por PF
           pr_res_qtcottot_fis:= 0;
           --Quantidade Total Cotistas recebe zero por PJ
           pr_res_qtcottot_jur:= 0;
         END IF;
       EXCEPTION
         WHEN vr_exc_saida THEN
           pr_cdcritic := nvl(pr_cdcritic,0);
           pr_des_erro := vr_dscritic;
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_des_erro := 'Erro na rotina PC_INIC_CAPITAL. '||SQLERRM;
       END;
     END PC_INIC_CAPITAL;
     
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

        /* Gerar arquivo com todos os PACs */
        vr_nom_arquivo := 'crrl031';
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_clob_xml, TRUE);
        dbms_lob.open(vr_clob_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl031><totais>');
        
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<tot1>
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<tot2>
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</totais><agencias>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper) LOOP

           -- Se existir cotistas para a agencia
           IF vr_tab_age_qtcotist_ati.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_age_qtcotist_dem.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_age_qtassmes_adm.EXISTS(rw_crapage.cdagenci) THEN

              -- Verificar se tem todas as informacoes nulas
              IF vr_tab_age_qtcotist_ati(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_age_qtcotist_dem(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_age_qtassmes_adm(rw_crapage.cdagenci) <> 0 THEN

                 -- Montar tag da conta para arquivo XML
                 gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                        ,pr_texto_completo => vr_text_xml
                                        ,pr_texto_novo     => '<agencia>
                                                                  <dsagenci>'||LPad(rw_crapage.cdagenci,3,'0')||' - '||rw_crapage.nmresage||'</dsagenci>
                                                                  <ati>'||vr_tab_age_qtcotist_ati(rw_crapage.cdagenci)||'</ati>
                                                                  <ina>'||vr_tab_age_qtcotist_dem(rw_crapage.cdagenci)||'</ina>
                                                                  <adm>'||vr_tab_age_qtassmes_adm(rw_crapage.cdagenci)||'</adm>
                                                               </agencia>');
              END IF;
           END IF;

        END LOOP;

        -- Finalizar agrupador agencias e iniciar o de pacs
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</agencias><pacs tot_lancamen="'||To_Char(vr_tot_lancamen,'fm999g990')||
                                                     '" tot_vllanmto="'||To_Char(vr_tot_vllanmto,'fm999g999g990d00')||'">');

        -- Processar tabela de memoria de debitos
        vr_des_chave:= vr_tab_debitos.FIRST;
        -- Enquanto o registro nao for nulo
        WHILE vr_des_chave IS NOT NULL LOOP
           -- Montar tag da conta para arquivo XML
           -- Inicilizar as informações do XML
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                  ,pr_texto_completo => vr_text_xml
                                  ,pr_texto_novo     => '<pac>
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</pacs></crrl031>'
                               ,pr_fecha_xml      => TRUE);

        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_clob_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl031'          --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl031.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 4                   --> Número de cópias
                                   ,pr_flg_gerar => vr_flg_gerar        --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic);       --> Saída com erro
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_saida;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clob_xml);
        dbms_lob.freetemporary(vr_clob_xml);

     EXCEPTION
        WHEN vr_exc_saida THEN
           pr_des_erro:= vr_dscritic;
        WHEN OTHERS THEN
           cecred.pc_internal_exception;
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
        rw_crapage2 cr_crapage%ROWTYPE;

        -- Variaveis de Controle
        vr_cdmotdem     NUMBER;
        vr_rel_qtmotdem NUMBER;
        vr_rel_qtdempac NUMBER;
        vr_rel_qttotdup NUMBER;
        vr_dsmotdem     VARCHAR2(100);
        vr_rel_nmmesref VARCHAR2(20);

        -- Variaveis de Email
        vr_email_dest VARCHAR2(400);
        vr_des_assunto VARCHAR2(400);

        -- Variavel de Arquivo Texto
        vr_nmarqtxt   VARCHAR2(100):= 'crrl421.txt';

     BEGIN

        /* Gerar arquivo com todos os PACs */

        -- Determinar o nome do arquivo que será gerado
        vr_nom_arquivo := 'crrl421';
        -- Inicializar os CLOBs
        dbms_lob.createtemporary(vr_clob_xml, TRUE);
        dbms_lob.open(vr_clob_xml, dbms_lob.lob_readwrite);
        dbms_lob.createtemporary(vr_clob_arq, TRUE);
        dbms_lob.open(vr_clob_arq, dbms_lob.lob_readwrite);

        -- Inicializar variaveis de totalizador
        vr_rel_qtmotdem:= 0;
        vr_rel_qtdempac:= 0;
        vr_rel_qttotdup:= 0;
        -- Nome mes referencia recebe descricao do mes da data atual
        vr_rel_nmmesref:= GENE0001.vr_vet_nmmesano(To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')))
                                                   ||'/'||To_Char(rw_crapdat.dtmvtolt,'YYYY');

        -- Inicilizar as informações do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl421>'||'<motivos ref="'||vr_rel_nmmesref||'">');

        -- Escrever o cabecalho no arquivo
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                               ,pr_texto_completo => vr_text_arq
                               ,pr_texto_novo     => 'PA;MOTIVO;CONTA/DV'||chr(13));  --> Texto para escrita

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
              OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => vr_tab_demitidos(vr_des_chave).cdagenci);
              -- Posicionar no proximo registro
              FETCH cr_crapage INTO rw_crapage2;
              -- Se nao encontrar
              IF cr_crapage%NOTFOUND THEN
                rw_crapage2.cdagenci:= vr_tab_demitidos(vr_des_chave).cdagenci;
                rw_crapage2.nmresage:= 'NAO ENCONTRADA';
              END IF;
              --Fechar Cursor
              CLOSE cr_crapage;
           END IF;

           -- Se estivermos processando o primeiro registro do vetor ou mudou o MOTIVO ou Agencia
           IF vr_des_chave = vr_tab_demitidos.FIRST OR
              vr_tab_demitidos(vr_des_chave).cdmotdem <> vr_tab_demitidos(vr_tab_demitidos.PRIOR(vr_des_chave)).cdmotdem OR
              vr_tab_demitidos(vr_des_chave).cdagenci <> vr_tab_demitidos(vr_tab_demitidos.PRIOR(vr_des_chave)).cdagenci THEN
              -- Zerar a quantidade de demitidos no pac
              vr_rel_qtmotdem:= 0;
           END IF;

           -- Escrever os detalhes no arquivo de dados
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_tab_demitidos(vr_des_chave).cdagenci||';'||
                                                        vr_tab_demitidos(vr_des_chave).cdmotdem||';'||
                                                        gene0002.fn_mask_conta(vr_tab_demitidos(vr_des_chave).nrdconta)||chr(13));  --> Texto para escrita

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
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                     ,pr_texto_completo => vr_text_xml
                                     ,pr_texto_novo     => '<motivo>
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</motivos><total_motivos ref="'||vr_rel_nmmesref||'" dup="'||To_Char(nvl(vr_rel_qttotdup,0),'fm999g999g990')||'">');

        --Somente se encontrar algum registro
        IF vr_tab_rel_qttotmot.count() > 0 THEN 
          
          -- Percorrer todos os motivos
          FOR idx IN vr_tab_rel_qttotmot.FIRST..vr_tab_rel_qttotmot.LAST LOOP

            --Inicializa variável
            vr_dsmotdem := '';
          
            IF vr_tab_rel_qttotmot.EXISTS(idx) THEN
               
              -- Verificar se existe o motivo da demissao
              IF vr_tab_craptab_motivo.EXISTS(idx) THEN
                -- Atribuir a descricao do motivo
                vr_dsmotdem:= vr_tab_craptab_motivo(idx);
              END IF;
               
              -- Montar tag da conta para arquivo XML
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                     ,pr_texto_completo => vr_text_xml
                                     ,pr_texto_novo     => '<tot_motivo>
                                                               <tot_dsmotdem>'||idx||' - '||vr_dsmotdem||'</tot_dsmotdem>
                                                               <tot_qttotmot>'||vr_tab_rel_qttotmot(idx)||'</tot_qttotmot>
                                                            </tot_motivo>');
                               
            END IF;
             
          END LOOP;
          
        END IF;

        -- Finalizar agrupador total motivos e criar total geral e duplicadas
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</total_motivos></crrl421>'
                               ,pr_fecha_xml      => TRUE);

        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_clob_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl421'          --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl421.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 80                  --> colunas
                                   ,pr_sqcabrel  => 4                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '80d'               --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 2                   --> Número de cópias
                                   ,pr_flg_gerar => vr_flg_gerar        --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic);       --> Saída com erro

        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_saida;
        END IF;
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clob_xml);
        dbms_lob.freetemporary(vr_clob_xml);
        
        -- Fechar Arquivo dados
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                               ,pr_texto_completo => vr_text_arq
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);

        -- Enviar email se for viacredi
        IF pr_cdcooper = 1 THEN
           -- Recuperar emails de destino
           vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL421_DETALHADO');
           -- Verificar se nao existe email cadastrado
           IF vr_email_dest IS NULL THEN
              -- Montar mensagem de erro
              vr_dscritic:= 'Não foi encontrado destinatário para relatório 421.';
              -- Levantar Exceção
              RAISE vr_exc_saida;
           END IF;
           -- Montar assunto
           vr_des_assunto := 'RELATORIO 421 - DETALHADO';
        END IF;
        
        -- Solicitar geração do arquivo txt
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper   => pr_cdcooper                       --> Cooperativa conectada
                                           ,pr_cdprogra   => vr_cdprogra                       --> Programa chamador
                                           ,pr_dtmvtolt   => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                           ,pr_dsxml      => vr_clob_arq                       --> Arquivo XML de dados
                                           ,pr_cdrelato   => '421'                             --> Código do relatório
                                           ,pr_dsarqsaid  => vr_nom_direto||'/'||vr_nmarqtxt   --> Arquivo final com o path
                                           ,pr_flg_gerar  => vr_flg_gerar                      --> Não gerar na hora
                                           ,pr_flgremarq  => 'N'                               --> Após cópia, remover arquivo de origem
                                           ,pr_dsmailcop  => vr_email_dest                     --> Email de envio
                                           ,pr_dsassmail  => vr_des_assunto                    --> Assunto do Email
                                           ,pr_des_erro   => vr_dscritic);
        -- Liberar memória alocada
        dbms_lob.close(vr_clob_arq);
        dbms_lob.freetemporary(vr_clob_arq);
        
        -- Se houve erro na geração
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
     EXCEPTION
       WHEN vr_exc_saida THEN
         pr_des_erro:= vr_dscritic;
       WHEN OTHERS THEN
         cecred.pc_internal_exception;
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

        -- Selecionar informacoes das Transferencias
        CURSOR cr_craptrf (pr_cdcooper IN craptrf.cdcooper%TYPE
                          ,pr_nrdconta IN craptrf.nrdconta%TYPE) IS
           SELECT craptrf.nrdconta
                 ,crapass.cdagenci
             FROM craptrf craptrf
                 ,crapass crapass
            WHERE craptrf.cdcooper = crapass.cdcooper
              AND craptrf.nrdconta = crapass.nrdconta
              AND craptrf.cdcooper = pr_cdcooper
              AND craptrf.nrsconta = pr_nrdconta;
        rw_craptrf cr_craptrf%ROWTYPE;
        
        -- Buscar telefones
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

     BEGIN

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
             dbms_lob.createtemporary(vr_clob_xml, TRUE);
             dbms_lob.open(vr_clob_xml, dbms_lob.lob_readwrite);
             -- Inicilizar as informações do XML com a agencia
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                    ,pr_texto_completo => vr_text_xml
                                    ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl426>'||
                                                          '<agencia cdagenci="'||vr_cdagenci||'"><contas>');
          END IF;

          /* Validar Informacoes */

          -- Inicializar codigo da critica
          vr_cdcritic:= 0;

          -- Selecionar informacoes do associado
          vr_idx_crapass := lpad(vr_tab_duplicados(vr_des_chave).cdagenci,5,'0') || lpad(vr_tab_duplicados(vr_des_chave).nrdconta,10,'0');
          IF NOT vr_tab_crapass.EXISTS(vr_idx_crapass) THEN
             -- Codigo da critica
             vr_cdcritic:= 9;
             rw_crapass.nrdconta:= vr_tab_duplicados(vr_des_chave).nrdconta;
          ELSE
             rw_crapass.nrdconta:= vr_tab_duplicados(vr_des_chave).nrdconta;
             rw_crapass.nmprimtl:= vr_tab_crapass(vr_idx_crapass).nmprimtl;
             rw_crapass.nrmatric:= vr_tab_crapass(vr_idx_crapass).nrmatric;
          END IF;

          -- Selecionar informacoes das cotas
          IF NOT vr_tab_crapcot.EXISTS(rw_crapass.nrdconta) THEN
            -- Codigo da critica
            vr_cdcritic:= 169;
          END IF;

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
          vr_idx_crapass := lpad(rw_craptrf.cdagenci,5,'0') || lpad(rw_craptrf.nrdconta,10,'0');
          IF NOT vr_tab_crapass.EXISTS(vr_idx_crapass) THEN
             -- Codigo da critica
             vr_cdcritic:= 9;
             rw_crabass.nrdconta:= rw_craptrf.nrdconta;
          ELSE
             rw_crabass.nrdconta:= rw_craptrf.nrdconta;
             rw_crabass.nmprimtl:= vr_tab_crapass(vr_idx_crapass).nmprimtl;
             rw_crabass.nrmatric:= vr_tab_crapass(vr_idx_crapass).nrmatric;
          END IF;

          vr_nrfonres := NULL;
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
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                    ,pr_texto_completo => vr_text_xml
                                    ,pr_texto_novo     => '<conta>
                                                              <nrdconta>'||LTrim(gene0002.fn_mask_conta(rw_crapass.nrdconta))||'</nrdconta>
                                                              <nmprimtl><![CDATA['||substr(rw_crapass.nmprimtl,1,21)||']]></nmprimtl>
                                                              <nrfonres>'||vr_nrfonres||'</nrfonres>
                                                              <nrfonemp>'||vr_nrfonemp||'</nrfonemp>
                                                              <vldcotas>'||To_Char(vr_tab_crapcot(rw_crapass.nrdconta).vldcotas,'fm999g999g990d00')||'</vldcotas>
                                                              <nrmatric>'||LTrim(gene0002.fn_mask_matric(rw_crabass.nrmatric))||'</nrmatric>
                                                              <nrdconta_trf>'||LTrim(gene0002.fn_mask_conta(rw_craptrf.nrdconta))||'</nrdconta_trf>
                                                              <nmprimtl_ori><![CDATA['||substr(rw_crabass.nmprimtl,1,19)||']]></nmprimtl_ori>
                                                           </conta>');
          END IF;

          -- Se este for o ultimo registro do vetor, ou da agência
          IF vr_des_chave = vr_tab_duplicados.LAST OR vr_tab_duplicados(vr_des_chave).cdagenci <> vr_tab_duplicados(vr_tab_duplicados.NEXT(vr_des_chave)).cdagenci THEN

             -- Finalizar o agrupador de contas, agencia e do relatorio
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                    ,pr_texto_completo => vr_text_xml
                                    ,pr_texto_novo     => '</contas></agencia></crrl426>'
                                    ,pr_fecha_xml      => TRUE);

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                        ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                        ,pr_dsxml     => vr_clob_xml          --> Arquivo XML de dados
                                        ,pr_dsxmlnode => '/crrl426/agencia/contas/conta' --> Nó base do XML para leitura dos dados
                                        ,pr_dsjasper  => 'crrl426.jasper'    --> Arquivo de layout do iReport
                                        ,pr_dsparams  => NULL                --> Sem parametros
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                        ,pr_qtcoluna  => 132                 --> 132 colunas
                                        ,pr_sqcabrel  => 5                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                        ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                        ,pr_flg_gerar => vr_flg_gerar        --> gerar PDF
                                        ,pr_des_erro  => vr_dscritic);       --> Saída com erro

             -- Testar se houve erro
             IF vr_dscritic IS NOT NULL THEN
                -- Gerar exceção
                RAISE vr_exc_saida;
             END IF;
             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_clob_xml);
             dbms_lob.freetemporary(vr_clob_xml);

          END IF;

          -- Buscar o próximo registro da tabela
          vr_des_chave := vr_tab_duplicados.NEXT(vr_des_chave);

       END LOOP;

     EXCEPTION
       WHEN vr_exc_saida THEN
         pr_des_erro:= vr_dscritic;
       WHEN OTHERS THEN
         cecred.pc_internal_exception;
         pr_des_erro:= 'Erro ao imprimir relatório pc_crps010_4. '||sqlerrm;
     END;


     -- Geracao do relatorio 398
     PROCEDURE pc_imprime_crrl398 (pr_des_erro OUT VARCHAR2) IS

        -- Variaveis Locais
        vr_idx_crapsld  NUMBER;
        vr_limite       NUMBER:= 0;
        vr_limite_conta NUMBER:= 0;
        vr_totgeral     NUMBER:= 0;

     BEGIN

        -- Determinar o nome do arquivo que será gerado
        vr_nom_arquivo := 'crrl398';
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_clob_xml, TRUE);
        dbms_lob.open(vr_clob_xml, dbms_lob.lob_readwrite);
        -- Inicializar as informações do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl398><linhas>');
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
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<linha>
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</linhas><saldos>');

        /*-- Cheque especial --*/

        -- Zerar Valor do limite
        vr_limite:= 0;
        --Processar todos os saldos dos associados
        vr_idx_crapsld := vr_tab_crapsld.first;
        LOOP
           -- Sair quando não encontrar mais
           EXIT WHEN vr_idx_crapsld IS NULL;
           -- Processar apenas registros negativos
           IF vr_tab_crapsld(vr_idx_crapsld).vlsddisp < 0 THEN
             -- Zerar valor saldo devedor
             vr_vlsdeved:= 0;
             -- Zerar valor limite conta
             vr_limite_conta:= 0;
             -- Verificar o limite do associado
             IF vr_tab_craplim.EXISTS(vr_tab_crapsld(vr_idx_crapsld).nrdconta) THEN
                -- Acumular limite da conta
                vr_limite_conta:= vr_tab_craplim(vr_tab_crapsld(vr_idx_crapsld).nrdconta);
             END IF;
             -- Saldo devedor recebe o saldo da conta multiplicado por -1
             vr_vlsdeved:= vr_tab_crapsld(vr_idx_crapsld).vlsddisp * -1;
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
           END IF;
           vr_idx_crapsld := vr_tab_crapsld.next(vr_idx_crapsld);
        END LOOP; --rw_crapsld

        -- Total geral recebe limite + desconto + titulos
        vr_totgeral:= Nvl(vr_totgeral,0) + Nvl(vr_limite,0)   +
                      Nvl(vr_desconto,0) + Nvl(vr_desctitu,0);
        -- Escrever informacoes dos saldos no arquivo XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<limite>'  ||To_Char(vr_limite,  'fm999g999g990d00')||'</limite>
                                                      <desconto>'||To_Char(vr_desconto,'fm999g999g990d00')||'</desconto>
                                                      <desctitu>'||To_Char(vr_desctitu,'fm999g999g990d00')||'</desctitu>
                                                      <total>'   ||To_Char(vr_totgeral,'fm999g999g999g990d00')||'</total></saldos></crrl398>'
                               ,pr_fecha_xml      => TRUE);

        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_clob_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl398/linhas/linha' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl398.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 80                  --> colunas
                                   ,pr_sqcabrel  => 3                   --> Sequencia do Relatorio
                                   ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_flg_gerar => vr_flg_gerar        --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic);       --> Saída com erro

        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clob_xml);
        dbms_lob.freetemporary(vr_clob_xml);

     EXCEPTION
       WHEN vr_exc_saida THEN
         pr_des_erro:= vr_dscritic;
       WHEN OTHERS THEN
         cecred.pc_internal_exception;
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

     BEGIN

        /* Gerar arquivo com todos os PACs */

        -- Determinar o nome do arquivo que será gerado
        vr_nom_arquivo := 'crrl014_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_clob_xml, TRUE);
        dbms_lob.open(vr_clob_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl014_tot'||
                                                     ' mes1="'||vr_rel_nomemes1||
                                                     '" mes2="'||vr_rel_nomemes2||
                                                     '" mes3="'||vr_rel_nomemes3||'"><planos>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper) LOOP

           -- Se existir associados e planos para a agencia
           IF vr_tab_tot_nrdplaag.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_vlprepla.EXISTS(rw_crapage.cdagenci) THEN

              --Verificar se tem informacao senao pula
              IF vr_tab_tot_nrdplaag(rw_crapage.cdagenci) <> 0 OR
                 vr_tab_tot_vlprepla(rw_crapage.cdagenci) <> 0 THEN

                 --Montar tag da conta para arquivo XML
                 gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                        ,pr_texto_completo => vr_text_xml
                                        ,pr_texto_novo     => '<p1>
                                                                  <p_nmresage>'||rw_crapage.nmresage||'</p_nmresage>
                                                                  <p_assoc>'||vr_tab_tot_nrdplaag(rw_crapage.cdagenci)||'</p_assoc>
                                                                  <p_capital>'||nvl(vr_tab_tot_vlprepla(rw_crapage.cdagenci),0)||'</p_capital>
                                                               </p1>');
              END IF;
           END IF;

        END LOOP;

        -- Finalizar agrupador de planos e iniciar parte2
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</planos><saldos>');

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
                 gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '<s1>
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</saldos><emprestimos>');

        -- Processar todas as agencias
        FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
           -- Se existir associados e planos para a agencia
           IF vr_tab_tot_qtassemp.EXISTS(rw_crapage.cdagenci) AND
              vr_tab_tot_qtassemp(rw_crapage.cdagenci) <> 0 THEN

              -- Montar tag da conta para arquivo XML
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                     ,pr_texto_completo => vr_text_xml
                                     ,pr_texto_novo     => '<e1>
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</emprestimos><recadastros>');

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
                 gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                        ,pr_texto_completo => vr_text_xml
                                        ,pr_texto_novo     => '<r1>
                                                                  <r_nmresage>'||rw_crapage.nmresage||'</r_nmresage>
                                                                  <r_feito>'||vr_tab_tot_qtjrecad(rw_crapage.cdagenci)||'</r_feito>
                                                                  <r_afazer>'||to_char(vr_tab_tot_qtnrecad(rw_crapage.cdagenci),'fm999g999g999g999')||'</r_afazer>
                                                                  <r_adm>'||to_char(vr_tab_tot_qtadmiss(rw_crapage.cdagenci),'fm999g999g999g999')||'</r_adm>
                                                               </r1>');
              END IF;
           END IF;
        END LOOP;

        -- Finalizar agrupador recadastro e relatorio
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                               ,pr_texto_completo => vr_text_xml
                               ,pr_texto_novo     => '</recadastros></crrl014_tot>'
                               ,pr_fecha_xml      => TRUE);

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
                                   ,pr_dsxml     => vr_clob_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl014_tot'       --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl014_total.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem Parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => vr_nmformul         --> Nome do formulário para impressão
                                   ,pr_nrcopias  => vr_nrcopias         --> Número de cópias
                                   ,pr_flg_gerar => vr_flg_gerar        --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic);       --> Saída com erro

        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_saida;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clob_xml);
        dbms_lob.freetemporary(vr_clob_xml);

     EXCEPTION
       WHEN vr_exc_saida THEN
         pr_des_erro:= vr_dscritic;
       WHEN OTHERS THEN
         cecred.pc_internal_exception;
         pr_des_erro:= 'Erro ao imprimir relatório crrl014_total. '||sqlerrm;
     END;


     -- Geracao de arquivo AAMMDD_CAPITAL.txt
     PROCEDURE pc_gera_arq_capital (pr_des_erro OUT VARCHAR2) IS

        -- Variavel
        vr_nmarqtxt   VARCHAR2(100);
        vr_setlinha   VARCHAR2(4000);
        
        -- Total geral de capital subscrito por PF e PJ
        vr_tot_capfis NUMBER := 0;
        vr_tot_capjur NUMBER := 0;

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
           vr_nmarqtxt:=  TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CAPITAL.txt';

           -- Busca o diretório para contabilidade
           vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
           vr_dircon := vr_dircon || vc_dircon;
           
           -- Incializar CLOB do arquivo txt
           dbms_lob.createtemporary(vr_clob_arq, TRUE, dbms_lob.CALL);
           dbms_lob.open(vr_clob_arq, dbms_lob.lob_readwrite);
           
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
                            '"COTAS CAPITAL COOPERADOS PESSOA FISICA"';                     
             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));
                                    
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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));
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

             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));

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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));
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

             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));
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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));
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
             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));
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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));
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

             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));
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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));
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

             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));
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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));                     END IF;
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
             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));
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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));
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
             -- Escreve no CLOB
             gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                    ,pr_texto_completo => vr_text_arq
                                    ,pr_texto_novo     => vr_setlinha||chr(13));
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
                       -- Escreve no CLOB
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                              ,pr_texto_completo => vr_text_arq
                                              ,pr_texto_novo     => vr_setlinha||chr(13));
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
              -- Escreve no CLOB
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                     ,pr_texto_completo => vr_text_arq
                                     ,pr_texto_novo     => vr_setlinha||chr(13));
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
                        -- Escreve no CLOB
                        gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                               ,pr_texto_completo => vr_text_arq
                                               ,pr_texto_novo     => vr_setlinha||chr(13));
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
              -- Escreve no CLOB
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                     ,pr_texto_completo => vr_text_arq
                                     ,pr_texto_novo     => vr_setlinha||chr(13));
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
                        -- Escreve no CLOB
                        gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                               ,pr_texto_completo => vr_text_arq
                                               ,pr_texto_novo     => vr_setlinha||chr(13));
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
              -- Escreve no CLOB
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                     ,pr_texto_completo => vr_text_arq
                                     ,pr_texto_novo     => vr_setlinha||chr(13));
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
                        -- Escreve no CLOB
                        gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                               ,pr_texto_completo => vr_text_arq
                                               ,pr_texto_novo     => vr_setlinha||chr(13));
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
              -- Escreve no CLOB
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                     ,pr_texto_completo => vr_text_arq
                                     ,pr_texto_novo     => vr_setlinha||chr(13));
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
                        -- Escreve no CLOB
                        gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                               ,pr_texto_completo => vr_text_arq
                                               ,pr_texto_novo     => vr_setlinha||chr(13));
                      END IF;
                    END IF;
                    -- Limpa variavel
                    vr_setlinha := '';
                  END LOOP;
                END LOOP; -- fim repete
              END IF;

           END IF;

           -- Efetuar a geração do arquivo TXT copiando para o diretório X
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => ''
                                  ,pr_fecha_xml      => TRUE);
           
           -- Submeter a geração do arquivo 
           gene0002.pc_solicita_relato_arquivo(pr_cdcooper   => pr_cdcooper                       --> Cooperativa conectada
                                              ,pr_cdprogra   => vr_cdprogra                       --> Programa chamador
                                              ,pr_dtmvtolt   => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                              ,pr_dsxml      => vr_clob_arq                       --> Arquivo XML de dados
                                              ,pr_cdrelato   => '010'                             --> Código do relatório
                                              ,pr_dsarqsaid  => vr_nom_direto||'/'||vr_nmarqtxt   --> Arquivo final com o path
                                              ,pr_flg_gerar  => vr_flg_gerar                      --> Não gerar na hora
                                              ,pr_dspathcop  => vr_dircon                         --> Copiar para o diretório
                                              ,pr_fldoscop   => 'S'                               --> Executar comando ux2dos
                                              ,pr_flgremarq  => 'N'                               --> Após cópia, remover arquivo de origem
                                              ,pr_des_erro   => vr_dscritic);
           -- Liberar memória alocada
           dbms_lob.close(vr_clob_arq);
           dbms_lob.freetemporary(vr_clob_arq);
           
           -- Se houve erro na geração
           IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;

        END IF; -- Fim do IF de validacao Mensal

     EXCEPTION
        WHEN vr_exc_saida THEN
           pr_des_erro:= vr_dscritic;
        WHEN OTHERS THEN
           cecred.pc_internal_exception;
           pr_des_erro:= 'Erro ao gerar arquivo AAMMDD_CAPITAL.txt para contabilidade. '||SQLERRM;
     END;



   BEGIN
      ---------------------------------------
      -- Inicio Bloco Principal pc_crps010
      ---------------------------------------   
         
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);
                                

      -- Na execução principal
      if nvl(pr_idparale,0) = 0 then
        -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        vr_idlog_ini_ger := null;
        pc_log_programa(pr_dstiplog   => 'I'    
                       ,pr_cdprograma => vr_cdprogra          
                       ,pr_cdcooper   => pr_cdcooper
                       ,pr_tpexecucao => 1    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_ger);
      end if;                                

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
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      pc_crps010_1(pr_dtmvtolt         => rw_crapdat.dtmvtolt
                  ,pr_rel_nomemes1     => vr_rel_nomemes1
                  ,pr_rel_nomemes2     => vr_rel_nomemes2
                  ,pr_rel_nomemes3     => vr_rel_nomemes3
                  ,pr_cdcritic         => vr_cdcritic
                  ,pr_des_erro         => vr_dscritic);
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Sair do programa
        RAISE vr_exc_saida;
      END IF;
      
      -- Inicializa variaveis do capital
      vr_res_vlcapcrz_exc_age := 0;
      vr_res_qtcotist_exc_age := 0;
      vr_res_vlcapcrz_tot_age := 0;
      vr_res_qtcotist_tot_age := 0;

      -- Zerar variavel de desconto
      vr_desconto:= 0;
      -- Zerar variavel de desconto de titulos
      vr_desctitu:= 0;
      
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper   --> Código da coopertiva
                                                   ,vr_cdprogra); --> Código do programa
      
      /* Paralelismo visando performance Rodar Somente no processo Noturno */
      if rw_crapdat.inproces > 2 and vr_qtdjobs > 0 and pr_cdagenci = 0 then  
        -- Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_ID_paralelo;
        
        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
           -- Levantar exceção
           vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
           RAISE vr_exc_saida;
        END IF;
                                              
        -- Verifica se algum job paralelo executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                     ,pr_cdprogra    => vr_cdprogra
                                                     ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                     ,pr_tpagrupador => 1
                                                     ,pr_nrexecucao  => 1);    
                                                     
        -- Na primeira execução, ou seja, sem erros anteriores
        IF vr_qterro = 0 THEN 
          -- Alimentar tabela de ultimos pagamentos de Empréstimos a partir do processo 
          -- principal, para facilitar aos processos filhos a recuperação futura. Isso é necessário
          -- pois a busca unitária (cada processo) estava tornando a execução lenta.        
          BEGIN
            INSERT /*+ APPEND PARALLEL NOLOGGING */
                   INTO tbgen_batch_relatorio_wrk 
                        (cdcooper
                        ,cdprograma
                        ,dsrelatorio
                        ,dtmvtolt
                        ,cdagenci
                        ,nrdconta
                        ,nrctremp
                        ,dtvencto
                        ,vltitulo)                  
                   SELECT /*+ FULL(craplem) */
                          pr_cdcooper
                         ,vr_cdprogra
                         ,'craplem'
                         ,rw_crapdat.dtmvtolt
                         ,0
                         ,craplem.nrdconta
                         ,craplem.nrctremp
                         ,max(craplem.dtmvtolt) keep (dense_rank last order by craplem.dtmvtolt) dtmvtolt
                         ,sum(craplem.vllanmto) keep (dense_rank last order by craplem.dtmvtolt) vllanmto
                     FROM craplem craplem
                    WHERE craplem.cdcooper = pr_cdcooper
                      AND EXISTS (SELECT 1 
                                    FROM craphis
                                   WHERE craphis.cdcooper = craplem.cdcooper
                                     AND craphis.cdhistor = craplem.cdhistor
                                     AND craphis.indebcre = 'C')
                   GROUP BY craplem.nrdconta,craplem.nrctremp; 
          EXCEPTION 
            WHEN OTHERS THEN
              -- Levantar exceção
              vr_dscritic := 'Problema durante a criação da tabela temporárias de Parcelas pagas -> '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          -- Efetuar a gravação das informações acima
          COMMIT;
        END IF;
        
        -- Retorna todas as agências da Cooperativa 
        for rw_age in cr_crapage (pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 0
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_qterro   => vr_qterro
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt) loop
                                              
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := vr_cdprogra ||'_'|| rw_age.cdagenci || '$';  
        
          -- Cadastra o programa paralelo
          gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(rw_age.cdagenci,3,'0') --> Utiliza a agência como id programa
                                    ,pr_des_erro => vr_dscritic);
                                    
          -- Testar saida com erro
          if vr_dscritic is not null then
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;     
          
          -- Montar o bloco PLSQL que será executado
          -- Ou seja, executaremos a geração dos dados
          -- para a agência atual atraves de Job no banco
          vr_dsplsql := 'DECLARE' || chr(13) 
                     || '  wpr_stprogra NUMBER;' || chr(13) 
                     || '  wpr_infimsol NUMBER;' || chr(13) 
                     || '  wpr_cdcritic NUMBER;' || chr(13) 
                     || '  wpr_dscritic VARCHAR2(1500);' || chr(13) 
                     || 'BEGIN' || chr(13) 
                     || '  PC_CRPS010('|| pr_cdcooper 
                     || '            ,'|| rw_age.cdagenci 
                     || '            ,'|| vr_idparale 
                     || '            ,wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' 
                     || chr(13) 
                     || 'END;'; --  
           
           -- Faz a chamada ao programa paralelo atraves de JOB
           gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                 ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                 ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                 ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                 ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                 ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                 ,pr_des_erro => vr_dscritic);    
                                 
           -- Testar saida com erro
           if vr_dscritic is not null then 
             -- Levantar exceçao
             raise vr_exc_saida;
           end if;

           -- Chama rotina que irá pausar este processo controlador
           -- caso tenhamos excedido a quantidade de JOBS em execuçao
           gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                       ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                       ,pr_des_erro => vr_dscritic);

           -- Testar saida com erro
           if  vr_dscritic is not null then 
             -- Levantar exceçao
             raise vr_exc_saida;
           end if;
           
        end loop;
        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- até que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => vr_dscritic);
                                    
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;    

        -- Verifica se algum job executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                     ,pr_cdprogra    => vr_cdprogra
                                                     ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                     ,pr_tpagrupador => 1
                                                     ,pr_nrexecucao  => 1);
        if vr_qterro > 0 then 
          vr_cdcritic := 0;
          vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
          raise vr_exc_saida;
        end if;    
      else
        
        if pr_cdagenci <> 0 then
          vr_tpexecucao := 2;
        else
          vr_tpexecucao := 1;
        end if;    
        
        -- Grava controle de batch por agência
        gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper      -- Codigo da Cooperativa
                                        ,pr_cdprogra    => vr_cdprogra      -- Codigo do Programa
                                        ,pr_dtmvtolt    => rw_crapdat.dtmvtolt  -- Data de Movimento
                                        ,pr_tpagrupador => 1                -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                        ,pr_cdagrupador => pr_cdagenci      -- Codigo do agrupador conforme (tpagrupador)
                                        ,pr_cdrestart   => null             -- Controle do registro de restart em caso de erro na execucao
                                        ,pr_nrexecucao  => 1                -- Numero de identificacao da execucao do programa
                                        ,pr_idcontrole  => vr_idcontrole    -- ID de Controle
                                        ,pr_cdcritic    => pr_cdcritic      -- Codigo da critica
                                        ,pr_dscritic    => vr_dscritic);    -- Descricao da critica
        -- Testar saida com erro
        if vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;    
        
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I'  
                       ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci          
                       ,pr_cdcooper   => pr_cdcooper 
                       ,pr_tpexecucao => vr_tpexecucao    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_par); 
                       

        -- Carregar tabela de memoria de titulares da conta
        FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_idseqttl => 1) LOOP
           -- Montar o indice para o vetor
           vr_tab_crapttl(rw_crapttl.nrdconta).cdempres:=  rw_crapttl.cdempres;
           vr_tab_crapttl(rw_crapttl.nrdconta).cdturnos:=  rw_crapttl.cdturnos;
        END LOOP;
        
        -- Carregar tabela de memoria depessoas juridicas
        FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci) LOOP
           -- Montar o indice para o vetor
           vr_tab_crapjur(rw_crapjur.nrdconta).cdempres:=  rw_crapjur.cdempres;
        END LOOP; 
        
        -- Carregar tabela de memoria de informacoes dos borderos de desconto de titulos
        FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                    ,pr_dtpagto  => rw_crapdat.dtmvtolt
                                    ,pr_cdagenci => pr_cdagenci) LOOP
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).cdbandoc := rw_craptdb.cdbandoc;
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrdctabb := rw_craptdb.nrdctabb;
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrcnvcob := rw_craptdb.nrcnvcob;
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrdconta := rw_craptdb.nrdconta;
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).nrdocmto := rw_craptdb.nrdocmto;
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).vltitulo := rw_craptdb.vltitulo;
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).insittit := rw_craptdb.insittit;
           vr_tab_craptdb(rw_craptdb.nrdconta).tab_craptdb(cr_craptdb%ROWCOUNT).vr_rowid := rw_craptdb.rowid;
        END LOOP;

        -- Carregar tabela de memoria de saldos dos associados
        FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci) LOOP
           vr_tab_crapsld(rw_crapsld.nrdconta) := rw_crapsld;
        END LOOP;
        
        -- Carregar tabela de memoria de subscricao de capital
        FOR rw_crapsdc IN cr_crapsdc_existe (pr_cdcooper => pr_cdcooper
                                            ,pr_cdagenci => pr_cdagenci) LOOP
           vr_tab_crapsdc(rw_crapsdc.nrdconta):= 0;
        END LOOP;      
        
        -- Buscar as informacoes do procap
        PCAP0001.pc_busca_procap_ativos(pr_cdcooper       => pr_cdcooper
                                       ,pr_totativo       => vr_totativo
                                       ,pr_vlativos       => vr_vlativos
                                       ,pr_tab_craplct    => vr_tab_craplct
                                       ,pr_typ_tab_ativos => vr_typ_tab_ativos
                                       ,pr_dscritic       => vr_dscritic);

        -- Se ocorrer algum erro aborta a geração
        IF vr_dscritic IS NOT NULL THEN
           -- Envio do log de erro
           RAISE vr_exc_saida;
        END IF;  
        
        -- Carregar tabela de memoria com limites dos associados
        FOR rw_craplim IN cr_craplim (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci) LOOP
           -- Atribuir valor do limite para a tabela de memoria
           vr_tab_craplim(rw_craplim.nrdconta):= rw_craplim.vllimite;
        END LOOP;
        
        -- Carregar tabela de memoria de informacoes de cotas
        FOR rw_crapcot IN cr_crapcot (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci) LOOP
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
        FOR rw_crappla IN cr_crappla (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci) LOOP
           -- Se a conta ja existir na tabela ignora
           IF NOT vr_tab_crappla.EXISTS(rw_crappla.nrdconta) THEN
              vr_tab_crappla(rw_crappla.nrdconta):= rw_crappla.vlprepla;
           END IF;
        END LOOP;

        -- Carregar tabela de memoria de historico alteracoes crapass
        FOR rw_crapalt IN cr_crapalt (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci) LOOP
           -- Se a conta ja existir na tabela ignora
           vr_tab_crapalt(rw_crapalt.nrdconta):= 0;
        END LOOP;
     
        
        -- Carregar tabela de memoria de cadastro de borderos
        FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => pr_cdcooper
                                     ,pr_dtlibera => rw_crapdat.dtmvtolt
                                     ,pr_insitchq => 2
                                     ,pr_cdagenci => pr_cdagenci) LOOP
           -- Atribuir valor para a tabela de memnoriaAcumular valor desconto
           vr_tab_crapcdb(rw_crapcdb.nrdconta):= Nvl(rw_crapcdb.vlcheque,0);
        END LOOP; 
        
        -- Carregar tabela de memoria de associados
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_cdagenci => pr_cdagenci);
        LOOP
           FETCH cr_crapass BULK COLLECT INTO rw_crapass LIMIT 5000;
           EXIT WHEN rw_crapass.COUNT = 0;            
           FOR idx IN rw_crapass.first..rw_crapass.last LOOP                
            -- No primeiro registro da agencia
            IF vr_idx_crapass IS NULL OR rw_crapass(idx).cdagenci <> vr_tab_crapass(vr_tab_crapass.prior(vr_idx_crapass)).cdagenci THEN
              -- Criar registro vazio com conta zero para facilitar o posicionamento do vetor por agencia
              vr_idx_crapass := lpad(rw_crapass(idx).cdagenci,5,'0') || lpad(0,10,'0');
              vr_tab_crapass(vr_idx_crapass).cdagenci := 0;
              vr_tab_crapass(vr_idx_crapass).nrdconta := 0;
            END IF;
            -- Enviar ao vetor
            vr_idx_crapass := lpad(rw_crapass(idx).cdagenci,5,'0') || lpad(rw_crapass(idx).nrdconta,10,'0');
            vr_tab_crapass(vr_idx_crapass) := rw_crapass(idx);
          END LOOP;
        END LOOP;  
        CLOSE cr_crapass;     
        
        -- Carregar tabela de memoria dos empréstimos (propostas e o contrato)
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_cdagenci => pr_cdagenci);
        LOOP                
           FETCH cr_crapepr BULK COLLECT INTO rw_crapepr_bulk LIMIT 10000;
           EXIT WHEN rw_crapepr_bulk.COUNT = 0;            
           FOR idx IN rw_crapepr_bulk.first..rw_crapepr_bulk.last LOOP   
             -- Montar indice para tabela memoria
             vr_index_crapepr := LPad(rw_crapepr_bulk(idx).nrdconta,10,'0')||LPad(rw_crapepr_bulk(idx).nrctremp,10,'0');
             vr_tab_crapepr(vr_index_crapepr):= rw_crapepr_bulk(idx);
             -- Guardar o primeiro contrato do cooperado na tabela de associado para facilitar busca futura
             vr_idx_crapass := lpad(rw_crapepr_bulk(idx).cdageass,5,'0') || lpad(rw_crapepr_bulk(idx).nrdconta,10,'0');
             IF trim(vr_tab_crapass(vr_idx_crapass).idxemprt) IS NULL THEN
               vr_tab_crapass(vr_idx_crapass).idxemprt := vr_index_crapepr;
             END IF;
          END LOOP;
        END LOOP;
        CLOSE cr_crapepr;
        
        -- Durante execuções paralelas, iremos buscar na tabela pre-processada
        IF pr_idparale > 0 THEN
          OPEN cr_craplem_work(pr_cdcooper  => pr_cdcooper
                              ,pr_cdagenci  => pr_cdagenci
                              ,pr_cdprograma  => vr_cdprogra
                              ,pr_dsrelatorio => 'craplem'
                              ,pr_dtmvtolt    => rw_crapdat.dtmvtolt);
          LOOP
            FETCH cr_craplem_work BULK COLLECT INTO rw_craplem_bulk LIMIT 20000;
             EXIT WHEN rw_craplem_bulk.COUNT = 0;            
             FOR idx IN rw_craplem_bulk.first..rw_craplem_bulk.last LOOP   
               -- Montar indice para tabela memoria
               vr_index_crapepr:= LPad(rw_craplem_bulk(idx).nrdconta,10,'0')||LPad(rw_craplem_bulk(idx).nrctremp,10,'0');
               -- Somente se existir (ou seja, foi carregado acima)
               IF vr_tab_crapepr.exists(vr_index_crapepr) THEN
                 vr_tab_crapepr(vr_index_crapepr).vllanlem := rw_craplem_bulk(idx).vllanmto;
                 vr_tab_crapepr(vr_index_crapepr).dtmvtlem := rw_craplem_bulk(idx).dtmvtolt;
               END IF;
             END LOOP;
          END LOOP;
          CLOSE cr_craplem_work;
        -- Senão, buscaremos na craplem direto
        ELSE
          -- Carregar tabela de memoria de lancamentos de emprestimos
          OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                         --,pr_dslsthis => vr_dslstlem
                         );
          LOOP                
             FETCH cr_craplem BULK COLLECT INTO rw_craplem_bulk LIMIT 20000;
             EXIT WHEN rw_craplem_bulk.COUNT = 0;            
             FOR idx IN rw_craplem_bulk.first..rw_craplem_bulk.last LOOP   
               -- Montar indice para tabela memoria
               vr_index_crapepr:= LPad(rw_craplem_bulk(idx).nrdconta,10,'0')||LPad(rw_craplem_bulk(idx).nrctremp,10,'0');
               -- Somente se existir (ou seja, foi carregado acima)
               IF vr_tab_crapepr.exists(vr_index_crapepr) THEN
                 vr_tab_crapepr(vr_index_crapepr).vllanlem := rw_craplem_bulk(idx).vllanmto;
                 vr_tab_crapepr(vr_index_crapepr).dtmvtlem := rw_craplem_bulk(idx).dtmvtolt;
               END IF;
             END LOOP;
          END LOOP;
          CLOSE cr_craplem;
        end if;
                       
        -- Selecionar e percorrer todas as Agencias da Cooperativa
        FOR rw_crapage IN cr_crapage (pr_cdcooper
                                     ,pr_cdagenci
                                     ,vr_cdprogra
                                     ,vr_qterro
                                     ,rw_crapdat.dtmvtolt) LOOP

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

           -- Pesquisar todos os associados partindo do primeiro da agencia atual
           vr_idx_crapass := lpad(vr_cdagenci,5,'0') || lpad(0,10,'0');
           vr_idx_crapass := vr_tab_crapass.next(vr_idx_crapass);
           LOOP
              -- Sair quando não existir mais registros ou a agencia for diferente da atual
              EXIT WHEN vr_idx_crapass IS NULL OR vr_tab_crapass(vr_idx_crapass).cdagenci <> vr_cdagenci;
              -- Bloco necessário para controle de loop
              BEGIN
                 -- Se for pessoa fisica
                 IF vr_tab_crapass(vr_idx_crapass).inpessoa = 1 THEN
                    -- Selecionar informacoes dos titulares da conta
                    IF vr_tab_crapttl.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
                       -- Codigo da empresa recebe o codigo da empresa do titular da conta
                       vr_cdempres:= vr_tab_crapttl(vr_tab_crapass(vr_idx_crapass).nrdconta).cdempres;
                    ELSE
                       -- Codigo da empresa recebe zero
                       vr_cdempres:= 0;
                    END IF;
                 ELSE
                    -- Selecionar informacoes dos titulares da conta PJ
                    IF vr_tab_crapjur.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
                       -- Codigo da empresa recebe o codigo da empresa do titular da conta
                       vr_cdempres:= vr_tab_crapjur(vr_tab_crapass(vr_idx_crapass).nrdconta).cdempres;
                    ELSE
                       -- Codigo da empresa recebe zero
                       vr_cdempres:= 0;
                    END IF;
                 END IF;

                 /* Se foi demitido no mes corrente */
                 IF vr_tab_crapass(vr_idx_crapass).dtdemiss  IS NOT NULL AND
                    trunc(vr_tab_crapass(vr_idx_crapass).dtdemiss,'MM') = trunc(rw_crapdat.dtmvtolt,'MM') THEN

                    -- Determinar o indice para o novo registro
                    vr_index_demitidos:= LPad(vr_tab_crapass(vr_idx_crapass).cdagenci,5,'0')||
                                         LPad(vr_tab_crapass(vr_idx_crapass).cdmotdem,5,'0')||
                                         LPad(vr_tab_crapass(vr_idx_crapass).nrdconta,10,'0');

                    --Gravar registro na tabela de memoria
                    vr_tab_demitidos(vr_index_demitidos).cdagenci:= vr_tab_crapass(vr_idx_crapass).cdagenci;
                    vr_tab_demitidos(vr_index_demitidos).nrdconta:= vr_tab_crapass(vr_idx_crapass).nrdconta;
                    vr_tab_demitidos(vr_index_demitidos).inmatric:= vr_tab_crapass(vr_idx_crapass).inmatric;

                    /* Quem nao possui motivo recebe motivo = 1 na temp-table */
                    IF vr_tab_crapass(vr_idx_crapass).cdmotdem = 0 THEN
                       vr_tab_demitidos(vr_index_demitidos).cdmotdem:= 1;
                    ELSE
                       vr_tab_demitidos(vr_index_demitidos).cdmotdem:= vr_tab_crapass(vr_idx_crapass).cdmotdem;
                    END IF;
                 END IF;

                 /* se for uma conta duplicada e nao demitida */
                 IF vr_tab_crapass(vr_idx_crapass).inmatric = 2 AND vr_tab_crapass(vr_idx_crapass).dtdemiss IS NULL THEN
                    -- Calcular a quantidade de meses e anos
                    CADA0001.pc_busca_idade (pr_dtnasctl => vr_tab_crapass(vr_idx_crapass).dtnasctl
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_nrdeanos => vr_nrdeanos
                                            ,pr_nrdmeses => vr_nrdmeses
                                            ,pr_dsdidade => vr_dsdidade
                                            ,pr_des_erro => vr_dscritic);

                    -- Se ocorreu erro
                    IF vr_dscritic IS NOT NULL THEN
                       -- Levantar Excecao
                     vr_dscritic := 'Conta '||vr_tab_crapass(vr_idx_crapass).nrdconta||' --> '||vr_dscritic;
                       RAISE vr_exc_saida;
                    END IF;

                    /* se tiver mais de 16 anos */
                    IF vr_nrdeanos > 16   THEN
                       -- Determinar o indice para o novo registro
                       vr_index_duplicados:= LPad(vr_tab_crapass(vr_idx_crapass).cdagenci,5,'0')||LPad(vr_tab_crapass(vr_idx_crapass).nrdconta,10,'0');
                       -- Incluir na tabela de duplicados
                       vr_tab_duplicados(vr_index_duplicados).cdagenci:= vr_tab_crapass(vr_idx_crapass).cdagenci;
                       vr_tab_duplicados(vr_index_duplicados).nrdconta:= vr_tab_crapass(vr_idx_crapass).nrdconta;
                    END IF;
                 END IF;

                 /* Admitidos do PAC no mes - Resumo Mensal do Capital */
                 IF trunc(vr_tab_crapass(vr_idx_crapass).dtadmiss,'MM') = trunc(rw_crapdat.dtmvtolt,'MM') THEN

                    -- Se ja existir a agencia no vetor
                    IF vr_tab_age_qtassmes_adm.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                       -- Incrementar contador
                       vr_tab_age_qtassmes_adm(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_age_qtassmes_adm(vr_tab_crapass(vr_idx_crapass).cdagenci) + 1;
                    ELSE
                       -- Iniciar contador com 1
                       vr_tab_age_qtassmes_adm(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                    END IF;
                 END IF;

                 -- Verificar se existe saldo para associado
                 IF vr_tab_crapsld.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
                    -- Atribuir valores do semestre para variaveis
                    rw_crapsld.vlsmstre##1:= vr_tab_crapsld(vr_tab_crapass(vr_idx_crapass).nrdconta).vlsmstre##1;
                    rw_crapsld.vlsmstre##2:= vr_tab_crapsld(vr_tab_crapass(vr_idx_crapass).nrdconta).vlsmstre##2;
                    rw_crapsld.vlsmstre##3:= vr_tab_crapsld(vr_tab_crapass(vr_idx_crapass).nrdconta).vlsmstre##3;
                    rw_crapsld.vlsmstre##4:= vr_tab_crapsld(vr_tab_crapass(vr_idx_crapass).nrdconta).vlsmstre##4;
                    rw_crapsld.vlsmstre##5:= vr_tab_crapsld(vr_tab_crapass(vr_idx_crapass).nrdconta).vlsmstre##5;
                    rw_crapsld.vlsmstre##6:= vr_tab_crapsld(vr_tab_crapass(vr_idx_crapass).nrdconta).vlsmstre##6;
                 ELSE
                    -- Montar mensagem de critica
                    vr_cdcritic:= 10;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                    vr_dscritic := 'Conta '||vr_tab_crapass(vr_idx_crapass).nrdconta||' --> '||vr_dscritic;
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
                 vr_rel_dsdacstp:= To_Char(vr_tab_crapass(vr_idx_crapass).cdsitdct,'fm9') ||To_Char(vr_tab_crapass(vr_idx_crapass).cdtipcta,'fm09');
                 -- Valor da media do semestre recebe mes1 + mes2 + mes3 / 3
                 vr_rel_vlsmtrag:= (Nvl(vr_rel_vlsmmes1,0) + Nvl(vr_rel_vlsmmes2,0) + Nvl(vr_rel_vlsmmes3,0)) / 3;

                 -- Se o tipo de limite for Capital
                 IF vr_tab_crapass(vr_idx_crapass).tplimcre = 1 THEN
                    vr_rel_dslimcre:= 'CP';
                    -- Se o tipo de limite for Saldo Medio
                 ELSIF vr_tab_crapass(vr_idx_crapass).tplimcre = 2 THEN
                    vr_rel_dslimcre:= 'SM';
                 ELSE
                    -- Limite Recebe null
                    vr_rel_dslimcre:= NULL;
                 END IF;

                 -- Atribuir false para flag nova pagina
                 vr_flgnvpag:= FALSE;

                 -- Verificar se a tabela já contem a agencia
                 IF vr_tab_tot_nrassmag.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                    --Incrementar total assinantes da agencia
                    vr_tab_tot_nrassmag(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_nrassmag(vr_tab_crapass(vr_idx_crapass).cdagenci) + 1;
                    --Acumular total do semestre com o valor calculado
                    vr_tab_tot_vlsmtrag(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlsmtrag(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlsmtrag,0);
                    --Acumular total do mes 1
                    vr_tab_tot_vlsmmes1(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlsmmes1(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlsmmes1,0);
                    --Acumular total do mes 2
                    vr_tab_tot_vlsmmes2(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlsmmes2(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlsmmes2,0);
                    --Acumular total do mes 3
                    vr_tab_tot_vlsmmes3(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlsmmes3(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlsmmes3,0);
                 ELSE
                    vr_tab_tot_nrassmag(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                    --Acumular total do semestre com o valor calculado
                    vr_tab_tot_vlsmtrag(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_rel_vlsmtrag,0);
                    --Acumular total do mes 1
                    vr_tab_tot_vlsmmes1(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_rel_vlsmmes1,0);
                    --Acumular total do mes 2
                    vr_tab_tot_vlsmmes2(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_rel_vlsmmes2,0);
                    --Acumular total do mes 3
                    vr_tab_tot_vlsmmes3(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_rel_vlsmmes3,0);
                 END IF;

                 /*  Le registro de cotas  */
                 IF NOT vr_tab_crapcot.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
                    -- Montar mensagem de critica
                    vr_cdcritic:= 169;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                    vr_dscritic := 'Conta '||vr_tab_crapass(vr_idx_crapass).nrdconta||' --> '||vr_dscritic;
                    -- Levantar Exceção
                    RAISE vr_exc_saida;
                 ELSE
                    --Valor do capital recebe valor das cotas
                    vr_rel_vlcaptal:= vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vldcotas;
                    --Quantidade de parcelas pagas recebe parcelas pagas das cotas
                    vr_rel_qtprpgpl:= vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).qtprpgpl;
                    --Acumular valor total capital da agencia
                    IF vr_tab_tot_vlcaptal.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                      vr_tab_tot_vlcaptal(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlcaptal(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlcaptal,0);
                    ELSE
                      vr_tab_tot_vlcaptal(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_rel_vlcaptal,0);
                    END IF;
                 END IF;

                 /* Acumula dados para o resumo mensal do capital */

                 -- Se a data de demissao estiver nula
                 IF vr_tab_crapass(vr_idx_crapass).dtdemiss IS NULL THEN
                    -- Incrementar Valor capital ativo com o valor do capital
                    vr_res_vlcapcrz_ati:= Nvl(vr_res_vlcapcrz_ati,0) + Nvl(vr_rel_vlcaptal,0);
                    -- Incrementar Valor capital ativo com o valor do capital por PF e PJ
                    vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_ati := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_ati  + Nvl(vr_rel_vlcaptal,0);
                    -- Incrementar Valor capital moeda fixa com o qdade cotas
                    vr_res_vlcapmfx_ati:= Nvl(vr_res_vlcapmfx_ati,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).qtcotmfx,0);
                    -- Incrementar Valor correcao monetaria a incorporar com o valor da correcao a incorporar das cotas
                    vr_res_vlcmicot_ati:= Nvl(vr_res_vlcmicot_ati,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmicot,0);
                    -- Incrementar Valor correcao monetaria mes com o valor da correcao mes das cotas
                    vr_res_vlcmmcot_ati:= Nvl(vr_res_vlcmmcot_ati,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmmcot,0);

                    -- Se a matricula for original
                    IF vr_tab_crapass(vr_idx_crapass).inmatric = 1 THEN
                       -- Incrementa Quantidade cotistas ativos
                       vr_res_qtcotist_ati:= Nvl(vr_res_qtcotist_ati,0) + 1;
                       -- Incrementa Quantidade cotistas ativos por PF e PJ
                       vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_ati := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_ati + 1;
                       -- Incrementa a quantidade de cotistas ativos da agencia
                       IF vr_tab_age_qtcotist_ati.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                         vr_tab_age_qtcotist_ati(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_age_qtcotist_ati(vr_tab_crapass(vr_idx_crapass).cdagenci)+1;
                       ELSE
                         vr_tab_age_qtcotist_ati(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                       END IF;
                    ELSE
                       -- Incrementar quantidade cotistas ativos duplicados
                       vr_dup_qtcotist_ati:= Nvl(vr_dup_qtcotist_ati,0) + 1;
                       -- Incrementar quantidade cotistas ativos duplicados separdados por PF e PJ
                       vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).dup_qtcotist_ati := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).dup_qtcotist_ati + 1;
                    END IF;
                 ELSIF vr_tab_crapass(vr_idx_crapass).dtelimin IS NULL THEN  --Data de eliminacao for nula
                    -- Incrementar Valor capital demitido com o valor do capital
                    vr_res_vlcapcrz_dem:= Nvl(vr_res_vlcapcrz_dem,0) + Nvl(vr_rel_vlcaptal,0);
                    -- Incrementar Valor capital demitido com o valor do capital por PF e PJ
                    vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_dem := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_dem +  Nvl(vr_rel_vlcaptal,0);
                    -- Incrementar Valor capital moeda fixa com o qdade cotas
                    vr_res_vlcapmfx_dem:= Nvl(vr_res_vlcapmfx_dem,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).qtcotmfx,0);
                    -- Incrementar Valor correcao monetaria a incorporar com o valor da correcao a incorporar das cotas
                    vr_res_vlcmicot_dem:= Nvl(vr_res_vlcmicot_dem,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmicot,0);
                    -- Incrementar Valor correcao monetaria mes com o valor da correcao mes das cotas
                    vr_res_vlcmmcot_dem:= Nvl(vr_res_vlcmmcot_dem,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmmcot,0);

                    -- Se a matricula for original
                    IF vr_tab_crapass(vr_idx_crapass).inmatric = 1 THEN
                       -- Incrementa Quantidade cotistas demitidos
                       vr_res_qtcotist_dem:= Nvl(vr_res_qtcotist_dem,0) + 1;
                       -- Incrementa Quantidade cotistas demitidos por PF e PJ
                       vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_dem := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_dem + 1;
                       -- Incrementa a quantidade de cotistas demitidos da agencia
                       IF vr_tab_age_qtcotist_dem.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                          vr_tab_age_qtcotist_dem(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_age_qtcotist_dem(vr_tab_crapass(vr_idx_crapass).cdagenci)+1;
                       ELSE
                          vr_tab_age_qtcotist_dem(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                       END IF;
                    ELSE
                       -- Incrementar quantidade cotistas demitidos duplicados
                       vr_dup_qtcotist_dem:= Nvl(vr_dup_qtcotist_dem,0) + 1;
                       -- Incrementar quantidade cotistas demitidos duplicados separados por PF e PJ
                       vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).dup_qtcotist_dem := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).dup_qtcotist_dem + 1;
                    END IF;
                 ELSE
                    -- Incrementar Valor capital excluido com o valor do capital
                    vr_res_vlcapcrz_exc_age := Nvl(vr_res_vlcapcrz_exc_age,0) + Nvl(vr_rel_vlcaptal,0);
                    -- Incrementar Valor capital excluido com o valor do capital por PF e PJ
                    vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_exc := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_exc + Nvl(vr_rel_vlcaptal,0);
                    -- Incrementar Valor capital moeda fixa com o qdade cotas
                    vr_res_vlcapmfx_exc:= Nvl(vr_res_vlcapmfx_exc,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).qtcotmfx,0);
                    -- Incrementar Valor correcao monetaria a incorporar com o valor da correcao a incorporar das cotas
                    vr_res_vlcmicot_exc:= Nvl(vr_res_vlcmicot_exc,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmicot,0);
                    -- Incrementar Valor correcao monetaria mes com o valor da correcao mes das cotas
                    vr_res_vlcmmcot_exc:= Nvl(vr_res_vlcmmcot_exc,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmmcot,0);

                    -- Se a matricula for original
                    IF vr_tab_crapass(vr_idx_crapass).inmatric = 1 THEN
                       -- Incrementa Quantidade cotistas demitidos
                       vr_res_qtcotist_exc_age:= Nvl(vr_res_qtcotist_exc_age,0) + 1;
                       -- Incrementa Quantidade cotistas demitidos por PF e PJ
                       vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_exc := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_exc + 1;
                       -- Incrementa a quantidade de cotistas demitidos da agencia

                       IF vr_tab_age_qtcotist_exc.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                          vr_tab_age_qtcotist_exc(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_age_qtcotist_exc(vr_tab_crapass(vr_idx_crapass).cdagenci)+1;
                       ELSE
                          vr_tab_age_qtcotist_exc(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                       END IF;
                    ELSE
                       -- Incrementar quantidade cotistas excluidos duplicados
                       vr_dup_qtcotist_exc:= Nvl(vr_dup_qtcotist_exc,0) + 1;
                       -- Incrementar quantidade cotistas excluidos duplicados separados por PF e PJ
                       vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).dup_qtcotist_exc := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).dup_qtcotist_exc + 1;
                    END IF;
                 END IF;

                 -- Acumular valor do capital total
                 vr_res_vlcapcrz_tot_age:= Nvl(vr_res_vlcapcrz_tot_age,0) + Nvl(vr_rel_vlcaptal,0);

                 -- Acumular valor do capital total por PF e PJ
                 vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_tot := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_vlcapcrz_tot + Nvl(vr_rel_vlcaptal,0);

                 -- Inicializa
                 vr_rel_vlcppctl := 0;
                 vr_rel_vlproctl := 0;

                 -- Verifica se existe procap
                 IF vr_tab_craplct.COUNT() > 0 THEN

                    -- Monta o indice inicial de agencia e conta para pesquisa
                    vr_ind_first := LPAD(vr_tab_crapass(vr_idx_crapass).cdagenci,5,'0')||
                                    LPAD(vr_tab_crapass(vr_idx_crapass).nrdconta,10,'0')||
                                    '00000000'||'0000000000';
                    -- Monta o indice final de agencia e conta para pesquisa
                    vr_ind_last  := LPAD(vr_tab_crapass(vr_idx_crapass).cdagenci,5,'0')||
                                    LPAD(vr_tab_crapass(vr_idx_crapass).nrdconta,10,'0')||
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
                       IF vr_tab_crapass(vr_idx_crapass).inpessoa = 1 THEN

                          IF vr_tab_tot_pcap_fis.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                             vr_tab_tot_pcap_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_tot_pcap_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) + vr_rel_vlproctl;
                          ELSE
                             vr_tab_tot_pcap_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_rel_vlproctl;
                          END IF;

                          vr_tot_pcapcred_fis := vr_tot_pcapcred_fis + vr_rel_vlproctl;
                       ELSE

                          IF vr_tab_tot_pcap_jur.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                             vr_tab_tot_pcap_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_tot_pcap_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) + vr_rel_vlproctl;
                          ELSE
                             vr_tab_tot_pcap_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_rel_vlproctl;
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
                 IF vr_tab_crapass(vr_idx_crapass).dtdemiss IS NULL THEN
                   -- Guarda as informacoes de total capital por agencia. Dados para Contabilidade
                   IF vr_tab_crapass(vr_idx_crapass).inpessoa = 1 THEN
                      -- Verifica se existe valor para agencia corrente de pessoa fisica
                      IF vr_tab_vlcapage_fis.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                         -- Soma os valores por agencia de pessoa fisica
                         vr_tab_vlcapage_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_vlcapage_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlcppctl,0);
                      ELSE
                         -- Inicializa o array com o valor inicial de pessoa fisica
                          vr_tab_vlcapage_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := Nvl(vr_rel_vlcppctl,0);
                      END IF;
                      -- Gravando as informacoe para gerar o valor total capital de pessoa fisica
                      vr_tot_capagefis := vr_tot_capagefis + Nvl(vr_rel_vlcppctl,0);
                   ELSE
                      -- Verifica se existe valor para agencia corrente de pessoa juridica
                      IF vr_tab_vlcapage_jur.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                         -- Soma os valores por agencia de pessoa juridica
                         vr_tab_vlcapage_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_vlcapage_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlcppctl,0);
                      ELSE
                         -- Inicializa o array com o valor inicial de pessoa juridica
                         vr_tab_vlcapage_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) :=  Nvl(vr_rel_vlcppctl,0);
                      END IF;
                      -- Gravando as informacoe para gerar o valor total capital de pessoa juridica
                      vr_tot_capagejur := vr_tot_capagejur + Nvl(vr_rel_vlcppctl,0);
                   END IF;
                 END IF;

                 -- Acumular valor capital em moeda fixa total
                 vr_res_vlcapmfx_tot:= Nvl(vr_res_vlcapmfx_tot,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).qtcotmfx,0);
                 -- Acumular valor correcao monetaria a incorporar total
                 vr_res_vlcmicot_tot:= Nvl(vr_res_vlcmicot_tot,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmicot,0);
                 -- Acumular valor correcao monetaria mes total
                 vr_res_vlcmmcot_tot:= Nvl(vr_res_vlcmmcot_tot,0) + Nvl(vr_tab_crapcot(vr_tab_crapass(vr_idx_crapass).nrdconta).vlcmmcot,0);

                 --Se for matricula Original
                 IF vr_tab_crapass(vr_idx_crapass).inmatric = 1 THEN
                   -- Incrementar Quantidade cotistas total
                   vr_res_qtcotist_tot_age:= vr_res_qtcotist_tot_age + 1;
                   -- Incrementar Quantidade cotistas total por PF e PJ
                   vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_tot := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).res_qtcotist_tot + 1;
                 END IF;

                 /*  Le registro do plano de subscricao de capital  */

                 -- Verificar se a conta possui subscricao antes de selecionar tudo
                 IF vr_tab_crapsdc.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
                    -- Selecionar informacoes da subscricao
                    FOR rw_crapsdc IN cr_crapsdc (pr_cdcooper => pr_cdcooper
                                                 ,pr_nrdconta => vr_tab_crapass(vr_idx_crapass).nrdconta) LOOP
                       -- Se a data de demissao for nula
                       IF vr_tab_crapass(vr_idx_crapass).dtdemiss IS NULL THEN
                          -- Montar indice para tabela debitos
                          vr_index_debitos:= LPad(vr_tab_crapass(vr_idx_crapass).cdagenci,5,'0')||LPad(vr_tab_crapass(vr_idx_crapass).nrdconta,10,'0');
                          -- Inserir informacoes na tabela de memoria de debitos
                          vr_tab_debitos(vr_index_debitos).cdagenci:= vr_tab_crapass(vr_idx_crapass).cdagenci;
                          vr_tab_debitos(vr_index_debitos).nrdconta:= vr_tab_crapass(vr_idx_crapass).nrdconta;
                          vr_tab_debitos(vr_index_debitos).nmprimtl:= vr_tab_crapass(vr_idx_crapass).nmprimtl;
                          vr_tab_debitos(vr_index_debitos).dtadmiss:= vr_tab_crapass(vr_idx_crapass).dtadmiss;
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
                          vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_ati := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_ati + Nvl(rw_crapsdc.vllanmto,0);
                          -- Acumular valor capital total subscrito
                          vr_sub_vlcapcrz_tot:= Nvl(vr_sub_vlcapcrz_tot,0) + Nvl(rw_crapsdc.vllanmto,0);
                          -- Acumular valor capital total subscrito por PF e PJ
                          vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_tot := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_tot + Nvl(rw_crapsdc.vllanmto,0);
                       ELSE
                          -- Data de eliminacao for nula
                          IF vr_tab_crapass(vr_idx_crapass).dtelimin IS NULL THEN
                             -- Acumular Valor capital subscrito demitido
                             vr_sub_vlcapcrz_dem:= Nvl(vr_sub_vlcapcrz_dem,0) + Nvl(rw_crapsdc.vllanmto,0);
                             -- Acumular Valor capital subscrito demitido por PF e PJ
                             vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_dem := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_dem + Nvl(rw_crapsdc.vllanmto,0);
                             -- Acumular valor capital subscrito total
                             vr_sub_vlcapcrz_tot:= Nvl(vr_sub_vlcapcrz_tot,0) + Nvl(rw_crapsdc.vllanmto,0);
                             -- Acumular valor capital subscrito total por PF e PJ
                             vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_tot := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_tot + Nvl(rw_crapsdc.vllanmto,0);
                          ELSE
                             -- Acumular Valor capital subscrito excluido
                             vr_sub_vlcapcrz_exc:= Nvl(vr_sub_vlcapcrz_exc,0) + Nvl(rw_crapsdc.vllanmto,0);
                             -- Acumular Valor capital subscrito excluido por PF e PJ
                             vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_exc := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_exc + Nvl(rw_crapsdc.vllanmto,0);
                             -- Acumular valor capital subscrito total
                             vr_sub_vlcapcrz_tot:= Nvl(vr_sub_vlcapcrz_tot,0) + Nvl(rw_crapsdc.vllanmto,0);
                             -- Acumular valor capital subscrito total por PF e PJ
                             vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_tot := vr_typ_tab_total(vr_tab_crapass(vr_idx_crapass).inpessoa).sub_vlcapcrz_tot + Nvl(rw_crapsdc.vllanmto,0);
                          END IF;
                       END IF;

                       -- Grava as informacoes para calcular o valor do capital subscrito menos o procap quando existir
                       vr_rel_vlcppctl := Nvl(rw_crapsdc.vllanmto,0) - Nvl(vr_rel_vlproctl,0);
                       -- Grava as informacoes para calcular o valor do capital a integralizar
                       vr_rel_vlcapctz := Nvl(rw_crapsdc.vllanmto,0);

                       -- Se a data de demissao for nula
                       IF vr_tab_crapass(vr_idx_crapass).dtdemiss IS NULL THEN
                         -- Guarda as informacoes de total capital por agencia. Dados para Contabilidade
                         IF vr_tab_crapass(vr_idx_crapass).inpessoa = 1 THEN
                            -- Verifica se existe valor para agencia corrente de pessoa fisica
                            IF vr_tab_vlcapage_fis.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                               -- Soma os valores por agencia de pessoa fisica
                               vr_tab_vlcapage_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_vlcapage_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlcppctl,0);
                            ELSE
                               -- Inicializa o array com o valor inicial de pessoa fisica
                               vr_tab_vlcapage_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := Nvl(vr_rel_vlcppctl,0);
                            END IF;
                            -- Gravando as informacoe para gerar o valor total capital de pessoa fisica
                            vr_tot_capagefis := vr_tot_capagefis + Nvl(vr_rel_vlcppctl,0);

                            -- Dados para contabilidade. Informacao de Capital a Integralizar
                            IF vr_tab_vlcapctz_fis.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                               vr_tab_vlcapctz_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_vlcapctz_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlcapctz,0);
                            ELSE
                               vr_tab_vlcapctz_fis(vr_tab_crapass(vr_idx_crapass).cdagenci) := Nvl(vr_rel_vlcapctz,0);
                            END IF;
                            vr_tot_vlcapctz_fis := vr_tot_vlcapctz_fis + Nvl(vr_rel_vlcapctz,0);

                         ELSE
                            -- Verifica se existe valor para agencia corrente de pessoa juridica
                            IF vr_tab_vlcapage_jur.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                               -- Soma os valores por agencia de pessoa juridica
                               vr_tab_vlcapage_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_vlcapage_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlcppctl,0);
                            ELSE
                               -- Inicializa o array com o valor inicial de pessoa juridica
                               vr_tab_vlcapage_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) := Nvl(vr_rel_vlcppctl,0);
                            END IF;
                            -- Gravando as informacoe para gerar o valor total capital de pessoa juridica
                            vr_tot_capagejur := vr_tot_capagejur + Nvl(vr_rel_vlcppctl,0);

                            --Dados para contabilidade. Informacao de Capital a Integralizar
                            IF vr_tab_vlcapctz_jur.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                               vr_tab_vlcapctz_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) := vr_tab_vlcapctz_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlcapctz,0);
                            ELSE
                               vr_tab_vlcapctz_jur(vr_tab_crapass(vr_idx_crapass).cdagenci) := Nvl(vr_rel_vlcapctz,0);
                            END IF;
                            vr_tot_vlcapctz_jur := vr_tot_vlcapctz_jur + Nvl(vr_rel_vlcapctz,0);

                         END IF;
                       END IF; -- vr_tab_crapass(vr_idx_crapass).dtdemiss IS NULL

                    END LOOP;
                 END IF;

                 /*  Le registro de planos  */

                 IF NOT vr_tab_crappla.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
                    -- Valor da prestacao do plano recebe 0
                    vr_rel_vlprepla:= 0;
                 ELSE
                    -- Valor da prestacao do plano recebe valor encontrado
                    vr_rel_vlprepla:= vr_tab_crappla(vr_tab_crapass(vr_idx_crapass).nrdconta);
                    -- Incrementar numero planos de capitalizacao da agencia
                    IF vr_tab_tot_nrdplaag.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                       vr_tab_tot_nrdplaag(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_nrdplaag(vr_tab_crapass(vr_idx_crapass).cdagenci) + 1;
                    ELSE
                       vr_tab_tot_nrdplaag(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                    END IF;

                    -- Acumular o valor dos planos de capitalizacao da agencia
                    IF vr_tab_tot_vlprepla.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                       vr_tab_tot_vlprepla(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlprepla(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_rel_vlprepla,0);
                    ELSE
                       vr_tab_tot_vlprepla(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_rel_vlprepla,0);
                    END IF;
                 END IF;

                 -- Atribuir nulo para a descricao do registro
                 vr_rel_dsmsgrec:= NULL;

                 -- Se a data de demissao for nula
                 IF vr_tab_crapass(vr_idx_crapass).dtdemiss IS NULL THEN

                    -- Se encontrou registro na tabela de memoria
                    IF vr_tab_crapalt.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
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
                       IF vr_tab_crapass(vr_idx_crapass).dtadmiss < vr_dtmvtolt THEN
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
                    dbms_lob.createtemporary(vr_clob_xml, TRUE);
                    dbms_lob.open(vr_clob_xml, dbms_lob.lob_readwrite);
                    -- Inicilizar as informações do XML
                    gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                           ,pr_texto_completo => vr_text_xml
                                           ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl014><agencias>'||
                                                                 '<agencia cdagenci="'||vr_cdagenci||'" nmresage="'|| vr_nmresage ||'"><contas>');
                 END IF;

                 -- Se For agencia 14 ou 15
                 IF vr_tab_crapass(vr_idx_crapass).cdagenci IN (14,15) THEN
                    -- Data de admissao na empresa recebe valor encontrado
                    vr_dtadmemp:= To_Char(vr_tab_crapass(vr_idx_crapass).dtadmemp,'DD/MM/YYYY');
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
                 gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                        ,pr_texto_completo => vr_text_xml
                                        ,pr_texto_novo     => '<conta>
                                                               <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crapass(vr_idx_crapass).nrdconta))||'</nrdconta>
                                                               <dsdacstp>'||vr_rel_dsdacstp||'</dsdacstp>
                                                               <nmprimtl><![CDATA['||substr(vr_tab_crapass(vr_idx_crapass).nmprimtl,1,33)||']]></nmprimtl>
                                                               <dtadmemp>'||vr_dtadmemp||'</dtadmemp>
                                                               <vlsmtrag>'||to_char(vr_rel_vlsmtrag,'fm999g999g990d00')||'</vlsmtrag>
                                                               <vlsmmes1>'||to_char(vr_rel_vlsmmes1,'fm99999g999g990d00')||'</vlsmmes1>
                                                               <vlsmmes2>'||to_char(vr_rel_vlsmmes2,'fm99999g999g990d00')||'</vlsmmes2>
                                                               <vlsmmes3>'||to_char(vr_rel_vlsmmes3,'fm99g999g999g990d00')||'</vlsmmes3>
                                                               <indnivel>'||vr_tab_crapass(vr_idx_crapass).indnivel||'</indnivel>
                                                               <dsmsgrec>'||vr_rel_dsmsgrec||'</dsmsgrec>
                                                               <nrmatric>'||To_Char(vr_tab_crapass(vr_idx_crapass).nrmatric,'fm999g990')||'</nrmatric>
                                                               <vledvmto>'||to_char(vr_tab_crapass(vr_idx_crapass).vledvmto,'fm999g999g990d00')||'</vledvmto>
                                                               <dtedvmto>'||To_Char(vr_tab_crapass(vr_idx_crapass).dtedvmto,'DD/MM/YYYY')||'</dtedvmto>
                                                               <cdempres>'||To_Char(vr_cdempres,'fm999')||'</cdempres>
                                                               <dtultlcr>'||To_Char(vr_tab_crapass(vr_idx_crapass).dtultlcr,'DD/MM/YYYY')||'</dtultlcr>
                                                               <dslimcre>'||vr_rel_dslimcre||'</dslimcre>
                                                               <vllimcre>'||To_Char(vr_tab_crapass(vr_idx_crapass).vllimcre,'fm99g999g990d00')||'</vllimcre>
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
                 vr_index_crapepr := trim(vr_tab_crapass(vr_idx_crapass).idxemprt);
                 LOOP
                    EXIT WHEN vr_index_crapepr IS NULL
                           OR vr_tab_crapepr(vr_index_crapepr).nrdconta <> vr_tab_crapass(vr_idx_crapass).nrdconta;
                    -- Criar bloco para controle fluxo
                    BEGIN
                       -- Se o valor do saldo devedor do emprestimo for zero
                       IF vr_tab_crapepr(vr_index_crapepr).vlsdeved = 0 THEN
                          -- Acumular o valor dos juros do mes da agencia
                          IF vr_tab_tot_vljurmes.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                             vr_tab_tot_vljurmes(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vljurmes(vr_tab_crapass(vr_idx_crapass).cdagenci) +
                                                                        Nvl(vr_tab_crapepr(vr_index_crapepr).vljurmes,0);
                          ELSE
                             vr_tab_tot_vljurmes(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_tab_crapepr(vr_index_crapepr).vljurmes,0);
                          END IF;
                          -- levantar excecao e ir para proximo emprestimo
                          RAISE vr_exc_pula;
                       END IF;

                       -- Se for o primeiro emprestimo
                       IF vr_fisrtemp THEN

                          -- Inicializar o agrupador de emprestimos
                          gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                                 ,pr_texto_completo => vr_text_xml
                                                 ,pr_texto_novo     => '<emprestimos>');

                          -- Atribuir false para flag primeiro emprestimo
                          vr_fisrtemp:= FALSE;
                       END IF;

                       -- Mudar flag para indicar existe emprestimo
                       vr_regexist:= TRUE;
                       -- Acumular saldo devedor
                       vr_vlsdeved:= Nvl(vr_vlsdeved,0) + Nvl(vr_tab_crapepr(vr_index_crapepr).vlsdeved,0);
                       -- Acumular valor prestacoes do emprestimo
                       vr_vlpreemp:= Nvl(vr_vlpreemp,0) + Nvl(vr_tab_crapepr(vr_index_crapepr).vlpreemp,0);
                       -- Acumular qtdade contratos de emprestimo
                       vr_qtctremp:= Nvl(vr_qtctremp,0) + 1;
                       -- Quantidade prestacoes a pagar recebe qde prestacoes do emprestimo - qde prestacoes calculadas
                       vr_rel_qtpreapg:= Nvl(vr_tab_crapepr(vr_index_crapepr).qtpreemp,0) - Nvl(vr_tab_crapepr(vr_index_crapepr).qtprecal,0);

                       -- Se o valor calculado for negativo entao zera
                       IF vr_rel_qtpreapg < 0 THEN
                          vr_rel_qtpreapg:= 0;
                       END IF;

                       -- Acumular a quantidade de contratos da agencia
                       IF vr_tab_tot_qtctremp.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                          vr_tab_tot_qtctremp(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_qtctremp(vr_tab_crapass(vr_idx_crapass).cdagenci) + 1;
                       ELSE
                          vr_tab_tot_qtctremp(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                       END IF;

                       -- Acumular o valor das prestacoes dos emprestimos da agencia
                       IF vr_tab_tot_vlpreemp.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                          vr_tab_tot_vlpreemp(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlpreemp(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_tab_crapepr(vr_index_crapepr).vlpreemp,0);
                       ELSE
                          vr_tab_tot_vlpreemp(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_tab_crapepr(vr_index_crapepr).vlpreemp,0);
                       END IF;

                       -- Acumular o valor do saldo devedor dos emprestimos da agencia
                       IF vr_tab_tot_vlsdeved.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                          vr_tab_tot_vlsdeved(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vlsdeved(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_tab_crapepr(vr_index_crapepr).vlsdeved,0);
                       ELSE
                          vr_tab_tot_vlsdeved(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_tab_crapepr(vr_index_crapepr).vlsdeved,0);
                       END IF;

                       -- Acumular o valor dos juros dos emprestimos da agencia
                       IF vr_tab_tot_vljurmes.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                          vr_tab_tot_vljurmes(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_vljurmes(vr_tab_crapass(vr_idx_crapass).cdagenci) + Nvl(vr_tab_crapepr(vr_index_crapepr).vljurmes,0);
                       ELSE
                         vr_tab_tot_vljurmes(vr_tab_crapass(vr_idx_crapass).cdagenci):= Nvl(vr_tab_crapepr(vr_index_crapepr).vljurmes,0);
                       END IF;

                       -- Verificar os lancamentos de emprestimo
                       pc_verifica_lancto_emprestimo(pr_idx_crapepr => vr_index_crapepr
                                                    ,pr_vlsdeved   => vr_tab_crapepr(vr_index_crapepr).vlsdeved
                                                    ,pr_dtultpagto => vr_dtultpagto
                                                    ,pr_vlultpagto => vr_vlultpagto
                                                    ,pr_vlprovisao => vr_vlprovisao
                                                    ,pr_nivelrisco => vr_nivelrisco
                                                    ,pr_des_erro   => vr_dscritic);

                       -- Se retornou erro
                       IF vr_dscritic IS NOT NULL THEN
                        vr_dscritic := 'Conta '||vr_tab_crapass(vr_idx_crapass).nrdconta||' --> '||vr_dscritic;
                          -- Levantar Excecao
                          RAISE vr_exc_saida;
                       END IF;

                       -- Escrever detalhe no xml
                       gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                              ,pr_texto_completo => vr_text_xml
                                              ,pr_texto_novo     => '<emprestimo>
                                                                     <nrctremp>'||LTrim(gene0002.fn_mask_contrato(vr_tab_crapepr(vr_index_crapepr).nrctremp))||'</nrctremp>
                                                                     <cdfinemp>'||To_Char(vr_tab_crapepr(vr_index_crapepr).cdfinemp,'fm990')||'</cdfinemp>
                                                                     <cdlcremp>'||To_Char(vr_tab_crapepr(vr_index_crapepr).cdlcremp,'fm9990')||'</cdlcremp>
                                                                     <dtmvtolt>'||To_Char(vr_tab_crapepr(vr_index_crapepr).dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>
                                                                     <qtpreemp>'||To_Char(vr_tab_crapepr(vr_index_crapepr).qtpreemp,'fm990')||'</qtpreemp>
                                                                     <txjuremp>'||To_Char(vr_tab_crapepr(vr_index_crapepr).txjuremp,'fm990d0000000')||'</txjuremp>
                                                                     <vlemprst>'||To_Char(vr_tab_crapepr(vr_index_crapepr).vlemprst,'fm99999g999g990d00')||'</vlemprst>
                                                                     <vlpreemp>'||To_Char(vr_tab_crapepr(vr_index_crapepr).vlpreemp,'fm99g999g999g990d00')||'</vlpreemp>
                                                                     <vlsdeved>'||vr_tab_crapepr(vr_index_crapepr).vlsdeved||'</vlsdeved>
                                                                     <qtpreapg>'||To_Char(vr_rel_qtpreapg,'fm990')||'</qtpreapg>
                                                                     <dtultpagto>'||To_Char(vr_dtultpagto,'DD/MM/YYYY')||'</dtultpagto>
                                                                     <vlultpagto>'||To_Char(vr_vlultpagto,'fm99g999g990d00')||'</vlultpagto>
                                                                     <vlprovisao>'||To_Char(vr_vlprovisao,'fm99g999g999g990d00')||'</vlprovisao>
                                                                     <nivelrisco>'||vr_nivelrisco||'</nivelrisco>
                                                                     </emprestimo>');

                       /*--- Dados para o relatorio 398 ---*/

                       -- Se o emprestimo estiver ativo e o saldo devedor > 0
                       IF vr_tab_crapepr(vr_index_crapepr).inliquid = 0 AND vr_tab_crapepr(vr_index_crapepr).vlsdeved > 0 THEN
                         --Verificar na tabela de memoria de totais se a linha existe
                         IF vr_tab_totlcred.EXISTS(vr_tab_crapepr(vr_index_crapepr).cdlcremp) THEN
                           --Acumular valor do limite de credito
                           vr_tab_totlcred(vr_tab_crapepr(vr_index_crapepr).cdlcremp):= vr_tab_totlcred(vr_tab_crapepr(vr_index_crapepr).cdlcremp) + Nvl(vr_tab_crapepr(vr_index_crapepr).vlsdeved,0);
                         ELSE
                           --Acumular valor do limite de credito
                           vr_tab_totlcred(vr_tab_crapepr(vr_index_crapepr).cdlcremp):= Nvl(vr_tab_crapepr(vr_index_crapepr).vlsdeved,0);
                         END IF;
                       END IF;

                    EXCEPTION
                       WHEN vr_exc_pula THEN
                          NULL;
                       WHEN OTHERS THEN
                          cecred.pc_internal_exception;
                          vr_dscritic:= 'Erro ao processar contratos de emprestimo. Rotina pc_crps010. '||SQLERRM;
                    END;
                    vr_index_crapepr := vr_tab_crapepr.next(vr_index_crapepr);
                 END LOOP; 

                 -- Se existe registro de emprestimo
                 IF vr_regexist THEN
                    -- Incrementa totalizador de associados com emprestimo na agencia
                    IF vr_tab_tot_qtassemp.EXISTS(vr_tab_crapass(vr_idx_crapass).cdagenci) THEN
                       vr_tab_tot_qtassemp(vr_tab_crapass(vr_idx_crapass).cdagenci):= vr_tab_tot_qtassemp(vr_tab_crapass(vr_idx_crapass).cdagenci) + 1;
                    ELSE
                       vr_tab_tot_qtassemp(vr_tab_crapass(vr_idx_crapass).cdagenci):= 1;
                    END IF;

                    -- Finalizar agrupador de emprestimos e Incluir informacao que houve emprestimos
                    gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                           ,pr_texto_completo => vr_text_xml
                                           ,pr_texto_novo     => '</emprestimos><controle>1</controle>');
                 ELSE
                    -- Incluir informacao que nao houve emprestimos
                    gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                           ,pr_texto_completo => vr_text_xml
                                           ,pr_texto_novo     => '<controle>0</controle>');
                 END IF;

                 -- Finalizar o agrupador de conta
                 gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                        ,pr_texto_completo => vr_text_xml
                                        ,pr_texto_novo     => '</conta>');

                 /*-- Desconto de Cheques - rel 398 --*/

                 IF vr_tab_crapcdb.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN
                    -- Acumular valor desconto
                    vr_desconto:= Nvl(vr_desconto,0) + vr_tab_crapcdb(vr_tab_crapass(vr_idx_crapass).nrdconta);
                 END IF;

                 /*-- Desconto de Titulos - rel 398 --*/

                 IF vr_tab_craptdb.EXISTS(vr_tab_crapass(vr_idx_crapass).nrdconta) THEN

                    vr_index_craptdb := vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb.first;
                    WHILE vr_index_craptdb IS NOT NULL LOOP
                       -- Selecionar informacoes dos boletos de cobranca
                       OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                                       ,pr_cdbandoc => vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).cdbandoc
                                       ,pr_nrdctabb => vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).nrdctabb
                                       ,pr_nrcnvcob => vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).nrcnvcob
                                       ,pr_nrdconta => vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).nrdconta
                                       ,pr_nrdocmto => vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).nrdocmto);
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
                                                                     || vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).vr_rowid );
                       ELSE
                          -- Ignorar registro se oes titulo estiver pago
                          -- e o indicador de pagto for caixa/Internetbank/TAA
                          IF (vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).insittit = 2  AND (rw_crapcob.indpagto IN (1,3,4))) THEN
                             NULL;
                          ELSE
                             -- Acumular valor desconto titulos
                             vr_desctitu:= Nvl(vr_desctitu,0) + Nvl(vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb(vr_index_craptdb).vltitulo,0);
                          END IF;
                       END IF;
                       --Fechar Cursor
                       CLOSE cr_crapcob;
                       vr_index_craptdb := vr_tab_craptdb(vr_tab_crapass(vr_idx_crapass).nrdconta).tab_craptdb.next(vr_index_craptdb);
                    END LOOP;
                 END IF;

              EXCEPTION
                 WHEN vr_exc_pula THEN
                    NULL;
               WHEN vr_exc_saida THEN
                 RAISE vr_exc_saida;
                 WHEN OTHERS THEN
                    cecred.pc_internal_exception;
                    vr_dscritic:= 'Erro ao selecionar associado. '||SQLERRM;
                    -- Levantar Excecao
                    RAISE vr_exc_saida;
              END;
              -- Buscar proximo crapass
              vr_idx_crapass := vr_tab_crapass.next(vr_idx_crapass);
           END LOOP; --rw_crapass

           -- Se criou o clob anteriormente
           IF vr_flgclob THEN

              -- Finalizar o agrupador de contas e agencia e inicia o totalizador
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_xml
                                     ,pr_texto_completo => vr_text_xml
                                     ,pr_texto_novo     => ' </contas></agencia><totais><total>
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
                                                           </total></totais></agencias></crrl014>'
                                     ,pr_fecha_xml     => TRUE);

              -- Efetuar solicitação de geração de relatório --
              gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                         ,pr_dsxml     => vr_clob_xml          --> Arquivo XML de dados
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
                                         ,pr_flg_gerar => vr_flg_gerar        --> gerar PDF
                                         ,pr_des_erro  => vr_dscritic);       --> Saída com erro

              -- Testar se houve erro
              IF vr_dscritic IS NOT NULL THEN
                 -- Gerar exceção
                 RAISE vr_exc_saida;
              END IF;

              -- Liberando a memória alocada pro CLOB
              dbms_lob.close(vr_clob_xml);
              dbms_lob.freetemporary(vr_clob_xml);

           END IF;
        END LOOP; --vr_tab_crapage
        
        
        -- Caso execução paralela -- Converter as informações das PLTABLES em tabela de Banco para commitar e ler depois
        IF pr_cdagenci > 0 THEN
        
          -- Gravar vetores totais por agencia
          FOR rw_crapage IN cr_crapage (pr_cdcooper,pr_cdagenci) LOOP
            -- Inserir na tabela temporária
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci
                         ,dscritic)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'total_agenci'
                         ,rw_crapdat.dtmvtolt
                         ,rw_crapage.cdagenci                         
                         -- Aproveitar dscritic para montar um registro genérico com o restante das informações
                         , to_char(vr_tab_age_qtassmes_adm(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_age_qtcotist_ati(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_age_qtcotist_dem(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_age_qtcotist_exc(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_nrassmag(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlsmtrag(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlsmmes1(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlsmmes2(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlsmmes3(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlcaptal(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_nrdplaag(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlprepla(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_qtnrecad(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_qtadmiss(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_qtjrecad(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_qtctremp(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlpreemp(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vlsdeved(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_vljurmes(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_qtassemp(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_vlcapage_fis(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_vlcapage_jur(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_vlcapctz_fis(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_vlcapctz_jur(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_pcap_fis(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_tab_tot_pcap_jur(rw_crapage.cdagenci),'fm999g999g999g999g990d00')||';');
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[total_agenci]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END LOOP;
          
          -- Gravar vetores totais por tipo pessoa
          FOR vr_idx IN 1..2 LOOP
            -- Inserir na tabela temporária
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci
                         ,dschave
                         ,dscritic)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'typ_total'
                         ,rw_crapdat.dtmvtolt
                         ,pr_cdagenci     
                         ,vr_idx                    
                         -- Aproveitar dscritic para montar um registro genérico com o restante das informações
                         , to_char(vr_typ_tab_total(vr_idx).dup_qtcotist_ati,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).dup_qtcotist_dem,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).dup_qtcotist_exc,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_vlcapcrz_ati,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_vlcapcrz_dem,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_vlcapcrz_exc,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_vlcapcrz_tot,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).sub_vlcapcrz_ati,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).sub_vlcapcrz_dem,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).sub_vlcapcrz_exc,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).sub_vlcapcrz_tot,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_qtcotist_ati,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_qtcotist_dem,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_qtcotist_exc,'fm999g999g999g999g990d00')||';'
                         ||to_char(vr_typ_tab_total(vr_idx).res_qtcotist_tot,'fm999g999g999g999g990d00')||';');
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[typ_total]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END LOOP;
          
          -- Processar tabela de memoria de debitos
          vr_index_debitos:= vr_tab_debitos.FIRST;
          -- Enquanto o registro nao for nulo
          WHILE vr_index_debitos IS NOT NULL LOOP
            -- Inserir na tabela temporária
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci
                         ,nrdconta
                         ,dschave
                         ,dscritic)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'tab_debitos'
                         ,rw_crapdat.dtmvtolt
                         ,vr_tab_debitos(vr_index_debitos).cdagenci
                         ,vr_tab_debitos(vr_index_debitos).nrdconta
                         ,vr_index_debitos                    
                         -- Aproveitar dscritic para montar um registro genérico com o restante das informações
                         , vr_tab_debitos(vr_index_debitos).nmprimtl||';'
                         ||to_char(vr_tab_debitos(vr_index_debitos).dtadmiss,'DD/MM/RRRR')||';'
                         ||to_char(vr_tab_debitos(vr_index_debitos).dtrefere,'DD/MM/RRRR')||';'
                         ||to_char(vr_tab_debitos(vr_index_debitos).vllanmto,'fm999g999g999g999g990d00')||';'
                         ||vr_tab_debitos(vr_index_debitos).tplanmto||';');
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[tab_debitos]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
             
            -- Buscar o próximo registro da tabela
            vr_index_debitos := vr_tab_debitos.NEXT(vr_index_debitos);
          END LOOP;
          
          -- Processar tabela de memoria de demitidos
          vr_des_chave:= vr_tab_demitidos.FIRST;
          -- Enquanto o registro nao for nulo
          WHILE vr_des_chave IS NOT NULL LOOP
            -- Inserir na tabela temporária
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci
                         ,nrdconta
                         ,dschave
                         ,dscritic)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'tab_demitidos'
                         ,rw_crapdat.dtmvtolt
                         ,vr_tab_demitidos(vr_des_chave).cdagenci
                         ,vr_tab_demitidos(vr_des_chave).nrdconta
                         ,vr_des_chave                    
                         -- Aproveitar dscritic para montar um registro genérico com o restante das informações
                         , vr_tab_demitidos(vr_des_chave).cdmotdem||';'
                         ||vr_tab_demitidos(vr_des_chave).inmatric||';');
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[tab_demitidos]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
             
            --- Buscar o próximo registro da tabela
            vr_des_chave := vr_tab_demitidos.NEXT(vr_des_chave);
          END LOOP;
          
          -- Processar tabela de memoria de duplicados
          vr_des_chave:= vr_tab_duplicados.FIRST;
          -- Enquanto o registro nao for nulo
          WHILE vr_des_chave IS NOT NULL LOOP
            -- Inserir na tabela temporária
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci
                         ,nrdconta
                         ,dschave)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'tab_duplicados'
                         ,rw_crapdat.dtmvtolt
                         ,vr_tab_duplicados(vr_des_chave).cdagenci
                         ,vr_tab_duplicados(vr_des_chave).nrdconta
                         ,vr_des_chave);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[tab_duplicados]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
             
            --- Buscar o próximo registro da tabela
            vr_des_chave := vr_tab_duplicados.NEXT(vr_des_chave);
          END LOOP;
          
          -- Processar tabela de memoria de linhas de credito
          vr_des_chave:= vr_tab_totlcred.FIRST;
          -- Enquanto o registro nao for nulo
          WHILE vr_des_chave IS NOT NULL LOOP
            -- Inserir na tabela temporária
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci
                         ,dschave
                         ,vlacumul)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'tab_totlcred'
                         ,rw_crapdat.dtmvtolt
                         ,pr_cdagenci
                         ,vr_des_chave
                         ,vr_tab_totlcred(vr_des_chave));
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[vr_tab_totlcred]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
             
            --- Buscar o próximo registro da tabela
            vr_des_chave := vr_tab_totlcred.NEXT(vr_des_chave);
          END LOOP;
          
          -- Inserir na tabela temporária os totais gerais
          BEGIN
            insert into tbgen_batch_relatorio_wrk
                       (cdcooper
                       ,cdprograma
                       ,dsrelatorio
                       ,dtmvtolt
                       ,cdagenci
                       ,dscritic)
                 values(pr_cdcooper
                       ,vr_cdprogra
                       ,'total_geral'
                       ,rw_crapdat.dtmvtolt
                       ,pr_cdagenci                         
                       -- Aproveitar dscritic para montar um registro genérico com o restante das informações
                       , to_char(vr_dup_qtcotist_ati,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_dup_qtcotist_dem,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_dup_qtcotist_exc,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_vlcapcrz_ati,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_vlcapcrz_dem,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_vlcapcrz_exc_age,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_vlcapcrz_tot_age,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_qtcotist_ati,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_qtcotist_dem,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_qtcotist_exc_age,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_res_qtcotist_tot_age,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_sub_vlcapcrz_ati,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_sub_vlcapcrz_dem,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_sub_vlcapcrz_exc,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_sub_vlcapcrz_tot,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_lancamen    ,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_vllanmto    ,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_capagefis   ,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_capagejur   ,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_vlcapctz_fis,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_vlcapctz_jur,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_pcapcred_fis,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tot_pcapcred_jur,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_desconto,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_desctitu,'fm999g999g999g999g990d00')||';');
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[total_geeral]: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
        END IF;

        -- Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F'  
                       ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci           
                       ,pr_cdcooper   => pr_cdcooper
                       ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_par
                       ,pr_flgsucesso => 1); 
      END IF;
      
      
      -- Se for o programa principal ou sem paralelismo
      if nvl(pr_idparale,0) = 0 then    
        
        -- Carregar tabela de memoria com motivos de demissao
        FOR rw_motivo IN cr_motivo LOOP
           -- Atribuir valor de motivo para a tabela de memoria
           vr_tab_craptab_motivo(rw_motivo.CDMOTIVO):= rw_motivo.DSMOTIVO;
        END LOOP;
        
        /*  Busca das medias  */
        PC_INIC_CAPITAL(pr_cdcooper         => pr_cdcooper
                       ,pr_dtmvtolt         => rw_crapdat.dtmvtolt
                       ,pr_res_qtassati     => vr_res_qtassati
                       ,pr_res_qtassdem     => vr_res_qtassdem
                       ,pr_res_qtassmes     => vr_res_qtassmes
                       ,pr_res_qtdemmes_ati => vr_res_qtdemmes_ati
                       ,pr_res_qtdemmes_dem => vr_res_qtdemmes_dem
                       ,pr_res_qtassbai     => vr_res_qtassbai
                       ,pr_res_qtdesmes_ati => vr_res_qtdesmes_ati
                       ,pr_res_qtdesmes_dem => vr_res_qtdesmes_dem
                       ,pr_res_vlcapcrz_exc => vr_res_vlcapcrz_exc
                       ,pr_res_vlcapexc_fis => vr_typ_tab_total(3).res_vlcapcrz_exc
                       ,pr_res_vlcapexc_jur => vr_typ_tab_total(4).res_vlcapcrz_exc
                       ,pr_res_vlcmicot_exc => vr_res_vlcmicot_exc
                       ,pr_res_vlcmmcot_exc => vr_res_vlcmmcot_exc
                       ,pr_res_vlcapmfx_exc => vr_res_vlcapmfx_exc
                       ,pr_res_qtcotist_exc => vr_res_qtcotist_exc
                       ,pr_res_qtcotexc_fis => vr_typ_tab_total(3).res_qtcotist_exc
                       ,pr_res_qtcotexc_jur => vr_typ_tab_total(4).res_qtcotist_exc
                       ,pr_res_vlcapcrz_tot => vr_res_vlcapcrz_tot
                       ,pr_res_vlcaptot_fis => vr_typ_tab_total(3).res_vlcapcrz_tot
                       ,pr_res_vlcaptot_jur => vr_typ_tab_total(4).res_vlcapcrz_tot
                       ,pr_res_vlcmicot_tot => vr_res_vlcmicot_tot
                       ,pr_res_vlcmmcot_tot => vr_res_vlcmmcot_tot
                       ,pr_res_vlcapmfx_tot => vr_res_vlcapmfx_tot
                       ,pr_res_qtcotist_tot => vr_res_qtcotist_tot
                       ,pr_res_qtcottot_fis => vr_typ_tab_total(3).res_qtcotist_tot
                       ,pr_res_qtcottot_jur => vr_typ_tab_total(4).res_qtcotist_tot
                       ,pr_tot_qtassati     => vr_tot_qtassati
                       ,pr_tot_qtassdem     => vr_tot_qtassdem
                       ,pr_tot_qtassexc     => vr_tot_qtassexc
                       ,pr_tot_qtasexpf     => vr_tot_qtasexpf
                       ,pr_tot_qtasexpj     => vr_tot_qtasexpj
                       ,pr_cdcritic         => vr_cdcritic
                       ,pr_des_erro         => vr_dscritic);
        -- Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Sair do programa
          RAISE vr_exc_saida;
        END IF;
        
        -- Caso execução paralela
        IF vr_idparale > 0 THEN
          
          -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
          pc_log_programa(pr_dstiplog     => 'O'
                         ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                         ,pr_cdcooper     => pr_cdcooper
                         ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         ,pr_tpocorrencia => 4
                         ,pr_dsmensagem   => 'Inicio - Restauração valores das execuções anteriores.'
                         ,pr_idprglog     => vr_idlog_ini_ger); 
          
          -- Cadastro de associados
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci);
          LOOP
             FETCH cr_crapass BULK COLLECT INTO rw_crapass LIMIT 50;
             EXIT WHEN rw_crapass.COUNT = 0;            
             FOR idx IN rw_crapass.first..rw_crapass.last LOOP                
              -- Enviar ao vetor
              vr_idx_crapass := lpad(rw_crapass(idx).cdagenci,5,'0') || lpad(rw_crapass(idx).nrdconta,10,'0');
              vr_tab_crapass(vr_idx_crapass) := rw_crapass(idx);
            END LOOP;
          END LOOP;  
          CLOSE cr_crapass; 
        
          -- Carregar tabela de memoria de informacoes de cotas
          FOR rw_crapcot IN cr_crapcot (pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci) LOOP
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

          -- Carregar tabela de memoria de saldos dos associados
          FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci) LOOP
             vr_tab_crapsld(rw_crapsld.nrdconta) := rw_crapsld;
          END LOOP;
          
          -- Carregar tabela de memoria com limites dos associados
          FOR rw_craplim IN cr_craplim (pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci) LOOP
             -- Atribuir valor do limite para a tabela de memoria
             vr_tab_craplim(rw_craplim.nrdconta):= rw_craplim.vllimite;
          END LOOP;
          
          -- Buscar as informações do banco para as variaveis sumarizando-as
          
          -- Vetores de totais por agencia
          FOR rw_work IN cr_work_total(pr_cdcooper    => pr_cdcooper
                                      ,pr_cdprograma  => vr_cdprogra
                                      ,pr_dsrelatorio => 'total_agenci' 
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) LOOP
            -- Cada registro é um prazo acumulado
            vr_tab_age_qtassmes_adm(rw_work.cdagenci) := rw_work.age_qtassmes_adm;
            vr_tab_age_qtcotist_ati(rw_work.cdagenci) := rw_work.age_qtcotist_ati;
            vr_tab_age_qtcotist_dem(rw_work.cdagenci) := rw_work.age_qtcotist_dem;
            vr_tab_age_qtcotist_exc(rw_work.cdagenci) := rw_work.age_qtcotist_exc;
            vr_tab_tot_nrassmag(rw_work.cdagenci) := rw_work.tot_nrassmag;
            vr_tab_tot_vlsmtrag(rw_work.cdagenci) := rw_work.tot_vlsmtrag;
            vr_tab_tot_vlsmmes1(rw_work.cdagenci) := rw_work.tot_vlsmmes1;
            vr_tab_tot_vlsmmes2(rw_work.cdagenci) := rw_work.tot_vlsmmes2;
            vr_tab_tot_vlsmmes3(rw_work.cdagenci) := rw_work.tot_vlsmmes3;
            vr_tab_tot_vlcaptal(rw_work.cdagenci) := rw_work.tot_vlcaptal;
            vr_tab_tot_nrdplaag(rw_work.cdagenci) := rw_work.tot_nrdplaag;
            vr_tab_tot_vlprepla(rw_work.cdagenci) := rw_work.tot_vlprepla;
            vr_tab_tot_qtnrecad(rw_work.cdagenci) := rw_work.tot_qtnrecad;
            vr_tab_tot_qtadmiss(rw_work.cdagenci) := rw_work.tot_qtadmiss;
            vr_tab_tot_qtjrecad(rw_work.cdagenci) := rw_work.tot_qtjrecad;
            vr_tab_tot_qtctremp(rw_work.cdagenci) := rw_work.tot_qtctremp;
            vr_tab_tot_vlpreemp(rw_work.cdagenci) := rw_work.tot_vlpreemp;
            vr_tab_tot_vlsdeved(rw_work.cdagenci) := rw_work.tot_vlsdeved;
            vr_tab_tot_vljurmes(rw_work.cdagenci) := rw_work.tot_vljurmes;
            vr_tab_tot_qtassemp(rw_work.cdagenci) := rw_work.tot_qtassemp;
            vr_tab_vlcapage_fis(rw_work.cdagenci) := rw_work.vlcapage_fis;
            vr_tab_vlcapage_jur(rw_work.cdagenci) := rw_work.vlcapage_jur;
            vr_tab_vlcapctz_fis(rw_work.cdagenci) := rw_work.vlcapctz_fis;
            vr_tab_vlcapctz_jur(rw_work.cdagenci) := rw_work.vlcapctz_jur;
            vr_tab_tot_pcap_fis(rw_work.cdagenci) := rw_work.tot_pcap_fis;
            vr_tab_tot_pcap_jur(rw_work.cdagenci) := rw_work.tot_pcap_jur;
          END LOOP;
          
          -- Dados das tabela de trabalho de dados TYP_TAB_TOTAL
          FOR rw_work IN cr_work_typ_total(pr_cdcooper    => pr_cdcooper
                                          ,pr_cdprograma  => vr_cdprogra
                                          ,pr_dsrelatorio => 'typ_total' 
                                          ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) LOOP
            -- Cada registro é um prazo acumulado
            vr_typ_tab_total(rw_work.dschave).dup_qtcotist_ati := rw_work.dup_qtcotist_ati;
            vr_typ_tab_total(rw_work.dschave).dup_qtcotist_dem := rw_work.dup_qtcotist_dem;
            vr_typ_tab_total(rw_work.dschave).dup_qtcotist_exc := rw_work.dup_qtcotist_exc;
            vr_typ_tab_total(rw_work.dschave).res_vlcapcrz_ati := rw_work.res_vlcapcrz_ati;
            vr_typ_tab_total(rw_work.dschave).res_vlcapcrz_dem := rw_work.res_vlcapcrz_dem;
            vr_typ_tab_total(rw_work.dschave).sub_vlcapcrz_ati := rw_work.sub_vlcapcrz_ati;
            vr_typ_tab_total(rw_work.dschave).sub_vlcapcrz_dem := rw_work.sub_vlcapcrz_dem;
            vr_typ_tab_total(rw_work.dschave).sub_vlcapcrz_exc := rw_work.sub_vlcapcrz_exc;
            vr_typ_tab_total(rw_work.dschave).sub_vlcapcrz_tot := rw_work.sub_vlcapcrz_tot;
            vr_typ_tab_total(rw_work.dschave).res_qtcotist_ati := rw_work.res_qtcotist_ati;
            vr_typ_tab_total(rw_work.dschave).res_qtcotist_dem := rw_work.res_qtcotist_dem;         
            vr_typ_tab_total(rw_work.dschave).res_vlcapcrz_exc := rw_work.res_vlcapcrz_exc;
            vr_typ_tab_total(rw_work.dschave).res_vlcapcrz_tot := rw_work.res_vlcapcrz_tot;
            vr_typ_tab_total(rw_work.dschave).res_qtcotist_exc := rw_work.res_qtcotist_exc;
            vr_typ_tab_total(rw_work.dschave).res_qtcotist_tot := rw_work.res_qtcotist_tot;
          END LOOP;
          
          -- Dados da tabela temporária vr_tab_debitos
          FOR rw_work IN cr_work_tab_debitos(pr_cdcooper    => pr_cdcooper
                                            ,pr_cdprograma  => vr_cdprogra
                                            ,pr_dsrelatorio => 'tab_debitos' 
                                            ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) LOOP
            -- Cada registro é um prazo acumulado
            vr_tab_debitos(rw_work.dschave).cdagenci := rw_work.cdagenci;
            vr_tab_debitos(rw_work.dschave).nrdconta := rw_work.nrdconta;
            vr_tab_debitos(rw_work.dschave).nmprimtl := rw_work.nmprimtl;
            vr_tab_debitos(rw_work.dschave).dtadmiss := to_date(rw_work.dtadmiss,'dd/mm/rrrr');
            vr_tab_debitos(rw_work.dschave).dtrefere := to_date(rw_work.dtrefere,'dd/mm/rrrr');
            vr_tab_debitos(rw_work.dschave).vllanmto := rw_work.vllanmto;
            vr_tab_debitos(rw_work.dschave).tplanmto := rw_work.tplanmto;
          END LOOP;
          
          -- Dados da tabela temporária vr_tab_debitos
          FOR rw_work IN cr_work_tab_demitidos(pr_cdcooper    => pr_cdcooper
                                              ,pr_cdprograma  => vr_cdprogra
                                              ,pr_dsrelatorio => 'tab_demitidos' 
                                              ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) LOOP
            -- Cada registro é um registro a ser criado
            vr_tab_demitidos(rw_work.dschave).cdagenci := rw_work.cdagenci;
            vr_tab_demitidos(rw_work.dschave).nrdconta := rw_work.nrdconta;
            vr_tab_demitidos(rw_work.dschave).cdmotdem := rw_work.cdmotdem;
            vr_tab_demitidos(rw_work.dschave).inmatric := rw_work.inmatric;
          END LOOP;
          
          -- Dados da tabela temporária vr_tab_totlcred
          FOR rw_work IN cr_work_tab_totlcred(pr_cdcooper    => pr_cdcooper
                                             ,pr_cdprograma  => vr_cdprogra
                                             ,pr_dsrelatorio => 'tab_totlcred' 
                                             ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) LOOP
            -- Cada registro é uma linha
            vr_tab_totlcred(rw_work.dschave) := rw_work.vlacumul;
          END LOOP;
          
          -- Dados da tabela temporária vr_tab_duplicados
          FOR rw_work IN cr_work_tab_duplicados(pr_cdcooper    => pr_cdcooper
                                               ,pr_cdprograma  => vr_cdprogra
                                               ,pr_dsrelatorio => 'tab_duplicados' 
                                               ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) LOOP
            -- Cada registro é um registro a ser criado
            vr_tab_duplicados(rw_work.dschave).cdagenci := rw_work.cdagenci;
            vr_tab_duplicados(rw_work.dschave).nrdconta := rw_work.nrdconta;
          END LOOP;
          
          -- Dados dos totais gerais
          FOR rw_work IN cr_work_total_geral(pr_cdcooper    => pr_cdcooper
                                            ,pr_cdprograma  => vr_cdprogra
                                            ,pr_dsrelatorio => 'total_geral' 
                                            ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) LOOP
            -- Haverá apenas um registro com o total geral de cada coop sumarizado agora em um só
            vr_dup_qtcotist_ati     := rw_work.vr_dup_qtcotist_ati;
            vr_dup_qtcotist_dem     := rw_work.vr_dup_qtcotist_dem;
            vr_dup_qtcotist_exc     := rw_work.vr_dup_qtcotist_exc;
            vr_res_vlcapcrz_ati     := rw_work.vr_res_vlcapcrz_ati;
            vr_res_vlcapcrz_dem     := rw_work.vr_res_vlcapcrz_dem;
            vr_res_vlcapcrz_exc_age := rw_work.vr_res_vlcapcrz_exc_age;
            vr_res_vlcapcrz_tot_age := rw_work.vr_res_vlcapcrz_tot_age;
            vr_res_qtcotist_ati     := rw_work.vr_res_qtcotist_ati;
            vr_res_qtcotist_dem     := rw_work.vr_res_qtcotist_dem;
            vr_res_qtcotist_exc_age := rw_work.vr_res_qtcotist_exc_age;
            vr_res_qtcotist_tot_age := rw_work.vr_res_qtcotist_tot_age;
            vr_sub_vlcapcrz_ati     := rw_work.vr_sub_vlcapcrz_ati;
            vr_sub_vlcapcrz_dem     := rw_work.vr_sub_vlcapcrz_dem;
            vr_sub_vlcapcrz_exc     := rw_work.vr_sub_vlcapcrz_exc;
            vr_sub_vlcapcrz_tot     := rw_work.vr_sub_vlcapcrz_tot;
            vr_tot_lancamen         := rw_work.vr_tot_lancamen;
            vr_tot_vllanmto         := rw_work.vr_tot_vllanmto; 
            vr_tot_capagefis        := rw_work.vr_tot_capagefis; 
            vr_tot_capagejur        := rw_work.vr_tot_capagejur;
            vr_tot_vlcapctz_fis     := rw_work.vr_tot_vlcapctz_fis;
            vr_tot_vlcapctz_jur     := rw_work.vr_tot_vlcapctz_jur;
            vr_tot_pcapcred_fis     := rw_work.vr_tot_pcapcred_fis;
            vr_tot_pcapcred_jur     := rw_work.vr_tot_pcapcred_jur;
            vr_desconto             := rw_work.vr_desconto;
            vr_desctitu             := rw_work.vr_desctitu;
          END LOOP;
          
          -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
          pc_log_programa(PR_DSTIPLOG           => 'O'
                         ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                         ,pr_cdcooper           => pr_cdcooper
                         ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         ,pr_tpocorrencia       => 4
                         ,pr_dsmensagem         => 'Fim - Restauração valores das execuções anteriores.'
                         ,PR_IDPRGLOG           => vr_idlog_ini_ger);  
          
        END IF;  
        
        -- Acumular aos valores totais os valores por agencia, gravados ou da execução principal, ou restaurados acima
        vr_res_vlcapcrz_exc := vr_res_vlcapcrz_exc + nvl(vr_res_vlcapcrz_exc_age,0);
        vr_res_qtcotist_exc := vr_res_qtcotist_exc + nvl(vr_res_qtcotist_exc_age,0);
        vr_res_vlcapcrz_tot := vr_res_vlcapcrz_tot + nvl(vr_res_vlcapcrz_tot_age,0);
        vr_res_qtcotist_tot := vr_res_qtcotist_tot + nvl(vr_res_qtcotist_tot_age,0);        
        vr_typ_tab_total(1).res_vlcapcrz_exc := vr_typ_tab_total(1).res_vlcapcrz_exc + vr_typ_tab_total(3).res_vlcapcrz_exc;
        vr_typ_tab_total(1).res_qtcotist_exc := vr_typ_tab_total(1).res_qtcotist_exc + vr_typ_tab_total(3).res_qtcotist_exc;
        vr_typ_tab_total(1).res_vlcapcrz_tot := vr_typ_tab_total(1).res_vlcapcrz_tot + vr_typ_tab_total(3).res_vlcapcrz_tot;
        vr_typ_tab_total(1).res_qtcotist_tot := vr_typ_tab_total(1).res_qtcotist_tot + vr_typ_tab_total(3).res_qtcotist_tot;
        vr_typ_tab_total(2).res_vlcapcrz_exc := vr_typ_tab_total(2).res_vlcapcrz_exc + vr_typ_tab_total(4).res_vlcapcrz_exc;
        vr_typ_tab_total(2).res_qtcotist_exc := vr_typ_tab_total(2).res_qtcotist_exc + vr_typ_tab_total(4).res_qtcotist_exc;
        vr_typ_tab_total(2).res_vlcapcrz_tot := vr_typ_tab_total(2).res_vlcapcrz_tot + vr_typ_tab_total(4).res_vlcapcrz_tot;
        vr_typ_tab_total(2).res_qtcotist_tot := vr_typ_tab_total(2).res_qtcotist_tot + vr_typ_tab_total(4).res_qtcotist_tot;
        -- Remover as posições 3 e 4 temporariamente criadas só para este fim
        vr_typ_tab_total.delete(3);
        vr_typ_tab_total.delete(4);        
        
        -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
        pc_log_programa(pr_dstiplog     => 'O'
                       ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                       ,pr_cdcooper     => pr_cdcooper
                       ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia => 4
                       ,pr_dsmensagem   => 'Inicio - Geração Relatórios e Arquivo Contábil'
                       ,pr_idprglog     => vr_idlog_ini_ger); 
      
        -- Executar procedure geração resumo geral
        pc_imprime_crrl014_total(pr_des_erro => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        -- Executar procedure geração resumo do capital (crrl031)
        pc_crps010_2 (pr_des_erro => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        -- Executar procedure geração relatorio 421
        pc_crps010_3 (pr_des_erro => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        -- Executar procedure geração relatorio 426
        pc_crps010_4 (pr_des_erro => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        -- Executar procedure geração relatorio 398
        pc_imprime_crrl398 (pr_des_erro => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        -- Gera Arq AAMMDD_CAPITAL.txt - Dados para Contabilidade
        /*
        Remover lancamentos de segregacao/reversao para contas PF/PJ.
        Apos atualizacao do plano de contas, nao e mais necessaria realizar essa segregacao.
        Solicitacao Contabilidade - Heitor (Mouts)

        pc_gera_arq_capital(pr_des_erro => vr_dscritic);
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
        */
           
        -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Fim - Geração Relatórios e Arquivo Contábil.'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
        
        -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
        pc_log_programa(pr_dstiplog     => 'O'
                       ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                       ,pr_cdcooper     => pr_cdcooper
                       ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia => 4
                       ,pr_dsmensagem   => 'Inicio - Limpeza tabelas temporárias'
                       ,pr_idprglog     => vr_idlog_ini_ger); 
           

        -- Limpa os registros da tabela de trabalho somente em execução paralela
        IF vr_idparale > 0 THEN
          begin    
            delete from tbgen_batch_relatorio_wrk
             where cdcooper    = pr_cdcooper
               and cdprograma  = vr_cdprogra
               AND dsrelatorio IN('craplem','total_agenci','typ_total','tab_debitos','tab_demitidos','tab_totlcred','tab_duplicados','total_geral')
               and dtmvtolt    = rw_crapdat.dtmvtolt;    
          exception
            when others then
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
              raise vr_exc_saida;            
          end;
        END IF;        
        
        -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Fim - Limpeza tabelas temporárias.'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
             

        -- Processo OK, devemos chamar a fimprg
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);

        -- Caso seja o controlador 
        if vr_idcontrole <> 0 then
          -- Atualiza finalização do batch na tabela de controle 
          gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                             ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                             ,pr_dscritic   => vr_dscritic);
          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;                                       
        end if; 
   
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F'   
                       ,pr_cdprograma => vr_cdprogra           
                       ,pr_cdcooper   => pr_cdcooper 
                       ,pr_tpexecucao => 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_ger
                       ,pr_flgsucesso => 1); 
        -- Efetuar commit
        COMMIT;
      ELSE
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                           ,vr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                           ,vr_dscritic);   --pr_dscritic  OUT crapcri.dscritic%TYPE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);  
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Salvar informacoes no banco de dados
        COMMIT;
      END IF;  

   EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
        -- Na execução paralela
        IF nvl(pr_idparale,0) <> 0 THEN

          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);                                     
          
          -- Grava LOG de erro com as críticas retornadas                           
          pc_log_programa(pr_dstiplog      => 'E', 
                          pr_cdprograma    => vr_cdprogra||'_'||pr_cdagenci,
                          pr_cdcooper      => pr_cdcooper,
                          pr_tpexecucao    => vr_tpexecucao,
                          pr_tpocorrencia  => 3,
                          pr_cdcriticidade => 1,
                          pr_cdmensagem    => pr_cdcritic,
                          pr_dsmensagem    => pr_dscritic,
                          pr_flgsucesso    => 0,
                          pr_idprglog      => vr_idlog_ini_par);  
                          
          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                      ,pr_des_erro => vr_dscritic);                        
                                      
        END IF;
        
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        cecred.pc_internal_exception;
         
        -- Retornar texto do erro
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        
        -- Na execução paralela
        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par); 
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  

          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                      ,pr_des_erro => vr_dscritic);
        end if; 

        -- Efetuar rollback
        ROLLBACK;

   END;
END pc_crps010;
/
