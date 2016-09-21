/* .............................................................................

   Programa: fontes/gt0011.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2005.                       Ultima atualizacao: 06/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela GT0011.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
               27/01/2006 - Inclusao de EXCLUSIVE-LOCK NO-ERROR para o FIND
                            da tabela gnbdirf.
               16/04/2012 - Fonte substituido por gt0011p.p (Tiago).
               
               06/12/2013 - Inclusao de VALIDATE gnrdirf (Carlos)
.............................................................................*/
{ includes/var_online.i }

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR tel_dspessoa AS CHAR                                  NO-UNDO.
DEF        VAR tel_lbldescr AS CHAR                                  NO-UNDO.

DEF BUTTON btn_salvar   LABEL "SALVAR".
DEF BUTTON btn_cancelar LABEL "CANCELAR".

DEF QUERY q_dirf FOR gnrdirf.

DEF BROWSE b_dirf QUERY q_dirf
    DISPLAY gnrdirf.cdretenc  NO-LABEL  FORMAT "9999"
            WITH 12 DOWN NO-BOX.

DEF BUFFER gnbdirf FOR gnrdirf.

FORM SKIP(1)
     glb_cddopcao     AT 15 LABEL "Opcao"    AUTO-RETURN
                            HELP "Informe a opcao desejada (A, C, E ou I)"
                            VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                     "014 - Opcao errada.")
     SKIP(1)
     gnrdirf.inpessoa AT 15 LABEL "Tipo de Pessoa"
        HELP "Informe o tipo (1-Fisica / 2-Juridica / 3-Fisica ou Juridica)."
                            VALIDATE(INPUT gnrdirf.inpessoa >= 1 AND 
                                     INPUT gnrdirf.inpessoa <= 3,
                                     "436 - Tipo de pessoa errado.")
     tel_dspessoa     AT 32 NO-LABEL            FORMAT "x(25)"
     SKIP(2)
     tel_lbldescr     AT 15 LABEL "Descricao"   FORMAT "x(1)"
     gnrdirf.cdretenc AT 30 LABEL "Cod."        FORMAT "9999"
                            VALIDATE(NOT CAN-FIND(gnbdirf WHERE
                                                          gnbdirf.cdretenc = 
                                                    INPUT gnrdirf.cdretenc) AND
                                     INPUT gnrdirf.cdretenc > 0,
                                     "Codigo ja existente ou igual a ZERO!")
     SKIP(1)
     gnrdirf.dsretenc AT 15 NO-LABEL VIEW-AS EDITOR INNER-LINES 7
                                     INNER-CHARS 63 BUFFER-LINES 7
                                     PFCOLOR 0
           HELP "Informe a descricao do codigo de retencao / TAB para navegar"
                            VALIDATE(INPUT gnrdirf.dsretenc <> "",
                                     "375 - O campo deve ser preenchido.")
     SKIP
     btn_salvar       AT 15
     btn_cancelar     AT 68
     WITH ROW 4 OVERLAY SIDE-LABELS SIZE 80 BY 18 TITLE glb_tldatela
          FRAME f_gt0011.
     
FORM SKIP(1)
     b_dirf                 HELP "Selecione o codigo desejado / F4 para Sair"
     WITH COLUMN 2 ROW 6 TITLE COLOR NORMAL " Codigos " OVERLAY FRAME f_browse.


ON VALUE-CHANGED OF b_dirf DO:

    HIDE MESSAGE NO-PAUSE.

    HIDE gnrdirf.cdretenc IN FRAME f_gt0011.
    HIDE btn_salvar       IN FRAME f_gt0011.
    HIDE btn_cancelar     IN FRAME f_gt0011.
    
    IF   gnrdirf.inpessoa = 1   THEN
         tel_dspessoa = " - Fisica".
    ELSE
    IF   gnrdirf.inpessoa = 2   THEN
         tel_dspessoa = " - Juridica".
    ELSE
    IF   gnrdirf.inpessoa = 3   THEN
         tel_dspessoa = " - Fisica ou Juridica".
    ELSE
         tel_dspessoa = "".
   
    DISPLAY gnrdirf.dsretenc
            gnrdirf.inpessoa
            tel_dspessoa
            tel_lbldescr
            WITH FRAME f_gt0011.
           
END.

