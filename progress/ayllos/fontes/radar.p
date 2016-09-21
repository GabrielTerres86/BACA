/* .............................................................................

   Programa: Fontes/radar.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Junior
   Data    : Marco/2005                   Ultima Atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa principal para Conectar/Desconectar.
               Efetuar Exportacao de informacoes do RADAR.

............................................................................. */

{ includes/var_online.i  } 

{includes/gg0000.i}

IF  f_conectagener() THEN
    DO:
       RUN fontes/radar2.p.

       RUN p_desconectagener.
    END.
    

