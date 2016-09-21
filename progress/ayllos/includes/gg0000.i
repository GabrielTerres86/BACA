/* ..........................................................................

   Programa: includes/gg0000.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Marco/2004.                        Ultima atualizacao: 21/07/2010    

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Contem rotinas referentes a conexao do 
               banco paralelo "gener.db" e do banco do progrid.

   ROTINAS :

     PROCEDURE p_desconectagener { Disconecta o banco centra.bd e
               destroi o alias al_central } - (Julio)

               p_desconecta_progrid { Desconecta o banco progrid e destroi
                                      o alias alprogrid } 

     FUNCTION  f_conectagener { Faz a conexao no banco central.db e cria o 
               ALIAS al_central e NOME LOGIGO bd_central } - (Julio)
                
               f_conecta_progrid { Faz a conecao no banco do progrid e cria o
                                  alias alprogrid }
                                  
               f_verconexaogener { Verifica se o banco generico ja esta 
                                   conectado }
                                   
               f_verconexaoprogrid { Verifica se o banco progrid ja esta 
                                     conectado }

   Alteracoes: 13/04/2009 - Incluir funcao para conectar ao progrid e procedure
                            para desconectar dele (Gabriel).
                            
               21/07/2010 - Incluir funcao para verificar se os bancos ja
                            estao conectados (David). 
                                        
               15/07/2011 - Retirar conexao com o banco gener (Fernando).
                      
               09/08/2011 - Alterar diretorio do banco progrid (Fernando).     
............................................................................ */

FUNCTION f_conectagener RETURN LOGICAL:

  RETURN TRUE.

END.

FUNCTION f_conecta_progrid RETURN LOGICAL:

  CONNECT /usr/coop/bdados/prd/progress/progrid/progrid.db -ld progrid NO-ERROR.
   
  IF   CONNECTED ("progrid")   THEN
       DO:
           CREATE ALIAS alprogrid FOR DATABASE progrid NO-ERROR.
           RETURN TRUE.
       END.

  RETURN FALSE.

END.

FUNCTION f_verconexaogener RETURN LOGICAL:

  RETURN TRUE.

END.

FUNCTION f_verconexaoprogrid RETURN LOGICAL:

  RETURN CONNECTED("progrid").

END.

PROCEDURE p_desconectagener:

    RETURN.

END.

PROCEDURE p_desconecta_progrid:

  IF   CONNECTED ("progrid")   THEN
       DO:
           DISCONNECT alprogrid.
           DELETE ALIAS alprogrid.
       END.

END.

/* .......................................................................... */
