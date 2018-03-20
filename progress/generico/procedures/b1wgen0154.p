/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0154.p
    Autor(a): Fabricio
    Data    : Marco/2013                     Ultima atualizacao: 05/12/2016
  
    Dados referentes ao programa:
  
    Objetivo  : BO com regras de negocio refente a tela ICFJUD.
                
  
    Alteracoes: 18/03/2013 -  Geracao/Importacao de Arquivos ICF 
                              (Andre Santos - SUPERO)
                              
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)      
                
                12/09/2014 - Tratamento devido a migração das coops Concredi e
                             Credimilsul, alterado importar_icf614 para quando
                             inportar uma conta migrada, buscar informações na conta
                             na nova coop(Odirlei/AMcom).
                             
                25/11/2014 - Incluir clausula no craptco flgativo = TRUE
                            (Lucas R./Rodrigo)  

                05/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

                15/03/2018 - Substituida verificacao "cdtipcta = 3,6,10,11,..." pela 
                             modalidade do tipo de conta = 2 ou 3. PRJ366 (Lombardi).

.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0154tt.i }

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.


FORM tt-consulta-icf.nrctaori COLUMN-LABEL "Conta"             AT 01
                              FORMAT "9999,999,9"
     tt-consulta-icf.dtinireq COLUMN-LABEL " Inicio"           AT 12
                              FORMAT "99/99/99"
     tt-consulta-icf.dtfimreq COLUMN-LABEL " Fim"              AT 21
                              FORMAT "99/99/99"
     tt-consulta-icf.cdbanreq COLUMN-LABEL "Bco"               AT 30
                              FORMAT "999"
     tt-consulta-icf.nrctareq COLUMN-LABEL "Conta"             AT 34
                              FORMAT "zzzzzzzzzzz9"
     aux_dscpfcgc             COLUMN-LABEL " CPF/CNPJ"         AT 47
                              FORMAT "X(18)"
     aux_dsdenome             COLUMN-LABEL " Nome"             AT 66
                              FORMAT "X(24)"
     aux_dstipcta             COLUMN-LABEL "Tp Cta"            AT 91
                              FORMAT "X(06)"
     tt-consulta-icf.dacaojud COLUMN-LABEL " Acao Judicial"    AT 98
                              FORMAT "X(25)"
     tt-consulta-icf.cdcritic COLUMN-LABEL "Obs"               AT 124
                              FORMAT "zz9"
     aux_dsstatus             COLUMN-LABEL "Situac"            AT 128
                              FORMAT "x(06)"
    WITH DOWN NO-BOX WIDTH 133 FRAME f_det_enviado.


FORM tt-consulta-icf.dtinireq COLUMN-LABEL "Inicio"            AT 01
                              FORMAT "99/99/99"
     tt-consulta-icf.dtfimreq COLUMN-LABEL "Fim"               AT 10
                              FORMAT "99/99/99"
     tt-consulta-icf.cdbanori COLUMN-LABEL "Bco"               AT 19
                              FORMAT "999"
     tt-consulta-icf.dacaojud COLUMN-LABEL "Acao Judicial"     AT 23
                              FORMAT "X(25)"
     tt-consulta-icf.nrctareq COLUMN-LABEL "Conta/DV"          AT 50
                              FORMAT "zz,zzz,zzz,9"
     aux_dsdenome             COLUMN-LABEL "Nome"              AT 63
                              FORMAT "X(34)"
     aux_dscpfcgc             COLUMN-LABEL "CPF/CNPJ"          AT 98
                              FORMAT "X(18)"
     aux_dstipcta             COLUMN-LABEL "Tp Cta"            AT 117
                              FORMAT "X(06)"
     tt-consulta-icf.cdcritic COLUMN-LABEL "Obs"               AT 124
                              FORMAT "zz9"
     aux_dsstatus             COLUMN-LABEL "Situac"            AT 128
                              FORMAT "x(06)"
     WITH DOWN NO-BOX WIDTH 133 FRAME f_det_recebido.



DEF VAR aux_cdcritic AS INTE NO-UNDO.
DEF VAR aux_dscritic AS CHAR NO-UNDO.


/* Variaveis - Incluido por Andre Santos*/
DEF        VAR aux_contador AS INTE                                  NO-UNDO.
DEF        VAR i            AS INTE                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdir AS CHAR                                  NO-UNDO.

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(170)"               NO-UNDO.
DEF        VAR aux_deslinha AS CHAR    FORMAT "x(170)"               NO-UNDO.

DEF        VAR aux_nrseqarq AS INTE                                  NO-UNDO.
DEF        VAR aux_dscooper AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.

DEFINE TEMP-TABLE tt-icf606
            FIELD nrsequen AS INTE 
            FIELD dsdlinha AS CHAR.

DEF TEMP-TABLE tt-icf606-dados
         FIELD nrsequen AS INTE 
         FIELD dsdlinha AS CHAR
         FIELD seqcliet AS INTE
         FIELD cdocorre LIKE crapicf.cdcritic
         FIELD cdtipcta AS INTE 
         FIELD nmprimtl AS CHAR          
         FIELD nrcpfcgc LIKE crapicf.nrcpfcgc 
         FIELD totalreg AS INTE.

FORM aux_setlinha  FORMAT "x(170)"
     WITH FRAME AA WIDTH 170 NO-BOX NO-LABELS.


DEF QUERY q-crapicf FOR crapicf.                                               
    

/*............................................................................*/

