/* .............................................................................

   Programa: Fontes/crps454.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2005                      Ultima atualizacao: 10/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratar arq. de retorno BB - C/C INTEGRACAO - RELACAO DAS CONTAS.
               Arquivo COO552 (Relatorio para acompanhamento).                
               
   Alteracoes:   19/09/2005 - Nao controlar sequencia arquivo COO552(Mirtes)
   
                 23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                              crapcop.cdcooper = glb_cdcooper (Diego).
                              
                 26/09/2005 - "Jogar" para o LOG da PRCITG quando a conta ano
                              for encontrada (Evandro).
                              
                 17/10/2005 - Incluido controle de falta de registro (Evandro).
                 
                 04/11/2005 - Alterado o tratamento de inclusoes e exclusoes de
                              titulares (Evandro).
                 
                 18/11/2005 - Acerto no erro de CPF nao encontrado;
                            - Tratamento de contas JURIDICAS (Evandro).
                            
                 10/01/2006 - Correcao das mensagens para o LOG (Evandro).
                 
                 19/01/2006 - Tratamento para informacao de conta encerrada
                              (Evandro).
                              
                 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
                 
                 20/02/2006 - Acerto na mensagem arquivo processado (Evandro).
                 
                 24/03/2006 - Acerto na informacao conta encerrada (Evandro).
                 
                 17/11/2006 - Criticar quando a conta estiver encerrada aqui e
                              ativa no BB (Evandro).

                 04/01/2007 - Prever tipos de contas BANCOOB - 08, 09, 10 e 11
                              (Evandro).
                              
                 21/06/2010 - Alteracao tamanho SET STREAM e extensao .ret (Vitor).    
                 
                 03/04/2012 - Alteracao dos arquivos COO552 para novo diretorio.
                              (David Kruger).                           
                              
                 12/11/2012 - Retirar matches dos find/for each (Gabriel).
                 
                 10/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)               

		             07/03/2018 - Ajuste para buscar os tipo de conta integracao 
                              da Package CADA0006 do orcale. PRJ366 (Lombardi).            

............................................................................. */

{ sistema/generico/includes/var_oracle.i } 

DEF STREAM str_1.     /*  Para relatorio  */
DEF STREAM str_2.     /*  Para arquivo de leitura  */

DEFINE TEMP-TABLE crawarq                                           NO-UNDO
          FIELD nmarquiv AS CHAR              
          FIELD nrsequen AS INTEGER
          FIELD qtassoci AS INTEGER
          INDEX crawarq1 AS PRIMARY
                nmarquiv nrsequen.

DEFINE TEMP-TABLE crawttl                                           NO-UNDO
          FIELD nrdconta LIKE crapttl.nrdconta
          FIELD nrcpfcgc LIKE crapttl.nrcpfcgc
          FIELD idseqttl LIKE crapttl.idseqttl
          INDEX crawttl1 AS PRIMARY
                nrdconta idseqttl.

DEFINE TEMP-TABLE tt_tipos_conta
       FIELD inpessoa AS INTEGER
       FIELD cdtipcta AS INTEGER.

{ includes/var_batch.i }
 
DEFINE VARIABLE rel_nmempres AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEFINE VARIABLE rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5     NO-UNDO.
DEFINE VARIABLE rel_nmresemp AS CHAR                                NO-UNDO.
DEFINE VARIABLE rel_nrmodulo AS INT     FORMAT "9"                  NO-UNDO.
DEFINE VARIABLE rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]            NO-UNDO.

DEFINE VARIABLE aux_cdseqtab AS INT                                 NO-UNDO.
DEFINE VARIABLE aux_nmarquiv AS CHAR                                NO-UNDO.
DEFINE VARIABLE aux_setlinha AS CHAR                                NO-UNDO.
DEFINE VARIABLE aux_flgfirst AS LOGICAL                             NO-UNDO.
DEFINE VARIABLE aux_contador AS INT                                 NO-UNDO.
DEFINE VARIABLE aux_nmarqdat AS CHAR                                NO-UNDO.
DEFINE VARIABLE aux_flaglast AS LOGICAL                             NO-UNDO.
DEFINE VARIABLE aux_qtregist AS INTEGER       INIT   0              NO-UNDO.
DEFINE VARIABLE aux_flgachou AS LOGICAL                             NO-UNDO.

