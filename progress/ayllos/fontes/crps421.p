/* .............................................................................

   Programa: Fontes/crps421.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro/Diego
   Data    : Abril/2006                      Ultima atualizacao: 16/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratar arquivo de retorno BB - ALTERACAO DE LIMITES PARA
               MOVIMENTACAO FINANCEIRA DO COOPERADO(COO501)
              (Somente relatorio para acompanhamento).                
               
   Alteracoes: 04/01/2007 - Prever tipos de contas BANCOOB - 08, 09, 10 e 11
                            (Evandro).
                            
               28/05/2007 - Retirado vinculacao da execucao do imprim.p ao
                            codigo da cooperativa.(Guilherme).
               
               09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme)              
                           
               09/01/2009 - Mover arquivo err* para diretorio /salvar e enviar
                            email para suporte.operacional@cecred.coop.br
                            (Diego).
                            
               18/06/2010 - Alteracao tamanho SET STREAM e extensao .ret (Vitor).            
   
               20/09/2010 - Inclusao do e-mail cartoes@cecred.coop.br (Adriano).
               
               09/12/2010 - Aumento do campo nrdconta no frame f_descricao 
                           (Vitor).
                           
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
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                    
               
               07/03/2018 - Ajuste para buscar os tipo de conta integracao 
                            da Package CADA0006 do orcale. (Lombardi).
............................................................................. */

{ sistema/generico/includes/var_oracle.i } 

DEF STREAM str_1.     /*  Para relatorio  */
DEF STREAM str_2.     /*  Para arquivo de leitura  */

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEFINE TEMP-TABLE cratrej
       FIELD cdagenci  LIKE crapass.cdagenci
       FIELD nrdctitg  LIKE crapass.nrdctitg      
       FIELD nrdconta  LIKE crapass.nrdconta
       FIELD cdcritic  AS   INTEGER   FORMAT "99"
       FIELD dscritic  AS   CHAR
       INDEX cratrej_1 AS   PRIMARY 
             nrdconta cdagenci.

DEFINE TEMP-TABLE crawarq                                            NO-UNDO
       FIELD nmarquiv AS CHAR              
       FIELD nrsequen AS INTEGER
       FIELD qtassoci AS INTEGER
       INDEX crawarq1 AS PRIMARY
             nmarquiv nrsequen.

DEFINE TEMP-TABLE tt_tipos_conta
       FIELD inpessoa AS INTEGER
       FIELD cdtipcta AS INTEGER.

{ includes/var_batch.i }
 
DEFINE VARIABLE rel_nmempres AS CHAR    FORMAT "x(15)"             NO-UNDO.
DEFINE VARIABLE rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5    NO-UNDO.
DEFINE VARIABLE rel_nmresemp AS CHAR                               NO-UNDO.
DEFINE VARIABLE rel_nrmodulo AS INT     FORMAT "9"                 NO-UNDO.
DEFINE VARIABLE rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]            NO-UNDO.

DEFINE VARIABLE aux_cdseqtab AS INT                                NO-UNDO.

DEFINE VARIABLE aux_nmarquiv AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_setlinha AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_flgfirst AS LOGICAL                            NO-UNDO.

DEFINE VARIABLE aux_contador AS INT                                NO-UNDO.
DEFINE VARIABLE aux_nmarqdat AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_flaglast AS LOGICAL                            NO-UNDO.
DEFINE VARIABLE aux_cdocorre AS INT                                NO-UNDO.
DEFINE VARIABLE tot_qtdcriti AS INT                                NO-UNDO.
 
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
DEFINE VARIABLE aux_nmarqlog AS CHAR                               NO-UNDO.

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

ASSIGN glb_cdprogra = "crps421"
       glb_flgbatch = FALSE.     

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

ASSIGN aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
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

/*FOR EACH crawarq:
    DELETE crawarq.
  END.*/
  
