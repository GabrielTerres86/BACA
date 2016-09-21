/* .............................................................................

   Programa: Fontes/imprel.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/96                    Ultima Atualizacao: 21/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPREL - Impressao de Relatorios do Sistema
   
   Alteracao : 21/07/99 - Incluir relatorio de taxas de rdca (Odair)

             06/03/2001 - Incluir relatorio 135 debitos nao efetuados 
                          (emprestimos). (Ze Eduardo).
                          
             17/10/2001 - Incluir opcao para visualizacao dos relatorios
                          (Junior).
                          
             21/02/2002 - Incluir relatorio 267 listagem de abertura/recadas-
                          tramento de contas no dia. (Ze Eduardo).

             23/08/2002 - Incluir relatorio 278 listagem dos saldos negativos
                          quando a COMPE e integrada por fora (Margarete).
                          
             26/09/2002 - Incluir relatorio 276 resumo das devolucoes.
                          (Ze Eduardo).
                          
             11/12/2002 - Incluir relatorio 280 matriculas novas (Junior).
             
             14/05/2003 - Incluir o relatorio 102 (Deborah).
             
             23/07/2003 - Inclusao do relatorio 266 (Julio).

             05/08/2003 - Inclusao do relatorio 294 (Fernando).
             
             11/09/2003 - Foi criado a opcao (D) para o usuario imprimir todos
                          os relatorios descritos na variavel aux_lsrelato ou
                          (C) para escolher o relatorio desejado (Fernando).
                          
             15/12/2003 - Incluir relatorio Devolucoes do Bco do Brasil (Ze).

             15/03/2004 - Alterada Descricao (crrl266) de Emprestimos p/
                          Emprestimos/Descto(Mirtes)
                           
             03/06/2004 - Inclusao do relatorio 353  (Evandro).
             
             13/08/2004 - Inclusao do relatorio 362-Cartas Empr/CL(Mirtes).
             
             03/09/2004 - Acrescentar o Rel. 090 (Ze Eduardo).

             04/10/2004 - Acrescentar Rel.372(Mirtes).
             
             22/10/2004 - Acrescentar o Rel. 374 (Ze Eduardo).
             
             16/03/2005 - Substituido o Rel.374 pelo Rel.396 (Evandro).
             
             18/04/2005 - Acrescentar o relatorio 11 (Edson).
             
             20/05/2005 - Incluido relatorio 055 (Evandro).
             
             23/05/2005 - Reordenados os relatorios por Codigo;
                          Corrigido o funcionamento do rel 090 (Evandro).
                          
             24/05/2005 - Incluido relatorio 386 (Evandro).
             
             30/06/2005 - Incluido relatorio 145 (Evandro).
             
             07/07/2005 - Incluido relatorio 426 e 033 (Evandro).
             
             15/08/2005 - Incluido relatorio 395 (Evandro).

             10/10/2005 - Incluido relatorio 352 (Diego).

             11/10/2005 - Incluido relatorio 345 (Diego).

             11/05/2006 - Inclusao do relatorio 156 (Julio)
             
             16/05/2006 - Excluir relatorio 276-Bancoob (Magui) 
             
             03/07/2006 - Incluido relatorio 229 (Diego).
             
             12/09/2006 - Excluida opcao "TAB" (Diego).
             
             01/06/2007 - Incluido relatorio 276 (Diego).
             
             02/08/2007 - RDCPRE e RDCPOS a vencer, crrl458 (Magui).
             
             04/11/2008 - Incluido relatorio 497 (Evandro).
             
             07/06/2010 - Inclusao do relatorio 529 e 530 (Adriano).
             
             18/03/2011 - Retirado relatorio 276 e inserido 529 na lista da
                          opcao C (Henrique).
                          
             30/03/2011 - Mudança do layout da opcao "C" (Vitor)
             
             27/04/2011 - Corrigido alteracoes acima (Guilherme).
             
             24/05/2011 - Incluir relatorio 599 (Guilherme).
             
             08/07/2011 - Incluidos relatorios crrl597 e crrl598 (Henrique).
             
             24/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1)
             
             13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO).
             
             29/05/2014 - Concatena o numero do servidor no endereco do
                          terminal (Tiago-RKAM).
                          
             21/08/2014 - Quando for mandar o crrl102 para a impressora, a
                          variavel glb_nmformul precisa ser alterada para 
                          '234dh'. (Chamado 192211) - (Fabricio).
                          
                          
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0109tt.i }
{ includes/var_online.i }

DEF VAR tel_qtdevias AS INT                                          NO-UNDO.
                                                                    
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.
                                                                    
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INTE                                         NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                         NO-UNDO.
DEF VAR par_flgrodar AS LOGI INIT TRUE                               NO-UNDO.
DEF VAR par_flgfirst AS LOGI INIT TRUE                               NO-UNDO.
DEF VAR par_flgcance AS LOGI                                         NO-UNDO.

DEF        VAR tel_cddopcao AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.

DEF        VAR h-b1wgen0109 AS HANDLE                                NO-UNDO.
DEF        VAR aux_nrdrelat AS INTE                                  NO-UNDO.
DEF        VAR aux_flgtermi AS LOGI                                  NO-UNDO.

DEF QUERY q-cmd FOR tt-nmrelato.

DEF BROWSE b-cmd QUERY q-cmd
    DISPLAY tt-nmrelato.nmrelato     
    WITH 13 DOWN WIDTH 50 NO-LABELS SCROLLBAR-VERTICAL.

FORM b-cmd  
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 6 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse.

FORM SKIP(1)
     tel_cdagenci AT  13 FORMAT "zz9" LABEL "PA"
     SKIP(1)
     tel_qtdevias AT  12 FORMAT "9"  LABEL "Vias"
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY WIDTH 30
          TITLE " Imprimir " + tt-nmrelato.nmdprogm + " " FRAME f_imprel.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.
          
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 2 LABEL "Opcao" AUTO-RETURN
         HELP "Opcao: C - Relatorios individuais / D - Relatorios mais usados"
         VALIDATE (CAN-DO("C,D", glb_cddopcao), "014 - Opcao errada.")
         WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.
     
FORM tel_cdagenci AT 1 LABEL "PA" AUTO-RETURN
                  HELP "Informe o numero do PA"
                  WITH ROW 7 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_pac.

ASSIGN glb_nmformul = "132col".

RUN Lista_Relatorios.

ON RETURN OF b-cmd IN FRAME f_browse
DO: 
    VIEW FRAME f_opcao.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN NEXT.

    ASSIGN tel_cddopcao = "T".

    MESSAGE "(T)erminal ou (I)mpressora: "
            UPDATE tel_cddopcao.

    HIDE MESSAGE NO-PAUSE.
    HIDE FRAME f_browse NO-PAUSE.

    IF  tel_cddopcao = "I" THEN
        DO:
            ASSIGN tel_cdagenci = 0
                   tel_qtdevias = 0.

            IF  tt-nmrelato.flgvepac THEN
                UPDATE tel_cdagenci tel_qtdevias WITH FRAME f_imprel.

            ASSIGN aux_nrdrelat = tt-nmrelato.contador.

            RUN Gera_Impressao.
                
        END.
    ELSE
    IF  tel_cddopcao = "T" THEN
        DO: 
            ASSIGN tel_cdagenci = 0
                   tel_qtdevias = 0.
            IF  tt-nmrelato.flgvepac THEN
                DO:
                    CLEAR FRAME f_imprel ALL NO-PAUSE.
                    HIDE FRAME f_imprel NO-PAUSE.
                    
                    UPDATE tel_cdagenci WITH FRAME f_imprel.

                    HIDE FRAME f_imprel NO-PAUSE.

                  END.

            ASSIGN aux_nrdrelat = tt-nmrelato.contador.

            RUN Gera_Impressao.

            IF  RETURN-VALUE <> "OK" THEN
                LEAVE.
            
            RUN fontes/visrel.p (INPUT aux_nmarqimp).

            DISPLAY glb_cddopcao WITH FRAME f_opcao.

        END.
    ELSE
        DO:
            BELL.
            MESSAGE "Escolha invalida, tente novamente!".
            LEAVE.
        END.

    APPLY LASTKEY.
END.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_opcao.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    HIDE MESSAGE NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    /* F4 OU FIM  */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "IMPREL" THEN
                DO: 
                    IF  VALID-HANDLE(h-b1wgen0109) THEN
                        DELETE OBJECT h-b1wgen0109.

                    HIDE FRAME f_opcao.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    DISPLAY glb_cddopcao WITH FRAME f_opcao.

    ASSIGN tel_cddopcao = ""
           tel_cdagenci = 0.

    CASE glb_cddopcao:

        WHEN "D" THEN
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN tel_cdagenci = 0
                       tel_qtdevias = 0.    

                FOR EACH tt-nmrelato WHERE tt-nmrelato.flgrelat 
                                                          ON ENDKEY UNDO, NEXT:

                    HIDE FRAME f_imprel NO-PAUSE.

                    UPDATE tel_cdagenci tel_qtdevias WITH FRAME f_imprel.

                    IF  tel_cdagenci <> 0 THEN
                        LEAVE.

                END.

                HIDE FRAME f_imprel NO-PAUSE.

                IF  tel_cdagenci <> 0 THEN
                    DO:
                        ASSIGN aux_nrdrelat = tt-nmrelato.contador.
                        RUN Gera_Impressao.
                    END.

                LEAVE.
               
             END.  /*  Fim do DO WHILE TRUE  */

        WHEN "C" THEN
             DO: 
                 PAUSE(0).
                 RUN imprelc.
             END.

   END.  /*  Fim do CASE  */

   HIDE FRAME f_pac.
   
