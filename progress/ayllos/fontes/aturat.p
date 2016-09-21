/*............................................................................

  Programa: Fontes/aturat.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Novembro/2009                       Ultima Atualizacao: 29/05/2015

  Dados referentes ao programa:

  Frequencia: Diario (on-line).
  Objetivo  : Mostrar a tela ATURAT, Ratings dos cooperados.
  
  Alteracoes: 08/03/2010 - Implementar opcao 'S' da tela (Gabriel).
  
              18/03/2011 - Incluido opcao 'L' - Risco Cooperado
                         - Incluido Risco e nota cooperado nas opcoes "C,A,R"
                         (Guilherme).
                         
              14/04/2011 - Incluido a temp-table tt-impressao-risco-tl como
                           parametro de saida da procedure atualiza_rating,
                           para atualizar a crapass. (Fabricio)
                           
              13/09/2011 - Alterações para Rating da Central (Guilherme).
              
              09/11/2011 - Alterações para Rating da Central (Adriano).

              15/02/2012 - Alteracao da msg O risco efetivado para a C. de Risco (Rosangela) 
  
              03/07/2012 - Alteração CDOPERAD de INTE para CHAR (Lucas R.).
              
              18/10/2012 - Alterado o format do campo 'bb-ratings.vloperac'
                           do browse 'b-ratings' (Lucas).
              
              10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
              03/01/2014 - Trocar critica 15 Agencia nao cadastrada por 
                           962 PA nao cadastrado (Reinert)
                           
              29/05/2015 - Remover a opcao "S", atualizacao do risco sera
                           no crps310_i. (James)
  ..........................................................................*/
  
{ includes/var_online.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0043tt.i }

DEF STREAM str_1.

/* Variaveis de tela */
DEF VAR tel_nrdconta AS INTE                                  NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR                                  NO-UNDO.
DEF VAR tel_cdagenci AS INTE                                  NO-UNDO.
DEF VAR tel_dtinirat AS DATE                                  NO-UNDO.
DEF VAR tel_dtfinrat AS DATE                                  NO-UNDO.
DEF VAR tel_nrctremp AS INTE                                  NO-UNDO.
DEF VAR tel_inrisctl AS CHAR                                  NO-UNDO.

DEF VAR tel_dsrelato AS CHAR EXTENT 6 INIT
                             ["367 - Rating Associado    ", 
                              "539 - Ratings Cadastrados "]   NO-UNDO.         

/* BO do RATING */
DEF VAR h-b1wgen0043 AS HANDLE                                NO-UNDO.

/* Variaveis auxiliares*/
DEF VAR aux_confirma AS CHAR  FORMAT "!(1)"                   NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF VAR aux_dsmessag AS CHAR                                  NO-UNDO.
DEF VAR aux_indrisco AS CHAR                                  NO-UNDO.
DEF VAR aux_nrnotrat AS DECI                                  NO-UNDO.
DEF VAR aux_rowidnrc AS ROWID                                 NO-UNDO.
DEF VAR aux_dsrelato AS CHAR                                  NO-UNDO.
DEF VAR aux_notacoop AS DECI                                  NO-UNDO.
DEF VAR aux_vlutiliz AS DECI                                  NO-UNDO.

/* Cabecalho */
DEF VAR rel_nmempres AS CHAR                                     NO-UNDO.
DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.

DEF VAR rel_nrmodulo AS INT   FORMAT "9"                         NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5

                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                 NO-UNDO.

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                     NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                     NO-UNDO.
DEF VAR par_flgcance AS LOGI                                     NO-UNDO.
DEF VAR aux_contador AS INTE                                     NO-UNDO.

DEFINE VARIABLE aux_nrdconta AS INTEGER     NO-UNDO.


DEF TEMP-TABLE bb-ratings LIKE tt-ratings
    FIELD dsdatual AS CHAR INIT "N".

DEF BUFFER bk-ratings FOR bb-ratings.

DEF QUERY q-ratings FOR bb-ratings.    
DEF QUERY q-riscos FOR bb-ratings.
     
DEF BROWSE b-ratings QUERY q-ratings
    DISPLAY bb-ratings.cdagenci COLUMN-LABEL "PA"         FORMAT "zz9"
            bb-ratings.nrdconta COLUMN-LABEL "Conta/dv"   FORMAT "zzzz,zzz,9"
            bb-ratings.vloperac COLUMN-LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
            bb-ratings.dsdopera COLUMN-LABEL "Tipo"       FORMAT "x(14)"
            bb-ratings.nrctrrat COLUMN-LABEL "Contrato"   FORMAT "zzzz,zz9"
            bb-ratings.dtmvtolt COLUMN-LABEL "Data"       FORMAT "99/99/99"                 
            WITH SCROLLBAR-VERTICAL 5 DOWN WIDTH 68.

