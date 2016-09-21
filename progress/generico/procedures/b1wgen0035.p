/*..............................................................................

    Programa: b1wgen0035.p
    Autor   : Magui/David
    Data    : Setembro/2008                   Ultima Atualizacao: 03/03/2016
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a geracao dos arquivos DLO.
                    
    Alteracoes: 08/10/2008 - Acerto na formatacao do valor (David).
    
                29/04/2009 - Layout alterado pelo Banco Central (David).
                
                07/08/2009 - Tratamento para envio de substituicao (David).
                        
                13/01/2010 - Parametro 1 passou para 13 por causa do envio
                             de novas contas (Magui).

                25/01/2010 - Parametro 2 passou para S por causa da alteracao
                             no parametro 1. E no parametro 31 colocar o
                             nome do Jose Carlos, e_mail e telefone (Magui).
                             
                09/02/2010 - Na CECRED,o parametro 1 deve continuar 11 (Magui).
                
                17/02/2010 - Na CECRED,o parametro 2 e N (Magui).  
                
                17/05/2010 - Adaptar para novo layout (David).
                
                21/03/2011 - Cdpara1 na CECRED de 11 para 14 (Magui).
                
                06/03/2014 - Incluido parametro 22 no XML e criado FORMAT dinamico
                             para contas DLO. (Reinert)
                
                10/02/2015 - Alteração/Inclusao de parametros no XML na procedure
                             gera_arquivo_dlo conforme SD 250688 (Vanessa)

                03/03/2016 - Alterar o e-mail de "jccosta@cecred.coop.br" para 
				             "fernando.schmitt@cecred.coop.br" na procedure
							 gera_arquivo_dlo (Douglas - Chamado 410956)
.............................................................................~ .*/

