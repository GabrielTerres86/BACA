/* ..........................................................................

   Programa: fontes/crps423.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2004                    Ultima atualizacao: 26/05/2018
   
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 100.
               Tratar arquivo retorno (COO510) de MOVIMENTACAO PARA CARTAO DE
               CREDITO (COO410), recebido pelo Banco do Brasil.

   Alteracoes: 04/07/2005 - Alimentado campo cdcooper da tabela crapeca (Diego).
   
               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Ajustes ao layout (Evandro).
               
               10/04/2006 - Excluido envio de e-mail para
                            marcospaulo@cecred.coop.br (Diego).
                            
               28/04/2006 - Realizados ajustes gerais (Diego).
                            
               24/05/2006 - Utilizar criticas vindas do BB(Retirada
                            includes/criticas_coo.i)(Mirtes)

               26/06/2006 - Inclusao da tabela crapcrd(Mirtes)
               
               08/08/2006 - Corrigida a leitura do sequencial do arquivo
                            conforme arquivo de layout (Evandro).

               02/10/2006 - Modificado para nao criticar os codigos de retorno
                            153(Alteracao limite credito) e 000(Cancelamento)
                            (Diego).
                            
               01/11/2006 - Desprezar a critica 081-RMS RECUSADA... (Evandro).
               
               03/01/2007 - Caso o arquivo tenha sequencial = 0, mover para o
                            diretorio salvar;
                            Se tiver nro de conta = 0, nao gerar erro, isso
                            porque eh furo no arquivo do BB (Evandro).
               
               09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme).
                           
               10/09/2007 - Alterado para poder processar um arquivo com mais
                            de um sequencial (Evandro).
                            
               19/09/2007 - Corrigido controle para importacao de arquivo com
                            sequencial zerado (Evandro).
                            
               05/10/2007 - Nao mostrar no log quando o arquivo for desprezado
                            e ignorar contas zeradas (Evandro).
                            
               26/12/2007 - Nao criticar erro de sequencia (Diego).
               
               29/08/2008 - Tratar erro de sequencia no Detalhe (Diego).

               31/10/2008 - Efetuado acerto cadastramento do cartao (Mirtes)
               
               09/01/2009 - Mover arquivo err* para diretorio /salvar e enviar
                            email para suporte.operacional@cecred.coop.br
                            (Diego).
               
               19/05/2009 - Inserida exclusao da crapeca antes de checar se
                            conta veio com erro (Fernando).
                            
               21/06/2010 - Alteracao tamanho SET STREAM e extensao .ret (Vitor).
               
               20/09/2010 - Efetuado correcao na leitura do crapeca e feito
                            a inclusao do e-mail cartoes@cecred.coop.br (Adriano).
                            
               08/11/2010 - Copia do arquivo COO510 p/ o diretorio  
                           /micros/cooperativa/compel/recepcao/retornos (Vitor).
                           
               17/06/2011 - Corrigida leitura do codigo das criticas (Evandro).
               
               31/05/2012 - Alteracao de email suporte para compe - Trf. 46725 
                           (Ze)
                           
               28/08/2012 - Inclusão de e-mail cobranca@cecred.coop.br (Lucas R.)
               
               17/12/2012 - Envio de emails referente ao COO500 a COO599 para
                            convenios@cecred.coop.br ao inves de
                            compe@cecred.coop.br (Tiago).
                            
               24/01/2014 - Incluir VALIDATE crapeca, crapcrd (Lucas R.) 
               
25/09/2015 - #322304 O operador eh gravado no momento que o colaborador 
             solicita o envio/retorno do arquivo do BB na tela PRCITG que 
             depois chama o CRPS423. No procmessage colocar o operador que 
             processou o arquivo, o arquivo e a chave completa da tabela 
             crawcrd para consulta (Carlos)

			  26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

              04/01/2019 - Inclusao de find para evitar ocorrencia de exception. 
                           Deletes que ocorrem anteriormente ao insert na crapeca
                           nao estavam limpando contas com valor igual a zero. 
                           Gabriel (Mouts) - SCTASK0035678.

............................................................................ */

{ includes/var_batch.i }   

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3. /* arquivo anexo para enviar via email */
DEF    VARIABLE aux_nmarqimp AS CHAR                                 NO-UNDO.

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR aux_nmarqdat AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdseqtab AS INT                                   NO-UNDO.
DEF        VAR aux_cdseqant AS INT                                   NO-UNDO.
DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flaglast AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrdcampo AS INT                                   NO-UNDO.

/* nome do arquivo de log */
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.

/* para nome de todos os arquivos a serem integrados */
DEFINE TEMP-TABLE crawarq
          FIELD nmarquiv AS CHAR
          FIELD nrsequen AS INTEGER
          FIELD qtassoci AS INTEGER
          INDEX crawarq1 AS PRIMARY
                nmarquiv nrsequen.
                
