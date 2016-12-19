/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0132.p
    Autor   : Lucas
    Data    : Novembro/2011               Ultima Atualizacao:
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela TAB007
                 
    Alteracoes: 06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

/*****************************************************************************
  Validar acesso à TAB007 
******************************************************************************/

PROCEDURE permiss_tab007:
         
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
   
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
     
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Permiss:
    DO:
        IF  par_cddepart <> 8   AND   /* COORD.ADM/FINANCEIRO */
            par_cddepart <> 20 THEN   /* TI */
            DO:
                aux_cdcritic = 36.
                LEAVE Permiss.
            END.
    END.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
  
    RETURN "OK".
  
END PROCEDURE.

/*****************************************************************************
  Carregar os dados gravados na TAB007 
******************************************************************************/
PROCEDURE busca_tab007:
         
    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
   
    DEF OUTPUT PARAM par_vlmaidep AS DEC                            NO-UNDO.
    DEF OUTPUT PARAM par_vlmaiapl AS DEC                            NO-UNDO.
    DEF OUTPUT PARAM par_vlmaicot AS DEC                            NO-UNDO.
    DEF OUTPUT PARAM par_vlmaisal AS DEC                            NO-UNDO.
    DEF OUTPUT PARAM par_vlsldneg AS DEC                            NO-UNDO.
   
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
     
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Busca-Dados:
    DO:
        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "MAIORESDEP"   AND
                           craptab.tpregist = 001            NO-LOCK NO-ERROR.
       
        IF  AVAILABLE craptab   THEN
            DO:
                ASSIGN par_vlmaidep = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
                       par_vlmaisal = DECIMAL(SUBSTRING(craptab.dstextab,17,15))
                       par_vlsldneg = DECIMAL(SUBSTRING(craptab.dstextab,33,15))
                       par_vlmaiapl = DECIMAL(SUBSTRING(craptab.dstextab,49,15))
                       par_vlmaicot = DECIMAL(SUBSTRING(craptab.dstextab,65,15)).                  
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 55.
                LEAVE Busca-Dados.                                 
            END.                   
    END.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
  
    RETURN "OK".
  
END PROCEDURE.

/*****************************************************************************
  Alterar os dados gravados na TAB007 
******************************************************************************/
PROCEDURE altera_tab007:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM par_vlmaidep AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlmaiapl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlmaicot AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlmaisal AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsldneg AS DECI                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgtrans         AS LOGI                           NO-UNDO.
    DEF  VAR log_dstextab         AS DEC EXTENT 5                   NO-UNDO.
    DEF  VAR aux_msgdolog         AS CHAR                           NO-UNDO.
    DEF  VAR aux_valanter         AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                       crapope.cdoperad = par_cdoperad    
                       NO-LOCK NO-ERROR.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:

        DO  aux_contador = 1 TO 10:
                
            ASSIGN aux_cdcritic = 0.
            
            FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND 
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "MAIORESDEP"   AND
                               craptab.tpregist = 001  
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE craptab   THEN
                IF  LOCKED craptab   THEN
                    DO:
                        ASSIGN aux_contador = aux_contador + 1
                               aux_cdcritic = 77.
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 55.
                        LEAVE.
                    END.
        END.
         
        IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            UNDO TRANS_TAB, LEAVE TRANS_TAB.
     
        IF  AVAIL craptab THEN 
            DO:
        
                /* Armazena Valores anteriores para o LOG */ 
                ASSIGN aux_valanter    = craptab.dstextab
                       log_dstextab[1] = DECIMAL(SUBSTRING(aux_valanter ,01,15))
                       log_dstextab[2] = DECIMAL(SUBSTRING(aux_valanter ,17,15))
                       log_dstextab[3] = DECIMAL(SUBSTRING(aux_valanter ,33,15))
                       log_dstextab[4] = DECIMAL(SUBSTRING(aux_valanter ,49,15))
                       log_dstextab[5] = DECIMAL(SUBSTRING(aux_valanter ,65,15)).
              
                ASSIGN craptab.dstextab = STRING(par_vlmaidep,"999999999999.99") + " " +
                                          STRING(par_vlmaisal,"999999999999.99") + " " +
                                          STRING(par_vlsldneg,"999999999999.99") + " " +
                                          STRING(par_vlmaiapl,"999999999999.99") + " " + 
                                          STRING(par_vlmaicot,"999999999999.99").
            END.    
    
        RELEASE craptab. 
        ASSIGN aux_flgtrans = TRUE.

    END. /* Fim da transacao */

    IF  NOT aux_flgtrans THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel atualizar os valores.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                DO:
                    UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                                       " - "        +   STRING(TIME,"HH:MM:SS")               +
                                       " Operador:"  + " " + par_cdoperad                     +
                                       " --- " +  aux_dscritic                                +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                                       "/log/tab007.log").
                END.                                                            

            RETURN "NOK".
        END.

    /* Grava LOG (Sucesso) */ 
    IF  par_flgerlog THEN 
        DO:
            IF par_vlmaidep <> log_dstextab[1] THEN
                ASSIGN aux_msgdolog = "Alterou o valor referente aos Maiores Depositos de " + STRING(log_dstextab[1],"zzz,zzz,zzz,zz9.99") + " para " + STRING(par_vlmaidep,"zzz,zzz,zzz,zz9.99") + ".".
            
            IF par_vlmaisal <> log_dstextab[2] THEN
                ASSIGN aux_msgdolog = aux_msgdolog + " Alterou o valor referente aos Maiores Saldos de " + STRING(log_dstextab[2],"zzz,zzz,zzz,zz9.99") + " para " + STRING(par_vlmaisal,"zzz,zzz,zzz,zz9.99") + ".".
            
            IF par_vlsldneg <> log_dstextab[3] THEN
                ASSIGN aux_msgdolog = aux_msgdolog + " Alterou o valor referente aos Maiores Negativos de " + STRING(log_dstextab[3],"zzz,zzz,zzz,zz9.99") + " para " + STRING(par_vlsldneg,"zzz,zzz,zzz,zz9.99") + ".".
            
            IF par_vlmaiapl <> log_dstextab[4] THEN
                ASSIGN aux_msgdolog = aux_msgdolog + " Alterou o valor referente as Maiores Aplicacoes de " + STRING(log_dstextab[4],"zzz,zzz,zzz,zz9.99") + " para " + STRING(par_vlmaiapl,"zzz,zzz,zzz,zz9.99") + ".".
            
            IF par_vlmaicot <> log_dstextab[5] THEN
                ASSIGN aux_msgdolog = aux_msgdolog + " Alterou o valor referente as Maiores Cotas de " + STRING(log_dstextab[5],"zzz,zzz,zzz,zz9.99") + " para " + STRING(par_vlmaicot,"zzz,zzz,zzz,zz9.99") + ".".

            IF par_vlmaidep <> log_dstextab[1] OR 
               par_vlmaisal <> log_dstextab[2] OR
               par_vlsldneg <> log_dstextab[3] OR 
               par_vlmaiapl <> log_dstextab[4] OR
               par_vlmaicot <> log_dstextab[5] THEN
               DO:   
                    UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                                       " - "        +   STRING(TIME,"HH:MM:SS")               +
                                       " Operador: "  + par_cdoperad + " --- "                +
                                              aux_msgdolog                                    +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                                       "/log/tab007.log").
               END.
        END.

    RETURN "OK".

END PROCEDURE. 

/*****************************************************************************
  Fim da b1wgen0132.p 
******************************************************************************/
