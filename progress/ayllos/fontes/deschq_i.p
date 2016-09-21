/* .............................................................................

   Programa: Fontes/deschq_i.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                        Ultima atualizacao: 11/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para incluir novo limite de descontos de cheques.

   Alteracoes: 17/06/2004 - Verificar capital e tempo minimo de sociedade
                            (Edson).
               21/06/2004 - Atualizar tabela avalistas Terceiros(Mirtes)
 
               20/07/2004 - Criticar valor utilizado(Mirtes)

               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
               
               16/09/2004 - Tratar tempo de filiacao (Edson).
               
               14/10/2004 - Obter Risco do Rating(Associado)/Verificar 
                            Atualizacao do Rating(Evandro).

               18/05/2005 - Alterada tabela craptab por crapcop (Diego).

               04/07/2005 - Alimentado campo cdcooper das tabelas craplim,
                            crapavl, crapavt e crapprp (Diego).
               
               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).

               25/08/2005 - Verificar valores utilizados(substituicao de
                            contratos)(Mirtes)

               26/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               12/01/2006 - Incluido campo Bens (Diego).
                
               06/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               25/10/2006 - Mostra mensagem de consulta ao SCR quando valor
                            excede o valor parametrizado na TAB033 (Elton).

               26/04/2007 - Revisao do RATING se valor da operacao for maior
                            que 5% do PR da cooperativa (David).
               
               05/07/2007 - HIDE no campo lim_dtcancel na hora de incluir.
                            (Guilherme).
                            
               10/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
               11/12/2007 - Nao verificar tempo de filiacao Transpocred(Mirtes)
               
               29/04/2008 - Efetuado acerto no campo craplim.dscfcav2 (Diego).
               
               29/07/2008 - Uso da TAB042 para permitir entrada de contratos
                            antes do prazo minimo (Gabriel).

               04/09/2008 - Ajuste na mensagem de consulta SCR (Guilherme).
                          - Alterada chave de acesso a tabela crapldc 
                            (Gabriel).
               
               24/09/2009 - Efetuadas alteraçoes para o novo RATING - preenchi-
                            mento obrigatorio dos campos do frame f_rating
                            (Fernando).
                          - Alterar para browse dinamico.Geracao de rating
                            (Gabriel).
                         
               09/12/2009 - Busca rating do cooperado nas tabelas crapttl e 
                            crapjur e grava as informacoes nessas tabelas e 
                            tambem na craplim; 
                          - Substituido campo tel_vlopescr por tel_vltotsfn 
                            (Elton).
                            
               01/03/2010 - Listar as criticas do Rating (Gabriel).             
               
               11/06/2010 - Adaptacao para RATING no Ayllos Web (David).
               
               22/09/2010 - Ajustar parametros para deschq_m.p (David).
               
               05/04/2011 - Alteracao do valor dos parametros da procedure
                            sequencia_rating, para atender a nova tabela do
                            rating. (Fabrício) 
                            
               27/04/2011 - CEP integrado, inclusao de campos nrendere, complend
                            nrcxapst. (André - DB1)
                            
               14/07/2011 - Voltar atras quando F4/END-ERROR no fontes dos
                            avalistas (Gabriel).              
                            
               01/09/2011 - Incluido a chamada da procedure alerta_fraude
                            (Adriano).
                            
               27/10/2011 - Adicionado no inicio do fonte, a chamada a
                            procedure valida_percentual_societario. (Fabricio)
                            
               21/11/2011 - Colocado em comentario temporariamente a chamada
                            da procedure valida_percentual_societario. 
                            (Fabricio)
              
               22/03/2012 - Incluido log para inclusao de limite de cheque
                            (Tiago).
                            
               26/11/2012 - Ajustes referente ao Projeto GE (Lucas R.).
               
               21/03/2013 - Ajustes realizados:
                            - Retirado a chamada da procedure alerta_fraude;
                            - Ajuste de layout para os frames f_grupo_economico,
                              f_grupo_economico2 (Adriano).
                              
               23/06/2014 - Inclusao da include b1wgen0138tt para uso da
                            temp-table tt-grupo ao invés da tt-ge-ocorrencias.
                            (Chamado 130880) - (Tiago Castro - RKAM)
                
               11/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
                            de proposta de novo limite de desconto de cheque para
                            menores nao emancipados. (Reinert)
               
............................................................................. */
                        
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }


DEF VAR tab_vlmaxlim        AS DECI                                  NO-UNDO.
DEF VAR tab_qtdiavig        AS INT                                   NO-UNDO.
DEF VAR tab_txdmulta        AS DECIMAL DECIMALS 7                    NO-UNDO.
DEF VAR tab_qtdiasoc        AS INT                                   NO-UNDO.

DEF VAR ant_nrctrpro        AS INT                                   NO-UNDO.
DEF VAR aux_dstransa        AS CHAR                                  NO-UNDO.
DEF VAR aux_nrdrowid        AS ROWID                                 NO-UNDO.


DEF VAR h-b1wgen0043        AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0058        AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0138        AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0009        AS HANDLE                                NO-UNDO.

