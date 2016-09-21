/* ............................................................................

   Programa: Fontes/crps625.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos/Supero
   Data    : Agosto/2012                        Ultima atualizacao: 12/08/2014.

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar/Gerar arquivos TIC
               Recebe arquivo TIC614 gera TIC606

   Alteracoes: 13/08/2012 - Primeira Versao
   
               24/10/2012 - Alterar Agencia Apresentante para Depositante (Ze).
               
               25/02/2013 - Alterado estrutura da procedure p_elimina_tic.
                            (Fabricio)
                            
               12/08/2014 - Ajustes na geracao do arquivo TIC606 para 
                            tratar a Unificacao das SIRC's; 018.
                            (Chamado 146058) - (Fabricio)
............................................................................ */

DEF STREAM str_1.   /*  Para importacao  */
DEF STREAM str_2.   /*  Para geracao   */

{ includes/var_batch.i }  

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tab_nmarqtel AS CHAR    FORMAT "x(25)" EXTENT 99      NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(210)"               NO-UNDO.
DEF        VAR aux_contareg AS INT                                   NO-UNDO.
DEF        VAR aux_qttotlot AS INT                                   NO-UNDO.
DEF        VAR aux_vltolarq AS DECI                                  NO-UNDO.
DEF        VAR aux_vltotlot AS DECI                                  NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.

DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_cdocorre AS INT                                   NO-UNDO.
DEF        VAR aux_cdtipdoc AS INT                                   NO-UNDO.
DEF        VAR aux_cdbanapr AS INT                                   NO-UNDO.
DEF        VAR aux_cdageapr AS INT                                   NO-UNDO.
DEF        VAR aux_nrctaapr LIKE craplcm.nrctachq                    NO-UNDO.
DEF        VAR aux_dircoper AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR       FORMAT "x(20)"             NO-UNDO.
DEF        VAR aux_mes      AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsdocmc7 AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtlibtic AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.

DEF        VAR aux_dtauxili AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtretarq AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtanmarq AS DATE                                  NO-UNDO.
DEF        VAR aux_dslibchq AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdbanchq LIKE craplcm.cdbanchq                    NO-UNDO.
DEF        VAR aux_cdcmpchq LIKE craplcm.cdcmpchq                    NO-UNDO.
DEF        VAR aux_cdagechq LIKE craplcm.cdagechq                    NO-UNDO.
DEF        VAR aux_nrctachq LIKE craplcm.nrctachq                    NO-UNDO.
DEF        VAR aux_flgdsede AS INT                                   NO-UNDO.

DEF TEMP-TABLE tt-tic606-dados
         FIELD nrsequen AS INT 
         FIELD dsdlinha AS CHAR
         FIELD cdocorre AS INT
         FIELD dsdocmc7 AS CHAR
         FIELD cdcmpdes AS INT
         FIELD cdbcodes AS INT
         FIELD cdtipdoc AS INT
         FIELD cdcomchq AS INT
         FIELD cdbcoctl AS INT.

DEF TEMP-TABLE tt-tic606
         FIELD nrsequen AS INT 
         FIELD dsdlinha AS CHAR.

FORM aux_setlinha  FORMAT "x(210)"
     WITH FRAME AA WIDTH 170 NO-BOX NO-LABELS.

ASSIGN glb_cdprogra = "crps625"
       glb_flgbatch = FALSE.

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
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

FIND FIRST crapage WHERE crapage.cdcooper = glb_cdcooper AND
                         crapage.flgdsede = TRUE 
                         NO-LOCK NO-ERROR.
                         
IF   NOT AVAILABLE crapage THEN
     aux_flgdsede = 16.
ELSE
     aux_flgdsede = crapage.cdcomchq.
     
/*  Fim da verificacao se deve executar */
IF   glb_nmtelant = "COMPEFORA" THEN
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtoan),"9999") +
                           STRING(MONTH(glb_dtmvtoan),"99") +
                           STRING(DAY(glb_dtmvtoan),"99")
            aux_dtmvtolt = glb_dtmvtoan
            aux_dtretarq = STRING(YEAR(glb_dtmvtolt),"9999") +
                           STRING(MONTH(glb_dtmvtolt),"99") +
                           STRING(DAY(glb_dtmvtolt),"99")
            aux_dtanmarq = glb_dtmvtolt.
