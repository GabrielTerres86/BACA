/* .............................................................................

   Programa: fontes/altava_a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes       
   Data    : Junho/2004                       Ultima atualizacao: 06/06/2011
                                                                        
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratamento das alteracoes dos dados de avalistas.      

   Alteracoes: 17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               19/05/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).

               06/09/2006 - Excluidas opcoes "TAB" (Diego).

               01/10/2007 - Conversao de rotina ver_cadastro para BO    
                            (Sidnei/Precise)
               
               05/08/2009 - trocar campo cdgraupr (crapass) para crapttl
                            Paulo - Precise.
                            
               10/12/2009 - Alterar inhabmen da ass para ttl (Guilherme).
               
               12/02/2011 - Validar os avalistas com a BO 9999 (Gabriel).
               
               29/04/2011 - Separação de avalistas. Inclusão de CEP integrado.
                            (André - DB1)
                            
               03/05/2011 - Bloqueio de campos ao sair de campo conta do
                            avalista. Alteração na chamada da busca do avalista.
                            (André - DB1)
                            
               13/07/2011 - Realizar a validacao dos avalisas atraves da 
                            B1wgen0024 (Gabriel) 

               14/12/2011 - Adaptado fonte para o uso de BO. 
                            (Rogerius Militao - DB1 ).
                            
               06/06/2014 - Adicionado tratamento para novos campos inpessoa e
                            dtnascto do avalista 1 e 2 (Daniel) 
                                         
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0126tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ includes/var_altava.i }
                                                                     
DEF VAR h-b1wgen0126 AS HANDLE                                       NO-UNDO.

DEF VAR aux_nrdconta AS INTE                                         NO-UNDO.
DEF VAR par_nmdcampo AS CHAR                                         NO-UNDO.                                                                     

DEF NEW SHARED VAR shr_inpessoa AS INT                               NO-UNDO.
DEF SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.


/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF pro_nrcepend1 IN FRAME f_promissoria1 DO:
    IF  INPUT pro_nrcepend1 = 0  THEN
        RUN Limpa_Endereco(1).
END.

ON GO, LEAVE OF pro_nrcepend2 IN FRAME f_promissoria2 DO:
    IF  INPUT pro_nrcepend2 = 0  THEN
        RUN Limpa_Endereco(2).
    
END.

ON RETURN OF pro_nrcepend1 IN FRAME f_promissoria1 DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT pro_nrcepend1.

    IF  pro_nrcepend1 <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT pro_nrcepend1,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN 
                       pro_nrcepend1   = tt-endereco.nrcepend 
                       pro_dsendav1[1] = tt-endereco.dsendere
                       pro_dsendav1[2] = tt-endereco.nmbairro 
                       pro_nmcidade1   = tt-endereco.nmcidade 
                       pro_cdufresd1   = tt-endereco.cdufende.
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

    DISPLAY pro_nrcepend1     
            pro_dsendav1[1]
            pro_dsendav1[2]
            pro_nmcidade1  
            pro_cdufresd1   WITH FRAME f_promissoria1.

    NEXT-PROMPT pro_nrendere1 WITH FRAME f_promissoria1.

END.

ON RETURN OF pro_nrcepend2 IN FRAME f_promissoria2 DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT pro_nrcepend2.

    IF  pro_nrcepend2 <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT pro_nrcepend2,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN 
                       pro_nrcepend2   = tt-endereco.nrcepend 
                       pro_dsendav2[1] = tt-endereco.dsendere
                       pro_dsendav2[2] = tt-endereco.nmbairro 
                       pro_nmcidade2   = tt-endereco.nmcidade 
                       pro_cdufresd2   = tt-endereco.cdufende.
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

    DISPLAY pro_nrcepend2     
            pro_dsendav2[1]
            pro_dsendav2[2]
            pro_nmcidade2  
            pro_cdufresd2   WITH FRAME f_promissoria2.

    NEXT-PROMPT pro_nrendere2 WITH FRAME f_promissoria2.

END.

ON GO, RETURN OF pro_nrctaav1 IN FRAME f_promissoria1 DO:

    IF  INPUT pro_nrctaav1 <> 0  THEN
        DO:

            RUN Valida_Conta ( INPUT INPUT pro_nrctaav1 ).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    APPLY "RECALL".
                    RETURN NO-APPLY.
                END.
        
            HIDE MESSAGE NO-PAUSE.
            
            RUN Busca_Avalista ( INPUT 1,  /* nrindice */ 
                                 INPUT INPUT pro_nrctaav1, 
                                 INPUT 0). /* nrcpfcgc */
            
        END.
