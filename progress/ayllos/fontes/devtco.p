/* .............................................................................

   Programa: Fontes/devtco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Dezembro/2010                      Ultima atualizacao: 07/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Adaptacao tela DEVOLU -- Devolucao de cheques
               Exclusivo para TCO - Transferencia de PACs
   
   Alteracoes:  25/01/2011 - Ajustes Gerais (Ze).
   
                07/07/2011 - Nao tarifar devolucao de alinea 31 (Diego).
                
                15/07/2011 - Melhoria na tela - retirar horario limite (Ze).
                
                12/11/2011 - Criticar a alinea 32 - Nao sera mais aceito
                            - Trf. 43954 (ZE).

                08/12/2011 - Sustação provisória (André R./Supero).
                
                18/06/2012 - Alteracao na leitura da craptco (David Kruger).
                
                13/08/2013 - Exclusao da alinea 29. (Fabricio)
                
                12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                04/12/2013 - Inclusao de VALIDATE crapdev (Carlos)
                
                07/08/2015 - Ajuste na consulta na tabela craplcm para melhorias
                            de performace SD281896 (Odirlei-AMcom) 
               
............................................................................. */

{ includes/var_online.i } 

{ includes/gg0000.i }


DEF   VAR s_title      AS CHAR                                         NO-UNDO.

DEF   VAR tel_nrdconta AS INTE    FORMAT "zzzz,zzz,9"                  NO-UNDO.
DEF   VAR tel_cdalinea AS INTE                                         NO-UNDO.

DEF   VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF   VAR aux_confirma AS CHAR    FORMAT "!"                           NO-UNDO.
DEF   VAR aux_regexist AS LOGI                                         NO-UNDO.
DEF   VAR aux_cddsenha AS CHAR    FORMAT "x(8)"                        NO-UNDO.

DEF   VAR tel_dtrefere AS DATE                                         NO-UNDO.
DEF   VAR tel_dtlimite AS DATE                                         NO-UNDO.

DEF   VAR p_opcao      AS CHAR    EXTENT 3 INIT  
                                  ["Devolver","","Executar Devolucao"] NO-UNDO.

DEF   VAR aux_cddevolu AS INTE                                         NO-UNDO.
DEF   VAR aux_cdagechq AS INTE                                         NO-UNDO.
DEF   VAR aux_cdbanchq AS INTE                                         NO-UNDO.
DEF   VAR aux_ultlinha AS INTE                                         NO-UNDO.

DEF   VAR aux_nrdconta AS INTE    FORMAT "zzzz,zzz,9"                  NO-UNDO.
DEF   VAR aux_cdcooper AS INTE                                         NO-UNDO.

DEF  VAR aut_flgsenha AS LOGICAL                                       NO-UNDO.
DEF  VAR aux_flghrexe AS LOGICAL                                       NO-UNDO.
DEF  VAR aut_cdoperad AS CHAR                                          NO-UNDO.

DEF BUFFER crabdev FOR crapdev.

DEF TEMP-TABLE w_lancto                                                NO-UNDO
    FIELD dsbccxlt AS CHAR FORMAT               "x(8)"
    FIELD nrdocmto AS DECI FORMAT         "zz,zzz,zz9"
    FIELD nrdctitg AS CHAR FORMAT        "9.999.999-X"
    FIELD cdbanchq AS INT  FORMAT              "z,zz9"
    FIELD banco    AS INT  FORMAT              "z,zz9"
    FIELD cdagechq AS INT  FORMAT              "z,zz9"
    FIELD nrctachq AS DEC
    FIELD vllanmto AS DECI FORMAT  "zz,zzz,zzz,zz9.99"
    FIELD dssituac AS CHAR FORMAT              "x(10)"
    FIELD cdalinea AS INTE FORMAT                "zz9"
    FIELD nmoperad AS CHAR FORMAT              "x(18)"
    FIELD cddsitua AS INTE FORMAT                "zz9"
    FIELD flag     AS LOGI
    FIELD nrdrecid AS RECID.

