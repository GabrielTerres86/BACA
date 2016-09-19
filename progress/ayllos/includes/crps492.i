/*..............................................................................

   Programa: includes/crps492.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise IT)
   Data    : Julho/2007                        Ultima atualizacao: 05/12/2013 

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Importacao de arquivo de atualizacao da data de 
               relacionamento bancario.               
               Atualizar tabelas crapsfn.
               Include utilizadas pelos programas crps492 e crps494.

   Alteracoes: 27/09/2007 - Copiar relatorio para o dir 'rlnsv' se for online
                          - Se a include nao for chamada online importar
                            arquivo do dir 'integra' (Guilherme/Evandro).
                            
               12/11/2007 - Efetuado acerto na atribuicao do campo
                            crapsfn.dtdemiss (Diego).
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
..............................................................................*/
                          
DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                         NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                         NO-UNDO.

DEF VAR aux_nrcpfcgc AS DEC                                          NO-UNDO.
DEF VAR aux_nrseqdig AS INT                                          NO-UNDO.

DEF  VAR aux_dscpfcgc   AS CHAR FORMAT "x(18)"                       NO-UNDO.
DEF  VAR aux_inpessoa   AS CHAR FORMAT "x(01)"                       NO-UNDO.
DEF  VAR aux_insitcta   AS CHAR FORMAT "x(10)"                       NO-UNDO.
DEF  VAR aux_dtdemiss   AS CHAR FORMAT "x(10)"                       NO-UNDO.

DEF TEMP-TABLE tt_resumo                                             NO-UNDO
    FIELD nmarquiv AS   CHAR FORMAT "x(50)"
    FIELD inpessoa LIKE crapsfn.inpessoa
    FIELD nrcpfcgc LIKE crapsfn.nrcpfcgc          
    FIELD nmclient AS   CHAR FORMAT "x(35)"   
    FIELD cddbanco LIKE crapsfn.cddbanco
    FIELD cdageban LIKE crapsfn.cdageban
    FIELD dtabtcct LIKE crapsfn.dtabtcct
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
     aux_dtdemiss         AT 115 FORMAT "x(10)"         LABEL "DT ENCERRAM"
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

IF   NOT AVAILABLE crapcop   THEN
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.
         
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
        
         RUN fontes/fimprg.p.
         RETURN.
     END.


ASSIGN aux_nmarquiv = IF   glb_inproces = 1   THEN
                           "/micros/"   + crapcop.dsdircop         + 
                           "/bancoob/6" + STRING(crapcop.cdagebcb) + 
                           "*.RT*"
                      ELSE 
                           "/usr/coop/" + crapcop.dsdircop         +
                           "/integra/6" + STRING(crapcop.cdagebcb) +
                           "*.RT*".

INPUT STREAM str_1 
             THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
                                              
DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .
    
    /* pegar nome do arquivo, que possui 12 caracteres */
    ASSIGN aux_nmarqdat = "integra/" +  
                          SUBSTR(aux_nmarquiv,
                                (LENGTH(aux_nmarquiv) - 12) + 1,12) + ".ux".
    
    UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + aux_nmarqdat + 
                      " 2> /dev/null").

    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").         
                      
    INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO. 

    IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
    
    /* Consistencia de validacao de arquivo correto */
    IF   SUBSTR(aux_setlinha,19,6) <> "ICF615"   THEN
         DO:
             ASSIGN glb_cdcritic = 173.
             RUN fontes/critic.p.
         
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> " + aux_nmarqlog).
        
             RUN fontes/fimprg.p.
             RETURN.       
         END.
    
    DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

        /*  Verifica se eh final do Arquivo  */
        IF   INT(SUBSTR(aux_setlinha,1,1)) = 9   THEN
             LEAVE.
        
        ASSIGN aux_nrcpfcgc = DEC(SUBSTR(aux_setlinha,9,14)).
        
        /*  Consistir CPF Associado  */
        FIND FIRST crapttl WHERE crapttl.cdcooper = crapcop.cdcooper   AND
                                 crapttl.nrcpfcgc = aux_nrcpfcgc
                                 NO-LOCK NO-ERROR.
        
        IF   NOT AVAIL crapttl   THEN
             DO:
                 FIND FIRST crapass WHERE 
                                    crapass.cdcooper = crapcop.cdcooper  AND
                                    crapass.nrcpfcgc = aux_nrcpfcgc 
                                    NO-LOCK NO-ERROR.
                                    
                 IF   NOT AVAIL crapass   THEN
                      DO:
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '"  +
                                           " CPF nao cadastrado: " + 
                                           STRING(aux_nrcpfcgc) +
                                           " >> " + aux_nmarqlog).
                         NEXT.
                      END.   
             END.
            
        FIND LAST crapsfn WHERE crapsfn.cdcooper = glb_cdcooper       AND
                                crapsfn.nrcpfcgc = aux_nrcpfcgc       AND
                                crapsfn.tpregist = 1 /* Recebido */ 
                                NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapsfn   THEN
             ASSIGN aux_nrseqdig = 1.
        ELSE
             ASSIGN aux_nrseqdig = crapsfn.nrseqdig + 1.

        CREATE crapsfn.
        ASSIGN crapsfn.cdcooper = glb_cdcooper
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
        
        /* para situacao de conta Encerrada, atualizar inf de encerramento */
        IF   INT(SUBSTR(aux_setlinha,105,1)) = 2   THEN
             DO:
                 ASSIGN crapsfn.dtdemiss = DATE(SUBSTR(aux_setlinha,112,2) + 
                                           "/" +  
                                           SUBSTR(aux_setlinha,110,2) + /*MES*/
                                           "/" +  
                                           SUBSTR(aux_setlinha,106,4))  /*ANO*/
                        crapsfn.cdmotdem = INT(SUBSTR(aux_setlinha,114,2)).
             END.    
        VALIDATE crapsfn.    
        /* atualizar informacoes resumo */
        CREATE tt_resumo.
        ASSIGN tt_resumo.nmarquiv = SUBSTR(aux_nmarquiv,
                                          (LENGTH(aux_nmarquiv) - 12) + 1,12)
               tt_resumo.inpessoa = crapsfn.inpessoa
               tt_resumo.nrcpfcgc = crapsfn.nrcpfcgc
               tt_resumo.nmclient = SUBSTR(aux_setlinha,23,35)
               tt_resumo.cddbanco = crapsfn.cddbanco
               tt_resumo.cdageban = crapsfn.cdageban
               tt_resumo.dtabtcct = crapsfn.dtabtcct
               tt_resumo.insitcta = crapsfn.insitcta
               tt_resumo.dtdemiss = crapsfn.dtdemiss.

    END.    /** Fim DO WHILE TRUE **/           
                                      
    UNIX SILENT VALUE("mv " + aux_nmarqdat + 
                      " salvar/" +
                      SUBSTR(aux_nmarqdat,9,12)). 

    INPUT STREAM str_2 CLOSE.
                                                          
END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

RUN gerar_resumo.
 
RUN fontes/fimprg.p.

/*............................................................................*/
PROCEDURE gerar_resumo.

    { includes/cabrel132_1.i }
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.

    FOR EACH tt_resumo NO-LOCK
             BREAK BY tt_resumo.nmarquiv:
  
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

        DOWN STREAM str_1 WITH FRAME f_resumo.
    END.

    OUTPUT STREAM str_1 CLOSE.
            
    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqrel.
             
    IF   glb_inproces = 1   THEN
         UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                           SUBSTRING(aux_nmarqrel,
                                     R-INDEX(aux_nmarqrel,"/") + 1,
                                     LENGTH(aux_nmarqrel) -
                                     R-INDEX(aux_nmarqrel,"/"))). 

    RUN fontes/imprim.p.
    
END PROCEDURE.

