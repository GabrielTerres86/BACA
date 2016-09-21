/* .............................................................................

   Programa: Fontes/deschq_e.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 04/12/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para excluir a proposta de limite de descontos de cheques.

   Alteracoes: 05/08/2003 - Tratamento para incluir a data da baixa no 
                            crapmcr (Julio).
               22/06/2004 - Acessar tabela avalistas Terceiros(Mirtes)

               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
     
               05/07/2007 - HIDE no campo lim_dtcancel na hora de excluir.
                            (Guilherme).

               17/09/2008 - Alterada chave de acesso a tabela crapldc
                            (Gabriel).
                            
               13/10/2009 - Alterado para browse dinamico (Gabriel).   
               
               27/04/2011 - Incluidos campos para CEP integrado: nrendere, 
                            complend e nrcxapst para avalistas. (André - DB1)
                            
               04/12/2012 - Ajuste para utilzar a BO9 (Adriano).             
                              
............................................................................. */

DEF INPUT PARAM par_nrctrlim AS INT                                  NO-UNDO.

DEF VAR   h-b1wgen0009  AS HANDLE                                    NO-UNDO.


{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i }
{ sistema/generico/includes/var_internet.i }
        
DO WHILE TRUE ON ERROR UNDO, LEAVE:


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
          lim_nrcxapst2    = 0.


   IF NOT VALID-HANDLE(h-b1wgen0009) THEN
      RUN sistema/generico/procedures/b1wgen0009.p 
          PERSISTENT SET h-b1wgen0009.

   
   RUN busca_dados_limite IN h-b1wgen0009(INPUT glb_cdcooper,
                                          INPUT glb_cdagenci,
                                          INPUT 0, /*nrdcaixa*/
                                          INPUT glb_cdoperad,
                                          INPUT glb_dtmvtolt,
                                          INPUT 1, /*idorigem*/
                                          INPUT tel_nrdconta,
                                          INPUT 1, /*idseqttl*/
                                          INPUT glb_nmdatela,
                                          INPUT par_nrctrlim,
                                          INPUT "E",
                                          INPUT TRUE,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-dscchq_dados_limite,
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
               
            END.
         ELSE
            DO:
               BELL.
               MESSAGE "Registro de limite nao encontrado.".

            END.
      

         HIDE FRAME f_prolim.

         RETURN.
      
      END.

    
   FIND FIRST tt-dscchq_dados_limite NO-LOCK NO-ERROR.

   ASSIGN tel_nrctrpro = tt-dscchq_dados_limite.nrctrlim
          tel_vllimpro = tt-dscchq_dados_limite.vllimite
          tel_qtdiavig = tt-dscchq_dados_limite.qtdiavig
          tel_cddlinha = tt-dscchq_dados_limite.cddlinha
          tel_dsdlinha = tt-dscchq_dados_limite.dsdlinha
          tel_txjurmor = tt-dscchq_dados_limite.txjurmor 
          tel_dsramati = tt-dscchq_dados_limite.dsramati
          tel_vlmedchq = tt-dscchq_dados_limite.vlmedchq
          tel_vlfatura = tt-dscchq_dados_limite.vlfatura
          lim_vloutras = tt-dscchq_dados_limite.vloutras
          lim_vlsalari = tt-dscchq_dados_limite.vlsalari
          lim_vlsalcon = tt-dscchq_dados_limite.vlsalcon
          tel_dsobserv = tt-dscchq_dados_limite.dsobserv
          tel_txdmulta = tt-dscchq_dados_limite.txdmulta.

   DISPLAY tel_nrctrpro  
           tel_vllimpro  
           tel_qtdiavig
           tel_cddlinha  
           tel_dsdlinha  
           tel_txjurmor 
           tel_txdmulta  
           tel_dsramati  
           tel_vlmedchq
           tel_vlfatura 
           WITH FRAME f_prolim.

   HIDE lim_dtcancel.
           
   /*  Confirmacao da exclusao  */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      ASSIGN glb_cdcritic = 0.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR 
      aux_confirma <> "S"                THEN
      DO:
          ASSIGN glb_cdcritic = 79.
          RUN fontes/critic.p.
          BELL.
          ASSIGN glb_cdcritic = 0.
          MESSAGE glb_dscritic.
          LEAVE.

      END.

   IF NOT VALID-HANDLE(h-b1wgen0009) THEN
      RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.

   RUN efetua_exclusao_limite IN h-b1wgen0009(INPUT glb_cdcooper,
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
                                              OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0009) THEN
      DELETE OBJECT h-b1wgen0009.

   IF RETURN-VALUE <> "OK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF AVAIL tt-erro THEN
             DO:
                BELL.
                MESSAGE tt-erro.dscritic.

             END.
          ELSE
             DO:
                BELL.
                MESSAGE "Nao foi possivel excluir o limite.".
                
             END.

          RETURN.

      END.


   LEAVE.


END.  /*  Fim do DO TRANSACTION  */

HIDE FRAME f_observacao.
HIDE FRAME f_promissoria1.
HIDE FRAME f_promissoria2.
HIDE FRAME f_rendas.
HIDE FRAME f_prolim.

/* .......................................................................... */