{ sistema/generico/includes/b1wgen0035.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdvalor AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.

PROCEDURE gera_arquivo_dlo:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdcopdlo LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_nrdocnpj LIKE crapcop.nrdocnpj             NO-UNDO.
    DEF  INPUT PARAM par_dsdircop LIKE crapcop.dsdircop             NO-UNDO.
    DEF  INPUT PARAM par_nmctrcop LIKE crapcop.nmctrcop             NO-UNDO.
    DEF  INPUT PARAM par_dtrefere LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_cdpara12 AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_dsdirdlo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqdlo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsemlctr AS CHAR                                    NO-UNDO.
    /***
    DEF VAR aux_cdpara1  AS CHAR FORMAT "X(02)" INITIAL "13"        NO-UNDO.
    DEF VAR aux_cdpara2  AS CHAR FORMAT "X(01)" INITIAL "S"         NO-UNDO.
    ***/
    DEF VAR aux_flglim03 AS LOGI                                    NO-UNDO.
    DEF VAR aux_flglim05 AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_formatct AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
          
    /** E-Mail do contador **/
    ASSIGN aux_dsemlctr  = "fernando.schmitt@cecred.coop.br"
           par_nmctrcop  = "FERNANDO ANDRE SCHMITT".

    /***
    IF  par_cdcopdlo = 3  THEN  /** DLO da Cecred **/
        ASSIGN aux_cdpara1 = "14"
               aux_cdpara2 = "N".
    ***/
    ASSIGN aux_nmarqdlo = "/usr/coop/" + par_dsdircop + "/arq/2061" + 
                          STRING(YEAR(par_dtrefere),"9999") + 
                          STRING(MONTH(par_dtrefere),"99") + ".xml"
           par_dsdirdlo = "/micros/" + par_dsdircop + "/contab/" + 
                          SUBSTR(aux_nmarqdlo,R-INDEX(aux_nmarqdlo,"2061")).
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqdlo).
    
    PUT STREAM str_1 UNFORMATTED
                     '<?xml version="1.0" encoding="UTF-8" ?>' SKIP
                     '<documentoDLO cnpj="'
                     SUBSTR(STRING(par_nrdocnpj,"99999999999999"),1,8) 
                      FORMAT "x(8)"
                     '" dataBase="' 
                     STRING(YEAR(par_dtrefere),"9999") FORMAT "x(4)"
                     '-' FORMAT "x(1)" 
                     STRING(MONTH(par_dtrefere),"99") FORMAT "x(2)" 
                     '" codigoDocumento="2061" tipoEnvio="' + par_cdpara12 + '" >' SKIP.
                  
    FIND FIRST crapdlo WHERE crapdlo.cdcooper = par_cdcopdlo AND
                             crapdlo.dtmvtolt = par_dtrefere AND
                             crapdlo.cdlimite = 3            NO-LOCK NO-ERROR.

    ASSIGN aux_flglim03 = IF AVAILABLE crapdlo THEN TRUE ELSE FALSE.

    FIND FIRST crapdlo WHERE crapdlo.cdcooper = par_cdcopdlo AND
                             crapdlo.dtmvtolt = par_dtrefere AND
                             crapdlo.cdlimite = 5            NO-LOCK NO-ERROR.

    ASSIGN aux_flglim05 = IF AVAILABLE crapdlo THEN TRUE ELSE FALSE.
        
    PUT STREAM str_1 UNFORMATTED 
                     '  <limitesInformados>' SKIP
                     '    <limite codigoLimite="03.00" enviado="'
                          aux_flglim03 FORMAT "S/N" '" />' SKIP
                     '    <limite codigoLimite="05.00" enviado="'
                          aux_flglim05 FORMAT "S/N" '" />' SKIP
                     '  </limitesInformados>' SKIP
                     '  <parametros>' SKIP
                     /***
                     '    <parametro codigoParametro="1" valorParametro="' +
                     aux_cdpara1 + '" />'
                     SKIP
                     '    <parametro codigoParametro="2" valorParametro="' +
                     aux_cdpara2 + '" />'
                     SKIP
                     '    <parametro codigoParametro="3" valorParametro="1" />'
                     SKIP
                     '    <parametro codigoParametro="11" valorParametro="N" />'
                     SKIP
                     ***/

                    /* '    <parametro codigoParametro="12" valorParametro="' +
                     par_cdpara12 + '" />' SKIP */
                     '    <parametro codigoParametro="22" valorParametro="N" />'
                     SKIP
                     '    <parametro codigoParametro="31" valorParametro="' + 
                     par_nmctrcop + '" />' SKIP
                     '    <parametro codigoParametro="32" valorParametro="' + 
                     '47-3231-4723" />' SKIP
                     '    <parametro codigoParametro="33" valorParametro="' +
                     aux_dsemlctr + '" />' SKIP                     
                     '  </parametros>' SKIP
                     '  <contas>' SKIP.
                         
    FOR EACH crapdlo WHERE crapdlo.cdcooper = par_cdcopdlo AND 
                           crapdlo.dtmvtolt = par_dtrefere NO-LOCK
                           BY STRING(crapdlo.cddconta):
                
        ASSIGN aux_dsdvalor = REPLACE(TRIM(STRING(crapdlo.vllanmto,
                                      "zzzzzzzzzzzzz9.99-")),",",".")
               aux_dsdvalor = IF  crapdlo.vllanmto < 0  THEN
                                  "-" + SUBSTR(aux_dsdvalor,1,
                                               LENGTH(aux_dsdvalor) - 1)
                              ELSE
                                  aux_dsdvalor
               /* Os tres primeiros numeros da conta possuem format "999" fixo, as contas
                  possuem um padrao */
               aux_formatct = FILL(",99" , INTE((LENGTH(STRING(crapdlo.cddconta)) - 3) / 2))
               aux_dslinxml = '    <conta codigoConta="' + STRING(crapdlo.cddconta, "999" + aux_formatct)                        
                            + '" valorConta="' + aux_dsdvalor + '"'.

        ASSIGN aux_dslinxml = aux_dslinxml + ">".

        PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.
                     
        IF  CAN-FIND(FIRST crapddo WHERE 
                           crapddo.cdcooper = crapdlo.cdcooper AND 
                           crapddo.dtmvtolt = crapdlo.dtmvtolt AND 
                           crapddo.cddconta = crapdlo.cddconta NO-LOCK)  THEN
            DO:
                /**
                ASSIGN aux_dslinxml = aux_dslinxml + ">".

                PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.
                **/     
                RUN gera-detalhamento (INPUT par_cdcooper).

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        OUTPUT STREAM str_1 CLOSE.

                        RETURN "NOK".
                    END.
                       
                
                /**
                ASSIGN aux_dslinxml = '    </conta>'.

                PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.
                ***/
            END. 
        /***
        ELSE
            DO:                                     
                IF  CAN-FIND(FIRST craptab WHERE 
                             craptab.cdcooper = par_cdcooper     AND
                             craptab.nmsistem = "DLO"            AND
                             craptab.tptabela = "CONFIG"         AND
                             craptab.cdempres = crapdlo.cddconta AND
                             craptab.cdacesso = "DETCTADLO"      NO-LOCK)  THEN
                    DO:
                        OUTPUT STREAM str_1 CLOSE.

                        ASSIGN aux_cdcritic = 0 
                               aux_dscritic = "Falta registro de " +
                                              "detalhamento. Conta " + 
                                              STRING(crapdlo.cddconta) + ".".
                   
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                         
                        RETURN "NOK".
                    END.

                ASSIGN aux_dslinxml = aux_dslinxml + " />".
                      
                PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.
            END.
        ***/

        ASSIGN aux_dslinxml = '    </conta>'.

        PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.
                       
    END. /** Fim do FOR EACH crapdlo **/
                   
    PUT STREAM str_1 UNFORMATTED '  </contas>' SKIP
                                 '</documentoDLO>'.
                
    OUTPUT STREAM str_1 CLOSE.
                   
    UNIX SILENT VALUE ("cp " + aux_nmarqdlo + " /usr/coop/" + par_dsdircop +
                       "/salvar/").
    
    UNIX SILENT VALUE ("cp " + aux_nmarqdlo + " " + par_dsdirdlo).
                    
    RETURN "OK".

