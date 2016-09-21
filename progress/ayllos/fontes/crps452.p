/* .............................................................................

   Programa: Fontes/crps452.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Julho/2005.                     Ultima atualizacao: 22/09/2014

   Dados referentes ao programa:

   Frequencia: Atende a solicitacao 2.
   Objetivo  : Ler o arquivo COO550 e gerar o arquivo COO407 para fazer a
               desmarcacao dos cheque que vieram marcados pelo BB.

   Alteracoes: 29/07/2005 - Alterada mensagem Log referente critica 847 (Diego).   
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               10/01/2006 - Correcao das mensagens para o LOG (Evandro).       
               
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................ */

DEF STREAM str_1.     /*  Para geracao do COO407   */
DEF STREAM str_2.     /*  Para arquivo de leitura  */

DEFINE TEMP-TABLE crawarq                                           NO-UNDO
          FIELD nmarquiv AS CHAR              
          FIELD nrsequen AS INTEGER
          FIELD qtassoci AS INTEGER
          INDEX crawarq1 AS PRIMARY
                nmarquiv nrsequen.

{ includes/var_batch.i "NEW" } 

DEF     VAR aux_cdseqtab AS INT                                     NO-UNDO.
  
DEF     VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
DEF     VAR aux_setlinha AS CHAR                                    NO-UNDO.
DEF     VAR aux_flgfirst AS LOGICAL                                 NO-UNDO.
  
DEF     VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF     VAR aux_contador AS INT                                     NO-UNDO.
DEF     VAR aux_nmarqdat AS CHAR                                    NO-UNDO.
   
DEF     VAR aux_nrtextab AS INT                                     NO-UNDO.
DEF     VAR aux_nrregist AS INT                                     NO-UNDO.
DEF     VAR aux_dtmvtolt AS CHAR                                    NO-UNDO.
DEF     VAR aux_maxcon   AS INT                                     NO-UNDO.

DEF     VAR arq_nrdctitg LIKE crapass.nrdctitg                      NO-UNDO.

DEF     VAR aux_dadosusr AS CHAR                                    NO-UNDO.
DEF     VAR par_loginusr AS CHAR                                    NO-UNDO.
DEF     VAR par_nmusuari AS CHAR                                    NO-UNDO.
DEF     VAR par_dsdevice AS CHAR                                    NO-UNDO.
DEF     VAR par_dtconnec AS CHAR                                    NO-UNDO.
DEF     VAR par_numipusr AS CHAR                                    NO-UNDO.
DEF     VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

DEF BUFFER crabtab FOR craptab. 

 FUNCTION f_ver_contaitg RETURN INTEGER(INPUT  par_nrdctitg AS CHAR):
       
    IF   par_nrdctitg = "" THEN
         RETURN 0.
    ELSE
         DO:
             IF   CAN-DO("1,2,3,4,5,6,7,8,9,0",
                         SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                  RETURN INTEGER(STRING(par_nrdctitg,"99999999")).
             ELSE
                  RETURN INTEGER(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                        1,LENGTH(par_nrdctitg) - 1) + "0").
         END.

 END. /* FUNCTION */

ASSIGN glb_cdprogra = "crps452".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         QUIT.
     END.

/*FOR EACH crawarq:
    DELETE crawarq.
END.*/
EMPTY TEMP-TABLE crawarq.

ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/compbb/COO550*.*"
       aux_flgfirst = TRUE.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo550" + STRING(DAY(glb_dtmvtolt),"99") +
                                            STRING(MONTH(glb_dtmvtolt),"99") +
                                            STRING(YEAR(glb_dtmvtolt),"9999") +
                                            STRING(aux_contador,"999").

   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                     aux_nmarqdat + " 2> /dev/null").
   
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").

   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") NO-ECHO.
      
   IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,027,05)) /* Quoter*/
          crawarq.nmarquiv = aux_nmarqdat
          aux_flgfirst     = FALSE.

   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_flgfirst THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         QUIT.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 550           NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         QUIT.
     END.    
                            
ASSIGN aux_cdseqtab = INTEGER(SUBSTR(craptab.dstextab,01,05)).
   
FOR EACH crawarq BY crawarq.nrsequen
                   BY crawarq.nmarquiv:  

    IF   aux_cdseqtab = crawarq.nrsequen THEN
         RUN p_processa_arquivo.
    ELSE
         DO:
             glb_cdcritic = 476.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - COO550 - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " " +
                               "SEQ.BB " + STRING(crawarq.nrsequen) + " " +
                               "SEQ.COOP " + STRING(aux_cdseqtab) + " - " +
                                crawarq.nmarquiv +
                               " >> log/proc_batch.log").
             ASSIGN glb_cdcritic = 0
                    aux_nmarquiv = "integra/err" +
                                   SUBSTR(crawarq.nmarquiv,12,29).
             UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
             UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
             NEXT.
         END. 

