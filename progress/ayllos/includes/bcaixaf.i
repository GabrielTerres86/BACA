/* ............................................................................

   Programa: Includes/Bcaixaf.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Marco/2001                           Ultima alteracao: 31/10/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de fechamento da tela BCAIXA.

   Alteracoes: 22/08/2003 - Nao fechar o boletim se nao foram registradas
                            as movimentacoes em especie (Margarete).

               10/12/2004 - Verificar Pendencias COBAN antes do Fechamento
                            (Mirtes).
                            
               26/09/2005 - Passado codigo da cooperativa para bo 80(Mirtes)
               
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               06/02/2006 - Inclusao de EXCLUSIVE-LOCK no FIND (linha 279) -
                            SQLWorks - Eder

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada 
                            do programa fontes/pedesenha.p - SQLWorks - 
                            Fernando.

               01/08/2006 - Retirado o caminho absoluto na chamada da rotina
                            b1crap80.p (Edson).

               24/07/2008 - Incluir critica de vercoban (Gabriel).
               
               24/08/2009 - Limpar o IP do caixa no fechamento (Evandro).
               
               16/04/2010 - Criticar caso a crapcme nao foi criada na rotina
                            20 (TED/DOC) quando em especie nao-cooperado
                            e especie cooperado com valor > 10000 (Fernando).
                            
               19/10/2010 - Bloquear Fechamento do Caixa quando ha cheques
                            pendentes para serem transmitidos para ABBC (Ze).
                           
               31/01/2011 - Nao verificar situacao da previa antes de 25/03/11
                            (Ze).
                            
               29/03/2011 - Alterar de 25/03 para 15/04 (Ze).
               
               19/05/2011 - Antes de verificar se o PAC fez as previas, 
                            verificar se o mesmo apresenta indisponibilidade
                            (Guilherme).
                          - Nao permite fechar caixa se haver cheques 
                            banco/caixa 500 nao digitalizados (Elton).  
                            
               22/09/2011 - Incluir lote 30000 na leitura do crapchd ref. 
                            rotina 66 (Guilherme).
                            
               31/10/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
............................................................................*/ 

INICIO:
DO WHILE TRUE:

    ASSIGN tel_vldsdini = 0
           tel_vldentra = 0
           tel_vldsaida = 0
           tel_qtautent = 0
           tel_nrdlacre = 0
           tel_vldsdfin = 0.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
            aux_flgfecha  THEN     /*   F4 OU FIM   */
            DO:
                ASSIGN glb_cdcritic = 0.
                LEAVE.   /* Volta pedir a opcao para o operador */
            END.

        FIND FIRST tt-boletimcx NO-ERROR.

        IF  AVAIL tt-boletimcx THEN
            ASSIGN aux_recidbol = tt-boletimcx.nrcrecid
                   aux_tipconsu = YES
                   tel_nrdmaqui = tt-boletimcx.nrdmaqui
                   tel_qtautent = tt-boletimcx.qtautent
                   tel_nrdlacre = tt-boletimcx.nrdlacre
                   tel_vldsdini = tt-boletimcx.vldsdini.

        DISPLAY tel_nrdmaqui tel_qtautent tel_nrdlacre
                tel_vldsdini WITH FRAME f_bcaixa.

        IF aux_msgsenha <> "" THEN
            DO:
                MESSAGE aux_msgsenha.  
                PAUSE 10.

                RUN fontes/pedesenha.p ( INPUT glb_cdcooper,
                                         INPUT 2, 
                                         OUTPUT aut_flgsenha,
                                         OUTPUT aut_cdoperad).

                IF  NOT aut_flgsenha THEN
                    LEAVE.
            END.

        IF  aux_flgsemhi THEN
            LEAVE.
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*   F4 OU FIM   */
                LEAVE.   /* Volta pedir a opcao para o operador */

            ASSIGN aux_flgfecha = NO.

            UPDATE tel_vldentra
                   tel_vldsaida 
                WITH FRAME f_bcaixa
            EDITING:
                READKEY.

                IF  LASTKEY =  KEYCODE(".") THEN
                    APPLY 44.
                ELSE
                    APPLY LASTKEY.

                IF  GO-PENDING THEN
                    DO:
                        RUN Valida_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            DO:
                                {sistema/generico/includes/foco_campo.i
                                    &VAR-GERAL=SIM
                                    &NOME-FRAME="f_bcaixa"
                                    &NOME-CAMPO=aux_nmdcampo }
                            END.
                    END.

            END.

            DISPLAY aux_vlrttcrd @ tel_vldentra
                    (tel_vldentra - tel_vldsaida)     @ tel_vldsdfin
                    WITH FRAME f_bcaixa.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
                    LEAVE. 

                UPDATE tel_qtautent WITH FRAME f_bcaixa.

                IF  tel_qtautent = 0 THEN
                    DO:
                        ASSIGN aux_confirma = NO.
                        MESSAGE COLOR NORMAL "Sem autenticacoes hoje?" 
                        UPDATE aux_confirma.

                        IF  NOT aux_confirma THEN
                            NEXT.
                        ELSE
                            LEAVE.
                    END.

                LEAVE.
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                LEAVE.

            UPDATE tel_nrdlacre 
                VALIDATE(tel_nrdlacre <> 0,
                         "375 - O campo deve ser preenchido")
                WITH FRAME f_bcaixa.         

            ASSIGN aux_confirma = NO.
            MESSAGE COLOR NORMAL "Confirma fechamento?" 
            UPDATE aux_confirma.

            IF  aux_confirma THEN 
                DO:
                    RUN Grava_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        LEAVE.

                    ASSIGN aux_recidbol = aux_nrdrecid
                           aux_tipconsu = NO.

                    RUN Gera_Boletim.

                    IF  RETURN-VALUE <> "OK" THEN
                        LEAVE.
                END.

            ASSIGN aux_flgfecha = YES
                    glb_cdcritic = 0.

            LEAVE.

        END.

    END. 

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
        LEAVE.   /* Volta pedir a opcao para o operador */

    CLEAR FRAME f_bcaixa ALL.
    LEAVE. /* definido que deve voltar para a opcao */
    
END.

/* ......................................................................... */


