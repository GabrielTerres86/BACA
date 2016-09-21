/* .............................................................................

   Programa: Fontes/dsctit_limite_a.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                     Ultima atualizacao: 23/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para alterar a proposta de limite de descontos de titulos.

   Alteracoes: 10/12/2009 - Geracao do rating (Gabriel). 
                          - Mostra valores do rating das tabelas crapttl ou 
                            crapjur ao inves da tabela craplim;
                          - Grava rating na crapttl ou crapjur além da craplim
                            (Elton).
                            
               01/03/2010 - Mostrar as criticas do Rating (Gabriel).  
               
               07/06/2010 - Adaptacao para RATING no Ayllos Web (David).
               
               05/04/2011 - Alteracao do valor dos parametros da procedure
                            sequencia_rating, para atender a nova tabela do
                            rating. (Fabrício)
                            
               20/04/2011 - Inseridos parametros de CEP integrado nrendere,
                            nrcxapst, e complend. (André - DB1)
                            
               14/07/2011 - Voltar atras quando F4/END-ERROR no fontes do
                            avalista (Gabriel).             
                            
               05/09/2011 - Incluido a chamada da procedure alerta_fraude
                            (Adriano).
                            
               09/07/2012 - Alteraçoes para listagem de Linhas de Desconto de
                            Título disponíveis ao pressionar F7 (Lucas).
                            
               05/11/2012 - Ajuste refente ao projeto GE (Adriano).      
               
               26/03/2013 - Ajsutes realizados:
                            - Retirado a chamada da procedure alerta_fraude;
                            - Retirado o tratamento "WHEN 33 " para o 
                              tratamento do tt-msg-confirma.inconfir (Adriano).
                              
               23/06/2014 - Inclusao da include b1wgen0138tt para uso da
                            temp-table tt-grupo ao invés da tt-ge-ocorrencias.
                            (Chamado 130880) - (Tiago Castro - RKAM)
                                                                                   
............................................................................. */

DEF INPUT PARAM par_nrctrlim AS INTE NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_dsctit.i }

DEF VAR aux_vlmaxleg         AS DEC                               NO-UNDO.
DEF VAR aux_vlmaxutl         AS DEC                               NO-UNDO.
DEF VAR aux_vlminscr         AS DEC                               NO-UNDO.
DEF VAR aux_vlexcedi         AS LOG                               NO-UNDO.

DEF VAR aux_dtmvtolt         AS DATE   FORMAT "99/99/9999"        NO-UNDO.
DEF VAR aux_inconfir         AS INTE                              NO-UNDO.
DEF VAR aux_inconfi2         AS INTE                              NO-UNDO.
DEF VAR aux_inconfi4         AS INTE                              NO-UNDO.
DEF VAR aux_inconfi5         AS INTE                              NO-UNDO.
DEF VAR aux_nriniseq         AS INTE                              NO-UNDO.
                                                               
DEF VAR aux_cdcritic         AS INTE                              NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                              NO-UNDO.
DEF VAR flg_next             AS LOGICAL                           NO-UNDO.
                                                               
DEF VAR h-b1wgen0030         AS HANDLE                            NO-UNDO.
DEF VAR h-b1wgen0043         AS HANDLE                            NO-UNDO.
DEF VAR h-b1wgen9999         AS HANDLE                            NO-UNDO.
DEF VAR h-b1wgen0138         AS HANDLE                            NO-UNDO.

DEF VAR aux_nrdgrupo AS INT                                       NO-UNDO.
DEF VAR aux_dsdrisgp AS CHAR                                      NO-UNDO.
DEF VAR aux_gergrupo AS CHAR                                      NO-UNDO.
DEF VAR aux_riscogrp AS CHAR FORMAT "X(2)"                        NO-UNDO.
DEF VAR aux_vlutiliz AS DEC                                       NO-UNDO.
DEF VAR aux_pertengp AS LOG                                       NO-UNDO.


DEF QUERY  q-craprad FOR tt-itens-topico-rating SCROLLING.

DEF BROWSE b-craprad QUERY q-craprad
    DISPLAY nrseqite COLUMN-LABEL "Seq.Item"
            dsseqite COLUMN-LABEL "Descricao Seq.Item" FORMAT "x(55)"
                     WITH CENTERED 5 DOWN TITLE " Itens do Rating ".

