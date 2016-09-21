/* .............................................................................

   Programa: Fontes/cmesaqi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2003.                    Ultima atualizacao: 19/07/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela CMESAQ.

   Alteracoes: 30/09/2003 - Nao registrar acima de R$ 100.000 quando pessoa
                            juridica (Margarete).
               
               23/05/2005 - Inclusao parametro bo imp ctr saques(Mirtes)

               27/06/2005 - Alimentado campo cdcooper da tabela crapcme        
                            (Diego).

               19/10/2005 - Inclusao parametro cooperativa
                                     bo imp ctr saques(Julio)

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               22/05/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               16/12/2008 - Tratar erros na chamada da BO
                            bo_controla_saques(Guilherme).
                            
               10/12/2009 - Adicionados parametros na chamada da procedure
                            bo imp ctr saques da bo_controle_saques
                            (Fernando).          
                            
               04/05/2010 - Ajustado programa para as movimentações em
                            espécie criadas na rotina 20 (a partir da
                            craptvl). (Fernando)                
                            
               20/05/2011 - Retirar campo Registrar.
                            Enviar email de Controle de Movimentacao.
                            Incluir campo 'Inf. prestadas pelo Cooperado'.
                            (Gabriel)             
                            
               22/06/2011 - Passar como parametro para a impressao o
                            operador logado e nao operador do lote (Gabriel)  
                            
               25/07/2011 - Nao informar ao COAF quando conta administrativa
                            (Gabriel)                            
                            
               16/09/2011 - Retirar tipo de Pessoa, obrigar pessoa fisica.
                            Incluir campo 'Valor sendo levado'. (Gabriel)
                            
               04/10/2011 - Se conta nao informada no DOC ou TED da erro
                            de associado nao cadastrado (Magui).
                            
               16/11/2011 - Converter para BO (Gabriel).
               
               23/12/2011 - Incluir tratamento para a transferencia 
                            intercooperativa (Gabriel). 
                            
               22/02/2012 - Informar conta (quando tipo 0) e, dessa forma,
                            não permitir encontrar registros duplicados. (Lucas)
                            
               19/07/2012 - Adicionado campo tel_nrdconta na chamada da 
                            procedure 'inclui_altera_dados'. (Jorge)              
............................................................................. */

                                     
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0104tt.i }                                     

{ includes/var_online.i }
{ includes/var_cmesaq_1.i }
{ includes/var_cmesaq.i }