PROCEDURE inclui-registro-icf:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT  PARAM par_nrctaori AS DECI NO-UNDO.
    DEF INPUT  PARAM par_cdbanori AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdbanreq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdagereq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrctareq AS DECI NO-UNDO.
    DEF INPUT  PARAM par_dacaojud AS CHAR NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    CREATE crapicf.
    ASSIGN crapicf.cdcooper = par_cdcooper
           crapicf.dtmvtolt = par_dtmvtolt
           crapicf.dtinireq = par_dtmvtolt
           crapicf.dtfimreq = ?
           crapicf.nrctaori = par_nrctaori
           crapicf.cdbanori = par_cdbanori
           crapicf.cdbanreq = par_cdbanreq
           crapicf.cdagereq = par_cdagereq
           crapicf.nrctareq = par_nrctareq
           crapicf.intipreq = 1 /* enviado */
           crapicf.dacaojud = par_dacaojud
           crapicf.cdoperad = par_cdoperad.
    VALIDATE crapicf.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE busca-cooperado:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrctaori AS DECI NO-UNDO.

    DEF OUTPUT PARAM par_nmprimtl AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper       AND
                       crapass.nrdconta = INT(par_nrctaori)
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass THEN
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    ASSIGN par_nmprimtl = crapass.nmprimtl.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE consulta-icf:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT  PARAM par_dtinireq AS DATE NO-UNDO.
    DEF INPUT  PARAM par_intipreq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdbanreq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdagereq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrctareq AS DECI NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-consulta-icf.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_query AS CHAR NO-UNDO.

    ASSIGN aux_query = "FOR EACH crapicf WHERE crapicf.cdcooper = " +
                        STRING(par_cdcooper) + " AND crapicf.intipreq = " +
                        STRING(par_intipreq).
    
    IF   par_dtinireq <> ? THEN
         ASSIGN aux_query = aux_query + " AND crapicf.dtinireq = " + 
                            STRING(par_dtinireq).

    IF   par_cdbanreq <> 0 THEN
         ASSIGN aux_query = aux_query + " AND crapicf.cdbanreq = " +
                            STRING(par_cdbanreq).

    IF   par_cdagereq <> 0 THEN
         ASSIGN aux_query = aux_query + " AND crapicf.cdagereq = " +
                            STRING(par_cdagereq).

    IF   par_nrctareq <> 0 THEN
         ASSIGN aux_query = aux_query + " AND crapicf.nrctareq = " +
                            STRING(par_nrctareq).

    ASSIGN aux_query = aux_query + " NO-LOCK.".
    
    QUERY q-crapicf:QUERY-CLOSE().
    QUERY q-crapicf:QUERY-PREPARE(aux_query).
    QUERY q-crapicf:QUERY-OPEN().

    GET FIRST q-crapicf NO-LOCK.

    IF   NOT AVAILABLE crapicf THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Lancamentos nao encontrados.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    DO WHILE AVAIL(crapicf):
        
       IF   crapicf.cdcritic <> 0 THEN
            aux_dsstatus = "ERRO".
       ELSE
       IF   crapicf.dtfimreq = ? THEN
            aux_dsstatus = "Em And".
       ELSE
            aux_dsstatus = "Concl.".

       CREATE tt-consulta-icf.
       ASSIGN tt-consulta-icf.dtinireq = crapicf.dtinireq
              tt-consulta-icf.dtfimreq = crapicf.dtfimreq
              tt-consulta-icf.cdbanori = crapicf.cdbanori
              tt-consulta-icf.nrctaori = crapicf.nrctaori
              tt-consulta-icf.cdbanreq = crapicf.cdbanreq
              tt-consulta-icf.cdagereq = crapicf.cdagereq
              tt-consulta-icf.nrctareq = crapicf.nrctareq
              tt-consulta-icf.nrcpfcgc = crapicf.nrcpfcgc
              tt-consulta-icf.nmprimtl = crapicf.nmprimtl
              tt-consulta-icf.dacaojud = crapicf.dacaojud
              tt-consulta-icf.cdcritic = crapicf.cdcritic
              tt-consulta-icf.cdtipcta = crapicf.cdtipcta
              tt-consulta-icf.dsstatus = aux_dsstatus.

       GET NEXT q-crapicf.

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE imprime-icf:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT  PARAM par_dtinireq AS DATE NO-UNDO.
    DEF INPUT  PARAM par_intipreq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdbanreq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdagereq AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrctareq AS DECI NO-UNDO.
    DEF INPUT  PARAM TABLE FOR tt-consulta-icf.

    DEF OUTPUT PARAM par_nmarqpdf AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 1           NO-UNDO.
    DEF VAR rel_nmrescop AS CHAR                                      NO-UNDO.
    DEF VAR rel_nmempres AS CHAR                                      NO-UNDO.
    DEF VAR rel_dsagenci AS CHAR    FORMAT "x(21)"                    NO-UNDO.
    DEF VAR rel_nrmodulo AS INT     FORMAT "9"                        NO-UNDO.
    DEF VAR rel_nmdestin AS CHAR                                      NO-UNDO.

    DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                    INIT ["DEP. A VISTA   ","CAPITAL        ",
                                          "EMPRESTIMOS    ","DIGITACAO      ",
                                          "GENERICO       "]          NO-UNDO.

    DEF VAR aux_nmarqimp AS CHAR NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapcop THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/crrl638.lst".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    { sistema/generico/includes/b1cabrel132.i "11" "638" }

    IF   par_intipreq = 1 THEN
         PUT STREAM str_1 SKIP(1)
                          "Tipo de Requisicao: Enviada"  AT 01.
    ELSE
         PUT STREAM str_1 SKIP(1)
                          "Tipo de Requisicao: Recebida" AT 01.

    IF   par_dtinireq <> ? OR 
         par_cdbanreq <> 0 OR 
         par_cdagereq <> 0 OR
         par_nrctareq <> 0 THEN
         PUT STREAM str_1 SKIP(2)
                          "Filtrando por:" AT 01 SKIP(1).

    IF   par_dtinireq <> ? THEN
         PUT STREAM str_1 "- Data Inicio da Requisicao:"   AT 03
                          par_dtinireq FORMAT "99/99/9999" SKIP.

    IF   par_cdbanreq <> 0 THEN
         PUT STREAM str_1 "-         Banco Requisitado:"   AT 03
                          par_cdbanreq FORMAT "999"        SKIP.

    IF   par_cdagereq <> 0 THEN
         PUT STREAM str_1 "-       Agencia Requisitada:"   AT 03
                          par_cdagereq FORMAT "zzz9"       SKIP.

    IF   par_nrctareq <> 0 THEN
         PUT STREAM str_1 "-         Conta Requisitada:"   AT 03
                          par_nrctareq FORMAT "zzzzzzzz9"  SKIP.

    PUT STREAM str_1 SKIP(2).
     
    IF   par_intipreq = 1 THEN
         PUT STREAM str_1 "Requisicao"                  AT 10
                          "Destino"                     AT 60
                          SKIP
                          "----------------------------" AT 01
 "-------------------------------------------------------------------" AT 30.
    ELSE
         PUT STREAM str_1 "Requisicao (Origem)"         AT 14
                          "Destino"                     AT 79
                          SKIP
 "-----------------------------------------------"      AT 01
 "-------------------------------------------------------------------------" 
                                                        AT 50.
    
    FOR EACH tt-consulta-icf NO-LOCK:
        
        IF   LENGTH(STRING(tt-consulta-icf.nrcpfcgc)) > 11   THEN
             ASSIGN aux_dscpfcgc = 
                           STRING(tt-consulta-icf.nrcpfcgc,"99999999999999")
                    aux_dscpfcgc = STRING(aux_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
        ELSE
             ASSIGN aux_dscpfcgc = 
                           STRING(tt-consulta-icf.nrcpfcgc,"99999999999")
                    aux_dscpfcgc = STRING(aux_dscpfcgc,"xxx.xxx.xxx-xx").
            
        IF   tt-consulta-icf.nmprimtl = "" THEN
             aux_dsdenome = "".
        ELSE
             aux_dsdenome = tt-consulta-icf.nmprimtl.

        IF   tt-consulta-icf.cdtipcta = 1 OR
             tt-consulta-icf.cdtipcta = 2 THEN
             aux_dstipcta = "".
        ELSE
        IF   tt-consulta-icf.cdtipcta = 3 THEN
             aux_dstipcta = "PF Ind".
        ELSE
        IF   tt-consulta-icf.cdtipcta = 4 THEN
             aux_dstipcta = "PJ".
        ELSE
        IF   tt-consulta-icf.cdtipcta = 5 THEN
             aux_dstipcta = "PF Cnj".
        ELSE
             aux_dstipcta = "".
             
        IF   tt-consulta-icf.cdcritic <> 0 THEN
             aux_dsstatus = "ERRO".
        ELSE
        IF   tt-consulta-icf.dtfimreq = ? THEN
             aux_dsstatus = "Em And".
        ELSE
             aux_dsstatus = "Concl.".
             
        IF   par_intipreq = 1 THEN         /* Enviado */
             DO:
                 DISPLAY STREAM str_1 tt-consulta-icf.nrctaori
                                      tt-consulta-icf.dtinireq
                                      tt-consulta-icf.dtfimreq
                                      tt-consulta-icf.cdbanreq
                                      tt-consulta-icf.nrctareq
                                      aux_dscpfcgc
                                      aux_dsdenome
                                      aux_dstipcta
                                      tt-consulta-icf.dacaojud
                                      tt-consulta-icf.cdcritic
                                      aux_dsstatus
                                      WITH FRAME f_det_enviado.

                 DOWN STREAM str_1 WITH FRAME f_det_enviado.
             END.
        ELSE                              /* Recebido */
             DO:
                 DISPLAY STREAM str_1 tt-consulta-icf.dtinireq
                                      tt-consulta-icf.dtfimreq
                                      tt-consulta-icf.cdbanori
                                      tt-consulta-icf.dacaojud
                                      tt-consulta-icf.nrctareq
                                      aux_dsdenome              
                                      aux_dscpfcgc
                                      aux_dstipcta
                                      tt-consulta-icf.cdcritic
                                      aux_dsstatus
                                      WITH FRAME f_det_recebido.

                 DOWN STREAM str_1 WITH FRAME f_det_recebido.
             END.
    END.

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN par_nmarqpdf = SUBSTR(aux_nmarqimp, 1, LENGTH(aux_nmarqimp) - 3) +
                          "pdf".

    RUN gera_impressao (INPUT par_cdcooper,
                        INPUT aux_nmarqimp,
                        INPUT-OUTPUT par_nmarqpdf,
                        OUTPUT aux_dscritic).

    IF   aux_dscritic <> "" THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT 0,
                            INPUT 0,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE gera_impressao:

    DEF INPUT  PARAM par_cdcooper AS INTE              NO-UNDO.
    DEF INPUT  PARAM par_nmarqimp AS CHAR              NO-UNDO.

    DEF INPUT-OUTPUT  PARAM par_nmarqpdf AS CHAR       NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR              NO-UNDO.

    DEF VARIABLE h-b1wgen0024     AS HANDLE            NO-UNDO.

               
    Imp-Web: DO WHILE TRUE:
                RUN sistema/generico/procedures/b1wgen0024.p 
                                    PERSISTENT SET h-b1wgen0024.
               
                IF   NOT VALID-HANDLE(h-b1wgen0024)  THEN
                     DO:
                         ASSIGN par_dscritic = 
                                    "Handle invalido para BO b1wgen0024.".
                         LEAVE Imp-Web.
                     END.

                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                        INPUT par_nmarqpdf).
        
                IF   SEARCH(par_nmarqpdf) = ?  THEN
                     DO:
                         ASSIGN par_dscritic = "Nao foi possivel gerar " + 
                                               "a impressao.".
                         LEAVE Imp-Web.
                     END.
               
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + par_nmarqpdf + 
                                   ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + 
                                   crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
               
                LEAVE Imp-Web.
             END. /** Fim do DO WHILE TRUE **/
               
    IF   VALID-HANDLE(h-b1wgen0024)  THEN
         DELETE OBJECT h-b1wgen0024.  

    ASSIGN par_nmarqpdf = ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/").

