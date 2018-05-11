CREATE OR REPLACE PROCEDURE CECRED.pc_crps688 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps688
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Reinert
       Data    : Julho/2014                     Ultima atualizacao: 13/04/2017

       Dados referentes ao programa:

       Frequencia: Diário
       Objetivo  : Efetuar resgate de aplicações agendadas pelo Internet Bank

       Alteracoes: 22/09/2014 - Reformulado regra de processamento do CRPS688,
                                para utlizar o processo correto para efetuar
                                os agendamentos de resgate/aplicacao 
                                (Tiago/Gielow)

                   17/10/2014 - Ajustes realizados:
                                 > Retirado if redundante
                                 > Tratamento de erro após a chamada de rotinas
                               (Adriano).
                               
                   18/11/2014 - Ajuste para desprezar resgate de aplicações que não
                                tenham zerado o valor de resgate.                               
                                (Adriano).
                                
                   27/11/2014 - Ajustes realizados:
                                - Efetuar commit para cada registro;
                                - Gera o relatório corretamente;
                                - Incrementar o numero do mês quando um agendamento
                                  de aplicação for atualizado para 4 - Não efetivado;
                                - Atualizado o campo craplau.dtdebito com dtmvtocd 
                                  quando este, for rejeitado;
                                (Adriano). 

									 20/01/2015 - Ajuste no tratamento de crítica. (Jean Michel).
                   
                   21/01/2015 - Ajuste para calcular data vencimento corretamente
                                qdo for efetivar aplicacao pois estava passando
                                sempre a data de vencimento da primeira parcela
                                SD243674 (Tiago/Gielow).                                

                   21/06/2016 - Ajuste para verificar sequencia da execucao no JOB,
                                programa retirado da cadeia (Tiago/Thiago SD402010)

				   29/07/2016 - Nao olhar mais inproces pra saber se eh segunda
				                execucao e commitar o controle de execucao
								(Tiago/Thiago SD496111)

                   13/04/2017 - Correcao para nao considerar as aplicacoes diferentes de RDCPOS
                                no agendamento do resgate de valores feitos pelo IBANK.
                                (Carlos Rafael Tanholi SD 637453)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS688';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_exc_controle EXCEPTION;
      vr_controla_commit EXCEPTION;
      vr_controla_rejeitado EXCEPTION;
      vr_exc_erro EXCEPTION;
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);

      vr_dtvencto DATE;
      vr_qtdiaapl INTEGER;
      vr_tipo     VARCHAR2(1);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
			-- Busca cadastro das aplicações e resgates
			CURSOR cr_crapaar (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
			  SELECT aar.ROWID
              ,aar.cdcooper
				      ,aar.nrmesaar
							,aar.qtmesaar
							,aar.cdagenci
							,aar.cdoperad
							,aar.nrdconta
							,aar.nrctraar
							,aar.flgtipar
							,aar.qtdiacar
							,aar.dtvencto
							,aar.idseqttl
							,aar.vlparaar
              ,aar.dtiniaar
              ,aar.nrdocmto
				  FROM crapaar aar
 				 WHERE aar.cdcooper = pr_cdcooper
				   AND aar.cdsitaar = 1
         ORDER BY aar.flgtipar; -- Ativo      
			rw_crapaar cr_crapaar%ROWTYPE;
      
      -- Busca os lancamentos automaticos
      CURSOR cr_craplau(pr_cdcooper craplau.cdcooper%TYPE,
                        pr_nrdconta craplau.nrdconta%TYPE,
                        pr_cdhistor craplau.cdhistor%TYPE,
                        pr_nrdolote craplau.nrdolote%TYPE,
                        pr_nrdocmto VARCHAR2,
                        pr_dtmvtocd crapdat.dtmvtocd%TYPE) IS
        SELECT cdagenci 
              ,cdbccxlt
              ,cdbccxpg
              ,cdhistor
              ,dtdebito
              ,dtmvtolt
              ,dtmvtopg
              ,insitlau
              ,nrdconta
              ,nrdctabb
              ,nrdolote
              ,nrseqdig
              ,nrseqlan
              ,tpdvalor
              ,vllanaut
              ,cdcooper
              ,nrdocmto
              ,idseqttl
              ,ROWID
          FROM craplau
         WHERE craplau.cdcooper = pr_cdcooper
           AND craplau.nrdconta = pr_nrdconta
           AND craplau.cdhistor = pr_cdhistor
           AND craplau.nrdolote = pr_nrdolote
           AND craplau.dtmvtopg = pr_dtmvtocd
           AND craplau.nrdocmto LIKE pr_nrdocmto
           AND craplau.insitlau = 1; --Pendente
      rw_craplau cr_craplau%ROWTYPE;

      -- Consulta as capas de lote
      CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrseqdig,
               cdbccxpg,
               nrdcaixa,
               cdoperad,
               ROWID
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = 1
           AND lot.cdbccxlt = 100
           AND lot.nrdolote = pr_nrdolote;           
      rw_craplot cr_craplot%ROWTYPE;
      
      CURSOR cr_crapttx(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_tptaxrdc crapttx.tptaxrdc%TYPE,
                        pr_qtdiacar crapttx.qtdiacar%TYPE) IS
        SELECT cdperapl
          FROM crapttx ttx
         WHERE ttx.cdcooper = pr_cdcooper
           AND ttx.tptaxrdc = pr_tptaxrdc
           AND ttx.qtdiacar = pr_qtdiacar;           
      rw_crapttx cr_crapttx%ROWTYPE;
      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      
      vr_tab_dados_resgate    APLI0001.typ_tab_resgate; --> dados para resgate
      vr_tab_resposta_cliente apli0002.typ_tab_resposta_cliente; --> Retorna respostas para as aplicações
      
      /* Tipo que compreende o registro da tab. temporária tt-dados-acumulo */
      TYPE typ_reg_agendamentos IS
          RECORD (nrdconta crapaar.nrdconta%TYPE
                 ,flgtipar crapaar.flgtipar%TYPE
                 ,vlparaar crapaar.vlparaar%TYPE
                 ,dscritic VARCHAR2(4000)
                 ,nrparcel VARCHAR2(12));
                 
      /* Definição de tabela que compreende os registros acima declarados */
      TYPE typ_tab_agendamentos IS
        TABLE OF typ_reg_agendamentos
        INDEX BY BINARY_INTEGER;
      
      ------------------------------- VARIAVEIS -------------------------------
      vr_nmdcampo VARCHAR2(45);
			vr_nrdocmto craplcm.nrdocmto%TYPE;
			vr_dsprotoc crappro.dsprotoc%TYPE;
			vr_tab_msg_confirma APLI0002.typ_tab_msg_confirma;
      
      vr_nrdocsrc VARCHAR2(30);
      vr_nrdolote craplot.nrdolote%TYPE;
      vr_cdhistor craplot.cdhistor%TYPE;
     
      vr_indice VARCHAR2(25);

      vr_saldo_rdca apli0001.typ_tab_saldo_rdca;
      vr_des_reto VARCHAR2(45);
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_tab_reg_agendamento typ_tab_agendamentos;
      
      -- Indice da temp-table
      vr_ind NUMBER;
      
	    vr_flultexe    INTEGER;
      vr_qtdexec     INTEGER;
      
      -- Variável de Controle de XML
      vr_des_xml CLOB;

      --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
      
      --Procedure para gerar o relatorio
      PROCEDURE pc_gera_relatorio(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
                                 
        -- Declaração de variáveis                                  
        vr_dscritic VARCHAR2(4000);   
        vr_dsdireto VARCHAR2(400);
        vr_dsdircop VARCHAR2(400);
        
      BEGIN
        
        -- Busca do diretório para gravação
        vr_dsdircop := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => null);

        vr_dsdireto := vr_dsdircop||'/rl/crrl691.lst';    
         
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl691>');  
      
        vr_ind := vr_tab_reg_agendamento.first; -- Vai para o primeiro registro

        -- loop sobre a tabela de retorno
        WHILE vr_ind IS NOT NULL LOOP  
        
          pc_escreve_xml('<agendamento>' ||
                          '<nrdconta>' || gene0002.fn_mask_conta(vr_tab_reg_agendamento(vr_ind).nrdconta)||'</nrdconta>'||
                          '<flgtipar>' || vr_tab_reg_agendamento(vr_ind).flgtipar || '</flgtipar>' ||
                          '<vlparaar>' || to_char(NVL(vr_tab_reg_agendamento(vr_ind).vlparaar,0),'fm999g999g999g990d00') || '</vlparaar>' ||
                          '<nrparcel>' || vr_tab_reg_agendamento(vr_ind).nrparcel || '</nrparcel>' ||                             
                          '<dscritic>' || SUBSTR(vr_tab_reg_agendamento(vr_ind).dscritic,1,82) || ' </dscritic>' || 
                         '</agendamento>');
                         
          -- Vai para o proximo registro
          vr_ind := vr_tab_reg_agendamento.next(vr_ind);               
                     
        END LOOP;
                 
        pc_escreve_xml('</crrl691>');
                                  
        /*A geração do relatório dever ser feito na hora e com append pois, este crps será executado no
          processo diário e uma segunda vez, através da automatização da DEBNET. Desta forma, o relatório
          gerado na primeira execução não será perdido. */
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => pr_cdprogra
                                   ,pr_dtmvtolt  => pr_dtmvtolt
                                   ,pr_dsxml     => vr_des_xml
                                   ,pr_dsxmlnode => '/crrl691/agendamento'
                                   ,pr_dsjasper  => 'crrl691.jasper'
                                   ,pr_dsparams  => ' '
                                   ,pr_dsarqsaid => vr_dsdireto
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 132
                                   ,pr_sqcabrel  => 1
                                   ,pr_flg_impri => 'S'
                                   ,pr_nrcopias  => 1
                                   ,pr_flappend  => 'S'
                                   ,pr_des_erro  => vr_dscritic);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);         
      
      END;                 
                 
      --Procedure para efetuar a rejeição do agendamento
      PROCEDURE pc_efetua_rejeicao(pr_nrdconta IN crapaar.nrdconta%TYPE
                                  ,pr_inproces IN crapdat.inproces%TYPE
                                  ,pr_flgtipar IN crapaar.flgtipar%TYPE
                                  ,pr_vlparaar IN crapaar.vlparaar%TYPE
                                  ,pr_nrparcel IN VARCHAR2
                                  ,pr_rowidaar IN ROWID
                                  ,pr_rowidlau IN ROWID
                                  ,pr_cdcritic IN INT
                                  ,pr_dscritic IN VARCHAR2
                                  ,pr_cdhistor IN craplot.cdhistor%TYPE
                                  ,pr_nrdolote IN craplot.nrdolote%TYPE
                                  ,pr_dtmvtocd IN crapdat.dtmvtocd%TYPE
                                  ,pr_nrdocsrc IN VARCHAR2
                                  ,pr_nrmesaar IN crapaar.nrmesaar%TYPE
                                  ,pr_qtmesaar IN crapaar.qtmesaar%TYPE
                                  ,pr_des_reto OUT VARCHAR2
                                  ,pr_cdcriret OUT crapcri.cdcritic%TYPE
                                  ,pr_dscriret OUT crapcri.dscritic%TYPE)IS
        
        -- Declaração de variáveis                          
        vr_cdcritic PLS_INTEGER;
        vr_dscritic VARCHAR2(4000);   
        
        -- Controle de exceção
        vr_exc_saida EXCEPTIon;
        
      BEGIN
        
        vr_ind := vr_tab_reg_agendamento.COUNT;
        vr_tab_reg_agendamento(vr_ind).nrdconta := pr_nrdconta;
        vr_tab_reg_agendamento(vr_ind).flgtipar := pr_flgtipar;
        vr_tab_reg_agendamento(vr_ind).vlparaar := pr_vlparaar;
        vr_tab_reg_agendamento(vr_ind).nrparcel := pr_nrparcel;
        
        -- Verifica se existe critica
        IF pr_cdcritic <> 0 THEN                   
          vr_tab_reg_agendamento(vr_ind).dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic); 
        ELSE            
          vr_tab_reg_agendamento(vr_ind).dscritic := pr_dscritic;
        END IF;
        
        /*Se for agendamento de aplicação*/                        
        IF pr_flgtipar = 0 THEN
          
          /*Se for a segunda tentativa de efetivação (Automatização da DEBNET)*/
          IF vr_flultexe = 1 THEN
            
            /*Atualiza a parcela (craplau) para informar o erro e atualiza-lo para "Não efetivado".*/
            BEGIN
              
              UPDATE craplau
                 SET craplau.cdcritic = pr_cdcritic 
                    ,craplau.insitlau = 4 /*Não efetivado*/
                    ,craplau.dtdebito = pr_dtmvtocd
                    WHERE craplau.cdcooper = pr_cdcooper
                      AND craplau.nrdconta = pr_nrdconta
                      AND craplau.cdhistor = pr_cdhistor
                      AND craplau.nrdolote = pr_nrdolote
                      AND craplau.dtmvtopg = pr_dtmvtocd                            
                      AND craplau.nrdocmto LIKE pr_nrdocsrc
                      AND craplau.insitlau = 1; --Pendente
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar a situacao atual da craplau --> '|| SQLERRM;
                RAISE vr_exc_saida;
            END;
                
            /*Incrementa o numero da parcela (nrmesaar) e se for a ultima parcela, deve atualizar
              o agendamento para não efetivado */
            BEGIN

              UPDATE crapaar
                 SET crapaar.cdsitaar = DECODE((pr_nrmesaar + 1),pr_qtmesaar,4,crapaar.cdsitaar) --Não efetivado
                    ,crapaar.nrmesaar = crapaar.nrmesaar + 1
               WHERE crapaar.rowid = pr_rowidaar;
            EXCEPTION
              WHEN OTHERS THEN
                
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar situacao da crapaar --> '|| SQLERRM;
                
                RAISE vr_exc_saida;
              
            END; 
            
          END IF;
          
        ELSE
          /* Pelo fato de não ter sido possível efetuar o resgate da parcela corrente, para o agendamento
             de resgate, todas as parcelas devem ser atualiza-das para "Não efetivada" e receber o código 
             de critica da parcela corrente. */          
          BEGIN
            
            UPDATE craplau
               SET craplau.cdcritic = pr_cdcritic 
                  ,craplau.insitlau = 4 /*Não efetivado*/
                  ,craplau.dtdebito = pr_dtmvtocd
                  WHERE craplau.cdcooper = pr_cdcooper
                    AND craplau.nrdconta = pr_nrdconta
                    AND craplau.cdhistor = pr_cdhistor
                    AND craplau.nrdolote = pr_nrdolote   
                    AND craplau.nrdocmto LIKE pr_nrdocsrc                     
                    AND craplau.insitlau = 1; --Pendente
            
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a situacao atual da craplau --> '|| SQLERRM;
              RAISE vr_exc_saida;
          END;   
        
          /*O agendamento (crapaar) deverá ser atualizado para "Não efetivado".*/
          BEGIN
            
            UPDATE crapaar
               SET crapaar.cdsitaar = 4 /*Não efetivado*/
                  ,crapaar.nrmesaar = crapaar.qtmesaar
             WHERE crapaar.rowid = pr_rowidaar;
          EXCEPTION
            WHEN OTHERS THEN
              
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a situacao do agendamento de aplicacao/resgate da crapaar --> '|| SQLERRM;
              
              RAISE vr_exc_saida;
              
          END;
          
        END IF;
      
        pr_des_reto := 'OK';
      
      EXCEPTION
        WHEN vr_exc_saida THEN
             
          IF NVL(vr_cdcritic,0) = 0 AND
             vr_dscritic = ' '      THEN       
            vr_dscritic := 'Erro ao gerar rejeicao.';
          END IF;
             
          pr_cdcriret := NVL(vr_cdcritic,0);
          pr_dscriret := vr_dscritic;
          
          pr_des_reto := 'NOK';
      
        WHEN OTHERS THEN
          
          pr_cdcriret := 0;
          pr_dscriret := 'Erro ao gerar rejeicao -->' || SQLERRM;
          
          pr_des_reto := 'NOK';
      
      END;  
      
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------

      -- Limpar tabelas
      vr_tab_reg_agendamento.delete;
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
                                
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
				
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;      
         
	  --> Verificar a execução da DEBNET e DEBSIC
      SICR0001.pc_controle_exec_deb (pr_cdcooper  => pr_cdcooper  --> Código da coopertiva
                                    ,pr_cdtipope  => 'I'               --> Tipo de operacao I-incrementar e C-Consultar
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento
                                    ,pr_cdprogra  => vr_cdprogra       --> Codigo do programa
                                    ,pr_flultexe  => vr_flultexe       --> Retorna se é a ultima execução do procedimento
                                    ,pr_qtdexec   => vr_qtdexec        --> Retorna a quantidade
                                    ,pr_cdcritic  => vr_cdcritic       --> Codigo da critica de erro
                                    ,pr_dscritic  => vr_dscritic);     --> descrição do erro se ocorrer
      IF nvl(vr_cdcritic,0) > 0 OR
        TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := 'Falha na execucao do Job da '|| vr_cdprogra||
                        ' (Coop:'||pr_cdcooper||'): '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
      --Commit para garantir o 
      --controle de execucao do programa
      COMMIT;
         
      -- Para cada aplicação/resgate agendado
      FOR rw_crapaar IN cr_crapaar(rw_crapcop.cdcooper) LOOP
            
        --Limpa variáveis de erro
        vr_cdcritic := 0;
        vr_dscritic := '';
        
        /* se tipo for aplicacao(flgtipar=0) ou resgate(flgtipar=1)
           pegar o nro lote e o historico correspondente*/
        IF rw_crapaar.flgtipar = 0 THEN
            
          vr_nrdolote := 32001;  /*lote agendamento aplicacao*/
          vr_cdhistor := 527;    /*historico DB APL RDCPOS*/
          
        ELSE /*tratamentos referentes a agendamentos de resgate*/
             
          vr_nrdolote := 32002;  /*lote agendamento resgate*/ 
          vr_cdhistor := 530;    /*historico CR APL RDCPOS*/
             
        END IF;   
          
        /*montar chave necessaria para encontrar os lancamentos automaticos do agendamento*/
        vr_nrdocsrc := TO_CHAR(vr_nrdolote,'fm00000') || TO_CHAR(rw_crapaar.nrdocmto,'fm0000000000') || '%'; 
                                              
        /*pegar os lancamentos de agendamento da lautom que devem ser efetuados no dia*/
        FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapaar.cdcooper
                                    ,pr_nrdconta => rw_crapaar.nrdconta
                                    ,pr_cdhistor => vr_cdhistor
                                    ,pr_nrdolote => vr_nrdolote
                                    ,pr_nrdocmto => vr_nrdocsrc
                                    ,pr_dtmvtocd => rw_crapdat.dtmvtocd) LOOP
                                    
          BEGIN                     
                    
            OPEN cr_craplot(pr_cdcooper => rw_craplau.cdcooper
                           ,pr_dtmvtolt => rw_craplau.dtmvtolt
                           ,pr_nrdolote => rw_craplau.nrdolote);
                               
            FETCH cr_craplot INTO rw_craplot;
              
            --Se nao encontrou lote
            IF cr_craplot%NOTFOUND THEN
                
               --Fecha cursor craplot
               CLOSE cr_craplot;
                 
               vr_cdcritic := 0;
               vr_dscritic := 'Lote nao encontrado ('||TO_CHAR(rw_craplau.cdcooper)||' | '||TO_CHAR(rw_craplau.nrdolote)||' | '||TO_CHAR(rw_craplau.dtmvtolt,'DD/MM/RRRR')||')';
                 
               
               RAISE vr_controla_rejeitado;
                  
            END IF;    
        
            --Fecha cursor craplot
            CLOSE cr_craplot;
            
            -- Agendamento de aplicacao  
            IF rw_crapaar.flgtipar = 0 THEN           
              
               OPEN cr_crapttx(pr_cdcooper => rw_craplau.cdcooper
                              ,pr_tptaxrdc => 8 /*RDC POS*/
                              ,pr_qtdiacar => rw_crapaar.qtdiacar); /*Qtd dias carencia*/
                                
               FETCH cr_crapttx INTO rw_crapttx;
                 
               IF cr_crapttx%NOTFOUND THEN
                 
                  CLOSE cr_crapttx;
                    
                  vr_cdcritic := 0;
                  vr_dscritic := 'Taxa de aplicacao nao encontrada!';
                    
                  RAISE vr_controla_rejeitado;
                  
               END IF;  
              
               CLOSE cr_crapttx;


               vr_qtdiaapl := (rw_crapaar.dtvencto - rw_crapaar.dtiniaar);
               vr_dtvencto := rw_crapdat.dtmvtocd + vr_qtdiaapl;      
               vr_tipo     := 'A';
      
               IF vr_qtdiaapl <= (rw_crapaar.qtdiacar + 2) THEN
                  vr_tipo := 'P';
               END IF;
         
               IF vr_dtvencto IS NOT NULL THEN
                  vr_dtvencto := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, 
                                                             pr_dtmvtolt => vr_dtvencto,
                                                             pr_tipo => vr_tipo);
               END IF;

               apli0002.pc_incluir_nova_aplicacao(pr_cdcooper => rw_craplau.cdcooper
                                                 ,pr_cdagenci => rw_craplau.cdagenci
                                                 ,pr_nrdcaixa => 100
                                                 ,pr_cdoperad => rw_craplot.cdoperad
                                                 ,pr_nmdatela => 'CRPS688'
                                                 ,pr_idorigem => 1
                                                 ,pr_nrdconta => rw_craplau.nrdconta
                                                 ,pr_idseqttl => rw_crapaar.idseqttl
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                                 ,pr_tpaplica => 8 --RDC POS
                                                 ,pr_qtdiaapl => vr_qtdiaapl
                                                 ,pr_dtresgat => vr_dtvencto
                                                 ,pr_qtdiacar => rw_crapaar.qtdiacar
                                                 ,pr_cdperapl => rw_crapttx.cdperapl
                                                 ,pr_flgdebci => 0 --Nao debitar cta investimento
                                                 ,pr_vllanmto => rw_craplau.vllanaut
                                                 ,pr_flgerlog => 1
                                                 ,pr_nmdcampo => vr_nmdcampo
                                                 ,pr_nrdocmto => vr_nrdocmto
																								 ,pr_dsprotoc => vr_dsprotoc
                                                 ,pr_tab_msg_confirma => vr_tab_msg_confirma
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic);              
                                                     
                /* Quando houver algum erro na inclusão da aplicação, não esta sendo efetuado um ROLLBACK
                   pelo fato de que a procedure de pc_incluir_nova_aplicacao já esta realizando. */
                IF vr_cdcritic > 0 OR vr_dscritic <> ' ' THEN
                  
                  --Monta mensagem de critica
                  vr_cdcritic := vr_cdcritic;
                  vr_dscritic := vr_dscritic;
                  
                  RAISE vr_controla_rejeitado;
                  
                END IF;
                  
            -- Agendamento de resgate
            ELSE
              
              vr_tab_dados_resgate.DELETE;

              apli0001.pc_consulta_aplicacoes(pr_cdcooper => rw_craplau.cdcooper
                                             ,pr_cdagenci => rw_craplau.cdagenci
                                             ,pr_nrdcaixa => rw_craplot.nrdcaixa
                                             ,pr_nrdconta => rw_craplau.nrdconta
                                             ,pr_nraplica => 0
                                             ,pr_tpaplica => 0
                                             ,pr_dtinicio => NULL
                                             ,pr_dtfim => NULL
                                             ,pr_cdprogra => 'CRPS688'
                                             ,pr_nrorigem => 1
                                             ,pr_saldo_rdca => vr_saldo_rdca 
                                             ,pr_des_reto => vr_des_reto
                                             ,pr_tab_erro => vr_tab_erro);
                                             
              -- Verificar se possui alguma crítica
              IF vr_des_reto = 'NOK' THEN        
                
                IF vr_tab_erro.COUNT > 0 THEN
                  
                  -- Se existir erro adiciona na crítica
                  vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  
                  -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
                  vr_tab_erro.DELETE;
                  
                ELSE  
                  vr_cdcritic := 0;
                  vr_dscritic := 'Nao foi possivel consultar as aplicacoes.';
                END IF;
                
                RAISE vr_controla_rejeitado;
                  
              END IF;  
      
              IF vr_saldo_rdca.COUNT <= 0 THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Saldo insuficiente para resgate.';     
                
                RAISE vr_controla_rejeitado;        
              
              END IF;
              
              -- le a pltable das aplicacoes e remove todas que nao forem do tipo 8 - RDCPOS
              FOR idx IN vr_saldo_rdca.FIRST..vr_saldo_rdca.LAST LOOP
                
                IF vr_saldo_rdca(idx).tpaplica <> 8  THEN
                  vr_saldo_rdca.DELETE(idx);
                END IF;
                
              END LOOP;              
              
              apli0002.pc_filtra_aplic_resg_auto(pr_cdcooper => rw_craplau.cdcooper
                                                ,pr_cdagenci => rw_craplau.cdagenci
                                                ,pr_nrdcaixa => rw_craplot.nrdcaixa
                                                ,pr_cdoperad => rw_craplot.cdoperad
                                                ,pr_nmdatela => 'CRPS688'
                                                ,pr_idorigem => 1
                                                ,pr_nrdconta => rw_craplau.nrdconta
                                                ,pr_idseqttl => rw_crapaar.idseqttl
                                                ,pr_tab_saldo_rdca => vr_saldo_rdca
                                                ,pr_tpaplica => 8 --RDCPOS
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                ,pr_inproces => rw_crapdat.inproces
                                                ,pr_dtresgat => rw_crapdat.dtmvtocd
                                                ,pr_cdprogra => 'CRPS688'
                                                ,pr_flgerlog => 1
                                                ,pr_tab_dados_resgate => vr_tab_dados_resgate
                                                ,pr_tab_resposta_cliente => vr_tab_resposta_cliente
                                                ,pr_vltotrgt => rw_craplau.vllanaut 
                                                ,pr_tab_erro => vr_tab_erro
                                                ,pr_des_reto => vr_des_reto);
                                                    
              -- Verificar se possui alguma crítica
              IF vr_des_reto = 'NOK' THEN
                IF vr_tab_erro.COUNT > 0 THEN
                    
                  -- Se existir erro adiciona na crítica
                  vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                    
                  -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
                  vr_tab_erro.DELETE;
                    
                ELSE  
                  vr_cdcritic := 0;
                  vr_dscritic := 'Nao foi possivel listar as aplicacoes.';
                END IF;
                  
                RAISE vr_controla_rejeitado;
                   
              END IF;   

              -- Despreza resgate quando não houver valor suficiente para suprir o valor a ser resgatado
              IF rw_craplau.vllanaut > 0 THEN
                
                vr_cdcritic := 0;
                vr_dscritic := 'Saldo insuficiente para resgate.';     
                
                RAISE vr_controla_rejeitado;        
              
              END IF;
              
              vr_indice := vr_tab_dados_resgate.first;
              
              --Se não foi encontrado nenhuma aplicação para efetuar o resgate então, cai fora do loop
              IF vr_indice IS NULL THEN
                
                --Monta critica
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi encontrado aplicacoes para serem efetuado(s) o(s) resgate(s).';
                
                RAISE vr_controla_rejeitado;
                
              END IF;  
              
              SAVEPOINT TRANSACAO;
              
              BEGIN   
                
                WHILE vr_indice IS NOT NULL LOOP

                  APLI0002.pc_cad_resgate_aplica(pr_cdcooper => rw_craplau.cdcooper
                                                ,pr_cdagenci => rw_craplau.cdagenci
                                                ,pr_nrdcaixa => rw_craplot.nrdcaixa
                                                ,pr_cdoperad => rw_craplot.cdoperad
                                                ,pr_nmdatela => 'CRPS688'
                                                ,pr_idorigem => 1 --Ayllos Caracter
                                                ,pr_nrdconta => rw_craplau.nrdconta
                                                ,pr_nraplica => vr_tab_dados_resgate(vr_indice).saldo_rdca.nraplica
                                                ,pr_idseqttl => rw_craplau.idseqttl
                                                ,pr_cdprogra => 'CRPS688'
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                ,pr_inproces => rw_crapdat.inproces
                                                ,pr_vlresgat => (CASE vr_tab_dados_resgate(vr_indice).tpresgat
                                                                     WHEN 1 THEN
                                                                       vr_tab_dados_resgate(vr_indice).vllanmto                                                                   
                                                                     ELSE
                                                                       0
                                                                  END) 
                                                ,pr_dtresgat => rw_crapdat.dtmvtocd
                                                ,pr_flmensag => 0
                                                ,pr_tpresgat => (CASE vr_tab_dados_resgate(vr_indice).tpresgat
                                                                     WHEN 1 THEN
                                                                       'P'
                                                                     WHEN 2 THEN
                                                                       'T'
                                                                     ELSE
                                                                       ''
                                                                  END) 
                                                ,pr_flgctain => 0
                                                ,pr_flgerlog => 1
                                                ,pr_nrdocmto => vr_nrdocmto
                                                ,pr_des_reto => vr_des_reto
                                                ,pr_tbmsconf => vr_tab_msg_confirma
                                                ,pr_tab_erro => vr_tab_erro);
                          
                  -- Verificar se possui alguma crítica
                  IF vr_des_reto = 'NOK' THEN
                    IF vr_tab_erro.COUNT > 0 THEN
                      -- Se existir erro adiciona na crítica
                      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                      -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
                      vr_tab_erro.DELETE;
                    ELSE  
                      vr_cdcritic := 0;
                      vr_dscritic := 'Nao foi possivel listar as aplicacoes.';
                    END IF;
                    
                    -- Executa a exceção
                    RAISE vr_exc_controle;
                  END IF;         
                  
                  -- ir para o proximo
                  vr_indice := vr_tab_dados_resgate.NEXT(vr_indice);                               
                    
                END LOOP;              
                
              EXCEPTION 
                WHEN vr_exc_controle THEN

                  ROLLBACK TO SAVEPOINT TRANSACAO;
                  RAISE vr_controla_rejeitado;
                  
                WHEN OTHERS THEN

                  ROLLBACK TO SAVEPOINT TRANSACAO;
                  RAISE vr_controla_rejeitado;
              END;          
                       
            END IF;  
            
            /*Cada vez que uma aplicacao/resgate for efetivado atualizar
              qtd de meses efetivados na tabela crapaar para indicar que foi realizado
              o agendamento do mes corrente.*/
            BEGIN
              -- Incrementa numero de meses da aplicacao/resgate atual
              UPDATE crapaar
                 SET crapaar.nrmesaar = crapaar.nrmesaar + 1
               WHERE crapaar.rowid = rw_crapaar.rowid;
                 
              rw_crapaar.nrmesaar := rw_crapaar.nrmesaar + 1;
            EXCEPTION
              WHEN OTHERS THEN
                
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar numero de meses da aplicacao/resgate atual da crapaar --> '|| SQLERRM;
                
                RAISE vr_controla_rejeitado;
                
            END;
            
            /*Verifica se é o último resgate/aplicacao do agendamento em questão para
              que, antes de atualizar a crapaar, garanta que todas as parcelas foram efetivadas.*/
            IF rw_crapaar.nrmesaar = rw_crapaar.qtmesaar THEN
              
              BEGIN
                -- Atualiza situação da crapaar para 5 - Vencido
                UPDATE crapaar
                   SET crapaar.cdsitaar = 5
                 WHERE crapaar.rowid = rw_crapaar.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar situacao da crapaar --> '|| SQLERRM;
                  
                  RAISE vr_controla_rejeitado;
                  
              END;            
                  
            END IF;
                                                     
            /*Atualiza a situação do lançamento automatico para EFETIVADO*/
            BEGIN
              -- Incrementa numero de meses da aplicacao/resgate atual
              UPDATE craplau
                 SET craplau.insitlau = 2 -- Efetivado                  
                    ,craplau.dtdebito = rw_crapdat.dtmvtocd
               WHERE craplau.rowid = rw_craplau.rowid;               

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar a situacao atual da craplau --> '|| SQLERRM;
                RAISE vr_controla_rejeitado;
            END;
            
            --Cria registro de sucesso para ser apresentado no relatorio
            vr_ind := vr_tab_reg_agendamento.COUNT;
            vr_tab_reg_agendamento(vr_ind).nrdconta := rw_crapaar.nrdconta;
            vr_tab_reg_agendamento(vr_ind).flgtipar := rw_crapaar.flgtipar;
            vr_tab_reg_agendamento(vr_ind).vlparaar := rw_crapaar.vlparaar;
            vr_tab_reg_agendamento(vr_ind).nrparcel := TO_CHAR(NVL(rw_crapaar.nrmesaar,0)) || '/' ||
                                                       TO_CHAR(NVL(rw_crapaar.qtmesaar,0));                                                    
            vr_tab_reg_agendamento(vr_ind).dscritic := 'Agendamento efetuado com sucesso.';
            
            --Gera exceção para efetuar o commit das informações                              
            RAISE vr_controla_commit;
            
          EXCEPTION
            WHEN vr_controla_commit THEN 
              
              --Efetua o commit das informações
              COMMIT;
              
            WHEN vr_controla_rejeitado THEN
               
              pc_efetua_rejeicao(pr_nrdconta => rw_crapaar.nrdconta
                                ,pr_inproces => rw_crapdat.inproces
                                ,pr_flgtipar => rw_crapaar.flgtipar
                                ,pr_vlparaar => rw_crapaar.vlparaar
                                ,pr_nrparcel => TO_CHAR(NVL(rw_crapaar.nrmesaar,0) + 1) || '/' ||
                                                TO_CHAR(NVL(rw_crapaar.qtmesaar,0))
                                ,pr_rowidaar => rw_crapaar.rowid
                                ,pr_rowidlau => rw_craplau.rowid
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdhistor => vr_cdhistor
                                ,pr_nrdolote => vr_nrdolote
                                ,pr_dtmvtocd => rw_crapdat.dtmvtocd
                                ,pr_nrdocsrc => vr_nrdocsrc
                                ,pr_nrmesaar => rw_crapaar.nrmesaar
                                ,pr_qtmesaar => rw_crapaar.qtmesaar
                                ,pr_des_reto => vr_des_reto
                                ,pr_cdcriret => vr_cdcritic 
                                ,pr_dscriret => vr_dscritic);
                                
              IF vr_des_reto = 'NOK' THEN
                --Chama a rotina que ira ler a pl_table e gerar o relatorio
                pc_gera_relatorio(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                                 
                --Gera exceção                 
                RAISE vr_exc_saida;
              
              END IF;                  
                                
              --Efetua o commit das operações
              COMMIT;                  
              
            WHEN OTHERS THEN
              
              pc_efetua_rejeicao(pr_nrdconta => rw_crapaar.nrdconta
                                ,pr_inproces => rw_crapdat.inproces
                                ,pr_flgtipar => rw_crapaar.flgtipar
                                ,pr_vlparaar => rw_crapaar.vlparaar
                                ,pr_nrparcel => TO_CHAR(NVL(rw_crapaar.nrmesaar,0) + 1) || '/' ||
                                                TO_CHAR(NVL(rw_crapaar.qtmesaar,0))
                                ,pr_rowidaar => rw_crapaar.rowid
                                ,pr_rowidlau => rw_craplau.rowid
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdhistor => vr_cdhistor
                                ,pr_nrdolote => vr_nrdolote
                                ,pr_dtmvtocd => rw_crapdat.dtmvtocd
                                ,pr_nrdocsrc => vr_nrdocsrc
                                ,pr_nrmesaar => rw_crapaar.nrmesaar
                                ,pr_qtmesaar => rw_crapaar.qtmesaar
                                ,pr_des_reto => vr_des_reto
                                ,pr_cdcriret => vr_cdcritic 
                                ,pr_dscriret => vr_dscritic);
              
              IF vr_des_reto = 'NOK' THEN
                --Chama a rotina que ira ler a pl_table e gerar o relatorio
                pc_gera_relatorio(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                
                --Gera exceção
                RAISE vr_exc_saida;
              
              END IF;
              
              --Efetua o commit das operações
              COMMIT;  
          
          END;
          
        END LOOP;          
          
      END LOOP;   
      
      --Chama a rotina que ira ler a pl_table e gerar o relatorio
      pc_gera_relatorio(pr_cdcooper => pr_cdcooper
                       ,pr_cdprogra => vr_cdprogra
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                                                       
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
             
      --Efetua o commit das informações                  
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Montar mensagem de critica
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 90
                             ,pr_nrdcaixa => 100
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
                             
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;  
        
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || '(Conta - Historico): ' 
                                                   || rw_craplau.nrdconta 
                                                   || ' - ' || rw_craplau.cdhistor
                                                   || vr_cdcritic 
                                                   || vr_dscritic);
                                                   
        -- Efetuar rollback
        ROLLBACK;   
      
      WHEN vr_exc_fimprg THEN
        
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
                                                                                                      
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps688;
/
