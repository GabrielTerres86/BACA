/* .............................................................................

   Programa: Includes/gt0004c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                    Ultima Atualizacao: 02/08/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Consulta Controle Execucao(Generico)
             - Integracao Arquivo Debito Automatico

   Alteracoes: 22/06/2012 - Substituido gncoper por crapcop (Tiago).          
   
               02/08/2012 - Corrigido problemas da tela gt0004 (Tiago). 
               
               02/08/2012 - Criado procedure para calcula dos totais 
                            f_convenioc (Tiago).
............................................................................. */

IF   tel_dtmvtolt <> ? AND   
     tel_cdcooper <> 0 AND 
     tel_cdconven <> 0 THEN
     DO:

         FIND gncontr NO-LOCK  WHERE
              gncontr.cdcooper = tel_cdcooper  AND
              gncontr.tpdcontr = 3             AND  /* Int.Arq.Debito Autom.*/
              gncontr.cdconven = tel_cdconven  AND
              gncontr.dtmvtolt = tel_dtmvtolt NO-ERROR NO-WAIT.

         IF   AVAILABLE gncontr   THEN
              DO:
                
                ASSIGN tel_nmrescop = " ".
                FIND first crapcop NO-LOCK WHERE
                           crapcop.cdcooper = tel_cdcooper NO-ERROR.
                IF  AVAIL crapcop THEN
                    ASSIGN tel_nmrescop = crapcop.nmrescop.
                
                ASSIGN  tel_cdcooper = gncontr.cdcooper  
                        tel_cdconven = gncontr.cdconven  
                        tel_dtmvtolt = gncontr.dtmvtolt.

                ASSIGN  tel_dtcredit   = gncontr.dtcredit   
                        tel_nmarquiv   = gncontr.nmarquiv 
                        tel_qtdoctos   = gncontr.qtdoctos  
                        tel_vldoctos   = gncontr.vldoctos  
                        tel_vltarifa   = gncontr.vltarifa
                        tel_vlapagar   = gncontr.vlapagar    
                        tel_nrsequen   = gncontr.nrsequen .
                      
                ASSIGN  tel_cdcopdom   = 0
                        tel_nrcnvfbr   = ""
                        tel_nmempres   = "".
                FIND gnconve NO-LOCK WHERE
                     gnconve.cdconve = gncontr.cdconven AND 
                     gnconve.flgativo = TRUE NO-ERROR.
                IF  AVAIL gnconve THEN
                    ASSIGN  tel_cdcopdom   = gnconve.cdcooper
                            tel_nrcnvfbr   = gnconve.nrcnvfbr
                            tel_nmempres   = gnconve.nmempres.
               
                DISPLAY tel_cdcooper   
                        tel_cdconven   
                        tel_dtmvtolt 
                        tel_dtcredit 
                        tel_nmarquiv 
                        tel_qtdoctos
                        tel_vldoctos
                        tel_vltarifa  
                        tel_vlapagar 
                        tel_nrsequen
                        tel_nmrescop
                        tel_cdcopdom
                        tel_nrcnvfbr
                        tel_nmempres
                        WITH FRAME f_convenio.
              END.
         ELSE
              DO:
                  ASSIGN glb_cdcritic = 563. /* Convenio nao Cadastrado */
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  CLEAR FRAME f_convenio.
                  DISPLAY tel_cdconven WITH FRAME f_convenio.
                  ASSIGN glb_cdcritic = 0
                         glb_dscritic = "".
                  NEXT.
              END.
     END.
ELSE
     DO:
        DISPLAY " " @ tel_dtcredit 
                " " @ tel_nmarquiv 
                " " @ tel_qtdoctos
                " " @ tel_vldoctos
                " " @ tel_vltarifa  
                " " @ tel_vlapagar 
                " " @ tel_nrsequen
                " " @ tel_nmrescop
                " " @ tel_cdcopdom
                " " @ tel_nrcnvfbr
                " " @ tel_nmempres 
                WITH FRAME f_convenio.
         PAUSE(0).
         
         RUN soma_totais(INPUT  tel_cdcooper,
                         INPUT  tel_dtmvtolt,
                         INPUT  tel_cdconven,
                         OUTPUT tel_totqtdoc,
                         OUTPUT tel_totvldoc,
                         OUTPUT tel_tottarif,
                         OUTPUT tel_totpagar).

         IF  tel_cdconven <> 0 THEN
             DO:   
                 OPEN QUERY bgncontrq 
                       FOR EACH gncontr NO-LOCK WHERE
                                gncontr.dtmvtolt = tel_dtmvtolt AND
                                gncontr.cdconven = tel_cdconven AND
                                gncontr.tpdcontr = 3, 
                       FIRST gnconve NO-LOCK WHERE
                             gnconve.cdconven = gncontr.cdconven AND
                             gnconve.flgativo = TRUE
                          BY gncontr.cdcooper
                          BY gncontr.cdconven
                          BY gncontr.dtmvtolt.
             END.
         ELSE
             DO:
                IF  tel_cdcooper <> 0 THEN
                    DO:
                        OPEN QUERY bgncontrq 
                              FOR EACH gncontr NO-LOCK WHERE
                                       gncontr.dtmvtolt = tel_dtmvtolt AND
                                       gncontr.cdcooper = tel_cdcooper AND
                                       gncontr.tpdcontr = 3, 
                              FIRST gnconve NO-LOCK WHERE
                                    gnconve.cdconven = gncontr.cdconven AND
                                    gnconve.flgativo = TRUE
                                 BY gncontr.cdcooper
                                 BY gncontr.cdconven
                                 BY gncontr.dtmvtolt.
                    END.
                ELSE
                    DO:
                        OPEN QUERY bgncontrq 
                              FOR EACH gncontr NO-LOCK WHERE
                                       gncontr.dtmvtolt = tel_dtmvtolt AND
                                       gncontr.tpdcontr = 3, 
                              FIRST gnconve NO-LOCK WHERE
                                    gnconve.cdconven = gncontr.cdconven AND
                                    gnconve.flgativo = TRUE
                                 BY gncontr.cdcooper
                                 BY gncontr.cdconven
                                 BY gncontr.dtmvtolt.
                    END.
             END.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            DISPLAY tel_totqtdoc 
                    tel_totvldoc
                    tel_tottarif
                    tel_totpagar
                    WITH FRAME f_convenioc. 
            UPDATE bgncontr-b WITH FRAME f_convenioc. 
            LEAVE.
         END.

     END.

