/* .............................................................................

   Programa: Fontes/emsavs.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Junho/2005                          Ultima Atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir cadastro de associados para geracao de avisos de debito
               em conta corrente.
                      
   ALTERACAO : 27/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               17/09/2008 - Incluido campo tipo de documento e opcao "A". 
                            Alteracoes no relatorio gerado.
                            Gerar log em cadcex.log (Gabriel).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               05/12/2013 - Inclusao de VALIDATE crapcex (Carlos)
               
               27/12/2013 - Aumentado o tamanho do campo tel_dsdemail para 
                            "x(40)". (Reinert)
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */
{ includes/var_online.i }

DEF STREAM str_1. /* Relacao de Avisos */

 /*** cabecalho do relatorio ***/                      
DEF  VAR rel_nmresemp  AS CHAR   FORMAT "x(15)"                         NO-UNDO.
DEF  VAR rel_nmrelato  AS CHAR   FORMAT "x(40)" EXTENT 5                NO-UNDO.
DEF  VAR rel_nrmodulo  AS INT    FORMAT "9"                             NO-UNDO.
DEF  VAR rel_nmempres  AS CHAR   FORMAT "x(15)"                         NO-UNDO.
DEF  VAR rel_nmmodulo  AS CHAR   FORMAT "x(15)" EXTENT 5
                                 INIT ["","","","",""]                  NO-UNDO.
DEF  VAR rel_nmarqimp  AS CHAR                                          NO-UNDO.

DEF  VAR tel_nrdconta  AS INT    FORMAT "zzzz,zzz,9"                    NO-UNDO.
DEF  VAR tel_nmprimtl  LIKE      crapass.nmprimtl                       NO-UNDO.
DEF  VAR tel_cdagenci  LIKE      crapass.cdagenci                       NO-UNDO.
DEF  VAR aux_confirma  AS CHAR   FORMAT "!(1)"                          NO-UNDO.
DEF  VAR aux_cddopcao  AS CHAR                                          NO-UNDO.

DEF  VAR tel_hrtransa  LIKE      crapcem.hrtransa                       NO-UNDO.
DEF  VAR tel_cddemail  LIKE      crapcex.cddemail                       NO-UNDO.
DEF  VAR tel_dsdemail  LIKE      crapcem.dsdemail                       NO-UNDO.
DEF  VAR tel_cdperiod  LIKE      crapcex.cdperiod                       NO-UNDO.
DEF  VAR tel_dsperiod  AS CHAR   FORMAT "x(10)"                         NO-UNDO.
DEF  VAR tel_tpextrat  AS INT    FORMAT "9"                             NO-UNDO.
DEF  VAR tel_dtmvtolt  AS DATE   FORMAT "99/99/9999"                    NO-UNDO.
DEF  VAR tel_cdoperad  AS CHAR   FORMAT "x(10)"                         NO-UNDO.
DEF  VAR tel_nmoperad  AS CHAR   FORMAT "x(35)"                         NO-UNDO.

/* Variavel para log */
DEF  VAR aux_cddemail  AS INT                                           NO-UNDO.

DEF  VAR aux_nmendter  AS CHAR   FORMAT "x(20)"                         NO-UNDO.
DEF  VAR aux_nmarqimp  AS CHAR                                          NO-UNDO.
DEF  VAR par_flgrodar  AS LOGI                                          NO-UNDO.

DEF  VAR aux_flgescra  AS LOGI                                          NO-UNDO.
DEF  VAR aux_dscomand  AS CHAR                                          NO-UNDO.
DEF  VAR par_flgfirst  AS LOG    INIT TRUE                              NO-UNDO.
DEF  VAR aux_contador  AS INT    FORMAT "99"                            NO-UNDO.
DEF  VAR tel_dsimprim  AS CHAR   FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF  VAR tel_dscancel  AS CHAR   FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF  VAR par_flgcance  AS LOG                                           NO-UNDO.

DEF  TEMP-TABLE w-documentos                                            NO-UNDO
     FIELD tpextrat    AS INT    FORMAT "9"
     FIELD dsextrat    AS CHAR   FORMAT "x(25)"
     INDEX w-dcto1     AS PRIMARY UNIQUE tpextrat.

DEF  QUERY q-documentos FOR w-documentos.

