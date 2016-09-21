/* .............................................................................

   Programa: Fontes/crps384.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Fevereiro/2004                     Ultima atualizacao: 28/09/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Integrar arquivo de saques  BRADESCO CECRED.
               Emite relatorio 340.

   Alteracoes: 26/04/2004 - Verificacao de craplau ja existe, incrementa 
                            nrdocmto mais 10000. (Julio).

               15/07/2004 - So integra arquivo para central se ja tiver sido
                            processado pelas singulares. "Referencia VIACREDI"
                            (Julio)

               01/07/2005 - Alimentado campo cdcooper das tabelas craprej,
                            craplot e craplau (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               29/06/2006 - Excluir rel. fila de impressao-Central(Tarefa 7849)
                            (Mirtes)
                            
               28/05/2007 - Retirado vinculacao da execucao do imprim.p
                            com o codigo da cooperativa(Guilherme).
                  
               20/02/2008 - Retirada tabela crapsig(Mirtes)   

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               08/05/2009 - Listar criticas no relatorio da CECRED (Gabriel). 
               
               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo

               25/08/2010 - Acerto na integracao do arquivo (Ze).
               
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                          - Alterado o relatório do carsaq (Isara - KAM).
                          
               28/06/2011 - Ajustes no relatório do carsaq (Isara - KAM).
               
               30/09/2011 - Os lançamentos rejeitados das críticas 546 e 794 
                            devem ser listados somente no relatório da Cecred.
                          - Em caso de saque rejeitado, o valor não deve ser
                            lançado na conta da cooperativa.
                            (Isara - RKAM)
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               08/11/2011 - Ajuste nos lançamentos rejeitados para o valor
                            não ser debitado da conta da cooperativa (carsaq)
                            (Isara - RKAM)
                            
               03/06/2013 - Incluido no FIND craplau a condicao - 
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                            
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               21/01/2014 - Incluir VALIDATE craprej, craplot, craplau (Lucas R)
               
               14/02/2014 - Efetuada correcao para nao continuar concatenando
                            ao nome do arquivo ".err" se o arquivo ja estiver
                            co esta extensao (Tiago).
                            
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               28/09/2015 - incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho */

{ includes/var_batch.i {1} }

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

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(320)"               NO-UNDO.

DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR aux_nrdolote AS INT  INIT 6850                        NO-UNDO.
DEF        VAR aux_tplotmov AS INT                                   NO-UNDO.

DEF        VAR aux_tpregist AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR aux_nrdconta AS INTEGER                               NO-UNDO.
DEF        VAR aux_nmarqdeb AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgrejei AS LOGICAL                               NO-UNDO.

DEF        VAR tot_qtcrdrec AS INT                                   NO-UNDO.
DEF        VAR tot_qtcrdint AS INT                                   NO-UNDO.
DEF        VAR tot_qtcrdrej AS INT                                   NO-UNDO.
DEF        VAR tot_vltotrec AS DECI                                  NO-UNDO.
DEF        VAR tot_vltotint AS DECI                                  NO-UNDO.
DEF        VAR tot_vltotrej AS DECI                                  NO-UNDO.

DEF        VAR tot_qtreccop AS INT  EXTENT 99                        NO-UNDO.
DEF        VAR tot_qtintcop AS INT  EXTENT 99                        NO-UNDO.
DEF        VAR tot_qtrejcop AS INT  EXTENT 99                        NO-UNDO.
DEF        VAR tot_vlreccop AS DECI EXTENT 99                        NO-UNDO.
DEF        VAR tot_vlintcop AS DECI EXTENT 99                        NO-UNDO.
DEF        VAR tot_vlrejcop AS DECI EXTENT 99                        NO-UNDO.
DEF        VAR tot_qtrecger AS INT                                   NO-UNDO.
DEF        VAR tot_qtintger AS INT                                   NO-UNDO.
DEF        VAR tot_qtrjdger AS INT                                   NO-UNDO.
DEF        VAR tot_vlrecger AS DECI                                  NO-UNDO.
DEF        VAR tot_vlintger AS DECI                                  NO-UNDO.
DEF        VAR tot_vlrjdger AS DECI                                  NO-UNDO.
DEF        VAR aux_qttotinv AS INT                                   NO-UNDO.
DEF        VAR aux_vltotinv AS DECI                                  NO-UNDO.

DEF        VAR aux_dtmvtopg AS DATE                                  NO-UNDO.
DEF        VAR aux_cdcooper AS INT                                   NO-UNDO.
DEF        VAR aux_nrcrcard AS DECI                                  NO-UNDO.
DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.
DEF        VAR aux_nmtitula AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlfatura AS DECI                                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_nrsequen AS INT    INIT 0                         NO-UNDO.
                
DEF        VAR aux_flgtrans AS LOG                                   NO-UNDO.

DEF BUFFER bf-crapcop FOR crapcop.

DEF TEMP-TABLE tt-craprej NO-UNDO
    FIELD cdagenci LIKE craprej.cdagenci
    FIELD nrcrcard LIKE crapcrd.nrcrcard
    FIELD nrdconta LIKE craprej.nrdconta
    FIELD vllanmto LIKE craprej.vllanmto
    FIELD cdcritic LIKE craprej.cdcritic
    FIELD dshistor LIKE craprej.dshistor
    FIELD qtreccop AS INT 
    FIELD vlreccop AS DEC
    FIELD qtintcop AS INT
    FIELD vlintcop AS DEC
    FIELD qtrejcop AS INT
    FIELD vlrejcop AS DEC.

