/*..............................................................................

   Programa: includes/crps555.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Precise
   Data    : Fevereiro/2010                   Ultima atualizacao: 05/12/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Importacao de arquivo de atualizacao da data de 
               relacionamento bancario.               
               Atualizar tabelas gncpicf.
               Include utilizadas pelos programas crps555 e crps556.

   Alteracoes: 07/07/2010 - Acerto para ler arquivo com referencia na CECRED
                            (Guilherme).
                            
               03/08/2010 - Acerto no comando mv (Guilherme).
               
               20/09/2010 - Gerar relatorio na intranet das singulares 
                            (Guilherme).
                            
               16/05/2012 - Buscar registro crapass atraves do nrdconta quando
                            existir crapttl, ao inves de nrcpfcgc (Diego).              

               10/10/2012 - Criar relatorio de contas migradas e enviar por
                            email pra compe@cecred.coop.br (Tiago).
                            
               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago). 
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)                     
..............................................................................*/
                          
DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.

DEF VAR b1wgen0011   AS HANDLE                                       NO-UNDO.

DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                         NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                         NO-UNDO.
DEF VAR rel_nmdsaida AS CHAR                                         NO-UNDO.

DEF VAR aux_nrcpfcgc AS DEC                                          NO-UNDO.
DEF VAR aux_nrseqdig AS INT                                          NO-UNDO.

DEF  VAR aux_dscpfcgc   AS CHAR FORMAT "x(18)"                       NO-UNDO.
DEF  VAR aux_inpessoa   AS CHAR FORMAT "x(01)"                       NO-UNDO.
DEF  VAR aux_insitcta   AS CHAR FORMAT "x(10)"                       NO-UNDO.
DEF  VAR aux_dtdemiss   AS CHAR FORMAT "x(10)"                       NO-UNDO.
DEF  VAR aux_dscooper   AS CHAR                                      NO-UNDO.

DEF TEMP-TABLE tt_resumo                                             NO-UNDO
    FIELD cdcooper AS   INT
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD dsdircop LIKE crapcop.dsdircop
    FIELD nmarquiv AS   CHAR FORMAT "x(50)"
    FIELD inpessoa LIKE gncpicf.inpessoa
    FIELD nrcpfcgc LIKE gncpicf.nrcpfcgc          
    FIELD nmclient AS   CHAR FORMAT "x(35)"   
    FIELD cddbanco LIKE gncpicf.cddbanco
    FIELD cdageban LIKE gncpicf.cdageban
    FIELD dtabtcct LIKE gncpicf.dtabtcct
    FIELD insitcta LIKE crapsfn.insitcta
    FIELD dtdemiss LIKE crapsfn.dtdemiss.

DEF TEMP-TABLE tt-migrada                                            NO-UNDO
    FIELD cdcooper AS   INT
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD dsdircop LIKE crapcop.dsdircop
    FIELD nmarquiv AS   CHAR FORMAT "x(50)"
    FIELD inpessoa LIKE gncpicf.inpessoa
    FIELD nrcpfcgc LIKE gncpicf.nrcpfcgc          
    FIELD nmclient AS   CHAR FORMAT "x(35)"   
    FIELD cddbanco LIKE gncpicf.cddbanco
    FIELD cdageban LIKE gncpicf.cdageban
    FIELD dtabtcct LIKE gncpicf.dtabtcct
    FIELD insitcta LIKE crapsfn.insitcta
    FIELD dtdemiss LIKE crapsfn.dtdemiss.


FORM SKIP(1)
     tt_resumo.nmarquiv   AT  06                        LABEL "NOME DO ARQUIVO"
     SKIP(2)
     WITH NO-BOX DOWN SIDE-LABELS  WIDTH 80 FRAME f_label.

