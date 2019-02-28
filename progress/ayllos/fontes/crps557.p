/* ............................................................................

   Programa: Fontes/crps557.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Janeiro/2010.                    Ultima atualizacao: 20/02/2019.

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Relatorio de Tarifas da COMPE - Por Cooperativa
               Gera relatorio crrl543 e crrl623
               Executa somente na CECRED

   Alteracoes: 01/06/2010 - Incluir NEW na includes/var_batch.i e troca de
                            data oan -> olt (Ze).

               07/07/2010 - Acertos no posicionamento do relatorio e inclusao
                            da descricao da Cooperativa na primeira coluna
                            (Guilherme/Supero)

               04/08/2010 - Alteracao na Soma dos Valores CHQ/TIT/DOC (Ze).

               16/08/2010 - Acerto no Relatorio (Ze).

               28/09/2010 - Alteracao no layout do relatorio 543 e incluido
                            devolucao dos cheques (Adriano).

               17/05/2011 - Inclusao do calculo de COB SR e no layout do
                            relatorio 543. (Guilherme/Supero)

               10/06/2011 - Alteracao acima nao estava fazendo a soma dos totais
                            se Cob SR (Guilherme).

               03/04/2012 - TIB DDA/Ajuste layout relatorio (Guilherme/Supero)
               
               17/08/2012 - Criado relatorio 623 - Tarifas ABBC Diario (Rafael).
               
               03/09/2012 - Inicializar variaveis dos frames f_total (Rafael).
               
               04/09/2012 - Inclusão dos campos qtdtic e valortic para o
                            relatorio de cheques roubados/dev. (Lucas R.)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
               
............................................................................. */

DEF STREAM str_1.   
DEF STREAM str_2.   /* Relatorio */ 

{ includes/var_batch.i "NEW" } 

/* chamado oracle - 20/02/2019 - Chamado REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
                                     
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_qtdchqnr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totchqnr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_qtdchqsr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totchqsr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totalchq AS DEC   INIT 0                          NO-UNDO.

DEF        VAR aux_qtdtitnr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_qtdtitsr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_tottitnr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_tottitsr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totaltit AS DEC   INIT 0                          NO-UNDO.

DEF        VAR aux_qtdddanr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_qtdddasr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totddanr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totddasr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totaldda AS DEC   INIT 0                          NO-UNDO.

DEF        VAR aux_qtddocnr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totdocnr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_qtddocsr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totdocsr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totaldoc AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totalliq AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totlqcob AS DEC   INIT 0                          NO-UNDO.

DEF        VAR aux_dataini  AS DATE                                  NO-UNDO.
DEF        VAR aux_datafim  AS DATE                                  NO-UNDO.
DEF        VAR aux_dscooper AS CHAR                                  NO-UNDO.


DEF        VAR aux_qtdcronr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totcronr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_qtdcrosr AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totcrosr AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totchqro AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_qtdcdeno AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totcdeno AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_qtdcdedi AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_totcdedi AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_totchqde AS DEC   INIT 0                          NO-UNDO.

DEF        VAR aux_somaqicf AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_somaticf AS DEC   INIT 0                          NO-UNDO.
DEF        VAR aux_somaqccf AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_somatccf AS DEC   INIT 0                          NO-UNDO.

DEF        VAR aux_somaqtic AS INT   INIT 0                          NO-UNDO.
DEF        VAR aux_somattic AS DEC   INIT 0                          NO-UNDO.

DEF        VAR aux_fill_75  AS CHAR  FORMAT "x(75)"                  NO-UNDO.
DEF        VAR aux_fill_24  AS CHAR  FORMAT "x(24)"                  NO-UNDO.
DEF        VAR aux_dsagenci AS CHAR                                  NO-UNDO.

DEF        VAR aux_fill_144 AS CHAR  FORMAT "x(207)"                 NO-UNDO.
DEF        VAR aux_fill_191 AS CHAR  FORMAT "x(208)"                 NO-UNDO.

DEF        VAR h-b1wgen0015 AS HANDLE                                NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.

DEF TEMP-TABLE w-relat-1                                             NO-UNDO
    FIELD dscooper  AS CHAR
    /*CHEQUE*/
    FIELD qtdchqnr  AS INT
    FIELD totchqnr  AS DEC
    FIELD qtdchqsr  AS INT
    FIELD totchqsr  AS DEC
    FIELD totalchq  AS DEC
    /*DOC*/
    FIELD qtddocnr  AS INT
    FIELD totdocnr  AS DEC
    FIELD qtddocsr  AS INT
    FIELD totdocsr  AS DEC
    FIELD totaldoc  AS DEC
    FIELD totalliq  AS DEC /* CHEQUE + DOC */
    /*TITULO/COBRANCA*/
    FIELD qtdtitnr  AS INT
    FIELD qtdtitsr  AS INT
    FIELD tottitnr  AS DEC
    FIELD tottitsr  AS DEC
    FIELD totaltit  AS DEC
    /*COBRANCA/DDA*/
    FIELD qtdddanr  AS INT
    FIELD qtdddasr  AS INT
    FIELD totddanr  AS DEC
    FIELD totddasr  AS DEC
    FIELD totaldda  AS DEC
    FIELD totlqcob  AS DEC /*COBRANCA + DDA*/
    /*CHEQUE ROUBADO*/
    FIELD qtdcronr  AS INT
    FIELD totcronr  AS DEC
    FIELD qtdcrosr  AS INT
    FIELD totcrosr  AS DEC
    FIELD totchqro  AS DEC
    /* DEVOL CHEQUES */
    FIELD qtdcdeno  AS INT
    FIELD totcdeno  AS DEC
    FIELD totcdqde  AS DEC /*nao usado*/
    FIELD qtdcdedi  AS INT
    FIELD totcdedi  AS DEC
    FIELD totchqde  AS DEC
    /*ICF*/
    FIELD qtde_icf  AS INT
    FIELD totalicf  AS DEC
    /*CCF*/
    FIELD qtde_ccf  AS INT
    FIELD totalccf  AS DEC
    /*TIC*/
    FIELD qtde_tic AS INT
    FIELD totaltic AS DEC
    INDEX w-relat-11 AS PRIMARY dscooper. 
    

