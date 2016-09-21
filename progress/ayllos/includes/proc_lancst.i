/* .............................................................................

   Programa: includes/proc_lancst.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                     Ultima atualizacao: 04/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures da tela lancst.

   Alteracoes: 24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               26/08/2002 - Alterado para tratar a agencia 3420 do
                            Banco do Brasil (Edson).

               20/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               11/05/2005 - Validar o banco e a agencia (Edson).

               16/05/2005 - Tratamento Conta Integracao(Mirtes).

               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               03/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               30/11/2005 - Ajustes na conversao crapchq/crapfdc (Edson).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
               20/12/2006 - Retirado tratamento Banco/Agencia 104/411 (Diego).

               14/02/2007 - Alterar consultas com indice crapfdc1 (David).

               12/03/2007 - Ajustes para o Bancoob (Magui).

               28/03/2007 - Procedure para confirmar redesconto (David).
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               26/03/2010 - Nao custodiar cheques do proprio cooperado 
                            (Guilherme).
                            
               17/06/2010 - Remoção da conferência da agência 95 (Vitor).
                            
               08/07/2010 - Tratamento para Compe 085 (Ze).
               
               07/12/2011 - Sustação provisória (André R./Supero).
               
               25/09/2012 - Inclusao de verificacao de cheque em custodia
                            (Lucas R.).             
                            
               07/01/2013 - Tratamento na procedure ver_cheque para as contas
                            migradas da Viacredi para AltoVale, para o banco
                            085. Apenas para cdcooper = 1. (Fabricio)
                            
               14/01/2013 - Tratamento para AltoVale (Ze).
               
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).             
               
               23/04/2014 - Alterado para nao mostrar FRAME f_lancst quando 
                            for opcao "L". (Reinert)
                            
               11/06/2014 - Somente emitir a crítica 950 apenas se a 
                            crapfdc.dtlibtic >= data do movimento (SD. 163588 - Lunelli)
                            
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               04/02/2015 - Ajustes na procedure ver_cheque ref a Migracao e 
                            Incorporacao. (SD 238692 - Rafael)
               
               06/03/2015 - Corrigir condição de IF na rotina ver_cheque, afim de evitar erro
                            relatado no chamado 261872 ( Renato - Supero )
                            
............................................................................. */

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


PROCEDURE mostra_dados:

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

    tel_nrctachq = IF tel_cdbanchq = 1 
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
                  
    tel_nrddigc3 = INT(SUBSTRING(STRING(glb_nrcalcul),
                          LENGTH(STRING(glb_nrcalcul)))).    
 
    /*  Verifica se o banco existe .......................................... */
    
    FOR FIRST crapban FIELDS (cdbccxlt) 
                       WHERE crapban.cdbccxlt = tel_cdbanchq NO-LOCK.
    END.
    
    IF   NOT AVAILABLE crapban   THEN
         DO:
             glb_cdcritic = 57.
             RETURN.
         END.

    /*  Verifica se a agencia existe ........................................ */

    FOR FIRST crapagb FIELDS (cddbanco)
                      WHERE crapagb.cddbanco = tel_cdbanchq AND
                            crapagb.cdageban = tel_cdagechq NO-LOCK.
    END.
                       
    IF   NOT AVAILABLE crapagb   THEN
         DO:
             glb_cdcritic = 15.
             RETURN.
         END.
   
    /*  Mostra os dados lidos  */
    IF  glb_cddopcao <> "L" THEN
        DISPLAY tel_cdcmpchq tel_cdbanchq tel_cdagechq 
                tel_nrddigc1 tel_nrctachq tel_nrddigc2 
                tel_nrcheque tel_nrddigc3 WITH FRAME f_lancst.

END PROCEDURE.

PROCEDURE ver_associado:

    IF   aux_nrdconta > 0   THEN
         DO WHILE TRUE:   

            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = aux_nrdconta  
                               NO-LOCK NO-ERROR NO-WAIT.

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
                                craptrf.cdcooper = glb_cdcooper     AND 
                                craptrf.nrdconta = crapass.nrdconta AND
                                craptrf.tptransa = 1 
                                USE-INDEX craptrf1 NO-LOCK NO-ERROR.

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

                     ASSIGN aux_nrdconta = craptrf.nrsconta
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