FORM aux_inpessoa         AT 02  FORMAT "x(01)"         LABEL "TIPO"
     aux_dscpfcgc         AT 07                         LABEL "CPF/CNPJ"
     tt_resumo.nmclient   AT 27  FORMAT "x(50)"         
                                 LABEL "NOME/RAZAO SOCIAL"
     tt_resumo.cddbanco   AT 80  FORMAT "zz9"           LABEL "BANCO"
     tt_resumo.cdageban   AT 86  FORMAT "zzzz9"         LABEL "AGENC"
     tt_resumo.dtabtcct   AT 92  FORMAT "99/99/9999"    LABEL "DT RELACIO"
     aux_insitcta         AT 103 FORMAT "x(10)"         LABEL "SITUACAO"
     aux_dtdemiss         AT 115 FORMAT "x(12)"         LABEL "DT ENCERRAM"
     WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_resumo.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR aux_nmmesano AS CHAR    EXTENT 12 INIT
                                       [" JANEIRO ","FEVEREIRO",
                                        "  MARCO  ","  ABRIL  ",
                                        "  MAIO   ","  JUNHO  ",
                                        " JULHO   "," AGOSTO  ",
                                        "SETEMBRO "," OUTUBRO ",
                                        "NOVEMBRO ","DEZEMBRO "]     NO-UNDO.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN DO:

     glb_cdcritic = 651.
     RUN fontes/critic.p.

     IF glb_cdprogra = "crps556" THEN
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - Coop: Sem crapcop" +
                           " - Processar: RELACIONAMENTO" +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
     ELSE
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
     RETURN.
 END.

ASSIGN aux_dscooper = "/usr/coop/cecred/".
ASSIGN aux_nmarquiv = "/micros/cecred/abbc/ICF615" + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".*".

