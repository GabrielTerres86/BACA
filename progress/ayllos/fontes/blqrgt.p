/* .............................................................................

   Programa: Fontes/blqrgt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah          
   Data    : Abril/2000                          Ultima atualizacao: 17/10/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela BLQRGT. 

   Alteracoes: 09/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                            para 7 posicoes, na leitura da tabela;
                            Modificado para aceitar o bloqueio/liberacao de
                            poupanca programada;
                            Incluido o Tipo da Aplicacao (Evandro).

               27/06/2005 - Alimentado campo cdccoper da tabela craptab (Diego).

               26/01/2006 - Unificacao dos bancos - SQLWorks - Luciane

               07/02/2006 - Inclusao de EXCLUSIVE-LOCK no FIND da linha 237 - 
                            SQLWorks - Fernando.
               
               21/05/2007 - Inclusao dos tipos de aplicacao PRE e POS (Elton).
               
               13/07/2010 - Criação de log para ser mostrado na tela LOGTEL
                            (Adriano).
                            
               15/01/2013 - Conversão para a BO148 (Lucas).
               
               14/05/2014 - Adicionar a pesquisa de aplicacoes quando 
                            presionar F7 no campo aplicacao. (Douglas)

               21/05/2014 - Alterado a tela de zoom das aplicações (Douglas)
               
               13/10/2014 - Alterações para leitura de novas aplicacoes, projeto
                            de captacao. (Jean Michel).

               17/10/2014 - Alterações nas chamadas das procedures busca-blqrgt,
                            valida-blqrgt, bloqueia-blqrgt, libera-blqrgt e ajustes
                            para os novos produtos de captacao (Jean Michel).
                            
............................................................................. */

{ includes/var_online.i}
{ sistema/generico/includes/var_internet.i }

DEF VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9" NO-UNDO.
DEF VAR tel_nraplica AS INT     FORMAT "zzzz,zz9"   NO-UNDO.
DEF VAR tel_tpaplica AS INT     FORMAT "zz9"        NO-UNDO.
DEF VAR tel_nmaplica AS CHAR    FORMAT "x(25)"      NO-UNDO.
DEF VAR tel_flgstapl AS LOGI                        NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                        NO-UNDO.
DEF VAR aux_cdprodut AS INT                         NO-UNDO.
DEF VAR aux_nraplicx AS INT                         NO-UNDO.
DEF VAR aux_idtipapl AS CHAR                        NO-UNDO.
DEF VAR aux_nmprodut AS CHAR                        NO-UNDO.

DEF VAR h-b1wgen0148 AS HANDLE                      NO-UNDO.

