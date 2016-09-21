/* .............................................................................
                                
   Programa: Fontes/deschq_c.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                        Ultima atualizacao: 28/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar o limite de descontos de cheques.

   Alteracoes: 17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               12/01/2006 - Incluido campo Bens (Diego).
    
               06/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               28/03/2007 - Alterado campos de endereco de avalista para
                            receberem dados da estrutura crapenc (Elton).
               
               05/07/2007 - Incluido data de cancelamento na consulta
                            So mostra a data de cancelamento se a situacao
                            estiver como cancelada(Guilherme).

               16/09/2008 - Alterada chave de acesso a tabela crapldc
                            (Gabriel).
                            
               08/12/2009 - Carregar variaveis e mostrar novo frame do rating -
                            frame f_rating (Fernando).
                          - Substituido variavel tel_vlopescr pela variavel 
                            tt-valores-rating.vltotsfn (Elton).   
                            
               14/03/2011 - Substituir campo dsdemail da ass para a crapcem
                            (Gabriel). 
                            
               27/04/2011 - Separação dos avalistas. Inclusão de Campos para
                            CEP integrado. (André - DB1)           
                            
               04/12/2012 - Ajuste para usar a B09 (Adriano).
               
               28/08/2015 - Ajuste na observacao para remover chaves caso venha do banco. 
                            SD 315453 (Kelvin)
                           
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/b1wgen9999tt.i }

DEF INPUT PARAM par_nrctrlim AS INT                                  NO-UNDO.

DEF VAR h-b1wgen0009 AS HANDLE                                       NO-UNDO.
DEF VAR aux_jagravou AS LOG                                          NO-UNDO.

ON 'RETURN' OF btn_btaosair DO:
    
    APPLY "GO".

END.


ASSIGN lim_nmdaval1     = " "
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
       lim_complend1    = " "
       lim_nrcxapst1    = 0

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
       lim_complend2    = " "
       lim_nrcxapst2    = 0
       aux_jagravou     = FALSE.

IF NOT VALID-HANDLE(h-b1wgen0009) THEN
   RUN sistema/generico/procedures/b1wgen0009.p
       PERSISTENT SET h-b1wgen0009.

RUN busca_dados_limite_consulta IN h-b1wgen0009(INPUT glb_cdcooper,
                                                INPUT glb_cdagenci,
                                                INPUT 0, /*nrdcaixa*/
                                                INPUT glb_cdoperad,
                                                INPUT glb_dtmvtolt,
                                                INPUT 1, /*idorigem*/
                                                INPUT tel_nrdconta,
                                                INPUT 1, /*idseqttl*/
                                                INPUT glb_nmdatela,
                                                INPUT par_nrctrlim,
                                                INPUT TRUE,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dscchq_dados_limite,
                                                OUTPUT TABLE tt-dados-avais,
                                                OUTPUT TABLE tt-dados_dscchq ).

IF VALID-HANDLE(h-b1wgen0009) THEN
   DELETE OBJECT h-b1wgen0009.

IF RETURN-VALUE <> "OK" THEN
   DO:
      FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
      IF AVAIL tt-erro THEN
         DO:
            BELL.
            MESSAGE tt-erro.dscritic.
            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE.
            
         END.
      ELSE
         DO:
            BELL.
            MESSAGE "Registro de limite nao encontrado.".
            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE.

         END.
   
      RETURN.
   
   END.


FIND tt-dscchq_dados_limite NO-LOCK NO-ERROR.

CREATE tt-valores-rating.

