/* ............................................................................

   Programa: Includes/Bcaixai.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001                     Ultima alteracao: 31/10/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela BCAIXA.

   Alteracoes: 06/07/2005 - Alimentado campo cdcooper da tabela crapbcx (Diego).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               22/06/2007 - Inclusao do indice crapbcx5 (Julio)
               
               22/09/2010 - Alterar o find executado caso nao encontre registro
                            na data atual. Anteriomente utilizava o LAST, 
                            alterado para trazer o FIRST. (Henrique)
                            
               31/10/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
               
............................................................................ */

INICIO:
DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN glb_cdcritic = 0.

        UPDATE tel_nrdmaqui tel_vldsdini WITH FRAME f_bcaixa
        EDITING:
            DO:
                READKEY.

                IF  FRAME-FIELD = "tel_vldsdini" THEN
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

        ASSIGN aux_recidbol = aux_nrdrecid
               ant_nrdlacre = aux_nrdlacre.

        RUN Gera_Termo.

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.   /* Volta pedir a opcao para o operador */

    CLEAR FRAME f_bcaixa ALL.
    LEAVE. /* definido que deve voltar para a opcao */

END.

/* ......................................................................... */