FORM SKIP(1)
     "CHEQUES NR/SR : R$"   gncdtrf.vltrfchq  FORMAT ">>9.99"
     "   -   DOC NR/SR   : R$"   gncdtrf.vltrfdoc  FORMAT ">>9.99"   SKIP
     SKIP(1)
     "CHEQUE"                                               AT 043
     "DOC"                                                  AT 107
     SKIP
     "Nossa Remessa"                                        AT 028
     "Sua Remessa"                                          AT 052
     "Nossa Remessa"                                        AT 091
     "Sua Remessa"                                          AT 115
     SKIP
     "-------------------"                                  AT 001
     aux_fill_144                                           AT 022
     SKIP
     "COOPERATIVA"                                          AT 001
     "Qtde"                                                 AT 026
     "Valor"                                                AT 039
     "Qtde"                                                 AT 049
     "Valor"                                                AT 062
     "Total CHEQUE"                                         AT 071
     "Qtde"                                                 AT 089
     "Valor"                                                AT 102
     "Qtde"                                                 AT 112
     "Valor"                                                AT 125
     "Total DOC"                                            AT 137
     "TOTAL LIQUIDO (R$)"                                   AT 148
     SKIP
     "-------------------"                                  AT 001
     "--------"                                             AT 022
     "-------------"                                        AT 031
     "--------"                                             AT 045
     "-------------"                                        AT 054
     "---------------"                                      AT 068
     "--------"                                             AT 085
     "-------------"                                        AT 094
     "--------"                                             AT 108
     "-------------"                                        AT 117
     "---------------"                                      AT 131
     "------------------"                                   AT 148
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_cabec_1.

FORM 
     "COBRANCA NR/SR/VLB : R$"   gncdtrf.vltrftit  FORMAT ">>9.99"
     "   -   COBRANCA NR/SR/VLB DDA : R$"   gncdtrf.vltrfdda  FORMAT ">>9.99"
     SKIP
     SKIP(1)
     "COBRANCA"                                             AT 042
     "COBRANCA  DDA"                                        AT 103
     SKIP
     "Nossa Remessa"                                        AT 028
     "Sua Remessa"                                          AT 052
     "Nossa Remessa"                                        AT 091
     "Sua Remessa"                                          AT 115
     SKIP
     "-------------------"                                  AT 001
     aux_fill_144                                           AT 022
     SKIP
     "COOPERATIVA"                                          AT 001
     "Qtde"                                                 AT 026
     "Valor"                                                AT 039
     "Qtde"                                                 AT 049
     "Valor"                                                AT 062
     "Total COBRANCA"                                       AT 069
     "Qtde"                                                 AT 089
     "Valor"                                                AT 102
     "Qtde"                                                 AT 112
     "Valor"                                                AT 125
     "Total COBRANCA"                                       AT 132
     "TOTAL LIQUIDO (R$)"                                   AT 148
     SKIP
     "-------------------"                                  AT 001
     "--------"                                             AT 022
     "-------------"                                        AT 031
     "--------"                                             AT 045
     "-------------"                                        AT 054
     "---------------"                                      AT 068
     "--------"                                             AT 085
     "-------------"                                        AT 094
     "--------"                                             AT 108
     "-------------"                                        AT 117
     "---------------"                                      AT 131
     "------------------"                                   AT 148
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_cabec_2.


FORM SKIP(1)
     "CHEQUE ROUBADO/DEVOLUCAO/ICF/CCF/TIC"
     "   -   "
     "Valor Tarifas"
     "   -   "
     "  Cheque roubado: R$"      gncdtrf.vlchqrob  FORMAT ">>9.99" AT 91
     "   -   "
     "  Cheque devolucao: R$"    gncdtrf.vltrfdev  FORMAT ">>9.99" AT 136
     "   -   "
     "  ICF: R$"                 gncdtrf.vltrficf  FORMAT ">>9.99" AT 166
     "   -   "
     "  CCF: R$"                 gncdtrf.vltrfccf  FORMAT ">>9.99" AT 196

     "  TIC: R$"                 gncdtrf.vltrftic  FORMAT ">>9.99" AT 219
     WITH NO-BOX NO-LABELS WIDTH 230 FRAME f_cabec_3.


