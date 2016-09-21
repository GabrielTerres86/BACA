/*.............................................................................

   Programa: Fontes/gt0008.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Marco/2008                          Ultima Atualizacao: 22/06/2012

   Dados referentes ao programa :

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar consulta de documentos enviados para PostMix.
   
   Alteracoes: 03/03/2009 - Incluido totalizador dos documentos na ultima linha
                            do browse (Evandro).
                                                        
               02/05/2011 - Criado combo-box para selecao de arquivo para
                            pesquisa. (Fabricio)
   
               16/04/2012 - Fonte substituido por gt0008p.p (Tiago).
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).          
..............................................................................*/

{ includes/var_online.i  }

DEF     VAR aux_cdcooper  AS   CHARACTER         FORMAT "x(15)"      NO-UNDO.
DEF     VAR tel_cdcooper  AS   INTEGER           FORMAT "zz9"        NO-UNDO.
DEF     VAR tel_dtmvtolt  LIKE gndcimp.dtmvtolt                      NO-UNDO.
DEF     VAR tel_dtmvtolt2 LIKE gndcimp.dtmvtolt                      NO-UNDO.
DEF     VAR tel_qtdoctos  LIKE gndcimp.qtdoctos                      NO-UNDO.
DEF     VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
DEF     VAR tel_nmarquiv AS CHAR    FORMAT "x(40)" VIEW-AS COMBO-BOX 
                                                   INNER-LINES 4     NO-UNDO.

DEF TEMP-TABLE w-docts  NO-UNDO
         FIELD cdcooper AS   CHAR             COLUMN-LABEL "Cooperativa" 
         FIELD dtmvtolt LIKE gndcimp.dtmvtolt COLUMN-LABEL "Data"
         FIELD qtdoctos LIKE gndcimp.qtdoctos COLUMN-LABEL "Qtdade"
         FIELD nmarquiv LIKE gndcimp.nmarquiv COLUMN-LABEL "Nome do arquivo"
         FIELD nrsequen LIKE gndcimp.nrsequen COLUMN-LABEL "Seq.".

DEF QUERY q_consulta FOR w-docts.

DEF BROWSE b_consulta QUERY q_consulta
           DISPLAY cdcooper FORMAT "x(22)"
                   dtmvtolt 
                   qtdoctos FORMAT "zzz,zz9"
                   nmarquiv FORMAT "x(25)" 
                   nrsequen FORMAT "z9"
                   WITH 10 DOWN.


FORM SKIP(3)
     "Opcao:"      AT 09
     glb_cddopcao  AUTO-RETURN  NO-LABEL
                   HELP "Informe a opcao desejada (C)."
                   VALIDATE(glb_cddopcao = "C" ,"014 - Opcao errada.")
     SKIP(2)
     tel_cdcooper  AT 03 LABEL "Cooperativa"
                   HELP "Informe o numero da cooperativa ou <999> para todas."
     
     aux_cdcooper  NO-LABEL
     
     "Periodo:"    AT 40
     tel_dtmvtolt  AT 49 NO-LABEL 
                   HELP "Informe a data inicial do periodo."
     "a"
     tel_dtmvtolt2 AT 62 NO-LABEL 
                   HELP "Informe a data final do periodo."
     SKIP(2)
     tel_nmarquiv  AT 07 LABEL "Arquivo"
                   HELP "Selecione o relatorio desejado."
     SKIP(6)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela 
     FRAME f_consulta.

FORM SKIP(1)
     b_consulta 
     HELP "Use as <SETAS> p/ navegar ou <F4> p/ sair."
     WITH CENTERED OVERLAY NO-BOX ROW 6 WIDTH 78 SIDE-LABELS FRAME f_query.

ON RETURN OF b_consulta
   APPLY "GO".

ON RETURN OF tel_nmarquiv  
   APPLY "F1".



glb_cddopcao = "C".
   
VIEW FRAME f_consulta.

