/*..............................................................................

   Programa: fontes/crps532.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Janeiro/2010                        Ultima atualizacao: 105/08/2014
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps491
               Atende a solicitacao 1
               Gera relatorio crrl556
               Geracao de arquivo de atualizacao da data de 
               relacionamento bancario - ICF.

   Alteracoes: 05/04/2010 - Alterado para processar todas cooperativas, nao
                            mais por cooperativa Singular (Guilherme/Supero)
                            
               11/01/2011 - Ajuste do relatorio devido a mudanca do format
                            do campo nmprimtl (Henrique).
                            
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).

..............................................................................*/

{ includes/var_batch.i }    

DEF STREAM str_1.

DEF TEMP-TABLE w_relato
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE gncpicf.nrcpfcgc
    FIELD dtabtcct LIKE gncpicf.dtabtcct
    FIELD cddbanco LIKE gncpicf.cddbanco
    FIELD cdageban LIKE gncpicf.cdageban   
    INDEX w_relato1 cdcooper cdagenci nrdconta.

DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.

DEF VAR aaa_dtabtcct AS CHAR    FORMAT "9999"                          NO-UNDO.
DEF VAR mmm_dtabtcct AS CHAR    FORMAT "99"                            NO-UNDO.
DEF VAR ddd_dtabtcct AS CHAR    FORMAT "99"                            NO-UNDO.


DEF VAR aux_nrregist AS INTE                                           NO-UNDO.

DEF VAR aux_nrseqcli AS INTE                                           NO-UNDO.
DEF VAR aux_insitcta AS INTE                                           NO-UNDO.
DEF VAR aux_dtdemiss AS INTE                                           NO-UNDO.
DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.

DEF VAR rel_nrmodulo AS INTE    FORMAT "9"                             NO-UNDO.

DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]               NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

FORM w_relato.cdagenci    AT   5   LABEL "PA"
     w_relato.nrdconta    AT   9   LABEL "Conta/DV"
     w_relato.nmprimtl    AT  21   LABEL "Nome"
     w_relato.nrcpfcgc    AT  73   LABEL "CPF/CNPJ"
     w_relato.dtabtcct    AT  89   LABEL "Abertura"
     w_relato.cddbanco    AT 101   LABEL "Banco Destino"
     w_relato.cdageban    AT 116   LABEL "Age. Destino"
     WITH DOWN NO-LABELS WIDTH 132 FRAME  f_relatorio.

ASSIGN glb_cdprogra = "crps532"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    DO:
        RUN fontes/critic.p.
        RUN fontes/fimprg.p.
        RETURN.
    END.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop THEN
    DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        RETURN.
    END.

ASSIGN aux_dscooper = "/usr/coop/cecred/"
       aux_nmarqimp = "ICF" + STRING(crapcop.cdbcoctl,"999") + "01.REM"
       aux_nmarqlog = "log/prcctl_" + 
                      STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

IF  SEARCH("/micros/cecred/abbc/" + aux_nmarqimp) <> ?  THEN DO:

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Coop:" + STRING(crapcop.cdcooper,"99") +
                      " - Processar: RELACIONAMENTO - " +
                      glb_cdprogra + "' --> '"  +
                      "Existe arquivo pendente para Envio [" +
                      aux_nmarqimp + "] >> " + aux_nmarqlog).
    RUN fontes/fimprg.p.
    RETURN.
END.

RUN abre_arquivo.
    
FOR EACH crabcop WHERE crabcop.cdcooper <> 3 NO-LOCK:

    FOR EACH gncpicf WHERE gncpicf.tpregist = 2 AND 
                           gncpicf.flgenvio = NO AND
                           gncpicf.cdcooper = crabcop.cdcooper EXCLUSIVE-LOCK,
       FIRST crapsfn WHERE crapsfn.cdcooper = gncpicf.cdcooper      AND
                           crapsfn.nrdconta = INT(gncpicf.nrdconta) AND
                           crapsfn.tpregist = gncpicf.tpregist      AND
                           crapsfn.nrseqdig = gncpicf.nrseqdig 
                           EXCLUSIVE-LOCK:
    
        FIND crapass WHERE crapass.cdcooper = crabcop.cdcooper
                       AND crapass.nrdconta = INT(gncpicf.nrdconta)
                   NO-LOCK NO-ERROR. 
       
        IF  NOT AVAIL crapass THEN
            NEXT.
    
        ASSIGN aux_insitcta = IF crapass.dtdemiss = ?  THEN 1
                              ELSE 2.
        
        IF  crapass.dtdemiss <> ? THEN
            ASSIGN aux_dtdemiss = INT( STRING(YEAR(crapass.dtdemiss),"9999") +    
                                       STRING(MONTH(crapass.dtdemiss),"99")  +   
                                       STRING(DAY(crapass.dtdemiss),"99")).
        ELSE
            aux_dtdemiss = 0.
         
        RUN registro.

        ASSIGN gncpicf.flgenvio = TRUE  
               gncpicf.dtdenvio = glb_dtmvtolt
               crapsfn.flgenvio = gncpicf.flgenvio
               crapsfn.dtdenvio = gncpicf.dtdenvio.

    END.

END. /** END do FOR EACH da CRAPCOP **/

RUN fecha_arquivo.

RUN gera_relatorio.

RUN fontes/fimprg.p.                 
  
/*-------------------------------- PROCEDURES --------------------------------*/
      
PROCEDURE abre_arquivo:
     
    ASSIGN aux_nrseqcli = 0
           aux_nrregist = 1.
       
    OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" + aux_nmarqimp).

    /*** Header ***/
    PUT STREAM str_1 "0000000"
                     YEAR(glb_dtmvtolt)     FORMAT "9999"
                     MONTH(glb_dtmvtolt)    FORMAT "99"
                     DAY(glb_dtmvtolt)      FORMAT "99"
                     crapcop.cdbcoctl       FORMAT "999"
                     "ICF605"               FORMAT "x(6)"
                     FILL(" ",126)          FORMAT "x(126)"
                     aux_nrregist           FORMAT "9999999999"
                     SKIP.

END PROCEDURE.

PROCEDURE fecha_arquivo:

    ASSIGN  aux_nrregist = aux_nrregist + 1.

    /*** Trailer ***/
    PUT STREAM str_1 "9999999"
                     YEAR(glb_dtmvtolt)     FORMAT "9999"
                     MONTH(glb_dtmvtolt)    FORMAT "99"
                     DAY(glb_dtmvtolt)      FORMAT "99"
                     crapcop.cdbcoctl       FORMAT "999"
                     "ICF605"               FORMAT "x(6)"
                     aux_nrseqcli           FORMAT "99999" 
                     FILL(" ",121)          FORMAT "x(121)"
                     aux_nrregist           FORMAT "9999999999".

    OUTPUT STREAM str_1 CLOSE.

    /*** Se arquivo gerado nao tem registros "detalhe", entao elimina ***/
    IF  aux_nrregist <= 2  THEN
        DO:
            UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                               aux_nmarqimp + " 2>/dev/null"). 
            LEAVE.        
        END.

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Coop:" + 
                      " - Processar: RELACIONAMENTO - " +
                      glb_cdprogra + "' --> ' ATENCAO !! Envie o arquivo pela" +
                      " opcao Enviar - " + 
                      aux_nmarqimp + " >> " + aux_nmarqlog).

    UNIX SILENT VALUE("ux2dos < " + aux_dscooper + "arq/" + aux_nmarqimp +  
                      ' | tr -d "\032"' +  
                      " > /micros/cecred/abbc/" + 
                      aux_nmarqimp + " 2>/dev/null").

    UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqimp + " " +
                       aux_dscooper + "salvar 2>/dev/null"). 


    ASSIGN glb_cdcritic = 0.

END PROCEDURE.

