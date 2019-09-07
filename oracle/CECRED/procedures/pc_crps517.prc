CREATE OR REPLACE PROCEDURE CECRED.pc_crps517(pr_cdcooper IN crapcop.cdcooper%TYPE) IS   --> Cooperativa solicitada
  BEGIN
    /* .............................................................................

    Programa: pc_crps517 (Fontes/crps517.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Outubro/2008                    Ultima Atualizacao: 20/09/2017

    Dados referente ao programa:
    
    Frequencia: Diario.
    
    Objetivo  : Controlar vigencia dos contratos de limite e o debito de 
                titulos em desconto que atingiram a data de vencimento.
                
    Alteracoes: 06/01/2009 - Tratamento p/ feriados e fins de semana (Evandro).
    
                28/05/2009 - Antes de efetuar a baixa do titulo como vencido
                             verificar se o crapcob esta baixado, caso esteja
                             jogar uma critica no processo pois ocorreu problema
                             na baixa do titulo quando ele foi pago
                             (Compe ou Caixa e Internet) (Guilherme).

                02/06/2009 - Retirado a critica do log, porque foi colocado
                             tratamento de erros dentro de b2crap14(Guilherme).
                             
                10/12/2009 - Imprimir cada relatorio 497 dos PAs (Evandro).
                
                30/11/2011 - Condiçao para nao executar relatórios 497 e nao dar
                             baixa nos títulos no último dia útil do ano (Lucas).
                         
                28/06/2012 - Incluido novo parametro na busca_tarifas_dsctit.
                             (David Kruger).
                             
                15/10/2012 - Incluido coluna Tipo Cobr. no relat. 497 (Rafael).

                06/11/2012 - Incluido chamada da procedure desativa-rating
                             da BO43 (Tiago).
                             
                12/07/2013 - Alterado processo para busca valor tarifa renovacao,
                             projeto tarifas (Daniel).
                             
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               27/11/2013 - Incluido chamada do fimprg antes do return que
                            abortava o programa sendo que nao era um erro
                            (Tiago).      
                            
               28/11/2013 - Retirado return no caso de tarifa de renovacao zerada
                            (Daniel).             
                            
               23/12/2013 - Alterado totalizador de PAs de 99 para 999. 
                            (Reinert)                            

               19/05/2014 - Conversao Progress => Oracle (Andrino-RKAM).
               
               13/11/2014 - Inclusão do titulo "Nova Vigencia" e "Fim Vigencia"
                            Projeto Conversao Progress / Oracle (Andrino-RKAM).

               10/02/2015 - Ajuste na sequencia do cabecalho do crrl497 (Andrino-RKAM).      
               
               13/02/2015 - Ajuste para enviar por email a critica de tarifa não encontrada
                            SD250545 (Odirlei-AMcom).         
                            
               29/04/2015 - Alterado para substituir o "&" do nome do sacado por "e"
                            para não ocorrer erro no parse do xml (Odirlei-AMcom)                     
               
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)                           
                            
               17/02/2016 - Retirado debito de titulos vencidos 
                           (Tiago/Rodrigo Melhoria 116 SD344086)
                           
               30/03/2016 - Alterar procedure para ser chamada pelo job.
                            (Lucas Ranghetti #402276)

               21/02/2017 - #551221 Ajuste de padronização do nome do job e log de início 
                            e fim do mesmo no proc_batch (Carlos)
                            
               29/06/2017 - Colocado Log no padrão
                            tratado Others
                            (Belli - Envolti - Chamado 660306)

               20/09/2017 - Ajustado para não gravar nmarqlog, pois so gera a tbgen_prglog
                            (Ana - Envolti - Chamado 746134)
                           
    ............................................................................ */
DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS517';       --> Código do programa
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

      vr_tempo        NUMBER;
            
      vr_nomdojob CONSTANT VARCHAR2(26) := 'jbdsct_limite_desconto';
      vr_cdcooper crapcop.cdcooper%TYPE := 3;
      
      -- Chamado 660306 - 10/07/2017
      -- Variaveis de inclusão de log 
      vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;      
      
      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.cdagebcb
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper <> 3
           AND cop.flgativo = 1
         ORDER BY cop.cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);      

       -- Valida inclusive se é dia útil
       gene0004.pc_executa_job( pr_cdcooper => 3   --> Codigo da cooperativa
                               ,pr_fldiautl => 1   --> Flag se deve validar dia util
                               ,pr_flproces => 0   --> Flag se deve validar se esta no processo
                               ,pr_flrepjob => 1   --> Flag para reprogramar o job
                               ,pr_flgerlog => 1   --> indicador se deve gerar log
                              ,pr_nmprogra => vr_nomdojob   --> Nome do programa que esta sendo executado no job
                               ,pr_dscritic => vr_dscritic);
                               
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      FOR rw_crapcop IN cr_crapcop LOOP
  
        vr_tempo := to_char(SYSDATE,'SSSSS');             
       
        vr_cdcooper := rw_crapcop.cdcooper;

        -- Mensagem de inicio não é gravafa pela rotina de log - 29/06/2017 - Chamado 660306
        vr_dscritic := null;        

        -- Colocado Log no padrão - 29/06/2017 - Chamado 660306                
        cecred.pc_log_programa(pr_dstiplog      => 'I',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                               pr_cdprograma    => vr_nomdojob,  -- tbgen_prglog
                               pr_cdcooper      => rw_crapcop.cdcooper,  -- tbgen_prglog
                               pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_tpocorrencia  => 4,            -- tbgen_prglog_ocorrencia - 4 MENSAGEM TRATADA
                               pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                               pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                               pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                               pr_nmarqlog      => NULL,
                               pr_idprglog      => vr_idprglog
                               ); 

        -- Leitura do calendario da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
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

        vr_xml_def := '';
        
        -- XML padrão com dados básicos para rodar o procedimento. É necessário devido à chamada pelo Ayllos WEB.
        vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>CRPS517</nmprogra>' ||
                      '<nmeacao>CRPS517</nmeacao><cdcooper>' || to_char(rw_crapcop.cdcooper) || '</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>1</idorigem>' ||
                      '<cdoperad>' || 1 || '</cdoperad></params></Root>';
        vr_xml := XMLType.createXML(vr_xml_def);

        LIMI0002.pc_crps517(pr_xmllog   => ''
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
        -- Seta modulo no retorno da package disparada - Chamado 660306 - 29/06/2017                   
        -- Incluir nome do modulo logado, action = null porque não tem subrotina mnessa procedure
        GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                  ,pr_action => null); 


        /****************************************************************************************
        Validacoes finais do programa não serão efetuadas, pois o programa não rodará na cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        ***************************************************************************************/
        -- Mensagem de inicio não é gravada pela rotina de log - 29/06/2017 - Chamado 660306
        vr_dscritic := null;        
        
        -- Colocado Log no padrão - 29/06/2017 - Chamado 660306                                                  
        cecred.pc_log_programa(pr_dstiplog      => 'F',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                               pr_cdprograma    => vr_nomdojob,  -- tbgen_prglog
                               pr_cdcooper      => rw_crapcop.cdcooper,  -- tbgen_prglog
                               pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_tpocorrencia  => 4,            -- tbgen_prglog_ocorrencia - 4 MENSAGEM TRATADA
                               pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                               pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                               pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                               pr_nmarqlog      => NULL,
                               pr_idprglog      => vr_idprglog
                               ); 
                       
        -- Commitar as alterações
        COMMIT;
      END LOOP;           
      
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_fimprg THEN

          -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

          -- Colocado Log no padrão - 29/06/2017 - Chamado 660306          
          vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_nomdojob || 
                                 ' --> ' || 
                                 'ERRO: ' || vr_dscritic ||
                                 ', pr_cdcooper=' || vr_cdcooper ||                     
                                 ' - Module: ' || vr_nomdojob;
          -- Envio centralizado de log de erro
          cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                 pr_cdprograma    => vr_nomdojob,  -- tbgen_prglog
                                 pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                                 pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                                 pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                                 pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                                 pr_nmarqlog      => NULL,
                                 pr_idprglog      => vr_idprglog
                                 ); 
        END IF;

			  /****************************************************************************************
			  Validacoes finais do programa não serão efetuadas, pois o programa não rodará na cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        ***************************************************************************************/

				-- Efetuar commit
--        COMMIT;

      WHEN vr_exc_saida THEN

          -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Colocado Log no padrão - 29/06/2017 - Chamado 660306         
          vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_nomdojob || 
                                 ' --> ' || 
                                 'ERRO: ' || vr_dscritic ||
                                 ', pr_cdcooper=' || vr_cdcooper ||                     
                                 ' - Module: ' || vr_nomdojob;
          -- Envio centralizado de log de erro
          cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                 pr_cdprograma    => vr_nomdojob,  -- tbgen_prglog
                                 pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                                 pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                                 pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                                 pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                                 pr_nmarqlog      => NULL,
                                 pr_idprglog      => vr_idprglog
                                 );
        END IF;

        -- Efetuar rollback
        ROLLBACK;

     WHEN OTHERS THEN        
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2017 - Chamado 660306        
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);       

        -- EFETUAR RETORNO DO ERRO NÃO TRATADO
        vr_cdcritic := 0;
        vr_dscritic := sqlerrm;

        -- Colocado Log no padrão - 29/06/2017 - Chamado 660306         
        vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_nomdojob || 
                               ' --> ' || 
                               'ERRO: ' || vr_dscritic ||
                               ', pr_cdcooper=' || vr_cdcooper ||                     
                               ' - Module: ' || vr_nomdojob;

          -- Envio centralizado de log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                               pr_cdprograma    => vr_nomdojob,  -- tbgen_prglog
                               pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                               pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                               pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                               pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                               pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                               pr_nmarqlog      => NULL,
                               pr_idprglog      => vr_idprglog
                               );
        -- Efetuar rollback
        ROLLBACK;

    END;

  END pc_crps517;
/
