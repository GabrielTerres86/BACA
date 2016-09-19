/*.............................................................................

   Programa: fontes/le_motivo_demissao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Maio/2005                            Ultima alteracao: 27/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Le cadastro de motivos de demissao (saida de socio).

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.
DEF INPUT  PARAM par_cdmotdem AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_dsmotdem AS CHAR                            NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                             NO-UNDO.

par_cdcritic = 0.

IF   par_cdmotdem = 0   THEN
     RETURN.

FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "MOTIVODEMI"  AND
                   craptab.tpregist = par_cdmotdem  NO-LOCK NO-ERROR.
   
IF   NOT AVAILABLE craptab   THEN
     ASSIGN par_dsmotdem = "MOTIVO NAO CADASTRADO"
            par_cdcritic = 848.
ELSE
     par_dsmotdem = craptab.dstextab.

/* .......................................................................... */

