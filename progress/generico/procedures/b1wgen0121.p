/*...................................................................................

    Programa: sistema/generico/procedures/b1wgen0121.p
    Autor   : Rogerius Militao (DB1)
    Data    : Outubro/2011                        Ultima atualizacao: 22/04/2015

    Objetivo  : Tranformacao BO tela SUMLOT

    Alteracoes: 27/04/2012 - Incluído validação de digitalição de borderos de 
                             cheques/títulos e limites de cheques/títulos 
                             (Guilherme Maba).
                             
               11/09/2012 - Alteracao de 27/04 somente com par_dtmvtoan 
                            (Guilherme).
                            
               19/04/2013 - Incluir critica que verifica se ha saldo em cofre na
                            Busca_Critica2 (Lucas R.)                           
                            
               25/06/2013 - Melhoria na leitura da crapenl (Evandro).
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               28/01/2014 - Alterado o parametro de data para validação de borderos
                            (Jean Michel).
                            
               22/04/2015 - Alteracao na formatacao do campo crabenl.nrseqenv de
                            6 para 10 caracteres. (Jaison/Elton - SD: 276984)
                            
....................................................................................*/

/*............................. DEFINICOES .........................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_dtvalida AS DATE                                        NO-UNDO.

DEF  TEMP-TABLE tt-documentos                                       NO-UNDO
        FIELD vldparam          AS DEC FORMAT "zzz,zzz,zz9.99"
        FIELD tpregist          AS INT.

DEF BUFFER crablot FOR craplot.
DEF BUFFER crabcop FOR crapcop.

DEF VAR h-b1wgen0024 AS HANDLE                                       NO-UNDO.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                GERAR AS CRITICAS PARA A TELA SUMLOT                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Criticas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
        
    DEF OUTPUT PARAM par_qtcompln AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlcompap AS DECIMAL                        NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgerros AS LOGICAL                                 NO-UNDO.

    DEF BUFFER crabage FOR crapage.
    DEF BUFFER crabbcl FOR crapbcl.
    
    /* Alimenta a tabela de parametros */
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper      AND         
                           craptab.nmsistem = "CRED"            AND         
                           craptab.tptabela = "GENERI"          AND         
                           craptab.cdempres = 00                AND         
                           craptab.cdacesso = "DIGITALIZA"
                           NO-LOCK:
        
        CREATE tt-documentos.
        ASSIGN tt-documentos.vldparam = DECI(ENTRY(2,craptab.dstextab,";"))
               tt-documentos.tpregist = craptab.tpregist.

    END. /* endfor craptab */

    /* Busca data para validação de borderos*/
    FIND craptab WHERE  craptab.cdcooper = par_cdcooper     AND
                        craptab.nmsistem = "CRED"           AND
                        craptab.tptabela = "GENERI"         AND
                        craptab.cdempres = 00               AND
                        craptab.cdacesso = "DIGITACOOP"     AND
                        craptab.tpregist = 0  NO-LOCK NO-ERROR.
    
    IF  AVAIL craptab  THEN 
        ASSIGN aux_dtvalida = DATE(ENTRY(3,craptab.dstextab,";")).

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Gera: DO ON ERROR UNDO Gera, LEAVE Gera:
    
        /* Busca quantidade de dias para envelopes TAA */
        FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        ASSIGN aux_flgerros = NO.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop +
                              "/rl/" + par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2> /dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). /* visualiza nao pode ter
                                                       caracteres de controle */
        IF  par_cdagencx > 0 THEN
            DO:
                FIND crabage WHERE crabage.cdcooper = par_cdcooper  AND
                                   crabage.cdagenci = par_cdagencx 
                                   NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL(crabage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15
                               par_nmdcampo = "cdagenci".
                        LEAVE Gera.                            
                    END.
            END.

        IF  par_cdbccxlt > 0 THEN
            DO:
                FIND crabbcl WHERE crabbcl.cdbccxlt = par_cdbccxlt 
                    NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE (crabbcl) THEN
                    DO:
                        ASSIGN aux_cdcritic = 57
                               par_nmdcampo = "cdbccxlt".
                        LEAVE Gera.                            
                    END.
            END.

        ASSIGN par_qtcompln = 0 
               par_vlcompap = 0.

        IF  par_cdagencx = 0 THEN
            DO:
                IF  par_cdbccxlt > 0 THEN
                    DO:
                        FOR EACH crablot WHERE 
                                 crablot.cdcooper = par_cdcooper AND
                                 crablot.dtmvtolt = par_dtmvtolt AND
                                 crablot.cdbccxlt = par_cdbccxlt NO-LOCK:

                            RUN Busca_Critica1
                                ( INPUT-OUTPUT par_qtcompln,
                                  INPUT-OUTPUT par_vlcompap,
                                  INPUT-OUTPUT aux_flgerros,
                                  INPUT-OUTPUT par_dtmvtoan).

                        END.
                    END.
                ELSE
                    DO:
                        FOR EACH crablot WHERE 
                                 crablot.cdcooper = par_cdcooper AND
                                 crablot.dtmvtolt = par_dtmvtolt NO-LOCK:

                            RUN Busca_Critica1
                                ( INPUT-OUTPUT par_qtcompln,
                                  INPUT-OUTPUT par_vlcompap,
                                  INPUT-OUTPUT aux_flgerros,
                                  INPUT-OUTPUT par_dtmvtoan).
                        END.
                    END.
            END.
        ELSE
            IF  par_cdbccxlt = 0 THEN
                DO:
                    FOR EACH crablot WHERE crablot.cdcooper = par_cdcooper AND
                                           crablot.dtmvtolt = par_dtmvtolt AND
                                           crablot.cdagenci = par_cdagencx 
                                           NO-LOCK:

                        RUN Busca_Critica1 (INPUT-OUTPUT par_qtcompln,
                                            INPUT-OUTPUT par_vlcompap,
                                            INPUT-OUTPUT aux_flgerros,
                                            INPUT-OUTPUT par_dtmvtoan).

                    END.
                END.
            ELSE
                DO:
                    FOR EACH crablot WHERE crablot.cdcooper = par_cdcooper  AND
                                           crablot.dtmvtolt = par_dtmvtolt  AND
                                           crablot.cdagenci = par_cdagencx  AND
                                           crablot.cdbccxlt = par_cdbccxlt
                                           NO-LOCK:

                        RUN Busca_Critica1 (INPUT-OUTPUT par_qtcompln,
                                            INPUT-OUTPUT par_vlcompap,
                                            INPUT-OUTPUT aux_flgerros,
                                            INPUT-OUTPUT par_dtmvtoan).

                    END.
                END.

        RUN Busca_Critica2 (INPUT par_cdcooper,
                            INPUT par_dtmvtolt,
                            INPUT par_cdagencx,
                            INPUT par_cdbccxlt,
                            INPUT aux_flgerros).

        ASSIGN aux_returnvl = "OK".
        LEAVE Gera.

    END. /* Gera */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        DO:

            ASSIGN aux_returnvl = "OK".       

            IF  par_idorigem = 5  THEN  /** Ayllos Web **/
                DO:
                    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                        SET h-b1wgen0024.
    
                    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                        DO:
                            ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                  "b1wgen0024.".
    
                        END.
    
                    RUN envia-arquivo-web IN h-b1wgen0024 
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-erro ).
    
                    IF  VALID-HANDLE(h-b1wgen0024)  THEN
                        DELETE PROCEDURE h-b1wgen0024.
    
                    IF  RETURN-VALUE <> "OK" THEN
                        ASSIGN aux_returnvl = "NOK".
                END.
        END.
        
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Criticas */
 