ASSIGN  tel_nrctrpro = tt-dscchq_dados_limite.nrctrlim
        tel_vllimpro = tt-dscchq_dados_limite.vllimite
        tel_qtdiavig = tt-dscchq_dados_limite.qtdiavig
        tel_cddlinha = tt-dscchq_dados_limite.codlinha
        tel_dsdlinha = tt-dscchq_dados_limite.dsdlinha
        tel_txjurmor = tt-dscchq_dados_limite.txjurmor 
        tel_dsramati = tt-dscchq_dados_limite.dsramati
        tel_vlmedchq = tt-dscchq_dados_limite.vlmedchq
        tel_vlfatura = tt-dscchq_dados_limite.vlfatura
        tel_dsdebens[1] = tt-dscchq_dados_limite.dsdbens1
        tel_dsdebens[2] = tt-dscchq_dados_limite.dsdbens2
        tel_dsobserv    = replace(replace(tt-dscchq_dados_limite.dsobserv,"~{",""),"~}","")
        tel_txdmulta = tt-dscchq_dados_limite.txdmulta
        lim_vloutras = tt-dscchq_dados_limite.vloutras
        lim_vlsalari = tt-dscchq_dados_limite.vlsalari
        lim_vlsalcon = tt-dscchq_dados_limite.vlsalcon
        lim_dtcancel = tt-dscchq_dados_limite.dtcancel
        tt-valores-rating.nrgarope = tt-dscchq_dados_limite.nrgarope
        tt-valores-rating.nrliquid = tt-dscchq_dados_limite.nrliquid
        tt-valores-rating.nrinfcad = tt-dscchq_dados_limite.nrinfcad  
        tt-valores-rating.nrpatlvr = tt-dscchq_dados_limite.nrpatlvr
        tt-valores-rating.nrperger = tt-dscchq_dados_limite.nrperger
        tt-valores-rating.vltotsfn = tt-dscchq_dados_limite.vltotsfn  
        tt-valores-rating.perfatcl = tt-dscchq_dados_limite.perfatcl.
        
 FOR EACH tt-dados-avais NO-LOCK:

    IF aux_jagravou = FALSE THEN
       DO:
          ASSIGN lim_nrctaav1    = tt-dados-avais.nrctaava
                 lim_nmdaval1    = tt-dados-avais.nmdavali  
                 lim_cpfcgc1     = (IF tt-dados-avais.nrctaava > 0 THEN
                                       0
                                    ELSE
                                       tt-dados-avais.nrcpfcgc)
                 lim_tpdocav1    = (IF tt-dados-avais.nrctaava > 0 THEN
                                       " "
                                    ELSE
                                       tt-dados-avais.tpdocava)
                 lim_dscpfav1    = tt-dados-avais.nrdocava
                 lim_nmdcjav1    = tt-dados-avais.nmconjug
                 lim_cpfccg1     = (IF tt-dados-avais.nrctaava > 0 THEN
                                       0
                                    ELSE
                                       tt-dados-avais.nrcpfcjg)
                 lim_tpdoccj1    = (IF tt-dados-avais.nrctaava > 0 THEN
                                       " "
                                    ELSE
                                       tt-dados-avais.tpdoccjg)
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
                 aux_jagravou    = TRUE.

       END.
    ELSE
       DO:
          ASSIGN lim_nrctaav2    = tt-dados-avais.nrctaava 
                 lim_nmdaval2    = tt-dados-avais.nmdavali  
                 lim_cpfcgc2     = (IF tt-dados-avais.nrctaava > 0 THEN
                                       0
                                    ELSE
                                       tt-dados-avais.nrcpfcgc)
                 lim_tpdocav2    = (IF tt-dados-avais.nrctaava > 0 THEN
                                       " "
                                    ELSE
                                       tt-dados-avais.tpdocava)
                 lim_dscpfav2    = tt-dados-avais.nrdocava
                 lim_nmdcjav2    = tt-dados-avais.nmconjug  
                 lim_cpfccg2     = (IF tt-dados-avais.nrctaava > 0 THEN
                                       0
                                    ELSE
                                       tt-dados-avais.nrcpfcjg)
                 lim_tpdoccj2    = (IF tt-dados-avais.nrctaava > 0 THEN
                                       " "
                                    ELSE
                                       tt-dados-avais.tpdoccjg)
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
          
       END.

END.


CONSULTA:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DISPLAY tel_nrctrpro  
           tel_vllimpro  
           tel_qtdiavig
           tel_cddlinha  
           tel_dsdlinha  
           tel_txjurmor 
           tel_txdmulta  
           tel_dsramati  
           tel_vlmedchq
           tel_vlfatura  
           lim_dtcancel
           WITH FRAME f_prolim.

   /*se nao estiver cancelado nao mostrara a data de cancelamento*/
   IF tt-dscchq_dados_limite.insitli <> 3  THEN 
      HIDE lim_dtcancel.
   
   PAUSE MESSAGE "Tecle algo para continuar...".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      DISPLAY lim_vlsalari 
              lim_vlsalcon 
              lim_vloutras 
              tel_dsdebens[1]
              tel_dsdebens[2] 
              WITH FRAME f_rendas.
    
      PAUSE MESSAGE "Tecle algo para continuar...".

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                            crapass.nrdconta = tel_nrdconta  
                            NO-LOCK NO-ERROR.

         IF   crapass.inpessoa = 1  THEN
              DO:
                 HIDE tt-valores-rating.perfatcl IN FRAME f_rating. 
                 HIDE tt-valores-rating.nrperger IN FRAME f_rating.

                 DISPLAY tt-valores-rating.nrgarope 
                         tt-valores-rating.nrinfcad
                         tt-valores-rating.nrliquid 
                         tt-valores-rating.nrpatlvr
                         tt-valores-rating.vltotsfn 
                         WITH FRAME f_rating.

              END.
         ELSE
              DISPLAY tt-valores-rating.nrgarope 
                      tt-valores-rating.nrinfcad
                      tt-valores-rating.nrliquid 
                      tt-valores-rating.nrpatlvr
                      tt-valores-rating.vltotsfn 
                      tt-valores-rating.perfatcl
                      tt-valores-rating.nrperger 
                      WITH FRAME f_rating.
              
         PAUSE MESSAGE "Tecle algo para continuar...".
                             
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
            ASSIGN tel_dsobserv:READ-ONLY IN FRAME f_observacao = YES. 

            UPDATE tel_dsobserv
                   btn_btaosair
                   WITH FRAME f_observacao.
            LEAVE.

         END.

         HIDE FRAME f_observacao NO-PAUSE.

         IF   KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
              NEXT CONSULTA.

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

            LEAVE CONSULTA.
            
         END.  /*  Fim do DO WHILE TRUE  */
            
         HIDE FRAME f_promissoria1 NO-PAUSE.
         HIDE FRAME f_promissoria2 NO-PAUSE.
                           
      END. /* Fim do DO WHILE TRUE */

      HIDE FRAME f_rating NO-PAUSE.

   END.  /*  Fim do DO WHILE TRUE  */

   HIDE FRAME f_rendas NO-PAUSE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_observacao   NO-PAUSE.
HIDE FRAME f_promissoria1 NO-PAUSE.
HIDE FRAME f_promissoria2 NO-PAUSE.
HIDE FRAME f_rating       NO-PAUSE.
HIDE FRAME f_rendas       NO-PAUSE.
HIDE FRAME f_prolim       NO-PAUSE.


/* .......................................................................... */



