/* ............................................................................

   Programa: Fontes/sldccr_2v.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                           Ultima atualizacao: 26/04/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para 2 via de  cartoes de credito.

   Alteracoes: 11/08/98 - Alimentar dtentr2v (Deborah).
    
               12/08/98 - Alterado para levar os dados de cobranca da anuidade
                          pela Credicard para o cartao 2via (Deborah).
                 
               25/08/98 - Criar os novos campos (tpcartao e cdadmcrd) no
                          crapcrd e no crawcrd (Deborah).

               01/09/98 - Novos campos dtnasccr e nrdocccr (Deborah).
               
               08/09/98 - Tratar nova administradora (Odair)

             01/08/2001 - Incluir geracao de nota promissoria (Margarete).

             11/10/2002 - Tratar cartoes reemitidos com nome Viacredi (Deborah)
                          Exigir sempre os dados para nota promissoria (Mag)
             
             18/10/2002 - Permitir alterar a validade do cartao na opcao
                          mudanca de nome (Deborah).
                          
             09/12/2002 - Consistir numero do cartao de credito (Junior).
             
             20/01/2003 - Ajuste na nota promissoria para tratar os 
                          conjuges fiadores (Eduardo).
                          
             24/05/2004 - Retirada a informacao do motivo de 2 via (Julio)
             23/06/2004 - Atualizar tabela avalistas Terceiros(Mirtes)

             17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

             05/07/2005 - Alimentado campo cdcooper das tabelas crawcrd,
                          crapcrd, crapavl crapavt (Diego).

             27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
             
             07/02/2006 - Inclusao de NO-LOCK no FOR EACH da linha 207 - 
                          SQLWorks -  Fernando.

             19/04/2006 - NUMICARTAO pode ter mais de um numero inicial (Julio)
             
             27/03/2007 - Substituido valores de campos de endereco da
                          estrutura crapass pelos valores da crapenc (Elton).
                          
             19/12/2008 - Informar apenas mes e ano na validade(Guilherme).

             17/02/2009 - Logar em log/sldccr.log (Gabriel).
             
             19/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                          (GATI - Eder)
                          
             20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                          (Gati - Daniel)                          
                          
             03/01/2011 - Alterado para solicitar numero completo do cartao
                          novamente na entrega (Diego).
                          
             26/04/2011 - Inclusões de variaveis de CEP integrado (nrendere,
                          complend e nrcxapst). (André - DB1)
                          
............................................................................ */

{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_limite.i "NEW"} 
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.

DEF VAR tel_nrcrcard AS DECI FORMAT "9999,9999,9999,9999"              NO-UNDO.
DEF VAR tel_dtnovval AS CHAR FORMAT "xx/xxxx"                          NO-UNDO.
DEF VAR tel_flgimpnp AS LOGI FORMAT "Imprime/Nao Imprime"              NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.
DEF VAR aux_cdprgctr AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctrcrd AS INTE                                           NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cpfrepre AS DEC EXTENT 3                                   NO-UNDO.
DEF VAR tel_repsolic AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR aux_represen AS CHAR                                           NO-UNDO.
DEF VAR aux_indposi2 AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_tipopess  AS INT                                          NO-UNDO.

FORM SKIP(1)
     tel_nrcrcard  LABEL "Numero do novo cartao"
     HELP "Entre com o numero do novo cartao"      AT 5 "   "
     SKIP(1)
     tel_dtnovval LABEL "Nova validade"  AT 13
     HELP "Entre com a nova validade"
     SKIP(1)
     tel_flgimpnp  LABEL "Promissoria"      AT 15
          HELP '"I" para imprimir ou "N" para nao imprimir a promissoria.'
     SKIP(1)
     WITH SIDE-LABELS ROW 10
     OVERLAY CENTERED TITLE COLOR NORMAL " 2 via " FRAME f_2via.

