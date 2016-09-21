/* ............................................................................

   Programa: Fontes/sldccr_l.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                           Ultima atualizacao: 01/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para liberar, cancelar  cartoes de credito.

   Alteracoes: 01/09/98 - Tratar administradoras de cartao (odair)

             31/07/2002 - Incluir nova situacao da conta (Margarete).
             
             07/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
             
             13/02/2006 - Nao modificar o 'insitcrd' se for administradora da
                          conta integracao (Evandro).
                          
             19/06/2006 - Bloqueada opcao de liberacao para Cartao BB (Diego).
             
             10/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                          (GATI - Eder)
                          
             05/09/2011 - Incluido a chamada da procedure alerta_fraude
                          (Adriano).
                          
             01/04/2013 - Retirado a chamada da procedure alerta_fraude
                          (Adriano).             
                          
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.
                                                                     
DEF VAR tel_dslibera AS CHAR INIT "Liberar"  FORMAT "x(07)"            NO-UNDO.
DEF VAR tel_dsdesfaz AS CHAR INIT "Desfazer" FORMAT "x(08)"            NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     tel_dslibera AT  5
     tel_dsdesfaz AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY CENTERED  WIDTH 40
     NO-LABELS TITLE COLOR NORMAL " Liberacao " FRAME f_libera.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN verifica_cartao_bb IN h_b1wgen0028
                            (INPUT glb_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT par_cdadmcrd,
                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h_b1wgen0028.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            RETURN "NOK".
        END.
     
    DISPLAY tel_dslibera tel_dsdesfaz WITH FRAME f_libera.
      
    CHOOSE FIELD tel_dslibera
           HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
                 tel_dsdesfaz
           HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
           WITH FRAME f_libera.
             
    HIDE MESSAGE NO-PAUSE.

    IF  FRAME-VALUE = tel_dslibera  THEN /* Liberar */
        DO:
            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.
            
            RUN libera_cartao IN h_b1wgen0028
                            (INPUT glb_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT glb_cdoperad,
                             INPUT tel_nrdconta,
                             INPUT glb_dtmvtolt,
                             INPUT 1,
                             INPUT 1,
                             INPUT glb_nmdatela,
                             INPUT par_nrctrcrd,
                             INPUT 1, /* Indicador de confirmacao */
                            OUTPUT TABLE tt-msg-confirma,
                            OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h_b1wgen0028.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAIL tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.

                    NEXT.
                END.     
            
            FOR EACH tt-msg-confirma:
            
                aux_confirma = "N".
           
                HIDE MESSAGE NO-PAUSE.
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                    BELL.
                    MESSAGE COLOR NORMAL tt-msg-confirma.dsmensag 
                                  UPDATE aux_confirma.
                           
                    LEAVE.

                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        aux_confirma = "N".
                        LEAVE.
                    END.

            END. /* FOR EACH tt-msg-confirma */
           
            IF  aux_confirma <> "S"  THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    glb_cdcritic = 0.

                    BELL.
                    MESSAGE glb_dscritic.
                     
                    NEXT.
                END.
           
            /** Reexecucao apos mensagens de confirmacao **/
            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.
            
            RUN libera_cartao IN h_b1wgen0028
                          (INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT glb_cdoperad,
                           INPUT tel_nrdconta,
                           INPUT glb_dtmvtolt,
                           INPUT 1,
                           INPUT 1,
                           INPUT glb_nmdatela,
                           INPUT par_nrctrcrd,
                           INPUT 2, /* Indicador de confirmacao */
                          OUTPUT TABLE tt-msg-confirma,
                          OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h_b1wgen0028.
           
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAIL tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.

                    NEXT.
                END.

        END.
    ELSE
    IF  FRAME-VALUE = tel_dsdesfaz  THEN /* Desfazer liberacao */
        DO: 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                glb_cdcritic = 0.
                
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.

                LEAVE.
            
            END.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                aux_confirma <> "S"                 THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    glb_cdcritic = 0.
                    
                    BELL.
                    MESSAGE glb_dscritic.
                    
                    NEXT.
                END.
                
            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.
            
            RUN desfaz_liberacao_cartao IN h_b1wgen0028
                          (INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT glb_cdoperad,
                           INPUT tel_nrdconta,
                           INPUT glb_dtmvtolt,
                           INPUT 1,
                           INPUT 1,
                           INPUT glb_nmdatela,
                           INPUT par_nrctrcrd,
                           OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h_b1wgen0028.
           
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAIL tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.

                    NEXT.
                END.
        END.

    LEAVE.     

END. /* DO WHILE TRUE */

HIDE FRAME f_libera NO-PAUSE.

RETURN "OK".

/* ......................................................................... */
