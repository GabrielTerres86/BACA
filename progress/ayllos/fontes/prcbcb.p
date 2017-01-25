/* ...........................................................................

   Programa: fontes/prcbcb.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego  
   Data    : Marco/2007                        Ultima atualizacao: 06/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tela para solicitar os processos referentes BANCOOB, GERAR
               ARQUIVOS e PROCESSAR RETORNOS.

   Alteracoes: 27/04/2007 - Tratamento para importacao de arquivos CAF (David).
   
               25/07/2007 - Incluido geracao de arquivos e relatorios ICF,
                            referente ao inicio do relacionamento do cliente 
                            com a cooperativa (Elton).
               13/08/2007 - Incluido chamada da rotina de recebimento de 
                            informacoes financeiras - crps494 (Sidnei/Precise)

               01/10/2007 - Alterada mensagem de liberacao de operador
                            bloqueado (Evandro).

               10/07/2008 - Bancoob alterou nome do arquivo CAF (Magui).

               27/01/2009 - Retirada permissao do operadro 799 (Gabriel).
               
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               04/06/2010 - Remocao do RELACIONAMENTO e CAF pois serao 
                            processados na PRCCTL pela IF CECRED (Guilherme).
                            
               28/10/2010 - Alterado para validar senha atraves do fonte
                            pedesenha.p (Adriano).
                            
               05/11/2012 - Alterada a solicitação dos programas crps468
                            e crps469 de 199 para 201 (Lucas).
                            
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               06/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                            
               17/12/2013 - Inclusao de VALIDATE crapsol (Carlos)
               
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
                            
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
............................................................................. */

{ includes/var_online.i } 

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                         NO-UNDO.
DEF VAR aux_confirma AS CHAR     FORMAT "!"                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_ultlinha AS INT                                          NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.

DEF VAR aut_flgsenha AS LOGICAL                                      NO-UNDO.
DEF VAR aut_cdoperad AS CHAR                                         NO-UNDO.

DEF VAR tel_datadlog AS DATE     FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_cddopcao AS CHAR     FORMAT "!(1)"                       NO-UNDO.
DEF VAR tel_cdagenci AS INT      FORMAT "999"                        NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR     FORMAT "x(40)"                      NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmendter AS CHAR     FORMAT "x(20)"                      NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR tel_dsimprim AS CHAR     FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR     FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.


DEF TEMP-TABLE crawrel                                               NO-UNDO
    FIELD tprelato  AS CHAR     
    FIELD dsrelato  AS CHAR.

DEF QUERY q_relatorios   FOR crawrel.

DEF BROWSE b_relatorios QUERY q_relatorios
    DISPLAY crawrel.tprelato  COLUMN-LABEL "RELATORIO"  FORMAT "x(10)"
            crawrel.dsrelato  COLUMN-LABEL "DESCRICAO"  FORMAT "x(52)"
    WITH 7 DOWN WIDTH 74 TITLE "Relatorios Gerados".
    
FORM b_relatorios AT 3  HELP "Pressione ENTER para selecionar"
     SKIP(2)
     WITH NO-BOX ROW 8 COLUMN 2 OVERLAY FRAME f_relatorios.

DEF TEMP-TABLE crawarq                                               NO-UNDO
    FIELD tparquiv  AS CHAR  
    FIELD dsarquiv  AS CHAR.

DEF QUERY q_arquivos   FOR crawarq.

DEF BROWSE b_arquivos QUERY q_arquivos
    DISPLAY crawarq.tparquiv  COLUMN-LABEL "TIPO"       FORMAT "x(16)"
            crawarq.dsarquiv  COLUMN-LABEL "DESCRICAO"  FORMAT "x(50)"
    WITH 7 DOWN WIDTH 74 TITLE "Arquivos a serem gerados/processados".

            
