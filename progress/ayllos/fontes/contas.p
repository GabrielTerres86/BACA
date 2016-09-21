/* .............................................................................

   Programa: Fontes/contas.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006                   Ultima Atualizacao: 27/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa principal para Conectar/Desconectar.
               Efetuar Cadastramento da tela CONTAS
               
   Alteracoes: 27/06/2012 - Alterardo a conexao do banco generico para o
                            progrid. Pois na rotina "PROCURADORES" será 
                            utilizado a BO52 (Adriano).

............................................................................. */

{ includes/var_online.i  } 

{includes/gg0000.i}

{ includes/var_contas.i "NEW" }

IF  f_conecta_progrid() THEN
    DO:
       RUN fontes/contasp.p.

       RUN p_desconecta_progrid.
    END.
    
/*............................................................................*/
