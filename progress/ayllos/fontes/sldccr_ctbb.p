/* ............................................................................

   Programa: Fontes/sldccr_ctbb.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Junho/2006                         Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Imprime o contrato de cartao de credito para administradoras
               83,84,85,86,87,88(BANCO DO BRASIL).
               
   Alteracoes: 21/07/2006 - Nao criticar mais se situacao for = 1 (Diego).
               13/10/2006 - Alterada data contrato (entrega p/data atual)
                            (Mirtes)
               03/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)
                            
               09/11/2010 - Alteracao para adequacao projeto cartao PJ
                            (GATI - Sandro)             
                            
               06/06/2011 - Aumento do formato dos campos bairro e cidade
                            (Gabriel)             
                     
               17/04/2012 - Alteração na parte de impressão para imprimir o 
                            contrato na b1wgen0028. (David kruger).   
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................ */
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT  PARAM par_nrctrcrd   AS  INTEGER       NO-UNDO.

DEF NEW GLOBAL SHARED STREAM str_1.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL      INIT TRUE                NO-UNDO.
/*************************************************************/
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR h_b1wgen0028 AS HANDLE                                NO-UNDO.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM " Aguarde... Imprimindo contrato de cartao de credito! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
RUN gera_impressao_contrato_bb IN h_b1wgen0028
                                (INPUT  glb_cdcooper,
                                 INPUT  0,
                                 INPUT  0,
                                 INPUT  glb_cdoperad,
                                 INPUT  glb_nmdatela,
                                 INPUT  1, /* Ayllos */
                                 INPUT  tel_nrdconta,
                                 INPUT  1,
                                 INPUT  glb_dtmvtolt,
                                 INPUT  glb_dtmvtopr,
                                 INPUT  0,
                                 INPUT  par_nrctrcrd,
                                 INPUT  NO, /* (par_flgimpnp) */
                                 INPUT  aux_nmendter,
                                 INPUT  aux_flgimp2v,
                                 INPUT  NO,
                                 INPUT  0,
                                 OUTPUT aux_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro).

DELETE PROCEDURE h_b1wgen0028.

IF   RETURN-VALUE = "NOK" THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         IF   AVAIL tt-erro THEN
              DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
              END.
        ELSE
           MESSAGE "Erro na criacao do arquivo".
           RETURN "NOK".
     END.
     
VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

glb_nrdevias = 1.

FIND crapass WHERE
     crapass.cdcooper = glb_cdcooper AND
     crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

{ includes/impressao.i }

RETURN "OK".
/* .........................................................................*/
