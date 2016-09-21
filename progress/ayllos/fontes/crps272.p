/* .............................................................................

   Programa: Fontes/crps272.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Agosto/99                       Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 078.
               Emite relatorio dos cheques pendentes para o associado (221).

   Alteracoes: 01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).

               13/03/2003 - Assinalar quando talao TB (Margarete).
               
               16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               10/11/2005 - Tratar o campo cdcooper na leitura da tabela
                            crapcor (Edson).
                            
               16/11/2005 - Tratar cada folha de cheque (Evandro).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               20/03/2007 - Ajustes para o Bancoob (Magui).
               
               29/03/2007 - Utilizar a BO b1wgen0003.p para listar os cheques
                            nao compensados (Evandro).
                            
               23/04/2007 - Utilizar a BO b1wgen0014.p para LOG (Evandro).

               07/02/2008 - Utilizar novos parametros da BO b1wgen0003 (David).
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................. */

DEF STREAM str_1.     /*  Para relacao dos cheques pendentes  */

DEF INPUT PARAM par_nrseqsol AS INT                                  NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INT                                  NO-UNDO.

{ includes/var_batch.i }

{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/var_internet.i }

DEF        VAR par_flgrodar     AS LOGICAL INIT TRUE                 NO-UNDO.
DEF        VAR par_flgfirst     AS LOGICAL INIT TRUE                 NO-UNDO.
DEF        VAR par_flgcance     AS LOGICAL                           NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tot_qtcordem AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR tot_qtcheque AS INT     FORMAT "z,zz9"                NO-UNDO.

DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsparame AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dstransa AS CHAR                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

DEF        VAR h-b1wgen0003 AS HANDLE                                NO-UNDO.


ASSIGN glb_cdprogra = "crps272"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM crapass.nrdconta AT  1 LABEL "CONTA/DV"
     crapass.nmprimtl AT 24 NO-LABEL
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS NO-LABEL WIDTH 80 FRAME f_associado.

FORM cratfdc.dtemschq AT  1 LABEL "EMISSAO"        FORMAT "99/99/9999"
     cratfdc.dtretchq AT 13 LABEL "RETIRADA"       FORMAT "99/99/9999"
     cratfdc.nrdctabb AT 25 LABEL "CONTA BASE"     FORMAT "zzzz,zzz,9"
     cratfdc.nrcheque AT 37 LABEL "CHEQUE"
     cratfdc.chqtaltb AT 47 LABEL "TB"
     cratfdc.dsobserv AT 50 LABEL "OBSERVACAO"     FORMAT "x(22)"
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 80 FRAME f_cheques.
     
FORM tot_qtcheque AT  9 LABEL "QTD. CHEQUES"
     tot_qtcordem AT 33 LABEL "QTD. CONTRA-ORDENS"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 80 FRAME f_total.

{ includes/cabrel080_1.i }

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                   crapsol.dtrefere = glb_dtmvtolt   AND
                   crapsol.nrsolici = 79             AND
                   crapsol.nrseqsol = par_nrseqsol   NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE crapsol   THEN
     DO:
         BELL.
         MESSAGE "Solicitacao nao existe".
         PAUSE 5 NO-MESSAGE.
         RETURN.
     END.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapass   THEN
     DO:
         glb_cdcritic = 9.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         PAUSE 5 NO-MESSAGE.
         glb_cdcritic = 0.
         RETURN.
     END.

/* BO para pegar os cheques nao compensados */
RUN sistema/generico/procedures/b1wgen0003.p 
    PERSISTENT SET h-b1wgen0003.
    
IF   VALID-HANDLE(h-b1wgen0003)   THEN
     DO:
         RUN selecao_cheques_pendentes
             IN h-b1wgen0003 (INPUT  glb_cdcooper,
                              INPUT  0,
                              INPUT  0,
                              INPUT  glb_cdoperad,
                              INPUT  glb_nmdatela,
                              INPUT  1,
                              INPUT  crapass.nrdconta,
                              INPUT  1,
                              OUTPUT tot_qtcheque,
                              OUTPUT tot_qtcordem,
                              OUTPUT TABLE cratfdc,
                              OUTPUT TABLE tt-erro).
                              
         IF   RETURN-VALUE = "NOK"   THEN
              DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
                   
                  IF  AVAILABLE tt-erro  THEN
                      DO:
                          BELL.
                          MESSAGE tt-erro.dscritic.
                          PAUSE 5 NO-MESSAGE.
                          RETURN.
                      END.
              END.
         
         DELETE PROCEDURE h-b1wgen0003.
     END.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

aux_nmarqimp = "rl/O221_" + STRING(TIME,"99999") + ".lst".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

VIEW STREAM str_1 FRAME f_cabrel080_1.

DISPLAY STREAM str_1 
        crapass.nrdconta  crapass.nmprimtl 
        WITH FRAME f_associado.
        
FOR EACH cratfdc:
                       
    IF   cratfdc.dsobserv = ""   THEN
         cratfdc.dsobserv = "_________________________".
    
    DISPLAY STREAM str_1
            cratfdc.dtemschq    cratfdc.dtretchq
            cratfdc.nrdctabb    cratfdc.nrcheque
            cratfdc.chqtaltb    cratfdc.dsobserv
            WITH FRAME f_cheques.
               
    DOWN 2 STREAM str_1 WITH FRAME f_cheques.

    IF  (LINE-COUNTER(str_1) + 1)  > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.
               
             DISPLAY STREAM str_1 
                     crapass.nrdconta  crapass.nmprimtl 
                     WITH FRAME f_associado.
         END.

END.  /*  Fim do FOR EACH  --  Leitura dos cheques  */

DISPLAY STREAM str_1
        tot_qtcheque  tot_qtcordem  WITH FRAME f_total.

OUTPUT STREAM str_1 CLOSE.

DO TRANSACTION ON ERROR UNDO, RETURN:

   crapsol.insitsol = 2.

END.  /*  Fim da transacao  */

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

{ includes/impressao.i }

/* .......................................................................... */

