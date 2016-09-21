/* .............................................................................

   Programa: includes/lelct.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/92.                           Ultima atualizacao: 13/05/2008

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Processar a rotina de calculo do capital.

   Alteracoes: 25/03/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

............................................................................. */

aux_vlcmmcot = 0.     /*  Zera valor da correcao monetaria do mes  */

DO WHILE TRUE:

   FOR EACH craplct WHERE craplct.cdcooper  = glb_cdcooper   AND
                          craplct.dtmvtolt >= aux_dtrefcot   AND
                          craplct.nrdconta =  aux_nrdconta
                          NO-LOCK, 
            craphis NO-LOCK WHERE
                       craphis.cdcooper = craplct.cdcooper AND 
                       craphis.cdhistor = craplct.cdhistor             
                          BY craplct.dtmvtolt
                             BY IF craphis.indebcre = "C" THEN "1"
                                ELSE IF craphis.inhistor = 17 THEN "2"
                                     ELSE "3":
       
       FIND craphis WHERE craphis.cdhistor = craplct.cdhistor AND
                          craphis.cdcooper = craplct.cdcooper
                          NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craphis   THEN
            DO:
                glb_cdcritic = 80.
                LEAVE.
            END.

       FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper       AND
                          crapmfx.dtmvtolt = craplct.dtmvtolt   AND
                          crapmfx.tpmoefix = 2 NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapmfx   THEN
            DO:
                glb_cdcritic = 140.
                LEAVE.
            END.

       aux_vllanmfx = craplct.vllanmto / crapmfx.vlmoefix.

       IF   craphis.inhistor = 6   THEN
            ASSIGN aux_qtcotmfx = aux_qtcotmfx + aux_vllanmfx.
       ELSE
       IF   craphis.inhistor = 7   THEN
            ASSIGN aux_qtcotmfx = aux_qtcotmfx + aux_vllanmfx
                   aux_vlcmicot = aux_vlcmicot + craplct.vllanmto.
       ELSE
       IF   craphis.inhistor = 8   THEN
            ASSIGN aux_qtcotmfx = aux_qtcotmfx + aux_vllanmfx
                   aux_vlcmmcot = aux_vlcmmcot - craplct.vllanmto.
       ELSE
       IF   craphis.inhistor = 16   THEN
            ASSIGN aux_qtcotmfx = aux_qtcotmfx - aux_vllanmfx.
       ELSE
       IF   craphis.inhistor = 17   THEN
            ASSIGN aux_qtcotmfx = aux_qtcotmfx - aux_vllanmfx
                   aux_vlcmmcot = aux_vlcmmcot + craplct.vllanmto.
       ELSE
       IF   craphis.inhistor = 18   THEN
            ASSIGN aux_qtcotmfx = aux_qtcotmfx - aux_vllanmfx
                   aux_vlcmicot = aux_vlcmicot - craplct.vllanmto.
       ELSE
       IF   craphis.inhistor = 19   THEN
            ASSIGN aux_vlcmicot = aux_vlcmicot - craplct.vllanmto.

   END.  /*  Fim do FOR EACH -- Leitura dos lanctos de capital  */

   IF   glb_cdcritic > 0   THEN
        LEAVE.

   IF   aux_flgdodia   THEN
        FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                           crapmfx.dtmvtolt = glb_dtmvtolt   AND
                           crapmfx.tpmoefix = 2 NO-LOCK NO-ERROR.
   ELSE
        FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                           crapmfx.dtmvtolt = glb_dtmvtopr   AND
                           crapmfx.tpmoefix = 2 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapmfx   THEN
        DO:
            glb_cdcritic = 140.
            LEAVE.
        END.

   ASSIGN aux_qtcotmfx = ROUND(aux_qtcotmfx,4).

   IF   aux_qtcotmfx = 0.0001   AND
        aux_vlcmmcot > 0        THEN
        aux_qtcotmfx = 0.

   ASSIGN aux_vlcmecot = TRUNCATE(((aux_qtcotmfx * crapmfx.vlmoefix) -
                                    aux_vldcotas),2)

          aux_vlcmmcot = aux_vlcmmcot + aux_vlcmecot.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
