/* .............................................................................
                                
   Programa: Fontes/dsctit_limite_c.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                         Ultima atualizacao: 20/04/2011    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar o limite de descontos de titulos.

   Alteracoes: 10/12/2009 - Geracao do rating (Gabriel).
                          - Substituido campo tt-dsctit_dados_limite.vlopescr 
                            por tt-dsctit_dados_limite.vltotsfn (Elton).
                            
               26/02/2010 - Mostrar frame dos avalistas (Gabriel).             
               
               20/04/2011 - Separação dos avalistas. Inclusão de Campos para
                            CEP integrado. (André - DB1)

............................................................................. */

DEF INPUT PARAM par_nrctrlim AS INTE        NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ includes/var_online.i }
{ includes/var_atenda.i }

{ includes/var_dsctit.i }

DEF VAR h-b1wgen0030 AS HANDLE              NO-UNDO.

RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        MESSAGE "Handle Invalido para h-b1wgen0030".
        RETURN.
    END.
ELSE
    DO:
        RUN busca_dados_limite_consulta IN h-b1wgen0030 
                                       (INPUT glb_cdcooper,
                                        INPUT 0, /*agencia*/
                                        INPUT 0, /*caixa*/
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT 1, /*origem*/
                                        INPUT tel_nrdconta,
                                        INPUT 1, /*idseqttl*/
                                        INPUT glb_nmdatela,
                                        INPUT par_nrctrlim,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-dsctit_dados_limite,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-dados_dsctit).
                                
        DELETE PROCEDURE h-b1wgen0030.
        
        IF  RETURN-VALUE = "NOK"  THEN                        
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  AVAIL tt-erro  THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        RETURN.
                    END.
                ELSE
                    DO:
                        MESSAGE "Registro de limite nao encontrado".
                        RETURN.
                    END.
            END.
    END.

FIND tt-dsctit_dados_limite NO-LOCK NO-ERROR.

IF  NOT AVAIL tt-dsctit_dados_limite  THEN
    DO:
        MESSAGE "Registro de limite nao encontrado".
        RETURN.
    END.

