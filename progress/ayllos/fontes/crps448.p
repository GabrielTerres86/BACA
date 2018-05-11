/* .............................................................................

   Programa: fontes/crps448.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Junho/2005                   Ultima atualizacao: 07/11/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 100.
               Tratar arquivo retorno (COO508) de INCLUSAO NO CCF (COO408)
               dos associados, recebido pelo Banco do Brasil.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego)
                            
               10/01/2006 - Correcao das mensagens para o LOG e envio de e-mail
                            quando houver RECUSA TOTAL (Evandro).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               20/02/2006 - Acerto na mensagem arquivo processado (Evandro).
               
               10/04/2006 - Excluido envio de e-mail para
                            marcospaulo@cecred.coop.br (Diego).
                            
               06/11/2006 - Mostrar as criticas vindas no arquivo (Evandro).
               
               09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme);
                          - Corrigida capturacao da data no arquivo (Evandro).
                          
               23/01/2008 - Buscar registro crapneg mesmo que a data venha
                            zerada no arquivo e adicionar o numero do cheque na
                            critica (Evandro).

               29/01/2008 - Armazenar a titularidade e o numero do cheque no
                            lugar do codigo de erro para nao dar duplicates
                            (Evandro).
                            
               30/01/2008 - Corrigir os registros crapneg para as criticas:
                            "NAO LOCAL. NO CCF P/EXCLUSAO"
                            "EXISTE INCLUSAO PARA DOCUMENTO" (Evandro).

               01/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)                            
                            
               24/09/2008 - Na recusa total, reenviar somente registros do
                            Banco do Brasil (Evandro).
                            
               09/01/2009 - Mover arquivo err* para diretorio /salvar e enviar
                            email para suporte.operacional@cecred.coop.br
                            (Diego).
                            
               21/06/2010 - Alteracao tamanho SET STREAM e extensao .ret (Vitor).            
                   
               20/09/2010 - Inclusao do e-mail cartoes@cecred.coop.br (Adriano).

               31/05/2012 - Alteracao de email suporte para compe - Trf. 46725 
                           (Ze)  
                           
               01/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               28/08/2012 - Inclusão de e-mail cobranca@cecred.coop.br na rotina
                            enviar_email, exclusão de william@cecred.coop.br
                            (Lucas R.)
                
               17/12/2012 - Envio de emails referente ao COO500 a COO599 para
                            convenios@cecred.coop.br ao inves de 
                            compe@cecred.coop.br (Tiago). 
                            
               15/04/2013 - Retirado e-mail de cobranca na rotina enviar_email
                           (Daniele).  
                           
               10/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)                                             
                            
               07/11/2017 - Adicionar validacao para inserir registros na crapeca (Lucas Ranghetti #740723)
............................................................................. */

{ includes/var_batch.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR aux_nrdconta AS INT      FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrsequen AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrctaitg AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_flaglast AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrcheque AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtiniest LIKE crapneg.dtiniest                    NO-UNDO.

DEF        VAR rel_nmempres AS CHAR     FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR     FORMAT "x(15)"               NO-UNDO.

DEF        VAR rel_nmrelato AS CHAR     FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEF        VAR rel_nrmodulo AS INT      FORMAT "9"                   NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR     FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

/* nome do arquivo de log */
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.

DEFINE TEMP-TABLE crawarq                                            NO-UNDO
          FIELD nmarquiv AS CHAR
          FIELD nrsequen AS INTEGER
          INDEX crawarq1 AS PRIMARY
                nmarquiv nrsequen.

   /* variaveis para as criticas */
DEF        VAR aux_dsprogra AS CHAR     FORMAT "x(6)"                NO-UNDO.
DEF        VAR aux_tpregist AS INT                                   NO-UNDO.
DEF        VAR aux_cdocorre AS INT                                   NO-UNDO.
DEF        VAR aux_dscritic AS CHAR     FORMAT "x(50)"               NO-UNDO.

DEF BUFFER crabtab FOR craptab.

ASSIGN glb_cdprogra = "crps448"
       aux_dsprogra = "COO408"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

EMPTY TEMP-TABLE crawarq.

ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/compel/recepcao/COO508*.ret"
       aux_flgfirst = TRUE
       aux_contador = 0
       aux_nrseqarq = 1000. /* nro. ficticio */
 
INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo508" + STRING(DAY(glb_dtmvtolt),"99") +
                                            STRING(MONTH(glb_dtmvtolt),"99") +
                                            STRING(YEAR(glb_dtmvtolt),"9999") +
                                            STRING(aux_contador,"999").

   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                     aux_nmarqdat + " 2> /dev/null").
   
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").
 
   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO.
       
   IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,039,05))
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
                           " - COO508 - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 508           NO-ERROR NO-WAIT. 

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.    