DEF  BROWSE b-documentos QUERY q-documentos 
     DISP   w-documentos.tpextrat COLUMN-LABEL "Tipo"
            w-documentos.dsextrat COLUMN-LABEL "Descricao"
            WITH 2 DOWN TITLE " Documentos ".

DEF  QUERY q-emails     FOR crapcem.

DEF  BROWSE b-emails QUERY q-emails
     DISP   crapcem.cddemail      COLUMN-LABEL "Cod."
            crapcem.dsdemail      COLUMN-LABEL "Email "  FORMAT "x(35)"
           WITH 2 DOWN TITLE " Emails ".

FORM SKIP(2)
     glb_cddopcao AT 3  LABEL "Opcao" AUTO-RETURN
     HELP "Entre com a opcao desejada (C ,A ,I ,E ,R)."
     VALIDATE(CAN-DO("A,C,I,E,R",STRING(glb_cddopcao)),"014 - Opcao errada.") 
     SKIP(13)
     
     WITH OVERLAY ROW 4 SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_opcao.
     
FORM SKIP
     tel_nrdconta AT 22 LABEL "Conta"  
     HELP "Digite o numero da  conta."
         
     tel_nmprimtl       NO-LABEL FORMAT "x(25)"
     
     SKIP(1)
     tel_tpextrat AT 13 LABEL "Tipo documento"
     HELP "Digite o Tipo de documento ou pressione <F7> p/ listar."
     VALIDATE(CAN-DO("3,5",STRING(tel_tpextrat)),"Tipo de documento invalido.")
     
     SKIP(1)
     
     tel_dsperiod AT 20 LABEL "Periodo"
     
     SKIP(1)
     
     tel_dsdemail AT 22 LABEL "Email" FORMAT "x(40)"
     HELP "Digite o e-mail ou <F7> p/ listar."
     
     WITH OVERLAY NO-BOX ROW 9 SIDE-LABELS WIDTH 78 CENTERED FRAME f_dados.

FORM tel_cdoperad AT 19 LABEL "Operador"    

     tel_nmoperad AT 41 NO-LABEL
     SKIP (1)
     
     tel_dtmvtolt AT 23 LABEL "Data"
     SKIP(1)
     WITH OVERLAY ROW 17 SIDE-LABELS NO-BOX WIDTH 78 CENTERED FRAME f_consulta.

FORM SKIP
     tel_cdagenci AT 13 LABEL "PA" 
     HELP "Digite o codigo do PA."
     
     SKIP(1)
     tel_tpextrat AT 13 LABEL "Tipo Documento"
     HELP "Digite o Tipo de documento ou pressione <F7> p/ listar."
     VALIDATE(CAN-DO("3,5",STRING(tel_tpextrat)),"Tipo de documento invalido.")
     
     WITH SIDE-LABELS ROW 9 NO-BOX OVERLAY WIDTH 78 CENTERED FRAME f_relatorio.
                          
FORM SKIP(1)
     b-documentos
     HELP "Use SETAS p/ navegar e <ENTER> p/ escolher o tipo de documento."
     
     WITH COLUMN 33 NO-BOX ROW 10 OVERLAY FRAME f_documentos.

FORM SKIP(1)
     b-emails
     HELP "Use as <SETAS> p/ navegar e <ENTER> p/ escolher o email."
     
     WITH COLUMN 30 NO-BOX ROW 14 OVERLAY FRAME f_emails.