INPUT STREAM str_1 
             THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

    /* pegar nome do arquivo, que possui 12 caracteres */
    ASSIGN aux_nmarqdat = aux_dscooper + "integra/" +
                          SUBSTR(aux_nmarquiv,
                                (LENGTH(aux_nmarquiv) - 12) + 1,12) + ".ux".

    UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + aux_nmarqdat +
                      " 2> /dev/null").

    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

    /* Valida se o arquivo lido e do banco da central */
    IF  INT(ENTRY(2,aux_nmarqdat,".")) <> crapcop.cdbcoctl   THEN DO:

        IF glb_cdprogra = "crps556" THEN
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - Coop:" + STRING(crapcop.cdcooper,"99") +
                             " - Processar: RELACIONAMENTO" +
                             " - " + glb_cdprogra + "' --> '"  +
                             " Arquivo ICF de outro banco: " + 
                             STRING(ENTRY(2,aux_nmarqdat,".")) +
                             " >> " + aux_nmarqlog).
        ELSE
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - " + glb_cdprogra + "' --> '"  +
                             " Arquivo ICF de outro banco: " + 
                             STRING(ENTRY(2,aux_nmarqdat,".")) +
                             " >> " + aux_nmarqlog).
       RETURN.
    END.

    /* Valida se o dia do arquivo lido eh do dia do glb_dtmvtolt */
    IF  INT(SUBSTR(aux_nmarqdat,INDEX(aux_nmarqdat,".") - 2,2))
        <> DAY(glb_dtmvtolt) THEN DO:

        IF glb_cdprogra = "crps556" THEN
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - Coop:" + STRING(crapcop.cdcooper,"99") +
                             " - Processar: RELACIONAMENTO" +
                              " - " + glb_cdprogra + "' --> '"  +
                              " Dia invalido no arquivo ICF: " + 
                              STRING(SUBSTR(aux_nmarqdat,
                                     INDEX(aux_nmarqdat,".") - 2,2)) +
                              " >> " + aux_nmarqlog).
        ELSE
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '"  +
                              " Dia invalido no arquivo ICF: " + 
                              STRING(SUBSTR(aux_nmarqdat,
                                     INDEX(aux_nmarqdat,".") - 2,2)) +
                              " >> " + aux_nmarqlog).
        RETURN.
    END.
    
    FOR EACH crapcop
       WHERE crapcop.cdcooper <> 3 NO-LOCK:

        INPUT STREAM str_3 FROM VALUE(aux_nmarqdat) NO-ECHO.

        ASSIGN aux_setlinha = "".
        
        IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

        /* Consistencia de validacao de arquivo correto */
        IF   SUBSTR(aux_setlinha,19,6) <> "ICF615"   THEN DO:

             ASSIGN glb_cdcritic = 173.
             RUN fontes/critic.p.

             IF glb_cdprogra = "crps556" THEN
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - Coop:" + STRING(crapcop.cdcooper,"99") +
                                  " - Processar: RELACIONAMENTO" +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  glb_dscritic + " >> " + aux_nmarqlog).
             ELSE
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  glb_dscritic + " >> " + aux_nmarqlog).

             RUN fontes/fimprg.p.
             RETURN.       
         END.

        DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

            ASSIGN aux_setlinha = "".

            IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

            /*  Verifica se eh final do Arquivo  */
            IF   INT(SUBSTR(aux_setlinha,1,1)) = 9 OR aux_setlinha = ""  THEN
                 LEAVE.

            /* Verifica se eh registro da agencia correta na IF CECRED */
            IF  INT(SUBSTR(aux_setlinha,93,4)) <> crapcop.cdagectl  THEN
                NEXT.
            
            ASSIGN aux_nrcpfcgc = DEC(SUBSTR(aux_setlinha,9,14)).

            /*  Consistir CPF Associado  */
            FIND FIRST crapttl
                 WHERE crapttl.cdcooper = crapcop.cdcooper
                   AND crapttl.nrcpfcgc = aux_nrcpfcgc
               NO-LOCK NO-ERROR.

            IF   NOT AVAIL crapttl   THEN
                 DO:
                     FIND FIRST crapass 
                          WHERE crapass.cdcooper = crapcop.cdcooper
                            AND crapass.nrcpfcgc = aux_nrcpfcgc 
                        NO-LOCK NO-ERROR.

                     IF NOT AVAIL crapass   THEN
                        NEXT.
                 END.
             ELSE
                  FIND FIRST crapass
                       WHERE crapass.cdcooper = crapcop.cdcooper
                         AND crapass.nrdconta = crapttl.nrdconta 
                     NO-LOCK NO-ERROR.


            /*verificar as ctas migradas e desprezar gerando
              relatorio com estas contas e enviar email pra compe*/  
            FIND craptco WHERE craptco.cdcopant = crapass.cdcooper AND
                               craptco.nrctaant = crapass.nrdconta AND
                               craptco.flgativo = TRUE             AND
                               craptco.tpctatrf <> 3
                               NO-LOCK NO-ERROR.

            IF  AVAIL(craptco) THEN
                DO:

                    CREATE  tt-migrada.
                    ASSIGN  tt-migrada.cdcooper = crapcop.cdcooper
                            tt-migrada.nmrescop = crapcop.nmrescop
                            tt-migrada.dsdircop = crapcop.dsdircop
                            tt-migrada.nmarquiv = SUBSTR(aux_nmarquiv,
                                            (LENGTH(aux_nmarquiv) - 12) + 1,12)
                            tt-migrada.inpessoa = INT(SUBSTR(aux_setlinha,8,1))
                            tt-migrada.nrcpfcgc = aux_nrcpfcgc
                            tt-migrada.nmclient = SUBSTR(aux_setlinha,23,35)
                            tt-migrada.cddbanco = INT(SUBSTR(aux_setlinha,83,3))
                            tt-migrada.cdageban = INT(SUBSTR(aux_setlinha,86,4))
                            tt-migrada.dtabtcct = 
                                      DATE(SUBSTR(aux_setlinha,103,2) + /*DIA*/
                                           "/" +  
                                           SUBSTR(aux_setlinha,101,2) + /*MES*/
                                           "/" +  
                                           SUBSTR(aux_setlinha,97,4)) /* ANO */
                            tt-migrada.insitcta = INT(SUBSTR(aux_setlinha,105,1)).

                           /* para situacao de conta Encerrada, atualizar inf de encerramento*/
                    IF   INT(SUBSTR(aux_setlinha,105,1)) = 2   THEN
                         DO:
                             ASSIGN tt-migrada.dtdemiss = 
                                    DATE(SUBSTR(aux_setlinha,112,2)
                                                + "/" +  
                                                /*MES*/
                                                SUBSTR(aux_setlinha,110,2) + 
                                                "/" +  
                                                /*ANO*/
                                                SUBSTR(aux_setlinha,106,4)).  
                         END.

                    NEXT.
                END.


