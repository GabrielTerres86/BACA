/* .............................................................................

   Programa: fontes/crps018.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
{ includes/var_batch.i } 

DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(40)"                NO-UNDO.

glb_cdprogra = "crps018".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.
/*
UPDATE aux_nmarquiv LABEL "Nome do arquivo a importar"
       WITH ROW 7 SIDE-LABELS CENTERED TITLE " Atualizacao do CRAPCOT ".

INPUT FROM VALUE(aux_nmarquiv) NO-ECHO.
*/
INPUT FROM integra/cotas07 NO-ECHO.
OUTPUT TO cotas.rej.

REPEAT:

   PROMPT-FOR crapcot.nrdconta VALIDATE(TRUE,"")
              crapcot.vldcotas VALIDATE(TRUE,"")
              crapcot.vlcmecot VALIDATE(TRUE,"")
              crapcot.vlcmicot VALIDATE(TRUE,"").

   IF   INPUT crapcot.nrdconta = 0   THEN
        LEAVE.

   DO  TRANSACTION ON ERROR UNDO, RETRY:

       FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper           AND
                          crapcot.nrdconta = INPUT crapcot.nrdconta 
                          EXCLUSIVE-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapcot   THEN
            DO:
                 DISPLAY INPUT crapcot.nrdconta
                         INPUT crapcot.vldcotas
                         INPUT crapcot.vlcmecot
                         INPUT crapcot.vlcmicot
                         WITH NO-LABELS DOWN FRAME f_cotas.
            END.
       ELSE
            ASSIGN crapcot.vldcotas
                   crapcot.vlcmecot
                   crapcot.vlcmicot.

   END.

END.

INPUT CLOSE.
OUTPUT CLOSE.

RUN fontes/fimprg.p.

/* .......................................................................... */

