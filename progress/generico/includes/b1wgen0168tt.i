/* .............................................................................

   Programa: b1wgen0168tt.i
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Agosto/2013.                       Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO referente a regras de geracao de arquivos CYBER

   Alteracoes:
   
............................................................................. */

DEF TEMP-TABLE tt-crapcyb NO-UNDO LIKE crapcyb.
        
DEF VAR aux_cderr168 AS INT INIT 0                                      NO-UNDO.
DEF VAR aux_dserr168 AS CHAR                                            NO-UNDO.