END.

ON GO, RETURN OF pro_nrctaav2 IN FRAME f_promissoria2 DO:

    IF  INPUT pro_nrctaav2 <> 0  THEN
        DO:

            RUN Valida_Conta ( INPUT INPUT pro_nrctaav2 ).
    
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    APPLY "RECALL".
                    RETURN NO-APPLY.
                END.
    
            HIDE MESSAGE NO-PAUSE.
    
            RUN Busca_Avalista ( INPUT 2,  /* nrindice */ 
                                 INPUT INPUT pro_nrctaav2, 
                                 INPUT 0). /* nrcpfcgc */

        END.
END.


DO WHILE TRUE ON ENDKEY UNDO, RETURN:

    DISPLAY pro_dsendav1[1]
            pro_dsendav1[2]
            pro_nmcidade1
            pro_cdufresd1
            pro_nrctaav1   
            pro_nmdaval1  
            pro_cpfcgc1
            pro_tpdocav1
            pro_dscpfav1
            pro_nmcjgav1 
            pro_cpfccg1
            pro_tpdoccj1
            pro_dscfcav1
            pro_nrcepend1
            pro_nrendere1
            pro_complend1
            pro_nrcxapst1
            pro_nrfonres1
            pro_dsdemail1
            pro_inpessoa1
            pro_dtnascto1
            pro_dspessoa1
            WITH FRAME f_promissoria1.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE pro_nrctaav1 WITH FRAME f_promissoria1
        EDITING:
            READKEY.
            IF  FRAME-FIELD = "pro_nrctaav1"   AND
                LASTKEY = KEYCODE("F7")        THEN
                DO: 
                    RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                  OUTPUT aux_nrdconta).

                    IF  aux_nrdconta > 0   THEN
                        DO:
                            ASSIGN pro_nrctaav1 = aux_nrdconta.
                            DISPLAY pro_nrctaav1 
                                WITH FRAME f_promissoria1.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */

        IF   pro_nrctaav1 <> 0   THEN
             DO:
                 RUN Valida_Avalista (INPUT 0, /* Este dado vai soh no 2. Tit*/
                                      INPUT 0, /* Este dado vai soh no 2. Tit*/
                                      INPUT 1, /* 1. Avalista */
                                      INPUT pro_nrctaav1, /* Conta*/
                                      INPUT pro_nmdaval1, /* Nome */
                                      INPUT pro_cpfcgc1,  /* CPF */
                                      INPUT pro_cpfccg1,  /* CPF conjuge */
                                      INPUT pro_dsendav1[1], /* Endereco */
                                      INPUT pro_cdufresd1, /* UF */
                                      INPUT pro_nrcepend1, /* CEP */
                                      INPUT pro_inpessoa1, /* Tipo Pessoa */ 
                                      INPUT pro_dtnascto1). /* Data de Nascimento */
                                 
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

    IF  pro_nrctaav1 = 0  THEN /* Conta nao prenchida */
        DO:
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
  
                UPDATE  
                       pro_inpessoa1
                       pro_cpfcgc1
                       pro_nmdaval1 
                       pro_dtnascto1
                       pro_tpdocav1
                       pro_dscpfav1
                       pro_nmcjgav1 
                       pro_cpfccg1
                       pro_tpdoccj1
                       pro_dscfcav1
                       pro_nrcepend1
                       pro_nrendere1
                       pro_complend1
                       pro_nrcxapst1
                       pro_nrfonres1
                       pro_dsdemail1
                       WITH FRAME f_promissoria1
   
                EDITING:
            
                    READKEY.

                    ON LEAVE, RETURN OF pro_inpessoa1 IN FRAME f_promissoria1 DO:

                       ASSIGN INPUT pro_inpessoa1.
                      
                       IF pro_inpessoa1 = 1   THEN
                          pro_dspessoa1 = "FISICA".
                       ELSE
                          IF pro_inpessoa1 = 2   THEN
                             pro_dspessoa1 = "JURIDICA".
                          ELSE
                             pro_dspessoa1 = "".
                    
                       DISPLAY pro_dspessoa1 WITH FRAME f_promissoria1.
                    
                    END.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        DO:
                            APPLY "RECALL".
                            LEAVE.
                        END.

                    IF  FRAME-FIELD = "pro_nrcepend1" THEN 
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
                                            ASSIGN pro_nrcepend1   = 
                                                        tt-endereco.nrcepend
                                                   pro_dsendav1[1] = 
                                                        tt-endereco.dsendere
                                                   pro_dsendav1[2] = 
                                                        tt-endereco.nmbairro
                                                   pro_nmcidade1   = 
                                                        tt-endereco.nmcidade
                                                   pro_cdufresd1   = 
                                                        tt-endereco.cdufende.
                                                                     
                                            DISPLAY pro_nrcepend1      
                                                    pro_dsendav1[1]
                                                    pro_dsendav1[2]
                                                    pro_nmcidade1  
                                                    pro_cdufresd1  
                                               WITH FRAME f_promissoria1.
                    
                                            IF  KEYFUNCTION(LASTKEY) 
                                                <> "END-ERROR" THEN 
                                                NEXT-PROMPT pro_nrendere1 
                                                WITH FRAME f_promissoria1.
                                        END.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                   /*---- Verificar CPFCGC TERCEIROS ja Cadastrados ---*/
                    IF  FRAME-FIELD = "pro_cpfcgc1"   THEN
                        DO:
                            IF (LASTKEY = KEYCODE("RETURN")       OR
                                LASTKEY = KEYCODE("F1")           OR
                                LASTKEY = KEYCODE("BACK-TAB")     OR
                                LASTKEY = KEYCODE("CURSOR-DOWN")  OR
                                LASTKEY = KEYCODE("CURSOR-LEFT")  OR
                                LASTKEY = KEYCODE("CURSOR-RIGHT") OR       
                                LASTKEY = KEYCODE("CURSOR-UP"))  AND
                                INPUT pro_cpfcgc1 > 0            AND
                                INPUT pro_nrctaav1 = 0           AND
                                pro_cpfcgc1 <> INPUT pro_cpfcgc1 THEN
                                DO:
                                    RUN Busca_Avalista ( INPUT 1,  /* nrindice */ 
                                                         INPUT 0,  /*_nrctaav1 */ 
                                                         INPUT INPUT pro_cpfcgc1). 

                                    APPLY LASTKEY.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                        APPLY LASTKEY.
            
                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN pro_nrctaav1   
                                   pro_nmdaval1   
                                   pro_cpfcgc1    
                                   pro_cpfccg1   
                                   pro_dsendav1[1]
                                   pro_nrcepend1
                                   pro_inpessoa1
                                   pro_dtnascto1.
                      
                             RUN Valida_Avalista 
                                 (INPUT 0, /* Este dado vai soh no 2. Tit*/
                                  INPUT 0, /* Este dado vai soh no 2. Tit*/
                                  INPUT 1, /* 1. Avalista */
                                  INPUT pro_nrctaav1, /* Conta*/
                                  INPUT pro_nmdaval1, /* Nome */
                                  INPUT pro_cpfcgc1,  /* CPF */
                                  INPUT pro_cpfccg1,  /* CPF conjuge */
                                  INPUT pro_dsendav1[1], /* Endereco */
                                  INPUT pro_cdufresd1, /* UF */
                                  INPUT pro_nrcepend1, /* CEP */
                                  INPUT pro_inpessoa1, /* Tipo Pessoa */ 
                                  INPUT pro_dtnascto1). /* Data de Nascimento */
                      
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

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR pro_nmdaval1 = "" THEN
        LEAVE.

    DISPLAY pro_dsendav2[1]
            pro_dsendav2[2]
            pro_nmcidade2
            pro_cdufresd2
            pro_nrctaav2   
            pro_nmdaval2  
            pro_cpfcgc2
            pro_tpdocav2
            pro_dscpfav2
            pro_nmcjgav2 
            pro_cpfccg2
            pro_tpdoccj2
            pro_dscfcav2
            pro_nrcepend2
            pro_nrendere2
            pro_complend2
            pro_nrcxapst2
            pro_nrfonres2
            pro_dsdemail2
            pro_inpessoa2
            pro_dtnascto2
            pro_dspessoa2
            WITH FRAME f_promissoria2.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
        UPDATE pro_nrctaav2 WITH FRAME f_promissoria2
        EDITING:
            READKEY.
            
            IF  FRAME-FIELD = "pro_nrctaav2"   AND
                LASTKEY = KEYCODE("F7")        THEN
                DO: 
                    RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                  OUTPUT aux_nrdconta).

                    IF  aux_nrdconta > 0   THEN
                        DO:
                            ASSIGN pro_nrctaav2 = aux_nrdconta.
                            DISPLAY pro_nrctaav2 WITH FRAME f_promissoria2.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */


        IF   pro_nrctaav2 <> 0 THEN
             DO:
                 RUN Valida_Avalista 
                             (INPUT pro_nrctaav1, /* Conta 1. Tit*/
                              INPUT pro_cpfcgc1,  /* CPF 1. Tit*/
                              INPUT 2, /* 2. Avalista */
                              INPUT pro_nrctaav2, /* Conta*/
                              INPUT pro_nmdaval2, /* Nome */
                              INPUT pro_cpfcgc2,  /* CPF */
                              INPUT pro_cpfccg2,  /* CPF conjuge */
                              INPUT pro_dsendav2[1], /* Endereco */
                              INPUT pro_cdufresd2, /* UF */
                              INPUT pro_nrcepend2, /* CEP */
                              INPUT pro_inpessoa2, /* Tipo Pessoa */ 
                              INPUT pro_dtnascto2). /* Data de Nascimento */
            
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

    IF  pro_nrctaav2 = 0  THEN /* Conta nao prenchida */
        DO:

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE pro_inpessoa2
                       pro_cpfcgc2
                       pro_nmdaval2  
                       pro_dtnascto2
                       pro_tpdocav2
                       pro_dscpfav2
                       pro_nmcjgav2   
                       pro_cpfccg2
                       pro_tpdoccj2
                       pro_dscfcav2
                       pro_nrcepend2
                       pro_nrendere2
                       pro_complend2 
                       pro_nrcxapst2 
                       pro_nrfonres2 
                       pro_dsdemail2 
                       WITH FRAME f_promissoria2

                EDITING:

                    READKEY.

                    ON LEAVE, RETURN OF pro_inpessoa2 IN FRAME f_promissoria2 DO:

                       ASSIGN INPUT pro_inpessoa2.
                      
                       IF pro_inpessoa2 = 1   THEN
                          pro_dspessoa2 = "FISICA".
                       ELSE
                          IF pro_inpessoa2 = 2   THEN
                             pro_dspessoa2 = "JURIDICA".
                          ELSE
                             pro_dspessoa2 = "".
                    
                       DISPLAY pro_dspessoa2 WITH FRAME f_promissoria2.
                    
                    END.
                    
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        DO:
                            APPLY "RECALL".
                            LEAVE.
                        END.

                    IF  FRAME-FIELD = "pro_nrcepend2" THEN
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
                   
                                            ASSIGN pro_nrcepend2   = 
                                                        tt-endereco.nrcepend
                                                   pro_dsendav2[1] = 
                                                        tt-endereco.dsendere
                                                   pro_dsendav2[2] = 
                                                        tt-endereco.nmbairro
                                                   pro_nmcidade2   = 
                                                        tt-endereco.nmcidade
                                                   pro_cdufresd2   = 
                                                        tt-endereco.cdufende.
                                                                             
                                            DISPLAY pro_nrcepend2      
                                                    pro_dsendav2[1]
                                                    pro_dsendav2[2]
                                                    pro_nmcidade2  
                                                    pro_cdufresd2  
                                                    WITH FRAME f_promissoria2.
                   
                                            IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN 
                                                NEXT-PROMPT pro_nrendere2 
                                                     WITH FRAME f_promissoria2.
                                        END.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                    IF  FRAME-FIELD = "pro_cpfcgc2"   THEN
                        DO:
                            IF (LASTKEY = KEYCODE("RETURN")       OR
                                LASTKEY = KEYCODE("F1")           OR
                                LASTKEY = KEYCODE("BACK-TAB")     OR
                                LASTKEY = KEYCODE("CURSOR-DOWN")  OR
                                LASTKEY = KEYCODE("CURSOR-LEFT")  OR
                                LASTKEY = KEYCODE("CURSOR-RIGHT") OR                   
                                LASTKEY = KEYCODE("CURSOR-UP"))  AND
                                INPUT pro_cpfcgc2 > 0            AND
                                INPUT pro_nrctaav2 = 0           AND
                                pro_cpfcgc2 <> INPUT pro_cpfcgc2 THEN
                                DO:
                                    RUN Busca_Avalista ( INPUT 2,  /* nrindice */ 
                                                         INPUT 0,  /*_nrctaav1 */ 
                                                         INPUT INPUT pro_cpfcgc2). 

                                    APPLY LASTKEY.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE  
                        APPLY LASTKEY.
                    
                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN pro_nrctaav2  
                                   pro_nmdaval2   
                                   pro_cpfcgc2    
                                   pro_cpfccg2   
                                   pro_dsendav2[1]
                                   pro_nrcepend2
                                   pro_inpessoa2
                                   pro_dtnascto2.
            
                            RUN Valida_Avalista 
                                 (INPUT pro_nrctaav1, /* Conta 1. Tit*/
                                  INPUT pro_cpfcgc1,  /* CPF 1. Tit*/
                                  INPUT 2, /* 2. Avalista */
                                  INPUT pro_nrctaav2, /* Conta*/
                                  INPUT pro_nmdaval2, /* Nome */
                                  INPUT pro_cpfcgc2,  /* CPF */
                                  INPUT pro_cpfccg2,  /* CPF conjuge */
                                  INPUT pro_dsendav2[1], /* Endereco */
                                  INPUT pro_cdufresd2, /* UF */
                                  INPUT pro_nrcepend2, /* CEP */
                                  INPUT pro_inpessoa2, /* Tipo Pessoa */ 
                                  INPUT pro_dtnascto2). /* Data de Nascimento */
            
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


    IF  pro_nrctaav1     = 0 AND
        pro_nmdaval1     = " " THEN
        ASSIGN
              pro_cpfcgc1      = 0
              pro_tpdocav1     = " " 
              pro_dscpfav1     = " "
              pro_nmcjgav1     = " "
              pro_cpfccg1      = 0
              pro_tpdoccj1     = " " 
              pro_dscfcav1     = " "
              pro_dsendav1[1]  = " "
              pro_dsendav1[2]  = " "
              pro_nrfonres1    = " "
              pro_dsdemail1    = " "
              pro_nmcidade1    = " "
              pro_cdufresd1    = " "
              pro_nrcepend1    = 0
              pro_nrendere1    = 0
              pro_complend1    = " "
              pro_nrcxapst1    = 0
              pro_inpessoa1    = 0
              pro_dtnascto1    = ?
              pro_dspessoa1    = " ".
               
    IF  pro_nrctaav2       = 0 AND
        pro_nmdaval2       = " " THEN
        ASSIGN
              pro_nmdaval2     = " " 
              pro_cpfcgc2      = 0
              pro_tpdocav2     = " "
              pro_dscpfav2     = " "
              pro_nmcjgav2     = " "
              pro_cpfccg2      = 0
              pro_tpdoccj2     = " " 
              pro_dscfcav2     = " "
              pro_dsendav2[1]  = " "
              pro_dsendav2[2]  = " "
              pro_nrfonres2    = " "
              pro_dsdemail2    = " "
              pro_nmcidade2    = " "
              pro_cdufresd2    = " "
              pro_nrcepend2    = 0
              pro_nrendere2    = 0
              pro_complend2    = " "
              pro_nrcxapst2    = 0
              pro_inpessoa2    = 0
              pro_dtnascto2    = ?
              pro_dspessoa2    = " ".
   
    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */


/* .......................................................................... */
/* ........................... PROCEDURE INTERNAS ........................... */

PROCEDURE Valida_Conta:
    
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0126) THEN
        RUN sistema/generico/procedures/b1wgen0126.p
            PERSISTENT SET h-b1wgen0126.

    RUN Valida_Conta IN h-b1wgen0126
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT par_nrdconta,
          INPUT TRUE, /* flgerlog */
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0126)  THEN
        DELETE PROCEDURE h-b1wgen0126.

    /* mostra a critica */
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
             PAUSE.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */


PROCEDURE Busca_Avalista:
    
    DEF  INPUT PARAM par_nrindice AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0126) THEN
        RUN sistema/generico/procedures/b1wgen0126.p
            PERSISTENT SET h-b1wgen0126.

    RUN Busca_Avalista IN h-b1wgen0126
        ( INPUT glb_cdcooper,
          INPUT par_nrdconta,
          INPUT par_nrcpfcgc,
         OUTPUT TABLE tt-avalista).

    IF  VALID-HANDLE(h-b1wgen0126)  THEN
        DELETE PROCEDURE h-b1wgen0126.

    /* mostra a critica */
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
             PAUSE.
                   
            RETURN "NOK".  
        END.
    ELSE
        DO:
            FIND FIRST tt-avalista NO-ERROR.

            IF  AVAIL tt-avalista THEN
                DO:

                    CASE par_nrindice:
                        WHEN 1 THEN
                            DO:
                                
                                ASSIGN  pro_nrctaav1    = tt-avalista.nrctaava 
                                        pro_nmdaval1    = tt-avalista.nmdavali
                                        pro_dsendav1[1] = tt-avalista.dsendava[1]
                                        pro_nmcjgav1    = tt-avalista.nmcjgava
                                        pro_nmcidade1   = tt-avalista.nmcidade
                                        pro_nrcepend1   = tt-avalista.nrcepend
                                        pro_nrcxapst1   = tt-avalista.nrcxapst
                                        pro_dscpfav1    = tt-avalista.dscpfava 
                                        pro_dsendav1[2] = tt-avalista.dsendava[2] 
                                        pro_dscfcav1    = tt-avalista.dscfcava
                                        pro_cdufresd1   = tt-avalista.cdufende
                                        pro_nrendere1   = tt-avalista.nrendere
                                        pro_complend1   = tt-avalista.complend
    
                                        pro_cpfcgc1     = tt-avalista.nrcpfcgc   
                                        pro_tpdocav1    = tt-avalista.tpdocava
                                        pro_cpfccg1     = tt-avalista.nrcpfcjg
                                        pro_tpdoccj1    = tt-avalista.tpdoccjg
                                        pro_nrfonres1   = tt-avalista.nrfonres
                                        pro_dsdemail1   = tt-avalista.dsdemail

                                        pro_inpessoa1   = tt-avalista.inpessoa
                                        pro_dtnascto1   = tt-avalista.dtnascto.

                                 
                                 IF pro_inpessoa1 = 1   THEN
                                   pro_dspessoa1 = "FISICA".
                                 ELSE
                                   IF pro_inpessoa1 = 2   THEN
                                     pro_dspessoa1 = "JURIDICA".
                                   ELSE
                                     pro_dspessoa1 = "".
    
                                 DISPLAY pro_dsendav1[1]
                                         pro_dsendav1[2]
                                         pro_nmcidade1
                                         pro_cdufresd1
                                         pro_nrctaav1   
                                         pro_nmdaval1  
                                         pro_cpfcgc1
                                         pro_tpdocav1
                                         pro_dscpfav1
                                         pro_nmcjgav1 
                                         pro_cpfccg1
                                         pro_tpdoccj1
                                         pro_dscfcav1
                                         pro_nrcepend1
                                         pro_nrendere1
                                         pro_complend1
                                         pro_nrcxapst1
                                         pro_nrfonres1
                                         pro_dsdemail1
                                         pro_inpessoa1
                                         pro_dtnascto1
                                         pro_dspessoa1
                                         WITH FRAME f_promissoria1.
                            END.

                        WHEN 2 THEN
                            DO:

                                ASSIGN pro_nrctaav2    = tt-avalista.nrctaava 
                                       pro_nmdaval2    = tt-avalista.nmdavali
                                       pro_dsendav2[1] = tt-avalista.dsendava[1]
                                       pro_nmcjgav2    = tt-avalista.nmcjgava
                                       pro_nmcidade2   = tt-avalista.nmcidade
                                       pro_nrcepend2   = tt-avalista.nrcepend
                                       pro_nrcxapst2   = tt-avalista.nrcxapst
                                       pro_dscpfav2    = tt-avalista.dscpfava 
                                       pro_dsendav2[2] = tt-avalista.dsendava[2] 
                                       pro_dscfcav2    = tt-avalista.dscfcava
                                       pro_cdufresd2   = tt-avalista.cdufende
                                       pro_nrendere2   = tt-avalista.nrendere
                                       pro_complend2   = tt-avalista.complend
    
                                       pro_cpfcgc2     = tt-avalista.nrcpfcgc   
                                       pro_tpdocav2    = tt-avalista.tpdocava
                                       pro_cpfccg2     = tt-avalista.nrcpfcjg
                                       pro_tpdoccj2    = tt-avalista.tpdoccjg
                                       pro_nrfonres2   = tt-avalista.nrfonres
                                       pro_dsdemail2   = tt-avalista.dsdemail
                                       
                                       pro_inpessoa2   = tt-avalista.inpessoa 
                                       pro_dtnascto2   = tt-avalista.dtnascto.

                                IF pro_inpessoa2 = 1   THEN
                                  pro_dspessoa2 = "FISICA".
                                ELSE
                                  IF pro_inpessoa2 = 2   THEN
                                    pro_dspessoa2 = "JURIDICA".
                                  ELSE
                                    pro_dspessoa2 = "".  
    
                                DISPLAY pro_dsendav2[1]
                                        pro_dsendav2[2]
                                        pro_nmcidade2
                                        pro_cdufresd2
                                        pro_nrctaav2   
                                        pro_nmdaval2  
                                        pro_cpfcgc2
                                        pro_tpdocav2
                                        pro_dscpfav2
                                        pro_nmcjgav2 
                                        pro_cpfccg2
                                        pro_tpdoccj2
                                        pro_dscfcav2
                                        pro_nrcepend2
                                        pro_nrendere2
                                        pro_complend2
                                        pro_nrcxapst2
                                        pro_nrfonres2
                                        pro_dsdemail2
                                        pro_inpessoa2
                                        pro_dtnascto2
                                        pro_dspessoa2
                                        WITH FRAME f_promissoria2.
                            END.

                    END CASE.

                END. /* IF  AVAIL tt-avalista THEN */

        END. /* DO */


    RETURN "OK".