DEF TEMP-TABLE tt-critica NO-UNDO
    FIELD cdcooper LIKE crapass.cdcooper  FORMAT  "zzz,zzz,zz9"
    FIELD nrdconta LIKE crapass.nrdconta 
    FIELD nmtitula LIKE crapass.nmprimtl
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD dtmvtopg AS DATE
    FIELD vlfatura AS DEC                 FORMAT "z,zzz,zz9.99"
    FIELD dscritic AS CHAR                FORMAT "x(36)".
    
FORM aux_setlinha  FORMAT "x(320)"
     WITH FRAME AA WIDTH 320 NO-BOX NO-LABELS.

FORM SKIP(1)
     "ARQUIVO:"         AT 01
     aux_nmarquiv       AT 10 FORMAT "x(35)"    NO-LABEL
     aux_dtmvtopg       AT 45 LABEL "DATA DO DEBITO" FORMAT "99/99/9999"
     SKIP(1)
     glb_dtmvtolt       AT 01 FORMAT "99/99/9999" LABEL "DATA"
     aux_cdagenci       AT 19 FORMAT "zz9"        LABEL "PA"
     aux_cdbccxlt       AT 30 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     aux_nrdolote       AT 49 FORMAT "zzz,zz9"    LABEL "LOTE"
     aux_tplotmov       AT 63 FORMAT "99"         LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM SKIP(1)
     "CARTAO"         AT 01 
     "CONTA/DV"       AT 23 
     "NOME"           AT 32 
     "VALOR DO SAQUE" AT 65 
     "DATA SAQUE"     AT 80 
     "CRITICA"        AT 91 
     "------------------- ---------- ------------------------------ ----------------" AT 01 
     "---------- ------------------------------------"                                AT 80
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_cab_lanctos.

FORM craprej.cdpesqbb AT 01 FORMAT "x(19)"            
     craprej.nrdconta AT 21                           
     craprej.dshistor AT 32 FORMAT "x(30)"            
     craprej.vllanmto AT 63 FORMAT "zzzzz,zzz,zz9.99" 
     craprej.dtdaviso AT 80 FORMAT "99/99/9999"       
     aux_dscritic     AT 91 FORMAT "x(36)"  
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_lanctos.

FORM SKIP(1)
     tt-craprej.nrdconta AT 01                          
     tt-craprej.dshistor AT 12 FORMAT "x(65)"            
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_lanctos3.

FORM SKIP(1)
     "RECEBIDOS      INTEGRADOS      REJEITADOS"   AT  28
     SKIP(1)
     "QTD.CARTOES:"       AT 10
     tot_qtcrdrec         AT 30 FORMAT "zzz,zz9"
     tot_qtcrdint         AT 46 FORMAT "zzz,zz9"
     tot_qtcrdrej         AT 62 FORMAT "zzz,zz9"
     SKIP
     "TOTAL DE SAQUES:"   AT 06
     tot_vltotrec         AT 23 FORMAT "zzz,zzz,zz9.99"
     tot_vltotint         AT 39 FORMAT "zzz,zzz,zz9.99"
     tot_vltotrej         AT 55 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total.

FORM SKIP(2)
     "** TOTAL **"      AT 7
     SKIP(1)
     "RECEBIDOS      INTEGRADOS      REJEITADOS"   AT  28
     SKIP(1)
     "QTD.CARTOES:"     AT 10
     tot_qtrecger       AT 30 FORMAT "zzz,zz9"
     tot_qtintger       AT 46 FORMAT "zzz,zz9"
     tot_qtrjdger       AT 62 FORMAT "zzz,zz9"
     SKIP
     "TOTAL DE SAQUES:" AT 06
     tot_vlrecger       AT 23 FORMAT "zzz,zzz,zz9.99-"
     tot_vlintger       AT 39 FORMAT "zzz,zzz,zz9.99-"
     tot_vlrjdger       AT 55 FORMAT "zzz,zzz,zz9.99-"
     SKIP(2)
     WITH NO-BOX NO-LABELS DOWN COLUMN 8 WIDTH 132 FRAME f_total_geral.

FORM "COOP. CONTA/DV   NOME                        NUMERO DO CARTAO   " AT 06
     "DATA        VALOR           CRITICA"                              
     SKIP
     "     ----- ---------- --------------------------- -------------------" 
     "----------- --------------- ------------------------------"
     WITH WIDTH 132 COLUMN 1 NO-LABELS NO-ATTR-SPACE FRAME f_cab_critica.

FORM tt-critica.cdcooper AT 06   FORMAT "zzzz9"
     tt-critica.nrdconta AT 12  
     tt-critica.nmtitula AT 23   FORMAT "x(27)"
     tt-critica.nrcrcard AT 51 
     tt-critica.dtmvtopg AT 71   FORMAT "99/99/9999"
     tt-critica.vlfatura AT 83   FORMAT "zzzz,zzz,zz9.99-"
     tt-critica.dscritic AT 99   FORMAT "x(30)"
     WITH WIDTH 132 COLUMN 1 DOWN NO-LABELS FRAME f_critica.

FORM "TOTAL:"        AT 06
     aux_qttotinv    AT 58     FORMAT "zzz,zz9"
     aux_vltotinv    AT 83     FORMAT "zzzz,zzz,zz9.99-"
     SKIP
     WITH WIDTH 132 COLUMN 1 NO-LABELS FRAME f_total_invalidos.

FUNCTION f_ctacooper RETURN INTEGER (INPUT par_cdcooper AS INT):

  DEF   VAR fun_prhandle    AS  HANDLE                              NO-UNDO.
  DEF   VAR fun_nrctabra    AS  INT                                 NO-UNDO.
  
  IF   crapcop.cdcooper = 3   THEN
       DO:
          RUN fontes/util_cecred.p PERSISTENT SET fun_prhandle.
          
          RUN p_nrdctacoop IN fun_prhandle (INPUT  par_cdcooper, 
                                            OUTPUT fun_nrctabra).
            
          DELETE PROCEDURE fun_prhandle.
            
          RETURN fun_nrctabra.
            
       END.
  ELSE
       RETURN 0.
 