EMPTY TEMP-TABLE crawarq.

ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/compel/recepcao/COO501*.ret"
       aux_flgfirst = TRUE.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo501" + STRING(DAY(glb_dtmvtolt),"99") +
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
   ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,040,05)) /* Quoter */
          crawarq.nmarquiv = aux_nmarqdat     /* "integra/coo501 ..." */
          aux_flgfirst     = FALSE.

   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_flgfirst THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO501 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                   crabtab.nmsistem = "CRED"        AND
                   crabtab.tptabela = "GENERI"      AND
                   crabtab.cdempres = 00            AND
                   crabtab.cdacesso = "NRARQMVITG"  AND
                   crabtab.tpregist = 401           NO-ERROR NO-WAIT.
                   
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

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 501           NO-ERROR NO-WAIT.

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
ASSIGN aux_cdseqtab = INTEGER(SUBSTR(craptab.dstextab,01,05)).
  
/* pre-filtragem dos arquivos */
FOR EACH crawarq BREAK BY crawarq.nrsequen:
                    
    IF   LAST-OF(crawarq.nrsequen)   THEN
         DO:
            IF   crawarq.nrsequen = aux_cdseqtab   THEN
                 ASSIGN aux_cdseqtab = aux_cdseqtab + 1.
            ELSE
                 DO:
                     /* sequencia errada */
                     glb_cdcritic = 476.
                     RUN fontes/critic.p.

                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO501 - " + glb_cdprogra + 
                                       "' --> '"  +
                                       glb_dscritic + " " +
                                       "SEQ.BB " + STRING(crawarq.nrsequen) + 
                                       " " + "SEQ.COOP " + 
                                       STRING(aux_cdseqtab) + " - " +
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
                     
                     /* Copia para diretorio converte para utilizar na BO */
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
                                      '"COO501 - "' +
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
                           " - COO501 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN p_imprime_rejeitados.           /*  Imprime Relatorio com Criticas  */

RUN fontes/fimprg.p.

/* .......................................................................... */