END PROCEDURE. /* Busca_Avalista */


PROCEDURE Valida_Avalista:
    
    DEF INPUT PARAM par_nrdcontx AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_idavalis AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrctaava AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nmdavali AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nrcpfava AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_nrcpfcjg AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_dsendere AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_cdufresd AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nrcepend AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtnascto AS DATE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    IF  NOT VALID-HANDLE(h-b1wgen0126) THEN
        RUN sistema/generico/procedures/b1wgen0126.p
            PERSISTENT SET h-b1wgen0126.

    RUN Valida_Avalista IN h-b1wgen0126 
                       (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT glb_cdoperad,
                        INPUT glb_nmdatela,
                        INPUT 1, /* idorigem */
                        INPUT glb_dtmvtolt,
                        INPUT tel_nrdconta,
                        INPUT par_nrdcontx, 
                        INPUT par_nrcpfcgc, 
                        INPUT par_idavalis, 
                        INPUT par_nrctaava, 
                        INPUT par_nmdavali,
                        INPUT par_nrcpfava,
                        INPUT par_nrcpfcjg,
                        INPUT par_dsendere,
                        INPUT par_cdufresd,
                        INPUT par_nrcepend,
                        INPUT TRUE, /* flgerlog*/
                        INPUT par_inpessoa,
                        INPUT par_dtnascto,
                       OUTPUT par_nmdcampo,
                       OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0126)  THEN
        DELETE PROCEDURE h-b1wgen0126.
    
    IF   RETURN-VALUE <> "OK"   THEN
         DO: 
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF    AVAIL tt-erro   THEN
                   MESSAGE tt-erro.dscritic.
                
             RETURN "NOK".
         END.
  
    RETURN "OK".

