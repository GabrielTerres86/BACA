/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0181.p
    Autor   : Oliver Fagionato (GATI)
    Data    : Outubro/2013

    Objetivo  : Possuir todas as regras de negocio da tela CADSEG.
    
    Alteracao : 27/01/2014 - Ajustes em Funcionamento de fluxo. 
                           - Adicionado param par_cdsegura e par_nmdcampo em
                             proc. Retorna_seguradoras.(Jorge)
                             
                06/03/2014 - Incluso VALIDATE (Daniel)
                             
                13/05/2014 - Inclusao de VALIDACAO de CNPJ 
                             (Jaison - SF: 122406)
							
                06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0181tt.i }

DEFINE VARIABLE aux_cdcritic AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.


PROCEDURE Retorna_seguradoras:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdsegura AS INTE        NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo        AS CHAR        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcsg.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-crapcsg.

    FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_dscritic = "Operador nao encontrado"
                   par_nmdcampo = "".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN 'NOK'.
        END.
	
    IF  NOT CAN-DO ("20,14",STRING(crapope.cddepart))  THEN  DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 36,
                       INPUT-OUTPUT aux_dscritic).
        RETURN 'NOK'.
    END.
    
    IF par_cdsegura > 0 THEN
    DO:
        FIND FIRST crapcsg WHERE crapcsg.cdcooper = par_cdcooper
                             AND crapcsg.cdsegura = par_cdsegura
                             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crapcsg THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Seguradora nao encontrada"
                   par_nmdcampo = "cdsegura".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN 'NOK'.
        END.

        CREATE tt-crapcsg.
        BUFFER-COPY crapcsg TO tt-crapcsg.
    END.
    ELSE
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Codigo de seguradora invalida"
               par_nmdcampo = "cdsegura".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN 'NOK'.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Grava_dados_seguradora:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER          NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER          NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER          NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdsegura AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmsegura AS CHARACTER          NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmresseg AS CHARACTER          NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgativo AS LOGICAL            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcgcseg AS DECIMAL            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrato AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrultpra AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrlimpra AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrultprc AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrlimprc AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsasauto AS CHARACTER          NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsmsgseg AS CHARACTER          NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdhstaut AS INTEGER EXTENT 10  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdhstcas AS INTEGER EXTENT 10  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR               NO-UNDO.
    
    DEFINE OUTPUT PARAMETER par_nmdcampo AS CHAR               NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE i-cont AS INTEGER     NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_dscritic = "Operador nao encontrado".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN 'NOK'.
        END.

    IF  NOT CAN-DO ("20,14",STRING(crapope.cddepart))  THEN  DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 36,
                       INPUT-OUTPUT aux_dscritic).
        RETURN 'NOK'.
    END.

    Grava: DO TRANSACTION
           ON ERROR  UNDO Grava, LEAVE Grava
           ON QUIT   UNDO Grava, LEAVE Grava
           ON STOP   UNDO Grava, LEAVE Grava
           ON ENDKEY UNDO Grava, LEAVE Grava:

            RUN Valida_inclusao_seguradora(INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_dtmvtolt,
                                           INPUT par_idorigem,
                                           INPUT par_nmdatela,
                                           INPUT par_cdprogra,
                                           INPUT par_cdbccxlt,
                                           INPUT par_cdsegura,
                                           INPUT par_nmsegura,
                                           INPUT par_nrcgcseg,
                                           INPUT par_dsasauto,
                                           INPUT YES, /* valida completa */
                                           INPUT par_cddopcao,
                                          OUTPUT par_nmdcampo,
                                          OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
            
            
            FIND FIRST crapcsg WHERE crapcsg.cdcooper = par_cdcooper
                                 AND crapcsg.cdsegura = par_cdsegura
                                 EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crapcsg THEN
                DO:
                    CREATE crapcsg.
                    ASSIGN crapcsg.cdcooper = par_cdcooper
                           crapcsg.cdsegura = par_cdsegura.
                    VALIDATE crapcsg.
                    
                    RUN Gera_log(INPUT par_cdcooper,
                                 INPUT "Cadastro Seguradoras",
                                 INPUT par_dtmvtolt,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT STRING(ROWID(crapcsg))). 
                END.

            ASSIGN crapcsg.nmsegura = par_nmsegura
                   crapcsg.nmresseg = par_nmresseg
                   crapcsg.flgativo = par_flgativo
                   crapcsg.nrcgcseg = par_nrcgcseg
                   crapcsg.nrctrato = par_nrctrato
                   crapcsg.nrultpra = par_nrultpra
                   crapcsg.nrlimpra = par_nrlimpra
                   crapcsg.nrultprc = par_nrultprc
                   crapcsg.nrlimprc = par_nrlimprc
                   crapcsg.dsasauto = par_dsasauto
                   crapcsg.dsmsgseg = par_dsmsgseg. 
            
            VALIDATE crapcsg.
            
            DO i-cont = 1 TO 10:
                ASSIGN crapcsg.cdhstaut[i-cont] = par_cdhstaut[i-cont]
                       crapcsg.cdhstcas[i-cont] = par_cdhstcas[i-cont].
            END.

            RUN Gera_log(INPUT par_cdcooper,
                         INPUT "Cadastro Seguradoras",
                         INPUT par_dtmvtolt,
                         INPUT par_cdoperad,
                         INPUT par_dtmvtolt,
                         INPUT STRING(ROWID(crapcsg))).
    END.

    RELEASE crapcsg NO-ERROR.

    RETURN 'OK'.
    
END PROCEDURE.

PROCEDURE Valida_inclusao_seguradora:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdsegura AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmsegura AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcgcseg AS DECI        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsasauto AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_valdtudo AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmdcampo AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF VAR aux_stsnrcal                 AS LOGICAL     NO-UNDO.
    DEF VAR aux_inpessoa                 AS INTE        NO-UNDO.
    DEF VAR h-b1wgen9999                 AS HANDLE      NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_dscritic = "Operador nao encontrado".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN 'NOK'.
        END.

    IF  NOT CAN-DO ("20,14",STRING(crapope.cddepart))  THEN  DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 36,
                       INPUT-OUTPUT aux_dscritic).
        RETURN 'NOK'.
    END.

    IF  par_cdsegura = 0 THEN
        DO:
            ASSIGN aux_dscritic = "Informe o codigo da seguradora"
                   par_nmdcampo = "cdsegura".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_cdbccxlt,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN 'NOK'.
        END.

    IF par_valdtudo THEN
    DO:
         RUN sistema/generico/procedures/b1wgen9999.p 
                        PERSISTENT SET h-b1wgen9999.

         RUN valida-cpf-cnpj 
             IN h-b1wgen9999(INPUT  par_nrcgcseg,
                             OUTPUT aux_stsnrcal,
                             OUTPUT aux_inpessoa).

         DELETE PROCEDURE h-b1wgen9999.

        IF par_nmsegura = "" THEN
            ASSIGN aux_dscritic = "Informe o nome da seguradora"
                   par_nmdcampo = "nmsegura".
        ELSE IF par_nrcgcseg = 0 THEN
            ASSIGN aux_dscritic = "Informe o CNPJ da seguradora"
                   par_nmdcampo = "nrcgcseg".
        ELSE IF aux_stsnrcal = FALSE OR 
                aux_inpessoa <> 2 THEN
            ASSIGN aux_dscritic = "CPNJ nao e valido"
                   par_nmdcampo = "nrcgcseg".
        ELSE IF par_dsasauto = "" THEN
            ASSIGN aux_dscritic = "Informe a assistencia auto"
                   par_nmdcampo = "dsasauto".
    END.
    ELSE
    DO:
        FIND FIRST crapcsg WHERE crapcsg.cdcooper = par_cdcooper 
                             AND crapcsg.cdsegura = par_cdsegura
                             NO-LOCK NO-ERROR.

        IF  AVAIL crapcsg THEN
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Seguradora ja cadastrada"
                   par_nmdcampo = "cdsegura".

    END.
    
    IF aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_cdbccxlt,
                       INPUT 1,
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
        RETURN 'NOK'.
    END.

    RETURN 'OK'.