FUNCTION fun_consulta RETURN LOGICAL:  

    FIND crapcex WHERE crapcex.cdcooper = glb_cdcooper   AND
                       crapcex.nrdconta = tel_nrdconta   AND
                       crapcex.tpextrat = tel_tpextrat 
                       NO-LOCK NO-ERROR.
                 
    IF   NOT AVAILABLE crapcex   THEN
         DO: 
             glb_cdcritic = 851.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             PAUSE 1 NO-MESSAGE.
             HIDE FRAME f_dados NO-PAUSE.
             RETURN FALSE.
         END. 
        
    FIND crapope WHERE crapope.cdcooper = glb_cdcooper   AND
                       crapope.cdoperad = crapcex.cdoperad 
                       NO-LOCK NO-ERROR.
         
    FIND crapcem WHERE crapcem.cdcooper = glb_cdcooper   AND
                       crapcem.nrdconta = tel_nrdconta   AND
                       crapcem.idseqttl = 1              AND
                       crapcem.cddemail = crapcex.cddemail
                       NO-LOCK NO-ERROR.
    
    IF   AVAILABLE crapcem   THEN
         tel_dsdemail = crapcem.dsdemail.
    ELSE
         tel_dsdemail = "".

    ASSIGN tel_cdoperad = crapope.cdoperad  
           tel_nmoperad = crapope.nmoperad
           tel_dtmvtolt = crapcex.dtmvtolt
           tel_hrtransa = crapcex.hrtransa
           tel_cdperiod = crapcex.cdperiod
           tel_cddemail = crapcex.cddemail
           tel_dsperiod = IF   crapcex.cdperiod = 1 THEN 
                               "Diario"
                          ELSE
                               "Mensal".
    RETURN TRUE.
         
END FUNCTION.


ON RETURN OF b-documentos IN FRAME f_documentos DO:

    tel_tpextrat = w-documentos.tpextrat.
    
    DISPLAY tel_tpextrat WITH FRAME f_dados.
   
    PAUSE 0.
    
    DISPLAY tel_tpextrat WITH FRAME f_relatorio.
    
    APPLY "GO". 

END.

ON RETURN OF b-emails IN FRAME f_emails DO:

    IF   AVAILABLE crapcem  THEN
         DO:
             ASSIGN tel_cddemail = crapcem.cddemail
                    tel_dsdemail = crapcem.dsdemail.
                                               
             DISPLAY tel_dsdemail WITH FRAME f_dados.
         END.

    APPLY "GO".   

END.      

glb_cddopcao = "C".

RUN fontes/inicia.p.

RUN proc_documentos.

