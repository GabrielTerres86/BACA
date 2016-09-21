/* .............................................................................

   Programa: Fontes/loteconv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 13/05/2008

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Rotina de conversao de URV para Cruzeiros Reais

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
............................................................................. */

{ includes/var_online.i }

FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                   crapmfx.dtmvtolt = glb_dtmvtolt   AND
                   crapmfx.tpmoefix = 9              NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapmfx   THEN
     DO:
         glb_cdcritic = 211.
         RETURN.
     END.

CONVERTE:

FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                       craplcm.dtmvtolt = glb_dtmvtolt   AND
                       craplcm.cdagenci = glb_cdagenci   AND
                       craplcm.cdbccxlt = glb_cdbccxlt   AND
                       craplcm.nrdolote = glb_nrdolote   
                       USE-INDEX craplcm3 EXCLUSIVE-LOCK:

    FIND craphis NO-LOCK WHERE craphis.cdcooper = craplcm.cdcooper AND 
                               craphis.cdhistor = craplcm.cdhistor NO-ERROR.

    IF   NOT AVAILABLE craphis   THEN
         DO:
             glb_cdcritic = 83.
             UNDO CONVERTE, RETURN.
         END.

    DO WHILE TRUE:

       FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                          craplot.dtmvtolt = glb_dtmvtolt   AND
                          craplot.cdagenci = glb_cdagenci   AND
                          craplot.cdbccxlt = glb_cdbccxlt   AND
                          craplot.nrdolote = glb_nrdolote
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craplot   THEN
            IF   LOCKED craplot   THEN
                 DO:
                     glb_cdcritic = 84.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 glb_cdcritic = 60.
       ELSE
            ASSIGN glb_cdcritic     = 0
                   craplot.tpdmoeda = 1.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF   glb_cdcritic > 0    THEN
         UNDO CONVERTE, RETURN.

    IF   craphis.indebcre = "D"   THEN
         ASSIGN craplot.vlinfodb = craplot.vlinfodb - craplcm.vllanmto
                craplot.vlcompdb = craplot.vlcompdb - craplcm.vllanmto
                craplcm.vllanmto = TRUNCATE(craplcm.vllanmto *
                                                    crapmfx.vlmoefix,2)
                craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
    ELSE
    IF   craphis.indebcre = "C"   THEN
         ASSIGN craplot.vlinfocr = craplot.vlinfocr - craplcm.vllanmto
                craplot.vlcompcr = craplot.vlcompcr - craplcm.vllanmto
                craplcm.vllanmto = TRUNCATE(craplcm.vllanmto *
                                                    crapmfx.vlmoefix,2)
                craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.

END.  /*  Fim do FOR EACH  */

/* .......................................................................... */

