/* ..........................................................................

   Programa: fontes/crps504.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Marco/2008                      Ultima atualizacao: 13/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 100.
               Tratar arquivo retorno (COO509) - ENCERRAMENTO CONTA ITG.
               
   Alteracoes: 11/04/2008 - Alterado envio de email para BO b1wgen0011 (Diego).
   
               09/01/2009 - Mover arquivo err* para diretorio /salvar (Diego).
                          - Atualizar crapass.flgctitg quando retorno da
                            reativacao (Gabriel).
                            
               11/02/2009 - Enviar email para 
                            suporte.operacional@cecred.coop.br quando houver
                            erro (Diego).

               11/03/2009 - Efetuada correcao nome arquivo e_mail(Mirtes)      
                          - Caso retorne 5 - REATIVACAO PARA CONTA ATIVA
                            tratar como 0 - PROCESSADO (Fernando).

               22/04/2009 - Nao desprezar arquivo com recusa total = 8 (David).
               
               21/06/2010 - Alteracao tamanho SET STREAM e extensao.ret(Vitor).
                               
               20/09/2010 - Inclusao do e-mail cartoes@cecred.coop.br (Adriano).
               
               08/11/2010 - Copia do arquivo COO509 p/ o diretorio  
                           /micros/cooperativa/compel/recepcao/retornos (Vitor)
                           
               19/10/2011 - Eliminacao das criticas quando registro processado
                            ok(Mirtes)       

               31/05/2012 - Alteracao de email suporte para compe - Trf. 46725 
                           (Ze)
                           
               03/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               29/08/2012 - Inclusão de e-mail cobranca@cecred.coop.br na rotina
                            enviar_email, exclusão de william@cecred.coop.br
                            (Lucas R.) 
                            
               06/11/2012 - Verificar se já existe registro na crapeca antes
                            de criar (Lucas).
                            
               12/11/2012 - Retirar matches dos find/for each (Gabriel).             
               
               17/12/2012 - Envio de emails referente ao COO500 a COO599 para
                            convenios@cecred.coop.br ao inves de
                            compe@cecred.coop.br (Tiago).                           
                            
               20/12/2012 - Implementado critica 953 de recusa total COO509
                            (Tiago). 
                            
               15/04/2013 - Retirado e-mail de cobranca na rotina enviar_email
                           (Daniele).                         
                           
               27/07/2013 - Alteração para quando for recusa total mesmo assim
                            iterar sobre o arquivo para tratar reativacao para
                            conta ativa itg (Tiago).
                            
               30/07/2013 - Alterado a forma como era tratado quando o arquivo
                            de retorno vinha com a critica (reativacao para 
                            conta ativa) (Tiago).
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)              
............................................................................. */

{ includes/var_batch.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF        VAR aux_nrdconta AS INT      FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_fstlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrsequen AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrctaitg AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_flaglast AS LOGICAL                               NO-UNDO.
DEF        VAR aux_ver_sequencia AS INTE                             NO-UNDO.

DEF        VAR rel_nmempres AS CHAR     FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR     FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR     FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEF        VAR rel_nrmodulo AS INT      FORMAT "9"                   NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR     FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.

/* variaveis para as criticas */
DEF        VAR aux_dsprogra AS CHAR     FORMAT "x(6)"                NO-UNDO.
DEF        VAR aux_cdocorre AS INT                                   NO-UNDO.
DEF        VAR aux_dscritic AS CHAR     FORMAT "x(50)"               NO-UNDO.

DEF        VAR b1wgen0011   AS HANDLE                                NO-UNDO.

DEF BUFFER crabalt FOR crapalt.

DEFINE TEMP-TABLE crawarq                                            NO-UNDO
       FIELD nmarquiv AS CHAR
       FIELD nrsequen AS INTEGER
       INDEX crawarq1 AS PRIMARY
             nmarquiv nrsequen.

DEF BUFFER crabtab FOR craptab.

ASSIGN glb_cdprogra = "crps504"
       aux_dsprogra = "COO509"
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
                      "/compel/recepcao/COO509*.ret"
       aux_flgfirst = TRUE
       aux_contador = 0
       aux_nrseqarq = 1000. /* nro. ficticio */

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .
   
   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo509" + STRING(DAY(glb_dtmvtolt),"99") +
                                            STRING(MONTH(glb_dtmvtolt),"99") +
                                            STRING(YEAR(glb_dtmvtolt),"9999") +
                                            STRING(aux_contador,"999").

   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                     aux_nmarqdat + " 2> /dev/null").

   UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + "/micros/" + 
                     crapcop.dsdircop + "/compel/recepcao/retornos").
                             
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
                           " - COO509 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 509
                   NO-LOCK NO-ERROR.

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

