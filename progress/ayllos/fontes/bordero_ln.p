/* .............................................................................

   Programa: Fontes/bordero_ln.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2003                        Ultima atualizacao: 14/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para liberar/analisar os borderos de descontos de cheques.

   Alteracoes: 26/01/2004 - Incluido o comando RELEASE apos a transacao 
                            (Edson).

               26/02/2004 - Alterado a forma de gravacao do crapljd. Antes era
                            por bordero, agora e' por cheque (Edson).

               05/04/2004 - Alterado para nao permitir a liberacao do bordero
                            quando houver cheques com data de liberacao igual
                            a do movimento (Edson).
               
               08/10/2004 - Verificar Atualizacao Rating (Mirtes). 
               
               09/11/2004 - Incluida Restricao Qtd.Cheques Devolvidos(Mirtes).
               
               02/12/2004 - Nao permitir desconto de cheques para associados
                            demitidos (Edson).

               15/03/2005 - Nao permitir descontos cujo montante ultrapasse o
                            valor do limite de desconto contratado [somente
                            para a VIACREDI] (Edson).

               18/05/2005 - Alterada tabela craptab por crapcop (Diego).

               04/07/2005 - Alimentado campo cdcooper das tabelas crapabc,
                            craplot, crapljd e craplcm (Diego).

               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).

               29/07/2005 - Criada procedure para consulta ao SPC (Diego).

               12/08/2005 - Melhorar a mensagem da concentracao de cheques
                            por CPF, mostrando a quantidade e o valor
                            dos cheques concentrados (Edson).
              
               25/08/2005 - Alterada procedure verificar_atualizacao_rating
                            (Mirtes)

               20/09/2005 - Alterado para fazer leituta tbm do codigo da       
                            cooperativa na tabela crapabc, e modificado
                            FIND FIRST para FIND na tabela crapcop.cdcooper =
                            glb_cdcooper (Diego).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               06/02/2006 - Incluida opcao NO-UNDO nas TEMP-TABLES cratabc e 
                            crawljd - SQLWorks - Fernando.
                            
               25/10/2006 - Mostra mensagem quando valor do limite exceder o
                            valor parametrizado na TAB033 (Elton).
                            
               31/01/2007 - Controlar o LOCK da crabass e verificar se o
                            registro na craplcm ja existe (Evandro).
               
               19/04/2007 - Incluido glb_cdcooper no FIND da tabela craplcm
                            (Elton).
                            
               26/04/2007 - Revisao do RATING se valor da operacao for maior
                            que 5% do PR da cooperativa (David).

               19/09/2007 - Controle para verificar LOCK de registro (David).

               03/01/2008 - Cobranca de IOF a partir de 03/01/2008 (Magui).
               
               22/08/2008 - Ajustes de sobreposicao de frames etc..(Guilherme).
               
                          - Alterada chave de acesso a tabela crapldc
                            (Gabriel).
                            
               15/10/2009 - Retirar procedure verificar_atualizacao_rating
                            nao mais necessaria. Projeto Rating (Gabriel).   
                            
               05/01/2009 - Mostrar nome do operador que esta prendendo o
                            registro de lote (David).
                            
               28/06/2010 - Nao descontar cheques do pac 5 da CREDITEXTIL
                            Migracao de pac de cooperativas (Guilherme).
                            
               05/09/2011 - Incluido a chamada da procedure alerta_fraude
                            (Adriano). 
                            
               14/02/2012 - Correção cheques não creditados na CC/Contabilidade/Compe
                            (Oscar).                          
                            
               04/06/2012 - Alterado numero do lote na liberação do crédito.
                            Objetivo: evitar lock de registros
                            8477 -> 12.000 + PAC (crédito da operação)
                            8452 -> 13.000 + PAC (IOF)           (Rafael).
                            
               07/12/2012 - Ajuste para utilizar a BO9 e para atender
                            ao projeto GE(Adriano).
                            
               21/03/2013 - Ajuste realizados:
                            - Retirado a chamada da procedure alerta_fraude;
                            - Ajuste no layout do frame f_grupo_economico
                            (Adriano).             
                            
               08/04/2014 - Ajuste WHOLE-INDEX; adicionado filtro com
                            cdcooper na leitura da temp-table. (Fabricio)
                            
               23/06/2014 - Inclusao da include b1wgen0138tt para uso da
                           temp-table tt-grupo ao invés da tt-ge-ocorrencias.
                           (Chamado 130880) - (Tiago Castro - RKAM)
                           
               14/05/2015 - (Chamado 275596) - Incluida verificacao para nao 
                            permitir liberacao de bordero se houver inconsistencia
                            nos lancamentos do lote (Tiago Castro - RKAM).
                             
............................................................................ */

