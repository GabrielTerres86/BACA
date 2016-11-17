/*..............................................................................

   Programa: b1wgen0083.p                  
   Autor   : Vitor.
   Data    : Janeiro/2011                      Ultima atualizacao: 02/12/2014

   Dados referentes ao programa:

   Objetivo  : Buscar dados p/ a tela IMPSAC.
   
   Alteracoes: 14/02/2013 - Substituido nmrescop por dsdircop ao importar
                            sacados. (Rafael)
                            
               17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)             
   
               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                           
..............................................................................*/
DEF STREAM str_1.
DEF STREAM str_2.

{ sistema/generico/includes/var_internet.i }    
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0083tt.i }

DEF   VAR aux_cdcritic     AS INTE                               NO-UNDO.
DEF   VAR aux_dscritic     AS CHAR                               NO-UNDO.

DEF   VAR aux_setlinha     AS CHAR                               NO-UNDO.
DEF   VAR aux_nmdsacad     AS CHAR                               NO-UNDO.
DEF   VAR aux_dsendsac     AS CHAR                               NO-UNDO.
DEF   VAR aux_complend     AS CHAR                               NO-UNDO.
DEF   VAR aux_nmbaisac     AS CHAR                               NO-UNDO.
DEF   VAR aux_nmcidsac     AS CHAR                               NO-UNDO.
DEF   VAR aux_cdufsaca     AS CHAR                               NO-UNDO.
DEF   VAR aux_nrcepsac     AS CHAR                               NO-UNDO.
DEF   VAR aux_dsinssac     AS CHAR                               NO-UNDO.
DEF   VAR aux_nrendsac     AS CHAR                               NO-UNDO.
DEF   VAR aux_nrinssac     AS DECI                               NO-UNDO.

DEF   VAR aux_contador     AS INTE                               NO-UNDO.
DEF   VAR aux_dscrdlog     AS CHAR     FORMAT "x(50)"            NO-UNDO. 
DEF   VAR aux_logerror     AS CHAR                               NO-UNDO. 
DEF   VAR aux_flgerror     AS LOGICAL                            NO-UNDO.
DEF   VAR aux_flgretor     AS LOGICAL                            NO-UNDO.
DEF   VAR aux_cdtpinsc     AS INTE                               NO-UNDO.
DEF   VAR aux_nmendter     AS CHAR                               NO-UNDO.

DEF   VAR aux_nmarqlog     AS CHAR                               NO-UNDO.

DEF   VAR h-b1wgen9999     AS HANDLE                             NO-UNDO.

/*****************************************************************************
 Procedure que carrega os dados p/ importacao, verificando a conta informada 
 e trazendo o nome da cooperativa p/ definir diretório do arquivo
*****************************************************************************/
PROCEDURE carrega_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nmendter AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_nmrescop AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_logerror AS CHAR                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
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

    FIND FIRST crapcop NO-LOCK WHERE crapcop.cdcooper = par_cdcooper.
    
    ASSIGN par_nmrescop = crapcop.dsdircop

           par_nmarqimp = "/micros/" + LOWER(par_nmrescop) + "/"

           par_logerror = 
           "/usr/coop/" + LOWER(par_nmrescop) + "/log/impsac_erro" + 
                                                      par_nmendter + ".log".
     
    RETURN "OK".


END PROCEDURE. /*carrega-dados*/

/*****************************************************************************
 Procedure para trazer os dados dos sacados
*****************************************************************************/
PROCEDURE busca-dados-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-sacados.

    EMPTY TEMP-TABLE tt-sacados.

    FOR EACH crapsab NO-LOCK WHERE crapsab.cdcooper = par_cdcooper AND
                                   crapsab.nrdconta = par_nrdconta:
      

        CREATE tt-sacados.

        IF crapsab.cdsitsac = 1 THEN
            tt-sacados.dssitsac = "Ativo".
        ELSE
            tt-sacados.dssitsac = "Inativo".

        ASSIGN tt-sacados.nmdsacad = crapsab.nmdsacad.

        IF crapsab.cdtpinsc = 1 THEN
            tt-sacados.nrcpfcgc = STRING(STRING(crapsab.nrinssac,"99999999999"),  
                                           "xxx.xxx.xxx-xx").  

        IF crapsab.cdtpinsc = 2 THEN
            tt-sacados.nrcpfcgc = STRING(STRING(crapsab.nrinssac,"99999999999999"),
                                           "xx.xxx.xxx/xxxx-xx").

    END.

    RETURN "OK".