END.    
  
glb_cdprogra = "crps384".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

RUN p_consistearq(OUTPUT aux_contador).

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

DO  i = 1 TO aux_contador:

    ASSIGN aux_flgrejei = FALSE
           aux_flgfirst = TRUE
           aux_nmtitula = "".
    
    INPUT STREAM str_2 FROM VALUE("bradesco/" + tab_nmarqtel[i] + ".q")
                            NO-ECHO.

    DO WHILE TRUE:

       SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 320.

       aux_tpregist = SUBSTR(aux_setlinha,1,1).
    
       IF   aux_tpregist <> "0" THEN
            NEXT.
       
       LEAVE.     
            
    END.
    
    IF   aux_tpregist <> "0" THEN
         NEXT.
            
    ASSIGN aux_diarefer = INTEGER(SUBSTR(aux_setlinha,112,2))
           aux_mesrefer = INTEGER(SUBSTR(aux_setlinha,114,2))
           aux_anorefer = INTEGER(SUBSTR(aux_setlinha,116,4))

           aux_dtmvtolt = DATE(aux_mesrefer,aux_diarefer,aux_anorefer)
           
           aux_diarefer = INTEGER(SUBSTR(aux_setlinha,120,2))
           aux_mesrefer = INTEGER(SUBSTR(aux_setlinha,122,2))
           aux_anorefer = INTEGER(SUBSTR(aux_setlinha,124,4))
           
           aux_dtmvtopg = DATE(aux_mesrefer,aux_diarefer,aux_anorefer).

    IF   glb_inrestar <> 0 AND glb_nrctares = 0 THEN
     
         FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                craprej.dtrefere = glb_cdprogra  AND
                                craprej.dtmvtolt = aux_dtmvtopg  
                                EXCLUSIVE-LOCK TRANSACTION:
             DELETE craprej.
         END.
    
    IF   glb_inrestar <> 0 THEN
         DO:
             ASSIGN aux_nrdolote = INT(glb_dsrestar)
                    glb_inrestar = 0.
                    
             IF   aux_nrdolote = 0 THEN
                  aux_nrdolote = 6850.
         END.         
    ELSE
         DO WHILE TRUE:
               
            IF   CAN-FIND(craplot WHERE
                          craplot.cdcooper = glb_cdcooper   AND
                          craplot.dtmvtolt = glb_dtmvtolt   AND
                          craplot.cdagenci = 1              AND
                          craplot.cdbccxlt = 100            AND
                          craplot.nrdolote = aux_nrdolote         
                          USE-INDEX craplot1) THEN
                 DO:
                     aux_nrdolote = aux_nrdolote + 1.
                     NEXT.
                 END.

            LEAVE.
         END. 

    ASSIGN tot_qtreccop = 0
           tot_vlreccop = 0
           tot_qtintcop = 0
           tot_vlintcop = 0
           tot_qtrejcop = 0
           tot_vlrejcop = 0
           tot_qtrecger = 0 
           tot_qtintger = 0 
           tot_qtrjdger = 0 
           tot_vlrecger = 0 
           tot_vlintger = 0 
           tot_vlrjdger = 0.

    EMPTY TEMP-TABLE tt-critica.
    EMPTY TEMP-TABLE tt-craprej.

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 320.

       aux_tpregist = SUBSTR(aux_setlinha,1,1).

       IF   aux_tpregist = "3" THEN
            DO:
                NEXT.
            END.
       ELSE
       IF   aux_tpregist = "0" THEN
            DO:
                NEXT.
            END.
       ELSE
       IF   aux_tpregist = "2" THEN
            DO:
                ASSIGN aux_cdcooper = INT(SUBSTR(aux_setlinha,21,7))    
                       aux_nrcrcard = DECI(SUBSTR(aux_setlinha,46,16))
                       aux_nmtitula = SUBSTR(aux_setlinha,160,30)
                       aux_vlfatura = 0 
                       aux_flgfirst = FALSE
                       aux_vlfatura = DECIMAL(SUBSTR(aux_setlinha,77,15)) / 100.                
                ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,292,15))
                       NO-ERROR.

                IF   ERROR-STATUS:ERROR THEN
                     ASSIGN aux_nrdconta = 0.

                CREATE tt-craprej.
                ASSIGN tt-craprej.cdagenci = aux_cdcooper
                       tt-craprej.nrcrcard = aux_nrcrcard.

                IF aux_cdcooper = crapcop.cdcooper THEN
                DO: 
                    ASSIGN aux_nrsequen = aux_nrsequen + 1.
                  
                    FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper AND
                                       crapcrd.nrcrcard = aux_nrcrcard
                                       NO-LOCK NO-ERROR.
                    IF   NOT AVAILABLE crapcrd THEN
                         aux_regexist = FALSE.
                    ELSE
                         aux_regexist = TRUE.

                    CREATE craprej.
                    ASSIGN craprej.dtrefere = glb_cdprogra
                           craprej.cdagenci = aux_cdcooper
                           craprej.dtmvtolt = aux_dtmvtopg
                           craprej.dtdaviso = aux_dtmvtolt
                           craprej.nrdconta = IF  aux_regexist 
                                              THEN crapcrd.nrdconta 
                                              ELSE aux_nrdconta
                           craprej.dshistor = aux_nmtitula
                           craprej.cdpesqbb = 
                                STRING(aux_nrcrcard,"9999,9999,9999,9999")
                           craprej.vllanmto = aux_vlfatura
                           craprej.nrdocmto = aux_nrsequen
                           craprej.cdcooper = glb_cdcooper
                           craprej.cdcritic = IF (aux_vlfatura <= 0 OR 
                                                  NOT aux_regexist) 
                                              THEN 1 
                                              ELSE 0. 
                        VALIDATE craprej.
                    
                END.
                ELSE
                IF crapcop.cdcooper = 3 THEN
                DO:
                    ASSIGN aux_nrsequen = aux_nrsequen + 1.

                    /* COOPERATIVA INVALIDA */
                    FIND FIRST bf-crapcop NO-LOCK
                         WHERE bf-crapcop.cdcooper = aux_cdcooper NO-ERROR.
                    IF NOT AVAIL bf-crapcop THEN
                    DO:
                        ASSIGN glb_cdcritic = 794.
                                         
                        RUN fontes/critic.p.
                        
                        CREATE tt-critica.
                        ASSIGN tt-critica.cdcooper = aux_cdcooper
                               tt-critica.nrdconta = aux_nrdconta
                               tt-critica.nmtitula = aux_nmtitula
                               tt-critica.nrcrcard = aux_nrcrcard  
                               tt-critica.dtmvtopg = aux_dtmvtopg
                               tt-critica.vlfatura = aux_vlfatura
                               tt-critica.dscritic = glb_dscritic.
                    END.
                    ELSE
                    DO:
                        /* CARTAO INVALIDO */
                        FIND FIRST crapcrd NO-LOCK 
                             WHERE crapcrd.cdcooper = aux_cdcooper                  
                               AND crapcrd.nrcrcard = aux_nrcrcard NO-ERROR.
                        IF NOT AVAIL crapcrd THEN
                        DO:
                            glb_cdcritic = 546.
                                             
                            RUN fontes/critic.p.
                        
                            CREATE tt-critica.
                            ASSIGN tt-critica.cdcooper = aux_cdcooper
                                   tt-critica.nrdconta = aux_nrdconta
                                   tt-critica.nmtitula = aux_nmtitula
                                   tt-critica.nrcrcard = aux_nrcrcard  
                                   tt-critica.dtmvtopg = aux_dtmvtopg 
                                   tt-critica.vlfatura = aux_vlfatura
                                   tt-critica.dscritic = glb_dscritic.
                        END.
                    END.

                    aux_nrdconta = f_ctacooper(aux_cdcooper).

                    FIND craprej WHERE craprej.cdcooper = glb_cdcooper AND
                                       craprej.dtrefere = glb_cdprogra AND
                                       craprej.cdagenci = aux_cdcooper AND
                                       craprej.dtmvtolt = aux_dtmvtopg AND
                                       craprej.nrdconta = aux_nrdconta
                                       EXCLUSIVE-LOCK NO-ERROR.
                    IF  AVAILABLE craprej   THEN
                    DO:
                        IF NOT (glb_cdcritic = 546  OR
                                glb_cdcritic = 794) THEN
                            craprej.vllanmto = craprej.vllanmto +
                                               aux_vlfatura.
                    END.
                    ELSE
                    DO:
                        FIND crapass WHERE 
                             crapass.cdcooper = glb_cdcooper AND
                             crapass.nrdconta = aux_nrdconta
                             NO-LOCK NO-ERROR.
                                     
                        CREATE craprej.
                        ASSIGN craprej.dtrefere = glb_cdprogra
                               craprej.cdpesqbb =
                               STRING(aux_nrcrcard,"9999,9999,9999,9999")
                               craprej.cdagenci = aux_cdcooper
                               craprej.dtmvtolt = aux_dtmvtopg
                               craprej.dtdaviso = aux_dtmvtolt
                               craprej.nrdconta = aux_nrdconta
                               craprej.dshistor = crapass.nmprimtl
                                                  WHEN AVAILABLE
                                                       crapass
                               craprej.nrdocmto = aux_nrsequen
                               craprej.cdcooper = glb_cdcooper
                               craprej.cdcritic = IF (aux_vlfatura <= 0 OR
                                                      NOT AVAIL crapass)
                                                  THEN 1 
                                                  ELSE 0.
                                
                               IF NOT (glb_cdcritic = 546  OR
                                       glb_cdcritic = 794) THEN
                                   craprej.vllanmto = aux_vlfatura.
                            VALIDATE craprej.
                    END.

                    glb_cdcritic = 0.

                    FOR FIRST tt-craprej
                        WHERE tt-craprej.cdagenci = aux_cdcooper
                          AND tt-craprej.nrcrcard = aux_nrcrcard:
                    
                        FIND FIRST crapcrd NO-LOCK 
                             WHERE crapcrd.cdcooper = tt-craprej.cdagenci 
                               AND crapcrd.nrcrcard = tt-craprej.nrcrcard NO-ERROR.                     
                        IF   NOT AVAILABLE crapcrd THEN
                             aux_regexist = FALSE.
                        ELSE
                             aux_regexist = TRUE.
                       
                        FIND FIRST bf-crapcop NO-LOCK
                             WHERE bf-crapcop.cdcooper = tt-craprej.cdagenci NO-ERROR.

                        ASSIGN tt-craprej.nrdconta = aux_nrdconta
                               tt-craprej.vllanmto = aux_vlfatura
                               tt-craprej.cdcritic = IF (aux_vlfatura <= 0 OR 
                                                         NOT aux_regexist) 
                                                     THEN 1 
                                                     ELSE 0
                               tt-craprej.dshistor = bf-crapcop.nmrescop + " - " +  bf-crapcop.nmextcop
                                                     WHEN AVAIL bf-crapcop.

                        IF aux_cdcooper > 0 THEN
                        DO:
                            IF tt-craprej.cdcritic = 0 THEN
                                ASSIGN tot_qtreccop[aux_cdcooper] = tot_qtreccop[aux_cdcooper] + 1
                                       tot_vlreccop[aux_cdcooper] = tot_vlreccop[aux_cdcooper] + tt-craprej.vllanmto
                                       tot_qtintcop[aux_cdcooper] = tot_qtintcop[aux_cdcooper] + 1
                                       tot_vlintcop[aux_cdcooper] = tot_vlintcop[aux_cdcooper] + tt-craprej.vllanmto.
                            ELSE
                                ASSIGN tot_qtreccop[aux_cdcooper] = tot_qtreccop[aux_cdcooper] + 1
                                       tot_vlreccop[aux_cdcooper] = tot_vlreccop[aux_cdcooper] + tt-craprej.vllanmto
                                       tot_qtrejcop[aux_cdcooper] = tot_qtrejcop[aux_cdcooper] + 1
                                       tot_vlrejcop[aux_cdcooper] = tot_vlrejcop[aux_cdcooper] + tt-craprej.vllanmto.
                         
                            ASSIGN tt-craprej.qtreccop = tot_qtreccop[aux_cdcooper]            
                                   tt-craprej.vlreccop = tot_vlreccop[aux_cdcooper]            
                                   tt-craprej.qtintcop = tot_qtintcop[aux_cdcooper]            
                                   tt-craprej.vlintcop = tot_vlintcop[aux_cdcooper]            
                                   tt-craprej.qtrejcop = tot_qtrejcop[aux_cdcooper]            
                                   tt-craprej.vlrejcop = tot_vlrejcop[aux_cdcooper].           
                        END.
                    END.
                END.
            END.
    END. /* FIM do DO WHILE TRUE TRANSACTION */

    DO TRANSACTION: 
    
       CREATE craprej.
       ASSIGN craprej.nrdconta = 99999999
              craprej.cdcritic = 1
              craprej.cdcooper = glb_cdcooper
              craprej.dtrefere = glb_cdprogra
              craprej.dtmvtolt = aux_dtmvtopg.

       VALIDATE craprej.
    END.
                    
    INPUT STREAM str_2 CLOSE.

    ASSIGN tot_qtcrdrec = 0
           tot_qtcrdint = 0    
           tot_qtcrdrej = 0
           tot_vltotrec = 0    
           tot_vltotint = 0
           tot_vltotrej = 0 
           glb_cdcritic = 0    
           aux_flgfirst = TRUE.

    /* CRIACAO DO LAU */

    TRANS_2:
    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                           craprej.dtrefere = glb_cdprogra  AND
                           craprej.dtmvtolt = aux_dtmvtopg  AND 
                           craprej.cdcritic = 0             NO-LOCK
                           BY craprej.nrdconta TRANSACTION:

        ASSIGN tot_qtcrdrec = tot_qtcrdrec + 1
               tot_vltotrec = tot_vltotrec + craprej.vllanmto
               tot_qtcrdint = tot_qtcrdint + 1
               tot_vltotint = tot_vltotint + craprej.vllanmto.
               
        IF   glb_nrctares >= craprej.nrdconta THEN
             NEXT.

        DO WHILE TRUE: 
                            
           FIND craplot WHERE  craplot.cdcooper = glb_cdcooper  AND
                               craplot.dtmvtolt = glb_dtmvtolt  AND
                               craplot.cdagenci = 1             AND
                               craplot.cdbccxlt = 100           AND
                               craplot.nrdolote = aux_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE craplot   THEN
                IF   LOCKED craplot   THEN
                     DO:
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:

                         CREATE craplot.
                         ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                craplot.dtmvtopg = glb_dtmvtolt
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.cdbccxpg = 237
                                craplot.cdhistor = 300
                                craplot.cdoperad = "1"
                                craplot.nrdolote = aux_nrdolote
                                craplot.tplotmov = 17
                                craplot.tpdmoeda = 1
                                craplot.cdcooper = glb_cdcooper.
                         
                     END.
           LEAVE.        

        END.  /*  Fim do DO WHILE TRUE  */

        DO WHILE TRUE:

           FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                              crapres.cdprogra = glb_cdprogra
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crapres   THEN
                IF   LOCKED crapres   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 151.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic +
                                           " >> log/proc_batch.log").
                                           UNDO TRANS_2, RETURN.
                     END.
           
           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
  
        aux_nrsequen = 0.

        FIND craplau WHERE craplau.cdcooper  = glb_cdcooper      AND
                           craplau.dtmvtolt  = craplot.dtmvtolt  AND
                           craplau.cdagenci  = craplot.cdagenci  AND
                           craplau.cdbccxlt  = craplot.cdbccxlt  AND
                           craplau.nrdolote  = craplot.nrdolote  AND
                           craplau.nrdctabb  = craprej.nrdconta  AND
                           craplau.nrdocmto  = craprej.nrdocmto  AND
                           craplau.dsorigem <> "CAIXA"           AND
                           craplau.dsorigem <> "INTERNET"        AND
                           craplau.dsorigem <> "TAA"             AND
                           craplau.dsorigem <> "PG555"           AND
                           craplau.dsorigem <> "CARTAOBB"        AND
                           craplau.dsorigem <> "BLOQJUD"         AND
                           craplau.dsorigem <> "DAUT BANCOOB"
                           NO-LOCK NO-ERROR.
        IF   AVAILABLE craplau   THEN
             aux_nrsequen = craprej.nrdocmto.
                             
        DO WHILE AVAILABLE craplau:

           aux_nrsequen = aux_nrsequen + 10000.
           
           FIND craplau WHERE craplau.cdcooper  = glb_cdcooper      AND
                              craplau.dtmvtolt  = craplot.dtmvtolt  AND
                              craplau.cdagenci  = craplot.cdagenci  AND
                              craplau.cdbccxlt  = craplot.cdbccxlt  AND
                              craplau.nrdolote  = craplot.nrdolote  AND
                              craplau.nrdctabb  = craprej.nrdconta  AND
                              craplau.nrdocmto  = aux_nrsequen      AND
                              craplau.nrseqdig  = aux_nrsequen      AND
                              craplau.dsorigem <> "CAIXA"           AND
                              craplau.dsorigem <> "INTERNET"        AND
                              craplau.dsorigem <> "TAA"             AND
                              craplau.dsorigem <> "PG555"           AND
                              craplau.dsorigem <> "CARTAOBB"        AND
                              craplau.dsorigem <> "BLOQJUD"         AND
                              craplau.dsorigem <> "DAUT BANCOOB"
                              NO-LOCK NO-ERROR.
        END.

        IF craprej.vllanmto > 0 THEN
        DO:
            CREATE craplau.
            ASSIGN craplau.cdagenci = craplot.cdagenci
                   craplau.cdbccxlt = craplot.cdbccxlt
                   craplau.cdbccxpg = craplot.cdbccxpg
                   craplau.cdcritic = 0
                   craplau.cdhistor = craplot.cdhistor
                   craplau.dtdebito = ?
                   craplau.dtmvtolt = craplot.dtmvtolt
                   craplau.dtmvtopg = craplot.dtmvtopg
                   craplau.insitlau = 3
                   craplau.nrcrcard = DECI(craprej.cdpesqbb)
                   craplau.nrdconta = craprej.nrdconta
                   craplau.nrdctabb = craprej.nrdconta
                   craplau.nrdocmto = craprej.nrdocmto + aux_nrsequen
                   craplau.nrdolote = craplot.nrdolote
                   craplau.nrseqdig = craprej.nrdocmto + aux_nrsequen
                   craplau.nrseqlan = craprej.nrdocmto + aux_nrsequen
                   craplau.tpdvalor = 1
                   craplau.cdseqtel = ""
                   craplau.vllanaut = craprej.vllanmto
                   craplau.cdcooper = glb_cdcooper
    
                   craplot.nrseqdig = craplot.nrseqdig + 1
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
                   craplot.vlcompcr = 0
                   craplot.vlinfodb = craplot.vlcompdb
                   craplot.vlinfocr = 0
    
                   crapres.nrdconta = craprej.nrdconta
                   crapres.dsrestar = STRING(aux_nrdolote).
            VALIDATE craplau.
        END.

        VALIDATE craplot.
    END.  /* FOR EACH CRAPREJ */  

    { includes/cabrel132_1.i }

    ASSIGN aux_nmarqimp = "rl/crrl340_" + STRING(i,"999") + ".lst"
           aux_cdagenci = 1
           aux_cdbccxlt = 100
           aux_tplotmov = 17
           aux_nmarquiv = tab_nmarqtel[i]
           aux_dscritic = "546 - CARTAO NAO ENCONTRADO"
           aux_flgrejei = FALSE.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    /* CRIACAO DO RELATORIO  */

    IF NOT crapcop.cdcooper = 3 THEN
    DO:
        FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper AND
                               craprej.dtrefere = glb_cdprogra AND
                               craprej.dtmvtolt = aux_dtmvtopg NO-LOCK
                               BREAK BY craprej.cdcritic 
                                     BY craprej.nrdconta:
    
            IF   craprej.cdcritic = 0 THEN
                 aux_dscritic = "INTEGRACAO EFETUADA COM SUCESSO".
            ELSE
            DO:
                glb_cdcritic = 546.
                RUN fontes/critic.p.
                aux_dscritic = glb_dscritic.
            END. 
             
            IF   craprej.nrdconta = 99999999   THEN
                 DO:
                     IF   LINE-COUNTER(str_1) > 77 THEN
                          DO:
                              PAGE STREAM str_1.
                          
                              DISPLAY STREAM str_1
                                      aux_nmarquiv     
                                      aux_dtmvtopg
                                      glb_dtmvtolt
                                      aux_cdagenci     
                                      aux_cdbccxlt     
                                      aux_nrdolote     
                                      aux_tplotmov  
                                      WITH FRAME f_cab.
    
                              DOWN STREAM str_1 WITH FRAME f_cab.
                          END.

                     DISPLAY STREAM str_1 
                                    tot_qtcrdrec 
                                    tot_qtcrdint 
                                    tot_qtcrdrej 
                                    tot_vltotrec 
                                    tot_vltotint 
                                    tot_vltotrej
                                    WITH FRAME f_total.
                     LEAVE.
                 END.
    
            IF   craprej.cdcritic = 1    THEN
                 ASSIGN tot_qtcrdrec = tot_qtcrdrec + 1
                        tot_vltotrec = tot_vltotrec + craprej.vllanmto
                        aux_flgrejei = TRUE
                        tot_qtcrdrej = tot_qtcrdrej + 1
                        tot_vltotrej = tot_vltotrej + craprej.vllanmto.
    
            IF   aux_flgfirst   OR   LINE-COUNTER(str_1) > 80 THEN
                 DO:
                     IF   LINE-COUNTER(str_1) > 80 THEN
                          PAGE STREAM str_1.
    
                     DISPLAY STREAM str_1
                             aux_nmarquiv     
                             aux_dtmvtopg
                             glb_dtmvtolt    
                             aux_cdagenci     
                             aux_cdbccxlt   
                             aux_nrdolote     
                             aux_tplotmov                         
                             WITH FRAME f_cab.
    
                     DOWN STREAM str_1 WITH FRAME f_cab.
    
                     aux_flgfirst = FALSE.
                 END.
    
            IF   craprej.cdagenci = crapcop.cdcooper    THEN
            DO:
                IF NOT (glb_cdcritic = 546  OR
                        glb_cdcritic = 794) THEN
                DO:
                    IF FIRST-OF(craprej.cdcritic) THEN
                        DISPLAY STREAM str_1 WITH FRAME f_cab_lanctos.
                    
                    DISPLAY STREAM str_1
                                   craprej.cdpesqbb  
                                   craprej.nrdconta 
                                   craprej.dshistor  
                                   craprej.vllanmto  
                                   craprej.dtdaviso  
                                   aux_dscritic
                                   WITH FRAME f_lanctos.
                           
                    DOWN STREAM str_1 WITH FRAME f_lanctos.       
                END.
            END.    
        END.
    END.
    ELSE
    DO:
        FOR EACH tt-craprej
           WHERE tt-craprej.nrdconta > 0
             AND tt-craprej.vllanmto > 0
           BREAK BY tt-craprej.cdagenci:

            IF FIRST(tt-craprej.cdagenci) THEN
            DO: 
                DISPLAY STREAM str_1
                               aux_nmarquiv                                
                               aux_dtmvtopg                                
                               glb_dtmvtolt                                
                               aux_cdagenci                                
                               aux_cdbccxlt                                
                               aux_nrdolote                                
                               aux_tplotmov                                
                               WITH FRAME f_cab.                           
                                                                           
                DOWN STREAM str_1 WITH FRAME f_cab.                        
            END.                                                           
            
            IF LAST-OF(tt-craprej.cdagenci) THEN
            DO:
                ASSIGN tot_qtrecger = tot_qtrecger + tt-craprej.qtreccop
                       tot_qtintger = tot_qtintger + tt-craprej.qtintcop
                       tot_qtrjdger = tot_qtrjdger + tt-craprej.qtrejcop
                       tot_vlrecger = tot_vlrecger + tt-craprej.vlreccop
                       tot_vlintger = tot_vlintger + tt-craprej.vlintcop
                       tot_vlrjdger = tot_vlrjdger + tt-craprej.vlrejcop.
                
                DISPLAY STREAM str_1
                               tt-craprej.nrdconta 
                               tt-craprej.dshistor  
                               WITH FRAME f_lanctos3.
                       
                DOWN STREAM str_1 WITH FRAME f_lanctos3.  

                DISPLAY STREAM str_1 
                               tt-craprej.qtreccop @ tot_qtcrdrec 
                               tt-craprej.qtintcop @ tot_qtcrdint 
                               tt-craprej.qtrejcop @ tot_qtcrdrej 
                               tt-craprej.vlreccop @ tot_vltotrec 
                               tt-craprej.vlintcop @ tot_vltotint 
                               tt-craprej.vlrejcop @ tot_vltotrej
                               WITH FRAME f_total.
            END. 

            IF LAST(tt-craprej.cdagenci) THEN
            DO:
                DISPLAY STREAM str_1 
                               tot_qtrecger
                               tot_qtintger
                               tot_qtrjdger
                               tot_vlrecger
                               tot_vlintger
                               tot_vlrjdger
                               WITH FRAME f_total_geral.

                FOR EACH tt-critica
                    BREAK BY tt-critica.cdcooper:

                    IF FIRST-OF(tt-critica.cdcooper) THEN
                        DISPLAY STREAM str_1 WITH FRAME f_cab_critica.

                    IF FIRST-OF(tt-critica.cdcooper) THEN 
                        ASSIGN aux_qttotinv = 0
                               aux_vltotinv = 0.

                    ASSIGN aux_qttotinv = aux_qttotinv + 1 
                           aux_vltotinv = aux_vltotinv + tt-critica.vlfatura.
                
                    DISPLAY STREAM str_1
                                   tt-critica.cdcooper
                                   tt-critica.nrdconta
                                   tt-critica.nmtitula
                                   tt-critica.nrcrcard
                                   tt-critica.dtmvtopg
                                   tt-critica.vlfatura
                                   tt-critica.dscritic
                                   WITH FRAME f_critica.

                    DOWN STREAM str_1 WITH FRAME f_critica.

                    IF LAST-OF(tt-critica.cdcooper) THEN
                        DISPLAY STREAM str_1
                                       aux_qttotinv 
                                       aux_vltotinv
                                       WITH FRAME f_total_invalidos.
                END.
            END.
        END.
    END.

    IF aux_flgfirst             AND 
       NOT crapcop.cdcooper = 3 THEN
    DO:
        DISPLAY STREAM str_1
                aux_nmarquiv     
                aux_dtmvtopg
                glb_dtmvtolt
                aux_cdagenci     
                aux_cdbccxlt     
                aux_nrdolote     
                aux_tplotmov     
                WITH FRAME f_cab.

        DOWN STREAM str_1 WITH FRAME f_cab.
                 
        DISPLAY STREAM str_1 
                       tot_qtcrdrec 
                       tot_qtcrdint 
                       tot_qtcrdrej 
                       tot_vltotrec 
                       tot_vltotint 
                       tot_vltotrej
                       WITH FRAME f_total.
    END.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("rm bradesco/" + tab_nmarqtel[i] + 
                      ".q 2> /dev/null").

    UNIX SILENT VALUE("mv bradesco/" + tab_nmarqtel[i] + "* salvar"). 
    
    glb_cdcritic = IF aux_flgrejei THEN 191 ELSE 190.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                      glb_dscritic + "' --> '" +  tab_nmarqtel[i] +
                      " >> log/proc_batch.log").

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                           craprej.dtrefere = glb_cdprogra  AND
                           craprej.dtmvtolt = aux_dtmvtopg  
                           EXCLUSIVE-LOCK TRANSACTION:
        DELETE craprej.
    END.
    
    DO TRANSACTION:
       DO WHILE TRUE:

          FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                             crapres.cdprogra = glb_cdprogra
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapres   THEN
               IF   LOCKED crapres   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 151.
                        RUN fontes/critic.p.
                        UNIX SILENT 
                             VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " >> log/proc_batch.log").
                        UNDO ,RETURN.
                    END.
              LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */
  
       ASSIGN crapres.nrdconta = 0
              glb_nrcopias = 1
              glb_nmformul = ""
              glb_nmarqimp = aux_nmarqimp.

    END. /* DO TRANSACTION */
    
    RUN fontes/imprim.p.

