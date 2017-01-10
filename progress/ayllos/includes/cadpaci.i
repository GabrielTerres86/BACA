/* .............................................................................

   Programa: Includes/cadpaci.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes   
   Data    : Marco/2004                       Ultima Atualizacao: 18/07/2016
                                                            
   Dados referentes ao programa:    

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela CADPAC(Inclusao PAC)
   
   Alteracao : 07/07/2004 - Acessar tabela GENERI(LOCALIDADE)- Cidade do PAC
                            (Mirtes)

               23/08/2004 - Acrescentar Endereco dos PAC nos talonarios (ZE).

               03/05/2005 - Acrescentar Ag.Relacionamento COBAN/Incluido cod.
                            Cooperativa(Mirtes)
                            
               08/02/2006 - Criar registro na craptab "HRGUIASGPS" e
                            "HRTRDOCTOS" (Evandro).
                            
               10/02/2006 - Unificacao dos bancos de dados - SQLWorks - Andre
               
               10/01/2007 - Incluido novos campos e substituido informacoes 
                            da craptab por dados da crapage (Elton).
                            
               17/01/2007 - Incluido opcao de confirmacao apos inclusao de um
                            novo PAC (Elton).

               25/06/2007 - Modificar inclusao de horario para titulo
                          - Gravar horario para transferencia pela internet
                            (David).

               28/09/2007 - Horario maximo/minimo para pagamentos e transf. 
                            internet deve ser no maximo 23:00 e no minimo 06:00
                            (Guilherme).
                                          
               18/10/2007 - Incluidos os campos Orgao pagador e Agencia 
                            Pioneira (Gabriel). 

               16/11/2007 - Incluido campo para planos de capital (Guilherme).
               
               11/12/2007 - Acerto em criticas e HELPs (Guilherme).
               
               11/02/2008 - Gravar craptab "HRPGTOINSS";
                          - Nao permitir mais fazer update nos horarios para
                            PAC <> 90, criar os registros craptab com o horario
                            padrao conforme o crps359.p (Evandro).

               25/04/2008 - Incluir campos (qtddaglf,qtddlslf) e parametro
                            para segundo processo de agendamentos (David).
                          - Incluido campo "Verificar Pend.COBAN" com
                            informacoes da crapage.vercoban (Elton).
                          - Incluir campos para canc. de pagamentos(Guilherme).
                            
               26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de CHEQUE/DOC/TITULO
                            (Sidnei - Precise).
                            
               30/11/2009 - Incluir campo crapage.vllimapv que armazena o
                            Valor de Aprovacao do Comite Local para crédito
                            (David).

               19/05/2010 - Incluido na tela campo "Envelopes"
                            (Sandro-GATI)
               
               27/05/2010 - Utilizar mesmos tratamentos do PAC 90 nas alteracoes
                            do PAC 91 (Diego).
                            
               11/10/2010 - Incluido o campo "Qtde. Max. de cheques por previa"
                            (Adriano).

               09/11/2010 - Gravar CRAPTAB de truncagem/Compe por Imagem ao
                            incluir um novo PAC (Guilherme/Supero)
                            
               22/02/2011 - Incluir campo 'Regional' (Gabriel).             
               
               10/05/2011 - Incluido campo "Geracao Boletos Registrada"
                            (Adriano).
                            
               09/02/2012 - Retirado os tratamentos de malote, agencia 
                            agrupadora para a inclusao da agencia do PAC
                            (Adriano).       
                            
               24/05/2012 - Removido campo tel_cdagectl e incluido opção para
                            alterar o pac sede.(David Kruger).  
                            
               01/06/2012 - Habilitado o campo "FAX" para edição em todos os PACs 
                           (Lucas).     
                           
               01/04/2013 - Tratamento para evitar Agencias de Pac's repetidas
                            no Sistema CECRED
                          - Inclusao campos convenios SICREDI (Lucas).
                          
               11/04/2013 - Incluir campos tel_vlminsgr, tel_vlmaxsgr, 
                            log_vlminsgr, log_vlmaxsgr no frame f_pac04 
                            (Lucas R.).
                            
               21/06/2013 - Inclusão dos campos tel_tpageins, tel_cdorgins
                            log_tpageins, log_cdorgins no frame f_pac04
                            (Reinert).
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)            
                            
               26/12/2013 - Atualização do campo Processo Manual para utilização
                            da tela DEBSIC (Lucas).
                            
               16/01/2014 - Alterada critica 89 para 962 ao nao informar PA.
                            (Reinert)                             
                            
               24/01/2014 - Permitir que apenas COMPE e TI alterem o Horário
                            de Pagamento SICREDI (Lucas).
                            
               05/03/2014 - Incluso VALIDATE (Daniel). 
               
               08/04/2014 - Ajuste WHOLE-INDEX; adicionado filtro com
                            cdcooper na leitura da temp-table. (Fabricio)
                            
               25/06/2014 - #141385 Log para os horarios das faturas SICREDI
                            (Carlos)
               
               19/08/2015 - Adicionar validacao de horario de 
                            cancelamento/estorno pagamento Sicredi e pagamento
                            convenio proprio. (Lucas Ranghetti #321363)
                            
               26/10/2015 - Conversão Oracle da rotina busca-crapreg da b1wgen0086
                             Adaptação para a nova chamda - Jéssica (DB1)
                             
               03/12/2015 - Ajuste de homologacao referente a conversao
                            realizada pela DB1
                            (Adriano).              
                            
               18/07/2016 - Incluido campo tel_nrtelvoz.
                            PRJ229 - Melhorias OQS (Odirlei - AMcom)   
							
			   08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)          
............................................................................. */
               
IF tel_cdagenci = 0  THEN
   DO:
       ASSIGN glb_cdcritic = 962. 
       RUN fontes/critic.p.
       ASSIGN glb_cdcritic = 0.

       BELL.
       MESSAGE glb_dscritic.
       
       CLEAR FRAME f_pac.
       DISPLAY glb_cddopcao tel_cdagenci WITH FRAME f_pac.
       NEXT.

   END.
     
FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                   crapage.cdagenci = tel_cdagenci 
                   NO-LOCK NO-ERROR.

IF AVAILABLE crapage  THEN
   DO:
       ASSIGN glb_cdcritic = 787. 
       RUN fontes/critic.p.
       ASSIGN glb_cdcritic = 0.

       BELL.
       MESSAGE glb_dscritic.
       
       CLEAR FRAME f_pac.
       DISPLAY glb_cddopcao tel_cdagenci WITH FRAME f_pac.
       NEXT.

   END.

