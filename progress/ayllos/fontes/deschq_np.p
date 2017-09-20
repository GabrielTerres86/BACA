/*............................................................................ 
   
   Programa: fontes/deschq_np.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao: 24/04/2017
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratamento dos dados para emissao de NOTA PROMISSORIA
               para inclusao de um novo LIMITE DE DESCONTO DE CHEQUES.

   Alteracoes: 05/09/2003 - Tratamento para revisao cadastral de Fiadores
                            (Julio).
                            
               22/06/2004 - Atualizar tabela de Avalistas Terceiros(Mirtes).
               
               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               23/05/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
               
               06/09/2006 - Exluidas opcoes "TAB" (Diego).
               
               28/03/2007 - Ajustado enderecos do 2o. avalista para nao pegar
                            informacoes do 1o. avalista (Elton).
               
               01/10/2007 - Conversao de rotina ver_cadastro para BO
                            (Sidnei/Precise)
               
               10/12/2007 - Retirado comentario da rotina antiga 
                            ver_cadastro (Sidnei/Precise)
                            
               29/01/2009 - Nao criticar idade para pessoa juridica (Evandro).
               
               05/08/2009 - Trocado campo cdgraupr da crapass para a crapttl.
                            Paulo - Precise.
                            
               10/12/2009 - Alterar inhabmen da ass para ttl (Guilherme).
               
               12/01/2010 - Validar os avalistas com a BO 9999 (Gabriel).
               
               25/04/2011 - Separação de avalistas. Inclusão de CEP integrado.
                            (André - DB1)
                            
               03/05/2011 - Bloqueio de campos ao sair de campo conta do
                            avalista. Alteração na chamada da busca do avalista.
                            (André - DB1) 
                            
               13/07/2011 - Realizar a validacao dos avalisas atraves da 
                            B1wgen0024 (Gabriel)              
               
               21/12/2011 - Corrigido warnings (Tiago).
                                                                               
               11/04/2013 - Alimentado os campos lim_cpfcgc1, lim_cpfcgc2 no
                            tratamento dos campos lim_nrctaav1, lim_nrctaav2
                            com o cpf do avalista (Adriano).
                            
               19/12/2013 - Alterado atribuicao das variaveis lim_dscpfav2 e
                            lim_dscpfav1 de "C.G.C." para "CNPJ". (Reinert) 
                            
               07/08/2014 - Exclusao do campo crapass.nmconjug. 
                            (Chamado 117414) - (Tiago Castro - RKAM)           
                            
               14/10/2014 - Validacao avalsitas. Projeto consultas 
                            automatizadas (Jonata-RKAM).                             
                                                                               
			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).                         
                                                                               
............................................................................. */
{ sistema/generico/includes/b1wgen0038tt.i }         
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i }

DEF VAR aux_inhabmen LIKE crapttl.inhabmen                            NO-UNDO.
DEF VAR aux_nrdeanos AS INT                                           NO-UNDO.
DEF VAR aux_nrdmeses AS INT                                           NO-UNDO.
DEF VAR aux_dsdidade AS CHAR                                          NO-UNDO.
DEF VAR aux_cpfcgc   LIKE crapavt.nrcpfcgc                            NO-UNDO.
DEF VAR par_nmdcampo AS CHAR                                          NO-UNDO.

DEF NEW SHARED VAR shr_inpessoa AS INT                                NO-UNDO.
                                                                      
DEF BUFFER crabass FOR crapass.                                       
                                                                      
DEF VAR h-b1wgen0001 AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                        NO-UNDO.

/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF lim_nrcepend1 IN FRAME f_promissoria1 DO:
    IF  INPUT lim_nrcepend1 = 0  THEN
        RUN Limpa_Endereco(1).
END.

ON GO, LEAVE OF lim_nrcepend2 IN FRAME f_promissoria2 DO:
    IF  INPUT lim_nrcepend2 = 0  THEN
        RUN Limpa_Endereco(2).
END.

ON RETURN OF lim_nrcepend1 IN FRAME f_promissoria1 DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT lim_nrcepend1.

    IF  lim_nrcepend1 <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT lim_nrcepend1,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN 
                       lim_nrcepend1   = tt-endereco.nrcepend 
                       lim_dsendav1[1] = tt-endereco.dsendere
                       lim_dsendav1[2] = tt-endereco.nmbairro 
                       lim_nmcidade1   = tt-endereco.nmcidade 
                       lim_cdufresd1   = tt-endereco.cdufende.
                END.
            ELSE 
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        RETURN NO-APPLY.
                        
                    MESSAGE "CEP nao cadastrado.".
                    RUN Limpa_Endereco(1).
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        RUN Limpa_Endereco(1).

    DISPLAY lim_nrcepend1     
            lim_dsendav1[1]
            lim_dsendav1[2]
            lim_nmcidade1  
            lim_cdufresd1   WITH FRAME f_promissoria1.

    NEXT-PROMPT lim_nrendere1 WITH FRAME f_promissoria1.

END.