FORM tel_cdalinea  AT  1 LABEL  "Codigo da Alinea "  FORMAT "zz9"
     HELP "Entre com o codigo da alinea."
     VALIDATE(CAN-DO("11,12,13,20,21,22,28,30,31,35,44,48,49,70,72",
              STRING(tel_cdalinea)),"412 - Alinea invalida.")
     WITH SIDE-LABELS ROW 13 CENTERED OVERLAY FRAME f_alinea.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta     AT  3 LABEL "Conta/dv" 
                            HELP "Entre com o numero da conta do associado."
     crapass.nmprimtl AT 27 NO-LABEL
     SKIP (1)
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_devolu.

FORM SPACE(10)
     p_opcao[1] FORMAT "x(8)"
     "  "
     p_opcao[2] FORMAT "x(10)"
     "  "
     p_opcao[3] FORMAT "x(18)"
     SPACE(4)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM SKIP(1) SPACE(2) aux_cddsenha LABEL "Informe a senha"
     BLANK SPACE(2) SKIP(1)
     WITH FRAME f_senha TITLE " Autorizacao "
        ROW 12 CENTERED SIDE-LABELS OVERLAY.

DEF QUERY q_devolv FOR crapdev FIELDS(cdbccxlt nrcheque
                                      vllanmto cdalinea insitdev),
                       crapope FIELDS(nmoperad),
                       craptco FIELDS(nrdconta).

DEF QUERY q_lancto FOR w_lancto.

DEF BROWSE b_devolv QUERY q_devolv
    DISP   crapdev.cdbccxlt    COLUMN-LABEL "Bco"
           craptco.nrdconta    COLUMN-LABEL "Conta/dv"
           crapdev.nrcheque    COLUMN-LABEL "Cheque"     FORMAT "zzz,zz9,9"
           crapdev.vllanmto    COLUMN-LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
           crapdev.cdalinea    COLUMN-LABEL "Alinea"
           IF   crapdev.insitdev = 0   THEN  "a devolver"
           ELSE
           IF   crapdev.insitdev = 1   THEN  "devolvido"
           ELSE
                "indefinida"   COLUMN-LABEL "Situacao"   FORMAT "x(10)"
           crapope.nmoperad    COLUMN-LABEL "Operador"   FORMAT "x(14)"
           WITH 8 DOWN WIDTH 77 OVERLAY TITLE COLOR NORMAL s_title.

DEF BROWSE b_lancto QUERY q_lancto
    DISP   w_lancto.dsbccxlt LABEL "Banco"
           w_lancto.nrdocmto LABEL "Cheque"
           w_lancto.vllanmto LABEL "Valor"
           w_lancto.dssituac LABEL "Situacao"
           w_lancto.cdalinea LABEL "Alinea"
           w_lancto.nmoperad LABEL "Operador"
           WITH 8 DOWN WIDTH 78 OVERLAY TITLE s_title.

FORM SKIP(1)
     b_devolv  HELP "Pressione ENTER para selecionar / <F4> para finalizar"
     SKIP
     WITH NO-BOX ROW 7 COLUMN 2 OVERLAY FRAME f_devolv.

FORM SKIP(1)
     b_lancto HELP "Pressione ENTER para selecionar / <F4> para finalizar"
     SKIP
     WITH NO-BOX ROW 7 CENTERED OVERLAY FRAME f_lancto. 


/*........................................................................... */
/* Executa Devolucao */    
ON RETURN OF b_devolv DO:

   RUN proc_exec_dev.

END.

/* Marcar p/ Devolucao */
ON RETURN OF b_lancto DO:

    RUN proc_gera_dev.
    
    APPLY "GO".
END.    
     
    
VIEW FRAME f_moldura.

PAUSE 0.

/*  Busca dados da cooperativa  */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         BELL.
         glb_cdcritic = 0.
         NEXT.
     END.
         
ASSIGN s_title = " Lancamentos do dia " + STRING(glb_dtmvtoan,"99/99/9999") + 
                 "  "
       tel_dtrefere = glb_dtmvtoan
       tel_dtlimite = glb_dtmvtolt
       glb_cdcritic = 0
       glb_nrdrecid = 0.
           
DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   EMPTY TEMP-TABLE w_lancto.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta WITH FRAME f_devolu.

      ASSIGN glb_nrcalcul = tel_nrdconta
             tel_cdalinea = 0
             aux_regexist = FALSE
             glb_cddopcao = "D"
             aux_cdbanchq = 0
             aux_cdagechq = 0
             aux_cdcooper = 2.

      IF  tel_nrdconta > 0 THEN
          DO:
              RUN fontes/digfun.p.

              FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                 crapass.nrdconta = tel_nrdconta 
                                 NO-LOCK NO-ERROR.

              IF   NOT glb_stsnrcal OR  NOT AVAILABLE crapass   THEN
                   DO:
                       glb_cdcritic = IF   NOT glb_stsnrcal THEN
                                           8
                                      ELSE 9.
                       NEXT.
                   END.

              IF   aux_cddopcao <> glb_cddopcao   THEN
                   DO:
                       { includes/acesso.i}
                       aux_cddopcao = glb_cddopcao.
                   END.

              DISPLAY crapass.nmprimtl WITH FRAME f_devolu.
           
          END.
     
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   tel_nrdconta = 0 THEN
        DO:
            DISPLAY "Todas as devolucoes " @ crapass.nmprimtl 
                    WITH FRAME f_devolu.
        END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "DEVTCO"   THEN
                 DO:
                     HIDE FRAME f_devolu.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   tel_nrdconta = 0 THEN 
        DO:
            COLOR DISPLAY MESSAGE p_opcao[3] WITH FRAME f_opcoes.
            
            DISPLAY p_opcao WITH FRAME f_opcoes. 
            
            HIDE p_opcao[1] IN FRAME f_opcoes.
            
            PAUSE 0.

            OPEN QUERY q_devolv FOR EACH crapdev WHERE 
                                         crapdev.cdcooper =  aux_cdcooper  AND
                                         crapdev.cdhistor <> 46            AND
                                        (crapdev.dtmvtolt = glb_dtmvtolt   OR
                                         crapdev.cdoperad = "1")           AND
                                         crapdev.cdpesqui = "TCO"          AND
                                         crapdev.cdbanchq = 85         NO-LOCK,
                     EACH crapope WHERE  crapope.cdcooper = glb_cdcooper   AND 
                                         crapope.cdoperad = crapdev.cdoperad
                                         NO-LOCK,
                     EACH craptco WHERE  craptco.cdcopant = aux_cdcooper     AND
                                         craptco.nrctaant = crapdev.nrdconta AND
                                         craptco.tpctatrf = 1                AND
                                         craptco.flgativo = TRUE
                                         NO-LOCK BY crapdev.nrdconta.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_devolv WITH FRAME f_devolv.
               LEAVE.
            END.
                           
            HIDE FRAME f_devolv
                 FRAME f_opcoes.
           
            NEXT.

        END.

   /* ....................................................................... */
   FOR EACH craphis NO-LOCK
            WHERE craphis.cdcooper = glb_cdcooper
              AND CAN-DO("524,572,521", STRING(craphis.cdhistor)):

       FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper                   AND
                              craplcm.nrdconta = tel_nrdconta                   AND
                              craplcm.dtmvtolt >= tel_dtrefere                  AND
                              craplcm.cdhistor = craphis.cdhistor               AND    
                             (craplcm.dtrefere >= tel_dtrefere                  AND
                              craplcm.dtrefere <= tel_dtlimite)
                              USE-INDEX craplcm2 NO-LOCK:
    
           /*para historico 521 deve considerar apenas o banco 100*/ 
           IF craplcm.cdhistor = 521 AND craplcm.cdbccxlt <> 100 THEN
           DO:
              NEXT.  
           END.
                              
           FIND FIRST craptco WHERE craptco.cdcooper = craplcm.cdcooper AND
                                    craptco.nrdconta = craplcm.nrdconta AND
                                    craptco.tpctatrf = 1                AND
                                    craptco.flgativo = TRUE
                                    NO-LOCK NO-ERROR.
        
           IF   AVAILABLE craptco THEN
                ASSIGN aux_nrdconta = craptco.nrctaant
                       aux_cdcooper = craptco.cdcopant.
           ELSE 
                DO:
                    MESSAGE "Devolucao exclusiva de Contas Transf. do PA 58" +
                            " e Cheques do Banco 085 - CECRED".
                    LEAVE.
                END.
    
           /*  Consulta o Cheque p/ verificar se esta com indicador 5 COMPENSADO */
    
           RUN fontes/digbbx.p (INPUT  craplcm.nrdctabb,
                                OUTPUT glb_dsdctitg,
                                OUTPUT glb_stsnrcal).
    
           ASSIGN aux_cdbanchq = 85
                  aux_cdagechq = 0102.
                  glb_nrcalcul = 
                         INT(SUBSTR(STRING(craplcm.nrdocmto,"9999999"),1,6)).
    
           
           FIND crapfdc WHERE crapfdc.cdcooper = aux_cdcooper     AND
                              crapfdc.cdbanchq = aux_cdbanchq     AND
                              crapfdc.cdagechq = aux_cdagechq     AND
                              crapfdc.nrctachq = aux_nrdconta     AND
                              crapfdc.nrcheque = INT(glb_nrcalcul)
                              USE-INDEX crapfdc1 NO-LOCK NO-ERROR. 
           
           IF   NOT AVAILABLE crapfdc THEN
                DO:
                    glb_cdcritic = 244.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic + " -> Cheque: " + 
                            STRING(craplcm.nrdocmto,"99999999").
                    BELL.
                    glb_cdcritic = 0.
                    NEXT.
                END.
    
           IF   crapfdc.incheque <> 5 AND
                crapfdc.incheque <> 6 THEN
                NEXT.
     
           CREATE w_lancto.
     
           ASSIGN w_lancto.dsbccxlt = "CECRED"
                  w_lancto.nrdocmto = craplcm.nrdocmto   
                  w_lancto.vllanmto = craplcm.vllanmto   
                  w_lancto.nrdctitg = craplcm.nrdctitg   
                  w_lancto.cdbanchq = crapfdc.cdbanchq   
                  w_lancto.cdagechq = crapfdc.cdagechq   
                  w_lancto.nrctachq = crapfdc.nrctachq   
                  w_lancto.banco    = aux_cdbanchq       
                  w_lancto.dssituac = "normal"
                  w_lancto.cddsitua = 0
                  w_lancto.flag     = FALSE
                  w_lancto.nrdrecid = RECID(craplcm)
                  aux_regexist      = TRUE
                  glb_nrcalcul      = crapfdc.nrcheque * 10.
                  
                  RUN fontes/digfun.p.
           
           FIND FIRST crapdev WHERE crapdev.cdcooper = aux_cdcooper        AND
                                    crapdev.cdbanchq = crapfdc.cdbanchq    AND
                                    crapdev.cdagechq = crapfdc.cdagechq    AND
                                    crapdev.nrctachq = crapfdc.nrctachq    AND
                                    crapdev.nrcheque = INTE(glb_nrcalcul)  AND
                                    crapdev.cdhistor <> 46                 AND
                                    crapdev.cdpesqui = "TCO"            
                                    NO-LOCK NO-ERROR.
                                             
           IF   AVAILABLE crapdev THEN
                DO:
                    CASE crapdev.insitdev:
                    
                        WHEN 0 THEN w_lancto.dssituac = "a devolver".
                        WHEN 1 THEN w_lancto.dssituac = "devolvido".
                        OTHERWISE   w_lancto.dssituac = "indefinida".
    
                    END CASE.
                    
                    FIND crapope WHERE 
                         crapope.cdcooper = glb_cdcooper       AND
                         crapope.cdoperad = crapdev.cdoperad   NO-LOCK NO-ERROR.
                    
                    ASSIGN w_lancto.cddsitua = crapdev.insitdev
                           w_lancto.flag     = TRUE
                           w_lancto.cdalinea = crapdev.cdalinea
                           w_lancto.nmoperad = IF   AVAILABLE crapope   THEN
                                                    crapope.nmoperad
                                               ELSE
                                                    STRING(crapdev.cdoperad) + 
                                                    " Nao cadastrado".
                END.
                                      
       END. /* FOR EACH */
   END. /* FOR EACH CRAPHIS*/

   IF   NOT aux_regexist THEN
        DO:
           glb_cdcritic = 81.
           NEXT.
        END.

   COLOR DISPLAY MESSAGE p_opcao[1] WITH FRAME f_opcoes.
   DISPLAY p_opcao WITH FRAME f_opcoes. 
   HIDE p_opcao[3] IN FRAME f_opcoes.                   
                      
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      PAUSE 0.
      
      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
           END.
      
      OPEN QUERY q_lancto FOR EACH w_lancto EXCLUSIVE-LOCK.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         UPDATE b_lancto WITH FRAME f_lancto.
         LEAVE.
      END.
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           DO:
               HIDE FRAME f_lancto
                    FRAME f_alinea    
                     FRAME f_opcoes.
               LEAVE.
           END.

   END.  /* Fim do DO WHILE TRUE */
   
