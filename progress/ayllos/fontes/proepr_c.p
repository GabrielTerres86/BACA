/* .............................................................................

   Programa: Fontes/proepr_c.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/96.                        Ultima atualizacao: 28/05/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento das consultas das propostas.

   Alteracoes: 19/03/97 - Alterado para tratar FINANCIAMENTO COM HIPOTECA
                          (Edson).

             10/07/2001 - Aumentar a observacao nas propostas de emprestimos.
                          (Eduardo)

             16/12/2002 - Tratar nome e documento do conjuge dos fiadores 
                          (Deborah).
             01/12/2003 - Incluido campo Nivel Risco(Mirtes)

             11/06/2004 - Incluido campo tel_nivcalcul(Risco Calculado(Evandro)
             
             16/06/2004 - Acessar dados Tabela Avalistas Terceiros(Mirtes)
             
             17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

             27/10/2004 - Incluido novos campos: Tipo de chassi, UF placa,
                          UF licenciamento, RENAVAN (Edson). 
                          
             29/08/2005 - Incluido o interveniente anuente na alienacao
                          (Evandro).
                          
             11/01/2006 - Inclusao do proprietario do bem (Evandro).
                          
             03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

             10/02/2006 - Comentado campo ali_uflicenc ref.
                          "UF Licenciamento" (Diego).
             
             14/03/2006 - Corrigido o display do campo da identidade (Evandro).
             
             27/03/2007 - Alterado campos de endereco para buscarem dados da
                          estrutura crapenc (Elton).
                          
             17/06/2009 - Substituida variavel pro_dsdebens por pro_dsrelbem
                          e variavel pro_vloutras por pro_vldrendi (Elton).
             
            06/07/2009 - Cadastro de pessoa fisica e juridica  (Gabriel).
            
            15/12/2009 - Incluir campo Qualif. da operacao (Gabriel)
                       - Mostra valor do campo Qualif. da operacao 
                         automaticamente (Elton).
                         
            21/01/2010 - Alteracoes referente ao projeto CMAPRV 2 (David).

            05/03/2010 - Evitar erro no frame da observacao (Gabriel).

            22/03/2010 - Corrigir erro quando mudança de estado civil
                         (Gabriel).

            27/07/2010 - Projeto de melhorias. Adaptacao para BO 02. 
                        (Gabriel).            

            21/12/2010 - Evitar erros na hora do display (Gabriel).

            13/04/2011 - Alterações devido a CEP integrado. Campos
                         nrendere, complend e nrcxapst na tt-interv-anuentes
                         e tt-dados-avais. (André - DB1)          

            25/11/2011 - Ajuste para a inlusao do campo "Justificativa"
                         (Adriano).             

            26/12/2013 - Exibicao do campo uflicenc no frame f_alienacao
                         (Guilherme/SUPERO)
                         
            13/01/2013 - Ajuste para mostrar avalistas quando houver. (Jorge)
            
            14/07/2014 - Adicionado campos inpessoa e dtnascto no form 
                         f_promissoria (Daniel).
                         
            18/08/2014 - Projeto Automatização de Consultas em Propostas 
                         de Crédito (Jonata-RKAM).
                         
            22/01/2015 - Melhoria Emprestimo, adicionado Tipo Veiculo (dstipbem).
                         (Jorge/Gielow) - SD 241854.
                         
            28/05/2015 - Adicionado parametros na chamada da procedure 
                         obtem-dados-proposta-emprestimo. (Reinert)
............................................................................ */

DEF INPUT PARAM par_nrdconta AS INTE                                 NO-UNDO.
DEF INPUT PARAM par_nrctremp AS INTE                                 NO-UNDO.

{ sistema/generico/includes/var_internet.i }  
{ sistema/generico/includes/b1wgen0069tt.i }

{ includes/var_online.i   }
{ includes/var_bens.i     }
{ includes/var_proepr.i   }
{ includes/var_proposta.i }
{ includes/gg0000.i       }


/* Verifica se o banco generico ja esta conectado */
ASSIGN aux_flggener = f_verconexaogener().


/* Se nao consegui se conectar */
IF   NOT aux_flggener     AND
     NOT f_conectagener() THEN
     RETURN.

RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