END PROCEDURE. /*busca-dados-sacado*/

/*****************************************************************************
 Procedure para importacao do arquivo contendo os sacados.
*****************************************************************************/
PROCEDURE importa_arquivo:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmarqint AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmendter AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_flgerror AS LOGICAL                         NO-UNDO.
    DEF OUTPUT PARAM par_flgdados AS LOGICAL                         NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapsab.
    DEF OUTPUT PARAM TABLE FOR tt-logerro.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapsab.

    ASSIGN par_flgerror = FALSE
           par_flgdados = FALSE
           aux_contador = 0
           aux_contador = 0.
    
    IF   SEARCH(par_nmarqint) = ?   THEN 
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Arquivo '" + par_nmarqimp + 
                                  "' nao encontrado!" .

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,   /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
     
            RETURN "NOK".
        END.

    INPUT STREAM str_1 FROM VALUE(par_nmarqint) NO-ECHO.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:
       
       IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
        
       ASSIGN aux_contador = aux_contador + 1.
      
       IF  TRIM(aux_setlinha) = ""  THEN
           NEXT.
       
       IF  NUM-ENTRIES(aux_setlinha,";") > 9  THEN
           DO:

               ASSIGN aux_dscrdlog = "' Pagador da Linha '" +
                             STRING(aux_contador,"999999") + 
                             "': Formatacao invalida --> '" +
                             aux_setlinha.

               CREATE tt-logerro.
               ASSIGN tt-logerro.dscrdlog = aux_dscrdlog.
               
               RUN gera_log ( INPUT par_nmrescop,
                              INPUT aux_dscrdlog,
                              INPUT par_dtmvtolt,
                              INPUT par_nmendter,
                             OUTPUT aux_logerror).
               
               par_flgerror  = TRUE.
               
               NEXT.

           END.
           
       ASSIGN aux_nmdsacad = CAPS(TRIM(ENTRY(1,aux_setlinha,";")))
              aux_dsinssac = TRIM(ENTRY(2,aux_setlinha,";"))
              aux_dsendsac = CAPS(TRIM(ENTRY(3,aux_setlinha,";")))
              aux_nrendsac = TRIM(ENTRY(4,aux_setlinha,";"))
              aux_complend = CAPS(TRIM(ENTRY(5,aux_setlinha,";")))
              aux_nmbaisac = CAPS(TRIM(ENTRY(6,aux_setlinha,";")))
              aux_nmcidsac = CAPS(TRIM(ENTRY(7,aux_setlinha,";")))
              aux_cdufsaca = CAPS(TRIM(ENTRY(8,aux_setlinha,";")))
              aux_nrcepsac = TRIM(ENTRY(9,aux_setlinha,";")) NO-ERROR.

       IF  ERROR-STATUS:ERROR  THEN
           DO: 
               ASSIGN aux_dscrdlog = "'Pagador da Linha '" +
                           STRING(aux_contador,"999999") + 
                           "': Formatacao invalida --> '" +
                           aux_setlinha.

               CREATE tt-logerro.
               ASSIGN tt-logerro.dscrdlog = aux_dscrdlog.

               RUN gera_log ( INPUT par_nmrescop,
                              INPUT aux_dscrdlog,
                              INPUT par_dtmvtolt,
                              INPUT par_nmendter,
                             OUTPUT aux_logerror).

               par_flgerror  = TRUE.

               NEXT.

           END.

       INTE(aux_nrendsac) NO-ERROR.

       IF  ERROR-STATUS:ERROR  THEN
           ASSIGN aux_nrendsac = "0".
           
       INTE(aux_nrcepsac) NO-ERROR.
       
       IF  ERROR-STATUS:ERROR  THEN
           ASSIGN aux_nrcepsac = "0".    
       
       IF  aux_nmdsacad = ""  THEN
           DO:
               ASSIGN aux_dscrdlog = "'Pagador da Linha '" +
                           STRING(aux_contador,"999999") + 
                           "': Nome nao informado --> '" + 
                           "'CPF/CNPJ: '" + aux_dsinssac.

               CREATE tt-logerro.
               ASSIGN tt-logerro.dscrdlog = aux_dscrdlog.

               RUN gera_log ( INPUT par_nmrescop,
                              INPUT aux_dscrdlog,
                              INPUT par_dtmvtolt,
                              INPUT par_nmendter,
                             OUTPUT aux_logerror).
                             
               par_flgerror  = TRUE.

               NEXT.

           END.
          
       ASSIGN aux_nrinssac = DECI(REPLACE(REPLACE(REPLACE(aux_dsinssac,
                                     ".",""),"/",""),"-","")) NO-ERROR.
           
       IF  ERROR-STATUS:ERROR  OR
           aux_nrinssac = 0    THEN
           DO:
               IF  aux_nrinssac = 0  THEN
                   ASSIGN aux_dsinssac = "00000000000000".

               ASSIGN aux_dscrdlog = "'Pagador da Linha '" +
                           STRING(aux_contador,"999999") + 
                           "': CPF/CNPJ invalido --> '" + 
                           "'CPF/CNPJ: '" + aux_dsinssac.

               CREATE tt-logerro.
               ASSIGN tt-logerro.dscrdlog = aux_dscrdlog.
       
               RUN gera_log ( INPUT par_nmrescop,
                              INPUT aux_dscrdlog,
                              INPUT par_dtmvtolt,
                              INPUT par_nmendter,
                             OUTPUT aux_logerror).

               par_flgerror  = TRUE.

               NEXT.

           END.
               
       FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                          crapsab.nrdconta = par_nrdconta AND
                          crapsab.nrinssac = aux_nrinssac NO-LOCK NO-ERROR.
              
       IF  AVAILABLE crapsab  THEN
           DO:
               ASSIGN aux_dscrdlog = "'Pagador da Linha '" +
                             STRING(aux_contador,"999999") + 
                             "': Pagador ja cadastrado --> '" +
                             "'CPF/CNPJ: '" + aux_dsinssac.

               CREATE tt-logerro.
               ASSIGN tt-logerro.dscrdlog = aux_dscrdlog.

               RUN gera_log ( INPUT par_nmrescop,
                              INPUT aux_dscrdlog,
                              INPUT par_dtmvtolt,
                              INPUT par_nmendter,
                             OUTPUT aux_logerror).

               par_flgerror  = TRUE.

               NEXT.

           END.

       FIND tt-crapsab WHERE tt-crapsab.nrinssac = aux_nrinssac 
                                               NO-LOCK NO-ERROR.

       IF  AVAIL tt-crapsab THEN
           DO: 
               ASSIGN aux_dscrdlog = "'Pagador da Linha '" +
                             STRING(aux_contador,"999999") + 
                             "': CPF/CNPJ duplicado --> '" +
                             aux_nmdsacad + "' CPF/CNPJ: '" + 
                             aux_dsinssac.

               CREATE tt-logerro.
               ASSIGN tt-logerro.dscrdlog = aux_dscrdlog.
                 
               RUN gera_log ( INPUT par_nmrescop,
                              INPUT aux_dscrdlog,
                              INPUT par_dtmvtolt,
                              INPUT par_nmendter,
                             OUTPUT aux_logerror).
                                                        
               CREATE tt-craprej.
               ASSIGN tt-craprej.nrinssac = aux_nrinssac.

               par_flgerror  = TRUE.

               NEXT.
           END.

       RUN sistema/generico/procedures/b1wgen9999.p 
                                          PERSISTENT SET h-b1wgen9999.
       
       RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT aux_nrinssac,
                                           OUTPUT aux_flgretor,
                                           OUTPUT aux_cdtpinsc).

       DELETE PROCEDURE h-b1wgen9999.
                                    
       IF  NOT aux_flgretor  THEN
           DO:  
               ASSIGN aux_dscrdlog = "'Pagador da Linha '" +
                             STRING(aux_contador,"999999") +
                             "': CPF/CNPJ invalido --> '" +
                             "'CPF/CNPJ: '" + aux_dsinssac.

               CREATE tt-logerro.
               ASSIGN tt-logerro.dscrdlog = aux_dscrdlog.
                
               RUN gera_log ( INPUT par_nmrescop,
                              INPUT aux_dscrdlog,
                              INPUT par_dtmvtolt,
                              INPUT par_nmendter,
                             OUTPUT aux_logerror).

               par_flgerror  = TRUE.

               NEXT. 

           END.

        FIND tt-crapsab WHERE tt-crapsab.cdcooper = par_cdcooper AND
                              tt-crapsab.nrdconta = par_nrdconta AND
                              tt-crapsab.nrinssac = aux_nrinssac AND
                              tt-crapsab.cdtpinsc = aux_cdtpinsc 
                              NO-LOCK NO-ERROR.

        IF NOT AVAIL tt-crapsab THEN
           DO:
               CREATE tt-crapsab.                             
               ASSIGN tt-crapsab.cdcooper = par_cdcooper      
                      tt-crapsab.nrdconta = par_nrdconta      
                      tt-crapsab.nrinssac = aux_nrinssac      
                      tt-crapsab.cdtpinsc = aux_cdtpinsc      
                      tt-crapsab.nmdsacad = aux_nmdsacad      
                      tt-crapsab.dsendsac = aux_dsendsac      
                      tt-crapsab.nrendsac = INTE(aux_nrendsac)
                      tt-crapsab.complend = aux_complend      
                      tt-crapsab.nmbaisac = aux_nmbaisac      
                      tt-crapsab.nrcepsac = INTE(aux_nrcepsac)
                      tt-crapsab.nmcidsac = aux_nmcidsac      
                      tt-crapsab.cdufsaca = aux_cdufsaca      
                      tt-crapsab.cdoperad = par_cdoperad      
                      tt-crapsab.hrtransa = TIME              
                      tt-crapsab.dtmvtolt = par_dtmvtolt      
                      tt-crapsab.cdsitsac = 1.
           END.

        par_flgdados = TRUE.

    END. /*DO WHILE TRUE*/

    INPUT STREAM str_1 CLOSE.