FORM b-craprad 
     WITH CENTERED NO-BOX OVERLAY ROW 10 FRAME f_craprad.

tt-dsctit_dados_limite.cddlinha:HELP = 
"Entre com a Linha de Desconto ou pressine F7 para listar.".

ON RETURN OF b-craprad IN FRAME f_craprad
   DO:
      APPLY "GO".
   END.


RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        MESSAGE "Handle Invalido para h-b1wgen0030".
        RETURN.
    END.

RUN busca_dados_limite_altera IN h-b1wgen0030 
                             (INPUT glb_cdcooper,
                              INPUT 0, /*agencia*/
                              INPUT 0, /*caixa*/
                              INPUT glb_cdoperad,
                              INPUT glb_dtmvtolt,
                              INPUT 1, /*origem*/
                              INPUT tel_nrdconta,
                              INPUT 1, /*idseqttl*/
                              INPUT glb_nmdatela,
                              INPUT par_nrctrlim,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-dsctit_dados_limite,
                             OUTPUT TABLE tt-dados-avais,
                             OUTPUT TABLE tt-risco,
                             OUTPUT TABLE tt-dados_dsctit).
                        
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF  AVAIL tt-erro  THEN
            DO:
                MESSAGE tt-erro.dscritic.
                RETURN.
            END.
        ELSE
            DO:
                MESSAGE "Registro de limite nao encontrado".
                RETURN.
            END.
    END.

FIND tt-dsctit_dados_limite NO-LOCK NO-ERROR.

IF  NOT AVAIL tt-dsctit_dados_limite  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        MESSAGE "Registro de limite nao encontrado".
        RETURN.
    END.
    
    
FIND FIRST tt-risco WHERE tt-risco.diaratin <> 0 NO-LOCK NO-ERROR.

IF  NOT AVAIL tt-risco  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        MESSAGE "Registro de risco nao encontrado".
        RETURN.
    END.    
    
FIND tt-dados_dsctit NO-LOCK NO-ERROR.

IF  NOT AVAIL tt-dados_dsctit  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        MESSAGE "Registro de limite craptab nao encontrado".
        RETURN.
    END.

RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

