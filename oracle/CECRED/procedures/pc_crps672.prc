CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS672 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Código do operador
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ..........................................................................

       Programa: pc_crps672
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Abril/2014.                     Ultima atualizacao: 17/04/2017

       Dados referentes ao programa:

       Frequencia: Diário.
       Objetivo  : Atende a solicitacao 01, Ordem 36.
                   Tratar arquivo de retorno da Solicitação de Cartão (Bancoob/CABAL).
                   Relatório crrl676 - Rejeições Processamento Arq. Retorno

       Alteracoes: 22/08/2014 - Ajustes para validação do processamento do arquivo,
                               alteração para buscar leitura do arquivo conforme cadastro.(Odirlei-AMcom)
                               
                   27/08/2014 - Realizar commit a cada processamento de arquivo(Odirlei/Amcom)
                   
                   08/09/2014 - Retirar código da Versão temporária, devido a solicitação via 
                                chamado SD 197307 (Renato - Supero)
                                
                   25/09/2014 - Incluir regra para buscar cartão em uso no cursor
                                cr_crawcrd_cdgrafin  ( Renato - Supero )
                                
                   30/09/2014 - Alterado as regras para tratamento de arquivo e
                                ajustada ordenação do relatório de rejeitados
                                (Renato - Supero)
                                
                   14/10/2014 - Alterações no formato do relatório conforme SD 204500 (Vanessa)

                   04/11/2014 - Quando inserir um novo CRAWCRD, deverá incluir o valor
                                do flgprcrd, conforme o valor do cartão encerrado ( Renato - Supero )
                                
                   11/11/2014 - Ajustar programa para gravar as datas relacionadas a solicitação
                                de segunda via de cartão, conforme chamado 217188 e ajuste nos 
                                selects do grupo de afinidade, afim de filtrar apenas por 
                                administradoras do Bancoob ( Renato - Supero )
                                
                   13/11/2014 - Alteração para não exibir as criticas menores que 10 e maiores 
                                que 900 (Vanessa)
                                
                   10/03/2015 - Alterado para gravar corretamente as datas de solicitação de 
                                segunda via de cartão, conforme chamado 251387 ( Renato - Supero )
                                
                   21/07/2015 - Realizado ajuste para ignorar linhas com crítica, onde a conta(posição 337)
                                esteja com valor igual a zero. Alteração realizada devido a erros ocorridos
                                no processo batch. (Renato - Supero)
                                
                   15/10/2015 - Desenvolvimento do projeto 126. (James)
                   
                   02/12/2015 - Ajuste para mostrar a Administradora no relatorio. (James)
                   
                   07/12/2015 - Resolução do chamado 370195.
                                Ajuste para gravar o codigo da administradora para os cartoes solicitados apartir do
                                Bancoob. (James)
                                
                   15/02/2016 - Ajuste para gerar no relatorio de criticas 676 retorno de solicitacao
                                criticado que vier com os dados do CNPJ. (Chamado 389699) - (Fabricio)
                                
                   10/03/2016 - Feita a troca de log do batch para o proc_message conforme
                                solicitado no chamado 405441 (Kelvin).
                                
                   12/05/2016 - Ajustado situacao de Cancelado para 6 no cursor cr_crawcrd_cdgrafin_conta
                                pois esse eh o indicador de cartao cancelado quando trata-se de
                                Cartao Cecred (Bancoob). (Chamado 433197 entre outros...) - (Fabricio)
                                
                   22/06/2016 - Ajuste no ELSE que verifica a existencia de registro na leitura do
                                cursor cr_crapacb para nao gerar mais RAISE, mas sim, gravar log
                                e continuar processando o arquivo. (Fabricio)
                                
                   29/06/2016 - Ajuste no cursor cr_crawcrd_cdgrafin_conta para contemplar a busca
                                tanto por cartoes Bloqueados quanto Cancelados (insitcrd = 5,6).
                                (Chamados 478655, 478680 entre outros...) - (Fabricio)
                                
                   14/07/2016 - Ajustado a identificacao dos dados da conta e controle na leitura do
                                numero da conta quando o valor recebido eh zero
                                (Douglas - Chamado 465010, 478018)

                   04/10/2016 - Ajustado para gravar o nome da empresa do plastico quando criar uma
                                nova proposta de cartao (Douglas - Chamado 488392)
                                
                   10/10/2016 - Ajuste para nao voltar para Aprovado uma solicitacao que
                                retornar com critica 80 do Bancoob (pessoa ja tem cartao nesta conta).
                                (Chamado 532712) - (Fabrício)

				           01/11/2016 - Ajustes quando ocorre integracao de cartao via Upgrade/Downgrade.
                                (Chamado 532712) - (Fabricio)
                                
                   11/11/2016 - Adicionado validação de CPF do primeiro cartão da administradora
                                para que os cartões solicitados como reposição também tenham a mesma
                                flag de primeiro cartão (Douglas - Chamado 499054 / 541033)
                                
                   24/11/2016 - Ajuste para alimentar o campo de indicador de funcao debito (flgdebit)
                                com a informacao que existe na linha do arquivo referente a
                                funcao habilitada ou nao. (Fabricio)
                              - Quando tipo de operacao for 10 (desbloqueio) e for uma reposicao de cartao,
                                chamar a procedure atualiza_situacao_cartao para cancelar o cartao
                                anterior. (Chamado 559710) - (Fabricio)
                                
                   05/12/2016 - Correcao no cursor cr_crapcrd para buscar cartoes atraves do indice da tabela
                                e inclusao da validacao da existencia de cartoes sem proposta gerando log 
                                no proc_message. SD 569619 (Carlos Rafael Tanholi)
                                
                   02/01/2017 - Ajuste na leitura dos registros de cartoes ja existentes.
                                (Fabricio)
                                
                   06/02/2017 - Ajuste para nao atualizar a wcrd em cima de um cartao ja existente
                                quando se trata de reposicao/2a via. (Fabricio)
                                
                   17/04/2017 - Alterar programa para ser uma JOB e chamar o crps672 que
                                foi incluido na package ccrd0003 (Lucas Ranghetti #630298)
    ............................................................................ */

    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS672';       --> Código do programa
      vr_nmdcampo   VARCHAR2(1000);                                    --> Variável de Retorno Nome do Campo		
      vr_des_erro   VARCHAR2(2000);                                    --> Variável de Retorno Descr Erro											
			vr_xml        xmltype;			                                     --> Variável de Retorno do XML
			vr_xml_def    VARCHAR2(4000);                                    --> XML Default de Entrada

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);
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
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel nao for 0
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      *****************************************************************************************/      

    	-- XML padrão com dados básicos para rodar o procedimento. 
 		  vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>CCR3</nmprogra>' ||
			              '<nmeacao>CRPS672</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>1</idorigem>' ||
										'<cdoperad>' || pr_cdoperad || '</cdoperad></params></Root>';										
      vr_xml := XMLType.createXML(vr_xml_def);									

			CCRD0003.pc_crps672(pr_xmllog   => ''
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

        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
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
        ****************************************************************************************/

        -- Efetuar commit
        COMMIT;

      WHEN vr_exc_saida THEN

        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
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

        btch0001.pc_log_internal_exception(3);
        
        -- Efetuar rollback
        ROLLBACK;

    END;

END PC_CRPS672;
/
