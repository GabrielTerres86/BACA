/* .............................................................................

   Programa: Fontes/convit.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Novembro/2008                     Ultima Atualizacao: 13/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa principal para Conectar/Desconectar.
               Efetuar Cadastramento na tela CONVIT(Generico)

   Alteracoes: 24/07/2009 - Efetuar a conexao e desconexao do PROGRID(Gabriel).
            
               13/04/2012 - Retirada a chamada para o banco generico (Elton).
............................................................................. */

{ includes/var_online.i  } 

{includes/gg0000.i}

IF  f_conecta_progrid()  THEN
    DO:
       RUN fontes/convitp.p.

       RUN p_desconecta_progrid.
    END.
    

