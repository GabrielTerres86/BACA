/* .............................................................................

   Programa: Fontes/Impbcaixa.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001                   Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para imprimir o TERMO DE ABERTURA DO BOLETIM DE CAIXA.

   Alteracoes: Unificacao dos Bancos - SQLWorks - Andre
   
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
                          
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
               
............................................................................. */

{ includes/var_online.i }

{ includes/var_bcaixa.i }

DEF STREAM str_1.

/* utilizados pelo includes impressao.i */

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.

DEF VAR par_flgrodar AS LOGI                                         NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                         NO-UNDO.
DEF VAR par_flgcance AS LOGI                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.

DEF VAR rel_nmresage AS CHAR                                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                     NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.

DEF VAR aux_lintrac1 AS CHAR    FORMAT "x(80)"                       NO-UNDO. 
DEF VAR aux_lintrac2 AS CHAR    FORMAT "x(48)"                       NO-UNDO.
DEF VAR aux_lintrac3 AS CHAR    FORMAT "x(80)"                       NO-UNDO.
DEF VAR aux_lintrac4 AS CHAR    FORMAT "x(65)"                       NO-UNDO.

DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_opcimpri AS LOG                                          NO-UNDO.

FORM "REFERENCIA:" crapbcx.dtmvtolt 
     "** TERMO DE ABERTURA **" AT 29 
     SKIP(1)
     "PA:" crapbcx.cdagenci "-" crapage.nmresage
     "OPERADOR:" crapbcx.cdopecxa "-" crapope.nmoperad  FORMAT "x(25)" 
     SKIP(1)
     "CAIXA:" crapbcx.nrdcaixa "AUTENTICADORA:" AT 21 crapbcx.nrdmaqui
     "LACRE ANTERIOR:" AT 56 ant_nrdlacre
     SKIP(1)
     aux_lintrac1 FORMAT "x(80)"
     SKIP(1)
     "SALDO INICIAL" aux_lintrac2 FORMAT "x(48)" ":" crapbcx.vldsdini
      SKIP(1)
      aux_lintrac3 FORMAT "x(80)"
      SKIP(1)
      "VISTOS: "
      SKIP(4)
      SPACE(10) "------------------------------"
      SPACE(6)  "------------------------------"
      SKIP   
      SPACE(17) "OPERADOR         " SPACE(22) "RESPONSAVEL"
      SKIP(3)
      SPACE(51) "AUTENTICACAO MECANICA"
      SKIP(4)
      "---<Corte aqui>" SPACE(0) aux_lintrac4 FORMAT "x(65)"
     WITH NO-BOX COLUMN 1 NO-LABELS  FRAME f_termo.

FORM "Aguarde... Imprimindo termo de abertura!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

ASSIGN glb_cdprogra    = "bcaixa"
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 258
       glb_flgbatch    = FALSE
       par_flgrodar    = TRUE.
       
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

{ includes/cabrel080_1.i }               /* Monta cabecalho do relatorio */

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.

/*  Configura a impressora para 1/8"  */
PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

ASSIGN glb_cdcritic = 0.
       
FIND crapbcx WHERE RECID(crapbcx) = aux_recidbol NO-LOCK NO-ERROR.
IF   NOT AVAILABLE crapbcx   THEN
     DO:
         ASSIGN glb_cdcritic = 90.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                   crapage.cdagenci = crapbcx.cdagenci NO-LOCK NO-ERROR.
IF   NOT AVAILABLE crapage   THEN
     DO:
         ASSIGN glb_cdcritic = 15.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         LEAVE.
     END.

FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                   crapope.cdoperad = crapbcx.cdopecxa NO-LOCK NO-ERROR.
IF   NOT AVAILABLE crapope   THEN
     DO:
         ASSIGN glb_cdcritic = 702.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         LEAVE.
     END.

ASSIGN aux_lintrac1 = fill("=",80)
       aux_lintrac2 = fill(".",48)
       aux_lintrac3 = fill("-",80)
       aux_lintrac4 = fill("-",65).
             
DISPLAY STREAM str_1
        crapbcx.dtmvtolt 
        crapbcx.cdagenci 
        crapage.nmresage
        crapbcx.cdopecxa
        crapope.nmoperad
        crapbcx.nrdcaixa
        crapbcx.nrdmaqui
        ant_nrdlacre
        aux_lintrac1
        aux_lintrac2
        crapbcx.vldsdini
        aux_lintrac3
        aux_lintrac4
        WITH FRAME f_termo.
DOWN STREAM str_1 WITH FRAME f_termo.        
PAGE STREAM str_1.
     
OUTPUT STREAM str_1 CLOSE.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

/*** nao necessario ao programa somente para nao dar erro de compilacao na
     rotina de impressao ****/
     
FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

{ includes/impressao.i } 
     
HIDE MESSAGE NO-PAUSE.

RETURN.
/* .......................................................................... */