/* ------------------------------------------------------------------------ */
/*                       EFETUA A BUSCA DAS CRITICAS                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Critica1:

    DEF INPUT-OUTPUT PARAM par_qtcompln AS INTE                           NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlcompap AS DECIMAL                        NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_flgerros AS LOGICAL                        NO-UNDO.    
    DEF INPUT-OUTPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    
    DEF VAR aux_vldparam                AS DECI   FORMAT "zzz,zzz,zz9.99" NO-UNDO.
    DEF VAR aux_vlctrato                AS DECI                           NO-UNDO.
    DEF VAR aux_idseqite                AS INT                            NO-UNDO.

    IF   crablot.cdbccxlt = 11   AND
         crablot.nrdcaixa = 0    THEN 
         DO:
             ASSIGN par_flgerros = YES.
             PUT STREAM str_1
                 "Lote de caixa NAO ASSOCIADO ==> Pa: "
                 crablot.cdagenci " Lote: " crablot.nrdolote SKIP.
         END.
                 
    IF   NOT CAN-DO("12,20,21",STRING(crablot.tplotmov))   THEN
         ASSIGN par_qtcompln = par_qtcompln + crablot.qtcompln.

    IF   crablot.tplotmov =  9 OR 
         crablot.tplotmov = 10 OR
         crablot.tplotmov = 14 THEN
         ASSIGN par_vlcompap = par_vlcompap + crablot.vlcompcr.

    IF   (crablot.qtcompln - crablot.qtinfoln) <> 0 OR
         (crablot.vlcompdb - crablot.vlinfodb) <> 0 OR
         (crablot.vlcompcr - crablot.vlinfocr) <> 0 THEN
         DO:
             ASSIGN par_flgerros = YES.
             PUT STREAM str_1
                 "Lote NAO BATIDO ==> Pa: " 
                 crablot.cdagenci " Bco/Cxa: " crablot.cdbccxlt 
                 " Lote: " crablot.nrdolote SKIP. 
         END.      

    IF   crablot.qtinfocc = crablot.qtcompcc   AND
         crablot.vlinfocc = crablot.vlcompcc   AND
         crablot.qtcompcs = crablot.qtinfocs   AND
         crablot.vlcompcs = crablot.vlinfocs   AND
         crablot.qtcompci = crablot.qtinfoci   AND
         crablot.vlcompci = crablot.vlinfoci   THEN
         .
    ELSE     
         DO: 
             ASSIGN par_flgerros = YES.
             PUT STREAM str_1
                "Protoc. CUSTODIA nao batido => Pa: "
                  crablot.cdagenci 
                 " Bco/Cxa: " crablot.cdbccxlt " Lote: " crablot.nrdolote 
                  SKIP.
         END.

    /* Validação de borderos de títulos e cheques */

    IF  aux_dtvalida <= par_dtmvtoan THEN
    DO: 
    
    /* Busca parametro limite para cheque */
    FIND tt-documentos WHERE tt-documentos.tpregist = 2 NO-LOCK NO-ERROR.
    
    IF AVAIL tt-documentos THEN
        ASSIGN aux_vldparam = tt-documentos.vldparam.
    ELSE
        ASSIGN aux_vldparam = 0.

         
    /* Bordero de cheques */
    FOR EACH crapbdc WHERE crapbdc.cdcooper = crablot.cdcooper AND
                           crapbdc.insitbdc = 3                AND
                           crapbdc.dtlibbdc = par_dtmvtoan     AND
                           crapbdc.nrdolote = crablot.nrdolote AND
                           crapbdc.cdagenci = crablot.cdagenci AND
                           crapbdc.cdbccxlt = crablot.cdbccxlt AND
                           crapbdc.flgdigit = FALSE            NO-LOCK:
        
        ASSIGN aux_vlctrato = 0.
        /* Se possuir limite parametrizado */
        IF aux_vldparam > 0 THEN
        DO:
            FOR EACH crapcdb WHERE crapcdb.cdcooper = crapbdc.cdcooper AND
                                   crapcdb.nrborder = crapbdc.nrborder AND
                                   crapcdb.nrdconta = crapbdc.nrdconta NO-LOCK:
                ASSIGN aux_vlctrato = aux_vlctrato + crapcdb.vlcheque.
            END.
         
            /* Se o valor do contrato for inferior ao parametro, nao faz a validacao */
            IF  aux_vlctrato < aux_vldparam  THEN
                NEXT.
        END.
        
        ASSIGN par_flgerros = YES.
             PUT STREAM str_1
                "Bor. de cheques nao dig. => " 
                "Pa: " STRING(crablot.cdagenci,"999")  
                " Bco/Cxa: " STRING(crablot.cdbccxlt,"999")
                " Lote: " STRING(crablot.nrdolote,"999999")
                 SKIP.
        
    END. /* end bordero cheques */

    /* Bordero de títulos */
    /* Busca parametro de limite para titulo */
    FIND tt-documentos WHERE tt-documentos.tpregist = 4 NO-LOCK NO-ERROR.
    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_vldparam = tt-documentos.vldparam.
    ELSE
        ASSIGN aux_vldparam = 0.

    FOR EACH crapbdt WHERE crapbdt.cdcooper = crablot.cdcooper AND
                           crapbdt.insitbdt = 3                AND
                           crapbdt.dtlibbdt = par_dtmvtoan     AND
                           crapbdt.nrdolote = crablot.nrdolote AND
                           crapbdt.cdagenci = crablot.cdagenci AND
                           crapbdt.cdbccxlt = crablot.cdbccxlt AND
                           crapbdt.flgdigit = FALSE            NO-LOCK:

        ASSIGN aux_vlctrato = 0.
        /* Se possuir limite parametrizado */
        IF  aux_vldparam > 0  THEN
        DO:
            FOR EACH craptdb WHERE craptdb.cdcooper = crapbdt.cdcooper AND
                                   craptdb.nrborder = crapbdt.nrborder AND
                                   craptdb.nrdconta = crapbdt.nrdconta NO-LOCK:
                ASSIGN aux_vlctrato = aux_vlctrato + craptdb.vltitulo.
            END.

            /* Se o valor do contrato for inferior ao parametro, nao faz a validacao */
            IF  aux_vlctrato < aux_vldparam  THEN
                NEXT.
        END.

        ASSIGN par_flgerros = YES.
             PUT STREAM str_1
                "Bor. de titulos nao dig. => " 
                "Pa: " STRING(crablot.cdagenci,"999")  
                " Bco/Cxa: " STRING(crablot.cdbccxlt,"999")
                " Lote: " STRING(crablot.nrdolote,"999999")
                SKIP.
    END. /* end bordero titulos */

    /* Limite de cheque/titulo */
    FOR EACH  crapcdc WHERE crapcdc.cdcooper = crablot.cdcooper  AND
                            crapcdc.dtmvtolt = par_dtmvtoan      AND
                            crapcdc.cdagenci = crablot.cdagenci  AND
                            crapcdc.cdbccxlt = crablot.cdbccxlt  AND
                            crapcdc.nrdolote = crablot.nrdolote  NO-LOCK, 
        FIRST craplim WHERE craplim.cdcooper = crapcdc.cdcooper  AND
                            craplim.nrctrlim = crapcdc.nrctrlim  AND
                            craplim.nrdconta = crapcdc.nrdconta  AND                            
                            craplim.insitlim = 2                 AND
                            craplim.tpctrlim <> 1                AND
                            craplim.flgdigit = FALSE             NO-LOCK.
        
        /* Zerar variavel de controle de parametros */ 
        ASSIGN aux_vldparam = 0.

        /* Limite de desconto de cheque */
        IF  craplim.tpctrlim = 2 THEN
            ASSIGN aux_idseqite = 1.
        ELSE 
        /* Limite de desconto de titulo */
        IF  craplim.tpctrlim = 3 THEN
            ASSIGN aux_idseqite = 3.

        /* Busca parametro de limite para titulo */
        FIND tt-documentos WHERE tt-documentos.tpregist = aux_idseqite NO-LOCK NO-ERROR.
        
        IF  AVAIL tt-documentos  THEN
            ASSIGN aux_vldparam = tt-documentos.vldparam.
    
        IF  craplim.vllimite < aux_vldparam  THEN
            NEXT.

        /* limite de desconteo de cheque */
        IF  craplim.tpctrlim = 2 THEN
        DO:
            ASSIGN par_flgerros = YES.
                PUT STREAM str_1
                    "Lim. desc. de cheque nao dig. => " 
                    "Conta: " STRING(craplim.nrdconta,"zzzz,zzz,9")  
                    " Contrato: " STRING(craplim.nrctrlim,"z,zzz,zz9")
                    SKIP.
        END.        
        /* limite de desconto de titulo */
        ELSE 
        IF  craplim.tpctrlim = 3 THEN
        DO:
            ASSIGN par_flgerros = YES.
                PUT STREAM str_1
                    "Lim. desc. de titulo nao dig. => " 
                    "Conta: " STRING(craplim.nrdconta,"zzzz,zzz,9")  
                    " Contrato: " STRING(craplim.nrctrlim,"z,zzz,zz9")
                    SKIP.
        END.

    END. /* end limite de cheque/titulo */
    END.