DO WHILE TRUE:

   RUN fontes/inicia.p.
  
   HIDE MESSAGE NO-PAUSE.
   
   CLEAR FRAME f_cmesaq ALL.
   
   DISPLAY glb_cddopcao
           tel_dtmvtolt 
           tel_tpdocmto WITH FRAME f_opcao.
            
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      HIDE MESSAGE NO-PAUSE.
      
      IF   tel_tpdocmto = 4   THEN /* Transferencia intercooperativa */
           DO:
               UPDATE tel_cdagenci
                      tel_nrdcaixa
                      tel_cdopecxa
                      tel_nrdocmto
                      WITH FRAME f_opcao_2.
           END.

      IF   tel_tpdocmto = 0 THEN
            DO:
                UPDATE tel_cdagenci
                       tel_cdbccxlt
                       tel_nrdolote
                       tel_nrdocmto
                       tel_nrdconta WITH FRAME f_opcao_0.
            END.
    
        IF   tel_tpdocmto <> 0 AND
             tel_tpdocmto <> 4 THEN
             DO:
                 UPDATE tel_cdagenci
                        tel_cdbccxlt
                        tel_nrdolote
                        tel_nrdocmto WITH FRAME f_opcao_3.
             END.

      RUN sistema/generico/procedures/b1wgen0104.p 
          PERSISTENT SET h-b1wgen0104.
  
      RUN busca_dados IN h-b1wgen0104 (INPUT glb_cdcooper,
                                       INPUT tel_dtmvtolt,
                                       INPUT tel_nrdcaixa,
                                       INPUT glb_cdoperad,
                                       INPUT 1, /* Ayllos */
                                       INPUT glb_nmdatela,
                                       INPUT tel_cdagenci,
                                       INPUT tel_cdbccxlt,
                                       INPUT tel_cdopecxa,
                                       INPUT tel_nrdolote,
                                       INPUT tel_nrdocmto,
                                       INPUT tel_tpdocmto,
                                       INPUT "I",
                                       INPUT tel_nrdconta,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-crapcme). 
      DELETE PROCEDURE h-b1wgen0104.

      IF   RETURN-VALUE <> "OK"   THEN
           DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
           
                IF   AVAIL tt-erro   THEN
                     MESSAGE tt-erro.dscritic.
                ELSE
              MESSAGE "Erro na busca dos dados do controle de movimentacao.".
           
                PAUSE 3 NO-MESSAGE.
           
                NEXT.
           END.


      FIND FIRST tt-crapcme NO-ERROR.

      ASSIGN tel_nrctnome = TRIM(STRING(tt-crapcme.nrdconta, "zzzz,zz9,9")) + "-" + tt-crapcme.nmcooptl.
                 
      IF   NOT AVAIL tt-crapcme   THEN
           NEXT.

      DISPLAY tel_nrctnome
              tt-crapcme.vllanmto
              tt-crapcme.nrseqaut 
              WITH FRAME f_cmesaq.
            
      DO WHILE TRUE:
       
         UPDATE tt-crapcme.nrccdrcb WITH FRAME f_cmesaq.

         IF   tt-crapcme.nrccdrcb <> 0   THEN
              DO:
                  RUN sistema/generico/procedures/b1wgen0104.p 
                      PERSISTENT SET h-b1wgen0104.

                  RUN busca_dados_assoc IN h-b1wgen0104
                                        (INPUT glb_cdcooper,
                                         INPUT glb_dtmvtolt,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT 1, /* Ayllos */
                                         INPUT tel_cdagenci,
                                         INPUT tel_cdbccxlt,
                                         INPUT "I",
                                         INPUT tt-crapcme.nrdconta,
                                         INPUT tt-crapcme.nrccdrcb,
                                         INPUT tel_tpdocmto,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE bk-cmedep).

                  DELETE PROCEDURE h-b1wgen0104.  
                  
                  IF   RETURN-VALUE <> "OK"   THEN
                       DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                      
                           IF   AVAIL tt-erro   THEN
                                MESSAGE tt-erro.dscritic.
                           ELSE
                                MESSAGE "Erro na busca dos dados do associado.".
                      
                           PAUSE 3 NO-MESSAGE.
                      
                           NEXT.
                       END.
                     
                  FIND FIRST bk-cmedep NO-LOCK NO-ERROR.

                  IF   NOT AVAIL bk-cmedep    THEN
                       NEXT.
                    
                  ASSIGN tt-crapcme.nmpesrcb = bk-cmedep.nmpesrcb
                         tt-crapcme.cpfcgrcb = bk-cmedep.cpfcgrcb 
                         tt-crapcme.nridercb = bk-cmedep.nridercb
                         tt-crapcme.dtnasrcb = bk-cmedep.dtnasrcb
                         tt-crapcme.desenrcb = bk-cmedep.desenrcb
                         tt-crapcme.nmcidrcb = bk-cmedep.nmcidrcb
                         tt-crapcme.cdufdrcb = bk-cmedep.cdufdrcb
                         tt-crapcme.nrceprcb = bk-cmedep.nrceprcb.

                  DISPLAY tt-crapcme.nmpesrcb tt-crapcme.cpfcgrcb
                          tt-crapcme.nridercb tt-crapcme.dtnasrcb 
                          tt-crapcme.desenrcb tt-crapcme.nmcidrcb 
                          tt-crapcme.cdufdrcb tt-crapcme.nrceprcb
                          WITH FRAME f_cmesaq.   
               
              END.
         ELSE
              DO WHILE TRUE:
         
                  UPDATE tt-crapcme.nmpesrcb tt-crapcme.cpfcgrcb
                         tt-crapcme.nridercb tt-crapcme.dtnasrcb 
                         tt-crapcme.desenrcb tt-crapcme.nmcidrcb 
                         tt-crapcme.nrceprcb tt-crapcme.cdufdrcb
                         WITH FRAME f_cmesaq

                  EDITING:
                    
                    READKEY.

                    APPLY LASTKEY.

                    IF   GO-PENDING   THEN
                         DO:
                             DO WITH FRAME f_cmesaq:
                                ASSIGN tt-crapcme.cpfcgrcb
                                       tt-crapcme.nridercb
                                       tt-crapcme.dtnasrcb.
                             END.

                             RUN sistema/generico/procedures/b1wgen0104.p 
                                 PERSISTENT SET h-b1wgen0104.

                             RUN valida_dados_nao_assoc IN h-b1wgen0104
                                               (INPUT glb_cdcooper,
                                                INPUT glb_dtmvtolt,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT 1, /* Ayllos */
                                                INPUT tel_cdagenci,
                                                INPUT tel_cdbccxlt,
                                                INPUT "I",
                                                INPUT tt-crapcme.cpfcgrcb,
                                                INPUT tt-crapcme.nridercb,
                                                INPUT tt-crapcme.dtnasrcb,
                                               OUTPUT par_nmdcampo,
                                               OUTPUT TABLE tt-erro).
                             
                             DELETE PROCEDURE h-b1wgen0104.

                             IF   RETURN-VALUE <> "OK"   THEN
                                  DO:
                                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                 
                                      IF   AVAIL tt-erro   THEN
                                           MESSAGE tt-erro.dscritic.
                                      ELSE
                                 MESSAGE "Erro na validacao do Sacador.".
                                 
                                      PAUSE 3 NO-MESSAGE.
                                 
                                      { sistema/generico/includes/foco_campo.i
                                             &VAR-GERAL=SIM
                                             &NOME-FRAME="f_cmesaq"
                                             &NOME-CAMPO=par_nmdcampo }                                      
                                  END.
                         END.
                  END.
                  
                  LEAVE.
                           
              END.
         
         LEAVE.
          
      END.
         
      UPDATE tt-crapcme.flinfdst WITH FRAME f_cmesaq.

      IF   tt-crapcme.flinfdst   THEN /* Prencher Destino */
           DO:
               DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
                  UPDATE tt-crapcme.dstrecur WITH FRAME f_cmesaq.
                  LEAVE.
               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.
           END.
      ELSE      /* Nao prencher , limpar */
           DO:
               ASSIGN tt-crapcme.dstrecur = "".

               DISPLAY tt-crapcme.dstrecur WITH FRAME f_cmesaq.       
           END.      
                                  
      IF   tt-crapcme.vllanmto >= tt-crapcme.vlmincen   THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                   UPDATE tt-crapcme.dsdopera WITH FRAME f_cmesaq_2.
                   LEAVE.
               
               END.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        HIDE FRAME f_cmesaq_2. 
                        NEXT.
                    END.
                         
               /* Se valor retirado é parcial , entao digitar ele */
               IF   tt-crapcme.dsdopera = "P"   THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                           UPDATE tt-crapcme.vlretesp WITH FRAME f_cmesaq_2.
                           LEAVE.
               
                        END. 
               
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                             DO:
                                 HIDE FRAME f_cmesaq_2. 
                                 NEXT.
                             END.
                    END.
               ELSE /* Senao pegar valor total e mostrar */
                    DO:
                         ASSIGN tt-crapcme.vlretesp = tt-crapcme.vllanmto.
               
                         DISPLAY tt-crapcme.vlretesp WITH FRAME f_cmesaq_2.
                    END.
           END.
      ELSE
           DO:
               tt-crapcme.vlretesp = 0. 
               HIDE FRAME f_cmesaq_2.
           END.

      RUN fontes/confirma.p (INPUT "",
                            OUTPUT aux_confirma).

      IF   aux_confirma <> "S" THEN
           NEXT.
            
      RUN fontes/confirma.p (INPUT "Deseja imprimir o DOCUMENTO(S/N):",
                            OUTPUT aux_confirma).

      HIDE MESSAGE NO-PAUSE.

      RUN sistema/generico/procedures/b1wgen0104.p 
          PERSISTENT SET h-b1wgen0104.
        
      RUN inclui_altera_dados IN h-b1wgen0104
                                          (INPUT glb_cdcooper,
                                           INPUT tel_dtmvtolt,
                                           INPUT tel_nrdcaixa,
                                           INPUT glb_cdoperad,
                                           INPUT 1, /* Ayllos*/
                                           INPUT glb_nmdatela,
                                           INPUT tel_cdagenci,
                                           INPUT tel_cdopecxa,
                                           INPUT tel_cdbccxlt,
                                           INPUT tel_nrdolote,
                                           INPUT tel_nrdocmto,
                                           INPUT tel_tpdocmto,
                                           INPUT "I",
                                           INPUT (aux_confirma = "S"),
                                           INPUT tel_nrdconta,
                                           INPUT tt-crapcme.nrccdrcb,
                                           INPUT tt-crapcme.nmpesrcb,
                                           INPUT tt-crapcme.nridercb,
                                           INPUT tt-crapcme.dtnasrcb,
                                           INPUT tt-crapcme.desenrcb,
                                           INPUT tt-crapcme.nmcidrcb,
                                           INPUT tt-crapcme.nrceprcb,
                                           INPUT tt-crapcme.cdufdrcb,
                                           INPUT tt-crapcme.flinfdst,
                                           INPUT "",
                                           INPUT tt-crapcme.dstrecur, 
                                           INPUT tt-crapcme.cpfcgrcb,
                                           INPUT tt-crapcme.vlretesp,
                                          OUTPUT par_nmarqimp,
                                          OUTPUT par_nmarqpdf,
                                          OUTPUT TABLE tt-erro).
      DELETE PROCEDURE h-b1wgen0104.

      IF   RETURN-VALUE <> "OK"   THEN
           DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
               IF   AVAIL tt-erro   THEN
                    MESSAGE tt-erro.dscritic.
               ELSE
                    MESSAGE "Erro na alteracao dos dados do saque.".
          
               PAUSE 3 NO-MESSAGE.
          
               NEXT.
           END.

      /* Se tem arquivo para imprimir */
      IF   par_nmarqimp <> ""  THEN
           DO:
               ASSIGN aux_nmarqimp = par_nmarqimp
                      par_flgrodar = TRUE
                      glb_nmformul = "132col"
                      glb_nrdevias = 1. 

               /* So para compilar includes */ 
               FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                        NO-LOCK NO-ERROR.

               { includes/impressao.i }
          
           END.

      CLEAR FRAME f_cmesaq ALL NO-PAUSE.
   
      DISPLAY glb_cddopcao
              tel_dtmvtolt 
              tel_tpdocmto WITH FRAME f_opcao.
               
      PAUSE(0).
                        
   END.  /*  Fim do DO WHILE TRUE  */      
   
   LEAVE.

END.   /*  Fim do DO WHILE TRUE  */

CLEAR FRAME f_cmesaq ALL NO-PAUSE.
HIDE FRAME f_cmesaq NO-PAUSE.
 
/* .......................................................................... */