END PROCEDURE.

PROCEDURE gera-detalhamento:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.

    ASSIGN aux_dslinxml = '    <detalhamentosDLO>'.

    PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.

    FOR EACH crapddo WHERE crapddo.cdcooper = crapdlo.cdcooper AND 
                           crapddo.dtmvtolt = crapdlo.dtmvtolt AND 
                           crapddo.cddconta = crapdlo.cddconta NO-LOCK
                           BY crapddo.nrseqdet:

        

        ASSIGN aux_dsdvalor = REPLACE(TRIM(STRING(crapddo.vllanmto,
                                "zzzzzzzzzzzzz9.99-")),",",".")
               aux_dsdvalor = IF  crapddo.vllanmto < 0  THEN
                                  "-" + SUBSTR(aux_dsdvalor,1,
                                          LENGTH(aux_dsdvalor) - 1)
                              ELSE
                                  aux_dsdvalor
               aux_dslinxml = '      <detalhamentoDLO valorDetalhe="' +
                               aux_dsdvalor + '">'.

        PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.
                       
        RUN lista-elementos (INPUT par_cdcooper).

        IF  RETURN-VALUE = "NOK"  THEN
            RETURN "NOK".
                         
        ASSIGN aux_dslinxml = '      </detalhamentoDLO>'.
        PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.

    END. /** Fim do FOR EACH crapddo **/

    ASSIGN aux_dslinxml = '    </detalhamentosDLO>'.
    PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista-elementos:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.

    FOR EACH crapedd WHERE crapedd.cdcooper = crapddo.cdcooper AND 
                           crapedd.dtmvtolt = crapddo.dtmvtolt AND 
                           crapedd.cddconta = crapddo.cddconta AND 
                           crapedd.nrseqdet = crapddo.nrseqdet NO-LOCK
                           BY crapedd.cdelemen:
                         
        FIND craptab WHERE craptab.cdcooper = par_cdcooper     AND
                           craptab.nmsistem = "DLO"            AND
                           craptab.tptabela = "CONFIG"         AND
                           craptab.cdempres = 0                AND
                           craptab.cdacesso = "ELEMENDLO"      AND
                           craptab.tpregist = crapedd.cdelemen
                           NO-LOCK NO-ERROR.
                         
        IF  NOT AVAILABLE craptab  THEN
            DO:          
                ASSIGN aux_cdcritic = 0 
                       aux_dscritic = 'Erro de sistema. Falta registro ' +
                                      '"ELEMENDLO".'.
           
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                 
                RETURN "NOK".
            END.

        /** Elemento de valor inteiro **/
        IF  ENTRY(1,craptab.dstextab,";") = "I"  THEN 
            ASSIGN aux_dsdvalor = STRING(crapedd.vlelemen,
                                         TRIM(ENTRY(2,craptab.dstextab,";")))
                   aux_dslinxml = '        <detalhe codigoElemento="' +
                                  STRING(crapedd.cdelemen) + 
                                  '" valorElemento="' + aux_dsdvalor + '" />'.
        ELSE        
            ASSIGN aux_dsdvalor = REPLACE(TRIM(STRING(crapedd.vlelemen,
                                          "zzzzzzzzzzzzz9.99-")),",",".")
                   aux_dsdvalor = IF  crapedd.vlelemen < 0  THEN
                                      "-" + SUBSTR(aux_dsdvalor,1,
                                                   LENGTH(aux_dsdvalor) - 1)
                                  ELSE
                                      aux_dsdvalor
                   aux_dslinxml = '        <detalhe codigoElemento="' +
                                  STRING(crapedd.cdelemen) + 
                                  '" valorElemento="' + aux_dsdvalor + '" />'.

        PUT STREAM str_1 UNFORMATTED aux_dslinxml SKIP.
                           
    END. /** Fim do FOR EACH crapedd **/

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */


