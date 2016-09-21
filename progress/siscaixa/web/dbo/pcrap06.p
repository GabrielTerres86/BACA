
/*-----------------------------------------------------------------------------------*/
/*  pcrap06.p - Identifica‡Æo CPF/CGC                                                */   
/*  Objetivo  : Identificar o numero informado, desviando conforme for CPF (para     */
/*              a rotina fontes/cpffun.p) ou CGC (para a rotina fontes/cgcfun.p).    */                              
/*             (antigo fontes/cpfcgc.p)                                              */                                    
/*-----------------------------------------------------------------------------------*/


DEF INPUT  param nro-calculado AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF OUTPUT param l-retorno     AS LOGICAL                               NO-UNDO.
DEF OUTPUT param i-pessoa      AS INT                                   NO-UNDO.

ASSIGN l-retorno = FALSE.

IF   nro-calculado = 9571   THEN DO:
         ASSIGN l-retorno = FALSE
                i-pessoa  = 1.                      /*  Valor default  */
         RETURN.
END.

IF   LENGTH(STRING(nro-calculado)) = 11 OR LENGTH(STRING(nro-calculado)) = 10 OR
     LENGTH(STRING(nro-calculado)) =  9 OR LENGTH(STRING(nro-calculado)) =  8 OR
     LENGTH(STRING(nro-calculado)) =  7 THEN DO:
     ASSIGN i-pessoa = 1.                       /*  Pessoa fisica  */
     RUN dbo/pcrap07.p (INPUT  nro-calculado,
                        OUTPUT l-retorno).

     IF  NOT l-retorno THEN DO:

         ASSIGN i-pessoa = 2.
                  
         RUN dbo/pcrap08.p (INPUT  nro-calculado,
                            OUTPUT l-retorno).
      
     END.

END.
ELSE
     IF   LENGTH(STRING(nro-calculado)) < 15 AND
          LENGTH(STRING(nro-calculado)) > 2   THEN  DO:
          assign i-pessoa = 2.                  /*  Pessoa juridica  */
          RUN dbo/pcrap08.p (INPUT  nro-calculado,
                             OUTPUT l-retorno).
         END.
     ELSE
              ASSIGN l-retorno = FALSE
                     i-pessoa  = 1.                /*  Valor default  */



/* pcrap06.p */