CONSULTA:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DISPLAY tt-dsctit_dados_limite.nrctrlim  tt-dsctit_dados_limite.vllimite  
           tt-dsctit_dados_limite.qtdiavig  tt-dsctit_dados_limite.cddlinha  
           tt-dsctit_dados_limite.dsdlinha  tt-dsctit_dados_limite.txjurmor 
           tt-dsctit_dados_limite.txdmulta  tt-dsctit_dados_limite.dsramati 
           tt-dsctit_dados_limite.vlmedtit  tt-dsctit_dados_limite.vlfatura  
           tt-dsctit_dados_limite.dtcancel
           WITH FRAME f_dsctit_prolim.

   /*se nao estiver cancelado nao mostrara a data de cancelamento*/
   IF   tt-dsctit_dados_limite.insitlim <> 3  THEN 
        HIDE tt-dsctit_dados_limite.dtcancel IN FRAME f_dsctit_prolim.
   
   PAUSE MESSAGE "Tecle algo para continuar...".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      DISPLAY tt-dsctit_dados_limite.vlsalari 
              tt-dsctit_dados_limite.vlsalcon 
              tt-dsctit_dados_limite.vloutras 
              tt-dsctit_dados_limite.dsdbens1
              tt-dsctit_dados_limite.dsdbens2
              WITH FRAME f_dsctit_rendas.
    
      PAUSE MESSAGE "Tecle algo para continuar...".

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

         IF   crapass.inpessoa = 1   THEN
              DO:
                 HIDE perfatcl IN FRAME f_rating.
                 HIDE nrperger IN FRAME f_rating.

                 DISPLAY tt-dsctit_dados_limite.nrinfcad
                         tt-dsctit_dados_limite.nrliquid
                         tt-dsctit_dados_limite.nrpatlvr
                         tt-dsctit_dados_limite.vltotsfn
                         tt-dsctit_dados_limite.nrgarope
                         WITH FRAME f_rating.
              END.
         ELSE
              DISPLAY tt-dsctit_dados_limite.nrinfcad
                      tt-dsctit_dados_limite.nrliquid
                      tt-dsctit_dados_limite.nrpatlvr
                      tt-dsctit_dados_limite.vltotsfn 
                      tt-dsctit_dados_limite.nrgarope
                      tt-dsctit_dados_limite.perfatcl
                      tt-dsctit_dados_limite.nrperger
                      WITH FRAME f_rating.

         PAUSE MESSAGE "Tecle algo para continuar...".

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
            ASSIGN tel_dsobserv = replace(replace(replace(replace(tt-dsctit_dados_limite.dsobserv,"~{",""),"~}",""),"(",""),")","").
            
            DISPLAY tel_dsobserv WITH FRAME f_observacao.
         
            ENABLE ALL WITH FRAME f_observacao.
       
            tel_dsobserv:READ-ONLY IN FRAME f_observacao = YES. 
       
            WAIT-FOR CHOOSE OF btn_btaosair.
       
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     
               FIND FIRST tt-dados-avais NO-LOCK NO-ERROR.

               IF  AVAIL tt-dados-avais  THEN
                   DO:
                       DISPLAY tt-dados-avais.nrctaava    @ lim_nrctaav1 
                               tt-dados-avais.nmdavali    @ lim_nmdaval1
                               tt-dados-avais.nrcpfcgc    @ lim_cpfcgc1
                               tt-dados-avais.tpdocava    @ lim_tpdocav1
                               tt-dados-avais.nrdocava    @ lim_dscpfav1
                               tt-dados-avais.nmconjug    @ lim_nmdcjav1
                               tt-dados-avais.nrcpfcjg    @ lim_cpfccg1
                               tt-dados-avais.tpdoccjg    @ lim_tpdoccj1
                               tt-dados-avais.nrdoccjg    @ lim_dscfcav1
                               tt-dados-avais.dsendre1    @ lim_dsendav1[1]
                               tt-dados-avais.dsendre2    @ lim_dsendav1[2]
                               tt-dados-avais.nrfonres    @ lim_nrfonres1
                               tt-dados-avais.dsdemail    @ lim_dsdemail1
                               tt-dados-avais.nmcidade    @ lim_nmcidade1
                               tt-dados-avais.cdufresd    @ lim_cdufresd1
                               tt-dados-avais.nrcepend    @ lim_nrcepend1
                               tt-dados-avais.nrendere    @ lim_nrendere1
                               tt-dados-avais.complend    @ lim_complend1
                               tt-dados-avais.nrcxapst    @ lim_nrcxapst1
                               WITH FRAME f_dsctit_promissoria1.
                   END.
               ELSE
                   DO:
                       DISPLAY "" @ lim_nrctaav1 
                               "" @ lim_nmdaval1
                               "" @ lim_cpfcgc1
                               "" @ lim_tpdocav1
                               "" @ lim_dscpfav1
                               "" @ lim_nmdcjav1
                               "" @ lim_cpfccg1
                               "" @ lim_tpdoccj1
                               "" @ lim_dscfcav1
                               "" @ lim_dsendav1[1]
                               "" @ lim_dsendav1[2]
                               "" @ lim_nrfonres1
                               "" @ lim_dsdemail1
                               "" @ lim_nmcidade1
                               "" @ lim_cdufresd1
                               "" @ lim_nrcepend1
                               "" @ lim_nrendere1
                               "" @ lim_complend1
                               "" @ lim_nrcxapst1
                               WITH FRAME f_dsctit_promissoria1.
                   END.

               FIND NEXT tt-dados-avais NO-LOCK NO-ERROR.
               IF  AVAIL tt-dados-avais  THEN
                   DO:
                       PAUSE MESSAGE "Tecle algo para continuar...".

                       DISPLAY tt-dados-avais.nrctaava    @ lim_nrctaav2 
                               tt-dados-avais.nmdavali    @ lim_nmdaval2
                               tt-dados-avais.nrcpfcgc    @ lim_cpfcgc2
                               tt-dados-avais.tpdocava    @ lim_tpdocav2
                               tt-dados-avais.nrdocava    @ lim_dscpfav2
                               tt-dados-avais.nmconjug    @ lim_nmdcjav2
                               tt-dados-avais.nrcpfcjg    @ lim_cpfccg2
                               tt-dados-avais.tpdoccjg    @ lim_tpdoccj2
                               tt-dados-avais.nrdoccjg    @ lim_dscfcav2
                               tt-dados-avais.dsendre1    @ lim_dsendav2[1]
                               tt-dados-avais.dsendre2    @ lim_dsendav2[2]
                               tt-dados-avais.nrfonres    @ lim_nrfonres2
                               tt-dados-avais.dsdemail    @ lim_dsdemail2
                               tt-dados-avais.nmcidade    @ lim_nmcidade2
                               tt-dados-avais.cdufresd    @ lim_cdufresd2
                               tt-dados-avais.nrcepend    @ lim_nrcepend2
                               tt-dados-avais.nrendere    @ lim_nrendere2
                               tt-dados-avais.complend    @ lim_complend2
                               tt-dados-avais.nrcxapst    @ lim_nrcxapst2
                               WITH FRAME f_dsctit_promissoria2.
                   END.

                  
              /* Pausar o programa para mostrar o ultimo frame */
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   PAUSE.
                   LEAVE.
               END.
                   
               LEAVE CONSULTA.
            
            END.  /*  Fim do DO WHILE TRUE  */
            
            HIDE FRAME f_dsctit_promissoria1 NO-PAUSE.
            HIDE FRAME f_dsctit_promissoria2 NO-PAUSE.
            
         END.  /*  Fim do DO WHILE TRUE  */
       
         HIDE FRAME f_observacao NO-PAUSE.
      
      END. /* Fim do DO WHILE TRUE */

      HIDE FRAME f_rating NO-PAUSE.
   
   END.  /*  Fim do DO WHILE TRUE  */

   HIDE FRAME f_dsctit_rendas NO-PAUSE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_observacao          NO-PAUSE.
HIDE FRAME f_dsctit_promissoria1 NO-PAUSE.
HIDE FRAME f_dsctit_promissoria2 NO-PAUSE. 
HIDE FRAME f_dsctit_rendas       NO-PAUSE.
HIDE FRAME f_dsctit_prolim       NO-PAUSE.
HIDE FRAME f_rating              NO-PAUSE.

/* .......................................................................... */

