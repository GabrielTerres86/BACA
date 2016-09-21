/* ..........................................................................

   Programa: Fontes/verifica_repl_server.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2005.                          Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Verificar se o servico de replicacao (server) esta ativa.

               _connect-type: SELF => Conexoes locais (terminais)
                              REMC => Conexoes remotas (cashes)
                              RPLS => Replicacao (Server)
                              RPLA => Replicacao (Agent)
   
   Alteracoes: 

............................................................................. */

DEF VAR aux_flgexist AS LOGICAL INIT FALSE                           NO-UNDO.

FIND _myconnection NO-LOCK.

FOR EACH _connect WHERE _connect-type = "RPLS"   AND
                        _connect-disconnect = 0   AND
                        _connect-usr <> _myconn-userid NO-LOCK:

    aux_flgexist = TRUE.

END.  /*  Fim do FOR EACH  */

IF   NOT aux_flgexist   THEN
     UNIX SILENT VALUE("> " + DBNAME + "_repl_server.erro").

QUIT.

/* .......................................................................... */

