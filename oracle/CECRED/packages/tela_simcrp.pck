CREATE OR REPLACE PACKAGE CECRED.TELA_SIMCRP AS
  
/*..............................................................................

   Programa: tela_confrp                        Antigo: Nao ha
   Sistema : Ayllos
   Sigla   : CRED
   Autor   : Marcos Martini - Supero
   Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente a tela CONFRP

   Alteracoes: 
  
..............................................................................*/
  
  /* Procedimento para emitir o relatório crrl713 que gera a relação dos valores realizados para Reciprocidade */
  PROCEDURE pc_emite_crrl713(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                            ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Cooperado solicitado
                            ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data atual
                            ,pr_idcalculo IN tbrecip_calculo.idcalculo_reciproci%TYPE       --> Calculo vinculado
                            ,pr_idparame  IN tbrecip_parame_calculo.idparame_reciproci%TYPE --> ID parametrização calculo
                            ,pr_nmarqpdf OUT VARCHAR2              --> Nome do PDF do relatório gerado e copiado ao AyllosWeb
                            ,pr_dscritic OUT VARCHAR2);
                            
  /* Procedimento para emitir o relatório crrl713 que gera a relação dos valores realizados para Reciprocidade */
  PROCEDURE pc_emite_crrl713_web(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Cooperado solicitado
                                ,pr_idcalculo IN tbrecip_calculo.idcalculo_reciproci%TYPE       --> Calculo vinculado
                                ,pr_idparame  IN tbrecip_parame_calculo.idparame_reciproci%TYPE --> ID parametrização calculo
                                ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);             --Saida OK/NOK
                                
  /* Buscar configuracao de calculo de reprocidade */
  PROCEDURE pc_busca_sim_reciprocidade(pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE
                                      ,pr_idparame_reciproci  IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                      ,pr_cdcooper            IN crapcop.cdcooper%TYPE
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE
                                      ,pr_xmllog              IN VARCHAR2                --XML com informações de LOG
                                      ,pr_cdcritic            OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic            OUT VARCHAR2               --Descrição da crítica
                                      ,pr_retxml              IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                      ,pr_nmdcampo            OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro            OUT VARCHAR2);             --Saida OK/NOK
  
  /* Buscar configuracao de valor máximo e minimo */
  PROCEDURE pc_busca_conf_min_max(pr_ls_vlcontrata      IN VARCHAR2
                                 ,pr_idcalculo          IN tbrecip_calculo.idcalculo_reciproci%TYPE
                                 ,pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                 ,pr_xmllog             IN VARCHAR2                --XML com informações de LOG
                                 ,pr_cdcritic           OUT PLS_INTEGER            --Código da crítica
                                 ,pr_dscritic           OUT VARCHAR2               --Descrição da crítica
                                 ,pr_retxml             IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                 ,pr_nmdcampo           OUT VARCHAR2               --Nome do Campo
                                 ,pr_des_erro           OUT VARCHAR2);             --Saida OK/NOK

  /* Calcular o valor de desconto conforme previstoXrealizado. */
  PROCEDURE pc_pct_desconto_indicador_web(pr_idcalculo   IN tbrecip_calculo.idcalculo_reciproci%TYPE       -- Id do calculo (se já existir)
                                         ,pr_idparame    IN tbrecip_parame_calculo.idparame_reciproci%TYPE -- Id da parametrização envolvida
                                         ,pr_idindicador IN tbrecip_indicador.idindicador%TYPE             -- ID Indicador
                                         ,pr_vlrbase     IN NUMBER                                         -- Valor base
                                         ,pr_xmllog      IN VARCHAR2                --XML com informações de LOG
                                         ,pr_cdcritic    OUT PLS_INTEGER            --Código da crítica
                                         ,pr_dscritic    OUT VARCHAR2               --Descrição da crítica
                                         ,pr_retxml      IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                         ,pr_nmdcampo    OUT VARCHAR2               --Nome do Campo
                                         ,pr_des_erro    OUT VARCHAR2);             --Saida OK/NOK

  /* Salva configuracao de calculo de reprocidade */
  PROCEDURE pc_confirma_simc_reciprocidade(pr_ls_vlcontrata            IN VARCHAR2
                                          ,pr_idcalculo_reciproci      IN tbrecip_apuracao.idconfig_recipro%TYPE
                                          ,pr_idparame_reciproci       IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE 
                                          ,pr_qtdmes_retorno_reciproci IN VARCHAR2
                                          ,pr_flgreversao_tarifa       IN VARCHAR2
                                          ,pr_flgdebito_reversao       IN VARCHAR2
                                          ,pr_modo                     IN VARCHAR2
                                          ,pr_xmllog                   IN VARCHAR2                --XML com informações de LOG
                                          ,pr_cdcritic                 OUT PLS_INTEGER            --Código da crítica
                                          ,pr_dscritic                 OUT VARCHAR2               --Descrição da crítica
                                          ,pr_retxml                   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                          ,pr_nmdcampo                 OUT VARCHAR2               --Nome do Campo
                                          ,pr_des_erro                 OUT VARCHAR2);             --Saida OK/NOK
  /* Calcula a reciprocidade */
	PROCEDURE pc_calcula_reciprocidade(pr_cdcooper             IN  tbrecip_param_workflow.cdcooper%TYPE -- Identificador da cooperativa
		                                ,pr_ls_nrconvenio        IN  VARCHAR2                             -- Lista com os número dos convênios
		                                ,pr_qtboletos_liquidados IN  INTEGER                               -- Quantidade de boletos liquidados
																		,pr_vlliquidados         IN  VARCHAR2                               -- Volume (R$) de boletos liquidados
																		,pr_idfloating           IN  INTEGER                               -- Quantidade de dias de floating
																		,pr_idvinculacao         IN  INTEGER                               -- Identificador do grau de vinculação do cooperado
																		,pr_vlaplicacoes         IN  VARCHAR2                               -- Valor a ser aplicado pelo cooperado
																		,pr_vldeposito           IN  VARCHAR2                               -- Valor a ser depositado pelo cooperado
																		,pr_idcoo                IN  INTEGER                               -- Cooperado emite e expede
																		,pr_idcee                IN  INTEGER                               -- Cooperativa emite e expede
--																		,pr_lsconvenios          IN  VARCHAR2                             -- Lista de convênios
--																		,pr_vlcustos_coo         IN  NUMBER                               -- Valor dos custos COO
--																		,pr_vlcustos_cee         IN  NUMBER                               -- Valor dos custos CEE
																		,pr_xmllog               IN  VARCHAR2                             -- XML com informações de LOG
																		,pr_cdcritic             OUT PLS_INTEGER                          -- Código da crítica
																		,pr_dscritic             OUT VARCHAR2                             -- Descrição da crítica
																		,pr_retxml               IN OUT NOCOPY xmltype                    -- Arquivo de retorno do XML
																		,pr_nmdcampo             OUT VARCHAR2                             -- Nome do campo com erro
																		,pr_des_erro             OUT VARCHAR2                             -- Erros do processo
																		);
END TELA_SIMCRP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_SIMCRP AS

