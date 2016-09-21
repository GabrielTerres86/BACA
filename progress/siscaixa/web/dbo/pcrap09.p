/*---------------------------------------------------------------------------

    Programa : pcrap09.p - Calcular os digitos do CMC-7.
    
    Objetivo : Calcular os digitos do CMC-7.(Antigo fontes/dig_cmc7.p)

  Alteracoes : 27/07/2007 - Verificar se a agencia esta ativa (Evandro).

               09/12/2008 - Incluir parametro na chamada do programa pcrap03.p
                            (David).
                            
               25/09/2009 - Validar agencia e banco do cheque pelo CAF na 
                            b1wgen0044 (Guilherme).
                                             
  
-----------------------------------------------------------------------------*/

{ sistema/generico/includes/var_internet.i }

DEF INPUT  PARAM p-cooper     AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_dsdocmc7 AS CHAR                                NO-UNDO.
DEF OUTPUT PARAM par_nrdcampo AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_lsdigctr AS CHAR                                NO-UNDO.

DEF VAR aux_nrcalcul AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrdigito AS INT                                          NO-UNDO.
DEF VAR aux_stsnrcal AS LOGICAL                                      NO-UNDO.

DEF VAR aux_nrcampo1 AS INT                                          NO-UNDO.
DEF VAR aux_nrcampo2 AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrcampo3 AS DECIMAL                                      NO-UNDO.

DEF VAR aux_cdbanchq AS INTE                                         NO-UNDO.
DEF VAR aux_cdagechq AS INTE                                         NO-UNDO.

DEF VAR h-b1wgen0044 AS HANDLE                                       NO-UNDO.

FIND crapcop NO-LOCK WHERE
     crapcop.nmrescop = p-cooper  NO-ERROR.

IF   LENGTH(par_dsdocmc7) <> 34   THEN DO:
     par_nrdcampo = 1.
     RETURN.
END.

/*  Conteudo do par_dsdocmc7 =  <00100950<0168086015>870000575178:  */

ASSIGN aux_nrcampo1 = INT(SUBSTRING(par_dsdocmc7,2,8)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN DO:
     par_nrdcampo = 1.
     RETURN.
END.
 
ASSIGN aux_nrcampo2 = DECIMAL(SUBSTRING(par_dsdocmc7,11,10)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN DO:
     par_nrdcampo = 1.
     RETURN.
END.

ASSIGN aux_nrcampo3 = DECIMAL(SUBSTRING(par_dsdocmc7,22,12)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN DO:
     par_nrdcampo = 1.
     RETURN.
END.

par_nrdcampo = 0.
       
DO WHILE TRUE:

   /*  Calcula o digito do terceiro campo  - DV 1  */
           
   aux_nrcalcul = aux_nrcampo1.
                   
   RUN dbo/pcrap03.p (INPUT-OUTPUT aux_nrcalcul,
                      INPUT        TRUE, /* Verificar zeros */
                            OUTPUT aux_nrdigito,
                            OUTPUT aux_stsnrcal).

   par_lsdigctr = STRING(aux_nrdigito,"9").

   IF   aux_nrdigito <> INT(SUBSTR(STRING(aux_nrcampo3,"999999999999"),1,1)) THEN Do:
        par_nrdcampo = 3.
        LEAVE.
   END.

   /*  Calcula o digito do primeiro campo  - DV 2  */
       
   aux_nrcalcul = aux_nrcampo2 * 10.
               
   
   RUN dbo/pcrap03.p (INPUT-OUTPUT aux_nrcalcul,
                      INPUT        TRUE, /* Verificar zeros */  
                            OUTPUT aux_nrdigito,
                            OUTPUT aux_stsnrcal).

   par_lsdigctr = par_lsdigctr + "," + STRING(aux_nrdigito,"9").
                               
   IF   aux_nrdigito <>
        INT(SUBSTR(STRING(aux_nrcampo1),LENGTH(STRING(aux_nrcampo1)),1))   THEN DO:
        par_nrdcampo = 1.
        LEAVE.
   END.
 
   /*  Calcula digito DV 3  */
   
   aux_nrcalcul = DECIMAL(SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11)).

   RUN dbo/pcrap03.p (INPUT-OUTPUT aux_nrcalcul,
                      INPUT        TRUE, /* Verificar zeros */
                            OUTPUT aux_nrdigito,
                            OUTPUT aux_stsnrcal).

   par_lsdigctr = par_lsdigctr + "," + STRING(aux_nrdigito,"9").
 
   IF   NOT aux_stsnrcal   THEN DO:
        par_nrdcampo = 3.
        LEAVE.
   END.


    aux_cdbanchq = INT(SUBSTR(par_dsdocmc7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN DO:
         par_nrdcampo = 1.
         RETURN.
    END.

    aux_cdagechq = INT(SUBSTR(par_dsdocmc7,05,04)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN DO:
         par_nrdcampo = 1.
         RETURN.
    END.
 
    
    RUN sistema/generico/procedures/b1wgen0044.p 
        PERSISTENT SET h-b1wgen0044.
    
    IF  NOT VALID-HANDLE(h-b1wgen0044) THEN
        DO:
            ASSIGN par_nrdcampo = 0.
            RETURN.
        END.

    /* Validacao generica de Banco e Agencia */
    RUN valida_banco_agencia IN h-b1wgen0044(INPUT aux_cdbanchq,
                                                         INPUT aux_cdagechq,
                                                        OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0044.
    
    IF  RETURN-VALUE = "NOK"  THEN
         DO:
             FIND LAST tt-erro NO-LOCK NO-ERROR.
             IF  AVAIL tt-erro THEN
                 ASSIGN par_nrdcampo = tt-erro.cdcritic.
             ELSE
                 ASSIGN par_nrdcampo = 0.
             RETURN.
         END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* pcrap09.p */

