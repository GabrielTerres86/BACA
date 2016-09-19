/* ..........................................................................

   Programa: sistema/generico/includes/var_oracle.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Euzebio / Supero
   Data    : Fevereiro/2014.                      Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (On-line/Batch)
   Objetivo  : Definicao de variaveis para tratamento de erro ao executar
               Store Procedure Oracle.

   Alteracoes:
               
............................................................................. */

/* GLOBAL-DEFINE para nome do banco Oracle do ayllos */
&GLOBAL-DEFINE scd_dboraayl "ayllosd"
&GLOBAL-DEFINE sc2_dboraayl ayllosd

/* Variaveis para tratamento de erro ao executar Store Procedure Oracle */
DEFINE VARIABLE aux_qterrora AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_msgerora AS CHAR                                 NO-UNDO.

/* Variaveis para rodar a Stored Procedure Oracle */
/* Status da Stored Procedure */
DEFINE VARIABLE aux_statproc AS INTEGER INITIAL 0                    NO-UNDO.
/* Ponteiro da Stored Procedure */
DEFINE VARIABLE aux_handproc AS INTEGER                              NO-UNDO.
/* Segundo ponteiro de Stored Procedure */
DEFINE VARIABLE aux_handpro2 AS INTEGER                              NO-UNDO.



 