DEF BROWSE b-riscos QUERY q-riscos
    DISPLAY bb-ratings.cdagenci COLUMN-LABEL "PA"             FORMAT "zz9"
            bb-ratings.nrdconta COLUMN-LABEL "Conta/dv"       FORMAT "zzzz,zzz,9"
            bb-ratings.vloperac COLUMN-LABEL "Valor"          FORMAT "zzzz,zz9.99"
            bb-ratings.nrctrrat COLUMN-LABEL "Contrato"       FORMAT "z,zzz,zz9"
            bb-ratings.indrisco COLUMN-LABEL "Risco Ope."     FORMAT "x(2)" 
            bb-ratings.dsdrisco COLUMN-LABEL "Risco Central"  FORMAT "x(2)" 
            bb-ratings.dtmvtolt COLUMN-LABEL "Data"           FORMAT "99/99/99"  
            bb-ratings.dsdatual COLUMN-LABEL "At."            FORMAT "!" 
              ENABLE bb-ratings.dsdatual AUTO-RETURN
               HELP "Informe p/ atualizar o risco da operaçao ((S)im/(N)ao/(T)odos)."
               VALIDATE (CAN-DO("S,N,T",bb-ratings.dsdatual),"014 - Opcao errada.")
            WITH SCROLLBAR-VERTICAL 8 DOWN WIDTH 78.



FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela
     FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
      HELP "Informe a opcao desejada (C,A,R,L)."
      VALIDATE (CAN-DO("C,A,R,L",glb_cddopcao), "014 - Opcao errada.")

     tel_nmprimtl NO-LABEL      AT 25 FORMAT "x(30)"

   WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao. 

FORM SKIP(1)

     tel_nrdconta LABEL "Conta/dv"  AT 03 FORMAT "zzzz,zzz,9"
      HELP "Informe o numero da conta, <F7> p/ pesquisa ou <zero> p/ todas."
                              
     tel_cdagenci LABEL "PA"        AT 26 FORMAT "zz9"
      HELP "Informe o numero do PA ou 0 <zero> p/ todos." 
      VALIDATE (CAN-FIND (crapage WHERE 
                          crapage.cdcooper = glb_cdcooper  AND
                          crapage.cdagenci = tel_cdagenci  NO-LOCK) OR
                tel_cdagenci = 0,
                "962 - PA nao cadastrado.")                        

     tel_dtinirat LABEL "Data"      AT 35 FORMAT "99/99/9999"
      HELP "Informe a data da geracao do Rating."
      VALIDATE (tel_dtinirat <= glb_dtmvtolt OR
                tel_dtinirat  = ?,
                "013 - Data errada.")                          

     tel_dtfinrat LABEL "a"         AT 53 FORMAT "99/99/9999"
      HELP "Informe a data da geracao do Rating."                        
      VALIDATE (tel_dtfinrat <= glb_dtmvtolt OR
                tel_dtfinrat  = ?,
                "013 - Data errada.")
     SKIP(1)
     tel_inrisctl LABEL "Risco Cooperado" AT 03 FORMAT "x(2)"

     WITH CENTERED NO-BOX OVERLAY ROW 7 SIDE-LABELS WIDTH 78 FRAME f_aturat.

FORM SKIP (1)

     tel_nrdconta LABEL "Conta/dv"  AT 03 FORMAT "zzzz,zzz,9"
      HELP "Informe o numero da conta, <F7> p/ pesquisa ou <zero> p/ todas."
                              
     tel_cdagenci LABEL "PA"        AT 26 FORMAT "zz9"
      HELP "Informe o numero do PA ou 0 <zero> p/ todos." 
      VALIDATE (CAN-FIND (crapage WHERE 
                          crapage.cdcooper = glb_cdcooper  AND
                          crapage.cdagenci = tel_cdagenci  NO-LOCK) OR
                tel_cdagenci = 0,
                "962 - PA nao cadastrado.") 
     
     tel_nrctremp LABEL "Contrato"  AT 35 FORMAT "zzz,zzz,zz9"
      HELP "Informe o numero do contrato ou 0 <zero> p/ todos."

     WITH CENTERED NO-BOX OVERLAY ROW 7 SIDE-LABELS 
                          
                                  WIDTH 78 FRAME f_sem_rating.


FORM b-ratings       
     
     WITH CENTERED NO-BOX OVERLAY ROW 9 WIDTH 70 FRAME f_ratings.

FORM b-riscos    
      HELP "Pressione <ENTER> p/ atualizar o risco. <F4> p/ voltar."
     
     WITH CENTERED NO-BOX OVERLAY ROW 9 WIDTH 78 FRAME f_riscos.


FORM bb-ratings.inrisctl LABEL "Risco Coop."     AT 09 FORMAT "x(2)" 
     bb-ratings.nrnotatl LABEL "Nota"            AT 25 FORMAT "zz9.99"  
     bb-ratings.indrisco LABEL "Rating"          AT 44 FORMAT "x(2)" 
     bb-ratings.nrnotrat LABEL "Nota"            AT 55 FORMAT "zz9.99"  
     SKIP
     bb-ratings.dteftrat LABEL "Efetivacao"      AT 02 FORMAT "99/99/9999"
     crapope.nmoperad    LABEL "Ope."            AT 26 FORMAT "x(15)"
     bb-ratings.vlutlrat LABEL "Vlr.Util."       AT 51 FORMAT "zzz,zzz,zz9.99"
     WITH CENTERED SIDE-LABELS NO-BOX OVERLAY ROW 18 WIDTH 78 FRAME f_detalhes.

FORM " Selecione o relatorio:"
     SKIP(1)
     tel_dsrelato[1] FORMAT "x(35)"  AT  2
      
     tel_dsrelato[2] FORMAT "x(35)"  AT 39

     WITH ROW 8 COLUMN 3 NO-BOX NO-LABELS OVERLAY FRAME f_regua.


ON RETURN OF b-ratings, b-riscos DO:
    
    IF   glb_cddopcao = "C"   THEN
         RETURN.

    APPLY "GO".

END.

