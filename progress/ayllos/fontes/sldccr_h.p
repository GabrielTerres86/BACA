/* ........................................................................... 
   
   Programa: Fontes/sldccr_h.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Sandro
   Data    : Ago/2010.                     Ultima atualizacao: 28/07/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para habilitar cartao de credito PJ.
   
   ALteracoes: 26/04/2011 - Inclusões de variaveis de CEP integrado (nrendere,
                            complend e nrcxapst). (André - DB1)
                            
               28/07/2014 - Adicionado parametro de entrada cdagenci e nrdcaixa
                            em chamada da proc. grava_dados_habilitacao.
                            (Jorge/Gielow) SD - 156112             

............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }
{ includes/var_limite.i "NEW"} 

DEF VAR tel_nmprimtl AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_vllimglb AS DECI FORMAT "zzz,zzz,zz9.99"                   NO-UNDO.
DEF VAR tel_flgativo AS LOGI FORMAT "Sim/Nao"                          NO-UNDO.
DEF VAR tel_nrcpfpri AS DECI FORMAT "999,999,999,99"                   NO-UNDO.
DEF VAR tel_nrcpfseg AS DECI FORMAT "999,999,999,99"                   NO-UNDO.
DEF VAR tel_nrcpfter AS DECI FORMAT "999,999,999,99"                   NO-UNDO.
DEF VAR tel_nmpespri AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_nmpesseg AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_nmpester AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_dtnaspri AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR tel_dtnasseg AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR tel_dtnaster AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR aux_flgalter AS LOGI INIT YES                                  NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_bfexiste AS LOGI                                           NO-UNDO.

DEF VAR aux_ulcpfpri AS DECI FORMAT "999,999,999,99"                   NO-UNDO.
DEF VAR aux_ulcpfseg AS DECI FORMAT "999,999,999,99"                   NO-UNDO.
DEF VAR aux_ulcpfter AS DECI FORMAT "999,999,999,99"                   NO-UNDO.

DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtnasctl AS DATE                                           NO-UNDO.

DEF VAR aux_nrctrcrd AS INTE                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR                                           NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

FORM tel_nmprimtl  LABEL "Razao Social"      AT 01
     SKIP(1)
     tel_nrcpfcgc  LABEL "CNPJ        "              AT 01
     SKIP
     tel_flgativo  LABEL "Ativo       "              AT 01
     tel_vllimglb  LABEL "Limite cartao empresarial" AT 33
     SKIP(1)
     tel_nrcpfpri  LABEL "C.P.F.       "             AT 01
     SKIP
     tel_nmpespri  LABEL "Representante"             AT 01
     tel_dtnaspri  LABEL "Nasc."                     AT 57
     SKIP(1)
     tel_nrcpfseg  LABEL "C.P.F.       "             AT 01
     SKIP
     tel_nmpesseg  LABEL "Representante"             AT 01
     tel_dtnasseg  LABEL "Nasc."                     AT 57
     SKIP(1)
     tel_nrcpfter  LABEL "C.P.F.       "             AT 01
     SKIP
     tel_nmpester  LABEL "Representante"             AT 01
     tel_dtnaster  LABEL "Nasc."                     AT 57
     SKIP(1)
     WITH ROW 6 WIDTH 76 SIDE-LABELS OVERLAY TITLE COLOR NORMAL " Habilitar "
               FRAME f_habilita CENTERED.
               
FORM "VERIFICAR ATUALIZACAO CADASTRAL" 
     WITH CENTERED ROW 10 OVERLAY COLOR MESSAGE FRAME f_msg_atualiza.

DEF OUTPUT PARAM par_flgativo AS LOGI NO-UNDO.
DEF OUTPUT PARAM par_nrctrhcj AS INTE NO-UNDO.

/* ON ENTRY OF tel_flgativo DO:                                               */
/*                                                                            */
/*     IF  NOT aux_flgalter THEN                                              */
/*         DO:                                                                */
/* /*             ASSIGN tel_flgativo:SENSITIVE = NO. */                      */
/*                                                                            */
/*             IF  tel_flgativo:SCREEN-VALUE IN FRAME f_habilita = "Nao" THEN */
/*                 ASSIGN tel_vllimglb:SENSITIVE = NO.                        */
/*                                                                            */
/*             RETURN NO-APPLY.                                               */
/*         END.                                                               */
/* END.                                                                       */

