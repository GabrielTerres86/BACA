/* ............................................................................

   Programa: Fontes/sldccr_c.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                           Ultima atualizacao: 15/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar dados do cartao de credito.

   Alteracoes: 11/08/98 - Identificar 2via pela data dtentr2v. (Deborah).
   
               12/08/98 - Mostrar a data de entrega da 2 via (Deborah).

               20/08/98 - Tratar novo cartao (Odair)

             17/01/2001 - Substituir CCOH por COOP (Margarete/Planner).
             05/08/2004 - Incluida opcao para Consultar Avalistas(Mirtes).

             26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
              
             13/04/2006 - Incluido campo "Limite Debito" (Diego).  
             
             01/02/2008 - Alterado LABELs para Bloqueio Cartoes BB(Guilherme).
             
             13/06/2008 - Atribuir motivo de cancelamento(aux_dsmotivo) somente
                          quando o cartao estiver cancelado (Diego).

             26/08/2008 - Mostrar data de solicitacao de 2via de senha (David).
             
             16/09/2008 - Mostrar data de solicitacao de 2via de cartao (David)

             10/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                          (GATI - Eder)
                          
             20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                          (Gati - Daniel)    
                          
             21/02/2011 - Incluido o campo Encerramento para atender o 
                          cartão do Banco do Brasil. (Isara - RKAM)
                          
             26/04/2011 - Separação de Avalistas devido a CEP integrado.
                          (André - DB1)
                          
             12/09/2011 - Incluir Data Venc. Anterior (Ze/Fabricio).
             
             10/07/2012 - Alterado campo "Titular" para mostrar coluna 
                          nmextttl e incluído campo "Nome no Plástico" 
                          para mostrar coluna nmtitcrd (Guilherme Maba).
                          
             15/10/2015 - Desenvolvimento do projeto 126. (James)
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }
{ includes/var_deschq.i "NEW" }
    

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.

DEF VAR tel_avalista AS CHAR FORMAT "x(05)" INIT "AVAIS"               NO-UNDO.

DEF VAR aux_ultdebit AS CHAR FORMAT "x(12)" INIT "Ult.debitos"         NO-UNDO.
DEF VAR aux_contadcd AS INTE                                           NO-UNDO.
DEF VAR aux_flgretor AS LOGI                                           NO-UNDO.

DEF VAR aux_dddebant AS CHAR FORMAT "x(02)" INIT ""                    NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.


FORM tt-dados_cartao.nrcrcard LABEL "Cartao"             AT 02
     tt-dados_cartao.dscartao NO-LABEL                   AT 33 FORMAT "X(34)"
     SKIP
     tt-dados_cartao.nmextttl LABEL "Titular"            AT 02 FORMAT "x(40)"
     tt-dados_cartao.nrcpftit LABEL "C.P.F."             AT 53 FORMAT "999,999,999,99"
     SKIP                                               
     tt-dados_cartao.dsparent LABEL "Parentesco"         AT 02 FORMAT "X(21)"
     tt-dados_cartao.dssituac LABEL "Situacao"           AT 51 FORMAT "x(16)"
     SKIP
     tt-dados_cartao.nmtitcrd LABEL "Nome no plastico"   AT 02 FORMAT "x(40)"
     SKIP(1)                                               
     tt-dados_cartao.vlsalari LABEL "Salario"            AT 02 FORMAT "zzz,zzz,zz9.99"
     tt-dados_cartao.vlsalcon LABEL "Sal.Conjuge"        AT 27 FORMAT "zz,zzz,zz9.99"
     tt-dados_cartao.vloutras LABEL "Rendas"             AT 55 FORMAT "zz,zzz,zz9.99"
     SKIP                                               
     tt-dados_cartao.vlalugue LABEL "Aluguel"            AT 02 FORMAT "zzz,zzz,zz9.99"
     tt-dados_cartao.vllimite LABEL "Limite"             AT 27 FORMAT "x(19)"
     tt-dados_cartao.dddebito LABEL "Dia do debito C/C"  AT 55
     SKIP
     tt-dados_cartao.vllimdeb LABEL "Limite Debito"      AT 20
     aux_dddebant             LABEL "Dia do debito 2v."  AT 55
     SKIP
     tt-dados_cartao.dtpropos LABEL "Datas ==> Proposta" AT 02
     tt-dados_cartao.dtsolici LABEL "Pedido"             AT 39
     tt-dados_cartao.dtlibera LABEL "Liber."             AT 58
     SKIP
     tt-dados_cartao.dtentreg LABEL "Entrega"            AT 13
     tt-dados_cartao.dtcancel LABEL "Cancelamento"       AT 33
     tt-dados_cartao.dsmotivo NO-LABEL                   AT 58 FORMAT "X(18)"
     SKIP
     tt-dados_cartao.dtvalida LABEL "Validade do cartao" AT 02
     tt-dados_cartao.qtanuida LABEL "Anuidades pagas"    AT 38
     SKIP
     tt-dados_cartao.nrctamae LABEL "Conta-mae"          AT 02
                              FORMAT "9999,9999,9999,9999"
     tt-dados_cartao.ds2viasn NO-LABEL                   AT 40 FORMAT "X(35)"
     SKIP
     tt-dados_cartao.ds2viacr NO-LABEL                   AT 02 FORMAT "X(36)"
     tt-dados_cartao.dsde2via NO-LABEL                   AT 40 FORMAT "X(34)"
     tt-dados_cartao.dtanucrd LABEL "Anuidade Administradora" AT 02 
                              FORMAT 99/99/9999
     "--->"
     tt-dados_cartao.dspaganu NO-LABEL FORMAT "x(30)"
     SKIP
     tt-dados_cartao.nmoperad LABEL "Alterado por" AT 02 FORMAT "x(20)"
     tt-dados_cartao.nrctrcrd LABEL "Proposta"     AT 40
     aux_ultdebit             NO-LABEL             AT 59
     HELP "Tecle <Entra> para ver os lancamentos ou <Fim> para retornar."
     tel_avalista            NO-LABEL             AT 72
     HELP "Tecle <Entra> para ver os avalistas ou <Fim> para retornar."
     WITH ROW 05 COLUMN 3 SIDE-LABELS OVERLAY
          TITLE COLOR NORMAL " Consulta cartao de credito "
          FRAME f_consulta CENTERED.

FORM tt-dados_cartao.nrcrcard LABEL "Cartao"      AT 02
     tt-dados_cartao.dscartao NO-LABEL            AT 33 FORMAT "X(34)"
     SKIP
     tt-dados_cartao.nmextttl LABEL "Titular"     AT 02 FORMAT "x(40)"
     tt-dados_cartao.nrcpftit LABEL "C.P.F."      AT 53 FORMAT "999,999,999,99"
     SKIP
     tt-dados_cartao.nmtitcrd LABEL "Nome no plastico"     AT 02 FORMAT "x(40)"
     SKIP
     tt-dados_cartao.dsparent LABEL "Representante solicitante"  AT 02 FORMAT "x(46)"  SKIP
     tt-dados_cartao.dssituac LABEL "Situacao"                   AT 02 FORMAT "x(16)" 
     tt-dados_cartao.vllimite LABEL "Limite Credito"             AT 20 FORMAT "x(19)"
     tt-dados_cartao.dddebito LABEL "Dia do debito C/C"          AT 55
     SKIP                                                        
     tt-dados_cartao.vllimdeb LABEL "Limite Debito"              AT 20
     aux_dddebant             LABEL "Dia do debito 2v."          AT 55
     SKIP                                                        
     tt-dados_cartao.dtpropos LABEL "Datas ==> Proposta"         AT 02
     tt-dados_cartao.dtsolici LABEL "Pedido"                     AT 39
     tt-dados_cartao.dtlibera LABEL "Liber."                     AT 58
     SKIP                                                        
     tt-dados_cartao.dtentreg LABEL "Entrega"                    AT 13
     tt-dados_cartao.dtcancel LABEL "Cancelamento"               AT 33
     tt-dados_cartao.dsmotivo NO-LABEL                           AT 58 FORMAT "X(18)"
     SKIP                                                        
     tt-dados_cartao.dtvalida LABEL "Validade do cartao"         AT 02
     tt-dados_cartao.qtanuida LABEL "Anuidades pagas"            AT 38
     SKIP                                                        
     tt-dados_cartao.nrctamae LABEL "Conta-mae"                  AT 02
                              FORMAT "9999,9999,9999,9999"
     tt-dados_cartao.ds2viasn NO-LABEL                           AT 40 FORMAT "X(35)"
     SKIP
     tt-dados_cartao.ds2viacr NO-LABEL                           AT 02 FORMAT "X(36)"
     tt-dados_cartao.dsde2via NO-LABEL                           AT 40 FORMAT "X(34)"
     tt-dados_cartao.dtanucrd LABEL "Anuidade Administradora"    AT 02 
                              FORMAT 99/99/9999
     "--->"
     tt-dados_cartao.dspaganu NO-LABEL FORMAT "x(30)"
     SKIP
     tt-dados_cartao.nmoperad LABEL "Alterado por" AT 02 FORMAT "x(20)"
     tt-dados_cartao.nrctrcrd LABEL "Proposta"     AT 40
     aux_ultdebit             NO-LABEL             AT 59
     HELP "Tecle <Entra> para ver os lancamentos ou <Fim> para retornar."
     tel_avalista            NO-LABEL             AT 72
     HELP "Tecle <Entra> para ver os avalistas ou <Fim> para retornar."
     WITH ROW 05 COLUMN 3 SIDE-LABELS OVERLAY
          TITLE COLOR NORMAL " Consulta cartao de credito "
          FRAME f_consulta_juridica CENTERED.

FORM tt-ult_deb.dtdebito  LABEL "Data"   AT 02
     tt-ult_deb.vldebito  LABEL "Valor"  FORMAT "zzz,zzz,zzz,zz9.99"
     WITH 12 DOWN  ROW 06 COLUMN 05 NO-LABELS OVERLAY NO-UNDERLINE
          TITLE COLOR NORMAL " Ultimos debitos " FRAME f_deb CENTERED.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

RUN consulta_dados_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT par_nrctrcrd,
                              INPUT 1, 
                              INPUT 1, 
                              INPUT glb_nmdatela,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-dados_cartao,
                             OUTPUT TABLE tt-msg-confirma).

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
     
FIND tt-dados_cartao NO-ERROR.

IF  NOT AVAIL tt-dados_cartao  THEN
    RETURN "NOK".

ASSIGN tt-dados_cartao.dtcancel:LABEL = tt-dados_cartao.lbcanblq.

IF tt-dados_cartao.dddebant > 0 THEN
    aux_dddebant = STRING(tt-dados_cartao.dddebant, "99").

IF tt-dados_cartao.inpessoa = 2 THEN
    RUN pessoa_juridica.
ELSE
    RUN pessoa_fisica.


PROCEDURE pessoa_fisica:

    DISPLAY tt-dados_cartao.nrcrcard  tt-dados_cartao.nrctrcrd  
            tt-dados_cartao.dscartao  tt-dados_cartao.nmextttl
            tt-dados_cartao.nrcpftit  tt-dados_cartao.dsparent
            tt-dados_cartao.dssituac  tt-dados_cartao.nmtitcrd 
            tt-dados_cartao.vlsalari  tt-dados_cartao.vlsalcon  
            tt-dados_cartao.vloutras  tt-dados_cartao.vlalugue  
            tt-dados_cartao.dddebito  aux_dddebant            
            tt-dados_cartao.vllimite  tt-dados_cartao.dtpropos  
            tt-dados_cartao.vllimdeb  tt-dados_cartao.dtsolici  
            tt-dados_cartao.dtlibera  tt-dados_cartao.dtentreg  
            tt-dados_cartao.dtcancel  tt-dados_cartao.dsmotivo  
            tt-dados_cartao.dtvalida  tt-dados_cartao.qtanuida  
            tt-dados_cartao.nrctamae  tt-dados_cartao.dsde2via  
            tt-dados_cartao.dtanucrd  tt-dados_cartao.dspaganu  
            tt-dados_cartao.nmoperad  tt-dados_cartao.ds2viasn  
            tt-dados_cartao.ds2viacr  aux_ultdebit              
            tel_avalista
            WITH FRAME f_consulta.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        CHOOSE FIELD aux_ultdebit tel_avalista WITH FRAME f_consulta.
    
        IF  FRAME-VALUE = aux_ultdebit  THEN /* Ultimos Debitos */
            DO:
                RUN sistema/generico/procedures/b1wgen0028.p 
                    PERSISTENT SET h_b1wgen0028.

                RUN ult_debitos IN h_b1wgen0028
                                 (INPUT glb_cdcooper,
                                  INPUT 0, 
                                  INPUT 0, 
                                  INPUT glb_cdoperad,
                                  INPUT tel_nrdconta,
                                  INPUT tt-dados_cartao.nrcrcard,
                                  INPUT 1, 
                                  INPUT 1, 
                                  INPUT glb_nmdatela,
                                 OUTPUT TABLE tt-ult_deb).
                
                DELETE PROCEDURE h_b1wgen0028.
    
                IF  NOT CAN-FIND(FIRST tt-ult_deb)  THEN
                    DO:
                        glb_cdcritic = 011.
                        RUN fontes/critic.p.
                        glb_cdcritic = 0.
    
                        BELL.
                        MESSAGE glb_dscritic.
                         
                        NEXT.
                    END.
                     
                ASSIGN aux_contadcd = 0
                       aux_flgretor = FALSE.
                       
                CLEAR FRAME f_deb ALL NO-PAUSE.
                
                FOR EACH tt-ult_deb NO-LOCK:
                
                    ASSIGN aux_contadcd = aux_contadcd + 1.
    
                    IF  aux_contadcd = 1  THEN
                        IF  aux_flgretor  THEN
                            DO:
                                PAUSE MESSAGE 
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                CLEAR FRAME f_deb ALL NO-PAUSE.
                            END.
                        ELSE
                            aux_flgretor = TRUE.
    
                    PAUSE(0).
    
                    DISPLAY tt-ult_deb.dtdebito tt-ult_deb.vldebito 
                            WITH FRAME f_deb.
    
                    IF  aux_contadcd = 12  THEN
                        aux_contadcd = 0. 
                    ELSE
                        DOWN WITH FRAME f_deb.
             
                END.
                                          
                IF (aux_contadcd > 0 AND KEYFUNCTION(LASTKEY) <> "END-ERROR") 
                    OR aux_contadcd = 0                                 THEN 
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                        PAUSE MESSAGE 
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                        LEAVE.
         
                    END.
         
                HIDE FRAME f_deb NO-PAUSE.
            END.
        ELSE
        IF  FRAME-VALUE = tel_avalista  THEN /* Avais */
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
                                  INPUT tt-dados_cartao.nrctrcrd,
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
    
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                      
                    DISPLAY lim_nrctaav1  
                            lim_nmdaval1  
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

                    IF  lim_nrctaav2 <> 0 OR lim_nmdaval2 <> "" THEN
                        DO:

                            PAUSE MESSAGE
                             "Pressione algo para continuar - <F4>/<END> para voltar.".
        
                            DISPLAY lim_nrctaav2 
                                    lim_nmdaval2  
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
    
                    PAUSE MESSAGE "Tecle algo para continuar...".
       
                    LEAVE.
             
                END. /* Fim do DO WHILE TRUE */
             
                HIDE FRAME f_promissoria1 NO-PAUSE.
                HIDE FRAME f_promissoria2 NO-PAUSE.
            END.
    
    END. /* Fim do DO WHILE TRUE */
    
    HIDE FRAME f_consulta NO-PAUSE.
    
    RETURN "OK".