ON RETURN OF tel_nrdconta IN FRAME f_aturat DO: 
    
    IF   INPUT tel_nrdconta <> 0   THEN
         DO:
             FIND crapass WHERE 
                  crapass.cdcooper = glb_cdcooper  AND
                  crapass.nrdconta = INPUT tel_nrdconta
                  NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapass THEN
                  DO:
                      MESSAGE "009 - Associado nao cadastrado.".
                      RETURN NO-APPLY.
                  END.

             HIDE MESSAGE NO-PAUSE.

             tel_cdagenci = crapass.cdagenci.

             DISPLAY tel_cdagenci
                     WITH FRAME f_aturat.

         END.
END.

ON RETURN OF tel_dtinirat DO:

    IF   INPUT tel_dtinirat <> ?  AND
         INPUT tel_dtfinrat = ?   THEN
         DO:
             ASSIGN tel_dtfinrat = glb_dtmvtolt.

             DISPLAY tel_dtfinrat 
                     WITH FRAME f_aturat.
         END.
       
END.


ON ENTRY, VALUE-CHANGED OF b-ratings , b-riscos DO:
   
    IF   NOT AVAILABLE bb-ratings   THEN
         RETURN.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                       crapass.nrdconta = bb-ratings.nrdconta
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapass THEN
         DO:
             ASSIGN tel_nmprimtl = crapass.nmprimtl.

             DISPLAY tel_nmprimtl WITH FRAME f_opcao.
         END.

    /* Para a opcao 'S' estes dados nao sao mostrados */
    IF   CAN-DO("C,A,R",glb_cddopcao) THEN
         DO:
             FIND crapope WHERE 
                  crapope.cdcooper = glb_cdcooper   AND
                  crapope.cdoperad = bb-ratings.cdoperad
                  NO-LOCK NO-ERROR.
             
             DISPLAY bb-ratings.indrisco
                     bb-ratings.nrnotrat
                     bb-ratings.inrisctl
                     bb-ratings.nrnotatl
                     bb-ratings.dteftrat 
                     crapope.nmoperad     WHEN AVAIL crapope
                     bb-ratings.vlutlrat
                     WITH FRAME f_detalhes.  
         END.
      
END.


ON ENTRY, GO , END-ERROR OF bb-ratings.dsdatual DO: 
      
    IF   CAN-FIND (FIRST bb-ratings WHERE bb-ratings.dsdatual = "T") THEN
         DO:
             /* Seta no buffer "sim" para todos */
             FOR EACH bk-ratings WHERE bk-ratings.dsdatual <> "S":
             
                  bk-ratings.dsdatual = "S".
             
             END.           
        
             RUN proc_carrega_riscos.

         END.
                                   
END.

VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic =  0.

