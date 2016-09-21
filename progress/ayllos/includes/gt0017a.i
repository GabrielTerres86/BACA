/* .............................................................................

   Programa: Includes/gt0017a.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Isara - RKAM
   Data    : Abril/2011                    Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Consulta da Submodalidade 
              (Generico)

   Alteracoes: 
   
............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

    ASSIGN tel_cdmodali = ""                         
           tel_cdsubmod = "" 
           tel_dssubmod = "".

    DISPLAY tel_cdmodali 
            tel_cdsubmod 
            tel_dssubmod 
            WITH FRAME f_modalida.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        SET tel_cdmodali WITH FRAME f_modalida
        EDITING:

            aux_stimeout = 0.
            DO WHILE TRUE:
    
                READKEY PAUSE 1.
                IF LASTKEY = -1 THEN
                DO:
                    aux_stimeout = aux_stimeout + 1.
                    IF aux_stimeout > glb_stimeout THEN
                        QUIT.

                    NEXT.
                END.
                ELSE
                    IF LASTKEY = KEYCODE("F7") THEN
                    DO:
                        IF FRAME-FIELD = "tel_cdmodali" THEN
                        DO:
                            RUN fontes/zoom_modalidades_risco.p
                                          (OUTPUT tel_cdmodali).
            
                            DISPLAY tel_cdmodali WITH FRAME f_modalida.
            
                            IF tel_cdmodali <> "" THEN
                                APPLY "RETURN".                             
                        END.
                    END.
                    ELSE
                        APPLY LASTKEY.
    
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
        END.  /*  Fim do EDITING  */

        IF NOT LENGTH(tel_cdmodali) = 2 THEN
        DO:
            tel_dssubmod = "".
            DISPLAY tel_dssubmod WITH FRAME f_modalida.
    
            MESSAGE "Informe dois digitos para o codigo da modalidade.".
            PAUSE 2 NO-MESSAGE.
           
            NEXT-PROMPT tel_cdmodali WITH FRAME f_modalida.
            NEXT.
        END.
    
        SET tel_cdsubmod WITH FRAME f_modalida.

        IF NOT LENGTH(tel_cdsubmod) = 2 THEN
        DO:
            tel_dssubmod = "".
            DISPLAY tel_dssubmod WITH FRAME f_modalida.
    
            MESSAGE "Informe dois digitos para o codigo da submodalidade.".
            PAUSE 2 NO-MESSAGE.
           
            NEXT-PROMPT tel_cdsubmod WITH FRAME f_modalida.
            NEXT.
        END.
       
        IF NOT CAN-FIND(FIRST gnsbmod
                        WHERE gnsbmod.cdmodali = INPUT tel_cdmodali
                          AND gnsbmod.cdsubmod = INPUT tel_cdsubmod) THEN
        DO:
            
            ASSIGN tel_cdmodali = ""
                   tel_cdsubmod = ""
                   tel_dssubmod = "".
       
            DISPLAY tel_cdmodali
                    tel_cdsubmod
                    tel_dssubmod
                    WITH FRAME f_modalida.
       
            MESSAGE "Codigo modalidade principal ou especifica nao cadastrado.".
            PAUSE 4 NO-MESSAGE.
           
            NEXT-PROMPT tel_cdmodali WITH FRAME f_modalida.
            NEXT.
        END.

        FIND FIRST gnsbmod EXCLUSIVE-LOCK
             WHERE gnsbmod.cdmodali = INPUT tel_cdmodali 
               AND gnsbmod.cdsubmod = INPUT tel_cdsubmod NO-ERROR.
        IF AVAIL gnsbmod THEN
        DO:
            tel_dssubmod = gnsbmod.dssubmod.
            DISPLAY tel_dssubmod WITH FRAME f_modalida.
    
            SET tel_dssubmod WITH FRAME f_modalida.

            IF tel_dssubmod = "" THEN
            DO:
                MESSAGE "Descricao deve ser informada.".
                PAUSE 2 NO-MESSAGE.
               
                NEXT-PROMPT tel_dssubmod WITH FRAME f_modalida.
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
                    ASSIGN gnsbmod.dssubmod = INPUT tel_dssubmod.
                    RELEASE gnsbmod.
            
                    MESSAGE "Alteracao efetuada com sucesso.".
                    PAUSE 2 NO-MESSAGE.
                END.
        
                LEAVE.
            END.
        END.

        LEAVE.
    END.

    LEAVE.
END. /* Fim da transacao */

/* F4, END ou FIM */
IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    
    NEXT.

/* .......................................................................... */
