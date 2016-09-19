/*............................................................................ 

   Programa: fontes/dsctit_aval.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008.                     Ultima atualizacao:  02/12/2014 
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Dar update nos avalistas para limite de desconto de titulos.

   Alteracoes: 07/10/2010 - Incluir parametro de retorno do campo com erro
                            na procedure que valida os avalistas (Gabriel).
                            
               20/12/2010 - Tratar AVAIL na tt-dados-avais (Guilherme).   
               
               11/01/2011 - Passar com parametro a conta na validacao dos
                            avalistas (Gabriel).   
                            
               20/04/2011 - Separação dos avalistas. Inclusão de Campos para
                            CEP integrado. (André - DB1)  
                            
               03/05/2011 - Bloqueio de campos ao sair de campo conta do
                            avalista. Alteração na chamada da busca do avalista.
                            (André - DB1)                     
                            
               13/07/2011 - Realizar a validacao dos avalisas atraves da 
                            B1wgen0024 (Gabriel)            
                
               21/12/2011 - Corrigido warnings (Tiago).             
               
               14/10/2014 - Ajustes validacao avalista. Projeto consultas
                            automatizadas (Jonata-RKAM).
               
               02/12/2014 - Identificar a natureza do avalista(PJ ou PF) e passar como parametro
                            para a função valida-avalista (Felipe - Chamado 228120).
               
               
............................................................................. */

DEF BUFFER crabass FOR crapass.

DEF VAR aux_nrdeanos   AS INT                                         NO-UNDO.
DEF VAR aux_nrdmeses   AS INT                                         NO-UNDO.
DEF VAR aux_dsdidade   AS CHAR                                        NO-UNDO.
DEF VAR aux_cpfcgc   LIKE crapavt.nrcpfcgc                            NO-UNDO.
DEF VAR par_nmdcampo   AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdcampo   AS CHAR                                        NO-UNDO.

DEF NEW SHARED VAR shr_inpessoa AS INT                                NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_dsctit.i }

DEF VAR h-b1wgen0024 AS HANDLE      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE      NO-UNDO.


/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF lim_nrcepend1 IN FRAME f_dsctit_promissoria1 DO:
    IF  INPUT lim_nrcepend1 = 0  THEN
        RUN Limpa_Endereco(1).
END.

ON GO, LEAVE OF lim_nrcepend2 IN FRAME f_dsctit_promissoria2 DO:
    IF  INPUT lim_nrcepend2 = 0  THEN
        RUN Limpa_Endereco(2).
END.

ON RETURN OF lim_nrcepend1 IN FRAME f_dsctit_promissoria1 DO:

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
            lim_cdufresd1   WITH FRAME f_dsctit_promissoria1.

    NEXT-PROMPT lim_nrendere1 WITH FRAME f_dsctit_promissoria1.

END.

ON RETURN OF lim_nrcepend2 IN FRAME f_dsctit_promissoria2 DO:

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
            lim_cdufresd2   WITH FRAME f_dsctit_promissoria2.

    NEXT-PROMPT lim_nrendere2 WITH FRAME f_dsctit_promissoria2.

END.