ON LEAVE OF tel_flgativo DO:

    IF  tel_flgativo:SCREEN-VALUE IN FRAME f_habilita = "Nao" THEN
        DO:

            ASSIGN tel_vllimglb = 0.
            DISPLAY tel_vllimglb WITH FRAME f_habilita.


            ASSIGN tel_vllimglb:SENSITIVE = NO.

        END.
    ELSE
        DO:

            ASSIGN tel_vllimglb:SENSITIVE = YES.

        END.

END.

ON LEAVE OF tel_dtnaspri DO:

    /* verificando se a data ‚ v lida */        
    ASSIGN aux_dtnasctl = DATE(INPUT FRAME f_habilita tel_dtnaspri) NO-ERROR.

    IF  NOT ERROR-STATUS:ERROR THEN
        ASSIGN INPUT FRAME f_habilita tel_dtnaspri.

END.

ON LEAVE OF tel_dtnasseg DO:

    /* verificando se a data ‚ v lida */
    ASSIGN aux_dtnasctl = DATE(INPUT FRAME f_habilita tel_dtnasseg) NO-ERROR.

    IF  NOT ERROR-STATUS:ERROR THEN
        ASSIGN INPUT FRAME f_habilita tel_dtnasseg.

END.

ON LEAVE OF tel_dtnaster DO:

    /* verificando se a data ‚ v lida */
    ASSIGN aux_dtnasctl = DATE(INPUT FRAME f_habilita tel_dtnaster) NO-ERROR.

    IF  NOT ERROR-STATUS:ERROR THEN
        ASSIGN INPUT FRAME f_habilita tel_dtnaster.

END.

ON LEAVE OF tel_nmpespri DO:

    ASSIGN INPUT FRAME f_habilita tel_nmpespri.

END.

ON LEAVE OF tel_nmpesseg DO:

    ASSIGN INPUT FRAME f_habilita tel_nmpesseg.

END.

ON LEAVE OF tel_nmpester DO:

    ASSIGN INPUT FRAME f_habilita tel_nmpester.