DEF INPUT PARAM par_recid    AS INT                             NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ includes/var_iof.i }

DEF VAR aux_confirma     AS CHAR FORMAT "!"                     NO-UNDO.
DEF VAR aux_inconfir     AS INTEGER                             NO-UNDO.
DEF VAR aux_inconfi2     AS INTEGER                             NO-UNDO.
DEF VAR aux_inconfi3     AS INTEGER                             NO-UNDO.
DEF VAR aux_inconfi4     AS INTEGER                             NO-UNDO.
DEF VAR aux_inconfi5     AS INTEGER                             NO-UNDO.
DEF VAR aux_indentra     AS INTEGER                             NO-UNDO.
DEF VAR aux_indrestr     AS INTEGER                             NO-UNDO.
DEF VAR aux_qtctarel     AS INTEGER FORMAT "zz9"                NO-UNDO.
                   
DEF VAR h-b1wgen0009     AS HANDLE                              NO-UNDO.

DEF TEMP-TABLE tt-risco NO-UNDO
    FIELD contador AS INTE
    FIELD dsdrisco AS CHAR
    FIELD tpregist AS INTE
    FIELD vlrrisco AS DECI
    FIELD diaratin AS INTE.

DEF TEMP-TABLE tt-dscchq_dados_bordero NO-UNDO
    FIELD nrborder AS INTE
    FIELD nrctrlim AS INTE
    FIELD insitbdc LIKE crapbdc.insitbdc
    FIELD txmensal LIKE crapbdc.txmensal
    FIELD txjurmor LIKE crapldc.txjurmor
    FIELD dtlibbdc LIKE crapbdc.dtlibbdc
    FIELD txdiaria LIKE crapldc.txdiaria
    FIELD qtcheque LIKE craplot.qtcompln
    FIELD vlcheque LIKE craplot.vlcompcr
    FIELD dspesqui AS CHAR
    FIELD dsdlinha AS CHAR
    FIELD dsopelib AS CHAR
    FIELD dsopedig AS CHAR
    FIELD flgdigit LIKE crapbdc.flgdigit
    FIELD cdtipdoc AS INTEGER.

/* .......................................................................... */

FORM SKIP(1)
     tt-dscchq_dados_bordero.dspesqui AT 22 LABEL "Pesquisa" FORMAT "x(40)"
     tt-dscchq_dados_bordero.nrborder AT 23 LABEL "Bordero"    SKIP
     tt-dscchq_dados_bordero.nrctrlim AT 22 LABEL "Contrato"   SKIP
     tt-dscchq_dados_bordero.dsdlinha AT 13 LABEL "Linha de Desconto" FORMAT "x(40)"
     SKIP(1)
     tt-dscchq_dados_bordero.qtcheque AT 10 LABEL "Qtd. Cheques"  FORMAT "zzz,zz9"
     tt-dscchq_dados_bordero.dsopedig AT 42 LABEL "Digitado por"  FORMAT "x(20)" SKIP
     tt-dscchq_dados_bordero.vlcheque AT 17 LABEL "Valor" FORMAT "zzz,zzz,zz9.99" SKIP
     tt-dscchq_dados_bordero.txmensal AT 11 LABEL "Taxa Mensal" "%"
     tt-dscchq_dados_bordero.dtlibbdc AT 43 LABEL "Liberado em" SKIP
     tt-dscchq_dados_bordero.txdiaria AT 11 LABEL "Taxa Diaria" "%"
     tt-dscchq_dados_bordero.dsopelib AT 56 NO-LABEL FORMAT "x(20)" SKIP
     tt-dscchq_dados_bordero.txjurmor AT 10 LABEL "Taxa de Mora" "%"
     SKIP(1)
     WITH ROW 7 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY WIDTH 78
          TITLE COLOR NORMAL " Analise/Liberacao de Bordero " FRAME f_bordero.