ATURAT:
DO WHILE TRUE:

   RUN fontes/inicia.p.


   IF glb_cdcritic <> 0   THEN
      DO:
          RUN fontes/critic.p.
          glb_cdcritic = 0.
          BELL.
          MESSAGE glb_dscritic.    

      END.

   HIDE FRAME f_aturat.       
   HIDE FRAME f_ratings.
   HIDE FRAME f_detalhes.
   HIDE FRAME f_sem_rating.
   HIDE FRAME f_riscos.

   ASSIGN tel_nmprimtl = ""
          tel_nrdconta = 0
          tel_cdagenci = 0
          tel_dtinirat = ?
          tel_dtfinrat = ?
          tel_nrctremp = 0.
        
   DISPLAY tel_nmprimtl WITH FRAME f_opcao.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_opcao.

      LEAVE.

   END.

   IF KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /* F4 ou Fim  */
      DO:
          RUN fontes/novatela.p.
    
          IF   CAPS(glb_nmdatela) <> "ATURAT"   THEN
               DO:
                   HIDE FRAME f_opcao.
                   RETURN.
               END.
          NEXT.
      END.

   IF aux_cddopcao <> glb_cddopcao   THEN
      DO:
          { includes/acesso.i }
          aux_cddopcao = glb_cddopcao.
      END.

   IF glb_cddopcao = "C"   THEN
      b-ratings:HELP = 
          "Utilize as <SETAS> p/ navegar. <F4> p/ voltar.".
   ELSE
   IF glb_cddopcao = "A"   THEN
      b-ratings:HELP =
          "Pressione <ENTER> p/ atualizar o Rating. <F4> p/ voltar.". 
   ELSE
        b-ratings:HELP = 
            "Pressione <ENTER> p/ visualizar o Rating. <F4> p/ voltar.".

   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      IF glb_cdcritic <> 0   THEN
         DO:
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE glb_dscritic.     
         END.

           /* Selecionar qual Relatorio */
      IF CAN-DO("R",glb_cddopcao)   THEN 
         DO:
             DISPLAY tel_dsrelato[1] 
                     tel_dsrelato[2]
                     WITH FRAME f_regua.

             DO WHILE TRUE ON ENDKEY UNDO , LEAVE:

                 CHOOSE FIELD tel_dsrelato[1]
                              tel_dsrelato[2]
                              WITH FRAME f_regua.  
                 LEAVE.
             END.
             
             HIDE FRAME f_regua.

             IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT ATURAT.

             /* Salvar relatorio escolhido */
             aux_dsrelato = FRAME-VALUE.

         END.

           /* Relatorio , Alteraçao e Consulta */
      IF CAN-DO ("R,A,C,L",glb_cddopcao)   THEN
         DO:
             HIDE tel_cdagenci IN FRAME f_aturat.
             HIDE tel_dtinirat IN FRAME f_aturat.
             HIDE tel_dtfinrat IN FRAME f_aturat.
             HIDE tel_inrisctl IN FRAME f_aturat.
             DO WHILE TRUE:
                 
                UPDATE tel_nrdconta WITH FRAME f_aturat
   
                EDITING:
                   
                   READKEY.
                
                   IF LASTKEY = KEYCODE ("F7")   THEN
                      DO:
                          IF FRAME-FIELD = "tel_nrdconta"   THEN
                             DO:
                                 RUN fontes/zoom_associados.p
                                            (INPUT  glb_cdcooper,
                                             OUTPUT tel_nrdconta).  
                
                                 DISPLAY tel_nrdconta
                                         WITH FRAME f_aturat.
                             END.
                          ELSE
                               APPLY LASTKEY.
                      END.
                   ELSE
                        APPLY LASTKEY.
                
                END. /* Fim do EDITING */

                IF glb_cddopcao <> "L"  THEN
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                      UPDATE tel_cdagenci
                             tel_dtinirat
                             tel_dtfinrat WITH FRAME f_aturat.
     
                      IF tel_dtinirat > tel_dtfinrat   THEN
                         DO:
                             NEXT-PROMPT tel_dtfinrat WITH FRAME f_aturat.  
                             glb_cdcritic = 13.
                             NEXT.
                         END.
                      
                      LEAVE.

                   END.
                ELSE
                DO:
                   IF CAN-FIND(FIRST crapnrc WHERE 
                                     crapnrc.cdcooper = glb_cdcooper AND
                                     crapnrc.nrdconta = tel_nrdconta AND
                                     crapnrc.insitrat = 2            AND
                                     crapnrc.flgativo NO-LOCK) THEN
                      DO:
                         MESSAGE "Cooperado com rating ativo. " +
                                 "Atualizacao pela opcao 'A'".
                         NEXT.

                      END.
                   ELSE
                     DO:
                        FIND crapass WHERE 
                             crapass.cdcooper = glb_cdcooper AND
                             crapass.nrdconta = tel_nrdconta 
                             NO-LOCK NO-ERROR.
                     
                        IF NOT AVAIL crapass  THEN
                           DO:
                               glb_cdcritic = 9.
                               RUN fontes/critic.p.
                               MESSAGE glb_dscritic.
                               PAUSE 2 NO-MESSAGE.
                               HIDE MESSAGE.
                               NEXT.
                        
                           END.
                     
                        ASSIGN tel_inrisctl = crapass.inrisctl.
                     
                        DISPLAY tel_inrisctl 
                                WITH FRAME f_aturat.
                     
                        ASSIGN aux_dsmessag = 
                               "Deseja atualizar o Risco Cooperado? (S/N):".
                        
                        RUN fontes/confirma.p (INPUT  aux_dsmessag,
                                               OUTPUT aux_confirma).
                     
                        IF NOT aux_confirma = "S"   THEN
                           NEXT. 
                     
                        RUN sistema/generico/procedures/b1wgen0043.p
                                                PERSISTENT SET h-b1wgen0043.
                        
                        RUN calcula-rating IN h-b1wgen0043 
                                      (INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT glb_dtmvtolt,
                                       INPUT glb_dtmvtopr,
                                       INPUT glb_inproces,
                                       INPUT tel_nrdconta,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT FALSE,
                                       INPUT TRUE,
                                       INPUT 1,
                                       INPUT 1,
                                       INPUT glb_nmdatela,
                                       INPUT FALSE,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-impressao-coop,
                                       OUTPUT TABLE tt-impressao-rating,
                                       OUTPUT TABLE tt-impressao-risco,
                                       OUTPUT TABLE tt-impressao-risco-tl,
                                       OUTPUT TABLE tt-impressao-assina,
                                       OUTPUT TABLE tt-efetivacao,
                                       OUTPUT TABLE tt-ratings).
                     
                        DELETE PROCEDURE h-b1wgen0043.
                     
                        IF RETURN-VALUE <> "OK"   THEN
                           DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
                     
                              IF   AVAILABLE tt-erro   THEN
                                   MESSAGE tt-erro.dscritic.
                              ELSE
                                   MESSAGE "Erro na verificacao da " + 
                                           "atualizacao do Rating.".
                     
                              PAUSE 3 NO-MESSAGE.
                              HIDE MESSAGE NO-PAUSE.
                              NEXT.
                     
                           END.
                        
                        FIND FIRST tt-impressao-risco-tl NO-LOCK NO-ERROR. 
                     
                        IF NOT AVAIL tt-impressao-risco-tl  THEN
                           DO:
                              MESSAGE "Registro do calculo " + 
                                      "de Risco Cooperado nao encontrado.".
                              
                              PAUSE 3 NO-MESSAGE.
                              HIDE MESSAGE NO-PAUSE.
                              NEXT.
                        
                           END.
                     
                        ASSIGN aux_dsmessag = 
                                 "O Risco Cooperado sera " + 
                                 STRING(tt-impressao-risco-tl.dsdrisco) + 
                                 ". " + "Confirma? (S/N):".
                     
                        RUN fontes/confirma.p (INPUT  aux_dsmessag,
                                               OUTPUT aux_confirma).
                     
                        IF NOT aux_confirma = "S"   THEN
                           NEXT. 
                     
                        FIND CURRENT crapass EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
                        IF AVAIL crapass  THEN
                           DO:
                               ASSIGN crapass.inrisctl = 
                                                tt-impressao-risco-tl.dsdrisco
                                      crapass.nrnotatl = 
                                                tt-impressao-risco-tl.vlrtotal
                                      crapass.dtrisctl = glb_dtmvtolt.
                        
                               FIND CURRENT crapass NO-LOCK NO-ERROR.

                           END.
                     
                        MESSAGE "Novo Risco Cooperado atualizado para " +
                                 STRING(tt-impressao-risco-tl.dsdrisco) + ".".
                        PAUSE 3 NO-MESSAGE.
                     
                     END.
                END.

                IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   NEXT.

                LEAVE.

             END.

             IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                NEXT.

        END. /* Fim de campos da opcao R, A e C  */

        LEAVE.
        
   END. /* Fim do DO WHILE TRUE */ 

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      NEXT.

   IF CAN-DO ("C,A,R",glb_cddopcao)   THEN
      DO:
          RUN proc_traz_ratings.

          IF   NOT TEMP-TABLE bb-ratings:HAS-RECORDS   THEN
               DO:  
                   MESSAGE "Nenhum Rating foi encontrado para estas condicoes.".
                   PAUSE 3 NO-MESSAGE.
                   NEXT.
               END.

          RUN proc_carrega_ratings.

          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
             /* Nao mostrar se Optar pelo relatorio 539 */
             IF (glb_cddopcao = "R"              AND 
                 aux_dsrelato = tel_dsrelato[1]) OR
                 glb_cddoPcao <> "R"              THEN
                 DO:
                      DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
          
                        UPDATE b-ratings WITH FRAME f_ratings.
                        LEAVE.
          
                      END.
          
                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                           LEAVE.   
          
                 END.

             IF glb_cddopcao = "R"   THEN /* Relatorios */
                DO:  
                   /* Rating Associado */  
                   IF aux_dsrelato = tel_dsrelato[1]  THEN
                      DO:
                         IF bb-ratings.nrctrrat = 0   AND   /* Rating */
                            bb-ratings.tpctrrat = 0   THEN  /* Antigo */
                            DO: 
                                RUN fontes/rating_r.p 
                                            (INPUT bb-ratings.nrdconta).
                                
                            END.
                         ELSE
                              DO: 
                                  /* Novo Rating */
                                  RUN fontes/gera_rating.p
                                     (INPUT glb_cdcooper,
                                      INPUT bb-ratings.nrdconta,
                                      INPUT bb-ratings.tpctrrat,
                                      INPUT bb-ratings.nrctrrat,
                                      INPUT FALSE).  /* Nao grava */
                                            
                              END.  
                      END.
                   ELSE /* Ratings cadastrados */
                        DO:
                            RUN gera_rel_539.
                   
                            UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2>/dev/null").
                   
                            LEAVE. /* Volta para a selecao da Opcao */
                        END.
                                                                            
                END. /* Fim Opcao R, Impressao do Rating */
             ELSE
             IF glb_cddopcao = "A"   THEN /* Atualizacao Rating */
                DO:
                   IF bb-ratings.nrctrrat = 0   AND
                      bb-ratings.tpctrrat = 0   THEN
                      DO:
                          MESSAGE "Para atualizar Rating antigo utilize a " +
                                  "tela RATING.". 
                          PAUSE 3 NO-MESSAGE.
                          NEXT.

                      END.

                   EMPTY TEMP-TABLE tt-singulares.

                   /* Verificar , independente da situacao, se o Rating */
                                 /* pode ser atualizado */
                   RUN sistema/generico/procedures/b1wgen0043.p
                                              PERSISTENT SET h-b1wgen0043.

                   IF  glb_cdcooper = 3  THEN
                   DO:
                       RUN verifica_atualizacao IN h-b1wgen0043
                                                  (INPUT glb_cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT glb_cdoperad,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT glb_dtmvtopr,
                                                   INPUT glb_inproces,
                                                   INPUT bb-ratings.nrdconta,
                                                   INPUT bb-ratings.tpctrrat,
                                                   INPUT bb-ratings.nrctrrat,
                                                   INPUT 1,
                                                   INPUT 1,
                                                   INPUT glb_nmdatela,
                                                   INPUT FALSE,
                                                   INPUT TRUE,
                                                   INPUT TABLE tt-singulares,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT aux_indrisco,
                                                   OUTPUT aux_nrnotrat,
                                                   OUTPUT aux_rowidnrc).

                       IF   RETURN-VALUE <> "OK"   THEN
                       DO:
                          FIND FIRST tt-erro NO-LOCK NO-ERROR.

                          IF   AVAILABLE tt-erro   THEN
                               MESSAGE tt-erro.dscritic.
                          ELSE
                               MESSAGE "Erro na verificacao da " + 
                                       "atualizacao do Rating.".
                          DELETE PROCEDURE h-b1wgen0043.
                          PAUSE 3 NO-MESSAGE.
                          HIDE MESSAGE NO-PAUSE.
                          NEXT.

                       END.
                       ELSE
                       DO:
                           ASSIGN aux_nrdconta = tel_nrdconta.

                           /* atualiza a tt-singulares */
                           { includes/rating_singulares.i  bb-ratings.nrctrrat 
                                                           bb-ratings.tpctrrat}


                           IF  glb_cdcritic > 0 OR glb_dscritic <> "" THEN
                               NEXT.

                       END.
                   END.

                   RUN verifica_atualizacao IN h-b1wgen0043
                                              (INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_dtmvtolt,
                                               INPUT glb_dtmvtopr,
                                               INPUT glb_inproces,
                                               INPUT bb-ratings.nrdconta,
                                               INPUT bb-ratings.tpctrrat,
                                               INPUT bb-ratings.nrctrrat,
                                               INPUT 1,
                                               INPUT 1,
                                               INPUT glb_nmdatela,
                                               INPUT FALSE,
                                               INPUT FALSE,
                                               INPUT TABLE tt-singulares,
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT aux_indrisco,
                                               OUTPUT aux_nrnotrat,
                                               OUTPUT aux_rowidnrc).

                   DELETE PROCEDURE h-b1wgen0043.

                   IF   RETURN-VALUE <> "OK"   THEN
                        DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                   
                           IF   AVAILABLE tt-erro   THEN
                                MESSAGE tt-erro.dscritic.
                           ELSE
                                MESSAGE "Erro na verificacao da " + 
                                        "atualizacao do Rating.".
                  
                           PAUSE 3 NO-MESSAGE.
                           HIDE MESSAGE NO-PAUSE.
                           NEXT.

                        END.

                   IF bb-ratings.insitrat = 1   THEN  /* Proposto */
                      DO: 
                          RUN calcula(INPUT FALSE,  /* Soh calcula */ 
                                      INPUT bb-ratings.insitrat,
                                      INPUT aux_rowidnrc,
                                      OUTPUT aux_indrisco,
                                      OUTPUT aux_nrnotrat,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-impressao-risco-tl). 
                  
                          IF   RETURN-VALUE <> "OK"   THEN
                               NEXT. 

                          ASSIGN aux_dsmessag = 
                                   "O risco será " + STRING(aux_indrisco) + 
                                   " com a nota "  + STRING(aux_nrnotrat) + 
                                   ". " + "Confirma? (S/N):".
                  
                          RUN fontes/confirma.p (INPUT  aux_dsmessag,
                                                 OUTPUT aux_confirma).
                  
                          IF   NOT aux_confirma = "S"   THEN
                               NEXT. 
                               
                          RUN calcula(INPUT TRUE,  /* Grava */
                                      INPUT bb-ratings.insitrat,
                                      INPUT aux_rowidnrc,
                                      OUTPUT aux_indrisco,
                                      OUTPUT aux_nrnotrat,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-impressao-risco-tl).
                  
                          IF   RETURN-VALUE <> "OK"   THEN
                               NEXT.                         
                  
                      END.  /* Fim proposto */
                   ELSE
                   IF bb-ratings.insitrat = 2   THEN /* Efetivo */
                      DO: 
                          aux_dsmessag = 
                              "O risco efetivado para o Rating será " +
                              STRING(aux_indrisco) + ", com nota "       +
                              STRING(aux_nrnotrat) + ". " + "Confirma? (S/N):".
                   
                          RUN fontes/confirma.p 
                               (INPUT  aux_dsmessag,
                                OUTPUT aux_confirma).
                   
                          IF   aux_confirma <> "S" THEN
                               NEXT.

                          RUN calcula(INPUT TRUE,  /* Grava */
                                      INPUT bb-ratings.insitrat,
                                      INPUT aux_rowidnrc,
                                      OUTPUT aux_indrisco,
                                      OUTPUT aux_nrnotrat,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-impressao-risco-tl).

                          IF RETURN-VALUE <> "OK"   THEN
                             DO:
                                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                         
                                 IF   AVAILABLE tt-erro   THEN
                                      MESSAGE tt-erro.dscritic.
                                 ELSE    
                                      MESSAGE "Erro na atualizacao do Rating.".
                         
                                 PAUSE 3 NO-MESSAGE.
                                 HIDE MESSAGE NO-PAUSE.
                                 NEXT.
                         
                             END.
                           
                           FIND crapass WHERE 
                                crapass.cdcooper = glb_cdcooper AND
                                crapass.nrdconta = bb-ratings.nrdconta
                                EXCLUSIVE-LOCK NO-ERROR.

                           IF AVAIL crapass THEN
                           DO:
                               FIND FIRST tt-impressao-risco-tl
                                          NO-LOCK NO-ERROR.

                               IF AVAIL tt-impressao-risco-tl THEN
                                  ASSIGN crapass.inrisctl = tt-impressao-risco-tl.dsdrisco
                                         crapass.nrnotatl = tt-impressao-risco-tl.vlrtotal
                                         crapass.dtrisctl = glb_dtmvtolt.
                                   
                           END.

                      END. /* Fim Efetivo */

                   RUN gera_log (INPUT TRUE, /* Possui Rating */
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_cdoperad,
                                 INPUT bb-ratings.nrdconta,
                                 INPUT bb-ratings.dsdopera,
                                 INPUT bb-ratings.nrctrrat,
                                 INPUT bb-ratings.indrisco, /* Risco Anterior */
                                 INPUT bb-ratings.nrnotrat, /* Nota Anterior  */
                                 INPUT aux_indrisco,        /* Novo risco     */
                                 INPUT aux_nrnotrat).       /* Nova nota      */
                             
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                      MESSAGE "O risco foi atualizado com sucesso.".
                      PAUSE 3 NO-MESSAGE.
                      LEAVE.
                   
                   END.                
                   
                   RUN proc_traz_ratings.
                   
                   RUN proc_carrega_ratings.
                       
                END. /* Fim Opcao A, Atualizacao do Rating  */            
                       
          END. /* FIM do DO WHILE TRUE */

      END. /* Fim da opcao C, A e R*/