END.  /*  Fim do DO WHILE TRUE  */

/*...........................................................................*/

PROCEDURE Lista_Relatorios:

    EMPTY TEMP-TABLE tt-nmrelato.

    IF  NOT VALID-HANDLE(h-b1wgen0109) THEN
        RUN sistema/generico/procedures/b1wgen0109.p
            PERSISTENT SET h-b1wgen0109.
    
    RUN Lista_Relatorios IN h-b1wgen0109 ( OUTPUT TABLE tt-nmrelato).

    RETURN "OK".

END PROCEDURE. /* Lista_Relatorios */

PROCEDURE Gera_Impressao:
      
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0109) THEN
        RUN sistema/generico/procedures/b1wgen0109.p
           PERSISTENT SET h-b1wgen0109.

    IF  glb_cddopcao = "C"  AND tel_cddopcao = "T" THEN
         ASSIGN aux_flgtermi = TRUE.
    ELSE ASSIGN aux_flgtermi = FALSE.
    
    RUN Gera_Impressao IN h-b1wgen0109
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1,
          INPUT aux_nmendter,
          INPUT glb_cddopcao,
          INPUT aux_nrdrelat,
          INPUT tel_cdagenci,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.
           
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    IF  NOT aux_flgtermi  THEN
        DO:
            IF  tel_qtdevias = 0   THEN
                ASSIGN glb_nrdevias = 1.
            ELSE 
                ASSIGN glb_nrdevias = tel_qtdevias.

            IF aux_nrdrelat = 7 THEN /* crrl102_* */
                ASSIGN glb_nmformul = "234dh".
            ELSE
                ASSIGN glb_nmformul = "132col".

            /*** nao necessario ao programa somente para nao dar erro 
                      de compilacao na rotina de impressao ****/
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.
        
            { includes/impressao.i }
        END.

    RETURN "OK".

END PROCEDURE. /* Gera_Impressao */


PROCEDURE imprelc:
                  
  OPEN QUERY q-cmd FOR EACH tt-nmrelato NO-LOCK.

  ENABLE b-cmd WITH FRAME f_browse.
  
  PAUSE 0.
  
  APPLY "ENTRY" TO b-cmd IN FRAME f_browse.
  
  WAIT-FOR END-ERROR, RETURN OF DEFAULT-WINDOW.

  CLOSE QUERY q-cmd.
  
  DISABLE b-cmd WITH FRAME f_browse.

  HIDE FRAME f_browse NO-PAUSE.
  HIDE FRAME f_imprel NO-PAUSE.
  HIDE BROWSE b-cmd NO-PAUSE.

END PROCEDURE. /* imprelc */

/*...........................................................................*/
