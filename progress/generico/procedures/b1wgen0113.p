/*.............................................................................

   Programa: b1wgen0113.p
   Autor   : Fabricio
   Data    : Setembro/2011                     Ultima atualizacao: 11/12/2013

   Dados referentes ao programa:

   Objetivo  : BO de cadastro de solicitacao de 2a. via de cartao e/ou senha
               do beneficio do INSS, feita atraves da tela SOLINS - WEB.

   Alteracoes: 22/12/2011 - Correcoes solicitadas na tarefa 42237, para
                            geracao de erros e leituras de tabela fisica
                            (Tiago).
                            
               11/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)             

............................................................................ */

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1crap85 AS HANDLE NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR              NO-UNDO.
DEF VAR aux_nmendter AS CHAR              NO-UNDO.
DEF VAR par_flgrodar AS LOGI INITIAL TRUE NO-UNDO.
DEF VAR aux_flgescra AS LOGI              NO-UNDO.
DEF VAR aux_dscomand AS CHAR              NO-UNDO.
DEF VAR par_flgfirst AS LOGI INITIAL TRUE NO-UNDO. 
DEF VAR tel_dsimprim AS CHAR INITIAL "Imprimir" FORMAT "x(8)"   NO-UNDO.
DEF VAR tel_dscancel AS CHAR INITIAL "Cancelar" FORMAT "x(8)"   NO-UNDO.
DEF VAR par_flgcance AS LOGI                                    NO-UNDO.
DEF VAR aux_contador AS INTE                                    NO-UNDO.

PROCEDURE cadastra_solicitacao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_nridtrab AS DECI NO-UNDO.
    DEF INPUT PARAM par_nrbenefi AS DECI NO-UNDO.
    DEF INPUT PARAM par_nmbenefi AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS INTE NO-UNDO.
    DEF INPUT PARAM par_motivsol AS INTE NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR NO-UNDO.

    DEF VAR    aux_nmarquiv       AS CHAR NO-UNDO.

    DEF VAR    aux_cdmotsol       AS INTE NO-UNDO.
    DEF VAR    aux_contador       AS INTE NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                          "/arq/solins_" + par_dsiduser.

    /** Se houver arquivo no arq, faz a remocao **/
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2> /dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           par_nmarqimp = aux_nmarquiv + ".ex"
           par_nmarqpdf = aux_nmarquiv + ".pdf".

    RUN siscaixa/web/dbo/b1crap85.p PERSISTEN SET h-b1crap85.
    
    RUN segunda_via IN h-b1crap85 (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nridtrab,
                                   INPUT par_nrbenefi,
                                   INPUT par_cddopcao,
                                   INPUT par_motivsol,
                                   INPUT par_nmarqimp).

    DELETE PROCEDURE h-b1crap85.

    IF RETURN-VALUE = "NOK" THEN
    DO:
        ASSIGN par_dscritic = "Nao foi possivel gerar a solicitacao.".
       
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT par_dscritic,
                       INPUT-OUTPUT par_dscritic).      
        
                RETURN "NOK".
    END.
                   
    ASSIGN par_dscritic = "".

    TRANS_1:
    DO TRANSACTION ON ERROR UNDO TRANS_1, LEAVE TRANS_1:
    
        DO aux_contador = 1 TO 10:

            FIND crapsci EXCLUSIVE-LOCK WHERE     
                 crapsci.cdcooper = par_cdcooper   AND
                 crapsci.cdagenci = par_cdagenci   AND
                 crapsci.nrrecben = par_nridtrab   AND
                 crapsci.nrbenefi = par_nrbenefi   AND
                 crapsci.tpsolici = par_cddopcao   AND
                 crapsci.dtmvtolt = par_dtmvtolt   NO-ERROR.
                                 
            IF NOT AVAIL crapsci THEN
            DO:
                IF  LOCKED crapsci THEN
                    DO:
                        ASSIGN par_dscritic = "Registro sendo alterado. "
                               + "Tente Novamente.".
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN par_dscritic = "".

                        CREATE crapsci.
                        ASSIGN crapsci.cdcooper = par_cdcooper
                               crapsci.dtmvtolt = par_dtmvtolt
                               crapsci.cdagenci = par_cdagenci
                               crapsci.nrbenefi = par_nrbenefi
                               crapsci.nrrecben = par_nridtrab
                               crapsci.tpsolici = par_cddopcao.
                        VALIDATE crapsci.
                        LEAVE TRANS_1.
                    END.
            END.                   
            ELSE
                DO:
                    ASSIGN aux_cdmotsol = crapsci.cdmotsol
                           par_dscritic = "".
                    LEAVE TRANS_1.
                END.

        END.

        IF  par_dscritic <> "" THEN
            DO:
        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 0,
                               INPUT 1,            /** Sequencia **/
                               INPUT 0,
                               INPUT-OUTPUT par_dscritic).

                UNDO TRANS_1, RETURN "NOK".
            END.
       
        ASSIGN crapsci.cdoperad = par_cdoperad
               crapsci.cdmotsol = par_motivsol.

    END.
    
    IF  par_motivsol <> aux_cdmotsol OR 
        NEW crapsci THEN            
            RUN gera_log(par_dtmvtolt,par_cdoperad,par_nmbenefi,par_nrbenefi,
                         par_nridtrab,par_cddopcao,aux_cdmotsol,par_motivsol).

    IF par_idorigem = 5 THEN /* Ayllos WEB */
    DO:
        RUN gera_impressao(INPUT  par_cdcooper,
                   INPUT  par_nmarqimp,
                   INPUT-OUTPUT par_nmarqpdf,
                   OUTPUT par_dscritic).

        IF  RETURN-VALUE <> "OK" THEN
            RUN gera_erro (INPUT par_cdcooper,
                   INPUT par_cdagenci,
                   INPUT 0,
                   INPUT 0,            /** Sequencia **/
                   INPUT par_dscritic,
                   INPUT-OUTPUT par_dscritic).      

    END.
               
    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_log:

    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmrecben LIKE crapcbi.nmrecben              NO-UNDO.
    DEF INPUT PARAM par_nrbenefi LIKE crapcbi.nrbenefi              NO-UNDO.
    DEF INPUT PARAM par_nrrecben LIKE crapcbi.nrrecben              NO-UNDO.
    DEF INPUT PARAM par_tpsolici AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_cdmotsol AS INT                             NO-UNDO.
    DEF INPUT PARAM par_cdmotso2 AS INT                             NO-UNDO.
              
    IF   NEW crapsci   THEN
         UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999")
               + " "                                         +
               STRING(TIME,"HH:MM:SS") + "' --> '"           +
               " Operador "  + par_cdoperad    + " - "       +
               " NIT " + STRING(par_nrrecben)  + " - "       +
               " NB " + STRING(par_nrbenefi)   + " - "       +
               " Beneficiario " + par_nmrecben + " - "       +
               " solicitou "    + par_tpsolici               +
               " pelo motivo "  + STRING(par_cdmotso2) + "." +
               " >> /usr/coop/" + crapcop.dsdircop + "/log/solins.log").
    ELSE
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999")
               + " "                                         +
               STRING(TIME,"HH:MM:SS") + "' --> '"           +
               " Operador " + par_cdoperad     + " - "       +
               " NIT " + STRING(par_nrrecben)  + " - "       +
               " NB " + STRING(par_nrbenefi)   + " - "       +
               " Beneficiario " + par_nmrecben + " - "       +
               " alterou o campo 'Motivo da solicitacao'"    + 
               " de " + STRING (par_cdmotsol)                +  
               " para " + STRING(par_cdmotso2) + "."         + 
               " >> /usr/coop/" + crapcop.dsdircop + "/log/solins.log").

    RETURN "OK".
