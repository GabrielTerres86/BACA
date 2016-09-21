/* ..........................................................................

   Programa: fontes/crps411.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004                   Ultima atualizacao: 22/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 082.
               Tratar arquivo retorno (COO505) de ALTERACOES CADASTRAIS (COO405)
               dos associados, recebido pelo Banco do Brasil.

   Alteracoes: 01/07/2005 - Alimentado campo cdcooper da tabela crapeca (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego)
               
               13/10/2005 - Alterados mensagem de criticas(Mirtes)

               17/10/2005 - Permanecer apenas criticas diferentes para
                            uma mesma conta(Mirtes)

               19/10/2005 - Gravar seq.888 - crapeca(Mirtes)
               
               27/10/2005 - Excluir o arquivo com status 7 - EM PROCESSAMENTO
                            (Evandro).

               27/10/2005 - Eliminar mensagens "*comando inc/alt*" e
                            mensagem "titular ja cadastrado" (Mirtes)
                            
               03/11/2005 - Eliminar mensagem "*comando inc*"(Mirtes)
               
               18/11/2005 - Removido controle de bloqueio porque deve ser feito
                            somente nos envios dos arquivos.
                          - Acerto para criar criticas para o COO552 (Evandro).
                          
               10/01/2006 - Correcao das mensagens para o LOG e envio de e-mail
                            quando houver RECUSA TOTAL;
                          - Tratamento para a critica de encerramento da conta
                            integracao (Evandro).
                            
               17/02/2006 - Acerto na mensagem arquivo processado (Evandro).
               
               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               10/04/2006 - Excluido envio de e-mail para
                            marcospaulo@cecred.coop.br (Diego).

               28/08/2006 - Alterado para mover arquivo p/ diretorio integra
                            quando critica 504 (Diego).
                            
              20/09/2006 - Comentada critica 504(Retornando total de registros
                           errado - arquivo processado - pelo BB) (Mirtes).
             
              09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme)
                           
              14/03/2008 - Nao tratar Encerramento de Conta Integracao,
                           substituido por COO509 - crps504 (Diego).
              
              18/03/2008 - Alterado envio de email para BO b1wgen0011
                           (Sidnei - Precise)
                           
              20/08/2008 - Incluida remocao de arquivo do diretorio "integra"
                           (Diego).
                           
              09/01/2009 - Mover arquivo err* para diretorio /salvar e enviar
                           email para suporte.operacional@cecred.coop.b
                         - Limpar erros crapeca com nrdconta = 0 (Diego).
                      
              18/06/2010 - Alteracao tamanho SET STREAM e extensao .ret (Vitor).
                          
              20/09/2010 - Inclusao do e-mail cartoes@cecred.coop.br (Adriano).
              
              08/11/2010 - Copia do arquivo COO505 p/ o diretorio  
                           /micros/cooperativa/compel/recepcao/retornos (Vitor).
                           
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
                           
              22/01/2014 - Incluir VALIDATE crapeca (Lucas R).   
.............................................................................*/

