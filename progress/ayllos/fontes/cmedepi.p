/* .............................................................................

   Programa: Fontes/cmedepi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2002.                  Ultima atualizacao: 18/07/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela cmedep.

   Alteracoes: 30/09/2003 - Nao registrar acima de R$ 100.000 quando pessoa
                            juridica (Margarete).

               23/03/2005 - Inclusao parametro 
                                     bo_imp_ctr_depositos(Mirtes)

               27/06/2005 - Alimentado campo cdcooper da tabela crapcme
                            (Diego).
                             
               19/10/2005 - Inclusao do cooperativa na bo_imp_depositos (Julio)
                             
               25/01/2006 - Unificacao dos bancos - SQLWorks - Fernando
               
               22/05/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               16/12/2008 - Tratar erros na chamada da BO
                            bo_controla_depositos(Guilherme).
                            
               20/05/2011 - Retirar campo 'Registrar'.
                            Enviar por e-mail o controle da movimentacao.
                            Incluir campo 'Inf. prestadas pelo cooperado'.
                            (Gabriel).            
                            
               22/06/2011 - Passar como parametro para a impressao o
                            operador logado e nao operador do lote (Gabriel) 
                                         
               25/07/2011 - Nao informar ao COAF quando conta administrativa
                            (Gabriel).                                
                            
               16/09/2011 - Retirar campo tipo de pessoa , obrigar 
                            fisica (Gabriel)                         
                            
               03/11/2011 - Converter para BO (Gabriel). 
               
               06/03/2012 - Alterações para trabalhar com novos parâmetros
							da BO104 (Lucas).
                            
               18/07/2012 - Adicionado parametro tel_nrdconta. (Jorge)
                                                                                                
............................................................................. */
                                 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0104tt.i }

{ includes/var_online.i }
{ includes/var_cmedep_1.i }
{ includes/var_cmedep.i }

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   CLEAR FRAME f_cmedep ALL.
   
   ASSIGN tel_nrdocmto = 0.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      HIDE MESSAGE NO-PAUSE.
      
      UPDATE tel_nrdocmto tel_nrdconta WITH FRAME f_cmedep.
                
      RUN sistema/generico/procedures/b1wgen0104.p PERSISTENT SET h-b1wgen0104.

      RUN busca_dados IN h-b1wgen0104 (INPUT glb_cdcooper,
                                       INPUT tel_dtmvtolt,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT 1, /* Ayllos */
                                       INPUT glb_nmdatela,
                                       INPUT tel_cdagenci,
                                       INPUT tel_cdbccxlt,
                                       INPUT "", /* cdopecxa - So CMESAQ */
                                       INPUT tel_nrdolote,
                                       INPUT tel_nrdocmto,
                                       INPUT 0, /* tpdocmto - So CMESAQ */
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
                    MESSAGE "Erro na consulta dos dados".
               
               PAUSE 3 NO-MESSAGE.
               NEXT.

           END.

      FIND FIRST tt-crapcme NO-LOCK NO-ERROR.

      ASSIGN tel_nrctnome = tt-crapcme.nmcooptl.

      DISPLAY tel_nrctnome
              tt-crapcme.vllanmto 
              tt-crapcme.nrseqaut 
              WITH FRAME f_cmedep.
             
      DO WHILE TRUE:
       
         UPDATE tt-crapcme.nrccdrcb WITH FRAME f_cmedep.

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
                                         INPUT 0,
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
                          WITH FRAME f_cmedep.                                          
              END.
         ELSE
              DO WHILE TRUE:
                       
                  UPDATE tt-crapcme.nmpesrcb tt-crapcme.cpfcgrcb
                         tt-crapcme.nridercb tt-crapcme.dtnasrcb 
                         tt-crapcme.desenrcb tt-crapcme.nmcidrcb 
                         tt-crapcme.nrceprcb tt-crapcme.cdufdrcb
                         WITH FRAME f_cmedep

                  EDITING:
                    
                    READKEY.

                    APPLY LASTKEY.

                    IF   GO-PENDING   THEN
                         DO:
                             DO WITH FRAME f_cmedep:
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
                                  MESSAGE "Erro na validacao do Depositante.".
                                 
                                      PAUSE 3 NO-MESSAGE.
                                 
                                      { sistema/generico/includes/foco_campo.i
                                             &VAR-GERAL=SIM
                                             &NOME-FRAME="f_cmedep"
                                             &NOME-CAMPO=par_nmdcampo }
                                  END.

                         END.
                  END.

                  LEAVE.
                           
              END.
         
         LEAVE.
          
      END.
         
      UPDATE tt-crapcme.flinfdst WITH FRAME f_cmedep.

      IF   tt-crapcme.flinfdst   THEN /* Informar origem dos recursos */
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   UPDATE tt-crapcme.recursos WITH FRAME f_cmedep.
                   LEAVE.
               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.
           END.
      ELSE      /* Limpar origem dos recursos */
           DO:
               ASSIGN tt-crapcme.recursos = "".

               DISPLAY tt-crapcme.recursos WITH FRAME f_cmedep.
           END.
          
      RUN fontes/confirma.p (INPUT "",
                            OUTPUT aux_confirma).

      IF   aux_confirma <> "S"   THEN
           NEXT.
            
      RUN fontes/confirma.p (INPUT "Deseja imprimir o DOCUMENTO(S/N):",
                            OUTPUT aux_confirma).
      HIDE MESSAGE NO-PAUSE.

      RUN sistema/generico/procedures/b1wgen0104.p PERSISTENT SET h-b1wgen0104.
     
      RUN inclui_altera_dados IN h-b1wgen0104
                                          (INPUT glb_cdcooper,
                                           INPUT tel_dtmvtolt,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT 1, /* Ayllos*/
                                           INPUT glb_nmdatela,
                                           INPUT tel_cdagenci,
                                           INPUT "", /* cdopecxa , So CMESAQ */
                                           INPUT tel_cdbccxlt,
                                           INPUT tel_nrdolote,
                                           INPUT tel_nrdocmto,
                                           INPUT 0, /* tpdocmto , So CMESAQ */
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
                                           INPUT tt-crapcme.recursos,
                                           INPUT "",
                                           INPUT tt-crapcme.cpfcgrcb,
                                           INPUT 0, /* vlretesp - So CMESAQ */
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
                    MESSAGE "Erro na alteracao dos dados do deposito.".
          
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

      CLEAR FRAME f_cmedep ALL NO-PAUSE.
   
      DISPLAY glb_cddopcao
              tel_cdagenci 
              tel_dtmvtolt 
              tel_cdbccxlt
              tel_nrdolote WITH FRAME f_opcao.
              
      PAUSE(0).
                  
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
           glb_nmtelant = "LANDPV"              OR
           glb_nmtelant = "LOTE"                THEN /*   F4 OU FIM   */
           LEAVE.
      
   END.  /*  Fim do DO WHILE TRUE  */      
   
   LEAVE.

END.   /*  Fim do DO WHILE TRUE  */

CLEAR FRAME f_cmedep ALL NO-PAUSE.

HIDE FRAME f_cmedep NO-PAUSE.

/* .......................................................................... */