/* sequencia de retorno esperada */
ASSIGN aux_nrsequen = INTEGER(SUBSTR(craptab.dstextab,01,05)).

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper   AND
                   crabtab.nmsistem = "CRED"         AND
                   crabtab.tptabela = "GENERI"       AND
                   crabtab.cdempres = 00             AND
                   crabtab.cdacesso = "NRARQMVITG"   AND
                   crabtab.tpregist = 409
                   NO-LOCK NO-ERROR.

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
FOR EACH crawarq  BREAK BY crawarq.nrsequen:

    IF   LAST-OF(crawarq.nrsequen)   THEN
         DO:
             IF   crawarq.nrsequen <= aux_nrsequen   THEN      
                  DO:
                      IF   crawarq.nrsequen = aux_nrsequen THEN
                           DO:
                               ASSIGN aux_nrsequen = aux_nrsequen + 1.
                           END.  
                  END.    
             ELSE
                  DO:
                      /* sequencia errada */
                      glb_cdcritic = 476.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - COO509 - " + glb_cdprogra + 
                                        "' --> '"  +
                                        glb_dscritic + " " + 
                                        "SEQ.BB " + STRING(crawarq.nrsequen) + 
                                        " " + "SEQ.COOP " + 
                                        STRING(aux_nrsequen) + " - " +
                                        crawarq.nmarquiv +
                                        " >> " + aux_nmarqlog).
                      ASSIGN glb_cdcritic = 0
                             aux_nmarquiv = "salvar/err" +
                                            SUBSTR(crawarq.nmarquiv,12,29).

                      /* move o arquivo para o /salvar */
                      UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                                        aux_nmarquiv).

                      /* Apagar o arquivo QUOTER */
                      UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                        ".q 2> /dev/null").
                                       
                      /* E-mail para CENTRAL avisando sobre o ERRO DE SEQ. */ 
                      UNIX SILENT VALUE ("cp " + aux_nmarquiv + " /usr/coop/" +
                                         crapcop.dsdircop + "/converte" +
                                         " 2> /dev/null").
                             
                      /* envio de email */ 
                      RUN sistema/generico/procedures/b1wgen0011.p
                          PERSISTENT SET b1wgen0011.
                      
                      RUN enviar_email IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT "convenios@cecred.coop.br," +
                                         "cartoes@cecred.coop.br",                                   INPUT '"ERRO DE SEQUENCIA - "' +
                                         '"COO509 - "' +
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
FOR EACH crawarq NO-LOCK BREAK BY crawarq.nrsequen              
                                 BY crawarq.nmarquiv:  

    IF   LAST-OF(crawarq.nrsequen)   THEN
         aux_flaglast = YES.
    ELSE
         aux_flaglast = NO.
    
    RUN proc_processa_arquivo.
    
    IF   glb_cdcritic = 0   THEN
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO509 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN fontes/fimprg.p.                   


/* .......................................................................... */

