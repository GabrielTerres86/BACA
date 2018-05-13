/* .............................................................................

   Programa: Fontes/cmedepc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Alteracao: 18/07/2012
   Data    : Agosto/2003

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela CMEDEP.

   Alteracoes: 25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
        
               20/05/2011 - Retirado o campo Registrar. Incluir campo
                            ''Informacoes prestadas pelo cooperado' (Gabriel)
                            
               16/09/2011 - Retirar campo tipo de pessoa , obrigar ser 
                            Fisica (Gabriel) 
                            
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
   
    DISPLAY glb_cddopcao 
            tel_cdagenci 
            tel_dtmvtolt
            tel_cdbccxlt
            tel_nrdolote WITH FRAME f_opcao.
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
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
                                       INPUT "C",
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
                    MESSAGE "Erro na busca dos dados.".

               NEXT.
           END.

      FIND FIRST tt-crapcme NO-LOCK NO-ERROR.

      ASSIGN tel_nrctnome = tt-crapcme.nmcooptl.
      
      DISPLAY tel_nrdocmto
              tt-crapcme.vllanmto  tt-crapcme.nrccdrcb 
              tt-crapcme.nmpesrcb  tt-crapcme.cpfcgrcb      
              tt-crapcme.nridercb  tt-crapcme.dtnasrcb  
              tt-crapcme.desenrcb  tt-crapcme.nmcidrcb 
              tt-crapcme.cdufdrcb  tt-crapcme.nrceprcb 
              tt-crapcme.recursos  tt-crapcme.nrseqaut  
              tel_nrctnome         tt-crapcme.flinfdst
              WITH FRAME f_cmedep.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* F4 OU FIM */
           LEAVE.
 
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.

END.           

HIDE FRAME f_cmedep.

/* .......................................................................... */

