/* .............................................................................

   Programa: Fontes/crps626.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos/Supero
   Data    : Agosto/2012                   Ultima atualizacao: 05/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos TIC - Recebe arquivo TIC616

   Alteracoes: 25/10/2012 - Desconsiderar algumas criticas (Ze).
   
               10/10/2013 - Incluido tratamento craprej.cdcritic = 12, 
                            ref. FDR 43/2013 (Diego).
               
               14/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
              05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).

			  05/06/2016 - Incluso tratativa para que na leitura da crapcst 
			               só gere critica para nrborder = 0 (Daniel)  
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho    */

{ includes/var_batch.i }  

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dspesqbb AS CHAR                                  NO-UNDO.

DEF        VAR tab_nmarqtel AS CHAR    FORMAT "x(25)" EXTENT 99      NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(210)"               NO-UNDO.

DEF        VAR tot_qtregrej AS INT                                   NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtauxili AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgrejei AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_cdpesqbb AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtcompln AS DECI                                  NO-UNDO.
DEF        VAR aux_vlcompdb AS DECI                                  NO-UNDO.
DEF        VAR aux_vlcheque AS DATE                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdocorre AS INT                                   NO-UNDO.
DEF        VAR aux_mes      AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtlimite AS DATE                                  NO-UNDO.

DEF        VAR aux_cdbanchq LIKE craplcm.cdbanchq                    NO-UNDO.
DEF        VAR aux_cdcmpchq LIKE craplcm.cdcmpchq                    NO-UNDO.
DEF        VAR aux_cdagechq LIKE craplcm.cdagechq                    NO-UNDO.
DEF        VAR aux_nrctachq LIKE craplcm.nrctachq                    NO-UNDO.

FORM aux_setlinha  FORMAT "x(210)"
     WITH FRAME AA WIDTH 170 NO-BOX NO-LABELS.

FORM SKIP(1)
     "ARQUIVO:"         AT 01           
     tab_nmarqtel[i]    AT 10 FORMAT "x(35)"    NO-LABEL
     SKIP(1)
     aux_dtmvtolt       AT 01 FORMAT "99/99/9999" LABEL "DATA DE REFERENCIA"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM rel_dspesqbb         AT  1 FORMAT "x(12)"        LABEL "CMP BCO AGE."
     craprej.nrdctitg     AT 14 FORMAT "x(15)"        LABEL "   CONTA CHEQUE"
     craprej.nrdocmto     AT 30 FORMAT "zzz,zzz"      LABEL "CHEQUE"
     craprej.vllanmto     AT 38 FORMAT "zzzz,zz9.99"  LABEL "VALOR"
     craprej.dtdaviso     AT 50 FORMAT "99/99/99"     LABEL "DT. LIB."
     craprej.nrdconta     AT 59 FORMAT "zz,zzz,zz9,9" LABEL "CONTA/DV"
     craprej.dtmvtolt     AT 72 FORMAT "99/99/99"     LABEL "DT. LOTE"
     craprej.dshistor     AT 81 FORMAT "x(15)"        LABEL "PA BCX   LOTE"
     glb_dscritic         AT 97 FORMAT "x(34)"        LABEL "CRITICA"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_lanctos.

FORM SKIP(2)
     tot_qtregrej     AT 30 FORMAT "zzz,zz9" 
                      LABEL "TOTAL DE REGISTROS COM CRITICAS  "
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_total.