ELSE
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtolt),"9999") +
                           STRING(MONTH(glb_dtmvtolt),"99") +
                           STRING(DAY(glb_dtmvtolt),"99")
            aux_dtmvtolt = glb_dtmvtolt
            aux_dtretarq = STRING(YEAR(glb_dtmvtopr),"9999") +
                           STRING(MONTH(glb_dtmvtopr),"99") +
                           STRING(DAY(glb_dtmvtopr),"99")
            aux_dtanmarq = glb_dtmvtopr.

IF   MONTH(aux_dtmvtolt) > 9 THEN
     CASE MONTH(aux_dtmvtolt):

         WHEN 10 THEN aux_mes = "O".
         WHEN 11 THEN aux_mes = "N".
         WHEN 12 THEN aux_mes = "D".

     END CASE.
ELSE
    aux_mes = STRING(MONTH(aux_dtmvtolt),"9").

/* Nome do arq de origem*/
ASSIGN aux_nmarquiv = "integra/1" + STRING(crapcop.cdagectl,"9999") +
                      aux_mes + STRING(DAY(aux_dtmvtolt),"99") + ".CSN"
       aux_contador = 0.                

/* Remove os arquivos ".q" caso existam */
UNIX SILENT VALUE("rm " + aux_nmarquiv + ".q 2> /dev/null").

/* Listar o nome do arquivo caso exista*/
INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.

/*Lê o conteudo do diretorio*/
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                     aux_nmarquiv + ".q 2> /dev/null") .

   /* Gravando a qtd de arquivos processados */
   ASSIGN aux_contador               = aux_contador + 1
          tab_nmarqtel[aux_contador] = aux_nmarquiv.

END. /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

/* Se não houver arquivos para processar */
IF   aux_contador = 0 THEN
     DO:
         RUN p_elimina_tic.
         
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         RETURN.
     END.