DO WHILE TRUE:
        
    RUN proc_limpa.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE glb_cddopcao WITH FRAME f_opcao.
       LEAVE.
    END.
      
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    
         DO:
             RUN fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "EMSAVS"   THEN
                  DO:
                      HIDE FRAME f_opcao.
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.

    IF   aux_cddopcao <> glb_cddopcao THEN
         DO:
             { includes/acesso.i }
             
             aux_cddopcao = glb_cddopcao.
         END.  
      
    IF   glb_cddopcao = "R"  THEN
         DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_cdagenci 
                       tel_tpextrat WITH FRAME f_relatorio
                
                    EDITING:
                
                        READKEY.
                    
                        IF   FRAME-FIELD = "tel_tpextrat"         AND
                             LASTKEY = KEYCODE("F7")              THEN
                             DO:
                                 OPEN QUERY q-documentos FOR EACH w-documentos
                                                                  NO-LOCK.
                             
                                 DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                    UPDATE b-documentos WITH FRAME f_documentos.
                                    LEAVE.
                                 END.
                             
                                 HIDE FRAME f_documentos.
                                                                         
                                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                      NEXT.
                             END.
                        ELSE
                             APPLY LASTKEY.
                
                    END. /* Fim do EDITING */
             
                LEAVE.
             
             END. /* Fim do DO WHILE TRUE */
             
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.
             
             RUN proc_imprimirelacao.               
             
             HIDE FRAME f_relatorio
                  FRAME f_dados.
            
             LEAVE.
         
         END. /* Fim opcao "R" */

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_nrdconta WITH FRAME f_dados.
        LEAVE.
    END.
        
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
         NEXT.
       
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                       crapass.nrdconta = tel_nrdconta  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass  THEN
         DO: 
             glb_cdcritic = 009.
             RUN fontes/critic.p.
             MESSAGE glb_dscritic.
             PAUSE 1 NO-MESSAGE.
             CLEAR FRAME f_dados.
             glb_cdcritic = 0.
             NEXT.
         END.

    tel_nmprimtl = crapass.nmprimtl.

    DISPLAY tel_nmprimtl WITH FRAME f_dados.                   
    
    DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
        
       UPDATE tel_tpextrat WITH FRAME f_dados

         EDITING:
            
            READKEY.

            IF   LASTKEY = KEYCODE("F7")   THEN
                 DO:
                     OPEN QUERY q-documentos FOR EACH w-documentos NO-LOCK.

                     DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                        UPDATE b-documentos WITH FRAME f_documentos.
                        LEAVE.
                     END.
   
                     HIDE FRAME f_documentos.
                     
                     IF   KEYFUNCTION(LASTKEY)  = "END-ERROR"   THEN
                          NEXT.
                 END.          
            ELSE
                 APPLY LASTKEY.
                 
         END. /* Fim do EDITING */   
         
       LEAVE.

    END.  /* Fim do DO WHILE TRUE */      
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         NEXT.

    IF   glb_cddopcao = "C"  THEN
         DO:
             IF   fun_consulta()   THEN
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                     DISPLAY tel_dsperiod
                             tel_dsdemail WHEN tel_tpextrat = 3
                             WITH FRAME f_dados.
                    
                     PAUSE 0.

                     DISPLAY tel_cdoperad 
                             tel_nmoperad 
                             tel_dtmvtolt WITH FRAME f_consulta.
                 
                     PAUSE.
                         
                     LEAVE.
                      
                  END.  /* Fim do DO WHILE TRUE */
         END.
    ELSE
    IF   glb_cddopcao = "A"   THEN
         DO:
             IF   NOT tel_tpextrat = 3   THEN
                  DO:
                      MESSAGE "Tipo de documento invalido para esta opcao.".
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
                    
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.
             
             IF   NOT fun_consulta()   THEN
                  NEXT.
                      
             FIND CURRENT crapcex EXCLUSIVE-LOCK NO-ERROR.
             
             /* variavel para log */
             aux_cddemail = tel_cddemail.
                      
             DISPLAY tel_dsperiod
                     tel_dsdemail WITH FRAME f_dados.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_dsdemail WITH FRAME f_dados
                      
                    EDITING:
                      
                        READKEY.
                            
                        IF   LASTKEY = KEYCODE("F7")   THEN
                             DO:
                                 OPEN QUERY q-emails FOR EACH crapcem WHERE
                                      crapcem.cdcooper = glb_cdcooper AND
                                      crapcem.nrdconta = tel_nrdconta AND
                                      crapcem.idseqttl = 1       NO-LOCK.
                                                                
                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    UPDATE b-emails WITH FRAME f_emails.
                                    LEAVE.
                                 END.                                      
                                 
                                 HIDE FRAME f_emails.
                                     
                                 IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                     NEXT.
                             END.
                            
                        ELSE
                             APPLY LASTKEY.

                    END. /* Fim do EDITING */

                FIND crapcem WHERE crapcem.cdcooper = glb_cdcooper   AND
                                   crapcem.nrdconta = tel_nrdconta   AND
                                   crapcem.idseqttl = 1              AND
                                   crapcem.dsdemail = tel_dsdemail
                                   NO-LOCK NO-ERROR.
                      
                IF   NOT AVAILABLE crapcem   THEN
                     DO:
                         tel_dsdemail = "".
                         DISPLAY tel_dsdemail WITH FRAME f_dados.
                         glb_cdcritic = 812.
                         RUN fontes/critic.p.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         NEXT.
                     END.
                     
                ASSIGN  tel_cddemail = crapcem.cddemail
                        tel_dsdemail = crapcem.dsdemail.
                     
                DISPLAY tel_dsdemail WITH FRAME f_dados.
                      
                LEAVE.
             
             END.  /* Fim do DO WHILE TRUE */
                
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.
             
             RUN confirma. 
             
             IF   NOT aux_confirma = "S"   THEN
                  LEAVE.
                              
             IF   AVAILABLE crapcex   THEN
                  DO:
                      ASSIGN crapcex.cddemail = tel_cddemail
                             crapcex.cdoperad = glb_cdoperad
                             crapcex.dtmvtolt = glb_dtmvtolt
                             crapcex.hrtransa = TIME.
                                   
                      RELEASE crapcex.
                               
                      IF   aux_cddemail <> tel_cddemail   THEN
                           RUN proc_gera_log(STRING(aux_cddemail) ,
                                             STRING(tel_cddemail) + " - " +
                                             tel_dsdemail         ,
                                             TRUE).
                  END.
                  
         END. /* Fim da opcao "A" */
    ELSE
    IF   glb_cddopcao = "I"  THEN
         DO:
             IF   CAN-FIND(crapcex WHERE 
                           crapcex.cdcooper = glb_cdcooper   AND
                           crapcex.nrdconta = tel_nrdconta   AND
                           crapcex.tpextrat = tel_tpextrat   NO-LOCK)   THEN
                  DO:
                      glb_cdcritic = 850.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      PAUSE 1 NO-MESSAGE.
                      LEAVE.
                  END.
             
             IF   tel_tpextrat = 5   THEN   
                  DO:
                      ASSIGN tel_cdperiod = 3
                             tel_dsperiod = "Mensal".

                      DISPLAY tel_dsperiod WITH FRAME f_dados.

                      RUN proc_incluir.
                      
                      CLEAR FRAME f_dados NO-PAUSE.
                      
                      LEAVE.
                  END.
             
             ASSIGN tel_cdperiod = 1
                    tel_dsperiod = " Diario".

             DISPLAY tel_dsperiod WITH FRAME f_dados.
                                 
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_dsdemail WITH FRAME f_dados
 
                    EDITING:  
                                                       
                        READKEY.
                            
                        IF   LASTKEY = KEYCODE("F7")   THEN
                             DO:
                                 OPEN QUERY q-emails FOR EACH crapcem WHERE
                                            crapcem.cdcooper = glb_cdcooper
                                            AND
                                            crapcem.nrdconta = tel_nrdconta
                                            AND
                                            crapcem.idseqttl = 1
                                            NO-LOCK.
                                               
                                 DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                    UPDATE b-emails WITH FRAME f_emails.
                                    LEAVE.           
                                 END.
                                               
                                 HIDE FRAME f_emails.
                                 
                                 IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
                                     NEXT.
                             END.
                        ELSE 
                             APPLY LASTKEY.
                                 
                    END. /* Fim do EDITING */
                  
                FIND crapcem WHERE crapcem.cdcooper = glb_cdcooper   AND
                                   crapcem.nrdconta = tel_nrdconta   AND
                                   crapcem.idseqttl = 1              AND
                                   crapcem.dsdemail = tel_dsdemail 
                                   NO-LOCK NO-ERROR.
                
                IF   NOT AVAILABLE crapcem   THEN
                     DO:
                          tel_dsdemail = "".
                          DISPLAY tel_dsdemail WITH FRAME f_dados.
                          glb_cdcritic = 812.
                          RUN fontes/critic.p.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                          NEXT.
                     END.

                ASSIGN  tel_cddemail = crapcem.cddemail
                        tel_dsdemail = crapcem.dsdemail.
                
                DISPLAY tel_dsdemail WITH FRAME f_dados.
                
                LEAVE.
                
             END. /* Fim do DO WHILE TRUE */
                       
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.
             
             RUN proc_incluir.
             
             CLEAR FRAME f_dados NO-PAUSE. 
                    
         END. /* Fim da opcao "I" */
    ELSE
    IF   glb_cddopcao = "E"  THEN
         DO:   
             IF   fun_consulta()  THEN 
                  DO:
                      DISPLAY tel_dsperiod 
                              tel_dsdemail WHEN tel_tpextrat = 3
                              WITH FRAME f_dados.
                      
                      RUN proc_excluir.
                  END.
         END.
     
