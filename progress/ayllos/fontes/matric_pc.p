/* .............................................................................

   Programa: Fontes/matric_pc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2004.                         Ultima atualizacao:14/07/2010
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para parcelamento do capital subscrito. Chamado pela 
               tela MATRIC.
               
   Alteracoes: 04/07/2005 - Alimentado campo cdcooper da tabela crapsdc (Diego).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks -
                            Eder
                            
               14/07/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0052tt.i }
{ includes/var_online.i }
{ includes/var_matric.i }

DEF  INPUT PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF  INPUT PARAM par_tptransa AS INT                                 NO-UNDO.
DEF OUTPUT PARAM tel_dtdebito AS DATE                                NO-UNDO.
DEF OUTPUT PARAM tel_vlparcel AS DECIMAL                             NO-UNDO.
DEF OUTPUT PARAM tel_qtparcel AS INT                                 NO-UNDO.

DEF VAR tel_dsparcel AS CHAR    EXTENT 4                             NO-UNDO.

DEF VAR aux_contareg AS INT                                          NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                         NO-UNDO.
DEF VAR hb1wgen0052p AS HANDLE                                       NO-UNDO.

/* ......................................................................... */

FORM SKIP(1)
     tel_dtdebito AT  2 LABEL "Iniciar em" FORMAT "99/99/9999"
     tel_vlparcel AT 26 LABEL "Valor a parcelar" FORMAT "zzz,zz9.99"
     tel_qtparcel AT 56 LABEL "Qtd. de parcelas" FORMAT "z9"
     SKIP(1)
     tel_dsparcel[1] AT  1 NO-LABEL FORMAT "x(72)"
     SKIP
     tel_dsparcel[2] AT  1 NO-LABEL FORMAT "x(72)"
     SKIP
     tel_dsparcel[3] AT  1 NO-LABEL FORMAT "x(72)"
     SKIP
     tel_dsparcel[4] AT  1 NO-LABEL FORMAT "x(72)"
     SKIP(1)
     WITH ROW 11 COLUMN 2 SIDE-LABELS OVERLAY WIDTH 78 
          TITLE " Parcelamento do Capital " FRAME f_plano.

/* ......................................................................... */
IF  NOT VALID-HANDLE(hb1wgen0052p) THEN
    RUN sistema/generico/procedures/b1wgen0052v.p
        PERSISTENT SET hb1wgen0052p.

RUN Calcula_Parcelamento .

IF  RETURN-VALUE <> "OK" THEN
    RETURN.

ASSIGN aux_confirma = "N".

IF  par_tptransa = 1   THEN     /*  Cria SUBSC. CAPITAL/PLANO PARCELAMENTO  */
    DO:
        IF   tel_qtparcel > 0   THEN           /*  Parcelamento do capital  */
             DO:
                 DO WHILE TRUE:
                 
                    HIDE MESSAGE NO-PAUSE.

                    PAUSE 0.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                       UPDATE tel_dtdebito tel_vlparcel tel_qtparcel 
                              WITH FRAME f_plano
                       EDITING:
                          READKEY.
                          HIDE MESSAGE NO-PAUSE.

                          APPLY LASTKEY.
                       END.
                       
                       ASSIGN tel_dsparcel = "".

                       RUN Valida_Parcelamento.

                       IF  RETURN-VALUE <> "OK" THEN
                           NEXT.

                       FOR EACH tt-parccap BY tt-parccap.nrseqdig:

                           IF  tt-parccap.nrseqdig > 0 AND 
                               tt-parccap.nrseqdig < 4 THEN
                               ASSIGN aux_contareg = 1.
                           ELSE
                           IF  tt-parccap.nrseqdig > 3 AND   
                               tt-parccap.nrseqdig < 7 THEN
                               ASSIGN aux_contareg = 2.
                           ELSE
                           IF  tt-parccap.nrseqdig > 6 AND   
                               tt-parccap.nrseqdig < 10 THEN
                               ASSIGN aux_contareg = 3.
                           ELSE
                           IF  tt-parccap.nrseqdig > 9 AND   
                               tt-parccap.nrseqdig < 13  THEN
                               ASSIGN aux_contareg = 4.

                           ASSIGN tel_dsparcel[aux_contareg] = 
                               tel_dsparcel[aux_contareg] + "   " +
                               STRING(tt-parccap.dtrefere,"99/99/9999") + " " 
                               + STRING(tt-parccap.vlparcel,"zzz,zz9.99").

                       END. /* FOR EACH tt-parccap  */

                       LEAVE.
                    
                    END.  /*  Fim do DO WHILE TRUE  */
                                  
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        DO:
                           IF  glb_cdcooper = 6   THEN
                               DO:
                                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                                      aux_confirma = "N".
                                      HIDE MESSAGE NO-PAUSE.
                                      
                                      MESSAGE "ATENCAO! Nao sera criado"
                                              "o plano de subscricao de"
                                              "capital!".
                                            
                                      glb_cdcritic = 78.
                                      RUN fontes/critic.p.
                                      BELL.
                                      MESSAGE COLOR NORMAL glb_dscritic 
                                                    UPDATE aux_confirma.
                                      LEAVE.
    
                                   END.  /*  Fim do DO WHILE TRUE  */
    
                                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                        aux_confirma <> "S" THEN
                                        DO:
                                            HIDE MESSAGE NO-PAUSE.
                                            NEXT.
                                        END.
                                   
                                   glb_cdcritic = 0.
                                   RETURN.
                               END.
                           ELSE
                               NEXT.
                        END.
                    
                    DISPLAY tel_dsparcel WITH FRAME f_plano.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       aux_confirma = "N".

                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       LEAVE.

                    END.

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             NEXT.
                         END.
                    
                    LEAVE.
                 
                 END.  /*  Fim do DO WHILE TRUE  */
                 
                 HIDE FRAME f_plano NO-PAUSE.
             END.
    END. /* IF  par_tptransa = 1 */

IF  VALID-HANDLE(hb1wgen0052p) THEN
    DELETE OBJECT hb1wgen0052p.

IF  aux_confirma <> "S" THEN
    ASSIGN
        tel_dtdebito = ?
        tel_qtparcel = 0
        tel_vlparcel = 0.

/* ......................................................................... */

PROCEDURE Calcula_Parcelamento:

    RUN Calcula_Parcelamento IN hb1wgen0052p
        ( INPUT glb_cdcooper, 
          INPUT tel_nrcpfcgc,
         OUTPUT tel_qtparcel,
         OUTPUT tel_vlparcel,
         OUTPUT glb_cdcritic,
         OUTPUT glb_dscritic ) NO-ERROR .

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
           IF  glb_cdcritic <> 0 THEN
               RUN fontes/critic.p.

           MESSAGE glb_dscritic.
           RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Parcelamento:

    EMPTY TEMP-TABLE tt-parccap.

    RUN Valida_Parcelamento IN hb1wgen0052p
        ( INPUT glb_cdcooper, 
          INPUT glb_dtmvtolt,
          INPUT tel_dtdebito,
          INPUT tel_qtparcel,
          INPUT tel_vlparcel,
         OUTPUT aux_msgretor,
         OUTPUT glb_cdcritic,
         OUTPUT glb_dscritic,
         OUTPUT TABLE tt-parccap ) NO-ERROR .

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
           IF  glb_cdcritic <> 0 THEN
               RUN fontes/critic.p.

           MESSAGE glb_dscritic.
           RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.
