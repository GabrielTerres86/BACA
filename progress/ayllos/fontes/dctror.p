/* ............................................................................

   Programa: Fontes/dctror.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 08/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela DCTROR.

   Alteracoes: 26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               06/11/98 - Tratar situacao em prejuizo (Deborah).
               
               23/10/2005 - Retirada da variavel tel_nrtalchq dos FORMs f_erros
                            f_label e f_lanctos (SQLWorks - Andre).
                            
               13/02/2007 - Incluidos novos campos utilizados na operacao tipo
                            2(contra-ordem), e modificada variavel tel_nrdctabb
                            para tel_nrctachq (Diego).
                            
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN FIND" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               08/06/2011 - Adaptacao para uso de BO. (André - DB1)
                            
............................................................................ */
{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0095tt.i }
{ includes/var_dctror.i NEW }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

ASSIGN glb_cddopcao = "I".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE 0.

NEXT-PROMPT tel_tptransa WITH FRAME f_dctror.

DO WHILE TRUE:

    HIDE FRAME f_label NO-PAUSE.
    HIDE FRAME f_lanctos NO-PAUSE.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
        UPDATE glb_cddopcao tel_tptransa tel_nrdconta WITH FRAME f_dctror.
   
        LEAVE.
   
    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "DCTROR"   THEN
                DO:
                    HIDE FRAME f_dctror.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    ASSIGN aux_nrdconta = tel_nrdconta.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-b1wgen9999.

    RUN dig_fun IN h-b1wgen9999 
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT-OUTPUT aux_nrdconta,
         OUTPUT TABLE tt-erro ).

    DELETE PROCEDURE h-b1wgen9999.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN 
                DO:
                    MESSAGE tt-erro.dscritic.
                    CLEAR FRAME f_dctror NO-PAUSE.
                    NEXT-PROMPT tel_nrdconta WITH FRAME f_dctror.
                END.

            NEXT.
        END.

    CASE glb_cddopcao:
        WHEN "A" THEN
            RUN fontes/dctrora.p.
        WHEN "C" THEN
            RUN fontes/dctrorc.p.
        WHEN "E" THEN
            RUN fontes/dctrore.p.
        WHEN "I" THEN
            RUN fontes/dctrori.p.
    END CASE.

    NEXT-PROMPT tel_nrdconta WITH FRAME f_dctror.

END.  /*  Fim do DO WHILE TRUE  */

/* ......................................................................... */












