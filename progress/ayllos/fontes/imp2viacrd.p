/* ............................................................................

   Programa: fontes/imp2viacrd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Maio/2004.                      Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Impressao do pedido de 2via de cartao de credito.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               27/01/2006 -Unificacao dos Bancos - SQLWorks - Luciane.

               04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                            arquivo (Martin).

               19/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)
                                                        
               09/11/2010 - Alteracao para adequacao projeto cartao PJ
                            (GATI - Sandro)  
                            
               03/02/2011 - Alteracao do formato do campo Nome do Cooperado
                            na assinatura para 50 posicoes (GATI - Eder)
                            
               19/10/2011 - Aumentar FORMAT no motivo da solicitacao (Ze).
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................ */
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }

DEF  INPUT  PARAM par_nrctrcrd   AS  INTEGER       NO-UNDO.

DEF STREAM str_1.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL      INIT TRUE                NO-UNDO.
/*************************************************************/

DEF        VAR aux_nmarqimp  AS CHAR                                 NO-UNDO.
DEF        VAR aux_nmendter  AS CHAR                                 NO-UNDO.
DEF        VAR tel_dsimprim  AS CHAR FORMAT "x(8)" INIT "Imprimir"   NO-UNDO.
DEF        VAR tel_dscancel  AS CHAR FORMAT "x(8)" INIT "Cancelar"   NO-UNDO.
DEF        VAR h_b1wgen0028  AS HANDLE                               NO-UNDO.

DEF        VAR aux_nrcrcard  LIKE crawcrd.nrcrcard                   NO-UNDO.

FORM SKIP(3)
     tt-termo_solici2via.nmextcop AT 18 FORMAT "x(50)" 
     SKIP
     tt-termo_solici2via.nrdocnpj AT 29 
     SKIP(3)
     WITH NO-BOX NO-LABELS FRAME f_cooperativa.

FORM "SOLICITACAO DE SEGUNDA VIA DE CARTAO DE CREDITO" AT 14
     SKIP
     "===============================================" AT 14
     SKIP(3)
     tt-termo_solici2via.nrdconta AT  2 FORMAT "zzzz,zzz,9" LABEL "Conta/dv"
     tt-termo_solici2via.nrcrcard AT 27 FORMAT "zzzz,zzzz,zzzz,zzz9" 
                                        LABEL "Numero do Cartao"
     SKIP(1)
     tt-termo_solici2via.nmprimtl AT  1 FORMAT "x(40)"      LABEL "Associado"
     SKIP(4)
     "Solicito pela presente, a segunda via do cartao de credito"
     tt-termo_solici2via.dsadmcrd FORMAT "x(20)" SKIP "numero"
     aux_nrcrcard FORMAT "zzzz,zzzz,zzzz,zzz9" 
     ", por motivo de " 
     tt-termo_solici2via.dsmot2vi FORMAT "x(20)" "."
     SKIP(3)
     WITH NO-BOX SIDE-LABELS NO-LABELS FRAME f_sol2via.

FORM SKIP(5) 
     tt-termo_solici2via.localdat       FORMAT "x(60)"
     SKIP(5)
     "________________________________________" AT 3  SKIP
     tt-termo_solici2via.nmprimtl               AT 3  FORMAT "x(50)" NO-LABEL 
     SKIP(4)
     "________________________________________" AT 3  SKIP
     tt-termo_solici2via.nmrecop1 AT 3 FORMAT "x(40)" SKIP
     tt-termo_solici2via.nmrecop2 AT 3 FORMAT "x(40)"
     WITH WIDTH 115 NO-BOX NO-LABELS FRAME f_assina.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM "Aguarde... Imprimindo pedido de segunda via!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
RUN impressoes_cartoes IN h_b1wgen0028
                            ( INPUT  glb_cdcooper,
                              INPUT  0,
                              INPUT  0,
                              INPUT  glb_cdoperad,
                              INPUT  glb_nmdatela,
                              INPUT  1,
                              INPUT  tel_nrdconta,
                              INPUT  1,
                              INPUT  glb_dtmvtolt,
                              INPUT  glb_dtmvtopr,
                              INPUT  glb_inproces,
                              INPUT  6, /* Termo de solicitacao de 2a. via */
                              INPUT  par_nrctrcrd,
                              INPUT  YES,
                              INPUT  ?, /* (par_flgimpnp) */
                              INPUT  0, /* (par_cdmotivo) */
                              
                              OUTPUT TABLE tt-dados_prp_ccr,
                              OUTPUT TABLE tt-dados_prp_emiss_ccr,
                              OUTPUT TABLE tt-outros_cartoes,
                              OUTPUT TABLE tt-termo_cancblq_cartao,
                              OUTPUT TABLE tt-ctr_credicard,
                              OUTPUT TABLE tt-bdn_visa_cecred,
                              OUTPUT TABLE tt-termo_solici2via,
                              OUTPUT TABLE tt-avais-ctr,
                              OUTPUT TABLE tt-ctr_bb,
                              OUTPUT TABLE tt-termo_alt_dt_venc,
                              OUTPUT TABLE tt-alt-limite-pj,
                              OUTPUT TABLE tt-alt-dtvenc-pj,
                              OUTPUT TABLE tt-termo-entreg-pj,       
                              OUTPUT TABLE tt-segviasen-cartao, /* sandro */
                              OUTPUT TABLE tt-segvia-cartao,
                              OUTPUT TABLE tt-termocan-cartao,
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
     END.
     
FIND tt-termo_solici2via NO-ERROR.
IF   NOT AVAIL tt-termo_solici2via   THEN
     RETURN "NOK".
     
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 66.

/*  Configura a impressora para 1/6"  */

PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.


ASSIGN aux_nrcrcard = tt-termo_solici2via.nrcrcard.

DISPLAY STREAM str_1 
        tt-termo_solici2via.nmextcop   tt-termo_solici2via.nrdocnpj 
        WITH FRAME f_cooperativa.

DISPLAY STREAM str_1 
        tt-termo_solici2via.nrdconta   tt-termo_solici2via.nrcrcard
        tt-termo_solici2via.nmprimtl   tt-termo_solici2via.dsadmcrd
        aux_nrcrcard                   tt-termo_solici2via.dsmot2vi
        WITH FRAME f_sol2via.

DISPLAY STREAM str_1 
        tt-termo_solici2via.localdat   tt-termo_solici2via.nmprimtl 
        tt-termo_solici2via.nmrecop1   tt-termo_solici2via.nmrecop2
        WITH FRAME f_assina.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrdevias = 1
       par_flgrodar = TRUE.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

FIND crapass WHERE
     crapass.cdcooper = glb_cdcooper AND
     crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.       
{includes/impressao.i}
  
/* ......................................................................... */