END. /* Fim do DO WHILE TRUE */


PROCEDURE proc_traz_ratings:

   MESSAGE "Aguarde, processando informaçoes ...".

   RUN sistema/generico/procedures/b1wgen0043.p 
                 PERSISTENT SET h-b1wgen0043. 
   
   RUN ratings-cooperado IN h-b1wgen0043 (INPUT glb_cdcooper,
                                          INPUT tel_cdagenci,
                                          INPUT glb_cdoperad,
                                          INPUT 1,
                                          INPUT glb_dtmvtolt,
                                          INPUT ?,
                                          INPUT tel_nrdconta,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT tel_dtinirat,
                                          INPUT tel_dtfinrat,
                                          INPUT 0, /* Todas as sit. */
                                          INPUT glb_inproces,
                                          OUTPUT TABLE tt-ratings).
   DELETE PROCEDURE h-b1wgen0043.

   /* Utilizar a bb-ratings para nao queimar registros de tt-ratings */
   EMPTY TEMP-TABLE bb-ratings.

   FOR EACH tt-ratings NO-LOCK:

       CREATE bb-ratings.
       BUFFER-COPY tt-ratings TO bb-ratings.

   END.
   
   HIDE MESSAGE NO-PAUSE.

END PROCEDURE.

PROCEDURE proc_carrega_ratings:

   OPEN QUERY q-ratings FOR EACH bb-ratings NO-LOCK
                                 BY bb-ratings.cdagenci
                                   BY bb-ratings.nrdconta
                                     BY bb-ratings.insitrat DESC
                                       BY bb-ratings.dtmvtolt. 
   