ASSIGN aux_nrsequen = INTEGER(SUBSTR(craptab.dstextab,01,05)).

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                   crabtab.nmsistem = "CRED"        AND
                   crabtab.tptabela = "GENERI"      AND
                   crabtab.cdempres = 00            AND
                   crabtab.cdacesso = "NRARQMVITG"  AND
                   crabtab.tpregist = 408           NO-ERROR NO-WAIT.
     
IF   NOT AVAILABLE crabtab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.    
     
/* pre-filtragem dos arquivos */
FOR EACH crawarq BREAK BY crawarq.nrsequen:
                    
    IF   LAST-OF(crawarq.nrsequen)   THEN
         DO:
            IF   crawarq.nrsequen = aux_nrsequen   THEN
                 ASSIGN aux_nrsequen = aux_nrsequen + 1.
            ELSE
                 DO:
                     /* sequencia errada */
                     glb_cdcritic = 476.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO508 - " + glb_cdprogra + 
                                       "' --> '"  +
                                       glb_dscritic + " " +
                                       "SEQ.BB " + STRING(crawarq.nrsequen) + 
                                       " " + "SEQ.COOP " + 
                                       STRING(aux_nrsequen) + " - " +
                                       "salvar/err" + 
                                       SUBSTR(crawarq.nmarquiv,12,29) +
                                       " >> " + aux_nmarqlog).
                     ASSIGN glb_cdcritic = 0
                            aux_nmarquiv = "salvar/err" +
                                           SUBSTR(crawarq.nmarquiv,12,29).

                     /* move o arquivo para o /salvar */
                     UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                                       aux_nmarquiv).
                     UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                       ".q 2> /dev/null").
                                       
                     UNIX SILENT VALUE
                          ("cp " + aux_nmarquiv + " /usr/coop/" +
                           crapcop.dsdircop + "/converte" +
                           " 2> /dev/null").
                     
                     /* envio de email */ 
                     RUN sistema/generico/procedures/b1wgen0011.p
                         PERSISTENT SET b1wgen0011.
          
                     RUN enviar_email IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT "convenios@cecred.coop.br," +
                                         "cartoes@cecred.coop.br",
                                   INPUT '"ERRO DE SEQUENCIA - "' +
                                         '"COO508 - "' +
                                         crapcop.nmrescop,
                                   INPUT SUBSTRING(aux_nmarquiv,8),
                                   INPUT FALSE).

                     DELETE PROCEDURE b1wgen0011.
                    
                     DELETE crawarq.
                     NEXT.
                 END.
         END.
END.
     
/* processar os arquivos que ja foram pre-filtrados */
FOR EACH crawarq BREAK BY crawarq.nrsequen
                         BY crawarq.nmarquiv:  

    IF   LAST-OF(crawarq.nrsequen)   THEN
         aux_flaglast = YES.
    ELSE
         aux_flaglast = NO.
    
    RUN proc_processa_arquivo.
    
    IF   glb_cdcritic = 0   THEN
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO508 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN fontes/fimprg.p.                   