DO WHILE TRUE:
   
   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
      
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
      
      EMPTY TEMP-TABLE w-docts.
      
      ASSIGN  tel_cdcooper  = 0
              aux_cdcooper  = ""
              tel_dtmvtolt  = ?
              tel_dtmvtolt2 = ?
              tel_nmarquiv:SCREEN-VALUE = ""
              tel_nmarquiv  = "".

      ASSIGN tel_nmarquiv:LIST-ITEMS = "crrl269 - Cartas de Inclusão no CCF,"
                                     + "crrl166 - Senhas Tele Atendimento,"
                                     + "crrl273 - Chegada de Cartão Magnético,"
                                     + "crrl136 - Empréstimos Concedidos,"
                                     + "convit  - Convite Progrid,"
                                     + "crrl056 - Recibo Depósito Cooperativo,"
                                     + "crrl171 - Extrato de Conta Corrente,"
                                     + "crrl410 - Crédito de Sobras,"
                                     + "crrl359 - Empréstimos em Atraso,"
                                     + "crrl174 - Extrato de Aplicações,"
                                     + "crrl173 - Aviso de Débito em Folha,"
                                     + "crrl193 - Aviso de Débito C/C,"
                                     + "crrl204 - Aviso de Débito C/C,"
                                     + "TODOS".

      
      DISPLAY tel_cdcooper
              aux_cdcooper
              tel_dtmvtolt
              tel_dtmvtolt2
              WITH FRAME f_consulta.

      VIEW tel_nmarquiv IN FRAME f_consulta.
      
      NEXT-PROMPT tel_cdcooper with frame f_consulta.
      
      DO WHILE TRUE:
         UPDATE glb_cddopcao 
                tel_cdcooper WITH FRAME f_consulta.
         LEAVE.
      END.
      
      IF   glb_cdcooper <> 3   THEN
           DO:
               glb_cdcritic = 794.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               MESSAGE "Opcao valida somente para a"
                       "cooperativa 3-CECRED".
               glb_cdcritic = 0.
               RETURN.
           END.
      
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */ 

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "GT0008"   THEN
                 DO:
                     HIDE FRAME f_consulta NO-PAUSE.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
                 
   IF   glb_cddopcao = "C"   THEN  
        DO:
            DO WHILE TRUE:
                  
               FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper
                                  NO-LOCK NO-ERROR.
            
               IF   AVAILABLE crapcop   THEN
                    DO:
                        aux_cdcooper =  "- " +  crapcop.nmrescop.
                        LEAVE.
                    END.                 
               ELSE 
                    IF   tel_cdcooper = 999   THEN
                         DO:
                             aux_cdcooper = "".
                             LEAVE.
                         END.
                    ELSE     
                         DO:
                             glb_cdcritic = 794.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             tel_cdcooper = 0.
                             UPDATE tel_cdcooper WITH FRAME f_consulta.
                             NEXT.
                         END.
            
            END. /*  Fim do DO WHILE TRUE  */
            
            DISPLAY aux_cdcooper WITH FRAME f_consulta.
            
            DO WHILE TRUE:
                
               UPDATE tel_dtmvtolt
                      tel_dtmvtolt2 WITH FRAME f_consulta.

               IF   tel_dtmvtolt   = ?   AND   
                    tel_dtmvtolt2 <> ?   THEN
                    
                    DO WHILE TRUE:
                           
                       UPDATE tel_dtmvtolt WITH FRAME f_consulta.
                       
                       IF   tel_dtmvtolt = ?   THEN
                            NEXT.
                       ELSE     
                            LEAVE.
                    END.
               ELSE
                    IF   tel_dtmvtolt  <> ?   AND 
                         tel_dtmvtolt2 =  ?   THEN
                          
                         DO WHILE TRUE:
 
                            UPDATE tel_dtmvtolt2 WITH FRAME f_consulta.
                              
                            IF   tel_dtmvtolt2 = ?   THEN
                                 NEXT.
                            ELSE
                                 LEAVE.   
                         END.
                    ELSE
                         LEAVE.
               LEAVE.
            
            END.  /*  Fim do DO WHILE TRUE  */

            UPDATE tel_nmarquiv WITH FRAME f_consulta.

            aux_nmarquiv = TRIM(SUBSTR(tel_nmarquiv:SCREEN-VALUE, 1, 7)).

                 /* Cooperativa informada */
            IF   tel_cdcooper <> 999   THEN
                 
                      /* Cop e Periodo informado */
                 IF   tel_dtmvtolt <> ? THEN

                      IF tel_nmarquiv <> "TODOS" THEN

                           FOR EACH gndcimp WHERE 
                                    gndcimp.cdcooper  = tel_cdcooper    AND
                                    gndcimp.dtmvtolt >= tel_dtmvtolt    AND
                                    gndcimp.dtmvtolt <= tel_dtmvtolt2   AND
                                    gndcimp.flgenvio  = TRUE            AND
                                    gndcimp.nmarquiv MATCHES 
                                    "*" + aux_nmarquiv + "*" NO-LOCK:
                               
                                CREATE w-docts.
                                ASSIGN w-docts.cdcooper = STRING
                                                          (gndcimp.cdcooper) 
                                                          + " - " +   
                                                          crapcop.nmrescop
                                       w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.
                           END.

                      ELSE /* Coop e periodo informado mas nao Arquivo */
                           FOR EACH gndcimp WHERE 
                                    gndcimp.cdcooper  = tel_cdcooper       AND
                                    gndcimp.dtmvtolt >= tel_dtmvtolt       AND
                                    gndcimp.dtmvtolt <= tel_dtmvtolt2      AND
                                    gndcimp.flgenvio  = TRUE           NO-LOCK: 
                                     
                                CREATE w-docts.
                                ASSIGN w-docts.cdcooper = STRING
                                                          (gndcimp.cdcooper)
                                                          + " - " +
                                                          crapcop.nmrescop
                                       w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.
                           END.

                     
                 ELSE
                      IF tel_nmarquiv <> "TODOS" THEN

                           FOR EACH gndcimp WHERE 
                                    gndcimp.cdcooper  = tel_cdcooper    AND
                                    gndcimp.flgenvio  = TRUE            AND
                                    gndcimp.nmarquiv MATCHES 
                                    "*" + aux_nmarquiv + "*" NO-LOCK:
                               
                                CREATE w-docts.
                                ASSIGN w-docts.cdcooper = STRING
                                                          (gndcimp.cdcooper) 
                                                          + " - " +   
                                                          crapcop.nmrescop
                                       w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.
                           END.


                      ELSE
                           FOR EACH gndcimp WHERE 
                                    gndcimp.cdcooper  = tel_cdcooper       AND
                                    gndcimp.flgenvio  = TRUE           NO-LOCK: 
                                     
                                CREATE w-docts.
                                ASSIGN w-docts.cdcooper = STRING
                                                          (gndcimp.cdcooper)
                                                          + " - " +
                                                          crapcop.nmrescop
                                       w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.
                           END.
                  
                  /* Todas as Cooperativas */
            ELSE
                 IF   tel_dtmvtolt <> ?  THEN

                      IF tel_nmarquiv <> "TODOS" THEN
                           
                           FOR EACH gndcimp WHERE 
                                    gndcimp.dtmvtolt >= tel_dtmvtolt    AND
                                    gndcimp.dtmvtolt <= tel_dtmvtolt2   AND
                                    gndcimp.flgenvio  = TRUE            AND 
                                    gndcimp.nmarquiv 
                                           MATCHES "*" + aux_nmarquiv + "*" 
                                                                    NO-LOCK:
                               
                                CREATE w-docts.
                               
                                FIND crapcop WHERE
                                     crapcop.cdcooper = gndcimp.cdcooper 
                                                         NO-LOCK NO-ERROR.
                                    
                                IF   AVAIL crapcop   THEN
                                     w-docts.cdcooper   = STRING
                                                          (gndcimp.cdcooper) 
                                                          + " - " +
                                                          crapcop.nmrescop.
                               
                                ASSIGN w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.

                           END.
                           
                      ELSE
                           FOR EACH gndcimp WHERE 
                                    gndcimp.dtmvtolt >= tel_dtmvtolt    AND
                                    gndcimp.dtmvtolt <= tel_dtmvtolt2   AND
                                    gndcimp.flgenvio  = TRUE       NO-LOCK:
                                    
                                CREATE w-docts.
                               
                                FIND crapcop WHERE
                                     crapcop.cdcooper = gndcimp.cdcooper 
                                                       NO-LOCK NO-ERROR.
                                    
                                IF   AVAIL crapcop   THEN
                                     w-docts.cdcooper   = STRING
                                                          (gndcimp.cdcooper)
                                                          + " - " +
                                                          crapcop.nmrescop.
                               
                                ASSIGN w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.
                           END.

                 ELSE
                      IF tel_nmarquiv <> "TODOS" THEN
                           
                           FOR EACH gndcimp WHERE 
                                    gndcimp.flgenvio  = TRUE            AND 
                                    gndcimp.nmarquiv 
                                             MATCHES "*" + aux_nmarquiv + "*" 
                                                                     NO-LOCK:
                               
                                CREATE w-docts.
                               
                                FIND crapcop WHERE
                                     crapcop.cdcooper = gndcimp.cdcooper 
                                                          NO-LOCK NO-ERROR.
                                    
                                IF   AVAIL crapcop   THEN
                                     w-docts.cdcooper   = STRING
                                                          (gndcimp.cdcooper) 
                                                          + " - " +
                                                          crapcop.nmrescop.
                               
                                ASSIGN w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.

                           END.
                           
                      ELSE
                           FOR EACH gndcimp WHERE 
                                    gndcimp.flgenvio  = TRUE NO-LOCK:
                               
                                CREATE w-docts.
                               
                                FIND crapcop WHERE
                                     crapcop.cdcooper = gndcimp.cdcooper 
                                                       NO-LOCK NO-ERROR.
                                    
                                IF   AVAIL crapcop   THEN
                                     w-docts.cdcooper   = STRING
                                                          (gndcimp.cdcooper)
                                                          + " - " +
                                                          crapcop.nmrescop.
                               
                                ASSIGN w-docts.dtmvtolt = gndcimp.dtmvtolt
                                       w-docts.nmarquiv = gndcimp.nmarquiv
                                       w-docts.qtdoctos = gndcimp.qtdoctos
                                       w-docts.nrsequen = gndcimp.nrsequen.
                           END.

            /* Monta a linha de total dos registros */
            tel_qtdoctos = 0.
            FOR EACH w-docts NO-LOCK:
                tel_qtdoctos = tel_qtdoctos + w-docts.qtdoctos.
            END.
            
            IF   tel_qtdoctos > 0   THEN
                 DO:
                     CREATE w-docts.
                     ASSIGN w-docts.cdcooper = "TOTAL GERAL"
                            w-docts.dtmvtolt = ?
                            w-docts.nmarquiv = ""
                            w-docts.qtdoctos = tel_qtdoctos
                            w-docts.nrsequen = 0.
                 END.
            
            OPEN QUERY q_consulta FOR EACH w-docts NO-LOCK 
                                           BY w-docts.cdcooper
                                              BY w-docts.dtmvtolt
                                                 BY w-docts.nmarquiv.
              
            IF   NUM-RESULTS("q_consulta") = 0   THEN
                 DO:
                     MESSAGE "Nenhum arquivo encontrado.".
                     PAUSE 1 NO-MESSAGE.
                     LEAVE.
                 END.    
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_consulta WITH FRAME f_query.
               LEAVE.
            END.   
        
        END. /* Fim da opcao "C" */

END.  /* Fim do DO WHILE TRUE */  

/*............................................................................*/

