/*.............................................................................

  Programa: generico/procedures/b1wgen0139.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Tiago
  Data    : Julho/12                            Ultima alteracao: 01/10/2014

  Objetivo  : Procedures referentes a tela TAB094.

  Alteracao : 02/02/2012 - Corrigdo a passagem dos parametros na procedure
                           busca_dados, grava_dados (Adriano).
                           
              25/06/2013 - Adicionado os campos Margem Cta Itg BB Credito e
                           Margem Cta Itg BB Debito (Reinert)
                           
              05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
              01/10/2014 - Incluir par_dsdepart <> "FINANCEIRO" na procedure
                           acesso_opcao (Lucas R. #201057)

			  06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                           departamento passando a considerar o código (Renato Darosci)
............................................................................ */

{ sistema/generico/includes/b1wgen0139tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }   

PROCEDURE busca_dados:

    DEF INPUT  PARAM par_cdcooper LIKE  crapcop.cdcooper                NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS    INTEGER                         NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS    INT                             NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS    CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_cdcoopex AS    INT                             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-fluxo-fin.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE  aux_mrgsrdoc AS    DECIMAL                         NO-UNDO.
    DEFINE VARIABLE  aux_mrgsrchq AS    DECIMAL                         NO-UNDO.
    DEFINE VARIABLE  aux_mrgnrtit AS    DECIMAL                         NO-UNDO.
    DEFINE VARIABLE  aux_mrgsrtit AS    DECIMAL                         NO-UNDO.
    DEFINE VARIABLE  aux_caldevch AS    DECIMAL                         NO-UNDO.
    DEFINE VARIABLE  aux_mrgitgcr AS    DECIMAL                         NO-UNDO.
    DEFINE VARIABLE  aux_mrgitgdb AS    DECIMAL                         NO-UNDO.
    DEFINE VARIABLE  aux_horabloq AS    CHARACTER                       NO-UNDO.

    DEFINE VARIABLE  aux_cdcritic AS    INTEGER                         NO-UNDO.
    DEFINE VARIABLE  aux_dscritic AS    CHARACTER                       NO-UNDO.


    ASSIGN  aux_mrgsrdoc = 0
            aux_mrgsrchq = 0
            aux_mrgnrtit = 0
            aux_mrgsrtit = 0
            aux_caldevch = 0
            aux_mrgitgcr = 0
            aux_mrgitgdb = 0
            aux_horabloq = ""
            aux_cdcritic = 0
            aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    FIND craptab WHERE craptab.cdcooper = par_cdcoopex    AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "GENERI"        AND
                       craptab.cdempres = 00              AND
                       craptab.cdacesso = "PARFLUXOFINAN" AND
                       craptab.tpregist = 0 
                       NO-LOCK NO-ERROR.
    
    IF  AVAIL(craptab) THEN
        DO:  
            ASSIGN  aux_mrgsrdoc = DECIMAL(ENTRY(1,craptab.dstextab,";"))  
                    aux_mrgsrchq = DECIMAL(ENTRY(2,craptab.dstextab,";"))  
                    aux_mrgnrtit = DECIMAL(ENTRY(3,craptab.dstextab,";"))  
                    aux_mrgsrtit = DECIMAL(ENTRY(4,craptab.dstextab,";"))  
                    aux_caldevch = DECIMAL(ENTRY(5,craptab.dstextab,";"))
                    aux_mrgitgcr = DECIMAL(ENTRY(6,craptab.dstextab,";"))
                    aux_mrgitgdb = DECIMAL(ENTRY(7,craptab.dstextab,";"))
                    aux_horabloq = ENTRY(8,craptab.dstextab,";").

            
            CREATE tt-fluxo-fin.

            ASSIGN tt-fluxo-fin.mrgsrdoc = aux_mrgsrdoc
                   tt-fluxo-fin.mrgsrchq = aux_mrgsrchq 
                   tt-fluxo-fin.mrgnrtit = aux_mrgnrtit
                   tt-fluxo-fin.mrgsrtit = aux_mrgsrtit
                   tt-fluxo-fin.caldevch = aux_caldevch
                   tt-fluxo-fin.mrgitgcr = aux_mrgitgcr
                   tt-fluxo-fin.mrgitgdb = aux_mrgitgdb
                   tt-fluxo-fin.horabloq = aux_horabloq.
            
        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Erro na consulta dos dados".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE grava_dados:

    DEF INPUT  PARAM par_cdcooper    LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    LIKE crapope.cdagenci              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_idorigem    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS   DATE                          NO-UNDO.
    DEF INPUT  PARAM par_mrgsrdoc    AS   DECIMAL                       NO-UNDO.
    DEF INPUT  PARAM par_mrgsrchq    AS   DECIMAL                       NO-UNDO.
    DEF INPUT  PARAM par_mrgnrtit    AS   DECIMAL                       NO-UNDO.
    DEF INPUT  PARAM par_mrgsrtit    AS   DECIMAL                       NO-UNDO.
    DEF INPUT  PARAM par_caldevch    AS   DECIMAL                       NO-UNDO.
    DEF INPUT  PARAM par_mrgitgcr    AS   DECIMAL                       NO-UNDO.
    DEF INPUT  PARAM par_mrgitgdb    AS   DECIMAL                       NO-UNDO.
    DEF INPUT  PARAM par_horabloq    AS   CHARACTER                     NO-UNDO.
    DEF INPUT  PARAM par_cdcoopex    AS   INT                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dstextab    AS   CHAR                                   NO-UNDO.
    DEF VAR aux_mrgsrdoc    AS   DECIMAL                                NO-UNDO.
    DEF VAR aux_mrgsrchq    AS   DECIMAL                                NO-UNDO.
    DEF VAR aux_mrgnrtit    AS   DECIMAL                                NO-UNDO.
    DEF VAR aux_mrgsrtit    AS   DECIMAL                                NO-UNDO.
    DEF VAR aux_caldevch    AS   DECIMAL                                NO-UNDO.
    DEF VAR aux_mrgitgcr    AS   DECIMAL                                NO-UNDO.
    DEF VAR aux_mrgitgdb    AS   DECIMAL                                NO-UNDO.
    DEF VAR aux_horabloq    AS   CHARACTER                              NO-UNDO.
    DEF VAR aux_cdcritic    AS   INTEGER                                NO-UNDO.
    DEF VAR aux_dscritic    AS   CHAR                                   NO-UNDO.      

    ASSIGN aux_dstextab = ""
           aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    IF  INTEGER(ENTRY(1,par_horabloq,":")) > 23 OR
        INTEGER(ENTRY(2,par_horabloq,":")) > 59 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Horario de bloqueio invalido.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".

        END.

    IF (par_mrgsrdoc > 100   OR
        par_mrgsrdoc < -100) OR
       (par_mrgsrchq > 100   OR
        par_mrgsrchq < -100) OR
       (par_mrgnrtit > 100   OR
        par_mrgnrtit < -100) OR
       (par_mrgsrtit > 100   OR
        par_mrgsrtit < -100) OR
       (par_caldevch > 100   OR 
        par_caldevch < -100) OR
        (par_mrgitgcr > 100  OR
        par_mrgitgcr < -100) OR
        (par_mrgitgdb > 100  OR
        par_mrgitgdb < -100) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Percentual invalido.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".

        END.

    FIND craptab WHERE craptab.cdcooper = par_cdcoopex    AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "GENERI"        AND
                       craptab.cdempres = 00              AND
                       craptab.cdacesso = "PARFLUXOFINAN" AND
                       craptab.tpregist = 0
                       EXCLUSIVE-LOCK NO-ERROR.

    IF  AVAIL(craptab) THEN
        DO:
            ASSIGN aux_dstextab = STRING(par_mrgsrdoc) + ";" +
                                  STRING(par_mrgsrchq) + ";" +
                                  STRING(par_mrgnrtit) + ";" +
                                  STRING(par_mrgsrtit) + ";" +
                                  STRING(par_caldevch) + ";" +
                                  STRING(par_mrgitgcr) + ";" +
                                  STRING(par_mrgitgdb) + ";" +
                                  par_horabloq.
            
            ASSIGN aux_mrgsrdoc = DECIMAL(ENTRY(1,craptab.dstextab,";")) 
                   aux_mrgsrchq = DECIMAL(ENTRY(2,craptab.dstextab,";")) 
                   aux_mrgnrtit = DECIMAL(ENTRY(3,craptab.dstextab,";")) 
                   aux_mrgsrtit = DECIMAL(ENTRY(4,craptab.dstextab,";")) 
                   aux_caldevch = DECIMAL(ENTRY(5,craptab.dstextab,";"))
                   aux_mrgitgcr = DECIMAL(ENTRY(6,craptab.dstextab,";"))
                   aux_mrgitgdb = DECIMAL(ENTRY(7,craptab.dstextab,";"))
                   aux_horabloq = ENTRY(8,craptab.dstextab,";").

            ASSIGN craptab.dstextab = aux_dstextab.

            FIND crapcop WHERE crapcop.cdcooper = par_cdcoopex
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapcop) THEN
                RETURN "NOK".

            IF  aux_mrgsrdoc <> par_mrgsrdoc THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Margem SR Doc " +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(STRING(aux_mrgsrdoc)) + " para  " +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.
                      
            IF  aux_mrgsrchq <> par_mrgsrchq THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Margem SR Cheque " +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(STRING(aux_mrgsrchq)) + " para  " +
                          TRIM(STRING(par_mrgsrchq))             +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.

            IF  aux_mrgnrtit <> par_mrgnrtit THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Margem NR Titulos " +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(STRING(aux_mrgnrtit)) + " para  " +
                          TRIM(STRING(par_mrgnrtit))             +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.

            IF  aux_mrgsrtit <> par_mrgsrtit THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Margem SR Titulos " +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(STRING(aux_mrgsrtit)) + " para  " +
                          TRIM(STRING(par_mrgsrtit))             +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.

            IF  aux_caldevch <> par_caldevch THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Margem SR Titulos " +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(STRING(aux_caldevch)) + " para  " +
                          TRIM(STRING(par_caldevch))             +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.

            IF  aux_mrgitgcr <> par_mrgitgcr THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Margem Cta Itg BB Credito" +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(STRING(aux_mrgitgcr)) + " para  " +
                          TRIM(STRING(par_mrgitgcr))             +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.

            IF  aux_mrgitgdb <> par_mrgitgdb THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Margem Cta Itg BB Debito" +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(STRING(aux_mrgitgdb)) + " para  " +
                          TRIM(STRING(par_mrgitgdb))             +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.

            IF  aux_horabloq <> par_horabloq THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o campo Horario de Bloqueio " +
                          " do PA " + STRING(par_cdagenci) + " de "        +
                          TRIM(aux_horabloq) + " para  "  +
                          TRIM(par_horabloq) +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop)         + 
                          "/log/tab094.log").
                END.

        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Problema na gravacao dos dados.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE acesso_opcao:

    DEF INPUT  PARAM par_cdcooper    AS  INTEGER                        NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    AS  INTEGER                        NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS  INTEGER                        NO-UNDO.
    DEF INPUT  PARAM par_cddopcao    AS  CHARACTER                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE  aux_cdcritic    AS  INTEGER                        NO-UNDO.
    DEFINE VARIABLE  aux_dscritic    AS  CHARACTER                      NO-UNDO.

    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    IF  par_cddepart <> 8    AND /* COORD.ADM/FINANCEIRO */
        par_cddepart <> 11   AND /* FINANCEIRO */
        par_cddepart <> 20   AND /* TI */
        par_cddopcao <> "C" THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Permissao de acesso negada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.
        

    RETURN "OK".

END PROCEDURE.

