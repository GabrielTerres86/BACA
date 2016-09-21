/*.............................................................................
  
   Programa: Fontes/rdcapp_c.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                        Ultima atualizacao: 21/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da consulta da poupanca programada.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               16/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               22/09/2004 - Aumentado campo nro poupanca prog.(Mirtes)

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               24/04/2008 - Data de vencimento e cdsitrpp = 5 (Guilherme).
               
               24/07/2008 - Solicita data inicial e data final para o periodo 
                            do extrato e mostra o saldo anterior da poupanca
                            (Elton).
               
               06/01/2009 - Mostra somente os lancamentos em que a data for
                            maior do que a data inicial informada (Elton).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               23/11/2009 - Alteracao Codigo Historico (Kbase). 
               
               28/04/2010 - Passar para um browse dinamico.
                            Utilizar a b1wgen0006  (Gabriel).
                            
               21/06/2011 - Alterada flag de log de FALSE  p/ TRUE
                            em BO b1wgen0006 (Jorge).
............................................................................. */

DEF INPUT PARAM par_nrctrrpp AS INTE                               NO-UNDO.                                                     
                                                     
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i }

{ sistema/generico/includes/var_internet.i }

DEF VAR aux_listahis AS CHAR                                       NO-UNDO.

DEF VAR h-b1wgen0006 AS HANDLE                                     NO-UNDO.

DEF VAR aux_vlsdrpp  AS DECI                                       NO-UNDO.
DEF VAR aux_flgretor AS LOGI                                       NO-UNDO.
DEF VAR aux_contareg AS INTE                                       NO-UNDO.


FORM tt-extr-rpp.dtmvtolt AT  2 LABEL "   Data"
     tt-extr-rpp.dshistor AT 14 LABEL "Historico"  FORMAT "x(26)"
     tt-extr-rpp.nrdocmto AT 42 LABEL " Documento" FORMAT "zzz,zzz,zz9"
     tt-extr-rpp.indebcre AT 54 LABEL "D/C"
     tt-extr-rpp.vllanmto AT 58 LABEL "Valor"
     WITH ROW 9 CENTERED OVERLAY 9 DOWN TITLE " Extrato " FRAME f_lanctos.

TRANS_POUP:

DO WHILE TRUE ON ERROR UNDO, LEAVE:

   RUN sistema/generico/procedures/b1wgen0006.p
                        PERSISTENT SET h-b1wgen0006.

   RUN consulta-poupanca IN h-b1wgen0006 (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_nmdatela,
                                          INPUT 1, /* Origem*/
                                          INPUT tel_nrdconta,
                                          INPUT 1, /* Titular */
                                          INPUT par_nrctrrpp,
                                          INPUT glb_dtmvtolt,
                                          INPUT glb_dtmvtopr,
                                          INPUT glb_inproces,
                                          INPUT glb_cdprogra,
                                          INPUT TRUE,
                                          OUTPUT aux_vlsdrpp,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-dados-rpp).
   DELETE PROCEDURE h-b1wgen0006.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro  THEN
                MESSAGE tt-erro.dscritic.

            RETURN.
        END.
       
   FIND FIRST tt-dados-rpp NO-LOCK NO-ERROR.

   IF   NOT AVAIL tt-dados-rpp   THEN
        RETURN.

   ASSIGN tel_dsaplica = " Poupanca Programada " +
                      TRIM(STRING(par_nrctrrpp,"z,zzz,zz9")) +
                         "-Dia " + STRING(DAY(tt-dados-rpp.dtdebito),"99") + " "

          tel_dspesrpp = STRING(tt-dados-rpp.dtmvtolt,"99/99/9999") + "-" +
                         STRING(tt-dados-rpp.cdagenci,"999") + "-" +
                         STRING(tt-dados-rpp.cdbccxlt,"999") + "-" +
                         STRING(tt-dados-rpp.nrdolote,"999999")

          tel_vlprerpp = tt-dados-rpp.vlprerpp
          tel_qtprerpp = tt-dados-rpp.qtprepag
          tel_vlprepag = tt-dados-rpp.vlprepag
          tel_vljuracu = tt-dados-rpp.vljuracu
          tel_vlrgtacu = tt-dados-rpp.vlrgtacu
          tel_dtinirpp = tt-dados-rpp.dtinirpp
          tel_dtrnirpp = tt-dados-rpp.dtrnirpp
          tel_dtaltrpp = tt-dados-rpp.dtaltrpp
          tel_dtdebito = tt-dados-rpp.dtdebito
          tel_dtcancel = tt-dados-rpp.dtcancel
          tel_dtvctopp = tt-dados-rpp.dtvctopp
          tel_dssitrpp = tt-dados-rpp.dssitrpp          
          tel_vlsdrdpp = tt-dados-rpp.vlsdrdpp.
  
   IF   tt-dados-rpp.dsmsgsaq <> ""   THEN
        DO:
            tel_dsmensaq = tt-dados-rpp.dsmsgsaq.

            COLOR DISPLAY MESSAGE tel_dsmensaq WITH FRAME f_rdcapp.
        END.
   ELSE
        DO:
            tel_dsmensaq = "".
        END.

   DISPLAY tel_vlprerpp tel_qtprerpp tel_vlprepag tel_vljuracu
           tel_vlrgtacu tel_vlsdrdpp tel_dtinirpp tel_dtrnirpp
           tel_dtaltrpp tel_dtdebito tel_dtcancel tel_dspesrpp
           tel_dssitrpp tel_extratos tel_dsmensaq tel_dtvctopp
           WITH FRAME f_rdcapp.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic <> 0   THEN
           DO:
               RUN fontes/critic.p.
               glb_cdcritic = 0.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               HIDE FRAME f_lanctos.
               BELL.
               MESSAGE glb_dscritic.     
               PAUSE 2 NO-MESSAGE.
               HIDE MESSAGE NO-PAUSE.
           END.

      CHOOSE FIELD tel_extratos WITH FRAME f_rdcapp.

      IF   FRAME-VALUE = tel_extratos   THEN
           DO:
               ASSIGN  aux_dtpesqui = tt-dados-rpp.dtinirpp 
                       aux_dtafinal = glb_dtmvtolt.
               
               /* Se a data inicial eh maior que a final */
               IF   aux_dtpesqui > aux_dtafinal  THEN
                    aux_dtafinal  = aux_dtpesqui.

               DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
                   UPDATE aux_dtpesqui                 
                          aux_dtafinal WITH FRAME f_data_poup.  
                   LEAVE.
               END.
               
               HIDE FRAME f_data_poup.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    NEXT.

               RUN sistema/generico/procedures/b1wgen0006.p
                                    PERSISTENT SET h-b1wgen0006.

               RUN consulta-extrato-poupanca IN h-b1wgen0006 
                                            (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT 1, /* Origem */
                                             INPUT tel_nrdconta,
                                             INPUT 1, /* Titular */
                                             INPUT par_nrctrrpp,
                                             INPUT aux_dtpesqui,
                                             INPUT aux_dtafinal,
                                             INPUT TRUE,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-extr-rpp).

               DELETE PROCEDURE h-b1wgen0006.
               
               IF   RETURN-VALUE <> "OK"   THEN
                    DO: 
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF   AVAIL tt-erro   THEN
                             MESSAGE tt-erro.dscritic.

                        NEXT.
                    END.

               IF   NOT CAN-FIND (FIRST tt-extr-rpp)  THEN
                    DO:            
                        glb_cdcritic = 81.
                        NEXT.
                    END.

               ASSIGN aux_contareg = 0
                      aux_flgretor = FALSE.

               CLEAR FRAME f_lanctos ALL NO-PAUSE.
                
               FOR EACH tt-extr-rpp NO-LOCK:
                                            
                   aux_contareg = aux_contareg + 1.

                   IF   aux_contareg = 1   AND
                        aux_flgretor       THEN
                        DO:
                            PAUSE MESSAGE
                               "Tecle <Entra> para continuar ou <Fim> para encerrar.".
                            CLEAR FRAME f_lanctos ALL NO-PAUSE.
                        END.

                   PAUSE 0.

                   IF   tt-extr-rpp.dtmvtolt = 01/01/9999   THEN
                        DISPLAY "FOLHA" @ tt-extr-rpp.dtmvtolt
                                          tt-extr-rpp.dshistor
                                          tt-extr-rpp.nrdocmto 
                                          tt-extr-rpp.indebcre 
                                          tt-extr-rpp.vllanmto
                                          WITH FRAME f_lanctos.
                   ELSE
                        DISPLAY tt-extr-rpp.dtmvtolt
                                tt-extr-rpp.dshistor
                                tt-extr-rpp.nrdocmto 
                                tt-extr-rpp.indebcre
                                tt-extr-rpp.vllanmto
                                WITH FRAME f_lanctos.

                   IF   aux_contareg = 9   THEN
                        ASSIGN aux_contareg = 0
                               aux_flgretor = TRUE.
                   ELSE
                        DOWN WITH FRAME f_lanctos.

               END.  /* Fim da Listagem */

           END. /* Fim Opcao Extrato */

   END.  /*  Fim do DO WHILE TRUE  */

   HIDE FRAME f_rdcapp NO-PAUSE.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_lanctos.
HIDE FRAME f_rdcapp NO-PAUSE.
HIDE MESSAGE NO-PAUSE.


/* .......................................................................... */
