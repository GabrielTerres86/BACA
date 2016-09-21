/*..............................................................................

    Programa: foco_campo.i
    Autor   : Jose Luis Marchezoni - DB1 Informatica
    Data    : Maio/2010                       Ultima atualizacao: 01/09/2011

    Objetivo  : Rotina para retornar o foco em um campo de um frame

    Alteracoes: 11/04/2011 - Adicionado Tipo de Campo EDITOR (André - DB1)
    
                01/09/2011 - Alterado o seletor para pegar sempre o ultimo
                             FIELD-GROUP do FRAME {&NOME-FRAME}
                             ( Gabriel Capoia - DB1 )
   
..............................................................................*/

&IF DEFINED(VAR-GERAL) &THEN

    DEFINE VARIABLE wFrame AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE wCampo AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE cCampo AS CHARACTER     NO-UNDO.

&ENDIF

ASSIGN 
    wFrame = FRAME {&NOME-FRAME}:HANDLE
    wCampo = wFrame:LAST-CHILD
    wCampo = wCampo:PREV-SIBLING
    wCampo = wCampo:FIRST-CHILD
    cCampo = {&NOME-CAMPO}.

/* percorre todos os objetos do frame */
Campo: DO WHILE VALID-HANDLE(wCampo):

    /* procura pelo campo que retornou o erro */
    IF  CAN-DO("FILL-IN,EDITOR",wCampo:TYPE) THEN 
        DO:
           IF  wCampo:NAME MATCHES ("*" + cCampo + "*") THEN 
               DO:
                   APPLY "ENTRY" TO wCampo.
                   LEAVE Campo.
               END.
        END.

    ASSIGN wCampo = wCampo:NEXT-SIBLING.
END.

/* mesmo se nao encontrar o campo, retorna ao inicio da edicao */
NEXT.
