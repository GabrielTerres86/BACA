/* ............................................................................

   Programa: Fontes/concbb_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Agosto/2004                     Ultima alteracao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar o relatorio de Conciliacao Correspondente Bancario

   Alteracoes:  24/11/2004 - Incluido nome operador relatorio(Mirtes)
   
                15/12/2004 - Separados os Ativos dos Cancelados (Evandro).
                
                23/03/2005 - Impressao Solicitacao Restituicao(Mirtes/Evandro).
                
                20/06/2005 - Somar os valores cancelados somente se forem
                             autenticacoes diferentes (Evandro).

                20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                             crapcop.cdcooper = glb_cdcooper (Diego).

                12/12/2005 - Tratar    tipo docto 3 - Recebto INSS(Mirtes)

                26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
                15/07/2009 - Alteracao CDOPERAD (Diego).
                
                11/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1)
                
                29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                
............................................................................ */
{ sistema/generico/includes/b1wgen0108tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF     STREAM str_1. /* relatorio */

DEF     INPUT PARAM     rel_dtmvtolt AS DATE   FORMAT "99/99/9999"   NO-UNDO.
DEF     INPUT PARAM     rel_cdagenci AS INT    FORMAT "zz9"          NO-UNDO.
DEF     INPUT PARAM     rel_nrdcaixa AS INT    FORMAT "zz9"          NO-UNDO.
DEF     INPUT PARAM     rel_inss     AS LOG                          NO-UNDO.
DEF     INPUT PARAM     rel_registro AS ROWID                        NO-UNDO.

DEF VAR h-b1wgen0108 AS HANDLE                                       NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.

/* variaveis para impressao */
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nrmodulo     AS INT     FORMAT "9"                NO-UNDO.
DEF        VAR rel_nmmodulo     AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF        VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmoperad AS CHAR    FORMAT "x(20)"                NO-UNDO.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM "Aguarde... Imprimindo..."
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.
CHOOSE FIELD tel_dsimprim tel_dscancel WITH FRAME f_atencao.
    
IF  FRAME-VALUE <> tel_dsimprim THEN
    DO: 
        HIDE FRAME f_atencao NO-PAUSE.
        RETURN.
    END.

INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

IF  NOT VALID-HANDLE(h-b1wgen0108) THEN
    RUN sistema/generico/procedures/b1wgen0108.p
        PERSISTENT SET h-b1wgen0108.

RUN Lista_Lotes IN h-b1wgen0108
    ( INPUT glb_cdcooper,
      INPUT 0,
      INPUT 0,
      INPUT 1,
      INPUT glb_dtmvtolt,
      INPUT aux_nmendter,
      INPUT rel_cdagenci,
      INPUT rel_nrdcaixa,
      INPUT rel_dtmvtolt,
      INPUT rel_registro,
      INPUT rel_inss,
     OUTPUT aux_nmarqimp,
     OUTPUT aux_nmarqpdf,
     OUTPUT TABLE tt-erro).

IF  VALID-HANDLE(h-b1wgen0108)  THEN
    DELETE PROCEDURE h-b1wgen0108.

IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
    DO:
        FIND FIRST tt-erro NO-ERROR.

        IF  AVAILABLE tt-erro THEN
            MESSAGE tt-erro.dscritic.
               
        RETURN "NOK".  
    END.

ASSIGN glb_nrdevias = 1
       glb_nmformul = IF  rel_registro <> ?   THEN 
                          "80col"
                      ELSE
                          "132col"
       par_flgrodar = TRUE.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.
HIDE FRAME f_atencao.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

{ includes/impressao.i }



/* .......................................................................... */