END. /* Fim do DO WHILE TRUE */


PROCEDURE proc_gera_dev:

     IF   w_lancto.cddsitua = 1   THEN   /* Devolvido */
          DO:
              glb_cdcritic = 414.
              RETURN.
          END. 

  
     glb_nrcalcul = INT(SUBSTR(STRING(w_lancto.nrdocmto,"9999999"),1,6)).

     FIND crapfdc WHERE crapfdc.cdcooper = aux_cdcooper        AND
                        crapfdc.cdbanchq = w_lancto.cdbanchq   AND
                        crapfdc.cdagechq = w_lancto.cdagechq   AND
                        crapfdc.nrctachq = w_lancto.nrctachq   AND
                        crapfdc.nrcheque = INT(glb_nrcalcul)
                        USE-INDEX crapfdc1 NO-LOCK NO-ERROR. 
       
     IF   NOT AVAILABLE crapfdc THEN
          DO:
              glb_cdcritic = 108.
              RETURN.                    
          END.
                              
     IF   crapfdc.cdbanchq = crapcop.cdbcoctl THEN 
          DO:
               IF   CAN-FIND(crapsol WHERE
                             crapsol.cdcooper = glb_cdcooper AND
                             crapsol.dtrefere = glb_dtmvtolt AND
                             crapsol.nrsolici = 78           AND
                             crapsol.nrseqsol = 6)           THEN
                    DO:       
                        glb_cdcritic = 138.
                        RETURN.
                    END.
          END.
          
          
          
     ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_lancto")
            tel_cdalinea = 0.
     
     IF   NOT w_lancto.flag  THEN      /* marcada */
          DO:  
              HIDE MESSAGE NO-PAUSE.
              
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 UPDATE tel_cdalinea WITH FRAME f_alinea.
                 LEAVE.
              END.             

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   DO:
                       HIDE FRAME f_alinea.
                       RETURN.
                   END.

              glb_nrcalcul = crapfdc.nrcheque * 10.
                       
              RUN fontes/digfun.p.
                                      
              FIND crapcor WHERE crapcor.cdcooper = crapfdc.cdcooper  AND
                                 crapcor.cdbanchq = crapfdc.cdbanchq  AND
                                 crapcor.cdagechq = crapfdc.cdagechq  AND
                                 crapcor.nrctachq = crapfdc.nrctachq  AND
                                 crapcor.nrcheque = INT(glb_nrcalcul) AND
                                 crapcor.flgativo = TRUE
                                 USE-INDEX crapcor1 NO-LOCK NO-ERROR.
 
              IF   NOT AVAILABLE crapcor   THEN
                   DO:
                       IF   CAN-DO("20,21,28",STRING(tel_cdalinea)) THEN
                            DO:
                                glb_cdcritic = 412.
                                RETURN.
                            END.
                   END. 
              ELSE
                   DO:
                       IF   CAN-DO("11,12,13,30,70",STRING(tel_cdalinea)) THEN
                            DO:   
                                glb_cdcritic = 412.
                                RETURN.
                            END.

                       IF   tel_cdalinea = 20         AND
                            crapcor.cdhistor <> 825   THEN
                            DO:
                                glb_cdcritic = 412.
                                RETURN.
                            END.
                                                      
                       IF   tel_cdalinea = 28 AND
                            NOT CAN-DO("818,835",STRING(crapcor.cdhistor)) THEN
                            DO:
                                glb_cdcritic = 412.
                                RETURN.
                            END.

                       IF   tel_cdalinea = 70 THEN
                            DO:
                                IF   crapcor.dtvalcor < glb_dtmvtolt OR
                                     crapcor.dtvalcor = ?            THEN
                                     DO:
                                         glb_cdcritic = 412.
                                         RETURN.
                                     END.
                            END.
                   END.

          END.
         
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
     END.

     HIDE FRAME f_alinea.
                             
     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
          aux_confirma <> "S" THEN
          DO:
              glb_cdcritic = 79.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              PAUSE 1 NO-MESSAGE.
              glb_cdcritic = 0.
              RETURN.
          END.

     DO TRANSACTION:  /* transacao para devolver */

        IF   w_lancto.flag THEN  /* a devolver */
             DO:
                 ASSIGN w_lancto.flag     = FALSE
                        w_lancto.dssituac = "normal"
                        w_lancto.cdalinea = 0
                        w_lancto.nmoperad = "".
                 
                 CLOSE QUERY q_lancto.
                 OPEN QUERY  q_lancto FOR EACH w_lancto NO-LOCK.
                 REPOSITION  q_lancto TO ROW   aux_ultlinha. 

                 RUN pi_cria_dev (INPUT  aux_cdcooper,
                                  INPUT  glb_dtmvtolt,
                                  INPUT  w_lancto.banco,
                                  INPUT  5 /* indevchq */,
                                  INPUT  crapfdc.nrdconta,
                                  INPUT  w_lancto.nrdocmto,
                                  INPUT  w_lancto.nrdctitg,
                                  INPUT  w_lancto.vllanmto,
                                  INPUT  tel_cdalinea,
                                  INPUT  47,  /* cdhistor */
                                  INPUT  glb_cdoperad,
                                  INPUT  crapfdc.cdagechq,
                                  INPUT  crapfdc.nrctachq,
                                  OUTPUT glb_cdcritic).

                 IF   glb_cdcritic <> 0   THEN
                      DO:
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          PAUSE 1 NO-MESSAGE.
                          glb_cdcritic = 0.
                          RETURN.
                      END.
             END.
        ELSE
             DO: 
                 ASSIGN w_lancto.flag     = TRUE
                        w_lancto.dssituac = "a devolver" 
                        w_lancto.cdalinea = tel_cdalinea
                        w_lancto.nmoperad = STRING(glb_nmoperad,"x(20)")
                        glb_nrdrecid      = w_lancto.nrdrecid.
                 
                 CLOSE QUERY q_lancto.
                 OPEN QUERY  q_lancto FOR EACH w_lancto NO-LOCK.
                 REPOSITION  q_lancto TO ROW   aux_ultlinha.
                 
                 RUN pi_cria_dev (INPUT  aux_cdcooper,
                                  INPUT  glb_dtmvtolt,
                                  INPUT  w_lancto.banco,
                                  INPUT  1 /* indevchq */,
                                  INPUT  crapfdc.nrdconta,
                                  INPUT  w_lancto.nrdocmto,
                                  INPUT  w_lancto.nrdctitg,  
                                  INPUT  w_lancto.vllanmto,
                                  INPUT  tel_cdalinea,
                                  INPUT  47,  /* cdhistor */
                                  INPUT  glb_cdoperad,
                                  INPUT  crapfdc.cdagechq,
                                  INPUT  crapfdc.nrctachq,
                                  OUTPUT glb_cdcritic).
                                   
                 IF   glb_cdcritic <> 0   THEN
                      DO:
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          PAUSE 1 NO-MESSAGE.
                          glb_cdcritic = 0.
                          RETURN.
                      END.
             END.
                                     
     END. /* Transaction */    
                          
     HIDE FRAME f_opcoes NO-PAUSE.