END PROCEDURE.

/*............................................................................*/

PROCEDURE gerar_icf604:

   DEF INPUT  PARAM par_cdcooper AS INT                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                             NO-UNDO.
   DEF OUTPUT PARAM par_dsmensag AS CHAR                             NO-UNDO.

   DEF VAR aux_seqclien          AS INTE  INIT 0                     NO-UNDO.
   DEF VAR aux_totcliet          AS INTE  INIT 0                     NO-UNDO.
   DEF VAR aux_flgregis          AS LOGICAL                          NO-UNDO.
   DEF VAR aux_dtfimreq          AS DATE                             NO-UNDO.
   DEF VAR aux_contador          AS INTE                             NO-UNDO.

   /* Busca Coop. Cecred para usar no nome do Arquivo */
   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   
   /* Nome do Arquivo */
   ASSIGN aux_nmarquiv = "i2" + STRING(crapcop.cdbcoctl,"999") +
                         STRING(DAY(par_dtmvtolt),"99") + ".REM"
          aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
          aux_nmarqlog = "/usr/coop/cecred/log/prcctl_" +
                         STRING(YEAR(par_dtmvtolt),"9999") +
                         STRING(MONTH(par_dtmvtolt),"99") +
                         STRING(DAY(par_dtmvtolt),"99") + ".log".

   FIND FIRST crapicf WHERE crapicf.dtmvtolt = par_dtmvtolt  AND
                            crapicf.intipreq = 1 /* enviado */
                            NO-LOCK NO-ERROR.

   /* Se não houver dados para processar */
   IF   NOT AVAIL crapicf THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Sem dados para geracao do arquivo ICF604."
                   par_dsmensag = aux_dscritic.
         
            RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                           INPUT 1,
                           INPUT 1,
                           INPUT 2, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

     
    ASSIGN aux_dtfimreq = par_dtmvtolt
           aux_contador = 0.

    /*conta 5 dias uteis para obter a data final para o retorno da requisicao*/
    DO WHILE aux_contador < 5:

        ASSIGN aux_dtfimreq = aux_dtfimreq + 1.

        IF   CAN-DO("1,7", STRING(WEEKDAY(aux_dtfimreq)))               OR
             CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                    crapfer.dtferiad = aux_dtfimreq)    THEN
             NEXT.

        ASSIGN aux_contador = aux_contador + 1.
    END.
 
   
   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm " + aux_dscooper + "arq/i2*.REM 2>/dev/null").

   ASSIGN aux_nrseqarq = 1  /* Seq. do arquivo  */
          aux_seqclien = 0. /* Seq. por cliente */

   OUTPUT STREAM str_3 TO VALUE(aux_dscooper + "arq/" + aux_nmarquiv).

   /* Geracao do HEADER */
   PUT STREAM str_3
       FILL("0",7)                       FORMAT "x(7)" /* Controle Header*/
       STRING(YEAR(par_dtmvtolt),"9999") FORMAT "9999" /* Dat Formato    */
       STRING(MONTH(par_dtmvtolt),"99")  FORMAT "99"   /* YYYYMMDD       */
       STRING(DAY(par_dtmvtolt),"99")    FORMAT "99"
       STRING(crapcop.cdbcoctl,"999")    FORMAT "999"    /* Banco Ctl    */
       "0001"                            FORMAT "9999"   /* Versao do Arq*/
       "ICF604"                          FORMAT "x(6)"   /* Nome         */
       FILL(" ",122)                     FORMAT "x(122)" /* Brancos      */
       STRING(aux_nrseqarq,"9999999999") FORMAT "x(10)"  /* Sequencia 1  */
       SKIP.


   /* Geracao Detalhes */
   FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

       FOR EACH crapicf WHERE crapicf.cdcooper = crapcop.cdcooper  AND
                              crapicf.dtmvtolt = par_dtmvtolt      AND
                              crapicf.intipreq = 1 /* enviado */
                              NO-LOCK:

           ASSIGN aux_nrseqarq = aux_nrseqarq + 1
                  aux_seqclien = aux_seqclien + 1.

           PUT STREAM str_3
               "01"                                     /* Tipo Detalhe - Circular 3571   */
               STRING(aux_seqclien,"99999")             FORMAT "99999" /* Seq Cliente/Reg */
               STRING(crapicf.cdbanori,"999")           FORMAT "999"   /* Bco Requisitada */
               STRING(crapicf.cdbanreq,"999")           FORMAT "999"   /* Bco Requisitada */
               "000"                                    /* IF Incorporada  */
               STRING(crapicf.cdagereq,"9999")          FORMAT "9999"  /* Age Requisitada */
               STRING(crapicf.nrctareq,"999999999999")  FORMAT "999999999999" /* Nr Conta */
               STRING(YEAR(crapicf.dtinireq),"9999")    FORMAT "9999"   /* Dat Inicio  */
               STRING(MONTH(crapicf.dtinireq),"99")     FORMAT "99"     /* (YYYYMM)    */
               STRING(YEAR(aux_dtfimreq),"9999")        FORMAT "9999"   /* Dat Fim      */
               STRING(MONTH(aux_dtfimreq),"99")         FORMAT "99"     /* (YYYYMM)    */
               crapicf.dacaojud                         FORMAT "x(25)"  /* Acao Jud.   */
               FILL(" ",2)                              FORMAT "x(2)"   /* Brancos     */
               "02"                                     /* Fixo 2 - Conta Depositaria  */
               FILL(" ",77)                             FORMAT "x(77)"  /* Brancos     */
               STRING(aux_nrseqarq,"9999999999")        FORMAT "x(10)"  /* Sequencia 1  */
               SKIP.

       END.
   END.

   /* Geracao do Trailer */
   ASSIGN aux_nrseqarq = aux_nrseqarq + 1
          aux_totcliet = aux_seqclien.

   /* Busca Coop. Cecred para usar no nome do Arquivo */
   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   PUT STREAM str_3
       FILL("9",7)                       FORMAT "x(7)"  /* Control Header */
       STRING(YEAR(par_dtmvtolt),"9999") FORMAT "9999"  /* Dat Formato    */
       STRING(MONTH(par_dtmvtolt),"99")  FORMAT "99"    /* YYYYMMDD       */
       STRING(DAY(par_dtmvtolt),"99")    FORMAT "99"
       STRING(crapcop.cdbcoctl,"999")    FORMAT "999"   /* IF Remetente   */
       "0001"                            FORMAT "9999"  /* Versao do Arq  */
       "ICF604"                          FORMAT "x(6)"  /* ICF604 (Envio) */
       STRING(aux_totcliet,"9999999999") FORMAT "9999999999" /* Tot Cliente */
       FILL(" ",112)                     FORMAT "x(112)"     /* Brancos     */
       STRING(aux_nrseqarq,"9999999999") FORMAT "9999999999" /* Sequencial  */
       SKIP.

   OUTPUT STREAM str_3 CLOSE.

   /* Copia para o /micros */
   UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" +
                     aux_nmarquiv + ' | tr -d "\032"' +
                     " > /micros/" + crapcop.dsdircop +
                     "/abbc/" + aux_nmarquiv + " 2>/dev/null").

   /* move para o salvar */
   UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarquiv +
                     " " + aux_dscooper + "salvar/" +
                     aux_nmarquiv + "_" + STRING(TIME,"99999") +
                     " 2>/dev/null").

   /* Gera Log */
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - Coop: 3" +
                     " - Processar: ICF604"  +
                     " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                     " - Qtd.: " + STRING(aux_seqclien,"zzz,zz9")    +
                     " " + " >> " + aux_nmarqlog).

