/* .............................................................................

   Programa: Includes/gt0016i.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Isara - RKAM
   Data    : Abril/2011                    Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Inclusao da Modalidade (Generico)

   Alteracoes: 
                
............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN tel_cdmodali = ""
               tel_dsmodali = "".

        DISPLAY tel_cdmodali 
                tel_dsmodali 
                WITH FRAME f_modalida.

        SET tel_cdmodali WITH FRAME f_modalida.

        IF NOT LENGTH(tel_cdmodali) = 2 THEN
        DO:
            tel_dsmodali = "".
            DISPLAY tel_dsmodali WITH FRAME f_modalida.

            MESSAGE "Informe dois digitos para o codigo da modalidade.".
            PAUSE 2 NO-MESSAGE.
           
            NEXT-PROMPT tel_cdmodali WITH FRAME f_modalida.
            NEXT.
        END.

        IF CAN-FIND(FIRST gnmodal
                    WHERE gnmodal.cdmodali = INPUT tel_cdmodali) THEN
        DO:
            tel_dsmodali = "".
            DISPLAY tel_dsmodali WITH FRAME f_modalida.

            MESSAGE "Codigo ja cadastrado.".
            PAUSE 2 NO-MESSAGE.
    
            NEXT-PROMPT tel_cdmodali WITH FRAME f_modalida.
            NEXT. 
        END.

        SET tel_dsmodali WITH FRAME f_modalida. 

        IF tel_dsmodali = "" THEN
        DO:
            MESSAGE "Descricao deve ser informada.".
            PAUSE 2 NO-MESSAGE.
           
            NEXT-PROMPT tel_dsmodali WITH FRAME f_modalida.
            NEXT.
        END.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            ASSIGN aux_confirma = "N"
                   glb_cdcritic = 78.
    
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
    
            MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           
            IF aux_confirma = "S" THEN
            DO:
                CREATE gnmodal.
                ASSIGN gnmodal.cdmodali = INPUT tel_cdmodali
                       gnmodal.dsmodali = tel_dsmodali.

                RELEASE gnmodal.
    
                MESSAGE "Cadastro efetuado com sucesso.".
                PAUSE 2 NO-MESSAGE.
            END.

            LEAVE.
        END.
    
        LEAVE.
    END.

    LEAVE.

END. /* Fim da transacao */

/* F4, END ou FIM */
IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    
    NEXT.

CLEAR FRAME f_modalida ALL NO-PAUSE.

/* .......................................................................... */

