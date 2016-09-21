/* .............................................................................

   Programa: Fontes/cmesaqc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Alteracao: 22/02/2012
   Data    : Agosto/2003

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela CMESAQ.

   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando
                
               04/05/2010 - Ajustado programa para as movimentações em
                            espécie criadas na rotina 20 (a partir da
                            craptvl). (Fernando) 
                            
               20/05/2011 - Retirar campo 'Registrar'.
                            Incluir campo 'Inf. prestadas pelo cooperado' 
                            (Gabriel)             
                            
               16/09/2011 - Retirar campo Pessoa , obrigar pessoa fisica.
                            Incluir campo 'Valor sendo levado'. (Gabriel).
                            
               16/11/2011 - Converter para BO (Gabriel).            
                          - Tratamento para a transferencia intercooperativa
                            (Gabriel)   
                            
               22/02/2012 - Informar conta (quando tipo 0) e, dessa forma,
                            não permitir encontrar registros duplicados. (Lucas)
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0104tt.i }

{ includes/var_online.i }
{ includes/var_cmesaq_1.i }
{ includes/var_cmesaq.i }

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   CLEAR FRAME f_cmesaq ALL.
   
   DISPLAY glb_cddopcao 
           tel_dtmvtolt
           tel_tpdocmto WITH FRAME f_opcao.
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      IF   tel_tpdocmto = 4   THEN
           DO:
               UPDATE tel_cdagenci
                      tel_nrdcaixa
                      tel_cdopecxa  
                      tel_nrdocmto WITH FRAME f_opcao_2.
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

      RUN sistema/generico/procedures/b1wgen0104.p PERSISTENT SET h-b1wgen0104.

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

      ASSIGN tel_nrctnome = TRIM(STRING(tt-crapcme.nrdconta, "zzzz,zz9,9")) + "-" + tt-crapcme.nmcooptl.
                 
      DISPLAY tt-crapcme.vllanmto  tt-crapcme.nrccdrcb 
              tt-crapcme.nmpesrcb  tt-crapcme.cpfcgrcb      
              tt-crapcme.nridercb  tt-crapcme.dtnasrcb  
              tt-crapcme.desenrcb  tt-crapcme.nmcidrcb 
              tt-crapcme.cdufdrcb  tt-crapcme.nrceprcb 
              tt-crapcme.dstrecur  tt-crapcme.nrseqaut  
              tel_nrctnome         tt-crapcme.flinfdst    
              WITH FRAME f_cmesaq.    

           /* Se valor acima de 100.000,00 */
      IF   tt-crapcme.vllanmto >= tt-crapcme.vlmincen   THEN
           DISPLAY tt-crapcme.vlretesp WITH FRAME f_cmesaq_2.
      ELSE
           HIDE FRAME f_cmesaq_2.
                       
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* F4 OU FIM */
           LEAVE.
 
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.

END.           

HIDE FRAME f_cmesaq.

/* .......................................................................... */
