/* .............................................................................
   Programa: Fontes/ver_ctace.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : ZE
   Data    : Dezembro/2008                       Ultima Atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa para Buscar as Contas Centralizadoras do BBrasil.

............................................................................. */

DEFINE INPUT  PARAM par_cdcooper AS INTEGER                          NO-UNDO.
DEFINE INPUT  PARAM par_tpregist AS INTEGER                          NO-UNDO.
DEFINE OUTPUT PARAM par_lscontas AS CHAR                             NO-UNDO.

IF   par_tpregist < 0 AND par_tpregist > 4 THEN
     RETURN.

FOR EACH gnctace WHERE gnctace.cdcooper = par_cdcooper  AND
                       gnctace.cddbanco = 1             AND
                     ((par_tpregist <> 0                AND
                       gnctace.tpregist = par_tpregist) OR
                       par_tpregist = 0)                NO-LOCK
                       BREAK BY gnctace.cdcooper:

    par_lscontas = par_lscontas + TRIM(STRING(gnctace.nrctace)).
     
    IF   NOT LAST-OF(gnctace.cdcooper) THEN
         par_lscontas = par_lscontas + ",".

END.

/* .......................................................................... */