/* .............................................................................

   Programa: Fontes/deschq_a.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                        Ultima atualizacao: 23/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para alterar a proposta de limite de descontos de cheques.

   Alteracoes: 13/04/2004 - Permitir alteracao somente quando o contrato de
                            limite estiver em estudo (Edson).
               21/06/2004 - Acessar tabela avalistas Terceiros(Mirtes)
 
               20/07/2004 - Criticar valor utilizado(Mirtes)

               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
               
               14/10/2004 - Obter Risco do Rating(Associado)/Verificar 
                            Atualizacao do Rating(Evandro).
                            
               18/05/2005 - Alterada tabela craptab por crapcop (Diego). 
                          
               04/07/2005 - Alimentado campo cdcooper das tabelas crapavl e
                            crapavt (Diego).

               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).

              25/08/2005 - Verificar valores utilizados(substituicao de
                            contratos)(Mirtes)

              26/09/2005 - Modificado FIND FIRST para FIND na tabela 
                           crapcop.cdcooper = glb_cdcooper (Diego).

              12/01/2006 - Incluido campo Bens (Diego).

              06/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
              25/10/2006 - Mostra mensagem quando valor do limite exceder o
                           valor parametrizado na TAB033 (Elton).   
 
              21/03/2007 - Substituido valores dos campos de endereco da
                           estrutura crapass pelos da crapenc (Elton).

              26/04/2007 - Revisao do RATING se valor da operacao for maior
                           que 5% do PR da cooperativa (David).

              05/07/2007 - HIDE no campo lim_dtcancel na hora de alterar.
                           (Guilherme). 
                           
              29/04/2008 - Efetuado acerto no campo craplim.dscfcav2 (Diego).
             
              16/09/2008 - Alterada chave de acesso a tabela crapldc 
                           (Gabriel) .
                         - Acerto para mostrar a mensagem de consulta SCR
                         - Acerto na critica de LDC nao encontrado
                           (Guilherme).
                           
              24/09/2009 - Efetuadas alteraçoes para o novo RATING - preenchi-
                           mento obrigatorio dos campos do frame f_rating
                           (Fernando).     
                         - Alterar para browse dinamico. Retirar tratamento de
                           atualizacao manual do Rating (Gabriel).
              
              09/12/2009 - Busca e grava rating do cooperado nas tabelas crapttl
                           e crapjur; 
                         - Substituido campo tel_vlopescr por tel_vltotsfn 
                           (Elton).             
                           
              01/03/2010 - Mostrar as criticas do Rating (Gabriel).    
              
              11/06/2010 - Adaptacao para RATING no Ayllos Web (David).     
              
              14/03/2011 - Substituir dsdemail da ass para a crapcem (Gabriel).
              
              05/04/2011 - Alteracao do valor dos parametros da procedure
                           sequencia_rating para atender a nova tabela do
                           rating. (Fabrício)  
                           
              27/04/2011 - Inclusao de parametros para CEP integrado.
                           (André - DB1)  
                           
              14/07/2011 - Voltar atras quando F4/END-ERROR no fontes
                           dos avalistas (Gabriel).             
                           
              05/09/2011 - Incluido a chamada para a procedure alerta_fraude
                           (Adriano).
                  
              27/11/2012 - Ajustes referentes ao Projeto GE (Lucas R.).
              
              21/03/2013 - Ajustes realizados:
                           - Retirado a chamada da procedure alerta_fraude;
                           - Ajuste de layout para os frames f_grupo_economico
                             f_grupo_economico2 (Adriano).
                             
             23/06/2014 - Inclusao da include b1wgen0138tt para uso da
                          temp-table tt-grupo ao invés da tt-ge-deschq.
                          (Chamado 130880) - (Tiago Castro - RKAM)
              
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i }

DEF INPUT PARAM par_nrctrlim AS INT                                  NO-UNDO.

DEF VAR aux_regexist         AS LOGICAL                              NO-UNDO.

DEF VAR tab_vlmaxlim         AS DECI                                 NO-UNDO. 
DEF VAR tab_qtdiavig         AS INT                                  NO-UNDO.
DEF VAR tab_txdmulta         AS DECIMAL DECIMALS 7                   NO-UNDO.
DEF VAR tab_qtdiasoc         AS INT                                  NO-UNDO.

DEF VAR h-b1wgen0043         AS HANDLE                               NO-UNDO.
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
DEF VAR aux_jagravou        AS LOG                                   NO-UNDO.


DEF QUERY  q-craprad FOR tt-itens-topico-rating SCROLLING.

DEF BROWSE b-craprad QUERY q-craprad
    DISPLAY nrseqite COLUMN-LABEL "Seq.Item"
            dsseqite COLUMN-LABEL "Descricao Seq.Item" FORMAT "x(55)"
                     WITH CENTERED 5 DOWN TITLE " Itens do Rating ".

FORM b-craprad 
     WITH NO-BOX OVERLAY ROW 10 CENTERED FRAME f_craprad.


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
                       crapldc.cddlinha = INPUT tel_cddlinha 
                       NO-LOCK NO-ERROR.
    
    IF AVAILABLE crapldc   THEN
       DO:    
          ASSIGN tel_dsdlinha = crapldc.dsdlinha.               
       END.
    ELSE
       DO:
          ASSIGN tel_dsdlinha = "NAO ENCONTRADA".
       END.

    DISPLAY tel_dsdlinha WITH FRAME f_prolim.

END.


DO WHILE TRUE ON ERROR UNDO, LEAVE:


   DO WHILE TRUE:

      IF NOT VALID-HANDLE(h-b1wgen0009) THEN
         RUN sistema/generico/procedures/b1wgen0009.p
             PERSISTENT SET h-b1wgen0009.

      RUN busca_dados_limite_altera IN h-b1wgen0009
                                      (INPUT glb_cdcooper,
                                       INPUT glb_cdagenci,
                                       INPUT 0, /*nrdcaixa*/
                                       INPUT glb_cdoperad,
                                       INPUT glb_dtmvtolt,
                                       INPUT 1, /*idorigem*/ 
                                       INPUT tel_nrdconta,
                                       INPUT 1, /*idseqttl*/
                                       INPUT glb_nmdatela,
                                       INPUT par_nrctrlim,
                                       INPUT TRUE,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-dscchq_dados_limite,
                                       OUTPUT TABLE tt-dados-avais,
                                       OUTPUT TABLE tt-risco,
                                       OUTPUT TABLE tt-dados_dscchq).

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
      
            RETURN.
      
         END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */                 
   
   ASSIGN lim_nmdaval1     = " "
          lim_cpfcgc1      = 0
          lim_tpdocav1     = " " 
          lim_dscpfav1     = " "
          lim_nmdcjav1     = " "
          lim_cpfccg1      = 0
          lim_tpdoccj1     = " " 
          lim_dscfcav1     = " "
          lim_dsendav1[1]  = " "
          lim_dsendav1[2]  = " "
          lim_nrfonres1    = " "
          lim_dsdemail1    = " "
          lim_nmcidade1    = " "
          lim_cdufresd1    = " "
          lim_nrcepend1    = 0
          lim_nrendere1    = 0
          lim_complend1    = " "
          lim_nrcxapst1    = 0
          
          lim_nmdaval2     = " " 
          lim_cpfcgc2      = 0
          lim_tpdocav2     = " "
          lim_dscpfav2     = " "
          lim_nmdcjav2     = " "
          lim_cpfccg2      = 0
          lim_tpdoccj2     = " " 
          lim_dscfcav2     = " "
          lim_dsendav2[1]  = " "
          lim_dsendav2[2]  = " "
          lim_nrfonres2    = " "
          lim_dsdemail2    = " "
          lim_nmcidade2    = " "
          lim_cdufresd2    = " "
          lim_nrcepend2    = 0
          lim_nrendere2    = 0
          lim_complend2    = " "
          lim_nrcxapst2    = 0
          aux_jagravou     = FALSE.


   FOR EACH tt-dados-avais NO-LOCK:

       IF aux_jagravou = FALSE THEN
          DO:
              ASSIGN lim_nmdaval1     = tt-dados-avais.nmdavali 
                     lim_cpfcgc1      = tt-dados-avais.nrcpfcgc 
                                        WHEN tt-dados-avais.nrctaava = 0
                     lim_tpdocav1     = tt-dados-avais.tpdocava
                     lim_dscpfav1     = tt-dados-avais.nrdocava
                     lim_nmdcjav1     = tt-dados-avais.nmconjug
                     lim_cpfccg1      = tt-dados-avais.nrcpfcjg
                     lim_tpdoccj1     = tt-dados-avais.tpdoccjg 
                     lim_dscfcav1     = tt-dados-avais.nrdoccjg
                     lim_dsendav1[1]  = tt-dados-avais.dsendre1
                     lim_dsendav1[2]  = tt-dados-avais.dsendre2
                     lim_nrfonres1    = tt-dados-avais.nrfonres
                     lim_dsdemail1    = tt-dados-avais.dsdemail
                     lim_nmcidade1    = tt-dados-avais.nmcidade
                     lim_cdufresd1    = tt-dados-avais.cdufresd
                     lim_nrcepend1    = tt-dados-avais.nrcepend
                     lim_nrendere1    = tt-dados-avais.nrendere
                     lim_complend1    = tt-dados-avais.complend
                     lim_nrcxapst1    = tt-dados-avais.nrcxapst
                     aux_jagravou     = TRUE.

          END.
       ELSE
          DO:
             ASSIGN lim_nmdaval2     = tt-dados-avais.nmdavali 
                    lim_cpfcgc2      = tt-dados-avais.nrcpfcgc 
                                       WHEN tt-dados-avais.nrctaava = 0
                    lim_tpdocav2     = tt-dados-avais.tpdocava 
                    lim_dscpfav2     = tt-dados-avais.nrdocava 
                    lim_nmdcjav2     = tt-dados-avais.nmconjug 
                    lim_cpfccg2      = tt-dados-avais.nrcpfcjg 
                    lim_tpdoccj2     = tt-dados-avais.tpdoccjg 
                    lim_dscfcav2     = tt-dados-avais.nrdoccjg 
                    lim_dsendav2[1]  = tt-dados-avais.dsendre1 
                    lim_dsendav2[2]  = tt-dados-avais.dsendre2 
                    lim_nrfonres2    = tt-dados-avais.nrfonres 
                    lim_dsdemail2    = tt-dados-avais.dsdemail 
                    lim_nmcidade2    = tt-dados-avais.nmcidade 
                    lim_cdufresd2    = tt-dados-avais.cdufresd 
                    lim_nrcepend2    = tt-dados-avais.nrcepend 
                    lim_nrendere2    = tt-dados-avais.nrendere 
                    lim_complend2    = tt-dados-avais.complend 
                    lim_nrcxapst2    = tt-dados-avais.nrcxapst.

          END.

   END.

   IF NOT VALID-HANDLE(h-b1wgen0043) THEN
      RUN sistema/generico/procedures/b1wgen0043.p
          PERSISTENT SET h-b1wgen0043.

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

   IF RETURN-VALUE <> "OK"   THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF AVAIL tt-erro   THEN
             DO:
                 MESSAGE tt-erro.dscritic.
                 PAUSE 2 NO-MESSAGE.
                 RETURN.

             END.

      END.

   FIND FIRST tt-valores-rating NO-LOCK NO-ERROR.

   FIND FIRST tt-dscchq_dados_limite NO-LOCK NO-ERROR.

   ASSIGN tel_nrctrpro = tt-dscchq_dados_limite.nrctrlim
          tel_vllimpro = tt-dscchq_dados_limite.vllimite
          tel_qtdiavig = tt-dscchq_dados_limite.qtdiavig
          tel_cddlinha = tt-dscchq_dados_limite.cddlinha
          
          tt-valores-rating.nrgarope = tt-dscchq_dados_limite.nrgarope
          tt-valores-rating.nrliquid = tt-dscchq_dados_limite.nrliquid   
          tt-valores-rating.vltotsfn = tt-dscchq_dados_limite.vltotsfn 

          lim_nrctaav1 = tt-dscchq_dados_limite.nrctaav1
          lim_nrctaav2 = tt-dscchq_dados_limite.nrctaav2.
                       

   ASSIGN tel_dsdlinha = tt-dscchq_dados_limite.dsdlinha
          tel_txjurmor = tt-dscchq_dados_limite.txjurmor 
          tel_dsramati = tt-dscchq_dados_limite.dsramati
          tel_vlmedchq = tt-dscchq_dados_limite.vlmedchq
          tel_vlfatura = tt-dscchq_dados_limite.vlfatura
          lim_vloutras = tt-dscchq_dados_limite.vloutras
          lim_vlsalari = tt-dscchq_dados_limite.vlsalari
          lim_vlsalcon = tt-dscchq_dados_limite.vlsalcon
          tel_dsdebens[1] = tt-dscchq_dados_limite.dsdbens1
          tel_dsdebens[2] = tt-dscchq_dados_limite.dsdbens2
          tel_dsobserv = tt-dscchq_dados_limite.dsobserv.


   FIND FIRST tt-dados_dscchq NO-LOCK NO-ERROR.

   ASSIGN tab_vlmaxlim = tt-dados_dscchq.vllimite
          tab_qtdiavig = tt-dados_dscchq.qtdiavig
          tab_txdmulta = tt-dados_dscchq.pcdmulta
          tab_qtdiasoc = tt-dados_dscchq.qtdiavig
          tel_txdmulta = tab_txdmulta.
    
   ALTERACAO:
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0.

         END.

      HIDE FRAME f_observacao NO-PAUSE.
      HIDE FRAME f_rating     NO-PAUSE.
      HIDE FRAME f_rendas     NO-PAUSE.

      DISPLAY tel_nrctrpro 
              tel_dsdlinha 
              tel_qtdiavig 
              tel_txjurmor
              tel_txdmulta
              WITH FRAME f_prolim.

      HIDE lim_dtcancel.
      
      UPDATE tel_vllimpro VALIDATE(tel_vllimpro <= tab_vlmaxlim,
                         "Limite maximo por contrato excedido, ver TAB019.")
             tel_cddlinha 
             tel_dsramati  
             tel_vlmedchq 
             tel_vlfatura 
             WITH FRAME f_prolim

      EDITING:
   
          READKEY.
      
          IF FRAME-FIELD = "tel_vllimpro" OR
             FRAME-FIELD = "tel_txjurmor" OR
             FRAME-FIELD = "tel_vldmulta" OR
             FRAME-FIELD = "tel_vlmedchq" OR
             FRAME-FIELD = "tel_vlfatura" THEN
             IF LASTKEY =  KEYCODE(".") THEN
                APPLY 44.
             ELSE
                APPLY LASTKEY.
          ELSE
            IF FRAME-FIELD = "tel_cddlinha"   THEN
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
                                   INPUT "A", /*cddopcao*/
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
                       NEXT ALTERACAO.
                   END.
                ELSE
                   NEXT ALTERACAO.
      
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
                                   NEXT ALTERACAO.
                                   
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
                                   NEXT ALTERACAO.
                                   
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
                                   NEXT ALTERACAO.
      
                               END.
      
                             NEXT. 
                                   
                        END.
      
                END CASE.
      
            END.
      
         LEAVE.
      
      END. /*final do DO WHILE TRUE */
      
      IF KEY-FUNCTION(LAST-KEY) = "END-ERROR" THEN
         NEXT ALTERACAO.
          
      
      DISPLAY tel_dsdlinha WITH FRAME f_prolim.     
      
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
                IF LASTKEY =  KEYCODE(".") THEN
                   APPLY 44.
                ELSE
                   APPLY LASTKEY.
             ELSE
                APPLY LASTKEY.
               
         END.  /*  Fim do EDITING  */
      
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = tel_nrdconta  
                               NO-LOCK NO-ERROR.
      
            IF crapass.inpessoa = 1    THEN
               DO:
                  HIDE tt-valores-rating.perfatcl IN FRAME f_rating.
                  HIDE tt-valores-rating.nrperger IN FRAME f_rating.
               END.
                         
            UPDATE tt-valores-rating.nrgarope
                   tt-valores-rating.nrinfcad
                   tt-valores-rating.nrliquid
                   tt-valores-rating.nrpatlvr
                   tt-valores-rating.vltotsfn 
                   tt-valores-rating.perfatcl WHEN crapass.inpessoa <> 1
                   tt-valores-rating.nrperger WHEN crapass.inpessoa <> 1
                   WITH FRAME f_rating
                
            EDITING:
                          
               READKEY.
                                       
               IF LASTKEY = KEYCODE("F7")   THEN
                  DO:
                     IF FRAME-FIELD = "nrgarope"   THEN
                        DO:
                           b-craprad:HELP = "Pressione <ENTER> p/ selecionar" +
                                            " a garantia.".
                                              
                           IF crapass.inpessoa = 1   THEN
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
                     IF FRAME-FIELD = "nrinfcad"   THEN
                        DO:
                           b-craprad:HELP =
                             "Pressione <ENTER> p/ selecionar as" +
                             " informacoes cadastrais.".
                                 
                           IF crapass.inpessoa = 1   THEN
                              RUN sequencia_rating (INPUT 1,
                                                    INPUT 4).
                           ELSE
                              RUN sequencia_rating (INPUT 3,
                                                    INPUT 3).
                                                   
                           IF AVAIL tt-itens-topico-rating   THEN
                              ASSIGN tt-valores-rating.nrinfcad = 
                                              tt-itens-topico-rating.nrseqite.
                                
                           DISPLAY tt-valores-rating.nrinfcad
                                   WITH FRAME f_rating.

                        END.
                     ELSE
                     IF FRAME-FIELD = "nrliquid"   THEN
                        DO:
                           b-craprad:HELP =
                             "Pressione <ENTER> p/ selecionar a" +
                             " liquidez das garantias.".
      
                           IF crapass.inpessoa = 1   THEN
                              RUN sequencia_rating (INPUT 2,
                                                      INPUT 3).
                           ELSE
                              RUN sequencia_rating (INPUT 4,
                                                    INPUT 3).
           
                           IF AVAIL tt-itens-topico-rating   THEN
                              ASSIGN tt-valores-rating.nrliquid =
                                         tt-itens-topico-rating.nrseqite.
      
                           DISPLAY tt-valores-rating.nrliquid
                                   WITH FRAME f_rating.

                        END.
                     ELSE
                     IF FRAME-FIELD = "nrpatlvr"   THEN
                        DO:
                           b-craprad:HELP = "Pressione <ENTER> p/ selecionar" +
                                            " os patrimonios pessoais livres.".
                                 
                           IF crapass.inpessoa = 1   THEN
                              RUN sequencia_rating (INPUT 1,
                                                    INPUT 8).
                           ELSE
                              RUN sequencia_rating (INPUT 3,
                                                    INPUT 9).
                                                   
                           IF AVAIL tt-itens-topico-rating   THEN
                              ASSIGN tt-valores-rating.nrpatlvr = 
                                        tt-itens-topico-rating.nrseqite.
                                 
                           DISPLAY tt-valores-rating.nrpatlvr
                                   WITH FRAME f_rating.

                        END.
                     ELSE
                     IF FRAME-FIELD = "nrperger"   THEN
                        DO:
                           b-craprad:HELP = "Pressione <ENTER> p/ selecionar" + 
                                            " a percepcao geral com relacao"  + 
                                            " a empresa.".
                                          
                           RUN sequencia_rating (INPUT 3,
                                                 INPUT 11).
                    
                           IF AVAIL tt-itens-topico-rating   THEN
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
                                       (INPUT  glb_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  glb_cdoperad,
                                        INPUT  glb_dtmvtolt,
                                        INPUT  tel_nrdconta,
                                        INPUT  tt-valores-rating.nrgarope,
                                        INPUT  tt-valores-rating.nrinfcad,
                                        INPUT  tt-valores-rating.nrliquid,
                                        INPUT  tt-valores-rating.nrpatlvr,
                                        INPUT  tt-valores-rating.nrperger,
                                        INPUT  1, /* Ayllos */
                                        INPUT  1, /* Titular */
                                        INPUT  glb_nmdatela,
                                        INPUT  FALSE,
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
                     HIDE MESSAGE.

                  END.
      
               IF aux_pertengp THEN
                  DO: 
                      IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                         RUN sistema/generico/procedures/b1wgen0138.p
                             PERSISTENT SET h-b1wgen0138. 

                      /* Procedure responsavel por calcular o 
                         endividamento do grupo */
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
             
                               DISP tt-grupo.dsdrisgp
                                    tel_nrdconta
                                    aux_qtctarel
                                    WITH FRAME f_grupo_economico2. 
                                
                               OPEN QUERY q-grupo-economico2
                                          FOR EACH tt-grupo NO-LOCK.
                                
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
                  NEXT ALTERACAO.
      
               LEAVE ALTERACAO.
         
            END.  /*  Fim do DO WHILE TRUE  */
      
            HIDE FRAME f_observacao NO-PAUSE.
      
         END.  /*  Fim do DO WHILE TRUE  */
      
         HIDE FRAME f_rating NO-PAUSE.
         
      END. /* Fim do DO WHILE TRUE */
      
      HIDE FRAME f_rendas NO-PAUSE.
      
   END.  /*  Fim do DO WHILE TRUE  */
      
   IF KEYFUNCTION(LAST-KEY) <> "END-ERROR" THEN
      DO:
         IF NOT VALID-HANDLE(h-b1wgen0009) THEN
            RUN sistema/generico/procedures/b1wgen0009.p 
                PERSISTENT SET h-b1wgen0009.

         RUN efetua_alteracao_limite IN h-b1wgen0009  
                                    (INPUT glb_cdcooper,    
                                     INPUT glb_cdagenci, 
                                     INPUT 0, /*nrdcaixa*/  
                                     INPUT tel_nrdconta,    
                                     INPUT glb_nmdatela,    
                                     INPUT 1, /*idorigem*/  
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
               PERSISTEN SET h-b1wgen0043.
      
          /** Grava alteracoes do rating do cooperado **/
        RUN atualiza_valores_rating IN h-b1wgen0043 
                                   (INPUT glb_cdcooper,
                                    INPUT 0,   /** PAC     **/
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
      
        IF RETURN-VALUE = "NOK"  THEN
           RUN fontes/lista_criticas_rating.p (INPUT TABLE tt-erro).

      END.

   LEAVE.

END.  /*  Fim  */


HIDE FRAME f_observacao   NO-PAUSE.
HIDE FRAME f_rating       NO-PAUSE.
HIDE FRAME f_promissoria1 NO-PAUSE.
HIDE FRAME f_promissoria2 NO-PAUSE.
HIDE FRAME f_rendas       NO-PAUSE.
HIDE FRAME f_prolim       NO-PAUSE.

PROCEDURE sequencia_rating:

   DEF INPUT PARAM par_nrtopico AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_nritetop AS INTE                            NO-UNDO.
      
    
   OPEN QUERY q-craprad 
        FOR EACH tt-itens-topico-rating 
                 WHERE tt-itens-topico-rating.nrtopico = par_nrtopico AND  
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





