/* .............................................................................
   Programa: Fontes/abrevia.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/97                        Ultima Atualizacao: 18/09/96

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Converter strings abreviando-as para o numero pedido..

   Parametros
   ==========

   ENTRADA: par_nmdentra: string com o texto a abreviar
            par_qtletras: quantidade de caracteres com que deve ficar o texto
            par_tpextens: E: expandido
                          C: comprimido

   SAIDA    glb_nmabrevi: string com o texto abreviado.

   Alteracoes:
............................................................................. */

DEF INPUT  PARAMETER par_nmdentra AS CHAR      NO-UNDO.
DEF INPUT  PARAMETER par_qtletras AS INT       NO-UNDO.
DEF INPUT  PARAMETER par_tpextens AS CHAR      NO-UNDO.

DEF OUTPUT PARAMETER glb_nmabrevi AS CHAR      NO-UNDO.

DEF VAR aux_contador AS INT                    NO-UNDO.
DEF VAR aux_nmdentra AS CHAR                   NO-UNDO.
DEF VAR aux_dsdletra AS CHAR                   NO-UNDO.

DEF VAR aux_palavras AS CHAR EXTENT 99         NO-UNDO.
DEF VAR aux_qtdnomes AS INT                    NO-UNDO.

IF  LENGTH(par_nmdentra) < par_qtletras THEN
    DO:
        glb_nmabrevi = par_nmdentra.
        RETURN.
    END.

/* E(xpandido) C(comprimido) */

IF  NOT CAN-DO("E,C",par_tpextens)  THEN
    DO:
        glb_nmabrevi = "TIPO DE PARAMETRO ERRADO".
        RETURN.
    END.

IF   par_qtletras < 10  THEN
     DO:
         glb_nmabrevi = "NUMERO MINIMO DE LETRAS PARA ABREVIAR E 10".
         RETURN.
     END.

ASSIGN aux_nmdentra = TRIM(par_nmdentra)
       aux_palavras = ""
       aux_qtdnomes = 1.

DO  aux_contador = 1 TO LENGTH(aux_nmdentra):

    aux_dsdletra = SUBSTR(aux_nmdentra,aux_contador,1).

    IF  aux_dsdletra <> " " THEN
        aux_palavras[aux_qtdnomes] = aux_palavras[aux_qtdnomes] + aux_dsdletra.
    ELSE
        aux_qtdnomes = aux_qtdnomes + 1.

END.  /*  Fim do DO .. TO  */

glb_nmabrevi = aux_palavras[1].

DO  aux_contador = 2 to (aux_qtdnomes - 1):

    IF LENGTH(aux_palavras[aux_contador]) > 3 THEN
       glb_nmabrevi = glb_nmabrevi + " " +
                      SUBSTR(aux_palavras[aux_contador],1,1) + ".".
    ELSE
       glb_nmabrevi = glb_nmabrevi + " " + aux_palavras[aux_contador].


END.

glb_nmabrevi = glb_nmabrevi + " "  + aux_palavras[aux_qtdnomes].


/* .......................................................................... */
