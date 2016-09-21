/* .............................................................................

   Programa: Fontes/dsctit_bordero_ln.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                       Ultima atualizacao: 27/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para liberar/pre-analisar os borderos de descontos de titulos.

   Alteracoes: 13/07/2009 - Logar analise e liberacao (Guilherme).

               28/06/2010 - Esconder frame f_bordero2 quando BO erro(Guilherme).
               
               05/09/2011 - Incluido a chamada para a procedure alerta_fraude
                            (Adriano).
                            
               23/08/2012 - Adicionado parametro 'nrdconta' na chamada do
                            fonte 'dsctit_bordero_m.p' (Lucas).

               13/11/2012 - Ajuste referente ao projeto GE (Adriano).
               
               26/03/2013 - Ajsutes realizados:
                            - Retirado a chamada da procedure alerta_fraude;
                            - Retirado o tratamento "WHEN 33 " para o 
                              tratamento do tt-msg-confirma.inconfir; 
                            - Ajuste de layout para o frame f_grupo_economico
                           (Adriano).
                           
              10/07/2014 - Alteraçao para utilizaçao da temp table 
                           tt-grupo na include b1wgen0138tt. 
                           (Chamado 130880) - (Tiago Castro - RKAM)

               27/06/2016 - Passagem dos parametros inconfi6, cdopcoan e cdopcoan
                            para efetua_liber_anali_bordero. (Jaison/James)

............................................................................ */

DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0030tt.i }  
{ includes/var_dsctit.i }

DEF VAR aux_inconfir AS INTEGER         NO-UNDO.
DEF VAR aux_inconfi2 AS INTEGER         NO-UNDO.
DEF VAR aux_inconfi3 AS INTEGER         NO-UNDO.
DEF VAR aux_inconfi4 AS INTEGER         NO-UNDO.
DEF VAR aux_inconfi5 AS INTEGER         NO-UNDO.
DEF VAR aux_indentra AS INTEGER         NO-UNDO.
DEF VAR aux_indrestr AS INTEGER         NO-UNDO.

DEF VAR h-b1wgen0030 AS HANDLE  NO-UNDO.

/* .......................................................................... */


