/* .............................................................................

   Programa: Fontes/critic.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson                    Ultima atualizacao: 04/06/2012
   Data    : Setembro/91

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Mostrar o texto das criticas na tela de acordo com o ocorrido.

   Alteracoes: 08/12/2004 - Inclusao do nome do banco antes das tabelas (Julio)
               
               04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
                            do prefixo "banco" (Guilherme Maba).
............................................................................. */

DEF SHARED VAR glb_cdcritic AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR glb_dscritic AS CHAR    FORMAT "x(40)"                NO-UNDO.

FIND crapcri WHERE crapcri.cdcritic = glb_cdcritic 
                   NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE crapcri   THEN
     glb_dscritic = STRING(glb_cdcritic) + " - Critica nao cadastrada!".
ELSE
     glb_dscritic = crapcri.dscritic.

/* .......................................................................... */