END PROCEDURE.

/*............................................................................*/

PROCEDURE importar_icf614:
   
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtoan AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM par_dsmensag AS CHAR                              NO-UNDO.

   DEF VAR aux_cdagereq AS INTE   FORMAT "zzz9"                       NO-UNDO.
   DEF VAR aux_nrctareq AS INTE   FORMAT "zzzzzzzzzzz9"               NO-UNDO.
   DEF VAR aux_cdocorre AS INTE                                       NO-UNDO.
   DEF VAR aux_cdtipcta AS INTE                                       NO-UNDO.

   DEF VAR tab_nmarqtel AS CHAR   FORMAT "x(50)"       EXTENT 99      NO-UNDO.
   DEF VAR aux_nrsequen AS INTE   INIT 0                              NO-UNDO.
   DEF VAR aux_seqcliet AS INTE   INIT 0                              NO-UNDO.
   DEF VAR aux_totcliet AS INTE   INIT 0                              NO-UNDO.

   DEF VAR aux_cdcooper LIKE crapicf.cdcooper                         NO-UNDO.
   DEF VAR aux_nrctaori LIKE crapicf.nrctaori                         NO-UNDO.
   DEF VAR aux_intipreq LIKE crapicf.intipreq                         NO-UNDO.
   DEF VAR aux_cdcritic LIKE crapicf.cdcritic                         NO-UNDO.
   DEF VAR aux_cdbanori LIKE crapicf.cdbanori                         NO-UNDO.
   DEF VAR aux_cdbanreq LIKE crapicf.cdbanreq                         NO-UNDO.
   DEF VAR aux_nrcpfcgc LIKE crapicf.nrcpfcgc                         NO-UNDO.
   DEF VAR aux_nmprimtl LIKE crapicf.nmprimtl                         NO-UNDO.
   DEF VAR aux_dacaojud LIKE crapicf.dacaojud                         NO-UNDO.
   DEF VAR aux_dtmvtolt LIKE crapicf.dtmvtolt                         NO-UNDO.
   DEF VAR aux_dtinireq LIKE crapicf.dtinireq                         NO-UNDO.
   DEF VAR aux_dtfimreq LIKE crapicf.dtfimreq                         NO-UNDO.


   /* Busca a Coop. Cecred para Usar no Nome do Arq. */
   FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

   /* Nome Arqivo de Origem */
   ASSIGN aux_nmarquiv = "integra/ICF614" + 
                         STRING(DAY(par_dtmvtoan),"99") + ".RET"
          aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
          aux_contador = 0.

   IF   SEARCH(aux_dscooper + aux_nmarquiv + ".q") <> ?  THEN
        DO:
            /* Remove os Arquivos ".q" Caso Existam */
            UNIX SILENT VALUE("rm " + aux_dscooper + aux_nmarquiv +
                              ".q 2> /dev/null").
        END.

   /* Listar o nome do arquivo caso exista */
   INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dscooper + aux_nmarquiv +
                                    " 2> /dev/null") NO-ECHO.
   
   /* Lê o Conteudo do Diretorio */
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      SET STREAM str_1 aux_nmarqdir FORMAT "x(78)" .

      UNIX SILENT VALUE("quoter " + aux_nmarqdir + " > " +
                        aux_nmarqdir +  ".q 2> /dev/null").

      /* Gravando a qtd de arquivos processados */
      ASSIGN aux_contador               = aux_contador + 1
             tab_nmarqtel[aux_contador] = aux_nmarqdir.

   END. /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_1 CLOSE.

   /* Se não houver arquivos processados */
   IF   aux_contador = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 182
                   aux_dscritic = "".
       
            RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                           INPUT 1,
                           INPUT 1,
                           INPUT 3, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            /* Descricao da critica */
            par_dsmensag = aux_dscritic.

            RETURN "NOK".
        END.

   /* Fim da verificacao se deve executar */

   DO  i = 1 TO aux_contador:

       aux_nrsequen = 1.

       /* Leitura da Linha do Header */
       INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

       IF   SUBSTR(aux_setlinha,1,7) <> "0000000" THEN /* Constante 0 */
            aux_cdcritic = 468.
       ELSE
       IF   SUBSTR(aux_setlinha,23,6) <> "ICF614" THEN /* ICF614 */
            aux_cdcritic = 173.

       IF   aux_cdcritic <> 0 THEN
            DO:
                INPUT STREAM str_2 CLOSE.
                RUN fontes/critic.p.
                aux_nmarquiv = "integra/err" + SUBSTR(tab_nmarqtel[i],12,29).
                UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").
                UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " " + aux_nmarquiv).
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - PRCCTL" + "' --> '" + aux_dscritic + " " +
                                  aux_nmarquiv + " >> log/proc_batch.log").
                aux_cdcritic = 0.
                NEXT.
            END.

       /* Grava Linha Cabeçalho (Header) */
       CREATE tt-icf606.
       ASSIGN tt-icf606.nrsequen = aux_nrsequen  /* Sequencial 1 */
              tt-icf606.dsdlinha = aux_setlinha.

       INPUT STREAM str_2 CLOSE. /* Fim Leitura Header */

       ASSIGN aux_cdcritic = 0
              aux_seqcliet = 0.

       /* Leitura da Linha do Detalhe */
       INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

       TRANS_1:

       DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                                 ON ERROR UNDO TRANS_1, LEAVE TRANS_1:

          SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

          /* Verifica se é a ultima linha do Arquivo */
          IF  SUBSTR(aux_setlinha,1,7) = "9999999" THEN
              DO:
                 /* Grava Linha do Trailer */
                 CREATE tt-icf606-dados.
                 ASSIGN tt-icf606-dados.nrsequen = 9999999
                        tt-icf606-dados.totalreg = aux_seqcliet
                        tt-icf606-dados.dsdlinha = aux_setlinha.

                 LEAVE TRANS_1.
              END.

          ASSIGN aux_nrsequen = aux_nrsequen + 1  /* Seq. Registro */
                 aux_seqcliet = aux_seqcliet + 1. /* Qtd. Cliente  */

          ASSIGN aux_deslinha = SUBSTR(aux_setlinha,1,69)
                 aux_cdbanori = INT(SUBSTR(aux_setlinha,8,3))
                 aux_cdbanreq = INT(SUBSTR(aux_setlinha,11,3))
                 aux_cdagereq = INT(SUBSTR(aux_setlinha,17,4))
                 aux_nrctareq = INT(SUBSTR(aux_setlinha,21,12))
                 aux_dtinireq = DATE(INT(SUBSTR(aux_setlinha,37,2)),1,
                                     INT(SUBSTR(aux_setlinha,33,4)))
                 aux_dtfimreq = DATE(INT(SUBSTR(aux_setlinha,43,2)),28,
                                     INT(SUBSTR(aux_setlinha,39,4)))
                 aux_dacaojud = SUBSTR(aux_setlinha,45,25).

          IF   ERROR-STATUS:ERROR   THEN
               DO:
                   aux_cdcritic = 79.
                   RUN fontes/critic.p.
                   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                     + " -PRCCTL" + "' --> '" + aux_dscritic
                                     + " " + STRING(aux_nrseqarq,"zzzz,zz9")
                                     + " >> log/proc_batch.log").
                   aux_cdcritic = 0.
                   NEXT TRANS_1.
               END.          

          /* Busca Cooperativa pela Agencia do Cooperado */
          FIND FIRST crapcop WHERE crapcop.cdbcoctl = aux_cdbanreq AND
                                   crapcop.cdagectl = aux_cdagereq
                                   NO-LOCK NO-ERROR.

          IF  AVAIL crapcop THEN DO:
                   
              IF  crapcop.cdagectl = 103 OR
                  crapcop.cdagectl = 114 OR
                  crapcop.cdagectl = 116 THEN DO:

                       /* verificar se é uma conta migrada */
                       FIND FIRST craptco 
                        WHERE craptco.nrctaant = aux_nrctareq 
                          AND craptco.cdcopant = crapcop.cdcooper  
                          AND craptco.flgativo = TRUE
                          NO-LOCK NO-ERROR.
                       
                       /* se for uma conta migrada deve buscar dados 
                          do associado na cooperativa nova */
                  IF  AVAIL(craptco) THEN DO:
                           
                           /* Crapass - Buscar o Associado */
                      FIND FIRST crapass
                           WHERE crapass.cdcooper = craptco.cdcooper
                             AND crapass.nrdconta = craptco.nrdconta
                                      NO-LOCK NO-ERROR.
                         END.
                  ELSE DO: /* senao for buscar com os dados do arquivo*/

                           /* Crapass - Buscar o Associado */
                           FIND FIRST crapass WHERE 
                                      crapass.cdcooper = crapcop.cdcooper AND
                                      crapass.nrdconta = aux_nrctareq
                                      NO-LOCK NO-ERROR.
                        END.
                   END.
                   ELSE
                       /* Crapass - Buscar o Associado */
                       FIND FIRST crapass WHERE 
                                  crapass.cdcooper = crapcop.cdcooper AND
                                  crapass.nrdconta = aux_nrctareq
                                  NO-LOCK NO-ERROR.
                   
                   IF   NOT AVAIL crapass THEN
                        ASSIGN aux_cdcooper = 0
                               aux_cdocorre = 1  /* Conta Nao Localizada      */
                               aux_cdtipcta = 1  /* Tipo Conta Nao Localizada */
                               aux_nmprimtl = " "
                               aux_nrcpfcgc = 0.
                   ELSE
                        DO:
                            /* Tipo de Conta Pesquisada - Pessoa Fisica   */
                            IF   crapass.inpessoa = 1 THEN
                      IF  CAN-DO("2,3", STRING(crapass.cdcatego)) THEN
                                      aux_cdtipcta = 5. /* Pessoa PF Conjunta */
                                 ELSE
                                      aux_cdtipcta = 3. /* Pessoa PF Normal   */
                            ELSE
                                 aux_cdtipcta = 4. /* Pessoa Juridica    */


                            ASSIGN aux_cdcooper = crapcop.cdcooper
                                   aux_cdocorre = 0 /* Conta Localizada   */
                                   aux_nmprimtl = crapass.nmprimtl
                                   aux_nrcpfcgc = crapass.nrcpfcgc.

                        END. /* Fim da Verificacao do Associado */
               END.
          ELSE 
               NEXT. /* Se nao encontrar COOP, Segue Prox. Registro */

         /* Atualiza as Informacoes na Tabela */
         CREATE crapicf.
         ASSIGN crapicf.cdcooper = aux_cdcooper
                crapicf.intipreq = 2 /* recebido */
                crapicf.cdcritic = 0
                crapicf.cdbanori = aux_cdbanori
                crapicf.cdbanreq = aux_cdbanreq
                crapicf.cdagereq = aux_cdagereq
                crapicf.nrcpfcgc = aux_nrcpfcgc
                crapicf.dacaojud = aux_dacaojud
                crapicf.nrctareq = aux_nrctareq
                crapicf.nmprimtl = aux_nmprimtl
                crapicf.dtmvtolt = par_dtmvtolt
                crapicf.dtinireq = aux_dtinireq
                crapicf.dtfimreq = par_dtmvtolt
                crapicf.cdtipcta = aux_cdtipcta
                crapicf.cdoperad = par_cdoperad.
         VALIDATE crapicf.
       
         /* Grava Linha Detalhes */
         CREATE tt-icf606-dados.
         ASSIGN tt-icf606-dados.nrsequen = aux_nrsequen
                tt-icf606-dados.dsdlinha = aux_deslinha
                tt-icf606-dados.seqcliet = aux_seqcliet
                tt-icf606-dados.cdocorre = aux_cdocorre
                tt-icf606-dados.cdtipcta = aux_cdtipcta
                tt-icf606-dados.nmprimtl = aux_nmprimtl
                tt-icf606-dados.nrcpfcgc = aux_nrcpfcgc.

       END. /* FIM do DO */

       INPUT STREAM str_2 CLOSE.

       UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " salvar").
       UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").


       /****** Geração do arquivo ICF606 ******/

       /* Busca a Coop. Cecred para Usar no Nome do Arq */
       FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

       /* Nome do Arquivo */
       ASSIGN aux_nmarquiv = "i3" + STRING(crapcop.cdbcoctl,"999") +
                             STRING(DAY(par_dtmvtolt),"99") + ".REM"
              aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
              aux_nrsequen = 1.

       IF   SEARCH(aux_dscooper + "arq/i3" + STRING(crapcop.cdbcoctl,"999") +
            STRING(DAY(par_dtmvtolt),"99") + ".REM") <> ?  THEN
            DO:
                /* Remove os arquivos temporarios */
                UNIX SILENT VALUE("rm " + aux_dscooper + "arq/i3*" +
                                  STRING(crapcop.cdbcoctl,"999") + "*.REM " +
                                  " 2>/dev/null").
            END.

       OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" + aux_nmarquiv).

       /* Geracao do HEADER */
       FIND FIRST tt-icf606 WHERE tt-icf606.nrsequen = 1 NO-LOCK NO-ERROR.

       PUT STREAM str_1 SUBSTR(tt-icf606.dsdlinha,1,07)    FORMAT "x(07)"
                        STRING(YEAR(par_dtmvtolt),"9999")  FORMAT "9999"
                        STRING(MONTH(par_dtmvtolt),"99")   FORMAT "99"
                        STRING(DAY(par_dtmvtolt),"99")     FORMAT "99"
                        SUBSTR(tt-icf606.dsdlinha,16,07)   FORMAT "x(07)"
                        "ICF606"
                        FILL(" ",122)                      FORMAT "x(122)"
                        STRING(aux_nrsequen,"9999999999")  FORMAT "x(10)"
                        SKIP.

       /* Geracao do DETALHE */
       FOR EACH tt-icf606-dados WHERE tt-icf606-dados.nrsequen <> 9999999
                                      NO-LOCK:

           aux_nrsequen = aux_nrsequen + 1.

           PUT STREAM str_1
               SUBSTR(tt-icf606-dados.dsdlinha,1,69)             FORMAT "x(69)"
               STRING(tt-icf606-dados.cdocorre,"99")             FORMAT "x(2)"
               STRING(tt-icf606-dados.cdtipcta,"99")             FORMAT "x(2)"
               STRING(tt-icf606-dados.nrcpfcgc,"99999999999999") FORMAT "x(14)"
               tt-icf606-dados.nmprimtl                          FORMAT "x(40)"
               YEAR(par_dtmvtolt)                                FORMAT "9999"
               MONTH(par_dtmvtolt)                               FORMAT "99"
               DAY(par_dtmvtolt)                                 FORMAT "99"
               FILL(" ",15)                                      FORMAT "x(15)"
               STRING(aux_nrsequen,"9999999999")                 FORMAT "x(10)"
               SKIP.

       END.

       aux_nrsequen = aux_nrsequen + 1.

       /*Linha do Trailer*/
       FIND FIRST tt-icf606-dados WHERE tt-icf606-dados.nrsequen = 9999999
                                        NO-LOCK NO-ERROR.

       PUT STREAM str_1
                  "9999999"
                  STRING(YEAR(par_dtmvtolt),"9999")             FORMAT "9999"
                  STRING(MONTH(par_dtmvtolt),"99")              FORMAT "99"
                  STRING(DAY(par_dtmvtolt),"99")                FORMAT "99"
                  SUBSTR(tt-icf606.dsdlinha,16,07)              FORMAT "x(07)"
                  "ICF606"
                  STRING(tt-icf606-dados.totalreg,"9999999999") FORMAT "x(10)"
                  FILL(" ",112)                                 FORMAT "x(112)"
                  STRING(aux_nrsequen,"9999999999")             FORMAT "x(10)"
                  SKIP.

       OUTPUT STREAM str_1 CLOSE.

       /* Copia para o /micros */
       UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" +
                         aux_nmarquiv + ' | tr -d "\032"' +
                         " > /micros/" + crapcop.dsdircop +
                         "/abbc/" + aux_nmarquiv + " 2>/dev/null").

       /* move para o salvar */
       UNIX SILENT VALUE("mv " + aux_dscooper + "arq/"  + aux_nmarquiv +
                         " " + aux_dscooper + "salvar/" + aux_nmarquiv +
                         "_" + STRING(TIME,"99999") + " 2>/dev/null").

   END. /* Fim do contador */

