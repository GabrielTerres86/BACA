/* ...........................................................................

   Programa: Fontes/telefone.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Janeiro/2011.                 Ultima atualizacao: 
   
   Dados referentes ao programa: 

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a rotina TELEFONE da tela ATENDA.
   
   Alteracoes:
                                                                              
............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0070tt.i }                         

{ includes/var_online.i }

DEF INPUT PARAM par_nrdconta AS INTE                                   NO-UNDO.


DEF VAR h-b1wgen0070 AS HANDLE                                         NO-UNDO.

DEF QUERY q_telefones FOR tt-telefone-cooperado.

DEF BROWSE b_telefones QUERY q_telefones DISP   
 tt-telefone-cooperado.nmopetfn COLUMN-LABEL "Operadora"         FORMAT "x(12)"
 tt-telefone-cooperado.nrdddtfc COLUMN-LABEL "DDD"               FORMAT "999"
 tt-telefone-cooperado.nrfonres COLUMN-LABEL "Telefone"          FORMAT "x(19)"
 tt-telefone-cooperado.nrdramal COLUMN-LABEL "Ramal"             FORMAT "zzzz"
 tt-telefone-cooperado.destptfc COLUMN-LABEL "Identificacao"     FORMAT "x(11)"
 tt-telefone-cooperado.nmpescto COLUMN-LABEL "Pessoa de Contato" FORMAT "x(17)"
 WITH 7 DOWN TITLE " TELEFONES ".

FORM b_telefones HELP "Pressione F4/END para sair."
     WITH WIDTH 80 NO-BOX ROW 11 OVERLAY NO-LABEL FRAME f_browse.


RUN sistema/generico/procedures/b1wgen0070.p PERSISTENT SET h-b1wgen0070.

RUN obtem-telefone-titulares IN h-b1wgen0070 (INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT 1, /* Ayllos */
                                              INPUT par_nrdconta,
                                              INPUT 1, /* Tit. */
                                              INPUT TRUE,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-telefone-cooperado).
DELETE PROCEDURE h-b1wgen0070.

IF   RETURN-VALUE <> "OK"   THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.
         ELSE
              MESSAGE "Erro na pesquisa dos telefones.".

         RETURN.
     END.

OPEN QUERY q_telefones FOR EACH tt-telefone-cooperado NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE b_telefones WITH FRAME f_browse.
    LEAVE.
END.

HIDE FRAME f_browse.

/* .........................................................................*/