/*................. CRIA TABELA GENERICA GNCPICF .............................*/
            FIND LAST gncpicf WHERE gncpicf.cdcooper = crapcop.cdcooper   AND
                                    gncpicf.nrcpfcgc = aux_nrcpfcgc       AND
                                    gncpicf.tpregist = 1 /* Recebido */ 
                                    NO-LOCK NO-ERROR.

            IF   NOT AVAIL gncpicf   THEN
                 ASSIGN aux_nrseqdig = 1.
            ELSE
                 ASSIGN aux_nrseqdig = gncpicf.nrseqdig + 1.

            CREATE gncpicf.
            ASSIGN gncpicf.cdcooper = crapcop.cdcooper
                   gncpicf.cdagenci = crapass.cdagenci
                   gncpicf.cdageban = INT(SUBSTR(aux_setlinha,86,4))
                   gncpicf.nrcpfcgc = aux_nrcpfcgc
                   gncpicf.cdcrictl = 0
                   gncpicf.cddbanco = INT(SUBSTR(aux_setlinha,83,3))
                   gncpicf.tpregist = 1 /* Recebido */
                   gncpicf.nrseqdig = aux_nrseqdig
                   gncpicf.inpessoa = INT(SUBSTR(aux_setlinha,8,1))
                   gncpicf.dtabtcct = DATE(SUBSTR(aux_setlinha,103,2) + /*DIA*/
                                           "/" +  
                                           SUBSTR(aux_setlinha,101,2) + /*MES*/
                                           "/" +  
                                           SUBSTR(aux_setlinha,97,4)) /* ANO */
                   gncpicf.dtmvtolt = glb_dtmvtolt
                   gncpicf.cdoperad = glb_cdoperad
                   gncpicf.hrtransa = TIME
                   gncpicf.flgenvio = YES.
             
/*............. CRIA TABELA CRAPSFN ..........................................*/

            FIND LAST crapsfn WHERE crapsfn.cdcooper = crapcop.cdcooper   AND
                                    crapsfn.nrcpfcgc = aux_nrcpfcgc       AND
                                    crapsfn.tpregist = 1 /* Recebido */ 
                                    NO-LOCK NO-ERROR.

            IF   NOT AVAIL crapsfn   THEN
                 ASSIGN aux_nrseqdig = 1.
            ELSE
                 ASSIGN aux_nrseqdig = crapsfn.nrseqdig + 1.

            CREATE crapsfn.
            ASSIGN crapsfn.cdcooper = crapcop.cdcooper
                   crapsfn.cdagenci = crapass.cdagenci
                   crapsfn.nrcpfcgc = aux_nrcpfcgc
                   crapsfn.tpregist = 1 /* Recebido */
                   crapsfn.nrseqdig = aux_nrseqdig
                   crapsfn.inpessoa = INT(SUBSTR(aux_setlinha,8,1))
                   crapsfn.dtabtcct = DATE(SUBSTR(aux_setlinha,103,2) + /*DIA*/
                                           "/" +  
                                           SUBSTR(aux_setlinha,101,2) + /*MES*/
                                           "/" +  
                                           SUBSTR(aux_setlinha,97,4)) /* ANO */
                   crapsfn.cddbanco = INT(SUBSTR(aux_setlinha,83,3))
                   crapsfn.cdageban = INT(SUBSTR(aux_setlinha,86,4))
                   crapsfn.dtmvtolt = glb_dtmvtolt
                   crapsfn.cdoperad = glb_cdoperad
                   crapsfn.hrtransa = TIME
                   crapsfn.insitcta = INT(SUBSTR(aux_setlinha,105,1)).

            /* para situacao de conta Encerrada, atualizar inf de encerramento*/
            IF   INT(SUBSTR(aux_setlinha,105,1)) = 2   THEN
                 DO:
                     ASSIGN crapsfn.dtdemiss = DATE(SUBSTR(aux_setlinha,112,2)
                                               + "/" +  
                                               /*MES*/
                                               SUBSTR(aux_setlinha,110,2) + 
                                               "/" +  
                                               /*ANO*/
                                               SUBSTR(aux_setlinha,106,4))  
                            crapsfn.cdmotdem = INT(SUBSTR(aux_setlinha,114,2))
                            gncpicf.cdmotdem = INT(SUBSTR(aux_setlinha,114,2)).
                 END.
            VALIDATE crapsfn.
            VALIDATE gncpicf.
