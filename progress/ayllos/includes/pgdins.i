/*.............................................................................

   Programa: Includes/pgdins.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 12/04/2011

   Dados referentes ao programa:
   
   Frequencia: Diario (Online).
   Objetivo  : Chamada pela includes/pgdeve.i para realizar as pre-inscricoes
               do evento do progrid para o cooperado.
                              
   Alteracoes: 24/08/2009 - Mostrar mensagem quando o evento eh exclusivo a
                            cooperados e mensagem de confirmacao avisando 
                            que o evento ja tem inscricoes com aquela conta
                            (se tiver). Aproveitar o fontes/confirma.p
                            (Gabriel).

               24/09/2009 - Padronizacao da BO.
                            Impressao do termo somente quando confirmar a 
                            pre-inscricao. (Gabriel).
                            
               23/10/2009 - Utilizar os graus de parentesco com temp-table
                            para melhorar desempenho (Gabriel).    
                            
               16/06/2010 - Trazer como parametro se o evento é exclusivo
                            a cooperados (Gabriel).                      
                            
               07/02/2011 - Incluir nome da tabela no By da data (Gabriel)   
               
               12/04/2011 - Incluir validação para não gravar o ponto de
                            interrogação no campo telefone (Isara - RKAM).
                                                                      
.............................................................................*/

ON RETURN OF tel_nmextttl DO:

    APPLY "GO".
    
END.    

ON 'LEAVE' OF tt-info-cooperado.cdgraupr DO: 

    FIND FIRST tt-grau-parentesco WHERE
         tt-grau-parentesco.cdgraupr = INPUT tt-info-cooperado.cdgraupr
         NO-LOCK NO-ERROR.

    IF   AVAILABLE tt-grau-parentesco THEN
         DO:
             tt-info-cooperado.dsgraupr = 
                    tt-grau-parentesco.dsgraupr.
         END.
    ELSE
         DO:
             tt-info-cooperado.dsgraupr = "NAO ENCONTRADO".
         END.
         
    DISPLAY tt-info-cooperado.dsgraupr
            WITH FRAME f_pre_inscricao_2.

END.