/* Variaveis para o XML */ 
DEFINE VARIABLE xDoc          AS HANDLE                              NO-UNDO.   
DEFINE VARIABLE xRoot         AS HANDLE                              NO-UNDO.  
DEFINE VARIABLE xRoot2        AS HANDLE                              NO-UNDO.  
DEFINE VARIABLE xField        AS HANDLE                              NO-UNDO. 
DEFINE VARIABLE xText         AS HANDLE                              NO-UNDO. 
DEFINE VARIABLE aux_cont_raiz AS INTEGER                             NO-UNDO. 
DEFINE VARIABLE aux_cont      AS INTEGER                             NO-UNDO. 
DEFINE VARIABLE ponteiro_xml  AS MEMPTR                              NO-UNDO. 
DEFINE VARIABLE aux_tpsconta  AS LONGCHAR                            NO-UNDO.
DEFINE VARIABLE aux_des_erro  AS CHAR                                NO-UNDO.
DEFINE VARIABLE aux_dscritic  AS CHAR                                NO-UNDO.

/* nome do arquivo de log */
DEFINE VARIABLE aux_nmarqlog AS CHAR                                NO-UNDO.
                                                               
DEFINE VARIABLE aux_ctpsqitg AS CHAR                                NO-UNDO.

DEFINE BUFFER crabttl FOR crawttl.

ASSIGN glb_cdprogra = "crps454"
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
                      "/compel/recepcao/COO552*.ret"                       
       aux_flgfirst = TRUE.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo552" + STRING(DAY(glb_dtmvtolt),"99") +
                                            STRING(MONTH(glb_dtmvtolt),"99") +
                                            STRING(YEAR(glb_dtmvtolt),"9999") +
                                            STRING(aux_contador,"999").

   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                     aux_nmarqdat + " 2> /dev/null").

   UNIX SILENT VALUE("cp " + aux_nmarquiv +  " " + "/micros/" + 
                     crapcop.dsdircop + "/compel/recepcao/retornos 2> /dev/null").
   
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").

   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") UNBUFFERED NO-ECHO.
       
   IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,027,05)) /* Quoter */
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
                           " - COO552 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

/* Limpa os erros para serem gerados novamente */
FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper AND
                       crapeca.tparquiv = 552 EXCLUSIVE-LOCK TRANSACTION:
    DELETE crapeca.
END.

ASSIGN aux_contador = 1.

FOR EACH crawarq NO-LOCK BREAK BY crawarq.nrsequen
                                 BY crawarq.nmarquiv:  

    RUN proc_processa_arquivo.
    
    IF   glb_cdcritic = 0   THEN
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO552 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN fontes/fimprg.p.

/* .......................................................................... */