FORM SKIP(1)
     "CHEQUE ROUBADO"                   AT 041
     "DEVOLUCAO CHEQUES"                AT 116
     "ICF"                              AT 170
     "CCF"                              AT 188
     "TIC"                              AT 210
     SKIP
     "Nossa Remessa"                    AT 028
     "Sua Remessa"                      AT 054
     "Noturno"                          AT 108
     "Diurno"                           AT 137
     SKIP
     "-------------------"              AT 001
     aux_fill_191                       AT 022 
     SKIP
     "COOPERATIVA"                      AT 001 
     "Qtde"                             AT 026
     "Valor"                            AT 041
     "Qtde"                             AT 051
     "Valor"                            AT 066
     "Tot Chq Roub (R$)"                AT 072
     "Qtde"                             AT 94
     "Valor"                            AT 109
     "Qtde"                             AT 119
     "Valor"                            AT 134
     "Total Dev"                        AT 146
     "Qtde"                             AT 160
     "Valor"                            AT 175
     "Qtde"                             AT 185
     "Valor"                            AT 200
     "Qtde"                             AT 210
     "Valor"                            AT 225
     SKIP
     "-------------------"              AT 001 
     "--------"                         AT 022
     "---------------"                  AT 031
     "--------"                         AT 047
     "---------------"                  AT 056
     "-----------------"                AT 072
     "--------"                         AT 090
     "---------------"                  AT 099
     "--------"                         AT 115
     "---------------"                  AT 124
     "---------------"                  AT 140
     "--------"                         AT 156
     "---------------"                  AT 165
     "--------"                         AT 181
     "---------------"                  AT 190
     "--------"                         AT 206
     "---------------"                  AT 215
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_titulo_3.


FORM SKIP
     w-relat-1.dscooper   FORMAT "x(19)"                    AT 001
     /* CHEQUE */
     w-relat-1.qtdchqnr   FORMAT ">>>,>>9"                  AT 023
     w-relat-1.totchqnr   FORMAT ">,>>>,>>9.99-"            AT 032
     w-relat-1.qtdchqsr   FORMAT ">>>,>>9"                  AT 046
     w-relat-1.totchqsr   FORMAT ">,>>>,>>9.99-"            AT 055
     w-relat-1.totalchq   FORMAT ">>>,>>>,>>9.99-"          AT 069
     /* DOC */
     w-relat-1.qtddocnr   FORMAT ">>>,>>9"                  AT 086
     w-relat-1.totdocnr   FORMAT ">,>>>,>>9.99-"            AT 095
     w-relat-1.qtddocsr   FORMAT ">>>,>>9"                  AT 109
     w-relat-1.totdocsr   FORMAT ">,>>>,>>9.99-"            AT 118
     w-relat-1.totaldoc   FORMAT ">>>,>>>,>>9.99-"          AT 132
     
     w-relat-1.totalliq   FORMAT ">,>>>,>>>,>>9.99-"        AT 150
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_result_1.


FORM SKIP
     w-relat-1.dscooper   FORMAT "x(19)"                    AT 001
     /* COBRANCA */
     w-relat-1.qtdtitnr   FORMAT ">>>,>>9"                  AT 023
     w-relat-1.tottitnr   FORMAT ">,>>>,>>9.99-"            AT 032
     w-relat-1.qtdtitsr   FORMAT ">>>,>>9"                  AT 046
     w-relat-1.tottitsr   FORMAT ">,>>>,>>9.99-"            AT 055
     w-relat-1.totaltit   FORMAT ">>>,>>>,>>9.99-"          AT 069
     /* COBRANCA DDA */
     w-relat-1.qtdddanr   FORMAT ">>>,>>9"                  AT 086
     w-relat-1.totddanr   FORMAT ">,>>>,>>9.99-"            AT 095
     w-relat-1.qtdddasr   FORMAT ">>>,>>9"                  AT 109
     w-relat-1.totddasr   FORMAT ">,>>>,>>9.99-"            AT 118
     w-relat-1.totaldda   FORMAT ">>>,>>>,>>9.99-"          AT 132
     
     w-relat-1.totlqcob   FORMAT ">,>>>,>>>,>>9.99-"        AT 150
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_result_2.