PROCEDURE proc_processa_arquivo.

   ASSIGN glb_cdcritic = 0
          glb_dscritic = "".

   INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
   
   /*   Header do Arquivo   */
   IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
   ASSIGN aux_fstlinha = aux_setlinha.

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
                              " - COO509 - " + glb_cdprogra + "' --> '" +
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
                                      '"COO509 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).
                                
            DELETE PROCEDURE b1wgen0011.
                              
            RETURN.
        END.
   
    IF   INTEGER(SUBSTR(aux_fstlinha,76,03)) <> 1 AND   /*  Processado   */
         INTEGER(SUBSTR(aux_fstlinha,76,03)) <> 8 AND   /*  Recusa Total   */
         INTEGER(SUBSTR(aux_fstlinha,76,03)) <> 4 AND   /*  Recusa Parcial */
         INTEGER(SUBSTR(aux_fstlinha,76,03)) <> 5 THEN  /*  Tipo registro inexistente */
         DO:
             ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_fstlinha,76,03)).

             /*   Recusa Total do Arquivo  */
             IF   aux_cdocorre = 2   OR
                  aux_cdocorre = 3   OR
                  aux_cdocorre = 6   THEN
                  RUN p_recusa_total.

             INPUT STREAM str_1 CLOSE.

             /* Status 7 - EM PROCESSAMENTO */
             IF   aux_cdocorre = 7   THEN
                  DO:
                      /* Apaga o arquivo QUOTER */
                      UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                        ".q 2> /dev/null").

                      /* Apaga o arquivo original */
                      UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                        " 2> /dev/null").

                      glb_cdcritic = 182.

                      /* Vai para o proximo arquivo */
                      RETURN.
                  END.


             aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).

             UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").

             UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).

             IF   glb_cdcritic <> 0 THEN
                  DO:
                      RUN fontes/critic.p.

                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - COO509 - " + glb_cdprogra +
                                        "' --> '" +
                                        glb_dscritic + " - " + 
                                        "RECUSA TOTAL - " +
                                        crawarq.nmarquiv + 
                                        " >> " + aux_nmarqlog).
                  END.
             ELSE
                  DO:
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - COO509 - " + glb_cdprogra + 
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
                                       '"COO509 - "' + 
                                       crapcop.nmrescop,
                                 INPUT SUBSTRING(aux_nmarquiv,8),
                                 INPUT FALSE).

             DELETE PROCEDURE b1wgen0011.

             RETURN.

         END.         /*   Fim  da  Recusa  Total  */



   DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0.

      /*  Verifica se eh detalhe do arquivo  */
      IF   INTEGER(SUBSTR(aux_setlinha,1,1)) <> 9 THEN
           DO:
              ASSIGN aux_cdocorre = INT(SUBSTR(aux_setlinha,76,3))
                     aux_dscritic = SUBSTRING(aux_setlinha,79,42).
              
              /* Nro Conta Integracao */
              ASSIGN aux_nrctaitg = TRIM(SUBSTR(aux_setlinha,13,8)) 
                     aux_nrdconta = 0.
                     
              FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                 crapass.nrdctitg = aux_nrctaitg
                                 NO-LOCK NO-ERROR.

              IF  AVAIL crapass THEN 
                  ASSIGN aux_nrdconta = crapass.nrdconta
                         aux_nrctaitg = crapass.nrdctitg.
              ELSE
                  DO:
                      DO WHILE TRUE:

                          FIND crapeca WHERE crapeca.cdcooper = glb_cdcooper AND
                                             crapeca.tparquiv = 509          AND
                                             crapeca.nrdconta = 0            AND
                                             crapeca.nrseqarq = aux_nrseqarq AND
                                             crapeca.nrdcampo = aux_cdocorre 
                                             NO-LOCK NO-ERROR NO-WAIT.
                          
                          IF  NOT AVAIL crapeca THEN
                              DO:
                                  CREATE crapeca.      /* conta que esta no arq */
                                  ASSIGN crapeca.nrdconta = 0                              
                                         crapeca.dtretarq = glb_dtmvtolt
                                         crapeca.nrdcampo = aux_cdocorre
                                         crapeca.nrseqarq = aux_nrseqarq    
                                         crapeca.tparquiv = 509
                                         crapeca.dscritic = TRIM(aux_dscritic) + 
                                                            " CI N/CAD. " +
                                                            TRIM(SUBSTR(aux_setlinha,13,8))
                                         crapeca.cdcooper = glb_cdcooper.
                                  VALIDATE crapeca.

                                  LEAVE.
                              END.
                          ELSE 
                              DO:
                                  ASSIGN aux_nrseqarq = aux_nrseqarq + 1.
                                  NEXT.
                              END.
                          
                      END.
                  END.

              IF aux_dscritic MATCHES "*REATIVACAO PARA CONTA ATIVA*" THEN
                 ASSIGN aux_cdocorre = 0.

              IF  aux_cdocorre > 0 THEN
                  DO:
                      /*Encerramento da conta integracao volta como erro (BB)*/
                      IF   aux_dscritic MATCHES "*CTA ENCERRADA PEDIDO COOP*"
                           THEN
                           DO:
                               /* Atualiza as flags da crapalt */
    
                               FOR EACH crapalt WHERE
                                        crapalt.cdcooper = glb_cdcooper  AND
                                        crapalt.nrdconta = aux_nrdconta  AND
                                        crapalt.flgctitg = 1
                                        EXCLUSIVE-LOCK:
    
                                   ASSIGN crapalt.flgctitg = 2. /* processado */
                               END.
    
                               /* Elimina os erros */
                               FOR EACH crapeca WHERE
                                        crapeca.cdcooper = glb_cdcooper AND
                                        crapeca.nrdconta = aux_nrdconta
                                        EXCLUSIVE-LOCK:
                                   DELETE crapeca.
                               END.
    
                               NEXT.
                           END.
                      ELSE
                           DO:
                               /* apaga os erros do associado */
                               FOR EACH crapeca WHERE 
                                        crapeca.cdcooper = glb_cdcooper   AND
                                        crapeca.nrdconta = aux_nrdconta   AND
                                        crapeca.tparquiv = 509         
                                        EXCLUSIVE-LOCK:
    
                                   DELETE crapeca.
                               END.
    
                               CREATE crapeca.
                               ASSIGN crapeca.nrdconta = aux_nrdconta
                                      crapeca.dtretarq = glb_dtmvtolt
                                      crapeca.nrdcampo = aux_cdocorre
                                      crapeca.nrseqarq = aux_nrseqarq    
                                      aux_nrseqarq     = aux_nrseqarq + 1
                                      crapeca.tparquiv = 509
                                      crapeca.idseqttl = 0
                                      crapeca.dscritic = aux_dscritic
                                      crapeca.cdcooper = glb_cdcooper.
                               VALIDATE crapeca.
                           END.
                           
                      FOR EACH crapalt WHERE 
                               crapalt.cdcooper = glb_cdcooper  AND
                               crapalt.nrdconta = aux_nrdconta  AND
                               crapalt.flgctitg = 1
                               EXCLUSIVE-LOCK:
    
                          ASSIGN crapalt.flgctitg = 4. /* reprocessar */      
                      END.

                  END.
              ELSE
                  DO:
                      FOR EACH crapalt WHERE
                               crapalt.cdcooper = glb_cdcooper  AND
                               crapalt.nrdconta = aux_nrdconta  AND
                               crapalt.flgctitg = 1
                               EXCLUSIVE-LOCK:
    
                          ASSIGN crapalt.flgctitg = 2. /* processado */
                      END.
    
                      /* apaga os erros do associado */
                      FOR EACH crapeca WHERE 
                               crapeca.cdcooper = glb_cdcooper   AND
                               crapeca.nrdconta = aux_nrdconta   AND
                               crapeca.tparquiv = 509         
                               EXCLUSIVE-LOCK:
    
                           DELETE crapeca.
                      END.
    
                      IF   SUBSTRING(aux_setlinha,21,1) = "2"   THEN
                           DO:                                  
                               FIND CURRENT crapass EXCLUSIVE-LOCK NO-ERROR.
    
                               crapass.flgctitg = 2.  /* cadastrada */ 
    
                               RELEASE crapass.
                           END.
                  END.

           END. 
           
   END. /* fim DO WHILE TRUE */
     

   IF   INTEGER(SUBSTR(aux_fstlinha,76,03)) = 8 THEN
        glb_cdcritic = 953.

   IF   glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_1 CLOSE.

            RUN fontes/critic.p.
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).

            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - COO509 - " + glb_cdprogra + "' --> '" +
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
                                      '"COO509 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).
                                
            DELETE PROCEDURE b1wgen0011.
                              
            RETURN.
        END.

   IF   INTEGER(SUBSTR(aux_fstlinha,76,03)) <> 1 AND   /*  Processado   */
        INTEGER(SUBSTR(aux_fstlinha,76,03)) <> 8 AND   /*  Recusa Total   */
        INTEGER(SUBSTR(aux_fstlinha,76,03)) <> 4 THEN  /*  Recusa Parcial */
        DO:
            ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_fstlinha,76,03)).
            
            /*   Recusa Total do Arquivo  */
            IF   aux_cdocorre = 2   OR
                 aux_cdocorre = 3   OR
                 aux_cdocorre = 5   OR
                 aux_cdocorre = 6   THEN
                 RUN p_recusa_total.


            INPUT STREAM str_1 CLOSE.
            
            /* Status 7 - EM PROCESSAMENTO */
            IF   aux_cdocorre = 7   THEN
                 DO:
                     /* Apaga o arquivo QUOTER */
                     UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                       ".q 2> /dev/null").
                                      
                     /* Apaga o arquivo original */
                     UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                       " 2> /dev/null").
                                      
                     glb_cdcritic = 182.
                     
                     /* Vai para o proximo arquivo */
                     RETURN.
                 END.
            
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).
            
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").

            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).

            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.
                 
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO509 - " + glb_cdprogra +
                                       "' --> '" +
                                       glb_dscritic + " - " + 
                                       "RECUSA TOTAL - " +
                                       crawarq.nmarquiv + 
                                       " >> " + aux_nmarqlog).
                 END.
            ELSE
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO509 - " + glb_cdprogra + 
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
                                      '"COO509 - "' + 
                                      crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.

            RETURN.

        END.         /*   Fim  da  Recusa  Total  */


   INPUT STREAM str_1 CLOSE.
   
   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
                         
   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
                           
   IF   glb_cdcritic = 0     AND     /* se esta OK */
        aux_flaglast = YES   THEN    /* e eh o ultimo da sequencia */
        DO  TRANSACTION:
        
            ASSIGN aux_ver_sequencia = INTE(SUBSTR(craptab.dstextab,1,5)).
           
            IF   aux_ver_sequencia <= crawarq.nrsequen  THEN
                 DO:
                     FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.

                     ASSIGN SUBSTRING(craptab.dstextab,1,5) = 
                                      STRING(crawarq.nrsequen + 1,"99999").
                 END.
        END.
  
