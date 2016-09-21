/* .............................................................................

   Programa: Fontes/atendap.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Paulo - Precise
   Data    : 17/07/2009.                          Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: chama de forma batch o programa atenda.p que seria de uso 
               diario e on-line.
   Objetivo  : Chamar tela ATENDA em backgroup para levantamento de tempos 
               de indicadores de Performance.                                                                               
............................................................................. */

{ includes/var_online.i "NEW"}

ASSIGN glb_cdprogra = "ATENDAP".

RUN fontes/inicia.p.

DEF VAR AUX_PARAMETER  AS CHAR                       NO-UNDO.
DEF VAR aux_cdcooper   AS INT                        NO-UNDO.
DEF VAR aux_nrdconta   AS INT                        NO-UNDO.
DEF VAR aux_posicao    AS INT                        NO-UNDO.
DEF VAR aux_tamanho    AS INT                        NO-UNDO.

ASSIGN AUX_PARAMETER = (SESSION:PARAMETER).

IF LENGTH(AUX_PARAMETER) > 0 THEN
DO:
    /* O parametro (AUX_PARAMETER) eh formado pelo parametro Cooperativa e
       nro conta de cooperado (seperado pelo caracter ";")
       Exemplo: AUX_PARAMETER = "1;329", sendo:
                - cooperativa = 1 (viacredi)
                - nro conta   = 329.
    */
    
    ASSIGN aux_tamanho  = LENGTH (aux_parameter)
           aux_posicao  = INDEX(aux_parameter,";") - 1
           aux_cdcooper = INT (SUBSTR(aux_parameter,1,aux_posicao))
           aux_posicao  = aux_posicao + 2
           aux_tamanho  = aux_tamanho - aux_posicao + 1
           aux_nrdconta = INT (SUBSTR(aux_parameter,aux_posicao,aux_tamanho)).

    ASSIGN glb_cdcooper = aux_cdcooper
           glb_conta_script = aux_nrdconta.

    RUN fontes/atenda.p.
    QUIT.
END.