FORM SKIP
     /* CHEQUE ROUBADO */
     w-relat-1.dscooper  FORMAT "x(19)"                     AT 001 
     w-relat-1.qtdcronr  FORMAT ">>>,>>9"                   AT 023
     w-relat-1.totcronr  FORMAT ">>>,>>>,>>9.99-"           AT 032
     w-relat-1.qtdcrosr  FORMAT ">>>,>>9"                   AT 048
     w-relat-1.totcrosr  FORMAT ">>>,>>>,>>9.99"            AT 057
     w-relat-1.totchqro  FORMAT ">>>,>>>,>>>,>>9.99-"       AT 071
     /* DEVOLUCAO */ 
     w-relat-1.qtdcdeno  FORMAT ">>>,>>9"                   AT 091
     w-relat-1.totcdeno  FORMAT ">>>,>>>,>>9.99"            AT 100
     w-relat-1.qtdcdedi  FORMAT ">>>,>>9"                   AT 116
     w-relat-1.totcdedi  FORMAT ">>>,>>>,>>9.99"            AT 125
     w-relat-1.totchqde  FORMAT ">>>,>>>,>>9.99"            AT 141
     /* ICF */
     w-relat-1.qtde_icf  FORMAT ">>>,>>9"                   AT 157
     w-relat-1.totalicf  FORMAT ">>>,>>>,>>9.99"            AT 166
     /* CCF */
     w-relat-1.qtde_ccf  FORMAT ">>>,>>9"                   AT 182
     w-relat-1.totalccf  FORMAT ">>>,>>>,>>9.99"            AT 191
     /* TIC */
     w-relat-1.qtde_tic  FORMAT ">>>,>>9"                   AT 207
     w-relat-1.totaltic  FORMAT ">>>,>>>,>>9.99"            AT 216
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_result_3.


FORM "-------------------"                                  AT 001
     aux_fill_144                                           AT 022
     SKIP
     "TOTAL"                                                AT 001  
     aux_qtdchqnr         FORMAT ">>>,>>9"                  AT 023
     aux_totchqnr         FORMAT ">,>>>,>>9.99-"            AT 032
     aux_qtdchqsr         FORMAT ">>>,>>9"                  AT 046
     aux_totchqsr         FORMAT ">,>>>,>>9.99-"            AT 055
     aux_totalchq         FORMAT ">>>,>>>,>>9.99-"          AT 069

     aux_qtddocnr         FORMAT ">>>,>>9"                  AT 086
     aux_totdocnr         FORMAT ">,>>>,>>9.99-"            AT 095
     aux_qtddocsr         FORMAT ">>>,>>9"                  AT 109
     aux_totdocsr         FORMAT ">,>>>,>>9.99-"            AT 118
     aux_totaldoc         FORMAT ">>>,>>>,>>9.99-"          AT 132

     aux_totalliq         FORMAT ">,>>>,>>>,>>9.99-"        AT 150
     SKIP(4) 
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_total_1.

FORM "-------------------"                                  AT 001
     aux_fill_144                                           AT 022
     SKIP
     "TOTAL"                                                AT 001  
     aux_qtdtitnr         FORMAT ">>>,>>9"                  AT 023
     aux_tottitnr         FORMAT ">,>>>,>>9.99-"            AT 032
     aux_qtdtitsr         FORMAT ">>>,>>9"                  AT 046
     aux_tottitsr         FORMAT ">,>>>,>>9.99-"            AT 055
     aux_totaltit         FORMAT ">>>,>>>,>>9.99-"          AT 069

     aux_qtdddanr         FORMAT ">>>,>>9"                  AT 086
     aux_totddanr         FORMAT ">,>>>,>>9.99-"            AT 095
     aux_qtdddasr         FORMAT ">>>,>>9"                  AT 109
     aux_totddasr         FORMAT ">,>>>,>>9.99-"            AT 118
     aux_totaldda         FORMAT ">>>,>>>,>>9.99-"          AT 132
     
     aux_totlqcob         FORMAT ">,>>>,>>>,>>9.99-"        AT 150
     SKIP(4) 
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_total_2.

FORM SKIP
     "-------------------"                                  AT 001
     aux_fill_191                                           AT 022
     SKIP
     "TOTAL"                                                AT 001 
     aux_qtdcronr        FORMAT ">>>,>>9"                   AT 023
     aux_totcronr        FORMAT ">>>,>>>,>>9.99-"           AT 032
     aux_qtdcrosr        FORMAT ">>>,>>9"                   AT 048
     aux_totcrosr        FORMAT ">>>,>>>,>>9.99"            AT 057
     aux_totchqro        FORMAT ">>>,>>>,>>>,>>9.99-"       AT 071
     aux_qtdcdeno        FORMAT ">>>,>>9"                   AT 091
     aux_totcdeno        FORMAT ">>>,>>>,>>9.99"            AT 100
     aux_qtdcdedi        FORMAT ">>>,>>9"                   AT 116
     aux_totcdedi        FORMAT ">>>,>>>,>>9.99"            AT 125
     aux_totchqde        FORMAT ">>>,>>>,>>9.99"            AT 141
     aux_somaqicf        FORMAT ">>>,>>9"                   AT 157
     aux_somaticf        FORMAT ">>>,>>>,>>9.99"            AT 166
     aux_somaqccf        FORMAT ">>>,>>9"                   AT 182
     aux_somatccf        FORMAT ">>>,>>>,>>9.99"            AT 191
     aux_somaqtic        FORMAT ">>>,>>9"                   AT 207
     aux_somattic        FORMAT ">>>,>>>,>>9.99"            AT 216
     SKIP(4)
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_total_3.
     

ASSIGN glb_cdprogra = "crps557"
       aux_fill_144 = FILL("-",144)
       aux_fill_191 = FILL("-",208)
       glb_flgbatch = false.