PROCEDURE proc_processa_arquivo:

   DEF VAR aux_flgtipo2 AS LOGICAL     INIT TRUE                     NO-UNDO.

   EMPTY TEMP-TABLE crawttl.

   INPUT STREAM str_2 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
   
   glb_cdcritic = 0.

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
                              " - COO552 - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " - " + aux_nmarquiv +
                              " >> " + aux_nmarqlog).
            RETURN.
        END.
 
   aux_qtregist = 1. /* header */
   
   DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
   
      IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0
             aux_qtregist = aux_qtregist + 1.
      
      /*  Verifica se eh final do Arquivo  */
      IF   INTEGER(SUBSTR(aux_setlinha,01,05)) = 99999 THEN
           DO:
                /*   Conferir o total do arquivo   */
                IF   (aux_qtregist) <> 
                     DECIMAL(SUBSTR(aux_setlinha,06,09)) THEN
                     DO:
                         ASSIGN glb_cdcritic = 504.
                         
                         RUN fontes/critic.p.

                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - COO552 - " + glb_cdprogra + 
                                           "' --> '" +
                                           glb_dscritic + 
                                           " - ARQUIVO PROCESSADO - " +
                                           aux_nmarquiv +
                                           " >> " + aux_nmarqlog).
                     END.
                LEAVE.
           END.

      /* Registro tipo 1 */
      IF   INTEGER(SUBSTRING(aux_setlinha,06,02)) = 1    THEN
           DO:
               IF   SUBSTRING(aux_setlinha,52,09) = "ENCERRADA"   THEN
                    DO:
                        /* Nao analisa detalhe tipo 2 se conta foi encerrada */
                        aux_flgtipo2 = FALSE.
                        
                        ASSIGN aux_ctpsqitg = SUBSTRING(aux_setlinha,08,08).
                        
                        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                           crapass.nrdctitg = aux_ctpsqitg
                                           NO-LOCK NO-ERROR.                

                        /* Nao pode criticar se nao encontrar o ASS porque pode
                           ser uma conta integracao muito velha que foi
                           substituida */
                        IF   AVAILABLE crapass   THEN
                             DO:
                                 /* A conta ITG nao esta encerrada na COOP */
                                 IF   crapass.flgctitg = 2   THEN
                                      DO:
                                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                          RUN STORED-PROCEDURE pc_lista_tipo_conta_itg
                                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 1,    /* Flag conta itg */
                                                                               INPUT 0,    /* modalidade */
                                                                              OUTPUT "",   /* Tipos de conta */
                                                                              OUTPUT "",   /* Flag Erro */
                                                                              OUTPUT "").  /* Descrição da crítica */

                                          CLOSE STORED-PROC pc_lista_tipo_conta_itg
                                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                                          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                          ASSIGN aux_tpsconta = ""
                                                 aux_des_erro = ""
                                                 aux_dscritic = ""
                                                 aux_tpsconta = pc_lista_tipo_conta_itg.pr_tiposconta 
                                                                WHEN pc_lista_tipo_conta_itg.pr_tiposconta <> ?
                                                 aux_des_erro = pc_lista_tipo_conta_itg.pr_des_erro 
                                                                WHEN pc_lista_tipo_conta_itg.pr_des_erro <> ?
                                                 aux_dscritic = pc_lista_tipo_conta_itg.pr_dscritic
                                                                WHEN pc_lista_tipo_conta_itg.pr_dscritic <> ?.

                                          IF aux_des_erro = "NOK"  THEN
                                              DO:
                                                  glb_dscritic = aux_dscritic.
                                                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                                    " - " + glb_cdprogra + "' --> '"  +
                                                                    glb_dscritic + " >> " + aux_nmarqlog).
                                                  RETURN.
                                              END.
                                          
                                          /* Inicializando objetos para leitura do XML */ 
                                          CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
                                          CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
                                          CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
                                          CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
                                          CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                                          
                                          EMPTY TEMP-TABLE tt_tipos_conta.

                                          /* Efetuar a leitura do XML*/ 
                                          SET-SIZE(ponteiro_xml) = LENGTH(aux_tpsconta) + 1. 
                                          PUT-STRING(ponteiro_xml,1) = aux_tpsconta. 
                                             
                                          IF ponteiro_xml <> ? THEN
                                              DO:
                                                  xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                                                  xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                                              
                                                  DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                                              
                                                      xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                                              
                                                      IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                                                       NEXT. 
                                              
                                                      IF xRoot2:NUM-CHILDREN > 0 THEN
                                                        CREATE tt_tipos_conta.
                                              
                                                      DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                                                          
                                                          xRoot2:GET-CHILD(xField,aux_cont).
                                                              
                                                          IF xField:SUBTYPE <> "ELEMENT" THEN 
                                                              NEXT. 
                                                          
                                                          xField:GET-CHILD(xText,1).
                                                         
                                                          ASSIGN tt_tipos_conta.inpessoa =  INT(xText:NODE-VALUE) WHEN xField:NAME = "inpessoa".
                                                          ASSIGN tt_tipos_conta.cdtipcta =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtipo_conta".
                                                          
                                                      END. 
                                                      
                                                  END.
                                              
                                                  SET-SIZE(ponteiro_xml) = 0. 
                                              END.

                                          DELETE OBJECT xDoc. 
                                          DELETE OBJECT xRoot. 
                                          DELETE OBJECT xRoot2. 
                                          DELETE OBJECT xField. 
                                          DELETE OBJECT xText.
                                      
                                          FIND tt_tipos_conta WHERE tt_tipos_conta.inpessoa = crapass.inpessoa AND
                                                                    tt_tipos_conta.cdtipcta = crapass.cdtipcta NO-LOCK NO-ERROR.

                                          IF AVAILABLE tt_tipos_conta THEN
                                              DO:
                                          
                                                  CREATE crapeca.
                                                  ASSIGN crapeca.nrdconta = crapass.nrdconta
                                                         crapeca.dscritic = "CONTA INTEGRACAO " +
                                                                            aux_ctpsqitg +
                                                                            " ATIVA NA COOP - " +
                                                                            "ENCERRADA NO BB"
                                                         crapeca.tparquiv = 552
                                                         crapeca.cdcooper = glb_cdcooper
                                                         crapeca.dtretarq = glb_dtmvtolt
                                                         crapeca.idseqttl = 0
                                                         crapeca.nrseqarq = crawarq.nrsequen
                                                         crapeca.nrdcampo = aux_contador
                                                         aux_contador     = aux_contador + 1.
                                                  VALIDATE crapeca.
                                                                 
                                                  NEXT.
                                              end.
                                      END.

                                 /* Atualiza as flags da crapalt */
                                 FOR EACH crapalt WHERE 
                                     crapalt.cdcooper = glb_cdcooper     AND
                                     crapalt.nrdconta = crapass.nrdconta AND
                                     crapalt.flgctitg = 1 EXCLUSIVE-LOCK:

                                     ASSIGN crapalt.flgctitg = 2. /* ok */
                                 END.
                              
                                 /* Elimina os erros */
                                 FOR EACH crapeca WHERE 
                                          crapeca.cdcooper = glb_cdcooper AND
                                          crapeca.nrdconta = crapass.nrdconta
                                          EXCLUSIVE-LOCK:
                                     DELETE crapeca.
                                 END.
                                 
                             END.  /* AVAIL ass */
                    END.  /* Fim do IF ... ENCERRADA */
               ELSE
                    DO:
                        ASSIGN aux_ctpsqitg = SUBSTRING(aux_setlinha,08,08).
                        
                        /* verifica se a conta esta ativa na cooperativa */
                        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                           crapass.nrdctitg = aux_ctpsqitg
                                           NO-LOCK NO-ERROR.                

                        /* Nao pode criticar se nao encontrar o ASS porque pode
                           ser uma conta integracao muito velha que foi
                           substituida */
                        IF   AVAILABLE crapass       AND
                             crapass.flgctitg <> 2   THEN
                             DO:
                                 ASSIGN aux_flgachou = FALSE.   

                                 /* procura o registro crapalt de exclusao para
                                    re-enviar */
                                 FOR EACH crapalt WHERE
                                          crapalt.cdcooper = glb_cdcooper
                                      AND crapalt.nrdconta = crapass.nrdconta
                                      AND crapalt.flgctitg <> 1
                                      AND crapalt.flgctitg <> 2
                                          EXCLUSIVE-LOCK:

                                     IF   crapalt.dsaltera 
                                          MATCHES "*exclusao conta-itg*"   THEN
                                          DO:
                                              ASSIGN crapalt.flgctitg = 0 /*enviar*/
                                                     aux_flgachou = TRUE.
                                              LEAVE.
                                          END.
                                 END.
                                            
                                 IF   NOT aux_flgachou   THEN 
                                      DO:
                                          CREATE crapeca.
                                          ASSIGN crapeca.nrdconta =
                                                      crapass.nrdconta
                                                 crapeca.dscritic = 
                                                      "CONTA INTEGRACAO " +
                                                      aux_ctpsqitg +
                                                      " ENCERRADA NA COOP - " +
                                                      "ATIVA NO BB"
                                                 crapeca.tparquiv = 552
                                                 crapeca.cdcooper = glb_cdcooper
                                                 crapeca.dtretarq = glb_dtmvtolt
                                                 crapeca.idseqttl = 0
                                                 crapeca.nrseqarq = 
                                                      crawarq.nrsequen
                                                 crapeca.nrdcampo = aux_contador
                                                 aux_contador    = 
                                                      aux_contador + 1.
                                          VALIDATE crapeca.
                                      END.
                                 NEXT.
                             END.                      
                        
                        aux_flgtipo2 = TRUE. /* Analisa detalhe tipo 2 */
                    END.
           END.  /* Fim do tipo 1 */
      ELSE
      /* Registro tipo 2 */
      IF   INTEGER(SUBSTRING(aux_setlinha,06,02)) = 2  AND
           aux_flgtipo2                                THEN
           DO:
               ASSIGN aux_ctpsqitg = SUBSTRING(aux_setlinha,08,08).
                
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdctitg = aux_ctpsqitg
                                  NO-LOCK NO-ERROR.                

               IF   NOT AVAILABLE crapass   THEN
                    DO:

                       /* Gera critica somente para o 1o titular */
                       IF   INT(SUBSTR(aux_setlinha,16,02)) <> 1   THEN
                            NEXT.
                            
                       FIND FIRST crapass WHERE 
                          crapass.cdcooper = glb_cdcooper    AND
                          crapass.nrcpfcgc = DEC(SUBSTRING(aux_setlinha,18,14))
                          NO-LOCK NO-ERROR.
                       
                       IF   NOT AVAILABLE crapass   THEN
                            DO:
                               /* Quando nao encontra o CPF do associado */
                               CREATE crapeca.
                               ASSIGN crapeca.nrdconta = 0
                                      crapeca.dscritic = "CONTA INTEGRACAO " +
                                              aux_ctpsqitg +
                                              ", CPF " +
                                              SUBSTRING(aux_setlinha,18,14) +
                                              " NAO ENCONTRADO"
                                      crapeca.tparquiv = 552
                                      crapeca.cdcooper = glb_cdcooper
                                      crapeca.dtretarq = glb_dtmvtolt
                                      crapeca.idseqttl = 0
                                      crapeca.nrseqarq = crawarq.nrsequen
                                      crapeca.nrdcampo = aux_contador
                                      aux_contador     = aux_contador + 1.
                               VALIDATE crapeca.
                               NEXT.
                            END.
                       ELSE
                            DO:
                               /* Quando existe mais de uma conta integracao
                                  para a mesma conta da cooperativa */
                               CREATE crapeca.
                               ASSIGN crapeca.nrdconta = crapass.nrdconta
                                      crapeca.dscritic = "CONTA INTEGRACAO " +
                                              aux_ctpsqitg +
                                              " NAO PERTENCE AO CPF " +
                                              SUBSTRING(aux_setlinha,18,14)
                                      crapeca.tparquiv = 552
                                      crapeca.cdcooper = glb_cdcooper
                                      crapeca.dtretarq = glb_dtmvtolt
                                      crapeca.idseqttl = 0
                                      crapeca.nrseqarq = crawarq.nrsequen
                                      crapeca.nrdcampo = aux_contador
                                      aux_contador     = aux_contador + 1.
                               VALIDATE crapeca.
                               NEXT.                                
                            END.
                            
                    END.

               /* So analisa titulares de contas pessoa FISICA */
               IF   crapass.inpessoa <> 1   THEN
                    NEXT.               
               
               CREATE crawttl.
               ASSIGN crawttl.nrdconta = crapass.nrdconta
                      crawttl.idseqttl = INT(SUBSTR(aux_setlinha,16,02))
                      crawttl.nrcpfcgc = DEC(SUBSTRING(aux_setlinha,18,14)).
           END.
       
   END.  /*   Fim  do DO WHILE TRUE  */

   INPUT STREAM str_2 CLOSE.

   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
    
   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").

   FOR EACH crawttl NO-LOCK TRANSACTION 
                            BREAK BY crawttl.nrdconta BY crawttl.idseqttl:

       /* Compara arquivo com a base */
       FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                          crapttl.nrdconta = crawttl.nrdconta AND
                          crapttl.idseqttl = crawttl.idseqttl NO-LOCK NO-ERROR.
                       
       IF   NOT AVAILABLE crapttl   THEN
            DO:
                /* Exclusao do titular no BB */
                CREATE crapeca.
                ASSIGN crapeca.nrdconta = crawttl.nrdconta
                       crapeca.dscritic = "EFETUANDO EXCLUSAO SEG. TITULAR"
                       crapeca.tparquiv = 552
                       crapeca.cdcooper = glb_cdcooper
                       crapeca.dtretarq = glb_dtmvtolt
                       crapeca.idseqttl = 2
                       crapeca.nrseqarq = crawarq.nrsequen
                       crapeca.nrdcampo = aux_contador
                       aux_contador     = aux_contador + 1.
                VALIDATE crapeca.
            END.
       ELSE
       IF   crawttl.nrcpfcgc <> crapttl.nrcpfcgc   THEN
            DO:
                CREATE crapeca.
                ASSIGN crapeca.nrdconta = crapttl.nrdconta
                       crapeca.tparquiv = 552
                       crapeca.dscritic = "Divergencias CPF(Cooperativa/BB)" +
                                          " - " + STRING(crapttl.idseqttl,"9")
                                          + " Titular"
                       crapeca.cdcooper = glb_cdcooper
                       crapeca.dtretarq = glb_dtmvtolt
                       crapeca.idseqttl = crapttl.idseqttl
                       crapeca.nrseqarq = crawarq.nrsequen
                       crapeca.nrdcampo = aux_contador
                       aux_contador     = aux_contador + 1.
                VALIDATE crapeca.
                       
                NEXT. /* Para nao dar erro de CPF duas vezes */
            END.

       /* Compara a base com o arquivo */
       IF   LAST-OF(crawttl.nrdconta)   THEN
            DO:
                FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                                       crapttl.nrdconta = crawttl.nrdconta
                                       NO-LOCK BREAK BY crapttl.idseqttl:
                                  
                    FIND crabttl WHERE crabttl.nrdconta = crapttl.nrdconta AND
                                       crabttl.idseqttl = crapttl.idseqttl
                                       NO-LOCK NO-ERROR.
                                  
                    /* So gera inclusao se o titular tem cadastro completo */
                    IF   NOT AVAILABLE crabttl   AND
                         crapttl.indnivel = 4    THEN
                         DO:
                            /* Inclusao do titular no BB */
                            CREATE crapeca.
                            ASSIGN crapeca.nrdconta = crawttl.nrdconta
                                   crapeca.dscritic = "EFETUANDO INCLUSAO " +
                                                      "SEG. TITULAR"
                                   crapeca.tparquiv = 552
                                   crapeca.cdcooper = glb_cdcooper
                                   crapeca.dtretarq = glb_dtmvtolt
                                   crapeca.idseqttl = 2
                                   crapeca.nrseqarq = crawarq.nrsequen
                                   crapeca.nrdcampo = aux_contador
                                   aux_contador     = aux_contador + 1.
                            VALIDATE crapeca.
                         END.
                    ELSE
                    IF   AVAILABLE crabttl                       AND
                         crabttl.nrcpfcgc <> crapttl.nrcpfcgc    THEN
                         DO:
                             CREATE crapeca.
                             ASSIGN crapeca.nrdconta = crabttl.nrdconta
                                    crapeca.tparquiv = 552
                                    crapeca.dscritic = "Divergencias " +
                                          "CPF(Cooperativa/BB)" +
                                          " - " + STRING(crabttl.idseqttl,"9")
                                          + " Titular"
                                    crapeca.cdcooper = glb_cdcooper
                                    crapeca.dtretarq = glb_dtmvtolt
                                    crapeca.idseqttl = crabttl.idseqttl
                                    crapeca.nrseqarq = crawarq.nrsequen
                                    crapeca.nrdcampo = aux_contador
                                    aux_contador     = aux_contador + 1.
                             VALIDATE crapeca.
                         END.
                END.
            END.
             
   END. /* Fim do FOR EACH */
    
END PROCEDURE.
/* ......................................................................... */

