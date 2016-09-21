/*.............................................................................

   Programa: includes/gerarazao_def.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003                     Ultima atualizacao: 07/03/2006
   
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Criacao de variaveis utilizadas pelos programas 
               crps(355,356,357,358).

               {1} -> parametro para criacao de variaveis.
               
   Alteracoes: 
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               07/03/2006 - Retirada inicializacao da variavel
                            aux_cdcxaage. Incluida no programa que acessa a
                            include(Mirtes)

..............................................................................*/

DEF STREAM str_1. /* ARQUIVO PARA MICROFILMAGEM */

DEF {1} SHARED  VAR  aux_cdcxaage AS DECI   EXTENT 99                 NO-UNDO.
DEF {1} SHARED  VAR  aux_contlinh AS INT    INITIAL 0                 NO-UNDO. 
DEF {1} SHARED  VAR  aux_tpctbcxa AS INT                              NO-UNDO.
DEF {1} SHARED  VAR  aux_contdata AS DATE   FORMAT "99/99/9999"       NO-UNDO.
DEF {1} SHARED  VAR  aux_nmmesano AS CHAR   EXTENT 12 INIT
                                            ["Janeiro",  "Fevereiro",
                                             "Marco",    "Abril",
                                             "Maio",     "Junho",
                                             "Julho",    "Agosto",
                                             "Setembro", "Outubro",
                                             "Novembro", "Dezembro"]  NO-UNDO.
DEF {1} SHARED  VAR  aux_histcred AS LOGICAL                          NO-UNDO.

DEF {1} SHARED  VAR  rel_txttermo AS CHAR   EXTENT 4                  NO-UNDO.
DEF {1} SHARED  VAR  rel_vllancrd AS DEC                              NO-UNDO.
DEF {1} SHARED  VAR  rel_vllandeb AS DEC                              NO-UNDO.
DEF {1} SHARED  VAR  rel_ttlanmto AS DEC                              NO-UNDO.
DEF {1} SHARED  VAR  rel_dtlanmto AS DATE   FORMAT "99/99/9999"       NO-UNDO.
DEF {1} SHARED  VAR  rel_cdhistor AS INT                              NO-UNDO.
DEF {1} SHARED  VAR  rel_dshistor AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_nrdconta AS INT                              NO-UNDO.
DEF {1} SHARED  VAR  rel_ttcrddia AS DEC                              NO-UNDO.
DEF {1} SHARED  VAR  rel_nmextage AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_ttdebdia AS DEC                              NO-UNDO.
DEF {1} SHARED  VAR  rel_cdagenci AS INT                              NO-UNDO.
DEF {1} SHARED  VAR  rel_ttlanage AS DEC                              NO-UNDO.
DEF {1} SHARED  VAR  rel_nrctadeb AS INT                              NO-UNDO.
DEF {1} SHARED  VAR  rel_nrctacrd AS INT                              NO-UNDO.
DEF {1} SHARED  VAR  rel_tpdrazao AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_nrdocmto AS DEC                              NO-UNDO.
DEF {1} SHARED  VAR  rel_vllamnto AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_nmcooper AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_cablinha AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_hislinha AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_linhpont AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_linhastr AS CHAR                             NO-UNDO.
DEF {1} SHARED  VAR  rel_contapag AS INT    INITIAL 1                 NO-UNDO.
DEF {1} SHARED  VAR  rel_nrdlivro AS INT                              NO-UNDO.
DEF {1} SHARED  VAR  rel_dtterabr AS DATE   FORMAT "99/99/9999"       NO-UNDO.

DEF {1} SHARED  VAR  aux_novapagi AS CHAR   INITIAL "1"               NO-UNDO.
DEF {1} SHARED  VAR  aux_novalinh AS CHAR   INITIAL " "               NO-UNDO.
DEF {1} SHARED  VAR  aux_pulalinh AS CHAR   INITIAL "0"               NO-UNDO.
DEF {1} SHARED  VAR  aux_sobrlinh AS CHAR   INITIAL "+"               NO-UNDO.
/*====
FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper   NO-LOCK:
    aux_cdcxaage[crapage.cdagenci] = crapage.cdcxaage.   
END. 
===*/

rel_linhpont = FILL("-", 132).
rel_linhastr = FILL(" ", 4) + FILL("*", 10) + " **** *** ********** " +
               FILL("*", 35) + " *********** ******** ********** " +
               FILL("*", 14) + " " + FILL("*", 14).
/*............................................................................*/