END.   /*  Fim da PROCEDURE  */

RUN fontes/fimprg.p.

/* .......................................................................... */

PROCEDURE p_processa_arquivo:

   DEF  VAR aux_nrdctitg AS INTEGER       FORMAT "9999999"        NO-UNDO.
                   
   DEF  VAR arq_nrcheque AS INTEGER                               NO-UNDO.
   DEF  VAR arq_vlcheque  AS DECIMAL                              NO-UNDO.
   DEF  VAR arq_cdalinea AS INT                                   NO-UNDO.
   DEF  VAR aux_cdalinea AS INTEGER                               NO-UNDO.
   
   INPUT STREAM str_2 FROM VALUE(crawarq.nmarquiv) NO-ECHO.

   /*   Header do Arquivo   */
    
   IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
                     
   IF   SUBSTR(aux_setlinha,01,05) <> "00000" THEN
        glb_cdcritic = 468.
   
   IF   INTEGER(SUBSTR(aux_setlinha,06,04)) <> crapcop.cdageitg THEN
        glb_cdcritic = 134.

   IF   INTEGER(SUBSTR(aux_setlinha,10,08)) <> crapcop.nrctaitg THEN
        glb_cdcritic = 127.
   
   IF   INTEGER(SUBSTR(aux_setlinha,52,09)) <> crapcop.cdcnvitg THEN
        glb_cdcritic = 563.
    
   IF   glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_2 CLOSE.
            RUN fontes/critic.p.
            aux_nmarquiv = "integra/err" + SUBSTR(crawarq.nmarquiv,12,29).
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - COO550 - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " - " + aux_nmarquiv +
                              " >> log/proc_batch.log").
            glb_cdcritic = 0.
            QUIT.
        END.
          
   RUN abre_arquivo.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
      IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0
             aux_cdalinea = 0.
      
      /*  Verifica se eh final do Arquivo  */
      
      IF   INTEGER(SUBSTR(aux_setlinha,01,05)) = 99999 THEN
           DO:
                /*   Conferir o total do arquivo   */

                IF   (aux_nrregist + 2) <> 
                     DECIMAL(SUBSTR(aux_setlinha,06,09)) THEN
                     DO:
                         ASSIGN glb_cdcritic = 504
                                aux_nmarquiv = "integra/err" +
                                               SUBSTR(crawarq.nmarquiv,12,29).
                         
                         RUN fontes/critic.p.
                         INPUT STREAM str_2 CLOSE.
                         UNIX SILENT VALUE("rm " + crawarq.nmarquiv +
                                           ".q 2> /dev/null").
                         UNIX SILENT VALUE("mv " + crawarq.nmarquiv +
                                           " " + aux_nmarquiv).
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - COO550 - " + glb_cdprogra + 
                                           "' --> '" + glb_dscritic + " - " +
                                           aux_nmarquiv +
                                           " >> log/proc_batch.log").
                         glb_cdcritic = 0.
                  
                     END.

                  LEAVE.
           END.

      ASSIGN arq_nrdctitg = SUBSTR(aux_setlinha,06,08).
      
      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdctitg = arq_nrdctitg NO-LOCK NO-ERROR.
      
      IF   NOT AVAILABLE crapass   THEN
           DO:
              glb_cdcritic = 9.
              RUN fontes/critic.p.
              UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - COO407 - " + glb_cdprogra + "' --> '"  +
                                glb_dscritic + " - CONTA ITG = " + 
                                arq_nrdctitg + " >> /log/proc_batch.log").
              glb_cdcritic = 0.
              NEXT.
           END.
      
      RUN registro.
               
   END.  /*   Fim  do DO WHILE TRUE  */

   RUN fecha_arquivo.
   
END PROCEDURE.

