/* .............................................................................

   Programa: Fontes/taxrdc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Maio/2007                       Ultima atualizacao: 25/03/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAXRDC.

   Alteracoes: 22/10/2007 - Alterado os rotulos das colunas do browser na opcao
                            de consulta e o HELP do campo "Tipo de Taxa" 
                            (Elton).
                
               06/11/2007 - Incluir operadores 29 e 903 na Central (Magui).
               
               12/02/2009 - Alterada permissoes (Gabriel). 
               
               16/07/2009 - Alteracao cdoperad (Diego).
               
               21/08/2009 - Alimentar o campo craptrd.qtdiaute (Fernando).
               
               04/09/2009 - Acerto na critica 323 (Diego).
               
               14/11/2011 - Inclusão das chamadas "cadastra_taxa_cdi_mensal" e  
                            "cadastra_taxa_cdi_acumulado" para calcular de
                            forma automática a Taxa de CDI somente para a
                            cooperativa 3 (Isara - RKAM) 
                            
               02/01/2012 - Acerto na Inclusao da TAXA CDI ANUAL (Ze).
               
               30/03/2012 - Incluir parametro (dtmvtopr) na opcao "I" (Ze).
               
               20/11/2012 - Possibilitar que seja cadastrado as taxas de 
                            somente uma cooperativa (Ze).
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)
                            
               28/07/2014 - Retiradas as opções "I" e "A" (Jean Michel).
               
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).    
............................................................................. */

{ includes/var_online.i  }

DEF VAR tel_dtmvtolt    AS DATE     FORMAT "99/99/9999"               NO-UNDO.
DEF VAR tel_txcdiano    LIKE craptrd.txofidia                         NO-UNDO.
DEF VAR aux_cddopcao    AS CHAR     FORMAT "!(1)"                     NO-UNDO.
DEF VAR tel_tptaxrdc    AS INT      FORMAT "z9"                       NO-UNDO.
DEF VAR tel_vlfaixas    LIKE craptrd.vlfaixas                         NO-UNDO.
DEF VAR flg_incalcul    AS LOG                                        NO-UNDO.
DEF VAR aux_txprodia    AS DEC DECIMALS 8 FORMAT "z9.999999"          NO-UNDO.
DEF VAR aux_dtfimper    AS DATE                                       NO-UNDO.
DEF VAR aux_dtmvtolt    AS DATE                                       NO-UNDO.
DEF VAR aux_qtdiaute    AS INTE                                       NO-UNDO.
DEF VAR aux_flgderro    AS LOG                                        NO-UNDO.
DEF VAR aux_flatuant    AS LOG                                        NO-UNDO.

DEF VAR tel_destprdc    AS CHAR                                       NO-UNDO.
DEF VAR h-b1wgen0128    AS HANDLE                                     NO-UNDO.

FORM tel_tptaxrdc LABEL "Tipo de Taxa"
                  HELP  "Informe tipo de taxa RDC."
     tel_dtmvtolt LABEL " Data"
                  HELP  "Informe a data de inicio."
     tel_vlfaixas LABEL " Faixa"
                  HELP  "Informe o valor da faixa." 
     WITH FRAME f_consulta OVERLAY  NO-BOX SIDE-LABEL ROW 7 COLUMN 17.

FORM tel_dtmvtolt LABEL "   Data"
                  HELP  "Informe a data da taxa."
                  VALIDATE(tel_dtmvtolt <> ?, "013 - Data errada.")  
     SKIP(2)
     tel_txcdiano label "CDI Ano"
                  HELP  "Informe o valor da taxa."
     WITH FRAME f_taxa OVERLAY NO-BOX SIDE-LABEL ROW 9 COLUMN 7.

FORM glb_cddopcao LABEL "Opcao"
     HELP "Informe a opcao desejada (C)."
          VALIDATE (CAN-DO("C", glb_cddopcao), "014 - Opcao errada.")
     WITH ROW 6 COLUMN 6 SIDE-LABELS NO-BOX OVERLAY FRAME f_opcao_singulares.
 
