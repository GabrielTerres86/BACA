/* ..............................................................................

Procedure: grava_log.p 
Objetivo : Gravar o log de uso do TAA
Autor    : Evandro
Data     : Fevereiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  27/08/2015 - Adicionado condicao para verificar se o cartao
                               eh magnetico. (James)
............................................................................... */


DEFINE INPUT PARAMETER par_mensagem     AS CHARACTER        NO-UNDO.

{ includes/var_taa.i }

DEFINE VARIABLE        aux_nmarqlog     AS CHARACTER        NO-UNDO.


/* Se nao possui numero do TAA ou data, esta configurando o terminal */
IF  glb_nrterfin = 0  or
    glb_dtmvtocd = ?  THEN
    aux_nmarqlog = "C:\TAA\LOG\LG_CONFIG.log".
ELSE
    aux_nmarqlog = "C:\TAA\LOG\LG" + STRING(glb_nrterfin,"9999") + "_" +
                                      STRING(YEAR(glb_dtmvtocd),'9999') + 
                                      STRING(MONTH(glb_dtmvtocd),'99')  +
                                      STRING(DAY(glb_dtmvtocd),'99')    + ".log".


IF   SEARCH(aux_nmarqlog) <> ?   THEN
     OUTPUT TO VALUE(aux_nmarqlog) APPEND.
ELSE
     OUTPUT TO VALUE(aux_nmarqlog).
     
PUT STRING(TODAY,"99/99/9999") FORMAT "x(10)"
    " - "
    STRING(TIME,"HH:MM:SS").
 
IF  glb_nrcartao <> 0  THEN
    DO:
        PUT " - CARTAO: " STRING(glb_nrcartao,"9999,9999,9999,9999") FORMAT "x(20)".

        /* Verifica se o cartao eh o magnetico e o cartão eh de operador */
        IF  SUBSTRING(STRING(glb_nrcartao),1,1) = "9"  THEN
            PUT " - OPERADOR: ".
        ELSE
            PUT " - CONTA: ".
             
        PUT STRING(glb_nrdconta,"zzzz,zzz,9") FORMAT "x(10)".
    END.

PUT UNFORMATTED " ==> " par_mensagem SKIP.

OUTPUT CLOSE.

RETURN "OK".

/* ............................................................................ */
