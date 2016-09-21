/* .............................................................................

   Programa: fontes/crps420.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2004                   Ultima atualizacao: 24/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 082. 
               Tratar arquivo retorno (COO506) de COMANDOS DE CHEQUES (COO406),
               recebido pelo Banco do Brasil.

    Alteracoes: 06/04/2005 - Gravar os erros no log da tela PRCITG (Evandro).
   
               01/07/2005 - Alimentado campo cdcooper da tabela crapeca (Diego).
              
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               26/09/2005 - Alterada mensagem log referente critica 182 (Diego).

               05/12/2005 - Correcao de transacao para que cada registro do
                            arquivo seja uma transacao (Evandro).
                            
               10/01/2006 - Correcao das mensagens para o LOG e envio de e-mail
                            quando houver RECUSA TOTAL (Evandro).
                            
               17/02/2006 - Acerto na mensagem arquivo processado (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               06/03/2006 - Atualizar registros com flag = 4 tambem (Evandro).
               
               09/03/2006 - Nao considerar a flag quando for atualizar para
                            registro OK (Evandro).

               17/03/2006 - Atualizar o ultimo movimento do cheque (Evandro).
               
               04/04/2006 - Modificada a busca do ultimo movimento do cheque
                            (Evandro).

               10/04/2006 - Excluido envio de e-mail para
                            marcospaulo@cecred.coop.br (Diego).
                            
               26/10/2006 - Desprezar a critica de conta encerrada e pegar as
                            descricoes direto do arquivo (Evandro).
                            
               01/03/2007 - Inclusao do campo cdbanchq nas leituras da
                            tabela crapcch (Diego)
               
               09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                            (Guilherme)             

               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               09/01/2009 - Mover arquivo err* para diretorio /salvar e enviar
                            email para suporte.operacional@cecred.coop.br
                            (Diego).
                            
               09/04/2009 - Corrigir SUBSTR para obter nrdconta (David).
               
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
                           
               24/01/2014 - Incluir VALIDATE crapeca (Lucas R.)
............................................................................. */

