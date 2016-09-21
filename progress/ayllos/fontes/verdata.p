/* .............................................................................

   Programa: Fontes/verdata.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes       
   Data    : Marco/2005.                     Ultima atualizacao:24/01/2006     

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Atualizar data no menu(se processo rodando)

   Alteracoes: 24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
............................................................................. */

{ includes/var_online.i }

FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapdat   THEN
     DO:
         glb_cdcritic = 1.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
         PAUSE MESSAGE "Tecle <entra> para voltar `a tela de identificacao!".
         BELL.
         QUIT.
     END.

PUT SCREEN "F2 = AJUDA" COLOR MESSAGE ROW 22 COLUMN 70.

ASSIGN glb_dtmvtolt = crapdat.dtmvtolt
       glb_dtmvtopr = crapdat.dtmvtopr
       glb_dtmvtoan = crapdat.dtmvtoan
       glb_inproces = crapdat.inproces.

IF  crapdat.inproces >= 3 THEN 
    DO:

       ASSIGN glb_dtmvtoan = glb_dtmvtolt
              glb_dtmvtolt = glb_dtmvtopr.
             
       DO WHILE TRUE:          /*  Procura pela proxima data de movimento */

         glb_dtmvtopr = glb_dtmvtopr + 1.

         IF   LOOKUP(STRING(WEEKDAY(glb_dtmvtopr)),"1,7") <> 0   THEN
              NEXT.

         IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                     crapfer.dtferiad = glb_dtmvtopr)   THEN
              NEXT.

         LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

    END.          

FORM SPACE(1) glb_dtmvtolt  FORMAT "99/99/9999"
     WITH FRAME f_dtmvtolt ROW  1 COLUMN 67 OVERLAY NO-LABEL WIDTH 14.

IF  glb_nmdatela <> "IDENTI"  AND
    glb_nmdatela <> " "      AND
    glb_nmdatela <> "PRINCIPAL" THEN
    DISPLAY glb_dtmvtolt WITH FRAME f_dtmvtolt.
/* .......................................................................... */
