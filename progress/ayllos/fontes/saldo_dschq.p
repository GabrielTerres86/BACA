/* .............................................................................

   Programa: Fontes/saldo_dschq.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Julho/2004.                         Ultima atualizacao: 26/01/2006

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Calcular o saldo devedor do Desconto de Cheques.

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

............................................................................. */

{ includes/var_online.i } 

DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrctrlim AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_vlsdeved AS DECIMAL                             NO-UNDO.

DEF VAR aux_vldscchq          AS DEC                                 NO-UNDO.

FIND craplim WHERE craplim.cdcooper = glb_cdcooper  AND
                   craplim.nrdconta = par_nrdconta  AND
                   craplim.tpctrlim = 2             AND
                   craplim.nrctrlim = par_nrctrlim  NO-LOCK
                   USE-INDEX craplim1 NO-ERROR.

IF  AVAIL craplim THEN 
    DO:
       
       /*  Totaliza o montante de cheques descontados  */
    
       FOR EACH crapbdc USE-INDEX crapbdc2
                 WHERE crapbdc.cdcooper = glb_cdcooper       AND
                              crapbdc.nrdconta = craplim.nrdconta   AND
                              crapbdc.nrctrlim = craplim.nrctrlim   NO-LOCK,
           EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                              crapcdb.nrdconta = crapbdc.nrdconta   AND
                              crapcdb.nrborder = crapbdc.nrborder   AND
                              crapcdb.nrctrlim = crapbdc.nrctrlim   AND
                              crapcdb.insitchq = 2                  AND
                              crapcdb.dtlibera > glb_dtmvtolt       NO-LOCK
                              USE-INDEX crapcdb7: 
   
           ASSIGN aux_vldscchq = aux_vldscchq + crapcdb.vlcheque.
       END.
    END.

ASSIGN  par_vlsdeved = aux_vldscchq.
/* .......................................................................... */