FORM SKIP(1)
     glb_cddopcao AT 5 LABEL  "Opcao"
       HELP "Informe a opcao(G-Geracao/L-Log/P-Process./R-Relat.)"
                        VALIDATE(CAN-DO("G,L,P,R",glb_cddopcao),
                                "014 - Opcao errada.")
     tel_datadlog AT 30 LABEL "Data do Log"
                        HELP "Informe a data do log desejado"
     SKIP(1)
     b_arquivos   AT  3 HELP "Pressione DELETE para excluir / F4 para sair"
     SKIP(2)
     WITH ROW 4 OVERLAY SIDE-LABELS NO-LABELS WIDTH 80 TITLE glb_tldatela 
          FRAME f_prcbcb.
          
FORM SKIP(1)
     tel_cdagenci AT  14 FORMAT "999" LABEL "PA"
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY WIDTH 30
          TITLE " Imprimir " FRAME f_pac.


ON "DELETE" OF b_arquivos IN FRAME f_prcbcb DO:

    IF   NOT AVAILABLE crawarq   THEN
         RETURN.
             
    DELETE crawarq. 
        
    /* linha que foi deletada */
    aux_ultlinha = CURRENT-RESULT-ROW("q_arquivos").
    
    OPEN QUERY q_arquivos FOR EACH crawarq   BY crawarq.tparquiv.
    
    /* reposiciona o browse */
    REPOSITION q_arquivos TO ROW aux_ultlinha.
END.


ON RETURN OF b_relatorios 
   DO:
       IF   NOT AVAILABLE crawrel   THEN
            RETURN.
             
       MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.

       HIDE MESSAGE NO-PAUSE.       
                          
       UPDATE tel_cdagenci WITH FRAME f_pac.

       IF  tel_cdagenci <> 0  THEN
           ASSIGN aux_nmarqimp = "rl/" + LOWER(crawrel.tprelato) + "_" + 
                                 STRING(tel_cdagenci,"999") + ".lst".
       ELSE
           ASSIGN aux_nmarqimp = "rl/" + LOWER(crawrel.tprelato) + "_999.lst".
       

       IF   tel_cddopcao = "I" THEN
            DO:
                ASSIGN glb_nmarqimp = aux_nmarqimp
                       glb_nrdevias = 1.
                
                IF   crawrel.tprelato = "CRRL444"  THEN
                     ASSIGN glb_cdrelato = 444.
                ELSE
                   IF  crawrel.tprelato = "CRRL445" THEN
                       ASSIGN  glb_cdrelato = 445.
                   ELSE
                       IF  crawrel.tprelato = "CRRL459" THEN
                           ASSIGN  glb_cdrelato = 459.
                       ELSE
                           ASSIGN  glb_cdrelato = 461.
            
                /* somente para a includes/impressao.i */
                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                         NO-LOCK NO-ERROR.
                                    
                { includes/impressao.i }  
            END.    
       ELSE
       IF   tel_cddopcao = "T" THEN
            DO:
                HIDE FRAME f_relatorios.
                RUN fontes/visrel.p (INPUT aux_nmarqimp). 
            END.
        
       APPLY "GO".

   END.


/* Verifica se o arquivo pode ser gerado */
FUNCTION verifica_horario RETURNS LOGICAL (INPUT par_tparquiv AS INT):

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper        AND 
                       craptab.nmsistem = "CRED"              AND
                       craptab.tptabela = "GENERI"            AND
                       craptab.cdempres = 00                  AND
                       craptab.cdacesso = "NRARQMVBCB"        AND
                       craptab.tpregist = par_tparquiv        NO-LOCK NO-ERROR.

    IF  (NOT AVAILABLE craptab                                    OR
         STRING(TIME,"HH:MM") > SUBSTRING(craptab.dstextab,9,5))  AND
         glb_cddepart <> 20 THEN /* TI */
         RETURN FALSE.
    ELSE
         RETURN TRUE.

END FUNCTION.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

ASSIGN glb_cdcritic = 0
       glb_cddopcao = "P".    /* PROCESSAMENTO */
        