RUN fontes/iniprg.p.   

IF   glb_cdcritic > 0 THEN
     QUIT.
  
/* Busca os valores das Tarifas */
FIND FIRST gncdtrf NO-LOCK NO-ERROR.

/* Será executado sempre no primeiro dia do mes, sendo assim, a variavel
   glb_dtmvtolt conterá  a data do ultimo dia do mes anterior  */

ASSIGN aux_dataini = glb_dtmvtolt
       aux_datafim = glb_dtmvtolt. 

/* execucao diaria - relatorio crrl623 */
RUN pi_processa_tarifas(INPUT aux_dataini,
                        INPUT aux_datafim).

/* GERAR RELATORIO */
ASSIGN aux_nmarqimp   = "rl/crrl623.lst"
       glb_cdrelato[1] = 623
       glb_cdempres    = 11.

RUN pi_processa_relatorio.

/* busca o ultimo dia util do mes */
RUN sistema/generico/procedures/b1wgen0015.p
    PERSISTENT SET h-b1wgen0015.

ASSIGN aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                        YEAR(glb_dtmvtolt)) + 4) -
                        DAY(DATE(MONTH(glb_dtmvtolt),28,
                        YEAR(glb_dtmvtolt)) + 4)).

RUN retorna-dia-util in h-b1wgen0015
    (INPUT glb_cdcooper,
     INPUT TRUE,  /** Feriado  **/
     INPUT TRUE,  /** Anterior **/
     INPUT-OUTPUT aux_dtultdia).

DELETE PROCEDURE h-b1wgen0015.

/* se a dtmvtolt = ultimo dia util, entao gerar relatorio 543 */
IF glb_dtmvtolt = aux_dtultdia THEN
DO:                                  
   ASSIGN aux_dataini = DATE(MONTH(glb_dtmvtolt),1,YEAR(glb_dtmvtolt))
          aux_datafim = glb_dtmvtolt.

   /* execucao mensal - relatorio crrl543 */
   RUN pi_processa_tarifas(INPUT aux_dataini,
                           INPUT aux_datafim).

   /* GERAR RELATORIO */
   ASSIGN aux_nmarqimp    = "rl/crrl543.lst"
          glb_cdrelato[1] = 543
          glb_cdempres    = 11.

   RUN pi_processa_relatorio.
END.

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS557.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS557.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

RUN fontes/fimprg.p.

