/* ............................................................................

   Programa: Includes/var_limite.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Eder
   Data    : Junho/09.                           Ultima atualizacao: 15/04/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)

   Objetivo  : Criacao das variaveis para tratamento de limite de credito.
   
   Alteracaoes: 15/04/2011 - Inclusão de variáveis para CEP integrado, 
                             nrendere, complend e nrcxapst. 
                             Alteração do form f_promissoria. (André - DB1)
............................................................................ */
DEF {1} SHARED VAR lim_nrctaav1  AS INT                            NO-UNDO.
DEF {1} SHARED VAR lim_nmdaval1  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav1  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_dsendav1  AS CHAR EXTENT 2                  NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav1  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav1  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_cpfcgc1   AS DEC  FORMAT "zzzzzzzzzzzzz9"   NO-UNDO.
DEF {1} SHARED VAR lim_cpfccg1   AS DEC  FORMAT "zzzzzzzzzzzzz9"   NO-UNDO.
DEF {1} SHARED VAR lim_nmcidade1 AS CHAR FORMAT "x(25)"            NO-UNDO.
DEF {1} SHARED VAR lim_cdufresd1 AS CHAR FORMAT "!(2)"             NO-UNDO.
DEF {1} SHARED VAR lim_nrcepend1 AS INTE FORMAT "zz,zzz,zz9"       NO-UNDO.
DEF {1} SHARED VAR lim_tpdocav1  AS CHAR FORMAT "x(2)"             NO-UNDO.
DEF {1} SHARED VAR lim_tpdoccj1  AS CHAR FORMAT "x(2)"             NO-UNDO.
DEF {1} SHARED VAR lim_nrfonres1 AS CHAR FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR lim_dsdemail1 AS CHAR FORMAT "x(30)"            NO-UNDO.

DEF {1} SHARED VAR lim_nrctaav2  AS INT                            NO-UNDO.
DEF {1} SHARED VAR lim_nmdaval2  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav2  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_dsendav2  AS CHAR EXTENT 2                  NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav2  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav2  AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR lim_cpfcgc2   AS DEC  FORMAT "zzzzzzzzzzzzz9"   NO-UNDO.
DEF {1} SHARED VAR lim_cpfccg2   AS DEC  FORMAT "zzzzzzzzzzzzz9"   NO-UNDO.
DEF {1} SHARED VAR lim_nmcidade2 AS CHAR FORMAT "x(25)"            NO-UNDO.
DEF {1} SHARED VAR lim_cdufresd2 AS CHAR FORMAT "!(2)"             NO-UNDO.
DEF {1} SHARED VAR lim_nrcepend2 AS INTE FORMAT "zz,zzz,zz9"       NO-UNDO.
DEF {1} SHARED VAR lim_tpdocav2  AS CHAR FORMAT "x(2)"             NO-UNDO.
DEF {1} SHARED VAR lim_tpdoccj2  AS CHAR FORMAT "x(2)"             NO-UNDO.
DEF {1} SHARED VAR lim_nrfonres2 AS CHAR FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR lim_dsdemail2 AS CHAR FORMAT "x(30)"            NO-UNDO.

/* Adicionais CEP integrado */
DEF {1} SHARED VAR lim_nrendere1 AS INTE FORMAT "zzz,zz9"          NO-UNDO.
DEF {1} SHARED VAR lim_complend1 AS CHAR FORMAT "x(40)"            NO-UNDO.
DEF {1} SHARED VAR lim_nrcxapst1 AS INTE FORMAT "zz,zz9"           NO-UNDO.
DEF {1} SHARED VAR lim_nrendere2 AS INTE FORMAT "zzz,zz9"          NO-UNDO.
DEF {1} SHARED VAR lim_complend2 AS CHAR FORMAT "x(40)"            NO-UNDO.
DEF {1} SHARED VAR lim_nrcxapst2 AS INTE FORMAT "zz,zz9"           NO-UNDO.