PROCEDURE abre_arquivo:
     
   FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                      crabtab.nmsistem = "CRED"        AND
                      crabtab.tptabela = "GENERI"      AND
                      crabtab.cdempres = 00            AND
                      crabtab.cdacesso = "NRARQMVITG"  AND
                      crabtab.tpregist = 407 NO-LOCK NO-ERROR NO-WAIT.

   ASSIGN aux_nrtextab = INT(SUBSTRING(crabtab.dstextab,1,5))
          aux_nmarqimp = "coo407" +
                         STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(aux_nrtextab,"99999") + ".rem"
          aux_nrregist = 0
          aux_dtmvtolt = STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(YEAR(glb_dtmvtolt),"9999").
       
   OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).

   /* ------------   Header do Arquivo   ------------  */

   PUT STREAM str_1 "0000000"
                    crapcop.cdageitg            FORMAT "9999"
                    crapcop.nrctaitg            FORMAT "99999999"
                    "COO407  "
                    aux_nrtextab                FORMAT "99999"
                    aux_dtmvtolt                FORMAT "x(08)"
                    crapcop.cdcnvitg            FORMAT "999999999"
                    crapcop.cdmasitg            FORMAT "99999"
                    FILL(" ",21)                FORMAT "x(21)" 
                    SKIP.
             
END PROCEDURE.

PROCEDURE fecha_arquivo:

   /* ------------   Trailer do Arquivo   ------------  */

   PUT STREAM str_1 "9999999"
                    (aux_nrregist + 2)    FORMAT "999999999"
                    FILL(" ",54)          FORMAT "x(54)"
                    SKIP.            
   
   OUTPUT STREAM str_1 CLOSE.

   /* verifica se o arquivo gerado nao tem registros "detalhe", ai elimina-o */

   IF   aux_nrregist = 0   THEN
        DO:
            UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null"). 
            LEAVE.        
        END.

   /* mensagem de envio de arquivo no log */
   glb_cdcritic = 847.
   RUN fontes/critic.p.
            
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - COO407 - " + glb_cdprogra + "' --> '" + glb_dscritic +
                     " - " + aux_nmarqimp + " >> log/proc_batch.log").
    
   /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
   UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                     ' | tr -d "\032"' +  
                     " > /micros/" + crapcop.dsdircop +
                     "/compel/" + aux_nmarqimp + " 2>/dev/null").

   UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null"). 
   
   /* move o arquivo COO550 para o diretorio "salvar" */
   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar 2>/dev/null").

   /* remove o QUOTER do COO550 */
   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2>/dev/null").
   
   ASSIGN aux_nrtextab = aux_nrtextab + 1      /* COO407 */
          aux_cdseqtab = aux_cdseqtab + 1      /* COO500 */
          aux_maxcon   = 0.
          
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
   
      /* atualiza a tab do COO550 */
      DO WHILE TRUE:

         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "NRARQMVITG"  AND
                            craptab.tpregist = 550
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crabtab   THEN
              IF   LOCKED crabtab   THEN
                   DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                       
                        NEXT.

                   END.
              ELSE
                   DO:
                       glb_cdcritic = 55.
                       LEAVE.
                   END.    
         ELSE
              glb_cdcritic = 0.

         LEAVE.
      END.   
      ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_cdseqtab,"99999").

      /* Atualiza a sequencia da remessa COO407 */
      DO WHILE TRUE:

         FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                            crabtab.nmsistem = "CRED"        AND
                            crabtab.tptabela = "GENERI"      AND
                            crabtab.cdempres = 00            AND
                            crabtab.cdacesso = "NRARQMVITG"  AND
                            crabtab.tpregist = 407
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crabtab   THEN
              IF   LOCKED crabtab   THEN
                   DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        NEXT.

                   END.
              ELSE
                   DO:
                       glb_cdcritic = 55.
                       LEAVE.
                   END.    
         ELSE
              glb_cdcritic = 0.

         LEAVE.
            
      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0 THEN
           QUIT.

      ASSIGN SUBSTRING(crabtab.dstextab,1,5) = STRING(aux_nrtextab,"99999").

   END. /* TRANSACTION */
       
END PROCEDURE.

PROCEDURE registro:

    IF  aux_maxcon > 9988  THEN  /* Maximo 9990 */
        DO:
           RUN fecha_arquivo.
           RUN abre_arquivo.
        END.
    
    /* registro (tipo unico) */             
    ASSIGN aux_maxcon   = aux_maxcon + 1 
           aux_nrregist = aux_nrregist + 1.
           
    PUT STREAM str_1 aux_nrregist                    FORMAT "99999"
                     "01"
                     arq_nrdctitg                    FORMAT "x(08)"
                     "02"
                     INT(SUBSTR(aux_setlinha,14,06)) FORMAT "999999"
                     INT(SUBSTR(aux_setlinha,20,17)) FORMAT "99999999999999999"
                     "0000"
                     crapass.nrdconta                FORMAT "99999999"
                     FILL(" ",18)                    FORMAT "x(18)"
                     SKIP. 
    
END PROCEDURE.

/* ..........................................................................*/

