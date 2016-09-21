/* .............................................................................

   Programa: Includes/lrotata.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2007.                         Ultima atualizacao: 23/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LROTAT.

   Alteracoes: Alterado para gerar log/lrotat.log (Gabriel).
   
               18/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Alteracao da exibicao do campo Tipo de limite;
                            - Inclusao das colunas 'Operacional' e 'CECRED';
                            - Alteracao para permitir alterar o campo 
                              'Descricao'
                            - Inclusao de validacao de Valor limite maximo
                              Operacional em relacao ao Valor limite maximo
                              CECRED;
                            - Inclusao de campos 'Descricao', 'Tipo limite',
                              'Qtde. Vezes Capital CECRED' e 'Valor limite
                              maximo CECRED' no registro de log.
                            - Replicar 'Qtde. Vezes Capital Operacional' para
                              'Qtde. Vezes Capital CECRED'
                            (GATI - Eder)
                            
               29/12/2010 - Inclusao do terceiro campo dsencfin (Adriano).  
               
               20/06/2011 - Controlar tarifas das linhas de credito através
                            da tabela CRATLR (Adriano). 
                 
               11/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)

               23/04/2014 - Remover a parte de tarifas da tela, e incluir
                            Central de Risco com campos Origem do Recurso,
                            Modalidade e Submodalidade (Guilherme/SUPERO)
............................................................................. */

TRANS_A:

DO TRANSACTION ON ERROR UNDO TRANS_A, RETRY:

   DO aux_contador = 1 TO 10:

      FIND craplrt WHERE craplrt.cdcooper = glb_cdcooper   AND
                         craplrt.cddlinha = tel_cddlinha
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplrt   THEN
           IF   LOCKED craplrt   THEN
                DO:
                    glb_cdcritic = 374.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 363.
      ELSE
           glb_cdcritic = 0.

      LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   glb_cdcritic > 0   THEN
        NEXT.


   
   ASSIGN tel_cddlinha    = craplrt.cddlinha
          tel_tpdlinha    = IF   craplrt.tpdlinha = 1   THEN
                                 "F"
                            ELSE "J"
          tel_dsdtplin    = IF   craplrt.tpdlinha = 1   THEN
                                 "Limite de Credito PF"
                            ELSE "Limite de Credito PJ"
          tel_dsdlinha    = craplrt.dsdlinha
          tel_flgstlcr    = craplrt.flgstlcr
          tel_qtdiavig    = craplrt.qtdiavig
          tel_qtvezcap    = craplrt.qtvezcap
          tel_qtvcapce    = craplrt.qtvcapce
          tel_txjurfix    = craplrt.txjurfix
          tel_txjurvar    = craplrt.txjurvar
          tel_txmensal    = craplrt.txmensal
          tel_vllimmax    = craplrt.vllimmax
          tel_vllmaxce    = craplrt.vllmaxce
          tel_dsencfin[1] = craplrt.dsencfin[1]
          tel_dsencfin[2] = craplrt.dsencfin[2]
          tel_dsencfin[3] = craplrt.dsencfin[3] 
          
          aux_dsdlinha    = craplrt.dsdlinha
          aux_tpdlinha    = craplrt.tpdlinha
          aux_qtvezcap    = craplrt.qtvezcap
          aux_qtvcapce    = craplrt.qtvcapce
          aux_txjurfix    = craplrt.txjurfix
          aux_vllimmax    = craplrt.vllimmax
          aux_vllmaxce    = craplrt.vllmaxce
          aux_txjurvar    = craplrt.txjurvar
          aux_qtdiavig    = craplrt.qtdiavig
          aux_dsencfin[1] = craplrt.dsencfin[1]
          aux_dsencfin[2] = craplrt.dsencfin[2]
          aux_dsencfin[3] = craplrt.dsencfin[3]
          tel_origrecu    = craplrt.dsorgrec.

FIND gnmodal WHERE gnmodal.cdmodali = craplrt.cdmodali NO-LOCK NO-ERROR.

IF   AVAIL gnmodal    THEN
     ASSIGN tel_cdmodali = gnmodal.cdmodali + "-" + gnmodal.dsmodali.
ELSE
     ASSIGN tel_cdmodali = "".

FIND gnsbmod WHERE gnsbmod.cdmodali = craplrt.cdmodali AND
                   gnsbmod.cdsubmod = craplrt.cdsubmod
                   NO-LOCK NO-ERROR.

IF   AVAIL gnsbmod   THEN
     ASSIGN tel_cdsubmod = gnsbmod.cdsubmod + "-" + gnsbmod.dssubmod.