RUN obtem-dados-proposta-emprestimo IN h-b1wgen0002
                                   (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT glb_inproces,
                                    INPUT 1, /* Ayllos*/
                                    INPUT par_nrdconta,
                                    INPUT 1, /* Tit.*/
                                    INPUT glb_dtmvtolt,
                                    INPUT par_nrctremp,                                    
                                    INPUT "C", /* Consulta */
                                    INPUT 1,
                                    INPUT FALSE,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dados-coope,
                                    OUTPUT TABLE tt-dados-assoc,
                                    OUTPUT TABLE tt-tipo-rendi,
                                    OUTPUT TABLE tt-itens-topico-rating,
                                    OUTPUT TABLE tt-proposta-epr,
                                    OUTPUT TABLE tt-crapbem,
                                    OUTPUT TABLE tt-bens-alienacao,
                                    OUTPUT TABLE tt-rendimento,
                                    OUTPUT TABLE tt-faturam,
                                    OUTPUT TABLE tt-dados-analise,
                                    OUTPUT TABLE tt-interv-anuentes,
                                    OUTPUT TABLE tt-hipoteca,
                                    OUTPUT TABLE tt-dados-avais,
                                    OUTPUT TABLE tt-aval-crapbem,
                                    OUTPUT TABLE tt-msg-confirma).
DELETE PROCEDURE h-b1wgen0002.

/* Desconectar se nao estava conectado */
IF   NOT aux_flggener  THEN
     RUN p_desconectagener.

IF   RETURN-VALUE <> "OK"   THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.
         ELSE
              MESSAGE "Erro na busca dos dados da proposta.".
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:    
           PAUSE 3 NO-MESSAGE.
           LEAVE.
         END.
         
         RETURN.
     END.

