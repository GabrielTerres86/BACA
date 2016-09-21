/* .............................................................................

   Programa: Siscaixa/web/dbo/pcrap14.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Magui
   Data    : Outubro/2008                    Ultima atualizacao: 10/10/2008

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo onze.

   Alteracoes:
............................................................................. */
DEF INPUT-OUTPUT PARAM nro-calculado AS DECIMAL                 NO-UNDO.
DEF OUTPUT       PARAM nro-digito    AS INTEGER                 NO-UNDO.
DEF OUTPUT       PARAM l-retorno     AS LOGICAL                 NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 9                         NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_strnume  AS CHAR                                   NO-UNDO.

IF   LENGTH(STRING(nro-calculado)) < 44   THEN
     DO:
         l-retorno = FALSE.
         RETURN.
     END.

ASSIGN aux_strnume = 
    SUBSTR(STRING(nro-calculado,"99999999999999999999999999999999999999999999"),
           1,3) +
    SUBSTR(STRING(nro-calculado,"99999999999999999999999999999999999999999999"),
           5,40)
       aux_peso = 2.  /*alimenta a tabela de pesos e multiplica 
                                                     para cada digito*/

DO aux_posicao = (LENGTH(STRING(aux_strnume))) TO 1 BY -1:
   ASSIGN aux_calculo = aux_calculo + 
              INTEGER(SUBSTRING(aux_strnume, aux_posicao, 1)) * aux_peso
          aux_peso = IF   aux_peso = 9 THEN
                          2
                     ELSE aux_peso + 1.
END.

ASSIGN aux_resto = aux_calculo MODULO 11.

CASE aux_resto:

     WHEN  0  THEN  ASSIGN aux_digito = 0.
     WHEN  1  THEN  ASSIGN aux_digito = 0.
     WHEN  10 THEN  ASSIGN aux_digito = 1.
END CASE.
    
IF aux_resto <> 0   AND
   aux_resto <> 1   AND
   aux_resto <> 10  THEN
   ASSIGN aux_digito = 11 - aux_resto.

IF   INTE(SUBSTR(STRING
     (nro-calculado,"99999999999999999999999999999999999999999999"),4,1)) <>
                           aux_digito THEN
     l-retorno = FALSE.
ELSE
     l-retorno = TRUE.

ASSIGN nro-digito = aux_digito.
/* .......................................................................... */