DEF VAR aux_nrdgrupo        AS INT                                   NO-UNDO.
DEF VAR aux_dsdrisgp        AS CHAR                                  NO-UNDO.
DEF VAR aux_gergrupo        AS CHAR                                  NO-UNDO.
DEF VAR aux_riscogrp        AS CHAR FORMAT "X(2)"                    NO-UNDO.
DEF VAR aux_vlutiliz        AS DEC                                   NO-UNDO.
DEF VAR aux_pertengp        AS LOG                                   NO-UNDO.

DEF VAR aux_inconfir        AS INTE                                  NO-UNDO.
DEF VAR aux_inconfi2        AS INTE                                  NO-UNDO.
DEF VAR aux_inconfi4        AS INTE                                  NO-UNDO.
DEF VAR aux_inconfi5        AS INTE                                  NO-UNDO.


DEF QUERY  q-craprad FOR tt-itens-topico-rating SCROLLING.

DEF BROWSE b-craprad QUERY q-craprad
    DISPLAY nrseqite COLUMN-LABEL "Seq.Item"
            dsseqite COLUMN-LABEL "Descricao Seq.Item" FORMAT "x(55)"
                     WITH CENTERED 5 DOWN TITLE " Itens do Rating ".

FORM b-craprad 
     WITH NO-BOX OVERLAY ROW 10 CENTERED FRAME f_craprad.

FORM SKIP(1) " "
     tel_nrctrpro FORMAT "z,zzz,zz9"
                  LABEL "Numero do contrato impresso"
                  HELP "Entre com o numero impresso no contrato."
     " " SKIP(1)
     WITH ROW 11 CENTERED SIDE-LABELS OVERLAY FRAME f_contrato.

FORM SKIP(1) " "
     tel_nrctrpro FORMAT "z,zzz,zz9"
                  LABEL "Confirme o numero do contrato impresso"
                  HELP "Confirme o numero impresso no contrato."
     " " SKIP(1)
     WITH ROW 11 CENTERED SIDE-LABELS OVERLAY FRAME f_confirma_ctr.


ON RETURN OF b-craprad IN FRAME f_craprad DO:

      APPLY "GO".

END.

ON RETURN OF b-grupo-economico
   DO:
       APPLY "GO".
   END.    

ON RETURN OF b-grupo-economico2
   DO:
       APPLY "GO".
   END. 

ON 'LEAVE' OF tel_cddlinha IN FRAME f_prolim DO:

    FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper AND
                       crapldc.tpdescto = 2            AND
                       crapldc.cddlinha = INPUT tel_cddlinha AND
                       crapldc.flgstlcr = TRUE /*ATIVA*/
                       NO-LOCK NO-ERROR.
    
    IF   AVAILABLE crapldc   THEN
         DO:    
             ASSIGN tel_dsdlinha = crapldc.dsdlinha.               
         END.
    ELSE
         DO:
             MESSAGE "LINHA DE DESCONTO NAO ENCONTRADA".
             RETURN NO-APPLY.
         END.

    DISPLAY tel_dsdlinha WITH FRAME f_prolim.

END.

/*RUN sistema/generico/procedures/b1wgen0058.p PERSISTENT SET h-b1wgen0058.

RUN valida_percentual_societario IN h-b1wgen0058 (INPUT glb_cdcooper,
                                                  INPUT tel_nrdconta,
                                                  OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0058.

IF RETURN-VALUE <> "OK" THEN
DO:
    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF AVAIL tt-erro THEN
    DO:
        ASSIGN glb_cdcritic = tt-erro.cdcritic
               glb_dscritic = tt-erro.dscritic.
    END.
END.

IF glb_cdcritic > 0 THEN
DO:
    RUN fontes/critic.p.
    BELL.
    glb_cdcritic = 0.
    MESSAGE glb_dscritic.
    RETURN.
END.*/


IF NOT VALID-HANDLE(h-b1wgen0009) THEN
   RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.

ASSIGN aux_inconfir = 1.

DO WHILE TRUE:

    RUN busca_dados_limite_incluir IN h-b1wgen0009(INPUT glb_cdcooper,
                                               INPUT glb_cdagenci,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_dtmvtolt,
                                               INPUT 1,
                                               INPUT tel_nrdconta,
                                               INPUT 1,
                                               INPUT glb_nmdatela,
                                               INPUT aux_inconfir,
                                               INPUT TRUE,
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT TABLE tt-risco,
                                               OUTPUT TABLE tt-dados_dscchq,
                                               OUTPUT TABLE tt-msg-confirma).

    FIND LAST tt-msg-confirma NO-LOCK NO-ERROR.
   
    IF  AVAIL tt-msg-confirma  THEN
        DO:                                      
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               ASSIGN aux_confirma = "N".
               BELL.
               MESSAGE tt-msg-confirma.dsmensag
                       UPDATE aux_confirma.            

               LEAVE.
               
            END.
            IF  aux_confirma = "S" THEN
                DO:
                    ASSIGN aux_inconfir = tt-msg-confirma.inconfir.
                    NEXT.
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
        END.        

    LEAVE.

END.

IF VALID-HANDLE(h-b1wgen0009) THEN
   DELETE OBJECT h-b1wgen0009.