PROCEDURE pi_processa_tarifas:

    DEF  INPUT PARAM par_dataini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_datafim AS DATE                           NO-UNDO.
 
    EMPTY TEMP-TABLE w-relat-1.

    /* Processa todos os lancamentos do periodo informado */
    FOR EACH gntarcp WHERE gntarcp.dtmvtolt >= par_dataini  AND
                           gntarcp.dtmvtolt <= par_datafim  NO-LOCK
                           BREAK BY gntarcp.cdcooper:
       
        FIND FIRST crapcop WHERE crapcop.cdcooper = gntarcp.cdcooper
             NO-LOCK NO-ERROR.
    
        IF   AVAIL crapcop THEN
             aux_dscooper = TRIM(STRING(crapcop.cdcooper,"999") + " - " + 
                            crapcop.nmrescop).
        ELSE
             aux_dscooper = "000 - Sem Identific.".
        
        FIND FIRST w-relat-1 WHERE w-relat-1.dscooper = aux_dscooper
                                   NO-LOCK NO-ERROR.
          
        IF   NOT AVAIL w-relat-1 THEN 
             DO:
                 CREATE w-relat-1.
                 ASSIGN w-relat-1.dscooper = aux_dscooper.
                       
             END.
        
        CASE gntarcp.cdtipdoc:
        
             /* CHQ DEVOL SR - DIURNO/NOTURNO */
             WHEN 9 OR WHEN 10 THEN 
                  DO:
                      IF   gntarcp.cdtipdoc = 9 THEN
                           ASSIGN w-relat-1.qtdcdeno = w-relat-1.qtdcdeno +
                                                       gntarcp.qtdocmto
                                  w-relat-1.totcdeno = w-relat-1.totcdeno +
                                                       gntarcp.vldocmto
                                  w-relat-1.totchqde = w-relat-1.totchqde +
                                                       gntarcp.vldocmto.
                      ELSE
                           ASSIGN w-relat-1.qtdcdedi = w-relat-1.qtdcdedi +
                                                       gntarcp.qtdocmto
                                  w-relat-1.totcdedi = w-relat-1.totcdedi +
                                                       gntarcp.vldocmto
                                  w-relat-1.totchqde = w-relat-1.totchqde + 
                                                       gntarcp.vldocmto.
                  END.
           
           
             /* CHQ ROUB NR / SR */
             WHEN 11 OR WHEN 12 THEN 
                  DO:
                      IF   gntarcp.cdtipdoc = 11 THEN
                           ASSIGN w-relat-1.qtdcronr = w-relat-1.qtdcronr +
                                                       gntarcp.qtdocmto
                                  w-relat-1.totcronr = w-relat-1.totcronr -
                                                       gntarcp.vldocmto
                                  w-relat-1.totchqro = w-relat-1.totchqro -
                                                       gntarcp.vldocmto.
                      ELSE
                           ASSIGN w-relat-1.qtdcrosr = w-relat-1.qtdcrosr +
                                                       gntarcp.qtdocmto
                                  w-relat-1.totcrosr = w-relat-1.totcrosr +
                                                       gntarcp.vldocmto
                                  w-relat-1.totchqro = w-relat-1.totchqro + 
                                                      gntarcp.vldocmto.
                  END.
       
             /* ICF */
             WHEN 13 THEN 
                  ASSIGN w-relat-1.qtde_icf = w-relat-1.qtde_icf +
                                              gntarcp.qtdocmto
                         w-relat-1.totalicf = w-relat-1.totalicf + 
                                              gntarcp.vldocmto.
             /* CCF */
             WHEN 18 THEN
                  ASSIGN w-relat-1.qtde_ccf = w-relat-1.qtde_ccf +
                                              gntarcp.qtdocmto
                         w-relat-1.totalccf = w-relat-1.totalccf +
                                              gntarcp.vldocmto.
            
             /* CHEQUES NR */
             WHEN 1 OR WHEN 2 THEN 
                 DO:
                     ASSIGN w-relat-1.totchqnr = w-relat-1.totchqnr +
                                                 gntarcp.vldocmto
                            w-relat-1.totalchq = w-relat-1.totalchq +
                                                 gntarcp.vldocmto
                            w-relat-1.qtdchqnr = w-relat-1.qtdchqnr +
                                                 gntarcp.qtdocmto.
                 END.
                
             /* CHEQUES SR */
             WHEN 6 OR WHEN 7 THEN 
                 DO:
                     ASSIGN w-relat-1.totchqsr = w-relat-1.totchqsr -
                                                 gntarcp.vldocmto
                            w-relat-1.totalchq = w-relat-1.totalchq -
                                                 gntarcp.vldocmto
                            w-relat-1.qtdchqsr = w-relat-1.qtdchqsr +
                                                 gntarcp.qtdocmto.
                 END.
        
             /* TITULO/COBRANCA NR */
             WHEN 3 OR WHEN 4 THEN 
                 ASSIGN w-relat-1.tottitnr = w-relat-1.tottitnr + 
                                             gntarcp.vldocmto
                        w-relat-1.totaltit = w-relat-1.totaltit +
                                             gntarcp.vldocmto
                        w-relat-1.qtdtitnr = w-relat-1.qtdtitnr +
                                             gntarcp.qtdocmto.
    
             /* TITULO/COBRANCA SR */
             WHEN 19 OR WHEN 20 THEN
                 ASSIGN w-relat-1.tottitsr = w-relat-1.tottitsr -
                                             gntarcp.vldocmto
                        w-relat-1.totaltit = w-relat-1.totaltit -
                                             gntarcp.vldocmto
                        w-relat-1.qtdtitsr = w-relat-1.qtdtitsr +
                                             gntarcp.qtdocmto.
    
             /* DOC NR e SR */
             WHEN 5 OR WHEN 8 THEN
                 DO:
                     IF   gntarcp.cdtipdoc = 5 THEN
                          ASSIGN w-relat-1.qtddocnr = w-relat-1.qtddocnr +
                                                      gntarcp.qtdocmto
                                 w-relat-1.totdocnr = w-relat-1.totdocnr -
                                                      gntarcp.vldocmto
                                 w-relat-1.totaldoc = w-relat-1.totaldoc -
                                                      gntarcp.vldocmto.
                     ELSE
                          ASSIGN w-relat-1.qtddocsr = w-relat-1.qtddocsr +
                                                      gntarcp.qtdocmto
                                 w-relat-1.totdocsr = w-relat-1.totdocsr +
                                                      gntarcp.vldocmto
                                 w-relat-1.totaldoc = w-relat-1.totaldoc +
                                                      gntarcp.vldocmto.
                 END.
    
             /* DDA NR */
             WHEN 21 OR WHEN 22 THEN 
                 ASSIGN w-relat-1.totddanr = w-relat-1.totddanr + 
                                             gntarcp.vldocmto
                        w-relat-1.totaldda = w-relat-1.totaldda +
                                             gntarcp.vldocmto
                        w-relat-1.qtdddanr = w-relat-1.qtdddanr +
                                             gntarcp.qtdocmto.
    
             /* DDA SR */
             WHEN 23 OR WHEN 24 THEN
                 ASSIGN w-relat-1.totddasr = w-relat-1.totddasr -
                                             gntarcp.vldocmto
                        w-relat-1.totaldda = w-relat-1.totaldda -
                                             gntarcp.vldocmto
                        w-relat-1.qtdddasr = w-relat-1.qtdddasr +
                                             gntarcp.qtdocmto.

             /*TIC*/
             WHEN 25 THEN
                 ASSIGN w-relat-1.qtde_tic = w-relat-1.qtde_tic +
                                             gntarcp.qtdocmto
                        w-relat-1.totaltic = w-relat-1.totaltic +
                                             gntarcp.vldocmto.

    
        END CASE.
        
        IF   LAST-OF (gntarcp.cdcooper) THEN 
             ASSIGN w-relat-1.totalliq = w-relat-1.totalchq +
                                         w-relat-1.totaldoc
                    w-relat-1.totlqcob = w-relat-1.totaltit +
                                         w-relat-1.totaldda.
        
    END. /* END FOR EACH gntarcp */

