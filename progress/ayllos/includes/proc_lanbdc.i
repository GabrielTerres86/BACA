/* .............................................................................

   Programa: includes/proc_lanbdc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                     Ultima atualizacao: 24/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures da tela LANBDC.

   Alteracoes: 11/05/2005 - Validar o banco e a agencia (Edson).

               16/05/2005 - Tratamento Conta Integracao(Mirtes).

               06/07/2005 - Alimentado campo cdcooper da tabela crapcec (Diego).

               09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               03/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               20/12/2006 - Retirado tratamento Banco/Agencia 104/411 (Diego).

               14/02/2007 - Alterar consultas com indice crapfdc1 (David).
                 
               12/03/2007 - Ajustes para o Bancoob (Magui).

               28/03/2007 - Procedure para confirmar redesconto (David).
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               15/07/2008 - Criticar conta com prejuizo ou demitido (Magui).
               
               24/03/2010 - Validar ITG para agencia 3420 (cri 860)(Guilherme)
               
               20/04/2010 - Validar ITG para a conta e nao pela agencia
                            pois agencia 3420 é para outros lugares tambem
                            (Guilherme).
                            
               17/06/2010 - Remoção da conferência da agência 95 (Vitor).
               
               08/07/2010 - Tratamento para Compe 085 (Ze).
               
               07/12/2011 - Sustação provisória (André R./Supero).               
               
               08/05/2012 - Ajuste na rotina de redesconto (Rafael).
               
               25/09/2012 - Inclusao de verificacao de cheque em custodia
                            (Lucas R.).               
                            
               07/01/2013 - Tratamento na procedure ver_cheque para as contas
                            migradas da Viacredi para AltoVale, para o banco
                            085. Apenas para cdcooper = 1. (Fabricio).
                            
               14/01/2013 - Tratamento para AltoVale (Ze).
               
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).    
               
               08/01/2014 - Incluso validate (Daniel) 
               
               11/06/2014 - Somente emitir a crítica 950 apenas se a 
                            crapfdc.dtlibtic >= data do movimento (SD. 163588 - Lunelli)
                            
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               05/01/2015 - Tratamento para Incorporacao Concredi e 
                            Credimilsul. (SD. 238692 - Rafael)
                            
               20/01/2015 - Criação da rotina valida_nome para validar o nome 
                            do emitente de cheque (Odirlei-Amcom)
                            
               04/02/2015 - Ajustes na procedure ver_cheque ref a Migracao e 
                            Incorporacao. (SD 238692 - Rafael)
                
               11/06/2015 - Corrigir condição de IF na rotina ver_cheque, afim de evitar erro
                            relatado no chamado 294466 (Kelvin)                            
                            
               24/08/2015 - Incluir nova procedure verifica_fraude_chq_extern
                            Melhoria 217 (Lucas Ranghetti #320543)
............................................................................. */