IF RETURN-VALUE <> "OK" THEN
   DO:
      FIND FIRST tt-erro NO-LOCK NO-ERROR.

      IF AVAIL tt-erro THEN
         DO:
            BELL.
            MESSAGE tt-erro.dscritic.
            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE.
            
         END.

      IF VALID-HANDLE(h-b1wgen0009) THEN
         DELETE OBJECT h-b1wgen0009.

      RETURN.

   END.

FIND FIRST tt-dados_dscchq NO-LOCK NO-ERROR.

IF AVAIL tt-dados_dscchq THEN
   ASSIGN tab_vlmaxlim = tt-dados_dscchq.vllimite
          tab_qtdiavig = tt-dados_dscchq.qtdiavig
          tab_txdmulta = tt-dados_dscchq.pcdmulta
          tab_qtdiasoc = tt-dados_dscchq.qtdiasoc
          tel_nrctrpro = 0
          tel_vllimpro = 0
          tel_qtdiavig = tab_qtdiavig
          tel_cddlinha = 0
          tel_dsdlinha = ""
          tel_txjurmor = 0 
          tel_txdmulta = tab_txdmulta
          tel_dsramati = ""
          tel_vlmedchq = 0
          tel_vlfatura = 0
          tel_dsobserv = ""
          lim_vlsalari = 0   
          lim_vlsalcon = 0  
          lim_vloutras = 0  
          tel_dsdebens[1] = ""
          tel_dsdebens[2] = "".

IF NOT VALID-HANDLE(h-b1wgen0009) THEN
   RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.

RUN ver_capital IN h-b1wgen0009(INPUT glb_cdcooper,
                                INPUT glb_cdagenci,
                                INPUT 0, /*nrdcaixa*/
                                INPUT glb_cdoperad,
                                INPUT glb_dtmvtolt,
                                INPUT tel_nrdconta,
                                INPUT glb_nmdatela,
                                INPUT 1, /*idorigem*/
                                INPUT 0, /*vllanmto*/
                                OUTPUT TABLE tt-erro).

IF VALID-HANDLE(h-b1wgen0009) THEN
   DELETE OBJECT h-b1wgen0009.

FIND FIRST tt-erro NO-LOCK NO-ERROR.

IF AVAIL tt-erro THEN
   DO:
      BELL.
      MESSAGE tt-erro.dscritic.
      PAUSE 3 NO-MESSAGE.
      HIDE MESSAGE.
      RETURN.

   END.