/* Variavel de contador trouxe arquivos */
DO  i = 1 TO aux_contador:

    /* Leitura da linha do header */
    INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

    SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 210.

    IF   SUBSTR(aux_setlinha,1,10) <> "0000000000"  THEN /* Const = 0 */
         glb_cdcritic = 468.
    ELSE
    IF   SUBSTR(aux_setlinha,48,6) <> "TIC614" THEN  /* Const = 'TIC614' */
         glb_cdcritic = 173.
    ELSE    
    IF   INT(SUBSTR(aux_setlinha,61,3)) <> crapcop.cdbcoctl THEN 
         glb_cdcritic = 057.
    ELSE
    IF   SUBSTR(aux_setlinha,66,08) <> aux_dtauxili THEN
         glb_cdcritic = 013.

    IF   glb_cdcritic <> 0 THEN
         DO:
             INPUT STREAM str_2 CLOSE.
             RUN fontes/critic.p.
             aux_nmarquiv = "integra/err" + SUBSTR(tab_nmarqtel[i],12,29).
             UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").
             UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " " + aux_nmarquiv).
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic + " " +
                               aux_nmarquiv + " >> log/proc_batch.log").
             glb_cdcritic = 0.
             NEXT.
    END.

    aux_contareg = 1.

    /* Linha Cabeçalho */
    CREATE tt-tic606.
    ASSIGN tt-tic606.nrsequen = aux_contareg
           tt-tic606.dsdlinha = aux_setlinha.

    /* Fim Leitura header */
    INPUT STREAM str_2 CLOSE.

    glb_cdcritic = 219.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra +
                      "' --> '" + glb_dscritic + "' --> '" + tab_nmarqtel[i] +
                      " >> log/proc_batch.log").

    glb_cdcritic = 0.

    INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

    /* Detalhe */
    SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 210.

    TRANS_1:

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                              ON ERROR UNDO TRANS_1, LEAVE TRANS_1:

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 210.

       aux_nrseqarq = INT(SUBSTR(aux_setlinha,151,10)) + aux_contareg.
       
       IF   aux_nrseqarq <= glb_nrctares THEN
            NEXT.

       /* Verificando se é a ultima linha do arquivo Trailler */
       IF   SUBSTR(aux_setlinha,1,10) = "9999999999" THEN
            DO:
               /* tt-tic606 */
               CREATE tt-tic606.
               ASSIGN tt-tic606.nrsequen = 999999
                      tt-tic606.dsdlinha = aux_setlinha.

               LEAVE TRANS_1.
       END. /* Fim do IF da verificação arquivo */

       /* Atribuição das Variaveis */
       ASSIGN aux_nrdocmto = INT(SUBSTR(aux_setlinha,25,6)) /* Nro docmto  */
              aux_nrseqarq = INT(SUBSTR(aux_setlinha,151,10))/* Seq Arquiv */  
              aux_cdbanchq = INT(SUBSTR(aux_setlinha,4,3))   /* Nr Bco Chq */
              aux_cdcmpchq = INT(SUBSTR(aux_setlinha,1,3))   /* Nro compe  */
              aux_cdagechq = INT(SUBSTR(aux_setlinha,7,4))   /* Age dest   */
              aux_nrctachq = DEC(SUBSTR(aux_setlinha,12,12)) /* Nr ctachq  */
              aux_cdtipdoc = INT(SUBSTR(aux_setlinha,148,3)) /* NR TD   */
              aux_cdbanapr = INT(SUBSTR(aux_setlinha,56,3))  /* NRO Bco apr */
              aux_cdageapr = INT(SUBSTR(aux_setlinha,63,4))  /* NR Agen dep */
              aux_nrctaapr = DEC(SUBSTR(aux_setlinha,67,12)) /* Nro ctachq  */
              aux_dtlibtic = DATE(INT(SUBSTRING(aux_setlinha,135,2)),
                                  INT(SUBSTRING(aux_setlinha,137,2)),
                                  INT(SUBSTRING(aux_setlinha,131,4)))
              aux_cdocorre = 0
              aux_dsdocmc7 = ""
              NO-ERROR.

       IF   ERROR-STATUS:ERROR   THEN
            DO:
                glb_cdcritic = 86.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")   +
                                  " - "   + glb_cdprogra + "' --> '"  +
                                  glb_dscritic  + " "                 +
                                  STRING(aux_nrseqarq,"zzzz,zz9")     +
                                  " >> log/proc_batch.log").
                glb_cdcritic = 0.
                NEXT TRANS_1.
            END.

       IF  aux_cdtipdoc = 960 THEN 
           DO: /* Inclusao */

               FIND crapfdc WHERE 
                    crapfdc.cdcooper = glb_cdcooper AND
                    crapfdc.cdbanchq = aux_cdbanchq AND /* Nr Bco   */
                    crapfdc.cdagechq = aux_cdagechq AND /* Age dest */
                    crapfdc.nrctachq = aux_nrctachq AND /* Nr ctachq*/
                    crapfdc.nrcheque = aux_nrdocmto     /* Nro chq  */
                    EXCLUSIVE-LOCK NO-ERROR.

               IF   AVAIL crapfdc THEN
                    DO:
                        /* Ocorrencia 02 */
                        IF   crapfdc.incheque = 8 THEN
                             ASSIGN aux_cdocorre = 2.
                        ELSE
                        /* Ocorrencia 10 */
                        IF   crapfdc.dtliqchq <> ? AND 
                             crapfdc.incheque = 5  THEN
                             ASSIGN aux_cdocorre = 10.
                        ELSE
                        /* Ocorrencia 07 */
                        IF   (crapfdc.cdbantic <> 0             AND
                              crapfdc.cdagetic <> 0             AND
                              crapfdc.nrctatic <> 0)            AND
                             (crapfdc.cdbantic <> aux_cdbanapr  AND
                              crapfdc.cdagetic <> aux_cdageapr  AND
                              crapfdc.nrctatic <> aux_nrctaapr) THEN
                              ASSIGN aux_cdocorre = 7.
                        ELSE
                             DO:
                                 /* Ocorrencia 04 e 05 */
                                 FIND crapcor WHERE 
                                      crapcor.cdcooper = glb_cdcooper     AND
                                      crapcor.cdbanchq = crapfdc.cdbanchq AND
                                      crapcor.cdagechq = crapfdc.cdagechq AND
                                      crapcor.nrctachq = crapfdc.nrctachq AND
                                      crapcor.nrcheque = aux_nrdocmto     AND
                                      crapcor.flgativo = TRUE
                                      USE-INDEX crapcor1 NO-LOCK NO-ERROR.
                 
                                 IF   AVAILABLE crapcor THEN 
                                      DO:
                                          IF   crapcor.cdhistor = 818 OR
                                               crapcor.cdhistor = 835 THEN
                                               aux_cdocorre = 4. /* Ocorr. 4 */
                                          ELSE 
                                          IF   crapcor.cdhistor = 821 THEN
                                               aux_cdocorre = 5. /* Ocorr. 5 */
                                      END.
                             END.
          
                        /* Atualiza Valores do TIC*/
                        IF  aux_cdocorre = 0 THEN
                            ASSIGN crapfdc.cdbantic = aux_cdbanapr  
                                   crapfdc.cdagetic = aux_cdageapr 
                                   crapfdc.nrctatic = aux_nrctaapr
                                   crapfdc.dtlibtic = aux_dtlibtic
                                   crapfdc.dtatutic = aux_dtmvtolt.    
 
                        ASSIGN aux_dsdocmc7 = crapfdc.dsdocmc7.
                    END.
               ELSE
                    DO:
                        /* Ocorrencia 11 */
                         ASSIGN aux_cdocorre = 11
                                aux_dsdocmc7 = "0".
                        
                        /* Ocorrencia 06 */ 
                        IF   crapcop.cdbcoctl = aux_cdbanchq AND
                             crapcop.cdagectl = aux_cdagechq THEN
                             DO:
                                 FIND crapass WHERE 
                                      crapass.cdcooper = glb_cdcooper AND
                                      crapass.nrdconta = INT(aux_nrctachq)
                                      NO-LOCK NO-ERROR.

                                 IF  NOT AVAIlABLE crapass THEN
                                     ASSIGN aux_cdocorre = 6.
                             END.
                        ELSE
                             ASSIGN aux_cdocorre = 6.
                    END.
                          
           END. /* End do Inclusao */
       ELSE
       IF  aux_cdtipdoc = 966 THEN 
           DO: /* Exclusao */

               FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                  crapfdc.cdbanchq = aux_cdbanchq AND 
                                  crapfdc.cdagechq = aux_cdagechq AND 
                                  crapfdc.nrctachq = aux_nrctachq AND 
                                  crapfdc.nrcheque = aux_nrdocmto
                                  EXCLUSIVE-LOCK NO-ERROR.

               IF   AVAIL crapfdc THEN
                    DO:
                        /* Ocorrencia 9 */
                        IF   crapfdc.cdbantic = 0  AND
                             crapfdc.cdagetic = 0  AND
                             crapfdc.nrctatic = 0  THEN 
                             ASSIGN aux_cdocorre = 9.
                        ELSE 
                             DO:
                                 /* Ocorrencia 07 */
                                 IF   crapfdc.cdbantic <> aux_cdbanapr  AND
                                      crapfdc.cdagetic <> aux_cdageapr  AND
                                      crapfdc.nrctatic <> aux_nrctaapr  THEN
                                      ASSIGN aux_cdocorre = 7.
                                 ELSE
                                     /* Atualiza Valores do TIC */
                                     IF  aux_cdocorre = 0 THEN
                                         ASSIGN crapfdc.cdbantic = 0
                                                crapfdc.cdagetic = 0
                                                crapfdc.nrctatic = 0
                                                crapfdc.dtlibtic = ?
                                                crapfdc.dtatutic = ?.   
                             END.

                        ASSIGN aux_dsdocmc7 = crapfdc.dsdocmc7.
                    END.
               ELSE   
                    /* Ocorrencia 11 */
                    ASSIGN aux_cdocorre = 11
                           aux_dsdocmc7 = "0".

           END. /* End do Exclusao */
       ELSE
           NEXT. /* Desconsidera todos os outros tipos de TD */
           

       IF   aux_cdocorre <> 0 THEN
            DO:
                ASSIGN aux_dslibchq = SUBSTR(aux_setlinha,131,8).
                
                /*  Rejeita registro caso a data de lib. for menor que o 
                    dia do movimento */
                IF   DEC(aux_dslibchq) < DEC(aux_dtretarq) THEN
                     NEXT.
                
                /*tt-tic606 linha detalhes */
                CREATE tt-tic606-dados.
                ASSIGN tt-tic606-dados.nrsequen = 
                                       INT(SUBSTR(aux_setlinha,151,10))
                       tt-tic606-dados.dsdlinha = aux_setlinha
                       tt-tic606-dados.cdocorre = aux_cdocorre
                       tt-tic606-dados.dsdocmc7 = aux_dsdocmc7
                       tt-tic606-dados.cdcmpdes = 
                                       INT(SUBSTR(aux_setlinha,79,3))
                       tt-tic606-dados.cdbcodes =
                                       INT(SUBSTR(aux_setlinha,56,3))
                       tt-tic606-dados.cdtipdoc = 968
                       tt-tic606-dados.cdcomchq = aux_flgdsede
                       tt-tic606-dados.cdbcoctl = crapcop.cdbcoctl.
       END.
       
    END. /* FIM do DO WHILE TRUE TRANSACTION */


    glb_cdcritic = 190.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra +
                      "' --> '" + glb_dscritic + "' --> '" + tab_nmarqtel[i] +
                      " >> log/proc_batch.log").
    glb_cdcritic = 0.

    INPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " salvar").
    UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").

    
    /* Geração do arquivo */ 
    ASSIGN aux_dircoper = "/usr/coop/" + crapcop.dsdircop + "/".

    /* Remove os arquivos temporarios */
    UNIX SILENT VALUE("rm " + aux_dircoper + "arq/1*.CSD 2>/dev/null").

    IF   MONTH(aux_dtanmarq) > 9 THEN
         CASE MONTH(aux_dtanmarq):

              WHEN 10 THEN aux_mes = "O".
              WHEN 11 THEN aux_mes = "N".
              WHEN 12 THEN aux_mes = "D".

         END CASE.
    ELSE
         aux_mes = STRING(MONTH(aux_dtanmarq),"9").
        
    /* Nome do Arquivo */
    ASSIGN aux_nmarqdat = "1" + STRING(crapcop.cdagectl,"9999") +
                           aux_mes + STRING(DAY(aux_dtanmarq),"99") + ".CSD" .
     
    /* Verifica se existe */ 
    IF  SEARCH(aux_dircoper + "arq/" + aux_nmarqdat) <> ? THEN
        DO:
            BELL.
            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Arquivo ja existe: " + aux_dircoper + "arq/" aux_nmarqdat.
        END.


    FIND FIRST tt-tic606-dados NO-LOCK NO-ERROR.
    IF  AVAIL tt-tic606-dados THEN DO:
        glb_cdcritic = 339.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                         glb_cdprogra +
                      "' --> '" + glb_dscritic + "' --> '" + aux_nmarqdat +
                      " >> log/proc_batch.log").
        glb_cdcritic = 0.
    END.
    ELSE DO:
         RUN fontes/fimprg.p.
         RETURN.
    END. 

    ASSIGN aux_vltolarq = 0
           aux_vltotlot = 0.
    
    OUTPUT STREAM str_2 TO VALUE(aux_dircoper + "arq/" + aux_nmarqdat).
    
    /* Linha do Header */
    FIND FIRST tt-tic606 WHERE tt-tic606.nrsequen = 1 NO-LOCK NO-ERROR.
    PUT STREAM str_2
        FILL("0",47)                      FORMAT "x(47)"
        "TIC606"
        "018"
        STRING(crapcop.cdagectl,"9999")   FORMAT "x(4)"
        SUBSTR(tt-tic606.dsdlinha,61,3)   FORMAT "x(3)"
        " "
        "2"
        aux_dtretarq                      FORMAT "x(8)"
        FILL(" ",77)                      FORMAT "x(77)"
        SUBSTR(tt-tic606.dsdlinha,151,50) FORMAT "x(50)"
        SKIP.
    
    /* Busca as linhas importadas */
    FOR EACH tt-tic606-dados 
        BREAK BY tt-tic606-dados.cdcmpdes 
              BY tt-tic606-dados.cdbcodes 
              BY tt-tic606-dados.cdtipdoc.

        ASSIGN aux_contareg = aux_contareg + 1
               aux_qttotlot = aux_qttotlot + 1.

        ASSIGN aux_vltolarq = aux_vltolarq + 
                      (DECI(SUBSTR(tt-tic606-dados.dsdlinha,34,17)) / 100)
               aux_vltotlot = aux_vltotlot +
                      (DECI(SUBSTR(tt-tic606-dados.dsdlinha,34,17)) / 100).

        /* Linha Detalhe */
        PUT STREAM str_2
            SUBSTR(tt-tic606-dados.dsdlinha,1,78)   FORMAT "x(078)" 
            STRING(tt-tic606-dados.cdcomchq,"999")  FORMAT "x(003)"
            aux_dtretarq                            FORMAT "x(8)"
            SUBSTR(tt-tic606-dados.dsdlinha,90,49)  FORMAT "x(049)" 
            STRING(tt-tic606-dados.cdocorre,"99")   FORMAT "x(2)"
            "018"
            STRING(crapcop.cdagectl,"9999")         FORMAT "x(4)"
            STRING(tt-tic606-dados.cdtipdoc,"999")  FORMAT "x(3)"
            STRING(aux_contareg,"9999999999")       FORMAT "x(10)"
            SUBSTR(tt-tic606-dados.dsdlinha,161,40) FORMAT "x(40)"
            SKIP.   
            
        IF  aux_qttotlot >= 400 THEN 
            DO:
                 ASSIGN aux_qttotlot = 0
                        aux_contareg = aux_contareg + 1.

                 /* Fechamento*/
                 PUT STREAM str_2
                     "018"
                     STRING(tt-tic606-dados.cdbcoctl,"999")  FORMAT "x(3)"
                     FILL("9",27)                            FORMAT "X(27)"
                     STRING(aux_vltotlot * 100,"99999999999999999")  
                                                             FORMAT "X(17)"
                     FILL(" ",5)                             FORMAT "X(5)"
                     STRING(tt-tic606-dados.cdbcoctl,"999")  FORMAT "x(3)"
                     FILL(" ",23)                            FORMAT "X(23)"
                     aux_dtretarq                            FORMAT "x(8)"
                     "0000001"                               FORMAT "x(7)"    
                     "999"                                   FORMAT "x(3)"    
                     "000000"                                FORMAT "x(6)"    
                     FILL(" ",35)                            FORMAT "x(35)" 
                     "018"
                     STRING(crapcop.cdagectl,"9999")         FORMAT "x(4)"
                     STRING(tt-tic606-dados.cdtipdoc,"999")  FORMAT "x(3)"
                     STRING(aux_contareg,"9999999999")       FORMAT "x(10)"
                     SUBSTR(tt-tic606-dados.dsdlinha,161,40) FORMAT "x(40)"
                     SKIP.

                 ASSIGN aux_vltotlot = 0.
                 
                 NEXT.

            END.
        
        IF  LAST-OF(cdcmpdes) OR 
            LAST-OF(cdbcodes) OR 
            LAST-OF(cdtipdoc) THEN 
            DO:
                ASSIGN aux_qttotlot = 0
                       aux_contareg = aux_contareg + 1.
                 
                /* Fechamento*/
                PUT STREAM str_2
                    "018"
                    STRING(tt-tic606-dados.cdbcoctl,"999")  FORMAT "x(3)"
                    FILL("9",27)                            FORMAT "X(27)"
                    STRING(aux_vltotlot * 100,
                           "99999999999999999")             FORMAT "X(17)"
                    FILL(" ",5)                             FORMAT "X(5)"
                    STRING(tt-tic606-dados.cdbcoctl,"999")  FORMAT "x(3)"
                    FILL(" ",23)                            FORMAT "X(23)"
                    aux_dtretarq                            FORMAT "x(8)"
                    "0000001"                               FORMAT "x(7)"    
                    "999"                                   FORMAT "x(3)"    
                    "000000"                                FORMAT "x(6)"    
                    FILL(" ",35)                            FORMAT "x(35)" 
                    "018"
                    STRING(crapcop.cdagectl,"9999")         FORMAT "x(4)"
                    STRING(tt-tic606-dados.cdtipdoc,"999")  FORMAT "x(3)"
                    STRING(aux_contareg,"9999999999")       FORMAT "x(10)"
                    SUBSTR(tt-tic606-dados.dsdlinha,161,40) FORMAT "x(40)"
                    SKIP.    
                    
                ASSIGN aux_vltotlot = 0.    
            END.
            
    END. /* Fim do FOR EACH */
    
    aux_contareg = aux_contareg + 1.

    /*Linha do Trailer*/
    FIND FIRST tt-tic606 WHERE tt-tic606.nrsequen = 999999 NO-LOCK NO-ERROR.
    PUT STREAM str_2
        FILL("9",47)                                    FORMAT "x(47)"
        "TIC606"                                                           
        "018"
        STRING(crapcop.cdagectl,"9999")                 FORMAT "x(4)"          
        SUBSTR(tt-tic606.dsdlinha,61,3)                 FORMAT "x(3)"
        " "                                             FORMAT "x(1)"
        "2"                                                              
        aux_dtretarq                                    FORMAT "x(8)"
        STRING(aux_vltolarq * 100,"99999999999999999")  FORMAT "X(17)"
        FILL(" ",60)                                    FORMAT "x(60)"
        STRING(aux_contareg,"9999999999")               FORMAT "x(10)"
        SUBSTR(tt-tic606.dsdlinha,161,40)               FORMAT "x(40)"
        SKIP.                                                                 

    OUTPUT STREAM str_2 CLOSE.

    /* Copia para o /micros */
    UNIX SILENT VALUE("ux2dos " + aux_dircoper + "arq/" + 
                      aux_nmarqdat + ' | tr -d "\032"' + 
                      " > /micros/" + crapcop.dsdircop + 
                      "/abbc/" + aux_nmarqdat + " 2>/dev/null").

    /* move para o salvar */
    UNIX SILENT VALUE("mv " + aux_dircoper + "arq/" + aux_nmarqdat
                      + " " + aux_dircoper + "salvar/" +
                      aux_nmarqdat + "_" + STRING(TIME,"99999") + 
                      " 2>/dev/null").

    /* Fim Gera Arquivo */

END. /* FIM Contador */

RUN p_elimina_tic.

RUN fontes/fimprg.p.

/*............................................................................*/

PROCEDURE p_elimina_tic:

    DEF VAR aux_incheque AS INT INIT 0 NO-UNDO.

    DO WHILE aux_incheque < 10:

        FOR EACH crapfdc WHERE crapfdc.cdcooper = glb_cdcooper     AND
                               crapfdc.incheque = aux_incheque     AND
                               crapfdc.dtlibtic < glb_dtmvtolt 
                               USE-INDEX crapfdc5 EXCLUSIVE-LOCK:

            ASSIGN crapfdc.cdbantic = 0
                   crapfdc.cdagetic = 0
                   crapfdc.nrctatic = 0
                   crapfdc.dtlibtic = ?
                   crapfdc.dtatutic = ?.
        END.

        ASSIGN aux_incheque = aux_incheque + 1.
    END.

END PROCEDURE.

/* .......................................................................... */