END PROCEDURE.

PROCEDURE Elimina_seguradora:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdsegura AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_dscritic = "Operador nao encontrado".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN 'NOK'.
        END.

    IF  NOT CAN-DO ("20,14",STRING(crapope.cddepart))  THEN  DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 36,
                       INPUT-OUTPUT aux_dscritic).
        RETURN 'NOK'.
    END.

    Elimina: DO TRANSACTION
             ON ERROR  UNDO Elimina, LEAVE Elimina
             ON QUIT   UNDO Elimina, LEAVE Elimina
             ON STOP   UNDO Elimina, LEAVE Elimina
             ON ENDKEY UNDO Elimina, LEAVE Elimina:

            DO  aux_contador = 1 TO 10:
                
                FIND FIRST crapcsg WHERE 
                           crapcsg.cdcooper = par_cdcooper AND 
                           crapcsg.cdsegura = par_cdsegura 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE crapcsg   THEN
                     IF   LOCKED crapcsg   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              aux_cdcritic = 55.
                              LEAVE.
                          END.    
                ELSE
                     aux_cdcritic = 0.
        
                LEAVE.
            END.  /*  Fim do DO .. TO  */
        
        
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    RETURN "NOK".
                END. 
            ELSE
               DO: 
                    DELETE crapcsg.
               END.
    END.

    RETURN 'OK'.

END PROCEDURE.

PROCEDURE Gera_log:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_tdtmvtol AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_registro AS CHARACTER   NO-UNDO.
    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN
        DO:
            MESSAGE "Cooperativa nao encontrada".
            PAUSE 2 NO-MESSAGE.
        END.
        
    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "        +
                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "       +
                      par_cdoperad + " '-->' Utilizou a opcao " + par_cddopcao +
                      " no dia " + par_tdtmvtol + " e alterou o registro "     +
                      par_registro + " >> /usr/coop/" + crapcop.dsdircop + 
                      "/log/cadseg.log").

    RETURN 'OK'.
    
END PROCEDURE. /* FIM gera-log */

PROCEDURE busca_crapcsg:
    /* Pesquisa para seguradora */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsegura AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmsegura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgativo AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcsg.
    
    DEF VAR aux_nrregist          AS INTE                           NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-crapcsg.

        ASSIGN par_nmsegura = TRIM(par_nmsegura).

        FOR EACH crapcsg WHERE 
                 crapcsg.cdcooper = par_cdcooper AND
                 (IF par_cdsegura <> 0 THEN
                  crapcsg.cdsegura = par_cdsegura ELSE TRUE) AND
                  crapcsg.nmsegura MATCHES("*" + par_nmsegura + "*") AND
                 (IF par_flgativo = TRUE OR par_flgativo = FALSE THEN
                  crapcsg.flgativo = par_flgativo ELSE TRUE)
                 NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.
            
            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapcsg WHERE 
                        tt-crapcsg.cdcooper = crapcsg.cdcooper AND
                        tt-crapcsg.cdsegura = crapcsg.cdsegura
                        NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapcsg THEN
                        DO:
                           CREATE tt-crapcsg.
                           BUFFER-COPY crapcsg TO tt-crapcsg.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.
        
        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.
