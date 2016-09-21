/* ..........................................................................

   Programa: Fontes/crps462.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio       
   Data    : Dezembro/2005.                     Ultima atualizacao: 10/01/2014

   Dados referentes ao programa:

   Frequencia: Diario CRON (Diario)
   Objetivo  : Fazer a chamada para o programa crps460.p

   Alteracoes: 02/01/2005 - Nao rodar se for feriado ou processo estiver
                            solicitado (Julio)
                            
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               24/03/2006 - Ajustes na captura do codigo da cooperativa
                            (Edson).
                            
               18/04/2007 - Conectar no banco genericao (Ze).    
               
               10/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)          
............................................................................*/

{ includes/var_batch.i "NEW" }

{ includes/gg0000.i }

/*  Captura codigo da cooperativa da variavel de ambiente CDCOOPER .......... */

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.

IF   NOT f_conectagener() THEN
     DO:
         glb_cdcritic = 791.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - crps460" + 
                           "' --> '"  + glb_dscritic + 
                           " Generico " + " >> log/proc_batch.log").
         QUIT.
     END.   
   
   FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapdat   THEN
        QUIT.
   ELSE
   IF   crapdat.inproces <> 1   THEN
        QUIT.
        
   FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                      crapfer.dtferiad = TODAY NO-LOCK NO-ERROR.
                      
   IF   AVAILABLE crapfer   THEN
        QUIT.

   DO TRANSACTION:
   
      CREATE crapsol.
      ASSIGN crapsol.nrsolici = 082
             crapsol.dtrefere = crapdat.dtmvtolt
             crapsol.nrseqsol = 01
             crapsol.cdempres = 11
             crapsol.dsparame = " "
             crapsol.insitsol = 1
             crapsol.nrdevias = 1
             crapsol.cdcooper = glb_cdcooper.
             
   END.  /*  Fim da transacao  */          
   VALIDATE crapsol.

   RUN fontes/crps460.p.

   DO TRANSACTION.
 
      FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper AND
                             crapsol.nrsolici = 82 EXCLUSIVE-LOCK:
      
          DELETE crapsol.
      
      END.  /*  Fim do FOR EACH   */

   END.  /*  Fim da transacao   */

   QUIT.

/* .......................................................................... */