HIDE FRAME f_convenioc.

/* .......................................................................... */

PROCEDURE soma_totais:

    DEF INPUT  PARAM par_cdcooper    AS  INTE                NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS  DATE                NO-UNDO.
    DEF INPUT  PARAM par_cdconven    AS  INTE                NO-UNDO.

    DEF OUTPUT PARAM par_totqtdoc    AS  DECI                NO-UNDO.
    DEF OUTPUT PARAM par_totvldoc    AS  DECI                NO-UNDO.
    DEF OUTPUT PARAM par_tottarif    AS  DECI                NO-UNDO.
    DEF OUTPUT PARAM par_totpagar    AS  DECI                NO-UNDO.

    ASSIGN par_totqtdoc = 0
           par_totvldoc = 0
           par_tottarif = 0
           par_totpagar = 0.

    IF  par_cdconven <> 0 THEN
        DO:

            FOR EACH b-gncontr NO-LOCK WHERE
                     b-gncontr.dtmvtolt = par_dtmvtolt AND
                     b-gncontr.cdconven = par_cdconven AND
                     b-gncontr.tpdcontr = 3, 
            FIRST gnconve NO-LOCK WHERE
                  gnconve.cdconven = b-gncontr.cdconven AND 
                  gnconve.flgativo = TRUE
               BY b-gncontr.cdcooper
               BY b-gncontr.cdconven
               BY b-gncontr.dtmvtolt:

                ASSIGN par_totqtdoc = par_totqtdoc + b-gncontr.qtdoctos
                       par_totvldoc = par_totvldoc + b-gncontr.vldoctos
                       par_tottarif = par_tottarif + b-gncontr.vltarifa
                       par_totpagar = par_totpagar + b-gncontr.vlapagar.
           
            END. 
        END.
    ELSE
        DO:
            IF  par_cdcooper <> 0 THEN
                DO:
                
                    FOR EACH b-gncontr NO-LOCK WHERE
                             b-gncontr.dtmvtolt = par_dtmvtolt AND
                             b-gncontr.cdcooper = par_cdcooper AND
                             b-gncontr.tpdcontr = 3, 
                    FIRST gnconve NO-LOCK WHERE
                          gnconve.cdconven = b-gncontr.cdconven AND 
                          gnconve.flgativo = TRUE
                       BY b-gncontr.cdcooper
                       BY b-gncontr.cdconven
                       BY b-gncontr.dtmvtolt:
    
                        ASSIGN par_totqtdoc = par_totqtdoc + b-gncontr.qtdoctos
                               par_totvldoc = par_totvldoc + b-gncontr.vldoctos
                               par_tottarif = par_tottarif + b-gncontr.vltarifa
                               par_totpagar = par_totpagar + b-gncontr.vlapagar.
                  
                    END. 
                END.
            ELSE
                DO: 

                    FOR EACH b-gncontr NO-LOCK WHERE
                             b-gncontr.dtmvtolt = par_dtmvtolt AND
                             b-gncontr.tpdcontr = 3, 
                    FIRST gnconve NO-LOCK WHERE
                          gnconve.cdconven = b-gncontr.cdconven AND 
                          gnconve.flgativo = TRUE
                       BY b-gncontr.cdcooper
                       BY b-gncontr.cdconven
                       BY b-gncontr.dtmvtolt:
                         
                        ASSIGN par_totqtdoc = par_totqtdoc + b-gncontr.qtdoctos
                               par_totvldoc = par_totvldoc + b-gncontr.vldoctos
                               par_tottarif = par_tottarif + b-gncontr.vltarifa
                               par_totpagar = par_totpagar + b-gncontr.vlapagar.
    
                    END. 
                    
                END.
        END.
     
    RETURN "OK".
END PROCEDURE.