ON GO, RETURN OF lim_nrctaav1 DO:

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN consulta-avalista IN h-b1wgen9999 
                            (INPUT glb_cdcooper,
                             INPUT 0, /*cdagenci*/
                             INPUT 0, /*nrdcaixa*/
                             INPUT 1,
                             INPUT tel_nrdconta,
                             INPUT glb_dtmvtolt,
                             INPUT INPUT lim_nrctaav1,
                             INPUT 0, /*nrcpfcgc*/
                            OUTPUT TABLE tt-dados-avais,
                            OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE PROCEDURE h-b1wgen9999.
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                MESSAGE tt-erro.dscritic.

            RETURN NO-APPLY.
        END.
    
    FIND FIRST tt-dados-avais WHERE
               tt-dados-avais.nrctaava = INPUT lim_nrctaav1
               NO-LOCK NO-ERROR.

    IF  AVAIL tt-dados-avais  THEN
        DO:
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
                   lim_nrcxapst1   = tt-dados-avais.nrcxapst
                   lim_complend1   = tt-dados-avais.complend.

            DISPLAY lim_nrctaav1    lim_nmdaval1    
                    lim_cpfcgc1     lim_tpdocav1   
                    lim_dscpfav1    lim_nmdcjav1
                    lim_cpfccg1     lim_tpdoccj1    
                    lim_dscfcav1    lim_dsendav1[1] 
                    lim_dsendav1[2] lim_nrfonres1
                    lim_dsdemail1   lim_nmcidade1   
                    lim_cdufresd1   lim_nrcepend1   
                    lim_nrendere1   lim_nrcxapst1
                    lim_complend1  
                    WITH FRAME f_dsctit_promissoria1.
        END.

END.

ON GO, RETURN OF lim_nrctaav2 IN FRAME f_dsctit_promissoria2 DO:

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN consulta-avalista IN h-b1wgen9999 
                          (INPUT glb_cdcooper,
                           INPUT 0, /*cdagenci*/
                           INPUT 0, /*nrdcaixa*/
                           INPUT 1,
                           INPUT tel_nrdconta,
                           INPUT glb_dtmvtolt,
                           INPUT INPUT lim_nrctaav2,
                           INPUT 0, /*nrcpfcgc*/
                          OUTPUT TABLE tt-dados-avais,
                          OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE PROCEDURE h-b1wgen9999.
                                                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                MESSAGE tt-erro.dscritic.
                
            RETURN NO-APPLY.
        END.

    FIND FIRST tt-dados-avais WHERE
            tt-dados-avais.nrctaava = INPUT lim_nrctaav2
             NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-dados-avais  THEN
        DO:
    
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
                   lim_nrcxapst2   = tt-dados-avais.nrcxapst
                   lim_complend2   = tt-dados-avais.complend.
                   
            DISPLAY lim_nrctaav2    lim_nmdaval2    
                    lim_cpfcgc2     lim_tpdocav2    
                    lim_dscpfav2    lim_nmdcjav2
                    lim_cpfccg2     lim_tpdoccj2    
                    lim_dscfcav2    lim_dsendav2[1]
                    lim_dsendav2[2] lim_nrfonres2
                    lim_dsdemail2   lim_nmcidade2   
                    lim_cdufresd2   lim_nrcepend2   
                    lim_nrendere2   lim_nrcxapst2
                    lim_complend2
                    WITH FRAME f_dsctit_promissoria2.
        END.
END.

IF  glb_cddopcao = "I"   THEN
    ASSIGN lim_nrctaav1  = 0
           lim_cpfcgc1   = 0
           lim_nmdaval1  = ""
           lim_dscpfav1  = ""
           lim_nmdcjav1  = ""
           lim_cpfccg1   = 0 
           lim_tpdocav1  = ""
           lim_tpdoccj1  = ""   
           lim_dscfcav1  = ""   
           lim_dsendav1  = ""
           lim_nmcidade1 = ""
           lim_cdufresd1 = "" 
           lim_nrcepend1 = 0
           lim_nrendere1 = 0
           lim_nrcxapst1 = 0
           lim_complend1 = ""
           lim_nrfonres1 = ""
           lim_dsdemail1 = ""
           
           lim_nrctaav2  = 0   
           lim_cpfcgc2   = 0
           lim_nmdaval2  = ""
           lim_tpdocav2  = ""
           lim_tpdoccj2  = ""
           lim_dscpfav2  = ""   
           lim_nmdcjav2  = ""   
           lim_cpfccg2   = 0 
           lim_dscfcav2  = ""
           lim_dsendav2  = ""
           lim_nmcidade2 = ""
           lim_cdufresd2 = "" 
           lim_nrcepend2 = 0
           lim_nrendere2 = 0     
           lim_nrcxapst2 = 0     
           lim_complend2 = ""
           lim_nrfonres2 = ""
           lim_dsdemail2 = "".
            
DO  WHILE TRUE ON ENDKEY UNDO, RETURN:

    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

    DISPLAY lim_dsendav1    lim_nmcidade1   lim_cdufresd1
            lim_nmdaval1    lim_cpfcgc1     lim_tpdocav1
            lim_dscpfav1    lim_nmdcjav1    lim_cpfccg1     lim_tpdoccj1
            lim_dscfcav1    lim_nrcepend1   lim_nrendere1   lim_complend1   
            lim_nrcxapst1   lim_nrfonres1   lim_dsdemail1
            WITH FRAME f_dsctit_promissoria1.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE lim_nrctaav1 WITH FRAME f_dsctit_promissoria1.

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
            HIDE FRAME f_dsctit_promissoria1.
            RETURN "NOK".
        END.

    IF  lim_nrctaav1 = 0  THEN /* Conta nao prenchida */
        DO:    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                UPDATE lim_nmdaval1    lim_cpfcgc1     lim_tpdocav1
                       lim_dscpfav1    lim_nmdcjav1    lim_cpfccg1     
                       lim_tpdoccj1    lim_dscfcav1    lim_nrcepend1   
                       lim_nrendere1   lim_complend1   lim_nrcxapst1   
                       lim_nrfonres1   lim_dsdemail1
                       WITH FRAME f_dsctit_promissoria1

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
                                               WITH FRAME f_dsctit_promissoria1.
                    
                                            IF  KEYFUNCTION(LASTKEY) 
                                                <> "END-ERROR" THEN 
                                                NEXT-PROMPT lim_nrendere1 
                                                WITH FRAME f_dsctit_promissoria1.
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
                                LASTKEY = KEYCODE("F1"))         AND           
                                INPUT lim_cpfcgc1 > 0            AND
                                INPUT lim_nrctaav1 = 0           AND
                                glb_cddopcao = "I"  THEN /* Somente inclusao*/
                                DO:
                                    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                                        RUN sistema/generico/procedures/b1wgen9999.p 
                                            PERSISTENT SET h-b1wgen9999.

                                    RUN consulta-avalista IN h-b1wgen9999 
                                               ( INPUT glb_cdcooper,
                                                 INPUT 0, /*cdagenci*/
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT 1,
                                                 INPUT tel_nrdconta,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT 0, /*nrdconta*/
                                                 INPUT INPUT lim_cpfcgc1,
                                                OUTPUT TABLE tt-dados-avais,
                                                OUTPUT TABLE tt-erro ).

                                    IF  VALID-HANDLE(h-b1wgen9999) THEN
                                        DELETE PROCEDURE h-b1wgen9999.
                                                               
                                    IF  RETURN-VALUE = "NOK"  THEN
                                        DO:
                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                            IF  AVAIL tt-erro  THEN
                                                MESSAGE tt-erro.dscritic.
                                                
                                            NEXT.
                                        END.

                                    FIND FIRST tt-dados-avais WHERE
                                               tt-dados-avais.nrcpfcgc = 
                                                              INPUT lim_cpfcgc1
                                               NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-dados-avais  THEN
                                    DO:
                                    ASSIGN 
                                      lim_nrctaav1    = tt-dados-avais.nrctaava  
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
                                      lim_nrcxapst1   = tt-dados-avais.nrcxapst
                                      lim_complend1   = tt-dados-avais.complend.
                    
                                    DISPLAY lim_nrctaav1    lim_nmdaval1    
                                            lim_cpfcgc1     lim_tpdocav1    
                                            lim_dscpfav1    lim_nmdcjav1
                                            lim_cpfccg1     lim_tpdoccj1    
                                            lim_dscfcav1    lim_dsendav1[1] 
                                            lim_dsendav1[2] lim_nrfonres1
                                            lim_dsdemail1   lim_nmcidade1   
                                            lim_cdufresd1   lim_nrcepend1  
                                            lim_nrendere1   lim_nrcxapst1
                                            lim_complend1  
                                            WITH FRAME f_dsctit_promissoria1.
                                    END.
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
                                          &NOME-FRAME="f_dsctit_promissoria1"
                                          &NOME-CAMPO=aux_nmdcampo }
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

    HIDE FRAME f_dsctit_promissoria1 NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR lim_nmdaval1 = "" THEN
        LEAVE.

    DISPLAY lim_dsendav2   lim_nmcidade2   lim_cdufresd2
            lim_nrctaav2   lim_nmdaval2    lim_cpfcgc2     lim_tpdocav2
            lim_dscpfav2   lim_nmdcjav2    lim_cpfccg2     lim_tpdoccj2
            lim_dscfcav2   lim_nrcepend2   lim_nrendere2   lim_complend2  
            lim_nrcxapst2  lim_nrfonres2   lim_dsdemail2 
            WITH FRAME f_dsctit_promissoria2.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE lim_nrctaav2 WITH FRAME f_dsctit_promissoria2.

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
            HIDE FRAME f_dsctit_promissoria2.
            RETURN "NOK".
        END.

    IF  lim_nrctaav2 = 0  THEN /* Conta nao prenchida */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
 
                UPDATE lim_nmdaval2    lim_cpfcgc2     lim_tpdocav2
                       lim_dscpfav2    lim_nmdcjav2    lim_cpfccg2     
                       lim_tpdoccj2    lim_dscfcav2    lim_nrcepend2   
                       lim_nrendere2   lim_complend2   lim_nrcxapst2 
                       lim_nrfonres2   lim_dsdemail2 
                       WITH FRAME f_dsctit_promissoria2
 
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
                                         OUTPUT TABLE tt-endereco).
                                       
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
                                              WITH FRAME f_dsctit_promissoria2.
                   
                                            IF  KEYFUNCTION(LASTKEY) 
                                                <> "END-ERROR" THEN 
                                                NEXT-PROMPT lim_nrendere2 
                                                WITH FRAME f_dsctit_promissoria2.
                                        END.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                   /*---- Verificar CPFCGC TERCEIROS ja Cadastrados ---*/
                    IF  FRAME-FIELD = "lim_cpfcgc2"   THEN
                        DO:
                            IF (LASTKEY = KEYCODE("RETURN")       OR
                                LASTKEY = KEYCODE("F1"))         AND
                                INPUT lim_cpfcgc2 > 0            AND
                                INPUT lim_nrctaav2 = 0           AND
                                glb_cddopcao = "I"  THEN  /* Somente inclusao */
                                DO:
                                    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                                        RUN sistema/generico/procedures/b1wgen9999.p 
                                            PERSISTENT SET h-b1wgen9999.

                                    RUN consulta-avalista IN h-b1wgen9999 
                                             (INPUT glb_cdcooper,
                                              INPUT 0, /*cdagenci*/
                                              INPUT 0, /*nrdcaixa*/
                                              INPUT 1,
                                              INPUT tel_nrdconta,
                                              INPUT glb_dtmvtolt,
                                              INPUT 0, /*nrdconta*/
                                              INPUT INPUT lim_cpfcgc2,
                                             OUTPUT TABLE tt-dados-avais,
                                             OUTPUT TABLE tt-erro).

                                    IF  VALID-HANDLE(h-b1wgen9999) THEN
                                        DELETE PROCEDURE h-b1wgen9999.
                                                               
                                    IF  RETURN-VALUE = "NOK"  THEN
                                        DO:
                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                            IF  AVAIL tt-erro  THEN
                                                MESSAGE tt-erro.dscritic.
                                            NEXT-PROMPT lim_cpfcgc2 
                                               WITH FRAME f_dsctit_promissoria2.
                                        END.
                   
                                    FIND FIRST tt-dados-avais WHERE
                                            tt-dados-avais.nrcpfcgc = 
                                                              INPUT lim_cpfcgc2
                                            NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-dados-avais  THEN
                                    DO:
                                    ASSIGN 
                                      lim_nrctaav2    = tt-dados-avais.nrctaava
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
                                      lim_nrcxapst2   = tt-dados-avais.nrcxapst
                                      lim_complend2   = tt-dados-avais.complend.
                   
                                    DISPLAY lim_nrctaav2    lim_nmdaval2    
                                            lim_cpfcgc2     lim_tpdocav2    
                                            lim_dscpfav2    lim_nmdcjav2
                                            lim_cpfccg2     lim_tpdoccj2    
                                            lim_dscfcav2    lim_dsendav2[1] 
                                            lim_dsendav2[2] lim_nrfonres2
                                            lim_dsdemail2   lim_nmcidade2  
                                            lim_cdufresd2   lim_nrcepend2   
                                            lim_nrendere2   lim_nrcxapst2
                                            lim_complend2
                                            WITH FRAME f_dsctit_promissoria2.
                                    END.
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
                                          &NOME-FRAME="f_dsctit_promissoria2"
                                          &NOME-CAMPO=aux_nmdcampo }
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

    IF  lim_nrctaav1     = 0 AND
        lim_nmdaval1     = " " THEN
        ASSIGN
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
              lim_complend1    = " ". 
             
    IF  lim_nrctaav2       = 0 AND
        lim_nmdaval2       = " " THEN
        ASSIGN
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
  
    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_dsctit_promissoria1 NO-PAUSE.
HIDE FRAME f_dsctit_promissoria2 NO-PAUSE.

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
    
    DEF  VAR        par_inpessoa AS INTE                        NO-UNDO.
    DEF  VAR        aux_stsnrcal AS INTE                        NO-UNDO.
    RUN sistema/generico/procedures/b1wgen9999.p 
                                   PERSISTENT SET h-b1wgen9999.
    RUN valida-cpf-cnpj IN h-b1wgen9999
                                    (INPUT par_nrcpfcgc,
                                    OUTPUT aux_stsnrcal,
                                    OUTPUT par_inpessoa).
        
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
                             INPUT par_inpessoa,
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
                    lim_nrcxapst1 WITH FRAME f_dsctit_promissoria1.
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
                    lim_nrcxapst2 WITH FRAME f_dsctit_promissoria2.
        END.

END PROCEDURE.

/* .......................................................................... */
