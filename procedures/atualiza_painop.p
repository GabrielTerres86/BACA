/* ..............................................................................

Procedure: atualiza_painop.p 
Objetivo : Atualizar o display do PAINOP - Painel do Operador
Autor    : Evandro
Data     : Agosto 2011


Ultima alteração: 

............................................................................... */


DEFINE INPUT PARAM buff         AS CHAR         EXTENT 6            NO-UNDO.

DEFINE VARIABLE LpBuffDisp      AS MEMPTR                           NO-UNDO.
DEFINE VARIABLE aux_contador    AS INTEGER                          NO-UNDO.

{ includes/var_taa.i }
{ includes/var_xfs_lite.i }


SET-SIZE(LpBuffDisp) = 81.


/* se enviar tudo em branco, monta somente a moldura */
IF  buff[1] + buff[2] + buff[3] +
    buff[4] + buff[5] + buff[6] = ""  THEN
    DO:
        PUT-STRING(LpBuffDisp,1) = "+--------------------------------------+" +
                                   "|                                      |".

        RUN WinAtualizaDisplay IN aux_xfsliteh (
            INPUT  2, /* Teclado PAINOP */
            INPUT -1, /* Nao Limpar */
            INPUT -1, /* Nao Fazer Scroll */
            INPUT  0, /* Cursor Invisivel */
            INPUT  1, /* Linha */
            INPUT  1, /* Coluna */
            INPUT GET-POINTER-VALUE(LpBuffDisp), /* Buffer */
            OUTPUT LT_Resp).

        PUT-STRING(LpBuffDisp,1) = "|                                      |" +
                                   "|                                      |".

        RUN WinAtualizaDisplay IN aux_xfsliteh (
            INPUT  2, /* Teclado PAINOP */
            INPUT -1, /* Nao Limpar */
            INPUT -1, /* Nao Fazer Scroll */
            INPUT  0, /* Cursor Invisivel */
            INPUT  3, /* Linha */
            INPUT  1, /* Coluna */
            INPUT GET-POINTER-VALUE(LpBuffDisp), /* Buffer */
            OUTPUT LT_Resp).

        PUT-STRING(LpBuffDisp,1) = "|                                      |" +
                                   "|                                      |".

        RUN WinAtualizaDisplay IN aux_xfsliteh (
            INPUT  2, /* Teclado PAINOP */
            INPUT -1, /* Nao Limpar */
            INPUT -1, /* Nao Fazer Scroll */
            INPUT  0, /* Cursor Invisivel */
            INPUT  5, /* Linha */
            INPUT  1, /* Coluna */
            INPUT GET-POINTER-VALUE(LpBuffDisp), /* Buffer */
            OUTPUT LT_Resp).

        PUT-STRING(LpBuffDisp,1) = "|                                      |" +
                                   "+--------------------------------------+".

        RUN WinAtualizaDisplay IN aux_xfsliteh (
            INPUT  2, /* Teclado PAINOP */
            INPUT -1, /* Nao Limpar */
            INPUT -1, /* Nao Fazer Scroll */
            INPUT  0, /* Cursor Invisivel */
            INPUT  7, /* Linha */
            INPUT  1, /* Coluna */
            INPUT GET-POINTER-VALUE(LpBuffDisp), /* Buffer */
            OUTPUT LT_Resp).
    END.
ELSE
    DO aux_contador = 1 TO 6:

        IF buff[aux_contador] = "" THEN
           NEXT.
        
        PUT-STRING(LpBuffDisp,1) = buff[aux_contador].
        
        RUN WinAtualizaDisplay IN aux_xfsliteh (
            INPUT  2,                            /* Teclado PAINOP */
            INPUT -1,                            /* Nao Limpar */
            INPUT -1,                            /* Nao Fazer Scroll */
            INPUT  0,                            /* Cursor Invisivel */
            INPUT  aux_contador + 1,             /* A partir da 2 linha (a 1 e a 8 sao para moldura) */
            INPUT  2,                            /* A partir da coluna 2 (a 1 e a 40 sao para moldura)*/
            INPUT GET-POINTER-VALUE(LpBuffDisp), /* Buffer */
            OUTPUT LT_Resp).
    END.

SET-SIZE(LpBuffDisp) = 0.


RETURN "OK".

/* ........................................................................... */