/*..............................................................................

   Programa: tela_confrp                        Antigo: Nao ha
   Sistema : Ayllos
   Sigla   : CRED
   Autor   : Marcos Martini - Supero
   Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente a tela CONFRP

   Alteracoes: 
  
..............................................................................*/

  
  /* Procedimento para emitir o relatório crrl713 que gera a relação dos valores realizados para Reciprocidade */
  PROCEDURE pc_emite_crrl713(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                            ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Cooperado solicitado
                            ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data atual
                            ,pr_idcalculo IN tbrecip_calculo.idcalculo_reciproci%TYPE       --> Calculo vinculado
                            ,pr_idparame  IN tbrecip_parame_calculo.idparame_reciproci%TYPE --> ID parametrização calculo
                            ,pr_nmarqpdf OUT VARCHAR2              --> Nome do PDF do relatório gerado e copiado ao AyllosWeb
                            ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_emite_crrl713                  Antigo: Não há
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Marcos Martini - SUPERO
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamado
    -- Objetivo  : Este procedimento é responsável por buscar as informações dos indicadores vinculados
    --             ao cooperado e os valores realizados nas ultimas 12 ocorrências do mesmo e então emitir 
    --             relatório das mesmas (Marcos-Supero).
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca do nome do titular
      CURSOR cr_ass IS
        SELECT nmprimtl 
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      -- Cursor genérico que irá trazer os indicadores vinculados ao cálculo 
      -- (quando já existir), ou os disponíveis quando estamos ainda sugerindo 
      -- a reciprocidade ao cooperado
      CURSOR cr_ind IS
        SELECT irc.idindicador
              ,gene0007.fn_caract_acento(irc.nmindicador) nmindicador
              ,irc.tpindicador
              ,decode(irc.tpindicador,'Q','Quantidade','M','Moeda','Adesao') dstpindicador
          FROM tbrecip_indica_calculo icr 
              ,tbrecip_indicador      irc
         WHERE icr.idcalculo_reciproci = pr_idcalculo
           AND icr.idindicador         = irc.idindicador
           AND pr_idcalculo            > 0 -- Somente quando houver
         UNION
        SELECT irc.idindicador
              ,gene0007.fn_caract_acento(irc.nmindicador) nmindicador
              ,irc.tpindicador
              ,decode(irc.tpindicador,'Q','Quantidade','M','Moeda','Adesao') dstpindicador
          FROM tbrecip_indicador             irc
              ,tbrecip_parame_indica_calculo ipr
         WHERE ipr.idparame_reciproci = PR_IDPARAME
           AND ipr.idindicador        = irc.idindicador
           AND irc.flgativo           = 1 --> Ativo globalmente
           AND pr_idcalculo           > 0 --> Somente quando houver
           -- E o mesmo não está selecionado no cálculo atual
           AND NOT EXISTS(SELECT 1 
                            FROM tbrecip_indica_calculo icr
                           WHERE icr.idcalculo_reciproci = pr_idcalculo
                             AND icr.idindicador         = irc.idindicador)
         UNION
        SELECT irc.idindicador
              ,gene0007.fn_caract_acento(irc.nmindicador) nmindicador
              ,irc.tpindicador
              ,decode(irc.tpindicador,'Q','Quantidade','M','Moeda','Adesao') dstpindicador
          FROM tbrecip_indicador     irc
              ,tbrecip_parame_indica_calculo ipr
         WHERE ipr.idparame_reciproci = pr_idparame
           AND ipr.idindicador        = irc.idindicador
           AND irc.flgativo           = 1 --> Ativo globalmente
           AND pr_idcalculo           = 0 --> Somente quando não há calculo                  
         ORDER BY idindicador;
      -- Valor realizado do indicador
      vr_valrealiz NUMBER;
      vr_qtdocorre NUMBER;
      vr_valacumul NUMBER;
      vr_dat_ini   DATE;
      vr_dat_fim   DATE;
      -- Variaveis para relatório
      vr_clobxml  CLOB;                   -- Clob para conter o XML de dados
      vr_nmdireto VARCHAR2(200);          -- Diretório para gravação do arquivo
      vr_dstxtemp VARCHAR2(32767);        -- Temporária para o texto do relatório
      -- Tratamento de exceção
      vr_exc_saida EXCEPTION;
      vr_dsretorn  VARCHAR2(100);
      vr_tab_erro  GENE0001.typ_tab_erro;
           
    BEGIN
      -- Busca do nome do cooperado
      OPEN cr_ass;
      FETCH cr_ass
       INTO vr_nmprimtl;
      CLOSE cr_ass; 
      -- Montar cabeçalho do relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,'<?xml version="1.0" encoding="utf-8"?><raiz><associ nrdconta="'||gene0002.fn_mask_conta(pr_nrdconta)||'" nmprimtl="'||vr_nmprimtl||'" >');
      -- Montar os prazos utilizados no calculo realizado
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,'<ocorrencias ');
      FOR vr_ind IN 1..12 LOOP
        vr_dat_ini := ADD_MONTHS(pr_dtmvtolt,vr_ind*-1)+1;
        vr_dat_fim := ADD_MONTHS(pr_dtmvtolt,(vr_ind-1)*-1);  
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,' oco_'||vr_ind||'="'||TO_char(vr_dat_ini,'dd/mm')||'>'||TO_char(vr_dat_fim,'dd/mm')||'" ');
      END LOOP;
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,'/>');
      -- Deveremos trazer os indicadores vinculados ao cálculo já efetuado, além dos outros 
      -- indicadores disponíveis ao convênio pois nada impede o operador de mudar um cálculo
      -- e adicionar novos indicadores ao cálculo após visualizar este relatório. 
      -- ou 
      -- Se não existe um cálculo, então traremos todos os indicadores disponíveis e ligados ao convênio atual
      FOR rw_ind IN cr_ind LOOP
        -- Iniciar a tag do indicador
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,'<indicador id="'||rw_ind.idindicador||'" nm="'||rw_ind.nmindicador||'" tp="'||rw_ind.dstpindicador||'" '); 
        -- Reiniciar variaveis
        vr_valrealiz := 0;
        vr_qtdocorre := 0;
        vr_valacumul := 0;
        -- Para cada indicador, iremos fazer um loop de 1 a 12
        FOR vr_ind IN 1..12 LOOP
          -- Buscar o valor realizado do indicador na ocorrência atual
          vr_valrealiz := RCIP0001.fn_valor_realizado_indicador(pr_cdcooper    => pr_cdcooper
                                                      ,pr_nrdconta    => pr_nrdconta
                                                      ,pr_idindicador => rw_ind.idindicador
                                                      ,pr_numocorre   => vr_ind);
          -- Somente enviar ao relatório quando valor vier <> -1, que é quando
          -- não há informação ou ocorreu erro no cálculo da ocorrência 
          IF vr_valrealiz != '-1' THEN
            -- Enviar ao XML do relatório o valor realizado formatado conforme o tipo do indicador
            gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,' val_'||vr_ind||'="'||gene0007.fn_caract_acento(RCIP0001.fn_format_valor_indicador(rw_ind.idindicador,vr_valrealiz))||'"');
            -- Somente para indicadores Quantidade ou Moeda
            IF rw_ind.tpindicador IN('Q','M') THEN
              -- Acumular variáveis
              vr_qtdocorre := vr_qtdocorre + 1;
              vr_valacumul := vr_valacumul + vr_valrealiz;
            END IF;  
          END IF;          
        END LOOP; -- Fim 12 ocorrências
        -- Calcular a média somente para Quantidade ou Moeda e Qtd ocorrências > 0
        IF rw_ind.tpindicador IN('Q','M') AND vr_qtdocorre > 0 THEN
          -- Calcular e formatar desde que qtde > 0
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,' media="'||RCIP0001.fn_format_valor_indicador(rw_ind.idindicador,vr_valacumul/vr_qtdocorre)||'"');      
        ELSE
          -- Média null
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,' media="---"');      
        END IF;
        -- Encerrar a tag do indicador
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,' />');      
      END LOOP; -- Fim indicadores
      -- Finalizar as tags abertas do relatório
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstxtemp,'</associ></raiz>',TRUE);      
      -- Buscar diretório rl
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl
      -- Submeter o relatório 250
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                 ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador
                                 ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/associ/indicador'      --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl713.jasper'              --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                          --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nmdireto||'/crrl713_'||pr_nrdconta||'.lst' --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                           --> 132 colunas
                                 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234col'                      --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                             --> Número de cópias
                                 ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                                 ,pr_cdrelato  => 713                           --> Código relatório
                                 ,pr_des_erro  => pr_dscritic);                 --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      
      -- Efetuar geração do LST como pdf
      gene0002.pc_cria_PDF(pr_cdcooper => pr_cdcooper        --> Cooperativa conectada
                          ,pr_nmorigem => vr_nmdireto||'/crrl713_'||pr_nrdconta||'.lst' --> Path arquivo origem
                          ,pr_ingerenc => 'NAo'              --> Não gerencial
                          ,pr_tirelato => '234col'           --> Tipo (80col, etc..)
                          ,pr_dtrefere => pr_dtmvtolt        --> Data de referencia
                          ,pr_nmsaida  => pr_nmarqpdf        --> Path do arquivo gerado
                          ,pr_des_erro => pr_dscritic);
      
      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      
      -- Por fim, copiar o PDF para o AyllosWeb
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => NULL            --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => NULL            --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => pr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_dsretorn     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
      -- Se encontrou erro
      IF nvl(vr_dsretorn,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Extrair somente o nome do PDF gerado
      gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarqpdf
                                     ,pr_direto  => vr_nmdireto
                                     ,pr_arquivo => pr_nmarqpdf);

      -- Efetuar commit
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Desfazer alterações
        ROLLBACK;
        -- Adicionar prefixo da procedure
        pr_dscritic := 'RCIP0001.pc_emite_crrl713 --> Erro tratado: ' || pr_dscritic;
      WHEN OTHERS THEN
        -- Desfazer alterações
        ROLLBACK;
        pr_dscritic := 'RCIP0001.pc_emite_crrl713 --> Erro não tratado: '||SQLERRM;
    END;
  END pc_emite_crrl713; 
  
  /* Procedimento para emitir o relatório crrl713 que gera a relação dos valores realizados para Reciprocidade */
  PROCEDURE pc_emite_crrl713_web(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Cooperado solicitado
                                ,pr_idcalculo IN tbrecip_calculo.idcalculo_reciproci%TYPE       --> Calculo vinculado
                                ,pr_idparame  IN tbrecip_parame_calculo.idparame_reciproci%TYPE --> ID parametrização calculo
                                ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) IS           --Saida OK/NOK
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_emite_crrl713                  Antigo: Não há
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Marcos Martini - SUPERO
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamado
    -- Objetivo  : Este procedimento é responsável por buscar as informações dos indicadores vinculados
    --             ao cooperado e os valores realizados nas ultimas 12 ocorrências do mesmo e então emitir 
    --             relatório das mesmas (Marcos-Supero).
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
    -- Variaveis genericas
    vr_nmarqpdf VARCHAR(200);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(3);
    
    -- calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_saida EXCEPTION;
    
    BEGIN
      
      gene0001.pc_informa_acesso(pr_module => 'TELA_SIMCRP', pr_action => 'PC_EMITE_CRRL713');
    
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Busca do calendário
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;  
      
      -- Acionar a emissão do relatório
      pc_emite_crrl713(pr_cdcooper  => pr_cdcooper
                      ,pr_nrdconta  => pr_nrdconta
                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                      ,pr_idcalculo => pr_idcalculo
                      ,pr_idparame  => pr_idparame
                      ,pr_nmarqpdf  => vr_nmarqpdf
                      ,pr_dscritic  => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      ELSE
         -- Criar cabeçalho do XML
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados>' || vr_nmarqpdf || '</Dados>');
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Erro tratado
        pr_dscritic := vr_dscritic;
        pr_des_erro := 'NOK';
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        -- Erro não tratado
        pr_dscritic := 'RCIP0001.pc_emite_crrl713_web --> Erro não tratado: '||SQLERRM;
        pr_des_erro := 'NOK';
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_emite_crrl713_web; 
    
  /* Buscar configuracao de calculo de reprocidade */
  PROCEDURE pc_busca_sim_reciprocidade(pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE
                                      ,pr_idparame_reciproci  IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                      ,pr_cdcooper            IN crapcop.cdcooper%TYPE
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE
                                      ,pr_xmllog              IN VARCHAR2                --XML com informações de LOG
                                      ,pr_cdcritic            OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic            OUT VARCHAR2               --Descrição da crítica
                                      ,pr_retxml              IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                      ,pr_nmdcampo            OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro            OUT VARCHAR2) IS           --Saida OK/NOK
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_sim_reciprocidade                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Lombardi
  --  Data     : Março/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Buscar configuracao de calculo de reprocidade.
  ---------------------------------------------------------------------------------------------------------------
    
    -- Busca dos valores previstos
    CURSOR cr_info_geral_calculo (pr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE) IS
      SELECT crc.qtdmes_retorno_reciproci
            ,crc.flgreversao_tarifa
            ,crc.flgdebito_reversao
        FROM tbrecip_calculo crc
       WHERE crc.idcalculo_reciproci = pr_idcalculo_reciproci;
    rw_info_geral_calculo cr_info_geral_calculo%ROWTYPE;
    
    CURSOR cr_calculo_indicador (pr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE) IS
      SELECT irc.idindicador
            ,irc.nmindicador
            ,decode(irc.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
            ,icr.vlcontrata
            ,icr.perdesconto
            ,icr.pertolera
        FROM tbrecip_indica_calculo icr 
            ,tbrecip_indicador      irc
       WHERE icr.idcalculo_reciproci = pr_idcalculo_reciproci
         AND icr.idindicador = irc.idindicador
       UNION
      SELECT irc.idindicador
            ,irc.nmindicador
            ,decode(irc.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
            ,0
            ,0
            ,ipr.pertolera
        FROM tbrecip_indicador             irc
            ,tbrecip_parame_indica_calculo ipr
       WHERE ipr.idparame_reciproci = pr_idparame_reciproci
         AND ipr.idindicador = irc.idindicador
         AND irc.flgativo = 1 --> Ativo globalmente
         -- E o mesmo não está selecionado no cálculo atual
         AND NOT EXISTS(SELECT 1 
                          FROM tbrecip_indica_calculo crc
                         WHERE crc.idcalculo_reciproci = pr_idcalculo_reciproci
                           AND crc.idindicador = irc.idindicador)
     ORDER BY idindicador;
    
    CURSOR cr_indicadores_disponiveis (pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE) IS
      SELECT irc.idindicador
            ,irc.nmindicador
            ,decode(irc.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
            ,ipr.pertolera
        FROM tbrecip_indicador irc
            ,tbrecip_parame_indica_calculo ipr
       WHERE ipr.idparame_reciproci = pr_idparame_reciproci
         AND ipr.idindicador = irc.idindicador
         AND irc.flgativo = 1 --> Ativo globalmente
     ORDER BY irc.idindicador;
    
    -- Variáveis genéricas
    vr_perdesmax               NUMBER;
    vr_contador                INTEGER;
    vr_vlminimo                VARCHAR2(100);
    vr_vlmaximo                VARCHAR2(100);
    vr_pertolera               VARCHAR2(100);
    vr_qtmes_retorno_reciproci INTEGER;
    vr_flgreversao_tarifa      INTEGER;
    vr_flgdebito_reversao      INTEGER;
    vr_vlcontrata              VARCHAR2(100);
    vr_ocorrencia              VARCHAR2(100);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(3);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;
    
  BEGIN
     --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'RCIP0001'
                              ,pr_action => NULL);
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar as informações gerais do calculo
    OPEN cr_info_geral_calculo(pr_idcalculo_reciproci);
    FETCH cr_info_geral_calculo INTO rw_info_geral_calculo;
     
    IF cr_info_geral_calculo%FOUND THEN
      vr_qtmes_retorno_reciproci := rw_info_geral_calculo.qtdmes_retorno_reciproci;
      vr_flgreversao_tarifa := rw_info_geral_calculo.flgreversao_tarifa;
      vr_flgdebito_reversao := rw_info_geral_calculo.flgdebito_reversao;
    ELSE
      vr_qtmes_retorno_reciproci := 3;
      vr_flgreversao_tarifa := 0;
      vr_flgdebito_reversao := 0;
    END IF;    
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vr_qtmes_retorno_reciproci', pr_tag_cont => vr_qtmes_retorno_reciproci, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vr_flgreversao_tarifa',      pr_tag_cont => vr_flgreversao_tarifa,      pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vr_flgdebito_reversao',      pr_tag_cont => vr_flgdebito_reversao,      pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'Calculo',                    pr_tag_cont => NULL,                       pr_des_erro => vr_dscritic);
    
    vr_contador := 0;
    
    -- Se tiver id do calculo de reciprocidade
    IF pr_idcalculo_reciproci > 0 THEN
      
      FOR rw_calculo_indicador IN cr_calculo_indicador (pr_idcalculo_reciproci) LOOP
        
        vr_vlcontrata := RCIP0001.fn_format_valor_indicador(rw_calculo_indicador.idindicador,rw_calculo_indicador.vlcontrata);
        
        -- Insere as tags dos campos da PLTABLE de aplicações
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Calculo', pr_posicao => 0     , pr_tag_nova => 'Reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'idindicador', pr_tag_cont => rw_calculo_indicador.idindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'nmindicador', pr_tag_cont => rw_calculo_indicador.nmindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'tpindicador', pr_tag_cont => rw_calculo_indicador.tpindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'vlcontrata',  pr_tag_cont => vr_vlcontrata                   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'perdesconto', pr_tag_cont => to_char(nvl(rw_calculo_indicador.perdesconto,0),'fm990d00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'pertolera',   pr_tag_cont => to_char(nvl(rw_calculo_indicador.pertolera,0)  ,'fm990d00'), pr_des_erro => vr_dscritic); 
        
        FOR vr_contador_ocorrencia IN 1..3 LOOP
          vr_ocorrencia := RCIP0001.fn_format_valor_indicador(rw_calculo_indicador.idindicador,
                           RCIP0001.fn_valor_realizado_indicador(pr_cdcooper =>    pr_cdcooper
                                                       ,pr_nrdconta =>    pr_nrdconta
                                                       ,pr_idindicador => rw_calculo_indicador.idindicador
                                                       ,pr_numocorre =>   vr_contador_ocorrencia));
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'ocorrencia_' || vr_contador_ocorrencia,   pr_tag_cont => vr_ocorrencia, pr_des_erro => vr_dscritic); 
        END LOOP;
        
        vr_contador := vr_contador + 1;
        
      END LOOP;
      
    ELSE
      FOR rw_indicadores_disponiveis IN cr_indicadores_disponiveis (pr_idparame_reciproci) LOOP
        
        vr_vlcontrata := RCIP0001.fn_format_valor_indicador(rw_indicadores_disponiveis.idindicador, 0);
        
        -- Insere as tags dos campos da PLTABLE de indicadores
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Calculo', pr_posicao => 0     , pr_tag_nova => 'Reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'idindicador', pr_tag_cont => rw_indicadores_disponiveis.idindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'nmindicador', pr_tag_cont => rw_indicadores_disponiveis.nmindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'tpindicador', pr_tag_cont => rw_indicadores_disponiveis.tpindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'vlcontrata',  pr_tag_cont => vr_vlcontrata                         , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'perdesconto', pr_tag_cont => to_char(0,'fm990d00')                 , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'pertolera',   pr_tag_cont => to_char(nvl(rw_indicadores_disponiveis.pertolera,0) ,'fm990d00'), pr_des_erro => vr_dscritic); 
        
        FOR vr_contador_ocorrencia IN 1..3 LOOP
          vr_ocorrencia := RCIP0001.fn_format_valor_indicador(rw_indicadores_disponiveis.idindicador,
                           RCIP0001.fn_valor_realizado_indicador(pr_cdcooper =>    pr_cdcooper
                                                       ,pr_nrdconta =>    pr_nrdconta
                                                       ,pr_idindicador => rw_indicadores_disponiveis.idindicador
                                                       ,pr_numocorre =>   vr_contador_ocorrencia));
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'ocorrencia_' || vr_contador_ocorrencia,   pr_tag_cont => vr_ocorrencia, pr_des_erro => vr_dscritic); 
        END LOOP;
        
        vr_contador := vr_contador + 1;
        
      END LOOP;
    END IF;
   
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'QtdRegist', pr_tag_cont => vr_contador,  pr_des_erro => vr_dscritic);

    --Retorno
    pr_des_erro:= 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro tratado
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_dscritic := 'RCIP0001.pc_busca_conf_reciprocidade --> Erro não tratado: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_sim_reciprocidade;
  
  /* Buscar configuracao de valor máximo e minimo */
  PROCEDURE pc_busca_conf_min_max(pr_ls_vlcontrata            IN VARCHAR2
                                 ,pr_idcalculo                IN tbrecip_calculo.idcalculo_reciproci%TYPE
                                 ,pr_idparame_reciproci       IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE 
                                 ,pr_xmllog                   IN VARCHAR2                --XML com informações de LOG
                                 ,pr_cdcritic                 OUT PLS_INTEGER            --Código da crítica
                                 ,pr_dscritic                 OUT VARCHAR2               --Descrição da crítica
                                 ,pr_retxml                   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                 ,pr_nmdcampo                 OUT VARCHAR2               --Nome do Campo
                                 ,pr_des_erro                 OUT VARCHAR2) IS           --Saida OK/NOK
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_conf_min_max                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Lombardi
  --  Data     : Março/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Buscar configuracao de valor máximo e minimo.
  ---------------------------------------------------------------------------------------------------------------
    
    -- Busca dos valores previstos
    CURSOR cr_busca_conf_min_max_cf (pr_idindicador IN tbrecip_parame_indica_calculo.idindicador%TYPE) IS
      SELECT ipr.vlminimo
            ,ipr.vlmaximo
        FROM tbrecip_parame_indica_calculo ipr
       WHERE ipr.idparame_reciproci = pr_idparame_reciproci
         AND ipr.idindicador        = pr_idindicador;
    rw_busca_conf_min_max cr_busca_conf_min_max_cf%ROWTYPE;

    -- Busca dos valores do histórico
    CURSOR cr_busca_conf_min_max_hs (pr_idindicador IN tbrecip_indica_calculo.idindicador%TYPE) IS
      SELECT idc.vlminimo
            ,idc.vlmaximo
        FROM tbrecip_indica_calculo idc
       WHERE idc.idcalculo_reciproci = pr_idcalculo
         AND idc.idindicador         = pr_idindicador;
    
    -- Variáveis genéricas
    vr_vlminimo            VARCHAR2(100);
    vr_vlmaximo            VARCHAR2(100);
    vr_vlpermitido         VARCHAR2(1000);
    vr_conf_geral          GENE0002.typ_split;
    vr_conf_dados          GENE0002.typ_split;
    vr_flg_uso             BOOLEAN;
    vr_hasfound            BOOLEAN;
    vr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(3);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;
    
  BEGIN
     --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'RCIP0001'
                              ,pr_action => NULL);
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    vr_vlpermitido := 'S';
    
    vr_conf_geral := gene0002.fn_quebra_string(pr_ls_vlcontrata,';');
    
    FOR ind_registro IN vr_conf_geral.FIRST..vr_conf_geral.LAST LOOP
        
      vr_conf_dados := gene0002.fn_quebra_string(vr_conf_geral(ind_registro),',');
      
      -- Buscar o valor da configuração  
      OPEN cr_busca_conf_min_max_cf(vr_conf_dados(1));
      FETCH cr_busca_conf_min_max_cf INTO rw_busca_conf_min_max;
         
      IF cr_busca_conf_min_max_cf%FOUND THEN
        vr_vlminimo := rw_busca_conf_min_max.vlminimo;
        vr_vlmaximo := rw_busca_conf_min_max.vlmaximo;
      ELSE
        -- Buscar o valor do historico
        rw_busca_conf_min_max := NULL;
        OPEN cr_busca_conf_min_max_hs(vr_conf_dados(1));
        FETCH cr_busca_conf_min_max_hs INTO rw_busca_conf_min_max;
        CLOSE cr_busca_conf_min_max_hs;                
        vr_vlminimo := nvl(rw_busca_conf_min_max.vlminimo,0);
        vr_vlmaximo := nvl(rw_busca_conf_min_max.vlmaximo,0);
      END IF;
      CLOSE cr_busca_conf_min_max_cf;
      
      IF gene0002.fn_char_para_number(vr_vlminimo) > gene0002.fn_char_para_number(vr_conf_dados(3)) OR
         gene0002.fn_char_para_number(vr_vlmaximo) < gene0002.fn_char_para_number(vr_conf_dados(3)) THEN
        vr_vlpermitido :='Indicador ' || vr_conf_dados(1) || ': Valor Contratado inválido! Favor informar um valor entre ' || rcip0001.fn_format_valor_indicador(vr_conf_dados(1),vr_vlminimo) || ' a ' || rcip0001.fn_format_valor_indicador(vr_conf_dados(1),vr_vlmaximo) || '!';
      END IF;
    END LOOP;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados>' || vr_vlpermitido || '</Dados>');
    
    --Retorno
    pr_des_erro:= 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro tratado
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_dscritic := 'RCIP0001.pc_busca_conf_min_max --> Erro não tratado: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_conf_min_max;
  
  /* Calcular o valor de desconto conforme previstoXrealizado. */
  PROCEDURE pc_pct_desconto_indicador_web(pr_idcalculo   IN tbrecip_calculo.idcalculo_reciproci%TYPE       -- Id do calculo (se já existir)
                                         ,pr_idparame    IN tbrecip_parame_calculo.idparame_reciproci%TYPE -- Id da parametrização envolvida
                                         ,pr_idindicador IN tbrecip_indicador.idindicador%TYPE             -- ID Indicador
                                         ,pr_vlrbase     IN NUMBER                                         -- Valor base
                                         ,pr_xmllog      IN VARCHAR2                --XML com informações de LOG
                                         ,pr_cdcritic    OUT PLS_INTEGER            --Código da crítica
                                         ,pr_dscritic    OUT VARCHAR2               --Descrição da crítica
                                         ,pr_retxml      IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                         ,pr_nmdcampo    OUT VARCHAR2               --Nome do Campo
                                         ,pr_des_erro    OUT VARCHAR2) IS           --Saida OK/NOK
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_percentu_desconto_indicador                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - SUPERO
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Esta função será responsável por calcular o percentual de desconto do indicador
  --             repassado conforme valores previsto/realizado e parametrização do cálculo de
  --             reciprocidade vinculado ao convênio.

  ---------------------------------------------------------------------------------------------------------------
    
    -- Variaveis Genericas
    vr_pct_desconto_indicador NUMBER;
  
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(3);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;
    
  BEGIN
    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'RCIP0001'
                              ,pr_action => NULL);
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    vr_pct_desconto_indicador := RCIP0001.fn_percentu_desconto_indicador(pr_idparame    => pr_idparame
                                                                        ,pr_idcalculo   => pr_idcalculo
                                                                        ,pr_idindicador => pr_idindicador
                                                                        ,pr_vlrbase     => pr_vlrbase);
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados>' || to_char(nvl(vr_pct_desconto_indicador,0),'fm990d00') || '</Dados>');
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro tratado
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_dscritic := 'RCIP0001.pc_busca_conf_reciprocidade --> Erro não tratado: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_pct_desconto_indicador_web;  
  
  /* Salva configuracao de calculo de reprocidade */
  PROCEDURE pc_confirma_simc_reciprocidade(pr_ls_vlcontrata            IN VARCHAR2
                                          ,pr_idcalculo_reciproci      IN tbrecip_apuracao.idconfig_recipro%TYPE
                                          ,pr_idparame_reciproci       IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE 
                                          ,pr_qtdmes_retorno_reciproci IN VARCHAR2
                                          ,pr_flgreversao_tarifa       IN VARCHAR2
                                          ,pr_flgdebito_reversao       IN VARCHAR2
                                          ,pr_modo                     IN VARCHAR2
                                          ,pr_xmllog                   IN VARCHAR2                --XML com informações de LOG
                                          ,pr_cdcritic                 OUT PLS_INTEGER            --Código da crítica
                                          ,pr_dscritic                 OUT VARCHAR2               --Descrição da crítica
                                          ,pr_retxml                   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                          ,pr_nmdcampo                 OUT VARCHAR2               --Nome do Campo
                                          ,pr_des_erro                 OUT VARCHAR2) IS           --Saida OK/NOK
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_confirma_conf_reciprocidade                Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Lombardi
  --  Data     : Março/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Gravar configuração para um cálculo de reciprocidade 
  --             futuro ou alterar um cálculo pré-existente.
  ---------------------------------------------------------------------------------------------------------------
    
    CURSOR cr_apuracao_vinculada(pr_idcalculo_reciproci IN tbrecip_apuracao.idconfig_recipro%TYPE) IS
      SELECT 1
        FROM tbrecip_apuracao
       WHERE tpreciproci        = 1 /* Somente aqueles com Previsão / Realização */
         AND idconfig_recipro = pr_idcalculo_reciproci;

        
    rw_apuracao_vinculada cr_apuracao_vinculada%ROWTYPE;
    
    CURSOR cr_existe_indicador (pr_idcalculo_reciproci IN tbrecip_indica_calculo.idcalculo_reciproci%TYPE
                               ,pr_idindicador         IN tbrecip_indica_calculo.idindicador%TYPE) IS
      SELECT vlcontrata
            ,perdesconto
            ,pertolera
            ,vlminimo
            ,vlmaximo
            ,perscore
        FROM tbrecip_indica_calculo
       WHERE idcalculo_reciproci = pr_idcalculo_reciproci
         AND idindicador = pr_idindicador;

    rw_existe_indicador cr_existe_indicador%ROWTYPE;
    
    CURSOR cr_existe_calculo (pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE) IS
      SELECT qtdmes_retorno_reciproci
            ,flgreversao_tarifa
            ,flgdebito_reversao
        FROM tbrecip_calculo
       WHERE idcalculo_reciproci = pr_idcalculo_reciproci;
    
    rw_existe_calculo cr_existe_calculo%ROWTYPE;
    
    -- Buscar a parametrização e os dados do indicador
    CURSOR cr_parame(pr_idindicador tbrecip_parame_indica_calculo.idindicador%TYPE) IS
      SELECT ipr.vlminimo
            ,ipr.vlmaximo
            ,ipr.perscore
        FROM tbrecip_parame_indica_calculo ipr
       WHERE ipr.idparame_reciproci = pr_idparame_reciproci
         AND ipr.idindicador        = pr_idindicador;
    rw_parame cr_parame%ROWTYPE;
    
    -- Variáveis genéricas
    vr_vlminimo            VARCHAR2(100);
    vr_vlmaximo            VARCHAR2(100);
    vr_vlpermitido         BOOLEAN;
    vr_conf_geral          GENE0002.typ_split;
    vr_conf_dados          GENE0002.typ_split;
    vr_flg_uso             BOOLEAN;
    vr_hasfound            BOOLEAN;
    vr_nrdrowid            ROWID;
    vr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE;
    vr_dstransa            VARCHAR2(1000);
    vr_old_qtdmes_retorno_reciproc tbrecip_calculo.qtdmes_retorno_reciproci%TYPE;
    vr_old_flgreversao_tarifa      tbrecip_calculo.flgreversao_tarifa%TYPE;
    vr_old_flgdebito_reversao      tbrecip_calculo.flgdebito_reversao%TYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(3);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;
    
  BEGIN
     --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'RCIP0001'
                              ,pr_action => NULL);
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    vr_idcalculo_reciproci := pr_idcalculo_reciproci;
    vr_flg_uso := FALSE;

    -- Verificar se existe alguma apuração vinculada
    IF pr_modo = 'A' AND pr_idcalculo_reciproci > 0 THEN
        OPEN cr_apuracao_vinculada(pr_idcalculo_reciproci);
        FETCH cr_apuracao_vinculada INTO rw_apuracao_vinculada;
        IF cr_apuracao_vinculada%FOUND THEN
            vr_flg_uso := TRUE;
        END IF;

        CLOSE cr_apuracao_vinculada;
    END IF;

      
    IF (pr_modo = 'I' AND pr_idcalculo_reciproci > 0) OR 
       (pr_modo = 'A' AND pr_idcalculo_reciproci > 0 AND vr_flg_uso = FALSE) THEN
      
      -- Busca dados anteriores
      OPEN cr_existe_calculo(pr_idcalculo_reciproci);
      FETCH cr_existe_calculo INTO rw_existe_calculo;
      vr_old_qtdmes_retorno_reciproc := rw_existe_calculo.qtdmes_retorno_reciproci;
      vr_old_flgreversao_tarifa := rw_existe_calculo.flgreversao_tarifa;
      vr_old_flgdebito_reversao := rw_existe_calculo.flgdebito_reversao;
      CLOSE cr_existe_calculo;
      vr_dstransa := 'SIMCRP - Atualizar configuracao para calculo de reciprocidade.';
      
      BEGIN
        UPDATE tbrecip_calculo
           SET qtdmes_retorno_reciproci = pr_qtdmes_retorno_reciproci
              ,flgreversao_tarifa = pr_flgreversao_tarifa
              ,flgdebito_reversao = pr_flgdebito_reversao
         WHERE idcalculo_reciproci = pr_idcalculo_reciproci;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar Configuracao para calculo ' ||
                         'de Reciprocidade. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Gerar informacoes do log
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'SIMCRP'
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
                          
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Retorno de Reciprocidade'
                               ,pr_dsdadant => vr_old_qtdmes_retorno_reciproc
                               ,pr_dsdadatu => pr_qtdmes_retorno_reciproci);
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Reversao da tarifa'
                               ,pr_dsdadant => vr_old_flgreversao_tarifa
                               ,pr_dsdadatu => pr_flgreversao_tarifa);
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Debito de reajuste Reciprocidade'
                               ,pr_dsdadant => vr_old_flgdebito_reversao
                               ,pr_dsdadatu => pr_flgdebito_reversao);
                               
      
      vr_conf_geral := gene0002.fn_quebra_string(pr_ls_vlcontrata,';');
    
      FOR ind_registro IN vr_conf_geral.FIRST..vr_conf_geral.LAST LOOP
            
        vr_conf_dados := gene0002.fn_quebra_string(vr_conf_geral(ind_registro),',');
        
        --Busca a parametrizao da CONFCRP
        rw_parame := NULL;
        OPEN cr_parame(vr_conf_dados(2));
        FETCH cr_parame
         INTO rw_parame;
        CLOSE cr_parame; 
          
        --Verifica se já existe na tabela:
        OPEN cr_existe_indicador(pr_idcalculo_reciproci,vr_conf_dados(2));
        FETCH cr_existe_indicador INTO rw_existe_indicador;
        vr_hasfound := cr_existe_indicador%FOUND;
        CLOSE cr_existe_indicador;
        IF vr_hasfound THEN
          IF vr_conf_dados(1) = 1 THEN -- Contratado
            vr_dstransa := 'SIMCRP - Atualizar indicador para calculo de reciprocidade.';
            
            BEGIN 
              UPDATE tbrecip_indica_calculo
                 SET vlcontrata  = gene0002.fn_char_para_number(vr_conf_dados(4))
                    ,perdesconto = gene0002.fn_char_para_number(vr_conf_dados(5))
                    ,pertolera   = gene0002.fn_char_para_number(vr_conf_dados(6))
                    ,vlminimo    = nvl(rw_parame.vlminimo,vlminimo)
                    ,vlmaximo    = nvl(rw_parame.vlmaximo,vlmaximo)
                    ,perscore    = nvl(rw_parame.perscore,perscore)
               WHERE idcalculo_reciproci = pr_idcalculo_reciproci
                 AND idindicador = vr_conf_dados(2);

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar indicador para calculo ' ||
                               'de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            
            -- Gerar informacoes do log
            GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1 --> TRUE
                                ,pr_hrtransa => GENE0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'SIMCRP'
                                ,pr_nrdconta => 0
                                ,pr_nrdrowid => vr_nrdrowid);
                                
            -- Gerar informacoes do item
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Contratado'
                                     ,pr_dsdadant => rw_existe_indicador.vlcontrata
                                     ,pr_dsdadatu => gene0002.fn_char_para_number(vr_conf_dados(4)));
            -- Gerar informacoes do item
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => '% Desconto'
                                     ,pr_dsdadant => rw_existe_indicador.perdesconto
                                     ,pr_dsdadatu => gene0002.fn_char_para_number(vr_conf_dados(5)));
            -- Gerar informacoes do item
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => '% Tolerancia'
                                     ,pr_dsdadant => rw_existe_indicador.pertolera
                                     ,pr_dsdadatu => gene0002.fn_char_para_number(vr_conf_dados(6)));
          ELSE
            vr_dstransa := 'SIMCRP - Deletar indicador para calculo de reciprocidade.';
            
            BEGIN 
              DELETE FROM tbrecip_indica_calculo
               WHERE idcalculo_reciproci = pr_idcalculo_reciproci
                 AND idindicador = vr_conf_dados(2);

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar indicador para calculo ' ||
                               'de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            
            -- Gerar informacoes do log
            GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1 --> TRUE
                                ,pr_hrtransa => GENE0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'SIMCRP'
                                ,pr_nrdconta => 0
                                ,pr_nrdrowid => vr_nrdrowid);
          END IF;

        ELSE
          vr_dstransa := 'SIMCRP - Inserir indicador para calculo de reciprocidade.';
          IF vr_conf_dados(1) = 1 THEN -- Contratado
            BEGIN
              INSERT INTO tbrecip_indica_calculo
                   (idcalculo_reciproci,idindicador,vlcontrata,perdesconto,pertolera,vlminimo,vlmaximo,perscore)
              VALUES (pr_idcalculo_reciproci
                     ,vr_conf_dados(2)
                     ,gene0002.fn_char_para_number(vr_conf_dados(4))
                     ,gene0002.fn_char_para_number(vr_conf_dados(5))
                     ,gene0002.fn_char_para_number(vr_conf_dados(6))
                     ,rw_parame.vlminimo
                     ,rw_parame.vlmaximo
                     ,rw_parame.perscore);

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir indicador para calculo ' ||
                               'de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            
            -- Gerar informacoes do log
            GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1 --> TRUE
                                ,pr_hrtransa => GENE0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'SIMCRP'
                                ,pr_nrdconta => 0
                                ,pr_nrdrowid => vr_nrdrowid);
                                  
            -- Gerar informacoes do item
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Contratado'
                                     ,pr_dsdadant => 0
                                     ,pr_dsdadatu => vr_conf_dados(4));
            -- Gerar informacoes do item
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => '% Desconto'
                                     ,pr_dsdadant => 0
                                     ,pr_dsdadatu => vr_conf_dados(5));
            -- Gerar informacoes do item
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => '% Tolerancia'
                                     ,pr_dsdadant => 0
                                     ,pr_dsdadatu => vr_conf_dados(6));
          END IF;
        END IF;

      END LOOP;

    ELSE
        
      vr_dstransa := 'SIMCRP - Inserir configuracao para calculo de reciprocidade.';
            
      BEGIN
        INSERT INTO tbrecip_calculo 
                    (qtdmes_retorno_reciproci,flgreversao_tarifa,flgdebito_reversao)
             VALUES (pr_qtdmes_retorno_reciproci,pr_flgreversao_tarifa,pr_flgdebito_reversao)
          RETURNING idcalculo_reciproci  INTO vr_idcalculo_reciproci;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir configuracao para calculo ' ||
                         'de Reciprocidade. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Gerar informacoes do log
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'SIMCRP'
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
                    
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Retorno de Reciprocidade'
                               ,pr_dsdadant => 0
                               ,pr_dsdadatu => pr_qtdmes_retorno_reciproci);
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Reversao da tarifa'
                               ,pr_dsdadant => 0
                               ,pr_dsdadatu => pr_flgreversao_tarifa);
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Debito de reajuste Reciprocidade'
                               ,pr_dsdadant => 0
                               ,pr_dsdadatu => pr_flgdebito_reversao);
        
      vr_conf_geral := gene0002.fn_quebra_string(pr_ls_vlcontrata,';');
    
      FOR ind_registro IN vr_conf_geral.FIRST..vr_conf_geral.LAST LOOP
            
        vr_conf_dados := gene0002.fn_quebra_string(vr_conf_geral(ind_registro),',');
        IF vr_conf_dados(1) = 1 THEN --Contratado
          
          vr_dstransa := 'SIMCRP - Inserir indicador para calculo de reciprocidade.';
          
          --Busca a parametrizao da CONFCRP
          rw_parame := NULL;
          OPEN cr_parame(vr_conf_dados(2));
          FETCH cr_parame
           INTO rw_parame;
          -- Se não existir
          IF cr_parame%NOTFOUND THEN
            CLOSE cr_parame;
            -- Buscaremos o valor do histórico do cálculo anterior
            rw_existe_indicador := NULL;
            OPEN cr_existe_indicador (pr_idcalculo_reciproci => pr_idcalculo_reciproci
                                     ,pr_idindicador         => vr_conf_dados(2));
            FETCH cr_existe_indicador
             INTO rw_existe_indicador;
            CLOSE cr_existe_indicador;
            -- Copiar os dados para o rowtype da cr_parame para reaproveitamento de código
            rw_parame.vlminimo := rw_existe_indicador.vlminimo;
            rw_parame.vlmaximo := rw_existe_indicador.vlmaximo;
            rw_parame.perscore := rw_existe_indicador.perscore;
          ELSE
            CLOSE cr_parame;
          END IF;
          
          BEGIN
            INSERT INTO tbrecip_indica_calculo
                 (idcalculo_reciproci,idindicador,vlcontrata,perdesconto,pertolera,vlminimo,vlmaximo,perscore)
            VALUES (vr_idcalculo_reciproci
                   ,vr_conf_dados(2)
                   ,gene0002.fn_char_para_number(vr_conf_dados(4))
                   ,gene0002.fn_char_para_number(vr_conf_dados(5))
                   ,gene0002.fn_char_para_number(vr_conf_dados(6))
                   ,rw_parame.vlminimo
                   ,rw_parame.vlmaximo
                   ,rw_parame.perscore);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir indicador para calculo ' ||
                             'de Reciprocidade. ' || SQLERRM;
              RAISE vr_exc_erro;

          END;

          -- Gerar informacoes do log
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => ' '
                              ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'SIMCRP'
                              ,pr_nrdconta => 0
                              ,pr_nrdrowid => vr_nrdrowid);
                                
          -- Gerar informacoes do item
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Contratado'
                                   ,pr_dsdadant => 0
                                   ,pr_dsdadatu => vr_conf_dados(4));
          -- Gerar informacoes do item
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => '% Desconto'
                                   ,pr_dsdadant => 0
                                   ,pr_dsdadatu => vr_conf_dados(5));
          -- Gerar informacoes do item
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => '% Tolerancia'
                                   ,pr_dsdadant => 0
                                   ,pr_dsdadatu => vr_conf_dados(6));
        END IF;

      END LOOP;

    END IF;

    --Retorno
    pr_des_erro:= 'OK';

    -- Efetua commit
    COMMIT;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'idcalculo_reciproci', pr_tag_cont => vr_idcalculo_reciproci, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dsmensagem',          pr_tag_cont => pr_des_erro, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro tratado
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_dscritic := 'RCIP0001.pc_busca_conf_reciprocidade --> Erro não tratado: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_confirma_simc_reciprocidade;
	
	-- PRJ431
	PROCEDURE pc_calcula_reciprocidade(pr_cdcooper             IN  tbrecip_param_workflow.cdcooper%TYPE -- Identificador da cooperativa
		                                ,pr_ls_nrconvenio        IN  VARCHAR2                             -- Lista com os número dos convênios
		                                ,pr_qtboletos_liquidados IN  INTEGER                               -- Quantidade de boletos liquidados
																		,pr_vlliquidados         IN  VARCHAR2                               -- Volume (R$) de boletos liquidados
																		,pr_idfloating           IN  INTEGER                               -- Quantidade de dias de floating
																		,pr_idvinculacao         IN  INTEGER                               -- Identificador do grau de vinculação do cooperado
																		,pr_vlaplicacoes         IN  VARCHAR2                               -- Valor a ser aplicado pelo cooperado
																		,pr_vldeposito           IN  VARCHAR2                               -- Valor a ser depositado pelo cooperado
																		,pr_idcoo                IN  INTEGER                               -- Cooperado emite e expede
																		,pr_idcee                IN  INTEGER                               -- Cooperativa emite e expede
																		,pr_xmllog               IN  VARCHAR2                             -- XML com informações de LOG
																		,pr_cdcritic             OUT PLS_INTEGER                          -- Código da crítica
																		,pr_dscritic             OUT VARCHAR2                             -- Descrição da crítica
																		,pr_retxml               IN OUT NOCOPY xmltype                    -- Arquivo de retorno do XML
																		,pr_nmdcampo             OUT VARCHAR2                             -- Nome do campo com erro
																		,pr_des_erro             OUT VARCHAR2                             -- Erros do processo
																		) IS
    /* .............................................................................

    Programa: pc_calcula_reciprocidade
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 23/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para calcular a reciprocidade.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Cursor para buscar os indicadores para o cálculo
		CURSOR cr_indicador(pr_cdcooper crapcco.cdcooper%TYPE
		                   ,pr_nrconven crapcco.nrconven%TYPE
		                    ) IS
      SELECT tpic.idindicador
						,tpic.vlminimo
						,tpic.vlmaximo
						,(tpic.vlpercentual_peso / 100) vlpercentual_peso
						,(tpic.vlpercentual_desconto / 100) vlpercentual_desconto
						,(tpc.vldesconto_maximo_cee / 100) vldesconto_maximo_cee
						,(tpc.vldesconto_maximo_coo / 100) vldesconto_maximo_coo
						,tpc.idparame_reciproci
				FROM crapcco
						,tbrecip_parame_indica_calculo tpic
						,tbrecip_parame_calculo tpc
				WHERE crapcco.idprmrec        = tpic.idparame_reciproci
				  AND tpic.idparame_reciproci = tpc.idparame_reciproci
					AND crapcco.cdcooper        = pr_cdcooper
					AND crapcco.nrconven        = pr_nrconven
		 ORDER BY tpic.idindicador;
		
		rw_indicador cr_indicador%ROWTYPE;
		
		CURSOR cr_vinculacao(pr_idvinculacao       tbrecip_vinculacao_parame.idvinculacao_reciproci%TYPE
		                    ,pr_idparame_reciproci tbrecip_vinculacao_parame.idparame_reciproci%TYPE
		                    ) IS
      SELECT tvp.idvinculacao_reciproci
						,(tvp.vlpercentual_desconto / 100) vlpercentual_desconto
						,(tvp.vlpercentual_peso / 100) vlpercentual_peso
				FROM tbrecip_vinculacao_parame tvp
			 WHERE tvp.flgativo               = 1
			   AND tvp.idvinculacao_reciproci = pr_idvinculacao
				 AND tvp.idparame_reciproci     = pr_idparame_reciproci;
		
		rw_vinculacao cr_vinculacao%ROWTYPE;
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
		vr_conf_geral   GENE0002.typ_split;
		
		-- Variáveis utilizadas no cálculo
		vr_qtfloating         NUMBER;
		--
		vr_resultado_ind02    NUMBER;
		vr_resultado_ind03    NUMBER;
		vr_resultado_ind21    NUMBER;
		vr_resultado_ind22    NUMBER;
		vr_resultado_ind23    NUMBER;
		--
		vr_resultado_indvi    NUMBER;
		vr_desconto_indvi_cee NUMBER;
		vr_desconto_indvi_coo NUMBER;
		--
		vr_desconto_ind02_cee NUMBER;
		vr_desconto_ind03_cee NUMBER;
		vr_desconto_ind21_cee NUMBER;
		vr_desconto_ind22_cee NUMBER;
		vr_desconto_ind23_cee NUMBER;
		vr_desconto_total_cee NUMBER;
		--
		vr_desconto_ind02_coo NUMBER;
		vr_desconto_ind03_coo NUMBER;
		vr_desconto_ind21_coo NUMBER;
		vr_desconto_ind22_coo NUMBER;
		vr_desconto_ind23_coo NUMBER;
		vr_desconto_total_coo NUMBER;
		
		--
		vr_vlaplicacoes NUMBER;
		vr_vlliquidados NUMBER;
    vr_vldeposito   NUMBER;
		
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		vr_vlaplicacoes := to_number(pr_vlaplicacoes);
		vr_vlliquidados :=  to_number(pr_vlliquidados);
		vr_vldeposito :=  to_number(pr_vldeposito);		
		
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_SIMCRP'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		-- Irá pegar apenas a primeira ocorrência, pois por definição, 
		-- não poderão existir parâmetros diferentes para os convênios da mesma cooperativa.
		vr_conf_geral := gene0002.fn_quebra_string(pr_ls_nrconvenio,',');
		--
		OPEN cr_indicador(pr_cdcooper
										 ,vr_conf_geral(1)
											);
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		LOOP
			--
			FETCH cr_indicador INTO rw_indicador;
			EXIT WHEN cr_indicador%NOTFOUND;
			-- Processa cada um dos indicadores retornados
			CASE rw_indicador.idindicador
				-- Valor de boletos compensados
				WHEN 2 THEN
					--
					IF vr_vlliquidados < rw_indicador.vlminimo THEN
						--
						vr_resultado_ind02 := 0;
						--
					ELSIF vr_vlliquidados > rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind02 := (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					ELSIF vr_vlliquidados BETWEEN rw_indicador.vlminimo AND rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind02 := ((vr_vlliquidados - rw_indicador.vlminimo) / (rw_indicador.vlmaximo - rw_indicador.vlminimo)) * (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					END IF;
					--
					IF pr_idcee = 1 THEN
						--
						vr_desconto_ind02_cee := vr_resultado_ind02;
						--
					END IF;
					--
					IF pr_idcoo = 1 THEN
						--
						vr_desconto_ind02_coo := vr_resultado_ind02;
						--
					END IF;
				-- Quantidade de pagamentos
				WHEN 3 THEN
					--
					IF pr_qtboletos_liquidados < rw_indicador.vlminimo THEN
						--
						vr_resultado_ind03 := 0;
						--
					ELSIF pr_qtboletos_liquidados > rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind03 := (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					ELSIF pr_qtboletos_liquidados BETWEEN rw_indicador.vlminimo AND rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind03 := ((pr_qtboletos_liquidados - rw_indicador.vlminimo) / (rw_indicador.vlmaximo - rw_indicador.vlminimo)) * (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					END IF;
					--
					IF pr_idcee = 1 THEN
						--
						vr_desconto_ind03_cee := vr_resultado_ind03;
						--
					END IF;
					--
					IF pr_idcoo = 1 THEN
						--
						vr_desconto_ind03_coo := vr_resultado_ind03;
						--
					END IF;
				-- Quantidade de Floating
				WHEN 21 THEN
					-- Busca a quantidade de dias
					BEGIN
						--
						SELECT tdc.dscodigo
						  INTO vr_qtfloating
						  FROM tbcobran_dominio_campo tdc
						 WHERE tdc.nmdominio = 'TPFLOATING_RECIPR'
						   AND tdc.cddominio = pr_idfloating;
						--
					EXCEPTION
						WHEN no_data_found THEN
							vr_dscritic := 'Floating ' || pr_idfloating || ' não encontrado!';
							RAISE vr_exc_erro;
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao buscar o Floating: ' || SQLERRM;
							RAISE vr_exc_erro;
					END;
					--
					IF vr_qtfloating < rw_indicador.vlminimo THEN
						--
						vr_resultado_ind21 := 0;
						--
					ELSIF vr_qtfloating > rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind21 := (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					ELSIF vr_qtfloating BETWEEN rw_indicador.vlminimo AND rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind21 := ((vr_qtfloating - rw_indicador.vlminimo) / (rw_indicador.vlmaximo - rw_indicador.vlminimo)) * (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					END IF;
					--
					IF pr_idcee = 1 THEN
						--
						vr_desconto_ind21_cee := vr_resultado_ind21;
						--
					END IF;
					--
					IF pr_idcoo = 1 THEN
						--
						vr_desconto_ind21_coo := vr_resultado_ind21;
						--
					END IF;
				-- Valor de Investimento (Quantidade de Aplicação)
				WHEN 22 THEN
					--
					IF vr_vlaplicacoes < rw_indicador.vlminimo THEN
						--
						vr_resultado_ind22 := 0;
						--
					ELSIF vr_vlaplicacoes > rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind22 := (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					ELSIF vr_vlaplicacoes BETWEEN rw_indicador.vlminimo AND rw_indicador.vlmaximo THEN
						--
						vr_resultado_ind22 := ((vr_vlaplicacoes - rw_indicador.vlminimo) / (rw_indicador.vlmaximo - rw_indicador.vlminimo)) * (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
						--
					END IF;
					--
					IF pr_idcee = 1 THEN
						--
						vr_desconto_ind22_cee := vr_resultado_ind22;
						--
					END IF;
					--
					IF pr_idcoo = 1 THEN
						--
						vr_desconto_ind22_coo := vr_resultado_ind22;
						--
					END IF;
				-- Valor de Depósito à Vista (Quantidade de Depósito à Vista)
                                WHEN 23 THEN
						--
						IF vr_vldeposito < rw_indicador.vlminimo THEN
							--
							vr_resultado_ind23 := 0;
							--
						ELSIF vr_vldeposito > rw_indicador.vlmaximo THEN
							--
							vr_resultado_ind23 := (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
							--
						ELSIF vr_vldeposito BETWEEN rw_indicador.vlminimo AND rw_indicador.vlmaximo THEN
							--
							vr_resultado_ind23 := ((vr_vldeposito - rw_indicador.vlminimo) / (rw_indicador.vlmaximo - rw_indicador.vlminimo)) * (rw_indicador.vlpercentual_peso * rw_indicador.vlpercentual_desconto);
							--
						END IF;
						--
						IF pr_idcee = 1 THEN
							--
							vr_desconto_ind23_cee := vr_resultado_ind23;
							--
						END IF;
						--
						IF pr_idcoo = 1 THEN
							--
							vr_desconto_ind23_coo := vr_resultado_ind23;
							--
						END IF;
						--
				-- Caso o indicador não tenha tratamento
				ELSE
					--
					NULL; -- Verificar
					--
			END CASE;
			--
		END LOOP;
		-- Verifica o grau de vinculação
		OPEN cr_vinculacao(pr_idvinculacao
		                  ,rw_indicador.idparame_reciproci
		                  );
		--
		FETCH cr_vinculacao INTO rw_vinculacao;
		--
		IF cr_vinculacao%FOUND THEN
			--
			vr_resultado_indvi := rw_vinculacao.vlpercentual_desconto * rw_vinculacao.vlpercentual_peso;
			--
		ELSE
			--
			vr_dscritic := 'Vinculação ' || pr_idvinculacao || ' não encontrada!';
			RAISE vr_exc_erro;
			--
		END IF;
		--
		IF pr_idcee = 1 THEN
			--
		  vr_desconto_indvi_cee := vr_resultado_indvi;
			--
		END IF;
		--
		IF pr_idcoo = 1 THEN
			--
			vr_desconto_indvi_coo := vr_resultado_indvi;
			--
		END IF;
		--
		vr_desconto_total_cee := round(nvl(vr_desconto_ind02_cee, 0) + 
																	 nvl(vr_desconto_ind03_cee, 0) +
																	 nvl(vr_desconto_ind21_cee, 0) +
																	 nvl(vr_desconto_ind22_cee, 0) +
																	 nvl(vr_desconto_ind23_cee, 0) +
																	 nvl(vr_desconto_indvi_cee, 0), 2);
		--
		vr_desconto_total_coo := round(nvl(vr_desconto_ind02_coo, 0) + 
																	 nvl(vr_desconto_ind03_coo, 0) +
																	 nvl(vr_desconto_ind21_coo, 0) +
																	 nvl(vr_desconto_ind22_coo, 0) +
																	 nvl(vr_desconto_ind23_coo, 0) +
																	 nvl(vr_desconto_indvi_coo, 0), 2);
		-- Valor do Desconto CEE
		IF vr_desconto_total_cee > rw_indicador.vldesconto_maximo_cee THEN
			--
			vr_desconto_total_cee := rw_indicador.vldesconto_maximo_cee;
			--
		END IF;
		-- Valor do Desconto COO
		IF vr_desconto_total_coo > rw_indicador.vldesconto_maximo_coo THEN
			--
			vr_desconto_total_coo := rw_indicador.vldesconto_maximo_coo;
			--
		END IF;
		--
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
		--
		pc_escreve_xml('<inf>'||
											'<vldesconto_cee>' || vr_desconto_total_cee ||'</vldesconto_cee>' ||
											'<vldesconto_coo>' || vr_desconto_total_coo ||'</vldesconto_coo>' ||
									 '</inf>');
		--
		IF cr_indicador%ROWCOUNT > 0 THEN
			--
			pc_escreve_xml('</dados></root>',TRUE);    
			--
			pr_retxml := XMLType.createXML(vr_des_xml);
			--
		ELSE
			--
			vr_dscritic := 'Nenhuma indicador encontrado para o calculo: ' || pr_cdcooper || ' - ' || vr_conf_geral(1);
      RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_vinculacao;
		--
		CLOSE cr_indicador;
		--
		pr_retxml := XMLType.createXML(vr_des_xml);
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela SIMCRP: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_calcula_reciprocidade;
	-- PRJ431

END TELA_SIMCRP;
/