ON RETURN OF lim_nrcepend2 IN FRAME f_promissoria2 DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT lim_nrcepend2.

    IF  lim_nrcepend2 <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT lim_nrcepend2,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN 
                       lim_nrcepend2   = tt-endereco.nrcepend 
                       lim_dsendav2[1] = tt-endereco.dsendere
                       lim_dsendav2[2] = tt-endereco.nmbairro 
                       lim_nmcidade2   = tt-endereco.nmcidade 
                       lim_cdufresd2   = tt-endereco.cdufende.
                END.
            ELSE 
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        RETURN NO-APPLY.
                        
                    MESSAGE "CEP nao cadastrado.".
                    RUN Limpa_Endereco(2).
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        RUN Limpa_Endereco(2).

    DISPLAY lim_nrcepend2     
            lim_dsendav2[1]
            lim_dsendav2[2]
            lim_nmcidade2  
            lim_cdufresd2   WITH FRAME f_promissoria2.

    NEXT-PROMPT lim_nrendere2 WITH FRAME f_promissoria2.

END.

ON GO, RETURN OF lim_nrctaav1 DO:

    IF  INPUT lim_nrctaav1 <> 0  THEN
        DO:

            ASSIGN glb_nrcalcul = INPUT lim_nrctaav1
                   glb_cdcritic = 0.

            RUN fontes/digfun.p.
            IF  NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    RETURN NO-APPLY.
                END.
                       
            IF  INPUT lim_nrctaav1 = tel_nrdconta   THEN
                DO:
                    glb_cdcritic = 127.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic
                            "Deve ser diferente do CONTRATANTE.".
                    PAUSE.
                    HIDE MESSAGE.
                    glb_cdcritic = 0.
                    APPLY "RECALL".
                    RETURN NO-APPLY.
                END.

            RUN sistema/generico/procedures/b1wgen0001.p
                PERSISTENT SET h-b1wgen0001.
        
            IF  VALID-HANDLE(h-b1wgen0001)   THEN
                DO:
                    RUN ver_cadastro IN h-b1wgen0001
                                  (INPUT  glb_cdcooper,
                                   INPUT  INPUT lim_nrctaav1,
                                   INPUT  0, /* cod-agencia */
                                   INPUT  0, /* nro-caixa   */
                                   INPUT  glb_dtmvtolt,
                                   INPUT  1, /* AYLLOS */
                                   OUTPUT TABLE tt-erro).
        
                    /* Verifica se houve erro */
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN glb_cdcritic = tt-erro.cdcritic
                               glb_dscritic = tt-erro.dscritic.
                END.
        
            DELETE PROCEDURE h-b1wgen0001.
        
            IF  glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    PAUSE.
                    HIDE MESSAGE.
                    glb_cdcritic = 0.
                    APPLY "RECALL".
                    RETURN NO-APPLY.
                END.
           
            HIDE MESSAGE NO-PAUSE.

        
            FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                               crabass.nrdconta = INPUT lim_nrctaav1
                               NO-LOCK NO-ERROR.
        
            IF  NOT AVAILABLE crabass   THEN
                ASSIGN lim_nmdaval1 = "** Nao cadastrado **"
                       lim_dsendav1 = ""
                       lim_dscpfav1 = ""
                       lim_nmdcjav1 = ""
                       lim_dscfcav1 = ""
                       lim_nmcidade1 = ""   
                       lim_cdufresd1 = "" 
                       lim_nrcepend1 = 0    
                       lim_nrendere1 = 0
                       lim_complend1 = ""   
                       lim_nrcxapst1 = 0.
        
            ELSE
                DO:
                    ASSIGN aux_inhabmen = 0.

                    IF  crabass.inpessoa = 1  THEN
                        DO:
                            FOR FIRST crapttl FIELDS(cdgraupr inhabmen nrcpfcgc)
							                  WHERE crapttl.cdcooper = glb_cdcooper     AND 
                                       crapttl.nrdconta = crabass.nrdconta AND 
												    crapttl.idseqttl = 2 
													NO-LOCK:

							  ASSIGN aux_inhabmen = crapttl.inhabmen
									 lim_dscfcav1 = IF crapttl.cdgraupr = 1 THEN
													   STRING(crapttl.nrcpfcgc, "99999999999")
													ELSE ""
									 lim_dscfcav1 = STRING(lim_dscfcav1,"xxx.xxx.xxx-xx")        
									 lim_dscfcav1 = IF lim_dscfcav1 <> " " THEN 
													  "C.P.F. " + lim_dscfcav1
												    ELSE "".

							END.
   
                        END.
        
                    IF  crabass.inpessoa = 3 THEN
                        DO:
                            glb_cdcritic = 808.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            RETURN NO-APPLY.
                        END.
                    ELSE
                    IF  crabass.inpessoa = 1   THEN
                        DO:
                            RUN fontes/idade.p
                                   ( INPUT  crabass.dtnasctl,
                                     INPUT  glb_dtmvtolt,
                                    OUTPUT aux_nrdeanos,
                                    OUTPUT aux_nrdmeses,
                                    OUTPUT aux_dsdidade ).
        
                            IF  aux_nrdeanos < 18    AND 
                                aux_inhabmen = 0 THEN
                                DO:
                                    glb_cdcritic = 585.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    RETURN NO-APPLY.
                                END.
                        END.
                         
                    FIND crapenc WHERE crapenc.cdcooper = glb_cdcooper      AND
                                       crapenc.nrdconta = crabass.nrdconta  AND
                                       crapenc.idseqttl = 1                 AND
                                       crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
                    
                    ASSIGN lim_nmdaval1 = crabass.nmprimtl
                           lim_dsendav1[1] = crapenc.dsendere
                           lim_dsendav1[2] = TRIM(crapenc.nmbairro)
                           lim_nmcidade1   = TRIM(crapenc.nmcidade)
                           lim_cdufresd1   = crapenc.cdufende
                           lim_nrcepend1   = crapenc.nrcepend
                           lim_nrendere1   = crapenc.nrendere
                           lim_nrcxapst1   = crapenc.nrcxapst
                           lim_complend1   = crapenc.complend.
        
                    IF  crabass.inpessoa = 1 THEN
                        ASSIGN lim_cpfcgc1  = crabass.nrcpfcgc
                               lim_dscpfav1 = STRING(crabass.nrcpfcgc, 
                                                     "99999999999")
                               lim_dscpfav1 = STRING(lim_dscpfav1,
                                                     "xxx.xxx.xxx-xx")
        
                               lim_dscpfav1 = "C.P.F. " + lim_dscpfav1.
                    ELSE
                        ASSIGN lim_cpfcgc1  = crabass.nrcpfcgc
                               lim_dscpfav1 = STRING(crabass.nrcpfcgc,
                                                     "99999999999999")
                               lim_dscpfav1 = STRING(lim_dscpfav1,
                                                     "xx.xxx.xxx/xxxx-xx")
                               lim_dscpfav1 = "CNPJ " + lim_dscpfav1.
                END.
        
            lim_dscpfav1 = lim_dscpfav1 + FILL(" ",30 - LENGTH(lim_dscpfav1)) +
                           STRING(INPUT lim_nrctaav1,"zzzz,zzz,9").
        
            DISPLAY lim_cpfcgc1 
                    lim_nmdaval1     lim_dscpfav1
                    lim_dsendav1[1]  lim_dsendav1[2]
                    lim_nmdcjav1     lim_dscfcav1
                    lim_nmcidade1    lim_cdufresd1   
                    lim_nrcepend1    lim_nrendere1
                    lim_nrcxapst1    lim_complend1 WITH FRAME f_promissoria1.
        END.
   