END PROCEDURE.


PROCEDURE proc_carrega_riscos:

   OPEN QUERY q-riscos FOR EACH bb-ratings NO-LOCK
                                BY bb-ratings.cdagenci
                                  BY bb-ratings.nrdconta
                                    BY bb-ratings.insitrat DESC
                                      BY bb-ratings.dtmvtolt. 
   
END PROCEDURE.


PROCEDURE calcula:

   DEF  INPUT PARAM par_flgcriar AS LOG                NO-UNDO.
   DEF  INPUT PARAM par_insitrat AS INT                NO-UNDO.
   DEF  INPUT PARAM par_rowidnrc AS ROWID              NO-UNDO.
   
   DEF OUTPUT PARAM par_indrisco AS CHAR               NO-UNDO.
   DEF OUTPUT PARAM par_nrnotrat AS DECI               NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.
  
   RUN sistema/generico/procedures/b1wgen0043.p
                                 PERSISTENT SET h-b1wgen0043.
  

   RUN proc_calcula IN h-b1wgen0043 (INPUT par_flgcriar,
                                     INPUT bb-ratings.nrdconta,
                                     INPUT bb-ratings.tpctrrat,
                                     INPUT bb-ratings.nrctrrat,
                                     INPUT glb_cdcooper,
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_dtmvtopr,
                                     INPUT glb_inproces,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT par_insitrat,
                                     INPUT par_rowidnrc,
                                     INPUT TABLE tt-singulares,
                                     OUTPUT par_indrisco,
                                     OUTPUT par_nrnotrat,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-impressao-risco-tl).
  
   DELETE PROCEDURE h-b1wgen0043.
  
   IF   RETURN-VALUE <> "OK"   THEN
        DO:    
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
  
            IF   AVAILABLE tt-erro   THEN
                 MESSAGE tt-erro.dscritic.
            ELSE
               IF par_insitrat = 1 THEN
                  MESSAGE "Erro na BO de calculo do RATING.".
               ELSE
                  MESSAGE "Erro na atualizacao do Rating.".
  
            PAUSE 3 NO-MESSAGE.

            RETURN "NOK".
  
        END.
          
   RETURN "OK".
  