END PROCEDURE.

PROCEDURE proc_exec_dev:

     IF   CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                                 crapsol.dtrefere = glb_dtmvtolt  AND
                                 crapsol.nrsolici = 78            AND
                                 crapsol.nrseqsol = 6)            THEN
          DO:
              glb_cdcritic = 138.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              glb_cdcritic = 0.
              HIDE FRAME f_geradev.
              RETURN.
          END.         

    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       glb_cdcritic = 0.
       LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S" THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             HIDE FRAME f_geradev.
             RETURN.
         END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_cddsenha = ""
               glb_cdcritic = 742.
        RUN fontes/critic.p.
        UPDATE aux_cddsenha WITH FRAME f_senha.
        glb_cdcritic = 0.
        LEAVE.
    END.
    
    HIDE FRAME f_senha NO-PAUSE.
     
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
         glb_cdcritic = 79.
    ELSE
         IF  aux_cddsenha <> "ceepntv"   THEN 
             glb_cdcritic = 03.

    IF   glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             HIDE FRAME f_geradev.
             RETURN.
         END.

    DO TRANSACTION:
        CREATE crapsol.
        ASSIGN crapsol.cdcooper = glb_cdcooper
               crapsol.nrsolici = 78
               crapsol.dtrefere = glb_dtmvtolt
               crapsol.cdempres = 11
               crapsol.dsparame = ""
               crapsol.insitsol = 1
               crapsol.nrdevias = 0
               crapsol.nrseqsol = 6.
    END.
                                          
    HIDE MESSAGE  NO-PAUSE.
    
    HIDE FRAME f_geradev.
                                               
    RELEASE crapsol.

    MESSAGE "Executando devolucoes ...".
     
    PAUSE 1 NO-MESSAGE.

    /* Conecta o Banco Generico .................................... */
    IF   f_conectagener() THEN
         DO:
             RUN fontes/crps587.p (INPUT aux_cddevolu,
                                   INPUT glb_cdcooper,  /*1*/
                                   INPUT aux_cdcooper). /*2*/

             RUN p_desconectagener.
         END.
    ELSE
         DO:
             glb_cdcritic = 791.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.

             DO TRANSACTION:

                FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper AND
                                   crapsol.dtrefere = glb_dtmvtolt AND
                                   crapsol.nrsolici = 78           AND
                                   crapsol.nrseqsol = 6
                                   EXCLUSIVE-LOCK NO-ERROR.
                                   
                IF   NOT AVAILABLE crapsol THEN
                     DELETE crapsol.
             END.

             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             PAUSE 5 NO-MESSAGE.
             glb_cdcritic = 0.
         END.
         
