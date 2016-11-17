/* .............................................................................

   Programa: Includes/Bcaixac.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001                  Ultima alteracao: 31/10/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela BCAIXA.

   Alteracoes: 23/11/2004 - Tratar impressao dos depositos efetuados (Edson).
   
               24/02/2005 - Nao permitir data menor que o 1o dia do mes
                            anterior a data atual (Evandro).
                            
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre.
               
               27/03/2007 - Apontar diferenca entre o boletim e a fita de caixa
                            mesmo com o caixa aberto (Magui).
                            
               31/10/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
............................................................................. */

ASSIGN glb_cdcritic = 0
       aux_tipconsu = yes
       aux_nmarqimp = "".


    OPEN QUERY bcaixa-q FOR EACH tt-boletimcx.

    ENABLE bcaixa-b btn-visualiz btn-impraber btn-imprbole 
           btn-impfitcx btn-impdepos btn-sair WITH FRAME f_boletim.

    ON RETURN OF bcaixa-b
        DO:
            APPLY "CHOOSE" TO btn-visualiz.
            RETURN NO-APPLY.
        END.

    ON CHOOSE OF btn-visualiz
        DO:
            IF  NOT AVAIL tt-boletimcx THEN
                RETURN NO-APPLY.

            /**** aqui o registro selecionado ja esta disponivel ***/
            ASSIGN aux_recidbol = tt-boletimcx.nrcrecid
                   aux_tipconsu = YES.

            RUN Gera_Boletim.

            IF  NOT aux_flgsemhi   THEN
                DO:
                    HIDE FRAME f_boletim.
                    RUN fontes/visualiza_boletim.p.
                    VIEW FRAME f_boletim.
                    VIEW FRAME f_opcao.  
                END.
        END.

    ON CHOOSE OF btn-impraber
        DO:
            IF  NOT AVAIL tt-boletimcx THEN
                RETURN NO-APPLY.

            ASSIGN aux_recidbol = tt-boletimcx.nrcrecid.
            RUN Gera_Termo.
        END.

    ON CHOOSE OF btn-imprbole
        DO:
            IF  NOT AVAIL tt-boletimcx THEN
                RETURN NO-APPLY.

            ASSIGN aux_recidbol = tt-boletimcx.nrcrecid
                   aux_tipconsu = NO.

            RUN Gera_Boletim.
        END.

    ON CHOOSE OF btn-impfitcx
        DO:
            IF  NOT AVAIL tt-boletimcx THEN
                RETURN NO-APPLY.

            ASSIGN aux_tpimprim = TRUE.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                MESSAGE "Voce deseja visualizar a fita" 
                        "em TELA ou na IMPRESSORA? (T/I)"
                        UPDATE aux_tpimprim.
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                NEXT.

            IF  aux_tpimprim THEN
                ASSIGN aux_tipconsu = YES.
            ELSE
                ASSIGN aux_tipconsu = NO.

            ASSIGN aux_recidbol = tt-boletimcx.nrcrecid.

            RUN Gera_Fita_Caixa.

            IF  aux_tpimprim THEN
                IF  NOT aux_flgsemhi THEN
                    DO:
                        HIDE FRAME f_boletim.
                        RUN fontes/visualiza_fitacx.p.
                                       VIEW FRAME f_boletim.
                        VIEW FRAME f_opcao.
                    END.
        END.

    ON CHOOSE OF btn-impdepos
        DO:
            IF  NOT AVAIL tt-boletimcx THEN
                RETURN NO-APPLY.

            ASSIGN aux_tpimprim = TRUE.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                MESSAGE "Voce deseja visualizar os dep./saq." 
                        "em TELA ou na IMPRESSORA? (T/I)"
                        UPDATE aux_tpimprim.
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                NEXT.

            IF  aux_tpimprim THEN
                ASSIGN aux_tipconsu = YES.
            ELSE
                ASSIGN aux_tipconsu = NO.

            ASSIGN aux_recidbol = tt-boletimcx.nrcrecid.

            RUN Gera_Depositos_Saques.
            
            IF  aux_tpimprim THEN
                IF  NOT aux_flgsemhi THEN
                    DO:
                        HIDE FRAME f_boletim.
                        RUN fontes/visualiza_deposito.p.
                        VIEW FRAME f_boletim.
                        VIEW FRAME f_opcao.  
                    END.
        END.

    ON CHOOSE OF btn-sair
        DO:    
            HIDE FRAME f_boletim.
        END.

    WAIT-FOR CHOOSE OF btn-sair.
/* .......................................................................... */