PROCEDURE proc_processa_arquivo:

   DEF  VAR aux_qtregist AS INTEGER       INIT   0                NO-UNDO.
   DEF  VAR aux_nrdctitg AS INTEGER       FORMAT "9999999"        NO-UNDO.
                   
   DEF  VAR arq_nrdctitg LIKE crapass.nrdctitg                    NO-UNDO.
                        
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
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - COO501 - " + glb_cdprogra + "' --> '" +
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
                                      '"COO501 - "' + crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.
            
            RETURN.
        END.
 
   IF   INTEGER(SUBSTR(aux_setlinha,76,03)) <> 1 AND   /*  Processado     */
        INTEGER(SUBSTR(aux_setlinha,76,03)) <> 4 THEN  /*  Recusa Parcial */
        DO:
            ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_setlinha,76,03)).
            
            /*   Recusa Total do Arquivo  */
            IF   aux_cdocorre = 2   OR   /* Recusa total Header   */
                 aux_cdocorre = 3   OR   /* Recusa total Trailer  */
                 aux_cdocorre = 5   OR   /* Recusa total tipo reg.*/
                 aux_cdocorre = 6   OR   /* Recusa total seq.invalida */
                 aux_cdocorre = 8   THEN /* Recusa total Remessa inv. */
                 RUN p_recusa_total.

            INPUT STREAM str_2 CLOSE.
            
            aux_nmarquiv = "salvar/err" + SUBSTR(crawarq.nmarquiv,12,29).
            
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").

            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).

            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.
                 
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO501 - " + glb_cdprogra + 
                                       "' --> '" +
                                       glb_dscritic + " - " + 
                                       "RECUSA TOTAL - " +
                                       crawarq.nmarquiv +
                                       " >> " + aux_nmarqlog).
                 END.
            ELSE
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - COO501 - " + glb_cdprogra + 
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
                                      '"COO501 - "' + 
                                      crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarquiv,8),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.
            
            RETURN.
        END.         /*   Fim  da  Recusa  Total  */
   
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0
             aux_qtregist = aux_qtregist + 1.
      
      /*  Verifica se eh final do Arquivo  */
      IF   INTEGER(SUBSTR(aux_setlinha,01,05)) = 99999 THEN
           DO:
                /*   Conferir o total do arquivo   */
                IF   (aux_qtregist + 1) <> 
                     DECIMAL(SUBSTR(aux_setlinha,06,09)) THEN
                     DO:
                         ASSIGN glb_cdcritic = 504.
                         
                         RUN fontes/critic.p.

                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - COO501 - " + glb_cdprogra + 
                                           "' --> '" +
                                           glb_dscritic + 
                                           " - ARQUIVO PROCESSADO - " +
                                           aux_nmarquiv +
                                           " >> " + aux_nmarqlog).
                     END.
                LEAVE.
           END.

      /* Nro da conta de integracao */
      ASSIGN arq_nrdctitg = SUBSTR(aux_setlinha,13,07) + 
                            SUBSTR(aux_setlinha,20,01).
                            
      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdctitg = arq_nrdctitg NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO: 
               CREATE cratrej.
               ASSIGN cratrej.nrdctitg = arq_nrdctitg
                      cratrej.cdcritic = 09.
           END.
      ELSE
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
                      CREATE cratrej.
                      ASSIGN cratrej.cdagenci = crapass.cdagenci
                             cratrej.nrdctitg = arq_nrdctitg
                             cratrej.nrdconta = crapass.nrdconta
                             cratrej.cdcritic = 0
                             cratrej.dscritic = aux_dscritic.
                  END.
              ELSE
                  DO:
                      
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
                      
                      IF  crapass.flgctitg = 2 /** Cadastrada/Ativa **/   THEN
                          DO:
                          
                             FIND tt_tipos_conta WHERE tt_tipos_conta.inpessoa = crapass.inpessoa AND
                                                       tt_tipos_conta.cdtipcta = crapass.cdtipcta NO-LOCK NO-ERROR.

                             IF   NOT AVAILABLE tt_tipos_conta   THEN
                                  DO: 
                                      CREATE cratrej.
                                      ASSIGN cratrej.cdagenci = crapass.cdagenci
                                             cratrej.nrdctitg = crapass.nrdctitg
                                             cratrej.nrdconta = crapass.nrdconta
                                             cratrej.cdcritic = 17.
                                  END.
                             
                          END.
                  END.
           END.
           
      /* Se o registro foi recusado */
      IF   INT(SUBSTR(aux_setlinha,76,3)) <> 0   THEN
           DO:
               ASSIGN tot_qtdcriti = tot_qtdcriti + 1.
 
               CREATE cratrej.
               ASSIGN cratrej.cdagenci = crapass.cdagenci   WHEN AVAIL crapass
                      cratrej.nrdctitg = arq_nrdctitg
                      cratrej.nrdconta = crapass.nrdconta  WHEN AVAIL crapass
                      cratrej.cdcritic = INT(SUBSTR(aux_setlinha,76,3))
                      cratrej.dscritic = SUBSTR(aux_setlinha,79,120).
           END.

    END.  /*   Fim  do DO WHILE TRUE  */

    INPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
    
    UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
    
    DO TRANSACTION ON ENDKEY UNDO, LEAVE:

       /*   Atualiza a sequencia da remessa  */
       DO WHILE TRUE:

          FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                             craptab.nmsistem = "CRED"        AND
                             craptab.tptabela = "GENERI"      AND
                             craptab.cdempres = 00            AND
                             craptab.cdacesso = "NRARQMVITG"  AND
                             craptab.tpregist = 501
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craptab   THEN
               IF   LOCKED craptab   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 55.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " >> " + aux_nmarqlog).
                        LEAVE.
                    END.    
          ELSE
               glb_cdcritic = 0.

          LEAVE.
       
       END.  /*  Fim do DO .. TO  */

       IF   glb_cdcritic = 0     AND     /* se esta OK */
            aux_flaglast = YES   THEN    /* e eh o ultimo da sequencia */
            ASSIGN SUBSTRING(craptab.dstextab,1,5) = 
                             STRING(aux_cdseqtab, "99999"). 

    END. /* TRANSACTION */

