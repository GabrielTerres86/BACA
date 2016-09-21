/* ............................................................................

   Programa: fontes/valida_usuario.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2008                          Ultima atualizacao: 08/04/2008

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Validar os usuarios cadastrados na tabela _User.

   .......................................................................... */

DEF VAR par_nmusuari AS CHAR NO-UNDO.

par_nmusuari = SESSION:PARAMETER.

IF   NUM-ENTRIES(par_nmusuari) = 0   THEN
     DO:
         MESSAGE "Nome do usuario deve ser informado!"
                 VIEW-AS ALERT-BOX.
         QUIT.
     END.

IF   NUM-ENTRIES(par_nmusuari) > 1   THEN
     DO:
         MESSAGE "Nao pode conter virgula no nome do usuario!" par_nmusuari
                 VIEW-AS ALERT-BOX.
         QUIT.
     END.

/*  Verifica se o usuario ja esta cadastrado na base de dados  */     
     
FIND _User WHERE _User._Userid = par_nmusuari NO-LOCK NO-ERROR.

IF   AVAILABLE _User   THEN
     QUIT.
     
/*  Cria usuario nao cadastrado */

DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE:

   CREATE _User.
   Assign _User._Userid = par_nmusuari
          _User._Password = ENCODE(par_nmusuari).

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

UNIX SILENT VALUE("echo " + 
                  STRING(TODAY,"99/99/9999") + " - " +
                  STRING(TIME,"HH:MM:SS") + " - " + 
                  "Criando usuario " + par_nmusuari + " na base de dados." +
                  " >> log/base_de_usuarios.log").

QUIT.

/* .......................................................................... */