PROCEDURE ver_cheque:

    DEF BUFFER b-crapcop FOR crapcop.

    ASSIGN glb_cdcritic = 0
           aux_nrdconta = 0
           aux_nrdctabb = 0
           aux_nrtalchq = 0
           aux_nrdocmto = INT(STRING(tel_nrcheque,"999999") +
                              STRING(tel_nrddigc3,"9")).
    
    /*** Verifica a existencia de conta de integracao ***/
    ASSIGN aux_ctpsqitg = tel_nrctachq.
    RUN existe_conta_integracao.
    /*************/
    
    IF   (tel_cdbanchq = 1   AND
          tel_cdagechq = 3420)   OR
         
         /** Conta Integracao **/

         (aux_nrdctitg <> "" AND
         CAN-DO("3420", STRING(tel_cdagechq)))  THEN
         DO:
             RUN fontes/digbbx.p (INPUT  INT(tel_nrctachq),
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
 
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      glb_cdcritic = 8.
                      RETURN.
                  END.

              ASSIGN glb_nrchqsdv = tel_nrcheque
                     glb_nrchqcdv = aux_nrdocmto.

              IF   CAN-DO(aux_lsconta1,STRING(tel_nrctachq))   OR
                  /** Conta Integracao **/
                  (aux_nrdctitg <> "" AND
                  CAN-DO("3420", STRING(tel_cdagechq)))  THEN
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                         crapfdc.cdbanchq = tel_cdbanchq AND
                                         crapfdc.cdagechq = tel_cdagechq AND
                                         crapfdc.nrctachq = tel_nrctachq AND
                                         crapfdc.nrcheque = glb_nrchqsdv
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                      
                      IF   NOT AVAILABLE crapfdc  THEN
                           DO:
                               glb_cdcritic = 108.
                               RETURN.
                           END.

                      ASSIGN aux_nrdconta = crapfdc.nrdconta
                             aux_nrdctabb = crapfdc.nrdctabb.
                           
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
                                    glb_cdcritic = 1000.
                                    
                               RETURN.
                           END.
                  END.
             ELSE
             IF   CAN-DO(aux_lsconta2,STRING(tel_nrctachq))   THEN
                  DO:
                      glb_cdcritic = 646.           /*  CHEQUE TB  */
                      RETURN.
                  END.
             ELSE
             IF   CAN-DO(aux_lsconta3,STRING(tel_nrctachq))   THEN
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                         crapfdc.cdbanchq = tel_cdbanchq AND
                                         crapfdc.cdagechq = tel_cdagechq AND
                                         crapfdc.nrctachq = tel_nrctachq AND
                                         crapfdc.nrcheque = glb_nrchqsdv
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapfdc   THEN
                           DO:
                               glb_cdcritic = 286.
                               RETURN.
                           END.

                      IF   crapfdc.vlcheque = tel_vlcheque   THEN
                           DO:
                               ASSIGN aux_nrdconta = crapfdc.nrdconta
                                      aux_nrdctabb = crapfdc.nrdctabb.
                                    
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
                                             glb_cdcritic = 1000.
                                    
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
    IF  (tel_cdbanchq = 756           AND  tel_cdagechq = aux_cdagebcb)  OR
        (tel_cdbanchq = aux_cdbcoctl  AND  tel_cdagechq = aux_cdagectl)  THEN
         DO:
             ASSIGN glb_nrchqsdv = tel_nrcheque
                    glb_nrchqcdv = aux_nrdocmto.
    
             IF   glb_cdcooper = 1 OR
                  glb_cdcooper = 2 THEN
                  DO:
                      FIND craptco WHERE 
                           craptco.cdcopant = glb_cdcooper      AND
                           craptco.nrctaant = INT(tel_nrctachq) AND
                           craptco.flgativo = TRUE              AND
                           craptco.tpctatrf = 1
                           NO-LOCK NO-ERROR.

                      IF   AVAIL craptco THEN
                           ASSIGN aux_nrdconta = 0.
                      ELSE
                           ASSIGN aux_nrdconta = INT(tel_nrctachq).
                  END.
             ELSE
                  ASSIGN aux_nrdconta = INT(tel_nrctachq).
                      
             RUN ver_associado.
                  
             IF   glb_cdcritic > 0   THEN
                  RETURN.
                      
             IF   aux_nrdconta <> 0 THEN
                  tel_nrctachq = aux_nrdconta.
             
             RUN fontes/digbbx.p (INPUT  INT(tel_nrctachq),
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
 
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      glb_cdcritic = 8.
                      RETURN.
                  END.

             FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                crapfdc.cdbanchq = tel_cdbanchq AND
                                crapfdc.cdagechq = tel_cdagechq AND
                                crapfdc.nrctachq = tel_nrctachq AND
                                crapfdc.nrcheque = glb_nrchqsdv
                                USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
             
             IF   NOT AVAILABLE crapfdc  THEN
                  DO:
                      glb_cdcritic = 108.
                      RETURN.
                  END.
              
             ASSIGN aux_nrdctabb = crapfdc.nrdctabb.
             
             IF   crapfdc.dtemschq = ?   THEN
                  DO:
                      glb_cdcritic = 108.
                      RETURN.
                  END.

            IF (crapfdc.cdbantic <> 0            OR 
                crapfdc.cdagetic <> 0            OR
                crapfdc.nrctatic <> 0)           AND 
               (crapfdc.dtlibtic >= glb_dtmvtolt OR
                crapfdc.dtlibtic  = ?)           THEN
                DO:
                   ASSIGN glb_cdcritic = 950.
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
                           glb_cdcritic = 1000.
                                    
                      RETURN.
                  END.
         END.
    ELSE

    /* 06/05/2015 - Corrigido IF para tratar erro relatado no chamado 261872 ( Renato - Supero ) */

    IF   tel_cdbanchq = aux_cdbcoctl  AND
        ( (tel_cdagechq = 101         AND
           glb_cdcooper = 16)     OR
          (tel_cdagechq = 102         AND
           glb_cdcooper = 01)     OR 
          (tel_cdagechq = 103         AND /* Incorporacao Concredi */
           glb_cdcooper = 01)     OR 
          (tel_cdagechq = 114         AND /* Incorporacao Credimilsul */
           glb_cdcooper = 13)   )    THEN
         DO:
             /* Tratamento para as contas migradas */
             ASSIGN glb_nrchqsdv = tel_nrcheque
                    glb_nrchqcdv = aux_nrdocmto.

             FOR FIRST b-crapcop FIELDS (cdcooper) 
                 WHERE b-crapcop.cdagectl = tel_cdagechq
                 NO-LOCK:

                 FIND craptco WHERE craptco.cdcooper = glb_cdcooper       AND
                                    craptco.nrctaant = INT(tel_nrctachq)  AND
                                    craptco.cdcopant = b-crapcop.cdcooper AND
                                    craptco.flgativo = TRUE               AND
                                    craptco.tpctatrf = 1
                                    NO-LOCK NO-ERROR.
             END.

             IF   AVAIL craptco THEN
                  ASSIGN aux_nrdconta = craptco.nrdconta. /* INT(tel_nrctachq).*/
             ELSE
                  ASSIGN aux_nrdconta = 0.
             
             RUN ver_associado.
 
             IF   glb_cdcritic > 0   THEN
                  RETURN.

             /* IF   aux_nrdconta <> 0 THEN
                  tel_nrctachq = aux_nrdconta. */

             RUN fontes/digbbx.p (INPUT  INT(tel_nrctachq),
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).

             IF   NOT glb_stsnrcal   THEN
                  DO:
                      glb_cdcritic = 8.
                      RETURN.
                  END.

             IF  glb_cdcooper = 16 OR   /* migracao */
                 (glb_cdcooper =  1 AND tel_cdagechq = 102) THEN DO:
             
                 FIND crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                    crapfdc.cdbanchq = tel_cdbanchq     AND
                                    crapfdc.cdagechq = tel_cdagechq     AND
                                    crapfdc.nrctachq = tel_nrctachq     AND
                                    crapfdc.nrcheque = glb_nrchqsdv
                                    USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

             END.
             ELSE 
                 IF  (glb_cdcooper = 1  AND tel_cdagechq = 103)  OR /* incorporacao */
                     (glb_cdcooper = 13 AND tel_cdagechq = 114)  THEN DO:

                     FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                        crapfdc.cdbanchq = tel_cdbanchq     AND
                                        crapfdc.cdagechq = tel_cdagechq     AND
                                        crapfdc.nrctachq = tel_nrctachq     AND
                                        crapfdc.nrcheque = glb_nrchqsdv
                                        USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                 END.
  
             IF   NOT AVAILABLE crapfdc  THEN
                  ASSIGN aux_nrdconta = 0.
             ELSE    
                  DO:
                      ASSIGN aux_nrdctabb = crapfdc.nrdctabb.
             
                      IF   crapfdc.dtemschq = ?   THEN
                           DO:
                               glb_cdcritic = 108.
                               RETURN.
                           END.

                      IF  (crapfdc.cdbantic <> 0            OR 
                           crapfdc.cdagetic <> 0            OR
                           crapfdc.nrctatic <> 0)           AND
                          (crapfdc.dtlibtic >= glb_dtmvtolt OR
                           crapfdc.dtlibtic  = ?)           THEN
                           DO:
                               ASSIGN glb_cdcritic = 950.
                               RETURN.
                           END.

                      IF   crapfdc.dtretchq = ?   THEN
                           DO:
                               glb_cdcritic = 109.
                               RETURN.
                           END.
                   
                      IF   crapfdc.incheque <> 0   THEN
                           DO:
                               IF   crapfdc.incheque = 1   OR
                                    crapfdc.incheque = 2   THEN
                                    glb_cdcritic = 96.
                               ELSE
                               IF   crapfdc.incheque = 5   THEN
                                    glb_cdcritic = 97.
                               ELSE
                               IF   crapfdc.incheque = 8   THEN
                                    glb_cdcritic = 320.
                               ELSE
                                    glb_cdcritic = 1000.
                                    
                               RETURN.
                           END.
                  END.         
         END.
    
    
    
    
    /* nao permitir cheque do cooperado */     
    IF  tel_nrcustod = aux_nrdconta  THEN
        DO:
            glb_cdcritic = 121.
        END.

    RETURN.

END PROCEDURE.

PROCEDURE contra_ordem:

    DEF INPUT PARAMETER par_incheque AS INT                  NO-UNDO.  
    
    IF   par_incheque = 1   OR
         par_incheque = 2   THEN
         DO:
             FIND crapcor WHERE crapcor.cdcooper = glb_cdcooper   AND
                                crapcor.cdbanchq = tel_cdbanchq   AND
                                crapcor.cdagechq = tel_cdagechq   AND
                                crapcor.nrctachq = tel_nrctachq   AND
                                crapcor.nrcheque = glb_nrchqcdv   AND
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

PROCEDURE confirma_redesconto:

    DO aux_contador = 1 TO 20:
    
        FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                           crapcst.cdcmpchq = tel_cdcmpchq   AND
                           crapcst.cdbanchq = tel_cdbanchq   AND
                           crapcst.cdagechq = tel_cdagechq   AND
                           crapcst.nrctachq = tel_nrctachq   AND
                           crapcst.nrcheque = tel_nrcheque   AND
                           crapcst.dtdevolu = ?              
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        IF  NOT AVAILABLE crapcst  THEN
            DO:
                IF  LOCKED(crapcst)  THEN
                    NEXT.
                ELSE
                    RETURN.
            END.
    
        LEAVE.
        
    END. /* Fim do DO TO */
    
    IF  aux_contador > 20  THEN
        DO:
            RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-b1wgen9999.
            
            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcst),
            					 INPUT "banco",
            					 INPUT "crapcst",
            					 OUTPUT par_loginusr,
            					 OUTPUT par_nmusuari,
            					 OUTPUT par_dsdevice,
            					 OUTPUT par_dtconnec,
            					 OUTPUT par_numipusr).
            
            DELETE PROCEDURE h-b1wgen9999.
            
            ASSIGN aux_dadosusr = 
            "077 - Tabela sendo alterada p/ outro terminal.".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            MESSAGE aux_dadosusr.
            PAUSE 3 NO-MESSAGE.
            LEAVE.
            END.
            
            ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
            			  " - " + par_nmusuari + ".".
            
            HIDE MESSAGE NO-PAUSE.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            MESSAGE aux_dadosusr.
            PAUSE 5 NO-MESSAGE.
            LEAVE.
            END.
            
            RETURN.
        END.
        
    IF  crapcst.dtlibera < glb_dtmvtolt  THEN
        DO:
            ASSIGN aux_confirma = "N".
    
            PAUSE(0).
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                UPDATE aux_confirma WITH FRAME f_redescto.
        
                IF  NOT CAN-DO("S,N",aux_confirma)  THEN
                    DO:
                        ASSIGN glb_cdcritic = 14.
                        
                        RUN fontes/critic.p.
                        
                        MESSAGE glb_dscritic.
                        
                        NEXT.
                    END.
        
                LEAVE.
        
            END. /* Fim do WHILE TRUE */
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma = "N"  THEN
                DO:
                    RELEASE crapcst.
                    
                    ASSIGN glb_cdcritic = 79.
                    
                    RETURN.
                END.

            ASSIGN crapcst.dtdevolu = glb_dtmvtoan.
        END.
    ELSE
        ASSIGN glb_cdcritic = 456.
        
    RELEASE crapcst.
    
END PROCEDURE.

/* .......................................................................... */