DO  WHILE TRUE ON ERROR UNDO, RETURN:

    IF NOT VALID-HANDLE(h-b1wgen0030) THEN
       RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

    IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
        DO:
            MESSAGE "Handle invalido para b1wgen0030".
            RETURN.
        END.

    RUN busca_dados_bordero IN h-b1wgen0030 
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT 1,
                                     INPUT tel_nrdconta,
                                     INPUT par_nrborder,
                                     INPUT par_cddopcao,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dsctit_dados_bordero).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF VALID-HANDLE(h-b1wgen0030) THEN
               DELETE OBJECT h-b1wgen0030.
        
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                       
                    RETURN.
                END.                
            ELSE
                DO:
                    MESSAGE "Bordero nao encontrado".
                            
                    RETURN.
                END.
        END.
    
    FIND FIRST tt-dsctit_dados_bordero NO-LOCK NO-ERROR.

    DISPLAY tt-dsctit_dados_bordero.dspesqui                     
            tt-dsctit_dados_bordero.nrborder 
            tt-dsctit_dados_bordero.nrctrlim 
            tt-dsctit_dados_bordero.dsdlinha      
            tt-dsctit_dados_bordero.qttitulo      
            tt-dsctit_dados_bordero.dsopedig 
            tt-dsctit_dados_bordero.vltitulo      
            tt-dsctit_dados_bordero.txmensal  
            tt-dsctit_dados_bordero.dtlibbdt
            tt-dsctit_dados_bordero.txdiaria  
            tt-dsctit_dados_bordero.dsopelib      
            tt-dsctit_dados_bordero.txjurmor 
            WITH FRAME f_bordero2.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
        ASSIGN glb_cdcritic = 0.
        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S" THEN
        DO:
            IF VALID-HANDLE(h-b1wgen0030) THEN
               DELETE OBJECT h-b1wgen0030.

            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.
            HIDE FRAME f_bordero2.
            RETURN.

        END.
        

    /* Variaveis para controle de mensagens */
    ASSIGN aux_inconfir = 1
           aux_inconfi2 = 11
           aux_inconfi3 = 21
           aux_inconfi4 = 71
           aux_inconfi5 = 30
           aux_indentra = 1
           aux_indrestr = 0.

    DO  WHILE TRUE:

        RUN efetua_liber_anali_bordero IN h-b1wgen0030
                                (INPUT glb_cdcooper,
                                 INPUT 0, /* caixa  */
                                 INPUT 0, /* agenci */
                                 INPUT glb_cdoperad,
                                 INPUT " ", /* cdopcoan */
                                 INPUT " ", /* cdopcolb */
                                 INPUT "ATENDA",
                                 INPUT 1, /* orgigem */
                                 INPUT tel_nrdconta,
                                 INPUT 1, /* idseqttl */
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_dtmvtopr,
                                 INPUT glb_inproces,
                                 INPUT par_nrborder,
                                 INPUT glb_cddopcao,
                                 INPUT aux_inconfir,
                                 INPUT aux_inconfi2,
                                 INPUT aux_inconfi3,
                                 INPUT aux_inconfi4,
                                 INPUT aux_inconfi5,
                                 INPUT 0, /* inconfi6 */
                                 INPUT-OUTPUT aux_indrestr,
                                 INPUT-OUTPUT aux_indentra,
                                 INPUT TRUE, /* LOG */
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-risco,
                                OUTPUT TABLE tt-msg-confirma,
                                OUTPUT TABLE tt-grupo).

        IF RETURN-VALUE <> "OK"  THEN
           DO:
              IF VALID-HANDLE(h-b1wgen0030) THEN
                 DELETE OBJECT h-b1wgen0030.

              /*Se valor legal excedido, mostrara mensagem informando o
                ocorrido e o grupo economico caso a conta em questao
                participe de algum. */
              FIND FIRST tt-msg-confirma WHERE tt-msg-confirma.inconfir = 19
                                               NO-LOCK NO-ERROR.

              IF AVAIL tt-msg-confirma THEN
                 DO:
                    MESSAGE tt-msg-confirma.dsmensag.
                    
                    /*Se a conta em questao faz parte de um grupo 
                      economico, serao listados as contas que se 
                      relacionam com a mesma.*/
                    IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                       DO:                             
                           ASSIGN aux_qtctarel = 0.

                           FOR EACH tt-grupo NO-LOCK:

                               ASSIGN aux_qtctarel = aux_qtctarel + 1.

                           END.

                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           
                               OPEN QUERY q-grupo-economico
                                    FOR EACH tt-grupo NO-LOCK.
                               
                               DISP tel_nrdconta
                                    aux_qtctarel
                                    WITH FRAME f_grupo_economico.

                               UPDATE b-grupo-economico
                                      WITH FRAME f_grupo_economico.
                    
                               LEAVE.
                    
                           END.
                    
                           CLOSE QUERY q-grupo-economico.
                           HIDE FRAME f_grupo_economico.
                                       
                       END. 

                 END.

              FIND FIRST tt-msg-confirma WHERE tt-msg-confirma.inconfir = 72 
                                         NO-LOCK NO-ERROR.

              IF AVAIL tt-msg-confirma  THEN
                 MESSAGE tt-msg-confirma.dsmensag.

              FIND FIRST tt-erro NO-LOCK NO-ERROR.
           
              IF AVAILABLE tt-erro  THEN
                 DO:
                    MESSAGE tt-erro.dscritic.
                    HIDE FRAME f_bordero2.                        
                    RETURN.

                 END.                
              ELSE
                 DO:
                    MESSAGE "Bordero nao encontrado".
                          
                    RETURN.

                 END.

           END.

        FIND LAST tt-msg-confirma NO-LOCK NO-ERROR.

        IF AVAIL tt-msg-confirma  THEN
           DO:
              CASE tt-msg-confirma.inconfir:

                   WHEN 2 THEN 
                      DO: 
                         HIDE FRAME f_bordero2.

                         /* Necessaria atualizacao RATING */
                         DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                             ASSIGN aux_confirma = "N".
                             BELL.
                             MESSAGE tt-msg-confirma.dsmensag
                                     UPDATE aux_confirma.

                             ASSIGN aux_inconfir = tt-msg-confirma.inconfir.

                             LEAVE.

                         END.

                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                            aux_confirma <> "S"                THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0030) THEN
                                   DELETE OBJECT h-b1wgen0030.

                                ASSIGN glb_cdcritic = 79.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                ASSIGN glb_cdcritic = 0.

                                RETURN.

                            END.

                          NEXT.   

                      END.      
                   WHEN 12 THEN 
                      DO: 
                         HIDE FRAME f_bordero2.

                         /* Valores Excedidos */
                         DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                             ASSIGN aux_confirma = "N".
                             BELL.
                             MESSAGE tt-msg-confirma.dsmensag
                                     UPDATE aux_confirma.

                             ASSIGN aux_inconfi2 = tt-msg-confirma.inconfir.

                             LEAVE.

                         END.

                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                            aux_confirma <> "S"                THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0030) THEN
                                   DELETE OBJECT h-b1wgen0030.

                                ASSIGN glb_cdcritic = 79.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                ASSIGN glb_cdcritic = 0.

                                RETURN.

                            END.

                          NEXT.   

                      END.    
                   WHEN 22 THEN 
                      DO:
                         HIDE FRAME f_bordero2.

                         /* Ha restricoes liberar mesmo assim ? */
                         DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                             ASSIGN aux_confirma = "N".
                             BELL.
                             MESSAGE tt-msg-confirma.dsmensag
                                     UPDATE aux_confirma.
                             ASSIGN aux_inconfi3 = tt-msg-confirma.inconfir.

                             LEAVE.

                         END.

                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                            aux_confirma <> "S"                THEN
                            DO:  
                                IF VALID-HANDLE(h-b1wgen0030) THEN
                                   DELETE OBJECT h-b1wgen0030.

                                ASSIGN glb_cdcritic = 79.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                ASSIGN glb_cdcritic = 0.

                                RETURN.

                            END.

                         NEXT. 

                      END.
                   WHEN 31 THEN 
                      DO:
                         HIDE FRAME f_bordero2.
                   
                         /* Ha restricoes liberar mesmo assim ? */
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                            ASSIGN aux_confirma = "N".
                            BELL.
                            MESSAGE tt-msg-confirma.dsmensag
                                    UPDATE aux_confirma.
                            ASSIGN aux_inconfi5 = 
                                   tt-msg-confirma.inconfir + 1.
                            LEAVE.
                   
                         END.
                   
                         IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                            aux_confirma <> "S"                THEN
                            DO:  
                                IF VALID-HANDLE(h-b1wgen0030) THEN
                                   DELETE OBJECT h-b1wgen0030.

                                ASSIGN glb_cdcritic = 79.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                ASSIGN glb_cdcritic = 0.

                                RETURN.
                            END.
                   
                         NEXT.    
                   
                      END.
                   WHEN 72 THEN 
                      DO:
                         MESSAGE tt-msg-confirma.dsmensag.
                         PAUSE 2 NO-MESSAGE.
                         HIDE MESSAGE NO-PAUSE.
                         ASSIGN aux_inconfi4 = tt-msg-confirma.inconfir.
                         NEXT.

                      END.
                   WHEN 88 THEN
                      DO: 
                          IF VALID-HANDLE(h-b1wgen0030) THEN
                             DELETE OBJECT h-b1wgen0030.

                          HIDE FRAME f_bordero2.
                          MESSAGE tt-msg-confirma.dsmensag 
                                  VIEW-AS ALERT-BOX TITLE "".
                          LEAVE.

                      END.

              END CASE.
                   
           END.

    END. /* Final do DO WHILE TRUE */    
   
    LEAVE.
        
