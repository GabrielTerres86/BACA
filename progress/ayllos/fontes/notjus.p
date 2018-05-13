/* .............................................................................

   Programa: Fontes/notjus.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/94.                        Ultima atualizacao: 19/11/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela NOTJUS - Manutencao de Notificacao e Justificacao.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               18/06/2002 - Alimentar o campo crapneg.cdoperad (Edson).
               
               08/06/2004 - Mostrar registros com cdhisest=1 e cdobserv=21     
                            (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela crapneg (Diego).
               
               07/10/2005 - Alterado para ler tbm na tabela crapali o codigo
                            da cooperativa (Diego).
 
              02/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
              
              06/02/2006 - Inclusao da opcao USE-INDEX na pesquisa da tabela
                           crapneg - SQLWorks - Andre
                           
              12/02/2007 - Efetuada alteracao para nova estrutura crapneg
                           (Diego).
                           
              11/02/2011 - Tratamento campo crapass.nmprimtl p/ 50 posicoes
                           (Diego).     
                           
              16/01/2013 - Alteracoes no fonte para ultilizacao da b1wgen0146
                           usada tambem na web (David Kruger).
                           
              19/11/2013 - Ajustes para homologação (Adriano)             
                           
............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0146tt.i }

DEF VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"                  NO-UNDO.
DEF VAR tel_nrseqdig AS INT     FORMAT "zzz9"                        NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR    FORMAT "x(50)"                       NO-UNDO.
DEF VAR tel_dsobserv AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR tel_dshisest AS CHAR    FORMAT "x(15)"                       NO-UNDO.
                                                               
DEF VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"                  NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.
                                                               
DEF VAR aux_confirma AS CHAR    FORMAT "x(1)"                        NO-UNDO.
DEF VAR aux_flgretor AS LOGICAL                                      NO-UNDO.
DEF VAR aux_regexist AS LOGICAL                                      NO-UNDO.
                                                               
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.

DEF VAR h-b1wgen0146 AS HANDLE                                       NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta     LABEL "Conta/dv" AUTO-RETURN
                      HELP "Entre com o numero da conta do associado."
     tel_nmprimtl     LABEL "Nome"
     SKIP(1)
     "Seq.   Inicio    Dias  Historico" AT  3
     " Valor do Estouro  Observacoes"   AT 43
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_notjus.

FORM tt-estouro.nrseqdig AT  3 FORMAT "zzz9"
     tt-estouro.dtiniest AT 08 FORMAT "99/99/9999"
     tt-estouro.qtdiaest AT 20
     tt-estouro.dshisest AT 26
     tt-estouro.vlestour AT 43 FORMAT "zzzzzz,zzz,zz9.99"
     tt-estouro.dsobserv AT 62
     WITH ROW 10 COLUMN 2 NO-BOX NO-LABELS 11 DOWN OVERLAY FRAME f_lanctos.

FORM SKIP(1)
     "Opcao    Sequencia" AT 3
     SKIP(1)
     glb_cddopcao AT  5 AUTO-RETURN
                        HELP "Informe a opcao desejada (E, J ou N)"
                        VALIDATE(CAN-DO("E,J,N",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_nrseqdig AT 15 AUTO-RETURN
                        HELP "Entre com a sequencia desejada."
     SKIP(1)
     WITH ROW 11 NO-LABELS CENTERED WIDTH 25 OVERLAY FRAME f_notifica.

VIEW FRAME f_moldura.

PAUSE(0).

IF NOT VALID-HANDLE(h-b1wgen0146) THEN
   RUN sistema/generico/procedures/b1wgen0146.p PERSISTENT SET h-b1wgen0146.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN glb_cdcritic = 0
          glb_cddopcao = "C"
          tel_nrdconta = 0
          tel_nmprimtl = "".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             CLEAR FRAME f_notjus NO-PAUSE.
             CLEAR FRAME f_lanctos ALL NO-PAUSE.
             ASSIGN glb_cdcritic = 0.

         END.

      UPDATE tel_nrdconta 
             WITH FRAME f_notjus.

      ASSIGN glb_nrcalcul = tel_nrdconta.

      RUN fontes/digfun.p.

      IF NOT glb_stsnrcal THEN
         DO:
             ASSIGN glb_cdcritic = 8.
             NEXT.

         END.

      EMPTY TEMP-TABLE tt-erro.
       
      RUN busca_associado IN h-b1wgen0146(INPUT glb_cdcooper,
                                          INPUT glb_cdagenci,
                                          INPUT 0, /*nrdcaixa*/
                                          INPUT glb_cdoperad,
                                          INPUT glb_nmdatela,
                                          INPUT 1, /*ayllos*/
                                          INPUT glb_dtmvtolt,
                                          INPUT glb_cddopcao,
                                          INPUT tel_nrdconta,
                                          OUTPUT aux_nmdcampo,
                                          OUTPUT tel_nmprimtl,
                                          OUTPUT TABLE tt-erro).
         
      IF RETURN-VALUE <> "OK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF AVAIL tt-erro THEN
               DO: 
                  MESSAGE tt-erro.dscritic.
                  {sistema/generico/includes/foco_campo.i
                      &VAR-GERAL="sim"
                      &NOME-FRAME="f_notjus"
                      &NOME-CAMPO=aux_nmdcampo}
         
               END.
            ELSE
               MESSAGE "Nao foi possivel realizar a consulta.".
         
            PAUSE(2)NO-MESSAGE.
            HIDE MESSAGE.
            NEXT.
                  
         END.   

      DISPLAY tel_nmprimtl 
              WITH FRAME f_notjus.

      CLEAR FRAME f_lanctos ALL NO-PAUSE.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    /*   F4 OU FIM   */
      DO:
         RUN fontes/novatela.p.

         IF glb_nmdatela <> "NOTJUS" THEN
            DO:
                HIDE FRAME f_notifica.
                HIDE FRAME f_notjus.
                HIDE FRAME f_lanctos.
                HIDE FRAME f_moldura.

                IF VALID-HANDLE (h-b1wgen0146) THEN
                   DELETE PROCEDURE h-b1wgen0146.

                RETURN.

            END.
         ELSE
            NEXT.

      END.

   EMPTY TEMP-TABLE tt-erro.
   EMPTY TEMP-TABLE tt-estouro.
   
   RUN busca_estouro IN h-b1wgen0146(INPUT glb_cdcooper,
                                     INPUT glb_cdagenci,
                                     INPUT 0, /* nrdcaixa */
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1, /* AYLLOS */
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_cddopcao,
                                     INPUT tel_nrdconta,
                                     OUTPUT aux_nmdcampo,
                                     OUTPUT TABLE tt-estouro,
                                     OUTPUT TABLE tt-erro).
   
   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
         IF AVAIL tt-erro THEN
            DO: 
               MESSAGE tt-erro.dscritic.
               {sistema/generico/includes/foco_campo.i
                   &NOME-FRAME="f_notjus"
                   &NOME-CAMPO=aux_nmdcampo}
   
            END.
         ELSE
            MESSAGE "Nao foi possivel realizar a consulta.".
   
         PAUSE(2)NO-MESSAGE.
         HIDE MESSAGE.
         NEXT.
               
      END.
   
   ASSIGN aux_flgretor = FALSE
          aux_contador = 0
          tel_nrseqdig = 0.
   
   IF TEMP-TABLE tt-estouro:HAS-RECORDS THEN
      DO:
         FOR EACH tt-estouro NO-LOCK:     
                          
             ASSIGN aux_regexist = TRUE
                    aux_contador = aux_contador + 1.
      
             IF aux_contador = 1 THEN
                IF aux_flgretor THEN
                   DO:
                      PAUSE MESSAGE
                      "Tecle <Entra> para continuar ou <Fim> para encerrar".
                      CLEAR FRAME f_lanctos ALL NO-PAUSE.
                      ASSIGN aux_flgretor = FALSE.
   
                   END.
             
             DISP tt-estouro.nrseqdig 
                  tt-estouro.dtiniest 
                  tt-estouro.qtdiaest 
                  tt-estouro.vlestour 
                  tt-estouro.dshisest 
                  tt-estouro.dsobserv
                  WITH FRAME f_lanctos.
      
             IF aux_contador = 11 THEN
                ASSIGN aux_contador = 0
                       aux_flgretor = TRUE.
             ELSE
                DOWN WITH FRAME f_lanctos.
      
         END.  /*  Fim do FOR EACH   */ 
      END.
   ELSE 
      DO:
         ASSIGN glb_cdcritic = 413.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_lanctos ALL NO-PAUSE.
         ASSIGN glb_cdcritic = 0.
         NEXT.
   
      END.   
   
   PAUSE(0).
   
   ASSIGN glb_cddopcao = "N".
   
   OPCOES:
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0.
   
         END.
      ELSE
         ASSIGN tel_nrseqdig = 0.
   
      UPDATE glb_cddopcao 
             tel_nrseqdig
             WITH FRAME f_notifica.
   
      IF aux_cddopcao <> glb_cddopcao THEN
         DO:
             { includes/acesso.i }
             ASSIGN aux_cddopcao = glb_cddopcao.
         END.
   
      IF glb_cddopcao = "E" THEN
         DO:  
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.
   
               RUN fontes/critic.p.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               ASSIGN glb_cdcritic = 0.
               LEAVE.
            
            END.
             
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma <> "S"                THEN
               DO:
                  ASSIGN glb_cdcritic = 79.
                  NEXT OPCOES.
   
               END.
            
            EMPTY TEMP-TABLE tt-erro.
            
            RUN exclui_registro IN h-b1wgen0146(INPUT glb_cdcooper,
                                                INPUT glb_cdagenci,
                                                INPUT 0, /* nrdcaixa */
                                                INPUT glb_cdoperad,
                                                INPUT glb_nmdatela,
                                                INPUT 1, /* AYLLOS */
                                                INPUT glb_dtmvtolt,
                                                INPUT glb_cddopcao,
                                                INPUT tel_nrdconta,
                                                INPUT tel_nrseqdig,
                                                OUTPUT aux_nmdcampo,
                                                OUTPUT TABLE tt-erro).
            
            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                  IF AVAIL tt-erro THEN
                     MESSAGE tt-erro.dscritic.
                  ELSE
                     MESSAGE "Nao foi possivel deletar o registro.".
            
                  PAUSE(2)NO-MESSAGE.
                  HIDE MESSAGE.
                  NEXT OPCOES.
            
               END.
            
         END.
      ELSE
         IF glb_cddopcao = "J" THEN
            DO: 
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                   ASSIGN aux_confirma = "N"
                          glb_cdcritic = 78.
   
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                   ASSIGN glb_cdcritic = 0.
                   LEAVE.
   
                END.
                
                IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                   aux_confirma <> "S"                THEN
                   DO:
                      ASSIGN glb_cdcritic = 79.
                      NEXT OPCOES.
   
                   END.
   
                EMPTY TEMP-TABLE tt-erro.
   
                RUN justifica_estouro IN h-b1wgen0146(INPUT glb_cdcooper,
                                                      INPUT glb_cdagenci,
                                                      INPUT 0, /* nrdcaixa */
                                                      INPUT glb_cdoperad,
                                                      INPUT glb_nmdatela,
                                                      INPUT 1, /* AYLLOS */
                                                      INPUT glb_dtmvtolt,
                                                      INPUT glb_cddopcao,
                                                      INPUT tel_nrdconta,
                                                      INPUT tel_nrseqdig,
                                                      OUTPUT aux_nmdcampo,
                                                      OUTPUT TABLE tt-erro).
   
                IF RETURN-VALUE <> "OK" THEN
                   DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                      IF AVAIL tt-erro THEN
                         MESSAGE tt-erro.dscritic.
                      ELSE
                         MESSAGE "Nao foi possivel alterar o registro.".
                
                      PAUSE(2)NO-MESSAGE.
                      HIDE MESSAGE.
                      NEXT OPCOES.
                
                   END.
                
            END.
      ELSE
         IF glb_cddopcao = "N" THEN
            DO: 
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
   
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  ASSIGN glb_cdcritic = 0.
                  LEAVE.
   
               END.
               
               IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                  aux_confirma <> "S"                THEN
                  DO:
                     ASSIGN glb_cdcritic = 79.
                     NEXT OPCOES.
   
                  END.
   
               EMPTY TEMP-TABLE tt-erro.
   
               RUN cria_notificacao IN h-b1wgen0146(INPUT glb_cdcooper,
                                                    INPUT glb_cdagenci,
                                                    INPUT 0, /* nrdcaixa */
                                                    INPUT glb_cdoperad,
                                                    INPUT glb_nmdatela,
                                                    INPUT 1, /* AYLLOS */
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_cddopcao,
                                                    INPUT tel_nrdconta,
                                                    OUTPUT aux_nmdcampo,
                                                    OUTPUT TABLE tt-erro).
   
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                        MESSAGE "Nao foi possivel criar o registro.".
               
                     PAUSE(2)NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT OPCOES.
               
                  END.
              
            END.
   
      LEAVE OPCOES.
      
   END.  /*  Fim do DO WHILE TRUE  */
   
   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN   /*  F4 OU FIM  */
      HIDE FRAME f_notifica.
   ELSE
      DO:
        CLEAR FRAME f_notjus NO-PAUSE.
        HIDE FRAME f_lanctos.
        HIDE FRAME f_notifica.
      END.

END.  /*  Fim do DO WHILE TRUE  */


/* .......................................................................... */
