/* ............................................................................

   Programa: fontes/limite_inp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2001.                         Ultima atualizacao: 14/10/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratamento dos dados para emissao de NOTA PROMISSORIA
               para inclusao de um novo LIMITE DE CREDITO.

   Alteracoes: 10/01/2003 - Maioridade de 21 para 18 anos (Deborah).

               08/09/2003 - Tratamento para Revisao Cadastral de Fiadores
                            (Julio).

               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               23/06/2006 - Concertada clausula OR no EDITING dos campos
                            lim_cpfcgc1 e lim_cpfcgc2 (Diego).
                            
               23/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).

               25/07/2006 - Incluido opcao "CH" no help e validate dos campos
                            tpdoc... (David).
                            
               12/09/2006 - Excluidas opcoes "TAB" (Diego).

               01/10/2007 - Conversao de rotina ver_cadastro para BO
                            (Sidnei/Precise)
                            
               02/06/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder
                            
               07/10/2010 - Incluir parametro de campo com erro na procedure
                            que valida os avalistas (Gabriel).      
                            
               11/01/2011 - Passar como parametro a conta para validacao
                            dos avalistas (Gabriel).
                                           
               15/04/2011 - Alteração para exibir avalistas separadamente
                            devido a CEP integrado. Incluidos campos nrendere,
                            complend e nrcxapst. (André - DB1)  
                            
               03/05/2011 - Bloqueio de campos ao sair de campo conta do
                            avalista. Alteração na chamada da busca do avalista.
                            (André - DB1)     
                            
               13/07/2011 - Realizar a validacao dos avalisas atraves da 
                            B1wgen0024 (Gabriel)               
               
               21/12/2011 - Corrigido warnings (Tiago).
               
               16/10/2012 - Correção descritivo Help campo documento
                            conjuge (Daniel).
                            
               14/10/2014 - Validacoes avalistas. Projeto consultas 
                            automatizadas (Jonata-RKAM).             
                           
............................................................................ */
{ includes/var_limite.i}
{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }

DEF            VAR h_b1wgen0028   AS HANDLE                         NO-UNDO.
DEF            VAR h_b1wgen0024   AS HANDLE                         NO-UNDO.
DEF            VAR l_ok           AS LOGI                           NO-UNDO.
DEF            VAR aux_nmdcampo   AS CHAR                           NO-UNDO.