FORM glb_cddopcao LABEL "Opcao"
     HELP "Informe a opcao desejada (C)."
          VALIDATE (CAN-DO("C", glb_cddopcao), "014 - Opcao errada.")
     WITH ROW 6 COLUMN 6 SIDE-LABELS NO-BOX OVERLAY FRAME f_opcao_cecred.
     
    

DEF TEMP-TABLE crattrd  NO-UNDO LIKE craptrd
    FIELD txresgat LIKE craptrd.txofidia
    FIELD vlmoefix LIKE crapmfx.vlmoefix.


DEF QUERY q_craptrd FOR crattrd.
                                             
DEF BROWSE b_craptrd QUERY q_craptrd
    DISPLAY 
            crattrd.dtiniper   COLUMN-LABEL "Data Inicial"       
            crattrd.cdperapl   COLUMN-LABEL "Periodo"
            crattrd.txprodia   COLUMN-LABEL "CDI Dia"
            crattrd.txofidia   COLUMN-LABEL "%Contrat."
            crattrd.txresgat   COLUMN-LABEL "%Minimo"
            crattrd.vlmoefix   COLUMN-LABEL "CDI Ano"   
            WITH 10 DOWN  NO-BOX.

DEF FRAME f_dados
          b_craptrd HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH CENTERED OVERLAY ROW 8.
           
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela
     FRAME f_moldura.
     
/** Fornece HELP dinamico para o campo Tipo de Taxa **/
ASSIGN tel_destprdc = "Informe tipo de aplicacao (".
 
FOR EACH crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                       crapdtc.flgstrdc = TRUE         AND
                      (crapdtc.tpaplrdc = 1            OR
                       crapdtc.tpaplrdc = 2)           NO-LOCK:
                           
    ASSIGN tel_destprdc = tel_destprdc + STRING(crapdtc.tpaplica) + "-" +
                          crapdtc.dsaplica + ", ".
                              
END. /** Fim do FOR EACH crapdtc **/

ASSIGN tel_tptaxrdc:HELP = 
                    SUBSTR(tel_destprdc,1,LENGTH(tel_destprdc) - 2) + ").".


ASSIGN  glb_cddopcao = "C".

