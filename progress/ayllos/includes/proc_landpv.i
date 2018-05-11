/* .............................................................................

   Programa: includes/proc_landpv.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Margarete
   Data    : Maio/2001                       Ultima atualizacao: 30/01/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures da tela landpv.

   Alteracoes: 27/08/2001 - Identificar depositos da cooperativa (Margarete).
      
               17/09/2001 - Criar histor 21 quando 386 (Margarete).

               31/01/2002 - Incluir procedure critica_contrato (Margarete).

               26/08/2002 - Alterado para tratar a agencia 3420 do
                            Banco do Brasil (Edson).

               03/10/2002 - Tratar liberacao de cheques (Margarete).

               11/03/2003 - Erro no numero do documento quando desmembra
                            o historico 3 e 4 (Margarete).

               22/08/2003 - Quando histor 386 criticar saldo (Margarete).

               09/06/2004 - Tratar historico 88 (Edson).

               06/01/2005 - Nao deixar estornar do emprestimos mais do
                            que ele pagou (Margarete).

               11/05/2005 - Validar o banco e a agencia (Edson).

               06/07/2005 - Alimentado campo cdcooper das tabelas craplcm e
                            crapdpb (Diego).

               29/09/2005 - Alteracao de crapchq p/ crapfdc 
                            (SQLWorks - Andre/Edson).
               
               10/11/2005 - Tratar campo cdcooper na leitura da tabela
                            crapcor (Edson).
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               20/12/2006 - Retirado tratamento Banco/Agencia 104/411 (Diego).

               14/02/2007 - Alterar consultas com indice crapfdc1 (David).

               02/03/2007 - Ajustes para o Bancoob (Magui).

               20/03/2007 - Leitura do crapcor, cheque com digito (Magui).
               
               25/05/2007 - Histor 428 nao pode quando preju (Magui).
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               21/07/2009 - Incluido boletos em emprestimo(Guilherme).
               
               03/12/2009 - Historico 3 e 4, calcular a data de liberacao do
                            cheque pela b1wgen0044.
                            
               06/12/2011 - Sustagco provissria (Andri R./Supero).             

               05/03/2012 - Adicionado validacao para novo tipo de emprestimo
                            (Tiago).
               
               11/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)
                            
               11/09/2014 - Incluir historicos 393 e 394 na busca da craplem.
                            (SD 198210 - Lucas R.)
                            
               24/06/2015 - #298239 Criada a procedure gera_log_critica para
                            quando o contrato nao for encontrato (Carlos)
                            
               09/11/2015 - Alterado procedure critica_contrato para tratar
                            pagamentos de boletos de emprestimo. 
                            (Reinert - PRJ 210)
                            
               27/11/2015 - Feito ajuste no tratamento para pagamento de boletos
                            de emprestimos. (Reinert)
                            
               11/08/2016 - Criar procedure para buscar o saldo disponivel do cooperado
                            (James)                            

               30/01/2017 - Nao permitir efetuar pagamento para o produto Pos-Fixado.
                            (Jaison/James - PRJ298)

........................................................................... */

