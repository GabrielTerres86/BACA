/* .............................................................................

   Programa: Includes/var_cmedep_1.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : 04/08/2003.                  Ultima atualizacao: 04/11/2011 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela CMEDEP.

   Alteracoes: 30/09/2003 - Nao registrar acima de R$ 100.000 quando pessoa
                            juridica (Margarete).
                            
               04/11/2011 - Retirar variaveis nao mais utilizadas (Gabriel).
                            
............................................................................. */

DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"            NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig LIKE craplot.nrseqdig                  NO-UNDO.
DEF {1} SHARED VAR tel_nrdocmto LIKE crapcme.nrdocmto                  NO-UNDO.
DEF {1} SHARED VAR tel_vllanmto AS DEC FORMAT "zzz,zz9.99"             NO-UNDO.

DEF {1} SHARED VAR aux_flgretor AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"               NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                NO-UNDO.


/* .......................................................................... */
