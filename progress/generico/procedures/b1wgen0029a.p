/*..............................................................................

   Programa: b1wgen0029a.p                  
   Autor   : Guilherme
   Data    : Julho/2008                        Ultima atualizacao: 26/10/2012

   Dados referentes ao programa:

   Objetivo  : Obter os dados do help da tela (Chamada pela b1wgen0029)

   Alteracoes: 26/10/2012 - Tratar da nova estrutura gnchopa (Gabriel).
                            
..............................................................................*/

    { sistema/generico/includes/b1wgen0029tt.i }

    DEF INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_nmrotina AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                NO-UNDO.
    DEF INPUT PARAM par_inrotina AS INTE                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-f2.

    DEF VAR aux_contador AS INTE                        NO-UNDO.

    FIND FIRST craptel WHERE craptel.cdcooper = par_cdcooper AND
                             craptel.nmdatela = par_nmdatela NO-LOCK NO-ERROR.
    
    /* Nao lista todas as rotinas da tela */
    IF  par_inrotina = 0  THEN
        DO:
            FIND LAST gnchelp WHERE gnchelp.nmdatela =  par_nmdatela AND
                                    gnchelp.nmrotina =  par_nmrotina AND
                                    gnchelp.dtlibera <= par_dtmvtolt 
                                    NO-LOCK NO-ERROR.
                    
            IF  NOT AVAILABLE gnchelp  THEN
                RETURN "NOK".

            FIND gnchopa WHERE gnchopa.nmdatela = gnchelp.nmdatela   AND
                               gnchopa.nmrotina = gnchelp.nmrotina   AND
                               gnchopa.nrversao = gnchelp.nrversao
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE gnchopa   THEN
                 RETURN "NOK".   

            CREATE tt-f2.
            ASSIGN tt-f2.nmdatela = gnchelp.nmdatela
                   tt-f2.nmrotina = gnchelp.nmrotina
                   tt-f2.nrversao = gnchelp.nrversao
                   tt-f2.dtmvtolt = gnchelp.dtmvtolt
                   tt-f2.cdoperad = gnchelp.cdoperad
                   tt-f2.dsdohelp = gnchelp.dsdohelp
                   tt-f2.dtlibera = gnchelp.dtlibera
                   tt-f2.lsopeavi = gnchopa.lsopeavi 
                   tt-f2.nmoperad = gnchelp.nmoperad
                   tt-f2.tldatela = craptel.tldatela.
        END.
    ELSE
    IF  par_inrotina = 1  THEN /* Lista todas as rotinas */
        DO:
            FOR EACH craptel WHERE craptel.cdcooper = par_cdcooper AND
                                   craptel.nmdatela = par_nmdatela
                                   NO-LOCK:
                       
                /* Versoes liberadas */
                FIND LAST gnchelp WHERE gnchelp.nmdatela  = craptel.nmdatela
                                    AND gnchelp.nmrotina  = craptel.nmrotina
                                    AND gnchelp.dtlibera <= par_dtmvtolt 
                                    NO-LOCK NO-ERROR.
                            
                IF   NOT AVAILABLE gnchelp   THEN
                     NEXT.

                FIND gnchopa WHERE gnchopa.nmdatela = gnchelp.nmdatela   AND
                                   gnchopa.nmrotina = gnchelp.nmrotina   AND
                                   gnchopa.nrversao = gnchelp.nrversao
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE gnchopa   THEN
                     RETURN "NOK".
   
                CREATE tt-f2.
                ASSIGN tt-f2.nmdatela = gnchelp.nmdatela
                       tt-f2.nmrotina = gnchelp.nmrotina
                       tt-f2.nrversao = gnchelp.nrversao
                       tt-f2.dtmvtolt = gnchelp.dtmvtolt
                       tt-f2.cdoperad = gnchelp.cdoperad
                       tt-f2.dsdohelp = gnchelp.dsdohelp
                       tt-f2.dtlibera = gnchelp.dtlibera
                       tt-f2.lsopeavi = gnchopa.lsopeavi
                       tt-f2.nmoperad = gnchelp.nmoperad
                       tt-f2.tldatela = craptel.tldatela.            
                       
                ASSIGN aux_contador = aux_contador + 1.       
            END.            
            
            IF  aux_contador = 0  THEN
                RETURN "NOK".
        END.

/* .......................................................................... */