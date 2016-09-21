/*-------------------------------------------------------------------------*/
/*  pcrap13.p - Critica Estado                                             */   
/*  Objetivo  : verificar se o estado digitado e um estado valido          */ 
/*-------------------------------------------------------------------------*/


DEF INPUT  PARAM par_cdufresd  LIKE crapenc.cdufende      NO-UNDO.
DEF OUTPUT PARAM par_flgerruf  AS LOGICAL                 NO-UNDO.

ASSIGN par_flgerruf = FALSE.

IF   par_cdufresd <> "RS"   AND 
     par_cdufresd <> "SC"   AND
     par_cdufresd <> "PR"   AND
     par_cdufresd <> "SP"   AND
     par_cdufresd <> "RJ"   AND
     par_cdufresd <> "ES"   AND
     par_cdufresd <> "MG"   AND
     par_cdufresd <> "MS"   AND
     par_cdufresd <> "MT"   AND 
     par_cdufresd <> "GO"   AND
     par_cdufresd <> "DF"   AND 
     par_cdufresd <> "BA"   AND
     par_cdufresd <> "PE"   AND
     par_cdufresd <> "PA"   AND 
     par_cdufresd <> "PI"   AND
     par_cdufresd <> "MA"   AND
     par_cdufresd <> "RO"   AND 
     par_cdufresd <> "RR"   AND
     par_cdufresd <> "AC"   AND 
     par_cdufresd <> "AM"   AND
     par_cdufresd <> "TO"   AND
     par_cdufresd <> "AM"   AND
     par_cdufresd <> "CE"   AND
     par_cdufresd <> "SE"   AND
     par_cdufresd <> "AL"   THEN
     ASSIGN par_flgerruf = YES.


/* pcrap13.p */
