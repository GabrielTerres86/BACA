/* .............................................................................

   Programa: Includes/lrotati.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2007.                         Ultima atualizacao: 23/04/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LROTAT.

   Alteracoes: 14/07/2008 - Alterado para gerar log/lrotat.log e nao permitir
                            cadastrar mais de uma linha do mesmo tipo(Gabriel).
                            
               18/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Alteracao da exibicao do campo Tipo de limite;
                            - Inclusao das colunas 'Operacional' e 'CECRED';
                            - Alteracao para possibilitar incluir mais de uma
                              linha de credito por tipo de limite.
                            (GATI - Eder)
                            
               29/12/2010 - Inclusao do terceiro campo dsencfin (Adriano).  
               
               17/06/2011 - Controlar tarifas das linhas de credito através
                            da tabela CRATLR (Adriano).
               
              11/12/2013 - Alteracao referente a integracao Progress X 
                           Dataserver Oracle 
                           Inclusao do VALIDATE ( André Euzébio / SUPERO) 

              23/04/2014 - Remover a parte de tarifas da tela, e incluir
                           Central de Risco com campos Origem do Recurso,
                           Modalidade e Submodalidade (Guilherme/SUPERO)
............................................................................. */

IF   CAN-FIND(craplrt WHERE craplrt.cdcooper = glb_cdcooper    AND
                            craplrt.cddlinha = tel_cddlinha)   THEN
     DO:
         glb_cdcritic = 873.
         NEXT.
     END.

TRANS_I:

