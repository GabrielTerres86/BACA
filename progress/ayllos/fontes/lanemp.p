/* .............................................................................

   Programa: Fontes/lanemp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 13/03/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANEMP.

   Alteracoes: 21/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               20/11/96 - Alterar a mascara do campo nrctremp (Odair).

               29/01/97 - Alterar ordem dos campos contrato e documento (Odair).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               12/03/01 - INcluir tratamento do boletim caixa (Margarete).
               
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               06/07/2009 - Adicionado FIND na craptab para buscar a linha de
                            credito dos emprestimos com emissao de boletos
                            (Fernando).
                          - Comentado alteracao do Fernando (Guilherme).
                          
               13/03/2012 - Implementado critica para novos numeros de
                            lotes (Tiago).           
............................................................................. */

{ includes/var_online.i }
{ includes/var_lanemp.i "NEW" }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0134 AS HANDLE                                       NO-UNDO.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_cdhistor = 0
       tel_nrdconta = 0
       tel_nrctremp = 0
       tel_nrdocmto = 0
       tel_vllanmto = 0
       tel_nrseqdig = 1
       tel_dtmvtolt = glb_dtmvtolt
       aux_flgretor = FALSE.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt
        tel_nrdolote tel_cdhistor tel_nrdconta tel_nrdocmto
        tel_nrctremp tel_vllanmto tel_nrseqdig
        WITH FRAME f_lanemp.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor
      AND  glb_cdcritic = 0   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      ASSIGN glb_cdcritic = 0.
      
      UPDATE glb_cddopcao tel_cdagenci tel_cdbccxlt tel_nrdolote
             WITH FRAME f_lanemp.

      /*Tiago*/
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
    
              IF RETURN-VALUE = "OK"   THEN
                 DO:
    
                     ASSIGN glb_cdcritic = 261.
                     RUN fontes/critic.p.
                     DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                             tel_cdbccxlt tel_nrdolote 
                             WITH FRAME f_lanemp.
                     MESSAGE glb_dscritic.
                     NEXT.
    
                 END.
            
          END.

      IF   glb_cddopcao <> "C"   AND
           tel_cdbccxlt = 11     AND
           tel_cdagenci <> 11    THEN  /* boletim de caixa -   EDSON PAC1 */ 
           DO:
               FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                  craplot.dtmvtolt = glb_dtmvtolt   AND
                                  craplot.cdagenci = tel_cdagenci   AND
                                  craplot.cdbccxlt = tel_cdbccxlt   AND
                                  craplot.nrdolote = tel_nrdolote
                                  NO-LOCK NO-ERROR.
                                  
               IF   NOT AVAILABLE craplot   THEN
                    DO: 
                        ASSIGN glb_cdcritic = 60. 
                        RUN fontes/critic.p.
                        BELL.
                        DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                                tel_cdbccxlt tel_nrdolote 
                                WITH FRAME f_lanemp.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               IF   craplot.nrdcaixa > 0   THEN
                    DO:
                        FIND LAST crapbcx WHERE 
                                  crapbcx.cdcooper = glb_cdcooper       AND
                                  crapbcx.dtmvtolt = glb_dtmvtolt       AND
                                  crapbcx.cdagenci = craplot.cdagenci   AND
                                  crapbcx.nrdcaixa = craplot.nrdcaixa   AND
                                  crapbcx.cdopecxa = craplot.cdopecxa   NO-LOCK
                                  USE-INDEX crapbcx2 NO-ERROR.
                        
                        IF   NOT AVAILABLE crapbcx    THEN
                             DO:
                                 ASSIGN glb_cdcritic = 701. 
                                 RUN fontes/critic.p.
                                 BELL.
                                 DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                                         tel_cdbccxlt tel_nrdolote 
                                         WITH FRAME f_lanemp.
                                 MESSAGE glb_dscritic.
                                 NEXT.
                             END.
                        ELSE
                        IF   crapbcx.cdsitbcx = 2   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 698.
                                 RUN fontes/critic.p.
                                 BELL.
                                 DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                                         tel_cdbccxlt tel_nrdolote 
                                         WITH FRAME f_lanemp.
                                 MESSAGE glb_dscritic.
                                 NEXT.
                             END.
                    END.
           END.
 
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANEMP"   THEN
                 DO:
                     HIDE FRAME f_lanemp.
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

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "USUARI"       AND
                      craptab.cdempres = 11             AND
                      craptab.cdacesso = "TAXATABELA"   AND
                      craptab.tpregist = 0              NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        tab_inusatab = FALSE.
   ELSE
        tab_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                          THEN FALSE
                          ELSE TRUE.

   /* Comentado por Guilherme antes mesmo de ser liberado 
   /* Busca linha de credito para emprestimos atrelados a emissao de boeltos */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "GENERI"     AND
                      craptab.cdempres = 00           AND
                      craptab.cdacesso = "LCREMISBOL" AND
                      craptab.tpregist = 0 NO-LOCK NO-ERROR.
                                 
   IF   NOT AVAILABLE craptab   THEN
        ASSIGN tab_cdlcrbol = 0.
   ELSE
        ASSIGN tab_cdlcrbol = INTEGER(craptab.dstextab).
   Comentario */        
   
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO:
            RUN fontes/lanempa.p.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            RUN fontes/lanempc.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            RUN fontes/lanempe.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            RUN fontes/lanempi.p.
        END.

   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_lanemp.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
END.

/* .......................................................................... */