END PROCEDURE.


PROCEDURE gera_rel_539:

   DEF VAR aux_dsagenci AS CHAR                        NO-UNDO.
   
   DEF VAR tel_cddopcao AS CHAR FORMAT "!(1)" INIT "T" NO-UNDO.

   FORM aux_dsagenci FORMAT "x(100)" 
        WITH NO-LABEL WIDTH 132 FRAME f_pac.

   FORM bb-ratings.cdagenci COLUMN-LABEL "PA"            FORMAT "zz9"
        bb-ratings.nrdconta COLUMN-LABEL "Conta/dv"      FORMAT "zzzz,zzz,9"
        bb-ratings.vloperac COLUMN-LABEL "Valor"         FORMAT "zzz,zz9.99"
        bb-ratings.dsdopera COLUMN-LABEL "Tipo"          FORMAT "x(14)"
        bb-ratings.nrctrrat COLUMN-LABEL "Contrato"      FORMAT "z,zzz,zz9"
        bb-ratings.inrisctl COLUMN-LABEL "Risco Coop"    FORMAT "x(2)"
        bb-ratings.nrnotatl COLUMN-LABEL "Nota"          FORMAT "zz9.99"
        bb-ratings.indrisco COLUMN-LABEL "Rating"        FORMAT "x(2)"
        bb-ratings.nrnotrat COLUMN-LABEL "Nota"          FORMAT "zz9.99"
        bb-ratings.dteftrat COLUMN-LABEL "Efetivacao"    FORMAT "99/99/9999"
        bb-ratings.dtmvtolt COLUMN-LABEL "Alteracao"     FORMAT "99/99/9999"
        crapope.nmoperad    COLUMN-LABEL "Operador"      FORMAT "x(25)"
        WITH DOWN WIDTH 133 FRAME f_crrl539.
        

   ASSIGN aux_nmarqimp = "rl/crrl539_" + STRING(TIME) + ".ex".

   OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 82. 
   
   ASSIGN glb_cdrelato[1] = 539
          glb_cdempres    = 11.

   { includes/cabrel132_1.i }

   VIEW STREAM str_1 FRAME f_cabrel132_1.

   FOR EACH bb-ratings NO-LOCK BREAK BY bb-ratings.cdagenci
                                        BY bb-ratings.nrdconta:

       IF   FIRST-OF (bb-ratings.cdagenci)   THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                   crapage.cdagenci = bb-ratings.cdagenci
                                   NO-LOCK NO-ERROR.

                aux_dsagenci = "PA -" + STRING(bb-ratings.cdagenci,"zz9") + "  ".

                IF   AVAIL crapage   THEN
                     aux_dsagenci = aux_dsagenci + crapage.nmresage.
                ELSE
                     aux_dsagenci = aux_dsagenci + "PA NAO CADASTRADO".

                DISPLAY STREAM str_1 aux_dsagenci
                                     WITH FRAME f_pac.
            END.

       FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                          crapope.cdoperad = bb-ratings.cdoperad
                          NO-LOCK NO-ERROR.

       DISPLAY STREAM str_1 bb-ratings.cdagenci 
                            bb-ratings.nrdconta
                            bb-ratings.vloperac
                            bb-ratings.dsdopera 
                            bb-ratings.nrctrrat
                            bb-ratings.inrisctl
                            bb-ratings.nrnotatl
                            bb-ratings.indrisco
                            bb-ratings.nrnotrat
                            bb-ratings.dtmvtolt
                            bb-ratings.dteftrat
                            crapope.nmoperad WHEN AVAIL crapope
                            WITH FRAME f_crrl539.

       DOWN WITH FRAME f_crrl539.

   END.

   OUTPUT STREAM str_1 CLOSE.

   DO WHILE TRUE ON END-KEY UNDO , LEAVE:
     
     MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
     LEAVE.
   
   END.

   HIDE MESSAGE NO-PAUSE.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        RETURN.

   IF   tel_cddopcao = "T"   THEN
        DO:
            RUN fontes/visrel.p (INPUT aux_nmarqimp).   
        END.         
   ELSE 
   IF   tel_cddopcao = "I"   THEN
        DO:
            ASSIGN par_flgrodar = TRUE
                   glb_nmformul = "132col"
                   glb_nrdevias = 1.

            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.
            { includes/impressao.i }

        END.