FORM SKIP(1)
     tel_repsolic FORMAT "x(30)" LABEL "Representante Solicitante" AT 2 
     HELP "Utilizar setas direita/esquerda para escolher Representante" SKIP (1)
     "Numero do novo cartao:"  AT 6 
     tel_nrcrcard 
     HELP "Entre com o numero do novo cartao" 
     SKIP(1)
     tel_dtnovval LABEL "Nova validade"  AT 14
     HELP "Entre com a nova validade"
     SKIP(1)
     WITH SIDE-LABELS NO-LABEL ROW 10
     OVERLAY CENTERED TITLE COLOR NORMAL " 2 via " FRAME f_2via_pj.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:    

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN valida_carregamento_entrega2via_cartao IN h_b1wgen0028
                                 (INPUT glb_cdcooper,
                                  INPUT 0, 
                                  INPUT 0, 
                                  INPUT glb_cdoperad,
                                  INPUT tel_nrdconta,
                                  INPUT par_nrctrcrd,
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
    
            IF  AVAIL tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
    
            RETURN "NOK".
        END.
    
    ASSIGN tel_flgimpnp    = TRUE
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

    DISPLAY tel_flgimpnp WITH FRAME f_2via.
    PAUSE 0.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF   aux_tipopess = 2 THEN
             DO:
                
                UPDATE tel_repsolic tel_nrcrcard tel_dtnovval 
                       WITH FRAME f_2via_pj
                 
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
                 
                                     DISPLAY tel_repsolic WITH FRAME f_2via_pj.
                                END.
    
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                DO:
                                     aux_indposi2 = aux_indposi2 + 1.
                 
                                     IF  aux_indposi2 > NUM-ENTRIES(aux_represen)  THEN
                                         aux_indposi2 = 1.
                 
                                     tel_repsolic =  TRIM(ENTRY(aux_indposi2,
                                                                aux_represen)).
                 
                                     DISPLAY tel_repsolic WITH FRAME f_2via_pj.
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
                     IF  FRAME-FIELD = "tel_dtnovva" /*"tel_nrcrcard"*/  THEN
                         IF  LASTKEY = KEYCODE(",")  THEN
                             APPLY 46.
                         ELSE
                             APPLY LASTKEY.
                     ELSE
                         APPLY LASTKEY.
                 
                END. /* Fim do EDITING */

             END.

         ELSE 
             DO:
                 UPDATE tel_nrcrcard tel_dtnovval WITH FRAME f_2via.
             END.

        RUN sistema/generico/procedures/b1wgen0028.p 
            PERSISTENT SET h_b1wgen0028.

        RUN valida_dados_entrega2via_cartao IN h_b1wgen0028
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
                              INPUT tel_nrcrcard,
                              INPUT tel_dtnovval,
                              INPUT tel_flgimpnp,
                              INPUT tel_repsolic,
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
     
        LEAVE.

    END. /* FIM do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_2via NO-PAUSE.
            HIDE FRAME f_2via_pj NO-PAUSE.
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
                          
            END. /* Fim do FOR EACH tt-dados-avais */
            IF   aux_tipopess = 1 THEN
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

    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
        aux_confirma <> "S"                 THEN
        DO:
            glb_cdcritic = 79.
            
            RUN fontes/critic.p.
            
            glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.
             
            HIDE FRAME f_2via NO-PAUSE.
            HIDE FRAME f_2via_pj NO-PAUSE.

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.


    RUN efetua_entrega2via_cartao IN h_b1wgen0028
                                (/*** Parametros Gerais ***/
                                 INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT tel_nrdconta,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1,
                                 INPUT 1,
                                 INPUT glb_nmdatela,
                                 /*** Dados do Cartao ***/
                                 INPUT par_cdadmcrd,
                                 INPUT par_nrctrcrd,
                                 INPUT tel_nrcrcard,
                                 INPUT tel_dtnovval,
                                 INPUT tel_flgimpnp,
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
                                 INPUT aux_cpfrepre[aux_indposi2],
                                OUTPUT aux_nrctrcrd,
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

    HIDE FRAME f_2via NO-PAUSE.
    HIDE FRAME f_2via_pj NO-PAUSE.

    LEAVE.

END. /* Fim do DO WHILE TRUE */

ASSIGN aux_flgimp2v = no
       aux_cdprgctr = "fontes/sldccr_ct" + 
                      STRING(par_cdadmcrd,"9") + ".p".

RUN VALUE(aux_cdprgctr) (INPUT aux_nrctrcrd).
                        
RETURN "OK".

/*....................................................................... */