END. /* Fim do DO WHILE TRUE */                      

/******************************************************************************/

PROCEDURE proc_incluir:

   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

      IF   CAN-FIND(crapcex WHERE
                    crapcex.cdcooper = glb_cdcooper   AND
                    crapcex.nrdconta = tel_nrdconta   AND
                    crapcex.tpextrat = tel_tpextrat   NO-LOCK)   THEN
           DO:
               glb_cdcritic = 850.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PAUSE 1 NO-MESSAGE.
               RETURN.
           END.
      
      RUN confirma.
      
      IF   aux_confirma = "S"   THEN
           DO:
               CREATE  crapcex.
               ASSIGN  crapcex.cdcooper = glb_cdcooper
                       crapcex.nrdconta = tel_nrdconta
                       crapcex.tpextrat = tel_tpextrat
                       crapcex.cdperiod = tel_cdperiod
                       crapcex.cddemail = tel_cddemail
                       crapcex.dtmvtolt = glb_dtmvtolt
                       crapcex.cdoperad = glb_cdoperad
                       crapcex.hrtransa = TIME.                       

               VALIDATE crapcex.

               IF   tel_cddemail = 0   THEN
                    RUN proc_gera_log("","Inclusao ",FALSE).
               ELSE
                    RUN proc_gera_log(", Email: " + STRING(tel_cddemail,"z") +
                                       " - " +  tel_dsdemail,
                                      "Inclusao"            ,
                                      FALSE).
           END.
   END. 