PROCEDURE proc_processa_arquivo:

   DEFINE VAR aux_qtregist AS INT  NO-UNDO.

   INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
   
   glb_cdcritic = 0.
   
   /*   Header do Arquivo   */
   IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
   
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
            INPUT STREAM str_1 CLOSE.
            
            RUN fontes/critic.p.
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).

            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - COO508 - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " - " + aux_nmarquiv +
                              " >> " + aux_nmarqlog).
                              
            /* Copia para diretorio converte para utilizar na BO */
            
            UNIX SILENT VALUE ("cp " + aux_nmarquiv + " /usr/coop/" +
                               crapcop.dsdircop + "/converte" +
                               " 2> /dev/null").
                     
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.
          
            RUN enviar_email IN b1wgen0011
                               (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "convenios@cecred.coop.br," + 
                                      "cartoes@cecred.coop.br",
                                INPUT '"ERROS DIVERSOS - "' +
                                      '"COO508 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.
            
            RETURN.
        END.

   IF   INTEGER(SUBSTR(aux_setlinha,156,03)) <> 1 AND   /*  Recusa Total   */
        INTEGER(SUBSTR(aux_setlinha,156,03)) <> 4 THEN  /*  Recusa Parcial */
        DO:
            ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_setlinha,156,03)).
            
            /*   Recusa Total do Arquivo  */
            IF   aux_cdocorre = 2   OR
                 aux_cdocorre = 3   OR
                 aux_cdocorre = 5   OR
                 aux_cdocorre = 6   OR
                 aux_cdocorre = 8   THEN
                 RUN p_recusa_total.

            INPUT STREAM str_1 CLOSE.
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).
            
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").

            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).

            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.
                 
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO508 - " + glb_cdprogra + 
                                       "' --> '" +
                                       glb_dscritic +  
                                       "RECUSA TOTAL - " +
                                       crawarq.nmarquiv +
                                       " >> " + aux_nmarqlog).
                 END.
            ELSE
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - COO508 - " + glb_cdprogra + 
                                      "' --> '" +
                                      "RECUSA TOTAL - " +
                                      crawarq.nmarquiv +
                                      " >> " + aux_nmarqlog).
                                      
                     glb_cdcritic = 182.
                 END.
                 
            /* Copia para diretorio converte para utilizar na BO */
            
            UNIX SILENT VALUE ("cp " + aux_nmarquiv + " /usr/coop/" +
                               crapcop.dsdircop + "/converte" +
                               " 2> /dev/null").
                     
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.
          
            RUN enviar_email IN b1wgen0011
                               (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "convenios@cecred.coop.br," +
                                      "cartoes@cecred.coop.br",
                                INPUT '"RECUSA TOTAL - "' +
                                      '"COO508 - "' + 
                                      crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.
            
            RETURN.
        END.         /*   Fim  da  Recusa  Total  */
   
   DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0
             aux_qtregist = aux_qtregist + 1.

      /*  Verifica se eh final do Arquivo  */
      IF   INTEGER(SUBSTR(aux_setlinha,1,1)) = 9 THEN
           DO:
               /*   Conferir o total do arquivo   */

               IF   (aux_qtregist + 1) <> 
                    DECIMAL(SUBSTR(aux_setlinha,06,09)) THEN             
                    DO:
                        ASSIGN glb_cdcritic = 504.
                         
                        RUN fontes/critic.p.

                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - COO508 - " + glb_cdprogra + 
                                          "' --> '" +
                                          glb_dscritic + 
                                          " - ARQUIVO PROCESSADO - " + 
                                          aux_nmarquiv +
                                          " >> " + aux_nmarqlog).
                        LEAVE.
                    END.
           END.
      ELSE
           /* tratamento dos registros detalhe */
           DO:
              ASSIGN aux_tpregist = INT(SUBSTR(aux_setlinha,11,2))
                     aux_cdocorre = INT(SUBSTR(aux_setlinha,156,3))
                     aux_nrcheque = SUBSTRING(aux_setlinha,39,6).
                     
              /* Ignora a data se vier zerada */
              IF   INT(SUBSTRING(aux_setlinha,68,2)) = 0   OR
                   INT(SUBSTRING(aux_setlinha,70,2)) = 0   OR
                   INT(SUBSTRING(aux_setlinha,64,4)) = 0   THEN
                   aux_dtiniest = ?.
              ELSE
                   aux_dtiniest = DATE(INT(SUBSTRING(aux_setlinha,68,2)),
                                       INT(SUBSTRING(aux_setlinha,70,2)),
                                       INT(SUBSTRING(aux_setlinha,64,4))).

              /* Nro Conta Integracao */
              ASSIGN aux_nrctaitg = TRIM(SUBSTR(aux_setlinha,13,8))
                     aux_nrdconta = 0.
                     
              FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                                 crapass.nrdctitg = aux_nrctaitg 
                                 NO-LOCK NO-ERROR.

              IF  AVAILABLE crapass  THEN 
                  ASSIGN aux_nrdconta = crapass.nrdconta.
              ELSE
                  NEXT.
                  
              IF  aux_cdocorre <> 0   THEN     /* COM ERRO */
                  DO:
                      aux_dscritic = SUBSTR(aux_setlinha,159,42) +
                                     " CHEQUE: " + aux_nrcheque.

                      /* Atualiza o registro para Reenviar */
                      FIND crapneg WHERE crapneg.cdcooper = glb_cdcooper    AND
                                         crapneg.nrdconta = aux_nrdconta    AND
                                        (crapneg.flgctitg = 1   OR
                                         crapneg.flgctitg = 2   OR
                                         crapneg.flgctitg = 4)              AND
                                         SUBSTRING(STRING(crapneg.nrdocmto,
                                           "9999999"),1,6) = aux_nrcheque   AND
                                        (crapneg.dtiniest  = aux_dtiniest   OR
                                         aux_dtiniest      = ?)
                                         USE-INDEX crapneg1
                                         EXCLUSIVE-LOCK NO-ERROR.
                                          
                      IF   AVAILABLE crapneg   THEN
                           DO:
                               /* Corrige o crapneg conforme a critica */
                               IF   aux_dscritic BEGINS 
                                         "NAO LOCAL. NO CCF P/EXCLUSAO"   OR
                                    aux_dscritic BEGINS
                                        "REGISTRO NAO ENCONTRADO - CCF" OR
                                    aux_dscritic BEGINS
                                         "EXISTE INCLUSAO PARA DOCUMENTO" THEN
                                    DO:
                                        ASSIGN crapneg.flgctitg = 2. /* OK */
                                        NEXT.
                                    END.
                               ELSE
                                    ASSIGN crapneg.flgctitg = 4. /* Reenviar */
                           END.

                      FIND FIRST crapeca WHERE crapeca.cdcooper = glb_cdcooper
                                           AND crapeca.tparquiv = 508
                                           AND crapeca.nrdconta = aux_nrdconta
                                           AND crapeca.nrseqarq = crawarq.nrsequen
                                           AND crapeca.nrdcampo = INT(STRING(INT(SUBSTR(aux_setlinha,112,2))) +
                                                                   aux_nrcheque)
                                           NO-LOCK NO-ERROR.
                                     
                      IF  NOT AVAILABLE crapeca THEN
                          DO:
                              CREATE crapeca.
                              ASSIGN crapeca.cdcooper = glb_cdcooper
                                     crapeca.nrdconta = aux_nrdconta
                                     crapeca.dtretarq = glb_dtmvtolt
                                     crapeca.nrdcampo = 
                                          INT(STRING(INT(SUBSTR(aux_setlinha,112,2))) +
                                              aux_nrcheque)
                                     crapeca.nrseqarq = crawarq.nrsequen
                                     crapeca.tparquiv = 508
                                     crapeca.idseqttl = INT(SUBSTR(aux_setlinha,112,2))
                                     crapeca.dscritic = aux_dscritic.
                              VALIDATE crapeca.
                          END.
                      
                  END.
              ELSE     /* se registro detalhe foi processado com sucesso */
                  DO:
                     /* Atualiza o registro */
                     FIND crapneg WHERE crapneg.cdcooper = glb_cdcooper     AND
                                        crapneg.nrdconta = aux_nrdconta     AND
                                        SUBSTRING(STRING(crapneg.nrdocmto,
                                           "9999999"),1,6) = aux_nrcheque   AND
                                        crapneg.dtiniest = aux_dtiniest
                                        USE-INDEX crapneg1
                                        EXCLUSIVE-LOCK NO-ERROR.
                                          
                     IF   AVAILABLE crapneg   THEN
                          ASSIGN crapneg.flgctitg = 2. /* OK */
                  END.  
           END. 
           
   END. /* fim DO WHILE TRUE */

   INPUT STREAM str_1 CLOSE.
   
   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
   
   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
   
   IF   glb_cdcritic = 0     AND     /* se esta OK */
        aux_flaglast = YES   THEN    /* e eh o ultimo da sequencia */
        DO TRANSACTION:

            ASSIGN SUBSTRING(craptab.dstextab,1,5) = 
                             STRING(crawarq.nrsequen + 1,"99999").

        END.

END PROCEDURE. /* FIM proc_processa_arquivo */

PROCEDURE p_recusa_total:

    /* Bloquear tabela de envio */
    ASSIGN SUBSTRING(crabtab.dstextab,1,7) = SUBSTR(aux_setlinha,39,05) + " 1".
    
    /* Deixar sequencia que estou processando arq.recebimento */
    ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(crawarq.nrsequen,"99999"). 
               
    FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper   AND
                           crapneg.flgctitg = 1              AND
                           crapneg.cdbanchq = 1 /* BB */
                           USE-INDEX crapneg5 EXCLUSIVE-LOCK:   
        ASSIGN crapneg.flgctitg = 4. /* Reenviar */
    END.
    
END.   /*   Fim da Procedure  */

/* .......................................................................... */