INSCRICAO:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   RUN pre-inscricao IN h-b1wgen0039 (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad, 
                                      INPUT glb_dtmvtolt,
                                      INPUT tel_nrdconta,
                                      INPUT tt-eventos-andamento.rowidadp,
                                      INPUT 1,
                                      INPUT 1,
                                      INPUT glb_nmdatela,
                                      INPUT FALSE,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-info-cooperado,
                                     OUTPUT TABLE tt-grau-parentesco,
                                     OUTPUT TABLE tt-inscricoes-conta,
                                     OUTPUT par_flgcoope). 

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF   AVAILABLE tt-erro   THEN
                 DO:
                     MESSAGE tt-erro.dscritic.
                     LEAVE.
                 END.
        END.

   ASSIGN aux_nmextttl = "".

   /* Monta lista de titulares */
   FOR EACH tt-info-cooperado NO-LOCK:
    
       aux_nmextttl = IF   aux_nmextttl  = ""  THEN
                           STRING(tt-info-cooperado.idseqttl) + " - " + 
                           tt-info-cooperado.nminseve
                      ELSE
                           aux_nmextttl + "," + 
                           STRING(tt-info-cooperado.idseqttl) +
                           " - " + tt-info-cooperado.nminseve. 
   END.
    
   tel_nmextttl:LIST-ITEMS IN FRAME f_pre_inscricao_2 = aux_nmextttl.
    
   DISPLAY tt-eventos-andamento.nmevento
           tt-eventos-andamento.dsrestri
           WITH FRAME f_pre_inscricao.
   
   PAUSE 0.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          /* Se existe mais de um titular */
      IF  INDEX(aux_nmextttl,",") > 0  THEN
          DO:
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                 UPDATE tel_nmextttl WITH FRAME f_pre_inscricao_2.
                 LEAVE.
   
              END. /* Fim do DO WHILE TRUE */
   
              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   LEAVE.
          END.
          
      DISPLAY tel_nmextttl WITH FRAME f_pre_inscricao_2.
       
      aux_idseqttl = INTE(SUBSTR(tel_nmextttl:SCREEN-VALUE,1,1)).
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
         UPDATE tel_tpinseve WITH FRAME f_pre_inscricao_2.
         LEAVE.   
 
      END.
    
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           IF   INDEX(aux_nmextttl,",") > 0  THEN
                NEXT.
           ELSE 
                LEAVE.
           
      IF   tel_tpinseve   THEN    /* Propria */
           DO:
               FIND FIRST tt-info-cooperado WHERE 
                    tt-info-cooperado.idseqttl = aux_idseqttl NO-ERROR.
      
               IF   tt-info-cooperado.cdgraupr = 0  THEN 
                    ASSIGN  tt-info-cooperado.cdgraupr = 9.
           END.
      ELSE                        /* Outra pessoa */
           DO:
               CREATE tt-info-cooperado.
               ASSIGN tt-info-cooperado.idseqttl = aux_idseqttl.
           END.  
      
      DISPLAY tt-info-cooperado.cdgraupr
              tt-info-cooperado.dsgraupr
              tt-info-cooperado.nminseve WITH FRAME f_pre_inscricao_2.
   
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
         UPDATE tt-info-cooperado.cdgraupr WHEN NOT tel_tpinseve
                tt-info-cooperado.nminseve WHEN NOT tel_tpinseve
                tt-info-cooperado.dsdemail
                tt-info-cooperado.nrdddins
                tt-info-cooperado.nrtelefo
                tt-info-cooperado.dsobserv 
                tt-info-cooperado.flgdispe
                WITH FRAME f_pre_inscricao_2.

         IF STRING(tt-info-cooperado.nrtelefo) = STRING(?) THEN
             DO:
                 MESSAGE "Numero de telefone invalido.".
        
                 NEXT-PROMPT tt-info-cooperado.nrtelefo
                             WITH FRAME f_pre_inscricao_2.

                 NEXT.            
             END.

         IF  tt-info-cooperado.dsdemail = ""   AND 
             (tt-info-cooperado.nrdddins = 0   OR 
              tt-info-cooperado.nrtelefo = 0)  THEN
             DO:
                 MESSAGE "O campo de e-mail ou telefone deve ser prenchido.".
        
                 NEXT-PROMPT tt-info-cooperado.dsdemail
                             WITH FRAME f_pre_inscricao_2.

                 NEXT.            
             END.
         
         LEAVE.
                             
      END.
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           DO:
               CLEAR FRAME f_pre_inscricao_2.
               NEXT INSCRICAO. /* Executa a procedure de novo ... */
           END.
               
           /* Ja possui inscricoes para este evento */
      IF   TEMP-TABLE tt-inscricoes-conta:HAS-RECORDS   THEN
           DO:
               ASSIGN aux_contador = 0
                      aux_dsdetalh = "".
                       
               /* Contabiliza inscricoes */
               FOR EACH tt-inscricoes-conta NO-LOCK:
               
                   aux_contador = aux_contador + 1.
          
                   IF   aux_contador > 3   THEN
                        DO:
                            aux_dsdetalh = "**Existem mais pre-inscricoes**".
                            LEAVE.
                        END.
               END.
               
               CLEAR FRAME f_possui_2 ALL NO-PAUSE.
               
               DISPLAY aux_dsdetalh WITH FRAME f_possui. 

               PAUSE 0. 
            
               ASSIGN aux_contador = 0.
               
               /* Avisar usuario que ja existe inscricao para este evento */

               FOR EACH tt-inscricoes-conta NO-LOCK 
                        BY DATE(tt-inscricoes-conta.dtmvtolt) DESC:
                    
                   aux_contador = aux_contador + 1.
                    
                   IF   aux_contador > 3  THEN
                        LEAVE.

                   DISPLAY tt-inscricoes-conta.nmresage 
                           tt-inscricoes-conta.dtmvtolt 
                           tt-inscricoes-conta.nminseve WITH FRAME f_possui_2.
                           
                   DOWN WITH FRAME f_possui_2.        
                    
               END.    

               DISPLAY tel_confirma
                       tel_confirm2 WITH FRAME f_possui_3.

               NEXT-PROMPT tel_confirma WITH FRAME f_possui_3.
               
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                  CHOOSE FIELD tel_confirma
                               tel_confirm2 WITH FRAME f_possui_3.
                        
                  LEAVE.
                  
               END.         

               HIDE FRAME f_possui
                    FRAME f_possui_2
                    FRAME f_possui_3.

               IF   FRAME-FIELD = "tel_confirma"         OR
                    KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.

           END.
      
           /* Se nao cooperado ...e exclusivo p/ eles*/
 
      IF   NOT tel_tpinseve   AND 
           par_flgcoope       THEN
           DO:
               aux_flginscr = NO.
               
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  MESSAGE "Evento exclusivo para cooperados." + 
                          "Confirma inscricao de um nao cooperado?"
                                
                  VIEW-AS ALERT-BOX BUTTONS YES-NO UPDATE aux_flginscr.

                  LEAVE.
                  
               END. 
                 
               IF   aux_flginscr = NO   OR
                    aux_flginscr = ?    THEN
                    NEXT.

           END.
      
      RUN fontes/confirma.p (INPUT "",
                             OUTPUT aux_confirma).
                             
      IF   aux_confirma <> "S"  THEN
           NEXT.

      RUN grava-pre-inscricao IN h-b1wgen0039 
                                 (INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT glb_cdoperad,
                                  INPUT glb_dtmvtolt,
                                  INPUT tel_nrdconta,
                                  INPUT tt-eventos-andamento.rowidedp,
                                  INPUT tt-eventos-andamento.rowidadp,
                                  INPUT tel_tpinseve,
                                  
                                  INPUT tt-info-cooperado.cdgraupr,
                                  INPUT tt-info-cooperado.dsdemail,
                                  INPUT tt-info-cooperado.dsobserv,
                                  INPUT tt-info-cooperado.flgdispe,
                                  INPUT tt-info-cooperado.nminseve,
                                  INPUT tt-info-cooperado.nrdddins,
                                  INPUT tt-info-cooperado.nrtelefo,
                                  
                                  INPUT tt-info-cooperado.idseqttl,
                                  INPUT 1,
                                  INPUT glb_nmdatela,
                                  INPUT FALSE,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT par_nrdrowid).
      
      IF   RETURN-VALUE <> "OK"   THEN
           DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
               IF   AVAILABLE tt-erro   THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        PAUSE 2 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                    END.
           
               LEAVE.
               
           END.
           
      IF   tt-eventos-andamento.flgcompr   AND  /* Termo de compromisso */
           tt-info-cooperado.flgdispe      THEN /* Dispensa confirmacao */ 
           DO:   

               { includes/pgdter.i }

           END.
      
      LEAVE.
      
   END. /* Fim do DO WHILE TRUE */
  
   CLEAR FRAME f_pre_inscricao_2.   
   
   HIDE FRAME f_pre_inscricao. 

   HIDE FRAME f_pre_inscricao_2. 

   LEAVE.

END.  /* Fim do DO WHILE TRUE */

/*............................................................................*/