INCLUSAO:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF glb_cdcritic > 0   THEN
      DO:
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          ASSIGN glb_cdcritic = 0.

      END.

   IF NOT VALID-HANDLE(h-b1wgen0043) THEN
      RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

   RUN busca_dados_rating IN h-b1wgen0043 
                             (INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT glb_cdoperad,
                              INPUT glb_dtmvtolt,
                              INPUT tel_nrdconta,
                              INPUT 1,
                              INPUT 1,
                              INPUT glb_nmdatela,
                              INPUT FALSE,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-valores-rating,
                              OUTPUT TABLE tt-itens-topico-rating).

   IF VALID-HANDLE(h-b1wgen0043) THEN
      DELETE OBJECT h-b1wgen0043.

   IF RETURN-VALUE <> "OK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF AVAIL tt-erro   THEN
             DO:
                 MESSAGE tt-erro.dscritic.
                 PAUSE 2 NO-MESSAGE.
                 RETURN.

             END.

      END.

   HIDE FRAME f_observacao   NO-PAUSE.
   HIDE FRAME f_rendas       NO-PAUSE.
   HIDE FRAME f_rating       NO-PAUSE.

   DISPLAY tel_dsdlinha 
           tel_qtdiavig
           tel_txjurmor
           tel_txdmulta 
           WITH FRAME f_prolim.

   HIDE lim_dtcancel.

   UPDATE tel_nrctrpro  
          tel_vllimpro VALIDATE(tel_vllimpro <= tab_vlmaxlim,
                         "Limite maximo por contrato excedido, ver TAB019.")
          tel_cddlinha  
          tel_dsramati  
          tel_vlmedchq  
          tel_vlfatura 
          WITH FRAME f_prolim
   
   EDITING:
   
       READKEY.

       IF FRAME-FIELD = "tel_vllimpro"   OR
          FRAME-FIELD = "tel_txjurmor"   OR
          FRAME-FIELD = "tel_txdmulta"   OR
          FRAME-FIELD = "tel_vlmedchq"   OR
          FRAME-FIELD = "tel_vlfatura"   THEN
          IF LASTKEY =  KEYCODE(".")   THEN
             APPLY 44.
          ELSE 
             APPLY LASTKEY.
       ELSE
       IF FRAME-FIELD = "tel_cddlinha" THEN
          DO:
             IF LASTKEY = KEYCODE("F7") THEN
                DO:
                    RUN fontes/zoom_linha_desconto.p
                             (INPUT glb_cdcooper,
                              INPUT 2, /*Desconto de cheque*/
                              INPUT TRUE, /* Liberadas*/
                              INPUT-OUTPUT tel_cddlinha,
                              INPUT-OUTPUT tel_dsdlinha).
                      
                    DISPLAY tel_cddlinha
                            tel_dsdlinha 
                            WITH FRAME f_prolim.  

                END.
             ELSE
                APPLY LASTKEY.
          
          END.   
       ELSE
          APPLY LASTKEY.
    
   END.  /*  Fim do EDITING  */
   
   ASSIGN aux_inconfir = 1
          aux_inconfi2 = 11
          aux_inconfi4 = 71
          aux_inconfi5 = 30.
   
   DO WHILE TRUE:

       IF NOT VALID-HANDLE(h-b1wgen0009) THEN
          RUN sistema/generico/procedures/b1wgen0009.p
              PERSISTENT SET h-b1wgen0009.

       RUN valida_proposta_dados IN h-b1wgen0009
                                (INPUT glb_cdcooper,                     
                                 INPUT glb_cdagenci, 
                                 INPUT 0, /*caixa*/
                                 INPUT glb_cdoperad,
                                 INPUT glb_nmdatela,
                                 INPUT 1, /*origem*/
                                 INPUT tel_nrdconta,
                                 INPUT 1, /*idseqttl*/
                                 INPUT tel_nrctrpro,
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_dtmvtopr,
                                 INPUT glb_inproces,
                                 INPUT  0, /*diaratin,*/
                                 INPUT tel_vllimpro,
                                 INPUT glb_dtmvtolt, /*dtrating*/
                                 INPUT 0,  /*par_vlrrisco*/
                                 INPUT "I", /*cddopcao*/
                                 INPUT tel_cddlinha,
                                 INPUT aux_inconfir,
                                 INPUT aux_inconfi2,
                                 INPUT aux_inconfi4,
                                 INPUT aux_inconfi5,
                                 INPUT TRUE,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-msg-confirma,
                                 OUTPUT TABLE tt-grupo).
   
       IF VALID-HANDLE(h-b1wgen0009) THEN
          DELETE OBJECT h-b1wgen0009.

       IF RETURN-VALUE = "NOK"  THEN
          DO:
             /*Se valor legal excedido, mostrara mensagem informando o
              ocorrido e o grupo economico caso a conta em questao
              participe de algum. */
              FIND FIRST tt-msg-confirma WHERE tt-msg-confirma.inconfir = 19
                                               NO-LOCK NO-ERROR.
   
              IF AVAIL tt-msg-confirma  THEN
                 DO:
                    MESSAGE tt-msg-confirma.dsmensag.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE.

                    /*Se a conta em questao faz parte de um grupo economico, 
                    serao listados as contas que se relacionam com a
                    mesma.*/
                    IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                       DO:     
                          ASSIGN aux_qtctarel = 0.

                          FOR EACH tt-grupo NO-LOCK:

                              ASSIGN aux_qtctarel = aux_qtctarel + 1.

                          END.

                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                              OPEN QUERY q-grupo-economico
                                   FOR EACH tt-grupo NO-LOCK.
                              
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
   
              FIND FIRST tt-msg-confirma WHERE tt-msg-confirma.inconfir = 72 
                                               NO-LOCK NO-ERROR.
   
              IF AVAIL tt-msg-confirma  THEN
                 MESSAGE tt-msg-confirma.dsmensag.
              
              FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
              IF AVAIL tt-erro  THEN
                 DO:
                     MESSAGE tt-erro.dscritic.
                     PAUSE 3 NO-MESSAGE.
                     HIDE MESSAGE.

                     NEXT INCLUSAO.

                 END.
              ELSE
                 NEXT INCLUSAO.

          END.
   
       FIND LAST tt-msg-confirma NO-LOCK NO-ERROR.
   
       IF AVAIL tt-msg-confirma  THEN
          DO: 
             CASE tt-msg-confirma.inconfir:
                 WHEN 2  THEN 
                     DO:
                        /* Necessaria atualizacao RATING */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           ASSIGN aux_confirma = "N".
                           BELL.
                           MESSAGE tt-msg-confirma.dsmensag
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

                               NEXT INCLUSAO.
                               
                           END.

                        NEXT.    

                     END.      
                 WHEN 12 THEN 
                     DO:
                        /* Valores Excedidos */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           ASSIGN aux_confirma = "N".
                           BELL.
                           MESSAGE tt-msg-confirma.dsmensag
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

                               NEXT INCLUSAO.
                               
                           END.

                         NEXT.   

                     END.    
                 WHEN 72 THEN 
                     DO: 
                         MESSAGE tt-msg-confirma.dsmensag.
                         PAUSE 3 NO-MESSAGE.
                         HIDE MESSAGE.
                         LEAVE.
                     END.
                 WHEN 31 THEN 
                     DO: 
                        /* Valores Excedidos */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           ASSIGN aux_confirma = "N".
                           BELL.
                           MESSAGE tt-msg-confirma.dsmensag
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

                               NEXT INCLUSAO.
   
                           END.
   
                         NEXT. 
                        
                     END.
   
             END CASE.
   
          END.
   
      LEAVE.
   
   END. /*final do DO WHILE TRUE */

   IF KEY-FUNCTION(LAST-KEY) = "END-ERROR" THEN
      NEXT INCLUSAO.
           
   DISPLAY tel_dsdlinha 
           WITH FRAME f_prolim.     
   
   PAUSE 0.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
      UPDATE lim_vlsalari 
             lim_vlsalcon 
             lim_vloutras 
             tel_dsdebens[1]
             tel_dsdebens[2] 
             WITH FRAME f_rendas

      EDITING:

          READKEY.
   
          IF FRAME-FIELD = "lim_vlsalari" OR
             FRAME-FIELD = "lim_vlsalcon" OR
             FRAME-FIELD = "lim_vloutras" THEN
             IF   LASTKEY =  KEYCODE(".") THEN
                  APPLY 44.
             ELSE
                  APPLY LASTKEY.
          ELSE
             APPLY LASTKEY.
               
      END.  /*  Fim do EDITING  */
 
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
         FIND FIRST tt-valores-rating NO-LOCK NO-ERROR.
                            
         IF tt-valores-rating.inpessoa = 1    THEN
            DO:
                HIDE tt-valores-rating.perfatcl IN FRAME f_rating.
                HIDE tt-valores-rating.nrperger IN FRAME f_rating.
            END.
                                 
         UPDATE tt-valores-rating.nrgarope 
                tt-valores-rating.nrinfcad
                tt-valores-rating.nrliquid 
                tt-valores-rating.nrpatlvr
                tt-valores-rating.vltotsfn
                tt-valores-rating.perfatcl WHEN tt-valores-rating.inpessoa <> 1
                tt-valores-rating.nrperger WHEN tt-valores-rating.inpessoa <> 1
                WITH FRAME f_rating
                        
           EDITING:
                     
            READKEY.
                                   
            IF LASTKEY = KEYCODE("F7") THEN
               DO:
                  IF FRAME-FIELD = "nrgarope" THEN
                     DO:
                        b-craprad:HELP = 
                                 "Pressione <ENTER> p/ selecionar a" + 
                                 " garantia.".
                                          
                        IF tt-valores-rating.inpessoa = 1 THEN
                           RUN sequencia_rating (INPUT 2,
                                                 INPUT 2).
                        ELSE
                           RUN sequencia_rating (INPUT 4,
                                                 INPUT 2).
                                               
                        IF AVAIL tt-itens-topico-rating  THEN
                           ASSIGN tt-valores-rating.nrgarope = 
                                        tt-itens-topico-rating.nrseqite.
                              
                        DISPLAY tt-valores-rating.nrgarope
                                WITH FRAME f_rating.
                                 
                     END.
                  ELSE
                  IF FRAME-FIELD = "nrinfcad" THEN
                     DO:
                        b-craprad:HELP = 
                            "Pressione <ENTER> p/ selecionar as" +
                            " informacoes cadastrais.".
                              
                        IF tt-valores-rating.inpessoa = 1 THEN
                           RUN sequencia_rating (INPUT 1,
                                                 INPUT 4).
                        ELSE
                           RUN sequencia_rating (INPUT 3,
                                                 INPUT 3).

                        IF AVAIL tt-itens-topico-rating THEN
                           ASSIGN tt-valores-rating.nrinfcad = 
                                         tt-itens-topico-rating.nrseqite.
                                   
                        DISPLAY tt-valores-rating.nrinfcad
                                WITH FRAME f_rating.

                     END.
                  ELSE
                  IF FRAME-FIELD = "nrliquid" THEN     
                     DO:
                        b-craprad:HELP = 
                            "Pressione <ENTER> p/ selecionar a" + 
                            " liquidez das garantias.".

                        IF tt-valores-rating.inpessoa = 1 THEN
                           RUN sequencia_rating (INPUT 2,
                                                 INPUT 3).
                        ELSE
                           RUN sequencia_rating (INPUT 4,
                                                 INPUT 3).
                  
                        IF AVAIL tt-itens-topico-rating THEN
                           ASSIGN tt-valores-rating.nrliquid = 
                                      tt-itens-topico-rating.nrseqite.
   
                        DISPLAY tt-valores-rating.nrliquid
                                WITH FRAME f_rating.

                     END.
                  ELSE
                  IF FRAME-FIELD = "nrpatlvr" THEN
                     DO:
                        b-craprad:HELP = 
                            "Pressione <ENTER> p/ selecionar os" + 
                            " patrimonios pessoais livres.".
                                   
                        IF tt-valores-rating.inpessoa = 1 THEN
                           RUN sequencia_rating (INPUT 1,
                                                 INPUT 8).
                        ELSE
                           RUN sequencia_rating (INPUT 3,
                                                 INPUT 9).
          
                        IF AVAIL tt-itens-topico-rating THEN
                           ASSIGN tt-valores-rating.nrpatlvr = 
                                      tt-itens-topico-rating.nrseqite.
   
                        DISPLAY tt-valores-rating.nrpatlvr
                                WITH FRAME f_rating.
                           
                     END.
                  ELSE
                  IF FRAME-FIELD = "nrperger" THEN
                     DO:
                        b-craprad:HELP = 
                          "Pressione <ENTER> p/ selecionar a" + 
                          " percepcao geral com relacao a empresa.".
                                      
                        RUN sequencia_rating (INPUT 3,
                                              INPUT 11).
                
                        IF AVAIL tt-itens-topico-rating THEN
                           ASSIGN tt-valores-rating.nrperger = 
                                      tt-itens-topico-rating.nrseqite.
                
                        DISPLAY tt-valores-rating.nrperger
                                WITH FRAME f_rating.
                        
                     END.
                  ELSE
                     APPLY LASTKEY.

               END.
               ELSE
                  APPLY LASTKEY.

           END. /* Fim do EDITING */       
            
           /* Validar os itens do RATING */

           IF NOT VALID-HANDLE(h-b1wgen0043) THEN
              RUN sistema/generico/procedures/b1wgen0043.p 
                  PERSISTENT SET h-b1wgen0043. 

           IF NOT VALID-HANDLE (h-b1wgen0043)   THEN
              DO:
                  MESSAGE "Handle invalido para a BO b1wgen0043.".
                  PAUSE 2 NO-MESSAGE.
                  NEXT.
              END.
           
           RUN valida-itens-rating IN h-b1wgen0043 
                                         (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_dtmvtolt,
                                          INPUT tel_nrdconta,
                                          INPUT tt-valores-rating.nrgarope,
                                          INPUT tt-valores-rating.nrinfcad,
                                          INPUT tt-valores-rating.nrliquid,
                                          INPUT tt-valores-rating.nrpatlvr,
                                          INPUT tt-valores-rating.nrperger,
                                          INPUT 1, /* Ayllos */
                                          INPUT 1, /* Titular */
                                          INPUT glb_nmdatela,
                                          INPUT FALSE,
                                          OUTPUT TABLE tt-erro).

           IF VALID-HANDLE(h-b1wgen0043) THEN
              DELETE OBJECT h-b1wgen0043.

           IF RETURN-VALUE <> "OK"   THEN
              DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
                  IF AVAILABLE tt-erro   THEN
                     DO:
                         MESSAGE tt-erro.dscritic.
                         NEXT.
                     END.

              END.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
              DISPLAY tel_dsobserv 
                      WITH FRAME f_observacao.
              
              ENABLE ALL WITH FRAME f_observacao.
              
              WAIT-FOR CHOOSE OF btn_btaosair.
              
              ASSIGN INPUT tel_dsobserv.
              
              RUN fontes/deschq_np.p.
              
              IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.
              
              /*  Confirma o numero do contrato informado .............  */
              
              ASSIGN ant_nrctrpro = tel_nrctrpro
                     tel_nrctrpro = 0.
              
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
                 UPDATE tel_nrctrpro 
                        WITH FRAME f_confirma_ctr.
              
                 LEAVE.
              
              END.  /*  Fim do DO WHILE TRUE  */
              
              HIDE FRAME f_confirma_ctr NO-PAUSE.
              
              IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    ASSIGN glb_cdcritic = 79
                           tel_nrctrpro = ant_nrctrpro.
                    NEXT INCLUSAO.

                 END.
              
              IF NOT VALID-HANDLE(h-b1wgen0009) THEN
                 RUN sistema/generico/procedures/b1wgen0009.p 
                     PERSISTENT SET h-b1wgen0009.

              RUN valida_nrctrato_avl IN h-b1wgen0009
                              (INPUT glb_cdcooper,
                               INPUT glb_cdagenci, 
                               INPUT 0, /*nrdcaixa*/
                               INPUT glb_cdoperad,
                               INPUT 1,   
                               INPUT tel_nrdconta,
                               INPUT glb_nmdatela,
                               INPUT 1,
                               INPUT tel_nrctrpro,
                               INPUT ant_nrctrpro,
                               INPUT lim_nrctaav1,
                               INPUT lim_nrctaav2,
                               INPUT TRUE,
                               OUTPUT TABLE tt-erro).
              
              IF VALID-HANDLE(h-b1wgen0009) THEN
                 DELETE OBJECT h-b1wgen0009.

              IF RETURN-VALUE <> "OK"  THEN
                 DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
                     IF AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
              
                     ASSIGN tel_nrctrpro = ant_nrctrpro.
              
                     NEXT INCLUSAO.
              
                 END.
              
              IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                 RUN sistema/generico/procedures/b1wgen0138.p
                     PERSISTENT SET h-b1wgen0138.
              
              ASSIGN aux_pertengp = DYNAMIC-FUNCTION("busca_grupo" 
                                                     IN h-b1wgen0138,
                                                     INPUT glb_cdcooper,
                                                     INPUT tel_nrdconta,
                                                     OUTPUT aux_nrdgrupo,
                                                     OUTPUT aux_gergrupo,
                                                     OUTPUT aux_dsdrisgp).

              IF VALID-HANDLE(h-b1wgen0138) THEN
                 DELETE OBJECT h-b1wgen0138.
               
              IF aux_gergrupo <> "" THEN
                 DO:
                    MESSAGE aux_gergrupo.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.

                 END.
               
              IF aux_pertengp THEN
                 DO: 
                     IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                        RUN sistema/generico/procedures/b1wgen0138.p
                            PERSISTENT SET h-b1wgen0138.

                    /*Procedure responsavel por calcular o endividamento 
                      do grupo */
                    RUN calc_endivid_grupo IN h-b1wgen0138
                                              (INPUT glb_cdcooper,
                                               INPUT glb_cdagenci, 
                                               INPUT 0, /*nrdcaixa*/
                                               INPUT glb_cdoperad, 
                                               INPUT glb_dtmvtolt, 
                                               INPUT glb_nmdatela, 
                                               INPUT 1, /*idorigem*/
                                               INPUT aux_nrdgrupo, 
                                               INPUT TRUE, /*Consulta por conta*/
                                              OUTPUT aux_riscogrp, 
                                              OUTPUT aux_vlutiliz,
                                              OUTPUT TABLE tt-grupo, 
                                              OUTPUT TABLE tt-erro).
                
                    IF VALID-HANDLE(h-b1wgen0138) THEN
                       DELETE OBJECT h-b1wgen0138.
                    
                    IF RETURN-VALUE <> "OK" THEN
                       RETURN "NOK".
              
                    IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                       DO:            
                          ASSIGN aux_qtctarel = 0.

                          FOR EACH tt-grupo NO-LOCK:

                              ASSIGN aux_qtctarel = aux_qtctarel + 1.

                          END.

                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                         
                             FIND FIRST tt-grupo NO-LOCK NO-ERROR.
              
                             OPEN QUERY q-grupo-economico2
                                        FOR EACH tt-grupo NO-LOCK.

                             DISP tt-grupo.dsdrisgp
                                  tel_nrdconta 
                                  aux_qtctarel
                                  WITH FRAME f_grupo_economico2. 

                             UPDATE b-grupo-economico2
                                    WITH FRAME f_grupo_economico2.
                    
                             LEAVE.
                    
                          END.
                               
                          CLOSE QUERY q-grupo-economico2.
                          HIDE FRAME f_grupo_economico2.

                       END.  
                       
                 END.
              

              /*  Confirmacao dos dados  */
              RUN fontes/confirma.p (INPUT "",
                                     OUTPUT aux_confirma).
              
              IF aux_confirma <> "S" THEN
                 NEXT INCLUSAO.
              
              LEAVE INCLUSAO.
         
           END.  /*  Fim do DO WHILE TRUE  */

           HIDE FRAME f_observacao NO-PAUSE.
      
      END. /* Fim do DO WHILE TRUE */
      
      HIDE FRAME f_rating NO-PAUSE.
      
   END.  /*  Fim do DO WHILE TRUE  */

   HIDE FRAME f_rendas NO-PAUSE.