END. /* Fim ON GO, RETURN OF lim_nrctaav1 */ 

ON GO, RETURN OF lim_nrctaav2 DO:

    IF  INPUT lim_nrctaav2 <> 0  THEN
        DO:
            ASSIGN glb_nrcalcul = INPUT lim_nrctaav2
                   glb_cdcritic = 0.
    
            RUN fontes/digfun.p.
            IF  NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    RETURN NO-APPLY.
                END.
                           
            IF  INPUT lim_nrctaav2 = tel_nrdconta   THEN
                DO:
                    glb_cdcritic = 127.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic
                          "Deve ser diferente do CONTRATANTE.".
                    PAUSE.
                    HIDE MESSAGE.
                    glb_cdcritic = 0.
                    APPLY "RECALL".
                    RETURN NO-APPLY.
                END.
                   
            RUN sistema/generico/procedures/b1wgen0001.p 
                PERSISTENT SET h-b1wgen0001.
                              
            IF  VALID-HANDLE(h-b1wgen0001)   THEN
                DO:
                    RUN ver_cadastro IN h-b1wgen0001
                                  (INPUT  glb_cdcooper,
                                   INPUT  INPUT lim_nrctaav2,
                                   INPUT  0, /* cod-agencia */
                                   INPUT  0, /* nro-caixa   */
                                   INPUT  glb_dtmvtolt,
                                   INPUT  1, /* AYLLOS */
                                   OUTPUT TABLE tt-erro).
        
                    /* Verifica se houve erro */
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN glb_cdcritic = tt-erro.cdcritic
                               glb_dscritic = tt-erro.dscritic.
                END.
                           
            DELETE PROCEDURE h-b1wgen0001.
                                         
            IF  glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    PAUSE.
                    HIDE MESSAGE.
                    glb_cdcritic = 0.
                    APPLY "RECALL".
                    RETURN NO-APPLY.
                END.
        
            HIDE MESSAGE NO-PAUSE.

            FIND crabass 
                 WHERE crabass.cdcooper = glb_cdcooper AND
                       crabass.nrdconta = INPUT lim_nrctaav2
                       NO-LOCK NO-ERROR.
        
            IF  NOT AVAILABLE crabass   THEN
                ASSIGN lim_nmdaval2 = "** Nao cadastrado **"
                       lim_dsendav2 = ""
                       lim_dscpfav2 = ""
                       lim_nmdcjav2 = ""
                       lim_dscfcav2 = ""
                       lim_nmcidade2 = ""   
                       lim_cdufresd2 = "" 
                       lim_nrcepend2 = 0    
                       lim_nrendere2 = 0
                       lim_complend2 = ""   
                       lim_nrcxapst2 = 0.
        
            ELSE
                DO:
                    ASSIGN aux_inhabmen = 0.

                    IF  crabass.inpessoa = 1  THEN
                        DO:
                            FOR FIRST crapttl FIELDS(cdgraupr inhabmen nrcpfcgc)
											  WHERE crapttl.cdcooper = glb_cdcooper AND 
                                      crapttl.nrdconta = crabass.nrdconta AND 
													crapttl.idseqttl = 2 
													NO-LOCK:

							  ASSIGN aux_inhabmen = crapttl.inhabmen
									 lim_dscfcav2 = IF crapttl.cdgraupr = 1 THEN
													  STRING(crapttl.nrcpfcgc,"99999999999")
												    ELSE ""        
									 lim_dscfcav2 = STRING(lim_dscfcav2,"xxx.xxx.xxx-xx")
									 lim_dscfcav2 = IF lim_dscfcav2 <> " " THEN 
													  "C.P.F. " + lim_dscfcav2
												    ELSE " ".

							END.

                        END.
        
                    IF  crabass.inpessoa = 3 THEN
                        DO:
                           glb_cdcritic = 808.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                           RETURN NO-APPLY.
                        END.
                    ELSE
                    IF  crabass.inpessoa = 1   THEN
                        DO:
                            RUN fontes/idade.p
                                   ( INPUT  crabass.dtnasctl,
                                     INPUT  glb_dtmvtolt,
                                    OUTPUT aux_nrdeanos,
                                    OUTPUT aux_nrdmeses,
                                    OUTPUT aux_dsdidade ).
        
                            IF  aux_nrdeanos < 18    AND aux_inhabmen = 0 THEN
                                DO:
                                   glb_cdcritic = 585.
                                   RUN fontes/critic.p.
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   glb_cdcritic = 0.
                                   RETURN NO-APPLY.
                                END.
                        END.
                    
                    FIND crapenc WHERE crapenc.cdcooper = glb_cdcooper     AND
                                       crapenc.nrdconta = crabass.nrdconta AND
                                       crapenc.idseqttl = 1                AND
                                       crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
                    
                    
                    ASSIGN lim_nmdaval2    = crabass.nmprimtl
                           lim_dsendav2[1] = crapenc.dsendere
                           lim_dsendav2[2] = TRIM(crapenc.nmbairro)
                           lim_nmcidade2   = TRIM(crapenc.nmcidade)
                           lim_cdufresd2   = crapenc.cdufende
                           lim_nrcepend2   = crapenc.nrcepend
                           lim_nrendere2   = crapenc.nrendere
                           lim_nrcxapst2   = crapenc.nrcxapst
                           lim_complend2   = crapenc.complend.
        
                    IF   crabass.inpessoa = 1 THEN
                         ASSIGN lim_cpfcgc2  = crabass.nrcpfcgc
                                lim_dscpfav2 =  
                                          STRING(crabass.nrcpfcgc,"99999999999")
                                lim_dscpfav2 = 
                                          STRING(lim_dscpfav2,"xxx.xxx.xxx-xx")
        
                                lim_dscpfav2 = "C.P.F. " + lim_dscpfav2.
                    ELSE
                         ASSIGN lim_cpfcgc2  = crabass.nrcpfcgc
                                lim_dscpfav2 = 
                                          STRING(crabass.nrcpfcgc,
                                                 "99999999999999")
                                lim_dscpfav2 = 
                                          STRING(lim_dscpfav2,
                                                 "xx.xxx.xxx/xxxx-xx")
        
                                lim_dscpfav2 = "CNPJ " + lim_dscpfav2.
                END.
        
            lim_dscpfav2 = lim_dscpfav2 + FILL(" ",30 - LENGTH(lim_dscpfav2)) +
                           STRING(INPUT lim_nrctaav2,"zzzz,zzz,9").
        
            DISPLAY lim_cpfcgc2
                    lim_nmdaval2     lim_dscpfav2
                    lim_dsendav2[1]  lim_dsendav2[2]
                    lim_nmdcjav2     lim_dscfcav2
                    lim_nmcidade2    lim_cdufresd2
                    lim_nrcepend2    lim_nrendere2
                    lim_nrcxapst2    lim_complend2
                    WITH FRAME f_promissoria2.
        END.
   
