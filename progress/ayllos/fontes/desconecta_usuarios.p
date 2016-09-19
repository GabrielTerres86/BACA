/* ..........................................................................

   Programa: Fontes/desconecta_usuarios.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2005.                          Ultima atualizacao: 05/06/2008

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Desconentar TODOS os usuarios conectados ao banco de dados
               exceto os processos do PROGRESS.

               _connect-type: SELF => Conexoes locais (terminais)
                              REMC => Conexoes remotas (cashes)
                              RPLS => Replicacao (Server)
                              RPLA => Replicacao (Agent)
   
   Alteracoes: 05/06/2008 - Nao proceder a desconexao dos cashes e processos 
                            batch (ex. agentes webspeed) (Edson).

............................................................................. */

FIND _myconnection NO-LOCK NO-ERROR.

FOR EACH _connect WHERE (_connect-type       = "SELF"          OR
                         _connect-type       = "REMC")         AND
                         _connect-disconnect = 0               AND
                         _connect-device     <> "batch"        AND
                         _connect-usr        <> _myconn-userid NO-LOCK:

    FIND _userio WHERE _userio._userio-usr = _connect-usr NO-LOCK NO-ERROR.
       
    IF   NOT AVAILABLE _userio  THEN
         NEXT.

    IF   _userio-name    =    "root"     OR
         _userio-name MATCHES "*cash*"   THEN
         NEXT.
            
    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " AS " +
                      STRING(TIME,"HH:MM:SS") +  
                      "' --> Desconectando usuario '"  +
                      STRING(_userio-usr) + " - " +
                      _userio-name + " >> log/desc_usuario.log").
                        
    UNIX SILENT VALUE("sudo proshut " + DBNAME + " -C disconnect " +
                      STRING(_userio-usr) + " > /dev/null").

END.  /*  Fim do FOR EACH  */

QUIT.

/* .......................................................................... */