END PROCEDURE. /*importa_arquivo*/

/*****************************************************************************
 Procedure para criar os Pagadores na tabela crapsab
*****************************************************************************/

PROCEDURE cria_sacados:

    DEF  INPUT PARAM TABLE FOR tt-crapsab.

    DEF OUTPUT PARAM par_dscritic AS CHAR                            NO-UNDO.

    DO TRANSACTION ON ENDKEY UNDO, RETURN "NOK"
                   ON ERROR  UNDO, RETURN "NOK":
        
            FOR EACH tt-crapsab NO-LOCK:
        
                CREATE crapsab.
                BUFFER-COPY tt-crapsab TO crapsab.
                VALIDATE crapsab.                       

            END.
        
    END.

    ASSIGN par_dscritic = "IMPORTACAO FEITA COM SUCESSO!".

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
 Procedure para gerar os logs temporarios de erros e log de importacao
*****************************************************************************/

PROCEDURE gera_log:

    DEF INPUT  PARAM par_nmrescop AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_dscrdlog AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT  PARAM par_nmendter AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_logerror AS CHAR                            NO-UNDO.
    
    par_logerror = "/usr/coop/" + LOWER(par_nmrescop) + "/log/impsac_erro" + 
                                                         par_nmendter + ".log".

    aux_nmarqlog = "/usr/coop/" + LOWER(par_nmrescop) + "/log/impsac.log".

    IF par_dscrdlog MATCHES "*Operador*" THEN
        DO:
            UNIX SILENT VALUE("echo " + 
                 STRING(par_dtmvtolt,"99/99/9999") +
                 "' - '" + STRING(TIME,"HH:MM:SS") +
                 par_dscrdlog + " >> "  + aux_nmarqlog).
        
        END.
    ELSE
        DO:
            UNIX SILENT VALUE("echo " + par_dscrdlog +
                              " >> "  + par_logerror).
        END.

END PROCEDURE.

/*****************************************************************************
 Procedure para gerar os logs de erros
*****************************************************************************/

PROCEDURE gera_log_erros:

    DEF INPUT  PARAM par_nmrescop AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT  PARAM TABLE FOR tt-logerro.

    aux_nmarqlog = "/usr/coop/" + LOWER(par_nmrescop) + "/log/impsac.log".

    FOR EACH tt-logerro NO-LOCK:

        UNIX SILENT VALUE("echo " +                       
             STRING(par_dtmvtolt,"99/99/9999") +          
             "' - '" + STRING(TIME,"HH:MM:SS") + "' --> '"
              + tt-logerro.dscrdlog + " >> "  + aux_nmarqlog).   

    END.

END PROCEDURE.