FUNCTION calc_prox_dia_util RETURNS DATE(INPUT par_data AS DATE):

    /* Calcular proximo dia util da data do parametro */
       
    DEF VAR tmp_dtrefere    AS DATE                         NO-UNDO.
    DEF VAR aux_dtultdia    AS DATE                         NO-UNDO.

    
    /* Pega o ultimo dia util antes de ontem */
    tmp_dtrefere = par_data + 1.
    
    DO  WHILE TRUE:

        IF   WEEKDAY(tmp_dtrefere) = 1   OR
             WEEKDAY(tmp_dtrefere) = 7   THEN
             DO:
                tmp_dtrefere = tmp_dtrefere + 1.
                NEXT.
             END.
                                    
        FIND crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                           crapfer.dtferiad = tmp_dtrefere
                           NO-LOCK NO-ERROR.
                                                            
        IF   AVAILABLE crapfer   THEN
             DO:
                tmp_dtrefere = tmp_dtrefere + 1.
                NEXT.
             END.

        LEAVE.
        
    END.  /*  Fim do DO WHILE TRUE  */
    
    IF   par_data = aux_dtultdia THEN
         tmp_dtrefere = tmp_dtrefere + 1.
    
    RETURN tmp_dtrefere.

END FUNCTION.  


ASSIGN glb_cdprogra = "crps626"
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

/*  Fim da verificacao se deve executar */
IF   glb_nmtelant = "COMPEFORA" THEN
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtoan),"9999") +
                           STRING(MONTH(glb_dtmvtoan),"99") +
                           STRING(DAY(glb_dtmvtoan),"99")
            aux_dtmvtolt = glb_dtmvtoan.
ELSE                                    
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtolt),"9999") +
                           STRING(MONTH(glb_dtmvtolt),"99") +
                           STRING(DAY(glb_dtmvtolt),"99")
            aux_dtmvtolt = glb_dtmvtolt.
  

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
                      aux_mes + STRING(DAY(aux_dtmvtolt),"99") + ".CND"
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

/* Se não houver arquivos processados */
IF   aux_contador = 0 THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         RETURN.
     END.
/*  Fim da verificacao se deve executar */


FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper
                       TRANSACTION:
    DELETE craprej.
END.


