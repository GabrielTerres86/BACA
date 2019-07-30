/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0164.p
    Autor   : Carlos Henrique
    Data    : Agosto/2013                     Ultima atualizacao: 06/11/2013

    Objetivo  : Tranformacao BO tela ENDAVA
    
    Alteracoes: 06/11/2013 - Incluido assign com campos do endereço para
                             atender a parte de web (Jéssica DB1).
                             
                19/03/2015 - Incluir a paginação dos resultados para web (Vanessa).

............................................................................*/
{ sistema/generico/includes/b1wgen0164tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdcritic AS INTE INIT 0 NO-UNDO.
DEF VAR aux_dscritic AS CHAR        NO-UNDO.
DEF VAR aux_contador AS INTE        NO-UNDO.
DEF VAR aux_nrregist AS INTE        NO-UNDO.

PROCEDURE busca_crapavt:

    DEF  INPUT PARAM par_cdcooper   AS INTE          NO-UNDO.
    DEF  INPUT PARAM par_cdagenci   AS INTE          NO-UNDO.
    DEF  INPUT PARAM par_cdoperad   AS CHAR          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt   AS DATE          NO-UNDO.
    DEF  INPUT PARAM par_nmdatela   AS CHAR          NO-UNDO.
    DEF  INPUT PARAM par_tpctrato   AS INTE          NO-UNDO.
    DEF  INPUT PARAM par_pro_cpfcgc AS DECI          NO-UNDO.
    DEF  INPUT PARAM par_idorigem   AS INTE          NO-UNDO.
    DEF  INPUT PARAM par_nrregist   AS INTE          NO-UNDO.
    DEF  INPUT PARAM par_nriniseq   AS INTE          NO-UNDO.
    DEF OUTPUT PARAM par_qtregist   AS INTE          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-crapavt.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-crapavt.
    EMPTY TEMP-TABLE tt-erro.
    
    FIND FIRST crapass WHERE 
        crapass.cdcooper = par_cdcooper  AND
        crapass.nrcpfcgc = par_pro_cpfcgc  
        NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
            aux_cdcritic = 1499.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,          /* nrdcaixa*/
                           INPUT 1,          /* Sequencia */
                           INPUT 1499,          /* cdcritic */
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.
    
    FOR EACH crapavt WHERE crapavt.cdcooper  = par_cdcooper   AND
                           crapavt.nrcpfcgc  = par_pro_cpfcgc AND
                           crapavt.tpctrato <= par_tpctrato
                           NO-LOCK:
        CREATE tt-crapavt.
        BUFFER-COPY crapavt TO tt-crapavt.
        
        IF crapavt.cdnacion > 0 THEN
        DO:
          /* Buscar nacionalidade */
          FIND FIRST crapnac
             WHERE crapnac.cdnacion = crapavt.cdnacion
             NO-LOCK NO-ERROR.
        END.
        
        ASSIGN tt-crapavt.dsendres1 = crapavt.dsendres[1]
               tt-crapavt.dsendres2 = crapavt.dsendres[2]
      		   tt-crapavt.dsnacion  = crapnac.dsnacion WHEN AVAIL crapnac.

    END.

    IF  NOT AVAILABLE tt-crapavt   THEN
        DO:
            aux_cdcritic = 803.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,          /* nrdcaixa*/
                           INPUT 1,          /* Sequencia */
                           INPUT 803,          /* cdcritic */
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    IF  par_idorigem = 5 THEN DO:
        RUN pi_paginacao
        ( INPUT par_nrregist,
          INPUT par_nriniseq,
          INPUT TABLE tt-crapavt,
         OUTPUT par_qtregist,
         OUTPUT TABLE tt-crapavt).
        
    END. 

   
    RETURN "OK".

END PROCEDURE.

PROCEDURE grava_crapavt:

    DEF  INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cpfcgc   AS DEC                          NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INT  FORMAT "99"             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt       AS DATE                   NO-UNDO.
    DEF  INPUT PARAM par_pro_dsendav1   AS CHAR                   NO-UNDO.
    DEF  INPUT PARAM par_pro_dsendav2   AS CHAR                   NO-UNDO.
    DEF  INPUT PARAM par_pro_nrendere   AS INTE                   NO-UNDO.
    DEF  INPUT PARAM par_pro_nrfonres   AS CHAR FORMAT "x(20)"    NO-UNDO.
    DEF  INPUT PARAM par_pro_complend AS CHAR FORMAT "x(40)"      NO-UNDO.
    DEF  INPUT PARAM par_pro_nrcxapst AS INTE FORMAT "zz,zz9"     NO-UNDO.
    DEF  INPUT PARAM par_pro_dsdemail AS CHAR FORMAT "x(30)"      NO-UNDO.  
    DEF  INPUT PARAM par_pro_nmcidade AS CHAR FORMAT "x(15)"      NO-UNDO.
    DEF  INPUT PARAM par_pro_cdufresd AS CHAR FORMAT "!(2)"       NO-UNDO.
    DEF  INPUT PARAM par_pro_nrcepend AS INTE FORMAT "zz,zzz,zz9" NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = " ".
    
    ContadorAvt: DO aux_contador = 1 TO 10:

        FIND FIRST crapavt WHERE 
            crapavt.cdcooper = par_cdcooper  AND
            crapavt.tpctrato = par_tpctrato  AND
            crapavt.nrdconta = par_nrdconta  AND
            crapavt.nrctremp = par_nrctremp  AND
            crapavt.nrcpfcgc = par_cpfcgc
            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE crapavt THEN
            DO:
                IF  LOCKED(crapavt) THEN
                    DO:
                        IF  aux_contador = 10 THEN
                            DO:
                                aux_dscritic = "Informacoes do avalista " +
                                               "sendo alteradas em " +
                                               "outra estacao.".
                                LEAVE ContadorAvt.
                            END.
                        ELSE 
                            DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorAvt.
                            END.
                    END.
                ELSE 
                    DO:
                        aux_dscritic = "Nao foi encontrado registro " +
                                       "do avalista.".
                        LEAVE ContadorAvt.
                    END.
            END.
        ELSE
            DO:
                ASSIGN  crapavt.dtmvtolt    = par_dtmvtolt
                        crapavt.dsendres[1] = CAPS(par_pro_dsendav1) 
                        crapavt.dsendres[2] = CAPS(par_pro_dsendav2)
                        crapavt.nrendere    = par_pro_nrendere
                        crapavt.nrfonres    = par_pro_nrfonres
                        crapavt.complend    = CAPS(par_pro_complend)
                        crapavt.nrcxapst    = par_pro_nrcxapst
                        crapavt.dsdemail    = par_pro_dsdemail
                        crapavt.nmcidade    = CAPS(par_pro_nmcidade)
                        crapavt.cdufresd    = par_pro_cdufresd 
                        crapavt.nrcepend    = par_pro_nrcepend.
                
                RELEASE crapavt.
            END.
    END.

    IF  aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,          /* nrdcaixa*/
                           INPUT 1,          /* Sequencia */
                           INPUT 0,          /* cdcritic */
                           INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE pi_paginacao:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-crapavt.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapavt-aux.

    ASSIGN aux_nrregist = par_nrregist.

    EMPTY TEMP-TABLE tt-crapavt-aux.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        

        FOR EACH tt-crapavt:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-crapavt-aux.
                    BUFFER-COPY tt-crapavt TO tt-crapavt-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao*/