END. /* END - pi_processa_tarifas */

PROCEDURE pi_processa_relatorio:
    
    { includes/cabrel234_1.i }
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 62.
    
    VIEW STREAM str_1 FRAME f_cabrel234_1.
                                          
    
    /* INICIO - MOSTRAR 1a PARTE DO RELATORIO */
    DISPLAY STREAM str_1  gncdtrf.vltrfchq  gncdtrf.vltrfdoc
                          aux_fill_144 WITH FRAME f_cabec_1.


    ASSIGN aux_qtdchqnr = 0
           aux_totchqnr = 0
           aux_qtdchqsr = 0
           aux_totchqsr = 0
           aux_totalchq = 0
                       
           aux_qtddocnr = 0
           aux_totdocnr = 0
           aux_qtddocsr = 0
           aux_totdocsr = 0
           aux_totaldoc = 0
           aux_totalliq = 0.

    FOR EACH w-relat-1
        BREAK BY w-relat-1.dscooper:
    
        DISPLAY STREAM str_1 w-relat-1.dscooper w-relat-1.qtdchqnr
                             w-relat-1.totchqnr w-relat-1.qtdchqsr
                             w-relat-1.totchqsr w-relat-1.totalchq
    
                             w-relat-1.qtddocnr w-relat-1.totdocnr
                             w-relat-1.qtddocsr w-relat-1.totdocsr
                             w-relat-1.totaldoc w-relat-1.totalliq
                             WITH FRAME f_result_1.
    
        DOWN WITH FRAME f_result_1.
    
        ASSIGN aux_qtdchqnr = aux_qtdchqnr + w-relat-1.qtdchqnr
               aux_totchqnr = aux_totchqnr + w-relat-1.totchqnr
               aux_qtdchqsr = aux_qtdchqsr + w-relat-1.qtdchqsr
               aux_totchqsr = aux_totchqsr + w-relat-1.totchqsr
               aux_totalchq = aux_totalchq + w-relat-1.totalchq
               aux_qtddocnr = aux_qtddocnr + w-relat-1.qtddocnr
               aux_totdocnr = aux_totdocnr + w-relat-1.totdocnr
               aux_qtddocsr = aux_qtddocsr + w-relat-1.qtddocsr
               aux_totdocsr = aux_totdocsr + w-relat-1.totdocsr
               aux_totaldoc = aux_totaldoc + w-relat-1.totaldoc
               aux_totalliq = aux_totalliq + w-relat-1.totalliq.
    
    END. /* END FOREACH */
    
    DISPLAY STREAM str_1 aux_fill_144  aux_qtdchqnr  aux_totchqnr  aux_qtdchqsr
                         aux_totchqsr  aux_totalchq  aux_qtddocnr  aux_totdocnr
                         aux_qtddocsr  aux_totdocsr  aux_totaldoc  aux_totalliq
                         WITH FRAME f_total_1.
    /* FIM - MOSTRAR 1a PARTE DO RELATORIO */
                                            
           
    
    /* INICIO - MOSTRAR 2a PARTE DO RELATORIO */
    DISPLAY STREAM str_1  gncdtrf.vltrftit  gncdtrf.vltrfdda
                          aux_fill_144 WITH FRAME f_cabec_2.

    
    ASSIGN aux_qtdtitnr = 0
           aux_tottitnr = 0
           aux_qtdtitsr = 0
           aux_tottitsr = 0
           aux_totaltit = 0
           aux_qtdddanr = 0
           aux_totddanr = 0
           aux_qtdddasr = 0
           aux_totddasr = 0
           aux_totaldda = 0
           aux_totlqcob = 0.
                        
    FOR EACH w-relat-1
        BREAK BY w-relat-1.dscooper:
    
        DISPLAY STREAM str_1 w-relat-1.dscooper
                             w-relat-1.qtdtitnr w-relat-1.tottitnr
                             w-relat-1.qtdtitsr w-relat-1.tottitsr
                             w-relat-1.totaltit
                             w-relat-1.qtdddanr w-relat-1.totddanr
                             w-relat-1.qtdddasr w-relat-1.totddasr
                             w-relat-1.totaldda
                             w-relat-1.totlqcob WITH FRAME f_result_2.
        
        DOWN WITH FRAME f_result_2.
    
        ASSIGN aux_qtdtitnr = aux_qtdtitnr + w-relat-1.qtdtitnr
               aux_tottitnr = aux_tottitnr + w-relat-1.tottitnr
               aux_qtdtitsr = aux_qtdtitsr + w-relat-1.qtdtitsr
               aux_tottitsr = aux_tottitsr + w-relat-1.tottitsr
               aux_totaltit = aux_totaltit + w-relat-1.totaltit
    
               aux_qtdddanr = aux_qtdddanr + w-relat-1.qtdddanr
               aux_totddanr = aux_totddanr + w-relat-1.totddanr
               aux_qtdddasr = aux_qtdddasr + w-relat-1.qtdddasr
               aux_totddasr = aux_totddasr + w-relat-1.totddasr
               aux_totaldda = aux_totaldda + w-relat-1.totaldda
               aux_totlqcob = aux_totlqcob + w-relat-1.totlqcob.
    
    END. /* END FOREACH */
    
    DISPLAY STREAM str_1 aux_fill_144  
                         aux_qtdtitnr  aux_tottitnr  aux_qtdtitsr  aux_tottitsr
                         aux_totaltit
                         aux_qtdddanr  aux_totddanr  aux_qtdddasr  aux_totddasr
                         aux_totaldda  aux_totlqcob
                         WITH FRAME f_total_2.
    /* FIM - MOSTRAR 2a PARTE DO RELATORIO */
    
    PAGE STREAM str_1.
    
    /* INICIO - MOSTRAR 3a PARTE DO RELATORIO */
    
    DISPLAY STREAM str_1 gncdtrf.vlchqrob gncdtrf.vltrfdev gncdtrf.vltrficf 
                         gncdtrf.vltrfccf gncdtrf.vltrftic WITH FRAME f_cabec_3.
    
    DISPLAY STREAM str_1 aux_fill_191 WITH FRAME f_titulo_3.

    ASSIGN aux_qtdcronr = 0
           aux_totcronr = 0
           aux_qtdcrosr = 0
           aux_totcrosr = 0
           aux_totchqro = 0
           aux_qtdcdeno = 0
           aux_totcdeno = 0
           aux_qtdcdedi = 0
           aux_totcdedi = 0
           aux_totchqde = 0
           aux_somaqicf = 0
           aux_somaticf = 0
           aux_somaqccf = 0
           aux_somatccf = 0
           aux_somaqtic = 0
           aux_somattic = 0.
    
    FOR EACH w-relat-1
        BREAK BY w-relat-1.dscooper:
    
        DISPLAY STREAM str_1 w-relat-1.dscooper  w-relat-1.qtdcronr
                             w-relat-1.totcronr  w-relat-1.qtdcrosr
                             w-relat-1.totcrosr  w-relat-1.totchqro
                             w-relat-1.qtdcdeno  w-relat-1.totcdeno 
                             w-relat-1.totchqde  w-relat-1.qtdcdedi
                             w-relat-1.totcdedi  w-relat-1.qtde_icf
                             w-relat-1.totalicf  w-relat-1.qtde_ccf
                             w-relat-1.totalccf  w-relat-1.qtde_tic
                             w-relat-1.totaltic  WITH FRAME f_result_3.
        
        DOWN WITH FRAME f_result_3.
    
        ASSIGN aux_qtdcronr = aux_qtdcronr + w-relat-1.qtdcronr
               aux_totcronr = aux_totcronr + w-relat-1.totcronr
               aux_qtdcrosr = aux_qtdcrosr + w-relat-1.qtdcrosr
               aux_totcrosr = aux_totcrosr + w-relat-1.totcrosr
               aux_totchqro = aux_totchqro + w-relat-1.totchqro
               aux_qtdcdeno = aux_qtdcdeno + w-relat-1.qtdcdeno
               aux_totcdeno = aux_totcdeno + w-relat-1.totcdeno
               aux_qtdcdedi = aux_qtdcdedi + w-relat-1.qtdcdedi
               aux_totcdedi = aux_totcdedi + w-relat-1.totcdedi
               aux_totchqde = aux_totchqde + w-relat-1.totchqde
               aux_somaqicf = aux_somaqicf + w-relat-1.qtde_icf
               aux_somaticf = aux_somaticf + w-relat-1.totalicf
               aux_somaqccf = aux_somaqccf + w-relat-1.qtde_ccf
               aux_somatccf = aux_somatccf + w-relat-1.totalccf
               aux_somaqtic = aux_somaqtic + w-relat-1.qtde_tic
               aux_somattic = aux_somattic + w-relat-1.totaltic.
    
    END. /* END FOREACH */
    
    DISPLAY STREAM str_1 aux_fill_191   aux_qtdcronr   aux_totcronr
                         aux_qtdcrosr   aux_totcrosr   aux_totchqro
                         aux_qtdcdeno   aux_totcdeno   aux_totchqde
                         aux_qtdcdedi   aux_totcdedi   aux_somaqicf
                         aux_somaticf   aux_somaqccf   aux_somatccf
                         aux_somaqtic   aux_somattic 
                         WITH FRAME f_total_3.
    
    DOWN WITH FRAME f_total_3.
    /* FIM - MOSTRAR 3a PARTE DO RELATORIO */
    
    OUTPUT STREAM str_1 CLOSE.
                               
    ASSIGN glb_nrcopias = 1
           glb_nmformul = "234dh"
           glb_nmarqimp = aux_nmarqimp.
    
    RUN fontes/imprim.p.

END. /* END - pi_processa_relatorio */            

/*............................................................................*/