ON RETURN OF b_dirf DO:

    IF   NOT AVAILABLE gnrdirf   THEN
         NEXT.
         
    IF   glb_cddopcao = "A"   THEN
         DO:
            DISPLAY gnrdirf.cdretenc WITH FRAME f_gt0011.
            
            UPDATE gnrdirf.dsretenc 
                   btn_salvar
                   btn_cancelar
                   WITH FRAME f_gt0011.
         END.                
    ELSE
    IF   glb_cddopcao = "E"   THEN
         DO:
            RUN confirma.
            
            IF   aux_confirma <> "S"   THEN
                 NEXT.
            
            FIND gnbdirf WHERE gnbdirf.cdretenc = gnrdirf.cdretenc   AND
                               gnbdirf.dsretenc = gnrdirf.dsretenc   AND
                               gnbdirf.inpessoa = gnrdirf.inpessoa
                               EXCLUSIVE-LOCK NO-ERROR.
                          
                               
            IF   AVAILABLE gnbdirf   THEN                               
                 DELETE gnbdirf.

            
            HIDE tel_dspessoa     IN FRAME f_gt0011.
            HIDE tel_lbldescr     IN FRAME f_gt0011.
            HIDE gnrdirf.cdretenc IN FRAME f_gt0011.
            HIDE gnrdirf.dsretenc IN FRAME f_gt0011.
            HIDE gnrdirf.inpessoa IN FRAME f_gt0011.
            
            CLOSE QUERY q_dirf.
            OPEN QUERY q_dirf FOR EACH gnrdirf NO-LOCK.
            
            APPLY "VALUE-CHANGED" TO BROWSE b_dirf.   /* atualizar os dados */
            PAUSE (0).

         END.

END.

ON CHOOSE OF btn_salvar DO:

    RUN confirma.
    
    IF   aux_confirma <> "S"  THEN
         NEXT.
         
    IF   glb_cddopcao = "A"   THEN
         DO:
            FIND gnbdirf WHERE gnbdirf.cdretenc = gnrdirf.cdretenc   AND
                               gnbdirf.inpessoa = gnrdirf.inpessoa
                               EXCLUSIVE-LOCK NO-ERROR.
                               
                             
            IF   AVAILABLE gnbdirf   THEN
                 ASSIGN gnbdirf.dsretenc = gnrdirf.dsretenc.
                 
            APPLY "GO".   /* para voltar ao browse */                 
         END.
    ELSE
    IF   glb_cddopcao = "I"   THEN
         APPLY "GO".    /* para voltar ao browse */
          
END.

ON CHOOSE OF btn_cancelar DO:
    
    HIDE gnrdirf.cdretenc IN FRAME f_gt0011.
    HIDE btn_salvar       IN FRAME f_gt0011.
    HIDE btn_cancelar     IN FRAME f_gt0011.
    
    APPLY "VALUE-CHANGED" TO BROWSE b_dirf.     /* atualizar os dados */
    PAUSE (0).
    
    APPLY "END-ERROR".  /* para voltar ao browse sem salvar */
END.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    HIDE FRAME f_browse.
    HIDE tel_dspessoa     IN FRAME f_gt0011.
    HIDE tel_lbldescr     IN FRAME f_gt0011.
    HIDE gnrdirf.cdretenc IN FRAME f_gt0011.
    HIDE gnrdirf.dsretenc IN FRAME f_gt0011.
    HIDE gnrdirf.inpessoa IN FRAME f_gt0011.
    HIDE btn_salvar       IN FRAME f_gt0011.
    HIDE btn_cancelar     IN FRAME f_gt0011.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_gt0011.
        LEAVE.
        
    END.
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "GT0011"   THEN
                  DO:
                      HIDE FRAME f_gt0011.
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.

    
    IF   aux_cddopcao <> glb_cddopcao THEN
         { includes/acesso.i }

    IF   glb_cddopcao <> "C"   THEN   /* permitir A,E,I somente para CECRED */
         DO:
            FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
                        
            IF   NOT AVAILABLE crapcop   OR
                 crapcop.cdcooper <> 3   THEN
                 DO:
                    glb_cdcritic = 36.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                 END.
         END.

    IF   glb_cddopcao = "I"   THEN
         DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                CREATE gnrdirf.

                DISPLAY tel_lbldescr WITH FRAME f_gt0011.
            
                UPDATE gnrdirf.inpessoa
                       gnrdirf.cdretenc
                       gnrdirf.dsretenc 
                       btn_salvar
                       btn_cancelar
                       WITH FRAME f_gt0011.

                VALIDATE gnrdirf.

                LEAVE.

            END. /* fim DO WHILE TRUE */
            
            NEXT.
         END.
    
    OPEN QUERY q_dirf FOR EACH gnrdirf NO-LOCK.
    
    APPLY "VALUE-CHANGED" TO BROWSE b_dirf.     /* atualizar os dados */
    PAUSE(0).
    
    UPDATE b_dirf WITH FRAME f_browse.
         
END.     

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

/* .......................................................................... */