END.

IF  par_cddopcao = "L"  THEN
    DO: 
        IF NOT VALID-HANDLE(h-b1wgen0030) THEN
           RUN sistema/generico/procedures/b1wgen0030.p 
               PERSISTENT SET h-b1wgen0030.

        IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
            DO:
                MESSAGE "Handle invalido para b1wgen0030".
                RETURN.
            END.
        
        RUN busca_total_descontos IN h-b1wgen0030 
                                    (INPUT glb_cdcooper,
                                     INPUT 0, /** agencia  **/
                                     INPUT 0, /** caixa    **/
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_nrdconta,
                                     INPUT 1, /** idseqttl **/
                                     INPUT 1, /** origem   **/
                                     INPUT "ATENDA",
                                     INPUT FALSE, /* LOG */
                                    OUTPUT TABLE tt-tot_descontos).

        IF VALID-HANDLE(h-b1wgen0030) THEN
           DELETE OBJECT h-b1wgen0030.
        
        FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

        IF  AVAIL tt-tot_descontos  THEN
            ASSIGN aux_vltotdsc = tt-tot_descontos.vltotdsc
                   aux_vldsctit = tt-tot_descontos.vldsctit
                   aux_qtdsctit = tt-tot_descontos.qtdsctit.

        RUN fontes/dsctit_bordero_m.p (INPUT tel_nrdconta,
                                       INPUT par_nrborder).    

    END.    

/* .......................................................................... */


