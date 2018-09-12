/* .............................................................................
   Programa: var_digidoc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Lucas Reinert
   Data    : Agosto/2018                       Ultima Atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Include criada para tratar URL do digidoc em producao e outros
               ambientes.

............................................................................. */

DEF VAR aux_svdigdoc AS CHAR                                          NO-UNDO.

IF CAPS(OS-GETENV("PKGNAME")) = "PKGPROD" THEN
  ASSIGN aux_svdigdoc = "ged.cecred.coop.br".
ELSE
  ASSIGN aux_svdigdoc = "0303hmlged01".