/* para poder ordenar (organizar) os erros e as informacoes recebidas */
DEFINE TEMP-TABLE wdados
          FIELD tpregist AS INT
          FIELD nrdconta LIKE crapass.nrdconta
          FIELD nrcpftit LIKE crawcrd.nrcpftit  FORMAT "999,999,999,99"
          FIELD nmtitcrd LIKE crawcrd.nmtitcrd
          FIELD nrcctitg LIKE crawcrd.nrcctitg
          FIELD dscritic AS CHAR
          FIELD dtvenfat AS DATE    FORMAT "99/99/9999"
          FIELD qtddatra AS INT     FORMAT "zz9"
          FIELD vlsdeved AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99"
          FIELD vlpagmin AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99"
          FIELD vlfatura AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99"
          FIELD vldebito AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99"
          
                  /* saldo da conta em moeda estrangeira */
          FIELD vlsctaes AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99" 

                  /* saldo da conta em Real */
          FIELD vlsctare AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99"

                  /* saldo em compras parceladas */
          FIELD vlsparce AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99"

                  /* valor total do debito da conta */
          FIELD vltotdeb AS DECIMAL FORMAT "zzzzzzzzzzzzzz9.99"
          INDEX wdados1  AS PRIMARY
                tpregist nrdconta.

DEFINE BUFFER crabtab FOR craptab.
DEFINE BUFFER crabarq FOR crawarq.
   
   /* variaveis para as criticas */
DEF     VAR aux_dsprogra AS CHAR     FORMAT "x(6)"                  NO-UNDO.
DEF     VAR aux_tpregist AS INT                                     NO-UNDO.
DEF     VAR aux_cdocorre AS INT                                     NO-UNDO.
DEF     VAR aux_dscritic AS CHAR     FORMAT "x(50)"                 NO-UNDO.


ASSIGN glb_cdprogra = "crps423"
       glb_flgbatch = FALSE.
       
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
     
ASSIGN aux_dsprogra = "COO410"
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".


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
                      "/compel/recepcao/COO510*.ret"
       aux_flgfirst = TRUE
       aux_contador = 0.
       
INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.

                                             
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .
                               
   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo510" + STRING(DAY(glb_dtmvtolt),"99") +
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

   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") NO-ECHO.

   aux_cdseqant = ?. /* Para poder considerar arquivos zerados */
   
   /* Varre todo o arquivo para ver se ha mais de 1 sequencial */
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_2 aux_setlinha.
      
      /* Despreza o header e o trailer */
      IF   INT(SUBSTRING(aux_setlinha,1,2)) = 0    OR
           INT(SUBSTRING(aux_setlinha,1,2)) = 99   THEN
           NEXT.
           
      /* Aceita arquivo zerado pois sera desprezado posteriormente */
      IF   aux_cdseqant <> INT(SUBSTRING(aux_setlinha,03,05))   THEN
           DO:
               CREATE crawarq.
               ASSIGN crawarq.nmarquiv = aux_nmarqdat
                      crawarq.nrsequen = INT(SUBSTRING(aux_setlinha,03,05))
                      aux_cdseqant     = crawarq.nrsequen
                      aux_flgfirst     = FALSE.
           END.
   END.
          
   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.
                        
