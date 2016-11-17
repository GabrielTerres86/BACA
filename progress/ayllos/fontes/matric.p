/* .............................................................................

   Programa: Fontes/matric.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Margarete
   Data    : Setembro/2004                   Ultima Atualizacao: 13/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa principal para Conectar/Desconectar.
               Efetuar Cadastramento da tela MATRIC.

   Alteracoes: 12/08/2010 - Adaptacao para usar BO, (Jose Luis, DB1) 
                            foi retirado o { includes/var_altera.i }
                            
               02/02/2011 - Incluido f_conecta_progrid(). (Jorge)             
               
               13/04/2012 - Retirada a chamada para o banco generico (Elton).
............................................................................. */

{ includes/var_online.i  } 

{includes/gg0000.i}

{ includes/var_matric.i "NEW" }

IF  f_conecta_progrid() THEN
    DO: 
        RUN fontes/matricp.p.
        RUN p_desconecta_progrid.
    END.
            