/*............................................................................*/

            /* atualizar informacoes resumo */
            CREATE tt_resumo.
            ASSIGN tt_resumo.cdcooper = gncpicf.cdcooper
                   tt_resumo.nmrescop = crapcop.nmrescop
                   tt_resumo.dsdircop = crapcop.dsdircop
                   tt_resumo.nmarquiv = SUBSTR(aux_nmarquiv,
                                              (LENGTH(aux_nmarquiv) - 12) + 1,
                                              12)
                   tt_resumo.inpessoa = gncpicf.inpessoa
                   tt_resumo.nrcpfcgc = gncpicf.nrcpfcgc
                   tt_resumo.nmclient = SUBSTR(aux_setlinha,23,35)
                   tt_resumo.cddbanco = gncpicf.cddbanco
                   tt_resumo.cdageban = gncpicf.cdageban
                   tt_resumo.dtabtcct = gncpicf.dtabtcct
                   tt_resumo.insitcta = crapsfn.insitcta
                   tt_resumo.dtdemiss = crapsfn.dtdemiss.

        END.    /** Fim DO WHILE TRUE **/           

        INPUT STREAM str_3 CLOSE.

    END. /** END do FOR EACH do CRAPCOP **/
    
    UNIX SILENT VALUE("mv " + aux_nmarqdat + 
                      " salvar/" + SUBSTR(aux_nmarquiv,
                                         INDEX(aux_nmarquiv,"ICF"),
                                         12)).
END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

RUN gerar_resumo.
RUN gerar_resumo_migradas.
 
RUN fontes/fimprg.p.