IF   aux_flgfirst THEN
     DO:  
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO510 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 510
                   NO-ERROR NO-WAIT.

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
ASSIGN aux_cdseqtab = INTEGER(SUBSTR(craptab.dstextab,01,05)).

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                   crabtab.nmsistem = "CRED"        AND
                   crabtab.tptabela = "GENERI"      AND
                   crabtab.cdempres = 00            AND
                   crabtab.cdacesso = "NRARQMVITG"  AND
                   crabtab.tpregist = 410           NO-ERROR NO-WAIT.
                   
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

    /* Verifica se veio zerado, entao despreza */
    IF   crawarq.nrsequen = 0   THEN
         DO: 
             /********************************************************
              *** Essa alteracao foi feita porque alguns arquivos  ***
              *** vindos do Banco do Brasil, vem com as informa-   ***
              *** coes zeradas e serao desprezados uma vez que os  ***
              *** processamentos ocorrem normalmente               ***
              *** eh provisorio - Evandro                          ***
              ********************************************************/

             /*** coloca no log que o arquivo zerado foi desprezado ***
             UNIX SILENT VALUE("echo " + 
                               STRING(TIME,"HH:MM:SS") +
                               " - COO510 - " +
                               glb_cdprogra + "' --> '"  +
                               "ARQUIVO ZERADO DESPREZADO - " +
                               SUBSTRING(crawarq.nmarquiv,
                                         R-INDEX(crawarq.nmarquiv,"/") + 1) +
                               " >> " + aux_nmarqlog).
             ***/
                              
             UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
 
             UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
             DELETE crawarq.
             NEXT.
         END.

    IF   LAST-OF(crawarq.nrsequen)   THEN
         DO:
            /* Mantem somente o registro do arquivo com o mesmo nome que tiver
               a maior sequencia, as demais sequencias serao processadas
               automaticamente */
            IF   CAN-FIND(FIRST crabarq WHERE
                                crabarq.nmarquiv = crawarq.nmarquiv   AND
                                crabarq.nrsequen > crawarq.nrsequen   NO-LOCK)
                 THEN
                 DO: 
                     ASSIGN aux_cdseqtab = aux_cdseqtab + 1.
                     DELETE crawarq.
                     NEXT.
                 END.

            IF   crawarq.nrsequen = aux_cdseqtab   THEN
                 ASSIGN aux_cdseqtab = aux_cdseqtab + 1.

            /********* NAO CRITICAR ERRO DE SEQUENCIA **************
            ELSE
                 DO:
                     /* sequencia errada */
                     glb_cdcritic = 476.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO510 - " + glb_cdprogra + 
                                       "' --> '"  +
                                       glb_dscritic + " " +
                                       "SEQ.BB " + STRING(crawarq.nrsequen) + 
                                       " " + "SEQ.COOP " + 
                                       STRING(aux_cdseqtab) + " - " +
                                       crawarq.nmarquiv +
                                       " >> " + aux_nmarqlog).
                     ASSIGN glb_cdcritic = 0
                            aux_nmarquiv = "salvar/err" +
                                           SUBSTR(crawarq.nmarquiv,12,29).

                     /* move o arquivo para o /salvar */
                     UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                                       aux_nmarquiv).

                     /* apaga o arquivo QUOTER */
                     UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q" ).
                     
                     /* criar arquivo anexo para email */
                     ASSIGN aux_nmarqimp = "arq/" + glb_cdprogra + 
                                           "_ANEXO" + STRING(TIME).
                     
                     OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp).
    
                     PUT STREAM str_3 "ERRO DE SEQUENCIA no arquivo "
                                      "COO510 da cooperativa "
                                      crapcop.nmrescop FORMAT "x(12)"
                                      " / DIA: "
                                      STRING(glb_dtmvtolt,"99/99/9999")
                                      FORMAT "x(17)"
                                      SKIP.
                                     
                     OUTPUT STREAM str_3 CLOSE.
              
                     /* Move para diretorio converte para utilizar na BO */
                     UNIX SILENT VALUE
                          ("cp " + aux_nmarqimp + " /usr/coop/" +
                           crapcop.dsdircop + "/converte" +
                           " 2> /dev/null").
                           
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
                                         INPUT "willian@ailos.coop.br",
                                         INPUT '"ERRO DE SEQUENCIA - "' +
                                               '"COO510 - "' +
                                               crapcop.nmrescop,
                                         INPUT SUBSTRING(aux_nmarqimp, 5),
                                         INPUT FALSE).
                                         
                     RUN enviar_email IN b1wgen0011
                               (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "convenios@ailos.coop.br," +
                                      "cartoes@ailos.coop.br",
                                INPUT '"ERRO DE SEQUENCIA - "' +
                                      '"COO510 - "' +
                                      crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).
                                  
                     DELETE PROCEDURE b1wgen0011.

                     /* remover arquivo criado de anexo */
                     UNIX SILENT VALUE("rm " + aux_nmarqimp +
                                       " 2>/dev/null").
                     
                     DELETE crawarq.
                     NEXT.
                 END.   
             ******************************************************/
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
                           " - COO510 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN p_imprime_informacoes.

RUN fontes/fimprg.p.                   


