/* .............................................................................

   Programa: Includes/b1cabrelvar.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rogerius Militao - DB1
   Data    : Outubro/2011                     Ultima Atualizacao: 00/00/0000 

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Variaveis para o cabecalho dos relatorios.

   Alteracoes: 
............................................................................. */

DEF VAR rel_nmrescop AS CHAR                                          NO-UNDO.
DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"                          NO-UNDO.
DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)"                          NO-UNDO.
DEF VAR rel_nmdestin AS CHAR                                          NO-UNDO.
DEF VAR rel_nrmodulo AS INTE                                          NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 6
                              INIT ["DEP. A VISTA   ","CAPITAL        ",
                                    "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO      ","PROCESSOS"]    NO-UNDO.
