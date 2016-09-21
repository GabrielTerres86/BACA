/* .............................................................................

   Programa: Includes/var_rdca2.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/96.                    Ultima atualizacao: 06/08/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis utilizadas na rotina includes/rdca2.i .

   Alteracoes: 27/03/98 - Tratamento para milenio e troca para V8 (Margarete).

             13/12/2004 -  Ajustes para tratar das novas aliquotas de 
                           IRRF (Margarete).

             06/08/2007 - Incluidas variaveis rd2_lshistor e rd2_contador para
                          a melhoria de performance (Evandro).

............................................................................. */

DEF        VAR rd2_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_vllan178 AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_vllan180 AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR rd2_dtcalcul AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtdolote AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtultdia AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtrefant AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR rd2_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR rd2_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR rd2_nrdolote AS INT                                   NO-UNDO.
DEF        VAR rd2_cdhistor AS INT                                   NO-UNDO.
DEF        VAR rd2_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR rd2_nrdiames AS INT                                   NO-UNDO.

DEF        VAR rd2_flgentra AS LOGICAL                               NO-UNDO.
DEF        VAR rd2_lshistor AS CHAR                                  NO-UNDO.
DEF        VAR rd2_contador AS INT                                   NO-UNDO.

/* .......................................................................... */