END. /* Fim ON GO, RETURN OF lim_nrctaav2 */


IF  glb_cddopcao = "I"   THEN
    ASSIGN lim_nrctaav1  = 0    lim_cpfcgc1   = 0
           lim_nmdaval1  = ""   lim_dscpfav1  = ""
           lim_nmdcjav1  = ""   lim_cpfccg1   = 0 
           lim_tpdocav1  = ""   lim_tpdoccj1  = ""   
           lim_dscfcav1  = ""   lim_dsendav1  = ""
           lim_nmcidade1 = ""   lim_cdufresd1 = "" 
           lim_nrcepend1 = 0    lim_nrendere1 = 0
           lim_complend1 = ""   lim_nrcxapst1 = 0
           lim_nrctaav2  = 0    lim_nrfonres1 = ""   
           lim_cpfcgc2   = 0    lim_dsdemail1 = ""
           lim_tpdocav2  = ""   lim_tpdoccj2  = ""
           lim_dscpfav2  = ""   lim_nmdcjav2  = ""   
           lim_cpfccg2   = 0    lim_dscfcav2  = ""
           lim_dsendav2  = ""   lim_nmcidade2 = ""
           lim_cdufresd2 = ""   lim_nrcepend2 = 0
           lim_nrendere2 = 0    lim_complend2 = ""
           lim_nmdaval2  = ""   lim_nrfonres2 = "" 
           lim_nrcxapst2 = 0    lim_dsdemail2 = "". 

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

    DISPLAY lim_nrctaav1    lim_dsendav1    lim_nmcidade1   lim_cdufresd1
            lim_nrctaav1    lim_nmdaval1    lim_cpfcgc1     lim_tpdocav1
            lim_dscpfav1    lim_nmdcjav1    lim_cpfccg1     lim_tpdoccj1
            lim_dscfcav1    lim_nrcepend1   lim_nrendere1   lim_complend1   
            lim_nrcxapst1   lim_nrfonres1   lim_dsdemail1
            WITH FRAME f_promissoria1.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE lim_nrctaav1 WITH FRAME f_promissoria1.

        IF   lim_nrctaav1 <> 0   THEN
             DO:
                 RUN valida_aval (INPUT 0, /* Este dado vai soh no 2. Tit*/
                                  INPUT 0, /* Este dado vai soh no 2. Tit*/
                                  INPUT 1, /* 1. Avalista */
                                  INPUT lim_nrctaav1, /* Conta*/
                                  INPUT lim_nmdaval1, /* Nome */
                                  INPUT lim_cpfcgc1,  /* CPF */
                                  INPUT lim_cpfccg1,  /* CPF conjuge */
                                  INPUT lim_dsendav1[1], /* Endereco */
                                  INPUT lim_cdufresd1, /* UF */
                                  INPUT lim_nrcepend1). /* CEP */
                                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.

        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_promissoria1.
            RETURN "NOK".
        END.

    IF  lim_nrctaav1 = 0  THEN /* Conta nao prenchida */
        DO:
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE lim_nmdaval1    lim_cpfcgc1     
                       lim_tpdocav1    lim_dscpfav1    lim_nmdcjav1    
                       lim_cpfccg1     lim_tpdoccj1    lim_dscfcav1    
                       lim_nrcepend1   lim_nrendere1   lim_complend1   
                       lim_nrcxapst1   lim_nrfonres1   lim_dsdemail1
                       WITH FRAME f_promissoria1

                EDITING:
                
                    READKEY.
        
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        DO:
                            IF   glb_cddopcao = "I"   THEN
                                 APPLY "CLEAR".
                            ELSE
                                 APPLY "RECALL".
                                 
                            LEAVE.
                        END.
        
                    IF  FRAME-FIELD = "lim_nrcepend1" THEN 
                        DO:
                            IF  LASTKEY = KEYCODE("F7") THEN
                                DO:
                                /* Inclusão de CEP integrado. (André - DB1) */
                                    RUN fontes/zoom_endereco.p 
                                             ( INPUT 0,
                                              OUTPUT TABLE tt-endereco ).
                                       
                                    FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                    
                                    IF  AVAIL tt-endereco THEN
                                        DO:
                                            ASSIGN lim_nrcepend1   = 
                                                        tt-endereco.nrcepend
                                                   lim_dsendav1[1] = 
                                                        tt-endereco.dsendere
                                                   lim_dsendav1[2] = 
                                                        tt-endereco.nmbairro
                                                   lim_nmcidade1   = 
                                                        tt-endereco.nmcidade
                                                   lim_cdufresd1   = 
                                                        tt-endereco.cdufende.
                                                                     
                                            DISPLAY lim_nrcepend1      
                                                    lim_dsendav1[1]
                                                    lim_dsendav1[2]
                                                    lim_nmcidade1  
                                                    lim_cdufresd1  
                                                    WITH FRAME f_promissoria1.
                    
                                            IF  KEYFUNCTION(LASTKEY) 
                                                <> "END-ERROR" THEN 
                                                NEXT-PROMPT lim_nrendere1 
                                                     WITH FRAME f_promissoria1.
                                        END.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                    /*---- Verificar CPFCGC TERCEIROS ja Cadastrados ---*/
                    IF  FRAME-FIELD = "lim_cpfcgc1"   THEN
                        DO:
                            IF (LASTKEY = KEYCODE("RETURN")       OR
                                LASTKEY = KEYCODE("F1")           OR
                                LASTKEY = KEYCODE("BACK-TAB")     OR
                                LASTKEY = KEYCODE("CURSOR-DOWN")  OR
                                LASTKEY = KEYCODE("CURSOR-LEFT")  OR
                                LASTKEY = KEYCODE("CURSOR-RIGHT") OR             
                                LASTKEY = KEYCODE("CURSOR-UP"))  AND
                                INPUT lim_cpfcgc1 > 0            AND
                                INPUT lim_nrctaav1 = 0           AND
                                glb_cddopcao = "I"  THEN  /* Somente inclusao*/
                                DO:
                                    ASSIGN aux_cpfcgc = INPUT lim_cpfcgc1.
                                    RUN lista_dados_aval1.
                                    APPLY LASTKEY.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                        APPLY LASTKEY.
            
                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN lim_nrctaav1   
                                   lim_nmdaval1   
                                   lim_cpfcgc1    
                                   lim_cpfccg1   
                                   lim_dsendav1[1]
                                   lim_nrcepend1.
            
                            RUN valida_aval 
                                 (INPUT 0, /* Este dado vai soh no 2. Tit*/
                                  INPUT 0, /* Este dado vai soh no 2. Tit*/
                                  INPUT 1, /* 1. Avalista */
                                  INPUT lim_nrctaav1, /* Conta*/
                                  INPUT lim_nmdaval1, /* Nome */
                                  INPUT lim_cpfcgc1,  /* CPF */
                                  INPUT lim_cpfccg1,  /* CPF conjuge */
                                  INPUT lim_dsendav1[1], /* Endereco */
                                  INPUT lim_cdufresd1, /* UF */
                                  INPUT lim_nrcepend1). /* CEP */
            
                            IF  RETURN-VALUE = "NOK" THEN
                                DO:          
                                    {sistema/generico/includes/foco_campo.i 
                                         &VAR-GERAL=SIM
                                         &NOME-FRAME="f_promissoria1"
                                         &NOME-CAMPO=par_nmdcampo }
                                END.
                        END. 
                END.  /*  Fim do EDITING  */
                LEAVE.
            END.
        END.
    ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE MESSAGE
                     "Pressione algo para continuar - <F4>/<END> para voltar.".
                LEAVE.
            END.
        END.

    HIDE FRAME f_promissoria1 NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR lim_nmdaval1 = "" THEN
        LEAVE.

    DISPLAY lim_nrctaav2   lim_dsendav2    lim_nmcidade2   lim_cdufresd2 
            lim_nmdaval2   lim_cpfcgc2     lim_tpdocav2
            lim_dscpfav2   lim_nmdcjav2    lim_cpfccg2     lim_tpdoccj2
            lim_dscfcav2   lim_nrcepend2   lim_nrendere2   lim_complend2  
            lim_nrcxapst2  lim_nrfonres2   lim_dsdemail2 
            WITH FRAME f_promissoria2.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE lim_nrctaav2 WITH FRAME f_promissoria2.

        IF   lim_nrctaav2 <> 0 THEN
             DO:
                 RUN valida_aval 
                             (INPUT lim_nrctaav1, /* Conta 1. Tit*/
                              INPUT lim_cpfcgc1,  /* CPF 1. Tit*/
                              INPUT 2, /* 2. Avalista */
                              INPUT lim_nrctaav2, /* Conta*/
                              INPUT lim_nmdaval2, /* Nome */
                              INPUT lim_cpfcgc2,  /* CPF */
                              INPUT lim_cpfccg2,  /* CPF conjuge */
                              INPUT lim_dsendav2[1], /* Endereco */
                              INPUT lim_cdufresd2, /* UF */
                              INPUT lim_nrcepend2). /* CEP */
            
                 IF  RETURN-VALUE = "NOK" THEN
                     NEXT.
             END.

        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_promissoria2.
            RETURN "NOK".
        END.

    IF  lim_nrctaav2 = 0  THEN /* Conta nao prenchida */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE lim_nmdaval2   lim_cpfcgc2    lim_tpdocav2
                       lim_dscpfav2   lim_nmdcjav2   lim_cpfccg2     
                       lim_tpdoccj2   lim_dscfcav2   lim_nrcepend2   
                       lim_nrendere2  lim_complend2  lim_nrcxapst2  
                       lim_nrfonres2  lim_dsdemail2 
                       WITH FRAME f_promissoria2

                EDITING:

                    READKEY.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  
                        DO:
                            IF   glb_cddopcao = "I"   THEN
                                 APPLY "CLEAR".
                            ELSE
                                 APPLY "RECALL".
                                 
                            LEAVE.
                        END.
            
                    IF  FRAME-FIELD = "lim_nrcepend2" THEN
                        DO:
                            IF  LASTKEY = KEYCODE("F7") THEN
                                DO:
                                /* Inclusão de CEP integrado. (André - DB1) */
                                    RUN fontes/zoom_endereco.p 
                                                    ( INPUT 0,
                                                     OUTPUT TABLE tt-endereco ).
                                       
                                    FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                   
                                    IF  AVAIL tt-endereco THEN
                                        DO:
                   
                                            ASSIGN lim_nrcepend2   = 
                                                        tt-endereco.nrcepend
                                                   lim_dsendav2[1] = 
                                                        tt-endereco.dsendere
                                                   lim_dsendav2[2] = 
                                                        tt-endereco.nmbairro
                                                   lim_nmcidade2   = 
                                                        tt-endereco.nmcidade
                                                   lim_cdufresd2   = 
                                                        tt-endereco.cdufende.
                                                                             
                                            DISPLAY lim_nrcepend2      
                                                    lim_dsendav2[1]
                                                    lim_dsendav2[2]
                                                    lim_nmcidade2  
                                                    lim_cdufresd2  
                                                    WITH FRAME f_promissoria2.
                   
                                            IF  KEYFUNCTION(LASTKEY) 
                                                <> "END-ERROR" THEN 
                                                NEXT-PROMPT lim_nrendere2 
                                                     WITH FRAME f_promissoria2.
                                        END.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                    IF  FRAME-FIELD = "lim_cpfcgc2"   THEN
                        DO:
                            IF (LASTKEY = KEYCODE("RETURN")       OR
                                LASTKEY = KEYCODE("F1")           OR
                                LASTKEY = KEYCODE("BACK-TAB")     OR
                                LASTKEY = KEYCODE("CURSOR-DOWN")  OR
                                LASTKEY = KEYCODE("CURSOR-LEFT")  OR
                                LASTKEY = KEYCODE("CURSOR-RIGHT") OR                   
                                LASTKEY = KEYCODE("CURSOR-UP"))  AND
                                INPUT lim_cpfcgc2 > 0            AND
                                INPUT lim_nrctaav2 = 0           AND
                                glb_cddopcao = "I"  THEN  /* Somente qdo inclusao*/
                                DO:
                                    ASSIGN aux_cpfcgc = INPUT lim_cpfcgc2.
                                    RUN lista_dados_aval2.
                                    APPLY LASTKEY.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                        APPLY LASTKEY.
        
                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN lim_nrctaav2  
                                   lim_nmdaval2   
                                   lim_cpfcgc2    
                                   lim_cpfccg2   
                                   lim_dsendav2[1]
                                   lim_nrcepend2.
                   
                            RUN valida_aval 
                                 (INPUT lim_nrctaav1, /* Conta 1. Tit*/
                                  INPUT lim_cpfcgc1,  /* CPF 1. Tit*/
                                  INPUT 2, /* 2. Avalista */
                                  INPUT lim_nrctaav2, /* Conta*/
                                  INPUT lim_nmdaval2, /* Nome */
                                  INPUT lim_cpfcgc2,  /* CPF */
                                  INPUT lim_cpfccg2,  /* CPF conjuge */
                                  INPUT lim_dsendav2[1], /* Endereco */
                                  INPUT lim_cdufresd2, /* UF */
                                  INPUT lim_nrcepend2). /* CEP */
                   
                            IF  RETURN-VALUE = "NOK" THEN
                                DO:
                                    {sistema/generico/includes/foco_campo.i 
                                              &NOME-FRAME="f_promissoria2"
                                              &NOME-CAMPO=par_nmdcampo }
                                END.
                        END.
                   
                END.  /*  Fim do EDITING  */
                LEAVE.
            END.
        END.
    ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE MESSAGE
                 "Pressione algo para continuar - <F4>/<END> para voltar.".
                LEAVE.
            END.
        END.

    IF  lim_nrctaav1     = 0   AND
        lim_nmdaval1     = " " THEN
        ASSIGN lim_cpfcgc1      = 0
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
               lim_complend1    = " ". 
              
    IF  lim_nrctaav2       = 0   AND
        lim_nmdaval2       = " " THEN
        ASSIGN lim_nmdaval2     = " " 
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
    
    LEAVE.
    
