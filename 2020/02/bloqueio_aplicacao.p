/*................................ DEFINICOES ............................... */
{ sistema/generico/includes/b1wgen0148tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

/* programas */
DEF VAR h-b1wgen0148 AS HANDLE                                         NO-UNDO.

PROCEDURE executa_programa:

  FIND crapdat WHERE crapdat.cdcooper = 16 NO-LOCK NO-ERROR.

  RUN sistema/generico/procedures/b1wgen0148.p PERSISTEN SET h-b1wgen0148.
  
  /*  [par_tpaplica] INVESTFACIL   = 2
      [par_tpaplica] INVESTFUTURO  = 2
  */  

  RUN bloqueia-blqrgt IN h-b1wgen0148 (INPUT par_cdcooper,     /*par_cdcooper*/
                                       INPUT 0,                /*par_cdagenci*/
                                       INPUT 0,                /*par_nrdcaixa*/
                                       INPUT "1",              /*par_cdoperad*/
                                       INPUT 97110,            /*par_nrdconta*/
                                       INPUT 2,                /*par_tpaplica*/
                                       INPUT 35,               /*par_nraplica*/
                                       INPUT crapdat.dtmvtolt, /*par_dtmvtolt*/
                                       INPUT TRUE,             /*par_flgerlog*/
                                       INPUT "A",              /*par_idtipapl*/
                                       INPUT "",               /*par_nmprodut*/                                       
                                       OUTPUT TABLE tt-erro).
  
  
  DELETE PROCEDURE h-b1wgen0148.


END PROCEDURE.

/*executar programa*/
RUN executa_programa.