END PROCEDURE. /* Busca_Critica1 */


/* ------------------------------------------------------------------------ */
/*                        EFETUA A BUSCA DAS CRITICAS                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Critica2:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerros AS LOGICAL                        NO-UNDO.

    DEF VAR aux_cdagefim AS INTE                                    NO-UNDO.
    DEF VAR aux_cdprogra AS CHAR                                    NO-UNDO.
    DEF VAR aux_hrtransa AS INTE                                    NO-UNDO.

    DEF BUFFER crabtrq FOR craptrq.
    DEF BUFFER crabcst FOR crapcst.
    DEF BUFFER crabcdb FOR crapcdb.
    DEF BUFFER crabbcx FOR crapbcx.
    DEF BUFFER crabenl FOR crapenl.
    DEF BUFFER crabtab FOR craptab.
    DEF BUFFER crabope FOR crapope.
    
    FOR EACH crabtrq WHERE crabtrq.cdcooper = par_cdcooper NO-LOCK:
    
        IF   crabtrq.qtinforq = crabtrq.qtcomprq   AND
             crabtrq.qtinfotl = crabtrq.qtcomptl   THEN
             NEXT.
    
        IF   par_cdagencx > 0 THEN
             IF   crabtrq.cdagelot = par_cdagencx THEN
                  DO:
                      ASSIGN aux_cdprogra = ""
                             par_flgerros = YES
                             aux_cdprogra = "LANREQ".
                      
                      PUT STREAM str_1
                          "Lote de requisicoes NAO BATIDO. Pa: "
                          crabtrq.cdagelot " Lote: " 
                          crabtrq.nrdolote " Na " aux_cdprogra
                          SKIP.
                      
                      NEXT.
                  END.
             ELSE
                  NEXT.
        ELSE
             DO:
                 ASSIGN aux_cdprogra = ""
                        par_flgerros = YES
                        aux_cdprogra = "LANREQ".
                                   
                 PUT STREAM str_1
                     "Lote de requisicoes NAO BATIDO. Pa: "
                     crabtrq.cdagelot " Lote: " crabtrq.nrdolote 
                     " Na " aux_cdprogra SKIP.
                 
                 NEXT.
             END.
    
    END.
    
    ASSIGN aux_cdagefim = IF   par_cdagencx = 0 THEN
                               9999
                          ELSE
                               par_cdagencx.
        
    /****** PROCESSAMENTO CST ******/
    FOR EACH crabcst WHERE crabcst.cdcooper  = par_cdcooper  AND
                           crabcst.dtmvtolt  = par_dtmvtolt  AND
                           crabcst.cdagenci >= par_cdagencx  AND
                           crabcst.cdagenci <= aux_cdagefim  AND
                           crabcst.insitprv < 2
                           NO-LOCK BREAK BY crabcst.nrdolote:
        
        IF   FIRST-OF(crabcst.nrdolote) THEN
             PUT STREAM str_1 "Ha Cheques de Custodia nao digitalizados => Pa: "
                              crabcst.cdagenci " Lote: " crabcst.nrdolote
                              SKIP.
        
    END.
    
        
    /****** PROCESSAMENTO CDB ******/
    FOR EACH crabcdb WHERE crabcdb.cdcooper  = par_cdcooper       AND
                           crabcdb.dtmvtolt >= par_dtmvtolt - 30  AND
                           crabcdb.cdagenci >= par_cdagencx       AND
                           crabcdb.cdagenci <= aux_cdagefim
                           NO-LOCK BREAK BY crabcdb.nrborder:
    
        IF   crabcdb.dtlibbdc <> par_dtmvtolt  OR
             crabcdb.insitprv >= 2             THEN
             NEXT.
                               
        IF   FIRST-OF(crabcdb.nrborder) THEN
             PUT STREAM str_1 "Ha Cheques de Desconto nao digitalizados => Pa: "
                              crabcdb.cdagenci " Bordero: " crabcdb.nrborder
                              SKIP.
    END.
    
    
    
    FOR EACH crabbcx WHERE crabbcx.cdcooper = par_cdcooper   AND 
                           crabbcx.dtmvtolt = par_dtmvtolt   AND
                           crabbcx.cdagenci <> 90 AND /* INTERNET */
                           crabbcx.cdagenci <> 91 AND /* TAA */
                           crabbcx.cdsitbcx = 1               NO-LOCK
                           USE-INDEX crapbcx1: 
                
        IF   par_cdagencx > 0   THEN
             IF   par_cdagencx <> crabbcx.cdagenci   THEN
                  NEXT.
                
        FIND crabope WHERE crabope.cdcooper = par_cdcooper       AND 
                           crabope.cdoperad = crabbcx.cdopecxa   NO-LOCK NO-ERROR.
           
        ASSIGN par_flgerros = YES.
        
        PUT STREAM str_1
            "Boletim de caixa ABERTO ==> Pa: "
            crabbcx.cdagenci " Caixa:" crabbcx.nrdcaixa
            " Operador:" crabbcx.cdopecxa "-" ENTRY(1,crabope.nmoperad," ")
            SKIP.
           
    END.  /*  Fim do FOR EACH  --  Leitura do crabbcx  */
    
    /* 
       Envelopes TAA pendentes:
       - Lista envelopes nao recolhidos (SIT = 0)
       - Lista envelopes recolhidos e nao processados (SIT = 3)
       OBS.: Considera horario de corte
    */
    
    /* Verifica os TAAs */
    FOR EACH craptfn WHERE craptfn.cdcooper  = par_cdcooper AND
                           craptfn.cdagenci >= par_cdagencx AND
                           craptfn.cdagenci <= aux_cdagefim AND
                           craptfn.cdsitfin <> 8  /* 8-Desativado */
                           NO-LOCK:

        /* Envelopes nao recolhidos */
        FOR EACH crabenl WHERE
                 crabenl.cdcoptfn  = craptfn.cdcooper   AND
                 crabenl.nrterfin  = craptfn.nrterfin   AND
                 crabenl.cdsitenv  = 0                  AND
                 crabenl.dtmvtolt >= (par_dtmvtolt - crabcop.qtdiaenl)
                 NO-LOCK:
        
            /* para envelopes nao recolhidos do dia, que foram depositados
               apos o horaio de corte, desconsidera  */
            IF   crabenl.dtmvtolt = par_dtmvtolt   THEN
                 DO:
                     FIND crabtab WHERE crabtab.cdcooper = crabenl.cdcoptfn   AND
                                        crabtab.nmsistem = "CRED"             AND
                                        crabtab.tptabela = "GENERI"           AND
                                        crabtab.cdempres = 0                  AND
                                        crabtab.cdacesso = "HRTRENVELO"       AND
                                        crabtab.tpregist = crabenl.cdagetfn
                                        NO-LOCK NO-ERROR.
                                        
                     ASSIGN aux_hrtransa = IF   AVAIL crabtab   THEN
                                                INTE(crabtab.dstextab)
                                           ELSE
                                                0.
        
                     IF   NOT AVAIL crabtab                 OR 
                          crabenl.hrtransa > aux_hrtransa   THEN
                          NEXT.
                 END. 
        
            ASSIGN par_flgerros = YES.
        
            PUT STREAM str_1 UNFORMATTED
                       "Envelopes nao recolhidos ==> " +
                       "TAA: "              + STRING(crabenl.nrterfin,"999")         + 
                       " " +                                                         
                       "Data do deposito: " + STRING(crabenl.dtmvtolt,"99/99/9999")  +
                       " - " + STRING(INTE(crabenl.hrtransa),"HH:MM")  
                       SKIP
                       FILL(" ",29) +
                       "Conferencia: " + STRING(crabenl.nrseqenv,"9999999999") + " " +
                       "Conta/DV: "    + STRING(crabenl.nrdconta,"zzzz,zzz,9")
                       SKIP
                       FILL(" ",29) + "Valor: ".
        
            IF   crabenl.vldininf > 0   THEN
                 PUT STREAM str_1 UNFORMATTED STRING(crabenl.vldininf,"zzz,zz9.99") +
                                              " - DINHEIRO" SKIP.
            ELSE
                 PUT STREAM str_1 UNFORMATTED STRING(crabenl.vlchqinf,"zzz,zz9.99") +
                                              " - CHEQUES" SKIP.
        END.
        
        /* Envelopes recolhidos, ainda nao liberados */
        FOR EACH crabenl WHERE
                 crabenl.cdcoptfn  = craptfn.cdcooper   AND
                 crabenl.nrterfin  = craptfn.nrterfin   AND
                 crabenl.cdsitenv  = 3                  AND
                 crabenl.dtmvtolt >= (par_dtmvtolt - crabcop.qtdiaenl)
                 NO-LOCK:

            ASSIGN par_flgerros = YES.
        
            PUT STREAM str_1 UNFORMATTED
                       "Envelopes nao liberados  ==> " +
                       "TAA: "              + STRING(crabenl.nrterfin,"999")         + 
                       " " +                                                         
                       "Data do deposito: " + STRING(crabenl.dtmvtolt,"99/99/9999")  +
                       " - " + STRING(INTE(crabenl.hrtransa),"HH:MM")  
                       SKIP
                       FILL(" ",29) +
                       "Conferencia: " + STRING(crabenl.nrseqenv,"9999999999") + " " +
                       "Conta/DV: "    + STRING(crabenl.nrdconta,"zzzz,zzz,9")
                       SKIP
                       FILL(" ",29) + "Valor: ".
        
            IF   crabenl.vldininf > 0   THEN
                 PUT STREAM str_1 UNFORMATTED STRING(crabenl.vldininf,"zzz,zz9.99") +
                                              " - DINHEIRO" SKIP.
            ELSE
                 PUT STREAM str_1 UNFORMATTED STRING(crabenl.vlchqinf,"zzz,zz9.99") +
                                              " - CHEQUES" SKIP.
        END.
    END.

    /* VERIFICA SE HA COFRE COM SALDO */
    FOR EACH crapslc WHERE crapslc.cdcooper = par_cdcooper AND
                           (IF par_cdagencx > 0 THEN 
                               crapslc.cdagenci = par_cdagencx
                            ELSE
                               crapslc.cdagenci > 0)       AND
                            crapslc.vlrsaldo > 0
                           NO-LOCK:
    
        ASSIGN par_flgerros = YES.
    
        PUT STREAM str_1 UNFORMATTED
            "Falta efetuar RECOLHIMENTO do saldo em Cofre ==> Pa: " +
            STRING(crapslc.cdagenci,"zz9") + " " +
            "Saldo: " + STRING(crapslc.vlrsaldo,"zzz,zzz,zzz,zz9.99")
            SKIP.
    END.
    
    IF   par_cdbccxlt = 0    AND
         NOT par_flgerros    THEN
         PUT STREAM str_1
             "NENHUMA pendencia ENCONTRADA" SKIP.
                
    OUTPUT STREAM str_1 CLOSE.
            
END PROCEDURE. /* Busca_Criticas2 */