END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_promissoria1 NO-PAUSE.
HIDE FRAME f_promissoria2 NO-PAUSE.

PROCEDURE lista_dados_aval1:
 
    FIND LAST crapavt WHERE crapavt.cdcooper = glb_cdcooper  AND
                            crapavt.nrcpfcgc = aux_cpfcgc    NO-LOCK NO-ERROR.
                            
    IF  AVAIL crapavt THEN 
        DO:
            ASSIGN  lim_nmdaval1     = crapavt.nmdavali 
                    lim_cpfcgc1      = crapavt.nrcpfcgc
                    lim_tpdocav1     = crapavt.tpdocava
                    lim_dscpfav1     = crapavt.nrdocava
                    lim_nmdcjav1     = crapavt.nmconjug
                    lim_cpfccg1      = crapavt.nrcpfcjg
                    lim_tpdoccj1     = crapavt.tpdoccjg 
                    lim_dscfcav1     = crapavt.nrdoccjg
                    lim_dsendav1[1]  = crapavt.dsendres[1]
                    lim_dsendav1[2]  = crapavt.dsendres[2]
                    lim_nrfonres1    = crapavt.nrfonres
                    lim_dsdemail1    = crapavt.dsdemail
                    lim_nmcidade1    = crapavt.nmcidade
                    lim_cdufresd1    = crapavt.cdufresd
                    lim_nrcepend1    = crapavt.nrcepend
                    lim_nrendere1    = crapavt.nrendere
                    lim_complend1    = crapavt.complend
                    lim_nrcxapst1    = crapavt.nrcxapst.
                    
            DISPLAY lim_nmdaval1  
                    lim_cpfcgc1 
                    lim_tpdocav1     
                    lim_dscpfav1     
                    lim_nmdcjav1     
                    lim_cpfccg1      
                    lim_tpdoccj1      
                    lim_dscfcav1     
                    lim_dsendav1[1]  
                    lim_dsendav1[2]  
                    lim_nrfonres1 
                    lim_dsdemail1  
                    lim_nmcidade1   
                    lim_cdufresd1   
                    lim_nrcepend1 
                    lim_nrendere1  
                    lim_complend1  
                    lim_nrcxapst1
                    WITH FRAME f_promissoria1.
        END.