END PROCEDURE. 

PROCEDURE confirma:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.  
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   
        aux_confirma <> "S"                  THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 1 NO-MESSAGE.
            glb_cdcritic = 0.
        END. 

END PROCEDURE.

PROCEDURE proc_excluir:
      
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
        
      FIND CURRENT crapcex EXCLUSIVE-LOCK NO-ERROR.

      IF   AVAILABLE crapcex  THEN
           DO:
               RUN confirma.
               
               IF   aux_confirma = "S"   THEN
                    DO:
                        IF   crapcex.cddemail = 0   THEN
                             RUN proc_gera_log("","Exclusao ",FALSE).
                        ELSE
                             DO:
                                 FIND crapcem WHERE 
                                      crapcem.cdcooper = glb_cdcooper AND
                                      crapcem.nrdconta = tel_nrdconta AND
                                      crapcem.idseqttl = 1            AND
                                      crapcem.cddemail = crapcex.cddemail
                                      NO-LOCK NO-ERROR.
                             
                                 IF   AVAILABLE crapcem   THEN
                                      RUN proc_gera_log
                                        (", Email: "+ STRING(tel_cddemail,"z")+
                                         " - " + crapcem.dsdemail,
                                         "Exclusao"              ,
                                         FALSE).
                                 ELSE
                                      RUN proc_gera_log("","Exclusao ",FALSE).
                             END.
                        
                        DELETE crapcex.
                        
                        CLEAR FRAME f_dados NO-PAUSE.
                    END.
               ELSE
                    CLEAR FRAME f_dados.  
           
               RELEASE crapcex.
               
           END.

   END. /* Fim da transacao */
       
END PROCEDURE.

PROCEDURE proc_imprimirelacao:

   DEF  VAR aux_dsdemail     AS CHAR FORMAT "x(33)"    NO-UNDO.
   DEF  VAR aux_cdperiod     AS INT                    NO-UNDO.

   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
   INPUT THROUGH basename `tty` NO-ECHO.
   
   SET aux_nmendter WITH FRAME f_terminal.

   INPUT CLOSE.
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
   
   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
   
   /* Inicializa Variaveis Relatorio */
   ASSIGN glb_cdcritic    =   0
          glb_cdrelato[1] = 491.
   
   { includes/cabrel080_1.i }  
   
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 60.
   
   VIEW STREAM str_1 FRAME f_cabrel080_1.
   
   IF   tel_tpextrat = 3   THEN
        DO:                      
            DISPLAY STREAM str_1 "RELACAO DE EXTRATOS PADRAO CNAB" 
                                 WITH CENTERED FRAME f_extratos.   
            aux_cdperiod = 1.
        END.
   ELSE 
        DO:                                                 
            DISPLAY STREAM str_1 "RELACAO DE AVISOS CADASTRADOS"  AT 26
                                 WITH FRAME f_avisos. 
            aux_cdperiod = 3.
        END.

   FOR EACH crapcex  WHERE crapcex.cdcooper = glb_cdcooper AND
                           crapcex.tpextrat = tel_tpextrat AND
                           crapcex.cdperiod = aux_cdperiod NO-LOCK,
       FIRST crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                           crapass.nrdconta = crapcex.nrdconta NO-LOCK
                           BREAK BY crapass.cdagenci
                                    BY crapass.nrdconta:
        
       IF   crapass.cdagenci = tel_cdagenci   OR
            tel_cdagenci     = 0              THEN
            DO:
                IF   tel_tpextrat = 3   THEN
                     DO:
                         FIND crapcem WHERE 
                              crapcem.cdcooper = glb_cdcooper       AND
                              crapcem.nrdconta = crapcex.nrdconta   AND
                              crapcem.idseqttl = 1                  AND
                              crapcem.cddemail = crapcex.cddemail 
                              NO-LOCK NO-ERROR.
                               
                         IF   AVAILABLE crapcem   THEN
                              aux_dsdemail = crapcem.dsdemail.
                         ELSE
                              aux_dsdemail = "".

                         DISPLAY STREAM str_1 
                            crapass.cdagenci COLUMN-LABEL "PA"
                            crapcex.nrdconta COLUMN-LABEL "CONTA/DV"
                            crapass.nmprimtl COLUMN-LABEL "NOME" FORMAT "x(33)"
                            aux_dsdemail     COLUMN-LABEL "EMAIL"
                                             FORMAT "x(28)".  
                     END.
                ELSE                                    
                     DISPLAY STREAM str_1
                        crapass.cdagenci COLUMN-LABEL "PA"
                        crapcex.nrdconta COLUMN-LABEL "CONTA/DV"
                        crapass.nmprimtl COLUMN-LABEL "NOME" FORMAT "x(40)"
                        WITH DOWN FRAME f_frame.
            END.
   END.

   IF   LINE-COUNTER(str_1) > 1  THEN
        DO:
            OUTPUT STREAM str_1 CLOSE.
            RUN confirma.
            
            IF   aux_confirma = "S"   THEN
                 DO:
                     ASSIGN glb_nrdevias = 1
                            par_flgrodar = TRUE
                            glb_nmformul = "80col".
           
                     { includes/impressao.i }
                 END.
        END.
   ELSE
        DO:
            OUTPUT STREAM str_1 CLOSE.
            ASSIGN glb_cdcritic = 263.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            CLEAR FRAME f_relatorio.
            DISPLAY glb_cddopcao WITH FRAME f_opcao.
            NEXT.
        END.          