{ includes/var_batch.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR aux_nrdconta AS INT      FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF        VAR aux_nrchqini AS INT      FORMAT "zzz,zzz,9"           NO-UNDO.
DEF        VAR aux_nrchqfim AS INT      FORMAT "zzz,zzz,9"           NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrsequen AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR                                  NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.

DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF        VAR aux_flaglast AS LOGICAL                               NO-UNDO.

DEFINE TEMP-TABLE crawarq                                            NO-UNDO
          FIELD nmarquiv AS CHAR
          FIELD nrsequen AS INTEGER
          FIELD qtassoci AS INTEGER
          INDEX crawarq1 AS PRIMARY
                nmarquiv nrsequen.

   /* variaveis para as criticas */
DEF     VAR aux_dsprogra AS CHAR     FORMAT "x(6)"                  NO-UNDO.
DEF     VAR aux_tpregist AS INT                                     NO-UNDO.
DEF     VAR aux_cdocorre AS INT                                     NO-UNDO.
DEF     VAR aux_dscritic AS CHAR     FORMAT "x(50)"                 NO-UNDO.

/* nome do arquivo de log */
DEF     VAR aux_nmarqlog AS CHAR                                    NO-UNDO.

DEF BUFFER crabtab FOR craptab.

ASSIGN glb_cdprogra = "crps420"
       aux_dsprogra = "COO406"     /* campos do layout coo406 */
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
                      "/compel/recepcao/COO506*.ret"
       aux_flgfirst = TRUE
       aux_contador = 0.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo506" + STRING(DAY(glb_dtmvtolt),"99") +
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
                           " - COO506 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 506           NO-ERROR NO-WAIT. 

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

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                   crabtab.nmsistem = "CRED"        AND
                   crabtab.tptabela = "GENERI"      AND
                   crabtab.cdempres = 00            AND
                   crabtab.cdacesso = "NRARQMVITG"  AND
                   crabtab.tpregist = 406           NO-ERROR NO-WAIT.

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
                                       " - COO506 - " + glb_cdprogra + 
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
                                       
                     /* E-mail para CENTRAL avisando sobre a ERRO DE SEQ. */

                     /* Move para diretorio converte para utilizar na BO */
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
                                      '"COO506 - "' +
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
                           " - COO506 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN fontes/fimprg.p.                   


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
                              " - COO506 - " + glb_cdprogra + "' --> '" +
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
                                      '"COO506 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.
            
            RETURN.
        END.

   IF   INTEGER(SUBSTR(aux_setlinha,76,03)) <> 1 AND   /*  Recusa Total   */
        INTEGER(SUBSTR(aux_setlinha,76,03)) <> 4 THEN  /*  Recusa Parcial */
        DO:
            ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_setlinha,76,03)).
            
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
                                       " - COO506 - " + glb_cdprogra + 
                                       "' --> '" +
                                       glb_dscritic + " - " + 
                                       "RECUSA TOTAL - " +
                                       crawarq.nmarquiv +
                                       " >> " + aux_nmarqlog).
                 END.
            ELSE
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - COO506 - " + glb_cdprogra + 
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
                                      '"COO506 - "' + 
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
                                          " - COO506 - " + glb_cdprogra + 
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
              ASSIGN aux_tpregist = 1  /* DETALHE UNICO */
                     aux_cdocorre = INTEGER(SUBSTRING(aux_setlinha,76,3))
                     aux_nrdconta = INTEGER(SUBSTRING(aux_setlinha,37,8))
                     aux_nrchqini = INTEGER(SUBSTRING(aux_setlinha,21,6))
                     aux_nrchqfim = INTEGER(SUBSTRING(aux_setlinha,27,6)).

               /* COM ERRO */
               IF   aux_cdocorre <> 0                           AND

                    /* Despreza esta critica */
                    SUBSTR(aux_setlinha,76,35) <> 
                           "002CTA ENCERRADA PEDIDO COOPERAT"   THEN
                    DO:
                       DO WHILE TRUE:
                       
                           /* atualiza esse(s) cheque(s) para reprocessar */
                           FIND crapcch WHERE crapcch.cdcooper = glb_cdcooper
                                          AND crapcch.nrdconta = aux_nrdconta
                                          /* cheque inicial - sem digito */
                                          AND INTEGER(SUBSTRING(STRING(
                                              crapcch.nrchqini,"9999999"),1,6))
                                              = aux_nrchqini
                                          /* cheque final - sem digito */
                                          AND INTEGER(SUBSTRING(STRING(
                                              crapcch.nrchqfim,"9999999"),1,6))
                                              = aux_nrchqfim
                                          AND crapcch.flgctitg = 1
                                          AND crapcch.cdbanchq = 1
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                          

                           IF   NOT AVAILABLE crapcch   THEN
                                IF   LOCKED crapcch   THEN
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                     END.
                                ELSE   /* nao existe na crapcch mas pode ter
                                          sido enviado pela craplcm */
                                     LEAVE.

                           ASSIGN crapcch.flgctitg = 4. /* reprocessar */
                       
                           LEAVE.

                       END.  /* fim DO WHILE */
                       
                       IF   glb_cdcritic <> 0   THEN
                            NEXT.
                            
                       aux_dscritic = SUBSTR(aux_setlinha,79,32).
                            
                       /* calcular os digitos dos cheques inicial e final */
                       glb_nrcalcul = aux_nrchqini * 10.
                       RUN fontes/digfun.p.

                       IF   aux_nrchqini = aux_nrchqfim   THEN
                            ASSIGN aux_nrchqini = glb_nrcalcul
                                   aux_nrchqfim = glb_nrcalcul.
                       ELSE
                            DO:
                                ASSIGN aux_nrchqini = glb_nrcalcul.

                                glb_nrcalcul = aux_nrchqfim * 10.
                                RUN fontes/digfun.p.
                                
                                ASSIGN aux_nrchqfim = glb_nrcalcul.
                            END.

                       FOR EACH crapeca WHERE
                                crapeca.cdcooper = glb_cdcooper  AND
                                crapeca.nrdconta = aux_nrdconta  AND
                                crapeca.tparquiv = 506
                                EXCLUSIVE-LOCK:
                           DELETE crapeca.                   
                       END.                         
                       
                       CREATE crapeca.
                       ASSIGN crapeca.nrdconta = aux_nrdconta
                              crapeca.dtretarq = glb_dtmvtolt
                              crapeca.nrdcampo = aux_cdocorre
                              crapeca.nrseqarq = crawarq.nrsequen
                              crapeca.tparquiv = 506
                              crapeca.dscritic = 
                                               STRING(aux_nrchqini,"zzz,zzz,9")
                                               + " - " +
                                               STRING(aux_nrchqfim,"zzz,zzz,9")
                                               + " --> "  + aux_dscritic
                              crapeca.cdcooper = glb_cdcooper.
                       VALIDATE crapeca.
                       
                    END.
               ELSE     /* se registro detalhe foi processado com sucesso */
                    DO:
                        /* atualiza esse(s) cheque(s) para cadastrado(s) */
                        FOR EACH crapcch WHERE 
                                 crapcch.cdcooper = glb_cdcooper 
                             AND crapcch.nrdconta = aux_nrdconta
                                 /* cheque inicial - sem digito */
                             AND INTEGER(SUBSTRING(STRING(
                                 crapcch.nrchqini,"9999999"),1,6))
                                 = aux_nrchqini
                                 /* cheque final - sem digito */
                             AND INTEGER(SUBSTRING(STRING(
                                 crapcch.nrchqfim,"9999999"),1,6))
                                 = aux_nrchqfim
                             AND crapcch.cdbanchq = 1
                                 EXCLUSIVE-LOCK USE-INDEX crapcch3 
                                 BREAK BY crapcch.nrdconta
                                         BY crapcch.dtmvtolt:
                                       
                            IF   LAST-OF(crapcch.nrdconta)   THEN
                                 DO:
                                     /* cadastrado */
                                     ASSIGN crapcch.flgctitg = 2. 
                                                                 
                                     FOR EACH crapeca WHERE
                                              crapeca.cdcooper =
                                                    glb_cdcooper       AND
                                              crapeca.nrdconta = 
                                                    crapcch.nrdconta   AND
                                              crapeca.tparquiv = 506
                                              EXCLUSIVE-LOCK:
                                         DELETE crapeca.
                                     END.
                                 END.
                        END.
                    END.  /* fim ELSE*/
           END. /* fim detalhes */
           
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
               
    FOR EACH crapcch WHERE crapcch.cdcooper = glb_cdcooper  AND
                           crapcch.flgctitg = 1             AND
                           crapcch.cdbanchq = 1  EXCLUSIVE-LOCK:

        ASSIGN crapcch.flgctitg = 0.
    END.
    
END.   /*   Fim da Procedure  */

/* ......................................................................... */