DO TRANSACTION ON ERROR UNDO TRANS_I, RETRY:

   ASSIGN tel_dsdlinha    = ""
          tel_tpdlinha    = ""
          tel_dsdtplin    = ""
          tel_flgstlcr    = YES
          tel_qtdiavig    = 0
          tel_qtvezcap    = 0
          tel_qtvcapce    = 0
          tel_txjurfix    = 0
          tel_txjurvar    = 0
          tel_txmensal    = 0
          tel_vllimmax    = 0
          tel_vllmaxce    = 0
          tel_dsencfin[1] = ""
          tel_dsencfin[2] = ""
          tel_dsencfin[3] = ""
          tel_origrecu    = ""
          tel_cdmodali    = ""
          tel_cdsubmod    = ""
          .


   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:


      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
           
      DISPLAY tel_dsdlinha 
              WITH FRAME f_descricao.       
      DISPLAY tel_tpdlinha    tel_dsdtplin    tel_flgstlcr    tel_qtvezcap
              tel_qtvcapce    tel_vllimmax    tel_vllmaxce    tel_qtdiavig
              tel_txjurfix    tel_txjurvar    tel_txmensal
              tel_dsencfin[1] tel_dsencfin[2] tel_dsencfin[3]
              WITH FRAME f_lrotat.
             
      UPDATE tel_dsdlinha WITH FRAME f_descricao.

      tel_dsdlinha = CAPS(tel_dsdlinha).
      
      DISPLAY tel_dsdlinha WITH FRAME f_descricao.

      UPDATE tel_tpdlinha    tel_qtvezcap    
             tel_vllimmax
             tel_vllmaxce    tel_qtdiavig    tel_txjurfix
             tel_txjurvar    tel_dsencfin[1] tel_dsencfin[2] tel_dsencfin[3]
             WITH FRAME f_lrotat
      
      EDITING:

          READKEY.

          IF   FRAME-FIELD = "tel_vllimmax"   OR
               FRAME-FIELD = "tel_txjurfix"   OR
               FRAME-FIELD = "tel_txjurvar"   THEN
               IF   LASTKEY =  KEYCODE(".")   THEN
                    APPLY 44.
               ELSE
                    APPLY LASTKEY.
          ELSE
               APPLY LASTKEY.

      END.  /*  Fim do EDITING  */
      
      IF   tel_vllimmax  > tel_vllmaxce           THEN
           DO:
               MESSAGE "Valor Limite maximo Operacional maior que Valor " +
                       "Limite maximo CECRED.".
               NEXT.
           END.
      
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        UNDO TRANS_I, NEXT.
   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "TAXASDOMES"   AND
                      craptab.tpregist = 001
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 347.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            UNDO TRANS_I, NEXT.
        END.

   IF   SUBSTRING(craptab.dstextab,1,1) = "T" THEN  /* Ident. TR ou UFIR */
        aux_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,03,10)).
   ELSE
        aux_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,14,10)).
        
   tel_txmensal = ROUND(((aux_txrefmes * (tel_txjurvar / 100) + 100) * 
                         (1 + (tel_txjurfix / 100)) - 100),6).

   DISPLAY tel_txmensal WITH FRAME f_lrotat.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         UPDATE tel_origrecu  tel_cdmodali
                tel_cdsubmod
           WITH FRAME f_lrotat2

         EDITING:

            READKEY.

            IF  FRAME-FIELD = "tel_origrecu" THEN DO:
                IF  LASTKEY = KEYCODE("F7") THEN DO:
                    OPEN QUERY origem-q FOR EACH tt-origem NO-LOCK.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE  brorigem WITH FRAME f_origem.
                        LEAVE.
                    END.

                    HIDE FRAME f_origem.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        NEXT.                         
           
                END.
                ELSE
                    IF  LASTKEY = KEYCODE ("F8") THEN DO:
                        ASSIGN tel_origrecu = "".
                        DISPLAY tel_origrecu WITH FRAME f_lrotat2.
                    END.   
                    ELSE 
                        APPLY LASTKEY.
            END.
            ELSE
            IF  FRAME-FIELD = "tel_cdmodali"   THEN DO:
                IF  LASTKEY = KEYCODE("F7")   THEN DO:
                    OPEN QUERY modali-q 
                         FOR EACH tt-modali NO-LOCK.
                
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE  modali-b WITH FRAME f_modali.
                        LEAVE.
                    END.
                 
                    HIDE FRAME f_modali.     
                
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        NEXT.
                END.
                ELSE
                    APPLY LASTKEY.
            END.
            ELSE
            IF  FRAME-FIELD = "tel_cdsubmod" THEN DO:
                IF  LASTKEY = KEYCODE("F7")   THEN DO:
                    RUN cria_submodali.   

                    OPEN QUERY submodali-q 
                         FOR EACH tt-submodali NO-LOCK.
      
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       UPDATE  submodali-b WITH FRAME f_submodali.
                       LEAVE.
                    END.
                     
                    HIDE FRAME f_submodali.     
                
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        NEXT.
                END.
                ELSE 
                IF  LASTKEY = 13  THEN DO:
                    APPLY "GO".
                END.
                ELSE
                    APPLY LASTKEY.

            END.
            ELSE
                APPLY LASTKEY.
                 
            HIDE MESSAGE. 

         END.   /** Fim Editing **/
           
         LEAVE.
           
      END. /* Fim do DO WHILE TRUE (2) */

      IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
         LEAVE.


      IF glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             HIDE FRAME f_lrotat2.
             UNDO TRANS_I, NEXT.

         END. 

      LEAVE.

   END.


   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      DO:      
         HIDE FRAME f_lrotat2.
         UNDO TRANS_I, NEXT.
   
      END.

   CREATE craplrt.

   ASSIGN craplrt.cddlinha    = tel_cddlinha
          craplrt.flgstlcr    = TRUE
          craplrt.cdcooper    = glb_cdcooper
          craplrt.tpdlinha    = IF tel_tpdlinha = "F" THEN 1 ELSE 2
          craplrt.dsdlinha    = tel_dsdlinha
          craplrt.qtdiavig    = tel_qtdiavig
          craplrt.qtvezcap    = tel_qtvezcap
          craplrt.qtvcapce    = tel_qtvezcap /* Replicar o mesmo valor de craplrt.qtvezcap para craplrt.qtvcapce */
          craplrt.txjurfix    = tel_txjurfix
          craplrt.txjurvar    = tel_txjurvar
          craplrt.txmensal    = tel_txmensal
          craplrt.vllimmax    = tel_vllimmax
          craplrt.vllmaxce    = tel_vllmaxce
          craplrt.dsencfin[1] = tel_dsencfin[1]
          craplrt.dsencfin[2] = tel_dsencfin[2]
          craplrt.dsencfin[3] = tel_dsencfin[3]
          craplrt.dsorgrec    = tel_origrecu
          craplrt.cdmodali    = SUBSTR(tel_cdmodali,1,2)
          craplrt.cdsubmod    = SUBSTR(tel_cdsubmod,1,2)
         .

   VALIDATE craplrt.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      HIDE FRAME f_lrotat2.
      glb_cdcritic = 0.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"   THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            HIDE FRAME f_lrotat2.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            UNDO TRANS_I, NEXT.

        END.

        
   DISPLAY  tel_tpdlinha    tel_dsdtplin    tel_flgstlcr    tel_qtvezcap
            tel_qtvcapce    tel_vllimmax    tel_vllmaxce    tel_qtdiavig
            tel_txjurfix    tel_txjurvar    tel_txmensal
            tel_dsencfin[1] tel_dsencfin[2] tel_dsencfin[3]
            WITH FRAME f_lrotat.

   PAUSE 0.
   
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")          +
                     " " + STRING(TIME,"HH:MM:SS") + "' --> '"            +
                     " Operador " + glb_cdoperad   + " -"                 +
                     " Cadastrou a linha "         + STRING(tel_cddlinha) +
                     " - "                         + tel_dsdlinha         +
                     "." + " >> log/lrotat.log").

   ASSIGN tel_cddlinha = 0.

END.  /*  Fim da transacao  */

/* .......................................................................... */