END PROCEDURE.

PROCEDURE lista_dados_aval2:
 
    FIND LAST crapavt WHERE crapavt.cdcooper = glb_cdcooper  AND
                            crapavt.nrcpfcgc = aux_cpfcgc    NO-LOCK NO-ERROR.
              
    IF  AVAIL crapavt THEN 
        DO:
            ASSIGN  lim_nmdaval2     = crapavt.nmdavali 
                    lim_cpfcgc2      = crapavt.nrcpfcgc
                    lim_tpdocav2     = crapavt.tpdocava
                    lim_dscpfav2     = crapavt.nrdocava
                    lim_nmdcjav2     = crapavt.nmconjug
                    lim_cpfccg2      = crapavt.nrcpfcjg
                    lim_tpdoccj2     = crapavt.tpdoccjg 
                    lim_dscfcav2     = crapavt.nrdoccjg
                    lim_dsendav2[1]  = crapavt.dsendres[1]
                    lim_dsendav2[2]  = crapavt.dsendres[2]
                    lim_nrfonres2    = crapavt.nrfonres
                    lim_dsdemail2    = crapavt.dsdemail
                    lim_nmcidade2    = crapavt.nmcidade
                    lim_cdufresd2    = crapavt.cdufresd
                    lim_nrcepend2    = crapavt.nrcepend
                    lim_nrendere2    = crapavt.nrendere
                    lim_complend2    = crapavt.complend
                    lim_nrcxapst2    = crapavt.nrcxapst.
                
            DISPLAY lim_nmdaval2  
                    lim_cpfcgc2 
                    lim_tpdocav2     
                    lim_dscpfav2     
                    lim_nmdcjav2     
                    lim_cpfccg2      
                    lim_tpdoccj2      
                    lim_dscfcav2     
                    lim_dsendav2[1]  
                    lim_dsendav2[2]  
                    lim_nrfonres2 
                    lim_dsdemail2  
                    lim_nmcidade2   
                    lim_cdufresd2  
                    lim_nrcepend2
                    lim_nrendere2  
                    lim_complend2  
                    lim_nrcxapst2
                    WITH FRAME f_promissoria2.
        END.