END PROCEDURE.


PROCEDURE gera_log:

   DEF INPUT PARAM par_flgratin AS LOGI              NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INTE              NO-UNDO.
   DEF INPUT PARAM par_dsoperad AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_nrctrrat AS INTE              NO-UNDO.
   DEF INPUT PARAM ant_indrisco AS CHAR              NO-UNDO.
   DEF INPUT PARAM ant_nrnotrat AS DECI              NO-UNDO.
   DEF INPUT PARAM nov_indrisco AS CHAR              NO-UNDO.
   DEF INPUT PARAM nov_nrnotrat AS DECI              NO-UNDO.


        /* Se nao tem Rating (Opcao S) */
   IF   NOT par_flgratin   THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")               +
                          " "     + STRING(TIME,"HH:MM:SS") + "' --> '"             +
                          " Operador "  + par_cdoperad  + " -"        +
                          " Atualizou o Risco da conta/dv " + STRING(par_nrdconta,
                          "zzzz,zzz,9") + ", " + par_dsoperad + ", contrato "       + 
                          STRING(par_nrctrrat,"z,zzz,zz9")  + " de " + ant_indrisco +
                          " para " + nov_indrisco + ". >> log/aturat.log"). 

   ELSE /* Sem alteraçao na nota do Rating */                                                                            
   IF   ant_nrnotrat = nov_nrnotrat THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")              +
                          " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"           +
                          " Operador "  + par_cdoperad + " -"        +
                          " Atualizou o Rating da conta/dv "     + 
                          STRING(par_nrdconta,"zzzz,zzz,9")  + ", " + par_dsoperad +
                          ", contrato " + STRING(par_nrctrrat,"z,zzz,zz9")         + 
                          ", sem alterar a nota do mesmo."                         +
                          " >> log/aturat.log").   
   
   ELSE /* Com alteraçao na nota */
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")               +
                          " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"            +
                          " Operador "  + par_cdoperad + " -"         +
                          " Atualizou o Rating da conta/dv "                        + 
                          STRING(par_nrdconta,"zzzz,zzz,9")  + ", " + par_dsoperad  +
                          ", contrato " + STRING(par_nrctrrat,"z,zzz,zz9")          +
                          ", risco " + ant_indrisco + " e nota "                    + 
                          STRING(ant_nrnotrat,"zz9.99") + " para o risco "          +
                          nov_indrisco + " e nota " + STRING(nov_nrnotrat,"zz9.99") +
                          ". >> log/aturat.log").
      
   RETURN "OK".

END PROCEDURE.

/*..........................................................................*/
