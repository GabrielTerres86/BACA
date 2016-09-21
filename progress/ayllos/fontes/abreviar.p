/* .............................................................................
   Programa: Fontes/abreviar.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/97                        Ultima Atualizacao: 20/01/98

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Converter strings abreviando-as para o numero pedido..

   Parametros
   ==========

   ENTRADA: par_nmdentra: string com o texto a abreviar
            par_qtletras: quantidade de caracteres com que deve ficar o texto

   SAIDA    glb_nmabrevi: string com o texto abreviado.

   Alteracoes: 19/01/99 - Tratar "E/OU" para segundo titular prefixo (Odair)
............................................................................. */

DEF INPUT  PARAMETER par_nmdentra AS CHAR  NO-UNDO.
DEF INPUT  PARAMETER par_qtletras AS INT   NO-UNDO.

DEF OUTPUT PARAMETER glb_nmabrevi AS CHAR  NO-UNDO.

DEF VAR aux_contador AS INT                    NO-UNDO.
DEF VAR aux_dsdletra AS CHAR                   NO-UNDO.

DEF VAR aux_palavras AS CHAR EXTENT 99         NO-UNDO.
DEF VAR aux_qtdnomes AS INT                    NO-UNDO.
DEF VAR aux_qtletini AS INT                    NO-UNDO.
DEF VAR aux_eliminar AS LOGICAL                NO-UNDO.
DEF VAR aux_lssufixo AS CHAR                   NO-UNDO.
DEF VAR aux_lsprfixo AS CHAR                   NO-UNDO.


ASSIGN glb_nmabrevi = TRIM(par_nmdentra)
       aux_eliminar = FALSE
       aux_lssufixo = "FILHO,NETO,SOBRINHO,JUNIOR,JR."
       aux_lsprfixo = "E/OU".

DO WHILE TRUE:

    aux_qtletini = LENGTH(glb_nmabrevi).

    IF  aux_qtletini <= par_qtletras THEN
        LEAVE.

    ASSIGN aux_palavras = ""
           aux_qtdnomes = 1.

        /* Separa os nomes */

    DO  aux_contador = 1 TO LENGTH(glb_nmabrevi):

        aux_dsdletra = SUBSTR(glb_nmabrevi,aux_contador,1).

        IF   aux_dsdletra <> " " THEN
             aux_palavras[aux_qtdnomes] = aux_palavras[aux_qtdnomes] +
                                          aux_dsdletra.
        ELSE
             aux_qtdnomes = aux_qtdnomes + 1.

    END.

    IF   CAN-DO(aux_lsprfixo,TRIM(aux_palavras[1])) THEN
         DO:
             aux_palavras[1] = aux_palavras[1] + " " + aux_palavras[2].
             
             DO  aux_contador = 2 TO aux_qtdnomes:
             
                 aux_palavras[aux_contador] = aux_palavras[aux_contador + 1].
         
             END.       
                    
             ASSIGN aux_palavras[aux_qtdnomes] = ""
                    aux_qtdnomes = aux_qtdnomes - 1.
                    
         END.
                    
    IF   CAN-DO(aux_lssufixo,TRIM(aux_palavras[aux_qtdnomes])) THEN
         DO:

             IF   aux_palavras[aux_qtdnomes] = "JUNIOR" THEN
                  aux_palavras[aux_qtdnomes] = "JR.".

             ASSIGN aux_palavras[aux_qtdnomes - 1] =
                        aux_palavras[aux_qtdnomes - 1] + " " +
                        aux_palavras[aux_qtdnomes]

             aux_palavras[aux_qtdnomes] = ""
             aux_qtdnomes = aux_qtdnomes - 1.

         END.

    glb_nmabrevi = "".

    DO aux_contador = 1 TO aux_qtdnomes.

       glb_nmabrevi = glb_nmabrevi + (IF   aux_contador <> 1
                                     THEN " "
                                     ELSE "")
                                     + aux_palavras[aux_contador].

    END.

    IF   aux_qtdnomes < 3 THEN
         LEAVE.

    ASSIGN glb_nmabrevi = aux_palavras[1]
           aux_contador = 2.

    DO WHILE TRUE:

       IF   LENGTH(aux_palavras[aux_contador]) > 2 THEN
            DO:
                glb_nmabrevi = glb_nmabrevi + " " +
                               SUBSTR(aux_palavras[aux_contador],1,1) + ".".
                LEAVE.
            END.
       ELSE
            IF   aux_eliminar THEN
                 aux_eliminar = FALSE.
            ELSE
                 glb_nmabrevi = glb_nmabrevi + " " +
                                aux_palavras[aux_contador].

       aux_contador = aux_contador + 1.

       IF   aux_contador >= aux_qtdnomes  THEN
            DO:
                aux_contador = aux_contador - 1.
                LEAVE.
            END.

    END.

    DO aux_contador = (aux_contador + 1) TO aux_qtdnomes.

       glb_nmabrevi = glb_nmabrevi + " "  + aux_palavras[aux_contador].

    END.

    IF   aux_qtletini = LENGTH(glb_nmabrevi) THEN
         IF   aux_qtdnomes > 2 THEN
              aux_eliminar = TRUE.
         ELSE
              LEAVE.

END.

/* .......................................................................... */