PROCEDURE registro:

    ASSIGN aux_nrregist = aux_nrregist + 1
           aux_nrseqcli = aux_nrseqcli + 1.

    IF  YEAR(gncpicf.dtabtcct) = ?  THEN
        ASSIGN aaa_dtabtcct = "0000"
               mmm_dtabtcct = "00"
               ddd_dtabtcct = "00".
    ELSE
        ASSIGN aaa_dtabtcct = STRING(YEAR(gncpicf.dtabtcct),"9999")
               mmm_dtabtcct = STRING(MONTH(gncpicf.dtabtcct),"99")
               ddd_dtabtcct = STRING(DAY(gncpicf.dtabtcct),"99").
    /*** Detalhe ***/
    PUT STREAM str_1 aux_nrseqcli               FORMAT "99999"  
                     "01"
                     gncpicf.inpessoa           FORMAT "9"
                     gncpicf.nrcpfcgc           FORMAT "99999999999999"
                     crapass.nmprimtl           FORMAT "x(60)"
                     crabcop.cdbcoctl           FORMAT "999"
                     crabcop.cdagectl           FORMAT "9999"
                     gncpicf.cddbanco           FORMAT "999"
                     gncpicf.cdageban           FORMAT "9999"
                     aaa_dtabtcct               FORMAT "9999"
                     mmm_dtabtcct               FORMAT "99"
                     ddd_dtabtcct               FORMAT "99"
                     aux_insitcta               FORMAT "9"     
                     aux_dtdemiss               FORMAT "99999999"
                     gncpicf.cdmotdem           FORMAT "99"    
                     "00"                       FORMAT "99"    
                     "000000"                   FORMAT "999999"
                     FILL(" ",27)               FORMAT "x(27)"
                     aux_nrregist               FORMAT "9999999999"
                     SKIP.


    CREATE w_relato.
    ASSIGN w_relato.cdcooper = crabcop.cdcooper
           w_relato.nmrescop = crabcop.nmrescop
           w_relato.cdagenci = crapass.cdagenci
           w_relato.nrdconta = crapass.nrdconta
           w_relato.nmprimtl = crapass.nmprimtl
           w_relato.nrcpfcgc = gncpicf.nrcpfcgc
           w_relato.dtabtcct = gncpicf.dtabtcct
           w_relato.cddbanco = gncpicf.cddbanco 
           w_relato.cdageban = gncpicf.cdageban.

END PROCEDURE.

PROCEDURE gera_relatorio:

    /*** Monta o cabecalho ***/
    { includes/cabrel132_1.i }

    ASSIGN aux_nmarqrel = aux_dscooper + "rl/crrl556.lst".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.    
    
    FOR EACH w_relato NO-LOCK 
             USE-INDEX w_relato1
             BREAK BY w_relato.cdcooper
                   BY w_relato.cdagenci
                   BY w_relato.nrdconta:

        IF  FIRST-OF(w_relato.cdcooper)  THEN 
            DO:
                PUT STREAM str_1
                    SKIP(1)
                    "COOPERATIVA: " + STRING(w_relato.cdcooper) +
                    " - " + w_relato.nmrescop 
                    FORMAT "x(70)".
            END.
            
        DISPLAY STREAM str_1
                       w_relato.cdagenci
                       w_relato.nrdconta  
                       w_relato.nmprimtl  
                       w_relato.nrcpfcgc
                       w_relato.dtabtcct
                       w_relato.cddbanco
                       w_relato.cdageban
                       WITH FRAME f_relatorio.

        DOWN STREAM str_1 WITH FRAME f_relatorio.

        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                PUT STREAM str_1
                    SKIP(1)
                    "COOPERATIVA: " + STRING(w_relato.cdcooper) +
                    " - " + w_relato.nmrescop 
                    FORMAT "x(70)" 
                    SKIP(1).
                
            END.

        IF  LAST-OF(w_relato.cdcooper) THEN 
            DO:
                PAGE STREAM str_1.
                
                VIEW STREAM str_1 FRAME f_cabrel132_1.
            END.

    END. /** Fim do FOR EACH w_relatorios **/

    OUTPUT STREAM str_1 CLOSE.
               
    ASSIGN glb_nmformul    = "132col"
           glb_nmarqimp    = aux_nmarqrel
           glb_nrcopias    = 1.

    /*** Se nao estiver rodando no PROCESSO copia relatorio ***/
    IF  glb_inproces = 1  THEN
        UNIX SILENT VALUE("cp " + aux_nmarqrel + " " + aux_dscooper +
                          "rlnsv/" +
                          SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                          LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).

    RUN fontes/imprim.p.

END PROCEDURE.

/*............................................................................*/
