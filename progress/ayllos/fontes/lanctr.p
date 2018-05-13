/* .............................................................................

   Programa: Fontes/lanctr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                       Ultima atualizacao: 13/03/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCTR.

   Alteracles: 01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               19/01/99 - Acessar a tabela do IOF (Deborah).

               13/11/03 - Incluido campo Nivel Risco(Mirtes).

               22/06/2004 - Retirado a opcao "A"(Devido a implementacao do
                            Cadastro do Avalistas Terceiros)(Mirtes)

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               25/06/2009 - Adicionar as leituras da craptab para emprestimos
                            atrelados a emissao de boletos (Fernando).
                            
               28/04/2010 - Inclusao da funcao K (Gati - Daniel)             

			   13/03/2012 - Implementado critica para os novos numeros de
                            lote (Tiago).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanctr.i "NEW" }

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0134 AS HANDLE                                       NO-UNDO.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_nrdconta = 0
       tel_nrctremp = 0
       tel_cdfinemp = 0
       tel_cdlcremp = 0
       tel_vlemprst = 0
       tel_vlpreemp = 0
       tel_qtpreemp = 0
       tel_nrctaav1 = 0
       tel_nrctaav2 = 0
       tel_avalist1 = " "
       tel_avalist2 = " "
       tel_nrseqdig = 1
       tel_dtmvtolt = glb_dtmvtolt
       aux_flgretor = FALSE.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt
        tel_nrdolote tel_nrdconta tel_nrctremp tel_cdfinemp
        tel_cdlcremp tel_vlemprst tel_vlpreemp tel_qtpreemp
        tel_nrctaav1 tel_nrctaav2 tel_nrseqdig tel_avalist1
        tel_avalist2
        WITH FRAME f_lanctr.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.


      UPDATE glb_cddopcao 
             WITH FRAME f_lanctr.

      IF   glb_cddopcao  = "K" THEN
           UPDATE tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
                  WITH FRAME f_lanctr.
      ELSE
          DO:
              ASSIGN  tel_dtmvtolt = glb_dtmvtolt.
              UPDATE tel_cdagenci tel_cdbccxlt tel_nrdolote
                     WITH FRAME f_lanctr.
          END.

      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "lanctr"   THEN
                 DO:
                     HIDE FRAME f_lanctr.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   ASSIGN aux_dtmvtolt = tel_dtmvtolt
          aux_cdagenci = tel_cdagenci
          aux_cdbccxlt = tel_cdbccxlt
          aux_nrdolote = tel_nrdolote
          aux_flgretor = TRUE.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   /*  Tabela com a taxa do IOF */

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND 
                      craptab.nmsistem = "CRED"             AND
                      craptab.tptabela = "USUARI"           AND
                      craptab.cdempres = 11                 AND
                      craptab.cdacesso = "CTRIOFEMPR"       AND
                      craptab.tpregist = 1 USE-INDEX craptab1 NO-LOCK NO-ERROR.

   IF  CAN-DO("I,E,A",glb_cddopcao) THEN
       DO:
       
            RUN sistema/generico/procedures/b1wgen0134.p
                             PERSISTENT SET h-b1wgen0134.

            RUN valida_lote_emprst_tipo1 IN h-b1wgen0134
                                        (INPUT glb_cdcooper,
                                         INPUT glb_cdagenci,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT tel_nrdolote,
                                         OUTPUT TABLE tt-erro).
                         
            DELETE PROCEDURE h-b1wgen0134.
                                                           
            IF  RETURN-VALUE = "OK"   THEN
                DO:

                    ASSIGN glb_cdcritic = 261.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    NEXT.
                         
                END.
       END.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 626.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
   
   ASSIGN tab_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                              INT(SUBSTRING(craptab.dstextab,1,2)),
                              INT(SUBSTRING(craptab.dstextab,7,4)))
          tab_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                              INT(SUBSTRING(craptab.dstextab,12,2)),
                              INT(SUBSTRING(craptab.dstextab,18,4)))
          tab_txiofepr = DECIMAL(SUBSTR(craptab.dstextab,23,16)).
   
   IF   glb_dtmvtolt >= tab_dtiniiof AND
        glb_dtmvtolt <= tab_dtfimiof THEN
        .
   ELSE
        tab_txiofepr = 0.
       
   /* Pega o numero da conta para emprestimos com emissao de boletos */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "GENERI"     AND
                      craptab.cdempres = 00           AND
                      craptab.cdacesso = "CTAEMISBOL" AND
                      craptab.tpregist = 0 NO-LOCK NO-ERROR.
                                     
   IF  AVAILABLE craptab  THEN
       ASSIGN tab_nrctabol = INT(craptab.dstextab).
   ELSE
       ASSIGN tab_nrctabol = 0.

   /* Pega a linha de credito para emprestimos com emissao de boletos */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "GENERI"     AND
                      craptab.cdempres = 00           AND
                      craptab.cdacesso = "LCREMISBOL" AND
                      craptab.tpregist = 0 NO-LOCK NO-ERROR.
                     
   IF   AVAILABLE craptab   THEN
        ASSIGN tab_cdlcrbol = INT(craptab.dstextab).
   ELSE
        ASSIGN tab_cdlcrbol = 0.

   /*====Retirado
   IF   glb_cddopcao = "A" THEN
        DO:
            RUN fontes/lanctra.p.   
        END.
   ELSE
   =======*/
   
   IF   glb_cddopcao = "C" THEN
        DO:
            RUN fontes/lanctrc.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            RUN fontes/lanctre.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            RUN fontes/lanctri.p.
        END.
   ELSE
   IF   glb_cddopcao = "K"   THEN
        DO:
            RUN fontes/lanctrk.p.
        END.
   

   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_lanctr.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
END.

/* .......................................................................... */

