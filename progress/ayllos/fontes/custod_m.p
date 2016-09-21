/* ............................................................................

   Programa: Fontes/custod_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2001.                          Ultima atualizacao: 04/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de cheques em custodia para os associados (261)

   Alteracoes: 11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               30/10/2003 - Mudanca do label para cheques descontados (Julio).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               10/12/2009 - Estruturacao do programa em BO (GATI - Eder)
               
               09/12/2010 - Inclusao dos campos Data inicial e final na 
                            consulta (GATI - Sandro).
                            
               12/01/2012 - Reestruturação da BO para comunição com WEB
                            (Gabriel Capoia - DB1).
                            
               04/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               02/02/2015 - Alteracao do nome das funcoes da BO0018                            
                            (Carlos Rafael Tanholi)                              
............................................................................ */
{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_batch.i } 

DEF STREAM str_1.

DEF  INPUT PARAM par_nrdconta AS INT                                NO-UNDO.
DEF  INPUT PARAM par_inresgat AS LOGICAL                            NO-UNDO.
DEF  INPUT PARAM par_dtlibini AS DATE                               NO-UNDO.
DEF  INPUT PARAM par_dtlibfim AS DATE                               NO-UNDO.
DEF OUTPUT PARAM TABLE FOR tt-erro.

DEF VAR par_flgrodar AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR par_flgfirst AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR par_flgcance AS LOGI                                        NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.

DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                      NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5             NO-UNDO.

DEF VAR rel_nrmodulo AS INTE     FORMAT "9"                         NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                             INIT ["DEP. A VISTA   ","CAPITAL        ",
                                   "EMPRESTIMOS    ","DIGITACAO      ",
                                   "GENERICO       "]               NO-UNDO.

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.

DEF VAR aux_flgfirst AS LOGI                                        NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                      NO-UNDO.
DEF VAR aux_server   AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0018 AS HANDLE                                      NO-UNDO.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

/*  Gerenciamento da impressao  */
INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

INPUT THROUGH basename `hostname -s` NO-ECHO.
IMPORT UNFORMATTED aux_server.
INPUT CLOSE.

aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                      aux_nmendter.

IF  NOT VALID-HANDLE(h-b1wgen0018) THEN
    RUN sistema/generico/procedures/b1wgen0018.p 
        PERSISTENT SET h-b1wgen0018.

MESSAGE "Aguarde... Imprimindo o relatorio!".

RUN Gera_Custodia_Cheques IN h-b1wgen0018
                          ( INPUT glb_cdcooper,
                            INPUT glb_cdagenci,
                            INPUT 0,
                            INPUT 1, /*idorigem*/
                            INPUT glb_nmdatela,
                            INPUT glb_cdprogra,
                            INPUT glb_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_dtlibini,
                            INPUT par_dtlibfim,
                            INPUT par_inresgat,
                            INPUT aux_nmendter,
                           OUTPUT aux_nmarqimp,
                           OUTPUT aux_nmarqpdf,
                           OUTPUT TABLE tt-erro ).

IF  VALID-HANDLE(h-b1wgen0018) THEN
    DELETE PROCEDURE h-b1wgen0018.

IF  RETURN-VALUE <> "OK" THEN
    DO:
        FIND FIRST tt-erro NO-ERROR.

        IF  AVAIL tt-erro   THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
                RETURN.
            END.
    END.

ASSIGN glb_nmformul = ""
       glb_nrcopias = 1
       glb_nmarqimp = aux_nmarqimp.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

IF  NOT par_flgcance   THEN
    MESSAGE "RETIRE O RELATORIO DA IMPRESSORA!".
ELSE
    MESSAGE "IMPRESSAO CANCELADA!".
/* ......................................................................... */