PROCEDURE mostra_dados:

    DEF VAR h-b1wgen0044 AS HANDLE                             NO-UNDO.
    
    glb_cdcritic = 666.

    tel_cdbanchq = INT(SUBSTRING(tel_dsdocmc7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
    
    tel_cdagechq = INT(SUBSTRING(tel_dsdocmc7,05,04)) NO-ERROR.
 
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
     
    tel_cdcmpchq = INT(SUBSTRING(tel_dsdocmc7,11,03)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
 
    tel_nrcheque = INT(SUBSTRING(tel_dsdocmc7,14,06)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
                                                 
    tel_nrctachq = DECIMAL(SUBSTRING(tel_dsdocmc7,23,10)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.

    tel_nrctabdb = IF tel_cdbanchq = 1 
                      THEN DECIMAL(SUBSTRING(tel_dsdocmc7,25,08))
                      ELSE DECIMAL(SUBSTRING(tel_dsdocmc7,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
     
    glb_cdcritic = 0.
    
    /*  Calcula primeiro digito de controle  */
               
    glb_nrcalcul = DECIMAL(STRING(tel_cdcmpchq,"999") +
                           STRING(tel_cdbanchq,"999") +
                           STRING(tel_cdagechq,"9999") + "0").
                                  
    RUN fontes/digfun.p.

    tel_nrddigc1 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                 LENGTH(STRING(glb_nrcalcul)))).    
                   
    /*  Calcula segundo digito de controle  */

    glb_nrcalcul = tel_nrctachq * 10.
                                         
    RUN fontes/digfun.p.
                  
    tel_nrddigc2 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                 LENGTH(STRING(glb_nrcalcul)))).    
 
    /*  Calcula terceiro digito de controle  */

    glb_nrcalcul = tel_nrcheque * 10.
                                         
    RUN fontes/digfun.p.
                  
    /* Fazer calculo da data de liberacao do cheque */
    IF  tel_cdhistor = 3  OR
        tel_cdhistor = 4  THEN
        DO:
            /* Instanciar a BO que fara o calculo do bloqueio do cheque */
            RUN sistema/generico/procedures/b1wgen0044.p 
                PERSISTENT SET h-b1wgen0044.
            
            IF  NOT VALID-HANDLE(h-b1wgen0044)  THEN
                DO:
                    ASSIGN glb_cdcritic = 66.
                    RETURN.
                END.              
                  
            RUN calcula_bloqueio_cheque IN h-b1wgen0044
                                      (INPUT crapcop.cdcooper,
                                       INPUT glb_dtmvtolt,
                                       INPUT tel_cdagenci,
                                       INPUT tel_cdbanchq,
                                       INPUT tel_cdagechq,
                                       INPUT tel_vlcompel,
                                       OUTPUT tel_dtliblan,
                                       OUTPUT TABLE tt-erro).
            
            /* Remover a instancia da b1wgen0044 da memoria */
            DELETE PROCEDURE h-b1wgen0044.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND LAST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAIL tt-erro THEN
                        glb_cdcritic = tt-erro.cdcritic.
                    ELSE
                        glb_cdcritic = 13.

                    RETURN.
                END.
        END.
    
    ASSIGN tel_nrddigc3 = INT(SUBSTRING(STRING(glb_nrcalcul),
                          LENGTH(STRING(glb_nrcalcul))))
           tel_vlcheque = tel_vlcompel
           tel_dtlibcom = tel_dtliblan.                  

    /*  Verifica se o banco existe .......................................... */
    
    IF   NOT CAN-FIND(crapban WHERE crapban.cdbccxlt = tel_cdbanchq)   THEN
         DO:
             glb_cdcritic = 57.
             RETURN.
         END.

    /*  Verifica se a agencia existe ........................................ */

    IF   NOT CAN-FIND(crapagb WHERE crapagb.cddbanco = tel_cdbanchq   AND
                                    crapagb.cdageban = tel_cdagechq)  THEN
         DO:
             glb_cdcritic = 15.
             RETURN.
         END.
    
    /*  Mostra os dados lidos  */
                  
    CLEAR FRAME f_lanctos_compel ALL.
    
    ASSIGN aux_qtlincom = 0.
    
    IF   NOT aux_flgchqex   THEN
         DO:
             ASSIGN aux_qtlincom = 1.

             DISPLAY tel_cdcmpchq  tel_cdbanchq  tel_cdagechq 
                     tel_nrddigc1  tel_nrctabdb  tel_nrddigc2 
                     tel_nrcheque  tel_nrddigc3  tel_vlcheque
                     tel_dtlibcom
                     WITH FRAME f_lanctos_compel.

             DOWN WITH FRAME f_lanctos_compel.
         END.
    
    FOR EACH w-compel NO-LOCK USE-INDEX compel2:
        
        DISPLAY w-compel.cdcmpchq @ tel_cdcmpchq 
                w-compel.cdbanchq @ tel_cdbanchq
                w-compel.cdagechq @ tel_cdagechq 
                w-compel.nrddigc1 @ tel_nrddigc1
                w-compel.nrctabdb @ tel_nrctabdb
                w-compel.nrddigc2 @ tel_nrddigc2 
                w-compel.nrcheque @ tel_nrcheque
                w-compel.nrddigc3 @ tel_nrddigc3
                w-compel.vlcompel @ tel_vlcheque
                w-compel.dtlibcom @ tel_dtlibcom
                WITH FRAME f_lanctos_compel.
        
        DOWN WITH FRAME f_lanctos_compel.
        
        ASSIGN aux_qtlincom = aux_qtlincom + 1.
        
        IF   aux_qtlincom = 5   THEN
             LEAVE.
    END.
         
END PROCEDURE.

PROCEDURE ver_cheque:

    ASSIGN glb_cdcritic = 0
           aux_nrctcomp = 0
           aux_nrctachq = 0
           aux_nrdocchq = INT(STRING(tel_nrcheque,"999999") +
                              STRING(tel_nrddigc3,"9"))
                              
           glb_nrchqcdv = aux_nrdocchq
           glb_nrchqsdv = tel_nrcheque.
    
    FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                       crapfdc.cdbanchq = tel_cdbanchq   AND
                       crapfdc.cdagechq = tel_cdagechq   AND
                       crapfdc.nrctachq = tel_nrctabdb   AND
                       crapfdc.nrcheque = tel_nrcheque
                       USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                      
    IF   NOT AVAILABLE crapfdc  THEN
         RETURN.

    ASSIGN aux_nrctcomp = crapfdc.nrdconta
           aux_nrctachq = crapfdc.nrdctabb.

    IF   crapfdc.dtemschq = ?   THEN
         DO:
             glb_cdcritic = 108.
             RETURN.
         END.

    IF   crapfdc.dtretchq = ?   THEN
         DO:
             glb_cdcritic = 109.
             RETURN.
         END.
                      
    IF   crapfdc.incheque <> 0   THEN
         DO:
             IF   crapfdc.incheque = 1   THEN
                  glb_cdcritic = 96.
             ELSE
             IF   crapfdc.incheque = 2   THEN
                  RUN contra_ordem(crapfdc.incheque).
             ELSE
             IF   crapfdc.incheque = 5   THEN
                  glb_cdcritic = 97.
             ELSE
             IF   crapfdc.incheque = 8   THEN
                  glb_cdcritic = 320.
             ELSE
                  glb_cdcritic = 100.
                                    
             RETURN.
         END.
         
    IF   crapfdc.tpcheque = 3   AND /* cheque salario */
         crapfdc.vlcheque = tel_vlcompel   THEN
         DO:
             glb_cdcritic = 91.
             RETURN. 
         END.
                  
    RUN ver_associado.
                  
    IF   glb_cdcritic > 0   THEN
         RETURN.
     
/*** Magui fora com a reformulacao do crapfdc
    /*  Formata conta integracao  */
            
    RUN fontes/digbbx.p (INPUT  tel_nrctabdb,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).
    
    IF  (tel_cdbanchq = 1                            AND  
         CAN-DO("95,3420",STRING(tel_cdagechq))      AND
         CAN-DO(aux_lscontas,STRING(tel_nrctabdb)))  OR
         
        (tel_cdbanchq = 1                            AND   
         CAN-DO("95,3420",STRING(tel_cdagechq))      AND
         aux_nrdctitg <> "")   THEN  
         DO:
             IF   CAN-DO(aux_lsconta1,STRING(tel_nrctabdb))  OR
                 (aux_nrdctitg <> "" AND
                  CAN-DO("95,3420",STRING(tel_cdagechq))) THEN
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                         crapfdc.cdbanchq = tel_cdbanchq   AND
                                         crapfdc.cdagechq = tel_cdagechq   AND
                                         crapfdc.nrctachq = tel_nrctachq   AND
                                         crapfdc.nrcheque = tel_nrcheque
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                      
                      IF   NOT AVAILABLE crapfdc  THEN
                           DO:
                               glb_cdcritic = 108.
                               RETURN.
                           END.

                      ASSIGN aux_nrctcomp = crapfdc.nrdconta
                             aux_nrctachq = crapfdc.nrdctabb.

                      IF   crapfdc.dtemschq = ?   THEN
                           DO:
                               glb_cdcritic = 108.
                               RETURN.
                           END.

                      IF   crapfdc.dtretchq = ?   THEN
                           DO:
                               glb_cdcritic = 109.
                               RETURN.
                           END.
                      
                      IF   crapfdc.incheque <> 0   THEN
                           DO:
                               IF   crapfdc.incheque = 1   THEN
                                    glb_cdcritic = 96.
                               ELSE
                               IF   crapfdc.incheque = 2   THEN
                                    RUN contra_ordem(crapfdc.incheque).
                               ELSE
                               IF   crapfdc.incheque = 5   THEN
                                    glb_cdcritic = 97.
                               ELSE
                               IF   crapfdc.incheque = 8   THEN
                                    glb_cdcritic = 320.
                               ELSE
                                    glb_cdcritic = 100.
                                    
                               RETURN.
                           END.
                  END.
             ELSE
             IF   CAN-DO(aux_lsconta2,STRING(tel_nrctabdb))   THEN
                  DO:
                      glb_cdcritic = 646.           /*  CHEQUE TB  */
                      RETURN.
                  END.
             ELSE
             IF   CAN-DO(aux_lsconta3,STRING(tel_nrctabdb))   THEN
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                         crapfdc.cdbanchq = tel_cdbanchq   AND
                                         crapfdc.cdagechq = tel_cdagechq   AND
                                         crapfdc.nrctachq = tel_nrctachq   AND
                                         crapfdc.nrcheque = tel_nrcheque
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapfdc   THEN
                           DO:
                               glb_cdcritic = 286.
                               RETURN.
                           END.

                      IF   crapfdc.vlcheque = tel_vlcompel   THEN
                           DO:
                               ASSIGN aux_nrctcomp = crapfdc.nrdconta
                                      aux_nrctachq = crapfdc.nrdctabb.
                                    
                               IF   crapfdc.incheque <> 0   THEN
                                    DO:
                                        IF   crapfdc.incheque = 1   THEN
                                             glb_cdcritic = 96.
                                        ELSE
                                        IF   crapfdc.incheque = 2   THEN
                                            RUN contra_ordem (crapfdc.incheque).
                                        ELSE
                                        IF   crapfdc.incheque = 5   THEN
                                             glb_cdcritic = 97.
                                        ELSE
                                        IF   crapfdc.incheque = 8   THEN
                                             glb_cdcritic = 320.
                                        ELSE
                                             glb_cdcritic = 100.
                                    
                                        RETURN.
                                    END.
                           END.
                      ELSE
                           DO:
                               glb_cdcritic = 91.
                               RETURN. 
                           END.
                  END.
             ELSE
                  RETURN.      /*  Qualquer outra conta da agencia 95/3420  */
                  
             RUN ver_associado.
                  
             IF   glb_cdcritic > 0   THEN
                  RETURN.
         END.
    ELSE
    IF   tel_cdbanchq = 756   AND   tel_cdagechq = aux_cdagebcb   THEN 
         DO:
             IF   CAN-DO(aux_lsconta3,STRING(tel_nrctabdb))   THEN
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                         crapfdc.cdbanchq = tel_cdbanchq   AND
                                         crapfdc.cdagechq = tel_cdagechq   AND
                                         crapfdc.nrctachq = tel_nrctachq   AND
                                         crapfdc.nrcheque = tel_nrcheque
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapfdc   THEN
                           DO:
                               glb_cdcritic = 286.
                               RETURN.
                           END.

                      ASSIGN aux_nrdocmto = crapfdc.nrcheque.
                        
                      IF   crapfdc.vlcheque = tel_vlcompel   THEN
                           DO:
                               ASSIGN aux_nrctcomp = crapfdc.nrdconta
                                      aux_nrctachq = crapfdc.nrdctabb.
                                    
                               RUN ver_associado.
                               
                               IF   glb_cdcritic > 0   THEN
                                    RETURN.
                   
                               IF   crapfdc.incheque <> 0   THEN
                                    DO:
                                        IF   crapfdc.incheque = 1   THEN
                                             glb_cdcritic = 96.
                                        ELSE
                                        IF   crapfdc.incheque = 2   THEN
                                            RUN contra_ordem (crapfdc.incheque).
                                        ELSE
                                        IF   crapfdc.incheque = 5   THEN
                                             glb_cdcritic = 97.
                                        ELSE
                                        IF   crapfdc.incheque = 8   THEN
                                             glb_cdcritic = 320.
                                        ELSE
                                             glb_cdcritic = 100.
                                    
                                        RETURN.
                                    END.
                           END.
                      ELSE
                           DO:
                               glb_cdcritic = 91.
                               RETURN. 
                           END.
      
                  END.
            
             ELSE 
             DO: 
                  RUN ver_associado.
                    
                  IF   glb_cdcritic > 0   THEN
                       RETURN.

                  FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                     crapfdc.cdbanchq = tel_cdbanchq   AND
                                     crapfdc.cdagechq = tel_cdagechq   AND
                                     crapfdc.nrctachq = tel_nrctachq   AND
                                     crapfdc.nrcheque = tel_nrcheque
                                     USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                      
                  IF   NOT AVAILABLE crapfdc  THEN
                       DO:
                           glb_cdcritic = 108.
                           RETURN.
                       END.
              
                  ASSIGN aux_nrctachq = crapfdc.nrdctabb.
             
                  IF   crapfdc.dtemschq = ?   THEN
                       DO:
                           glb_cdcritic = 108.
                           RETURN.
                       END.

                  IF   crapfdc.dtretchq = ?   THEN
                       DO:
                           glb_cdcritic = 109.
                           RETURN.
                       END.
                   
                  IF   crapfdc.incheque <> 0   THEN
                       DO:
                           IF   crapfdc.incheque = 1   THEN
                                glb_cdcritic = 96.
                           ELSE
                           IF   crapfdc.incheque = 2   THEN
                                RUN contra_ordem (crapfdc.incheque).
                           ELSE
                           IF   crapfdc.incheque = 5   THEN
                                glb_cdcritic = 97.
                           ELSE
                           IF   crapfdc.incheque = 8   THEN
                                glb_cdcritic = 320.
                           ELSE
                                glb_cdcritic = 100.
                                    
                           RETURN.
                       END.
                       
             END.
         END.
   ELSE
         RETURN.            /*  Qualquer outro banco  */

   ******************/
END PROCEDURE.

PROCEDURE ver_associado:

    IF   aux_nrctcomp > 0   THEN
         DO WHILE TRUE:
    
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = aux_nrctcomp NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapass   THEN
                 DO:
                     glb_cdcritic = 9.
                     RETURN.
                 END.
 
            IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                 DO:
                     glb_cdcritic = 695.
                     RETURN.
                 END.

            IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                 DO:
                     FIND FIRST craptrf WHERE 
                                craptrf.cdcooper = glb_cdcooper      AND
                                craptrf.nrdconta = crapass.nrdconta  AND
                                craptrf.tptransa = 1                 NO-LOCK
                                USE-INDEX craptrf1 NO-ERROR.

                     IF   NOT AVAILABLE craptrf THEN
                          DO:
                              glb_cdcritic = 95.
                              RETURN.
                          END.

                     glb_cdcritic = 156.
                     RUN fontes/critic.p.

                     MESSAGE glb_dscritic STRING(craptrf.nrdconta,"zzzz,zzz,9")
                                          "para o numero" 
                                          STRING(craptrf.nrsconta,"zzzz,zzz,9").

                     ASSIGN aux_nrctcomp = craptrf.nrsconta
                            glb_cdcritic = 0.
                     
                     NEXT.
                 END.

            IF   crapass.dtelimin <> ? THEN
                 DO:
                     glb_cdcritic = 410.
                     RETURN.
                 END.
          
            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE contra_ordem:

    DEF INPUT PARAMETER par_incheque AS INT                  NO-UNDO.  
    
    IF   par_incheque = 1   OR
         par_incheque = 2   THEN
         DO:
             FIND crapcor WHERE crapcor.cdcooper = glb_cdcooper      AND
                                crapcor.cdbanchq = crapfdc.cdbanchq  AND
                                crapcor.cdagechq = crapfdc.cdagechq  AND
                                crapcor.nrctachq = crapfdc.nrctachq  AND
                                crapcor.nrcheque = 
                                 INT(STRING(crapfdc.nrcheque,"999999") +
                                       STRING(crapfdc.nrdigchq,"9")) AND
                                crapcor.flgativo = TRUE
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapcor   THEN
                  DO:
                      glb_cdcritic = 101.
                      RETURN.
                  END.

             FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                craphis.cdhistor = crapcor.cdhistor
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craphis   THEN
                  glb_dscritic = FILL("*",50).
             ELSE
                  glb_dscritic = craphis.dshistor.

             BELL.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                aux_confirma = "N".

                MESSAGE "Aviso de" STRING(crapcor.dtemscor,"99/99/9999") 
                        "->" glb_dscritic.

                glb_cdcritic = 78.
                RUN fontes/critic.p.
                glb_cdcritic = 0.
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                  aux_confirma <> "S" THEN
                  DO:
                      glb_cdcritic = 257.
                      RETURN.
                  END.
         END.

END PROCEDURE.

PROCEDURE critica_contrato:

   DEF VAR flg_next AS LOGI NO-UNDO.
   
   ASSIGN glb_dscritic = "".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
      flg_next = FALSE.
      
      IF   glb_cdcritic <> 0  OR 
           glb_dscritic <> "" THEN
           DO:
               IF glb_dscritic = "" THEN
                  RUN fontes/critic.p.
               BELL.
               IF   glb_cdcritic = 634   THEN
                    MESSAGE glb_dscritic STRING(aux_ttjpgepr,"ZZZ,ZZ9.99").
               ELSE
                    MESSAGE glb_dscritic.

               RUN gera_log_critica.
                    
               ASSIGN glb_cdcritic = 0
                      glb_dscritic = "".
           END.
      
      UPDATE tel_nrctremp WITH FRAME f_nrctremp.
              
      HIDE MESSAGE NO-PAUSE.          

      FOR FIRST crapprm
          WHERE crapprm.cdcooper = glb_cdcooper AND
                crapprm.cdacesso = "COBEMP_BLQ_RESG_CC"
        NO-LOCK:

        IF  crapprm.dsvlrprm = "S" THEN
            DO:
                /* buscar boletos de contratos em aberto */
                FOR EACH tbepr_cobranca FIELDS (cdcooper nrdconta_cob nrcnvcob nrboleto nrctremp)
                   WHERE tbepr_cobranca.cdcooper = glb_cdcooper AND
                         tbepr_cobranca.nrdconta = tel_nrdctabb AND
                         tbepr_cobranca.nrctremp = tel_nrctremp
                  NO-LOCK:
                  
                      FOR FIRST crapcob FIELDS (dtvencto vltitulo)
                          WHERE crapcob.cdcooper = tbepr_cobranca.cdcooper
                            AND crapcob.nrdconta = tbepr_cobranca.nrdconta_cob
                            AND crapcob.nrcnvcob = tbepr_cobranca.nrcnvcob
                            AND crapcob.nrdocmto = tbepr_cobranca.nrboleto
                            AND crapcob.incobran = 0 NO-LOCK:
                          
                                ASSIGN glb_cdcritic = 0
                                       glb_dscritic = "Boleto do contrato " + STRING(tbepr_cobranca.nrctremp) + " em aberto." +
                                                      " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +
                                                      " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + ".".    
                                LEAVE.
                      END.
            
                      /* verificar se o boleto do contrato está em pago, pendente de processamento */
                      FOR FIRST crapcob FIELDS (dtvencto vltitulo dtdpagto)
                          WHERE crapcob.cdcooper = tbepr_cobranca.cdcooper
                            AND crapcob.nrdconta = tbepr_cobranca.nrdconta_cob
                            AND crapcob.nrcnvcob = tbepr_cobranca.nrcnvcob
                            AND crapcob.nrdocmto = tbepr_cobranca.nrboleto
                            AND crapcob.incobran = 5 NO-LOCK:
              
                              FOR FIRST crapret      
                                  WHERE crapret.cdcooper = crapcob.cdcooper    
                                    AND crapret.nrdconta = crapcob.nrdconta     
                                    AND crapret.nrcnvcob = crapcob.nrcnvcob     
                                    AND crapret.nrdocmto = crapcob.nrdocmto     
                                    AND crapret.cdocorre = 6     
                                    AND crapret.dtocorre = crapcob.dtdpagto     
                                    AND crapret.flcredit = 0     
                                    NO-LOCK:    
            
                                  ASSIGN glb_cdcritic = 0
                                         glb_dscritic = "Boleto do contrato " + STRING(tbepr_cobranca.nrctremp) + 
                                                        " esta pago pendente de processamento." +       
                                                        " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +      
                                                        " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + ".".    
                                  LEAVE.
                              END.
                      END.   
                END.
            END.
      END.
      IF  glb_cdcritic <> 0  OR
          glb_dscritic <> "" THEN
          NEXT.

      FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                         crapepr.nrdconta = tel_nrdctabb   AND
                         crapepr.nrctremp = tel_nrctremp   NO-LOCK NO-ERROR.
                             
      IF   NOT AVAILABLE crapepr   THEN
           DO:
               ASSIGN glb_cdcritic = 356.
               NEXT.
           END.
                 
      IF   crapepr.tpemprst = 1 OR
	       crapepr.tpemprst = 2 THEN
           DO:
               ASSIGN glb_cdcritic = 946.
               NEXT. 
           END.      
                 
      IF   tel_cdhistor = 428   AND
           crapepr.inprejuz = 1 THEN
           DO:
               ASSIGN glb_cdcritic = 865.
               NEXT.
           END.
         
      IF    crapepr.inliquid > 0 THEN
            DO:
                his_dtultpag = glb_dtmvtolt - DAY(glb_dtmvtolt).
                his_dtultpag = his_dtultpag - DAY(his_dtultpag).
 
                IF   crapepr.dtultpag <= his_dtultpag   THEN
                     DO:
                         MESSAGE "Emprestimo liquidado em"
                                 STRING(crapepr.dtultpag,"99/99/9999").
                         NEXT.
                     END.
            END.

      ASSIGN aux_ttjpgepr = 0.
      IF   tel_cdhistor = 317   THEN
           DO:
               FOR EACH craplem WHERE craplem.cdcooper  = glb_cdcooper      AND
                                      craplem.dtmvtolt <= glb_dtmvtolt      AND
                                      craplem.nrdconta  = crapepr.nrdconta  AND
                                      craplem.nrctremp  = crapepr.nrctremp  AND
                        CAN-DO("91,92,93,95,88,393,394",STRING(craplem.cdhistor))
                                      NO-LOCK:
                                      
                   IF   craplem.cdhistor = 88   THEN
                        ASSIGN aux_ttjpgepr = aux_ttjpgepr - craplem.vllanmto.
                   ELSE
                        ASSIGN aux_ttjpgepr = aux_ttjpgepr + craplem.vllanmto.
               END.                         
               IF   tel_vllanmto > aux_ttjpgepr   THEN
                    DO:
                        ASSIGN glb_cdcritic = 634.
                        NEXT.
                    END.
           END.
           
      /* Verifica se eh uma linha de credito para boletos na internet */
      FIND craplcr WHERE craplcr.cdcooper = crapepr.cdcooper AND
                         craplcr.cdlcremp = crapepr.cdlcremp AND
                         craplcr.cdusolcr = 3
                         NO-LOCK NO-ERROR.
                         
      IF  AVAIL craplcr  THEN
          DO:
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE tel_nrboleto WITH FRAME f_nrboleto.
                
                FIND crapcob WHERE crapcob.cdcooper = crapepr.cdcooper AND
                                   crapcob.nrctasac = crapepr.nrdconta AND
                                   crapcob.nrctremp = crapepr.nrctremp AND
                                   crapcob.nrdocmto = tel_nrboleto
                                   NO-LOCK NO-ERROR.
                                   
                IF  AVAIL crapcob  THEN
                    DO:
                        IF  crapcob.dtdbaixa = ?  THEN
                            DO:
                                flg_next = TRUE.
                                MESSAGE "O boleto deve estar baixado.".
                            END.
                    END.
                ELSE
                    DO:
                        flg_next = TRUE.
                        MESSAGE "Boleto nao encontrado.".
                    END.
                LEAVE.
            END.
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                flg_next  THEN
                DO:
                    HIDE FRAME f_nrboleto.
                    NEXT.
                END.
                
          END.
      
      his_nrctremp = crapepr.nrctremp.        
              
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
     
END PROCEDURE.

PROCEDURE libera_cheques:

   ASSIGN aux_nrdoclcm = tel_nrdocmto.
   
   FOR EACH w-compel BREAK BY w-compel.tpdmovto:
             
       IF   FIRST-OF(w-compel.tpdmovto)   THEN
            ASSIGN aux_vllanmto = 0.
            
       ASSIGN aux_vllanmto      = aux_vllanmto + w-compel.vlcompel
              w-compel.nrseqlcm = tel_nrseqdig
              w-compel.nrdoclcm = aux_nrdoclcm.
            
       IF   LAST-OF(w-compel.tpdmovto)   THEN  
            DO:
                /* Formata conta integracao */
                RUN fontes/digbbx.p (INPUT  tel_nrdctabb,
                                     OUTPUT glb_dsdctitg,
                                     OUTPUT glb_stsnrcal).
         
                CREATE craplcm.
                ASSIGN craplcm.dtmvtolt = tel_dtmvtolt 
                       craplcm.cdagenci = tel_cdagenci
                       craplcm.cdbccxlt = tel_cdbccxlt 
                       craplcm.nrdolote = tel_nrdolote
                       craplcm.nrdconta = aux_nrdconta
                       craplcm.nrdocmto = aux_nrdoclcm
                       craplcm.vllanmto = aux_vllanmto 
                       craplcm.cdhistor = tel_cdhistor
                       craplcm.nrseqdig = tel_nrseqdig 
                       craplcm.nrdctabb = tel_nrdctabb
                       craplcm.nrdctitg = glb_dsdctitg
                       craplcm.cdpesqbb = ""
                       craplcm.cdcooper = glb_cdcooper

                       craplot.nrseqdig = tel_nrseqdig
                       craplot.qtcompln = craplot.qtcompln + 1.
               VALIDATE craplcm.  
               IF   aux_indebcre = "D"   THEN
                    craplot.vlcompdb = craplot.vlcompdb + aux_vllanmto.
               ELSE
                    IF   aux_indebcre = "C"   THEN
                       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto.

               IF   CAN-DO("3,4,5",STRING(aux_inhistor))   THEN
                    DO:
              
                        CREATE crapdpb.
                        ASSIGN crapdpb.nrdconta = aux_nrdconta
                               crapdpb.cdhistor = tel_cdhistor
                               crapdpb.nrdocmto = aux_nrdoclcm
                               crapdpb.dtmvtolt = tel_dtmvtolt
                               crapdpb.cdagenci = tel_cdagenci
                               crapdpb.cdbccxlt = tel_cdbccxlt
                               crapdpb.nrdolote = tel_nrdolote
                               crapdpb.vllanmto = aux_vllanmto
                               crapdpb.inlibera = 1
                               crapdpb.dtliblan = ?
                               crapdpb.cdcooper = glb_cdcooper.                               
                        
                        IF   CAN-DO("403",STRING(tel_cdhistor))   THEN
                             DO:
                                 IF   w-compel.tpdmovto = 1   THEN
                                      crapdpb.dtliblan = glb_dtlibdma.
                                 ELSE
                                      crapdpb.dtliblan = glb_dtlibdpr.
                             END.
                        ELSE
                        IF   CAN-DO("404",STRING(tel_cdhistor))   THEN
                             DO:
                                 IF   w-compel.tpdmovto = 1   THEN
                                      crapdpb.dtliblan = glb_dtlibfma.
                                 ELSE
                                      crapdpb.dtliblan = glb_dtlibfpr.
                             END.
                        ELSE
                        IF   CAN-DO("3,4",STRING(tel_cdhistor))   THEN
                             crapdpb.dtliblan = tel_dtlibcom.
                        VALIDATE crapdpb.     
                   END.


 
               IF   NOT LAST(w-compel.tpdmovto)   THEN
                    DO:
                        ASSIGN tel_nrseqdig = tel_nrseqdig + 1
                               aux_nrdocchr = "9" + FILL("0",
                                   LENGTH(STRING(craplcm.nrdocmto)))
                               aux_nrdoclcm = DEC(aux_nrdocchr) +
                                                   craplcm.nrdocmto.
      
                    END.
              
            END.
            
   END.         
            
END PROCEDURE.

PROCEDURE critica_dtliblan:

   IF   tel_dtliblan <> ?   THEN
        DO:
            IF   tel_cdhistor = 2   OR
                 tel_cdhistor = 6   THEN
                 DO:
                     IF   tel_dtliblan <= glb_dtmvtolt      OR
                          tel_dtliblan > glb_dtmvtolt + 30  OR
                          CAN-DO("1,7",
                                  STRING(WEEKDAY(tel_dtliblan)))   THEN 
                          DO:
                              glb_cdcritic = 13.
                              NEXT-PROMPT tel_dtliblan WITH FRAME f_landpv.
                          END.
                     ELSE
                          DO:
                              FIND crapfer WHERE 
                                   crapfer.cdcooper = glb_cdcooper AND
                                   crapfer.dtferiad = tel_dtliblan 
                                   NO-LOCK NO-ERROR.

                              IF   AVAILABLE crapfer   THEN
                                   DO:
                                       glb_cdcritic = 13.
                                       NEXT-PROMPT tel_dtliblan
                                                   WITH FRAME f_landpv.
                                   END.
                          END.
                 END.
                 ELSE
                      IF   tel_cdhistor = 403   THEN
                           DO:
                               IF   tel_dtliblan < glb_dtlibdma   OR
                                    tel_dtliblan > glb_dtlibdpr  THEN
                                    DO:
                                        glb_cdcritic = 13.
                                        NEXT-PROMPT tel_dtliblan
                                                    WITH FRAME f_landpv.
                                    END.
                           END.
                      ELSE
                           IF   tel_cdhistor = 404   THEN
                                DO:
                                    IF   tel_dtliblan < glb_dtlibfma   OR
                                         tel_dtliblan > glb_dtlibfpr  THEN
                                         DO:
                                             glb_cdcritic = 13.
                                             NEXT-PROMPT tel_dtliblan
                                                         WITH FRAME f_landpv.
                                         END.
                                END.
                           ELSE                                                                                  tel_dtliblan = ?. 
        END.         
   ELSE
        IF   tel_cdhistor = 2   OR
             tel_cdhistor = 6   OR
             tel_cdhistor = 403 OR
             tel_cdhistor = 404 THEN
             DO:
                 glb_cdcritic = 13.
                 NEXT-PROMPT tel_dtliblan WITH FRAME f_landpv.
             END.

END PROCEDURE.

PROCEDURE verifica_saldo:
  
   RUN siscaixa/web/dbo/b1crap02.p PERSISTENT SET h-b1crap02.

   RUN  consulta-conta IN h-b1crap02(INPUT crapcop.nmrescop,
                                     INPUT craplot.cdagenci,
                                     INPUT craplot.nrdcaixa,
                                     INPUT aux_nrctcomp,
                                     OUTPUT TABLE tt-conta).
   DELETE PROCEDURE h-b1crap02.

   IF  RETURN-VALUE = "NOK" THEN
       DO:
           ASSIGN glb_cdcritic = 10.
           RETURN.
       END.
          
   ASSIGN aux_vllibera = 0
          aux_flgctrsl = NO.
          
   FIND FIRST tt-conta NO-LOCK NO-ERROR.
   IF   AVAIL tt-conta   THEN 
        DO:
            IF   tt-conta.cheque-salario = 0   THEN
                 DO:
                    /*----Antigo  
                    IF  (tt-conta.acerto-conta + tt-conta.limite-credito) < 
                         tel_vlcompel   THEN
                         DO:
                             ASSIGN aux_flgctrsl = YES
                                    aux_vlsddisp = 
                                tt-conta.acerto-conta + tt-conta.limite-credito
                                    aux_vllibera    = (tt-conta.acerto-conta - 
                                                       tel_vlcompel) * -1
                                    aux_mensagem = "Saldo= " +
                    TRIM(string(tt-conta.acerto-conta,"zzz,zzz,zzz,zz9.99-")) +
                                                   "  Limite Credito= " +
                  TRIM(string(tt-conta.limite-credito,"zzz,zzz,zzz,zz9.99-")) +
                                                   "  EXCEDIDO= " + 
                           TRIM(string(aux_vllibera,"zzz,zzz,zzz,zz9.99-"))
                                    aux_mensagem = aux_mensagem +
                                                   " CONFIRMA(S/N)".
                         END.
                     ------*/
                   
                    ASSIGN de-valor-bloqueado = tt-conta.bloqueado +
                                                tt-conta.bloq-praca +
                                                tt-conta.bloq-fora-praca.
                    ASSIGN de-valor-liberado = tt-conta.acerto-conta -
                                               de-valor-bloqueado.
   
                    IF  de-valor-liberado  + tt-conta.limite-credito
                        < tel_vlcompel THEN
                        DO:
        ASSIGN aux_flgctrsl = YES.
        ASSIGN aux_vlsddisp =  de-valor-liberado + tt-conta.limite-credito
               aux_vllibera = (de-valor-liberado - tel_vlcompel) * -1.
        
        ASSIGN aux_mensagem =
           "Saldo " +
           TRIM(string(de-valor-liberado,"zzz,zzz,zzz,zz9.99-"))  + 
           " Limite " +
           TRIM(string(tt-conta.limite-credito,"zzz,zzz,zzz,zz9.99-")) +
           " Excedido " + TRIM(string(aux_vllibera,"zzz,zzz,zzz,zz9.99-")) 
                                                                   +
           " Bloq. " + TRIM(string(de-valor-bloqueado,"zzz,zzz,zzz,zz9.99-"))
                                             aux_mensagem = aux_mensagem +
                                                   " CONFIRMA(S/N)".
                       
                        END.
                 END.
        END.
 
END PROCEDURE.


PROCEDURE gera_log_critica:

  UNIX SILENT VALUE(
        "echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - "      +
        STRING(TIME,"HH:MM:SS")                                  + 
        " - CRITICA CONTRATO " + "'     -->'"                    +
        " Operador: " + glb_cdoperad                             +

        " PA:          " + STRING(tel_cdagenci,"999")       + 
        " Banco/Caixa: " + STRING(tel_cdbccxlt,"999")       +  
        " Lote: "     + TRIM(STRING(tel_nrdolote,"zzz,zz9"))     + 

        " Hst: "      + STRING(tel_cdhistor)                      +
        " Conta: "    + TRIM(STRING(aux_nrdconta,"zz,zzz,zzz,z")) + 
        " Bco: "      + STRING(tel_cdbccxlt,"999")                + 
        " Age:  "     + STRING(tel_cdagenci,"999")                + 
        " Doc: "      + STRING(tel_nrdocmto)                      +
        " Valor: "    + TRIM(STRING(tel_vllanmto,
                                 "zzzzzz,zzz,zz9.99"))           +
        " Contrato: " + STRING(tel_nrctremp)                     +
        " - "         + glb_dscritic                             +
        " >> log/landpv.log").

END PROCEDURE.


PROCEDURE obtem_saldo_dia_prog:

  DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  
  DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
  DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-saldos.
  
  EMPTY TEMP-TABLE tt-saldos.
  
  TRANSACAO:
  DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
  
     /* Utilizar o tipo de busca A, para carregar do dia anterior
      (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
    RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nrdconta,
                                             INPUT par_dtmvtolt,
                                             INPUT "A", /* Tipo Busca */
                                             OUTPUT 0,
                                             OUTPUT "").
  
    CLOSE STORED-PROC pc_obtem_saldo_dia_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
  
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
  
    ASSIGN par_cdcritic = 0
           par_dscritic = ""
           par_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                              WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
           par_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                              WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 

    FIND FIRST wt_saldos NO-LOCK NO-ERROR.
    IF AVAIL wt_saldos THEN
       DO:
           CREATE tt-saldos.
           BUFFER-COPY wt_saldos TO tt-saldos.
           VALIDATE tt-saldos.
       END.
       
  END. /** Fim do DO TRANSACTION - TRANSACAO **/
              
END PROCEDURE.
/* .......................................................................... */