{ sistema/generico/includes/var_oracle.i }

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
    
    FIND crapban WHERE crapban.cdbccxlt = tel_cdbanchq NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapban   AND glb_cddopcao <> "R"   THEN
         DO:
             glb_cdcritic = 57.
             RETURN.
         END.

    /*  Verifica se a agencia existe ........................................ */

    FIND crapagb WHERE crapagb.cddbanco = tel_cdbanchq   AND
                       crapagb.cdageban = tel_cdagechq NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapagb    AND glb_cddopcao <> "R"    THEN
         DO:
             glb_cdcritic = 15.
             RETURN.
         END.
    
    /*  Mostra os dados lidos  */
                  
    DISPLAY tel_cdcmpchq tel_cdbanchq tel_cdagechq 
            tel_nrddigc1 tel_nrctachq tel_nrddigc2 
            tel_nrcheque tel_nrddigc3 WITH FRAME f_lanbdc.

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
            
            /*** Verificar se o cooperado esta demitido ***/
            IF   crapass.dtdemiss <> ?   THEN
                 DO:
                     glb_cdcritic = 75.
                     RETURN.
                 END.
                 
            /*** Verificar se ha preju na conta ***/
            FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper     AND
                                   crapepr.nrdconta = crapass.nrdconta AND 
                                   crapepr.inprejuz = 1                AND
                                   crapepr.vlsdprej > 0           NO-LOCK:
                aux_flgpreju = TRUE.
            END.
 
            IF   aux_flgpreju   THEN
                 DO:
                     glb_cdcritic = 695.
                     RETURN.
                 END.

            ASSIGN aux_nmprimtl = crapass.nmprimtl
                   aux_nrcpfcgc = crapass.nrcpfcgc.
            
            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE ver_cheque:

    DEF BUFFER buf-crapass FOR crapass.
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

    IF   (tel_cdbanchq = 1       AND
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
             
             /* Validar ITG Ativa pela conta */
             FIND buf-crapass WHERE buf-crapass.cdcooper = glb_cdcooper AND
                                    buf-crapass.nrdctitg = 
                                            STRING(tel_nrctachq,"99999999")
                                    NO-LOCK NO-ERROR.
             
             IF  AVAIL buf-crapass  THEN
                 IF  buf-crapass.flgctitg <> 2  THEN
                     DO:
                        glb_cdcritic = 860.
                        RETURN.    
                     END.
                  
             IF   CAN-DO(aux_lsconta1,STRING(tel_nrctachq))   OR
                  /** Conta Integracao **/
                  (aux_nrdctitg <> "" AND
                  CAN-DO("3420", STRING(tel_cdagechq)))  THEN
                  DO:
                       FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                          crapfdc.cdbanchq = tel_cdbanchq AND
                                          crapfdc.cdagechq = tel_cdagechq AND
                                          crapfdc.nrctachq = tel_nrctachq AND
                                          crapfdc.nrcheque = tel_nrcheque 
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
                  
                      FIND crapfdc WHERE
                           crapfdc.cdcooper = glb_cdcooper AND
                           crapfdc.cdbanchq = tel_cdbanchq AND
                           crapfdc.cdagechq = tel_cdagechq AND
                           crapfdc.nrctachq = tel_nrctachq AND
                           crapfdc.nrcheque = tel_nrcheque 
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
                                            RUN contra_ordem (crapfdc.incheque).
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
                 RETURN.      
             
             RUN ver_associado.
                  
             IF   glb_cdcritic > 0   THEN
                  RETURN.
         END.
    ELSE
    IF   (tel_cdbanchq = 756          AND tel_cdagechq = aux_cdagebcb) OR
         (tel_cdbanchq = aux_cdbcoctl AND tel_cdagechq = aux_cdagectl) THEN
         DO:
             ASSIGN glb_nrcalcul = aux_nrdocmto.

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
             
             FIND crapfdc WHERE
                  crapfdc.cdcooper = glb_cdcooper AND
                  crapfdc.cdbanchq = tel_cdbanchq AND
                  crapfdc.cdagechq = tel_cdagechq AND
                  crapfdc.nrctachq = tel_nrctachq AND
                  crapfdc.nrcheque = tel_nrcheque 
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

             IF   crapfdc.dtretchq = ?   THEN
                  DO:
                      glb_cdcritic = 109.
                      RETURN.
                  END.
            
            IF   (crapfdc.cdbantic <> 0            OR 
                  crapfdc.cdagetic <> 0            OR
                  crapfdc.nrctatic <> 0)           AND
                 (crapfdc.dtlibtic >= glb_dtmvtolt OR
                  crapfdc.dtlibtic  = ?)           THEN
                  DO:
                      ASSIGN glb_cdcritic = 950.
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
                           glb_cdcritic = 1000.
                                    
                      RETURN.
                  END.
         END.
    ELSE
    IF   tel_cdbanchq = aux_cdbcoctl  AND
     (  (tel_cdagechq = 101           AND
         glb_cdcooper = 16)           OR
        (tel_cdagechq = 102           AND
         glb_cdcooper = 01)           OR 
        (tel_cdagechq = 103           AND /* Incorporacao Concredi */
         glb_cdcooper = 01)           OR 
        (tel_cdagechq = 114           AND /* Incorporacao Credimilsul */
         glb_cdcooper = 13)  )        THEN
         DO:
             ASSIGN glb_nrcalcul = aux_nrdocmto.

             FOR FIRST b-crapcop FIELDS (cdcooper) 
                 WHERE b-crapcop.cdagectl = tel_cdagechq
                 NO-LOCK:

                 FIND craptco WHERE craptco.cdcooper = glb_cdcooper       AND
                                    craptco.cdcopant = b-crapcop.cdcooper AND
                                    craptco.nrctaant = INT(tel_nrctachq)  AND
                                    craptco.flgativo = TRUE               AND
                                    craptco.tpctatrf = 1
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL craptco THEN
                      ASSIGN aux_nrdconta = craptco.nrdconta.
                 ELSE
                      ASSIGN aux_nrdconta = 0.

             END.            
                  
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
                                    crapfdc.nrcheque = tel_nrcheque
                                    USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

             END.
             ELSE 
                 IF  (glb_cdcooper = 1  AND tel_cdagechq = 103)  OR /* incorporacao */
                     (glb_cdcooper = 13 AND tel_cdagechq = 114)  THEN DO:

                     FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                        crapfdc.cdbanchq = tel_cdbanchq     AND
                                        crapfdc.cdagechq = tel_cdagechq     AND
                                        crapfdc.nrctachq = tel_nrctachq     AND
                                        crapfdc.nrcheque = tel_nrcheque
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

                      IF   crapfdc.dtretchq = ?   THEN
                           DO:
                               glb_cdcritic = 109.
                               RETURN.
                           END.
            
                     IF   (crapfdc.cdbantic <> 0            OR 
                           crapfdc.cdagetic <> 0            OR
                           crapfdc.nrctatic <> 0)           AND
                          (crapfdc.dtlibtic >= glb_dtmvtolt OR
                           crapfdc.dtlibtic  = ?)           THEN
                           DO:
                               ASSIGN glb_cdcritic = 950.
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
   ELSE      
         
         RETURN.            /*  Qualquer outro banco  */

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
                                crapcor.nrcheque = aux_nrdocmto   AND
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

PROCEDURE pede_dados:

    ASSIGN tel_nmemichq = ""
           tel_nrcpfchq = 0.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       IF   glb_cdcritic > 0 OR 
            glb_dscritic <> " " THEN
            DO:
                IF   glb_cdcritic > 0  THEN
                  RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.

                glb_cdcritic = 0.
                glb_dscritic = " ".
            END.

              
       UPDATE tel_nmemichq tel_nrcpfchq WITH FRAME f_emitente.
       
       IF   TRIM(tel_nmemichq) = ""   THEN
            DO:
                glb_cdcritic = 375.
                NEXT-PROMPT tel_nmemichq WITH FRAME f_emitente.
                NEXT.
            END.

       IF   tel_nrcpfchq = 0   THEN
            DO:
                glb_cdcritic = 375.
                NEXT-PROMPT tel_nrcpfchq WITH FRAME f_emitente.
                NEXT.
            END.

       RUN valida_nome (INPUT  tel_nmemichq,
                        INPUT  tel_nrcpfchq,
                        OUTPUT glb_dscritic ).

       IF  RETURN-VALUE = "NOK" THEN
       DO:
          NEXT-PROMPT tel_nmemichq WITH FRAME f_emitente.
          NEXT.
       END.

       glb_nrcalcul = tel_nrcpfchq.

       IF   LENGTH(STRING(tel_nrcpfchq)) > 11   THEN
            RUN fontes/cgcfun.p.
       ELSE
            DO:
                RUN fontes/cpffun.p.

                IF   NOT glb_stsnrcal   THEN
                     RUN fontes/cgcfun.p.
            END.

       IF   NOT glb_stsnrcal THEN
            DO:
                glb_cdcritic = 27.
                NEXT.
            END.

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          aux_confirma = "N".
          glb_cdcritic = 78.

          RUN fontes/critic.p.
          glb_cdcritic = 0.
          BELL.
          MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
            aux_confirma <> "S" THEN
            NEXT.
       
       LEAVE.
                                     
    END.  /*  Fim do DO WHILE TRUE  */

    HIDE FRAME f_emitente NO-PAUSE.
 
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:
             glb_cdcritic = 79.
             RETURN.
         END.
 
    DO TRANSACTION ON ERROR UNDO, RETURN:
    
       CREATE crapcec.
       ASSIGN crapcec.cdagechq = tel_cdagechq
              crapcec.cdbanchq = tel_cdbanchq
              crapcec.cdcmpchq = tel_cdcmpchq
              crapcec.nmcheque = CAPS(tel_nmemichq)
              crapcec.nrcpfcgc = tel_nrcpfchq
              crapcec.nrctachq = tel_nrctachq
              crapcec.nrdconta = 0
              crapcec.cdcooper = glb_cdcooper.

       VALIDATE crapcec.
    
    END.  /*  Fim da transacao  */

END PROCEDURE.

PROCEDURE confirma_redesconto:

    DO aux_contador = 1 TO 20:
    
        FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper   AND 
                           crapcdb.cdcmpchq = tel_cdcmpchq   AND
                           crapcdb.cdbanchq = tel_cdbanchq   AND
                           crapcdb.cdagechq = tel_cdagechq   AND
                           crapcdb.nrctachq = tel_nrctachq   AND
                           crapcdb.nrcheque = tel_nrcheque   AND
                           crapcdb.dtdevolu = ? /* situacao anterior */
                           /* crapcdb.insitchq = 1  resgatado */
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE crapcdb  THEN
            DO:
                IF  LOCKED(crapcdb)  THEN
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
            
            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcdb),
                             INPUT "banco",
                             INPUT "crapcdb",
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
        
    IF  crapcdb.dtlibera < glb_dtmvtolt  THEN
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
                    RELEASE crapcdb.
                    
                    ASSIGN glb_cdcritic = 79.
                    
                    RETURN.
                END.

            ASSIGN crapcdb.dtdevolu = glb_dtmvtoan.
        END.
    ELSE
        ASSIGN glb_cdcritic = 456.


    RELEASE crapcdb.