ELSE
     ASSIGN tel_cdsubmod = "".
   

   DISPLAY tel_cddlinha tel_dsdlinha WITH FRAME f_descricao.

   DISPLAY tel_tpdlinha    tel_dsdtplin    tel_flgstlcr    
           tel_qtvezcap    tel_qtvcapce    tel_vllimmax    tel_vllmaxce
           tel_qtdiavig    tel_txjurfix    tel_txjurvar
           tel_txmensal    tel_dsencfin[1] tel_dsencfin[2] tel_dsencfin[3]
           WITH FRAME f_lrotat.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      /* Descricao so pode ser alterada pela Central */
      IF   glb_dsdepart = "PRODUTOS"               OR
           glb_dsdepart = "COORD.ADM/FINANCEIRO"   OR
           glb_dsdepart = "TI"                     THEN
           DO:
               UPDATE tel_dsdlinha WITH FRAME f_descricao.

               ASSIGN tel_dsdlinha = CAPS(tel_dsdlinha).

               DISPLAY tel_dsdlinha WITH FRAME f_descricao.
           END.
                    
      IF   glb_dsdepart <> "PRODUTOS"             AND
           glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
           glb_dsdepart <> "TI"                   THEN
           DO:
              UPDATE tel_qtvezcap    tel_vllimmax 
                     WITH FRAME f_lrotat
      
                     EDITING:

                        READKEY.

                        IF   FRAME-FIELD = "tel_vllimmax"   THEN
                             IF   LASTKEY =  KEYCODE(".")   THEN
                                  APPLY 44.
                             ELSE
                                  APPLY LASTKEY.
                        ELSE
                             APPLY LASTKEY.

                     END.  /*  Fim do EDITING  */
           END. /* Fim - IF   glb_dsdepart <> "PRODUTOS"... */
      ELSE
           DO:
              UPDATE tel_qtvezcap    tel_vllimmax  
                     tel_vllmaxce    tel_qtdiavig    
                     tel_txjurfix    tel_txjurvar
                     tel_dsencfin[1] tel_dsencfin[2] tel_dsencfin[3]
                     WITH FRAME f_lrotat
      
                     EDITING:

                        READKEY.

                        IF   FRAME-FIELD = "tel_vllimmax"   OR 
                             FRAME-FIELD = "tel_vllmaxce"   OR
                             FRAME-FIELD = "tel_txjurfix"   OR
                             FRAME-FIELD = "tel_txjurvar"   THEN
                             IF   LASTKEY =  KEYCODE(".")   THEN
                                  APPLY 44.
                             ELSE
                                  APPLY LASTKEY.
                        ELSE
                             APPLY LASTKEY.

                     END.  /*  Fim do EDITING  */
                     
           END. /* Fim - ELSE IF   glb_dsdepart <> "PRODUTOS"... */

      IF   glb_dsdepart <> "PRODUTOS"             AND
           glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
           glb_dsdepart <> "TI"                   AND
           tel_vllimmax  > tel_vllmaxce           THEN
           DO:
               MESSAGE "Valor Limite maximo Operacional maior que Valor " +
                       "Limite maximo CECRED.".
               NEXT.
           END.

      IF  (glb_dsdepart = "PRODUTOS"               OR
           glb_dsdepart = "COORD.ADM/FINANCEIRO"   OR
           glb_dsdepart = "TI")                    AND
           tel_vllmaxce < tel_vllimmax             THEN
           DO:
               MESSAGE "Valor Limite maximo CECRED menor que Valor " +
                       "Limite maximo Operacional.".
               NEXT.
           END.
           
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        UNDO TRANS_A, NEXT.
   
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
            UNDO TRANS_A, NEXT.
        END.

   IF   SUBSTRING(craptab.dstextab,1,1) = "T" THEN  /* Ident. TR ou UFIR */
        aux_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,03,10)).
   ELSE
        aux_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,14,10)).
        
   tel_txmensal = ROUND(((aux_txrefmes * (tel_txjurvar / 100) + 100) * 
                         (1 + (tel_txjurfix / 100)) - 100),6).

   DISPLAY tel_txmensal WITH FRAME f_lrotat.

   IF glb_dsdepart = "PRODUTOS"               OR
      glb_dsdepart = "COORD.ADM/FINANCEIRO"   OR
      glb_dsdepart = "TI"                     THEN
      DO:
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

               HIDE MESSAGE NO-PAUSE.

               LEAVE.

            END.
          
            IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                LEAVE.

            LEAVE.

         END.

         IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN DO: 
             HIDE MESSAGE NO-PAUSE.
             HIDE FRAME f_lrotat2. 
             UNDO TRANS_A, NEXT.
        
         END.

      END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            HIDE FRAME f_lrotat2.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            UNDO TRANS_A, NEXT.

        END.

   IF   aux_confirma = "S"   THEN
        DO:
            ASSIGN craplrt.dsdlinha    = tel_dsdlinha
                   craplrt.tpdlinha    = IF tel_tpdlinha = "F" THEN 1 ELSE 2
                   craplrt.qtdiavig    = tel_qtdiavig
                   craplrt.qtvezcap    = tel_qtvezcap
                   craplrt.qtvcapce    = tel_qtvezcap /* Replica Qtde Vezes Capital - Operacional para CECRED */
                   craplrt.txjurfix    = tel_txjurfix
                   craplrt.txjurvar    = tel_txjurvar
                   craplrt.txmensal    = tel_txmensal
                   craplrt.vllimmax    = tel_vllimmax
                   craplrt.vllmaxce    = tel_vllmaxce
                   craplrt.dsencfin[1] = tel_dsencfin[1]
                   craplrt.dsencfin[2] = tel_dsencfin[2]
                   craplrt.dsencfin[3] = tel_dsencfin[3]
                   craplrt.dsorgrec     = tel_origrecu
                   craplrt.cdmodali     = SUBSTR(tel_cdmodali,1,2)
                   craplrt.cdsubmod     = SUBSTR(tel_cdsubmod,1,2)
                   .

            IF glb_cdcritic > 0   THEN
               NEXT.

        END. /* IF   aux_confirma = "S"... */           

   HIDE FRAME f_lrotat2.
   CLEAR FRAME f_lrotat NO-PAUSE.
   CLEAR FRAME f_lrotat2 NO-PAUSE.
   CLEAR FRAME f_descricao NO-PAUSE.
   
   IF   aux_dsdlinha <> tel_dsdlinha   THEN
        RUN gera_log (aux_dsdlinha,tel_dsdlinha,
                      "Descricao da linha de credito").

   IF   aux_tpdlinha <> craplrt.tpdlinha   THEN
        RUN gera_log (STRING(aux_tpdlinha = 1,
                             "Limite de Credito PF/Limite de Credito PJ"),
                      STRING(craplrt.tpdlinha = 1,
                             "Limite de Credito PF/Limite de Credito PJ"),
                      "Tipo de linha de credito").

   IF   aux_qtvezcap <> tel_qtvezcap   THEN
        RUN gera_log (STRING(aux_qtvezcap,"zzz,zzz,zz9.99"),
                      STRING(tel_qtvezcap,"zzz,zzz,zz9.99"),
                      "Quantidade de vezes do capital - Operacional").
                      
   IF   aux_qtvcapce <> tel_qtvcapce   THEN
        RUN gera_log (STRING(aux_qtvcapce,"zzz,zzz,zz9.99"),
                      STRING(tel_qtvcapce,"zzz,zzz,zz9.99"),
                      "Quantidade de vezes do capital - CECRED").

   IF   aux_vllimmax <> tel_vllimmax   THEN
        RUN gera_log (STRING(aux_vllimmax,"zzz,zzz,zz9.99"),
                      STRING(tel_vllimmax,"zzz,zzz,zz9.99"),
                      "Valor Limite maximo - Operacional").
                      
   IF   aux_vllmaxce <> tel_vllmaxce   THEN
        RUN gera_log (STRING(aux_vllmaxce,"zzz,zzz,zz9.99"),
                      STRING(tel_vllmaxce,"zzz,zzz,zz9.99"),
                      "Valor Limite maximo - CECRED").


   IF   aux_qtdiavig <> tel_qtdiavig   THEN
        RUN gera_log (STRING(aux_qtdiavig),STRING(tel_qtdiavig),
                      "Dias de vigencia no contrato").

   IF   aux_txjurfix <> tel_txjurfix   THEN
        RUN gera_log (STRING(aux_txjurfix,"zz9.999999"),
                      STRING(tel_txjurfix,"zz9.999999"),"Taxa Fixa").

   IF   aux_txjurvar <> tel_txjurvar   THEN
        RUN gera_log (STRING(aux_txjurvar,"zz9.999999"),
                      STRING(tel_txjurvar,"zz9.999999"),"Taxa Variavel").

   IF   aux_dsencfin[1] <> tel_dsencfin[1]   OR 
        aux_dsencfin[2] <> tel_dsencfin[2]   OR
        aux_dsencfin[3] <> tel_dsencfin[3]   THEN
        RUN gera_log (aux_dsencfin[1] + " " + aux_dsencfin[2] + 
                      " " + aux_dsencfin[3],
                      tel_dsencfin[1] + " " + tel_dsencfin[2] +
                      " " + tel_dsencfin[3],
                      "Texto no contrato").

END.  /*  Fim da transacao  */


PROCEDURE gera_log:

    DEF INPUT   PARAMETER     aux_anvalor     AS CHAR         NO-UNDO.
    DEF INPUT   PARAMETER     aux_nwvalor     AS CHAR         NO-UNDO.
    DEF INPUT   PARAMETER     aux_dsvalor     AS CHAR         NO-UNDO.

    IF   aux_anvalor = ""    THEN
         aux_anvalor = "---".

    IF   aux_nwvalor = ""    THEN
         aux_nwvalor = "---".
         
    UNIX SILENT VALUE("echo '" + STRING(glb_dtmvtolt,"99/99/9999")     +
                      " " + STRING(TIME,"HH:MM:SS")  + " --> "         +
                      " Operador " + glb_cdoperad    + " -"            +
                      " Alterou o/a "    + aux_dsvalor + " de "        +
                        aux_anvalor + " para " + aux_nwvalor           +
                      " da linha " + STRING(tel_cddlinha)              +
                      ".'" + " >> log/lrotat.log").

END PROCEDURE.


/*........................................................................... */
