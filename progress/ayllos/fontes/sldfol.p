
/* .............................................................................

   Programa: Fontes/sldfol.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Agosto/97.                          Ultima atualizacao: 13/05/2008
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o saldo dos avisos e mostrar o
               extrato dos mesmos na tela ATENDA.

   Alteracao : 18/12/97 - Alterado para mostrar tambem os debitos em conta
                          referentes a convenios (Deborah).

               02/08/1999 - Tratar seguro de vida (Deborah). 

               20/01/2000 - Tratar seguro prestamista (Deborah).
               
               27/07/2001 - Tratar historico 341 - Seguro de Vida (Junior)

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
............................................................................. */

{ includes/var_online.i }

{ includes/var_atenda.i }

DEF INPUT  PARAM par_flgextra AS LOGICAL                             NO-UNDO.

glb_cdcritic = 0.

IF   par_flgextra    THEN
     FOR EACH crawext:

         DELETE crawext.

     END.
       
     
     /*  Fim do FOR EACH  */

FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper  AND
                       crapavs.nrdconta = tel_nrdconta  AND
                       crapavs.tpdaviso = 1             AND
                       crapavs.insitavs = 0             AND
                       crapavs.flgproce = FALSE         AND
                       NOT CAN-DO("160,175,199,341",STRING(crapavs.cdhistor))
                       NO-LOCK:

    FIND craphis NO-LOCK WHERE craphis.cdcooper = crapavs.cdcooper AND 
                               craphis.cdhistor = crapavs.cdhistor NO-ERROR.

    IF   NOT AVAILABLE craphis   THEN
         DO:
             glb_cdcritic = 80.
             aux_flgerros = TRUE.
             LEAVE.
         END.

    IF   CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
         aux_vldfolha = aux_vldfolha + crapavs.vllanmto - crapavs.vldebito.
    ELSE
    IF   CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
         aux_vldfolha = aux_vldfolha - (crapavs.vllanmto - crapavs.vldebito).
    ELSE
         DO:
             glb_cdcritic = 83.
             aux_flgerros = TRUE.
             LEAVE.
         END.

    IF   par_flgextra   THEN
         DO:
             CREATE crawext.
             ASSIGN crawext.dtmvtolt = 01/01/9999

                    crawext.dshistor = craphis.dshistor

                    crawext.nrdocmto = STRING(crapavs.nrdocmto,"zz,zzz,zz9")

                    crawext.indebcre = craphis.indebcre

                    crawext.vllanmto = crapavs.vllanmto - crapavs.vldebito.
         END.

END.  /*  Fim do FOR EACH -- Leitura dos avisos */

FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper   AND
                       crapavs.nrdconta = tel_nrdconta   AND
                       crapavs.tpdaviso = 3              AND
                       crapavs.insitavs = 0              AND
                       crapavs.flgproce = FALSE
                       NO-LOCK:

    FIND craphis NO-LOCK WHERE craphis.cdcooper = crapavs.cdcooper AND 
                               craphis.cdhistor = crapavs.cdhistor NO-ERROR.

    IF   NOT AVAILABLE craphis   THEN
         DO:
             glb_cdcritic = 80.
             aux_flgerros = TRUE.
             LEAVE.
         END.

    IF   CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
         aux_vldfolha = aux_vldfolha + crapavs.vllanmto - crapavs.vldebito.
    ELSE
    IF   CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
         aux_vldfolha = aux_vldfolha - (crapavs.vllanmto - crapavs.vldebito).
    ELSE
         DO:
             glb_cdcritic = 83.
             aux_flgerros = TRUE.
             LEAVE.
         END.

    IF   par_flgextra   THEN
         DO:
             CREATE crawext.
             ASSIGN crawext.dtmvtolt = crapavs.dtdebito

                    crawext.dshistor = craphis.dshistor

                    crawext.nrdocmto = STRING(crapavs.nrdocmto,"zz,zzz,zz9")

                    crawext.indebcre = craphis.indebcre

                    crawext.vllanmto = crapavs.vllanmto - crapavs.vldebito.
         END.

END.  /*  Fim do FOR EACH -- Leitura dos avisos */

FOR EACH crapseg WHERE crapseg.cdcooper  = glb_cdcooper         AND
                       crapseg.nrdconta  = tel_nrdconta         AND
                       crapseg.tpseguro <> 4                    AND 
                       crapseg.indebito  = 0                    AND
                       crapseg.cdsitseg  = 1                    AND
                 MONTH(crapseg.dtdebito) = MONTH(glb_dtmvtolt)  AND
                   DAY(crapseg.dtdebito) > 1                    AND
                   DAY(crapseg.dtdebito) < 11                   NO-LOCK:

    IF   par_flgextra THEN
         DO:

             CREATE crawext.
             ASSIGN crawext.dtmvtolt = crapseg.dtdebito

                    crawext.dshistor = IF crapseg.tpseguro = 1
                                          THEN "SEGURO CASA"
                                          ELSE IF crapseg.tpseguro = 2 
                                                  THEN "SEGURO AUTO"
                                                  ELSE "SEGURO VIDA"

                    crawext.nrdocmto = STRING(crapseg.nrctrseg,"zz,zzz,zz9")

                    crawext.indebcre = "D"

                    crawext.vllanmto = crapseg.vlpreseg.
         END.

    aux_vldfolha = aux_vldfolha - crapseg.vlpreseg.

END.  /* FOR EACH SEGURO */

FOR EACH craprpp WHERE craprpp.cdcooper = glb_cdcooper          AND
                       craprpp.nrdconta = tel_nrdconta          AND
                      (craprpp.cdsitrpp = 1                      OR
                      (craprpp.cdsitrpp = 2                     AND
                       craprpp.dtrnirpp = craprpp.dtdebito))    AND
                   DAY(craprpp.dtdebito) < 11                   AND
                 MONTH(craprpp.dtdebito) = MONTH(glb_dtmvtolt)  NO-LOCK:

    IF   par_flgextra THEN
         DO:

             CREATE crawext.
             ASSIGN crawext.dtmvtolt = craprpp.dtdebito

                    crawext.dshistor = "DB.POUP.PROGR"

                    crawext.nrdocmto = STRING(craprpp.nrctrrpp,"zz,zzz,zz9")

                    crawext.indebcre = "D"

                    crawext.vllanmto = craprpp.vlprerpp.
         END.

    aux_vldfolha = aux_vldfolha - craprpp.vlprerpp.

END. /* FOR EACH POUPANCA PROGRAMADA */

IF   aux_flgerros   THEN
     DO:
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

IF   par_flgextra   THEN
     RUN fontes/atenda_e.p.
/* .......................................................................... */

