/* ............................................................................

   Programa: Fontes/sldccr_db.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Abril/2006.                        Ultima atualizacao: 01/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para alteracao do limite de debito.

   Alteracoes: 10/06/2008 - Criticar valor limite total de cartoes BB da
                            Coperativa mediante ao BB (Guilherme).
               
               13/02/2009 - Gerar log de alteracao do limite (Gabriel).
               
               16/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)
                            
               05/09/2011 - Incluido a chamada da procedure alerta_fraude
                            (Adriano).
                            
               01/04/2013 - Retirado a chamada da procedure alerta_fraude
                            (Adriano).             
                            
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.

DEF VAR tel_vllimite AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     par_nrcrcard LABEL "Numero do cartao" COLON 25 
                  FORMAT "9999,9999,9999,9999"
     SKIP(1)
     tel_vllimite LABEL "Valor do limite"  COLON 25
                  HELP "Entre com o valor do limite de debito"
     SKIP(1)
     WITH SIDE-LABELS ROW 9
     OVERLAY CENTERED TITLE COLOR NORMAL " Alteracao de limite " 
     FRAME f_limite.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0028.p 
        PERSISTENT SET h_b1wgen0028.
    
    RUN carrega_dados_limdeb_cartao IN h_b1wgen0028
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
                            OUTPUT TABLE tt-limite_deb_cartao,
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
             
    FIND tt-limite_deb_cartao NO-ERROR.
    
    IF  NOT AVAIL tt-limite_deb_cartao  THEN 
        RETURN "NOK".
    
    ASSIGN tel_vllimite = tt-limite_deb_cartao.vllimdeb.

    DISPLAY par_nrcrcard WITH FRAME f_limite.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_vllimite  WITH FRAME f_limite

        EDITING:
        
            READKEY.

            IF  FRAME-FIELD = "tel_vllimite"  THEN
                IF  LASTKEY = KEYCODE(".")  THEN
                    APPLY 44.
                ELSE
                    APPLY LASTKEY.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */
            
        LEAVE.

    END. /* FIM do DO WHILE TRUE */
  
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_limite NO-PAUSE.
            RETURN "NOK".
        END.
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         aux_confirma = "N".
         glb_cdcritic = 78.
         RUN fontes/critic.p.
         glb_cdcritic = 0.   
         
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         
         LEAVE.

    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
        aux_confirma <> "S"                 THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.

            HIDE FRAME f_limite NO-PAUSE.
             
            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN altera_limdeb_cartao IN h_b1wgen0028
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
                                    INPUT tel_vllimite,
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
        
        MESSAGE tt-msg-confirma.dsmensag.
        PAUSE.
    
    END.

    HIDE FRAME f_limite NO-PAUSE.
   
    LEAVE.

END. /* DO WHILE TRUE */
   
RETURN "OK".

/*.......................................................................... */