RUN busca_dados_rating IN h-b1wgen0043 (INPUT glb_cdcooper,
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
                                    
DELETE PROCEDURE h-b1wgen0043.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-erro  THEN
            ASSIGN glb_dscritic = tt-erro.dscritic.
        ELSE
            ASSIGN glb_dscritic = "Parametros de rating nao encontrados.".
             
        MESSAGE glb_dscritic.
        RETURN.
    END.
    
ASSIGN aux_dtmvtolt = (glb_dtmvtolt - tt-risco.diaratin). /* 180 dias */    

FIND FIRST tt-dados-avais NO-LOCK NO-ERROR.

IF  NOT AVAIL tt-dados-avais THEN                  
    ASSIGN lim_nrctaav1     = 0                    
           lim_nmdaval1     = " "                  
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
           lim_nrcxapst1    = 0                    
           lim_complend1    = " "                  
                                                   
           lim_nrctaav1     = 0                    
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
           lim_nrcxapst2    = 0                    
           lim_complend2    = " ".                 
ELSE                                               
    ASSIGN lim_nrctaav1    = tt-dados-avais.nrctaava                           
           lim_nmdaval1    = tt-dados-avais.nmdavali
           lim_cpfcgc1     = tt-dados-avais.nrcpfcgc
           lim_tpdocav1    = tt-dados-avais.tpdocava
           lim_dscpfav1    = tt-dados-avais.nrdocava
           lim_nmdcjav1    = tt-dados-avais.nmconjug
           lim_cpfccg1     = tt-dados-avais.nrcpfcjg
           lim_tpdoccj1    = tt-dados-avais.tpdoccjg
           lim_dscfcav1    = tt-dados-avais.nrdoccjg
           lim_dsendav1[1] = tt-dados-avais.dsendre1
           lim_dsendav1[2] = tt-dados-avais.dsendre2
           lim_nrfonres1   = tt-dados-avais.nrfonres
           lim_dsdemail1   = tt-dados-avais.dsdemail
           lim_nmcidade1   = tt-dados-avais.nmcidade
           lim_cdufresd1   = tt-dados-avais.cdufresd
           lim_nrcepend1   = tt-dados-avais.nrcepend
           lim_nrendere1   = tt-dados-avais.nrendere
           lim_complend1   = tt-dados-avais.complend
           lim_nrcxapst1   = tt-dados-avais.nrcxapst.
                                                   
FIND NEXT tt-dados-avais NO-LOCK NO-ERROR.         
                                                   
IF  AVAIL tt-dados-avais THEN                      
    ASSIGN lim_nrctaav2    = tt-dados-avais.nrctaava                     
           lim_nmdaval2    = tt-dados-avais.nmdavali
           lim_cpfcgc2     = tt-dados-avais.nrcpfcgc
           lim_tpdocav2    = tt-dados-avais.tpdocava
           lim_dscpfav2    = tt-dados-avais.nrdocava
           lim_nmdcjav2    = tt-dados-avais.nmconjug
           lim_cpfccg2     = tt-dados-avais.nrcpfcjg
           lim_tpdoccj2    = tt-dados-avais.tpdoccjg
           lim_dscfcav2    = tt-dados-avais.nrdoccjg
           lim_dsendav2[1] = tt-dados-avais.dsendre1
           lim_dsendav2[2] = tt-dados-avais.dsendre2
           lim_nrfonres2   = tt-dados-avais.nrfonres
           lim_dsdemail2   = tt-dados-avais.dsdemail
           lim_nmcidade2   = tt-dados-avais.nmcidade
           lim_cdufresd2   = tt-dados-avais.cdufresd
           lim_nrcepend2   = tt-dados-avais.nrcepend
           lim_nrendere2   = tt-dados-avais.nrendere
           lim_complend2   = tt-dados-avais.complend
           lim_nrcxapst2   = tt-dados-avais.nrcxapst.

DO WHILE TRUE ON ERROR UNDO, LEAVE:                
                                                   
    
   ALTERACAO:                                      
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:   

      IF   glb_cdcritic > 0   THEN                 
           DO:                                     
               RUN fontes/critic.p.                
               BELL.                               
               MESSAGE glb_dscritic.               
               glb_cdcritic = 0.                   
           END.                                    
                                                   
      HIDE FRAME f_observacao     NO-PAUSE.        
      HIDE FRAME f_dsctit_rendas  NO-PAUSE.        
      HIDE FRAME f_rating         NO-PAUSE.        
                                                   
      EMPTY TEMP-TABLE tt-erro.                    
                                                   
      DISPLAY tt-dsctit_dados_limite.nrctrlim      
              tt-dsctit_dados_limite.dsdlinha      
              tt-dsctit_dados_limite.qtdiavig      
              tt-dsctit_dados_limite.txdmulta      
              WITH FRAME f_dsctit_prolim.          
                                                   
      HIDE tt-dsctit_dados_limite.dtcancel IN FRAME f_dsctit_prolim.
                                                   
      lab:                                         
      DO WHILE TRUE: 

          IF  KEYFUNCTION(LASTKEY) = "END-ERROR" AND 
              FRAME-FIELD = "b_linhas_desc"      THEN
              DO:             
                  NEXT-PROMPT tt-dsctit_dados_limite.cddlinha WITH FRAME f_dsctit_prolim.
              END.    

          RUN lista-linhas-desc-tit IN h-b1wgen0030 (INPUT glb_cdcooper,
                                                     INPUT glb_cdagenci, /*cdagenci*/
                                                     INPUT 0,            /*nrdcaixa*/
                                                     INPUT glb_cdoperad,
                                                     INPUT glb_dtmvtolt,
                                                     INPUT tel_nrdconta,
                                                     INPUT 0,
                                                     INPUT 999,
                                                     INPUT 0,
                                                     OUTPUT aux_nriniseq,
                                                     OUTPUT TABLE tt-linhas_desc).

          DO WHILE TRUE:

              UPDATE tt-dsctit_dados_limite.vllimite   
                      VALIDATE (tt-dsctit_dados_limite.vllimite <= tt-dados_dsctit.vllimite,
                     "Limite maximo por contrato excedido, valor maximo R$ " + STRING(tt-dados_dsctit.vllimite,"zzz,zzz,zz9.99") + ".")
                     tt-dsctit_dados_limite.cddlinha
                     VALIDATE (CAN-FIND (tt-linhas_desc WHERE tt-linhas_desc.cddlinha = tt-dsctit_dados_limite.cddlinha NO-LOCK) OR 
                               tt-dsctit_dados_limite.cddlinha = 0, 
                               "Linha de Desconto inexistente.")
                     tt-dsctit_dados_limite.dsramati  
                     tt-dsctit_dados_limite.vlmedtit 
                     tt-dsctit_dados_limite.vlfatura 
                     WITH FRAME f_dsctit_prolim        
                    
              EDITING:        
             
                  HIDE FRAME f_linhas_desc NO-PAUSE.
                                                       
                  READKEY.    
             
                  IF  LASTKEY =  KEYCODE("F7") AND     
                      FRAME-FIELD = "cddlinha" THEN    
                      DO:                            
                          OPEN QUERY q_linhas_desc FOR EACH tt-linhas_desc NO-LOCK.
             
                          ON  RETURN OF b_linhas_desc
                              DO:                     
                                  IF TEMP-TABLE tt-linhas_desc:HAS-RECORDS THEN
                                      DO:
                                          ASSIGN tt-dsctit_dados_limite.cddlinha = tt-linhas_desc.cddlinha
                                                 tt-dsctit_dados_limite.dsdlinha = tt-linhas_desc.dsdlinha.
                                          
                                          DISPLAY tt-dsctit_dados_limite.cddlinha
                                                  tt-dsctit_dados_limite.dsdlinha 
                                                  WITH FRAME f_dsctit_prolim.
                                      END.
                                    
                                  APPLY "GO". 
                              END.
             
                          DO WHILE TRUE ON ENDKEY UNDO, NEXT lab:
             
                              UPDATE b_linhas_desc WITH FRAME f_linhas_desc.
                              HIDE FRAME f_linhas_desc NO-PAUSE.
                              LEAVE.
                        
                          END.
                      END.
                     
                  ON  RETURN OF tt-dsctit_dados_limite.cddlinha 
                      DO:
                          FIND tt-linhas_desc WHERE tt-linhas_desc.cddlinha = INTEGER(FRAME-VALUE)
                                                                          NO-LOCK NO-ERROR NO-WAIT.
                          IF  AVAIL tt-linhas_desc THEN
                              DO:
                                  ASSIGN tt-dsctit_dados_limite.cddlinha = tt-linhas_desc.cddlinha
                                         tt-dsctit_dados_limite.dsdlinha = tt-linhas_desc.dsdlinha.
                                        
                                  DISPLAY tt-dsctit_dados_limite.cddlinha
                                          tt-dsctit_dados_limite.dsdlinha 
                                          WITH FRAME f_dsctit_prolim.
                              END. 
                      END.
                    
                  IF  FRAME-FIELD = "tt-dsctit_dados_limite.vllimite"   OR
                      FRAME-FIELD = "tt-dsctit_dados_limite.txjurmor"   OR
                      FRAME-FIELD = "tt-dsctit_dados_limite.vldmulta"   OR
                      FRAME-FIELD = "tt-dsctit_dados_limite.vlmedtit"   OR
                      FRAME-FIELD = "tt-dsctit_dados_limite.dsramati"   THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
             
                  APPLY LASTKEY.
                  
              END.  /*  Fim do EDITING  */
              LEAVE.

          END. /* DO WHILE TRUE */
          LEAVE.
          
      END. /* DO WHILE TRUE lab */
       
      ASSIGN aux_inconfir = 1
             aux_inconfi2 = 11
             aux_inconfi4 = 71
             aux_inconfi5 = 30.

      DO  WHILE TRUE:

          RUN valida_proposta_dados IN h-b1wgen0030
                                   (INPUT glb_cdcooper,
                                    INPUT 0, /*agencia*/
                                    INPUT 0, /*caixa*/
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT 1, /*origem*/
                                    INPUT tel_nrdconta,
                                    INPUT 1, /*idseqttl*/
                                    INPUT par_nrctrlim,
                                    INPUT glb_dtmvtolt,
                                    INPUT glb_dtmvtopr,
                                    INPUT glb_inproces,
                                    INPUT tt-risco.diaratin,
                                    INPUT tt-dsctit_dados_limite.vllimite,
                                    INPUT aux_dtmvtolt, /*dtrating*/
                                    INPUT tt-risco.vlrrisco,
                                    INPUT "A", /*cddopcao*/
                                    INPUT tt-dsctit_dados_limite.cddlinha,
                                    INPUT aux_inconfir,
                                    INPUT aux_inconfi2,
                                    INPUT aux_inconfi4,
                                    INPUT aux_inconfi5,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-msg-confirma,
                                    OUTPUT TABLE tt-grupo).
      
          IF RETURN-VALUE = "NOK"  THEN
             DO:
                /*Se valor legal excedido, mostrara mensagem informando o
                 ocorrido e o grupo economico caso a conta em questao
                 participe de algum. */
                 FIND FIRST tt-msg-confirma WHERE tt-msg-confirma.inconfir = 19 
                                            NO-LOCK NO-ERROR.

                 IF AVAIL tt-msg-confirma THEN
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

                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF AVAIL tt-erro  THEN
                   DO:
                       MESSAGE tt-erro.dscritic.
                       NEXT ALTERACAO.
                   END.

             END.

        FIND LAST tt-msg-confirma NO-LOCK NO-ERROR.

        IF  AVAIL tt-msg-confirma  THEN
            DO:
                CASE tt-msg-confirma.inconfir:
                    WHEN 2  THEN DO:
                                    /* Necessaria atualizacao RATING */
                                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        ASSIGN aux_confirma = "N".
                                        BELL.
                                        MESSAGE tt-msg-confirma.dsmensag
                                            UPDATE aux_confirma.
                                        ASSIGN aux_inconfir = 
                                               tt-msg-confirma.inconfir.
                                        LEAVE.
                                    END.
                                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                        aux_confirma <> "S" THEN
                                        DO:
                                            glb_cdcritic = 79.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE glb_dscritic.
                                            ASSIGN glb_cdcritic = 0
                                                   flg_next = TRUE.
                                            LEAVE.
                                        END.
                                    NEXT.
                                  END.      
                    WHEN 12 THEN DO:
                                    /* Valores Excedidos */
                                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        ASSIGN aux_confirma = "N".
                                        BELL.
                                        MESSAGE tt-msg-confirma.dsmensag
                                            UPDATE aux_confirma.
                                        ASSIGN aux_inconfi2 = 
                                               tt-msg-confirma.inconfir.
                                        LEAVE.
                                    END.
                                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                        aux_confirma <> "S" THEN
                                        DO:
                                            glb_cdcritic = 79.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE glb_dscritic.
                                            ASSIGN glb_cdcritic = 0
                                                   flg_next = TRUE.
                                            LEAVE.
                                        END.
                                    NEXT.
                                  END.    
                    WHEN 72 THEN DO: 
                                     MESSAGE tt-msg-confirma.dsmensag.
                                     LEAVE.
                                 END.
                    WHEN 31 THEN DO: 
                                     /* Valores Excedidos */
                                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        ASSIGN aux_confirma = "N".
                                        BELL.
                                        MESSAGE tt-msg-confirma.dsmensag
                                            UPDATE aux_confirma.
                                        ASSIGN aux_inconfi5 = 
                                               tt-msg-confirma.inconfir + 1.
                                        LEAVE.       

                                     END.

                                     IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                        aux_confirma <> "S" THEN
                                        DO:
                                            glb_cdcritic = 79.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE glb_dscritic.
                                            ASSIGN glb_cdcritic = 0
                                                   flg_next = TRUE.
                                            LEAVE.

                                        END.

                                      NEXT. 

                                 END.

                END CASE.
                    
            END.          

          LEAVE.
      END. /* final do DO WHILE */
      
      /* ------------------------ 
         Quando o registro esta LOCKED e o operador der END-ERROR 
         forca a volta para o inicio do bloco.
      ----------------------- */
      IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
          NEXT ALTERACAO.
      
      IF  flg_next THEN
          DO:
              flg_next = FALSE.
              NEXT.
          END.    

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
         UPDATE tt-dsctit_dados_limite.vlsalari 
                tt-dsctit_dados_limite.vlsalcon 
                tt-dsctit_dados_limite.vloutras 
                tt-dsctit_dados_limite.dsdbens1
                tt-dsctit_dados_limite.dsdbens2 
                WITH FRAME f_dsctit_rendas

         EDITING:

             READKEY.
   
             IF   FRAME-FIELD = "tt-dsctit_dados_limite.vlsalari"   OR
                  FRAME-FIELD = "tt-dsctit_dados_limite.vlsalcon"   OR
                  FRAME-FIELD = "tt-dsctit_dados_limite.vloutras"   THEN
                  IF   LASTKEY =  KEYCODE(".")   THEN
                       APPLY 44.
                  ELSE
                       APPLY LASTKEY.
             ELSE
                  APPLY LASTKEY.
               
         END.  /*  Fim do EDITING  */

         /** Busca rating das tabelas crapttl ou crapjur **/
         FIND FIRST tt-valores-rating NO-LOCK NO-ERROR.
                               
         IF   tt-valores-rating.inpessoa = 1    THEN
              DO:
                  HIDE tt-dsctit_dados_limite.perfatcl IN FRAME f_rating.
                  HIDE tt-dsctit_dados_limite.nrperger IN FRAME f_rating.
              END.

         ASSIGN tt-dsctit_dados_limite.nrinfcad = 
                         tt-valores-rating.nrinfcad
             
                tt-dsctit_dados_limite.nrpatlvr = 
                         tt-valores-rating.nrpatlvr
             
                tt-dsctit_dados_limite.nrperger = 
                         tt-valores-rating.nrperger. 

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tt-dsctit_dados_limite.nrgarope 
                   tt-dsctit_dados_limite.nrinfcad
                   tt-dsctit_dados_limite.nrliquid 
                   tt-dsctit_dados_limite.nrpatlvr
                   tt-dsctit_dados_limite.vltotsfn
                   tt-dsctit_dados_limite.perfatcl WHEN tt-valores-rating.inpessoa <> 1
                   tt-dsctit_dados_limite.nrperger WHEN tt-valores-rating.inpessoa <> 1
                   WITH FRAME f_rating
                           
              EDITING:
                        
               READKEY.
                                      
               IF   LASTKEY = KEYCODE("F7")   THEN
                    DO:
                       IF   FRAME-FIELD = "nrgarope"   THEN
                            DO:
                               b-craprad:HELP = 
                                        "Pressione <ENTER> p/ selecionar a" + 
                                        " garantia.".
                                                 
                               IF   tt-valores-rating.inpessoa = 1   THEN
                                    RUN sequencia_rating (INPUT 2,
                                                          INPUT 2).
                               ELSE
                                    RUN sequencia_rating (INPUT 4,
                                                          INPUT 2).
                                                      
                               IF  AVAIL tt-itens-topico-rating  THEN
                                   ASSIGN tt-dsctit_dados_limite.nrgarope = 
                                                               tt-itens-topico-rating.nrseqite.
                                     
                               DISPLAY tt-dsctit_dados_limite.nrgarope
                                       WITH FRAME f_rating.
                                        
                            END.
                       ELSE
                       IF   FRAME-FIELD = "nrinfcad"   THEN
                            DO:
                               b-craprad:HELP = 
                                   "Pressione <ENTER> p/ selecionar as" +
                                   " informacoes cadastrais.".
                                     
                               IF   tt-valores-rating.inpessoa = 1   THEN
                                    RUN sequencia_rating (INPUT 1,
                                                          INPUT 4).
                               ELSE
                                    RUN sequencia_rating (INPUT 3,
                                                          INPUT 3).
     
                               IF   AVAIL tt-itens-topico-rating   THEN
                                    ASSIGN tt-dsctit_dados_limite.nrinfcad = 
                                                               tt-itens-topico-rating.nrseqite.
                                          
                               DISPLAY tt-dsctit_dados_limite.nrinfcad
                                       WITH FRAME f_rating.
                            END.
                       ELSE
                       IF   FRAME-FIELD = "nrliquid"   THEN     
                            DO:
                               b-craprad:HELP = 
                                   "Pressione <ENTER> p/ selecionar a" + 
                                   " liquidez das garantias.".
     
                               IF   tt-valores-rating.inpessoa = 1   THEN
                                    RUN sequencia_rating (INPUT 2,
                                                          INPUT 3).
                               ELSE
                                    RUN sequencia_rating (INPUT 4,
                                                          INPUT 3).
                       
                               IF   AVAIL tt-itens-topico-rating  THEN
                                    ASSIGN tt-dsctit_dados_limite.nrliquid = 
                                                               tt-itens-topico-rating.nrseqite.
      
                               DISPLAY tt-dsctit_dados_limite.nrliquid
                                       WITH FRAME f_rating.
                            END.
                       ELSE
                       IF   FRAME-FIELD = "nrpatlvr"   THEN
                            DO:
                               b-craprad:HELP = 
                                 "Pressione <ENTER> p/ selecionar os" + 
                                 " patrimonios pessoais livres.".
                                          
                               IF   tt-valores-rating.inpessoa = 1   THEN
                                     RUN sequencia_rating (INPUT 1,
                                                           INPUT 8).
                               ELSE
                                     RUN sequencia_rating (INPUT 3,
                                                           INPUT 9).
             
                               IF   AVAIL tt-itens-topico-rating   THEN
                                    ASSIGN tt-dsctit_dados_limite.nrpatlvr = 
                                                               tt-itens-topico-rating.nrseqite.
      
                               DISPLAY tt-dsctit_dados_limite.nrpatlvr
                                       WITH FRAME f_rating.
                                  
                            END.
                       ELSE
                       IF   FRAME-FIELD = "nrperger" AND
                            tt-valores-rating.inpessoa <> 1   THEN
                            DO:
                               b-craprad:HELP = 
                                   "Pressione <ENTER> p/ selecionar a" + 
                                   " percepcao geral com relacao a empresa.".
                                          
                               RUN sequencia_rating (INPUT 3,
                                                     INPUT 11).
                               
                               IF   AVAIL tt-itens-topico-rating   THEN
                                    ASSIGN tt-dsctit_dados_limite.nrperger = 
                                                               tt-itens-topico-rating.nrseqite.
      
                               DISPLAY tt-dsctit_dados_limite.nrperger
                                       WITH FRAME f_rating. 
                            END.
                       ELSE     
                            APPLY LASTKEY.
                    END.
               ELSE
                    APPLY LASTKEY.

              END. /* Fim do EDITING */      

              /* Validar os campos do RATING */

              RUN sistema/generico/procedures/b1wgen0043.p 
                    PERSISTENT SET h-b1wgen0043.

              RUN valida-itens-rating IN h-b1wgen0043 
                                     (INPUT  glb_cdcooper,
                                      INPUT  0,
                                      INPUT  0,
                                      INPUT  glb_cdoperad,
                                      INPUT  glb_dtmvtolt,
                                      INPUT  tel_nrdconta,
                                      INPUT  tt-dsctit_dados_limite.nrgarope,
                                      INPUT  tt-dsctit_dados_limite.nrinfcad,
                                      INPUT  tt-dsctit_dados_limite.nrliquid,
                                      INPUT  tt-dsctit_dados_limite.nrpatlvr,
                                      INPUT  tt-dsctit_dados_limite.nrperger,
                                      INPUT  1, /* Titular*/ 
                                      INPUT  1, /* Ayllos */ 
                                      INPUT  glb_nmdatela,
                                      INPUT  FALSE,
                                      OUTPUT TABLE tt-erro).

               DELETE PROCEDURE h-b1wgen0043.

               IF   RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF   AVAILABLE tt-erro   THEN
                             DO:
                                 MESSAGE tt-erro.dscritic.
                                 NEXT.
                             END.
                    END.
    
              ASSIGN tel_dsobserv = tt-dsctit_dados_limite.dsobserv.
              
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                 DISPLAY tel_dsobserv WITH FRAME f_observacao.
           
                 ENABLE ALL WITH FRAME f_observacao.
          
                 WAIT-FOR CHOOSE OF btn_btaosair.
                 
                 RUN fontes/dsctit_aval.p.
          
                 IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.
                 
                 IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                    RUN sistema/generico/procedures/b1wgen0138.p
                        PERSISTENT SET h-b1wgen0138.

                 ASSIGN aux_pertengp = DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                      INPUT glb_cdcooper,
                                                      INPUT tel_nrdconta,
                                                      OUTPUT aux_nrdgrupo,
                                                      OUTPUT aux_gergrupo,
                                                      OUTPUT aux_dsdrisgp).

                 IF VALID-HANDLE(h-b1wgen0138) THEN
                    DELETE OBJECT h-b1wgen0138.

                 IF aux_gergrupo <> "" THEN
                    MESSAGE aux_gergrupo.

                 IF aux_pertengp THEN
                    DO:
                       IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                          RUN sistema/generico/procedures/b1wgen0138.p
                              PERSISTENT SET h-b1wgen0138.

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
                                                  OUTPUT aux_riscogrp,
                                                  OUTPUT aux_vlutiliz,
                                                  OUTPUT TABLE tt-grupo,
                                                  OUTPUT TABLE tt-erro).

                       IF VALID-HANDLE(h-b1wgen0138) THEN
                          DELETE OBJECT(h-b1wgen0138).
                       
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

         END. /* Fim do DO WHILE TRUE */
          
         HIDE FRAME f_rating NO-PAUSE.
   
      END.  /*  Fim do DO WHILE TRUE  */

      HIDE FRAME f_dsctit_rendas NO-PAUSE.

   END.  /*  Fim do DO WHILE TRUE  */

      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S" THEN
        DO:
            DELETE PROCEDURE h-b1wgen0030.
            LEAVE.
        END.

   RUN efetua_alteracao_limite IN h-b1wgen0030 
                                    (INPUT glb_cdcooper,
                                     INPUT 0, /*cdagenci*/
                                     INPUT 0, /*nrdcaixa*/
                                     INPUT tel_nrdconta,
                                     INPUT glb_nmdatela,
                                     INPUT 1, /*cdorigem*/
                                     INPUT 1, /*idseqttl*/
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_cdoperad,
                                     INPUT tt-dsctit_dados_limite.vllimite,
                                     INPUT tt-dsctit_dados_limite.dsramati,
                                     INPUT tt-dsctit_dados_limite.vlmedtit,
                                     INPUT tt-dsctit_dados_limite.vlfatura,
                                     INPUT tt-dsctit_dados_limite.vloutras,
                                     INPUT tt-dsctit_dados_limite.vlsalari,
                                     INPUT tt-dsctit_dados_limite.vlsalcon,
                                     INPUT tt-dsctit_dados_limite.dsdbens1,
                                     INPUT tt-dsctit_dados_limite.dsdbens2,
                                     INPUT par_nrctrlim,
                                     INPUT tt-dsctit_dados_limite.cddlinha,
                                     INPUT INPUT tel_dsobserv,
                                     INPUT TRUE, /* LOG */
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
                                     INPUT tt-dsctit_dados_limite.nrgarope,
                                     INPUT tt-dsctit_dados_limite.nrinfcad,
                                     INPUT tt-dsctit_dados_limite.nrliquid,
                                     INPUT tt-dsctit_dados_limite.nrpatlvr,
                                     INPUT tt-dsctit_dados_limite.nrperger,
                                     INPUT tt-dsctit_dados_limite.vltotsfn,
                                     INPUT tt-dsctit_dados_limite.perfatcl,
                                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0030.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    LEAVE.
                END.
        END.

    RUN sistema/generico/procedures/b1wgen0043.p PERSISTEN SET h-b1wgen0043.

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
                                INPUT tt-dsctit_dados_limite.nrinfcad,
                                INPUT tt-dsctit_dados_limite.nrpatlvr,
                                INPUT tt-dsctit_dados_limite.nrperger,
                                INPUT 3,  /** Dsc.Tit. **/
                                INPUT tt-dsctit_dados_limite.nrctrlim,
                                INPUT FALSE,
                               OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0043.

    HIDE FRAME f_observacao NO-PAUSE.


    IF  RETURN-VALUE = "NOK"  THEN
        RUN fontes/lista_criticas_rating.p (INPUT TABLE tt-erro).

    LEAVE.

END.  /*  Fim do DO */

HIDE FRAME f_dsctit_promissoria NO-PAUSE.
HIDE FRAME f_observacao         NO-PAUSE.
HIDE FRAME f_dsctit_rendas      NO-PAUSE.
HIDE FRAME f_dsctit_prolim      NO-PAUSE.
HIDE FRAME f_rating             NO-PAUSE.


PROCEDURE sequencia_rating:

   DEF INPUT PARAM par_nrtopico AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_nritetop AS INTE                            NO-UNDO.
      

   OPEN QUERY q-craprad FOR EACH tt-itens-topico-rating WHERE
            
                        tt-itens-topico-rating.nrtopico = par_nrtopico   AND
                        tt-itens-topico-rating.nritetop = par_nritetop   NO-LOCK.
                                 
   IF   NUM-RESULTS("q-craprad")  = 0  THEN
        RETURN.
        
   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
      
      UPDATE b-craprad
             WITH FRAME f_craprad.
      LEAVE.
                                 
   END. /* Fim do DO WHILE TRUE */
                                     
   HIDE FRAME f_craprad.
                                        
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        RELEASE tt-itens-topico-rating.

END PROCEDURE.

/* .......................................................................... */


