/* ............................................................................

   Programa: Includes/var_cobregis.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2011                        Ultima atualizacao: 05/06/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Definicao de variaves e temp-tables da Cobranca Registrada.

   Alteracao : 16/01/2013 - Incluido nr.convenio - tt-lcm-consolidada. (Rafael)
   
               05/06/2013 - Incluso campo cdfvlcop na tt-lcm-consolidada. (Daniel)
............................................................................ */


DEF TEMP-TABLE tt-lcm-consolidada NO-UNDO
    FIELD cdcooper LIKE craplcm.cdcooper
    FIELD nrdconta LIKE craplcm.nrdconta
    FIELD nrconven LIKE crapcco.nrconven
    FIELD cdocorre AS INT
    FIELD cdhistor LIKE craplcm.cdhistor
    FIELD tplancto AS CHAR
    FIELD vllancto LIKE craplcm.vllanmto
    FIELD qtdregis AS INT
    FIELD cdfvlcop AS INT 
   INDEX ix-lcm1 cdcooper nrdconta cdocorre cdhistor.


DEF TEMP-TABLE tt-trailer NO-UNDO
    FIELD cdcooper AS INT
    FIELD nmarquiv AS CHAR
    FIELD qtreglot AS INT
    FIELD qttitcsi AS INT
    FIELD vltitcsi LIKE craplcm.vllanmto
    FIELD qttitcvi AS INT
    FIELD vltitcvi LIKE craplcm.vllanmto
    FIELD qttitcca AS INT
    FIELD vltitcca LIKE craplcm.vllanmto
    FIELD qttitcde AS INT
    FIELD vltitcde LIKE craplcm.vllanmto
   INDEX ix-tr1 cdcooper nmarquiv.










