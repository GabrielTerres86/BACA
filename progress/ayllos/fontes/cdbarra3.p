/* .............................................................................

   Programa: Fontes/cdbarra3.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Janeiro/2001.                         Ultima atualizacao: 25/08/01

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador do codigo de barras
               dos titulos compensaveis IPTU E SAMAE BLUMENAU.
             
   Alteracoes: 25/08/2001 - Existe digito verificar 0 (Celesc). (Ze Eduardo).
............................................................................. */

DEF OUTPUT PARAM par_nrdigver AS INT                                 NO-UNDO.

DEF SHARED VAR glb_nrcalcul AS DECIMAL                               NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dscalcul AS CHAR                                  NO-UNDO.
DEF        VAR aux_conver   AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdigbar AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.


/********************************************************* Ze Eduardo - Inicio
IF   INTEGER(SUBSTRING(STRING(glb_nrcalcul,
                             "99999999999999999999999999999999999999999999"),
                       4,1)) = 0   THEN
     DO:
         glb_stsnrcal = TRUE.     /*  Nao tem digito verificador  */
         RETURN.
     END.
********************************************************* Ze Eduardo - Fim ***/

ASSIGN aux_dscalcul = STRING(glb_nrcalcul,
                             "99999999999999999999999999999999999999999999")

       glb_nrcalcul = DECIMAL(SUBSTRING(aux_dscalcul,01,03) +
                              SUBSTRING(aux_dscalcul,05,40))
                              
       aux_nrdigbar = INTEGER(SUBSTRING(aux_dscalcul,4,1)).
                            
aux_peso = 2.

DO  aux_posicao = 1 TO LENGTH(STRING(glb_nrcalcul)):

    aux_conver = STRING(INTEGER(SUBSTRING(STRING(glb_nrcalcul), aux_posicao,1)) 
                                                                * aux_peso).
    
    IF   LENGTH(aux_conver) = 2 THEN
         DO:
             aux_calculo = aux_calculo + INTEGER(SUBSTRING(aux_conver,1,1)).
             aux_calculo = aux_calculo + INTEGER(SUBSTRING(aux_conver,2,1)).
         END.
    ELSE
         aux_calculo = aux_calculo + INTEGER(aux_conver).

    IF   aux_peso = 2 THEN
         aux_peso = 1.
    ELSE 
         aux_peso = 2.

END.  /*  Fim do DO .. TO  */

aux_resto = 10 - (aux_calculo MODULO 10).

IF   aux_resto = 10  THEN
     aux_digito = 0.
ELSE
     aux_digito = aux_resto.

IF   aux_digito <> aux_nrdigbar   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

ASSIGN par_nrdigver = aux_digito
       glb_nrcalcul = DECIMAL(SUBSTRING(aux_dscalcul,01,03) +
                              STRING(aux_digito) +
                              SUBSTRING(aux_dscalcul,05,40)).
/* .......................................................................... */