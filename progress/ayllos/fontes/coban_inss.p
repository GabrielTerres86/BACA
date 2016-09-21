/* .............................................................................

   Programa: fontes/coban_inss.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

             01/12/2008 - Alterado IP 172.18.1.6 para 172.17.2.253 (Edson).

............................................................................. */

def input param  cartao  as char no-undo.
def input param  senha   as char no-undo.
def output param retorno as int no-undo.
def output param dukpt   as char no-undo.

def var lRetorno as logical no-undo.
def var hServer  as handle  no-undo.

create server hServer.

lRetorno = hServer:connect("-AppService coban -H 172.17.2.253").

if not lRetorno then do:

   assign retorno = 999
          dukpt   = "ERRO: Erro na conexao do AppServer".
   return.
end.
   
run libdukpt.p on hServer
   (input cartao, input senha, output retorno, output dukpt).
   
hServer:disconnect().
delete object hServer.
   