DEF QUERY q-grupo-economico FOR tt-grupo.

DEF BROWSE b-grupo-economico QUERY q-grupo-economico
    DISPLAY tt-grupo.nrctasoc 
    WITH 3 DOWN WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                      AT 7
     tel_nrdconta
     "Pertence a Grupo Economico."
     SKIP
     "Valor ultrapassa limite legal permitido."   AT 7
     SKIP
     "Verifique endividamento total das contas."  AT 7
     SKIP(1)
     "Grupo possui"                               AT 7
     aux_qtctarel
     "Contas Relacionadas:"                       
     SKIP                                         
     "-------------------------------------"      AT 7
     SKIP                                         
     b-grupo-economico                            AT 18
     HELP "Pressione ENTER, F4/END para sair"
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 FRAME f_grupo_economico.

/*****************************************************************************/

{ includes/iof.i }

ON RETURN OF b-grupo-economico
   DO:
       APPLY "GO".
   END.  

DO  WHILE TRUE ON ERROR UNDO, RETURN:

    FIND crapbdc WHERE RECID(crapbdc) = par_recid NO-LOCK NO-ERROR.
   
    IF NOT AVAILABLE crapbdc   THEN
       RETURN.

    IF NOT VALID-HANDLE(h-b1wgen0009) THEN
       RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.

    IF  NOT VALID-HANDLE(h-b1wgen0009)  THEN
        DO:
            MESSAGE "Handle invalido para b1wgen0009".
            RETURN.

        END.

        RUN busca_dados_bordero IN h-b1wgen0009
                                (INPUT glb_cdcooper,
                                 INPUT glb_cdagenci, 
                                 INPUT 0, /*nrdcaixa*/
                                 INPUT glb_cdoperad,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1, /*idorigem*/
                                 INPUT tel_nrdconta,
                                 INPUT 1, /*idseqttl*/
                                 INPUT glb_nmdatela,
                                 INPUT crapbdc.nrborder, 
                                 INPUT par_cddopcao,
                                 INPUT FALSE,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dscchq_dados_bordero).

    IF VALID-HANDLE(h-b1wgen0009) THEN
       DELETE OBJECT h-b1wgen0009.

    IF RETURN-VALUE = "NOK"  THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
          IF AVAILABLE tt-erro  THEN
             MESSAGE tt-erro.dscritic.
          ELSE
             MESSAGE "Bordero nao encontrado.".
                         
          RETURN.

       END.    

    FIND FIRST tt-dscchq_dados_bordero NO-LOCK NO-ERROR.

    DISPLAY tt-dscchq_dados_bordero.dspesqui                     
            tt-dscchq_dados_bordero.nrborder 
            tt-dscchq_dados_bordero.nrctrlim 
            tt-dscchq_dados_bordero.dsdlinha      
            tt-dscchq_dados_bordero.qtcheque      
            tt-dscchq_dados_bordero.dsopedig 
            tt-dscchq_dados_bordero.vlcheque      
            tt-dscchq_dados_bordero.txmensal  
            tt-dscchq_dados_bordero.dtlibbdc
            tt-dscchq_dados_bordero.txdiaria  
            tt-dscchq_dados_bordero.dsopelib      
            tt-dscchq_dados_bordero.txjurmor  
            WITH FRAME f_bordero.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

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
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           ASSIGN glb_cdcritic = 0.
           HIDE FRAME f_bordero.
           RETURN.

       END.

    /* Variaveis para controle de mensagens */
    ASSIGN aux_inconfir = 1
           aux_inconfi2 = 11
           aux_inconfi3 = 21
           aux_inconfi4 = 71
           aux_inconfi5 = 30
           aux_indentra = 1
           aux_indrestr = 0.

    HIDE MESSAGE NO-PAUSE.

    MESSAGE "Aguarde...".
    
    /* Tiago */

    FOR EACH crapbdc WHERE crapbdc.cdcooper = glb_cdcooper     AND
                           crapbdc.nrborder = crapbdc.nrborder AND
                           crapbdc.nrdconta = tel_nrdconta     AND 
                           crapbdc.dtmvtolt = glb_dtmvtolt     AND 
                           crapbdc.cdagenci = glb_cdagenci NO-LOCK:

        FIND craplot WHERE craplot.cdcooper = crapbdc.cdcooper AND 
                           craplot.nrdolote = crapbdc.nrdolote AND
                           craplot.cdagenci = crapbdc.cdagenci AND
                           craplot.cdbccxlt = crapbdc.cdbccxlt AND 
                           craplot.dtmvtolt = crapbdc.dtmvtolt EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE  craplot   THEN
                IF   LOCKED craplot   THEN
                DO:
                    MESSAGE "Lote sendo alterado por outro usuario.".
                    RETURN.
                END.
            ELSE 
                IF  craplot.qtinfoln <> craplot.qtcompln   OR
                    craplot.vlinfodb <> craplot.vlcompdb   OR
                    craplot.vlinfocr <> craplot.vlcompcr   THEN
                DO:
                    MESSAGE "Liberacao nao permitida. Verificar lancamentos do lote".
                    RETURN.
                END.
    END. /* END do FOR EACH crapbdc */


    DO WHILE TRUE:

       IF NOT VALID-HANDLE(h-b1wgen0009) THEN
          RUN sistema/generico/procedures/b1wgen0009.p 
              PERSISTENT SET h-b1wgen0009.

       RUN efetua_liber_anali_bordero IN h-b1wgen0009
                                     (INPUT glb_cdcooper,
                                      INPUT glb_cdagenci, 
                                      INPUT 0, /* caixa */
                                      INPUT glb_cdoperad,
                                      INPUT glb_nmdatela,
                                      INPUT 1, /* orgigem */
                                      INPUT tel_nrdconta,
                                      INPUT 1, /* idseqttl */
                                      INPUT glb_dtmvtolt,
                                      INPUT glb_dtmvtopr,
                                      INPUT glb_inproces,
                                      INPUT tt-dscchq_dados_bordero.nrborder,
                                      INPUT par_cddopcao,
                                      INPUT aux_inconfir,
                                      INPUT aux_inconfi2,
                                      INPUT aux_inconfi3,
                                      INPUT aux_inconfi4,
                                      INPUT aux_inconfi5,
                                      INPUT-OUTPUT aux_indrestr,
                                      INPUT-OUTPUT aux_indentra,
                                      INPUT TRUE, /* LOG */
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-risco,
                                     OUTPUT TABLE tt-msg-confirma,
                                     OUTPUT TABLE tt-grupo).

       IF VALID-HANDLE(h-b1wgen0009) THEN
          DELETE OBJECT h-b1wgen0009.

       HIDE MESSAGE NO-PAUSE.

       IF RETURN-VALUE <> "OK"  THEN
          DO:    
             /*Se valor legal excedido, mostrara mensagem informando o
               ocorrido e o grupo economico caso a conta em questao
               participe de algum. */
             FIND FIRST tt-msg-confirma WHERE tt-msg-confirma.inconfir = 19
                                              NO-LOCK NO-ERROR.
           
             IF AVAIL tt-msg-confirma THEN
                DO:                
                    MESSAGE tt-msg-confirma.dsmensag.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE.

                   /*Se a conta em questao faz parte de um grupo 
                     economico, serao listados as contas que se 
                     relacionam com a mesma.*/
                   IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                      DO: 
                          ASSIGN aux_qtctarel = 0.

                          FOR EACH tt-grupo NO-LOCK:

                              ASSIGN aux_qtctarel = aux_qtctarel + 1.

                          END.

                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                              OPEN QUERY q-grupo-economico
                                   FOR EACH tt-grupo 
                                   WHERE tt-grupo.cdcooper = glb_cdcooper 
                                   NO-LOCK.
                              
                              DISP tel_nrdconta
                                   aux_qtctarel
                                   WITH FRAME f_grupo_economico.

                              UPDATE b-grupo-economico
                                     WITH FRAME f_grupo_economico.
                   
                              LEAVE.
                   
                          END.
                   
                          CLOSE QUERY q-grupo-economico.
                          HIDE FRAME f_grupo_economico.
                                      
                      END. 

                END.

             FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
             IF AVAILABLE tt-erro  THEN
                DO:
                   MESSAGE tt-erro.dscritic.
                   HIDE FRAME f_bordero.                        

                END.                
             ELSE
                MESSAGE "Bordero nao encontrado".
                         
             RETURN.

          END.

       FIND LAST tt-msg-confirma NO-LOCK NO-ERROR.
       
       IF AVAIL tt-msg-confirma  THEN
          DO:
             CASE tt-msg-confirma.inconfir:

                  WHEN 2 THEN 
                     DO: 
                        HIDE FRAME f_bordero.

                        /* Necessaria atualizacao RATING */
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                            ASSIGN aux_confirma = "N".
                            BELL.
                            MESSAGE COLOR NORMAL tt-msg-confirma.dsmensag
                                    UPDATE aux_confirma.

                            ASSIGN aux_inconfir = tt-msg-confirma.inconfir.

                            LEAVE.

                        END.

                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                           aux_confirma <> "S"                THEN
                           DO: 
                               ASSIGN glb_cdcritic = 79.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               ASSIGN glb_cdcritic = 0.

                               RETURN.

                           END.

                         NEXT.   

                     END.      
                  WHEN 12 THEN 
                     DO:  
                        HIDE FRAME f_bordero.

                        /* Valores Excedidos */
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                            ASSIGN aux_confirma = "N".
                            BELL.
                            MESSAGE COLOR NORMAL tt-msg-confirma.dsmensag
                                    UPDATE aux_confirma.

                            ASSIGN aux_inconfi2 = tt-msg-confirma.inconfir.

                            LEAVE.

                        END.

                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                           aux_confirma <> "S"                THEN
                           DO: 
                               ASSIGN glb_cdcritic = 79.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               ASSIGN glb_cdcritic = 0.

                               RETURN.

                           END.

                         NEXT.   

                     END.    
                WHEN 22 THEN 
                     DO:  
                        HIDE FRAME f_bordero.

                        /* Ha restricoes liberar mesmo assim ? */
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                            ASSIGN aux_confirma = "N".
                            BELL.
                            MESSAGE COLOR NORMAL tt-msg-confirma.dsmensag
                                    UPDATE aux_confirma.
                            ASSIGN aux_inconfi3 = tt-msg-confirma.inconfir.

                            LEAVE.

                        END.

                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                           aux_confirma <> "S"                THEN
                           DO: 
                               ASSIGN glb_cdcritic = 79.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               ASSIGN glb_cdcritic = 0.

                               RETURN.

                           END.

                        NEXT. 

                     END.
                  WHEN 31 THEN 
                     DO:  
                        HIDE FRAME f_bordero.
                  
                        /* Ha restricoes liberar mesmo assim ? */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                           ASSIGN aux_confirma = "N".
                           BELL.
                           MESSAGE COLOR NORMAL tt-msg-confirma.dsmensag
                                   UPDATE aux_confirma.
                           ASSIGN aux_inconfi5 = tt-msg-confirma.inconfir + 1.
                           LEAVE.
                  
                        END.
                  
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                           aux_confirma <> "S"                THEN
                           DO:   
                               ASSIGN glb_cdcritic = 79.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               ASSIGN glb_cdcritic = 0.

                               RETURN.
                           END.
                  
                        NEXT.    
                  
                     END.
                  WHEN 72 THEN 
                     DO:  
                        HIDE FRAME f_bordero.
                        MESSAGE tt-msg-confirma.dsmensag.
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE.
                        ASSIGN aux_inconfi4 = tt-msg-confirma.inconfir.
                        NEXT.

                     END.
                  WHEN 88 THEN
                     DO:  
                         HIDE FRAME f_bordero.
                         MESSAGE tt-msg-confirma.dsmensag 
                                 VIEW-AS ALERT-BOX TITLE "".
                         LEAVE.

                     END.

             END CASE.
                  
          END.

    END. /* Final do DO WHILE TRUE */    

    RUN fontes/bordero_m.p (INPUT par_recid, 
                            INPUT tt-dscchq_dados_bordero.insitbdc).
    
    RUN fontes/bordero_lst.p.      

    
    LEAVE.

END.

  

