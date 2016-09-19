/* ............................................................................

   Programa: Fontes/sldccr_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah iborah
   Data    : Marco/99                        Ultima atualizacao: 01/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para entregar o cartao com nova validade (renovacao)

   Alteracoes: 30/07/2001 - Incluir geracao de nota promissoria (Margarete).
   
               21/08/2001 - Liberar a renovacao para Bradesco/Visa (Deborah).

               09/10/2002 - Pedir sempre a nota promissoria (Margarete).
               
               20/01/2003 - Ajuste na nota promissoria para tratar os 
                            conjuges fiadores (Eduardo).
                            
               31/07/2003 - Inclusao da rotina ver_cadastro.p (Julio).

      
               23/06/2004 - Atualizar tabela avalistas Terceiros(Mirtes)
               
               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               09/06/2005 - Salvar a data da alteracao da validade (Julio)
                   
               05/07/2005 - Alimentado campo cdcooper das tabelas crapavl e
                            crapavt (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

               07/02/2006 - Inclusao de NO-LOCK no FOR EACH da linha 225 - 
                            SQLWorks - Fernando.
                            
               19/06/2006 - Bloqueada opcao de renovacao para Cartao BB
                            (Diego).
               
               27/03/2007 - Alterado campos de endereco dos Avalistas/Fiadores
                            para receberem dados da estrutura crapenc (Elton).

               24/09/2007 - Conversao de rotina ver_capital e 
                            ver_cadastro para BO (Sidnei/Precise)
                            
               19/12/2008 - Informar apenas mes e ano na validade(Guilherme).
                
               17/02/2009 - Criar log/sldccr.log (Gabriel).

               25/03/2009 - Incluir criticas sobre situacao e tipo da conta do
                            cooperado (David).
                            
               22/04/2009 - Nao permitir acesso a opcao se foi solicitada 2via 
                            do cartao (David).
                                         
               16/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)

               20/10/2010 - Alteracao projeto Cartao PJ
                            (GATI - Sandro)
                            
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
{ includes/var_limite.i "NEW"} /* Geracao de Nota Promissoria */
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.

DEF VAR tel_flgimpnp AS LOGI FORMAT "Imprime/Nao Imprime"              NO-UNDO.

DEF VAR tel_dtnovval AS CHAR FORMAT "xx/xxxx"                          NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.
DEF VAR aux_cdprgctr AS CHAR                                           NO-UNDO.
                                                                      
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     par_nrcrcard LABEL "Numero do cartao" COLON 25 
                  FORMAT "9999,9999,9999,9999"
     SKIP(1)
     tt-dados_renovacao_cartao.dtvalida LABEL "Validade atual" 
                                        FORMAT "99/99/9999" COLON 25
     " Em:"
     tt-dados_renovacao_cartao.dtaltval NO-LABEL FORMAT "99/99/9999"
     SKIP(1)
     tel_dtnovval LABEL "Nova validade" COLON 25
     SKIP(1)
     tel_flgimpnp LABEL "Promissoria"   COLON 25
             HELP '"I" para imprimir ou "N" para nao imprimir a promissoria.'
     WITH SIDE-LABELS ROW 10  
     OVERLAY CENTERED TITLE COLOR NORMAL " Renovacao " FRAME f_renovar.

FORM SKIP(1)
     par_nrcrcard LABEL "Numero do cartao" COLON 25 
                  FORMAT "9999,9999,9999,9999"
     SKIP(1)
     tt-dados_renovacao_cartao.dtvalida LABEL "Validade atual" 
                                        FORMAT "99/99/9999" COLON 25
     " Em:"
     tt-dados_renovacao_cartao.dtaltval NO-LABEL FORMAT "99/99/9999"
     SKIP(1)
     tel_dtnovval LABEL "Nova validade" COLON 25
     WITH SIDE-LABELS ROW 10  
     OVERLAY CENTERED TITLE COLOR NORMAL " Renovacao " FRAME f_renovar_pj.


IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
    RUN sistema/generico/procedures/b1wgen0028.p
        PERSISTENT SET h_b1wgen0028.

ASSIGN aux_inpessoa = DYNAMIC-FUNCTION("f_tipo_assoc" IN h_b1wgen0028,glb_cdcooper,tel_nrdconta).

DELETE PROCEDURE h_b1wgen0028.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0028.p 
        PERSISTENT SET h_b1wgen0028.
    
    RUN carrega_dados_renovacao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT par_nrctrcrd,
                              INPUT glb_dtmvtolt,
                              INPUT 1, 
                              INPUT 1, 
                              INPUT glb_nmdatela,
                             OUTPUT TABLE tt-dados_renovacao_cartao,
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

            RETURN "NOK".                
        END.
         
    FIND tt-dados_renovacao_cartao NO-ERROR.

    IF  NOT AVAIL tt-dados_renovacao_cartao  THEN 
        RETURN "NOK".

    ASSIGN tel_flgimpnp    = TRUE
           lim_nrctaav1    = tt-dados_renovacao_cartao.nrctaav1
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

           lim_nrctaav2    = tt-dados_renovacao_cartao.nrctaav2
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
               
    IF  aux_inpessoa = 1 THEN
        DISPLAY par_nrcrcard                       
                tt-dados_renovacao_cartao.dtvalida
                tt-dados_renovacao_cartao.dtaltval 
                tel_flgimpnp
                WITH FRAME f_renovar.
    ELSE
        DISPLAY par_nrcrcard                       
                tt-dados_renovacao_cartao.dtvalida
                tt-dados_renovacao_cartao.dtaltval 
                WITH FRAME f_renovar_pj.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
        IF  aux_inpessoa = 1 THEN
            UPDATE tel_dtnovval WITH FRAME f_renovar.
        ELSE
            UPDATE tel_dtnovval WITH FRAME f_renovar_pj.

        RUN sistema/generico/procedures/b1wgen0028.p 
            PERSISTENT SET h_b1wgen0028.
        
        RUN valida_renovacao_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT glb_dtmvtolt,
                              INPUT 1, 
                              INPUT 1, 
                              INPUT glb_nmdatela,
                              INPUT tel_dtnovval,
                              INPUT par_nrctrcrd,
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

    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            IF  aux_inpessoa = 1 THEN
                HIDE FRAME f_renovar NO-PAUSE.
            ELSE
                HIDE FRAME f_renovar_pj NO-PAUSE.

            RETURN "NOK".
        END.

    IF  tel_flgimpnp     AND
        aux_inpessoa = 1 THEN
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
             
            IF  aux_inpessoa = 1 THEN
                HIDE FRAME f_renovar NO-PAUSE.
            ELSE
                HIDE FRAME f_renovar_pj NO-PAUSE.

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
   
    RUN renova_cartao IN h_b1wgen0028 (/*** Parametros Gerais ***/
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
                                       INPUT par_nrctrcrd,
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

    IF  aux_inpessoa = 1 THEN
        HIDE FRAME f_renovar NO-PAUSE.
    ELSE
        HIDE FRAME f_renovar_pj NO-PAUSE.
   
    LEAVE.
        
END. /* Fim do DO WHILE TRUE */

IF  aux_inpessoa = 1 THEN 
    DO:

        ASSIGN aux_flgimp2v = NO
               aux_cdprgctr = "fontes/sldccr_ct" +
                              STRING(par_cdadmcrd,"9") + ".p".
        
        RUN VALUE(aux_cdprgctr) (INPUT par_nrctrcrd).

    END.

RETURN "OK".

/* ......................................................................... */
