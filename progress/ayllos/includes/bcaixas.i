/* ............................................................................

   Programa: Includes/Bcaixas.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001                  Ultima alteracao: 09/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela BCAIXA.

   Alteracoes: 23/11/2004 - Tratar impressao dos depositos efetuados (Edson).
   
               24/02/2005 - Nao permitir data menor que o 1o dia do mes
                            anterior a data atual (Evandro).
               
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               26/03/2007 - Apontar diferenca entre o boletim e a fita de caixa
                            mesmo com o caixa aberto (Magui).
                            
               31/10/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
               
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
............................................................................ */

DEF QUERY bcaixa-s FOR tt-boletimcx.

DEF BROWSE bcaixa-s QUERY bcaixa-s
      DISP tt-boletimcx.cdagenci               COLUMN-LABEL "PA"
           tt-boletimcx.nrdcaixa               COLUMN-LABEL "Caixa"
           tt-boletimcx.nmoperad               COLUMN-LABEL "Operador"
           tt-boletimcx.cdsitbcx               COLUMN-LABEL "S"
           tt-boletimcx.vldsdini               COLUMN-LABEL "Saldo Inicial"
           tt-boletimcx.vldsdfin               COLUMN-LABEL "Saldo Final"
           WITH 8 DOWN OVERLAY.    

DEF FRAME f_saldos
          bcaixa-s     HELP "Use <TAB> para navegar" SKIP 
          SPACE(17)
          btn-visualiz HELP "Use <TAB> para navegar" 
          SPACE(2)
          btn-impraber HELP "Use <TAB> para navegar"
          SPACE(2)
          btn-imprbole HELP "Use <TAB> para navegar" SKIP
          SPACE(20)
          btn-impfitcx HELP "Use <TAB> para navegar"
          SPACE(2)
          btn-impdepos HELP "Use <TAB> para navegar"
          SPACE(2)
          btn-sair HELP "Use <TAB> para navegar"
          WITH NO-BOX CENTERED OVERLAY ROW 7.

ASSIGN glb_cdcritic = 0
       aux_tipconsu = yes
       aux_nmarqimp = "".

OPEN QUERY bcaixa-s FOR EACH tt-boletimcx.

    ENABLE bcaixa-s btn-visualiz btn-impraber btn-imprbole
           btn-impfitcx btn-impdepos btn-sair WITH FRAME f_saldos.

    ON RETURN OF bcaixa-s
        DO:
            APPLY "CHOOSE" TO btn-visualiz.
            RETURN NO-APPLY.
        END.

    ON END-ERROR OF FRAME f_saldos
        DO:
            APPLY "CHOOSE" TO btn-sair.
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

            IF  NOT aux_flgsemhi THEN
                DO:
                    HIDE FRAME f_saldos.
                    RUN fontes/visualiza_boletim.p.
                    VIEW FRAME f_saldos.
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
                        HIDE FRAME f_saldos.
                        RUN fontes/visualiza_fitacx.p.
                        VIEW FRAME f_saldos.
                        VIEW FRAME f_opcao.  
                    END.
        END.

    ON CHOOSE OF btn-impdepos
        DO:
            IF  NOT AVAIL tt-boletimcx THEN
                RETURN NO-APPLY.

            ASSIGN aux_tpimprim = TRUE.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                MESSAGE "Voce deseja visualizar os depositos" 
                        "em TELA ou na IMPRESSORA? (T/I)"
                        UPDATE aux_tpimprim.

                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                NEXT.

            IF  aux_tpimprim THEN
                ASSIGN aux_tipconsu = YES.
            ELSE
                ASSIGN aux_tipconsu = no.

            ASSIGN aux_recidbol = tt-boletimcx.nrcrecid.

            RUN Gera_Depositos_Saques.
            
            IF  aux_tpimprim THEN
                IF  NOT aux_flgsemhi THEN
                    DO:
                        HIDE FRAME f_saldos.
                        RUN fontes/visualiza_deposito.p.
                        VIEW FRAME f_saldos.
                        VIEW FRAME f_opcao.  
                    END.
        END.

    ON CHOOSE OF btn-sair
        DO:
            HIDE FRAME f_saldos.
        END.

    WAIT-FOR CHOOSE OF btn-sair.
/* .......................................................................... */