VIEW FRAME f_moldura.
PAUSE 0.  

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
    HIDE FRAME f_consulta.
    HIDE FRAME f_taxa.
    HIDE FRAME f_dados. 
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF   glb_cdcooper = 3 THEN
             UPDATE  glb_cddopcao WITH FRAME f_opcao_cecred.
        ELSE
             UPDATE  glb_cddopcao WITH FRAME f_opcao_singulares.
        LEAVE.
    END.
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:
             RUN  fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "TAXRDC"   THEN
                  DO:
                    HIDE FRAME f_consulta.
                    HIDE FRAME f_taxa.
                    HIDE FRAME f_dados. 
                    RETURN.                 
                  END.
             ELSE
                  NEXT.
         END.

    IF   CAN-DO("A,I",glb_cddopcao)  AND
        NOT CAN-DO("TI,FINANCEIRO,COORD.ADM/FINANCEIRO,COORD.PRODUTOS",
                    glb_dsdepart)  THEN
         DO:
             ASSIGN glb_cdcritic = 323.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0.
             NEXT.
         END.

    IF   aux_cddopcao <> INPUT glb_cddopcao THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = INPUT glb_cddopcao.
         END.
    
    ASSIGN  tel_dtmvtolt = ?
            tel_txcdiano = 0
            tel_vlfaixas = 0 
            tel_tptaxrdc = 0.
    
    IF  glb_cddopcao = "C"  THEN
        DO:
            DO  WHILE TRUE ON ENDKEY UNDO WITH FRAME f_consulta:
                UPDATE tel_tptaxrdc tel_dtmvtolt 
                       tel_vlfaixas WITH FRAME f_consulta
                EDITING:
                    READKEY.
            
                    IF   FRAME-FIELD = "tel_tptaxrdc"         AND
                         KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
                         DO:
                            LEAVE.      
                         END.
                    ELSE 
                
                    IF   FRAME-FIELD = "tel_vlfaixas"   THEN
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                    ELSE
                        APPLY LASTKEY.

                END.  /* Fim do EDITING */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

                FIND FIRST crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                         crapdtc.tpaplica = tel_tptaxrdc AND
                                         crapdtc.flgstrdc = YES          AND
                                        (crapdtc.tpaplrdc = 1            OR 
                                         crapdtc.tpaplrdc = 2) 
                                         NO-LOCK NO-ERROR.
                IF NOT AVAIL crapdtc THEN
                   DO:
                       BELL.
                       MESSAGE "Tipo de Taxa deve ser 'PRE ou POS'.".
                       NEXT.
                   END.
                                    
                IF tel_dtmvtolt = ? THEN
                   DO:
                       ASSIGN glb_cdcritic = 13.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       NEXT.
                   END.
                   
                EMPTY TEMP-TABLE crattrd.
                FOR EACH craptrd  WHERE  craptrd.cdcooper =  glb_cdcooper AND 
                                         craptrd.tptaxrda =  tel_tptaxrdc AND 
                                         craptrd.dtiniper >= tel_dtmvtolt AND
                                         craptrd.vlfaixas =  tel_vlfaixas AND
                                         craptrd.incarenc = 0,
                         FIRST crapmfx WHERE 
                                       crapmfx.cdcooper = glb_cdcooper     AND
                                       crapmfx.dtmvtolt = craptrd.dtiniper AND
                                       crapmfx.tpmoefix = 6:
                            
                               CREATE crattrd.
                               ASSIGN crattrd.cdcooper = craptrd.cdcooper
                                      crattrd.tptaxrda = craptrd.tptaxrda
                                      crattrd.dtiniper = craptrd.dtiniper
                                      crattrd.vlfaixas = craptrd.vlfaixas
                                      crattrd.cdperapl = craptrd.cdperapl
                                      crattrd.txprodia = craptrd.txprodia
                                      crattrd.txofidia = craptrd.txofidia
                                      crattrd.vlmoefix = crapmfx.vlmoefix.
                               VALIDATE crattrd.
                END.                 
                
                FOR EACH crattrd: 
                
                    FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper     AND
                                       craptrd.tptaxrda = crattrd.tptaxrda AND
                                       craptrd.dtiniper = crattrd.dtiniper AND
                                       craptrd.cdperapl = crattrd.cdperapl AND
                                       craptrd.vlfaixas = crattrd.vlfaixas AND
                                       craptrd.incarenc = 1 NO-LOCK NO-ERROR.
                    
                     IF AVAIL craptrd THEN
                        DO:
                            ASSIGN crattrd.txresgat = craptrd.txofidia.
                        END.             
                END.
                
                OPEN QUERY q_craptrd FOR EACH crattrd.
                       
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE :
                    UPDATE b_craptrd WITH FRAME f_dados.
                END.
            END.   
        END.
    /*Retiradas as opções "I" e "A"
    
    IF  glb_cddopcao = "I" THEN
        DO:  
           IF  glb_cdcooper <> 3 THEN
               NEXT.
           
           DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
               ASSIGN tel_dtmvtolt = ?
                      tel_txcdiano = 0
                      aux_flgderro = FALSE.
               
               UPDATE tel_dtmvtolt tel_txcdiano WITH FRAME f_taxa.

               IF   MONTH(tel_dtmvtolt) <> MONTH(glb_dtmvtolt) THEN
                    DO:
                        ASSIGN glb_cdcritic = 347
                               aux_flgderro = TRUE.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_taxa.  
                        NEXT.
                    END.

               TRANS_1:
               DO TRANSACTION ON ERROR UNDO, LEAVE:
               
               FOR EACH crapcop NO-LOCK:
               
                  FIND crapmfx WHERE crapmfx.cdcooper = crapcop.cdcooper AND
                                     crapmfx.dtmvtolt = tel_dtmvtolt     AND
                                     crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR.
               
                  IF   AVAIL crapmfx THEN
                       NEXT.
                   
                  CREATE  crapmfx.
                  ASSIGN  crapmfx.cdcooper = crapcop.cdcooper
                          crapmfx.dtmvtolt = tel_dtmvtolt
                          crapmfx.vlmoefix = tel_txcdiano
                          crapmfx.tpmoefix = 6.
                  VALIDATE crapmfx.

                  RUN fontes/calcdata.p (INPUT tel_dtmvtolt,
                                         INPUT 1,
                                         INPUT "M", 
                                         INPUT 0,
                                         OUTPUT aux_dtfimper).

                  ASSIGN aux_dtmvtolt = tel_dtmvtolt
                         aux_qtdiaute = 0.
   
                  DO WHILE aux_dtmvtolt < aux_dtfimper:
                     IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                      
                          CAN-FIND(crapfer WHERE 
                                   crapfer.cdcooper = crapcop.cdcooper  AND
                                   crapfer.dtferiad = aux_dtmvtolt)     THEN
                          .    
                     ELSE 
                          aux_qtdiaute = aux_qtdiaute + 1.

                     aux_dtmvtolt = aux_dtmvtolt + 1.

                  END. /* Fim do DO WHILE TRUE */

                  IF  (aux_dtfimper - tel_dtmvtolt) < 28  OR
                      (aux_dtfimper - tel_dtmvtolt) > 35  THEN
                      DO:
                          ASSIGN glb_cdcritic = 13
                                 aux_flgderro = TRUE.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN tel_dtmvtolt = ?.
                          CLEAR FRAME f_taxa.
                          UNDO TRANS_1, LEAVE.
                      END.

                  FOR EACH crapdtc WHERE 
                           crapdtc.cdcooper = crapcop.cdcooper AND
                           crapdtc.flgstrdc = YES              AND
                          (crapdtc.tpaplrdc = 1                OR 
                           crapdtc.tpaplrdc = 2)               NO-LOCK:
                   
                      FOR EACH crapttx WHERE 
                               crapttx.cdcooper = crapcop.cdcooper AND
                               crapttx.tptaxrdc = crapdtc.tpaplica 
                               NO-LOCK:
                                    
                          FOR EACH crapftx WHERE 
                                   crapftx.cdcooper = crapcop.cdcooper AND
                                   crapftx.tptaxrdc = crapdtc.tpaplica AND
                                   crapftx.cdperapl = crapttx.cdperapl
                                   NO-LOCK: 

                              FIND craptrd WHERE 
                                   craptrd.cdcooper = crapcop.cdcooper AND
                                   craptrd.dtiniper = tel_dtmvtolt     AND
                                   craptrd.tptaxrda = crapdtc.tpaplica AND
                                   craptrd.incarenc = 0                AND
                                   craptrd.vlfaixas = crapftx.vlfaixas AND
                                   craptrd.cdperapl = crapftx.cdperapl
                                   NO-LOCK NO-ERROR.

                              IF   AVAILABLE craptrd THEN
                                   NEXT.
                                   
                              CREATE craptrd.
                              ASSIGN craptrd.cdcooper = crapcop.cdcooper
                                     craptrd.dtiniper = tel_dtmvtolt
                                     craptrd.qtdiaute = aux_qtdiaute
                                     craptrd.tptaxrda = crapdtc.tpaplica
                                     craptrd.incarenc = 0
                                     craptrd.vlfaixas = crapftx.vlfaixas
                                     craptrd.cdperapl = crapftx.cdperapl
                                     aux_txprodia = 
                                         (EXP((1 + tel_txcdiano / 100),
                                             (1 / 252)) - 1) * 100
                                     craptrd.txprodia = aux_txprodia
                                     craptrd.txofidia = 
                                         ROUND((aux_txprodia * 
                                                crapftx.perapltx / 100 ),6).
                              VALIDATE craptrd.
                           
                              IF   crapftx.perrdttx <> 0  THEN
                                   DO: 
                                       CREATE craptrd.
                                       ASSIGN
                                        craptrd.cdcooper = crapcop.cdcooper
                                        craptrd.dtiniper = tel_dtmvtolt
                                        craptrd.qtdiaute = aux_qtdiaute
                                        craptrd.tptaxrda = crapdtc.tpaplica
                                        craptrd.incarenc = 1
                                        craptrd.vlfaixas = crapftx.vlfaixas
                                        craptrd.cdperapl = crapftx.cdperapl
                                        aux_txprodia = 
                                           (EXP((1 + tel_txcdiano / 100),
                                               (1 / 252)) - 1) * 100
                                        craptrd.txprodia = aux_txprodia
                                        craptrd.txofidia =  
                                           ROUND((aux_txprodia * 
                                                crapftx.perrdttx / 100),6).
                                       VALIDATE craptrd.
                                   END.
                       
                          END. /** fim FOR EACH **/
                      END.
                  END.

                  IF   tel_dtmvtolt = glb_dtmvtolt THEN
                       aux_flatuant = TRUE.
                  ELSE
                       aux_flatuant = FALSE.
                                         
                  RUN sistema/generico/procedures/b1wgen0128.p 
                      PERSISTENT SET h-b1wgen0128.
    
                  RUN cadastra_taxa_cdi_mensal IN h-b1wgen0128 
                                (INPUT crapcop.cdcooper,
                                 INPUT INPUT FRAME f_taxa tel_txcdiano, 
                                 INPUT INPUT FRAME f_taxa tel_dtmvtolt,
                                 INPUT glb_dtmvtoan,
                                 INPUT glb_dtmvtopr,
                                 INPUT aux_flatuant).   
    
                  IF   RETURN-VALUE <> "OK" THEN
                       DO:
                           MESSAGE "ERRO AO CADASTRAR O CDI MENSAL - COOP: "
                                   + STRING(crapcop.nmrescop).
                           PAUSE 10 NO-MESSAGE.
                     
                           ASSIGN aux_flgderro = TRUE.
                           
                           DELETE PROCEDURE h-b1wgen0128.
                           UNDO TRANS_1, LEAVE.
                       END.
                  
                  RUN cadastra_taxa_cdi_acumulado IN h-b1wgen0128 
                                (INPUT crapcop.cdcooper,
                                 INPUT INPUT FRAME f_taxa tel_txcdiano,
                                 INPUT INPUT FRAME f_taxa tel_dtmvtolt,
                                 INPUT glb_dtmvtoan,
                                 INPUT glb_dtmvtopr,
                                 INPUT aux_flatuant).
    
                  IF   RETURN-VALUE <> "OK" THEN
                       DO:
                           MESSAGE "ERRO AO CADASTRAR O CDI ACUMUL - COOP: "
                                   + STRING(crapcop.nmrescop).
                           PAUSE 10 NO-MESSAGE.
                                  
                           ASSIGN aux_flgderro = TRUE.
                     
                           DELETE PROCEDURE h-b1wgen0128.
                           UNDO TRANS_1, LEAVE.
                       END.
                  ELSE
                       
                  DELETE PROCEDURE h-b1wgen0128.

               END.  /*  Fim do FOR EACH crapcop  */
               
               END.  /*  Fim da Transacao  */

               IF   aux_flgderro = FALSE THEN
                    DO:
                        MESSAGE "TAXA CADASTRADA COM SUCESSO EM TODAS AS COOP.".
                        PAUSE 10 NO-MESSAGE.
                    END.
               ELSE
                    DO:
                        MESSAGE "ERRO AO CADASTRAR A TAXA.".
                        PAUSE 10 NO-MESSAGE.
                    END.
                    
           END. /** Fim DO WHILE TRUE **/
      
        END. 
        
    IF  glb_cddopcao = "A"  THEN
        DO:
            IF  glb_cdcooper <> 3 THEN
                NEXT.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               /***limpa campo****/
               ASSIGN flg_incalcul = TRUE
                      aux_flgderro = FALSE
                      tel_txcdiano = 0
                      tel_dtmvtolt = ?.

               DISPLAY tel_txcdiano WITH FRAME f_taxa.
               
               UPDATE tel_dtmvtolt WITH FRAME f_taxa.

               IF   MONTH(tel_dtmvtolt) <> MONTH(glb_dtmvtolt) THEN
                    DO:
                        ASSIGN glb_cdcritic = 347
                               aux_flgderro = TRUE.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_taxa.  
                        NEXT.
                    END.

               FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper     AND
                                  crapmfx.dtmvtolt = tel_dtmvtolt     AND
                                  crapmfx.tpmoefix = 6 
                                  NO-LOCK NO-ERROR NO-WAIT.
            
               IF   AVAIL crapmfx THEN
                    DO:
                        ASSIGN tel_txcdiano = crapmfx.vlmoefix.
                        UPDATE tel_txcdiano WITH FRAME f_taxa.
                    END.
               ELSE
                    DO:
                        ASSIGN glb_cdcritic = 347
                               aux_flgderro = TRUE.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_taxa.  
                        NEXT.
                    END.

               TRANS_1:
               DO TRANSACTION ON ERROR UNDO, LEAVE:
               
               FOR EACH crapcop NO-LOCK:

                   FIND crapmfx WHERE  crapmfx.cdcooper = crapcop.cdcooper AND
                                       crapmfx.dtmvtolt = tel_dtmvtolt     AND
                                       crapmfx.tpmoefix = 6 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                   IF   NOT AVAILABLE crapmfx THEN
                        DO:
                            ASSIGN glb_cdcritic = 347
                                   aux_flgderro = TRUE.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            CLEAR FRAME f_taxa.  
                            UNDO TRANS_1, LEAVE.
                        END.

                   FIND FIRST craptrd WHERE 
                              craptrd.cdcooper = crapcop.cdcooper   AND
                              craptrd.dtiniper = tel_dtmvtolt       AND
                              craptrd.tptaxrda < 6                  AND
                              craptrd.incalcul = 2              
                              NO-LOCK NO-ERROR.

                   IF   AVAILABLE craptrd   THEN
                        DO:
                            IF   craptrd.vltrapli <> tel_txcdiano THEN
                                 DO:
                                     ASSIGN glb_cdcritic = 424.
                                            aux_flgderro = TRUE.
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     CLEAR FRAME f_taxa.  
                                     UNDO TRANS_1, LEAVE.
                                 END.
                        END.
                   
                   FOR EACH crapdtc WHERE 
                            crapdtc.cdcooper = crapcop.cdcooper AND
                            crapdtc.flgstrdc = YES              AND
                           (crapdtc.tpaplrdc = 1                OR 
                            crapdtc.tpaplrdc = 2)               NO-LOCK:

                       FOR EACH crapttx WHERE 
                                crapttx.cdcooper = crapcop.cdcooper AND
                                crapttx.tptaxrdc = crapdtc.tpaplica NO-LOCK: 
                                    
                           FOR EACH crapftx WHERE 
                                    crapftx.cdcooper = crapcop.cdcooper AND
                                    crapftx.tptaxrdc = crapdtc.tpaplica AND
                                    crapftx.cdperapl = crapttx.cdperapl
                                    NO-LOCK: 
               
                               FOR EACH craptrd WHERE 
                                    craptrd.cdcooper = crapcop.cdcooper AND
                                    craptrd.dtiniper = tel_dtmvtolt     AND
                                    craptrd.tptaxrda = crapdtc.tpaplica AND
                                    craptrd.cdperapl = crapttx.cdperapl AND
                                    craptrd.vlfaixas = crapftx.vlfaixas AND
                                    craptrd.incalcul = 0 EXCLUSIVE-LOCK:
                               
                                   ASSIGN flg_incalcul = FALSE.
                               
                                   IF craptrd.incarenc = 0 THEN    
                                      DO:
                                         ASSIGN aux_txprodia = 
                                                 (EXP((1 + tel_txcdiano / 100),
                                                      (1 / 252)) - 1) * 100
                                                craptrd.txprodia = aux_txprodia
                                                craptrd.txofidia = 
                                                  ROUND((aux_txprodia * 
                                                   crapftx.perapltx / 100 ),6).
                                      END.
                                   ELSE
                                    IF craptrd.incarenc = 1 THEN
                                       DO:
                                          ASSIGN aux_txprodia = 
                                                (EXP((1 + tel_txcdiano / 100),
                                                     (1 / 252)) - 1) * 100
                                                 craptrd.txprodia = aux_txprodia
                                                 craptrd.txofidia = 
                                                   ROUND((aux_txprodia *
                                                   crapftx.perrdttx / 100),6).
                                       END.
                               END.
                           END.
                       END.
                   END.

                   IF   flg_incalcul = FALSE THEN
                        ASSIGN crapmfx.vlmoefix = tel_txcdiano.
                        
                   IF   tel_dtmvtolt = glb_dtmvtolt THEN
                        aux_flatuant = TRUE.
                   ELSE
                        aux_flatuant = FALSE.
                        
                   RUN sistema/generico/procedures/b1wgen0128.p 
                            PERSISTENT SET h-b1wgen0128.
                
                   RUN cadastra_taxa_cdi_mensal IN h-b1wgen0128 
                                    (INPUT crapcop.cdcooper,
                                     INPUT crapmfx.vlmoefix, 
                                     INPUT tel_dtmvtolt,
                                     INPUT glb_dtmvtoan,
                                     INPUT glb_dtmvtopr,
                                     INPUT aux_flatuant). 
    
                   IF   RETURN-VALUE <> "OK" THEN
                        DO:
                            MESSAGE "ERRO AO ALTERAR O CDI MENSAL - COOP: "
                                    + STRING(crapcop.nmrescop).
                            PAUSE 10 NO-MESSAGE.
                                  
                            ASSIGN aux_flgderro = TRUE.
                            
                            DELETE PROCEDURE h-b1wgen0128.
                            UNDO TRANS_1, LEAVE.
                        END.

                   RUN cadastra_taxa_cdi_acumulado IN h-b1wgen0128 
                                    (INPUT crapcop.cdcooper,
                                     INPUT crapmfx.vlmoefix,         
                                     INPUT tel_dtmvtolt,
                                     INPUT glb_dtmvtoan,
                                     INPUT glb_dtmvtopr,
                                     INPUT aux_flatuant).
                                     
                   IF   RETURN-VALUE <> "OK" THEN
                        DO:
                            MESSAGE "ERRO AO ALTERAR O CDI ACUMUL - COOP: "
                                    + STRING(crapcop.nmrescop).
                            PAUSE 10 NO-MESSAGE.
                            
                            ASSIGN aux_flgderro = TRUE.
                                  
                            DELETE PROCEDURE h-b1wgen0128.
                            UNDO TRANS_1, LEAVE.
                        END.
                   
                   DELETE PROCEDURE h-b1wgen0128.
                     
               END.  /*  Fim do FOR EACH   */
               
               END.  /*  Fim da Transacao  */

               IF   aux_flgderro = FALSE                AND
                    KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                    DO:
                        MESSAGE "TAXA ALTERADA COM SUCESSO EM TODAS AS COOP.".
                        PAUSE 10 NO-MESSAGE.
                    END.
               ELSE
                    DO:
                        MESSAGE "TAXA NAO ALTERADA.".
                        PAUSE 10 NO-MESSAGE.
                    END.
            
            END. /** Fim DO WHILE TRUE **/
        END.    */
END.