END PROCEDURE.

PROCEDURE p_imprime_rejeitados:
   
   DEFINE VARIABLE rel_dsagenci AS CHAR       FORMAT "x(21)"          NO-UNDO.
   DEFINE VARIABLE aux_nmarqimp AS CHAR                               NO-UNDO.
   DEFINE VARIABLE aux_dtmvtopr AS DATE                               NO-UNDO.
   DEFINE VARIABLE aux_dscritic AS CHAR       FORMAT "x(65)"          NO-UNDO.

   FORM rel_dsagenci AT  1 FORMAT "x(21)" LABEL "AGENCIA"
        SKIP(1)
        WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_agencia.

   FORM cratrej.cdagenci AT 01 FORMAT "zz9"            LABEL "PA" 
        cratrej.nrdconta AT 06 FORMAT "zzzz,zzz,9"     LABEL "CONTA/DV"
        cratrej.nrdctitg AT 17 FORMAT "9.999.999-X"    LABEL "CONTA ITG."
        aux_dscritic     AT 57 FORMAT "x(65)"          LABEL "MOTIVO DA CRITICA"
        WITH NO-BOX NO-LABELS DOWN  WIDTH 133 FRAME f_descricao.

   FORM SKIP(1)
        "TOTAL  DE  REJEITADOS ==>"    AT  30
        tot_qtdcriti                   AT  67 FORMAT "zzz,zz9"
        SKIP(2)
        WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_age.

   { includes/cabrel132_1.i }  /*  Monta cabecalho do relatorio  */

   ASSIGN aux_nmarqimp = "rl/crrl385_" + STRING(TIME) + ".lst". 
          
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
             
   VIEW STREAM str_1 FRAME f_cabrel132_1.
   
   FOR EACH cratrej: 
        
       IF cratrej.dscritic = " " THEN
          DO:
             ASSIGN glb_cdcritic = cratrej.cdcritic.
               
             RUN fontes/critic.p.

             ASSIGN aux_dscritic = glb_dscritic.
          END.
      ELSE    
          ASSIGN  aux_dscritic = cratrej.dscritic.
       
       DISPLAY STREAM str_1 cratrej.cdagenci  cratrej.nrdconta  
                            cratrej.nrdctitg  aux_dscritic
                            WITH FRAME f_descricao.

       DOWN STREAM str_1 WITH FRAME f_descricao.
 
       IF   LINE-COUNTER(str_1) >= 83   THEN
            PAGE STREAM str_1.
       
   END.           /*   Fim  do  For Each   */
   
   DISPLAY STREAM str_1 tot_qtdcriti WITH FRAME f_total_age.

   OUTPUT STREAM str_1 CLOSE.
   
   ASSIGN glb_nrcopias = 1
          glb_nmformul = "132col"
          glb_nmarqimp = aux_nmarqimp.
       
   RUN fontes/imprim.p.
   
   /* se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" */
   IF   glb_inproces = 1   THEN
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv/" +
                          SUBSTRING(aux_nmarqimp,R-INDEX(aux_nmarqimp,"/") + 1,
                          LENGTH(aux_nmarqimp) - R-INDEX(aux_nmarqimp,"/"))).

END.   /*  fim da PROCEDURE  */

PROCEDURE p_recusa_total:

    /* Bloquear tabela de envio */
    ASSIGN SUBSTRING(crabtab.dstextab,1,7) = SUBSTR(aux_setlinha,39,05) + " 1".
    
    /* Deixar sequencia que estou processando arq.recebimento */
    ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(crawarq.nrsequen,"99999"). 
    
END.   /*   Fim da Procedure  */

/* ........................................................................ */