/* Dados gerais da proposta */
FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.
      

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   HIDE FRAME f_tel_fis.
   HIDE FRAME f_tel_jur.
   HIDE FRAME f_observ_comite.
   HIDE FRAME f_observacao.
   HIDE FRAME f_promissoria. 
   HIDE FRAME f_alienacao.
   HIDE FRAME f_hipoteca.
   HIDE FRAME f_analise_proposta.


   DISPLAY tt-proposta-epr.vlemprst  tt-proposta-epr.qtpreemp 
           tt-proposta-epr.nivrisco  tt-proposta-epr.nivcalcu
           tt-proposta-epr.cdlcremp  tt-proposta-epr.cdfinemp 
           tt-proposta-epr.qtdialib  tt-proposta-epr.flgpagto 
           tt-proposta-epr.dtdpagto  tt-proposta-epr.dsctrliq 
           tt-proposta-epr.flgimppr  tt-proposta-epr.flgimpnp
           tt-proposta-epr.vlpreemp  tt-proposta-epr.dslcremp 
           tt-proposta-epr.dsfinemp  tt-proposta-epr.percetop  
           tt-proposta-epr.idquapro  tt-proposta-epr.dsquapro  
           fn_dstpempr(tt-proposta-epr.tpemprst,
                       tt-proposta-epr.cdtpempr,
                       tt-proposta-epr.dstpempr) @ aux_dstpempr
           WITH FRAME f_proepr.

   PAUSE MESSAGE 
         "Pressione algo para continuar - <F4>/<END> para voltar.".
   
   /* mostrar avalistas se houver */
   FIND FIRST tt-dados-avais NO-LOCK NO-ERROR.
   
   IF   AVAIL tt-dados-avais           OR   
        tt-proposta-epr.tplcremp > 1   THEN
        DO:
            PAUSE 0.
                      
            ASSIGN aux_contador = 0
                    tel_qtpromis = tt-proposta-epr.qtpromis.

            /* Avalistas */
            FOR EACH tt-dados-avais NO-LOCK:

                ASSIGN aux_contador = aux_contador + 1.

                DISPLAY tel_qtpromis
                        
                        tt-dados-avais.nrctaava   tt-dados-avais.nmdavali
                        tt-dados-avais.dsnacion   tt-dados-avais.nrcpfcgc    
                        tt-dados-avais.tpdocava   tt-dados-avais.nrdocava 
                        tt-dados-avais.nmconjug   tt-dados-avais.nrcpfcjg 
                        tt-dados-avais.tpdoccjg   tt-dados-avais.nrdoccjg
                        tt-dados-avais.nrcepend   tt-dados-avais.dsendre1
                        tt-dados-avais.nrendere   tt-dados-avais.complend   
                        tt-dados-avais.dsendre2   tt-dados-avais.nrcxapst
                        tt-dados-avais.nmcidade   tt-dados-avais.cdufresd 
                        tt-dados-avais.nrfonres   tt-dados-avais.dsdemail
                        tt-dados-avais.vledvmto   tt-dados-avais.vlrenmes   
                        tt-dados-avais.inpessoa   tt-dados-avais.dtnascto
                                                  WITH FRAME f_promissoria 
                        
                        TITLE COLOR NORMAL " Dados dos Avalistas/Fiadores "
                                           + STRING(aux_contador,"9") + " ". 
                
                PAUSE MESSAGE 
                  "Pressione algo para continuar - <F4>/<END> para voltar.". 

                HIDE FRAME f_promissoria.

                /* Orgaos de protecao ao credito para o avalista */
                RUN fontes/proepr_org.p (INPUT par_nrdconta,
                                         INPUT par_nrctremp,
                                         INPUT aux_contador,
                                         INPUT tt-dados-avais.inpessoa,
                                         INPUT tt-dados-avais.nrctaava,
                                         INPUT tt-dados-avais.nrcpfcgc,
                                         INPUT TABLE tt-itens-topico-rating,
                                         INPUT-OUTPUT TABLE tt-dados-analise).
                       
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

        END.
    
   /* RENDIMENTOS - Dados associado */
   FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.

   IF   tt-proposta-epr.flgimppr   THEN
        DO:
            PAUSE 0.
            
            HIDE FRAME f_observacao    NO-PAUSE.
            HIDE FRAME f_observ_comite NO-PAUSE.

            /* Rendimentos dos cooperados */
            FIND FIRST tt-rendimento NO-LOCK NO-ERROR.

            
            IF   tt-dados-assoc.inpessoa = 1   THEN
                 DO: 
                    ASSIGN aux_dsjusren[1] = SUBSTR(tt-rendimento.dsjusren,1,60)
                           aux_dsjusren[2] = TRIM(SUBSTR(tt-rendimento.dsjusren,61,60))
                           aux_dsjusren[3] = TRIM(SUBSTR(tt-rendimento.dsjusren,121,40)).

                    
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        DISPLAY tt-rendimento.vlsalari
                                tt-rendimento.vloutras
                                
                                tt-rendimento.tpdrendi 
                                tt-rendimento.dsdrendi 
                                tt-rendimento.vldrendi     
                                aux_dsjusren[1]
                                aux_dsjusren[2]
                                aux_dsjusren[3]
                                                          
                                tt-rendimento.vlsalcon 
                                tt-rendimento.nmextemp
                                tt-rendimento.flgdocje 
                                tt-rendimento.vlalugue 
                                tt-rendimento.inconcje WITH FRAME f_tel_fis.

                        PAUSE MESSAGE
                   
                            "Pressione algo para continuar - <F4>/<END> para voltar.".
                        
                        LEAVE.

                     END.                                  
                 END.
            ELSE
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        DISPLAY tt-rendimento.vlmedfat
                                tt-rendimento.perfatcl
                                tt-rendimento.vlalugue
                                WITH FRAME f_tel_jur.

                        PAUSE MESSAGE  
                  "Pressione algo para continuar - <F4>/<END> para voltar.".
                        
                        LEAVE.

                     END.
                 END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.
                 
            OPEN QUERY q-crapbem FOR EACH tt-crapbem NO-LOCK.

            VIEW FRAME f_regua.

            PAUSE 0.

            b-crapbem:HELP = 
                "Pressione algo para continuar - <F4>/<END> para voltar.".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b-crapbem WITH FRAME f_crapbem.
                LEAVE.
            END.
            
            HIDE FRAME f_crapbem.
            HIDE FRAME f_regua.
            HIDE FRAME f_tel_jur.
            HIDE FRAME f_tel_fis. 

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 NEXT.

        END.
    
   IF   tt-proposta-epr.tplcremp = 2    THEN   /*  ALIENACAO  */
        DO:
            FOR EACH tt-bens-alienacao NO-LOCK:

                DISPLAY tt-bens-alienacao.lsbemfin
                        tt-bens-alienacao.dscatbem
                        tt-bens-alienacao.dstipbem
                        tt-bens-alienacao.vlmerbem
                        tt-bens-alienacao.dsbemfin
                        tt-bens-alienacao.dscorbem
                        tt-bens-alienacao.dschassi
                        tt-bens-alienacao.nranobem
                        tt-bens-alienacao.nrmodbem 
                        tt-bens-alienacao.nrdplaca
                        tt-bens-alienacao.nrrenava
                        tt-bens-alienacao.tpchassi
                        tt-bens-alienacao.ufdplaca
                        tt-bens-alienacao.dscpfbem @ tt-bens-alienacao.nrcpfbem
                        tt-bens-alienacao.uflicenc
                        WITH FRAME f_alienacao NO-ERROR.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                  PAUSE MESSAGE 
                    "Pressione algo para continuar - <F4>/<END> para voltar.".
                  LEAVE.
                  
               END.

               HIDE FRAME f_alienacao.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.

            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

            ASSIGN aux_contador = 0.

            /* Interveniente */
            FOR EACH tt-interv-anuentes NO-LOCK:

                HIDE FRAME f_interveniente.

                ASSIGN aux_contador = aux_contador + 1.

                DISPLAY tt-interv-anuentes.nrctaava   
                        tt-interv-anuentes.nmdavali    
                        tt-interv-anuentes.nrcpfcgc 
                        tt-interv-anuentes.tpdocava 
                        tt-interv-anuentes.nrdocava
                        tt-interv-anuentes.dsnacion
                        tt-interv-anuentes.nmconjug 
                        tt-interv-anuentes.nrcpfcjg
                    
                        tt-interv-anuentes.tpdoccjg
                        tt-interv-anuentes.nrdoccjg

                        tt-interv-anuentes.nrcepend
                        tt-interv-anuentes.dsendres[1]
                        tt-interv-anuentes.nrendere   
                        tt-interv-anuentes.complend 
                        tt-interv-anuentes.dsendres[2] 
                        tt-interv-anuentes.nrcxapst
                        tt-interv-anuentes.nmcidade
                        tt-interv-anuentes.cdufresd
                        tt-interv-anuentes.nrfonres
                        tt-interv-anuentes.dsdemail

                WITH FRAME f_interveniente TITLE " Dados do Interveniente " +
                                                 "Anuente " + 
                                                 STRING(aux_contador,"9") + " ".
            END.
            
            HIDE FRAME f_interveniente.
            
        END.
   ELSE
   IF   tt-proposta-epr.tplcremp = 3    THEN  /*  HIPOTECA  */
        DO:
            FOR EACH tt-hipoteca NO-LOCK:

                DISPLAY tt-hipoteca.lsbemfin 
                        tt-hipoteca.dscatbem
                        tt-hipoteca.vlmerbem
                        tt-hipoteca.dsbemfin
                        tt-hipoteca.dscorbem WITH FRAME f_hipoteca NO-ERROR.
                  
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
                   PAUSE MESSAGE 
                    "Pressione algo para continuar - <F4>/<END> para voltar.".
                   LEAVE.
               
                END. 

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                     LEAVE.

            END.
          
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.
                 
        END. /* Fim Hipoteca */
     
   HIDE FRAME f_promissoria   NO-PAUSE. 
   HIDE FRAME f_alienacao     NO-PAUSE.

   /* Dados da analise da proposta */
   FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.

   IF   tt-dados-assoc.inpessoa = 1   THEN /* Pessoa fisica */
        DO:
            tel_nrpatlvr = "Patr. pessoal livre        :". 

            /* Esconde o campo da pessoa juridica */
            tt-dados-analise.nrperger:HIDDEN 
                             IN FRAME f_analise_proposta = TRUE.

            /* Mostra campos da pessoa fisica */
            DISPLAY tt-dados-analise.dtoutris
                    tt-dados-analise.vlsfnout
                    WITH FRAME f_analise_proposta.                   
        END.        
   ELSE                                    /* Pessoa juridica */ 
        DO:
            tel_nrpatlvr = "Patr. garant./sócios s/onus:".

            /* Esconde os campos da pessoa fisica */
            ASSIGN tt-dados-analise.dtoutris:HIDDEN 
                                    IN FRAME f_analise_proposta = TRUE
                
                   tt-dados-analise.vlsfnout:HIDDEN 
                                    IN FRAME f_analise_proposta = TRUE.

            /* Mostrar campos da pessoa juridica */
            DISPLAY tt-dados-analise.nrperger 
                    tt-dados-analise.dsperger
                    WITH FRAME f_analise_proposta.     
        END.
            
   PAUSE 0.                                               

   DISPLAY tt-dados-analise.dtdrisco
           tt-dados-analise.qtopescr
           tt-dados-analise.qtifoper
           tt-dados-analise.vltotsfn
           tt-dados-analise.vlopescr
           tt-dados-analise.vlrpreju 
           tt-dados-analise.nrgarope
           tt-dados-analise.dsgarope
           tt-dados-analise.nrliquid
           tt-dados-analise.dsliquid
           tel_nrpatlvr
           tt-dados-analise.nrpatlvr
           tt-dados-analise.dspatlvr 
           WITH FRAME f_analise_proposta.
                
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      PAUSE MESSAGE "Pressione algo para continuar - <F4>/<END> para voltar.".
      LEAVE.
      
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.

   /* Orgaos de protecao ao credito para o titular e socios (caso haja) */
   RUN fontes/proepr_org.p (INPUT par_nrdconta,
                            INPUT par_nrctremp,
                            INPUT 0,
                            INPUT tt-dados-assoc.inpessoa, 
                            INPUT par_nrdconta,         
                            INPUT 0,
                            INPUT TABLE tt-itens-topico-rating,
                            INPUT-OUTPUT TABLE tt-dados-analise).
     
   /* Se tem que consultar ao conjuge  */
   IF   AVAIL tt-rendimento      AND 
        tt-rendimento.inconcje   THEN
        DO:
            /* Orgaos de protecao ao credito */
            RUN fontes/proepr_org.p (INPUT par_nrdconta,    
                                     INPUT par_nrctremp,    
                                     INPUT 99,
                                     INPUT 1,
                                     INPUT tt-dados-assoc.nrctacje,
                                     INPUT tt-dados-assoc.nrcpfcjg,
                                     INPUT TABLE tt-itens-topico-rating,
                                     INPUT-OUTPUT TABLE tt-dados-analise).
        END.

   /*************************************************************************/
   /* Mostrar campos para visualizacao de observacoes referente a aprovacao */
   /* do comite e observacoes referente a proposta                          */
   /*************************************************************************/

   /* Abrir ambas as observacoes como so leitura */
   ASSIGN tt-proposta-epr.dsobscmt:READ-ONLY IN FRAME f_observ_comite = YES
          tt-proposta-epr.dsobserv:READ-ONLY IN FRAME f_observacao    = YES

          tt-proposta-epr.dsobscmt:HELP = 
            "Pressione <TAB> e <ENTER> p/ continuar - <F4>/<END> p/ voltar."
       
          tt-proposta-epr.dsobserv:HELP = 
            "Pressione <TAB> e <ENTER> p/ continuar - <F4>/<END> p/ voltar.".

   DISPLAY tt-proposta-epr.dsobscmt WITH FRAME f_observ_comite.    
   
   DISPLAY tt-proposta-epr.dsobserv WITH FRAME f_observacao NO-ERROR.


   /* Observacoes */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ENABLE ALL WITH FRAME f_observ_comite.

      WAIT-FOR CHOOSE OF btn_btsaicmt.

      DISABLE ALL WITH FRAME f_observ_comite.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         ENABLE ALL WITH FRAME f_observacao.   
                                               
         WAIT-FOR CHOOSE OF btn_btaosair.

         LEAVE.

      END.
                     
      DISABLE ALL WITH FRAME f_observacao.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           NEXT.
                                      
      LEAVE.

   END. /* Fim observacao */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.
   
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_alienacao        NO-PAUSE.
HIDE FRAME f_hipoteca         NO-PAUSE.
HIDE FRAME f_tel_fis          NO-PAUSE.
HIDE FRAME f_tel_jur          NO-PAUSE.
HIDE FRAME f_promissoria      NO-PAUSE.
HIDE FRAME f_observacao       NO-PAUSE.
HIDE FRAME f_observ_comite    NO-PAUSE.
HIDE FRAME f_proepr           NO-PAUSE.
HIDE FRAME f_analise_proposta NO-PAUSE.


/* ......................................................................... */


