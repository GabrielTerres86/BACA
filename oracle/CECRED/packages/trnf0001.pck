CREATE OR REPLACE PACKAGE CECRED.TRNF0001 AS

/*..............................................................................

    Programa: TRNF0001                         Antiga: generico/procedures/b1wgen0025.p
    Autor   : Ze Eduardo
    Data    : Novembro/2007                  Ultima Atualizacao: 01/05/2014
    
    Dados referentes ao programa:

    Objetivo  : BO referente a funcoes e transacoes do CASH DISPENSER
                trata layout de comunicacao com o sistema ExtraCash - Foton  

    Alteracoes: 09/01/2008 - Acerto no suprimento/recolhimento e Envelopes (Ze).

                12/02/2008 - Incluir trilha do cartao no grava_lancamento (Ze).
                
                29/07/2008 - Alterar crapnsu para uma transacao isolada 
                             e alterar dtransa para Today (Ze).
                             
                27/08/2008 - Incluido tratamento na procedure "valida_cartao"
                             referente Agencia Bancoob (Diego).
                             
                05/09/2008 - Tratar sensores do CASH na procedure status_ATM
                             (Diego).
                             
                10/12/2008 - Trata Resolucao 3518 - BACEN, cobrar tarifa de
                             extrato a partir do 3o extrato por mes (Ze).
                
                07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
                
                22/05/2009 - Implementado controle de estorno, somente efetuar
                             o estorno se houver saque anterior ainda nao
                             estornado (Evandro).
                             
                23/06/2009 - Alteracao nas procedures de Suprimento e 
                             Recolhimento - Verifica e Executa e
                           - Retira a Verificacao se a nova senha eh igual a
                             senha do tele-atendimento   (Ze).
                             
                02/10/2009 - Aumento do campo nrterfin (Diego).
                
                09/03/2010 - Incluidas procedures para o novo sistema do cash
                             Progress (Evandro).
                             
                30/06/2010 - Retirar telefone da ouvidoria (Evandro).
                
                16/07/2010 - Ajuste de controle de lock timeout (Evandro).
                
                30/07/2010 - Sobrescrever o saldo no momento virada de data
                             caso ja exista;
                             Contemplar o valor dos rejeitados (K7R) no
                             recolhimento que aparece na opcao "Operacao"
                             da tela "CASH" (Evandro).
                             
                01/09/2010 - Verificar dia util para busca de saque no
                             momento do estorno para contemplar o fim de 
                             semana e corrigido lancamento de estorno em
                             casos onde mudou a data de saque (maquina
                             desligada, por exemplo);
                           - Melhoria do tratamento de recolhimento
                             (Evandro).
                             
                08/09/2010 - Adicionada procedure de estatisticos de uso nos
                             moldes do sistema antigo (Evandro).
                             
                16/09/2010 - Melhorada procedure verifica transferencia
                            (Evandro).
                            
                08/10/2010 - Adequacoes para uso do TAA compartilhado e
                             retiradas as procedures da Foton (Evandro).

                15/10/2010 - Criacao das procedures:
                             - busca_movto_saque_cooperativa
                             - taa_lancamento_tarifas_ext
                             - taa_lancto_titulos_convenios
                             (Guilherme/Supero)

                22/10/2010 - Adicionado controle para que o saque e o estorno 
                             nao ocorram na mesma hora, minuto e segundo 
                             (Henrique).
                             
                02/12/2010 - Corrigido controle de valores ja sacados
                             utilizando TODAY devido a data de transacao;
                           - Ajuste p/ correcao de problemas na contabilizacao
                             de valores rejeitados (Evandro).
                             
                27/12/2010 - Na procedure vira_data, verificar os lancamentos
                             conforme a cooperativa do terminal (cdcoptfn)
                             devido a saque multicooperativa (Evandro).
                             
                23/02/2011 - Incluidas procedures de confirmacao de reboot e
                             confirmacao de update;
                           - Nao permitir configuracao se terminal ja tiver
                             algum valor de saldo (Evandro).
                             
                01/04/2011 - Ajuste devido ao agendamento de pagamentos e 
                             transferencias no TAA (Henrique).
                             
                08/08/2011 - Incluir no protocolo: a cooperativa , agencia e
                             terminal. Incluir TIME na entrega envelope
                             (Gabriel). 
                           - Trocada mensagem quando TAA desabilitado
                            (Evandro)
                            
                27/10/2011 - Parametros na gera_protocolo 
                           - Transformado a entrega_envelope em uma transacao,
                             pois se voltar erro na gera_protocolo desfaz tudo
                             (Guilherme).
                             
                19/12/2011 - Adicionada validacao da data de nascimento (Evandro).
                
                17/01/2012 - Adicionado controle de letras de seguranca (Evandro).
                
                13/06/2012 - Eliminar EXTENT vldmovto;
                           - Eliminar e-mails utilzados na epoca das fraudes de
                             clonagem de cartao (Evandro).
                             
                23/07/2012 - Tratamento para migracao VIACREDI ALTO VALE
                             (Evandro).
                             
                17/10/2012 - Temp-Tables transferidas para include b1wgen0025tt.i (Oscar)
                
                07/11/2012 - Ajustar letras de seguranca para utilizacao no
                             InternetBank (David).
                             
                28/11/2012 - Tratamento para evitar agendamentos de contas
                             migradas - tabela craptco - TAA (Evandro).
                             
                17/01/2013 - Retornar se eh uma conta migrada na procedure
                             busca_associado (Evandro).
                             
                05/02/2013 - Rotina de verificacao de prova de vida para o 
                             INSS (Evandro).
                             
                26/02/2013 - Corrigida falta de DELETE PROCEDURE para a
                             prova de vida do INSS (Evandro).

                19/03/2013 - Incluir historico 1009 de transf. intercoop.
                             na proc taa transferencias (Gabriel).
                             
                05/06/2013 - Adicionados valores de multa e juros ao valor total
                             das faturas, para DARFs (Lucas).
                            
                26/08/2013 - Nao permitir suprimento de notas inferiores a R$ 10;
                           - Adicionado e-mail de monitoramento de saques de fraude
                             (Evandro).
                             
                02/09/2013 - Ajuste no email de monitoracao (Evandro).
                
                03/09/2013 - Valor de limite minimo de 400,00 no email de
                             monitoracao (Evandro).
                             
                11/09/2013 - Adicionado email da multitask na monitoracao
                             (Evandro).
                             
                12/09/2013 - Alterado valor de saque limite na monitoracao para
                             400,00 e retirado e-mail de varios saques em 10
                             minutos (Evandro).
                             
                25/09/2013 - Alterada rotina de email para monitoracao de
                             terceiros conforme solicitacao da equipe de
                             seguranca (Evandro).
                             
                04/10/2013 - Tratamento para migracao da Acredicoop usando
                             "de/para" de cartoes magneticos e retirada do
                             email da multitask (Evandro).
                             
                07/10/2013 - Ajustar bloqueio de agendamento para contas
                             migradas (David).
                
                12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                13/11/2013 - Adicionado verificao e gravacao de historico qd
                             for alterada senha do cartao magnetico do operador
                             em proc. altera_senha. (Jorge)                          
                             
                09/12/2013 - Adicionar PA no assunto dos emails de monitoracao
                             (Evandro).
                             
                11/12/2013 - Enviar e-mail de monitoracao para as cooperativas
                             Viacredi, Alto Vale, Acredicoop, Concredi e
                             Credifoz;
                           - Tratar acoes antifraude nas procedures:
                             verifica_saque
                             verifica_transferencia
                             verifica_autorizacao
                             (Evandro)
                             
                12/12/2013 - Ajustado o valor de e-mails para 300,00 e adicionados
                            dados do TAA no assunto (Evandro).
                            
                05/03/2014 - Incluso VALIDATE (Daniel).
                
                14/03/2014 - Ajustar saque noturno para bloquear saque maior 
                             que 300,00 tambem em cartoes com parametro de 
                             saque livre (David).
                             
                24/03/2014 - Ajuste Oracle tratamento FIND LAST crapnsu para 
                             utilizar sequence (Daniel).
                             
                01/05/2014 - Conversao Progress para oracle (Andrino - RKAM)
                                         										 
..............................................................................*/

  /* Consulta por:                                                       
      - Transferencias feitos no meu TAA por outras Coops (pr_cdcoptfn <> 0)     
      - Transferencias feitos por meus Assoc. em outras Coops (pr_cdcooper <> 0) */
  PROCEDURE pc_taa_transferencias(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                  pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE,
                                  pr_dtmvtoin        IN  DATE,
                                  pr_dtmvtofi        IN  DATE,
                                  pr_cdtplanc        IN  PLS_INTEGER,
                                  pr_dscritic        OUT VARCHAR2,
                                  pr_tab_lancamentos OUT cada0001.typ_tab_lancamentos);


  /* Consulta por:                                                       
      - Agendamentos de transferencias feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)     
      - Agendamentos de transferencias feitos por meus Assoc. em outras Coops (par_cdcooper <> 0) */
  PROCEDURE  pc_taa_agenda_transferencias(pr_cdcooper        IN  crapcop.cdcooper%TYPE, 
                                          pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE, 
                                          pr_dtmvtoin        IN  DATE,
                                          pr_dtmvtofi        IN  DATE,
                                          pr_cdtplanc        IN  PLS_INTEGER,
                                          pr_dscritic        OUT VARCHAR2,
                                          pr_tab_lancamentos OUT cada0001.typ_tab_lancamentos);