/* .......................................................................... */
PROCEDURE proc_processa_arquivo.

   DEFINE VARIABLE aux_qtregist AS INTEGER                            NO-UNDO.
   DEFINE VARIABLE aux_nrdconta AS INTEGER                            NO-UNDO.

   ASSIGN aux_flgfirst = FALSE
          glb_cdcritic = 0
          aux_dscritic = "".

   INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
   
   
   /*   Header do Arquivo   */
    
   IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

   IF   SUBSTR(aux_setlinha,01,02) <> "00" THEN
        glb_cdcritic = 468.
        
   IF   INTEGER(SUBSTR(aux_setlinha,35,04)) <> crapcop.cdageitg THEN
        glb_cdcritic = 134.

   IF   INTEGER(SUBSTR(aux_setlinha,39,11)) <> crapcop.nrctaitg THEN
        glb_cdcritic = 127.

   IF   INTEGER(SUBSTR(aux_setlinha,50,09)) <> crapcop.cdcnvitg THEN
        glb_cdcritic = 563.
    
   IF   glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_1 CLOSE.
            
            RUN fontes/critic.p.
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).
            
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - COO510 - " + glb_cdprogra + "' --> '" +
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
                                INPUT "convenios@ailos.coop.br," +
                                      "cartoes@ailos.coop.br," +
                                      "cobranca@ailos.coop.br",
                                INPUT '"ERROS DIVERSOS - "' +
                                      '"COO510 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).
                                
            DELETE PROCEDURE b1wgen0011.
            

            RETURN.
        END.

   /* Neste arquivo nao ha RECUSA TOTAL */

   /* registros DETALHE */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
      
      ASSIGN aux_qtregist = aux_qtregist + 1.

      /*  Verifica se eh final do Arquivo  */
       
      IF   INTEGER(SUBSTR(aux_setlinha,1,2)) = 99 THEN
           DO:
               /*   Conferir o total do arquivo   */

               IF   (aux_qtregist + 1) <> 
                    DECIMAL(SUBSTR(aux_setlinha,13,09)) THEN
                    DO:
                        ASSIGN glb_cdcritic = 504.
                         
                        RUN fontes/critic.p.
                        
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - COO510 - " + glb_cdprogra + 
                                          "' --> '" +
                                          glb_dscritic + 
                                          " ARQUIVO PROCESSADO! " +
                                          crawarq.nmarquiv +           
                                          " >> " + aux_nmarqlog).
                        LEAVE.
                    END.
           END.
      ELSE
           DO:
               ASSIGN aux_tpregist = INTEGER(SUBSTRING(aux_setlinha,1,2))
                      /* Conta integracao */
                      aux_nrdconta = INTEGER(SUBSTRING(aux_setlinha,34,11) +
                                     "0").
                                     
               /* Se a conta veio zerada, despreza */
               IF  aux_nrdconta = 0   THEN
                   DO:
                        IF   aux_tpregist = 31  THEN
                             aux_cdocorre = INTEGER(SUBSTRING(aux_setlinha,127,3)).
                        ELSE
                        IF   aux_tpregist = 32  THEN
                             aux_cdocorre = INTEGER(SUBSTRING(aux_setlinha,126,3)).
                        ELSE
                             aux_cdocorre = INTEGER(SUBSTRING(aux_setlinha,160,3)).


                       /* Se houver erro de sequencia no Detalhe */ 
                       IF  aux_cdocorre = 121  THEN
                           DO:
                               INPUT STREAM str_1 CLOSE.
                                 
                               aux_nmarquiv = "salvar/err" +
                                              SUBSTR(crawarq.nmarquiv,12,29).

                               /* Bloqueia geracao do arquivo */ 
                               FIND  crabtab   WHERE
                                     crabtab.cdcooper = glb_cdcooper  AND
                                     crabtab.nmsistem = "CRED"        AND
                                     crabtab.tptabela = "GENERI"      AND
                                     crabtab.cdempres = 00            AND
                                     crabtab.cdacesso = "NRARQMVITG"  AND
                                     crabtab.tpregist = 410  
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.          
                                                       
                               ASSIGN SUBSTR(crabtab.dstextab,7,1) = "1".
                               
                               UNIX SILENT VALUE
                                          ("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - COO510 - " + glb_cdprogra +
                                           "' --> '" + "ERRO DE SEQUENCIA - " +
                                           SUBSTRING(crawarq.nmarquiv,
                                            R-INDEX(crawarq.nmarquiv,"/") + 1) 
                                           + " >> " + aux_nmarqlog).
                                           
                               ASSIGN glb_cdcritic = 117. 
                               LEAVE.
                             
                           END.
                       ELSE
                           NEXT.
                    
                   END.
                   
               /* Elimina os erros */
               
               FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                      crapass.nrdctitg = STRING(aux_nrdconta)
                                      NO-LOCK,                  
                   EACH crapeca WHERE crapeca.cdcooper = crapass.cdcooper AND
                                      crapeca.nrdconta = crapass.nrdconta AND
                                      crapeca.tparquiv = 510 
                                      EXCLUSIVE-LOCK:
                   
                   DELETE crapeca.
                                    
               END.
               
               /* Calcula o digito da conta integracao - inclusive o "X" */
               RUN fontes/digbbx.p (INPUT  aux_nrdconta,
                                    OUTPUT glb_dsdctitg,
                                    OUTPUT glb_stsnrcal).
                                    
               /* Busca pela conta integracao */
               FIND crapass WHERE
                    crapass.cdcooper = glb_cdcooper AND
                    crapass.nrdctitg = glb_dsdctitg
                                  NO-LOCK NO-ERROR. 
                                  
               IF   NOT AVAILABLE crapass   THEN
                    DO:
                        /* Conta corrente */
                        aux_nrdconta = INTEGER(SUBSTRING(aux_setlinha,13,17)).

                        /* Busca pela conta corrente */
                        FIND crapass WHERE
                             crapass.cdcooper = glb_cdcooper AND
                             crapass.nrdconta = aux_nrdconta
                              NO-LOCK NO-ERROR. 
                    END.
                    
               FIND crapeca WHERE 
                    crapeca.cdcooper = glb_cdcooper     AND
                    crapeca.tparquiv = 510              AND  
                    crapeca.nrdconta = 0                AND
                    crapeca.nrseqarq = crawarq.nrsequen AND  
                    crapeca.nrdcampo = aux_nrdcampo NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass AND NOT AVAILABLE crapeca THEN
                    DO: 
                        CREATE crapeca. 
                        ASSIGN crapeca.nrdconta = 0
                               crapeca.dtretarq = glb_dtmvtolt
                               crapeca.nrdcampo = aux_nrdcampo
                               aux_nrdcampo     = aux_nrdcampo + 1
                               crapeca.nrseqarq = crawarq.nrsequen
                               crapeca.tparquiv = 510
                               crapeca.dscritic = "CI NAO CAD. " +
                                       SUBSTRING(aux_setlinha,34,11)
                               crapeca.cdcooper = glb_cdcooper.
                        VALIDATE crapeca.
                        NEXT. 
                    END.
               ELSE
                    aux_nrdconta = crapass.nrdconta.

               /* se for tipo de registro com codigo de ocorrencia (erros) */
               IF   CAN-DO("31,32,37",STRING(aux_tpregist))   THEN
                    DO:
                        IF   aux_tpregist = 31  THEN
                             ASSIGN aux_cdocorre =
                                    INTEGER(SUBSTRING(aux_setlinha,127,3)).
                        ELSE
                        IF   aux_tpregist = 32  THEN
                             ASSIGN aux_cdocorre =
                                    INTEGER(SUBSTRING(aux_setlinha,126,3)).
                        ELSE
                             ASSIGN aux_cdocorre =
                                    INTEGER(SUBSTRING(aux_setlinha,160,3)).
                        
                        /* se houve erro */
                        IF   aux_cdocorre <> 152  AND
                             aux_cdocorre <> 153  AND
                             aux_cdocorre <> 000  AND
                             aux_cdocorre <> 081  THEN   
                             DO:
                                 ASSIGN  aux_dscritic =
                                         SUBSTR(aux_setlinha,130,40).
                                 /*-----
                                 IF   aux_cdocorre = 999   THEN
                                      aux_dscritic =
                                                SUBSTR(aux_setlinha,130,40).
                                 ELSE                            
                                      DO:
                                          { includes/criticas_coo.i }
                                      END.
                                 -----*/
                            
                                 /* para o caso do mesmo erro duas vezes */
                                 FIND crapeca WHERE 
                                      crapeca.cdcooper = glb_cdcooper AND
                                      crapeca.tparquiv = 510
                                               AND  crapeca.nrdconta =
                                                            crapass.nrdconta
                                               AND  crapeca.nrseqarq = 
                                                            crawarq.nrsequen
                                               AND  crapeca.nrdcampo =
                                                            aux_cdocorre
                                                            NO-LOCK NO-ERROR.
                                     
                                 IF   NOT AVAILABLE crapeca   THEN
                                      DO:
                                         CREATE crapeca.
                                         ASSIGN crapeca.nrdconta = 
                                                              crapass.nrdconta
                                                crapeca.dtretarq = glb_dtmvtolt
                                                crapeca.nrdcampo = aux_cdocorre
                                                crapeca.nrseqarq = 
                                                              crawarq.nrsequen
                                                crapeca.tparquiv = 510
                                                crapeca.idseqttl = 
                                                       INT(SUBSTR(aux_setlinha,
                                                                  126,01)) 
                                                crapeca.dscritic = aux_dscritic
                                                crapeca.cdcooper = glb_cdcooper.
                                         VALIDATE crapeca.
                                        
                                      END.
                             END.
                        ELSE     /* sem erro */
                        IF   aux_tpregist = 31   THEN /* Cadastro do cartao */
                             DO:
                                 FOR EACH crawcrd WHERE
                                          crawcrd.cdcooper = glb_cdcooper AND
                                          crawcrd.nrdconta = 
                                          aux_nrdconta  AND
                                          crawcrd.flgctitg = 1 AND
                                          crawcrd.nrcrcard = 0 AND
                                          crawcrd.nrcctitg = 0
                                          EXCLUSIVE-LOCK:
                                    
                                     IF  aux_cdocorre <> 152 THEN 
                                         DO:  /* Com erro */
                                            ASSIGN crawcrd.flgctitg = 4.
                                         END.
                                     ELSE 
                                         DO:
                                            ASSIGN
                                            crawcrd.flgctitg = 2 /*cadastrado*/
                                            crawcrd.insitcrd = 4 /*em uso*/
                                            /* conta cartao */
                                            crawcrd.nrcctitg =
                                              INT(SUBSTR(aux_setlinha,46,9))  
                                          
                                            crawcrd.nrcrcard =
                                              INT(SUBSTR(aux_setlinha,46,9))  
                                                                   
                                            crawcrd.dtentreg = glb_dtmvtolt
                                            crawcrd.dtanuida = glb_dtmvtolt
                                            crawcrd.vlanuida = 0   
                                            crawcrd.inanuida = 0
                                            crawcrd.qtanuida = 0
                                            crawcrd.qtparcan = 0.

                                            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") 
                                             + " - " + STRING(TIME,"HH:MM:SS")   
                                             + " - " + glb_cdprogra + "' --> '"  
                                             + "Solicitado o envio/retorno do arquivo COO510 do BB na tela PRCITG pelo operador " + glb_cdoperad
                                             + " - Arquivo " + crawarq.nmarquiv
                                             + " - Conta "   + STRING(crawcrd.nrdconta)
                                             + " - Cartao "  + STRING(crawcrd.nrcrcard)
                                             + " >> log/proc_message.log").

                                            FIND crapcrd WHERE 
                                                 crapcrd.cdcooper = 
                                                         glb_cdcooper     AND
                                                 crapcrd.nrdconta =
                                                         crawcrd.nrdconta AND
                                                 crapcrd.nrcrcard =
                                                         crawcrd.nrcrcard
                                                 NO-LOCK NO-ERROR.
                                                 
                                            IF   AVAIL crapcrd  THEN
                                                 NEXT.
                                            
                                            CREATE crapcrd.
                                            ASSIGN
                                            crapcrd.nrdconta = crawcrd.nrdconta
                                            crapcrd.nrcrcard = crawcrd.nrcrcard
                                            crapcrd.nrctrcrd = crawcrd.nrctrcrd
                                            crapcrd.nrcpftit = crawcrd.nrcpftit
                                            crapcrd.nmtitcrd = crawcrd.nmtitcrd
                                            crapcrd.dddebito = crawcrd.dddebito
                                            crapcrd.cdlimcrd = crawcrd.cdlimcrd
                                            crapcrd.dtvalida = crawcrd.dtvalida
                                            crapcrd.tpcartao = crawcrd.tpcartao
                                            crapcrd.cdadmcrd = crawcrd.cdadmcrd
                                            crapcrd.dtcancel = ?
                                            crapcrd.cdmotivo = 0
                                            crapcrd.cdcooper = glb_cdcooper.
                                            VALIDATE crapcrd.

                                         END.
                                 END.
                             END.
                    END.
               ELSE         /* se for informacoes */
                    DO:
                       CREATE wdados.
                       ASSIGN wdados.tpregist = aux_tpregist
                              wdados.nrdconta = aux_nrdconta
                              wdados.nrcpftit = 
                                     DECIMAL(SUBSTRING(aux_setlinha,55,11))
                              wdados.nmtitcrd = 
                                     TRIM(SUBSTRING(aux_setlinha,66,60))
                              wdados.dscritic = aux_dscritic
                              wdados.nrcctitg = 
                                     DECIMAL(SUBSTRING(aux_setlinha,46,9)).

                       /* tratamento de cada tipo de registro de informacao */ 
                       IF   aux_tpregist = 33   THEN
                            DO:
                                ASSIGN wdados.dtvenfat = 
                                         DATE(SUBSTRING(aux_setlinha,126,8))
                                       wdados.qtddatra = 
                                         INTEGER(SUBSTRING(aux_setlinha,136,2))
                                       wdados.vlsdeved =
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                138,17),"999999999999999,99"))
                                                / 100
                                       wdados.vlpagmin =
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                155,17),"999999999999999,99"))
                                                / 100
                                       wdados.vlfatura =
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                172,17),"999999999999999,99"))
                                                / 100.
                            END.
                       ELSE
                       IF   aux_tpregist = 34   THEN
                            DO:
                                ASSIGN wdados.dtvenfat = 
                                         DATE(SUBSTRING(aux_setlinha,126,8))
                                       wdados.qtddatra = 
                                         INTEGER(SUBSTRING(aux_setlinha,136,2))
                                       wdados.vldebito =
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                138,17),"999999999999999,99"))
                                                / 100.
                            END.
                       ELSE
                       IF   aux_tpregist = 35   THEN
                            DO:
                                ASSIGN wdados.dtvenfat = 
                                         DATE(SUBSTRING(aux_setlinha,126,8))
                                       wdados.vldebito =
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                136,17),"999999999999999,99"))
                                                / 100.
                            END.
                       ELSE
                       IF   aux_tpregist = 36   THEN
                            DO:
                                ASSIGN wdados.dtvenfat = 
                                         DATE(SUBSTRING(aux_setlinha,96,8))
                                       wdados.vlsctaes = 
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                106,17),"999999999999999,99"))
                                                / 100
                                       wdados.vlsctare = 
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                123,17),"999999999999999,99"))
                                                / 100
                                       wdados.vlsparce = 
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                140,17),"999999999999999,99"))
                                                / 100
                                       wdados.vltotdeb =
                                         DECIMAL(STRING(SUBSTRING(aux_setlinha,
                                                157,17),"999999999999999,99"))
                                                / 100.
                            END.
                    END.
           END.
   END.  /* Fim DO WHILE */
   
   INPUT STREAM str_1 CLOSE.

   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
   
   IF   glb_cdcritic = 117  THEN  /* Sequencia Errada */ 
        DO:
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            
            /* Copia para diretorio converte para utilizar na BO */
            
            UNIX SILENT VALUE ("cp " + aux_nmarquiv + " /usr/coop/" +
                               crapcop.dsdircop + "/converte" +
                               " 2> /dev/null").
            
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.
          
            RUN enviar_email IN b1wgen0011
                               (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "convenios@ailos.coop.br," +
                                      "cartoes@ailos.coop.br," +
                                      "cobranca@ailos.coop.br",
                                INPUT '"ERRO DE SEQUENCIA - "' +
                                      '"COO510 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).
                                
            DELETE PROCEDURE b1wgen0011.
            
        END.
   ELSE
        UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
   
   IF   glb_cdcritic = 0     AND     /* se esta OK */
        aux_flaglast = YES   THEN    /* e eh o ultimo da sequencia */
        DO TRANSACTION:

            ASSIGN SUBSTRING(craptab.dstextab,1,5) =
                                         STRING(crawarq.nrsequen + 1,"99999").
        END.

END PROCEDURE. /* FIM proc_processa_arquivo */


PROCEDURE p_imprime_informacoes:

   DEF     VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
   DEF     VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.

   DEF     VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
   DEF     VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
   DEF     VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
   DEF     VAR aux_nmarqinf AS CHAR                                  NO-UNDO.

   FORM HEADER
        "INFORMACOES RECEBIDAS PELO B.BRASIL, NO ARQUIVO COO510 -"  AT 14
        "CARTAO DE CREDITO"
        WITH PAGE-TOP WIDTH 132 FRAME f_cab_info.


   FORM wdados.nrdconta    LABEL "Conta/DV"
        wdados.nrcctitg    LABEL "Cta. Cartao"
        wdados.nrcpftit    LABEL "CPF"
        wdados.nmtitcrd    LABEL "Nome"             FORMAT "x(30)"
        wdados.dtvenfat    LABEL "Venc.Fatura"
        wdados.qtddatra    LABEL "Atraso"   
        wdados.vlsdeved    LABEL "Saldo Devedor"    FORMAT "zzzzzzzzz9.99"
        wdados.vlpagmin    LABEL "Pagto.Minimo"     FORMAT "zzzzzzzzz9.99"
        wdados.vlfatura    LABEL "Valor da Fatura"  FORMAT "zzzzzzzzz9.99"
        WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_tipo33.

   FORM wdados.nrdconta    LABEL "Conta/DV"
        wdados.nrcctitg    LABEL "Cta. Cartao"
        wdados.nrcpftit    LABEL "CPF"
        wdados.nmtitcrd    LABEL "Nome"
        wdados.dtvenfat    LABEL "Venc.Fatura"
        wdados.qtddatra    LABEL "Dias em Atraso"
        wdados.vldebito    LABEL "Valor do Debito"
        WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_tipo34.
     
   FORM wdados.nrdconta    LABEL "Conta/DV"
        wdados.nrcctitg    LABEL "Cta. Cartao"
        wdados.nrcpftit    LABEL "CPF"
        wdados.nmtitcrd    LABEL "Nome"
        wdados.dtvenfat    LABEL "Venc.Fatura"
        wdados.vldebito    LABEL "Valor a ser Debitado"
        WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_tipo35.
     

   FORM wdados.nrdconta    LABEL "Conta/DV"
        wdados.nrcctitg    LABEL "Cta. Cartao"
        wdados.nrcpftit    LABEL "CPF"
        wdados.nmtitcrd    LABEL "Nome"              FORMAT "x(22)"
        wdados.dtvenfat    LABEL "Venc.Fatura"
        wdados.vlsctaes    LABEL "Saldo(M.Estr.)"    FORMAT "zzz,zzz,zz9.99"
        wdados.vlsctare    LABEL "Saldo(Em Real)"    FORMAT "zzz,zzz,zz9.99"
        wdados.vlsparce    LABEL "Saldo Parcelas"    FORMAT "zzz,zzz,zz9.99"
        wdados.vltotdeb    LABEL "Total Debito"      FORMAT "zzz,zzz,zz9.99"
        WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_tipo36.

   ASSIGN aux_nmarqinf = "rl/crrl389_" + STRING(TIME) + ".lst".
   
   { includes/cabrel132_1.i }
   
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqinf) PAGED PAGE-SIZE 30 APPEND.
   
   VIEW STREAM str_1 FRAME f_cabrel132_1.
   VIEW STREAM str_1 FRAME f_cab_info.

   FOR EACH wdados NO-LOCK BREAK BY wdados.tpregist
                                   BY wdados.nrdconta:
                                   
       IF   wdados.tpregist = 33  THEN
            DO:
                IF   FIRST-OF(wdados.tpregist)   THEN
                     PUT STREAM str_1 SKIP(2)
                                      "CONTAS EM ATRASO OU INADIMPLENTES"
                                      SKIP(1).

                DISPLAY STREAM str_1 
                        wdados.nrdconta  wdados.nrcpftit
                        wdados.nmtitcrd  wdados.dtvenfat
                        wdados.qtddatra  wdados.vlsdeved
                        wdados.vlpagmin  wdados.vlfatura
                        wdados.nrcctitg
                        WITH FRAME f_tipo33.
                                 
                DOWN STREAM str_1 WITH FRAME f_tipo33.
            END.
       ELSE
       IF   wdados.tpregist = 34  THEN
            DO:
                IF   FIRST-OF(wdados.tpregist)   THEN
                     PUT STREAM str_1 SKIP(2)
                                      "DEBITO A COOPERATIVA POR MOTIVO DE "
                                      "INADIMPLENCIA" 
                                      SKIP(1).

                DISPLAY STREAM str_1 
                        wdados.nrdconta  wdados.nrcpftit
                        wdados.nmtitcrd  wdados.dtvenfat
                        wdados.qtddatra  wdados.vldebito
                        wdados.nrcctitg
                        WITH FRAME f_tipo34.
                                 
                DOWN STREAM str_1 WITH FRAME f_tipo34.
            END.
       ELSE
       IF   wdados.tpregist = 35  THEN
            DO:
                IF   FIRST-OF(wdados.tpregist)   THEN
                     PUT STREAM str_1 SKIP(2)
                                      "PEDIDO DE AUTORIZACAO PARA PAGAMENTO "
                                      "DE CARTAO DE CREDITO" 
                                      SKIP(1).

                DISPLAY STREAM str_1 
                        wdados.nrdconta  wdados.nrcpftit
                        wdados.nmtitcrd  wdados.dtvenfat
                        wdados.vldebito  wdados.nrcctitg
                        WITH FRAME f_tipo35.
                                 
                DOWN STREAM str_1 WITH FRAME f_tipo35.
            END.
       ELSE
       IF   wdados.tpregist = 36  THEN
            DO:
                IF   FIRST-OF(wdados.tpregist)   THEN
                     PUT STREAM str_1 SKIP(2)
                                      "VALORES DOS SALDOS PARA LIQUIDACAO"
                                      SKIP(1).

                DISPLAY STREAM str_1 
                        wdados.nrdconta  wdados.nrcpftit
                        wdados.nmtitcrd  wdados.dtvenfat
                        wdados.vlsctaes  wdados.vlsctare
                        wdados.vlsparce  wdados.vltotdeb
                        wdados.nrcctitg
                        WITH FRAME f_tipo36.
                                 
                DOWN STREAM str_1 WITH FRAME f_tipo36.
            END.
   
       IF   LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 5)  THEN
            DO:
                PAGE STREAM str_1.
                VIEW STREAM str_1 FRAME f_cabrel132_1.
                VIEW STREAM str_1 FRAME f_cab_info.
            END.   
   END.                           
   
   OUTPUT STREAM str_1 CLOSE.

   ASSIGN glb_nrcopias = 1
          glb_nmformul = "132col"
          glb_nmarqimp = aux_nmarqinf.
   
   RUN fontes/imprim.p.
   
   /* se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" */
   IF   glb_inproces = 1   THEN
        UNIX SILENT VALUE("cp " + aux_nmarqinf + " rlnsv/" +
                          SUBSTRING(aux_nmarqinf,R-INDEX(aux_nmarqinf,"/") + 1,
                          LENGTH(aux_nmarqinf) - R-INDEX(aux_nmarqinf,"/"))).
                          
END PROCEDURE.


/* ........................................................................ */