END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_cria_dev:

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdbccxlt AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_inchqdev AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdocmto AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdctitg AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_vllanmto AS DECIMAL                             NO-UNDO.
DEF INPUT  PARAM par_cdalinea AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_cdagechq LIKE crapfdc.cdagechq                  NO-UNDO.
DEF INPUT  PARAM par_nrctachq LIKE crapfdc.nrctachq                  NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.


 IF  par_inchqdev = 1   THEN  /* cheque normal */
     DO:
         IF   CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper   AND
                                     crapdev.cdbanchq = aux_cdbanchq   AND
                                     crapdev.cdagechq = par_cdagechq   AND
                                     crapdev.nrctachq = par_nrctachq   AND
                                     crapdev.nrcheque = par_nrdocmto   AND
                                     crapdev.cdhistor = 46)            OR
              CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper   AND
                                     crapdev.cdbanchq = aux_cdbanchq   AND
                                     crapdev.cdagechq = par_cdagechq   AND
                                     crapdev.nrctachq = par_nrctachq   AND
                                     crapdev.nrcheque = par_nrdocmto   AND
                                     crapdev.cdhistor = par_cdhistor)  THEN
              DO:
                  par_cdcritic = 415.
                  RETURN.
              END.

         IF   (par_cdalinea > 40 AND par_cdalinea < 50) OR
              (par_cdalinea = 20)                       OR
              (par_cdalinea = 28)                       OR
              (par_cdalinea = 30)                       OR
              (par_cdalinea = 31)                       OR
              (par_cdalinea = 35)                       OR
              (par_cdalinea = 72)                       THEN
              .
         ELSE
              DO: 
                  CREATE crapdev.
                  ASSIGN crapdev.cdcooper = par_cdcooper
                         crapdev.dtmvtolt = par_dtmvtolt
                         crapdev.cdbccxlt = par_cdbccxlt
                         crapdev.nrdconta = par_nrdconta
                         crapdev.nrdctabb = par_nrctachq
                         crapdev.nrdctitg = par_nrdctitg
                         crapdev.nrcheque = par_nrdocmto
                         crapdev.vllanmto = par_vllanmto
                         crapdev.cdalinea = par_cdalinea
                         crapdev.cdoperad = par_cdoperad
                         crapdev.cdhistor = 46
                         crapdev.cdpesqui = "TCO"
                         crapdev.insitdev = 0
                         crapdev.cdbanchq = crapcop.cdbcoctl
                         crapdev.cdagechq = par_cdagechq
                         crapdev.nrctachq = par_nrctachq
                         crapdev.cdcooper = par_cdcooper.

                  IF   par_nrdctitg = ""   THEN   /* Nao eh conta-integracao */
                       crapdev.indctitg = FALSE.
                  ELSE
                       crapdev.indctitg = TRUE.

                  VALIDATE crapdev.
              END.

         CREATE crapdev.
         ASSIGN crapdev.cdcooper = par_cdcooper
                crapdev.dtmvtolt = par_dtmvtolt
                crapdev.cdbccxlt = par_cdbccxlt
                crapdev.nrdconta = par_nrdconta
                crapdev.nrdctabb = par_nrctachq
                crapdev.nrdctitg = par_nrdctitg
                crapdev.nrcheque = par_nrdocmto
                crapdev.vllanmto = par_vllanmto
                crapdev.cdalinea = par_cdalinea
                crapdev.cdoperad = par_cdoperad
                crapdev.cdhistor = par_cdhistor
                crapdev.cdpesqui = "TCO"
                crapdev.insitdev = 0
                crapdev.cdbanchq = crapcop.cdbcoctl
                crapdev.cdagechq = par_cdagechq
                crapdev.nrctachq = par_nrctachq
                crapdev.cdcooper = par_cdcooper.
                
         IF   par_nrdctitg = ""   THEN   /* Nao eh conta-integracao */
              crapdev.indctitg = FALSE.
         ELSE
              crapdev.indctitg = TRUE.       

         VALIDATE crapdev.

     END.

 IF  par_inchqdev = 5   THEN
     DO WHILE TRUE:

        FIND crabdev WHERE crabdev.cdcooper = par_cdcooper   AND
                           crabdev.cdbanchq = aux_cdbanchq   AND
                           crabdev.cdagechq = par_cdagechq   AND
                           crabdev.nrctachq = par_nrctachq   AND
                           crabdev.nrcheque = par_nrdocmto   AND
                           crabdev.cdhistor = par_cdhistor   AND  /* 47  191 */
                           crabdev.cdpesqui = "TCO"
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF   NOT AVAILABLE crabdev   THEN
             IF   LOCKED crabdev   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      par_cdcritic = 416.
                      RETURN.
                  END.

        IF   (crabdev.cdalinea > 40 AND crabdev.cdalinea < 50) OR
             (crabdev.cdalinea = 20)                           OR
             (crabdev.cdalinea = 28)                           OR
             (crabdev.cdalinea = 30)                           OR
             (crabdev.cdalinea = 31)                           OR
             (crabdev.cdalinea = 35)                           OR
             (crabdev.cdalinea = 72)                           THEN
              .
        ELSE
             DO:

                 FIND crapdev WHERE crapdev.cdcooper = par_cdcooper AND
                                    crapdev.cdbanchq = aux_cdbanchq AND
                                    crapdev.cdagechq = par_cdagechq AND
                                    crapdev.nrctachq = par_nrctachq AND
                                    crapdev.nrcheque = par_nrdocmto AND
                                    crapdev.cdhistor = 46           AND
                                    crapdev.cdpesqui = "TCO"
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapdev   THEN
                      IF   LOCKED crapdev   THEN
                           DO:
                               PAUSE 2 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               par_cdcritic = 416.
                               RETURN.
                           END.
               
                 DELETE crapdev.

             END.

        DELETE crabdev.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */


END PROCEDURE.

/* .......................................................................... */