END.

RUN fontes/fimprg.p.

/*****  PROCEDURE RESPONSAVEL POR CONSISTIR O CONTEUDO DO ARQUIVO A SER
        PROCESSADO (Data, Quant. Registros e Numero da Conta no Bradesco) ****/

PROCEDURE p_consistearq:

    DEF OUTPUT PARAMETER  par_contaarq   AS INTEGER  INIT 0           NO-UNDO.

    DEF             VAR   pro_nrdconta   AS CHAR                      NO-UNDO.
    DEF             VAR   pro_dtarquiv   AS CHAR                      NO-UNDO.
    DEF             VAR   pro_flgerros   AS LOGICAL                   NO-UNDO.
    DEF             VAR   pro_qtregist   AS INTEGER                   NO-UNDO.

    DEF             VAR   aux_extensao   AS CHAR                      NO-UNDO.

    ASSIGN aux_nmarqdeb = "carsaq*"
           pro_qtregist = 0.
           pro_nrdconta = "2656-0164666".
              
    INPUT STREAM str_1 THROUGH VALUE( "ls bradesco/" + aux_nmarqdeb +
                                      " 2> /dev/null") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
        
       SET STREAM str_1 aux_nmarquiv FORMAT "x(40)" .

       IF   glb_cdcooper = 3   THEN
            IF   SEARCH("/usr/coop/viacredi/" + aux_nmarquiv) <> ? THEN  
                 NEXT.

       par_contaarq = par_contaarq + 1.

       UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                          aux_nmarquiv + "_ux 2> /dev/null").
       
       UNIX SILENT VALUE("mv " + aux_nmarquiv + "_ux " + aux_nmarquiv +
                         " 2> /dev/null").
       
       UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                          aux_nmarquiv + ".q 2> /dev/null").

       tab_nmarqtel[par_contaarq] =  SUBSTR(aux_nmarquiv,
                                            INDEX(aux_nmarquiv, "carsaq"),
                                                     LENGTH(aux_nmarquiv)).

       INPUT STREAM str_2 FROM VALUE("bradesco/" +
                                    tab_nmarqtel[par_contaarq] + ".q") NO-ECHO.

       glb_cdcritic = 0.

       DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
     
          SET STREAM str_2 aux_setlinha WITH FRAME AA.
          
          ASSIGN pro_qtregist = pro_qtregist + 1.
          
          IF   SUBSTR(aux_setlinha, 1, 1) = "0"   THEN
               DO:
                   pro_dtarquiv = SUBSTR(aux_setlinha, 112, 8).

                   IF   TRIM(pro_dtarquiv) = ""   THEN
                        DO:
                            ASSIGN pro_dtarquiv = "err"
                                   pro_flgerros = TRUE
                                   glb_cdcritic = 789.
                        END.
               END.
          ELSE
          IF   SUBSTR(aux_setlinha, 1, 1) = "2"   THEN
               DO:
                   pro_flgerros = (INDEX(aux_setlinha, pro_nrdconta) = 0).
 
                   IF   pro_flgerros   THEN
                        glb_cdcritic = 127.
               END.
          ELSE
          IF   SUBSTR(aux_setlinha, 1, 1) = "3"   THEN
               DO:
                   pro_flgerros = INT(SUBSTR(aux_setlinha, 56, 7)) <> 
                                                    (pro_qtregist).           
                   IF   pro_flgerros   THEN
                        glb_cdcritic = 504.
               END.              
               
          IF   pro_flgerros   THEN
               LEAVE.               
       END.
 
       IF   pro_flgerros   THEN      
            DO:       
                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.

                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                            + " - " + glb_cdprogra + "' --> '"
                                            + glb_dscritic + "' --> '" + 
                                            tab_nmarqtel[par_contaarq] +
                                            " >> log/proc_batch.log").
                     END.

                
                aux_extensao = SUBSTR(tab_nmarqtel[par_contaarq],
                                      LENGTH(tab_nmarqtel[par_contaarq]) - 3, 
                                      LENGTH(tab_nmarqtel[par_contaarq])).    

                IF  NOT aux_extensao MATCHES ".err" THEN
                    DO: 
                        UNIX SILENT VALUE("mv bradesco/" +
                                          tab_nmarqtel[par_contaarq] +
                                          " bradesco/" +
                                           tab_nmarqtel[par_contaarq] +
                                          ".err 2> /dev/null").
                    END.

                UNIX SILENT VALUE("rm bradesco/" +
                             tab_nmarqtel[par_contaarq] + ".q 2> /dev/null").
                    
                ASSIGN tab_nmarqtel[par_contaarq] = ""
                       par_contaarq = par_contaarq - 1
                       pro_flgerros = FALSE.
            END.
       ELSE
            DO:
                UNIX SILENT VALUE("mv bradesco/" +
                                  tab_nmarqtel[par_contaarq] +
                                  " bradesco/" +
                                  tab_nmarqtel[par_contaarq] + 
                                  "." + pro_dtarquiv + " 2> /dev/null"). 
            END.
      
       ASSIGN pro_qtregist = 0.
       
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
    INPUT STREAM str_2 CLOSE.
END.

/* .......................................................................... */