{ includes/var_batch.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR aux_nrdconta AS INT      FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
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
DEF        VAR aux_nrdconta_ant LIKE crapeca.nrdconta                NO-UNDO.
DEF        VAR aux_idseqttl_ant LIKE crapeca.idseqttl                NO-UNDO.
DEF        VAR aux_dscritic_ant LIKE crapeca.dscritic                NO-UNDO.

DEF BUFFER crabtab FOR craptab.

ASSIGN glb_cdprogra = "crps411"
       aux_dsprogra = "COO405"
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
                      "/compel/recepcao/COO505*.ret"
       aux_flgfirst = TRUE
       aux_contador = 0
       aux_nrseqarq = 1000. /* nro. ficticio */
 
INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .
            
   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo505" + STRING(DAY(glb_dtmvtolt),"99") +
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
                           " - COO505 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 505           NO-ERROR NO-WAIT. 

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

/* sequencia de rotorno esperada */
ASSIGN aux_nrsequen = INTEGER(SUBSTR(craptab.dstextab,01,05)).

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper   AND
                   crabtab.nmsistem = "CRED"         AND
                   crabtab.tptabela = "GENERI"       AND
                   crabtab.cdempres = 00             AND
                   crabtab.cdacesso = "NRARQMVITG"   AND
                   crabtab.tpregist = 405            NO-ERROR NO-WAIT.

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
            IF   crawarq.nrsequen <= aux_nrsequen   THEN      
                 DO:
                    IF  crawarq.nrsequen = aux_nrsequen THEN
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
                                       " - COO505 - " + glb_cdprogra + 
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
                                       
                     /* E-mail para CENTRAL avisando sobre a ERRO DE SEQ. */
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
                                      '"COO505 - "' +
                                      crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

                     DELETE PROCEDURE b1wgen0011.
                     
                     DELETE crawarq.
                     NEXT.
                 END.
         END.
END.
                                            
    
FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper AND
                       crapeca.tparquiv = 505          AND
                       crapeca.nrdconta = 0 
                       EXCLUSIVE-LOCK TRANSACTION:
    DELETE crapeca.
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
                           " - COO505 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN fontes/fimprg.p.                   



/* .......................................................................... */
PROCEDURE proc_processa_arquivo.

   DEFINE VAR aux_qtregist AS INT  NO-UNDO.
   
   ASSIGN glb_cdcritic = 0.

   INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
   
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
                              " - COO505 - " + glb_cdprogra + "' --> '" +
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
                                      '"COO505 - "' + crapcop.nmrescop,
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
                                       " - COO505 - " + glb_cdprogra +
                                       "' --> '" +
                                       glb_dscritic + " - " + 
                                       "RECUSA TOTAL - " +
                                       crawarq.nmarquiv + 
                                       " >> " + aux_nmarqlog).
                 END.
            ELSE
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO505 - " + glb_cdprogra + 
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
                                       '"COO505 - "' + 
                                       crapcop.nmrescop,
                                 INPUT SUBSTRING(aux_nmarquiv,8),
                                 INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.

            RETURN.
        END.         /*   Fim  da  Recusa  Total  */
   
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0
             aux_qtregist = aux_qtregist + 1.

      /*  Verifica se eh final do Arquivo  */
      IF   INTEGER(SUBSTR(aux_setlinha,1,1)) = 9 THEN
           DO:
               /*   Conferir o total do arquivo   */
               .

               /*------------------------------
               IF   (aux_qtregist + 1) <> 
                    DECIMAL(SUBSTR(aux_setlinha,06,09)) THEN             
                    DO:
                        aux_nmarquiv = "integra/err" + 
                                       SUBSTR(crawarq.nmarquiv,12,29).

                        UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                          ".q 2> /dev/null").
                        
                        UNIX SILENT  VALUE("mv " + crawarq.nmarquiv + " " +
                                           aux_nmarquiv).
                        
                        ASSIGN glb_cdcritic = 504.
                         
                        RUN fontes/critic.p.

                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - COO505 - " + glb_cdprogra + 
                                          "' --> '" +
                                          glb_dscritic + 
                                          " - ARQUIVO PROCESSADO - " + 
                                          aux_nmarquiv +
                                          " >> " + aux_nmarqlog).
                        LEAVE.
                    END.
               ------------------------------------------*/
           END.
      ELSE
           /* tratamento dos registros detalhe */
           DO:
              
              ASSIGN aux_tpregist = INT(SUBSTR(aux_setlinha,11,2))
                     aux_cdocorre = INT(SUBSTR(aux_setlinha,156,3))
                     aux_dscritic = SUBSTR(aux_setlinha,159,42).
              
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
                      CREATE crapeca.      /* conta que esta no arq */
                      ASSIGN crapeca.nrdconta = 0                              
                             crapeca.dtretarq = glb_dtmvtolt
                             crapeca.nrdcampo = aux_cdocorre
                             crapeca.nrseqarq = aux_nrseqarq    
                             aux_nrseqarq     = aux_nrseqarq + 1
                             crapeca.tparquiv = 505
                             crapeca.dscritic = TRIM(aux_dscritic) + 
                                                " CI N/CAD. " +
                                                TRIM(SUBSTR(aux_setlinha,13,8))
                             crapeca.cdcooper = glb_cdcooper.
                       VALIDATE crapeca. 
                       NEXT.
                  END.
                         
              IF  aux_cdocorre <> 0   THEN     /* COM ERRO */
                  DO:
                      /* Erro de inclusao de titular */
                      IF   aux_tpregist = 1                    AND
                           INT(SUBSTR(aux_setlinha,21,1)) = 3  THEN 
                           DO:
                              FIND crapeca NO-LOCK WHERE
                                   crapeca.cdcooper = glb_cdcooper AND
                                   crapeca.nrdconta = aux_nrdconta AND
                                   crapeca.nrdcampo = aux_cdocorre AND
                                   crapeca.tparquiv = 552          NO-ERROR.
                                   
                              IF NOT AVAIL crapeca THEN
                                 DO:
                                    CREATE crapeca.
                                    ASSIGN crapeca.nrdconta = aux_nrdconta
                                           crapeca.dtretarq = glb_dtmvtolt
                                           crapeca.nrdcampo = aux_cdocorre
                                           crapeca.nrseqarq = aux_nrseqarq    
                                           aux_nrseqarq     = aux_nrseqarq + 1
                                           crapeca.tparquiv = 552
                                           crapeca.idseqttl = 2
                                           crapeca.dscritic = "EFETUANDO " +
                                                              "INCLUSAO " +
                                                              "SEG. TITULAR"
                                           crapeca.cdcooper = glb_cdcooper.
                                    VALIDATE crapeca.
                                 END.
                           END.
                      ELSE
                      /* Erro de exclusao de titular */
                      IF   aux_tpregist = 1                    AND
                           INT(SUBSTR(aux_setlinha,21,1)) = 5  THEN 
                           DO:
                              FIND crapeca WHERE
                                   crapeca.cdcooper = glb_cdcooper  AND
                                   crapeca.nrdconta = aux_nrdconta  AND
                                   crapeca.nrdcampo = aux_cdocorre  AND
                                   crapeca.tparquiv = 552          
                                   NO-LOCK NO-ERROR.
                                   
                              IF NOT AVAIL crapeca THEN
                                 DO:
                                    CREATE crapeca.
                                    ASSIGN crapeca.nrdconta = aux_nrdconta
                                           crapeca.dtretarq = glb_dtmvtolt
                                           crapeca.nrdcampo = aux_cdocorre
                                           crapeca.nrseqarq = aux_nrseqarq    
                                           aux_nrseqarq     = aux_nrseqarq + 1
                                           crapeca.tparquiv = 552
                                           crapeca.idseqttl = 2
                                           crapeca.dscritic = "EFETUANDO " +
                                                              "EXCLUSAO " +
                                                              "SEG. TITULAR"
                                           crapeca.cdcooper = glb_cdcooper.
                                    VALIDATE crapeca.
                                 END.
                           END.
                      ELSE
                           DO:
                              /* apaga os erros do associado */
                              FOR EACH crapeca WHERE 
                                       crapeca.cdcooper = glb_cdcooper   AND
                                       crapeca.nrdconta = aux_nrdconta   AND
                                       crapeca.tparquiv = 505          
                                       EXCLUSIVE-LOCK:
                                      
                                  DELETE crapeca.
                              END.
                              
                              CREATE crapeca.
                              ASSIGN crapeca.nrdconta = aux_nrdconta
                                     crapeca.dtretarq = glb_dtmvtolt
                                     crapeca.nrdcampo = aux_cdocorre
                                     crapeca.nrseqarq = aux_nrseqarq    
                                     aux_nrseqarq     = aux_nrseqarq + 1
                                     crapeca.tparquiv = 505
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
              ELSE     /* se registro detalhe foi processado com sucesso */
                  DO:
                      FOR EACH crapalt WHERE 
                               crapalt.cdcooper = glb_cdcooper  AND
                               crapalt.nrdconta = aux_nrdconta  AND
                               crapalt.flgctitg = 1
                               EXCLUSIVE-LOCK:

                          ASSIGN crapalt.flgctitg = 2. /* processado */       
                      END.                    
                  END.  
           END. 
           
   END. /* fim DO WHILE TRUE */
     
   INPUT STREAM str_1 CLOSE.
   
   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
   
   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
   
   IF   glb_cdcritic = 0     AND     /* se esta OK */
        aux_flaglast = YES   THEN    /* e eh o ultimo da sequencia */
        DO TRANSACTION:
        
            ASSIGN aux_ver_sequencia = INTE(SUBSTR(craptab.dstextab,1,5)).
           
            IF   aux_ver_sequencia <= crawarq.nrsequen  THEN
                 ASSIGN SUBSTRING(craptab.dstextab,1,5) = 
                             STRING(crawarq.nrsequen + 1,"99999").
        
        END.
  
   FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper  AND
                          crapeca.tparquiv = 505:
   
       IF crapeca.dscritic MATCHES "*titular ja cadastrado*" OR
          crapeca.dscritic MATCHES "*comando inc*" THEN
          DO:
             DELETE crapeca.
          END.
   END.
          
   /* Deixar apenas criticas diferencias no arq. de erro */
   FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper                   AND
                          crapeca.tparquiv = 505 BREAK BY crapeca.nrdconta
                                                          BY crapeca.idseqttl
                                                            BY crapeca.dscritic:

       IF   aux_nrdconta_ant = crapeca.nrdconta   AND
            aux_idseqttl_ant = crapeca.idseqttl   AND
            aux_dscritic_ant = crapeca.dscritic   THEN
            DELETE crapeca.
       ELSE
            DO:
               ASSIGN aux_nrdconta_ant = crapeca.nrdconta
                      aux_idseqttl_ant = crapeca.idseqttl
                      aux_dscritic_ant = crapeca.dscritic.
            END.        
   END.

END PROCEDURE. /* FIM proc_processa_arquivo */

PROCEDURE p_recusa_total:

    /* Bloquear tabela de envio */
    ASSIGN SUBSTRING(crabtab.dstextab,1,7) = SUBSTR(aux_setlinha,39,05) + " 1".
    
    /* Deixar sequencia que estou processando arq.recebimento */
    ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(crawarq.nrsequen,"99999"). 
               
    FOR EACH crapalt WHERE 
             crapalt.cdcooper = glb_cdcooper  AND
             crapalt.nrdconta = aux_nrdconta  AND
             crapalt.flgctitg = 1 
             EXCLUSIVE-LOCK:  
        ASSIGN crapalt.flgctitg = 4. /* Reprocessar */
    END.
    
END.   /*   Fim da Procedure  */


/* .........................................................................*/