END PROCEDURE.

/* Procedimento para validar nome do emitente de cheque*/
PROCEDURE valida_nome:

  DEF  INPUT PARAM  par_nmemichq  AS CHARACTER  NO-UNDO.
  DEF  INPUT PARAM  par_nrcpfchq  AS CHARACTER  NO-UNDO.
  DEF  OUTPUT PARAM par_dscritic  AS CHARACTER  NO-UNDO.
    
  DEF VAR aux_flencnum  AS LOG                   NO-UNDO.
  DEF VAR aux_inpessoa AS INT                   NO-UNDO.
  DEF VAR aux_listanum AS CHAR                  NO-UNDO.
  DEF VAR aux_listachr AS CHAR                  NO-UNDO.
  DEF VAR aux_nrextnum AS HANDLE EXTENT         NO-UNDO.
  DEF VAR aux_nrextent AS HANDLE EXTENT         NO-UNDO.
  
  /* se o numero possuir mais de 11 caracteres
     se trata de uma pessoa juridica */
  IF LENGTH(STRING(tel_nrcpfchq)) > 11   THEN
     ASSIGN aux_inpessoa = 2.
  ELSE
     ASSIGN aux_inpessoa = 1.
  
  /* Verificacoes para o nome */
  ASSIGN aux_listachr = "=,%,&,#,+,?,',','.',/,;,[,],!,@,$,(,),*,|,\,:,<,>," +
                        "~{,~},~," + '",'
         aux_listanum = "0,1,2,3,4,5,6,7,8,9".

  
  EXTENT(aux_nrextent) = NUM-ENTRIES(aux_listachr).

  DO aux_contador = 1 TO EXTENT(aux_nrextent):
     IF  INDEX(par_nmemichq,ENTRY(aux_contador,aux_listachr)) <> 0 THEN
     DO:
         ASSIGN par_dscritic = "O Caracter " + TRIM(ENTRY(aux_contador,
                                                          aux_listachr))
                             + " nao e permitido! " + 
                               "Caracteres invalidos: " + 
                               "=%&#+?',./;][!@$()*|\:<>{}" + '"'.
               RETURN "NOK".
            END.
    END.

    IF  aux_inpessoa = 1 THEN
    DO:
        EXTENT(aux_nrextnum) = NUM-ENTRIES(aux_listanum).
        
        DO aux_contador = 1 TO EXTENT(aux_nrextnum):
            IF  INDEX(par_nmemichq,ENTRY(aux_contador,aux_listanum)) <> 0 THEN
            DO:
                ASSIGN par_dscritic = "Nao sao permitidos numeros no nome" +
                                      " do emitente de cheque pessoa fisica".
                RETURN "NOK".
            END.
        END.
    END. 

  /* para pessoa juridica verifica
    se o nome só possui numericos */
  IF aux_inpessoa = 2 THEN
  DO:
      ASSIGN aux_flencnum = FALSE.

      EXTENT(aux_nrextnum) = NUM-ENTRIES(aux_listanum).
      
      DO aux_contador = 1 TO LENGTH(par_nmemichq):
          IF  INDEX(aux_listanum, SUBSTR(par_nmemichq,aux_contador,1)) <> 0 THEN
              DO:
                  /* setar que somente encontrou numerico*/
                  ASSIGN aux_flencnum = TRUE.
              END.
          ELSE
              DO:
                  /* caso não for numerico setar como false e sair*/
                  ASSIGN aux_flencnum = FALSE.
                  LEAVE.
              END.          
      END.
      
      IF aux_flencnum  THEN
      DO:      
         ASSIGN par_dscritic = "Nao sao permitidos somente numeros no nome" +
                               " do emitente de cheque pessoa juridica".
         RETURN "NOK".
     END.
  END.
  
  RETURN "OK".

