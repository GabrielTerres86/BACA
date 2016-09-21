/* ............................................................................

   Programa: Includes/Bcaixak.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Marco/2001                      Ultima alteracao: 31/10/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de lancamentos especiais  da tela BCAIXA.

   Alteracoes: 15/05/2003 - Nao excluir lanctos caixa on_line (Margarete).
   
               06/10/2004 - Diferenca de caixa so coordenador (Margarete).
               
               06/07/2005 - Alimentado campo cdcooper da tabela craplcx (Diego).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)  
                            
               31/10/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
............................................................................ */

INICIO:
DO WHILE TRUE:

    ASSIGN aux_cdoplanc = "".

    RUN Busca_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        LEAVE.

    IF  aux_msgretor <> "" THEN
        DO:
            ASSIGN aux_flgreabr = NO
                   glb_cdcritic = 0.

            MESSAGE COLOR NORMAL aux_msgretor UPDATE aux_flgreabr.

            IF  aux_flgreabr THEN
                DO:
                    RUN Grava_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        LEAVE.

                    MESSAGE "Boletim reaberto.".
                    PAUSE 3 NO-MESSAGE.

                END.
            ELSE
                LEAVE.
        END.

    VIEW FRAME f_moldura_especial.
    HIDE MESSAGE NO-PAUSE.
    PAUSE(0).

    DISPLAY tel_altlacto tel_conlacto tel_exclacto tel_inclacto
        WITH FRAME f_extra.

    ASSIGN tel_cdhistor = 0
           tel_dsdcompl = ""
           tel_nrdocmto = 0
           tel_vldocmto = 0
           tel_nrseqdig = 0
           glb_cdcritic = 0
           aux_flgreabr = yes.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CLEAR FRAME f_lancamentos ALL.
        HIDE FRAME f_lancamentos NO-PAUSE.
 
        ASSIGN aux_flgreabr = YES.

        CHOOSE FIELD  tel_altlacto tel_conlacto tel_exclacto tel_inclacto 
            WITH FRAME f_extra.

        IF  FRAME-VALUE = tel_altlacto  THEN /* Alterar lancamento */
            DO WHILE TRUE ON ERROR UNDO, NEXT:

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    DO:
                        CLEAR FRAME f_extra all.
                        ASSIGN tel_cdhistor = 0
                               tel_dsdcompl = ""
                               tel_nrdocmto = 0
                               tel_vldocmto = 0
                               tel_nrseqdig = 0
                               glb_cdcritic = 0.

                        DISPLAY tel_altlacto tel_conlacto tel_exclacto 
                                tel_inclacto WITH FRAME f_extra.
                        LEAVE.
                    END.

                DISPLAY tel_altlacto tel_conlacto tel_exclacto tel_inclacto
                    WITH FRAME f_extra.

                IF  NOT aux_flgreabr THEN
                    LEAVE.

                DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        DO:    
                            PAUSE(0).
                            LEAVE.
                        END.

                    ASSIGN aux_cdoplanc = "A".
                   
                    UPDATE tel_cdhistor tel_nrdocmto tel_nrseqdig
                        WITH FRAME f_extra.

                    RUN Valida_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    ASSIGN tel_dsdcompl = aux_dsdcompl
                           tel_vldocmto = aux_vldocmto.

                    DISPLAY aux_dshistor aux_nrctadeb aux_nrctacrd
                            aux_cdhistor tel_dsdcompl tel_vldocmto
                        WITH FRAME f_extra.

                    UPDATE tel_cdhistor WITH FRAME f_extra.

                    RUN Valida_Historico.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    DISPLAY aux_dshistor aux_nrctadeb aux_nrctacrd
                            aux_cdhistor WITH FRAME f_extra.

                    IF  aux_indcompl <> 0 THEN
                        UPDATE tel_dsdcompl WITH FRAME f_extra.
                    ELSE
                        DO:
                            ASSIGN tel_dsdcompl = "".
                            DISPLAY tel_dsdcompl WITH FRAME f_extra.
                        END.

                    UPDATE tel_vldocmto WITH FRAME f_extra
                    EDITING:
                        DO:
                            READKEY.
                            IF  LASTKEY =  KEYCODE(".") THEN
                                APPLY 44.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    END.

                    ASSIGN aux_confirma = NO.
                    MESSAGE COLOR NORMAL "Confirma alteracao?" 
                        UPDATE aux_confirma.

                    IF  aux_confirma THEN 
                        DO:
                            RUN Grava_Dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.
                        END.

                    CLEAR FRAME f_extra all.
                    ASSIGN tel_cdhistor = 0
                           tel_dsdcompl = ""
                           tel_nrdocmto = 0
                           tel_vldocmto = 0
                           tel_nrseqdig = 0
                           glb_cdcritic = 0.

                    LEAVE.
                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        CLEAR FRAME f_extra all.
                        ASSIGN tel_cdhistor = 0
                               tel_dsdcompl = ""
                               tel_nrdocmto = 0
                               tel_vldocmto = 0
                               tel_nrseqdig = 0
                               glb_cdcritic = 0.

                        DISPLAY tel_altlacto tel_conlacto tel_exclacto 
                                tel_inclacto WITH FRAME f_extra.
                        LEAVE.
                    END.
            END. /* FRAME-VALUE = tel_altlacto */

        IF  FRAME-VALUE = tel_conlacto   THEN /* consultar lancamentos */
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                ASSIGN aux_cdoplanc = "C".

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE.

                HIDE MESSAGE NO-PAUSE.

                OPEN QUERY bcraplcx-q FOR EACH tt-lanctos.

                ENABLE bcraplcx-b WITH FRAME f_lancamentos.

                WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
            END. /* FRAME-VALUE = tel_conlacto */

        IF  FRAME-VALUE = tel_exclacto  THEN /* Excluir lancamento */
            DO WHILE TRUE ON ERROR UNDO, NEXT:

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        CLEAR FRAME f_extra all.
                        ASSIGN tel_cdhistor = 0
                               tel_dsdcompl = ""
                               tel_nrdocmto = 0
                               tel_vldocmto = 0
                               tel_nrseqdig = 0
                               glb_cdcritic = 0.

                        DISPLAY tel_altlacto tel_conlacto tel_exclacto 
                                tel_inclacto WITH FRAME f_extra.
                        LEAVE.
                    END.

                DISPLAY tel_altlacto tel_conlacto tel_exclacto tel_inclacto
                    WITH FRAME f_extra.

                IF  NOT aux_flgreabr   THEN
                    LEAVE.

                DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

                    ASSIGN aux_cdoplanc = "E".

                    UPDATE tel_cdhistor tel_nrdocmto tel_nrseqdig
                        WITH FRAME f_extra.

                    RUN Valida_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    ASSIGN tel_dsdcompl = aux_dsdcompl
                           tel_vldocmto = aux_vldocmto.

                    DISPLAY aux_dshistor aux_nrctadeb aux_nrctacrd
                            aux_cdhistor tel_dsdcompl tel_vldocmto
                        WITH FRAME f_extra.
                 
                    ASSIGN aux_confirma = NO.

                    MESSAGE COLOR NORMAL "Confirma eliminacao?" 
                        UPDATE aux_confirma.

                    IF  aux_confirma THEN 
                        DO:
                            RUN Grava_Dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.
                        END.

                    CLEAR FRAME f_extra ALL.
                    ASSIGN tel_cdhistor = 0
                           tel_dsdcompl = ""
                           tel_nrdocmto = 0
                           tel_nrseqdig = 0
                           glb_cdcritic = 0.
                    
                    LEAVE.

                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        CLEAR FRAME f_extra all.
                        ASSIGN tel_cdhistor = 0
                               tel_dsdcompl = ""
                               tel_nrdocmto = 0
                               tel_vldocmto = 0
                               tel_nrseqdig = 0
                               glb_cdcritic = 0.

                        DISPLAY tel_altlacto tel_conlacto tel_exclacto 
                                tel_inclacto WITH FRAME f_extra.

                        LEAVE.
                    END.
            END. /* FRAME-VALUE = tel_exclacto */

        IF  FRAME-VALUE = tel_inclacto  THEN /* Incluir lancamento */
            DO WHILE TRUE ON ERROR UNDO, NEXT:

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        CLEAR FRAME f_extra all.
                        ASSIGN tel_cdhistor = 0
                               tel_dsdcompl = ""
                               tel_nrdocmto = 0
                               tel_vldocmto = 0
                               tel_nrseqdig = 0
                               glb_cdcritic = 0.

                        DISPLAY tel_altlacto tel_conlacto tel_exclacto 
                                tel_inclacto WITH FRAME f_extra.

                        LEAVE.
                    END.

                DISPLAY tel_altlacto tel_conlacto tel_exclacto tel_inclacto
                    WITH FRAME f_extra.

                IF  NOT aux_flgreabr   THEN
                    LEAVE.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN aux_cdoplanc = "I".

                    UPDATE tel_cdhistor WITH FRAME f_extra.

                    RUN Valida_Historico.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    DISPLAY aux_dshistor aux_nrctadeb aux_nrctacrd
                            aux_cdhistor WITH FRAME f_extra.

                    IF  aux_indcompl <> 0 THEN
                        UPDATE tel_dsdcompl WITH FRAME f_extra.
                 
                    UPDATE tel_nrdocmto tel_vldocmto WITH FRAME f_extra
                    EDITING:
                        DO:
                            READKEY.
                            IF  FRAME-FIELD = "tel_vldocmto" THEN
                                DO:
                                    IF  LASTKEY =  KEYCODE(".") THEN
                                        APPLY 44.
                                    ELSE
                                        APPLY LASTKEY.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    END.

                    RUN Grava_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    CLEAR FRAME f_extra ALL.
                    ASSIGN tel_cdhistor = 0
                           tel_dsdcompl = ""
                           tel_nrdocmto = 0
                           tel_vldocmto = 0
                           glb_cdcritic = 0.

                    LEAVE.

                END. /* Fim do DO WHILE TRUE... */              

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        CLEAR FRAME f_extra all.
                        ASSIGN tel_cdhistor = 0
                               tel_dsdcompl = ""
                               tel_nrdocmto = 0
                               tel_vldocmto = 0
                               tel_nrseqdig = 0
                               glb_cdcritic = 0.

                        DISPLAY tel_altlacto tel_conlacto tel_exclacto 
                                tel_inclacto WITH FRAME f_extra.

                        LEAVE.
                    END.
            END. /* FRAME-VALUE = tel_inclacto */

    END. /* DO WHILE TRUE ON ENDKEY UNDO */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*   F4 OU FIM   */
        DO:
            CLEAR FRAME f_extra ALL.
            HIDE FRAME f_extra NO-PAUSE.
            HIDE FRAME f_moldura_especial NO-PAUSE.
            LEAVE.
        END.    
END.

/* ......................................................................... */