END.

PROCEDURE gera_impressao:

    DEF INPUT         PARAM  par_cdcooper  AS INTE                     NO-UNDO.
    DEF INPUT         PARAM  par_nmarqimp  AS CHAR                     NO-UNDO.

    DEF INPUT-OUTPUT  PARAM  par_nmarqpdf  AS CHAR                     NO-UNDO.
    DEF OUTPUT        PARAM  par_dscritic  AS CHAR                     NO-UNDO.

    DEF VARIABLE             h-b1wgen0024  AS HANDLE                   NO-UNDO.

    Imp-Web: DO WHILE TRUE:
        RUN sistema/generico/procedures/b1wgen0024.p 
                                            PERSISTENT SET h-b1wgen0024.
               
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        DO:
            ASSIGN par_dscritic = "Handle invalido para BO b1wgen0024.".
            LEAVE Imp-Web.
        END.

        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                INPUT par_nmarqpdf).
              
        IF  SEARCH(par_nmarqpdf) = ?  THEN
        DO:
            ASSIGN par_dscritic = "Nao foi possivel gerar " + 
                                                "a impressao.".
            LEAVE Imp-Web.
        END.
               
        UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                      '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra 
                      + ':/var/www/ayllos/documentos/' + crapcop.dsdircop 
                      + '/temp/" 2>/dev/null').
               
        LEAVE Imp-Web.
    END. /** Fim do DO WHILE TRUE **/

    IF  VALID-HANDLE(h-b1wgen0024)  THEN
        DELETE OBJECT h-b1wgen0024.

    UNIX SILENT VALUE ("rm " + par_nmarqpdf + "* 2>/dev/null").  
    
    IF  par_dscritic <> "" THEN
        RETURN "NOK".

    ASSIGN par_nmarqpdf = ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/").
    
    RETURN "OK".
END PROCEDURE.