END PROCEDURE. /* Fim PROCEDURE valida_nome*/

/* Verifiacr cheques externos com sinistros (UNICRED) */
PROCEDURE verifica_fraude_chq_extern:

  DEFINE INPUT PARAMETER par_cdcooper AS INT                          NO-UNDO.
  DEFINE INPUT PARAMETER par_cdprogra AS CHAR                         NO-UNDO.
  DEFINE INPUT PARAMETER par_cdbanco  AS DECIMAL                      NO-UNDO.
  DEFINE INPUT PARAMETER par_nrcheque AS DECIMAL                      NO-UNDO.
  DEFINE INPUT PARAMETER par_nrctachq AS CHAR                         NO-UNDO.
  DEFINE INPUT PARAMETER par_cdoperad AS CHAR                         NO-UNDO.
  DEFINE INPUT PARAMETER par_cdagenci AS DECIMAL                      NO-UNDO.
  DEFINE OUTPUT PARAMETER par_des_erro AS CHAR                        NO-UNDO.
  
  ASSIGN par_des_erro = "".
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
         
  RUN STORED-PROCEDURE pc_ver_fraude_chq_extern 
       aux_handproc = PROC-HANDLE NO-ERROR
       (INPUT par_cdcooper, /* pr_cdcooper */
        INPUT par_cdprogra, /* pr_cdprogra */
        INPUT par_cdbanco,  /* pr_cdbanco  */
        INPUT par_nrcheque, /* pr_nrcheque */
        INPUT par_nrctachq, /* pr_nrctachq */
        INPUT par_cdoperad, /* pr_cdoperad */
        INPUT par_cdagenci, /* pr_cdagenci */
        OUTPUT "").         /* pr_des_erro */

  CLOSE STORED-PROC pc_ver_fraude_chq_extern 
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  /* Gravar mensagem de erro caso tenha mensagem */
  ASSIGN par_des_erro = pc_ver_fraude_chq_extern.pr_des_erro
                        WHEN pc_ver_fraude_chq_extern.pr_des_erro <> ?.
                 
  RETURN "OK".
                 
END PROCEDURE.                        

/* .......................................................................... */

