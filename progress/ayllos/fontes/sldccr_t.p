/* ............................................................................

   Programa: Fontes/sldccr_t.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/97.                           Ultima atualizacao: 01/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para alteracao do limite de cartoes de credito.

   Alteracoes: 22/05/97 - Alterar dia de debito (Odair).

               25/08/98 - Modificado acesso a tabela de limites (Deborah).

               11/10/1999 - Alterado para imprimir proposta de alteracao de 
                            limite de cartao (Deborah).

               27/07/2001 - Incluir geracao de nota promissoria (Margarete).

               09/10/2002 - Pedir sempre a nota promissoria (Margarete).
               
               20/01/2003 - Ajuste na nota promissoria para tratar os 
                            conjuges fiadores (Eduardo).

               22/06/2004 - Separacao da alteracao de limite com a alteracao
                            da data de vencimento (Julio).

               23/06/2004 - Atualizar tabela avalistas Terceiros(Mirtes)
               
               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               13/06/2005 - Atualizar data de alteracao do limite. (Julio) 
               
               05/07/2005 - Alimentado campo cdcooper das tabelas crapavl e
                            crapavt (Diego).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               12/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).

               17/08/2006 - Incluida critica para nao realizar operacao se for
                            administradora BB (Diego).
                            
               20/09/2006 - Liberada alteracao do limite de credito para
                            administradoras BB (Diego).
                            
               10/06/2008 - Valor limite total de cartoes da Cooperativa com o
                            BB (Guilherme).              
     
               13/02/2009 - Incluido log para alt. de limite (Gabriel).
               
               16/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                           (GATI - Eder)
                           
               20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                           (Gati - Daniel).
                           
               26/04/2011 - Inclusões de variaveis de CEP integrado (nrendere,
                            complend e nrcxapst). (André - DB1)            
                            
               05/09/2011 - Incluido a chamada para a procedure alerta_fraude
                            (Adriano).
               
               01/04/2013 - Retirado a chamada da procedure alerta_fraude
                            (Adriano).

............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_limite.i "NEW"} /* Geracao de Nota Promissoria */

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.

DEF VAR tel_flgimpnp AS LOGI FORMAT "Imprime/Nao Imprime"              NO-UNDO.
DEF VAR tel_vllimite AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cpfrepre AS DEC EXTENT 3                                   NO-UNDO.
DEF VAR tel_repsolic AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR aux_represen AS CHAR                                           NO-UNDO.
DEF VAR aux_indposi2 AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_tipopess  AS INT                                           NO-UNDO.

FORM SKIP(1)
     par_nrcrcard  LABEL "Numero do cartao" COLON 26
                   FORMAT "9999,9999,9999,9999"
     "   "
     SKIP(1)
     tel_vllimite  LABEL "Valor do limite"  COLON 26
     HELP "Entre com o valor do limite"
     SKIP(1)
     tel_flgimpnp  LABEL "Promissoria"      COLON 26
          HELP '"I" para imprimir ou "N" para nao imprimir a promissoria.'
     WITH SIDE-LABELS ROW 9
     OVERLAY CENTERED TITLE COLOR NORMAL " Alteracao de limite " 
     FRAME f_limite.

FORM SKIP(1)
     par_nrcrcard  LABEL "Numero do cartao" COLON 26
                   FORMAT "9999,9999,9999,9999"
     "   "
     SKIP(1)
     tel_repsolic FORMAT "x(40)" LABEL "Representante Solicitante" 
     HELP "Utilizar setas direita/esquerda para escolher Representante" SKIP(1)
     tel_vllimite  LABEL "Valor do limite"  COLON 26
     HELP "Entre com o valor do limite"
     WITH SIDE-LABELS ROW 10
     OVERLAY CENTERED TITLE COLOR NORMAL " Alteracao de limite " 
     FRAME f_limite_pj.

