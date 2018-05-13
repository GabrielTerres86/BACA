/*.............................................................................
   
   Programa: Fontes/extapl.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004.                     Ultima atualizacao: 22/08/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela extapl.

   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando
               
               25/01/2007 - Listar Poup. Programada se estiver ativa ou se 
                            possuir saldo positivo (David).
               
               21/05/2007 - Incluida aplicacoes RDC PRE e POS na impressao de
                            extratos (Elton).
               
               04/10/2007 - Alimentar temp-table para mostrar data da aplicacao
                            (Guilherme).
                            
               22/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
                
............................................................................ */

{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

{ includes/var_extapl.i "NEW"}


DEF VAR aux_descapli AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR h-b1wgen0103 AS HANDLE                                         NO-UNDO.

VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN tel_nrsequen = 0
       tel_nrdconta = 0.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DISPLAY glb_cddopcao tel_nrdconta  WITH FRAME f_opcao.

CLEAR FRAME f_listafinc ALL.
HIDE MESSAGE NO-PAUSE.

DO WHILE TRUE:
                        
    CLEAR FRAME f_listafinc ALL.
    HIDE FRAME f_listafinc NO-PAUSE.

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_opcao
        EDITING:
            READKEY.
            IF  FRAME-FIELD = "tel_nrdconta"   AND
                LASTKEY = KEYCODE("F7")        THEN
                DO: 
                    RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                  OUTPUT aux_nrdconta).
       
                    IF  aux_nrdconta > 0   THEN
                        DO:
                            ASSIGN tel_nrdconta = aux_nrdconta.
                            DISPLAY tel_nrdconta WITH FRAME f_opcao.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */

        LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   HIDE MESSAGE NO-PAUSE.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            
            VIEW FRAME f_moldura.
            PAUSE(0).
            VIEW FRAME f_opcao.
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "extapl"   THEN
                 DO:

                    IF  VALID-HANDLE(h-b1wgen0103) THEN
                        DELETE OBJECT h-b1wgen0103.

                     HIDE FRAME f_moldura.
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_listafinc.
                     HIDE FRAME f_alterar.
                     HIDE FRAME f_consultar.
                     HIDE FRAME f_excluir.
                     HIDE FRAME f_manutencao.
                     HIDE FRAME f_moldura_extra.
                     HIDE FRAME f_moldura_especial.
                     HIDE FRAME f_extra.
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

   ASSIGN aux_flgretor = TRUE.
   
   IF  glb_cddopcao = "C" THEN
       DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
            
           RUN Busca_Dados.
           LEAVE.
        END.
   ELSE
        IF   glb_cddopcao = "A"   THEN
             DO: 
                 { includes/extapla.i } 
             END.

END.

IF  VALID-HANDLE(h-b1wgen0103) THEN
    DELETE OBJECT h-b1wgen0103.

/*****************************************************************************/

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-infoass.
    EMPTY TEMP-TABLE tt-extapl.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.

    RUN Busca_Extapl IN h-b1wgen0103
        ( INPUT glb_cdcooper, 
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT glb_cddopcao,
          INPUT YES,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-extapl,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    ELSE
        DO:
            IF  glb_cddopcao = "C" THEN
                DO:
                    OPEN QUERY blistafin-q FOR EACH tt-extapl NO-LOCK.
                          
                    ENABLE blistafin-b WITH FRAME f_listafinc.
        
                    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
                END.

        END.
        
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.
    
    RUN Valida_Extapl IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT aux_cddopcao,
          INPUT tel_nrdconta,
          INPUT aux_tpaplica,
          INPUT aux_nraplica,
          INPUT aux_tpemiext,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.
            
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
             
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE. /* Valida_Dados */


PROCEDURE Grava_Dados:
    
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.
    
    RUN Grava_Extapl IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT 1, /*idseqttl*/
          INPUT aux_cddopcao,
          INPUT aux_descapli,
          INPUT aux_tpaplica,
          INPUT aux_nraplica,
          INPUT aux_tpemiext,
          INPUT TRUE, /*flgerlog*/
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.
          
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".
        END.

    IF  aux_msgretor <> "" THEN
        MESSAGE aux_msgretor.

    IF  VALID-HANDLE(h-b1wgen0103) THEN
        DELETE OBJECT h-b1wgen0103.

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.
    
    RETURN "OK".

END PROCEDURE. /* Grava_Dados */


/* .......................................................................... */

