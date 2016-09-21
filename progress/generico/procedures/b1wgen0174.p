/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0174.p
    Autor   : Oliver Fagionato (GATI)
    Data    : Agosto/2013                       Ultima Altualizacao: 29/02/2016

    Objetivo  : Possuir todas as regras de negocio da tela CLDMES.

    Alteracoes: 24/02/2014 - Incluir Procedure que retorna o ultimo dia util 
                            do mes calcula_ultimo_dia_util (Lucas R.)
                            
                06/03/2014 - Incluso VALIDATE (Daniel).
                
                07/03/2014 - Ajustando o fonte (Carlos)
               
                24/11/2014 - Ajustes para liberação (Adriano).

                17/12/2014 - Remover o campo crapass.cdagenci no FIND na 
                             Carrega_creditos. (Douglas - Chamado 143945)

                30/12/2014 - Adicionar validacao para realizar o fechamento 
                             mensal, verificando se existem movimentacoes 
                             para o mês que ainda não foram fechadas.
                             (Douglas - Chamado 143945)

                25/05/2015 - Ajustar procedure gera_relatorio_diario para 
                             que as informações do relatório sejam carregadas
                             coma data informada na tela e não a data 
                             glb_dtmvtolt. (Douglas - 282637)
                             
                29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                             solicitado no chamado 402159 (Kelvin).
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0174tt.i }

DEF STREAM str_1.

PROCEDURE Fechamento_diario:
 
    DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_tdtmvtol AS DATE                            NO-UNDO.
                                                              
    DEF OUTPUT PARAM TABLE FOR tt-erro.                       
                                                                     
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_contador = 0.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop  THEN
       DO:
          ASSIGN aux_cdcritic = 651
                 aux_dscritic = "".
          
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

        END. 

    RUN calcula_ultimo_dia_util(INPUT par_cdcooper,
                                INPUT par_tdtmvtol,
                                OUTPUT par_tdtmvtol).


    /** Para realizar o fechamento mensal, deve-se verificar se não existe 
        nenhuma movimentação para o mês que ainda não foi fechada. 
        Pegar todas as datas que estão na crapcld e verificar se ela existe
        ne crapfld */
    FOR EACH crapcld WHERE crapcld.cdcooper = par_cdcooper               AND 
                           crapcld.cdtipcld = 1 /* Diario COOP */        AND
                           MONTH(crapcld.dtmvtolt) = MONTH(par_tdtmvtol) AND
                           YEAR(crapcld.dtmvtolt)  = YEAR(par_tdtmvtol)  NO-LOCK
                     BREAK BY crapcld.dtmvtolt:

        IF FIRST-OF(crapcld.dtmvtolt) THEN
        DO:
            FIND crapfld WHERE crapfld.cdcooper = crapcld.cdcooper AND
                               crapfld.dtmvtolt = crapcld.dtmvtolt AND
                               crapfld.cdtipcld = 1 /* Diario COOP */
                         NO-LOCK NO-ERROR.

            IF NOT AVAIL crapfld THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Existem movimentacoes que nao possuem " +
                                      "fechamento diario pela CLDSED, no mes " +
                                      STRING(MONTH(crapcld.dtmvtolt),"99") + 
                                      "/" + STRING(YEAR(crapcld.dtmvtolt)).

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.
        END.
    END.


    ContadorFld: 
    DO aux_contador = 1 TO 10:

       FIND crapfld WHERE crapfld.cdcooper = par_cdcooper AND 
                          crapfld.dtmvtolt = par_tdtmvtol AND 
                          crapfld.cdtipcld = 2 /* DIARIO COOP */ 
                          NO-LOCK NO-ERROR.
    
       IF AVAIL crapfld THEN
          DO:
             ASSIGN aux_dscritic = "O fechamento desta operacao ja foi " +
                                   "realizado no dia " + 
                                   STRING(crapfld.dttransa).
       
             LEAVE ContadorFld.
             
          END.
       ELSE 
          DO:
             IF LOCKED(crapfld) THEN
                DO:
                   IF aux_contador = 10 THEN
                      DO:
                         ASSIGN aux_cdcritic = 77.
    
                         LEAVE ContadorFld.
    
                      END.
                   ELSE 
                      DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT ContadorFld.
                      END.
                END.
             ELSE /* Nao existe e nao locked */
                DO: 
                   FOR EACH crapcld WHERE crapcld.cdcooper = par_cdcooper AND 
                                          crapcld.dtmvtolt = par_tdtmvtol AND 
                                          crapcld.infrepcf = 1
                                          NO-LOCK:
                               
                       RUN Gera_log(INPUT "Fechamento Credito",
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdoperad,
                                    INPUT par_tdtmvtol,
                                    INPUT crapcop.dsdircop,
                                    INPUT STRING(ROWID(crapcld))).
                   END.
             
                   Grava: 
                   DO TRANSACTION ON ERROR  UNDO Grava, LEAVE Grava
                                  ON QUIT   UNDO Grava, LEAVE Grava
                                  ON STOP   UNDO Grava, LEAVE Grava
                                  ON ENDKEY UNDO Grava, LEAVE Grava:
    
                      CREATE crapfld.
    
                      ASSIGN crapfld.cdcooper = par_cdcooper
                             crapfld.dtmvtolt = par_tdtmvtol
                             crapfld.cdoperad = par_cdoperad
                             crapfld.cdtipcld = 2 /* MENSAL COOP */
                             crapfld.hrtransa = TIME
                             crapfld.dttransa = TODAY.
    
                      VALIDATE crapfld.
    
                      LEAVE ContadorFld.
    
                   END.
    
                END.
    
          END. /* else */
    
    END. /* do to */

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:
          RUN gera_erro(INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 0, /* nrsequen */
                        INPUT aux_cdcritic, /* cdcritic */
                        INPUT-OUTPUT aux_dscritic).
          
          RETURN 'NOK'.

       END.

    RETURN 'OK'.