/* Variavel de contador trouxe arquivos */
DO  i = 1 TO aux_contador:

    ASSIGN aux_flgrejei = FALSE
           aux_qtcompln = 0
           aux_vlcompdb = 0.   
    
    /* Leitura da linha do header */
    
    INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

    SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 210.

    IF   SUBSTR(aux_setlinha,1,10) <> "0000000000"  THEN /* Const = 0 */
         glb_cdcritic = 468.
    ELSE
    IF   SUBSTR(aux_setlinha,48,6) <> "TIC616" THEN  /* Const = 'TIC616' */
         glb_cdcritic = 173.
    ELSE
    IF   INT(SUBSTR(aux_setlinha,61,3)) <> crapcop.cdbcoctl THEN /* Nr cd bco */
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

       /* verificando se é a ultima linha do arquivo Trailler*/
       IF   SUBSTR(aux_setlinha,1,10) = "9999999999" THEN
            LEAVE TRANS_1.

       /* FECHAMENTO DE LOTE - DESCONSIDERAR A LINHA */
       IF   SUBSTR(aux_setlinha,29,10) = "9999900000" THEN
            NEXT.


       ASSIGN aux_nrdocmto = INT(SUBSTR(aux_setlinha,25,6))     /*Nro docmto */
              aux_nrseqarq = INT(SUBSTR(aux_setlinha,151,10))   /* seq  arq  */
              aux_cdbanchq = INT(SUBSTR(aux_setlinha,4,3))      /* Nr do Bco */
              aux_cdcmpchq = INT(SUBSTR(aux_setlinha,1,3))      /* Nro compe */
              aux_cdagechq = INT(SUBSTR(aux_setlinha,7,4))      /* Age dest  */
              aux_nrctachq = DEC(SUBSTR(aux_setlinha,12,12))    /* Nr ctachq */
              aux_cdocorre = INT(SUBSTR(aux_setlinha,139,2)) /* Ocorrencia   */
              aux_cdpesqbb = aux_setlinha NO-ERROR.

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

       IF   aux_cdocorre = 01  OR
            aux_cdocorre = 02  OR
            aux_cdocorre = 03  OR
            aux_cdocorre = 04  OR
            aux_cdocorre = 05  OR
            aux_cdocorre = 08  OR
            aux_cdocorre = 09  THEN
            NEXT.
            
       /*  Libera registro craprej .........................................*/
       RELEASE craprej.

       FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper AND 
                          crapcst.cdcmpchq = aux_cdcmpchq AND /* Nro compe */
                          crapcst.cdbanchq = aux_cdbanchq AND /* Nro do Bco*/
                          crapcst.cdagechq = aux_cdagechq AND /* Age dest  */
                          crapcst.nrctachq = aux_nrctachq AND /* Nr ctachq */
                          crapcst.nrcheque = aux_nrdocmto     /* Nro chq   */
						  crapcst.nrborder = 0
                          EXCLUSIVE-LOCK NO-ERROR.

       IF   AVAIL crapcst THEN
            DO:
                IF   aux_cdocorre <> 0 THEN
                     DO:
                         ASSIGN crapcst.flocotic = TRUE
                                crapcst.cdocotic = aux_cdocorre.
              
                         CREATE craprej.
                         ASSIGN craprej.cdcooper = glb_cdcooper
                                craprej.nrdconta = crapcst.nrdconta
                                craprej.dtdaviso = crapcst.dtlibera
                                craprej.dtmvtolt = crapcst.dtmvtolt
                                craprej.nrdctitg = 
                                        STRING(aux_nrctachq,"zzz,zzz,zzz,zzz,9")
                                craprej.nrdocmto = aux_nrdocmto /* Nro Docmto */
                                craprej.vllanmto = crapcst.vlcheque
                                craprej.nrseqdig = aux_nrseqarq /*  seq  arq  */
                                craprej.cdpesqbb = aux_cdpesqbb
                                craprej.dshistor = 
                                   STRING(crapcst.cdagenci,"999") + " " +
                                   STRING(crapcst.cdbccxlt,"999") + " " +
                                   STRING(crapcst.nrdolote,"zzz,zz9") 
                                craprej.cdcritic = aux_cdocorre.
                         VALIDATE craprej.
                     END.
                ELSE 
                     aux_qtcompln     = aux_qtcompln + 1.
            END.

       FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper AND
                          crapcdb.cdcmpchq = aux_cdcmpchq AND /* Nro compe  */
                          crapcdb.cdbanchq = aux_cdbanchq AND /* Nro do Bco */
                          crapcdb.cdagechq = aux_cdagechq AND /* Agen dest  */
                          crapcdb.nrctachq = aux_nrctachq AND /* Nro ctachq */
                          crapcdb.nrcheque = aux_nrdocmto     /* Nro chq    */
                          EXCLUSIVE-LOCK NO-ERROR.

       IF   AVAIL crapcdb THEN
            DO:
               IF   aux_cdocorre <> 0 THEN
                    DO:
                        ASSIGN crapcdb.flocotic = TRUE
                               crapcdb.cdocotic = aux_cdocorre.
        
                        CREATE craprej.
                        ASSIGN craprej.cdcooper = glb_cdcooper
                               craprej.nrdconta = crapcdb.nrdconta
                               craprej.dtdaviso = crapcdb.dtlibera
                               craprej.dtmvtolt = crapcdb.dtmvtolt
                               craprej.nrdctitg = 
                                       STRING(aux_nrctachq,"zzz,zzz,zzz,zzz,9")
                               craprej.nrdocmto = aux_nrdocmto /* Nro Docmto */
                               craprej.vllanmto = crapcdb.vlcheque
                               craprej.nrseqdig = aux_nrseqarq /* seq arq */
                               craprej.cdpesqbb = aux_cdpesqbb
                               craprej.dshistor = 
                                   STRING(crapcdb.cdagenci,"999") + " " +
                                   STRING(crapcdb.cdbccxlt,"999") + " " +
                                   STRING(crapcdb.nrdolote,"zzz,zz9")
                               craprej.cdcritic = aux_cdocorre.
                        VALIDATE craprej.
                    END.
               ELSE 
                    ASSIGN aux_qtcompln = aux_qtcompln + 1.
            END.    

   
    END. /* FIM do DO WHILE TRUE TRANSACTION */

    INPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " salvar").
    UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").

    ASSIGN tot_qtregrej = 0
           glb_cdcritic = 0
           glb_cdrelato = 626.

    { includes/cabrel132_1.i }

    ASSIGN aux_nmarqimp = "rl/crrl626_" + STRING(i,"99") +  ".lst"
           glb_cdempres = 11.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    DISPLAY STREAM str_1 tab_nmarqtel[i] aux_dtmvtolt  WITH FRAME f_cab.

    /* Considerar somente a data de liberacao superior a D+2, pelo motivo
       da compensacao da ABBC */
    
    aux_dtlimite = calc_prox_dia_util(glb_dtmvtopr + 1).
    
    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper AND
                           craprej.dtdaviso > aux_dtlimite
                           NO-LOCK BY craprej.dtdaviso:

        IF   LINE-COUNTER(str_1) > 82 THEN
             DO:
                 PAGE STREAM str_1.

                 DISPLAY STREAM str_1 tab_nmarqtel[i] aux_dtmvtolt
                                      WITH FRAME f_cab.
             END.

        ASSIGN aux_flgrejei = TRUE
               rel_dspesqbb = SUBSTRING(craprej.cdpesqbb,1,3) + " " +
                              SUBSTRING(craprej.cdpesqbb,4,3) + " " +
                              SUBSTRING(craprej.cdpesqbb,7,4)
               tot_qtregrej = tot_qtregrej + 1.
                             
        CASE craprej.cdcritic:
             WHEN 1 THEN ASSIGN glb_dscritic = "Conta Encerrada".
             WHEN 2 THEN ASSIGN glb_dscritic = "Cheque cancelado pelo cliente".
             WHEN 3 THEN ASSIGN glb_dscritic = 
                                         "Cheque cancelado pelo Banco sacado".
             WHEN 4 THEN ASSIGN glb_dscritic = "Cheque furtado/roubado".
             WHEN 5 THEN ASSIGN glb_dscritic = "Cheque malote roubado".
             WHEN 6 THEN ASSIGN glb_dscritic = "Registro inconsistente".
             WHEN 7 THEN ASSIGN glb_dscritic = 
                                         "Cheque já custodiado por outra IF".
             WHEN 8 THEN ASSIGN glb_dscritic = 
                                         "Registro duplicado pelo mesma IF".
             WHEN 9 THEN ASSIGN glb_dscritic = 
                                         "Registro para exclusão inexistente".
             WHEN 10 THEN ASSIGN glb_dscritic =  
                                         "Cheque liquidado anteriormente.".
             WHEN 11 THEN ASSIGN glb_dscritic = "Cheque inexistente".
             WHEN 12 THEN ASSIGN glb_dscritic = 
                                 "Registro efetuado por outra IF nesta data".

        END CASE.

        DISPLAY STREAM str_1  rel_dspesqbb      craprej.nrdctitg
                              craprej.nrdocmto  craprej.vllanmto
                              craprej.dtdaviso  craprej.nrdconta
                              craprej.dtmvtolt  craprej.dshistor
                              glb_dscritic      WITH FRAME f_lanctos.

        DOWN STREAM str_1 WITH FRAME f_lanctos.
    END.

    DISPLAY STREAM str_1 tot_qtregrej WITH FRAME f_total.
    
    OUTPUT STREAM str_1 CLOSE.

    glb_cdcritic = IF   aux_flgrejei THEN
                        191
                   ELSE 190.

    RUN fontes/critic.p.

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra +
                      "' --> '" + glb_dscritic + "' --> '" +  tab_nmarqtel[i] +
                      " >> log/proc_batch.log").

    ASSIGN glb_nrcopias = 1
           glb_nmformul = ""
           glb_nmarqimp = aux_nmarqimp
           glb_cdcritic = 0.

    RUN fontes/imprim.p.


    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper
                           TRANSACTION:
        DELETE craprej.
    END.

END.

RUN fontes/fimprg.p.

/* .......................................................................... */