END PROCEDURE.


PROCEDURE valida_aval:
    
    DEF INPUT PARAM par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_idavalis AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrctaavl AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nmdavali AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nrcpfavl AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_nrcpfcjg AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_dsendere AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_cdufresd AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nrcepend AS INTE                        NO-UNDO.


    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.

    RUN valida-avalistas IN h-b1wgen0024 
                            (INPUT glb_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT tel_nrdconta, /* Conta ATENDA*/
                             INPUT 999, /* parametro so do EMPRESTIMO */
                             INPUT 999, /* parametro so do EMPRESTIMO */                                       
                             INPUT par_nrdconta, /* Conta 1.aval */
                             INPUT par_nrcpfcgc, /* CPF 1.aval */
                             INPUT par_idavalis, /* 1ero./2do. aval */
                             INPUT par_nrctaavl, /* Dados do aval em questao */
                             INPUT par_nmdavali,
                             INPUT par_nrcpfavl,
                             INPUT par_nrcpfcjg,
                             INPUT par_dsendere,
                             INPUT par_cdufresd,
                             INPUT par_nrcepend,
                             INPUT 0, /* inpessoa */
                            OUTPUT par_nmdcampo,
                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0024.
    
    IF   RETURN-VALUE <> "OK"   THEN
         DO: 
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF    AVAIL tt-erro   THEN
                   MESSAGE tt-erro.dscritic.
             ELSE
                   MESSAGE "Erro na validaçao dos avalistas".
                
             RETURN "NOK".
         END.
  
    RETURN "OK".

END PROCEDURE.


PROCEDURE Limpa_Endereco:

    DEF INPUT PARAM aux_tpform AS INTE                               NO-UNDO.

    IF  aux_tpform = 1 THEN
        DO:
            ASSIGN lim_nrcepend1   = 0  
                   lim_dsendav1[1] = ""  
                   lim_dsendav1[2] = "" 
                   lim_nmcidade1   = ""  
                   lim_cdufresd1   = ""
                   lim_nrendere1   = 0
                   lim_complend1   = ""
                   lim_nrcxapst1   = 0.
        
            DISPLAY lim_nrcepend1  
                    lim_dsendav1[1]
                    lim_dsendav1[2]
                    lim_nmcidade1   
                    lim_cdufresd1  
                    lim_nrendere1  
                    lim_complend1  
                    lim_nrcxapst1 WITH FRAME f_promissoria1.
    END.
    ELSE
    IF  aux_tpform = 2 THEN
        DO:
            ASSIGN lim_nrcepend2   = 0  
                  lim_dsendav2[1] = ""  
                  lim_dsendav2[2] = "" 
                  lim_nmcidade2   = ""  
                  lim_cdufresd2   = ""
                  lim_nrendere2   = 0
                  lim_complend2   = ""
                  lim_nrcxapst2   = 0.
        
            DISPLAY lim_nrcepend2  
                    lim_dsendav2[1]
                    lim_dsendav2[2]
                    lim_nmcidade2   
                    lim_cdufresd2  
                    lim_nrendere2  
                    lim_complend2  
                    lim_nrcxapst2 WITH FRAME f_promissoria2.
        END.

END PROCEDURE.

/* ....................................................................... */