END PROCEDURE.

/* ......................................................................... */


PROCEDURE pessoa_juridica:

    DISPLAY tt-dados_cartao.nrcrcard  tt-dados_cartao.nrctrcrd  
            tt-dados_cartao.dscartao  tt-dados_cartao.nmextttl 
            tt-dados_cartao.nmtitcrd  tt-dados_cartao.nrcpftit  
            tt-dados_cartao.dsparent  tt-dados_cartao.dssituac  
            /*tt-dados_cartao.vlsalari  tt-dados_cartao.vlsalcon  
            tt-dados_cartao.vloutras  tt-dados_cartao.vlalugue*/  
            tt-dados_cartao.dddebito  tt-dados_cartao.vllimite  
            tt-dados_cartao.dtpropos  tt-dados_cartao.vllimdeb  
            tt-dados_cartao.dtsolici  tt-dados_cartao.dtlibera  
            tt-dados_cartao.dtentreg  tt-dados_cartao.dtcancel  
            tt-dados_cartao.dsmotivo  tt-dados_cartao.dtvalida  
            tt-dados_cartao.qtanuida  tt-dados_cartao.nrctamae  
            tt-dados_cartao.dsde2via  tt-dados_cartao.dtanucrd  
            tt-dados_cartao.dspaganu  tt-dados_cartao.nmoperad  
            tt-dados_cartao.ds2viasn  tt-dados_cartao.ds2viacr  
            aux_ultdebit              aux_dddebant
            /*tel_avalista*/
        WITH FRAME f_consulta_juridica.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                                         
                                                                                 
        CHOOSE FIELD aux_ultdebit WITH FRAME f_consulta_juridica.                
                                                                                 
        IF  FRAME-VALUE = aux_ultdebit  THEN /* Ultimos Debitos */               
            DO:                                                                  
                RUN sistema/generico/procedures/b1wgen0028.p                     
                    PERSISTENT SET h_b1wgen0028.                                 
                                                                                 
                RUN ult_debitos IN h_b1wgen0028                                  
                                 (INPUT glb_cdcooper,                            
                                  INPUT 0,                                       
                                  INPUT 0,                                       
                                  INPUT glb_cdoperad,                            
                                  INPUT tel_nrdconta,                            
                                  INPUT tt-dados_cartao.nrcrcard,                
                                  INPUT 1,                                       
                                  INPUT 1,                                       
                                  INPUT glb_nmdatela,                            
                                 OUTPUT TABLE tt-ult_deb).                       
                                                                                 
                DELETE PROCEDURE h_b1wgen0028.                                   
                                                                                 
                IF  NOT CAN-FIND(FIRST tt-ult_deb)  THEN                         
                    DO:                                                          
                        glb_cdcritic = 011.                                      
                        RUN fontes/critic.p.                                     
                        glb_cdcritic = 0.                                        
                                                                                 
                        BELL.                                                    
                        MESSAGE glb_dscritic.                                    
                                                                                 
                        NEXT.                                                    
                    END.                                                         
                                                                                 
                ASSIGN aux_contadcd = 0                                          
                       aux_flgretor = FALSE.                                     
                                                                                 
                CLEAR FRAME f_deb ALL NO-PAUSE.                                  
                                                                                 
                FOR EACH tt-ult_deb NO-LOCK:                                     
                                                                                 
                    ASSIGN aux_contadcd = aux_contadcd + 1.                      
                                                                                 
                    IF  aux_contadcd = 1  THEN                                   
                        IF  aux_flgretor  THEN                                   
                            DO:                                                  
                                PAUSE MESSAGE                                    
                         "Tecle <Entra> para continuar ou <Fim> para encerrar".  
                                CLEAR FRAME f_deb ALL NO-PAUSE.                  
                            END.                                                 
                        ELSE                                                     
                            aux_flgretor = TRUE.                                 
                                                                                 
                    PAUSE(0).                                                    
                                                                                 
                    DISPLAY tt-ult_deb.dtdebito tt-ult_deb.vldebito              
                            WITH FRAME f_deb.                                    
                                                                                 
                    IF  aux_contadcd = 12  THEN                                  
                        aux_contadcd = 0.                                        
                    ELSE                                                         
                        DOWN WITH FRAME f_deb.                                   
                                                                                 
                END.                                                             
                                                                                 
                IF (aux_contadcd > 0 AND KEYFUNCTION(LASTKEY) <> "END-ERROR") 
                    OR aux_contadcd = 0   THEN                                   
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                         
                                                                                 
                        PAUSE MESSAGE                                            
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".   
                        LEAVE.                                                   
                                                                           
                    END.                                                   
                                                                           
                HIDE FRAME f_deb NO-PAUSE.                                 
            END.                                                           
        ELSE                                                               
        IF  FRAME-VALUE = tel_avalista  THEN /* Avais */                   
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
                                  INPUT tt-dados_cartao.nrctrcrd,          
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
                                                                          
                                                                          
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                      
                                            
                    DISPLAY lim_nrctaav1    
                            lim_nmdaval1    
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

                    PAUSE MESSAGE
                     "Pressione algo para continuar - <F4>/<END> para voltar.".


                    DISPLAY lim_nrctaav2             
                            lim_nmdaval2             
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
                                                                 
                    PAUSE MESSAGE "Tecle algo para continuar...".
                                                                 
                    LEAVE.                           
                                                     
                END. /* Fim do DO WHILE TRUE */      
                                                     
                HIDE FRAME f_promissoria1 NO-PAUSE. 
                HIDE FRAME f_promissoria2 NO-PAUSE. 
            END.                                     
                                                   
    END. /* Fim do DO WHILE TRUE */     

    HIDE FRAME f_consulta_juridica NO-PAUSE.
    
    RETURN "OK".


END PROCEDURE.

