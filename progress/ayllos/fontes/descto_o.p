/* ..........................................................................

   Programa: Fontes/descto_o.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Outubro/2003.                   Ultima atualizacao: 04/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de cheques descontados para conferencia
               de um periodo (307).

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               29/10/2009 - Alteracao da estrutura dos dados - quebra por PAC;
                            Inclusao de opcao de imprimir de um PAC especifico 
                            - parametro; 
                            Estruturacao em BOs (GATI - Eder)
                            
               16/02/2011 - Alteracao devido ajuste do campo nome (Henrique).
               
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               27/02/2015 - Alteracao do handle da BO 18 para 18i aonde
                            se encontram as funcoes de impressao
                            (Carlos Rafael Tanholi)                              
............................................................................ */
{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_batch.i } 

DEF   STREAM str_1.

DEF INPUT PARAM par_dtiniper AS DATE                            NO-UNDO.
DEF INPUT PARAM par_dtfimper AS DATE                            NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta              NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapass.cdagenci              NO-UNDO.

/* Variaveis utilizadas na impressao - impressao.i */
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                       NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                       NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                 NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                 NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.

/* Variaveis utilizadas no relatorio - cabrel132_i.i */
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                  NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5         NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                      NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                              INIT ["DEP. A VISTA   ","CAPITAL        ",
                                    "EMPRESTIMOS    ","DIGITACAO      ",
                                        "GENERICO       "]      NO-UNDO.

DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"   NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"   NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                  NO-UNDO.
DEF VAR aux_server   AS CHAR                                    NO-UNDO.
DEF VAR aux_contador AS INT                                     NO-UNDO.
DEF VAR h-b1wgen0018i AS HANDLE                                  NO-UNDO.

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

IF  NOT VALID-HANDLE(h-b1wgen0018i) THEN
    RUN sistema/generico/procedures/b1wgen0018i.p
        PERSISTENT SET h-b1wgen0018i.

MESSAGE "AGUARDE... IMPRIMINDO RELATORIO!".

RUN gera-conferencia-cheques IN h-b1wgen0018i
                           ( INPUT glb_cdcooper,
                             INPUT glb_cdagenci,
                             INPUT 0, /*nrdcaixa*/
                             INPUT 1, /*idorigem*/
                             INPUT glb_nmdatela,
                             INPUT glb_cdprogra,
                             INPUT glb_dtmvtolt,
                             INPUT aux_nmendter,
                             INPUT par_dtiniper,
                             INPUT par_dtfimper,
                             INPUT par_nrdconta,
                             INPUT par_cdagenci,
                            OUTPUT aux_nmarqimp,
                            OUTPUT aux_nmarqpdf,
                            OUTPUT TABLE tt-erro ).

IF  VALID-HANDLE(h-b1wgen0018i) THEN
    DELETE PROCEDURE h-b1wgen0018i.

HIDE MESSAGE NO-PAUSE.

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

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

IF  NOT par_flgcance   THEN
    MESSAGE "RETIRE O RELATORIO DA IMPRESSORA!".
ELSE
    MESSAGE "IMPRESSAO CANCELADA!".
/* ......................................................................... */