/* Somente um usuario pode usar a tela ao mesmo tempo */
DO WHILE TRUE:
   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper        AND 
                      craptab.nmsistem = "CRED"              AND
                      craptab.tptabela = "GENERI"            AND
                      craptab.cdempres = 00                  AND
                      craptab.cdacesso = "NRARQMVBCB"        AND
                      craptab.tpregist = 0                   NO-LOCK NO-ERROR.
   IF   craptab.dstextab <> ""   THEN
        DO:
            HIDE MESSAGE.
            MESSAGE "Esta tela esta sendo usada pelo operador"
                    craptab.dstextab.
        
            /* Verifica se o operador que esta usando a tela eh o mesmo que
               esta tentando acessar */
            IF   glb_cdoperad <> SUBSTRING(craptab.dstextab,1,10)   THEN
                 DO:
                     MESSAGE "Peca a liberacao ao Coordenador/Gerente...".
                     PAUSE 2 NO-MESSAGE.

                     /* necessita da senha do coordenador/gerente */
                     RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                             INPUT 2,
                                             OUTPUT aut_flgsenha,
                                             OUTPUT aut_cdoperad).
                                          
                     IF   aut_flgsenha   THEN
                          LEAVE.
                 END.
            ELSE
                 DO:
                     MESSAGE "Aguarde ou pressione F4/END para sair...".
                     READKEY PAUSE 2.
                 END.
                 
            IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    /* Forca a saida para a tela do MENU */
                    glb_nmdatela = "".
                    RETURN.
                 END.

            NEXT.
        END.   
   ELSE
        DO TRANSACTION:
            FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.
            
            IF   AVAILABLE craptab   THEN
                 craptab.dstextab = STRING(glb_cdoperad,"x(10)") + "-" +
                                    glb_nmoperad.
                 
            RELEASE craptab.
            HIDE MESSAGE.
        END. 

   LEAVE.
   
END. /* Fim do DO WHILE */        

DO WHILE TRUE:  

   HIDE b_arquivos   IN FRAME f_prcbcb.
   HIDE tel_datadlog IN FRAME f_prcbcb.
   
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao WITH FRAME f_prcbcb.
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PRCBCB"   THEN
                 DO:
                     DO TRANSACTION:
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                           craptab.nmsistem = "CRED"        AND
                                           craptab.tptabela = "GENERI"      AND
                                           craptab.cdempres = 00            AND
                                           craptab.cdacesso = "NRARQMVBCB"  AND
                                           craptab.tpregist = 0
                                           EXCLUSIVE-LOCK NO-ERROR.
            
                        IF   AVAILABLE craptab   THEN
                             craptab.dstextab = "".
                     END. 

                     HIDE FRAME f_prcbcb.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.                                 
   
   IF   glb_cddopcao = "G"   THEN
        RUN carrega_tabela_geracao.
   ELSE
   IF   glb_cddopcao = "P"   THEN    
        RUN carrega_tabela_retorno.
   ELSE   
   IF   glb_cddopcao = "L"   THEN
        DO:
            RUN opcao_l.
            NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN
        DO:
            RUN opcao_r.
            NEXT.
        END.
   ELSE   
        NEXT.

   /* as opcoes G e P entram aqui, as outras executam NEXT */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
      OPEN QUERY q_arquivos FOR EACH crawarq   BY crawarq.tparquiv.
      UPDATE b_arquivos WITH FRAME f_prcbcb.
      LEAVE.
   END.

   /* pede confirmacao */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.
                             
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S" THEN
        DO:
           glb_cdcritic = 79.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           glb_cdcritic = 0.
           CLOSE QUERY q_arquivos. 
           NEXT.
        END.

   CLOSE QUERY q_arquivos.

   FIND FIRST crawarq NO-LOCK NO-ERROR.
   
   IF   AVAILABLE crawarq   THEN
        RUN executa.
   ElSE
        DO:
            glb_cdcritic = 239.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

END.  /* fim DO WHILE TRUE */