FORM SKIP(3)
     glb_cddopcao AT 30 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (C, B, L)"
                        VALIDATE(CAN-DO("C,B,L",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(2)
     tel_nrdconta AT 27 LABEL "Conta/dv"                       
             HELP "Entre com o numero da conta do associado"
     SKIP(2)
     tel_nmaplica AT 28 LABEL "Produto"
     HELP "Pressione F7 para selecionar o tipo da aplicacao"
     
     SKIP(2)
     tel_nraplica AT 26 LABEL "Aplicacao"                         
             HELP "Entre com o numero da aplicacao ou F7 para pesquisar"
     SKIP(2)
     WITH ROW 4 OVERLAY SIDE-LABELS TITLE glb_tldatela WIDTH 80 FRAME f_blqrgt.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_blqrgt.
        LEAVE.
   
    END.  /*  Fim do DO WHILE TRUE  */
   
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "BLQRGT"   THEN
                DO:
                    HIDE FRAME f_blqrgt.
                    RETURN.
                END.
            ELSE
                NEXT.
         END.
   
    IF   aux_cddopcao <> glb_cddopcao THEN
         DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
         END.
   
    ASSIGN glb_cdcritic = 0
           tel_nrdconta = 0
           tel_tpaplica = 0
           tel_nraplica = 0
           tel_nmaplica = "".
   
    DO WHILE TRUE:

        ASSIGN aux_cdprodut = 0
               aux_idtipapl = "".
               
        UPDATE tel_nrdconta tel_nmaplica tel_nraplica WITH FRAME f_blqrgt
        EDITING:

            READKEY.

            IF  LASTKEY = KEYCODE("F7")  THEN
                DO:
                    /* Verificacao se o campo que está sendo editado
                       é o "tel_nraplica" */
                    IF  FRAME-FIELD = "tel_nraplica" THEN
                        DO:
                            
                            RUN fontes/zoom_aplic_blqrgt.p 
                                ( INPUT glb_cdcooper,
                                  INPUT 0, /* cdagenci */
                                  INPUT 0, /* nrdcaixa */
                                  INPUT glb_cdoperad,
                                  INPUT glb_cdprogra,
                                  INPUT INPUT tel_nrdconta,
                                  INPUT tel_tpaplica,
                                  INPUT glb_cddopcao,
                                  INPUT aux_idtipapl,
                                 OUTPUT aux_nraplicx ).
        
                            IF  aux_nraplicx > 0   THEN
                                DO:
                                    ASSIGN tel_nraplica = aux_nraplicx.
                                    DISPLAY tel_nraplica WITH FRAME f_blqrgt.
                                END.
                        END. /* Campo Nr Aplicacao */

                    /* Verificacao se o campo que está sendo editado
                       é o "tel_tpaplica" */
                    IF  FRAME-FIELD = "tel_nmaplica" THEN
                        DO:
                            RUN fontes/zoom_prod_aplic.p 
                                ( INPUT glb_cdcooper,
                                  INPUT 0, /* cdagenci */
                                  INPUT 0, /* nrdcaixa */
                                  INPUT glb_cdoperad,
                                  INPUT glb_cdprogra,
                                  INPUT INPUT tel_nrdconta,
                                 OUTPUT aux_cdprodut,
                                 OUTPUT aux_nmprodut,
                                 OUTPUT aux_idtipapl).
                            
                            IF aux_cdprodut > 0   THEN
                              DO:
                                ASSIGN tel_nmaplica = aux_nmprodut
                                       tel_tpaplica = aux_cdprodut. 

                                DISPLAY tel_nmaplica WITH FRAME f_blqrgt.
                              END.
                        END. /* Campo Nr Aplicacao */
                END. /* F7 */

                IF FRAME-FIELD = "tel_nmaplica" THEN
                  DO:
                    IF LASTKEY = KEYCODE("F7")            OR 
                       LASTKEY = KEYCODE("END-ERROR")     OR
                       LASTKEY = KEYCODE("CURSOR-DOWN")   OR
                       LASTKEY = KEYCODE("CURSOR-UP")     OR
                       LASTKEY = KEYCODE("CURSOR-LEFT")   OR
                       LASTKEY = KEYCODE("CURSOR-RIGHT")  OR
                       LASTKEY = KEYCODE("RETURN")        OR
                       LASTKEY = KEYCODE("BACK-TAB")      OR
                       LASTKEY = KEYCODE("TAB")           OR
                       LASTKEY = KEYCODE("GO")
                       THEN
                      APPLY LASTKEY.
                  END.
                ELSE
                  APPLY LASTKEY.

        END.  /*  Fim do EDITING  */
        
        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    IF  glb_cddopcao = "C" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0148.p 
                 PERSISTENT SET h-b1wgen0148.
                     
            RUN busca-blqrgt IN h-b1wgen0148 (INPUT glb_cdcooper,
                                              INPUT 0, /* Agencia*/
                                              INPUT 0, /* Caixa  */
                                              INPUT glb_cdoperad,
                                              INPUT tel_nrdconta,
                                              INPUT tel_tpaplica,
                                              INPUT tel_nraplica,
                                              INPUT glb_dtmvtolt,
                                              INPUT aux_idtipapl,
                                              OUTPUT tel_flgstapl,
                                              OUTPUT TABLE tt-erro).
                 
            DELETE PROCEDURE h-b1wgen0148.
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF AVAILABLE tt-erro  THEN
                      MESSAGE tt-erro.dscritic.
                    
                    NEXT.
                END.
            
             IF  tel_flgstapl THEN
                 MESSAGE "Aplicacao liberada!".
             ELSE
                 MESSAGE "Aplicacao bloqueada.".
   
   
             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "B" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0148.p 
                PERSISTENT SET h-b1wgen0148.
                     
            RUN bloqueia-blqrgt IN h-b1wgen0148 (INPUT glb_cdcooper,
                                                 INPUT 0, /* Agencia*/
                                                 INPUT 0, /* Caixa  */
                                                 INPUT glb_cdoperad,
                                                 INPUT tel_nrdconta,
                                                 INPUT tel_tpaplica,
                                                 INPUT tel_nraplica,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT TRUE /* LOG */,
                                                 INPUT aux_idtipapl,
                                                 INPUT aux_nmprodut,
                                                 OUTPUT TABLE tt-erro).
                                       
            DELETE PROCEDURE h-b1wgen0148.
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
   
                    NEXT.
                END.
             ELSE
                MESSAGE "Aplicacao bloqueada com sucesso.".
   
             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */

                 NEXT.
         END.
    ELSE
    IF  glb_cddopcao = "L" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0148.p 
                PERSISTENT SET h-b1wgen0148.
                     
            RUN libera-blqrgt IN h-b1wgen0148 (INPUT glb_cdcooper,
                                               INPUT 0, /* Agencia*/
                                               INPUT 0, /* Caixa  */
                                               INPUT glb_cdoperad,
                                               INPUT tel_nrdconta,
                                               INPUT tel_tpaplica,
                                               INPUT tel_nraplica,
                                               INPUT glb_dtmvtolt,
                                               INPUT TRUE /* LOG */,
                                               INPUT aux_idtipapl,
                                               INPUT aux_nmprodut,
                                               OUTPUT TABLE tt-erro).
                                       
            DELETE PROCEDURE h-b1wgen0148.
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
   
                    NEXT.
                END.
            ELSE
                MESSAGE "Aplicacao liberada com sucesso.".
   
           IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
               NEXT.
        END.
   
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
