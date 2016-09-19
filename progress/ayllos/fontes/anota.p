/*.............................................................................
   
   Programa: Fontes/anota.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Dezembro/2001.                   Ultima atualizacao: 11/06/2012

   Dados referentes ao programa:


   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ANOTA.


   Alteracoes: 23/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               22/12/2009 - Implementacao de zoom no campo Conta/DV - 
                           (GATI - Daniel/Eder)
                           
               22/02/2011 - Adaptado para uso de BO (Jose Luis - DB1)
               
               11/06/2012 - Corrigido para não deixar o HANDLE da 
                            b1wgen0085 preso (Guilherme Maba).
............................................................................ */
{ includes/var_online.i }
{ includes/var_anota.i "NEW"}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_nrdconta AS INT  FORMAT "zzzz,zzz,9"   NO-UNDO.
DEF VAR h-b1wgen0085 AS HANDLE                     NO-UNDO.

ON CHOOSE OF btn-sair DO:

    CLOSE QUERY anota-q.

    APPLY "GO" TO anota-b.

END.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DISPLAY glb_cddopcao tel_nrdconta WITH FRAME f_opcao.

HIDE MESSAGE NO-PAUSE.

DO   WHILE TRUE:

     IF  NOT VALID-HANDLE(h-b1wgen0085) THEN
         RUN sistema/generico/procedures/b1wgen0085.p 
             PERSISTENT SET h-b1wgen0085.
                        
     HIDE FRAME f_anotacoes NO-PAUSE.
     
     DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:

          UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_opcao
          EDITING:
               READKEY /* PAUSE 1 */ .
               IF   FRAME-FIELD = "tel_nrdconta"   AND
                    LASTKEY = KEYCODE("F7")        THEN
                    DO: 
                        RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                      OUTPUT aux_nrdconta).
          
                        IF   aux_nrdconta > 0   THEN
                             DO:
                                 ASSIGN tel_nrdconta = aux_nrdconta.
                                 DISPLAY tel_nrdconta WITH FRAME f_opcao.
                                 PAUSE 0.
                                 APPLY "RETURN".
                             END.
                    END.
               ELSE
                    APPLY LASTKEY.
          END.
     
          ASSIGN
              glb_nrcalcul = tel_nrdconta
              aux_nrseqdig = 0.

          RUN Busca_Dados.

          IF  RETURN-VALUE <> "OK" THEN
              NEXT.
          
          DISPLAY tel_nmprimtl WITH FRAME f_opcao.
          
          LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
          DO:
              RUN fontes/novatela.p.
              IF   CAPS(glb_nmdatela) <> "ANOTA"   THEN
                   DO:
                       HIDE FRAME f_moldura.
                       HIDE FRAME f_opcao.
                       HIDE FRAME f_anotacoes.
                       HIDE FRAME fra_anota.
                       IF VALID-HANDLE(h-b1wgen0085) THEN
                           DELETE OBJECT h-b1wgen0085.
                       RETURN.
                   END.
              ELSE
                   DO:
                       ASSIGN glb_cdcritic = 0.
                       NEXT.
                   END.
          END.
     
     IF   aux_cddopcao <> glb_cddopcao   THEN
          DO:
              { includes/acesso.i }
              aux_cddopcao = glb_cddopcao.
          END.
      
     ASSIGN aux_flgretor        = TRUE
            btn-visualiz:HIDDEN = FALSE
            btn-imprimir:HIDDEN = FALSE.
     
     IF   glb_cddopcao = "A" THEN /* Alterar */
          DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

             { includes/anotaa.i }

             LEAVE.
          END.
     ELSE
     IF   glb_cddopcao = "C" THEN /* Consultar */
          DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
     
             { includes/anotac.i }
          
             LEAVE.
          END.
     ELSE
     IF   glb_cddopcao = "E"   THEN /* Excluir */
          DO:
              { includes/anotae.i }
          END.
     ELSE
     IF   glb_cddopcao = "I"   THEN /* Incluir */
          DO:
              { includes/anotai.i }
          END.

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0085) THEN
    DELETE OBJECT h-b1wgen0085.

/* ......................................................................... */

/*.................................PROCEDURES................................*/

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.

    RUN Busca_Dados IN h-b1wgen0085
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT aux_nrseqdig, 
          INPUT glb_cddopcao,
          INPUT YES,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-crapobs,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
                  
           RETURN "NOK".  
        END.

    FIND FIRST tt-infoass NO-ERROR.

    IF  AVAILABLE tt-infoass THEN
        ASSIGN tel_nmprimtl = tt-infoass.nmprimtl.

    RETURN "OK".
END. /* Busca_Dados */

PROCEDURE Valida_Dados:

    DEF VAR aux_msgretor AS CHAR  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN Valida_Dados IN h-b1wgen0085
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT aux_nrseqdig, 
          INPUT glb_cddopcao,
          INPUT tel_dsobserv,
          INPUT tel_flgprior,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
                  
           RETURN "NOK".    
        END.

    RETURN "OK".
END. /* Valida_Dados */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.

    IF  VALID-HANDLE(h-b1wgen0085) THEN
        DELETE OBJECT h-b1wgen0085.

    IF  NOT VALID-HANDLE(h-b1wgen0085) THEN
        RUN sistema/generico/procedures/b1wgen0085.p 
            PERSISTENT SET h-b1wgen0085.

    RUN Grava_Dados IN h-b1wgen0085
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT aux_nrseqdig, 
          INPUT tel_dsobserv,
          INPUT tel_flgprior,
          INPUT glb_cddopcao,
          INPUT glb_dtmvtolt,
          INPUT YES,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
                  
           RETURN "NOK".
        END.

    RETURN "OK".
END. /* Grava_Dados */

PROCEDURE Confirma:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       aux_confirma = "S".

       glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       glb_cdcritic = 0.
       LEAVE.

    END.

    IF   glb_cddopcao = "E"  THEN
         DO:
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                  aux_confirma <> "S"                  THEN
                  DO:
                      glb_cdcritic = 79.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      RETURN "NOK".
                  END.
         END.
    ELSE
         DO:
             IF   NOT KEYFUNCTION(LASTKEY) = "END-ERROR"   AND
                  aux_confirma = "S"                       THEN
                  DO:
                      glb_cdcritic = 79.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      RETURN "NOK".
                  END. 
         END.

    RETURN "OK".

END PROCEDURE.