DO WHILE TRUE:

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
        
    RUN carrega_dados_limcred_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT glb_dtmvtolt,
                              INPUT 1,
                              INPUT 1,
                              INPUT glb_nmdatela,
                              INPUT par_nrctrcrd,
                             OUTPUT TABLE tt-limite_crd_cartao,
                             OUTPUT TABLE tt-erro).

    RUN verifica_associado IN h_b1wgen0028 (INPUT glb_cdcooper,
                                            INPUT tel_nrdconta,
                                            OUTPUT aux_tipopess).
        
    DELETE PROCEDURE h_b1wgen0028.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
                 
    RUN carrega_representante IN h_b1wgen0028(INPUT glb_cdcooper,
                                              INPUT tel_nrdconta,  
                                              OUTPUT aux_represen,
                                              OUTPUT aux_cpfrepre).
     
    DELETE PROCEDURE h_b1wgen0028.

    
    ASSIGN tel_repsolic = ENTRY(1,aux_represen). 

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
        
            RETURN "NOK".
        END.
             
    FIND tt-limite_crd_cartao NO-ERROR.
    
    IF  NOT AVAIL tt-limite_crd_cartao  THEN 
        RETURN "NOK".

    ASSIGN tel_vllimite    = tt-limite_crd_cartao.vllimcrd
           tel_flgimpnp    = TRUE
           lim_nmdaval1    = " "
           lim_cpfcgc1     = 0
           lim_tpdocav1    = " " 
           lim_dscpfav1    = " "
           lim_nmdcjav1    = " "
           lim_cpfccg1     = 0
           lim_tpdoccj1    = " " 
           lim_dscfcav1    = " "
           lim_dsendav1[1] = " "
           lim_dsendav1[2] = " "
           lim_nrfonres1   = " "
           lim_dsdemail1   = " "
           lim_nmcidade1   = " " 
           lim_cdufresd1   = " "
           lim_nrcepend1   = 0
           lim_nrendere1   = 0    
           lim_complend1   = " "
           lim_nrcxapst1   = 0

           lim_nmdaval2    = " " 
           lim_cpfcgc2     = 0
           lim_tpdocav2    = " "
           lim_dscpfav2    = " "
           lim_nmdcjav2    = " "
           lim_cpfccg2     = 0
           lim_tpdoccj2    = " " 
           lim_dscfcav2    = " "
           lim_dsendav2[1] = " "
           lim_dsendav2[2] = " "
           lim_nrfonres2   = " "
           lim_dsdemail2   = " "
           lim_nmcidade2   = " " 
           lim_cdufresd2   = " "
           lim_nrcepend2   = 0
           lim_nrendere2   = 0    
           lim_complend2   = " "
           lim_nrcxapst2   = 0.

    IF   aux_tipopess <> 2 THEN
         DISPLAY par_nrcrcard tel_flgimpnp WITH FRAME f_limite.
    ELSE 
         DISPLAY par_nrcrcard tel_repsolic WITH FRAME f_limite_pj.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF   aux_tipopess <> 2 THEN
             DO:
                 UPDATE tel_vllimite WITH FRAME f_limite
        
                 EDITING:
                         
                     READKEY.
                     
                     IF  FRAME-FIELD = "tel_vllimite"  THEN
                         IF  LASTKEY = KEYCODE(".")  THEN
                             APPLY 44.
                         ELSE
                             APPLY LASTKEY.
                     ELSE
                         APPLY LASTKEY.
            
                 END. /* Fim do EDITING */
             END.
        ELSE DO:
            UPDATE tel_repsolic tel_vllimite WITH FRAME f_limite_pj
        
            EDITING:
                      
             READKEY.
            
                  IF  FRAME-FIELD = "tel_repsolic"  THEN
                      DO:
                      
                         IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                              DO:
                                  aux_indposi2 = aux_indposi2 - 1.
                      
                                  IF  aux_indposi2 = 0  THEN
                                      aux_indposi2 = NUM-ENTRIES(aux_represen).
                      
                                  tel_repsolic = ENTRY(aux_indposi2,aux_represen).
                      
                                  DISPLAY tel_repsolic WITH FRAME f_limite_pj.
                              END.
                      
                          ELSE
                          IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                              DO:
                                  aux_indposi2 = aux_indposi2 + 1.
                      
                                  IF  aux_indposi2 > NUM-ENTRIES(aux_represen)  THEN
                                      aux_indposi2 = 1.
                      
                                  tel_repsolic =  TRIM(ENTRY(aux_indposi2,
                                                             aux_represen)).
                      
                                  DISPLAY tel_repsolic WITH FRAME f_limite_pj.
                              END.
                          ELSE
                          IF  KEYFUNCTION(LASTKEY) = "RETURN"      OR
                              KEYFUNCTION(LASTKEY) = "BACK-TAB"    OR
                              KEYFUNCTION(LASTKEY) = "GO"          OR
                              KEYFUNCTION(LASTKEY) = "CURSOR-UP"   OR
                              KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                              KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                              APPLY LASTKEY.

                      END. 
                  ELSE
                  IF  FRAME-FIELD = "tel_vllimite"  THEN
                      IF  LASTKEY = KEYCODE(".")  THEN
                          APPLY 44.
                      ELSE
                          APPLY LASTKEY.
                  ELSE
                      APPLY LASTKEY.
            
            END. /* Fim do EDITING */
        END.

        RUN sistema/generico/procedures/b1wgen0028.p 
            PERSISTENT SET h_b1wgen0028.
        
        RUN valida_dados_limcred_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT glb_dtmvtolt,
                              INPUT 1,
                              INPUT 1,
                              INPUT glb_nmdatela,
                              INPUT par_nrctrcrd,
                              INPUT tel_vllimite,
                              INPUT tel_repsolic,
                             OUTPUT TABLE tt-dados-avais,
                             OUTPUT TABLE tt-msg-confirma,
                             OUTPUT TABLE tt-erro).
                
        DELETE PROCEDURE h_b1wgen0028.
     
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAIL tt-erro  THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                    END.
            
                NEXT.
            END.

        
        FOR EACH tt-msg-confirma:
            MESSAGE tt-msg-confirma.dsmensag.
            PAUSE.
        END.     
        
        LEAVE.
      
    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN    
        DO:
            HIDE FRAME f_limite NO-PAUSE.
            HIDE FRAME f_limite_pj NO-PAUSE.
            RETURN "NOK".
        END.
        
    IF  tel_flgimpnp  THEN
        DO:
            ASSIGN aux_contador = 1.
            
            FOR EACH tt-dados-avais:

                IF  aux_contador = 1  THEN
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
                           lim_nrcxapst1   = tt-dados-avais.nrcxapst
                           aux_contador    = 2.
                ELSE
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
                             
            END. /* FOR EACH tt-dados-avais */
            IF   aux_tipopess <> 2 THEN
                RUN fontes/limite_inp.p.            
        END.
    ELSE
        ASSIGN lim_nrctaav1    = 0
               lim_nmdaval1    = " "                  
               lim_cpfcgc1     = 0
               lim_tpdocav1    = " " 
               lim_dscpfav1    = " "
               lim_nmdcjav1    = " "
               lim_cpfccg1     = 0
               lim_tpdoccj1    = " " 
               lim_dscfcav1    = " "
               lim_dsendav1[1] = " "
               lim_dsendav1[2] = " "
               lim_nrfonres1   = " "
               lim_dsdemail1   = " "
               lim_nmcidade1   = " " 
               lim_cdufresd1   = " "
               lim_nrcepend1   = 0
               lim_nrendere1   = 0    
               lim_complend1   = " "
               lim_nrcxapst1   = 0

               lim_nrctaav2    = 0
               lim_nmdaval2    = " " 
               lim_cpfcgc2     = 0
               lim_tpdocav2    = " "
               lim_dscpfav2    = " "
               lim_nmdcjav2    = " "
               lim_cpfccg2     = 0
               lim_tpdoccj2    = " " 
               lim_dscfcav2    = " "
               lim_dsendav2[1] = " "
               lim_dsendav2[2] = " "
               lim_nrfonres2   = " "
               lim_dsdemail2   = " "
               lim_nmcidade2   = " " 
               lim_cdufresd2   = " "
               lim_nrcepend2   = 0
               lim_nrendere2   = 0    
               lim_complend2   = " "
               lim_nrcxapst2   = 0.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        glb_cdcritic = 0.
                     
        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             
        LEAVE.

    END.  /* Fim do DO WHILE TRUE */

   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
        aux_confirma <> "S"                 THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            
            BELL.
            MESSAGE glb_dscritic.
            
            HIDE FRAME f_limite NO-PAUSE.
            HIDE FRAME f_limite_pj NO-PAUSE.
            
            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

    RUN altera_limcred_cartao IN h_b1wgen0028
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT tel_nrdconta,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1,
                                 INPUT 1,
                                 INPUT glb_nmdatela,
                                 /*** Dados do cartao ***/
                                 INPUT par_nrctrcrd,
                                 INPUT tel_vllimite,
                                 INPUT tel_flgimpnp,
                                 INPUT aux_cpfrepre[aux_indposi2],
                                 /*** Dados do primeiro avalista ***/
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
                                 /*** Dados do segundo avalista ***/
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
                                OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h_b1wgen0028.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
        
            NEXT.
        END.

    HIDE FRAME f_limite NO-PAUSE.
    HIDE FRAME f_limite_pj NO-PAUSE.

    LEAVE.

END. /* DO WHILE TRUE */


RUN fontes/sldccr_it.p (INPUT par_nrctrcrd,
                        INPUT par_nrcrcard).
   
RETURN "OK".

/* .......................................................................... */
