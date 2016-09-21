CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS671 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Código do operador
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  BEGIN

/* ..........................................................................

       Programa: pc_crps671
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Março/2014.                     Ultima atualizacao: 17/07/2015

       Dados referentes ao programa:

       Frequencia: Diário.
       Objetivo  : Atende a solicitacao ??. Rodado via CRON ou Manualmente (tela ARQBCB).
                   Criar o arquivo de Solicitação de Cartão de Crédito (Bancoob/CABAL).

       Alteracoes:
       
       17/07/2015 - #309876 Log para as exceptions vr_exc_saida e OTHERS (Carlos)

    ............................................................................ */

    DECLARE		  
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS671';       --> Código do programa			
      vr_nmdcampo   VARCHAR2(1000);                                    --> Variável de Retorno Nome do Campo		
      vr_des_erro   VARCHAR2(2000);                                    --> Variável de Retorno Descr Erro											
			vr_xml        xmltype;			                                     --> Variável de Retorno do XML
			vr_xml_def    VARCHAR2(4000);                                    --> XML Default de Entrada

			-- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
			vr_tp_excep   VARCHAR2(1000);
      
      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.cdagebcb
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;     

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
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

 			/****************************************************************************************
      Validacoes iniciais do programa não serão efetuadas, pois o programa não rodará na cadeia
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 0 -- Lunelli colocar '1' após testes
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel nao for 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
			***************************************************************************************/
			
			-- XML padrão com dados básicos para rodar o procedimento. É necessário devido à chamada pelo Ayllos WEB.
 		  vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>ARQBCB</nmprogra>' ||
			              '<nmeacao>CRPS671</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>1</idorigem>' ||
										'<cdoperad>' || pr_cdoperad || '</cdoperad></params></Root>';										
      vr_xml := XMLType.createXML(vr_xml_def);									
																						
			CCRD0003.pc_crps671(pr_xmllog   => ''
												 ,pr_cdcritic => vr_cdcritic
												 ,pr_dscritic => vr_dscritic
												 ,pr_retxml   => vr_xml
												 ,pr_nmdcampo => vr_nmdcampo
												 ,pr_des_erro => vr_des_erro);
																 
	    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN								
				-- Busca o tipo de Exception em que deve dar RAISE
				vr_tp_excep := gene0007.fn_valor_tag(pr_xml     => vr_xml
																            ,pr_pos_exc => 0
																            ,pr_nomtag  => 'TpException');
        -- Define a Exception a ser levantada
        CASE vr_tp_excep
					WHEN 1 THEN RAISE vr_exc_saida;
          WHEN 2 THEN RAISE vr_exc_fimprg;             
          ELSE        RAISE vr_exc_saida;
        END CASE;								
			END IF;
																			       			
 			/****************************************************************************************
			Validacoes finais do programa não serão efetuadas, pois o programa não rodará na cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      ***************************************************************************************/
																		 
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN

        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN					
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
        END IF;

			  /****************************************************************************************
			  Validacoes finais do programa não serão efetuadas, pois o programa não rodará na cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        ***************************************************************************************/
				
				-- Efetuar commit
        COMMIT;

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
        END IF;

        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

     WHEN OTHERS THEN
        
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
        END IF;        
        
        -- Efetuar rollback
        ROLLBACK;

    END;

END PC_CRPS671;
/