END PROCEDURE. /* Valida_Avalista */


PROCEDURE Limpa_Endereco:
    
    DEF INPUT PARAM aux_tpform AS INTE                               NO-UNDO.

    IF  aux_tpform = 1 THEN
        DO:
            ASSIGN pro_nrcepend1   = 0  
                   pro_dsendav1[1] = ""  
                   pro_dsendav1[2] = "" 
                   pro_nmcidade1   = ""  
                   pro_cdufresd1   = ""
                   pro_nrendere1   = 0
                   pro_complend1   = ""
                   pro_nrcxapst1   = 0.
        
            DISPLAY pro_nrcepend1  
                    pro_dsendav1[1]
                    pro_dsendav1[2]
                    pro_nmcidade1   
                    pro_cdufresd1  
                    pro_nrendere1  
                    pro_complend1  
                    pro_nrcxapst1 WITH FRAME f_promissoria1.
    END.
    ELSE
    IF  aux_tpform = 2 THEN
        DO:
            ASSIGN pro_nrcepend2   = 0  
                   pro_dsendav2[1] = ""  
                   pro_dsendav2[2] = "" 
                   pro_nmcidade2   = ""  
                   pro_cdufresd2   = ""
                   pro_nrendere2   = 0
                   pro_complend2   = ""
                   pro_nrcxapst2   = 0.
        
            DISPLAY pro_nrcepend2  
                    pro_dsendav2[1]
                    pro_dsendav2[2]
                    pro_nmcidade2   
                    pro_cdufresd2  
                    pro_nrendere2  
                    pro_complend2  
                    pro_nrcxapst2 WITH FRAME f_promissoria2.
        END.

END PROCEDURE. /* Limpa_Endereco */

/* .......................................................................... */