PROCEDURE carrega_tabela_retorno.

    EMPTY TEMP-TABLE crawarq.
   
    /****** carregar arquivos de retorno ********/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/bancoob/*RET_*".
            
    INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                       NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .
       
       /* Verifica se o arquivo esta vazio e o remove */
       INPUT STREAM str_2 THROUGH VALUE( "wc -m " + aux_nmarquiv + 
                                         " 2> /dev/null") NO-ECHO.
                                                  
       SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
             
       IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
            DO:
                UNIX SILENT VALUE("rm " + aux_nmarquiv + 
                                  " 2> /dev/null").
                INPUT STREAM str_2 CLOSE.
                NEXT.
            END.

       INPUT STREAM str_2 CLOSE.
                
       IF   aux_nmarquiv MATCHES "*RET_BCB_CCF*"  THEN
            DO TRANSACTION:
               CREATE crawarq.
               ASSIGN crawarq.tparquiv = "RET_CCF"
                      crawarq.dsarquiv = "RETORNO DE INCLUSAO/EXCLUSAO DO CCF".
            END.
                
       IF   aux_nmarquiv MATCHES "*RET_BCB_CONTRA*"  THEN
            DO TRANSACTION:
               CREATE crawarq. 
               ASSIGN crawarq.tparquiv = "RET_CONTRA_ORDEM"
                      crawarq.dsarquiv =
                                "RETORNO DE INCLUSAO/EXCLUSAO DE CONTRA-ORDEM".
            END.
                     
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.

    /********** carregar arquivos de informacoes financeiras *****/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/bancoob/6" + STRING(crapcop.cdagebcb) + 
                          "*.RT*".

    INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                       NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .
       
       /* Verifica se o arquivo esta vazio e o remove */
       INPUT STREAM str_2 THROUGH VALUE( "wc -m " + aux_nmarquiv + 
                                         " 2> /dev/null") NO-ECHO.
                                                  
       SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
             
       IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
            DO:
                UNIX SILENT VALUE("rm " + aux_nmarquiv + 
                                  " 2> /dev/null").
                INPUT STREAM str_2 CLOSE.
                NEXT.
            END.

       INPUT STREAM str_2 CLOSE.
                
       DO TRANSACTION:
          CREATE crawarq.
          ASSIGN crawarq.tparquiv = "RET_RELACIONAMEN"
                 crawarq.dsarquiv = "RECEB. ARQUIVO DE RELACION. " + 
                                    "DO CLIENTE COM O BANCO".
       END.
       
       LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
  

END PROCEDURE.

PROCEDURE carrega_tabela_geracao:

    DEF VAR aux_contador AS INT                                     NO-UNDO.
    
    /* limpa a tabela */
    EMPTY TEMP-TABLE crawarq.
    
    DO aux_contador = 1 TO 2 TRANSACTION:     

       CREATE crawarq.
       
       IF   aux_contador = 1        AND
            verifica_horario(01)   THEN
            ASSIGN crawarq.tparquiv = "CCF"
                   crawarq.dsarquiv =
                                   "GERAR ARQUIVO DE INCLUSAO/EXCLUSAO DO CCF".
       ELSE
       IF   aux_contador = 2        AND
            verifica_horario(02)   THEN
            ASSIGN crawarq.tparquiv = "CONTRA-ORDEM"
                   crawarq.dsarquiv =
                          "GERAR ARQUIVO DE INCLUSAO/EXCLUSAO DE CONTRA-ORDEM".
       
       IF   crawarq.tparquiv = ""   THEN
            DELETE crawarq.
            
    END.   /* fim DO */
   
END PROCEDURE.