END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN carrega_dados_habilitacao IN h_b1wgen0028
                                    (INPUT glb_cdcooper,
                                     INPUT tel_nrdconta,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-hab_cartao).
        
    DELETE PROCEDURE h_b1wgen0028.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-erro   THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
    
            RETURN "NOK".
         END.
         
    FIND tt-hab_cartao NO-ERROR.
    
    IF  NOT AVAIL tt-hab_cartao  THEN
        RETURN "NOK".

    ASSIGN aux_flgalter = tt-hab_cartao.flgalter.

    ASSIGN tel_nmprimtl = tt-hab_cartao.nmprimtl
           tel_nrcpfcgc = STRING(tt-hab_cartao.nrcpfcgc,"99999999999999")
           tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx")
           tel_vllimglb = tt-hab_cartao.vllimglb
           tel_flgativo = tt-hab_cartao.flgativo
           tel_nrcpfpri = tt-hab_cartao.nrcpfpri
           tel_nmpespri = tt-hab_cartao.nmpespri
           tel_dtnaspri = tt-hab_cartao.dtnaspri
           tel_nrcpfseg = tt-hab_cartao.nrcpfseg
           tel_nmpesseg = tt-hab_cartao.nmpesseg
           tel_dtnasseg = tt-hab_cartao.dtnasseg
           tel_nrcpfter = tt-hab_cartao.nrcpfter
           tel_nmpester = tt-hab_cartao.nmpester
           tel_dtnaster = tt-hab_cartao.dtnaster.

    ASSIGN aux_ulcpfpri = tel_nrcpfpri
           aux_ulcpfseg = tel_nrcpfseg
           aux_ulcpfter = tel_nrcpfter.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        DISPLAY tel_nmprimtl tel_nrcpfcgc WITH FRAME f_habilita.
       
        entrada_dados:
        DO:

            UPDATE tel_flgativo   tel_vllimglb      
                   tel_nrcpfpri   tel_nmpespri   tel_dtnaspri
                   tel_nrcpfseg   tel_nmpesseg   tel_dtnasseg
                   tel_nrcpfter   tel_nmpester   tel_dtnaster
                   WITH FRAME f_habilita
        
            EDITING:

                READKEY.

                IF  FRAME-FIELD = "tel_nrcpfpri"           AND
                    (KEYFUNCTION(LASTKEY) = "RETURN"       OR
                     KEYFUNCTION(LASTKEY) = "BACK-TAB"     OR
                     KEYFUNCTION(LASTKEY) = "GO"           OR
                     KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                     KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  ) THEN
                    DO:

                        IF  INPUT FRAME f_habilita  tel_nrcpfpri = 0 THEN
                            ASSIGN tel_nmpespri:SENSITIVE = NO
                                   tel_dtnaspri:SENSITIVE = NO
                                   tel_nmpespri = ""
                                   tel_dtnaspri = ?.

                        ELSE 
                            DO :

                                IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
                                    RUN sistema/generico/procedures/b1wgen0028.p
                                        PERSISTENT SET h_b1wgen0028.

                                RUN busca_dados_assoc IN h_b1wgen0028
                                          ( INPUT glb_cdcooper,
                                            INPUT FRAME f_habilita tel_nrcpfpri,
                                            INPUT NO,
                                            OUTPUT aux_nmprimtl,
                                            OUTPUT aux_dtnasctl,
                                            OUTPUT aux_bfexiste).

                                IF  aux_bfexiste THEN
                                    ASSIGN tel_nmpespri = aux_nmprimtl
                                           tel_dtnaspri = aux_dtnasctl
                                           tel_nmpespri:SENSITIVE = NO
                                           tel_dtnaspri:SENSITIVE = NO.
                                ELSE
                                    DO:

                                        IF  aux_ulcpfpri <> 
                                            DEC(INPUT FRAME f_habilita tel_nrcpfpri) THEN
                                            DO:
                                
                                                ASSIGN tel_nmpespri = ""
                                                       tel_dtnaspri = ?.

                                            END.

                                        ASSIGN tel_nmpespri:SENSITIVE = YES
                                               tel_dtnaspri:SENSITIVE = YES.

                                    END.
                                    
                                DELETE PROCEDURE h_b1wgen0028.

                        END.

                        DISP tel_nmpespri
                             tel_dtnaspri WITH FRAME f_habilita.

                        ASSIGN aux_ulcpfpri = 
                                     INPUT FRAME f_habilita tel_nrcpfpri.

                    END.

                    IF  FRAME-FIELD = "tel_nrcpfseg"           AND
                        (KEYFUNCTION(LASTKEY) = "RETURN"       OR
                         KEYFUNCTION(LASTKEY) = "BACK-TAB"     OR
                         KEYFUNCTION(LASTKEY) = "GO"           OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  ) THEN
                        DO:

                            IF  INPUT FRAME f_habilita tel_nrcpfseg = 0 THEN
                                ASSIGN tel_nmpesseg:SENSITIVE = NO
                                       tel_dtnasseg:SENSITIVE = NO
                                       tel_nmpesseg = ""
                                       tel_dtnasseg = ?.

                            ELSE 
                                DO :

                                    IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
                                        RUN sistema/generico/procedures/b1wgen0028.p
                                            PERSISTENT SET h_b1wgen0028.

                                    RUN busca_dados_assoc IN h_b1wgen0028 
                                          ( INPUT glb_cdcooper,
                                            INPUT FRAME f_habilita tel_nrcpfseg,
                                            INPUT NO,
                                            OUTPUT aux_nmprimtl,
                                            OUTPUT aux_dtnasctl,
                                            OUTPUT aux_bfexiste).

                                    IF  aux_bfexiste THEN
                                        ASSIGN tel_nmpesseg = aux_nmprimtl
                                               tel_dtnasseg = aux_dtnasctl
                                               tel_nmpesseg:SENSITIVE = NO
                                               tel_dtnasseg:SENSITIVE = NO.
                                    ELSE
                                        DO:

                                            IF  aux_ulcpfseg <> 
                                                DEC(INPUT FRAME f_habilita tel_nrcpfseg) THEN
                                                DO:

                                                    ASSIGN tel_nmpesseg = ""
                                                           tel_dtnasseg = ?.

                                                END.

                                            ASSIGN tel_nmpesseg:SENSITIVE = YES
                                                   tel_dtnasseg:SENSITIVE = YES.

                                        END.

                                    DELETE PROCEDURE h_b1wgen0028.

                            END.

                            DISP tel_nmpesseg
                                 tel_dtnasseg WITH FRAME f_habilita.

                            ASSIGN aux_ulcpfseg = 
                                          INPUT FRAME f_habilita tel_nrcpfseg.

                        END.

                        IF  FRAME-FIELD = "tel_nrcpfter"           AND
                            (KEYFUNCTION(LASTKEY) = "RETURN"       OR
                             KEYFUNCTION(LASTKEY) = "BACK-TAB"     OR
                             KEYFUNCTION(LASTKEY) = "GO"           OR
                             KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                             KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  ) THEN
                            DO:

                                IF  INPUT FRAME f_habilita tel_nrcpfter = 0 THEN
                                    ASSIGN tel_nmpester:SENSITIVE = NO
                                           tel_dtnaster:SENSITIVE = NO
                                           tel_nmpester = ""
                                           tel_dtnaster = ?.

                                ELSE 
                                    DO :

                                        IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
                                            RUN sistema/generico/procedures/b1wgen0028.p
                                                PERSISTENT SET h_b1wgen0028.


                                        RUN busca_dados_assoc IN h_b1wgen0028 
                                          ( INPUT glb_cdcooper,
                                            INPUT FRAME f_habilita tel_nrcpfter,
                                            INPUT NO,
                                            OUTPUT aux_nmprimtl,
                                            OUTPUT aux_dtnasctl,
                                            OUTPUT aux_bfexiste).

                                        IF  aux_bfexiste THEN
                                            ASSIGN tel_nmpester = aux_nmprimtl
                                                   tel_dtnaster = aux_dtnasctl
                                                   tel_nmpester:SENSITIVE = NO
                                                   tel_dtnaster:SENSITIVE = NO.
                                        ELSE
                                            DO:

                                                IF  aux_ulcpfter <> 
                                                    DEC(INPUT FRAME f_habilita tel_nrcpfter) THEN
                                                    DO:

                                                        ASSIGN tel_nmpester = ""
                                                               tel_dtnaster = ?.

                                                    END.

                                                ASSIGN tel_nmpester:SENSITIVE = YES
                                                       tel_dtnaster:SENSITIVE = YES.

                                            END.

                                        DELETE PROCEDURE h_b1wgen0028.

                                END.

                                DISP tel_nmpester
                                     tel_dtnaster WITH FRAME f_habilita.

                                ASSIGN aux_ulcpfter = 
                                           INPUT FRAME f_habilita tel_nrcpfter.

                            END.

                APPLY LASTKEY.
                            
            END. /* Fim do EDITING */

        END.
            
        RUN sistema/generico/procedures/b1wgen0028.p 
            PERSISTENT SET h_b1wgen0028.

        RUN valida_habilitacao IN h_b1wgen0028
                                    (INPUT glb_cdcooper,
                                     INPUT tel_nrdconta,
                                     INPUT tel_vllimglb,
                                     INPUT tel_flgativo,
                                     INPUT tel_nrcpfpri,
                                     INPUT tel_nrcpfseg,
                                     INPUT tel_nrcpfter,
                                     INPUT tel_nmpespri,
                                     INPUT tel_nmpesseg,
                                     INPUT tel_nmpester,
                                     INPUT tel_dtnaspri,
                                     INPUT tel_dtnasseg,
                                     INPUT tel_dtnaster,
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
                                       
        LEAVE.

    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_habilita NO-PAUSE.

            IF  tt-hab_cartao.nrctrcrd > 0 THEN
                ASSIGN par_flgativo = tel_flgativo
                       par_nrctrhcj = aux_nrctrcrd.

            RETURN "NOK".
        END.
                
    IF  tt-hab_cartao.nrctrcrd = 0 THEN /* registro novo*/
        ASSIGN lim_nrctaav1    = tt-hab_cartao.nrctaav1
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

               lim_nrctaav2    = tt-hab_cartao.nrctaav2
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

    ELSE 
        DO:
            
            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.
            
            RUN carrega_dados_avais IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT glb_nmdatela,
                              INPUT 1, 
                              INPUT tel_nrdconta,
                              INPUT 1, 
                              INPUT glb_dtmvtolt,
                              INPUT tt-hab_cartao.nrctrcrd,
                             OUTPUT TABLE tt-dados-avais,
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
          
            ASSIGN lim_nmdaval1    = " "
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
                   lim_nrcxapst2   = 0
                   aux_contador    = 1.
       
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

            END. /* Fim do FOR EACH tt-dados-avais */

        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
        RUN fontes/limite_inp.p.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    aux_confirma = "N".

                    BELL.
                    MESSAGE COLOR NORMAL
                            " Deseja cancelar a operacao?"
                            UPDATE aux_confirma.

                    LEAVE.

                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                    aux_confirma = "S"                  THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        glb_cdcritic = 0.

                        BELL.
                        MESSAGE glb_dscritic.

                        HIDE FRAME f_habilita NO-PAUSE.

                        RETURN "NOK".
                    END.
                ELSE
                    NEXT.
            END.

        LEAVE.

    END. /* Fim do DO WHILE TRUE */
    
    /* Confirmacao dos dados */
    RUN fontes/confirma.p (INPUT "",
                           OUTPUT aux_confirma).

    IF   aux_confirma <> "S"   THEN
         DO:

            HIDE FRAME f_habilita NO-PAUSE.
            LEAVE.

         END.
                 
    FIND tt-hab_cartao NO-ERROR.

    ASSIGN tt-hab_cartao.vllimglb = tel_vllimglb
           tt-hab_cartao.flgativo = tel_flgativo
           tt-hab_cartao.nrcpfpri = tel_nrcpfpri
           tt-hab_cartao.nrcpfseg = tel_nrcpfseg
           tt-hab_cartao.nrcpfter = tel_nrcpfter
           tt-hab_cartao.nmpespri = tel_nmpespri
           tt-hab_cartao.dtnaspri = tel_dtnaspri
           tt-hab_cartao.nmpesseg = tel_nmpesseg
           tt-hab_cartao.dtnasseg = tel_dtnasseg
           tt-hab_cartao.nmpester = tel_nmpester
           tt-hab_cartao.dtnaster = tel_dtnaster.
        
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

    RUN grava_dados_habilitacao IN h_b1wgen0028
                                (INPUT glb_cdcooper,
                                 INPUT tel_nrdconta,
                                 INPUT glb_cdoperad,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1,
                                 INPUT glb_cdagenci,
                                 INPUT 1, /* nrdcaixa */
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
                                 OUTPUT aux_nrctrcrd,
                                 INPUT TABLE tt-hab_cartao,
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

    HIDE FRAME f_habilita NO-PAUSE.    

    LEAVE.

END. /* Fim do DO WHILE TRUE */

IF   aux_confirma = "S"   THEN DO:
    RUN fontes/sldccr_ip.p (INPUT aux_nrctrcrd,1).
    RUN fontes/sldccr_ct2.p (INPUT aux_nrctrcrd).
END.

ASSIGN par_flgativo = tel_flgativo
       par_nrctrhcj = aux_nrctrcrd.

RETURN "OK".

/* ......................................................................... */