END PROCEDURE.


PROCEDURE Gera_log:

    DEF INPUT PARAM par_cddopcao AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_tdtmvtol AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_dsdircop AS CHAR                             NO-UNDO.
    DEF INPUT PARAMETER par_registro AS CHAR                         NO-UNDO.
    
    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "       +
                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "      +
                      par_cdoperad + " - Utilizou a opcao " + par_cddopcao    +
                      " no dia " + par_tdtmvtol + " e alterou o registro "    +
                      par_registro + " >> /usr/coop/" + par_dsdircop          +
                      "/log/cldmes.log").

    RETURN 'OK'.
    
END PROCEDURE. /* FIM gera-log */

PROCEDURE Carrega_creditos:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagepac AS INT                      NO-UNDO.
    DEFINE INPUT  PARAMETER par_tdtmvtol AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrregist AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nriniseq AS INTEGER                  NO-UNDO.
    
    DEFINE OUTPUT PARAMETER par_qtregist AS INTEGER                  NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-creditos.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_dscritic AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE aux_cdcritic AS INTEGER                          NO-UNDO.
    DEFINE VARIABLE aux_nrregist AS INTEGER                          NO-UNDO.

    EMPTY TEMP-TABLE tt-creditos.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrregist = par_nrregist.
    
    RUN calcula_ultimo_dia_util(INPUT par_cdcooper,
                                INPUT par_tdtmvtol,
                                OUTPUT par_tdtmvtol).

    FOR EACH crapcld WHERE crapcld.cdcooper = par_cdcooper  AND 
                           crapcld.dtmvtolt = par_tdtmvtol  AND 
                          (par_cdagepac = 0                 OR 
                           crapcld.cdagenci = par_cdagepac) AND 
                           crapcld.cdtipcld = 2
                           NO-LOCK:

        FIND crapass WHERE crapass.cdcooper = crapcld.cdcooper AND 
                           crapass.nrdconta = crapcld.nrdconta 
                           NO-LOCK NO-ERROR.

        ASSIGN par_qtregist = par_qtregist + 1.

        IF (par_qtregist < par_nriniseq)                  OR
           (par_qtregist > (par_nriniseq + par_nrregist)) THEN
           NEXT.

        IF aux_nrregist > 0 THEN
           DO:
              CREATE tt-creditos.
              
              ASSIGN tt-creditos.nrdconta = crapcld.nrdconta   
                     tt-creditos.cdagenci = crapcld.cdagenci
                     tt-creditos.dtmvtolt = crapcld.dtmvtolt
                     tt-creditos.vlrendim = crapcld.vlrendim   
                     tt-creditos.vltotcre = crapcld.vltotcre   
                     tt-creditos.qtultren = IF crapcld.vlrendim > 0 THEN 
                                               crapcld.vltotcre / crapcld.vlrendim 
                                            ELSE 0
                     tt-creditos.cddjusti = crapcld.cddjusti   
                     tt-creditos.dsdjusti = crapcld.dsdjusti  
                     tt-creditos.flextjus = crapcld.flextjus
                     tt-creditos.cdoperad = crapcld.cdoperad 
                     tt-creditos.infrepcf = IF crapcld.infrepcf = 0 THEN 
                                               "Nao Informar"
                                            ELSE
                                            IF crapcld.infrepcf = 1 THEN
                                               "Informar"
                                            ELSE 
                                            IF crapcld.infrepcf = 2 THEN
                                               "Ja informado"
                                            ELSE
                                               ""
                     tt-creditos.opeenvcf = crapcld.opeenvcf
                     tt-creditos.dsobserv = crapcld.dsobserv
                     tt-creditos.nrdrowid = ROWID(crapcld).    
                                                               
              IF AVAIL crapass THEN 
                 ASSIGN tt-creditos.nmprimtl = crapass.nmprimtl 
                        tt-creditos.inpessoa = IF crapass.inpessoa = 1 THEN 
                                                  STRING(crapass.inpessoa) + 
                                                         "-FIS" 
                                               ELSE 
                                                  STRING(crapass.inpessoa) + 
                                                         "-JUR".

           END.

           ASSIGN aux_nrregist = aux_nrregist - 1.

    END.
     
    IF NOT CAN-FIND(FIRST tt-creditos) THEN 
       DO:          
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 0,  /* nrsequen */
                          INPUT 11, /* cdcritic */
                          INPUT-OUTPUT aux_dscritic).

           RETURN 'NOK'.

       END.
    
    RETURN 'OK'.

