/* .............................................................................

   Programa: Includes/extaplc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004                            Ulima Alteracao: 04/10/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela extapl.
   
   Alteracoes - Unificacao dos Bancos - SQLWorks - Fernando  
    
              04/10/2007 - Data da Aplicacao (Guilherme).

............................................................................. */

ASSIGN glb_cdcritic = 0
       tel_nrsequen = 0.

RUN carrega_workapl.

/*************
FOR EACH craprda WHERE craprda.cdcooper  = glb_cdcooper   AND
                       craprda.nrdconta  = tel_nrdconta   AND
                       craprda.vlsdrdca <> 0              NO-LOCK:
    CREATE workapl.
    ASSIGN tel_nrsequen     = tel_nrsequen + 1
           workapl.nrsequen = tel_nrsequen
           workapl.tpaplica = craprda.tpaplica
           workapl.nraplica = craprda.nraplica
           workapl.tpemiext = craprda.tpemiext
           workapl.dtmvtolt = craprda.dtmvtolt.
    IF   craprda.tpaPlica = 3   THEN
         ASSIGN workapl.descapli = "RDCA30".
    ELSE
         ASSIGN workapl.descapli = "RDCA60".
    IF   craprda.tpemiext = 1   THEN
         ASSIGN workapl.dsemiext = "Individual".
    ELSE
         IF   craprda.tpemiext = 2   THEN
              ASSIGN workapl.dsemiext = "Todos juntos".
         ELSE
              IF   craprda.tpemiext = 3   THEN
                   ASSIGN workapl.dsemiext = "Nao imprime".
END. 
         
FOR EACH craprpp WHERE craorpp.cdcooper = glb_cdcooper   AND
                       craprpp.nrdconta = tel_nrdconta   AND
                       craprpp.cdsitrpp = 1              NO-LOCK:
    CREATE workapl.
    ASSIGN tel_nrsequen     = tel_nrsequen + 1
           workapl.nrsequen = tel_nrsequen
           workapl.tpaplica = 6
           workapl.nraplica = craprpp.nrctrrpp
           workapl.tpemiext = craprpp.tpemiext
           workapl.descapli = "P.PROG"
           workapl.dtmvtolt = craprpp.dtmvtolt.
     IF   craprpp.tpemiext = 1   THEN
         ASSIGN workapl.dsemiext = "Individual".
    ELSE
         IF   craprpp.tpemiext = 2   THEN
              ASSIGN workapl.dsemiext = "Todos juntos".
         ELSE
              IF   craprpp.tpemiext = 3   THEN
                   ASSIGN workapl.dsemiext = "Nao imprime".
END.                    
*************/                        
PAUSE(0).

FIND FIRST workapl NO-LOCK NO-ERROR.
IF   NOT AVAILABLE workapl   THEN
     DO:
         ASSIGN glb_cdcritic = 11.
         LEAVE.
     END.
ELSE
     DO:             
         OPEN QUERY blistafin-q 
         FOR EACH tt-extapl NO-LOCK.
              
             ENABLE blistafin-b WITH FRAME f_listafinc.

             WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
     END.
    
CLEAR FRAME f_listafinc ALL.
HIDE FRAME f_listafinc.

/* .......................................................................... */