END PROCEDURE.  

PROCEDURE proc_gera_log:

    DEF  INPUT PARAMETER par_antcampo    AS CHAR    NO-UNDO.
    DEF  INPUT PARAMETER par_vldcampo    AS CHAR    NO-UNDO.
    DEF  INPUT PARAMETER par_flgdelog    AS LOGI    NO-UNDO.

    FIND w-documentos WHERE w-documentos.tpextrat = tel_tpextrat
                            NO-LOCK NO-ERROR.

    IF   par_flgdelog   THEN
         UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")        +
                           " "     + STRING(TIME,"HH:MM:SS") + "' --> '"      +
                           "Operador "   + glb_cdoperad   + " - Alteracao "   +
                           " Conta: " + STRING(tel_nrdconta,"zzzz,zzz,9")     + 
                           ", Tipo doc: " + STRING(tel_tpextrat)  + " - "     +
                           w-documentos.dsextrat + ", Email: de "             + 
                           par_antcampo + " para " + par_vldcampo             +
                           " >> log/cadcex.log").                     
    ELSE
         UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")        +
                           " "     + STRING(TIME,"HH:MM:SS")   + "' --> '"    +
                           "Operador "  + glb_cdoperad + " - " + par_vldcampo +
                           " Conta: " + STRING(tel_nrdconta,"zzzz,zzz,9")     + 
                           ", Tipo doc: " +  STRING(tel_tpextrat) +  " - "    +
                           w-documentos.dsextrat + " " + par_antcampo         +                            " >> log/cadcex.log"). 
END PROCEDURE.

PROCEDURE proc_documentos:

    CREATE w-documentos NO-ERROR.
    ASSIGN w-documentos.tpextrat = 3
           w-documentos.dsextrat = "Extrato c/c CNAB" NO-ERROR.
               
    CREATE w-documentos NO-ERROR.
    ASSIGN w-documentos.tpextrat = 5               
           w-documentos.dsextrat = "Aviso de Debito"  NO-ERROR.
                               
END PROCEDURE.

PROCEDURE proc_limpa:

    tel_nmprimtl:VISIBLE IN FRAME f_dados = FALSE.
    tel_tpextrat:VISIBLE IN FRAME f_dados = FALSE.
    tel_dsperiod:VISIBLE IN FRAME f_dados = FALSE.
    tel_dsdemail:VISIBLE IN FRAME f_dados = FALSE.

    ASSIGN tel_nrdconta = 0
           tel_tpextrat = 0
           tel_cddemail = 0
           tel_dsdemail = ""
           tel_cdagenci = 0.
           
END PROCEDURE.

/*...........................................................................*/
 