ASSIGN tel_nmextage    = ""
       tel_insitage    = 0
       tel_dssitage    = "EM OBRAS"
       tel_nmresage    = ""
       tel_cdcxaage    = 0
       tel_tpagenci    = 0
       tel_cdccuage    = 0
       tel_cdorgpag    = 0
       tel_cdagecbn    = 0
       tel_vercoban    = TRUE
       tel_cdcomchq    = 0
       tel_cdbantit    = 0
       tel_cdbanchq    = 0
       tel_cdbandoc    = 0
       tel_cdagetit    = 0
       tel_cdagechq    = 0
       tel_cdagedoc    = 0
       tel_flgdsede    = FALSE
       tel_dsendcop    = ""
       tel_nmbairro    = ""
       tel_dscomple    = ""
       tel_nrcepend    = 0
       tel_nmcidade    = ""
       tel_cdufdcop    = ""
       tel_dsdemail    = ""
       tel_dsinform[1] = ""
       tel_dsinform[2] = ""
       tel_dsinform[3] = ""
       tel_hhcapfim    = 0
       tel_mmcapfim    = 0
       tel_hhcapini    = 0
       tel_mmcapini    = 0
       tel_hhtitfim    = 0
       tel_mmtitfim    = 0
       tel_hhtitini    = 0
       tel_mmtitini    = 0
       tel_hhbolini    = 0
       tel_mmbolini    = 0
       tel_hhbolfim    = 0
       tel_mmbolfim    = 0
       tel_flsgproc    = FALSE
       tel_hhcompel    = 0
       tel_mmcompel    = 0
       tel_hhguigps    = 0
       tel_mmguigps    = 0
       tel_hhenvelo    = 0
       tel_mmenvelo    = 0
       tel_hhdoctos    = 0
       tel_mmdoctos    = 0
       tel_hhtrffim    = 0
       tel_mmtrffim    = 0
       tel_hhtrfini    = 0
       tel_mmtrfini    = 0
       tel_hhlimcan    = 0
       tel_mmlimcan    = 0
       tel_nrtelfax    = ""
       tel_nrtelvoz    = ""
       tel_qtddaglf    = 0
       tel_hhsicini    = 0
       tel_mmsicini    = 0
       tel_hhsicfim    = 0
       tel_mmsicfim    = 0
       tel_hhsiccan    = 0
       tel_mmsiccan    = 0
       tel_qtddlslf    = 0
       tel_vllimapv    = 0
       tel_qtchqprv    = 0
       tel_flgdopgd    = FALSE
       tel_cdageagr    = 0
       tel_cddregio    = 0
       tel_dsdregio    = ""
       tel_cdagepac    = 0
       tel_tpageins    = 0
       tel_cdorgins    = 0
       tel_vlminsgr    = 0
       tel_vlmaxsgr    = 0
       aux_hrtitini    = 0 
       aux_hrtitfim    = 0 
       aux_hrtrfini    = 0 
       aux_hrtrffim    = 0 
       aux_hrbolini    = 0 
       aux_hrbolfim    = 0 
       aux_hrcapini    = 0 
       aux_hrcapfim    = 0 
       aux_hrcompel    = 0 
       aux_hrdoctos    = 0 
       aux_hrguigps    = 0 
       aux_hrenvelo    = 0 
       aux_hrcancel    = 0
       log_cdagepac    = tel_cdagepac
       log_nmextage    = tel_nmextage
       log_insitage    = tel_insitage
       log_nmresage    = tel_nmresage
       log_cdcxaage    = tel_cdcxaage
       log_tpagenci    = tel_tpagenci
       log_cdccuage    = tel_cdccuage
       log_cdorgpag    = tel_cdorgpag
       log_cdagecbn    = tel_cdagecbn
       log_vercoban    = tel_vercoban
       log_cdcomchq    = tel_cdcomchq
       log_cdbantit    = tel_cdbantit
       log_cdbanchq    = tel_cdbanchq
       log_cdbandoc    = tel_cdbandoc
       log_cdagetit    = tel_cdagetit
       log_cdagechq    = tel_cdagechq
       log_cdagedoc    = tel_cdagedoc
       log_dsendcop    = tel_dsendcop
       log_nmbairro    = tel_nmbairro
       log_dscomple    = tel_dscomple
       log_nrcepend    = tel_nrcepend
       log_nmcidade    = tel_nmcidade
       log_cdufdcop    = tel_cdufdcop
       log_dsdemail    = tel_dsdemail
       log_dsinform[1] = tel_dsinform[1]
       log_dsinform[2] = tel_dsinform[2]
       log_dsinform[3] = tel_dsinform[3]
       log_hrcapfim    = 0
       log_hrcapini    = 0
       log_hrtitfim    = 0
       log_hrtitini    = 0
       log_hrcompel    = 0
       log_hrguigps    = 0
       log_hrenvelo    = 0
       log_hrdoctos    = 0
       log_hrtrffim    = 0
       log_hrtrfini    = 0
       log_hrbolini    = 0
       log_hrbolfim    = 0
       log_hrcancel    = 0
       log_hhsicini    = ""
       log_hhsicfim    = ""
       log_hhsiccan    = ""
       log_nrtelfax    = tel_nrtelfax
       log_nrtelvoz    = tel_nrtelvoz
       log_qtddaglf    = tel_qtddaglf
       log_qtddlslf    = tel_qtddlslf
       log_flsgproc    = tel_flsgproc
       log_vllimapv    = tel_vllimapv
       log_qtchqprv    = tel_qtchqprv
       log_flgdopgd    = tel_flgdopgd
       log_cdageagr    = tel_cdageagr
       log_cddregio    = 0
       log_tpageins    = tel_tpageins
       log_cdorgins    = tel_cdorgins
       log_vlminsgr    = tel_vlminsgr
       log_vlmaxsgr    = tel_vlmaxsgr.
       
       
DISPLAY tel_nmextage
        tel_insitage
        tel_dssitage
        tel_nmresage
        tel_cdcxaage 
        tel_tpagenci
        tel_cdccuage
        tel_cdorgpag
        tel_cdagecbn
        tel_vercoban
        tel_cdcomchq
        tel_cdbantit 
        tel_cdbanchq
        tel_cdbandoc
        tel_cdagetit
        tel_cdagechq
        tel_cdagedoc
        tel_flgdsede  
        tel_cdagepac
        WITH FRAME f_pac01.
    
DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
        UPDATE tel_nmextage 
               tel_nmresage 
               tel_cdcxaage 
               tel_tpagenci 
               tel_cdccuage 
               tel_cdorgpag 
               tel_cdagecbn 
               tel_cdcomchq 
               tel_vercoban 
               tel_cdbantit 
               tel_cdagetit
               tel_cdbanchq
               tel_cdagechq
               tel_cdbandoc 
               tel_cdagedoc
               tel_flgdsede 
               tel_cdagepac
               WITH FRAME f_pac01.

        IF tel_cdagepac <> 0 THEN
           DO:

            /* Procura se já existe PAC com essa agencia em outras coop */
            FIND crapage WHERE crapage.cdagepac = tel_cdagepac  NO-LOCK NO-ERROR.

            IF  AVAIL crapage THEN
                IF  crapage.cdagenci <> tel_cdagenci THEN
                    DO:
                        MESSAGE "Agencia do PA deve ser unica.".
                        NEXT-PROMPT tel_cdagepac WITH FRAME f_pac01.
                        NEXT.
                    END.

            /* Busca o registro da agencia */
            FIND crapagb WHERE crapagb.cddbanco = crapcop.cdbcoctl   AND
                               crapagb.cdageban = tel_cdagepac
                               NO-LOCK NO-ERROR.

            IF NOT AVAIL crapagb THEN
               DO:
                  BELL.
                  MESSAGE "Agencia do PA nao cadastrada no CAF".

                  NEXT-PROMPT tel_cdagepac WITH FRAME f_pac01.
                  NEXT.

               END.

            /* Verifica a cidade da agencia */
            FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapcaf  THEN
                DO:
                   BELL.
                   MESSAGE "Agencia do PA nao cadastrada no CAF.".

                   NEXT-PROMPT tel_cdagepac WITH FRAME f_pac01.
                   NEXT.

                END.
           END.

        DISPLAY tel_dsendcop
                tel_nmbairro
                tel_dscomple
                tel_nrcepend
                tel_nmcidade
                tel_cdufdcop
                tel_dsdemail
                tel_dsinform[1]
                tel_dsinform[2]
                tel_dsinform[3]
                WITH FRAME f_pac02.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           UPDATE tel_dsendcop 
                  tel_nmbairro 
                  tel_dscomple 
                  tel_nrcepend 
                  tel_nmcidade 
                  tel_cdufdcop 
                  tel_dsdemail 
                  tel_dsinform[1]
                  tel_dsinform[2]
                  tel_dsinform[3]
                  WITH FRAME f_pac02.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               DISPLAY tel_hhtitini
                       tel_mmtitini
                       tel_hhtitfim
                       tel_mmtitfim
                       tel_hhbolini
                       tel_mmbolini
                       tel_hhbolfim
                       tel_mmbolfim
                       tel_hhcompel
                       tel_mmcompel
                       tel_hhcapini
                       tel_mmcapini
                       tel_hhcapfim
                       tel_mmcapfim
                       tel_hhdoctos
                       tel_mmdoctos
                       tel_hhtrfini
                       tel_mmtrfini 
                       tel_hhtrffim
                       tel_mmtrffim
                       tel_hhguigps
                       tel_mmguigps
                       tel_hhenvelo
                       tel_mmenvelo
                       tel_hhlimcan
                       tel_mmlimcan
                       tel_nrtelvoz
                       tel_nrtelfax
                       tel_qtddaglf
                       tel_qtddlslf
                       tel_flsgproc
                       tel_hhsicini
                       tel_mmsicini
                       tel_hhsicfim
                       tel_mmsicfim
                       tel_hhsiccan
                       tel_mmsiccan
                       WITH FRAME f_pac03.
                         
               ASSIGN tel_hhtitini:HELP = "Informe a hora inicial do " +
                                              "limite (00:00 a 22:59)." 
                      tel_hhtitfim:HELP = "Informe a hora final do " +
                                              "limite (00:00 a 23:00)."
                      tel_hhcompel:HELP = "Informe a hora limite" +
                                              " (00:00 a 23:00)."
                      tel_hhdoctos:HELP = "Informe a hora limite" +
                                              " (00:00 a 23:00)."
                      tel_hhguigps:HELP = "Informe a hora limite" + 
                                              " (00:00 a 23:00)."
                      tel_hhenvelo:HELP = "Informe a hora limite" + 
                                              " (00:00 a 23:00).".

               IF  glb_cddepart = 20   OR  /* TI */
                   glb_cddepart = 4  THEN  /* COMPE */
                   DO:
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:          
                          
                          UPDATE tel_hhsicini
                                 tel_mmsicini
                                 tel_hhsicfim
                                 tel_mmsicfim
                                 WITH FRAME f_pac03.
                       
                          IF tel_hhsicini = 0 AND tel_mmsicini = 0  AND
                             tel_hhsicfim = 0 AND tel_mmsicfim = 0  THEN
                             DO:
                                 MESSAGE "Horario para pagamento SICREDI nao pode ser nulo.".
                                 NEXT.
                             END.
                       
                          IF ((tel_hhsicini * 3600) + (tel_mmsicini * 60)) >=
                             ((tel_hhsicfim * 3600) + (tel_mmsicfim * 60)) THEN
                             DO:
                                 ASSIGN glb_cdcritic = 687.
                                 RUN fontes/critic.p.
                                 ASSIGN glb_cdcritic = 0.
                           
                                 BELL.
                                 MESSAGE glb_dscritic.
                              
                                 NEXT.
                           
                             END.
                       
                          LEAVE.          
                       
                       END.
                       
                       IF KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN
                          LEAVE.
                   END.

               IF tel_cdagenci = 90 OR tel_cdagenci = 91 THEN
                  DO:
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                         UPDATE tel_hhtitini
                                tel_mmtitini
                                tel_hhtitfim
                                tel_mmtitfim
                                WITH FRAME f_pac03.
                         
                         IF tel_hhtitini = 0 AND tel_mmtitini = 0  AND
                            tel_hhtitfim = 0 AND tel_mmtitfim = 0  THEN
                            LEAVE.
                           
                         IF tel_hhtitini < 0 OR tel_hhtitini > 23  THEN
                            DO:
                                ASSIGN glb_cdcritic = 687.
                                RUN fontes/critic.p.
                                ASSIGN glb_cdcritic = 0.
                            
                                BELL.
                                MESSAGE glb_dscritic.
                                
                                DISPLAY tel_hhtitini WITH FRAME f_pac03.
                                NEXT-PROMPT tel_hhtitini WITH FRAME f_pac03.
                                NEXT.

                            END.
                             
                        IF tel_hhtitfim < 0 OR tel_hhtitfim > 23  THEN
                           DO:
                               ASSIGN glb_cdcritic = 687.
                               RUN fontes/critic.p.
                               ASSIGN glb_cdcritic = 0.
                           
                               BELL.
                               MESSAGE glb_dscritic.
                               
                               DISPLAY tel_hhtitfim WITH FRAME f_pac03.
                               NEXT-PROMPT tel_hhtitfim WITH FRAME f_pac03.
                               NEXT.

                           END.    
                       
                        IF tel_hhtitfim = 23 AND tel_mmtitfim > 0  THEN
                           DO:
                               ASSIGN glb_cdcritic = 687.
                               RUN fontes/critic.p.
                               ASSIGN glb_cdcritic = 0.
                          
                               BELL.
                               MESSAGE glb_dscritic.
                               
                               DISPLAY tel_hhtitfim WITH FRAME f_pac03.
                               NEXT-PROMPT tel_hhtitfim WITH FRAME f_pac03.
                               NEXT.

                           END.
                             
                        IF tel_mmtitini > 59  THEN
                           DO:
                               ASSIGN glb_cdcritic = 687.
                               RUN fontes/critic.p.
                               ASSIGN glb_cdcritic = 0.
                               
                               BELL.
                               MESSAGE glb_dscritic.
                               
                               DISPLAY tel_mmtitini WITH FRAME f_pac03.
                               NEXT-PROMPT tel_mmtitini WITH FRAME f_pac03.
                               NEXT.

                           END.
                            
                        IF tel_mmtitfim > 59  THEN
                           DO:
                               ASSIGN glb_cdcritic = 687.
                               RUN fontes/critic.p.
                               ASSIGN glb_cdcritic = 0.
                              
                               BELL.
                               MESSAGE glb_dscritic.
                               
                               DISPLAY tel_mmtitfim WITH FRAME f_pac03.
                               NEXT-PROMPT tel_mmtitfim WITH FRAME f_pac03.
                               NEXT.

                           END.
                            
                        IF ((tel_hhtitini * 3600) + (tel_mmtitini * 60))  >= 
                           ((tel_hhtitfim * 3600) + (tel_mmtitfim * 60))  THEN
                           DO:
                               ASSIGN glb_cdcritic = 687.
                               RUN fontes/critic.p.
                               ASSIGN glb_cdcritic = 0.
                               
                               BELL.
                               MESSAGE glb_dscritic.
                               
                               DISPLAY tel_hhtitini WITH FRAME f_pac03.
                               NEXT-PROMPT tel_hhtitini WITH FRAME f_pac03.
                               NEXT.

                           END.        
                             
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           UPDATE tel_hhcompel
                                  tel_mmcompel 
                                  WITH FRAME f_pac03.
                      
                           IF tel_hhcompel = 0 AND tel_mmcompel = 0  THEN
                              LEAVE.
                      
                           IF tel_hhcompel < 0 OR tel_hhcompel > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                             
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhcompel WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhcompel 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                     
                           IF tel_hhcompel = 23 AND tel_mmcompel > 0  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                  
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhcompel WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhcompel 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                                
                           IF tel_mmcompel > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                 
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_mmcompel WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmcompel 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
             
                           LEAVE.
                            
                        END. /** Fim do DO WHILE TRUE **/
                 
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.
                            
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           UPDATE tel_hhcapini
                                  tel_mmcapini
                                  tel_hhcapfim
                                  tel_mmcapfim
                                  WITH FRAME f_pac03.
                          
                           IF tel_hhcapini = 0 AND tel_mmcapini = 0  AND
                              tel_hhcapfim = 0 AND tel_mmcapfim = 0  THEN
                              LEAVE.
                               
                           IF tel_hhcapini < 6 OR tel_hhcapini > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                  
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhcapini WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhcapini 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                               
                           IF tel_hhcapfim < 6 OR tel_hhcapfim > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                  
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhcapfim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhcapfim 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                                
                           IF tel_hhcapfim = 23 AND tel_mmcapfim > 0  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                  
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhcapfim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhcapfim 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.         
                               
                           IF tel_mmcapini > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                  
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_mmcapini WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmcapini 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                               
                           IF tel_mmcapfim > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                             
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_mmcapfim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmcapfim 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                              
                           IF ((tel_hhcapini * 3600) + (tel_mmcapini * 60)) >=
                              ((tel_hhcapfim * 3600) + (tel_mmcapfim * 60)) 
                              THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                    
                                  BELL.
                                  MESSAGE glb_dscritic.
                               
                                  DISPLAY tel_hhcapini WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhcapini 
                                           WITH FRAME f_pac03.
                                  NEXT.

                              END.
                  
                           LEAVE.
                            
                        END. /** Fim do DO WHILE TRUE **/
                  
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.
                            
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           UPDATE tel_hhdoctos
                                  tel_mmdoctos
                                  WITH FRAME f_pac03.
                       
                           IF tel_hhdoctos = 0 AND tel_mmdoctos = 0  THEN
                              LEAVE.
                       
                           IF tel_hhdoctos < 0 OR tel_hhdoctos > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                              
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhdoctos WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhdoctos 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                               
                           IF tel_hhdoctos = 23 AND tel_mmdoctos > 0  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                  
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhdoctos WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhdoctos 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                                
                           IF tel_mmdoctos > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                        
                                  BELL.
                                  MESSAGE glb_dscritic.
                                   
                                  DISPLAY tel_mmdoctos WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmdoctos 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                   
                           LEAVE.
                            
                        END. /** Fim do DO WHILE TRUE **/
                   
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.
                            
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           UPDATE tel_hhtrfini
                                  tel_mmtrfini
                                  tel_hhtrffim
                                  tel_mmtrffim
                                  WITH FRAME f_pac03.
                              
                           IF tel_hhtrfini = 0 AND tel_mmtrfini = 0  AND
                              tel_hhtrffim = 0 AND tel_mmtrffim = 0  THEN
                              LEAVE.
                              
                           IF tel_hhtrfini < 6 OR tel_hhtrfini > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                   
                                  BELL.
                                  MESSAGE glb_dscritic.
                               
                                  DISPLAY tel_hhtrfini WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhtrfini 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                              
                           IF tel_hhtrffim < 6 OR tel_hhtrffim > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                              
                                  BELL.
                                  MESSAGE glb_dscritic.
                               
                                  DISPLAY tel_hhtrffim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhtrffim 
                                           WITH FRAME f_pac03.
                                  NEXT.

                              END.
                                
                           IF tel_hhtrffim = 23 AND tel_mmtrffim > 0  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                    
                                  BELL.
                                  MESSAGE glb_dscritic.
                               
                                  DISPLAY tel_hhtrffim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhtrffim 
                                           WITH FRAME f_pac03.
                                  NEXT.

                              END.         
                              
                           IF tel_mmtrfini > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                       
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_mmtrfini WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmtrfini 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                             
                           IF tel_mmtrffim > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                              
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_mmtrffim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmtrffim 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                              
                           IF ((tel_hhtrfini * 3600) + (tel_mmtrfini * 60)) >=
                              ((tel_hhtrffim * 3600) + (tel_mmtrffim * 60))  
                              THEN
                                   DO:
                                       ASSIGN glb_cdcritic = 687.
                                       RUN fontes/critic.p.
                                       ASSIGN glb_cdcritic = 0.
                            
                                       BELL.
                                       MESSAGE glb_dscritic.
                                       
                                       DISPLAY tel_hhtrfini WITH FRAME f_pac03.
                                       NEXT-PROMPT tel_hhtrfini 
                                                   WITH FRAME f_pac03.
                                       NEXT.

                                   END.
                    
                           LEAVE.
                            
                        END. /** Fim do DO WHILE TRUE **/
                    
                        
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.
                            
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            
                           UPDATE tel_hhguigps
                                  tel_mmguigps 
                                  WITH FRAME f_pac03.
                               
                           IF tel_hhguigps = 0 AND tel_mmguigps = 0  THEN
                              LEAVE.
                               
                           IF tel_hhguigps < 0 OR tel_hhguigps > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                       
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhguigps WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhguigps WITH FRAME f_pac03.
                                  NEXT.

                              END.
                               
                           IF tel_hhguigps = 23 AND tel_mmguigps > 0  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                       
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_hhguigps WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhguigps 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                                
                            IF tel_mmguigps > 59  THEN
                               DO:
                                   ASSIGN glb_cdcritic = 687.
                                   RUN fontes/critic.p.
                                   ASSIGN glb_cdcritic = 0.
                        
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   
                                   DISPLAY tel_mmguigps WITH FRAME f_pac03.
                                   NEXT-PROMPT tel_mmguigps 
                                               WITH FRAME f_pac03.
                                   NEXT.

                               END.
                    
                            LEAVE.
                            
                        END. /** Fim do DO WHILE TRUE **/
                    
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                           LEAVE.
             
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            
                           UPDATE tel_hhbolini
                                  tel_mmbolini
                                  tel_hhbolfim
                                  tel_mmbolfim
                                  WITH FRAME f_pac03.
                              
                           IF tel_hhbolini = 0 AND tel_mmbolini = 0  AND
                              tel_hhbolfim = 0 AND tel_mmbolfim = 0  THEN
                              LEAVE.
                              
                           IF tel_hhbolini < 6 OR tel_hhbolini > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                   
                                  BELL.
                                  MESSAGE glb_dscritic.
                               
                                  DISPLAY tel_hhbolini WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhbolini 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                              
                           IF tel_hhbolfim < 6 OR tel_hhbolfim > 23  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                              
                                  BELL.
                                  MESSAGE glb_dscritic.
                               
                                  DISPLAY tel_hhbolfim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhbolfim 
                                           WITH FRAME f_pac03.
                                  NEXT.

                              END.
                                
                           IF tel_hhbolfim = 23 AND tel_mmbolfim > 0  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                    
                                  BELL.
                                  MESSAGE glb_dscritic.
                               
                                  DISPLAY tel_hhbolfim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_hhbolfim 
                                           WITH FRAME f_pac03.
                                  NEXT.

                              END.         
                              
                           IF tel_mmbolini > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                       
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_mmbolini WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmbolini 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                             
                           IF tel_mmbolfim > 59  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 687.
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                              
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  
                                  DISPLAY tel_mmbolfim WITH FRAME f_pac03.
                                  NEXT-PROMPT tel_mmbolfim 
                                              WITH FRAME f_pac03.
                                  NEXT.

                              END.
                              
                           IF ((tel_hhbolini * 3600) + (tel_mmbolini * 60)) >=
                              ((tel_hhbolfim * 3600) + (tel_mmbolfim * 60))  
                              THEN
                                   DO:
                                       ASSIGN glb_cdcritic = 687.
                                       RUN fontes/critic.p.
                                       ASSIGN glb_cdcritic = 0.
                            
                                       BELL.
                                       MESSAGE glb_dscritic.
                                       
                                       DISPLAY tel_hhbolini WITH FRAME f_pac03.
                                       NEXT-PROMPT tel_hhbolini 
                                                   WITH FRAME f_pac03.
                                       NEXT.

                                   END.
                    
                           LEAVE.
                            
                        END. /** Fim do DO WHILE TRUE **/
                    
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE tel_hhenvelo
                                   tel_mmenvelo 
                                   WITH FRAME f_pac03.
                           
                            IF tel_hhenvelo = 0 AND tel_mmenvelo = 0  THEN
                               LEAVE.
                                
                            IF tel_hhenvelo < 0 OR tel_hhenvelo > 23  THEN
                               DO:
                                   ASSIGN glb_cdcritic = 687.
                                   RUN fontes/critic.p.
                                   ASSIGN glb_cdcritic = 0.
                        
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   
                                   DISPLAY tel_hhenvelo WITH FRAME f_pac03.
                                   NEXT-PROMPT tel_hhenvelo 
                                               WITH FRAME f_pac03.
                                   NEXT.

                               END.
                           
                            IF tel_hhenvelo = 23 AND tel_mmenvelo > 0  THEN
                               DO:
                                   ASSIGN glb_cdcritic = 687.
                                   RUN fontes/critic.p.
                                   ASSIGN glb_cdcritic = 0.
                        
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   
                                   DISPLAY tel_hhenvelo WITH FRAME f_pac03.
                                   NEXT-PROMPT tel_hhenvelo 
                                               WITH FRAME f_pac03.
                                   NEXT.

                               END.
                            
                            IF tel_mmenvelo > 59  THEN
                               DO:
                                   ASSIGN glb_cdcritic = 687.
                                   RUN fontes/critic.p.
                                   ASSIGN glb_cdcritic = 0.
                        
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   
                                   DISPLAY tel_mmenvelo WITH FRAME f_pac03.
                                   NEXT-PROMPT tel_mmenvelo 
                                               WITH FRAME f_pac03.
                                   NEXT.

                               END.
                    
                            LEAVE.
                        
                        END. /** Fim do DO WHILE TRUE **/
                    
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.
                    
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE tel_hhlimcan
                                   tel_mmlimcan
                                   WITH FRAME f_pac03.
                          
                            IF tel_hhlimcan = 0 AND tel_mmlimcan = 0  THEN
                               LEAVE.
                                
                            IF tel_hhlimcan < 0 OR tel_hhlimcan > 23  THEN
                               DO:
                                   ASSIGN glb_cdcritic = 687.
                                   RUN fontes/critic.p.
                                   ASSIGN glb_cdcritic = 0.
                        
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   
                                   DISPLAY tel_hhlimcan WITH FRAME f_pac03.
                                   NEXT-PROMPT tel_hhlimcan 
                                               WITH FRAME f_pac03.
                                   NEXT.

                               END.
                          
                            IF tel_mmlimcan > 59  THEN
                               DO:
                                   ASSIGN glb_cdcritic = 687.
                                   RUN fontes/critic.p.
                                   ASSIGN glb_cdcritic = 0.
                        
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   
                                   DISPLAY tel_mmlimcan WITH FRAME f_pac03.
                                   NEXT-PROMPT tel_mmlimcan 
                                               WITH FRAME f_pac03.
                                   NEXT.

                               END.
                          
                            FIND craphec WHERE craphec.cdcooper = glb_cdcooper AND
                                         CAPS(craphec.dsprogra) = CAPS("TAA E INTERNET")
                                         NO-LOCK NO-ERROR.

                            IF AVAIL craphec THEN
                               DO:
                                  /* Horario de cancelamento deve ser menor que o 
                                     parametrizado na tela hrcomp */
                                  IF  ((tel_hhlimcan * 3600) + (tel_mmlimcan * 60)) >= 
                                       craphec.hriniexe THEN
                                      DO:
                                          ASSIGN glb_cdcritic = 687.
                                          RUN fontes/critic.p.
                                          ASSIGN glb_cdcritic = 0.
                               
                                          BELL.
                                          MESSAGE glb_dscritic.
                                          
                                          DISPLAY tel_hhlimcan WITH FRAME f_pac03.
                                          NEXT-PROMPT tel_hhlimcan WITH FRAME f_pac03.
                                          NEXT.
                                      END.
                               END.
                    
                            LEAVE.
                                
                        END. /** Fim do DO WHILE TRUE **/
                    
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.

                        IF  glb_cddepart = 20   OR  /* TI */
                            glb_cddepart = 4  THEN  /* COMPE */
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   UPDATE tel_nrtelvoz WITH FRAME f_pac03.
                                   LEAVE.
                                END.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                              
                                  UPDATE tel_hhsiccan
                                         tel_mmsiccan
                                         WITH FRAME f_pac03.
       
                                  IF  tel_hhsiccan = 0 AND tel_mmsiccan = 0  THEN
                                      DO:
                                          MESSAGE "Horario para cancelamento de pgto. SICREDI nao pode ser nulo.".
                                          NEXT.
                                      END.
                                
                                  /* Horario limite para cancelamento de pagamento Sicredi 19:24 */
                                  IF ((tel_hhsiccan * 3600) + (tel_mmsiccan * 60)) >= 69900 THEN
                                      DO:
                                          ASSIGN glb_cdcritic = 687.
                                          RUN fontes/critic.p.
                                          ASSIGN glb_cdcritic = 0.
                                      
                                          BELL.
                                          MESSAGE glb_dscritic.
                                       
                                          NEXT.
                                      
                                      END.   
                                
                                  LEAVE.
                                      
                                END. /** Fim do DO WHILE TRUE **/

                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   UPDATE tel_nrtelfax WITH FRAME f_pac03.
                                   LEAVE.
                                END.
                            END.
                        ELSE
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               UPDATE tel_nrtelvoz
                                      tel_nrtelfax WITH FRAME f_pac03.
                               LEAVE.
                            END.
                    
                       IF KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN
                          LEAVE.
                            
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE tel_qtddaglf
                                   tel_qtddlslf
                                   tel_flsgproc 
                                   WITH FRAME f_pac03.
                        
                            LEAVE.
                        
                        END. /** Fim do DO WHILE TRUE **/
                    
                        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                           LEAVE.
                    
                        LEAVE.
                     
                      END. /** Fim do DO WHILE TRUE **/
                    
                      IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                         LEAVE.
                  
                  END. /* Fim PAC 90,91 */
             ELSE
                DO:
                    IF  glb_cddepart = 20   OR  /* TI */
                        glb_cddepart = 4  THEN  /* COMPE */
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               UPDATE tel_nrtelvoz WITH FRAME f_pac03.
                               LEAVE.
                            END.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                              UPDATE tel_hhsiccan
                                     tel_mmsiccan
                                     WITH FRAME f_pac03.
                  
                              IF  tel_hhsiccan = 0 AND tel_mmsiccan = 0  THEN
                                  DO:
                                      MESSAGE "Horario para cancelamento de pgto. SICREDI nao pode ser nulo.".
                                      NEXT.
                                  END.
                                  
                              /* Horario limite para cancelamento de pagamento Sicredi 19:24 */
                              IF ((tel_hhsiccan * 3600) + (tel_mmsiccan * 60)) >= 69900 THEN
                                  DO:
                                      ASSIGN glb_cdcritic = 687.
                                      RUN fontes/critic.p.
                                      ASSIGN glb_cdcritic = 0.
                                  
                                      BELL.
                                      MESSAGE glb_dscritic.
                                   
                                      NEXT.
                                  
                                  END.  
                            
                              LEAVE.
                                  
                            END. /** Fim do DO WHILE TRUE **/

                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               UPDATE tel_nrtelfax WITH FRAME f_pac03.
                               LEAVE.
                            END.
                        END.
                    ELSE
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           UPDATE tel_nrtelvoz
                                  tel_nrtelfax WITH FRAME f_pac03.
                           LEAVE.
                        END.
                END.

               IF KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN
                  LEAVE.
               
               HIDE FRAME f_pac03.

               RUN Busca_Crapreg.

               IF RETURN-VALUE <> "OK" THEN
                  NEXT.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  DISPLAY tel_qtchqprv WITH FRAME f_pac04.

                  UPDATE tel_qtchqprv
                         tel_cddregio
                         tel_tpageins
                         tel_cdorgins
                         tel_vlminsgr
                         tel_vlmaxsgr
                         WITH FRAME f_pac04
                  
                   EDITING:

                      READKEY.

                      IF FRAME-FIELD = "tel_cddregio" THEN
                         IF LAST-KEY = KEYCODE("F7")     THEN
                            DO:
                                OPEN QUERY q-crapreg FOR EACH tt-crapreg
                                     WHERE tt-crapreg.cdcooper = glb_cdcooper 
                                           NO-LOCK.
                            
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    UPDATE b-crapreg WITH FRAME f_crapreg.
                                    LEAVE.
                                END.
                            
                                HIDE FRAME f_crapreg.
                            
                            END.
                         ELSE
                            APPLY LASTKEY.
                      ELSE
                         APPLY LASTKEY.
                     
                   END. /* Fim do EDITING */
                   
                   LEAVE.
               END.

               IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.

               LEAVE.

           END. /** Fim DO WHILE TRUE **/

           IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
              NEXT.

           LEAVE.

        END. /** Fim do DO WHILE TRUE **/
  
        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
           NEXT.
  
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       UNDO, LEAVE.

    RUN fontes/confirma.p (INPUT "",
                           OUTPUT aux_confirma).

    IF aux_confirma <> "S"  THEN
       UNDO, LEAVE.                

    CREATE crapage.

    ASSIGN crapage.cdcooper    = glb_cdcooper
           crapage.cdagenci    = tel_cdagenci                  
           crapage.nmextage    = CAPS(tel_nmextage)
           crapage.nmresage    = CAPS(tel_nmresage)
           crapage.cdcxaage    = tel_cdcxaage
           crapage.tpagenci    = tel_tpagenci
           crapage.cdccuage    = tel_cdccuage
           crapage.cdorgpag    = tel_cdorgpag
           crapage.cdagecbn    = tel_cdagecbn
           crapage.vercoban    = tel_vercoban 
           crapage.cdcomchq    = tel_cdcomchq
           crapage.cdbantit    = tel_cdbantit          
           crapage.cdbanchq    = tel_cdbanchq
           crapage.cdbandoc    = tel_cdbandoc
           crapage.cdagetit    = tel_cdagetit
           crapage.cdagechq    = tel_cdagechq
           crapage.cdagedoc    = tel_cdagedoc
           crapage.dsendcop    = CAPS(tel_dsendcop)
           crapage.nmbairro    = CAPS(tel_nmbairro)
           crapage.dscomple    = CAPS(tel_dscomple)
           crapage.nrcepend    = tel_nrcepend
           crapage.nmcidade    = CAPS(tel_nmcidade)
           crapage.cdufdcop    = CAPS(tel_cdufdcop)
           crapage.dsdemail    = tel_dsdemail
           crapage.dsinform[1] = tel_dsinform[1]
           crapage.dsinform[2] = tel_dsinform[2]
           crapage.dsinform[3] = tel_dsinform[3]
           crapage.nrordage    = crapage.cdagenci
           crapage.cddsenha    = STRING(crapage.cdagenci)
           crapage.dtaltsnh    = TODAY
           crapage.qtchqprv    = tel_qtchqprv
           crapage.cddregio    = tel_cddregio
           crapage.flgdsede    = tel_flgdsede 
           crapage.cdagepac    = tel_cdagepac
           crapage.nrtelfax    = tel_nrtelfax
           crapage.nrtelvoz    = tel_nrtelvoz
           crapage.tpageins    = tel_tpageins
           crapage.cdorgins    = tel_cdorgins
           crapage.vlminsgr    = tel_vlminsgr
           crapage.vlmaxsgr    = tel_vlmaxsgr.
    VALIDATE crapage.

    /* Param. horarios SICREDI */
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRPGSICRED" AND
                       craptab.tpregist = tel_cdagenci 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            CREATE craptab.
            ASSIGN craptab.cdcooper = glb_cdcooper
                   craptab.nmsistem = "CRED"        
                   craptab.tptabela = "GENERI"      
                   craptab.cdempres = 00            
                   craptab.cdacesso = "HRPGSICRED"
                   craptab.tpregist = tel_cdagenci
                   craptab.dstextab = STRING((tel_hhsicini * 3600) + (tel_mmsicini * 60))   + " " +
                                      STRING((tel_hhsicfim * 3600) + (tel_mmsicfim * 60))   + " " +
                                      STRING((tel_hhsiccan * 3600) + (tel_mmsiccan * 60))
                   aux_hhsicini = STRING(tel_hhsicini, "99") + ":" + STRING(tel_mmsicini, "99")
                   aux_hhsicfim = STRING(tel_hhsicfim, "99") + ":" + STRING(tel_mmsicfim, "99")
                   aux_hhsiccan = STRING(tel_hhsiccan, "99") + ":" + STRING(tel_mmsiccan, "99").
            VALIDATE craptab.

            /* Processo Manual - Sicredi */
            ASSIGN SUBSTRING(craptab.dstextab,19,3) = STRING(tel_flsgproc,"SIM/NAO").
        END.
      
    IF tel_cdagenci = 90 OR tel_cdagenci = 91 THEN
       DO:
           ASSIGN aux_hrcancel     = (tel_hhlimcan * 3600) + 
                                     (tel_mmlimcan * 60)
                  crapage.hrcancel = aux_hrcancel
                  crapage.qtddaglf = tel_qtddaglf
                  crapage.qtddlslf = tel_qtddlslf.
                  
                                              
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "GENERI"     AND
                              craptab.cdempres = 00           AND
                              craptab.cdacesso = "HRPLANCAPI" AND
                              craptab.tpregist = tel_cdagenci
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
           IF NOT AVAILABLE craptab  THEN
              DO:
                  CREATE craptab.

                  ASSIGN craptab.cdcooper = glb_cdcooper
                         craptab.nmsistem = "CRED"        
                         craptab.tptabela = "GENERI"      
                         craptab.cdempres = 00            
                         craptab.cdacesso = "HRPLANCAPI"  
                         craptab.tpregist = tel_cdagenci.
                  VALIDATE craptab.
              END.
      
           ASSIGN aux_hrcapini = 21600
                  aux_hrcapfim = 64800
                  aux_cdsituac = 1 /* Processado */
                  craptab.dstextab = STRING(aux_cdsituac,"9") +
                                     " " + 
                                     STRING(aux_hrcapfim,"99999") + 
                                     " " +
                                     STRING(aux_hrcapini,"99999").     
                                    
    
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "GENERI"     AND
                              craptab.cdempres = 00           AND
                              craptab.cdacesso = "HRTRANSFER" AND
                              craptab.tpregist = tel_cdagenci
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
           IF NOT AVAILABLE craptab  THEN
              DO:
                  CREATE craptab.

                  ASSIGN craptab.cdcooper = glb_cdcooper
                         craptab.nmsistem = "CRED"        
                         craptab.tptabela = "GENERI"      
                         craptab.cdempres = 00            
                         craptab.cdacesso = "HRTRANSFER"  
                         craptab.tpregist = tel_cdagenci.
                  VALIDATE craptab.
              END.           
    
           ASSIGN aux_hrtrfini = 21600
                  aux_hrtrffim = 64800
                  aux_cdsituac = 1 /* Processado */
                  craptab.dstextab = STRING(aux_cdsituac,"9") + 
                                     " " + 
                                     STRING(aux_hrtrffim,"99999") + 
                                     " " +
                                     STRING(aux_hrtrfini,"99999") + 
                                     " " +
                                     STRING(tel_flsgproc,"SIM/NAO").

           FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "GENERI"     AND
                              craptab.cdempres = 00           AND
                              craptab.cdacesso = "HRCOBRANCA" AND
                              craptab.tpregist = tel_cdagenci
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
           IF NOT AVAILABLE craptab  THEN
              DO: 
                  CREATE craptab.

                  ASSIGN craptab.cdcooper = glb_cdcooper
                         craptab.nmsistem = "CRED"        
                         craptab.tptabela = "GENERI"      
                         craptab.cdempres = 00            
                         craptab.cdacesso = "HRCOBRANCA"  
                         craptab.tpregist = tel_cdagenci.
                  VALIDATE craptab.
              END.           

           ASSIGN aux_hrbolini = 21600
                  aux_hrbolfim = 64800
                  craptab.dstextab = STRING(aux_hrbolfim,"99999") + 
                                     " " +
                                     STRING(aux_hrbolini,"99999").
                                     
       END.
             
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRTRTITULO" AND
                       craptab.tpregist = tel_cdagenci
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab  THEN
       DO:
           CREATE craptab.

           ASSIGN craptab.cdcooper = glb_cdcooper
                  craptab.nmsistem = "CRED"        
                  craptab.tptabela = "GENERI"      
                  craptab.cdempres = 00            
                  craptab.cdacesso = "HRTRTITULO"  
                  craptab.tpregist = tel_cdagenci.
           VALIDATE craptab.

       END.           

    ASSIGN aux_hrtitini = 21600
           aux_hrtitfim = 64800
           aux_cdsituac = 1 /* Processado */
           craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                              STRING(aux_hrtitfim,"99999") + " " +
                              STRING(aux_hrtitini,"99999") + " " +
                              STRING(tel_flsgproc,"SIM/NAO"). 

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRTRCOMPEL" AND
                       craptab.tpregist = tel_cdagenci
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab  THEN
       DO:
           CREATE craptab.

           ASSIGN craptab.cdcooper = glb_cdcooper
                  craptab.nmsistem = "CRED"        
                  craptab.tptabela = "GENERI"      
                  craptab.cdempres = 00            
                  craptab.cdacesso = "HRTRCOMPEL"  
                  craptab.tpregist = tel_cdagenci.
           VALIDATE craptab.

       END.           

    ASSIGN aux_hrcompel = 58500
           aux_cdsituac = 1 /* Processado */
           craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                              STRING(aux_hrcompel,"99999"). 

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRGUIASGPS" AND
                       craptab.tpregist = tel_cdagenci
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab  THEN
       DO:
           CREATE craptab.

           ASSIGN craptab.cdcooper = glb_cdcooper
                  craptab.nmsistem = "CRED"        
                  craptab.tptabela = "GENERI"      
                  craptab.cdempres = 00            
                  craptab.cdacesso = "HRGUIASGPS"  
                  craptab.tpregist = tel_cdagenci.
           VALIDATE craptab.

       END.           

    ASSIGN aux_hrguigps = 64800
           aux_cdsituac = 1 /* Processado */
           craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                              STRING(aux_hrguigps,"99999"). 
                       
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRTRENVELO" AND
                       craptab.tpregist = tel_cdagenci
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab  THEN
       DO:
           CREATE craptab.

           ASSIGN craptab.cdcooper = glb_cdcooper
                  craptab.nmsistem = "CRED"        
                  craptab.tptabela = "GENERI"      
                  craptab.cdempres = 00            
                  craptab.cdacesso = "HRTRENVELO"  
                  craptab.tpregist = tel_cdagenci.
           VALIDATE craptab.

       END.           

    ASSIGN aux_hrenvelo = 57600
           aux_cdsituac = 1 /* Processado */
           craptab.dstextab = STRING(aux_hrenvelo,"99999"). 

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND 
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRTRDOCTOS" AND
                       craptab.tpregist = tel_cdagenci
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab  THEN
       DO:
           CREATE craptab.

           ASSIGN craptab.cdcooper = glb_cdcooper
                  craptab.nmsistem = "CRED"        
                  craptab.tptabela = "GENERI"      
                  craptab.cdempres = 00            
                  craptab.cdacesso = "HRTRDOCTOS"  
                  craptab.tpregist = tel_cdagenci.
           VALIDATE craptab.

       END.           

    ASSIGN aux_hrdoctos = 58500
           aux_cdsituac = 1 /* Processado */
           craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                              STRING(aux_hrdoctos,"99999").
                              

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRPGTOINSS" AND
                       craptab.tpregist = tel_cdagenci
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab  THEN
       DO:
           CREATE craptab.

           ASSIGN craptab.cdcooper = glb_cdcooper
                  craptab.nmsistem = "CRED"        
                  craptab.tptabela = "GENERI"      
                  craptab.cdempres = 00            
                  craptab.cdacesso = "HRPGTOINSS"  
                  craptab.tpregist = tel_cdagenci.
           VALIDATE craptab.
       END.           

    ASSIGN craptab.dstextab = "58500". 


    /************ TRUNCAGEM - COMPE POR IMAGEM ************/
    FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                             craptab.nmsistem = "CRED"         AND
                             craptab.tptabela = "GENERI"       AND
                             craptab.cdempres = 00             AND
                             craptab.cdacesso = "EXETRUNCAGEM" AND
                             craptab.tpregist = tel_cdagenci
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab  THEN
       DO:
           CREATE craptab.

           ASSIGN craptab.cdcooper = glb_cdcooper
                  craptab.nmsistem = "CRED"
                  craptab.tptabela = "GENERI"
                  craptab.cdempres = 00
                  craptab.cdacesso = "EXETRUNCAGEM"
                  craptab.tpregist = tel_cdagenci.
           VALIDATE craptab.

       END.

    ASSIGN craptab.dstextab = "NAO".
    /************ TRUNCAGEM - COMPE POR IMAGEM ************/


    RUN gera_log_cadpac.
    
END. /** Fim do DO TRANSACTION **/

FIND CURRENT crapage NO-LOCK NO-ERROR.
FIND CURRENT craptab NO-LOCK NO-ERROR.

CLEAR FRAME f_pac   NO-PAUSE.
CLEAR FRAME f_pac01 NO-PAUSE.
CLEAR FRAME f_pac03 NO-PAUSE.
CLEAR FRAME f_pac03 NO-PAUSE.
CLEAR FRAME f_pac04 NO-PAUSE.

HIDE FRAME f_pac01 NO-PAUSE.
HIDE FRAME f_pac03 NO-PAUSE.
HIDE FRAME f_pac03 NO-PAUSE.
HIDE FRAME f_pac04 NO-PAUSE.


/* .......................................................................... */

