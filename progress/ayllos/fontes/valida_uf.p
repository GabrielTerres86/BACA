/* .............................................................................

   Programa: Fontes/valida_uf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/2004.                       Ultima atualizacao: 08/04/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Validar alinea de devolucao.

   Alteracoes: 08/04/2015 - Inclusao de todos os Estados do Brasil.
                            (Jaison/Gielow - SD: 274267)

............................................................................. */

DEF INPUT  PARAM par_ufbrasil AS CHAR                             NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                              NO-UNDO.

IF   par_ufbrasil = "AC" OR par_ufbrasil = "AL" OR 
     par_ufbrasil = "AP" OR par_ufbrasil = "AM" OR
     par_ufbrasil = "BA" OR par_ufbrasil = "CE" OR
     par_ufbrasil = "DF" OR par_ufbrasil = "ES" OR
     par_ufbrasil = "GO" OR par_ufbrasil = "MA" OR 
     par_ufbrasil = "MG" OR par_ufbrasil = "MS" OR
     par_ufbrasil = "MT" OR par_ufbrasil = "PA" OR 
     par_ufbrasil = "PB" OR par_ufbrasil = "PE" OR
     par_ufbrasil = "PI" OR par_ufbrasil = "PR" OR 
     par_ufbrasil = "RJ" OR par_ufbrasil = "RN" OR
     par_ufbrasil = "RO" OR par_ufbrasil = "RR" OR
     par_ufbrasil = "RS" OR par_ufbrasil = "SC" OR 
     par_ufbrasil = "SE" OR par_ufbrasil = "SP" OR
     par_ufbrasil = "TO"  THEN
     par_cdcritic = 0.
ELSE
     par_cdcritic = 33.

/* .......................................................................... */

