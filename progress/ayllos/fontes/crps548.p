/*..............................................................................

    Programa: fontes/crps548.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Dezembro/2009                     Ultima atualizacao: 26/05/2018

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Gerar relatorio do fechamento diario. Executa somente na CECRED
                Gera relatorios crrl533 e crrl547.
               
    Alteracoes: 18/02/2010 - Gerar relatorio(crrl547) detalhado por Cooperativa
                             (Guilherme/Supero) 
                             
                26/05/2010 - Enviar relatorios para compe@cecred.coop.br (David)

                07/06/2010 - Acerto no relatorio (Ze).
                
                15/06/2010 - Acerto no cabecalho analitico e tratamento
                             para dtliquid (Vitor/Ze).
                
                15/06/2010 - Incluso Tarifas FAC/ROC no relatório crrl533 
                            (Jonatas - Supero)

                23/06/2010 - Acertos Gerais (Ze).

                30/06/2010 - Inclusao do SR CHQ INF no relatorio
                             (Guilherme/Supero)

                02/08/2010 - Incluir TD 90 (Ze).
                
                27/09/2010 - Incluir TD 70 (Ze).

                16/05/2011 - Incluir Cobranca SR, Cobranca VLB SR e DEV COB REM
                             no crrl547 e crrl533 (Guilherme/Supero)
                             
                07/06/2011 - Mudancas na alteracao acima (Guilherme).
                
                24/08/2011 - Incluir Cob SR na coluna ROC crrl533 (Rafael).
                
                12/09/2011 - Filtrar registros cdtipdoc 
                             = 140 - Troca Cobr Abaixo DDA
                             = 144 - Troca Cobr VLB DDA           (Rafael).
                            
                02/12/2011 - Filtrar registros 40,44,140,144 (Cob. Sua Remessa)
                             com tipo fechamento = 3 (Rafael).
                             
                18/04/2012 - Adicionado campos no relatorio 533:
                             - NR COB INF DDA, NR COB VLB DDA,
                             - SR COB INF DDA, SR COB VLB DDA. (Rafael)
                             
                27/04/2012 - Ajuste na DEV COB RC. (Rafael)
                
                22/06/2012 - Substituido gncoper por crapcop (Tiago).
                
                01/04/2013 - Incluir TD 433 e 439 no FAC - Trf. 50563 (Ze)          

				27/03/2017 - Ajuste na DEV COB REM. (P340 - Fase SILOC - Rafael)

                26/06/2017 - Listar uma única linha para NR CHQ e outra para SR CHQ, com o
                             somatório dos antigos valores que estao separados em CHQ SUP 
                             e CHQ INF. Relatório 547 nao será mais gerado. Projeto 367 (Lombardi)

			    26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

          14/08/2019 - PJ565 - Ajuste relatorio 533 (FAC) - Renato AMcom

..............................................................................*/

DEF STREAM str_1.
DEF STREAM str_2.

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR rel_nmempres AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR rel_nmresemp AS CHAR FORMAT "x(11)"                            NO-UNDO.
DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                   NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                             INIT ["DEP. A VISTA   ","CAPITAL        ",
                                   "EMPRESTIMOS    ","DIGITACAO      ",
                                   "GENERICO       "]                  NO-UNDO.
    
DEF VAR rel_nrmodulo AS INTE FORMAT "9"                                NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_vlcobvlb AS DECI                                           NO-UNDO.
DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.
DEF VAR aux_rowid    AS ROWID                                          NO-UNDO.


/* EXTEND de 6 -> 1-FAC / 2-ROC / 3-ABBC / 4-CECRED / 5-GerCoop / 6-IntCoop */
DEF VAR rel_nrcheque AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_srcheque AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_nrchqinf AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_srchqinf AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_dvchqrmn AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_dvchqrcn AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_dvchqrmd AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_dvchqrcd AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_nrcobinf AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_nrddainf AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_nrcobvlb AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_nrddavlb AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_devcobrm AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_srcobinf AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_srddainf AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_srcobvlb AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_srddavlb AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_devcobrc AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_nrdedocs AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_srdedocs AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_devdedoc AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_devdocrc AS DEC             EXTENT 6        INIT 0         NO-UNDO.
DEF VAR rel_devdocrm AS DEC             EXTENT 6        INIT 0         NO-UNDO.


DEF VAR rel_tot_abbc AS DEC      /* SOMA TOTAL PROCESSADO ABBC    */   NO-UNDO.
DEF VAR rel_totcecre AS DEC      /* SOMA TOTAL INTEGRADO CECRED   */   NO-UNDO.

DEF VAR rel_totl_fac AS DEC      /* SOMA TOTAL FAC (Futuro)       */   NO-UNDO.
DEF VAR rel_totl_roc AS DEC      /* SOMA TOTAL ROC (Futuro)       */   NO-UNDO.
DEF VAR rel_t_facroc AS DEC      /* SOMA TOTAL FAC + ROC (Futuro) */   NO-UNDO.

DEF VAR tot_vlremdoc AS DEC                                            NO-UNDO.
DEF VAR tot_vlrecdoc AS DEC                                            NO-UNDO.

DEF VAR aux_prtarifa AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR tot_vlremfac AS DEC                                            NO-UNDO.
DEF VAR tot_vlrecfac AS DEC                                            NO-UNDO.
DEF VAR tot_vlremroc AS DEC                                            NO-UNDO.
DEF VAR tot_vlrecroc AS DEC                                            NO-UNDO.
DEF VAR tot_vltotfac AS DEC                                            NO-UNDO.
DEF VAR tot_vltotroc AS DEC                                            NO-UNDO.
DEF VAR aux_dstarifa AS CHAR                                           NO-UNDO.
DEF VAR tot_vlgerfac AS DEC                                            NO-UNDO.
DEF VAR tot_vlgerroc AS DEC                                            NO-UNDO.

DEF VAR h-b1wgen0011 AS HANDLE                                         NO-UNDO.

/* Devolucao boletos 085 */
DEF VAR aux_ponteiro    AS INT                                         NO-UNDO.
DEF VAR vlr_totdevol    AS DEC INIT 0                                  NO-UNDO.

DEF BUFFER b-gnfcomp FOR gnfcomp.
DEF BUFFER b-crapdat FOR crapdat.

DEF TEMP-TABLE w-relatorio                                             NO-UNDO
    FIELD cdcooper  AS INT
    FIELD cdtipreg  AS CHAR 
    FIELD nrcheque  AS DEC  /* CHQ NR SUP */
    FIELD srcheque  AS DEC  /* CHQ SR SUP */
    FIELD dvchqrmn  AS DEC  /* DEV REMET CHQ NOTURNA */
    FIELD dvchqrmd  AS DEC  /* DEV REMET CHQ DIURNA  */
    FIELD dvchqrcn  AS DEC  /* DEV RECEB CHQ NOTURNA */
    FIELD dvchqrcd  AS DEC  /* DEV RECEB CHQ DIURNA  */
    FIELD nrcobinf  AS DEC  /* COB NR INF */
    FIELD nrcobvlb  AS DEC  /* COB NR VLB */
    FIELD srcobinf  AS DEC  /* COB SR INF */
    FIELD srcobvlb  AS DEC  /* COB SR VLB */
    FIELD nrddainf  AS DEC  /* COB NR INF DDA */
    FIELD nrddavlb  AS DEC  /* COB NR VLB DDA */
    FIELD srddainf  AS DEC  /* COB SR INF DDA */
    FIELD srddavlb  AS DEC  /* COB SR VLB DDA */
    FIELD devcobrc  AS DEC  /* DEV COB REC */
    FIELD devcobrm  AS DEC  /* DEV COB REM */
    FIELD nrdedocs  AS DEC  /* DOC NR */
    FIELD srdedocs  AS DEC  /* DOC SR */
    FIELD devdedoc  AS DEC  /* DEV DOC  - Para Relatorio Analitico */
    FIELD devdocrc  AS DEC  /* DEV DOC NR */
    FIELD devdocrm  AS DEc  /* DEV DOC SR */
    INDEX ix-relat AS PRIMARY cdtipreg cdcooper.

DEF BUFFER bw-relatorio  FOR w-relatorio.
DEF BUFFER bfw-relatorio FOR w-relatorio.
DEF BUFFER crabcop FOR crapcop.