PROCEDURE executa:

    /* Limpa as solicitacoes */
    DO TRANSACTION:

       FIND FIRST crawarq WHERE (crawarq.tparquiv = "CCF"           OR
                                 crawarq.tparquiv = "CONTRA-ORDEM"  )
                                 NO-LOCK NO-ERROR.

       IF  AVAIL crawarq THEN
           DO:
               FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                     crapsol.nrsolici = 201            AND
                                     crapsol.dtrefere = glb_dtmvtolt   
                                     NO-LOCK NO-ERROR.

               IF  AVAILABLE crapsol   THEN
                   DO:
                       FIND CURRENT crapsol EXCLUSIVE-LOCK.
                     
                       DELETE crapsol.
                   END.
           END.
    END.


    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 199            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.
    
    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 200            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.

    DO TRANSACTION:

        FIND FIRST crawarq WHERE (crawarq.tparquiv = "CCF"           OR
                                  crawarq.tparquiv = "CONTRA-ORDEM"  )
                                  NO-LOCK NO-ERROR.

            IF  AVAIL crawarq THEN
                DO:
                    /* cria a solicitacao --> 201 para GERACAO de arquivos */
                    CREATE crapsol. 
                    ASSIGN crapsol.nrsolici = 201
                           crapsol.dtrefere = glb_dtmvtolt
                           crapsol.nrseqsol = 1
                           crapsol.cdempres = 11
                           crapsol.dsparame = ""
                           crapsol.insitsol = 1
                           crapsol.nrdevias = 0
                           crapsol.cdcooper = glb_cdcooper.
                    VALIDATE crapsol.
                END.
            ELSE
                DO:
                    /* cria a solicitacao --> 199 para GERACAO de arquivos */
                    CREATE crapsol. 
                    ASSIGN crapsol.nrsolici = 199
                           crapsol.dtrefere = glb_dtmvtolt
                           crapsol.nrseqsol = 1
                           crapsol.cdempres = 11
                           crapsol.dsparame = ""
                           crapsol.insitsol = 1
                           crapsol.nrdevias = 0
                           crapsol.cdcooper = glb_cdcooper.
                    VALIDATE crapsol.

                    /* cria a solicitacao --> 200 se for P - PROCESSAMENTO */
                    IF   glb_cddopcao = "P"   THEN
                         DO:
                            CREATE crapsol. 
                            ASSIGN crapsol.nrsolici = 200
                                   crapsol.dtrefere = glb_dtmvtolt
                                   crapsol.nrseqsol = 1
                                   crapsol.cdempres = 11
                                   crapsol.dsparame = ""
                                   crapsol.insitsol = 1
                                   crapsol.nrdevias = 0
                                   crapsol.cdcooper = glb_cdcooper.
                            VALIDATE crapsol.

                         END.
                         
                END.
       
    END. /* Fim TRANSACTION */
           
    FOR EACH crawarq BY crawarq.tparquiv:
        MESSAGE "Aguarde... Gerando/Processando Arquivos (" crawarq.tparquiv
                ")...".

        CASE crawarq.tparquiv:
             /* programas de geracao */
             WHEN "CCF"              THEN  RUN fontes/crps468.p.  
             WHEN "CONTRA-ORDEM"     THEN  RUN fontes/crps469.p.

             /* programas de retornos */
             WHEN "RET_CCF"          THEN  RUN fontes/crps470.p.  
             WHEN "RET_CONTRA_ORDEM" THEN  RUN fontes/crps471.p. 
             WHEN "RET_RELACIONAMEN" THEN  RUN fontes/crps494.p.
        END CASE.
    END.

    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 200            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.
    
    /* Limpa as solicitacoes */
    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 199             AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.
    
    DO TRANSACTION:

        FIND FIRST crawarq WHERE (crawarq.tparquiv = "CCF"           OR
                                  crawarq.tparquiv = "CONTRA-ORDEM"  )
                                  NO-LOCK NO-ERROR.

        IF  AVAIL crawarq THEN
            DO:
                FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                         crapsol.nrsolici = 201            AND
                                         crapsol.dtrefere = glb_dtmvtolt   
                                         NO-LOCK NO-ERROR.
                                         
                IF   AVAILABLE crapsol   THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         
                         DELETE crapsol.
                     END.
            END.
    END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       MESSAGE "ATENCAO! Verifique a GERIMP!".
       PAUSE(5) NO-MESSAGE.    
       HIDE MESSAGE NO-PAUSE.
       LEAVE.
    END.

