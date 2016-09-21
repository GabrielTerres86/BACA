/*  ...........................................................................

   Programa: Fontes/custod_r2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/2003                       Ultima atualizacao: 11/12/2009

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de cheques em custodia transferidos
               para o desconto de cheques (315).

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               11/12/2009 - Estruturacao do programa em BO (GATI - Eder)
............................................................................ */
{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_batch.i }

DEF   STREAM str_1.

DEF INPUT PARAMETER TABLE FOR tt-crapbdc.

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

DEF   VAR rel_dspesqui AS CHAR                                       NO-UNDO.

DEF   VAR tot_qtcheque AS INT                                        NO-UNDO.
DEF   VAR tot_vlcheque AS DECIMAL                                    NO-UNDO.

DEF   VAR ger_qtcheque AS INT                                        NO-UNDO.
DEF   VAR ger_vlcheque AS DECIMAL                                    NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_regexist AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.
DEF   VAR aux_contabdc AS INT                                        NO-UNDO.
DEF   VAR aux_nrborder AS INT                                        NO-UNDO.

DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.

DEF   VAR h_b1wgen0018 AS HANDLE                                     NO-UNDO.


FORM "CUSTODIA DO DIA" 
     tt-crapbdc.dtlibera FORMAT "99/99/9999" NO-LABEL

     "TRANSFERIDA PARA DESCONTO - BORDERO" 
     tt-crapbdc.nrborder NO-LABEL FORMAT "z,zzz,zz9"
     SKIP(1)
     tt-crapbdc.nrdconta LABEL "CONTA/DV" "-"
     tt-crapbdc.nmprimtl NO-LABEL
     SKIP(2)
     WITH SIDE-LABELS NO-BOX WIDTH 80 FRAME f_conta.

FORM rel_dspesqui AT 10 LABEL "PROTOCOLO UTILIZADO" FORMAT "x(30)"
     tot_qtcheque AT 41 LABEL "QTD."                FORMAT "zzz,zz9"
     tot_vlcheque AT 51 LABEL "VALOR"               FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX WIDTH 80 DOWN FRAME f_protocolo.
 
FORM SKIP(1)
     "TOTAL GERAL ===>" AT 23
     ger_qtcheque AT 41 FORMAT "zzz,zz9"
     ger_vlcheque AT 51 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_total_geral.
   
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
       glb_cdrelato[1] = 315
       
       aux_nmarqimp = "rl/O315_" + STRING(TIME,"99999") + ".lst".
 
{ includes/cabrel080_1.i }
      
HIDE MESSAGE NO-PAUSE.

IF   NOT CAN-FIND(FIRST tt-crapbdc)   THEN
     RETURN "NOK".

/*  Gerenciamento da impressao  */
INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

MESSAGE "AGUARDE... IMPRIMINDO RELATORIO!".

RUN sistema/generico/procedures/b1wgen0018.p PERSISTENT SET h_b1wgen0018.
RUN busca_relatorio_desconto_custodia IN h_b1wgen0018
                               (INPUT        glb_cdcooper,
                                INPUT        0,
                                INPUT        0,
                                INPUT-OUTPUT TABLE tt-crapbdc,
                                OUTPUT       TABLE tt-crapcst,
                                OUTPUT       TABLE tt-erro).
DELETE PROCEDURE h_b1wgen0018.

IF   RETURN-VALUE = "NOK"   THEN
     DO:
         MESSAGE RETURN-VALUE.
         RETURN "NOK".
     END.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

FOR EACH tt-crapbdc:

   PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
   PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

   VIEW STREAM str_1 FRAME f_cabrel080_1.
 
   DISPLAY STREAM str_1 
           tt-crapbdc.dtlibera   tt-crapbdc.nrborder
           tt-crapbdc.nrdconta   tt-crapbdc.nmprimtl 
           WITH FRAME f_conta.

   FOR EACH tt-crapcst WHERE 
            tt-crapcst.cdcooper = tt-crapbdc.cdcooper   AND
            tt-crapcst.nrborder = tt-crapbdc.nrborder   
            BREAK BY tt-crapcst.dtmvtolt
                  BY tt-crapcst.cdagenci
                  BY tt-crapcst.cdbccxlt 
                  BY tt-crapcst.nrdolote:
                                              
       ASSIGN tot_qtcheque = tot_qtcheque + 1
              tot_vlcheque = tot_vlcheque + tt-crapcst.vlcheque
            
              ger_qtcheque = ger_qtcheque + 1
              ger_vlcheque = ger_vlcheque + tt-crapcst.vlcheque.
    
       IF   LAST-OF(tt-crapcst.dtmvtolt)   OR
            LAST-OF(tt-crapcst.cdagenci)   OR
            LAST-OF(tt-crapcst.cdbccxlt)   OR
            LAST-OF(tt-crapcst.nrdolote)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 2)  THEN
                     DO:
                         PAGE STREAM str_1.
                       
                         DISPLAY STREAM str_1 
                                 tt-crapbdc.dtlibera   tt-crapbdc.nrborder
                                 tt-crapbdc.nrdconta   tt-crapbdc.nmprimtl 
                                 WITH FRAME f_conta.
                     END.
             
                rel_dspesqui = STRING(tt-crapcst.dtmvtolt,"99/99/9999") + "-" +
                               STRING(tt-crapcst.cdagenci,"999")        + "-" +
                               STRING(tt-crapcst.cdbccxlt,"999")        + "-" +
                               STRING(tt-crapcst.nrdolote,"999999").
             
                IF   LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 2)   THEN
                     DO:
                         PAGE STREAM str_1.
         
                         DISPLAY STREAM str_1 
                                 tt-crapbdc.dtlibera   tt-crapbdc.nrborder  
                                 tt-crapbdc.nrdconta   tt-crapbdc.nmprimtl 
                                 WITH FRAME f_conta.
                     END.

                DISPLAY STREAM str_1   
                        rel_dspesqui tot_qtcheque  tot_vlcheque  
                        WITH FRAME f_protocolo.
         
                DOWN 2 STREAM str_1 WITH FRAME f_protocolo.
             
                ASSIGN tot_qtcheque = 0
                       tot_vlcheque = 0.
            END.

   END.  /*  Fim do FOR EACH -- Leitura da custodia  */

   IF   LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 10)   THEN
        DO:
            PAGE STREAM str_1.
         
            DISPLAY STREAM str_1 
                    tt-crapbdc.dtlibera   tt-crapbdc.nrborder  
                    tt-crapbdc.nrdconta   tt-crapbdc.nmprimtl 
                    WITH FRAME f_conta.
        END.
             
   DISPLAY STREAM str_1   
           ger_qtcheque  ger_vlcheque WITH FRAME f_total_geral.

   DISPLAY STREAM str_1
           SKIP(5)
           "____________________________________" AT 29 SKIP
           "  CADASTRO E VISTO DO FUNCIONARIO   " AT 29
           WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_visto.
 
   ASSIGN ger_qtcheque = 0
          ger_vlcheque = 0.
   
   PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
   PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

   PAGE STREAM str_1.
 
END.  /*  Fim do DO .. TO  */

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nmformul = ""
       glb_nrcopias = 2
       glb_nmarqimp = aux_nmarqimp.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

IF   NOT par_flgcance   THEN
     MESSAGE "RETIRE O RELATORIO DA IMPRESSORA!".
ELSE
     MESSAGE "IMPRESSAO CANCELADA!".

/* ......................................................................... */