FORM SKIP(1)         
     "Conta:"         AT  6
     lim_nrctaav1     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do primeiro avalista/fiador"
     SKIP(1)
     "Nome:"          AT  7 
     lim_nmdaval1     FORMAT "x(40)"
                      HELP "Entre com o nome do primeiro avalista/fiador."
     "C.P.F.:"        
     lim_cpfcgc1      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do primeiro avalista"
     "Documento:"     AT  2
     lim_tpdocav1     VALIDATE (lim_tpdocav1 = " "  OR
                                lim_tpdocav1 = "CH" OR
                                lim_tpdocav1 = "CP" OR
                                lim_tpdocav1 = "CI" OR              
                                lim_tpdocav1 = "CT" OR
                                lim_tpdocav1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscpfav1     FORMAT "x(40)"
                      HELP "Entre com o Docto do primeiro avalista/fiador."
     SKIP(1)
     "Conjuge:"       AT  4 
     lim_nmdcjav1     FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do primeiro aval." 
     "C.P.F.:"        
     lim_cpfccg1      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do conjuge do primeiro aval."
     "Documento:"     AT  2
     lim_tpdoccj1     VALIDATE (lim_tpdoccj1 = " "  OR
                                lim_tpdoccj1 = "CH" OR
                                lim_tpdoccj1 = "CP" OR
                                lim_tpdoccj1 = "CI" OR              
                                lim_tpdoccj1 = "CT" OR
                                lim_tpdoccj1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscfcav1     FORMAT "x(40)"
                      HELP "Entre com o Docto do conjuge do primeiro aval."

     SKIP(1)
     "CEP:"           AT 05
     lim_nrcepend1    FORMAT "99999,999"
                      HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "Endereco:"      AT  23
     lim_dsendav1[1]  FORMAT "x(40)"
                      HELP "Entre com o endereco."
     SKIP
     "Nro.:"          AT 04
     lim_nrendere1    FORMAT "zzz,zz9"
                      HELP "Entre com o numero do endereco"
     "Complemento:"   AT 23
     lim_complend1    FORMAT "X(40)"
                      HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"        AT 02
     lim_dsendav1[2]  FORMAT "x(40)"
                      HELP "Entre com o bairro"
     "Caixa Postal:"  AT 56
     lim_nrcxapst1    FORMAT "zz,zz9"  
                      HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"        AT 02
     lim_nmcidade1    FORMAT "x(25)"
                      HELP "Entre com o nome da cidade"
     "UF:"            AT 40
     lim_cdufresd1    HELP "Entre com a UF"
     "Fone:"          AT 50 
     lim_nrfonres1    FORMAT "x(20)"
                      HELP "Entre com o telefone do primeiro avalista"
     "E-mail:"        AT 2
     lim_dsdemail1    FORMAT "x(32)" 
                      HELP "Entre com o email do primeiro avalista/fiador"
     SKIP(1)
            WITH ROW 5 WIDTH 78 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
                " Dados dos Avalistas/Fiadores (1) " FRAME f_promissoria1.
    
FORM SKIP(1)         
     "Conta:"         AT  6
     lim_nrctaav2     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do segundo avalista/fiador"
     SKIP(1)
     "Nome:"          AT 7 
     lim_nmdaval2     FORMAT "x(40)"
                      HELP "Entre com o nome do segundo avalista/fiador."
     "C.P.F.:"        
     lim_cpfcgc2      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do segundo avalista"
     "Documento:"     AT  2
     lim_tpdocav2     VALIDATE (lim_tpdocav1 = " "  OR
                                lim_tpdocav1 = "CH" OR
                                lim_tpdocav1 = "CP" OR
                                lim_tpdocav1 = "CI" OR              
                                lim_tpdocav1 = "CT" OR
                                lim_tpdocav1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscpfav2     FORMAT "x(40)"
                      HELP "Entre com o Docto do segundo avalista/fiador."
     SKIP(1)
     "Conjuge:"       AT  4 
     lim_nmdcjav2     FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do primeiro aval." 
     "C.P.F.:"        
     lim_cpfccg2      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do conjuge do primeiro aval."
     "Documento:"     AT  2
     lim_tpdoccj2     VALIDATE (lim_tpdoccj1 = " "  OR
                                lim_tpdoccj1 = "CH" OR
                                lim_tpdoccj1 = "CP" OR
                                lim_tpdoccj1 = "CI" OR              
                                lim_tpdoccj1 = "CT" OR
                                lim_tpdoccj1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscfcav2     FORMAT "x(40)"
                      HELP "Entre com o Docto do conjuge do primeiro aval."

     SKIP(1)
     "CEP:"           AT 05
     lim_nrcepend2    FORMAT "99999,999"
                      HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "Endereco:"      AT  23
     lim_dsendav2[1]  FORMAT "x(40)"
                      HELP "Entre com o endereco."
     SKIP
     "Nro.:"          AT 04
     lim_nrendere2    FORMAT "zzz,zz9"
                      HELP "Entre com o numero do endereco"
     "Complemento:"   AT 23
     lim_complend2    FORMAT "X(40)"
                      HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"        AT 02
     lim_dsendav2[2]  FORMAT "x(30)"
                      HELP "Entre com o bairro"
     "Caixa Postal:"  AT 56
     lim_nrcxapst2    FORMAT "zz,zz9"  
                      HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"        AT 02
     lim_nmcidade2    FORMAT "x(15)"
                      HELP "Entre com o nome da cidade"
     "UF:"            AT 40
     lim_cdufresd2    HELP "Entre com a UF"
     "Fone:"          AT 50 
     lim_nrfonres2    FORMAT "x(20)"
                      HELP "Entre com o telefone do segundo avalista"
     "E-mail:"        AT 2
     lim_dsdemail2    FORMAT "x(32)" 
                      HELP "Entre com o email do segundo avalista/fiador"
     SKIP(1)
            WITH ROW 5 WIDTH 78 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
                " Dados dos Avalistas/Fiadores (2) " FRAME f_promissoria2.


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
                    ASSIGN lim_nrcepend1   = tt-endereco.nrcepend 
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

    NEXT-PROMPT lim_nrfonres1 WITH FRAME f_promissoria1.
END.

/* Inclusão de CEP integrado. (André - DB1) */
ON RETURN OF lim_nrcepend2 IN FRAME f_promissoria2 DO:

    ASSIGN INPUT lim_nrcepend2.

    IF  lim_nrcepend2 <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT lim_nrcepend2,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN lim_nrcepend2   = tt-endereco.nrcepend 
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

    NEXT-PROMPT lim_nrfonres2 WITH FRAME f_promissoria2.
END.

ON GO, RETURN OF lim_nrctaav1 DO:

    ASSIGN glb_nrcalcul = INPUT lim_nrctaav1
           glb_cdcritic = 0.

    IF  INPUT lim_nrctaav1 <> 0  THEN
        DO:
  
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
    END.
  
    HIDE MESSAGE NO-PAUSE.
  
    /* Busca dados do Avalista informado */
    RUN piBuscaDadosAvalista 
                    (INPUT  1,
                     INPUT  INPUT lim_nrctaav1,
                     INPUT  ?).

    IF  RETURN-VALUE = "NOK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF   AVAIL tt-erro THEN
                 DO:
                     MESSAGE tt-erro.dscritic.
                     RETURN NO-APPLY.
                 END.
        END.
END. 

ON GO, RETURN OF lim_nrctaav2 DO:
    ASSIGN glb_nrcalcul = INPUT lim_nrctaav2
           glb_cdcritic = 0.

    IF  INPUT lim_nrctaav2 <> 0  THEN
        DO:

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
        END.
             
    HIDE MESSAGE NO-PAUSE.

    /***** Busca dados do Avalista informado *****/
    RUN piBuscaDadosAvalista 
                         (INPUT  2,
                          INPUT  INPUT lim_nrctaav2,
                          INPUT  ?).

    IF  RETURN-VALUE = "NOK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN NO-APPLY.
                END.
        END.
   
END. 

                
ASSIGN l_ok = FALSE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

    DISPLAY lim_nrctaav1   lim_dsendav1   lim_nmcidade1   lim_cdufresd1
            lim_nrctaav1   lim_nmdaval1    lim_cpfcgc1      lim_tpdocav1
            lim_dscpfav1   lim_nmdcjav1    lim_cpfccg1      lim_tpdoccj1
            lim_dscfcav1   lim_nrcepend1   lim_nrendere1    lim_complend1
            lim_nrcxapst1  lim_nrfonres1   lim_dsdemail1     
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
    
                UPDATE lim_nmdaval1   lim_cpfcgc1       
                       lim_tpdocav1   lim_dscpfav1      lim_nmdcjav1      
                       lim_cpfccg1    lim_tpdoccj1      lim_dscfcav1      
                       lim_nrcepend1  lim_nrendere1     lim_complend1      
                       lim_nrcxapst1  lim_nrfonres1     lim_dsdemail1      
                       WITH FRAME f_promissoria1

                EDITING:
            
                    READKEY.
            
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        LEAVE.
            
                    IF  FRAME-FIELD = "lim_nrcepend1" THEN 
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
                    /*---- Buscar dados do Avalista pelo CPF/CNPJ ---*/
                    IF  FRAME-FIELD = "lim_cpfcgc1"   THEN
                        DO:

                            IF (LASTKEY = KEYCODE("RETURN")        OR
                                LASTKEY = KEYCODE("F1")            OR
                                LASTKEY = KEYCODE("BACK-TAB")      OR
                                LASTKEY = KEYCODE("CURSOR-DOWN")   OR
                                LASTKEY = KEYCODE("CURSOR-LEFT")   OR
                                LASTKEY = KEYCODE("CURSOR-RIGHT")  OR           
                                LASTKEY = KEYCODE("CURSOR-UP"))    AND
                                INPUT lim_cpfcgc1  > 0             AND
                                INPUT lim_nrctaav1 = 0             AND
                               (glb_cddopcao = "I"  OR  
                                glb_cddopcao = "N")                THEN
                                DO:
                                    /* Busca dados do Avalista informado */
                                    RUN piBuscaDadosAvalista 
                                                   (INPUT  1,
                                                    INPUT  0,
                                                    INPUT  INPUT lim_cpfcgc1).
                                                          
                                    IF  RETURN-VALUE = "NOK"   THEN
                                        DO:
                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                            IF  AVAIL tt-erro THEN
                                                DO:
                                                    MESSAGE tt-erro.dscritic.
                                                    UNDO.
                                                END.
                                        END.
                                     
                                    APPLY LASTKEY.            
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END. /* FRAME-FIELD = "lim_cpfcgc1" */
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

    HIDE FRAME f_promissoria1 NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR INPUT lim_nmdaval1 = "" THEN
        LEAVE.

    DISPLAY lim_nrctaav2  lim_dsendav2   lim_nmcidade2   lim_cdufresd2  
            lim_nrctaav2  lim_nmdaval2   lim_cpfcgc2       
            lim_tpdocav2  lim_dscpfav2   lim_nmdcjav2    lim_cpfccg2       
            lim_tpdoccj2  lim_dscfcav2   lim_nrcepend2   lim_nrendere2     
            lim_complend2 lim_nrcxapst2  lim_nrfonres2   lim_dsdemail2
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

                UPDATE lim_nmdaval2   lim_cpfcgc2     
                       lim_tpdocav2   lim_dscpfav2    lim_nmdcjav2      
                       lim_cpfccg2    lim_tpdoccj2    lim_dscfcav2   
                       lim_nrcepend2  lim_nrendere2   lim_complend2
                       lim_nrcxapst2  lim_nrfonres2   lim_dsdemail2     
                       WITH FRAME f_promissoria2
                EDITING:
   
                    READKEY.
        
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        LEAVE.
           
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
                    /*---- Buscar dados do Avalista pelo CPF/CNPJ ---*/
                    IF  FRAME-FIELD = "lim_cpfcgc2"   THEN
                        DO:
                            IF (LASTKEY = KEYCODE("RETURN")        OR
                                LASTKEY = KEYCODE("F1")            OR
                                LASTKEY = KEYCODE("BACK-TAB")      OR
                                LASTKEY = KEYCODE("CURSOR-DOWN")   OR
                                LASTKEY = KEYCODE("CURSOR-LEFT")   OR
                                LASTKEY = KEYCODE("CURSOR-RIGHT")  OR    
                                LASTKEY = KEYCODE("CURSOR-UP"))    AND
                                INPUT lim_cpfcgc2  > 0             AND
                                INPUT lim_nrctaav2 = 0             AND
                               (glb_cddopcao = "I"  OR
                                glb_cddopcao = "N")                THEN
                                DO:
                                    /* Busca dados do Avalista informado */
                                    RUN piBuscaDadosAvalista 
                                                 (INPUT  2,
                                                  INPUT  0,
                                                  INPUT  INPUT lim_cpfcgc2).
                                                          
                                    IF  RETURN-VALUE = "NOK"   THEN
                                        DO:                         
                                            FIND FIRST tt-erro 
                                                 NO-LOCK NO-ERROR.
                                            IF  AVAIL tt-erro THEN
                                                DO:
                                                    MESSAGE tt-erro.dscritic.
                                                    UNDO.
                                                END.
                                        END.                          
                                    APPLY LASTKEY.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END. /* FRAME-FIELD = "lim_cpfcgc2" */
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

    
    /***** Se avalistas nao informados, zera valores das variaveis *****/
    IF  lim_nrctaav1 = 0     AND
        lim_nmdaval1 = " "   THEN
        DO:
        ASSIGN lim_cpfcgc1     = 0
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
               lim_complend1   = ""
               lim_nrcxapst1   = 0.

        END.
       
    IF  lim_nrctaav2 = 0     AND
        lim_nmdaval2 = " "   THEN
    DO:
        ASSIGN lim_nmdaval2    = " " 
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
               lim_complend2   = ""
               lim_nrcxapst2   = 0.
    END.

    ASSIGN l_ok = TRUE.                                
    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_promissoria1 NO-PAUSE.
HIDE FRAME f_promissoria2 NO-PAUSE.

IF   l_ok = TRUE   THEN
     RETURN "OK".
ELSE
     RETURN "NOK".


PROCEDURE piBuscaDadosAvalista:
    /***************************************************************
       Objetivo..: Mostrar dados de um avalista a partir da conta ou 
                   CPF informados
       Parametros: --- Entrada ---
                   par_indicava: Indicador do avalista (1 ou 2)
                   par_nrctaava: Conta do avalista
                   par_nrcpfava: CPF do avalista
    ***************************************************************/
    DEF INPUT  PARAM par_indicava AS INTE   NO-UNDO.
    DEF INPUT  PARAM par_nrctaava AS INTE   NO-UNDO.
    DEF INPUT  PARAM par_nrcpfava AS DECI   NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    RUN carrega_avalista IN h_b1wgen0028
                              ( INPUT  glb_cdcooper,
                                INPUT  0,
                                INPUT  0,
                                INPUT  glb_cdoperad,
                                INPUT  glb_nmdatela,
                                INPUT  1,
                                INPUT  tel_nrdconta,
                                INPUT  1,
                                INPUT  glb_dtmvtolt,
                                INPUT  par_nrctaava,
                                INPUT  par_nrcpfava,
                                INPUT  YES,
                                OUTPUT TABLE tt-dados-avais,
                                OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h_b1wgen0028.
                                
    IF  CAN-FIND(FIRST tt-erro)   THEN
        RETURN "NOK".
                               
    FIND tt-dados-avais NO-ERROR.
    IF  AVAIL tt-dados-avais THEN 
        DO:
            IF  par_indicava = 1   THEN /* Primeiro Avalista */
                DO:
                    ASSIGN lim_nmdaval1    = tt-dados-avais.nmdavali
                           lim_cpfcgc1     = tt-dados-avais.nrcpfcgc
                           lim_tpdocav1    = tt-dados-avais.tpdocava
                           lim_dscpfav1    = tt-dados-avais.nrdocava
                           lim_nmdcjav1    = tt-dados-avais.nmconjug
                           lim_cpfccg1     = tt-dados-avais.nrcpfcjg
                           lim_tpdoccj1    = tt-dados-avais.tpdoccjg
                           lim_dscfcav1    = tt-dados-avais.nrdoccjg
                           lim_dsendav1[1] = tt-dados-avais.dsendre1
                           lim_dsendav1[2] = tt-dados-avais.dsendre2
                           lim_nmcidade1   = tt-dados-avais.nmcidade
                           lim_cdufresd1   = tt-dados-avais.cdufresd
                           lim_nrcepend1   = tt-dados-avais.nrcepend
                           lim_nrendere1   = tt-dados-avais.nrendere
                           lim_complend1   = tt-dados-avais.complend
                           lim_nrcxapst1   = tt-dados-avais.nrcxapst.

                    DISPLAY lim_nmdaval1     lim_cpfcgc1    lim_tpdocav1
                            lim_dscpfav1     lim_nmdcjav1   lim_cpfccg1
                            lim_tpdoccj1     lim_dscfcav1   lim_dsendav1[1]
                            lim_dsendav1[2]  lim_nmcidade1  lim_cdufresd1
                            lim_nrcepend1    lim_nrendere1  lim_complend1 
                            lim_nrcxapst1 
                            WITH FRAME f_promissoria1.
                END.
            ELSE                 
                DO:
                    ASSIGN lim_nmdaval2    = tt-dados-avais.nmdavali
                           lim_cpfcgc2     = tt-dados-avais.nrcpfcgc
                           lim_tpdocav2    = tt-dados-avais.tpdocava
                           lim_dscpfav2    = tt-dados-avais.nrdocava
                           lim_nmdcjav2    = tt-dados-avais.nmconjug
                           lim_cpfccg2     = tt-dados-avais.nrcpfcjg
                           lim_tpdoccj2    = tt-dados-avais.tpdoccjg
                           lim_dscfcav2    = tt-dados-avais.nrdoccjg
                           lim_dsendav2[1] = tt-dados-avais.dsendre1
                           lim_dsendav2[2] = tt-dados-avais.dsendre2
                           lim_nmcidade2   = tt-dados-avais.nmcidade
                           lim_cdufresd2   = tt-dados-avais.cdufresd
                           lim_nrcepend2   = tt-dados-avais.nrcepend
                           lim_nrendere2   = tt-dados-avais.nrendere
                           lim_complend2   = tt-dados-avais.complend
                           lim_nrcxapst2   = tt-dados-avais.nrcxapst.
                           
                    DISPLAY lim_nmdaval2     lim_cpfcgc2    lim_tpdocav2
                            lim_dscpfav2     lim_nmdcjav2   lim_cpfccg2
                            lim_tpdoccj2     lim_dscfcav2   lim_dsendav2[1]
                            lim_dsendav2[2]  lim_nmcidade2  lim_cdufresd2
                            lim_nrcepend2    lim_nrendere2  lim_complend2 
                            lim_nrcxapst2
                            WITH FRAME f_promissoria2.       

                END.
        END. /* IF   AVAIL tt-dados-avais THEN */
         
    RETURN "OK".      
                  
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


    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h_b1wgen0024.

    RUN valida-avalistas IN h_b1wgen0024 
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
                             INPUT 0,
                            OUTPUT aux_nmdcampo,
                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h_b1wgen0024.
    
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

/*....................................................................... */