END PROCEDURE.  

PROCEDURE opcao_l:
          
    ASSIGN tel_datadlog = glb_dtmvtolt.
    
    UPDATE tel_datadlog WITH FRAME f_prcbcb.
    
    ASSIGN aux_nmarqimp = "log/prcbcb_" + STRING(YEAR(tel_datadlog),"9999") + 
                          STRING(MONTH(tel_datadlog),"99") + 
                          STRING(DAY(tel_datadlog),"99") + ".log".
                          
    IF   SEARCH(aux_nmarqimp) = ?   THEN
         DO:
             MESSAGE "!!NAO EXISTEM PENDENCIAS ATE O MOMENTO!!".
             PAUSE 2 NO-MESSAGE.
             RETURN.
         END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
    
       IF   tel_cddopcao = "T"   THEN
            RUN fontes/visrel.p (INPUT aux_nmarqimp).
       ELSE
       IF   tel_cddopcao = "I"   THEN
            DO:
                /* somente para o includes/impressao.i */
                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                         NO-LOCK NO-ERROR.
                
                { includes/impressao.i }
            END.
       ELSE
            DO: 
               glb_cdcritic = 14.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
            END.
       
       LEAVE.
    END.

END PROCEDURE.


PROCEDURE opcao_r:
    
    EMPTY TEMP-TABLE crawrel.
    
    ASSIGN aux_nmarquiv = "rl/crrl4*.lst".
    
    INPUT STREAM str_1 
             THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
    
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

       /* Verifica se o arquivo esta vazio*/
       INPUT STREAM str_2 THROUGH VALUE( "wc -m " + aux_nmarquiv + 
                                         " 2> /dev/null") NO-ECHO.
                                                  
       SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
                
       IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
            DO:
                INPUT STREAM str_2 CLOSE.
                NEXT.
            END.

       INPUT STREAM str_2 CLOSE.

       IF   SUBSTRING(aux_nmarquiv,INDEX(aux_nmarquiv,"crrl"),7) <> "crrl444"
            AND
            SUBSTRING(aux_nmarquiv,INDEX(aux_nmarquiv,"crrl"),7) <> "crrl445"
            AND 
            SUBSTRING(aux_nmarquiv,INDEX(aux_nmarquiv,"crrl"),7) <> "crrl459"
            AND 
            SUBSTRING(aux_nmarquiv,INDEX(aux_nmarquiv,"crrl"),7) <> "crrl461"               THEN
            NEXT.
            
       FIND FIRST crawrel WHERE 
                  crawrel.tprelato = CAPS(SUBSTRING(aux_nmarquiv,
                                             INDEX(aux_nmarquiv,"crrl"),7))
                  NO-LOCK NO-ERROR.
                               
       IF   NOT AVAIL crawrel  THEN
            DO:
                CREATE crawrel.
                ASSIGN crawrel.tprelato = CAPS(SUBSTRING(aux_nmarquiv,
                                               INDEX(aux_nmarquiv,"crrl"),7)).
                      
                IF   crawrel.tprelato = "CRRL444"  THEN
                     crawrel.dsrelato =  "ENVIO ARQUIVO INCLUSAO/EXCLUSAO CCF".
                ELSE
                IF   crawrel.tprelato = "CRRL445" THEN
                     crawrel.dsrelato =  
                             "ENVIO ARQUIVO INCLUSAO/EXCLUSAO CONTRA-ORDENS".
                ELSE
                     crawrel.dsrelato = 
                             "RECEB ARQUIVO DE RELACIONAMENTO COM BANCO".
            END.               
            

    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
       OPEN QUERY q_relatorios FOR EACH crawrel   BY crawrel.tprelato.
       UPDATE b_relatorios WITH FRAME f_relatorios.
       LEAVE.
    END.

END PROCEDURE.



/* .......................................................................... */
