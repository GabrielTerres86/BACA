

/* .............................................................................

   Programa: Fontes/verige.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Dezembro/2012                   Ultima atualizacao: 25/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar contas participantes do Grupo economico.
    
   Alteracoes: 18/04/2013 - Ajuste para a incluisao do paramentro "PAC" na 
                            opcao "R"  (Adriano).
               
               06/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               18/11/2013 - Passando instrucoes de leitura e gravacao de dados
                            da tela verige p/ BO p/ conversao web (Carlos)

               13/01/2014 - Alterada critica "015 - Agencia nao cadastrada."
                            para "962 - PA nao cadastrado." (Reinert)     
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               25/06/2014 - Inclusao do uso da temp-table tt-grupo na b1wgen0138tt.
                            (Chamado 130880) - (Tiago Castro - RKAM)
 ............................................................................*/
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }   
{ sistema/generico/includes/b1wgen0138tt.i }  

DEF STREAM str_1.

DEF VAR rel_nmempres AS CHAR                                           NO-UNDO. 
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                             NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5                NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmendter    AS CHAR FORMAT "x(20)"                         NO-UNDO.
DEF VAR par_flgrodar    AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR aux_flgescra    AS LOGI                                        NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                        NO-UNDO.
DEF VAR par_flgfirst    AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR tel_dsimprim    AS CHAR FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel    AS CHAR FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF VAR par_flgcance    AS LOGI                                        NO-UNDO.
DEF VAR aux_contador    AS INT                                         NO-UNDO.

DEF VAR tel_nrdconta AS INTE    FORMAT "zzzz,zzz,9"                    NO-UNDO.
DEF VAR tel_dsdrisgp AS CHAR    FORMAT "X(2)"                          NO-UNDO.
DEF VAR tel_vlendivi AS DEC     FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_cdagenci AS INT     FORMAT "zz9"                           NO-UNDO.
                                                                     