END.  /*  Fim do DO WHILE TRUE  */


IF KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN
   DO TRANSACTION ON ERROR UNDO, RETURN:

      IF NOT VALID-HANDLE(h-b1wgen0009) THEN
         RUN sistema/generico/procedures/b1wgen0009.p 
             PERSISTENT SET h-b1wgen0009.

      RUN efetua_inclusao_limite IN h-b1wgen0009  
                                 (INPUT glb_cdcooper,                                      
                                  INPUT glb_cdagenci,
                                  INPUT 0, /*nrdcaixa*/                                    
                                  INPUT tel_nrdconta,                                      
                                  INPUT glb_nmdatela,                                      
                                  INPUT 1, /*idseqttl*/                                    
                                  INPUT glb_dtmvtolt,                                      
                                  INPUT glb_cdoperad,                                      
                                  INPUT tel_vllimpro,                                      
                                  INPUT tel_dsramati,                                      
                                  INPUT tel_vlmedchq, 
                                  INPUT tel_vlfatura,                                      
                                  INPUT lim_vloutras,                                      
                                  INPUT lim_vlsalari,                                      
                                  INPUT lim_vlsalcon,                                      
                                  INPUT tel_dsdebens[1],
                                  INPUT tel_dsdebens[2], 
                                  INPUT tel_nrctrpro,                                      
                                  INPUT tel_cddlinha,                                      
                                  INPUT tel_dsobserv,                                      
                                  INPUT tab_qtdiavig,                                      
                                  INPUT TRUE,                                              
                                  /** 1 avalista **/                                       
                                  INPUT lim_nrctaav1,                                      
                                  INPUT lim_nmdaval1,                                      
                                  INPUT lim_cpfcgc1,                                       
                                  INPUT lim_tpdocav1,                                      
                                  INPUT lim_dscpfav1,                                      
                                  INPUT lim_nmdcjav1,                                      
                                  INPUT lim_cpfccg1,                                       
                                  INPUT lim_tpdoccj1,                                      
                                  INPUT lim_dscfcav1,       
                                  INPUT lim_dsendav1[1],                                   
                                  INPUT lim_dsendav1[2],                                   
                                  INPUT lim_nrfonres1,                                     
                                  INPUT lim_dsdemail1,                                     
                                  INPUT lim_nmcidade1,                                     
                                  INPUT lim_cdufresd1,                                     
                                  INPUT lim_nrcepend1,                                     
                                  INPUT lim_nrendere1,                                     
                                  INPUT lim_complend1,                                     
                                  INPUT lim_nrcxapst1,                                     
                                  /**  2 avalista  **/                                     
                                  INPUT lim_nrctaav2,                                      
                                  INPUT lim_nmdaval2,                                      
                                  INPUT lim_cpfcgc2,                                       
                                  INPUT lim_tpdocav2,                                      
                                  INPUT lim_dscpfav2,                                      
                                  INPUT lim_nmdcjav2,                                      
                                  INPUT lim_cpfccg2,                                       
                                  INPUT lim_tpdoccj2,                                      
                                  INPUT lim_dscfcav2,                                      
                                  INPUT lim_dsendav2[1],                                   
                                  INPUT lim_dsendav2[2],                                   
                                  INPUT lim_nrfonres2,                                     
                                  INPUT lim_dsdemail2,                                     
                                  INPUT lim_nmcidade2,                                     
                                  INPUT lim_cdufresd2,                                     
                                  INPUT lim_nrcepend2,                                     
                                  INPUT lim_nrendere2,                                     
                                  INPUT lim_complend2,                                     
                                  INPUT lim_nrcxapst2,                                     
                                  /** ---- RATING ----- **/                                
                                  INPUT tt-valores-rating.nrgarope,                        
                                  INPUT tt-valores-rating.nrinfcad,                        
                                  INPUT tt-valores-rating.nrliquid,                        
                                  INPUT tt-valores-rating.nrpatlvr,                        
                                  INPUT tt-valores-rating.vltotsfn,
                                  INPUT tt-valores-rating.perfatcl,
                                  INPUT tt-valores-rating.nrperger,      
                                  INPUT TRUE,                      
                                  OUTPUT TABLE tt-erro).                                   
                                                                                                    
      IF VALID-HANDLE(h-b1wgen0009) THEN
         DELETE OBJECT h-b1wgen0009.                                                                
      
      IF RETURN-VALUE = "NOK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    LEAVE.

                END.
         END.
      
      
      IF NOT VALID-HANDLE(h-b1wgen0043) THEN
         RUN sistema/generico/procedures/b1wgen0043.p 
             PERSISTENT SET h-b1wgen0043.

      /** Grava alteracoes do rating do cooperado **/
      RUN atualiza_valores_rating IN h-b1wgen0043 
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdagenci, 
                                  INPUT 0,   /** Caixa   **/
                                  INPUT glb_cdoperad,
                                  INPUT glb_nmdatela,
                                  INPUT 1,   /** Origem  **/
                                  INPUT tel_nrdconta,
                                  INPUT 1,   /** Titular **/
                                  INPUT glb_dtmvtolt,
                                  INPUT glb_inproces,
                                  INPUT tt-valores-rating.nrinfcad,
                                  INPUT tt-valores-rating.nrpatlvr,
                                  INPUT tt-valores-rating.nrperger,
                                  INPUT 2,  /** Dsc.Chq. **/
                                  INPUT tel_nrctrpro,
                                  INPUT FALSE,
                                 OUTPUT TABLE tt-erro).

      IF VALID-HANDLE(h-b1wgen0043) THEN
         DELETE OBJECT h-b1wgen0043.

      HIDE FRAME f_observacao NO-PAUSE.

      IF  RETURN-VALUE = "NOK"  THEN
          RUN fontes/lista_criticas_rating.p (INPUT TABLE tt-erro).
             
      RUN fontes/deschq_m.p (INPUT tel_nrdconta,
                             INPUT tel_nrctrpro).
      
      HIDE FRAME f_imprime NO-PAUSE.        
      /* Caso seja efetuada alguma alteracao na descricao deste log,
            devera ser tratado o relatorio de "demonstrativo produtos por
            colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
      ASSIGN aux_dstransa = "Incluir limite " + STRING(tel_nrctrpro) 
                            + " de desconto de cheques.".

      RUN proc_gerar_log (INPUT glb_cdcooper,
                          INPUT glb_cdoperad,
                          INPUT "",
                          INPUT "AYLLOS",
                          INPUT aux_dstransa,
                          INPUT TRUE,
                          INPUT 1 ,
                          INPUT glb_nmdatela,
                          INPUT tel_nrdconta,
                          OUTPUT aux_nrdrowid).


   END.  /*  Fim da transacao  */
    
HIDE FRAME f_observacao   NO-PAUSE.
HIDE FRAME f_rendas       NO-PAUSE.
HIDE FRAME f_rating       NO-PAUSE.
HIDE FRAME f_prolim       NO-PAUSE.

PROCEDURE sequencia_rating:

   DEF INPUT PARAM par_nrtopico AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_nritetop AS INTE                            NO-UNDO.
      
      
   OPEN QUERY q-craprad FOR EACH tt-itens-topico-rating WHERE 
                        tt-itens-topico-rating.nrtopico = par_nrtopico AND
                        tt-itens-topico-rating.nritetop = par_nritetop   
                        NO-LOCK.
                                 
   IF NUM-RESULTS("q-craprad")  = 0  THEN
      RETURN.

   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
      
      UPDATE b-craprad
             WITH FRAME f_craprad.
      LEAVE.
                                 
   END. /* Fim do DO WHILE TRUE */
                                     
   HIDE FRAME f_craprad.
                                        
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      RELEASE tt-itens-topico-rating.

END PROCEDURE.

/* .......................................................................... */



