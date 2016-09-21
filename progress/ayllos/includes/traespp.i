/* ............................................................................

   Programa: includes/traespp.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Novembro/2003.                  Ultima atualizacao: 12/11/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Lista transacoes que nao foi feito o documento.

   Alteracoes: 02/02/2006 - Unificacao dos Campos - SQLWorks - Fernando.
   
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               04/05/2010 - Ajustado programa para as movimentações em
                            espécie criadas na rotina 20 (a partir da
                            craptvl). (Fernando)             

               09/06/2010 - Ajustar leitura do crapcme para o SPB (Magui).
               
               02/12/2011 - Incluir listagem da craplcx (Gabriel).
               
               22/12/2011 - Incluir historico 1030 (Gabriel).
               
               12/11/2013 - Adequacao da regra de negocio a b1wgen0135.p
                            (conversao tela web). (Fabricio)
............................................................................. */
           
           UPDATE tel_cdagenci WITH FRAME f_pac

           EDITING:

              aux_stimeout = 0.

              DO WHILE TRUE:

                 READKEY PAUSE 1.

                 IF   LASTKEY = -1   THEN
                      DO:
                          aux_stimeout = aux_stimeout + 1.

                          IF   aux_stimeout > glb_stimeout   THEN
                               QUIT.

                          NEXT.
                      END.

                 APPLY LASTKEY.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */

           END.  /*  Fim do EDITING  */  

           ASSIGN aux_flgretor = FALSE
                  aux_contador = 0.

           CLEAR FRAME f_transacoes ALL NO-PAUSE.

           EMPTY TEMP-TABLE tt-erro.

           RUN consulta-transacoes-sem-documento IN h-b1wgen0135
                                            (INPUT glb_cdcooper,
                                             INPUT tel_cdagenci,
                                             INPUT 1,
                                             INPUT glb_dtmvtolt,
                                             INPUT 1,
                                             INPUT 999999,
                                            OUTPUT aux_qtregist,
                                            OUTPUT TABLE tt-transacoes-especie,
                                            OUTPUT TABLE tt-erro).

           IF RETURN-VALUE = "NOK" THEN
           DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               BELL.
               MESSAGE tt-erro.dscritic.
               CLEAR FRAME f_transacoes ALL NO-PAUSE.
               LEAVE.
           END.
           
           FOR EACH tt-transacoes-especie NO-LOCK:

               ASSIGN aux_contador = aux_contador + 1.

               IF   aux_contador = 1 THEN
                    IF   aux_flgretor THEN
                         DO:
                             PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                             CLEAR FRAME f_transacoes ALL NO-PAUSE.
                         END.
                    ELSE
                         aux_flgretor = TRUE.

               DISP tt-transacoes-especie.cdagenci
                    tt-transacoes-especie.nrdolote
                    tt-transacoes-especie.nrdconta
                    tt-transacoes-especie.nmprimtl
                    tt-transacoes-especie.nrdocmto
                    tt-transacoes-especie.tpoperac
                    tt-transacoes-especie.vllanmto
                    tt-transacoes-especie.dtmvtolt      
                    tt-transacoes-especie.sisbacen     
                    WITH FRAME f_transacoes.
 
               IF   aux_contador = 4   THEN
                    aux_contador = 0.
               ELSE
                    DOWN WITH FRAME f_transacoes.
           END.

/*............................................................................*/