END TRNF0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TRNF0001 AS

  PROCEDURE pc_taa_transferencias(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                  pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE,
                                  pr_dtmvtoin        IN  DATE,
                                  pr_dtmvtofi        IN  DATE,
                                  pr_cdtplanc        IN  PLS_INTEGER,
                                  pr_dscritic        OUT VARCHAR2,
                                  pr_tab_lancamentos OUT cada0001.typ_tab_lancamentos) IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_taa_transferencias        Antigo: generico/procedures/b1wgen0025.p/taa_transferencias
  --  Sistema  : Procedure para buscar tarifa transferencia intercooperativa
  --  Sigla    : CRED
  --  Autor    : Andrino Carlos de Souza Junior - RKAM
  --  Data     : Maio/2014.                    Ultima atualizacao: 04/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Consulta por:
  --                Transferencias feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)
  --                Transferencias feitos por meus Assoc. em outras Coops (par_cdcooper <> 0)
  --
	-- Alterações: 04/12/2015 - Alterado para tratar transferencias com efetivação nesta 
  --                          data que ficaram pendentes. (Reinert)
  ---------------------------------------------------------------------------------------------------------------

    -- Lancamentos em deposito a vista
    CURSOR cr_craplcm IS
      SELECT cdcooper
            ,cdcoptfn
            ,cdagetfn
            ,nrdconta
            ,sum(vllanmto) vllanmto
            ,COUNT(*) qtdmovto
        FROM craplcm
       WHERE (craplcm.cdcoptfn  = pr_cdcoptfn
         AND  craplcm.cdhistor  = 375
         AND  craplcm.dtmvtolt >= pr_dtmvtoin
         AND  craplcm.dtmvtolt <= pr_dtmvtofi
         AND  craplcm.cdcooper <> craplcm.cdcoptfn)
          OR (craplcm.cdcoptfn  = pr_cdcoptfn
         AND  craplcm.cdhistor  = 376
         AND  craplcm.dtmvtolt >= pr_dtmvtoin
         AND  craplcm.dtmvtolt <= pr_dtmvtofi
         AND  craplcm.cdcooper <> craplcm.cdcoptfn)
          OR (craplcm.cdcoptfn  = pr_cdcoptfn
         AND  craplcm.cdhistor  = 1009
         AND  craplcm.cdagenci  = 91
         AND  craplcm.dtmvtolt >= pr_dtmvtoin
         AND  craplcm.dtmvtolt <= pr_dtmvtofi
         AND  craplcm.cdcooper <> craplcm.cdcoptfn)
       GROUP BY cdcooper
            ,cdcoptfn
            ,cdagetfn
            ,nrdconta;

    -- Lancamentos em deposito a vista
    CURSOR cr_craplcm_2 IS
      SELECT cdcooper
            ,cdcoptfn
            ,cdagetfn
            ,nrdconta
            ,SUM(vllanmto) vllanmto
            ,COUNT(*) qtdmovto
        FROM craplcm
       WHERE (craplcm.cdcooper  = pr_cdcooper
         AND  craplcm.cdhistor  = 375
         AND  craplcm.dtmvtolt >= pr_dtmvtoin
         AND  craplcm.dtmvtolt <= pr_dtmvtofi
         AND  craplcm.cdcooper <> craplcm.cdcoptfn
         AND  craplcm.cdcoptfn <> 0)
          OR (craplcm.cdcooper  = pr_cdcooper
         AND  craplcm.cdhistor  = 376
         AND  craplcm.dtmvtolt >= pr_dtmvtoin
         AND  craplcm.dtmvtolt <= pr_dtmvtofi
         AND  craplcm.cdcooper <> craplcm.cdcoptfn
         AND  craplcm.cdcoptfn <> 0)
          OR (craplcm.cdcooper  = pr_cdcooper
         AND  craplcm.cdhistor  = 1009
         AND  craplcm.cdagenci  = 91      
         AND  craplcm.dtmvtolt >= pr_dtmvtoin
         AND  craplcm.dtmvtolt <= pr_dtmvtofi
         AND  craplcm.cdcooper <> craplcm.cdcoptfn
         AND  craplcm.cdcoptfn <> 0)
       GROUP BY cdcooper
            ,cdcoptfn
            ,cdagetfn
            ,nrdconta;
						
		-- Transferencias com efetivação nesta data que ficaram pendentes
		CURSOR cr_tbgen_trans_pend IS
			SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn
						,tbgen_trans_pend.nrdconta
						,SUM(tbtransf_trans_pend.vltransferencia) vllanmto
						,COUNT(*) qtdmovto
			 FROM tbgen_trans_pend, tbtransf_trans_pend 
			WHERE tbgen_trans_pend.cdcoptfn = pr_cdcoptfn 
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao IN (1,5) /* Transferencias */
				AND tbtransf_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
				AND tbtransf_trans_pend.idagendamento = 1 /* Nesta Data */
	 GROUP BY tbgen_trans_pend.cdcooper
					 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;
					 
		-- Transferencias com efetivação nesta data que ficaram pendentes					 
		CURSOR cr_tbgen_trans_pend_2 IS
			SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn
						,tbgen_trans_pend.nrdconta
						,SUM(tbtransf_trans_pend.vltransferencia) vllanmto
						,COUNT(*) qtdmovto
			 FROM tbgen_trans_pend, tbtransf_trans_pend 
			WHERE tbgen_trans_pend.cdcooper = pr_cdcooper
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.cdcoptfn <> 0
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao IN (1,5) /* Transferencias */
				AND tbtransf_trans_pend.cdtransacao_pendente =
						tbgen_trans_pend.cdtransacao_pendente
				AND tbtransf_trans_pend.idagendamento = 1 /* Nesta Data */
	 GROUP BY tbgen_trans_pend.cdcooper
					 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;

    -- Variaveis gerais
    vr_ind VARCHAR2(38);              --> Indice da Pl_table pr_tab_lancamentos

  BEGIN
    -- Limpa a tabela temporaria
    pr_tab_lancamentos.delete;
    
    /* Saques feitos no meu TAA por outras Coops     */
    IF pr_cdcoptfn <> 0 THEN 
      
      -- Efetua loop sobre os lancamentos de deposito a vista
      FOR rw_craplcm IN cr_craplcm LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplcm.cdcooper,10,'0')||lpad(rw_craplcm.cdcoptfn,10,'0')||
                  lpad(rw_craplcm.cdagetfn,5,'0') ||lpad(rw_craplcm.nrdconta,10,'0');

        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craplcm.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplcm.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplcm.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craplcm.nrdconta;
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Transferencia';
        pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplcm.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplcm.vllanmto;
         
      END LOOP;
			
			-- Efetua loop sobre os lancamentos de deposito a vista
      FOR rw_tbgen_trans_pend IN cr_tbgen_trans_pend LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend.cdcooper,10,'0')
								||lpad(rw_tbgen_trans_pend.cdcoptfn,10,'0')
								||lpad(rw_tbgen_trans_pend.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend.nrdconta,10,'0');


        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend.vllanmto;
        ELSE
					-- Atualiza a temp-table de retorno
					pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
					pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend.cdcooper;
					pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend.cdcoptfn;
					pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend.cdagetfn;
					pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend.nrdconta;
					pr_tab_lancamentos(vr_ind).qtdecoop := 1;
					pr_tab_lancamentos(vr_ind).dstplanc := 'Transferencia';
					pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
					pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend.qtdmovto;
					pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend.vllanmto;
        END IF;         
      END LOOP;

    END IF; /* END do IF par_cdcoptfn */
    
    /* Saques feitos por meus Assoc. em outras Coops */
    IF pr_cdcooper <> 0 THEN

      -- Efetua loop sobre os lancamentos de deposito a vista
      FOR rw_craplcm IN cr_craplcm_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplcm.cdcooper,10,'0')||lpad(rw_craplcm.cdcoptfn,10,'0')||
                  lpad(rw_craplcm.cdagetfn,5,'0') ||lpad(rw_craplcm.nrdconta,10,'0');

        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craplcm.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplcm.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplcm.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craplcm.nrdconta;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Transferencia';
        pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplcm.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplcm.vllanmto;

      END LOOP;

      -- Efetua loop sobre os lancamentos de deposito a vista
      FOR rw_tbgen_trans_pend_2 IN cr_tbgen_trans_pend_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend_2.cdcooper,10,'0')
								||lpad(rw_tbgen_trans_pend_2.cdcoptfn,10,'0')
								||lpad(rw_tbgen_trans_pend_2.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend_2.nrdconta,10,'0');


        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend_2.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend_2.vllanmto;
        ELSE
					-- Atualiza a temp-table de retorno
					pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
					pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend_2.cdcooper;
					pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend_2.cdcoptfn;
					pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend_2.cdagetfn;
					pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend_2.nrdconta;
					pr_tab_lancamentos(vr_ind).qtdecoop := 1;
					pr_tab_lancamentos(vr_ind).dstplanc := 'Transferencia';
					pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
					pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend_2.qtdmovto;
					pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend_2.vllanmto;
        END IF;
      END LOOP;


    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na TRNF0001.pc_taa_transferencias: '||SQLerrm;    
  END pc_taa_transferencias;
  
  
  
  PROCEDURE  pc_taa_agenda_transferencias(pr_cdcooper        IN  crapcop.cdcooper%TYPE, 
                                          pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE, 
                                          pr_dtmvtoin        IN  DATE,
                                          pr_dtmvtofi        IN  DATE,
                                          pr_cdtplanc        IN  PLS_INTEGER,
                                          pr_dscritic        OUT VARCHAR2,
                                          pr_tab_lancamentos OUT cada0001.typ_tab_lancamentos) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_taa_agenda_transferencias        Antigo: generico/procedures/b1wgen0025.p/taa_agenda_transferencias
  --  Sistema  : Procedure para buscar tarifa transferencia intercooperativa
  --  Sigla    : CRED
  --  Autor    : Andrino Carlos de Souza Junior - RKAM
  --  Data     : Maio/2014.                    Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Consulta por:
  --                Agendamentos de transferencias feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)
  --                Agendamentos de transferencias feitos por meus Assoc. em outras Coops (par_cdcooper <> 0)
  --
  ---------------------------------------------------------------------------------------------------------------
  
    -- Cursor sobre os lancamentos automaticos
    CURSOR cr_craplau IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             count(*) qtdmovto,
             sum(vllanaut) vllanaut
        FROM craplau 
       WHERE craplau.cdcoptfn =  pr_cdcoptfn
         AND craplau.cdtiptra IN (1,5)
         AND craplau.dtmvtolt >= pr_dtmvtoin 
         AND craplau.dtmvtolt <= pr_dtmvtofi
         AND craplau.cdagenci =  91         
         AND craplau.cdcooper <> craplau.cdcoptfn
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

    -- Cursor sobre os lancamentos automaticos
    CURSOR cr_craplau_2 IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             count(*) qtdmovto,
             sum(vllanaut) vllanaut
        FROM craplau 
       WHERE craplau.cdcooper =  pr_cdcooper
         AND craplau.cdtiptra IN (1,5)
         AND craplau.dtmvtolt >= pr_dtmvtoin 
         AND craplau.dtmvtolt <= pr_dtmvtofi
         AND craplau.cdagenci =  91         
         AND craplau.cdcooper <> craplau.cdcoptfn
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;
             
		-- Transferencias com efetivação nesta data que ficaram pendentes
		CURSOR cr_tbgen_trans_pend IS
			SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn
						,tbgen_trans_pend.nrdconta
						,SUM(tbtransf_trans_pend.vltransferencia) vllanmto
						,COUNT(*) qtdmovto
			 FROM tbgen_trans_pend, tbtransf_trans_pend 
			WHERE tbgen_trans_pend.cdcoptfn = pr_cdcoptfn 
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao IN (1,5) /* Transferencias */
				AND tbtransf_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
				AND tbtransf_trans_pend.idagendamento = 2 /* Nesta Data */
	 GROUP BY tbgen_trans_pend.cdcooper
					 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;
					 
		-- Transferencias com efetivação nesta data que ficaram pendentes					 
		CURSOR cr_tbgen_trans_pend_2 IS
			SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn
						,tbgen_trans_pend.nrdconta
						,SUM(tbtransf_trans_pend.vltransferencia) vllanmto
						,COUNT(*) qtdmovto
			 FROM tbgen_trans_pend, tbtransf_trans_pend 
			WHERE tbgen_trans_pend.cdcooper = pr_cdcooper
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.cdcoptfn <> 0
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao IN (1,5) /* Transferencias */
				AND tbtransf_trans_pend.cdtransacao_pendente =
						tbgen_trans_pend.cdtransacao_pendente
				AND tbtransf_trans_pend.idagendamento = 2 /* Nesta Data */
	 GROUP BY tbgen_trans_pend.cdcooper
					 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;             

    -- Variaveis gerais
    vr_ind VARCHAR2(38);              --> Indice da Pl_table pr_tab_lancamentos

  BEGIN
    -- Limpa a tabela temporaria
    pr_tab_lancamentos.delete;

    /* Agendamento de transferencias feitos no meu TAA por outras Coops     */
    IF pr_cdcoptfn <> 0 THEN

      -- Efetua loop sobre os lancamentos automaticos
      FOR rw_craplau IN cr_craplau LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplau.cdcooper,10,'0')||lpad(rw_craplau.cdcoptfn,10,'0')||
                  lpad(rw_craplau.cdagetfn,5,'0') ||lpad(rw_craplau.nrdconta,10,'0');
          
        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craplau.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplau.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplau.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craplau.nrdconta;
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Transferencia';
        pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplau.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplau.vllanaut;
        
      END LOOP;
      
      -- Efetua loop sobre os lancamentos de deposito a vista
      FOR rw_tbgen_trans_pend IN cr_tbgen_trans_pend LOOP
        
        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend.cdcooper,10,'0')
								||lpad(rw_tbgen_trans_pend.cdcoptfn,10,'0')
								||lpad(rw_tbgen_trans_pend.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend.nrdconta,10,'0');


        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend.vllanmto;
        ELSE
					-- Atualiza a temp-table de retorno
					pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
					pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend.cdcooper;
					pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend.cdcoptfn;
					pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend.cdagetfn;
					pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend.nrdconta;
					pr_tab_lancamentos(vr_ind).qtdecoop := 1;
					pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Transferencia';
					pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
					pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend.qtdmovto;
					pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend.vllanmto;
        END IF;         
      END LOOP;

    END IF; /* End If pr_cdcopftn */

    /* Agendamento de transferencias feitos por meus Assoc. em outras Coops */
    IF pr_cdcooper <> 0 THEN 

      -- Efetua loop sobre os lancamentos automaticos
      FOR rw_craplau IN cr_craplau_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplau.cdcooper,10,'0')||lpad(rw_craplau.cdcoptfn,10,'0')||
                  lpad(rw_craplau.cdagetfn,5,'0') ||lpad(rw_craplau.nrdconta,10,'0');
          
        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craplau.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplau.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplau.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craplau.nrdconta;
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Transferencia';
        pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplau.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplau.vllanaut;        

      END LOOP;
      
      -- Efetua loop sobre os lancamentos de deposito a vista
      FOR rw_tbgen_trans_pend_2 IN cr_tbgen_trans_pend_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend_2.cdcooper,10,'0')
								||lpad(rw_tbgen_trans_pend_2.cdcoptfn,10,'0')
								||lpad(rw_tbgen_trans_pend_2.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend_2.nrdconta,10,'0');


        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend_2.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend_2.vllanmto;
        ELSE
					-- Atualiza a temp-table de retorno
					pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
					pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend_2.cdcooper;
					pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend_2.cdcoptfn;
					pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend_2.cdagetfn;
					pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend_2.nrdconta;
					pr_tab_lancamentos(vr_ind).qtdecoop := 1;
					pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Transferencia';
					pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
					pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend_2.qtdmovto;
					pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend_2.vllanmto;
        END IF;
      END LOOP;
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na TRNF0001.pc_taa_agenda_transferencias: '||SQLerrm;    
  END pc_taa_agenda_transferencias;
  
END TRNF0001;
/