/*............................................................................*/
PROCEDURE gerar_resumo.

    { includes/cabrel132_1.i }
    { includes/cabrel132_2.i }

    ASSIGN rel_nmdsaida = aux_dscooper + aux_nmarqrel.
            
    OUTPUT STREAM str_1 TO VALUE(rel_nmdsaida) PAGED PAGE-SIZE 84.
            
    VIEW STREAM str_1 FRAME f_cabrel132_1.

    FOR EACH tt_resumo NO-LOCK
             BREAK BY tt_resumo.cdcooper
                   BY tt_resumo.nmarquiv:

        IF  FIRST-OF(tt_resumo.cdcooper) THEN 
            DO:
                ASSIGN rel_nmdsaida = "/usr/coop/" + 
                                      tt_resumo.dsdircop +
                                      "/" + aux_nmarqrel.
                OUTPUT STREAM str_2 TO VALUE(rel_nmdsaida) APPEND PAGED 
                       PAGE-SIZE 84.
            
                VIEW STREAM str_2 FRAME f_cabrel132_2.

                DISPLAY STREAM str_2 tt_resumo.nmarquiv 
                                     WITH FRAME f_label.

                DISPLAY STREAM str_1
                         "COOPERATIVA: " + STRING(tt_resumo.cdcooper) +
                         " - " + tt_resumo.nmrescop 
                         NO-LABEL FORMAT "x(70)".
                
            END.

        IF   FIRST-OF(tt_resumo.nmarquiv)   THEN
             DO:
                 DISPLAY STREAM str_1
                                tt_resumo.nmarquiv
                                WITH FRAME f_label.
             END.

        IF   tt_resumo.inpessoa = 2   THEN
             DO:
                 ASSIGN aux_inpessoa = "J"
                        aux_dscpfcgc = STRING(STRING(tt_resumo.nrcpfcgc,
                                                     "99999999999999"),
                                                     "xx.xxx.xxx/xxxx-xx").
             END.     
         ELSE
             DO:
                 ASSIGN aux_inpessoa = "F"
                        aux_dscpfcgc = STRING(STRING(tt_resumo.nrcpfcgc, 
                                                     "99999999999"),
                                                     "xxx.xxx.xxx-xx").
             END.

        IF   tt_resumo.insitcta = 1 THEN
             DO:
                 ASSIGN aux_insitcta = "ATIVA"
                        aux_dtdemiss = "".
             END.    
        ELSE
             DO:
                 ASSIGN aux_insitcta = "ENCERRADA"
                        aux_dtdemiss = STRING(tt_resumo.dtdemiss,"99/99/9999").
             END.

        DISPLAY STREAM str_1 aux_inpessoa
                             aux_dscpfcgc
                             tt_resumo.nmclient
                             tt_resumo.cddbanco
                             tt_resumo.cdageban
                             tt_resumo.dtabtcct
                             aux_insitcta
                             aux_dtdemiss
                             WITH FRAME f_resumo.

        DISPLAY STREAM str_2 aux_inpessoa
                             aux_dscpfcgc
                             tt_resumo.nmclient
                             tt_resumo.cddbanco
                             tt_resumo.cdageban
                             tt_resumo.dtabtcct
                             aux_insitcta
                             aux_dtdemiss
                             WITH FRAME f_resumo.

        DOWN STREAM str_1 WITH FRAME f_resumo.

        DOWN STREAM str_2 WITH FRAME f_resumo.
        
        IF  LAST-OF(tt_resumo.cdcooper)  THEN 
            DO:
                OUTPUT STREAM str_2 CLOSE.
    
                ASSIGN glb_nrcopias = 1
                       glb_nmformul = "132col"
                       glb_nmarqimp = rel_nmdsaida.
    
                RUN fontes/imprim_unif.p (INPUT tt_resumo.cdcooper).

                IF  glb_inproces = 1   THEN
                    UNIX SILENT VALUE("cp " + rel_nmdsaida + " " +
                                      "/usr/coop/" + tt_resumo.dsdircop +
                                      "/rlnsv/" +
                                      SUBSTRING(aux_nmarqrel,
                                      R-INDEX(aux_nmarqrel,"/") + 1,
                                      LENGTH(aux_nmarqrel) -
                                      R-INDEX(aux_nmarqrel,"/"))). 
    
                PAGE STREAM str_1.

                VIEW STREAM str_1 FRAME f_cabrel132_1.               
            END.

    
    END. /** END do FOR EACH tt_resumo **/
    
    FIND FIRST tt-migrada NO-LOCK NO-ERROR.

    IF  AVAIL(tt-migrada) THEN
        DISPLAY STREAM str_1 
                SKIP(1)
                "Contas migradas nao integradas do arquivo: "
                SKIP(1).
                

    FOR EACH tt-migrada NO-LOCK 
        BREAK BY tt-migrada.cdcooper
              BY tt-migrada.nmarquiv:

        IF  FIRST-OF(tt-migrada.cdcooper) THEN 
            DO:
                DISPLAY STREAM str_1
                         "COOPERATIVA: " + STRING(tt-migrada.cdcooper) +
                         " - " + tt-migrada.nmrescop 
                         NO-LABEL FORMAT "x(70)".
            END.                                 

        IF   tt-migrada.inpessoa = 2   THEN
             DO:
                 ASSIGN aux_inpessoa = "J"
                        aux_dscpfcgc = STRING(STRING(tt-migrada.nrcpfcgc,
                                                     "99999999999999"),
                                                     "xx.xxx.xxx/xxxx-xx").
             END.     
         ELSE
             DO:
                 ASSIGN aux_inpessoa = "F"
                        aux_dscpfcgc = STRING(STRING(tt-migrada.nrcpfcgc, 
                                                     "99999999999"),
                                                     "xxx.xxx.xxx-xx").
             END.

        IF   tt-migrada.insitcta = 1 THEN
             DO:
                 ASSIGN aux_insitcta = "ATIVA"
                        aux_dtdemiss = "".
             END.    
        ELSE
             DO:
                 ASSIGN aux_insitcta = "ENCERRADA"
                        aux_dtdemiss = STRING(tt-migrada.dtdemiss,"99/99/9999").
             END.


        DISPLAY STREAM str_1 aux_inpessoa
                             aux_dscpfcgc
                             tt-migrada.nmclient @ tt_resumo.nmclient
                             tt-migrada.cddbanco @ tt_resumo.cddbanco
                             tt-migrada.cdageban @ tt_resumo.cdageban
                             tt-migrada.dtabtcct @ tt_resumo.dtabtcct
                             aux_insitcta
                             aux_dtdemiss
                             WITH FRAME f_resumo.

    END.
   

    OUTPUT STREAM str_1 CLOSE.
        
    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqrel
           rel_nmdsaida = aux_dscooper + aux_nmarqrel.
        
    IF  glb_inproces = 1   THEN
        UNIX SILENT VALUE("cp " + rel_nmdsaida + " " +
                          aux_dscooper + "rlnsv/" +
                          SUBSTRING(aux_nmarqrel,
                          R-INDEX(aux_nmarqrel,"/") + 1,
                          LENGTH(aux_nmarqrel) -
                          R-INDEX(aux_nmarqrel,"/"))). 
        
    RUN fontes/imprim.p.    
    