DEF VAR aux_stimeout AS INT                                            NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdgrupo AS INTE                                           NO-UNDO.
DEF VAR aux_gergrupo AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdrisgp AS CHAR                                           NO-UNDO.
DEF VAR aux_pertengp AS LOGI                                           NO-UNDO.
DEF VAR h-b1wgen0138 AS HANDLE                                         NO-UNDO.
                                                                     
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C ou R)"
                        VALIDATE (glb_cddopcao = "C" OR glb_cddopcao = "R",
                                    "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_nrdconta LABEL "Conta/Dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar"
     WITH WIDTH 30 ROW 6 COLUMN 15 OVERLAY SIDE-LABELS NO-BOX FRAME f_conta.

FORM tel_cdagenci LABEL "PA" AUTO-RETURN
                  HELP "Informe o numero do PA."
                  VALIDATE (CAN-FIND(crapage WHERE
                                     crapage.cdcooper = glb_cdcooper AND
                                     crapage.cdagenci = tel_cdagenci  
                                     NO-LOCK),
                 "962 - PA nao cadastrado.")
     WITH WIDTH 30 ROW 6 COLUMN 50 OVERLAY SIDE-LABELS NO-BOX FRAME f_pac.

DEF QUERY q-grupo FOR tt-grupo.
    
DEF BROWSE b-grupo QUERY q-grupo
    DISPLAY tt-grupo.cdagenci     FORMAT "zz9"
                                            LABEL "PA"
            tt-grupo.nrctasoc     FORMAT "zzzz,zzz,9"
                                            LABEL "Conta"
            tt-grupo.nrcpfcgc               LABEL "CNPJ/CPF"
            SPACE(3)
            tt-grupo.dsdrisco     LABEL "Risco"
            SPACE(8)
            tt-grupo.vlendivi     FORMAT "zzzzzz,zz9.99-"
                                            LABEL "Endividamento"
            SPACE(8)
    WITH 5 DOWN NO-LABELS OVERLAY NO-BOX.

FORM SKIP(1)
     b-grupo
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 8 NO-LABELS CENTERED OVERLAY TITLE " Grupo Economico " 
                                 FRAME f_browse_grupo.

FORM SKIP(2) 
     "Risco do Grupo:"  AT 04
     tel_dsdrisgp
     "Endividamento do Grupo:" AT 36
     tel_vlendivi
     WITH ROW 18 COLUMN 3 OVERLAY NO-BOX NO-LABELS WIDTH 76 FRAME f_endivid.

FORM SKIP(2) 
     "Risco do Grupo:"  AT 04
     tt-grupo.dsdrisgp
     "Endividamento do Grupo:" AT 36
     tt-grupo.vlendigp
     WITH ROW 18 COLUMN 3 OVERLAY NO-BOX NO-LABELS WIDTH 76 FRAME f_endivid2.

FORM tt-grupo.cdagenci COLUMN-LABEL "PA"    
     tt-grupo.nrdgrupo COLUMN-LABEL "Grupo"
     tt-grupo.nrctasoc COLUMN-LABEL "Conta"
     tt-grupo.nrcpfcgc COLUMN-LABEL "CNPJ/CPF"       
     tt-grupo.vlendivi COLUMN-LABEL "Endividamento" FORMAT "zzz,zzz,zzz,zz9.99" 
     tt-grupo.dsdrisco COLUMN-LABEL "Risco"  
     tt-grupo.vlendigp COLUMN-LABEL "Endividamento do Grupo" 
                                    FORMAT "zzz,zzz,zzz,zz9.99"
     tt-grupo.dsdrisgp COLUMN-LABEL "Risco do Grupo"
     WITH DOWN WIDTH 132 NO-BOX FRAME f_grupo_3.


VIEW FRAME f_moldura.

PAUSE(0).

Inicio:
DO WHILE TRUE:
    
   ASSIGN glb_cddopcao = "C"
          glb_cdrelato[1] = 631
          tel_nrdconta = 0
          tel_cdagenci = 0
          glb_cdcritic = 0
          glb_dscritic = "".

   { includes/cabrel132_1.i }
   
   HIDE FRAME f_conta
        FRAME f_pac.

   CLEAR FRAME f_conta NO-PAUSE.
   CLEAR FRAME f_pac NO-PAUSE.

   NEXT-PROMPT glb_cddopcao WITH FRAME f_opcao.

   RUN fontes/inicia.p.


   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      EMPTY TEMP-TABLE tt-grupo.
      EMPTY TEMP-TABLE tt-erro.
                               
      UPDATE glb_cddopcao 
             WITH FRAME f_opcao.

      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.

          IF glb_nmdatela <> "VERIGE"   THEN
             DO:
                HIDE FRAME f_grupo.
                HIDE FRAME f_moldura.
                RETURN.
             END.
          ELSE
             NEXT.

      END.

   IF aux_cddopcao <> glb_cddopcao   THEN
      DO:
          { includes/acesso.i }
          aux_cddopcao = glb_cddopcao.

      END.


   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta 
             WITH FRAME f_conta

      EDITING:

         ASSIGN aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF LASTKEY = -1   THEN
               DO:
                   ASSIGN aux_stimeout = aux_stimeout + 1.

                   IF aux_stimeout > glb_stimeout   THEN
                      QUIT.

                   NEXT.
               END.
               
               
            IF LASTKEY = KEYCODE("F7") THEN
               DO:
                  RUN fontes/zoom_associados.p (INPUT glb_cdcooper,
                                               OUTPUT tel_nrdconta).

                  IF tel_nrdconta > 0   THEN
                     DO:
                         DISPLAY tel_nrdconta WITH FRAME f_conta.
                         PAUSE 0.
                         APPLY "RETURN".

                     END.
               END.
            ELSE
               APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      IF tel_nrdconta <> 0  THEN
         DO:
            ASSIGN glb_nrcalcul = tel_nrdconta.
            
            RUN fontes/digfun.p.
            
            IF NOT glb_stsnrcal   THEN
               DO:
                   ASSIGN glb_cdcritic = 8.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   CLEAR FRAME f_grupo NO-PAUSE.
                   NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
                   NEXT.
            
               END.

         END.

      LEAVE.

   END.  /*  Fim do WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
      NEXT.


   IF glb_cddopcao = "C" THEN
      DO:
         IF NOT VALID-HANDLE(h-b1wgen0138) THEN
            RUN sistema/generico/procedures/b1wgen0138.p 
                PERSISTENT SET h-b1wgen0138.

         ASSIGN aux_pertengp =  DYNAMIC-FUNCTION("busca_grupo" 
                                              IN h-b1wgen0138,
                                              INPUT  glb_cdcooper, 
                                              INPUT  tel_nrdconta, 
                                              OUTPUT aux_nrdgrupo,
                                              OUTPUT aux_gergrupo, 
                                              OUTPUT aux_dsdrisgp).

         IF VALID-HANDLE(h-b1wgen0138) THEN
            DELETE OBJECT h-b1wgen0138.
         
         /*Esta sendo feito a formacao do grupo economico*/
         IF aux_gergrupo <> "" THEN
            DO: 
               MESSAGE aux_gergrupo.
               HIDE MESSAGE.
         
            END.
      
         /*Conta faz parte de um grupo economico*/
         IF aux_pertengp THEN
            DO:
                IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                   RUN sistema/generico/procedures/b1wgen0138.p
                       PERSISTENT SET h-b1wgen0138.

                /* Procedure responsavel para calcular o endividamento 
                  do grupo */
                RUN calc_endivid_grupo IN h-b1wgen0138
                                      (INPUT glb_cdcooper,
                                       INPUT glb_cdagenci, 
                                       INPUT 0, 
                                       INPUT glb_cdoperad, 
                                       INPUT glb_dtmvtolt, 
                                       INPUT glb_nmdatela, 
                                       INPUT 1, 
                                       INPUT aux_nrdgrupo, 
                                       INPUT TRUE, /*Consulta por conta*/
                                      OUTPUT tel_dsdrisgp, 
                                      OUTPUT tel_vlendivi,
                                      OUTPUT TABLE tt-grupo,
                                      OUTPUT TABLE tt-erro).

                IF VALID-HANDLE(h-b1wgen0138) THEN
                   DELETE OBJECT h-b1wgen0138.
                
                IF RETURN-VALUE <> "OK"  THEN
                   DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                      
                      IF AVAILABLE tt-erro  THEN
                         ASSIGN glb_dscritic = tt-erro.dscritic.
                      ELSE
                         ASSIGN glb_dscritic = "Erro no carregamento " +
                                               "do Grupo Economico.".
                             
                      BELL.
                      MESSAGE glb_dscritic.
                      NEXT.
                           
                   END.
              
                IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                   DO:
                       DISP tel_vlendivi
                            tel_dsdrisgp
                            WITH FRAME f_endivid.

                       PAUSE 0.
          
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           
                           
                           
                          OPEN QUERY q-grupo 
                               FOR EACH tt-grupo NO-LOCK 
                                        BY tt-grupo.cdagenci
                                         BY tt-grupo.nrctasoc.

                          UPDATE b-grupo
                                 WITH FRAME f_browse_grupo.
                           
                          LEAVE.
                
                       END.
                       
                       CLOSE QUERY q-grupo.
                       HIDE FRAME f_browse_grupo.
                       HIDE FRAME f_endivid.

                   
                   END. 

            END.
         ELSE /*Conta nao faz parte de um grupo economico*/ 
            DO:
               BELL.
               MESSAGE "Cooperado nao faz parte de nenhum grupo economico.".
               PAUSE 3 NO-MESSAGE.
               HIDE MESSAGE.
               NEXT.
          
            END.

      END. /*fim da opcao C */
   ELSE
   IF glb_cddopcao = "R" THEN
       DO:
          IF NOT VALID-HANDLE(h-b1wgen0138) THEN
             RUN sistema/generico/procedures/b1wgen0138.p
                 PERSISTENT SET h-b1wgen0138.

          ASSIGN aux_pertengp = DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                 INPUT  glb_cdcooper, 
                                                 INPUT  tel_nrdconta, 
                                                 OUTPUT aux_nrdgrupo,
                                                 OUTPUT aux_gergrupo, 
                                                 OUTPUT aux_dsdrisgp).

          IF VALID-HANDLE(h-b1wgen0138) THEN
             DELETE OBJECT h-b1wgen0138.
          
          /*Esta sendo feito a formacao do grupo economico*/
          IF aux_gergrupo <> "" THEN
             DO:
                MESSAGE aux_gergrupo.
                HIDE MESSAGE.
          
             END.

          IF tel_nrdconta = 0 THEN
             DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   UPDATE tel_cdagenci
                          WITH FRAME f_pac.

                   LEAVE.

                END.

                IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                   NEXT.

                BELL.
                MESSAGE "Gerando relatorio...".

                IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                   RUN sistema/generico/procedures/b1wgen0138.p
                       PERSISTENT SET h-b1wgen0138.

                INPUT THROUGH basename `tty` NO-ECHO.
                SET aux_nmendter WITH FRAME f_terminal.
                INPUT CLOSE.
                
                aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                      aux_nmendter.

                RUN relatorio_gp IN h-b1wgen0138
                                    (INPUT  glb_cdcooper,
                                     INPUT  tel_cdagenci,
                                     INPUT  0, 
                                     INPUT  glb_cdoperad, 
                                     INPUT  glb_nmdatela,
                                     INPUT  1,
                                     INPUT  glb_dtmvtolt,
                                     INPUT  aux_nmendter,
                                     INPUT  glb_cdrelato[1],
                                     INPUT  aux_nrdgrupo,
                                     INPUT  TRUE,
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT tel_dsdrisgp, 
                                     OUTPUT tel_vlendivi,
                                     OUTPUT TABLE tt-grupo APPEND,
                                     OUTPUT TABLE tt-erro).

                IF RETURN-VALUE <> "OK"  THEN
                    DO: 
                        IF VALID-HANDLE(h-b1wgen0138) THEN
                           DELETE PROCEDURE h-b1wgen0138.
    
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                        BELL.
                        HIDE MESSAGE NO-PAUSE.

                        IF AVAILABLE tt-erro  THEN
                           MESSAGE tt-erro.dscritic.
                        ELSE
                           MESSAGE "Erro no calculo do " +
                                   "endividamento.".

                        PAUSE(3) NO-MESSAGE.
                        NEXT Inicio.
                             
                    END.
                                
                HIDE MESSAGE NO-PAUSE.

                IF VALID-HANDLE(h-b1wgen0138) THEN
                   DELETE PROCEDURE h-b1wgen0138.

             END.
          ELSE
             IF aux_pertengp THEN /*Conta faz parte de um grupo economico*/
                DO:
                    BELL.
                    MESSAGE "Gerando relatorio...".

                    IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                       RUN sistema/generico/procedures/b1wgen0138.p
                           PERSISTENT SET h-b1wgen0138.

                    INPUT THROUGH basename `tty` NO-ECHO.
                    SET aux_nmendter WITH FRAME f_terminal.
                    INPUT CLOSE.
                    
                    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                          aux_nmendter.

                    RUN relatorio_gp IN h-b1wgen0138
                                    (INPUT  glb_cdcooper,
                                     INPUT  glb_cdagenci,
                                     INPUT  0, 
                                     INPUT  glb_cdoperad, 
                                     INPUT  glb_nmdatela,
                                     INPUT  1,
                                     INPUT  glb_dtmvtolt,
                                     INPUT  aux_nmendter,
                                     INPUT  glb_cdrelato[1],
                                     INPUT  aux_nrdgrupo,
                                     INPUT  FALSE,         /* par_infoagen */
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT tel_dsdrisgp, 
                                     OUTPUT tel_vlendivi,
                                     OUTPUT TABLE tt-grupo APPEND,
                                     OUTPUT TABLE tt-erro).

                    IF VALID-HANDLE(h-b1wgen0138) THEN
                        DELETE OBJECT h-b1wgen0138.

                    IF RETURN-VALUE <> "OK"  THEN
                       DO:
                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                          
                          BELL.
                          HIDE MESSAGE NO-PAUSE.

                          IF  AVAILABLE tt-erro  THEN
                              MESSAGE tt-erro.dscritic.
                          ELSE
                              MESSAGE "Erro no calculo do " +
                                     "endividamento.".
                          NEXT.
                               
                       END.

                    HIDE MESSAGE NO-PAUSE.

                END.
             ELSE /*Conta nao faz parte de um grupo economico*/
                DO:
                   BELL.
                   HIDE MESSAGE NO-PAUSE.
                   MESSAGE "Cooperado nao faz parte de nenhum grupo economico.".
                   PAUSE 3 NO-MESSAGE.
                   NEXT.

                END.

          /*Gera impressao*/
          /* se aux_nmarqimp tiver valor, chamar impressao.i */
          IF  aux_nmarqimp <> "" THEN
              DO:

                  FIND FIRST crapass
                       WHERE crapass.cdcooper = glb_cdcooper
                            NO-LOCK NO-ERROR. 

                  { includes/impressao.i }

                  UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2>/dev/null").

              END.
          ELSE 
              IF  tel_nrdconta = 0 THEN
                  DO:
                      BELL.
                      HIDE MESSAGE NO-PAUSE.
                      MESSAGE "Nenhum grupo encontrado.".
                      PAUSE 2 NO-MESSAGE.
                      HIDE MESSAGE.
                  END.

       END. /*** fim opcao R ***/


END. /*** fim do DO WHILE TRUE ***/