END PROCEDURE.

PROCEDURE gera_relatorio_diario:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER                  NO-UNDO.
    DEFINE INPUT  PARAMETER par_tdtmvtol AS DATE                     NO-UNDO.

    DEFINE OUTPUT PARAMETER par_nmarqimp AS CHARACTER                NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqpdf AS CHARACTER                NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    /* Para impressao */
    DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                                 INIT ["DEP. A VISTA   ","CAPITAL        ",
                                       "EMPRESTIMOS    ","DIGITACAO      ",
                                       "GENERICO       "]            NO-UNDO.
    DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5             NO-UNDO.
    DEF VAR rel_dsagenci AS CHAR FORMAT "x(21)"                      NO-UNDO.

    DEF VAR rel_nmrescop AS CHAR                                     NO-UNDO.
    DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"                     NO-UNDO.
    DEF VAR rel_nrmodulo AS INTE  FORMAT     "9"                     NO-UNDO.
    DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"                     NO-UNDO.
    DEF VAR rel_nmdestin AS CHAR                                     NO-UNDO.
    
    DEF VAR aux_dtmvtolt AS DATE                                     NO-UNDO.
    DEF VAR aux_dtinimes AS DATE                                     NO-UNDO.
    DEF VAR aux_dtfimmes AS DATE                                     NO-UNDO.
    DEF VAR aux_inpolexp AS CHAR                                     NO-UNDO.
    
    DEF VAR aux_nmextcop AS CHAR                                     NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                     NO-UNDO.
    DEF VAR aux_infrepcf AS CHAR                                     NO-UNDO.
    DEF VAR aux_dsocpttl AS CHAR                                     NO-UNDO.
    DEF VAR aux_flgpubli AS LOGI      FORMAT "Sim/Nao"               NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                      NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                   NO-UNDO.


    FORM SKIP
         "   Cooperativa:" aux_nmextcop FORMAT "x(65)"
         SKIP
         "            PA:" aux_dsagenci FORMAT "x(50)"
         SKIP
         "      Conta/DV:" par_nrdconta
         SKIP(1)
         "Tit. Nome"
         "CPF/CNPJ          "                      AT 47
         "Politicamente exposta Servidor Publico"   
         SKIP
         "---- ---------------------------------------- ------------------"
         "--------------------- ----------------"
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_titulares.
    
    FORM crapttl.idseqttl   FORMAT "zzz9"
         crapttl.nmextttl   FORMAT "x(40)"
         aux_nrcpfcgc       FORMAT "x(18)"  AT 47
         aux_inpolexp                       AT 66
         aux_flgpubli                       AT 88
         WITH DOWN WIDTH 132  NO-BOX NO-LABELS FRAME f_titulares_fis.
    
    FORM crapjur.nmextttl   FORMAT "x(40)"  AT 6
         aux_nrcpfcgc       FORMAT "x(18)"  AT 47
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_titulares_jur.    
    
    FORM SKIP(1)
         crapcld.dtmvtolt  LABEL "Data"
         SPACE(3)
         crapcld.vlrendim  LABEL "Rendimento"
         SPACE(3)
         crapcld.vltotcre  LABEL "Credito"
         SKIP
         crapcld.cddjusti  LABEL "Justificativa"
         crapcld.dsdjusti  NO-LABEL
         SKIP
         crapcld.dsobserv  LABEL "Comp.Justi"
         SKIP
         crapcld.dsobsctr  LABEL "Parecer Sede"
         SKIP
         aux_infrepcf      LABEL "COAF" FORMAT "x(15)"
         SKIP
         WITH DOWN WIDTH 132 NO-BOX SIDE-LABELS FRAME f_lanctos.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop  THEN
       DO:
          ASSIGN aux_cdcritic = 651
                 aux_dscritic = "".
          
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

        END. 
         
    ASSIGN aux_dsocpttl = "169,319,67,309,308,271,65,306,272,273," +
                          "74,305,69,316,209,311,303,64,310,314,"  +
                          "313,315,307,76,75,77,317,325,312,304"
           aux_dtinimes = DATE(MONTH(par_tdtmvtol),01,YEAR(par_tdtmvtol))
           aux_dtfimmes = (DATE(MONTH(par_tdtmvtol),28,YEAR(par_tdtmvtol)) + 4) -
                       DAY(DATE(MONTH(par_tdtmvtol),28,YEAR(par_tdtmvtol)) + 4)
           par_nmarqimp    = "/micros/" + crapcop.dsdircop + "/cld_" + STRING(TIME,"99999") + ".ex"
           rel_nmrelato[1] = "CREDITOS DO COOPERADO"
           rel_nrmodulo    = 5.
    
    { sistema/generico/includes/b1cabrel132.i "11" 0}
    
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapass THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 0,  /* nrsequen */
                          INPUT 9,  /* cdcritic */
                          INPUT-OUTPUT aux_dscritic).
           RETURN 'NOK'.
       END.
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND 
                       crapage.cdagenci = crapass.cdagenci 
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapass THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,  /* nrsequen */
                           INPUT 15, /* cdcritic */
                           INPUT-OUTPUT aux_dscritic).
            RETURN 'NOK'.
        END.
    
    ASSIGN aux_nmextcop = crapcop.nmrescop + " - " + crapcop.nmextcop
           aux_dsagenci = STRING(crapage.cdagenci) + " - " +
                          crapage.nmresage + " (" + crapage.nmcidade + ")". 
    
    DISP STREAM str_1 aux_nmextcop
                      aux_dsagenci
                      par_nrdconta
                      WITH FRAME f_titulares. 
    
    IF crapass.inpessoa = 1 THEN
       DO:
          FOR EACH crapttl FIELDS(nrcpfcgc idseqttl nmextttl inpolexp cdocpttl)
                           WHERE crapttl.cdcooper = par_cdcooper AND 
                                 crapttl.nrdconta = par_nrdconta
                                 NO-LOCK:
              
              /* Verifica se é servidor publico */
              ASSIGN aux_flgpubli = 
                     CAN-DO(aux_dsocpttl,STRING(crapttl.cdocpttl)).
    
                     aux_nrcpfcgc = STRING(STRING(crapttl.nrcpfcgc,
                                    "zzzzzzzzzzz"), "xxx.xxx.xxx-xx").
    
              IF crapttl.inpolexp = 0 THEN  
                ASSIGN aux_inpolexp = "Nao".
              ELSE IF crapttl.inpolexp = 1 THEN
                ASSIGN aux_inpolexp = "Sim".
              ELSE IF  crapttl.inpolexp = 2 THEN
                ASSIGN aux_inpolexp = "Pendente".
                
              DISP STREAM str_1 crapttl.idseqttl  crapttl.nmextttl 
                                 aux_nrcpfcgc     aux_inpolexp
                                 aux_flgpubli
                                 WITH FRAME f_titulares_fis.
    
              DOWN STREAM str_1 WITH FRAME f_titulares_fis.
    
          END. /* FIM FOR EACH crapttl */
       END.
    ELSE
       DO:
          FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                             crapjur.nrdconta = par_nrdconta
                             NO-LOCK.
    
          IF NOT AVAIL crapjur THEN
             DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 0,  /* nrsequen */
                               INPUT 821,/* cdcritic */
                               INPUT-OUTPUT aux_dscritic).
                RETURN 'NOK'.
             END.
    
          ASSIGN aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                "zzzzzzzzzzzzzz"),"xx.xxx.xxx/xxxx-xx").
    
          DISP STREAM str_1 crapjur.nmextttl  aux_nrcpfcgc
                             WITH FRAME f_titulares_jur.

       END.
    
    DO aux_dtmvtolt = aux_dtinimes TO aux_dtfimmes:
        
       FOR EACH crapcld FIELDS(infrepcf dtmvtolt vlrendim vltotcre cddjusti
                               dsdjusti dsobserv)
                        WHERE crapcld.cdcooper = par_cdcooper        AND 
                              crapcld.dtmvtolt = aux_dtmvtolt        AND 
                              crapcld.cdagenci = crapass.cdagenci    AND 
                              crapcld.cdtipcld = 1 /* DIARIO COOP */ AND 
                              crapcld.nrdconta = par_nrdconta
                              NO-LOCK:
           
           CASE crapcld.infrepcf:
               WHEN 0 THEN ASSIGN aux_infrepcf = "Nao Informar".
               WHEN 1 THEN ASSIGN aux_infrepcf = "Informar".
               WHEN 2 THEN ASSIGN aux_infrepcf = "Ja Informado".
           END CASE.
           
           DISP STREAM str_1 crapcld.dtmvtolt crapcld.vlrendim 
                             crapcld.vltotcre aux_infrepcf
                             crapcld.cddjusti crapcld.dsdjusti
                             crapcld.dsobserv
                             WITH FRAME f_lanctos.
    
           DOWN STREAM str_1 WITH FRAME f_lanctos.
       
       END.

    END.  /* FIM aux_dtmvtolt */

    OUTPUT STREAM str_1 CLOSE.
    
    IF par_idorigem = 5  THEN  /** Ayllos Web **/
       DO:
           RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
               SET h-b1wgen0024.

           IF NOT VALID-HANDLE(h-b1wgen0024)  THEN
              DO:
                  ASSIGN aux_dscritic = "Handle invalido para BO " +
                                        "b1wgen0024.".
              END.

           RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_nmarqimp,
                                                   OUTPUT par_nmarqpdf,
                                                   OUTPUT TABLE tt-erro ).
           
           IF VALID-HANDLE(h-b1wgen0024)  THEN
              DELETE PROCEDURE h-b1wgen0024.

           IF RETURN-VALUE <> "OK" THEN
              RETURN 'NOK'.
       END.  

    RETURN 'OK'.

END PROCEDURE.

/* Calcula ultimo dia util do mes */
PROCEDURE calcula_ultimo_dia_util:

    DEF INPUT  PARAMETER par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtmvtoan AS DATE                        NO-UNDO.

    DEF OUTPUT PARAMETER par_dtcalcul AS DATE                        NO-UNDO.

    ASSIGN par_dtcalcul = ((DATE(MONTH(par_dtmvtoan),28,YEAR(par_dtmvtoan)) +
                            4) - DAY(DATE(MONTH(par_dtmvtoan),28,
                                 YEAR(par_dtmvtoan)) + 4)).

    DO WHILE TRUE:
       IF CAN-DO("1,7",STRING(WEEKDAY(par_dtcalcul)))             OR
          CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                 crapfer.dtferiad = par_dtcalcul) THEN
          DO:
             ASSIGN par_dtcalcul = par_dtcalcul - 1.
             NEXT.             

          END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

END. /* Final calcula_ultimo_dia_util */