END PROCEDURE. /* FIM proc_processa_arquivo */

PROCEDURE p_recusa_total:

    DO  TRANSACTION: 
    
        FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.
       
        FIND CURRENT crabtab EXCLUSIVE-LOCK NO-ERROR.
       
        /* Bloquear tabela de envio */
        ASSIGN SUBSTRING(crabtab.dstextab,1,7) =
                         SUBSTRING(aux_setlinha,39,05) + " 1".

        /* Deixar sequencia que estou processando arq.recebimento */
        ASSIGN SUBSTRING(craptab.dstextab,1,5) =
                         STRING(crawarq.nrsequen,"99999"). 
    END. /* Fim TRANSACTION */
               
    FOR EACH crapalt WHERE  
             crapalt.cdcooper = glb_cdcooper                  AND
             crapalt.flgctitg = 1  /* Enviada */ NO-LOCK:

        IF   NOT crapalt.dsaltera MATCHES "*exclusao conta-itg*"   THEN
             NEXT.

        /* Reprocessar todas alteracoes desta conta */ 
        FOR EACH crabalt WHERE crabalt.cdcooper = glb_cdcooper     AND
                               crabalt.nrdconta = crapalt.nrdconta AND
                               crapalt.flgctitg = 1
                               EXCLUSIVE-LOCK TRANSACTION:
                                      
            ASSIGN crabalt.flgctitg = 4. /* Reprocessar */

        END.
    END.               
END.   /*   Fim da Procedure  */
/* .........................................................................*/
