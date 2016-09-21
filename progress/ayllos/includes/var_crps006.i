/* .............................................................................

   Programa: Includes/var_crps006.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Fevereiro/97.                           Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento do crps006_1.
............................................................................. */

DEF {1} SHARED   VAR aux_tb09qtvc AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb09ttvc AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb09ttdp AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb10qtap AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb10ttap AS DECIMAL                   NO-UNDO.

DEF {1} SHARED   VAR aux_tbrd2tot AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tbrd2qtd AS INT                       NO-UNDO.

DEF {1} SHARED   VAR aux_qtpoupro AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_sdpoupro AS DECIMAL                   NO-UNDO.

DEF {1} SHARED   VAR aux_tb07lian AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb07liat AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb07liqt AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb07liqn AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb07cran AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb07crat AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb07crqt AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb08ctcn AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb08ctnv AS INT                       NO-UNDO.

DEF {1} SHARED   VAR aux_tb09qtap AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb09ttap AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb09ttjp AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb11qtrg AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb11ttrg AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb13qtft AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb13ttft AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb14qtpp AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb14ttpp AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb15qtsg AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_tb15ttsg AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb16qtcr AS INTEGER                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb16ttcr AS DECIMAL                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb17qtcr AS INTEGER                   NO-UNDO.
DEF {1} SHARED   VAR aux_tb17ttcr AS DECIMAL                   NO-UNDO.

DEF {1} SHARED   VAR aux_qtrgrd60 AS INT                       NO-UNDO.
DEF {1} SHARED   VAR aux_vlrgrd60 AS DECIMAL                   NO-UNDO.

/* .......................................................................... */
