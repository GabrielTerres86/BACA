/* ............................................................................

   Programa: fontes/proposta_bens.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Junho/2010                          Ultima atualizacao: 30/07/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Trazer os bens do cooperado e permitir o cadastro deles na
               operacao de credito.  

   Alteracoes: 08/08/2013 - Bloqueio do char ";" no cadastro dos bens (Carlos)
        
               30/07/2014 - Bloqueio do char "|" no cadastro dos bens (Jorge)

,............................................................................ */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen9999tt.i }
    
{ includes/var_online.i }
{ includes/var_bens.i }
{ includes/var_proposta.i }

DEF INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_nrcpfcgc AS DECI                                  NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-crapbem.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DISPLAY reg_dsdopcao 
            WITH FRAME f_regua.

    /* Somente para marcar a opcao escolhida */
    CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

    IF   par_nrdconta > 0   THEN
         OPEN QUERY q-crapbem 
                    FOR EACH tt-crapbem WHERE 
                             tt-crapbem.nrdconta = par_nrdconta NO-LOCK.
    ELSE
    IF   par_nrcpfcgc > 0   THEN
         OPEN QUERY q-crapbem
                    FOR EACH tt-crapbem WHERE
                             tt-crapbem.nrcpfcgc = par_nrcpfcgc NO-LOCK.
                   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b-crapbem WITH FRAME f_crapbem.
        LEAVE.

    END.
  
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         KEYFUNCTION(LASTKEY) = "GO"          THEN
         DO:
             HIDE FRAME f_crapbem.
             HIDE FRAME f_regua.
             HIDE FRAME f_altera.

             RETURN "OK".
         END.
         
    /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
    VIEW FRAME f_crapbem.

    IF   aux_nrdlinha > 0   THEN
         REPOSITION q-crapbem TO ROW(aux_nrdlinha). 

    IF   glb_cddopcao = "I"   THEN
         DO:
             ASSIGN tel_dsrelbem = ""
                    tel_persemon = 0 
                    tel_qtprebem = 0
                    tel_vlprebem = 0
                    tel_vlrdobem = 0. 
           
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                
                UPDATE tel_dsrelbem
                       tel_persemon
                       tel_qtprebem
                       tel_vlprebem
                       tel_vlrdobem WITH FRAME f_altera
                EDITING:
                    READKEY.
                    IF LASTKEY = KEYCODE(";") OR
                       LASTKEY = KEYCODE("|") THEN
                        NEXT.
                    APPLY LASTKEY.
                END.

                RUN Valida_Dados.

                IF   RETURN-VALUE <> "OK" THEN
                     NEXT.

                LEAVE.

             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                  NEXT.
        
             ASSIGN tel_dsrelbem = CAPS(tel_dsrelbem).
            
             DISPLAY tel_dsrelbem WITH FRAME f_altera. 
             
             PAUSE 0.
             
             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).

             IF   aux_confirma <> "S"   THEN
                  NEXT.

             ASSIGN aux_idseqbem = 1.

             IF   par_nrdconta > 0   THEN
                  DO:
                      /* Pegar proximo sequencial */
                      FOR EACH tt-crapbem WHERE 
                               tt-crapbem.nrdconta = par_nrdconta NO-LOCK
                               BREAK BY tt-crapbem.idseqbem:

                          ASSIGN aux_idseqbem = tt-crapbem.idseqbem + 1.

                      END.
                  END.
             ELSE     /* Avalistas terceiros */
                  DO:
                      /* Pegar proximo sequencial */
                      FOR EACH tt-crapbem WHERE 
                               tt-crapbem.nrdconta = 0 NO-LOCK
                               BREAK BY tt-crapbem.idseqbem:

                          ASSIGN aux_idseqbem = tt-crapbem.idseqbem + 1.

                      END.                    
                  END.

             CREATE tt-crapbem.
             ASSIGN tt-crapbem.nrdconta = par_nrdconta
                    tt-crapbem.nrcpfcgc = par_nrcpfcgc
                    tt-crapbem.dsrelbem = tel_dsrelbem
                    tt-crapbem.persemon = tel_persemon
                    tt-crapbem.qtprebem = tel_qtprebem
                    tt-crapbem.vlprebem = tel_vlprebem
                    tt-crapbem.vlrdobem = tel_vlrdobem
                    tt-crapbem.idseqbem = aux_idseqbem.
   
         END. /* Fim Opcao 'I' */
    ELSE
    IF   glb_cddopcao = "A"   THEN
         DO:
             IF   NOT AVAILABLE tt-crapbem   THEN
                  NEXT.

             ASSIGN tel_dsrelbem = tt-crapbem.dsrelbem
                    tel_persemon = tt-crapbem.persemon
                    tel_qtprebem = tt-crapbem.qtprebem
                    tel_vlprebem = tt-crapbem.vlprebem
                    tel_vlrdobem = tt-crapbem.vlrdobem
                    aux_idseqbem = tt-crapbem.idseqbem
                    aux_nrdrowid = tt-crapbem.nrdrowid.
                
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                
               UPDATE tel_dsrelbem 
                      tel_persemon
                      tel_qtprebem
                      tel_vlprebem
                      tel_vlrdobem 
                      WITH FRAME f_altera
               EDITING:
                   READKEY.
                   IF LASTKEY = KEYCODE(";") OR 
                      LASTKEY = KEYCODE("|") THEN
                       NEXT.
                   APPLY LASTKEY.
               END.

               RUN Valida_Dados.

               IF   RETURN-VALUE <> "OK"   THEN
                    NEXT.

               LEAVE.
                    
             END.  

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.

             tel_dsrelbem = CAPS(tel_dsrelbem).
           
             DISPLAY tel_dsrelbem WITH FRAME f_altera.
              
             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).

             IF   aux_confirma <> "S"   THEN
                  NEXT.

             ASSIGN tt-crapbem.nrdconta = par_nrdconta
                    tt-crapbem.nrcpfcgc = par_nrcpfcgc
                    tt-crapbem.dsrelbem = tel_dsrelbem
                    tt-crapbem.persemon = tel_persemon
                    tt-crapbem.qtprebem = tel_qtprebem
                    tt-crapbem.vlprebem = tel_vlprebem
                    tt-crapbem.vlrdobem = tel_vlrdobem.

         END. /* Fim Opcao 'A' */
    ELSE
    IF   glb_cddopcao = "E"   THEN
         DO:
             IF   NOT AVAIL tt-crapbem   THEN
                  NEXT.

             /* mostrar os dados antes da exclusao */
             DISPLAY  tt-crapbem.dsrelbem @ tel_dsrelbem
                      tt-crapbem.persemon @ tel_persemon
                      tt-crapbem.qtprebem @ tel_qtprebem
                      tt-crapbem.vlprebem @ tel_vlprebem
                      tt-crapbem.vlrdobem @ tel_vlrdobem
                      WITH FRAME f_altera.

             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).
                          
             IF   aux_confirma <> "S"  THEN
                  NEXT.
             
             DELETE tt-crapbem.

         END. /* Fim Opcao 'E' */
    
END. /* Fim do DO WHILE TRUE */


PROCEDURE valida_Dados:

    RUN sistema/generico/procedures/b1wgen0056.p PERSISTENT SET h-b1wgen0056.
    
    RUN Valida-Dados IN h-b1wgen0056 
       ( INPUT glb_cdcooper,
         INPUT glb_cdagenci,
         INPUT 0,
         INPUT par_nrdconta,
         INPUT 1,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT glb_cdoperad,
         INPUT glb_cddopcao,
         INPUT tel_dsrelbem,
         INPUT tel_persemon,
         INPUT tel_qtprebem,
         INPUT tel_vlprebem,
         INPUT tel_vlrdobem,
         INPUT aux_idseqbem,
        OUTPUT TABLE tt-erro ).

    DELETE PROCEDURE h-b1wgen0056.

    IF   RETURN-VALUE <> "OK" THEN
         DO:
             FIND FIRST tt-erro NO-ERROR.
             
             IF  AVAILABLE tt-erro THEN
                 DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                 END.
         END.

    RETURN "OK".

END PROCEDURE.

/* ......................................................................... */