END PROCEDURE.

/*............................................................................*/

PROCEDURE importar_icf616.

   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtoan AS DATE                              NO-UNDO.
   DEF OUTPUT PARAM par_dsmensag AS CHAR                              NO-UNDO.

   DEF VAR tab_nmarqtel AS CHAR   FORMAT "x(50)"       EXTENT 99      NO-UNDO.
   DEF VAR aux_cdbcoreq AS INTE   FORMAT "999"                        NO-UNDO.
   DEF VAR aux_cdagereq AS INTE   FORMAT "zzz9"                       NO-UNDO.
   DEF VAR aux_nrctareq AS INTE   FORMAT "zzzzzzzzzzz9"               NO-UNDO.
   DEF VAR aux_cdtipcta AS INTE                                       NO-UNDO.

   DEF VAR aux_cdcritic LIKE crapicf.cdcritic                         NO-UNDO.
   DEF VAR aux_nrcpfcgc LIKE crapicf.nrcpfcgc                         NO-UNDO.
   DEF VAR aux_nmprimtl LIKE crapicf.nmprimtl                         NO-UNDO.
   DEF VAR aux_dacaojud LIKE crapicf.dacaojud                         NO-UNDO.
   DEF VAR aux_dtmvtolt LIKE crapicf.dtmvtolt                         NO-UNDO.


   /* Busca a Coop. Cecred para Usar no Nome do Arq */
   FIND crapcop WHERE crapcop.cdcooper = 3
        NO-LOCK NO-ERROR.


   /* Nome Arqivo de Origem */
   ASSIGN aux_nmarquiv = "integra/ICF616" + 
                          STRING(DAY(par_dtmvtoan),"99") + ".RET"
          aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
          aux_contador = 0.


   IF   SEARCH(aux_dscooper + aux_nmarquiv + ".q") <> ?  THEN
        DO:
            /* Remove os Arquivos ".q" Caso Existam */
            UNIX SILENT VALUE("rm " + aux_dscooper + aux_nmarquiv +
                              ".q 2> /dev/null").
        END.

   /* Listar o nome do arquivo caso exista */
   INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dscooper + aux_nmarquiv +
                                    " 2> /dev/null") NO-ECHO.

   /* Lê o Conteudo do Diretorio */
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      SET STREAM str_1 aux_nmarqdir FORMAT "x(60)" .

      UNIX SILENT VALUE("quoter " + aux_nmarqdir + " > " +
                         aux_nmarqdir +  ".q 2> /dev/null").

      /* Gravando a qtd de arquivos processados */
      ASSIGN aux_contador               = aux_contador + 1
             tab_nmarqtel[aux_contador] = aux_nmarqdir.

   END. /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_1 CLOSE.

   /* Se não houver arquivos processados */
   IF   aux_contador = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 182
                   aux_dscritic = "".
      
            RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                           INPUT 1,
                           INPUT 1,
                           INPUT 4, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            /* Descricao da critica */
            par_dsmensag = aux_dscritic.

            RETURN "NOK".
        END.

   /* Fim da verificacao se deve executar */

   DO  i = 1 TO aux_contador:

       /* Leitura da Linha do Header */
       INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

       IF   SUBSTR(aux_setlinha,1,7) <> "0000000" THEN /* Constante 0 */
            aux_cdcritic = 468.
       ELSE
       IF   SUBSTR(aux_setlinha,23,6) <> "ICF616" THEN /* ICF616 */
            aux_cdcritic = 173.

       IF   aux_cdcritic <> 0 THEN
            DO:
                INPUT STREAM str_2 CLOSE.
                RUN fontes/critic.p.
                aux_nmarquiv = "integra/err" + SUBSTR(tab_nmarqtel[i],12,29).
                UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").
                UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " " + aux_nmarquiv).
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - PRCCTL" + "' --> '" + aux_dscritic + " " +
                                  aux_nmarquiv + " >> log/proc_batch.log").
                aux_cdcritic = 0.
                NEXT.
            END.

       INPUT STREAM str_2 CLOSE. /* Fim Leitura Header */

       ASSIGN aux_cdcritic = 0.

       /* Leitura da Linha do Detalhe */
       INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

       TRANS_1:

       DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                                 ON ERROR UNDO TRANS_1, LEAVE TRANS_1:

          SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

          /* Verifica se é a ultima linha do Arquivo */
          IF  SUBSTR(aux_setlinha,1,7) = "9999999" THEN
              LEAVE TRANS_1.

          ASSIGN aux_cdbcoreq = INT(SUBSTR(aux_setlinha,11,3))
                 aux_cdagereq = INT(SUBSTR(aux_setlinha,17,4))
                 aux_nrctareq = INT(SUBSTR(aux_setlinha,21,12))
                 aux_dacaojud = SUBSTR(aux_setlinha,45,25)
                 aux_cdtipcta = INT(SUBSTR(aux_setlinha,72,2))
                 aux_nrcpfcgc = DEC(SUBSTR(aux_setlinha,74,14))
                 aux_nmprimtl = SUBSTR(aux_setlinha,88,40)
                 aux_dtmvtolt = DATE(INT(SUBSTR(aux_setlinha,132,2)),
                                     INT(SUBSTR(aux_setlinha,134,2)),
                                     INT(SUBSTR(aux_setlinha,128,4))).

          IF   ERROR-STATUS:ERROR   THEN
               DO:
                   aux_cdcritic = 79.
                   RUN fontes/critic.p.
                   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                     + " -PRCCTL" + "' --> '" + aux_dscritic
                                     + " " + STRING(aux_nrseqarq,"zzzz,zz9")
                                     + " >> log/proc_batch.log").
                   aux_cdcritic = 0.
                   NEXT TRANS_1.
               END.

          /* Busca Cooperativa pela Agencia do Cooperado */
          FIND FIRST crapcop WHERE crapcop.cdbcoctl = aux_cdbcoreq AND
                                   crapcop.cdagectl = aux_cdagereq
                                   NO-LOCK NO-ERROR.

          FIND FIRST crapicf WHERE crapicf.cdcooper = crapcop.cdcooper AND
                                   crapicf.dtmvtolt = aux_dtmvtolt     AND
                                   crapicf.dacaojud = aux_dacaojud     AND
                                   crapicf.nrctareq = aux_nrctareq
                                   EXCLUSIVE-LOCK NO-ERROR.

          IF   AVAIL crapicf THEN
               /* Atualiza as Informacoes na crapicf */
               ASSIGN crapicf.nmprimtl = aux_nmprimtl
                      crapicf.nrcpfcgc = aux_nrcpfcgc
                      crapicf.cdtipcta = aux_cdtipcta
                      crapicf.dtfimreq = par_dtmvtolt.


       END. /* FIM do DO WHILE TRUE TRANSACTION */

       INPUT STREAM str_2 CLOSE.

       UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " salvar").
       UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").

   END. /* Fim do contador */

