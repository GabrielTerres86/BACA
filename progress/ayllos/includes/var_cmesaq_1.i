/* .............................................................................

   Programa: Includes/var_cmesaq_1.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : 04/08/2003.                  Ultima atualizacao: 16/11/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela CMESAQ.

   Alteracoes: 04/05/2010 - Adicionadas variveis para tratamento da rotina 20
                            na cmesaq (impressão de movimentação em espécie)
                            (Fernando). 
                            
               16/11/2011 - Retirar variaveis nao utilizadas (Gabriel)             
............................................................................. */

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrdcaixa AS INTE                                NO-UNDO.
DEF {1} SHARED VAR tel_cdopecxa LIKE crapope.cdoperad                  NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"            NO-UNDO.
DEF {1} SHARED VAR tel_nrdocmto LIKE crapcme.nrdocmto                  NO-UNDO.
DEF {1} SHARED VAR tel_tpdocmto AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"               NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_flgretor AS LOGICAL                             NO-UNDO.
 
/* .......................................................................... */
