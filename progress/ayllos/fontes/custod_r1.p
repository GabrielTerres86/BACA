/* ...........................................................................

   Programa: Fontes/custod_r1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Setembro/2000.                  Ultima atualizacao: 03/12/2009

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de cheques em custodia digitados no
               dia (246).

   Alteracoes: 08/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
    
               01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).
               
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               03/12/2009 - Estruturacao do programa em BO (GATI - Eder)
............................................................................ */
{ sistema/generico/includes/b1wgen0018tt.i }
{ includes/var_batch.i }

DEF   STREAM str_1.

DEF INPUT PARAM par_dtlibera AS DATE FORMAT "99/99/9999"             NO-UNDO.

DEF   VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgcance AS LOGICAL                                    NO-UNDO.
DEF   VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                     NO-UNDO.
DEF   VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5            NO-UNDO.
DEF   VAR rel_nrmodulo AS INT     FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR rel_qtcompln AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR rel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.

DEF   VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_regexist AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.

DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmoperad AS CHAR    FORMAT "x(10)"                     NO-UNDO.
DEF   VAR aux_totqtinf LIKE craplot.qtinfoln                         NO-UNDO.
DEF   VAR aux_totvlcom LIKE craplot.vlcompdb                         NO-UNDO.
DEF   VAR aux_qtdlotes LIKE craplot.nrdolote                         NO-UNDO.

DEF   VAR aux_dtlibera AS DATE                                       NO-UNDO.
DEF   VAR h_b1wgen0018 AS HANDLE                                     NO-UNDO.

FORM "LIBERACAO PARA:" par_dtlibera  
     "** COOPER **" AT 69 SKIP(1)
     WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_cab.
      
FORM crawlot.dtmvtolt AT 1  COLUMN-LABEL "DATA"
     crawlot.cdagenci AT 14 COLUMN-LABEL "PAC"      FORMAT "zz9"
     crawlot.cdbccxlt AT 19 COLUMN-LABEL "CXA"
     crawlot.nrdolote AT 24 COLUMN-LABEL "   LOTE"
     crawlot.qtcompln AT 32 COLUMN-LABEL "QTD."     FORMAT "zzz,zz9"
     crawlot.vlcompdb AT 42 COLUMN-LABEL "VALOR"    FORMAT "zzz,zzz,zzz,zz9.99"
     crawlot.nmoperad AT 62 COLUMN-LABEL "DIGITADO POR"           
     WITH DOWN NO-BOX WIDTH 80 FRAME f_lotes.

FORM  SKIP(1)
      tt-relat-lotes.qtdlotes AT 24                 FORMAT "zzz,zz9" 
      tt-relat-lotes.qtchqtot AT 32                 FORMAT "zz,zz9"
      tt-relat-lotes.vlchqtot AT 42                 FORMAT "zzz,zzz,zzz,zz9.99"
      WITH NO-LABEL NO-BOX WIDTH 80 FRAME f_total.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 246.

{ includes/cabrel080_1.i }

ASSIGN aux_nmarqimp = "rl/crrl246.lst".
       
HIDE MESSAGE NO-PAUSE.

MESSAGE "AGUARDE... IMPRIMINDO RELATORIO!".

RUN sistema/generico/procedures/b1wgen0018.p PERSISTENT SET h_b1wgen0018.
RUN busca_lotes_custodia IN h_b1wgen0018
                               (INPUT  glb_cdcooper,
                                INPUT  0,
                                INPUT  0,
                                INPUT  par_dtlibera,
                                OUTPUT TABLE tt-relat-lotes,
                                OUTPUT TABLE crawlot).
DELETE PROCEDURE h_b1wgen0018.

IF   RETURN-VALUE = "NOK"   THEN
     DO:
         MESSAGE RETURN-VALUE.
         RETURN "NOK".
     END.

FIND tt-relat-lotes NO-ERROR.
IF   NOT AVAIL tt-relat-lotes   THEN
     RETURN "NOK".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

VIEW STREAM str_1 FRAME f_cabrel080_1.

DISPLAY STREAM str_1 par_dtlibera WITH FRAME f_cab.

FOR EACH crawlot BREAK BY crawlot.dtmvtolt
                       BY crawlot.cdagenci
                       BY crawlot.dtmvtolt
                       BY crawlot.nrdolote:
    
    IF   LINE-COUNTER(str_1) > 80  THEN
         DO:
             PAGE STREAM str_1.
             DISPLAY STREAM str_1 par_dtlibera 
                            WITH FRAME f_cab.
         END.

    DISPLAY STREAM str_1
            crawlot.dtmvtolt
            crawlot.cdagenci
            crawlot.cdbccxlt
            crawlot.nrdolote
            crawlot.qtcompln
            crawlot.vlcompdb
            crawlot.nmoperad
            WITH FRAME f_lotes.

    DOWN STREAM str_1 WITH FRAME f_lotes.
    
END.  /*  Fim do FOR EACH  */

IF   LINE-COUNTER(str_1) > 80  THEN
     DO:
         PAGE STREAM str_1.
         DISPLAY STREAM str_1 par_dtlibera 
                              WITH FRAME f_cab.
     END.

DISPLAY STREAM str_1
        tt-relat-lotes.qtdlotes   tt-relat-lotes.qtchqtot 
        tt-relat-lotes.vlchqtot
        WITH FRAME f_total.

DOWN STREAM str_1 WITH FRAME f_total.        
 
PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

OUTPUT  STREAM str_1 CLOSE.

ASSIGN glb_nmformul = ""
       glb_nrcopias = 1
       glb_nmarqimp = aux_nmarqimp.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

IF   NOT par_flgcance   THEN
     MESSAGE "RETIRE O RELATORIO DA IMPRESSORA!".
ELSE
     MESSAGE "IMPRESSAO CANCELADA!".

/* ......................................................................... */