END PROCEDURE.

/*............................................................................*/

PROCEDURE icf_validar_retorno:

   /**** Procedimento que valida as ocorrencias dos arq. icf674 e icf676 ****/

   DEF INPUT  PARAM par_nmretorn AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtoan AS DATE                              NO-UNDO.
   DEF OUTPUT PARAM par_dsmensag AS CHAR                              NO-UNDO.

   DEF VAR tab_nmarqtel AS CHAR   FORMAT "x(50)"       EXTENT 99      NO-UNDO.
   DEF VAR aux_cdbcoctl AS INTE   FORMAT "999"                        NO-UNDO.
   DEF VAR aux_cdagereq AS INTE   FORMAT "zzz9"                       NO-UNDO.
   DEF VAR aux_nrctareq AS INTE   FORMAT "zzzzzzzzzzz9"               NO-UNDO.
   DEF VAR aux_cdtipcta AS INTE                                       NO-UNDO.
   DEF VAR aux_cdocorre AS INTE   FORMAT "999"                        NO-UNDO.

   DEF VAR aux_contareg AS INTE   INIT 0                              NO-UNDO.
   DEF VAR aux_nrsequen AS INTE                                       NO-UNDO.
   DEF VAR aux_totalreg AS INTE                                       NO-UNDO.
   DEF VAR aux_cdcooper LIKE crapicf.cdcooper                         NO-UNDO.
   DEF VAR aux_nrctaori LIKE crapicf.nrctaori                         NO-UNDO.
   DEF VAR aux_cdcritic LIKE crapicf.cdcritic                         NO-UNDO.
   DEF VAR aux_cdbanori LIKE crapicf.cdbanori                         NO-UNDO.
   DEF VAR aux_cdbanreq LIKE crapicf.cdbanreq                         NO-UNDO.
   DEF VAR aux_nrcpfcgc LIKE crapicf.nrcpfcgc                         NO-UNDO.
   DEF VAR aux_nmprimtl LIKE crapicf.nmprimtl                         NO-UNDO.
   DEF VAR aux_dacaojud LIKE crapicf.dacaojud                         NO-UNDO.
   DEF VAR aux_dtmvtolt LIKE crapicf.dtmvtolt                         NO-UNDO.
   DEF VAR aux_dtinireq LIKE crapicf.dtinireq                         NO-UNDO.


   /* Busca a Coop. Cecred para Usar no Nome do Arq. */
   FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

   IF   par_nmretorn  = "ICF674"  THEN /* Importacao do Arq. ICF674 */
        DO:
            /* Nome Arqivo de Origem */
            ASSIGN aux_nmarquiv = "integra/ICF674" +
                                  STRING(DAY(par_dtmvtoan),"99") + ".RET"
                   aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
                   aux_contador = 0.

            IF   SEARCH(aux_dscooper + aux_nmarquiv + ".q") <> ?  THEN
                 DO:
                     /* Remove os Arquivos ".q" Caso Existam */
                     UNIX SILENT VALUE("rm " + aux_dscooper + aux_nmarquiv +
                                       ".q 2> /dev/null").
                 END.


            /* Listar o nome do arquivo caso exista */
            INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dscooper +
                                             aux_nmarquiv + " 2> /dev/null")
                                             NO-ECHO.


            /* Lê o Conteudo do Diretorio */
            DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

               SET STREAM str_1 aux_nmarqdir FORMAT "x(60)" .

               UNIX SILENT VALUE("quoter " + aux_nmarqdir + " > " +
                                 aux_nmarqdir +  ".q 2> /dev/null").

               /* Gravando a qtd de arquivos processados */
               ASSIGN aux_contador               = aux_contador + 1
                      tab_nmarqtel[aux_contador] = aux_nmarqdir.

            END. /*  Fim do DO WHILE TRUE  */

            INPUT STREAM str_1 CLOSE.

            /* Se não houver arquivos processados */
            IF   aux_contador = 0 THEN
                 DO:
                     ASSIGN aux_cdcritic = 182
                            aux_dscritic = "".
           
                     RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                                    INPUT 1,
                                    INPUT 1,
                                    INPUT 5, /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).

                     par_dsmensag = aux_dscritic.

                     RETURN "NOK".
                 END.

            /* Fim da verificacao se deve executar */

            DO i = 1 TO aux_contador:

               aux_cdcritic = 0.

               /* Leitura da Linha do Header */
               INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

               SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

               IF   SUBSTR(aux_setlinha,1,7) <> "0000000" THEN /* Constante 0 */
                    aux_cdcritic = 468.
               ELSE
               IF   SUBSTR(aux_setlinha,19,6) <> "ICF674" THEN /* ICF674 */
                    aux_cdcritic = 173.

               IF   aux_cdcritic <> 0 THEN 
                    DO:
                        INPUT STREAM str_2 CLOSE.
                        RUN fontes/critic.p.
                        aux_nmarquiv = "integra/err" +
                                       SUBSTR(tab_nmarqtel[i],26,12).
                        UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + 
                                          ".q 2> /dev/null").
                        UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + 
                                          " " + aux_nmarquiv).
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - PRCCTL" + "' --> '" + 
                                          aux_dscritic + " " + aux_nmarquiv + 
                                          " >> log/proc_batch.log").
                        aux_cdcritic = 0.
                        NEXT.
                    END.

               aux_dtmvtolt = DATE(INT(SUBSTR(aux_setlinha,12,2)),
                                   INT(SUBSTR(aux_setlinha,14,2)),
                                   INT(SUBSTR(aux_setlinha,8,4))).

               INPUT STREAM str_2 CLOSE. /* Fim Leitura Header */

               /* Leitura da Linha do Detalhe */
               INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

               SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

               TRANS_1:

               DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                                         ON ERROR UNDO TRANS_1, LEAVE TRANS_1:

                  SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

                  /* Verifica se é a ultima linha do Arquivo */
                  IF   SUBSTR(aux_setlinha,1,7) = "9999999" THEN
                       LEAVE TRANS_1. /* Fim do IF da verificacao arquivo */

                  ASSIGN aux_cdbanreq = INT(SUBSTR(aux_setlinha,11,3))
                         aux_cdagereq = INT(SUBSTR(aux_setlinha,17,4))
                         aux_nrctareq = INT(SUBSTR(aux_setlinha,21,12))
                         aux_dacaojud = SUBSTR(aux_setlinha,45,25)
                         aux_cdocorre = INT(SUBSTR(aux_setlinha,148,3)).

                  IF   ERROR-STATUS:ERROR   THEN
                       DO:
                           aux_cdcritic = 86.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                             + " -PRCCTL" + "' --> '" 
                                             + aux_dscritic + " " + 
                                             STRING(aux_nrseqarq,"zzzz,zz9")
                                             + " >> log/proc_batch.log").
                           aux_cdcritic = 0.
                           NEXT TRANS_1.
                       END.

                  /* Busca o registro na tabela para atualizar a critica */
                  FIND FIRST crapicf WHERE crapicf.cdbanreq = aux_cdbanreq AND
                                           crapicf.cdagereq = aux_cdagereq AND
                                           crapicf.nrctareq = aux_nrctareq AND
                                           crapicf.dacaojud = aux_dacaojud
                                           EXCLUSIVE-LOCK NO-ERROR.

                  IF    AVAILABLE crapicf THEN
                        /* Atualiza Critica na Tabela */
                        ASSIGN crapicf.cdcritic = aux_cdocorre
                               crapicf.dtfimreq = par_dtmvtolt.


               END. /* FIM do DO WHILE TRUE TRANSACTION */

               INPUT STREAM str_2 CLOSE.

               UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " salvar").
               UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").

            END. /* Fim do contador */

        END. /* Fim Importacao do Arq. ICF674 */
   ELSE
   IF   par_nmretorn  = "ICF676"  THEN 
        DO: /* Importação do Arq. ICF676 */
 
            /* Nome Arqivo de Origem */
            ASSIGN aux_nmarquiv = "integra/ICF676" +
                                  STRING(DAY(par_dtmvtoan),"99") + ".RET"
                   aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
                   aux_contador = 0.

            IF   SEARCH(aux_dscooper + aux_nmarquiv + ".q") <> ?  THEN
                 DO:
                     /* Remove os Arquivos ".q" Caso Existam */
                     UNIX SILENT VALUE("rm " + aux_dscooper + aux_nmarquiv +
                                       ".q 2> /dev/null").
                 END.

            /* Listar o nome do arquivo caso exista */
            INPUT STREAM str_1 THROUGH VALUE("ls " + aux_dscooper +
                                             aux_nmarquiv + " 2> /dev/null") 
                                             NO-ECHO.


            /* Lê o Conteudo do Diretorio */
            DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

               SET STREAM str_1 aux_nmarqdir FORMAT "x(60)" .

               UNIX SILENT VALUE("quoter " + aux_nmarqdir + " > " +
                                 aux_nmarqdir +  ".q 2> /dev/null").

               /* Gravando a qtd de arquivos processados */
               ASSIGN aux_contador               = aux_contador + 1
                      tab_nmarqtel[aux_contador] = aux_nmarqdir.

            END. /*  Fim do DO WHILE TRUE  */

            INPUT STREAM str_1 CLOSE.

            /* Se não houver arquivos processados */
            IF   aux_contador = 0 THEN
                 DO:
                     ASSIGN aux_cdcritic = 182
                            aux_dscritic = "".
                 
                     RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                                    INPUT 1,
                                    INPUT 1,
                                    INPUT 6, /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
                     RETURN "NOK".
                 END.

            /* Fim da verificacao se deve executar */

            DO i = 1 TO aux_contador:

               aux_cdcritic = 0.

               /* Leitura da Linha do Header */
               INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

               SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

               IF   SUBSTR(aux_setlinha,1,7) <> "0000000" THEN /* Constante 0 */
                    aux_cdcritic = 468.
               ELSE
               IF   SUBSTR(aux_setlinha,19,6) <> "ICF676" THEN /* ICF676 */
                    aux_cdcritic = 173.

               IF   aux_cdcritic <> 0 THEN 
                    DO:
                        INPUT STREAM str_2 CLOSE.
                        RUN fontes/critic.p.
                        aux_nmarquiv = "integra/err" +
                                       SUBSTR(tab_nmarqtel[i],26,12).
                        UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + 
                                          ".q 2> /dev/null").
                        UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + 
                                          " " + aux_nmarquiv).
                        UNIX SILENT VALUE("echo " + 
                                          STRING(TIME,"HH:MM:SS") +
                                          " - PRCCTL" + "' --> '" + 
                                          aux_dscritic + " " + aux_nmarquiv + 
                                          " >> log/proc_batch.log").
                        aux_cdcritic = 0.
                        NEXT.
                    END.

               aux_dtmvtolt = DATE(INT(SUBSTR(aux_setlinha,12,2)),
                                   INT(SUBSTR(aux_setlinha,14,2)),
                                   INT(SUBSTR(aux_setlinha,8,4))).

               INPUT STREAM str_2 CLOSE. /* Fim Leitura Header */

               /* Leitura da Linha do Detalhe */
               INPUT STREAM str_2 FROM VALUE(tab_nmarqtel[i] + ".q") NO-ECHO.

               SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

               TRANS_1:

               DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                                         ON ERROR UNDO TRANS_1, LEAVE TRANS_1:

                  SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 170.

                  /* Verifica se é a ultima linha do Arquivo */
                  IF   SUBSTR(aux_setlinha,1,7) = "9999999" THEN
                       LEAVE TRANS_1.

                  ASSIGN aux_cdbcoctl = INT(SUBSTR(aux_setlinha,8,3))
                         aux_cdagereq = INT(SUBSTR(aux_setlinha,17,4))
                         aux_nrctareq = INT(SUBSTR(aux_setlinha,21,12))
                         aux_dacaojud = SUBSTR(aux_setlinha,45,25)
                         aux_cdocorre = INT(SUBSTR(aux_setlinha,148,3)).

                  IF   ERROR-STATUS:ERROR  THEN 
                       DO:
                           aux_cdcritic = 86.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                       + " -PRCCTL" + "' --> '" + aux_dscritic
                                       + " " + STRING(aux_nrseqarq,"zzzz,zz9")
                                       + " >> log/proc_batch.log").
                           aux_cdcritic = 0.
                           NEXT TRANS_1.
                       END.

                  /* Busca Cooperativa pela Agencia do Cooperado */
                  FIND FIRST crapcop WHERE crapcop.cdbcoctl = aux_cdbcoctl AND
                                           crapcop.cdagectl = aux_cdagereq
                                           NO-LOCK NO-ERROR.


                 /* Busca o registro na tabela para atualizar a critica */
                 FIND FIRST crapicf WHERE 
                            crapicf.cdcooper = crapcop.cdcooper AND
                            crapicf.dtmvtolt = aux_dtmvtolt     AND
                            crapicf.dacaojud = aux_dacaojud     AND
                            crapicf.nrctareq = aux_nrctareq
                            EXCLUSIVE-LOCK NO-ERROR.

                 IF   AVAILABLE crapicf THEN
                      /* Atualiza Critica na Tabela */
                      ASSIGN crapicf.cdcritic = aux_cdocorre
                             crapicf.dtfimreq = par_dtmvtolt.

               END. /* FIM do DO WHILE TRUE TRANSACTION */

               INPUT STREAM str_2 CLOSE.

               UNIX SILENT VALUE("mv " + tab_nmarqtel[i] + " " +
                                 aux_dscooper + "salvar").
               
               UNIX SILENT VALUE("rm " + tab_nmarqtel[i] + ".q 2> /dev/null").

            END. /* Fim do contador */
        END. /* Fim Importacao do Arq. ICF676 */
   ELSE 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Parametro Invalido".
        
            RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                           INPUT 1,
                           INPUT 1,
                           INPUT 7, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            /* Descricao da critica */
            par_dsmensag = aux_dscritic.

            RETURN "NOK".
        END.

END PROCEDURE.

/*............................................................................*/