FORM SKIP(3)
     "MOVIMENTO"                                  AT 001
     "FAC"                                        AT 035
     "ROC"                                        AT 053
     "PROCESSADO ABBC"                            AT 059
     "INTEGRADO AILOS"                            AT 076
     "GERADO COOP"                                AT 099
     "INTEGRADO COOP"                             AT 114
     SKIP
     "NR CHQ"                                     AT 001
     rel_nrcheque[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021     
     rel_nrcheque[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_nrcheque[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_nrcheque[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_nrcheque[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_nrcheque[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "NR COB VLB"                                 AT 001
     rel_nrcobvlb[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_nrcobvlb[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_nrcobvlb[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_nrcobvlb[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_nrcobvlb[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_nrcobvlb[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "NR COB VLB DDA"                             AT 001
     rel_nrddavlb[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_nrddavlb[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_nrddavlb[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_nrddavlb[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_nrddavlb[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_nrddavlb[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "NR COB INF"                                 AT 001
     rel_nrcobinf[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_nrcobinf[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_nrcobinf[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_nrcobinf[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_nrcobinf[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_nrcobinf[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     "NR COB INF DDA"                             AT 001
     rel_nrddainf[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_nrddainf[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_nrddainf[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_nrddainf[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_nrddainf[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_nrddainf[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "NR DOC"                                     AT 001
     rel_nrdedocs[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_nrdedocs[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_nrdedocs[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_nrdedocs[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_nrdedocs[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_nrdedocs[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_relat_sintetico_1.

FORM SKIP
     "SR CHQ"                                     AT 001
     rel_srcheque[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_srcheque[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_srcheque[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_srcheque[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_srcheque[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_srcheque[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "SR COB VLB"                                 AT 001
     rel_srcobvlb[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_srcobvlb[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_srcobvlb[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_srcobvlb[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_srcobvlb[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_srcobvlb[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "SR COB VLB DDA"                             AT 001
     rel_srddavlb[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_srddavlb[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_srddavlb[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_srddavlb[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_srddavlb[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_srddavlb[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "SR COB INF"                                 AT 001
     rel_srcobinf[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_srcobinf[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_srcobinf[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_srcobinf[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_srcobinf[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_srcobinf[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "SR COB INF DDA"                             AT 001
     rel_srddainf[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_srddainf[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_srddainf[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_srddainf[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_srddainf[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_srddainf[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "SR DOC"                                     AT 001
     rel_srdedocs[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_srdedocs[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_srdedocs[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_srdedocs[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_srdedocs[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_srdedocs[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_relat_sintetico_2.

FORM SKIP
     "DEV CHQ REM FRAUDES"                        AT 001
     rel_dvchqrmn[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_dvchqrmn[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_dvchqrmn[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_dvchqrmn[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_dvchqrmn[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_dvchqrmn[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "DEV CHQ REC FRAUDES"                        AT 001
     rel_dvchqrcn[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_dvchqrcn[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_dvchqrcn[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_dvchqrcn[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_dvchqrcn[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_dvchqrcn[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "DEV CHQ REM"                                AT 001
     rel_dvchqrmd[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_dvchqrmd[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_dvchqrmd[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_dvchqrmd[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_dvchqrmd[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_dvchqrmd[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "DEV CHQ REC"                                AT 001
     rel_dvchqrcd[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_dvchqrcd[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_dvchqrcd[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_dvchqrcd[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_dvchqrcd[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_dvchqrcd[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "DEV COB REM"                                AT 001
     rel_devcobrm[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_devcobrm[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_devcobrm[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_devcobrm[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_devcobrm[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_devcobrm[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "DEV COB REC"                                AT 001
     rel_devcobrc[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_devcobrc[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_devcobrc[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_devcobrc[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_devcobrc[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_devcobrc[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "DEV DOC REM"                                AT 001
     rel_devdocrm[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_devdocrm[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_devdocrm[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_devdocrm[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_devdocrm[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_devdocrm[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     SKIP
     "DEV DOC REC"                                AT 001
     rel_devdocrc[1] FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_devdocrc[2] FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     rel_devdocrc[3] FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_devdocrc[4] FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     rel_devdocrc[5] FORMAT ">>,>>>,>>>,>>9.99"   AT 093
     rel_devdocrc[6] FORMAT ">>,>>>,>>>,>>9.99"   AT 111
     WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_relat_sintetico_3.

FORM SKIP
     "TOTAL FAC/ROC"                              AT 008
     rel_totl_fac    FORMAT ">>,>>>,>>>,>>9.99"   AT 021
     rel_totl_roc    FORMAT ">>,>>>,>>>,>>9.99"   AT 039
     "================="                          AT 057
     "================="                          AT 075
     SKIP
     "TOTAL FAC + ROC"                            AT 006
     rel_t_facroc    FORMAT ">>,>>>,>>>,>>9.99"   AT 030
     rel_tot_abbc    FORMAT ">>,>>>,>>>,>>9.99"   AT 057
     rel_totcecre    FORMAT ">>,>>>,>>>,>>9.99"   AT 075
     SKIP(3)
     WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_relat_sintetico_totais.

FORM SKIP(1)
     "FECHAMENTO DA COMPE - NOTURNA/DIURNA (SINTETICO)"   AT 52
     SKIP
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_titulo_sintetico.

/* Nao usa mais. Projeto 367
FORM SKIP(1)
     "FECHAMENTO DA COMPE - NOTURNA/DIURNA (ANALITICO)"   AT 67
     SKIP
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_titulo_analitico.

FORM SKIP(1)
     w-relatorio.cdtipreg  FORMAT "x(25)"                 AT 001
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_titulo_area.



FORM SKIP
     "CHQ MAIOR"                                       AT 028
     "CHQ MENOR"                                       AT 058
     "DEVOL REMET CHQ"                                 AT 085
     "DEVOL RECEB CHQ"                                 AT 114
     "DOC"                                             AT 152
     "DEVOL DOC"                                       AT 171
    SKIP
     "COOPERATIVA"                                     AT 001
     "NR" /* CHQ SUP */                                AT 024
     "SR" /* CHQ SUP */                                AT 039
     "NR" /* CHQ INF */                                AT 055
     "SR" /* CHQ INF */                                AT 070
     "NOTURNA" /* DEV CHQ REM */                       AT 082
     "DIURNA"  /* DEV CHQ REM */                       AT 097
     "NOTURNA" /* DEV CHQ REC */                       AT 112
     "DIURNA"  /* DEV CHQ REC */                       AT 127
     "NR" /* DOC */                                    AT 144
     "NR" /* DOC VLB */                                AT 159
    SKIP
    WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_cabec_analitico_1_1.

FORM aux_dscooper            FORMAT "x(15)"            AT 003
     bw-relatorio.nrchqsup   FORMAT "->>,>>>,>>9.99"   AT 018
     bw-relatorio.srchqsup   FORMAT "->>,>>>,>>9.99"   AT 034
     bw-relatorio.nrchqinf   FORMAT "->>,>>>,>>9.99"   AT 049
     bw-relatorio.srchqinf   FORMAT "->>,>>>,>>9.99"   AT 064
     bw-relatorio.dvchqrmn   FORMAT "->>,>>>,>>9.99"   AT 079
     bw-relatorio.dvchqrmd   FORMAT "->>,>>>,>>9.99"   AT 094
     bw-relatorio.dvchqrcn   FORMAT "->>,>>>,>>9.99"   AT 109
     bw-relatorio.dvchqrcd   FORMAT "->>,>>>,>>9.99"   AT 124
     bw-relatorio.nrdedocs   FORMAT "->>,>>>,>>9.99"   AT 139
     bw-relatorio.srdedocs   FORMAT "->>,>>>,>>9.99"   AT 154
     bw-relatorio.devdedoc   FORMAT "->>,>>>,>>9.99"   AT 169
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_relat_analitico_1_1.

FORM SKIP(1)
     "COBRANCA"                                        AT 029
     "COBRANCA VLB"                                    AT 057
     "DEV COB"                                         AT 091
    SKIP
     "COOPERATIVA"                                     AT 001
     "NR" /* COBRANCA */                               AT 024
     "SR" /* COBRANCA */                               AT 039
     "NR" /* COBRANCA VLB */                           AT 055
     "SR" /* COBRANCA VLB */                           AT 070
     "NR" /* DEV COB */                                AT 085
     "SR" /* DEV COB */                                AT 099
    SKIP
    WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_cabec_analitico_1_2.

FORM aux_dscooper            FORMAT "x(15)"            AT 003
     bfw-relatorio.nrcobinf  FORMAT "->>,>>>,>>9.99"   AT 018
     bfw-relatorio.srcobinf  FORMAT "->>,>>>,>>9.99"   AT 034
     bfw-relatorio.nrcobvlb  FORMAT "->>,>>>,>>9.99"   AT 049
     bfw-relatorio.srcobvlb  FORMAT "->>,>>>,>>9.99"   AT 064
     bfw-relatorio.devcobrc  FORMAT "->>,>>>,>>9.99"   AT 079
     bfw-relatorio.devcobrm  FORMAT "->>,>>>,>>9.99"   AT 094
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_relat_analitico_1_2.


FORM aux_dscooper            FORMAT "x(15)"            AT 003
     w-relatorio.nrchqsup    FORMAT "->>,>>>,>>9.99"   AT 018
     w-relatorio.srchqsup    FORMAT "->>,>>>,>>9.99"   AT 034
     w-relatorio.nrchqinf    FORMAT "->>,>>>,>>9.99"   AT 049
     w-relatorio.srchqinf    FORMAT "->>,>>>,>>9.99"   AT 064
     w-relatorio.dvchqrmn    FORMAT "->>,>>>,>>9.99"   AT 079
     w-relatorio.dvchqrmd    FORMAT "->>,>>>,>>9.99"   AT 094
     w-relatorio.dvchqrcn    FORMAT "->>,>>>,>>9.99"   AT 109
     w-relatorio.dvchqrcd    FORMAT "->>,>>>,>>9.99"   AT 124
     w-relatorio.nrdedocs    FORMAT "->>,>>>,>>9.99"   AT 139
     w-relatorio.srdedocs    FORMAT "->>,>>>,>>9.99"   AT 154
     w-relatorio.devdedoc    FORMAT "->>,>>>,>>9.99"   AT 169
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_total_analitico_1_1.

FORM aux_dscooper            FORMAT "x(15)"            AT 003
     w-relatorio.nrcobinf    FORMAT "->>,>>>,>>9.99"   AT 018
     w-relatorio.srcobinf    FORMAT "->>,>>>,>>9.99"   AT 034
     w-relatorio.nrcobvlb    FORMAT "->>,>>>,>>9.99"   AT 049
     w-relatorio.srcobvlb    FORMAT "->>,>>>,>>9.99"   AT 064
     w-relatorio.devcobrc    FORMAT "->>,>>>,>>9.99"   AT 079
     w-relatorio.devcobrm    FORMAT "->>,>>>,>>9.99"   AT 094
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_total_analitico_1_2.


FORM SKIP
     "CHQ MAIOR"                                       AT 028
     "CHQ MENOR"                                       AT 058
     "DEVOL REMET CHQ"                                 AT 085
     "COBRANCA"                                        AT 141
     "COBRANCA VLB"                                    AT 154
     "DEV COB REC"                                     AT 171
     "DOC"                                             AT 196
     SKIP
     "COOPERATIVA"                                     AT 001
     "NR" /* CHQ SUP */                                AT 024
     "NR" /* CHQ INF */                                AT 055
     "NOTURNA" /* DEV CHQ REM */                       AT 082
     "DIURNA"  /* DEV CHQ REM */                       AT 097
     "NR" /* COB INF */                                AT 144
     "NR" /* COB VLB */                                AT 159
     "NR" /* DOC */                                    AT 189
     SKIP
    WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_cabec_analitico_2.

FORM aux_dscooper            FORMAT "x(15)"            AT 003
     bw-relatorio.nrchqsup   FORMAT "->>,>>>,>>9.99"   AT 018
     bw-relatorio.nrchqinf   FORMAT "->>,>>>,>>9.99"   AT 049
     bw-relatorio.dvchqrmn   FORMAT "->>,>>>,>>9.99"   AT 079
     bw-relatorio.dvchqrmd   FORMAT "->>,>>>,>>9.99"   AT 094
     bw-relatorio.nrcobinf   FORMAT "->>,>>>,>>9.99"   AT 139
     bw-relatorio.nrcobvlb   FORMAT "->>,>>>,>>9.99"   AT 154
     bw-relatorio.nrdedocs   FORMAT "->>,>>>,>>9.99"   AT 184
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_relat_analitico_2.

FORM aux_dscooper            FORMAT "x(15)"            AT 003
     w-relatorio.nrchqsup    FORMAT "->>,>>>,>>9.99"   AT 018
     w-relatorio.nrchqinf    FORMAT "->>,>>>,>>9.99"   AT 049
     w-relatorio.dvchqrmn    FORMAT "->>,>>>,>>9.99"   AT 079
     w-relatorio.dvchqrmd    FORMAT "->>,>>>,>>9.99"   AT 094
     w-relatorio.nrcobinf    FORMAT "->>,>>>,>>9.99"   AT 139
     w-relatorio.nrcobvlb    FORMAT "->>,>>>,>>9.99"   AT 154
     w-relatorio.nrdedocs    FORMAT "->>,>>>,>>9.99"   AT 184
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_total_analitico_2.

FORM SKIP
     "CHQ MAIOR"                                       AT 028
     "CHQ MENOR"                                       AT 058
     "DEVOL RECEB CHQ"                                 AT 114
     "COBRANCA"                                        AT 141
     "COBRANCA VLB"                                    AT 154
     "DEV COB REM"                                     AT 171
     "DOC"                                             AT 196
     SKIP
     "COOPERATIVA"                                     AT 001
     "SR" /* CHQ SUP */                                AT 039
     "SR" /* CHQ INF */                                AT 070
     "NOTURNA" /* DEV CHQ REC */                       AT 112
     "DIURNA"  /* DEV CHQ REC */                       AT 127
     "SR" /* COB INF */                                AT 144
     "SR" /* COB VLB */                                AT 159
     "SR" /* DOC */                                    AT 204
     SKIP
    WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_cabec_analitico_3.

FORM aux_dscooper            FORMAT "x(15)"            AT 003
     bw-relatorio.srchqsup   FORMAT "->>,>>>,>>9.99"   AT 034
     bw-relatorio.srchqinf   FORMAT "->>,>>>,>>9.99"   AT 064
     bw-relatorio.dvchqrcn   FORMAT "->>,>>>,>>9.99"   AT 109
     bw-relatorio.dvchqrcd   FORMAT "->>,>>>,>>9.99"   AT 124
     bw-relatorio.srcobinf   FORMAT "->>,>>>,>>9.99"   AT 139
     bw-relatorio.srcobvlb   FORMAT "->>,>>>,>>9.99"   AT 154
     bw-relatorio.devcobrm   FORMAT "->>,>>>,>>9.99"   AT 170
     bw-relatorio.srdedocs   FORMAT "->>,>>>,>>9.99"   AT 199
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_relat_analitico_3.

FORM aux_dscooper            FORMAT "x(15)"            AT 003
     w-relatorio.srchqsup    FORMAT "->>,>>>,>>9.99"   AT 034
     w-relatorio.srchqinf    FORMAT "->>,>>>,>>9.99"   AT 064
     w-relatorio.dvchqrcn    FORMAT "->>,>>>,>>9.99"   AT 109
     w-relatorio.dvchqrcd    FORMAT "->>,>>>,>>9.99"   AT 124
     w-relatorio.srcobinf    FORMAT "->>,>>>,>>9.99"   AT 139
     w-relatorio.srcobvlb    FORMAT "->>,>>>,>>9.99"   AT 154
     w-relatorio.devcobrm    FORMAT "->>,>>>,>>9.99"   AT 170
     w-relatorio.srdedocs    FORMAT "->>,>>>,>>9.99"   AT 199
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_total_analitico_3.

FORM SKIP(2)
     aux_prtarifa            FORMAT "x(40)"            AT 033
     SKIP(1)
     "DESCRICAO - TD"                                  AT 001
     "FAC"                                             AT 060
     "ROC"                                             AT 090
     WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_periodo_tarifa.

FORM aux_dstarifa        FORMAT "x(40)"                AT 1
     tot_vltotfac        FORMAT "->>,>>>,>>>,>>9.99"   AT 45
     tot_vltotroc        FORMAT "->>,>>>,>>>,>>9.99"   AT 75
     WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_tarifa.
     
FORM SKIP
     "TOTAL"                                           AT 1
     tot_vlgerfac        FORMAT "->>,>>>,>>>,>>9.99"   AT 45
     tot_vlgerroc        FORMAT "->>,>>>,>>>,>>9.99"   AT 75
     WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_total_tarifa.    
*/

ASSIGN glb_cdprogra = "crps548"
       glb_flgbatch = FALSE.
 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

{ includes/cabrel132_1.i }
{ includes/cabrel234_2.i }

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 0            AND
                   craptab.cdacesso = "VALORESVLB" AND
                   craptab.tpregist = 0            NO-LOCK NO-ERROR.

ASSIGN aux_vlcobvlb = IF  AVAILABLE craptab  THEN
                          DEC(ENTRY(1,craptab.dstextab,";"))
                      ELSE
                          5000.

/*........................... GNFCOMP - FAC ................................. */
    FOR EACH gnfcomp WHERE gnfcomp.cdcooper = 3            AND
                           gnfcomp.dtmvtolt = glb_dtmvtolt AND
                           gnfcomp.cdtipfec = 1            AND
                           gnfcomp.idregist = 1            AND
                           gnfcomp.cdtipdoc <> 0           NO-LOCK
                           BREAK BY gnfcomp.cdperarq
                                    BY gnfcomp.cdtipdoc:

        IF   CAN-DO("30,33,70,76,90,433,34,39,94,439",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_nrcheque[1] = rel_nrcheque[1] + gnfcomp.vlremdoc
                    rel_srcheque[1] = rel_srcheque[1] + gnfcomp.vlrecdoc.
        ELSE
        IF   CAN-DO("11,31,73,434",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_dvchqrmn[1] = rel_dvchqrmn[1] + gnfcomp.vlremdoc
                    rel_dvchqrcn[1] = rel_dvchqrcn[1] + gnfcomp.vlrecdoc.
        ELSE
        IF   CAN-DO("12,32",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_dvchqrmd[1] = rel_dvchqrmd[1] + gnfcomp.vlremdoc
                    rel_dvchqrcd[1] = rel_dvchqrcd[1] + gnfcomp.vlrecdoc.
      END.
      FIND b-crapdat WHERE b-crapdat.cdcooper = 3.
    FOR EACH b-gnfcomp WHERE b-gnfcomp.cdcooper = 3            AND
                           b-gnfcomp.dtmvtolt = b-crapdat.dtmvtoan AND
                           b-gnfcomp.cdtipfec = 1            AND
                           b-gnfcomp.idregist = 1            AND
                           b-gnfcomp.cdtipdoc <> 0           NO-LOCK
                           BREAK BY b-gnfcomp.cdperarq
                                    BY b-gnfcomp.cdtipdoc:

        IF   CAN-DO("12,32",STRING(b-gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_dvchqrmd[1] = rel_dvchqrmd[1] + b-gnfcomp.vlremdoc
                    rel_dvchqrcd[1] = rel_dvchqrcd[1] + b-gnfcomp.vlrecdoc.
                  
    END.

    IF   rel_nrcheque[1] <> 0 OR
         rel_srcheque[1] <> 0 OR
         rel_dvchqrmn[1] <> 0 OR
         rel_dvchqrcn[1] <> 0 OR
         rel_dvchqrmd[1] <> 0 OR
         rel_dvchqrcd[1] <> 0 THEN
         DO:
             RUN cria_tt_relatorio (INPUT  0,
                                    INPUT  "1 - FAC",
                                    OUTPUT aux_rowid).
    
             FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                    EXCLUSIVE-LOCK NO-ERROR.

             ASSIGN w-relatorio.nrcheque = rel_nrcheque[1]
                    w-relatorio.srcheque = rel_srcheque[1]
                    w-relatorio.dvchqrmn = rel_dvchqrmn[1]
                    w-relatorio.dvchqrcn = rel_dvchqrcn[1]
                    w-relatorio.dvchqrmd = rel_dvchqrmd[1]
                    w-relatorio.dvchqrcd = rel_dvchqrcd[1].

             ASSIGN rel_nrcheque[1] = 0
                    rel_srcheque[1] = 0
                    rel_dvchqrmn[1] = 0
                    rel_dvchqrcn[1] = 0
                    rel_dvchqrmd[1] = 0
                    rel_dvchqrcd[1] = 0.             
        END.


/*.......................... GNFCOMP - ROC .................................. */
    FOR EACH gnfcomp WHERE gnfcomp.cdcooper = 3            AND
                           gnfcomp.dtmvtolt = glb_dtmvtolt AND
                           gnfcomp.cdtipfec >= 2           AND
                           gnfcomp.cdtipfec <= 3           AND
                           gnfcomp.idregist = 1            AND
                           gnfcomp.cdtipdoc <> 0           NO-LOCK
                           BREAK BY gnfcomp.cdperarq
                                    BY gnfcomp.cdtipdoc:

        IF   CAN-DO("44",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_nrcobvlb[1] = rel_nrcobvlb[1] + gnfcomp.vlremdoc
                    rel_srcobvlb[1] = rel_srcobvlb[1] + gnfcomp.vlrecdoc.
        ELSE
        IF   CAN-DO("144",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_nrddavlb[1] = rel_nrddavlb[1] + gnfcomp.vlremdoc
                    rel_srddavlb[1] = rel_srddavlb[1] + gnfcomp.vlrecdoc.
        ELSE
        IF   CAN-DO("40",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_nrcobinf[1] = rel_nrcobinf[1] + gnfcomp.vlremdoc
                    rel_srcobinf[1] = rel_srcobinf[1] + gnfcomp.vlrecdoc.
        ELSE      
        IF   CAN-DO("140",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_nrddainf[1] = rel_nrddainf[1] + gnfcomp.vlremdoc
                    rel_srddainf[1] = rel_srddainf[1] + gnfcomp.vlrecdoc.
        ELSE
        IF   CAN-DO("41,46",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_devcobrc[1] = rel_devcobrc[1] + gnfcomp.vlrecdoc
                    rel_devcobrm[1] = rel_devcobrm[1] + gnfcomp.vlremdoc.
        ELSE
        IF   CAN-DO("43,45,47",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_nrdedocs[1] = rel_nrdedocs[1] + gnfcomp.vlremdoc
                    rel_srdedocs[1] = rel_srdedocs[1] + gnfcomp.vlrecdoc.
        ELSE
        IF   CAN-DO("42,66",STRING(gnfcomp.cdtipdoc))  THEN
             ASSIGN rel_devdocrm[1] = rel_devdocrm[1] + gnfcomp.vlremdoc
                    rel_devdocrc[1] = rel_devdocrc[1] + gnfcomp.vlrecdoc.
    END.

    IF   rel_nrcobvlb[1] <> 0 OR
         rel_nrcobinf[1] <> 0 OR
         rel_srcobvlb[1] <> 0 OR
         rel_srcobinf[1] <> 0 OR

         rel_nrddavlb[1] <> 0 OR
         rel_nrddainf[1] <> 0 OR
         rel_srddavlb[1] <> 0 OR
         rel_srddainf[1] <> 0 OR

         rel_devcobrc[1] <> 0 OR
         rel_devcobrm[1] <> 0 OR
         rel_nrdedocs[1] <> 0 OR
         rel_srdedocs[1] <> 0 OR
         rel_devdocrc[1] <> 0 OR
         rel_devdocrm[1] <> 0 THEN
         DO:
             RUN cria_tt_relatorio (INPUT  0,
                                    INPUT  "2 - ROC",
                                    OUTPUT aux_rowid).
    
             FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                    EXCLUSIVE-LOCK NO-ERROR.
             
             ASSIGN w-relatorio.nrcobvlb = rel_nrcobvlb[1]
                    w-relatorio.nrcobinf = rel_nrcobinf[1]
                    w-relatorio.srcobvlb = rel_srcobvlb[1]
                    w-relatorio.srcobinf = rel_srcobinf[1]

                    w-relatorio.nrddavlb = rel_nrddavlb[1]
                    w-relatorio.nrddainf = rel_nrddainf[1]
                    w-relatorio.srddavlb = rel_srddavlb[1]
                    w-relatorio.srddainf = rel_srddainf[1]

                    w-relatorio.devcobrc = rel_devcobrc[1]
                    w-relatorio.devcobrm = rel_devcobrm[1]
                    w-relatorio.nrdedocs = rel_nrdedocs[1]
                    w-relatorio.srdedocs = rel_srdedocs[1]
                    w-relatorio.devdocrc = rel_devdocrc[1]
                    w-relatorio.devdocrm = rel_devdocrm[1].
                    
             ASSIGN rel_nrcobvlb[1] = 0
                    rel_nrcobinf[1] = 0
                    rel_srcobvlb[1] = 0
                    rel_srcobinf[1] = 0

                    rel_nrddavlb[1] = 0
                    rel_nrddainf[1] = 0
                    rel_srddavlb[1] = 0
                    rel_srddainf[1] = 0

                    rel_devcobrc[1] = 0
                    rel_devcobrm[1] = 0
                    rel_nrdedocs[1] = 0
                    rel_srdedocs[1] = 0
                    rel_devdocrc[1] = 0
                    rel_devdocrm[1] = 0.
         END.                                                

/* PROCESSA PARA TODAS AS COOPERATIVAS, EXCETO A 3  */

FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK
   BREAK BY crapcop.cdcooper:

/*........................... GNCPCHQ ....................................... */
    FOR EACH gncpchq WHERE gncpchq.cdcooper = crapcop.cdcooper AND
                           gncpchq.dtliquid = glb_dtmvtolt     NO-LOCK:
    
        /** Processado ABBC **/
        IF   gncpchq.cdtipreg = 2  THEN 
             DO:
                 RUN cria_tt_relatorio (INPUT gncpchq.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 ASSIGN w-relatorio.nrcheque = w-relatorio.nrcheque + gncpchq.vlcheque.
             
                 /** Integrado Cecred **/

                 RUN cria_tt_relatorio (INPUT gncpchq.cdcooper,
                                        INPUT "4 - INTEGRADO AILOS",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 ASSIGN w-relatorio.nrcheque = w-relatorio.nrcheque + gncpchq.vlcheque.
                 
             END.

        /** Integrado Coop **/
        IF   gncpchq.cdcrictl = 0 AND
             gncpchq.cdcritic = 0 AND
             gncpchq.cdtipreg = 2 THEN 
             DO:
                 RUN cria_tt_relatorio (INPUT gncpchq.cdcooper,
                                        INPUT "6 - INTEGRADO COOP",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 ASSIGN w-relatorio.nrcheque = w-relatorio.nrcheque + gncpchq.vlcheque.
             END.

    
        /** Sua Remessa / Devolucao Recebimento **/
        IF   gncpchq.cdtipreg = 3 OR 
             gncpchq.cdtipreg = 4 THEN 
             DO:
                 /** Processado ABBC **/
                 RUN cria_tt_relatorio (INPUT gncpchq.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 ASSIGN w-relatorio.srcheque = w-relatorio.srcheque + gncpchq.vlcheque.
    
                 /** Integrado Cecred **/
                 IF   gncpchq.cdtipreg  = 4  OR
                     (gncpchq.cdtipreg  = 3  AND
                      gncpchq.cdcritic <> 0) THEN
                      DO:
                          RUN cria_tt_relatorio (INPUT gncpchq.cdcooper,
                                                 INPUT "4 - INTEGRADO AILOS",
                                                 OUTPUT aux_rowid).
                          FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                 EXCLUSIVE-LOCK NO-ERROR.
    
                          ASSIGN w-relatorio.srcheque = w-relatorio.srcheque + gncpchq.vlcheque.
                      END.

                 /** Integrado Coop **/
                 IF   gncpchq.cdtipreg = 4  AND
                      gncpchq.cdcritic = 0  THEN 
                      DO:
                          RUN cria_tt_relatorio (INPUT gncpchq.cdcooper,
                                                 INPUT "6 - INTEGRADO COOP",
                                                 OUTPUT aux_rowid).
                          FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                 EXCLUSIVE-LOCK NO-ERROR.
    
                          ASSIGN w-relatorio.srcheque = w-relatorio.srcheque + gncpchq.vlcheque.
                      END.
             END.

        /** Gerado Coop **/
        IF (gncpchq.cdtipreg = 2  AND
            gncpchq.cdcritic = 0) OR
            gncpchq.cdtipreg = 1  THEN 
            DO:
                RUN cria_tt_relatorio (INPUT gncpchq.cdcooper,
                                       INPUT "5 - GERADO COOP",
                                       OUTPUT aux_rowid).
                FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                       EXCLUSIVE-LOCK NO-ERROR.
    
                ASSIGN w-relatorio.nrcheque = w-relatorio.nrcheque + gncpchq.vlcheque.
            END.

    END. /** Fim do FOR EACH gncpchq **/

/*........................... GNCPTIT ....................................... */
    FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper AND
                           gncptit.dtliquid = glb_dtmvtolt     NO-LOCK:
    
        IF   gncptit.cdtipreg = 2  THEN
             DO:
                 RUN cria_tt_relatorio (INPUT gncptit.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 IF   gncptit.cdmotdev = 0 AND 
                      gncptit.flgpgdda = FALSE THEN /* ENVIO COB */
                 DO:
                      IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                          ASSIGN w-relatorio.nrcobinf = w-relatorio.nrcobinf
                                                        + gncptit.vldpagto.
                      ELSE
                          ASSIGN w-relatorio.nrcobvlb = w-relatorio.nrcobvlb
                                                        + gncptit.vldpagto.
                 END.
                 ELSE
                 IF   gncptit.cdmotdev = 0 AND 
                      gncptit.flgpgdda = TRUE THEN /* ENVIO COB DDA */
                 DO:
                      IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                          ASSIGN w-relatorio.nrddainf = w-relatorio.nrddainf
                                                        + gncptit.vldpagto.
                      ELSE
                          ASSIGN w-relatorio.nrddavlb = w-relatorio.nrddavlb
                                                        + gncptit.vldpagto.
                 END.
                 ELSE /* DEVOLU COB REC */
                      ASSIGN w-relatorio.devcobrc = w-relatorio.devcobrc
                                                    + gncptit.vldpagto.
                 
                 
                 /** Integrado CECRED **/

                 RUN cria_tt_relatorio (INPUT gncptit.cdcooper,
                                        INPUT "4 - INTEGRADO AILOS",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 IF   gncptit.cdmotdev = 0 AND 
                      gncptit.flgpgdda = FALSE THEN /* ENVIO COB */
                 DO:
                      IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                          ASSIGN w-relatorio.nrcobinf = w-relatorio.nrcobinf
                                                        + gncptit.vldpagto.
                      ELSE
                          ASSIGN w-relatorio.nrcobvlb = w-relatorio.nrcobvlb
                                                        + gncptit.vldpagto.
                
                 END.
                 ELSE
                 IF   gncptit.cdmotdev = 0 AND 
                      gncptit.flgpgdda = TRUE THEN /* ENVIO COB DDA */
                 DO:
                      IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                          ASSIGN w-relatorio.nrddainf = w-relatorio.nrddainf
                                                        + gncptit.vldpagto.
                      ELSE
                          ASSIGN w-relatorio.nrddavlb = w-relatorio.nrddavlb
                                                        + gncptit.vldpagto.

                 END.
                 ELSE /* DEVOLU COB REC */
                      ASSIGN w-relatorio.devcobrc = w-relatorio.devcobrc
                                                    + gncptit.vldpagto.
              END. /* FIM do IF cdtipreg = 2 */
    

        /** Integrado Coop **/
        IF   gncptit.cdcrictl = 0 AND
             gncptit.cdcritic = 0 AND
             gncptit.cdtipreg = 2 THEN 
             DO:
                 RUN cria_tt_relatorio (INPUT gncptit.cdcooper,
                                        INPUT "6 - INTEGRADO COOP",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 IF   gncptit.cdmotdev = 0 AND 
                      gncptit.flgpgdda = FALSE THEN /* ENVIO COB */
                 DO:
                      IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                          ASSIGN w-relatorio.nrcobinf = w-relatorio.nrcobinf
                                                        + gncptit.vldpagto.
                      ELSE
                          ASSIGN w-relatorio.nrcobvlb = w-relatorio.nrcobvlb
                                                        + gncptit.vldpagto.
                 END.
                 ELSE
                 IF   gncptit.cdmotdev = 0 AND 
                      gncptit.flgpgdda = TRUE THEN /* ENVIO COB DDA */
                 DO:
                      IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                          ASSIGN w-relatorio.nrddainf = w-relatorio.nrddainf
                                                        + gncptit.vldpagto.
                      ELSE
                          ASSIGN w-relatorio.nrddavlb = w-relatorio.nrddavlb
                                                        + gncptit.vldpagto.
                 END.
                 ELSE /* DEVOLU COB */
                      ASSIGN w-relatorio.devcobrc = w-relatorio.devcobrc
                                                    + gncptit.vldpagto.
             END.
        
        IF   gncptit.cdtipreg = 3 OR
             gncptit.cdtipreg = 4 THEN 
             DO:
                 /** Processado ABBC **/
                 RUN cria_tt_relatorio (INPUT gncptit.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 IF   NOT gncptit.cdmotdev = 0 THEN /* DEVOLU COB */
                      ASSIGN w-relatorio.devcobrc = w-relatorio.devcobrc
                                                    + gncptit.vldpagto.
                 ELSE
                 IF gncptit.flgpgdda = FALSE THEN
                 DO:
                     IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                         ASSIGN w-relatorio.srcobinf = w-relatorio.srcobinf
                                                       + gncptit.vldpagto.
                     ELSE
                         ASSIGN w-relatorio.srcobvlb = w-relatorio.srcobvlb
                                                       + gncptit.vldpagto.
                 END.
                 ELSE
                 IF gncptit.flgpgdda = TRUE THEN
                 DO:
                     IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                         ASSIGN w-relatorio.srddainf = w-relatorio.srddainf
                                                       + gncptit.vldpagto.
                     ELSE
                         ASSIGN w-relatorio.srddavlb = w-relatorio.srddavlb
                                                       + gncptit.vldpagto.
                 END.
    
                 /** Integrado Cecred **/
                 IF   gncptit.cdtipreg  = 4  OR  /* importou sem erro */
                     (gncptit.cdtipreg  = 3  AND /* importou com erro */
                      gncptit.cdcritic <> 0) THEN
                      DO:
                           RUN cria_tt_relatorio (INPUT gncptit.cdcooper,
                                                  INPUT "4 - INTEGRADO AILOS",
                                                  OUTPUT aux_rowid).
                           FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                  EXCLUSIVE-LOCK NO-ERROR.

                           IF   gncptit.cdmotdev <> 0 THEN /* DEVOLU COB */
                                IF  gncptit.cdtipreg  = 4 THEN
                                    ASSIGN w-relatorio.devcobrc =
                                                         w-relatorio.devcobrc
                                                       + gncptit.vldpagto.
                                ELSE 
                                    ASSIGN w-relatorio.devcobrm =
                                                         w-relatorio.devcobrm
                                                       + gncptit.vldpagto.
                           ELSE
                           IF gncptit.flgpgdda = FALSE THEN
                           DO:
                               IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                                   ASSIGN w-relatorio.srcobinf = w-relatorio.srcobinf
                                                                  + gncptit.vldpagto.
                               ELSE
                                   ASSIGN w-relatorio.srcobvlb = w-relatorio.srcobvlb
                                                                 + gncptit.vldpagto.

                           END.
                           ELSE
                           IF gncptit.flgpgdda = TRUE THEN
                           DO:
                               IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                                   ASSIGN w-relatorio.srddainf = w-relatorio.srddainf
                                                                  + gncptit.vldpagto.
                               ELSE
                                   ASSIGN w-relatorio.srddavlb = w-relatorio.srddavlb
                                                                 + gncptit.vldpagto.

                           END.
                      END.
    
                 /** Integrado Coop **/
                 IF   gncptit.cdtipreg = 4  AND /* importou sem erro */
                      gncptit.cdcritic = 0  THEN 
                      DO:
                          RUN cria_tt_relatorio (INPUT gncptit.cdcooper,
                                                 INPUT "6 - INTEGRADO COOP",
                                                 OUTPUT aux_rowid).
                          FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                 EXCLUSIVE-LOCK NO-ERROR.

                          IF   gncptit.cdmotdev <> 0 THEN /* DEVOLU COB */
                               IF  gncptit.cdtipreg  = 4 THEN
                                   ASSIGN w-relatorio.devcobrc =
                                                        w-relatorio.devcobrc
                                                      + gncptit.vldpagto.
                               ELSE 
                                   ASSIGN w-relatorio.devcobrm =
                                                        w-relatorio.devcobrm
                                                      + gncptit.vldpagto.

                          ELSE
                          IF gncptit.flgpgdda = FALSE THEN
                          DO:
                               IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                                   ASSIGN w-relatorio.srcobinf = w-relatorio.srcobinf
                                                                  + gncptit.vldpagto.
                               ELSE
                                   ASSIGN w-relatorio.srcobvlb = w-relatorio.srcobvlb
                                                                 + gncptit.vldpagto.
                          END.
                          ELSE
                          IF gncptit.flgpgdda = TRUE THEN
                          DO:
                               IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                                   ASSIGN w-relatorio.srddainf = w-relatorio.srddainf
                                                                 + gncptit.vldpagto.
                               ELSE
                                   ASSIGN w-relatorio.srddavlb = w-relatorio.srddavlb
                                                                 + gncptit.vldpagto.
                          END.

                      END.
             END.
        
        /** Gerado Coop **/
        IF (gncptit.cdtipreg = 2  AND
            gncptit.cdcritic = 0) OR
            gncptit.cdtipreg = 1  THEN 
            DO:
                RUN cria_tt_relatorio (INPUT gncptit.cdcooper,
                                       INPUT "5 - GERADO COOP",
                                       OUTPUT aux_rowid).
                FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                       EXCLUSIVE-LOCK NO-ERROR.

                IF   gncptit.cdmotdev = 0 AND 
                     gncptit.flgpgdda = FALSE THEN /* ENVIO COB */
                     DO:
                        IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                            ASSIGN w-relatorio.nrcobinf = w-relatorio.nrcobinf
                                                          + gncptit.vldpagto.
                        ELSE
                            ASSIGN w-relatorio.nrcobvlb = w-relatorio.nrcobvlb
                                                          + gncptit.vldpagto.
                     END.                                      
                ELSE
                IF   gncptit.cdmotdev = 0 AND 
                     gncptit.flgpgdda = TRUE THEN /* ENVIO COB DDA */
                     DO:
                        IF  gncptit.vldpagto < aux_vlcobvlb  THEN
                            ASSIGN w-relatorio.nrddainf = w-relatorio.nrddainf
                                                          + gncptit.vldpagto.
                        ELSE
                            ASSIGN w-relatorio.nrddavlb = w-relatorio.nrddavlb
                                                          + gncptit.vldpagto.
                     END.                                      
                ELSE /* DEVOLU COB */
                     ASSIGN w-relatorio.devcobrc = w-relatorio.devcobrc
                                                   + gncptit.vldpagto.
            END.

    END. /** Fim do FOR EACH gncptit **/

/*...................... DEVOLUCAO BOLETOS 085 ............................. */
        
    ASSIGN vlr_totdevol = 0.    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
       aux_ponteiro = PROC-HANDLE
               ("SELECT NVL(sum(dvc.vlliquid),0) 
                   FROM gncpdvc dvc
                  WHERE dvc.cdcooper = " + STRING(crapcop.cdcooper) + "
                    AND dvc.dtmvtolt = TO_DATE('" + 
                              STRING(glb_dtmvtolt,'99/99/9999') + "','DD/MM/RRRR')
                    AND TRIM(dvc.nmarquiv) IS NOT NULL").
              
    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
        ASSIGN vlr_totdevol = DEC(proc-text). 
    END.
                                              
    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
          WHERE PROC-HANDLE = aux_ponteiro.
                                 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    /** Processado ABBC **/
    RUN cria_tt_relatorio (INPUT crapcop.cdcooper,
                           INPUT "3 - PROCESSADO ABBC",
                           OUTPUT aux_rowid).
    FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                           EXCLUSIVE-LOCK NO-ERROR.

    ASSIGN w-relatorio.devcobrm = w-relatorio.devcobrm + vlr_totdevol.
    
/*................................................ */    

    ASSIGN vlr_totdevol = 0.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
       aux_ponteiro = PROC-HANDLE
               ("SELECT NVL(sum(dvc.vlliquid),0) 
                   FROM gncpdvc dvc
                  WHERE dvc.cdcooper = " + STRING(crapcop.cdcooper) + "
                    AND dvc.dtmvtolt = TO_DATE('" + 
                              STRING(glb_dtmvtolt,'99/99/9999') + "','DD/MM/RRRR')
                    AND dvc.flgconci = 1
                    AND dvc.flgpcctl = 1").
              
    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
        ASSIGN vlr_totdevol = DEC(proc-text). 
    END.
                                              
    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
          WHERE PROC-HANDLE = aux_ponteiro.
                                 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                
    /** Integrado CECRED **/                                
    RUN cria_tt_relatorio (INPUT crapcop.cdcooper,
                           INPUT "4 - INTEGRADO AILOS",
                           OUTPUT aux_rowid).
    FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                           EXCLUSIVE-LOCK NO-ERROR.

    ASSIGN w-relatorio.devcobrm = w-relatorio.devcobrm + vlr_totdevol.
    
/*................................................ */    

    ASSIGN vlr_totdevol = 0.    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
       aux_ponteiro = PROC-HANDLE
               ("SELECT NVL(sum(dvc.vlliquid),0) 
                   FROM gncpdvc dvc
                  WHERE dvc.cdcooper = " + STRING(crapcop.cdcooper) + "
                    AND dvc.dtmvtolt = TO_DATE('" + 
                              STRING(glb_dtmvtolt,'99/99/9999') + "','DD/MM/RRRR')
                    AND dvc.flgconci = 0
                    AND dvc.flgpcctl = 0").
              
    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
        ASSIGN vlr_totdevol = DEC(proc-text). 
    END.
                                              
    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
          WHERE PROC-HANDLE = aux_ponteiro.
                                 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                       
    /* Gerado Coop */                                       
    RUN cria_tt_relatorio (INPUT crapcop.cdcooper,
                           INPUT "5 - GERADO COOP",
                           OUTPUT aux_rowid).
    FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                           EXCLUSIVE-LOCK NO-ERROR.
                            
    ASSIGN w-relatorio.devcobrm = w-relatorio.devcobrm + vlr_totdevol.

/*................................................ */    

    ASSIGN vlr_totdevol = 0.    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
       aux_ponteiro = PROC-HANDLE
               ("SELECT NVL(sum(dvc.vlliquid),0) 
                   FROM gncpdvc dvc
                  WHERE dvc.cdcooper = " + STRING(crapcop.cdcooper) + "
                    AND dvc.dtmvtolt = TO_DATE('" + 
                              STRING(glb_dtmvtolt,'99/99/9999') + "','DD/MM/RRRR')
                    AND dvc.flgpcctl = 1").
              
    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
        ASSIGN vlr_totdevol = DEC(proc-text). 
    END.
                                              
    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
          WHERE PROC-HANDLE = aux_ponteiro.
                                 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                    
    /* Integrado Coop */
    RUN cria_tt_relatorio (INPUT crapcop.cdcooper,
                           INPUT "6 - INTEGRADO COOP",
                           OUTPUT aux_rowid).
    FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                           EXCLUSIVE-LOCK NO-ERROR.

    ASSIGN w-relatorio.devcobrm = w-relatorio.devcobrm + vlr_totdevol.    

/*........................... GNCPDOC ....................................... */
    FOR EACH gncpdoc WHERE gncpdoc.cdcooper = crapcop.cdcooper AND
                           gncpdoc.dtliquid = glb_dtmvtolt     NO-LOCK:

        IF   gncpdoc.cdtipreg = 2  THEN 
             DO:
                 RUN cria_tt_relatorio (INPUT gncpdoc.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 IF   gncpdoc.cdmotdev = 0 THEN /* ENVIO DOC */
                      ASSIGN w-relatorio.nrdedocs = w-relatorio.nrdedocs
                                                    + gncpdoc.vldocmto.
                 ELSE                        /* DEVOLU DOC */
                      ASSIGN w-relatorio.devdedoc = w-relatorio.devdedoc
                                                    + gncpdoc.vldocmto
                             w-relatorio.devdocrc = w-relatorio.devdocrc
                                                    + gncpdoc.vldocmto.
                 
                 /** Integrado Cecred **/

                 RUN cria_tt_relatorio (INPUT gncpdoc.cdcooper,
                                        INPUT "4 - INTEGRADO AILOS",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 IF   gncpdoc.cdmotdev = 0 THEN /* ENVIO DOC */
                      ASSIGN w-relatorio.nrdedocs = w-relatorio.nrdedocs
                                                    + gncpdoc.vldocmto.
                 ELSE                        /* DEVOLU DOC */
                      ASSIGN w-relatorio.devdedoc = w-relatorio.devdedoc
                                                    + gncpdoc.vldocmto
                             w-relatorio.devdocrc = w-relatorio.devdocrc
                                                    + gncpdoc.vldocmto.
             END.
    
        /** Integrado Coop **/
        IF   gncpdoc.cdcrictl = 0 AND
             gncpdoc.cdcritic = 0 AND
             gncpdoc.cdtipreg = 2 THEN 
             DO:
                 RUN cria_tt_relatorio (INPUT gncpdoc.cdcooper,
                                        INPUT "6 - INTEGRADO COOP",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 IF   gncpdoc.cdmotdev = 0 THEN /* ENVIO DOC */
                      ASSIGN w-relatorio.nrdedocs = w-relatorio.nrdedocs
                                                    + gncpdoc.vldocmto.
                 ELSE                        /* DEVOLU DOC */
                      ASSIGN w-relatorio.devdedoc = w-relatorio.devdedoc
                                                    + gncpdoc.vldocmto
                             w-relatorio.devdocrc = w-relatorio.devdocrc
                                                    + gncpdoc.vldocmto.
             END.

        IF   gncpdoc.cdtipreg = 3 OR 
             gncpdoc.cdtipreg = 4 THEN 
             DO:
                 /** Processado ABBC **/
                 RUN cria_tt_relatorio (INPUT gncpdoc.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 IF   gncpdoc.cdmotdev = 0 THEN /* ENVIO DOC */
                      ASSIGN w-relatorio.srdedocs = w-relatorio.srdedocs
                                                    + gncpdoc.vldocmto.
                 ELSE                           /* DEVOLU DOC */
                      ASSIGN w-relatorio.devdedoc = w-relatorio.devdedoc
                                                    + gncpdoc.vldocmto
                             w-relatorio.devdocrm = w-relatorio.devdocrm
                                                    + gncpdoc.vldocmto.
           
                 /** Integrado Cecred **/
                 IF   gncpdoc.cdtipreg  = 4  OR
                     (gncpdoc.cdtipreg  = 3  AND
                      gncpdoc.cdcritic <> 0) THEN
                      DO:
                          RUN cria_tt_relatorio (INPUT gncpdoc.cdcooper,
                                                 INPUT "4 - INTEGRADO AILOS",
                                                 OUTPUT aux_rowid).
                          FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                 EXCLUSIVE-LOCK NO-ERROR.
                    
                          IF   gncpdoc.cdmotdev = 0 THEN /* ENVIO DOC */
                               ASSIGN w-relatorio.srdedocs =
                                                     w-relatorio.srdedocs
                                                     + gncpdoc.vldocmto.
                          ELSE                          /* DEVOLU DOC */
                               ASSIGN w-relatorio.devdedoc =
                                                     w-relatorio.devdedoc
                                                     + gncpdoc.vldocmto
                                      w-relatorio.devdocrm =
                                                     w-relatorio.devdocrm
                                                     + gncpdoc.vldocmto.
                      END.
    
                 /** Integrado Coop **/
                 IF   gncpdoc.cdtipreg = 4  AND
                      gncpdoc.cdcritic = 0  THEN 
                      DO:
                          RUN cria_tt_relatorio (INPUT gncpdoc.cdcooper,
                                                 INPUT "6 - INTEGRADO COOP",
                                                 OUTPUT aux_rowid).
                          FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                 EXCLUSIVE-LOCK NO-ERROR.
    
                          IF   gncpdoc.cdmotdev = 0 THEN /* ENVIO DOC */
                               ASSIGN w-relatorio.srdedocs =
                                                     w-relatorio.srdedocs
                                                     + gncpdoc.vldocmto.
                      END.
             END.

        /** Gerado Coop **/
        IF  ((gncpdoc.cdtipreg = 2  AND
              gncpdoc.cdcritic = 0) OR
              gncpdoc.cdtipreg = 1) AND
              gncpdoc.cdmotdev = 0  /* ENVIO DOC */ THEN 
              DO:
                 RUN cria_tt_relatorio (INPUT gncpdoc.cdcooper,
                                        INPUT "5 - GERADO COOP",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.

                 ASSIGN w-relatorio.nrdedocs = w-relatorio.nrdedocs
                                               + gncpdoc.vldocmto.
             END.
             
    END. /** Fim do FOR EACH gncpdoc **/

/*........................... GNCPDEV ....................................... */
    FOR EACH gncpdev WHERE gncpdev.cdcooper = crapcop.cdcooper AND
                           gncpdev.dtliquid = glb_dtmvtolt     NO-LOCK:
    
        IF   gncpdev.cdtipreg = 2  THEN 
             DO:
                 RUN cria_tt_relatorio (INPUT gncpdev.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                      ASSIGN w-relatorio.dvchqrmn = w-relatorio.dvchqrmn
                                                    + gncpdev.vlcheque.
                 ELSE
                      IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                           ASSIGN w-relatorio.dvchqrmd = w-relatorio.dvchqrmd
                                                         + gncpdev.vlcheque.
                                                         
                 /** Integrado Cecred **/
                 
                 RUN cria_tt_relatorio (INPUT gncpdev.cdcooper,
                                        INPUT "4 - INTEGRADO AILOS",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                      ASSIGN w-relatorio.dvchqrmn = w-relatorio.dvchqrmn
                                                    + gncpdev.vlcheque.
                 ELSE
                      IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                           ASSIGN w-relatorio.dvchqrmd = w-relatorio.dvchqrmd
                                                         + gncpdev.vlcheque.
             END.
    
        /** Integrado Coop **/
        IF   gncpdev.cdcrictl = 0 AND
             gncpdev.cdcritic = 0 AND
             gncpdev.cdtipreg = 2 THEN 
             DO:
                 RUN cria_tt_relatorio (INPUT gncpdev.cdcooper,
                                        INPUT "6 - INTEGRADO COOP",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                      ASSIGN w-relatorio.dvchqrmn = w-relatorio.dvchqrmn
                                                    + gncpdev.vlcheque.
                 ELSE
                      IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                           ASSIGN w-relatorio.dvchqrmd = w-relatorio.dvchqrmd
                                                         + gncpdev.vlcheque.
             END.
    
        IF   gncpdev.cdtipreg = 3 OR 
             gncpdev.cdtipreg = 4 THEN 
             DO:
                 /** Processado ABBC **/
                 RUN cria_tt_relatorio (INPUT gncpdev.cdcooper,
                                        INPUT "3 - PROCESSADO ABBC",
                                        OUTPUT aux_rowid).
                 FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                        EXCLUSIVE-LOCK NO-ERROR.
    
                 IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                      ASSIGN w-relatorio.dvchqrcn = w-relatorio.dvchqrcn
                                                    + gncpdev.vlcheque.
                 ELSE
                      IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                           ASSIGN w-relatorio.dvchqrcd = w-relatorio.dvchqrcd
                                                         + gncpdev.vlcheque.
    
                 /** Integrado Cecred **/
                 IF   gncpdev.cdtipreg  = 4  OR
                     (gncpdev.cdtipreg  = 3  AND
                      gncpdev.cdcritic <> 0) THEN
                      DO:
                          RUN cria_tt_relatorio (INPUT gncpdev.cdcooper,
                                                 INPUT "4 - INTEGRADO AILOS",
                                                 OUTPUT aux_rowid).
                          FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                 EXCLUSIVE-LOCK NO-ERROR.
    
                          IF    gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                                ASSIGN w-relatorio.dvchqrcn =
                                                     w-relatorio.dvchqrcn
                                                     + gncpdev.vlcheque.
                          ELSE
                          IF    gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                                ASSIGN w-relatorio.dvchqrcd =
                                                     w-relatorio.dvchqrcd
                                                     + gncpdev.vlcheque.
                      END.
    
                 /** Integrado Coop **/
                 IF   gncpdev.cdtipreg = 4  AND
                      gncpdev.cdcritic = 0  THEN 
                      DO:
                          RUN cria_tt_relatorio (INPUT gncpdev.cdcooper,
                                                 INPUT "6 - INTEGRADO COOP",
                                                 OUTPUT aux_rowid).
                          FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                                 EXCLUSIVE-LOCK NO-ERROR.
    
                          IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                               ASSIGN w-relatorio.dvchqrcn =
                                                     w-relatorio.dvchqrcn
                                                     + gncpdev.vlcheque.
                          ELSE
                          IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                               ASSIGN w-relatorio.dvchqrcd =
                                                     w-relatorio.dvchqrcd
                                                     + gncpdev.vlcheque.
                      END.
             END.

        /** Gerado Coop **/
        IF (gncpdev.cdtipreg = 2  AND
            gncpdev.cdcritic = 0) OR
            gncpdev.cdtipreg = 1  THEN 
            DO:
                RUN cria_tt_relatorio (INPUT gncpdev.cdcooper,
                                       INPUT "5 - GERADO COOP",
                                       OUTPUT aux_rowid).
                FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                                       EXCLUSIVE-LOCK NO-ERROR.
    
                IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                     ASSIGN w-relatorio.dvchqrmn = w-relatorio.dvchqrmn
                                                   + gncpdev.vlcheque.
                ELSE
                    IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                         ASSIGN w-relatorio.dvchqrmd = w-relatorio.dvchqrmd
                                                       + gncpdev.vlcheque.
            END.
                
    END. /** Fim do FOR EACH gncpdev **/

END. /* Fim do FOR EACH crapcop */



/* Nao sera mais gerado o relatório crrl547, porém continuará chamando esta procedure 
para popular a tabela temporaria - Projeto 367 */
RUN imprime_relat_analitico.
RUN imprime_relat_sintetico.

RUN fontes/fimprg.p.

/*........................................................................... */

PROCEDURE imprime_relat_analitico:
/* Quebra por COOPER */
/* 
    ASSIGN aux_nmarqimp = "rl/crrl547.lst".

    OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 65.
    
    VIEW STREAM str_2 FRAME f_cabrel234_2.
    
    /* FRAME com o Titulo da pagina */
    VIEW STREAM str_2  FRAME f_titulo_analitico.
*/
    /** PROCESSANDO RELATORIO **/
    FOR EACH bw-relatorio WHERE bw-relatorio.cdcooper <> 0 NO-LOCK
                       BREAK BY bw-relatorio.cdtipreg
                             BY bw-relatorio.cdcooper:
/*
        FIND FIRST crabcop WHERE crabcop.cdcooper = bw-relatorio.cdcooper
                                 NO-LOCK NO-ERROR.
        
        IF   NOT AVAIL crabcop THEN
             aux_dscooper = "NAO ENCONTRADA".
        ELSE
             aux_dscooper = CAPS(crabcop.dsdircop).

        /* Frame - Mostra titulo do grupo */
        IF   FIRST-OF(bw-relatorio.cdtipreg) THEN
             DO:
                 DISPLAY STREAM str_2 bw-relatorio.cdtipreg FORMAT "x(25)"
                         WITH FRAME f_titulo_area.

                 IF   bw-relatorio.cdtipreg = "3 - PROCESSADO ABBC"  OR
                      bw-relatorio.cdtipreg = "4 - INTEGRADO AILOS" THEN
                      VIEW STREAM str_2 FRAME f_cabec_analitico_1_1.

                 IF   bw-relatorio.cdtipreg = "5 - GERADO COOP" THEN
                      VIEW STREAM str_2 FRAME f_cabec_analitico_2.

                 IF   bw-relatorio.cdtipreg = "6 - INTEGRADO COOP" THEN
                      VIEW STREAM str_2 FRAME f_cabec_analitico_3.
             END.

        CASE bw-relatorio.cdtipreg:

            WHEN "3 - PROCESSADO ABBC"  OR
            WHEN "4 - INTEGRADO AILOS" THEN
                 DO:
                     DISPLAY STREAM str_2 aux_dscooper  bw-relatorio.nrchqsup
                                 bw-relatorio.srchqsup  bw-relatorio.nrchqinf
                                 bw-relatorio.srchqinf  bw-relatorio.dvchqrmn
                                 bw-relatorio.dvchqrmd  bw-relatorio.dvchqrcn
                                 bw-relatorio.dvchqrcd  bw-relatorio.nrdedocs
                                 bw-relatorio.srdedocs  bw-relatorio.devdedoc
                                 WITH FRAME f_relat_analitico_1_1.
              
                     DOWN WITH FRAME f_relat_analitico_1_1.
                     
                 END.


            WHEN "5 - GERADO COOP" THEN 
                 DO:
                     DISPLAY STREAM str_2 aux_dscooper  bw-relatorio.nrchqsup
                                 bw-relatorio.nrchqinf  bw-relatorio.dvchqrmn
                                 bw-relatorio.dvchqrmd  bw-relatorio.nrcobinf
                                 bw-relatorio.nrcobvlb  bw-relatorio.nrdedocs
                                 WITH FRAME f_relat_analitico_2.
           
                     DOWN WITH FRAME f_relat_analitico_2.
                 END.

            WHEN "6 - INTEGRADO COOP" THEN 
                 DO:
                     DISPLAY STREAM str_2 aux_dscooper  bw-relatorio.srchqsup
                                 bw-relatorio.srchqinf  bw-relatorio.dvchqrcn
                                 bw-relatorio.dvchqrcd  bw-relatorio.srcobinf
                                 bw-relatorio.srcobvlb  bw-relatorio.devcobrm
                                 bw-relatorio.srdedocs
                                 WITH FRAME f_relat_analitico_3.
                     DOWN WITH FRAME f_relat_analitico_3.

                 END.
        END CASE.
*/
        /* Acumula valores para esse tipo na cooperativa 0 - Acumular TOTAIS */
        RUN cria_tt_relatorio (INPUT 0,
                               INPUT bw-relatorio.cdtipreg,
                               OUTPUT aux_rowid).

        FIND w-relatorio WHERE ROWID(w-relatorio) = aux_rowid
                               EXCLUSIVE-LOCK NO-ERROR.

        RUN soma_tt_relatorio.

/*
        IF   LAST-OF(bw-relatorio.cdtipreg) THEN 
             DO:
                 /* cdcooper = 0 eh o acumulador para campo TOTAL */
                 FIND w-relatorio WHERE 
                      w-relatorio.cdtipreg = bw-relatorio.cdtipreg AND
                      w-relatorio.cdcooper = 0        NO-LOCK NO-ERROR.

                 ASSIGN aux_dscooper = "TOTAL".

                 /* Mostra TOTAL do Tipo */
                 CASE w-relatorio.cdtipreg:
                      WHEN "3 - PROCESSADO ABBC"  OR
                      WHEN "4 - INTEGRADO AILOS" THEN
                          DO:
                               DISPLAY STREAM str_2 
                                   aux_dscooper          w-relatorio.nrchqsup
                                   w-relatorio.srchqsup  w-relatorio.nrchqinf
                                   w-relatorio.srchqinf  w-relatorio.dvchqrmn
                                   w-relatorio.dvchqrmd  w-relatorio.dvchqrcn
                                   w-relatorio.dvchqrcd  w-relatorio.nrdedocs
                                   w-relatorio.srdedocs  w-relatorio.devdedoc
                                   WITH FRAME f_total_analitico_1_1.


                               VIEW STREAM str_2 FRAME f_cabec_analitico_1_2.

                               /*** Parte 2 do PROCESSADO ABBC ***/
                               FOR EACH bfw-relatorio NO-LOCK
                                  WHERE bfw-relatorio.cdcooper <> 0
                                    AND bfw-relatorio.cdtipreg  =
                                        w-relatorio.cdtipreg
                                  BREAK BY bfw-relatorio.cdtipreg
                                        BY bfw-relatorio.cdcooper:

                                   FIND FIRST crabcop
                                        WHERE crabcop.cdcooper = 
                                              bfw-relatorio.cdcooper
                                      NO-LOCK NO-ERROR.

                                   IF   NOT AVAIL crabcop THEN
                                        aux_dscooper = "NAO ENCONTRADA".
                                   ELSE
                                        aux_dscooper = CAPS(crabcop.dsdircop).

                                   DISPLAY STREAM str_2 aux_dscooper
                                        bfw-relatorio.nrcobinf
                                        bfw-relatorio.srcobinf
                                        bfw-relatorio.nrcobvlb
                                        bfw-relatorio.srcobvlb
                                        bfw-relatorio.devcobrc
                                        bfw-relatorio.devcobrm  
                                        WITH FRAME f_relat_analitico_1_2.

                                   DOWN WITH FRAME f_relat_analitico_1_2.

                               END. /* Fim do FOR EACH */

                               ASSIGN aux_dscooper = "TOTAL".
                               DISPLAY STREAM str_2 
                                       aux_dscooper
                                       w-relatorio.nrcobinf
                                       w-relatorio.srcobinf
                                       w-relatorio.nrcobvlb
                                       w-relatorio.srcobvlb
                                       w-relatorio.devcobrc
                                       w-relatorio.devcobrm
                                  WITH FRAME f_total_analitico_1_2.

                          END.
    
                      WHEN "5 - GERADO COOP" THEN
                           DISPLAY STREAM str_2
                                   aux_dscooper          w-relatorio.nrchqsup
                                   w-relatorio.nrchqinf  w-relatorio.dvchqrmn
                                   w-relatorio.dvchqrmd  w-relatorio.nrcobinf
                                   w-relatorio.nrcobvlb  w-relatorio.nrdedocs
                                   WITH FRAME f_total_analitico_2.
    
                      WHEN "6 - INTEGRADO COOP" THEN
                           DISPLAY STREAM str_2
                                   aux_dscooper          w-relatorio.srchqsup
                                   w-relatorio.srchqinf  w-relatorio.dvchqrcn
                                   w-relatorio.dvchqrcd  w-relatorio.srcobinf
                                   w-relatorio.srcobvlb  w-relatorio.devcobrm
                                   w-relatorio.srdedocs
                                   WITH FRAME f_total_analitico_3.
                 END CASE.
             END. /* END do LAST-OF */
 */
    END. /* Fim FOR EACH */
 /*   
    OUTPUT STREAM str_2 CLOSE.

    ASSIGN glb_nrcopias = 1
           glb_nmformul = "234dh"
           glb_nmarqimp = aux_nmarqimp.
              
    RUN fontes/imprim.p. 

    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

    RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                          INPUT aux_nmarqimp,
                                          INPUT SUBSTR(aux_nmarqimp,4)).

    RUN enviar_email IN h-b1wgen0011 (INPUT glb_cdcooper,
                                      INPUT glb_cdprogra,
                                      INPUT "compe@ailos.coop.br",
                                      INPUT "RELATORIO FECHAMENTO COMPE " +
                                            "ABBC - ANALITICO",
                                      INPUT SUBSTR(aux_nmarqimp,4),
                                      INPUT TRUE).
                           
    DELETE PROCEDURE h-b1wgen0011.
*/                
END PROCEDURE.

/*........................................................................... */

PROCEDURE imprime_relat_sintetico:
/* Consolidado por Tipo Movimento */

    DEF VAR aux_extend            AS INT            NO-UNDO.

    ASSIGN aux_nmarqimp    = "rl/crrl533.lst".

    FOR EACH w-relatorio
       WHERE w-relatorio.cdcooper = 0 NO-LOCK:

        CASE w-relatorio.cdtipreg:
            WHEN "1 - FAC"              THEN  /* EXTEND = 1 */
                ASSIGN aux_extend = 1.
            WHEN "2 - ROC"              THEN  /* EXTEND = 2 */
                ASSIGN aux_extend = 2.
            WHEN "3 - PROCESSADO ABBC"  THEN  /* EXTEND = 3 */
                ASSIGN aux_extend = 3.
            WHEN "4 - INTEGRADO AILOS" THEN  /* EXTEND = 4 */
                ASSIGN aux_extend = 4.
            WHEN "5 - GERADO COOP"      THEN  /* EXTEND = 5 */
                ASSIGN aux_extend = 5.
            WHEN "6 - INTEGRADO COOP"   THEN  /* EXTEND = 6 */
                ASSIGN aux_extend = 6.
        END CASE.
        ASSIGN rel_nrcheque[aux_extend] = w-relatorio.nrcheque
               rel_nrcobvlb[aux_extend] = w-relatorio.nrcobvlb
               rel_nrcobinf[aux_extend] = w-relatorio.nrcobinf
               rel_srcobvlb[aux_extend] = w-relatorio.srcobvlb
               rel_srcobinf[aux_extend] = w-relatorio.srcobinf

               rel_nrddavlb[aux_extend] = w-relatorio.nrddavlb
               rel_nrddainf[aux_extend] = w-relatorio.nrddainf
               rel_srddavlb[aux_extend] = w-relatorio.srddavlb
               rel_srddainf[aux_extend] = w-relatorio.srddainf

               rel_nrdedocs[aux_extend] = w-relatorio.nrdedocs
               rel_srcheque[aux_extend] = w-relatorio.srcheque
               rel_srdedocs[aux_extend] = w-relatorio.srdedocs
               rel_dvchqrmn[aux_extend] = w-relatorio.dvchqrmn
               rel_dvchqrcn[aux_extend] = w-relatorio.dvchqrcn
               rel_dvchqrmd[aux_extend] = w-relatorio.dvchqrmd
               rel_dvchqrcd[aux_extend] = w-relatorio.dvchqrcd
               rel_devcobrc[aux_extend] = w-relatorio.devcobrc
               rel_devcobrm[aux_extend] = w-relatorio.devcobrm
               rel_devdocrc[aux_extend] = w-relatorio.devdocrc
               rel_devdocrm[aux_extend] = w-relatorio.devdocrm.
              
        IF   aux_extend = 1 THEN /* FAC */
             ASSIGN rel_totl_fac = rel_totl_fac + w-relatorio.nrcheque +
                                                  w-relatorio.nrcobvlb +
                                                  w-relatorio.nrcobinf +
                                                  w-relatorio.nrdedocs +
                                                  w-relatorio.srcheque +
                                                  w-relatorio.srdedocs +
                                                  w-relatorio.dvchqrmn +
                                                  w-relatorio.dvchqrcn +
                                                  w-relatorio.dvchqrmd +
                                                  w-relatorio.dvchqrcd +
                                                  w-relatorio.devcobrm +
                                                  w-relatorio.devcobrc +
                                                  w-relatorio.devdocrc +
                                                  w-relatorio.devdocrm.

        IF   aux_extend = 2 THEN /* ROC */
             ASSIGN rel_totl_roc = rel_totl_roc + w-relatorio.nrcheque +
                                                  w-relatorio.nrcobvlb +
                                                  w-relatorio.nrcobinf +
                                                  w-relatorio.nrddavlb +
                                                  w-relatorio.nrddainf +
                                                  w-relatorio.nrdedocs +
                                                  w-relatorio.srcheque +
                                                  w-relatorio.srcobvlb +
                                                  w-relatorio.srcobinf +
                                                  w-relatorio.srddavlb +
                                                  w-relatorio.srddainf +
                                                  w-relatorio.srdedocs +
                                                  w-relatorio.dvchqrmn +
                                                  w-relatorio.dvchqrcn +
                                                  w-relatorio.dvchqrmd +
                                                  w-relatorio.dvchqrcd +
                                                  w-relatorio.devcobrm +
                                                  w-relatorio.devcobrc +
                                                  w-relatorio.devdocrc +
                                                  w-relatorio.devdocrm.
     
    END. /* END do FOR EACH w-relatorio */

    ASSIGN rel_t_facroc = rel_totl_fac + rel_totl_roc
           rel_tot_abbc = rel_tot_abbc    + rel_nrcheque[3] 
                        + rel_nrcobvlb[3] + rel_nrcobinf[3] + rel_nrdedocs[3]
                        + rel_srcheque[3] + rel_srdedocs[3] + rel_dvchqrmn[3]
                        + rel_dvchqrcn[3] + rel_dvchqrmd[3] + rel_dvchqrcd[3]
                        + rel_devcobrc[3] + rel_devdocrc[3] + rel_devdocrm[3]
                        + rel_srcobvlb[3] + rel_srcobinf[3]
                        + rel_devcobrm[3] + rel_nrddavlb[3] + rel_nrddainf[3]
                        + rel_srddavlb[3] + rel_srddainf[3]
           rel_totcecre = rel_totcecre    + rel_nrcheque[4] 
                        + rel_nrcobvlb[4] + rel_nrcobinf[4] + rel_nrdedocs[4]
                        + rel_srcheque[4] + rel_srdedocs[4] + rel_dvchqrmn[4]
                        + rel_dvchqrcn[4] + rel_dvchqrmd[4] + rel_dvchqrcd[4]
                        + rel_devcobrc[4] + rel_devdocrc[4] + rel_devdocrm[4]
                        + rel_srcobvlb[4] + rel_srcobinf[4]
                        + rel_devcobrm[4] + rel_nrddavlb[4] + rel_nrddainf[4]
                        + rel_srddavlb[4] + rel_srddainf[4].

    /* GERAR RELATORIO*/                                         
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    /* FRAME com o Titulo da pagina */
    VIEW STREAM str_1  FRAME f_titulo_sintetico.

    DISPLAY STREAM str_1
                   rel_nrcheque
                   rel_nrcobvlb 
                   rel_nrddavlb
                   rel_nrcobinf
                   rel_nrddainf
                   rel_nrdedocs
        WITH FRAME f_relat_sintetico_1.

    DISPLAY STREAM str_1
                   rel_srcheque
                   rel_srcobvlb
                   rel_srddavlb
                   rel_srcobinf
                   rel_srddainf
                   rel_srdedocs
        WITH FRAME f_relat_sintetico_2.

    DISPLAY STREAM str_1
                   rel_dvchqrmn
                   rel_dvchqrcn
                   rel_dvchqrmd
                   rel_dvchqrcd
                   rel_devcobrm
                   rel_devcobrc
                   rel_devdocrm
                   rel_devdocrc
        WITH FRAME f_relat_sintetico_3.

    DISPLAY STREAM str_1
                   rel_totl_fac
                   rel_totl_roc
                   rel_t_facroc
                   rel_tot_abbc
                   rel_totcecre
        WITH FRAME f_relat_sintetico_totais.

/*** PROJETO 367 ***
    /* Inclusao das tarifas FAC/ROC */

    /* DIURNO */
    ASSIGN AUX_CONTADOR = 1.

    FOR EACH gnfcomp WHERE gnfcomp.cdcooper = glb_cdcooper AND
                           gnfcomp.dtmvtolt = glb_dtmvtolt AND
                           gnfcomp.idregist = 1            AND
                           gnfcomp.cdperarq = "D"          AND
                           gnfcomp.cdtipdoc <> 0           NO-LOCK
                           BREAK BY gnfcomp.cdtipfec
                                    BY gnfcomp.cdtipdoc:
       
        IF FIRST-OF (gnfcomp.cdtipdoc) THEN
           ASSIGN tot_vlremfac = 0
                  tot_vlrecfac = 0
                  tot_vlremroc = 0
                  tot_vlrecroc = 0.
        
        IF  gnfcomp.cdtipfec = 1 THEN  /* FAC */
            ASSIGN tot_vlremfac = tot_vlremfac + gnfcomp.vlremdoc 
                   tot_vlrecfac = tot_vlrecfac + (gnfcomp.vlrecdoc * -1).
        ELSE                           /* ROC */
            ASSIGN tot_vlremroc = tot_vlremroc + gnfcomp.vlremdoc 
                   tot_vlrecroc = tot_vlrecroc + (gnfcomp.vlrecdoc * -1).

        IF aux_contador = 1 THEN
           DO:
                ASSIGN aux_prtarifa = "TARIFAS - FECHAMENTO DIURNO".
                
                DISPLAY STREAM str_1 aux_prtarifa 
                    WITH FRAME f_periodo_tarifa.
           END.

        IF   LAST-OF(gnfcomp.cdtipdoc) THEN       
             DO:
                 CASE gnfcomp.cdtipdoc:
                    WHEN 007 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERB. DE DOC - 007".
                    WHEN 015 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERB. COBRANCAS - 015".
                    WHEN 055 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE FORNEC.DE COPIA - 055".
                    WHEN 056 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE DEV.DOC  PROC. - 056".
                    WHEN 093 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE TIC PARA A CIP - 093".
                    WHEN 096 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE RETORNO - CIP - 096".
                    WHEN 098 THEN 
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. (TEC) - 098".
                    WHEN 083 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE PROC. SILOC DIA - 083".
                    WHEN 086 THEN
                        ASSIGN aux_dstarifa = "TARIFA DEVOL.COB.PROCESS. - 086".
                    WHEN 058 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE DEV.COB  RESS. - 058".
                    WHEN 084 THEN
                        ASSIGN aux_dstarifa = "TARIFA DEV TEC PROCESSAD. - 084".
                    WHEN 064 THEN
                        ASSIGN aux_dstarifa = "TARIFA DEVOL.TEC RESSAR. - 064".
                    WHEN 099 THEN
                        ASSIGN aux_dstarifa = "TARIFA ATIVACAO REPROC - 099".
                    WHEN 052 THEN 
                        ASSIGN aux_dstarifa = "TAXA DEVOL. DIURNA - PART - 052".
                    WHEN 051 THEN 
                        ASSIGN aux_dstarifa = "TX.DEVOLUCAO NOTURNA PART - 051".
                    WHEN 091 THEN
                        ASSIGN aux_dstarifa = "TX.DEVOL.NOTURNA - EXECUT - 091".
                    WHEN 092 THEN
                        ASSIGN aux_dstarifa = "TAXA DEVOL. DIURNA - EXEC - 092".
                    WHEN 018 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. MVR - 018".
                    WHEN 024 THEN
                        ASSIGN aux_dstarifa = "TARIFA SUST CHQ MVR ROUBO - 024".
                    WHEN 087 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE PROCESSAM (EXE) - 087".
                    WHEN 002 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE ROUBO DE CHEQUE - 002".
                    WHEN 897 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE FORNECIMENTO - 897".
                    WHEN 887 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE PROCESSAMENTO - 887".
                    WHEN 027 THEN 
                        ASSIGN aux_dstarifa = "TARIFA CHEQUE ROUBADO - 027".
                    WHEN 016 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. (TIB) - 016".
                    WHEN 026 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. (TIB) - 026".
                    WHEN 097 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE PROCESSAM (EXE) - 097".
                    WHEN 013 THEN 
                        ASSIGN aux_dstarifa = "TAXA-CAD.EMIT.CHQ.S/FUNDO - 013".
                    OTHERWISE NEXT.
                 END CASE.
              
                 ASSIGN tot_vltotfac = tot_vlremfac + tot_vlrecfac
                        tot_vltotroc = tot_vlremroc + tot_vlrecroc. 


                 DISPLAY STREAM str_1 aux_dstarifa 
                         tot_vltotfac 
                         tot_vltotroc 
                 WITH FRAME f_tarifa.

                 DOWN STREAM str_1 WITH FRAME f_tarifa.

             END.
             ASSIGN tot_vlgerfac = tot_vlgerfac + tot_vltotfac
                    tot_vlgerroc = tot_vlgerroc + tot_vltotroc
                    tot_vltotfac = 0
                    tot_vltotroc = 0
                    aux_contador = aux_contador + 1.

    END.

    DISPLAY STREAM str_1 tot_vlgerfac
                         tot_vlgerroc
    WITH FRAME f_total_tarifa.

    ASSIGN tot_vlgerfac = 0
           tot_vlgerroc = 0
           tot_vltotfac = 0
           tot_vltotroc = 0.
           aux_contador = 1.

    /* NOTURNO */

    FOR EACH gnfcomp WHERE gnfcomp.cdcooper = glb_cdcooper AND
                           gnfcomp.dtmvtolt = glb_dtmvtolt AND
                           gnfcomp.idregist = 1            AND
                           gnfcomp.cdperarq = "N"          AND
                           gnfcomp.cdtipdoc <> 0           NO-LOCK
                           BREAK BY gnfcomp.cdtipfec
                                    BY gnfcomp.cdtipdoc:

        IF FIRST-OF (gnfcomp.cdtipdoc) THEN
            ASSIGN tot_vlremfac = 0
                   tot_vlrecfac = 0
                   tot_vlremroc = 0
                   tot_vlrecroc = 0.

        IF  gnfcomp.cdtipfec = 1 THEN  /* FAC */
            ASSIGN tot_vlremfac = tot_vlremfac + gnfcomp.vlremdoc 
                   tot_vlrecfac = tot_vlrecfac + (gnfcomp.vlrecdoc * -1).
        ELSE                           /* ROC */
            ASSIGN tot_vlremroc = tot_vlremroc + gnfcomp.vlremdoc 
                   tot_vlrecroc = tot_vlrecroc + (gnfcomp.vlrecdoc * -1).

        IF aux_contador = 1 THEN
           DO:
                ASSIGN aux_prtarifa = "TARIFAS - FECHAMENTO NOTURNO".
                
                DISPLAY STREAM str_1 aux_prtarifa 
                WITH FRAME f_periodo_tarifa.  
           END.

        IF   LAST-OF(gnfcomp.cdtipdoc) THEN       
             DO:
                 CASE gnfcomp.cdtipdoc:
                    WHEN 007 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERB. DE DOC - 007".
                    WHEN 015 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERB. COBRANCAS - 015".
                    WHEN 055 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE FORNEC.DE COPIA - 055".
                    WHEN 056 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE DEV.DOC  PROC. - 056".
                    WHEN 093 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE TIC PARA A CIP - 093".
                    WHEN 096 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE RETORNO - CIP - 096".
                    WHEN 098 THEN 
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. (TEC) - 098".
                    WHEN 083 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE PROC. SILOC DIA - 083".
                    WHEN 086 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DEVOL.COB.PROCESS. - 086".
                    WHEN 058 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE DEV.COB  RESS. - 058".
                    WHEN 084 THEN
                        ASSIGN aux_dstarifa = "TARIFA DEV TEC PROCESSAD. - 084".
                    WHEN 064 THEN
                        ASSIGN aux_dstarifa = "TARIFA DEVOL.TEC RESSAR. - 064".
                    WHEN 099 THEN
                        ASSIGN aux_dstarifa = "TARIFA ATIVACAO REPROC - 099".
                    WHEN 052 THEN 
                        ASSIGN aux_dstarifa = "TAXA DEVOL. DIURNA - PART - 052".
                    WHEN 051 THEN 
                        ASSIGN aux_dstarifa = "TX.DEVOLUCAO NOTURNA PART - 051".
                    WHEN 091 THEN
                        ASSIGN aux_dstarifa = "TX.DEVOL.NOTURNA - EXECUT - 091".
                    WHEN 092 THEN 
                        ASSIGN aux_dstarifa = "TAXA DEVOL. DIURNA - EXEC - 092".
                    WHEN 018 THEN
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. MVR - 018".
                    WHEN 024 THEN 
                        ASSIGN aux_dstarifa = "TARIFA SUST CHQ MVR ROUBO - 024".
                    WHEN 087 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE PROCESSAM (EXE) - 087".
                    WHEN 002 THEN
                        ASSIGN aux_dstarifa = "TARIFA DE ROUBO DE CHEQUE - 002".
                    WHEN 897 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE FORNECIMENTO - 897".
                    WHEN 887 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE PROCESSAMENTO - 887".
                    WHEN 027 THEN 
                        ASSIGN aux_dstarifa = "TARIFA CHEQUE ROUBADO - 027".
                    WHEN 016 THEN 
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. (TIB) - 016".
                    WHEN 026 THEN 
                        ASSIGN aux_dstarifa = "TARIFA INTERBANC. (TIB) - 026".
                    WHEN 097 THEN 
                        ASSIGN aux_dstarifa = "TARIFA DE PROCESSAM (EXE) - 097".
                    WHEN 013 THEN 
                        ASSIGN aux_dstarifa = "TAXA-CAD.EMIT.CHQ.S/FUNDO - 013".
                    OTHERWISE NEXT.
                 END CASE.
              
                 ASSIGN tot_vltotfac = tot_vlremfac + tot_vlrecfac
                        tot_vltotroc = tot_vlremroc + tot_vlrecroc. 

                 DISPLAY STREAM str_1 aux_dstarifa 
                                      tot_vltotfac 
                                      tot_vltotroc 
                 WITH FRAME f_tarifa.    

                 DOWN STREAM str_1 WITH FRAME f_tarifa.

             END.            
             ASSIGN tot_vlgerfac = tot_vlgerfac + tot_vltotfac
                    tot_vlgerroc = tot_vlgerroc + tot_vltotroc
                    tot_vltotfac = 0
                    tot_vltotroc = 0
                    aux_contador = aux_contador + 1.
    END.

    DISPLAY STREAM str_1 tot_vlgerfac
                         tot_vlgerroc
    WITH FRAME f_total_tarifa.             
****/ 
   
    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqimp.
               
    RUN fontes/imprim.p. 

    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

    RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                          INPUT aux_nmarqimp,
                                          INPUT SUBSTR(aux_nmarqimp,4)).

    RUN enviar_email IN h-b1wgen0011 (INPUT glb_cdcooper,
                                      INPUT glb_cdprogra,
                                      INPUT "compe@ailos.coop.br",
                                      INPUT "RELATORIO FECHAMENTO COMPE " +
                                            "ABBC - SINTETICO",
                                      INPUT SUBSTR(aux_nmarqimp,4),
                                      INPUT TRUE).

    DELETE PROCEDURE h-b1wgen0011.
                 
END PROCEDURE.

/*........................................................................... */

PROCEDURE cria_tt_relatorio:

    DEF INPUT  PARAM par_cdcooper AS INT            NO-UNDO.
    DEF INPUT  PARAM par_cdtipreg AS CHAR           NO-UNDO.
    DEF OUTPUT PARAM ret_rowid    AS ROWID          NO-UNDO.

    FIND FIRST w-relatorio WHERE w-relatorio.cdcooper = par_cdcooper  AND
                                 w-relatorio.cdtipreg = par_cdtipreg 
                                 EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAIL w-relatorio THEN 
         DO:
             CREATE w-relatorio.
             ASSIGN w-relatorio.cdcooper = par_cdcooper
                    w-relatorio.cdtipreg = par_cdtipreg.
         END.

    ret_rowid = ROWID(w-relatorio).

END PROCEDURE.

/*........................................................................... */

PROCEDURE soma_tt_relatorio.

    ASSIGN w-relatorio.nrcheque = w-relatorio.nrcheque + bw-relatorio.nrcheque
           w-relatorio.srcheque = w-relatorio.srcheque + bw-relatorio.srcheque
           w-relatorio.dvchqrmn = w-relatorio.dvchqrmn + bw-relatorio.dvchqrmn
           w-relatorio.dvchqrmd = w-relatorio.dvchqrmd + bw-relatorio.dvchqrmd
           w-relatorio.dvchqrcn = w-relatorio.dvchqrcn + bw-relatorio.dvchqrcn
           w-relatorio.dvchqrcd = w-relatorio.dvchqrcd + bw-relatorio.dvchqrcd
           w-relatorio.nrcobinf = w-relatorio.nrcobinf + bw-relatorio.nrcobinf
           w-relatorio.nrcobvlb = w-relatorio.nrcobvlb + bw-relatorio.nrcobvlb
           w-relatorio.nrddainf = w-relatorio.nrddainf + bw-relatorio.nrddainf
           w-relatorio.nrddavlb = w-relatorio.nrddavlb + bw-relatorio.nrddavlb
           w-relatorio.srcobinf = w-relatorio.srcobinf + bw-relatorio.srcobinf
           w-relatorio.srcobvlb = w-relatorio.srcobvlb + bw-relatorio.srcobvlb
           w-relatorio.srddainf = w-relatorio.srddainf + bw-relatorio.srddainf
           w-relatorio.srddavlb = w-relatorio.srddavlb + bw-relatorio.srddavlb
           w-relatorio.devcobrc = w-relatorio.devcobrc + bw-relatorio.devcobrc
           w-relatorio.devcobrm = w-relatorio.devcobrm + bw-relatorio.devcobrm
           w-relatorio.nrdedocs = w-relatorio.nrdedocs + bw-relatorio.nrdedocs
           w-relatorio.srdedocs = w-relatorio.srdedocs + bw-relatorio.srdedocs
           w-relatorio.devdedoc = w-relatorio.devdedoc + bw-relatorio.devdedoc
           w-relatorio.devdocrc = w-relatorio.devdocrc + bw-relatorio.devdocrc
           w-relatorio.devdocrm = w-relatorio.devdocrm + bw-relatorio.devdocrm.
           

END PROCEDURE.

/*........................................................................... */