END PROCEDURE.

 
PROCEDURE gerar_resumo_migradas.

    DEF VAR aux_conteudo    AS  CHAR                            NO-UNDO.

    { includes/cabrel132_1.i }
    { includes/cabrel132_2.i }

    ASSIGN rel_nmdsaida = aux_dscooper + "converte/c_email_crrl557.txt".
            
    OUTPUT STREAM str_1 TO VALUE(rel_nmdsaida) PAGED PAGE-SIZE 84.
            
    VIEW STREAM str_1 FRAME f_cabrel132_1.

    FOR EACH tt-migrada NO-LOCK
             BREAK BY tt-migrada.cdcooper
                   BY tt-migrada.nmarquiv:

        IF  FIRST-OF(tt-migrada.cdcooper) THEN 
            DO:                                
                DISPLAY STREAM str_1
                         "COOPERATIVA: " + STRING(tt-migrada.cdcooper) +
                         " - " + tt-migrada.nmrescop 
                         NO-LABEL FORMAT "x(70)".
            END.

        IF   FIRST-OF(tt-migrada.nmarquiv)   THEN
             DO:
                 DISPLAY STREAM str_1            
                                tt-migrada.nmarquiv  @ tt_resumo.nmarquiv
                                WITH FRAME f_label.
             END.

        IF   tt-migrada.inpessoa = 2   THEN
             DO:
                 ASSIGN aux_inpessoa = "J"
                        aux_dscpfcgc = STRING(STRING(tt-migrada.nrcpfcgc,
                                                     "99999999999999"),
                                                     "xx.xxx.xxx/xxxx-xx").
             END.     
         ELSE
             DO:
                 ASSIGN aux_inpessoa = "F"
                        aux_dscpfcgc = STRING(STRING(tt-migrada.nrcpfcgc, 
                                                     "99999999999"),
                                                     "xxx.xxx.xxx-xx").
             END.

        IF   tt-migrada.insitcta = 1 THEN
             DO:
                 ASSIGN aux_insitcta = "ATIVA"
                        aux_dtdemiss = "".
             END.    
        ELSE
             DO:
                 ASSIGN aux_insitcta = "ENCERRADA"
                        aux_dtdemiss = STRING(tt-migrada.dtdemiss,"99/99/9999").
             END.

        DISPLAY STREAM str_1 aux_inpessoa
                             aux_dscpfcgc
                             tt-migrada.nmclient @ tt_resumo.nmclient
                             tt-migrada.cddbanco @ tt_resumo.cddbanco
                             tt-migrada.cdageban @ tt_resumo.cdageban
                             tt-migrada.dtabtcct @ tt_resumo.dtabtcct
                             aux_insitcta
                             aux_dtdemiss
                             WITH FRAME f_resumo.

        DOWN STREAM str_1 WITH FRAME f_resumo.

        IF  LAST-OF(tt-migrada.cdcooper)  THEN 
            DO:
                ASSIGN glb_nrcopias = 1
                       glb_nmformul = "132col"
                       glb_nmarqimp = rel_nmdsaida.
    
                RUN fontes/imprim_unif.p (INPUT tt-migrada.cdcooper).

                PAGE STREAM str_1.

                VIEW STREAM str_1 FRAME f_cabrel132_1.               
            END.

    
    END. /** END do FOR EACH tt_resumo **/
    
    OUTPUT STREAM str_1 CLOSE.
        
    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqrel
           rel_nmdsaida = aux_dscooper + aux_nmarqrel.
        
    IF  glb_inproces = 1   THEN
        DO:

            UNIX SILENT VALUE("ux2dos " + rel_nmdsaida + " > " +
                              aux_dscooper + "rlnsv/" +
                              SUBSTRING(aux_nmarqrel,
                              R-INDEX(aux_nmarqrel,"/") + 1,
                              LENGTH(aux_nmarqrel) -
                              R-INDEX(aux_nmarqrel,"/"))). 
                   
            UNIX SILENT VALUE("ux2dos " + aux_dscooper + 
                              "converte/c_email_crrl557.txt > " +
                              aux_dscooper + "converte/email_crrl557.txt"). 
                 

        END.
    RUN fontes/imprim.p.

    IF  TEMP-TABLE tt-migrada:HAS-RECORDS  THEN
    DO:
        /*enviar email*/
        RUN sistema/generico/procedures/b1wgen0011.p
                        PERSISTENT SET b1wgen0011.

        RUN enviar_email IN b1wgen0011
                           (INPUT glb_cdcooper,
                            INPUT glb_cdprogra,
                            INPUT "compe@cecred.coop.br",
                            INPUT "Contas migradas nao integradas do " +
                                  "arquivo ICF615",
                            INPUT "email_crrl557.txt", 
                            INPUT TRUE).
                                 
        DELETE PROCEDURE b1wgen0011.
    END.
    
END PROCEDURE.


/*............................................................................*/
