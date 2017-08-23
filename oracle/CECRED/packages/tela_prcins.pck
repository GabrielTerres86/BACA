CREATE OR REPLACE PACKAGE CECRED.TELA_PRCINS AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_PRCINS
--    Autor   : Douglas Quisinski
--    Data    : Setembro/2015                   Ultima Atualizacao: 20/06/2017 
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela PRCINS (Processos do INSS)
--
--    Alteracoes: 29/02/2016 - Ajuste para enviar o parâmetro nmdatela pois não está sendo
--					                   possível gerar o relatório. A rotina do oracle está tentando
--								             encontrar o registro crapprg com base no parâmetro cdprogra 
--								             e não o encontra, pois ele é gravado com o nome da tela.
--								            (Adriano - SD 409943)
--    
-- 20/06/2017 - Colocar no padrão erro tratado ou mensagem(alerta) - (Belli Envolti) - Chamado 660286
--    
---------------------------------------------------------------------------------------------------------------

  /* Rotina para buscar as cooperativas */
  PROCEDURE pc_buscar_cooperativas(pr_cddopcao   IN VARCHAR2           -->Codigo Opcao
                                  ,pr_tipopera   IN VARCHAR2           --> Tipo de operacao
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

                                  
  /* Rotina para buscar o resumo de pagamento de beneficio em determinada data */
  PROCEDURE pc_buscar_resumo(pr_cdcopaux   IN INTEGER            --> Código da cooperativa
                            ,pr_dtinicio   IN VARCHAR2           --> Data inicial
                            ,pr_dtafinal   IN VARCHAR2           --> Data final
                            ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                            ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                            ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                            ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                  
  /* Rotina para solicitar os benefícios via MQ ao SICREDI */
  PROCEDURE pc_solicitar(pr_cdcopaux   IN INTEGER            --> Código da cooperativa
                        ,pr_dtmvtolt   IN VARCHAR2           --> Data
                        ,pr_nmdatela   IN VARCHAR2           --> Nome da tela
                        ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                        ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                        ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                        ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para buscar o lançamento de pagamento do benefício que deve ser excluído */
  PROCEDURE pc_busca_lanmto_exclui(pr_cdcopcon  IN crapass.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_cddotipo  IN VARCHAR2              --> Tipo
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  /* Rotina para processar a exclusão do lançamento de pagamento do benefício */
  PROCEDURE pc_processa_exclui_lanmto(pr_cdcopcon  IN crapass.cdcooper%TYPE --> Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                     ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE --> Número do Documento
                                     ,pr_cddotipo  IN VARCHAR2              --> Tipo de Exclusão (E-Exclusiva/T-Todos)
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  /* Rotina para processar a planilha de pagamento dos beneficios do INSS */
  PROCEDURE pc_processa_planilha(pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo para ser processado
                                ,pr_nmdatela   IN VARCHAR2           --> Nome da tela                                  
                                ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo


  /* Rotina para processar a planilha de prova de vida dos beneficiarios do INSS */
  PROCEDURE pc_importar_prova_vida(pr_nmdatela   IN VARCHAR2           --> Nome da tela                                  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
END TELA_PRCINS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PRCINS AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_PRCINS
--    Autor   : Douglas Quisinski
--    Data    : Setembro/2015                   Ultima Atualizacao: 07/06/2016
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela PRCINS (Processos do INSS)
--
--    Alteracoes: 29/02/2016 - Ajuste para enviar o parâmetro nmdatela pois não está sendo
--                             possível gerar o relatório. A rotina do oracle está tentando
--                             encontrar o registro crapprg com base no parâmetro cdprogra 
--                             e não o encontra, pois ele é gravado com o nome da tela.
--                             (Adriano - SD 409943)
--    
--                14/04/2016 - Ajuste para utilizar a procedure pc_informa_acesso que altera
--                             o padrao de formatacao de data e valor do sistema, para utilizar
--                             padrao brasileiro ao inves do padrao americano, quando acessado
--                             pela WEB (Douglas - Chamado 424716)

--				  07/06/2016 - Melhoria 195 folha de pagamento (Tiago/Thiago)
--    
--          20/06/2017 - Colocar no padrão erro tratado ou mensagem(alerta)
--                     - (Belli Envolti) - Chamado 660286
--    
---------------------------------------------------------------------------------------------------------------
  /* Rotina para buscar as cooperativas */
  PROCEDURE pc_buscar_cooperativas(pr_cddopcao   IN VARCHAR2           -->Codigo Opcao
                                  ,pr_tipopera   IN VARCHAR2           --> Tipo de operacao
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_buscar_cooperativas
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 25/09/2015                        Ultima atualizacao: 11/11/2015

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as cooperativas ativas 

    Alteracoes: 16/10/2015 - Incluido o parametro pr_cddopcao (Adriano).
    
                11/11/2015 - Incluido o parametro pr_cddotipo (Adriano).
                           
    ............................................................................. */
      CURSOR cr_crapcop IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper <> 3
           AND crapcop.flgativo = 1
      ORDER BY crapcop.cdcooper;
    BEGIN
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><cooperativas></cooperativas></Root>');
      
      IF pr_cddopcao = 'R' OR 
        (pr_cddopcao = 'E' AND
         pr_tipopera = 'T' )THEN
        
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root/cooperativas'
                                           ,XMLTYPE('<cooperativa>'
                                                  ||'  <cdcooper>0</cdcooper>'
                                                  ||'  <nmrescop>TODAS</nmrescop>'
                                                  ||'</cooperativa>'));
                                                  
      END IF;                                                                                                    
                                                  
      FOR rw_crapcop IN cr_crapcop LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/cooperativas'
                                            ,XMLTYPE('<cooperativa>'
                                                   ||'  <cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'
                                                   ||'  <nmrescop>'||UPPER(rw_crapcop.nmrescop)||'</nmrescop>'
                                                   ||'</cooperativa>'));
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PRCINS.pc_buscar_cooperativas): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_buscar_cooperativas;
  
  /* Rotina para buscar o resumo de pagamento de beneficio em determinada data */
  PROCEDURE pc_buscar_resumo(pr_cdcopaux   IN INTEGER            --> Código da cooperativa
                            ,pr_dtinicio   IN VARCHAR2           --> Data inicial
                            ,pr_dtafinal   IN VARCHAR2           --> Data final
                            ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                            ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                            ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                            ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_buscar_resumo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 25/09/2015                        Ultima atualizacao: 11/11/2015

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar o resumo de benefícios que foram pagos em determinada data

    Alteracoes: 14/10/2015 - Ajustes realizados:
                             > Na validação da data de resumo será retornado o nome do
                               campo validado;
                             > Validação de erro ao chamar a rotina pc_extrai_dados;
                             > Alterado a forma de criação e retorno do xml com as informações.
                             (Adriano).
                             
                11/11/2015 - Ajuste para realizar consulta com base em um periodo informado
                             (Adriano).
                
    ............................................................................. */
      vr_cdcopaux INTEGER;  
      vr_dtinicio DATE;
      vr_dtafinal DATE;      
      
      vr_qtdtotal INTEGER;
      vr_vlrtotal NUMBER(25,2);
      
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_auxconta PLS_INTEGER:= 0;
            
      vr_exc_saida EXCEPTION;
    
      CURSOR cr_resumo (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtinicio IN craplcm.dtmvtolt%TYPE
                       ,pr_dtafinal IN craplcm.dtmvtolt%TYPE) IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,count(*) qtdbenef
              ,sum(craplcm.vllanmto) vlrbenef
          FROM craplcm, crapcop
         WHERE crapcop.cdcooper = craplcm.cdcooper
           AND craplcm.cdcooper = NVL(pr_cdcooper,craplcm.cdcooper)
           AND craplcm.dtmvtolt BETWEEN pr_dtinicio AND pr_dtafinal
           AND craplcm.cdhistor = 1399
        GROUP BY crapcop.cdcooper, crapcop.nmrescop
        ORDER BY crapcop.cdcooper;
        
    BEGIN
      
      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtinicio:= to_date(pr_dtinicio,'DD/MM/YYYY'); 
        
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_dscritic := 'Data incial invalida.';
          pr_nmdcampo := 'dtinicio';
          
          --Gera exceção
          RAISE vr_exc_saida;
      END;
    
      -- Verificar se existe cooperativa informada
      IF NVL(pr_cdcopaux,0) > 0 THEN
        vr_cdcopaux:= pr_cdcopaux;
      END IF;
      
      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtafinal:= to_date(pr_dtafinal,'DD/MM/YYYY'); 
        
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_dscritic := 'Data final invalida.';
          pr_nmdcampo := 'dtafinal';
          
          --Gera exceção
          RAISE vr_exc_saida;
      END;

      /* Extrai os dados */
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      vr_qtdtotal:= 0;
      vr_vlrtotal:= 0;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><resumos/>');
      
      FOR rw_resumo IN cr_resumo(pr_cdcooper => vr_cdcopaux
                                ,pr_dtinicio => vr_dtinicio
                                ,pr_dtafinal => vr_dtafinal) LOOP

        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> BUSCAR RESUMO DE PAGAMENTO: ' ||
                                                      UPPER(rw_resumo.nmrescop) ||
                                                      ' - Operador: ' || vr_cdoperad); 
                                                      
        vr_qtdtotal:= vr_qtdtotal + rw_resumo.qtdbenef;
        vr_vlrtotal:= vr_vlrtotal + rw_resumo.vlrbenef;
        
        -- Insere as tags dos campos da PLTABLE 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'resumos', pr_posicao => 0     , pr_tag_nova => 'resumo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'resumo', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_resumo.cdcooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'resumo', pr_posicao => vr_auxconta, pr_tag_nova => 'nmrescop', pr_tag_cont => UPPER(rw_resumo.nmrescop), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'resumo', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdbenef', pr_tag_cont => to_char(rw_resumo.qtdbenef,'fm999G999G990'), pr_des_erro => vr_dscritic);        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'resumo', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrbenef', pr_tag_cont => to_char(rw_resumo.vlrbenef,'fm999G999G990D00'), pr_des_erro => vr_dscritic);        
          
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;                  
          
      END LOOP;
      
      IF NVL(vr_cdcopaux,0) = 0 THEN
        
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                 ,pr_tag   => 'resumos'             --> Nome da TAG XML
                                 ,pr_atrib => 'qtdtotal'          --> Nome do atributo
                                 ,pr_atval => to_char(vr_qtdtotal,'fm999G999G990')         --> Valor do atributo
                                 ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                           
        -- Verifica se houve erro                      
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
            
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                 ,pr_tag   => 'resumos'             --> Nome da TAG XML
                                 ,pr_atrib => 'vlrtotal'          --> Nome do atributo
                                 ,pr_atval => to_char(vr_vlrtotal,'fm999G999G990D00')   --> Valor do atributo
                                 ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
        -- Verifica se houve erro                      
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
      END IF;        
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
        END IF;
        pr_cdcritic := pr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PRCINS.pc_buscar_resumo): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_buscar_resumo;

  /* Rotina para solicitar os benefícios via MQ ao SICREDI */
  PROCEDURE pc_solicitar(pr_cdcopaux   IN INTEGER            --> Código da cooperativa
                        ,pr_dtmvtolt   IN VARCHAR2           --> Data
                        ,pr_nmdatela   IN VARCHAR2           --> Nome da tela                        
                        ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                        ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                        ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                        ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_solicitar
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 25/09/2015                        Ultima atualizacao: 29/02/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para realizar a solicitação de mensagens por MQ ao SICREDI

    Alteracoes: 14/10/2015 - Ajustes efetuados:
                             > Validação de erro ao chamar a rotina pc_extrai_dados;
                             > Reestruturado o xml de retorno com as informações das cooperativas
                               processadas com sucesso ou não.
                             (Adriano).
                             
                29/02/2016 - Ajuste na rotina pc_solicitar para enviar o parâmetro nmdatela pois não está sendo
   				                   possível gerar o relatório. A rotina do oracle está tentando
	  						             encontrar o registro crapprg com base no parâmetro cdprogra 
		  					             e não o encontra, pois ele é gravado com o nome da tela.
			  				            (Adriano - SD 409943)
         
    ............................................................................. */
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_des_reto  VARCHAR2(10);
      
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_cdprogra VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dtmvtolt DATE;
      
      vr_exc_saida EXCEPTION;
      
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      CURSOR cr_crapcop_all IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper <> 3
           AND crapcop.flgativo = 1
      ORDER BY crapcop.cdcooper;

    BEGIN
      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
        
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          --Gera exceção
          RAISE vr_exc_saida;
      END;
    
      /* Extrai os dados */
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_cdprogra
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><processos></processos></Root>');
      
      -- Verificar se existe cooperativa informada
      IF NVL(pr_cdcopaux,0) = 0 THEN
        
        FOR rw_crapcop IN cr_crapcop_all LOOP
          --Escrever No LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'prcins.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                        ' --> INICIO SOLICITACAO BENEFICIO: ' ||
                                                        UPPER(rw_crapcop.nmrescop) ||
                                                        ' - Operador: ' || vr_cdoperad); 
        
          -- Solicita os creditos
          INSS0001.pc_benef_inss_solic_cred(pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_idorigem => vr_idorigem
                                           ,pr_cdoperad => vr_cdoperad
                                           ,pr_dtmvtolt => vr_dtmvtolt
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_cdprogra => vr_cdprogra
                                           ,pr_des_reto => vr_des_reto
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          /* Verificar se ocorreu erro */
          IF vr_des_reto <> 'OK' THEN
            
            pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                               ,'/Root/processos'
                                               ,XMLTYPE('<processo>'
                                                      ||'  <dsmensag>Nao foi possivel enviar solicitacao</dsmensag>'
                                                      ||'  <dscooper>'|| TRIM(UPPER(rw_crapcop.nmrescop)) ||'</dscooper>'
                                                      ||'</processo>'));
                                                   
            --Verificar se possui somente código erro
            IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            END IF;
            
            --Escrever No LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => 'prcins.log'
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                          ' --> ERRO SOLICITACAO BENEFICIO: ' ||
                                                          UPPER(rw_crapcop.nmrescop) ||
                                                          ' - Operador: ' || vr_cdoperad || 
                                                          ' - Erro: ' || vr_dscritic); 
          ELSE
            pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                               ,'/Root/processos'
                                               ,XMLTYPE('<processo>'
                                                      ||'  <dsmensag>Solicitacao enviada com sucesso</dsmensag>'
                                                      ||'  <dscooper>'|| TRIM(UPPER(rw_crapcop.nmrescop)) ||'</dscooper>'
                                                      ||'</processo>'));
                                                   
            --Verificar se possui somente código erro
            IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            END IF;
            
            --Escrever No LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => 'prcins.log'
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                          ' --> FIM SOLICITACAO BENEFICIO: ' ||
                                                          UPPER(rw_crapcop.nmrescop) ||
                                                          ' - Operador: ' || vr_cdoperad); 
          END IF;
        END LOOP;
        
      ELSE
        /* Quando possuir cooperativa selecionada
        *  solicitar os creditos apenas dessa cooperativa
        */
        OPEN cr_crapcop (pr_cdcooper => pr_cdcopaux);
        
        FETCH cr_crapcop INTO rw_crapcop;
        
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          RAISE vr_exc_saida;
        END IF;
        
        -- Fecha cursor
        CLOSE cr_crapcop;
        
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> INICIO SOLICITACAO BENEFICIO: ' ||
                                                      UPPER(rw_crapcop.nmrescop) ||
                                                      ' - Operador: ' || vr_cdoperad); 
        -- Solicita os creditos
        INSS0001.pc_benef_inss_solic_cred(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_idorigem => vr_idorigem
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_dtmvtolt => vr_dtmvtolt
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_cdprogra => vr_cdprogra
                                         ,pr_des_reto => vr_des_reto
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
         
        /* Verificar se ocorreu erro */
        IF vr_des_reto <> 'OK' THEN

          pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                             ,'/Root/processos'
                                             ,XMLTYPE('<processo>'
                                                    ||'  <dsmensag>Nao foi possivel enviar solicitacao</dsmensag>'
                                                    ||'  <dscooper>'|| TRIM(UPPER(rw_crapcop.nmrescop)) ||'</dscooper>'
                                                    ||'</processo>'));
                                                      
          --Verificar se possui somente código erro
          IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
            
          --Escrever No LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'prcins.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                        ' --> ERRO SOLICITACAO BENEFICIO: ' ||
                                                        UPPER(rw_crapcop.nmrescop) ||
                                                        ' - Operador: ' || vr_cdoperad || 
                                                        ' - Erro: ' || vr_dscritic); 
        ELSE
          pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                             ,'/Root/processos'
                                             ,XMLTYPE('<processo>'
                                                    ||'  <dsmensag>Solicitacao enviada com sucesso</dsmensag>'
                                                    ||'  <dscooper>'|| TRIM(UPPER(rw_crapcop.nmrescop)) ||'</dscooper>'
                                                    ||'</processo>'));
                                                      
          --Verificar se possui somente código erro
          IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          
          --Escrever No LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'prcins.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                        ' --> FIM SOLICITACAO BENEFICIO: ' ||
                                                        UPPER(rw_crapcop.nmrescop) ||
                                                        ' - Operador: ' || vr_cdoperad); 
        END IF;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
        END IF;
        pr_cdcritic := pr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
        
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PRCINS.pc_solicitar): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_solicitar;

  /* Rotina para buscar o lançamento de pagamento do benefício que deve ser excluído */
  PROCEDURE pc_busca_lanmto_exclui(pr_cdcopcon  IN crapass.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_cddotipo  IN VARCHAR2              --> Tipo
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    /* .............................................................................
    Programa: pc_busca_lanmto_exclui
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 02/10/2015                        Ultima atualizacao: 11/11/2015

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar o último lançamento de pagamento do benefício de INSS

    Alteracoes: 14/10/2015 - Ajustes efetuados:
                             > Validação de erro ao chamar a rotina pc_extrai_dados
                             (Adriano).
                             
                11/11/2015 - Ajuste para efetuar a buscar de acordo com o tipo da
                             exclusao
                             (Adriano).              
    ............................................................................. */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      --Variáveis auxiliares      
      vr_exislanc BOOLEAN := FALSE;
      vr_qtdtotal INTEGER := 0;
      vr_vlrtotal NUMBER(25,2) := 0;
      
      --Controle de erro
      vr_exc_erro EXCEPTION;

      CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%TYPE
                       ,pr_nrdconta craplcm.nrdconta%TYPE
                       ,pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
        SELECT craplcm.cdcooper
              ,crapcop.nmrescop
              ,craplcm.nrdconta
              ,craplcm.dtmvtolt
              ,craplcm.cdhistor
              ,craplcm.nrdocmto
              ,craplcm.vllanmto
              ,craphis.dshistor
          FROM craplcm, craphis, crapcop
         WHERE crapcop.cdcooper = craplcm.cdcooper
           AND craphis.cdcooper = craplcm.cdcooper
           AND craphis.cdhistor = craplcm.cdhistor
           AND craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.dtmvtolt = pr_dtmvtolt
           AND craplcm.cdhistor = 1399;
      rw_craplcm cr_craplcm%ROWTYPE;
      
      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.cdcooper            
       FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_craplcm_qtd(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE)  IS
        SELECT COUNT(craplcm.nrdconta) qtlanmto
          FROM craplcm
         WHERE (NVL(pr_cdcooper,0) = 0 OR 
                craplcm.cdcooper = pr_cdcooper)
           AND craplcm.dtmvtolt = pr_dtmvtolt
           AND craplcm.cdhistor = 1399;
      rw_craplcm_qtd cr_craplcm_qtd%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      /* Extrai os dados */
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                        
                              
      -- Leitura do calendario da CENTRAL
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      
      -- Se a conta possuir valor zero
      IF pr_cddotipo = 'T' THEN
        
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> BUSCAR QUANTIDADE DE BENEFICIOS PAGOS NO DIA' ||
                                                      ' - Operador: ' || vr_cdoperad); 
                                                      
        -- Total de lançamentos que devem ser excluidos
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_craplcm_qtd(pr_cdcooper => pr_cdcopcon
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        
        FETCH cr_craplcm_qtd INTO rw_craplcm_qtd;
        
        CLOSE cr_craplcm_qtd;
        
        -- Verificar se existem lançamentos para o dia de hoje
        IF rw_craplcm_qtd.qtlanmto = 0 THEN
          -- Monta critica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao existe lancamento de pagamento de beneficio no dia de hoje.';
          RAISE vr_exc_erro;
        ELSE
          -- Retorna o nome do cooperado      
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Dados><qtlanmto>' || rw_craplcm_qtd.qtlanmto || '</qtlanmto></Dados></Root>');

        END IF;
        
      ELSE 
        
        -- Verifica se o associado existe
        OPEN cr_crapass (pr_cdcooper => pr_cdcopcon
                        ,pr_nrdconta => pr_nrdconta);
                        
        FETCH cr_crapass INTO rw_crapass;
        
        -- Se nao encontrar
        IF cr_crapass%NOTFOUND THEN
          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapass;
          
          -- Montar mensagem de critica
          vr_cdcritic := 9;
          
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          
          --Campo com critica
          pr_nmdcampo:= 'nrdconta';
          
          --Levantar Excecao
          RAISE vr_exc_erro;
          
        END IF;
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> BUSCAR DADOS DO PAGAMENTO DE BENEFICIO' ||
                                                      ' - COOP: '  || pr_cdcopcon || 
                                                      ' - CONTA: ' || pr_nrdconta || 
                                                      ' - Operador: ' || vr_cdoperad); 
      
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><lancamentos></lancamentos></Root>');
                
        FOR rw_craplcm IN cr_craplcm(pr_cdcooper => pr_cdcopcon
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                                    
          vr_exislanc := TRUE; 
          vr_qtdtotal := vr_qtdtotal + 1;
          vr_vlrtotal := vr_vlrtotal + rw_craplcm.vllanmto;
          
          pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                             ,'/Root/lancamentos'
                                             ,XMLTYPE('<lancamento>'
                                                   ||'  <cdcooper>' || rw_craplcm.cdcooper || '</cdcooper>'
                                                   ||'  <nmrescop>' || rw_craplcm.nmrescop || '</nmrescop>'
                                                   ||'  <nrdconta>' || GENE0002.fn_mask_conta(rw_craplcm.nrdconta) || '</nrdconta>'
                                                   ||'  <dtmvtolt>' || NVL(to_char(rw_craplcm.dtmvtolt,'DD/MM/YYYY'),' ') || '</dtmvtolt>'
                                                   ||'  <cdhistor>' || rw_craplcm.cdhistor || '</cdhistor>'
                                                   ||'  <dshistor>' || rw_craplcm.dshistor || '</dshistor>'
                                                   ||'  <nrdocmto>' || rw_craplcm.nrdocmto || '</nrdocmto>'
                                                   ||'  <vllanmto>' || to_char(rw_craplcm.vllanmto,'fm999G999G990D00') || '</vllanmto>'
                                                   ||'</lancamento>'));
                                                   
      
        END LOOP;
        
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                 ,pr_tag   => 'lancamentos'             --> Nome da TAG XML
                                 ,pr_atrib => 'qtdtotal'          --> Nome do atributo
                                 ,pr_atval => to_char(vr_qtdtotal,'fm999G999G990')         --> Valor do atributo
                                 ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic);    --> Descrição de erros
         
        -- Verifica se houve erro                      
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
                                  
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                 ,pr_tag   => 'lancamentos'             --> Nome da TAG XML
                                 ,pr_atrib => 'vlrtotal'          --> Nome do atributo
                                 ,pr_atval => to_char(vr_vlrtotal,'fm999G999G990D00')   --> Valor do atributo
                                 ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                   
        -- Verifica se houve erro                      
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
         

      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PRCINS.pc_busca_lanmto_exclui): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_busca_lanmto_exclui;

  /* Rotina para processar a exclusão do lançamento de pagamento do benefício */
  PROCEDURE pc_processa_exclui_lanmto(pr_cdcopcon  IN crapass.cdcooper%TYPE --> Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                     ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE --> Número do Documento
                                     ,pr_cddotipo  IN VARCHAR2              --> Tipo de Exclusão (E-Exclusiva/T-Todos)
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    /* .............................................................................
    Programa: pc_processa_exclui_lanmto
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 02/10/2015                        Ultima atualizacao: 07/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para excluir o lançamento de pagamento do benefício

    Alteracoes: 14/10/2015 - Ajustes efetuados:
                             > Validação de erro ao chamar a rotina pc_extrai_dados
                             (Adriano).
                             
                11/11/2015 - Ajustes para eliminar o lote quando for excluido o ultimo
                             lancamento
                             (Adriano).             
                             
                07/06/2016 - Melhoria 195 folha de pagamento (Tiago/Thiago)                         
    ............................................................................. */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
            
      vr_exc_erro EXCEPTION;

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.nmrescop
            ,crapcop.nmextcop
            ,crapcop.dsdircop
            ,crapcop.cdagesic
            ,crapcop.cdcooper
        FROM crapcop crapcop
       WHERE (NVL(pr_cdcooper,0) = 0 OR
              crapcop.cdcooper = pr_cdcooper);
      rw_crapcop cr_crapcop%ROWTYPE;
       
      -- Cursor para identificar o lançamento
      CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%TYPE
                       ,pr_nrdconta craplcm.nrdconta%TYPE
                       ,pr_nrdocmto craplcm.nrdocmto%TYPE
                       ,pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
        SELECT craplcm.cdcooper
              ,craplcm.nrdconta
              ,craplcm.dtmvtolt
              ,craplcm.cdhistor
              ,craplcm.nrdocmto
              ,craplcm.vllanmto
              ,craplcm.nrdolote
              ,craplcm.cdagenci
              ,craplcm.nrseqdig
              ,craplcm.cdbccxlt              
              ,craplcm.rowid
          FROM craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.nrdocmto = pr_nrdocmto
           AND craplcm.dtmvtolt = pr_dtmvtolt
           AND craplcm.cdhistor = 1399;
      rw_craplcm cr_craplcm%ROWTYPE;
      
      -- Cursor para identificar o lote do lançamento
      CURSOR cr_craplot(pr_cdcooper craplcm.cdcooper%TYPE
                       ,pr_dtmvtolt craplcm.dtmvtolt%TYPE
                       ,pr_cdagenci craplcm.cdagenci%TYPE) IS
      SELECT craplot.cdcooper
            ,craplot.dtmvtolt
            ,craplot.cdagenci
            ,craplot.cdbccxlt
            ,craplot.nrdolote
            ,craplot.nrseqdig
            ,craplot.qtcompln
            ,craplot.qtinfoln
            ,craplot.vlcompcr
            ,craplot.vlinfocr            
            ,craplot.rowid
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper 
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = 100
         AND craplot.nrdolote = 10132;
      rw_craplot cr_craplot%ROWTYPE;
      
      -- Cursor para validar se o lote está vazio
      CURSOR cr_craplot_validar(pr_rowid VARCHAR2) IS
      SELECT craplot.qtcompln
            ,craplot.rowid
        FROM craplot
       WHERE craplot.rowid = pr_rowid;
      rw_craplot_validar cr_craplot_validar%ROWTYPE;
         
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      /* Extrai os dados */
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

                              
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
      
      -- Leitura do calendario da CENTRAL
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;

      -- Validar o tipo de Exclusão
      IF pr_cddotipo = 'E' THEN
        
        IF pr_cdcopcon = 0 OR pr_nrdconta = 0 OR pr_nrdocmto = 0 THEN
          -- Monta critica
          vr_cdcritic := 0;
          vr_dscritic := 'Lancamento nao identificado para excluir';
          RAISE vr_exc_erro;
        END IF;
        
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> INICIO EXCLUSAO PAGAMENTO DE BENEFICIO' ||
                                                      ' - Operador: ' || vr_cdoperad); 

        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => pr_cdcopcon);
        
        FETCH cr_crapcop INTO rw_crapcop;
        
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;          
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_erro;          
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;
        
        OPEN cr_craplcm(pr_cdcooper => pr_cdcopcon
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrdocmto => pr_nrdocmto
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                       
        FETCH cr_craplcm INTO rw_craplcm;
        
        -- Verifica se encontrou lancamento
        IF cr_craplcm%NOTFOUND THEN
          CLOSE cr_craplcm;
          -- Monta critica
          vr_cdcritic := 0;
          vr_dscritic := 'Lancamento nao identificado para excluir';
          RAISE vr_exc_erro;
        END IF;
        
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' -->   IDENTIFICADO PAGAMENTO DE BENEFICIO' ||
                                                      ' - COOP: '  || rw_craplcm.cdcooper ||
                                                      ' - CONTA: ' || rw_craplcm.nrdconta ||
                                                      ' - DOCMTO: ' || rw_craplcm.nrdocmto ||
                                                      ' - LOTE: ' || rw_craplcm.nrdolote ||
                                                      ' - HISTORICO: ' || rw_craplcm.cdhistor ||
                                                      ' - VALOR: ' || rw_craplcm.vllanmto ||
                                                      ' - ROWID: ' || rw_craplcm.rowid ||
                                                      ' - Operador: ' || vr_cdoperad); 

        OPEN cr_craplot(pr_cdcooper => rw_craplcm.cdcooper
                       ,pr_dtmvtolt => rw_craplcm.dtmvtolt
                       ,pr_cdagenci => rw_craplcm.cdagenci);
                       
        FETCH cr_craplot INTO rw_craplot;
        -- Verifica se encontrou lancamento
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          -- Monta critica
          vr_cdcritic := 0;
          vr_dscritic := 'Lote do lancamento nao identificado';
          RAISE vr_exc_erro;
        END IF;
        
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' -->   IDENTIFICADO LOTE DO BENEFICIO' ||
                                                      ' - COOP: ' || rw_craplot.cdcooper ||
                                                      ' - DATA: ' || rw_craplot.dtmvtolt ||
                                                      ' - AGENCIA: ' || rw_craplot.cdagenci ||
                                                      ' - CAIXA: ' || rw_craplot.cdbccxlt ||
                                                      ' - LOTE: ' || rw_craplot.nrdolote ||
                                                      ' - ROWID: ' || rw_craplot.rowid ||
                                                      ' - Operador: ' || vr_cdoperad); 

        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' -->   ALTERADO LOTE DO BENEFICIO' ||
                                                      ' - qtcompln: de ' || rw_craplot.qtcompln || ' para ' || (rw_craplot.qtcompln - 1) || 
                                                      ' - qtinfoln: de ' || rw_craplot.qtinfoln || ' para ' || (rw_craplot.qtinfoln - 1) || 
                                                      ' - vlcompcr: de ' || rw_craplot.vlcompcr || ' para ' || (rw_craplot.vlcompcr - rw_craplcm.vllanmto) || 
                                                      ' - vlinfocr: de ' || rw_craplot.vlinfocr || ' para ' || (rw_craplot.vlinfocr - rw_craplcm.vllanmto) || 
                                                      ' - Operador: ' || vr_cdoperad); 

        UPDATE craplot
           SET craplot.qtcompln = rw_craplot.qtcompln - 1
              ,craplot.qtinfoln = rw_craplot.qtinfoln - 1
              ,craplot.vlcompcr = rw_craplot.vlcompcr - rw_craplcm.vllanmto
              ,craplot.vlinfocr = rw_craplot.vlinfocr - rw_craplcm.vllanmto
         WHERE craplot.rowid    = rw_craplot.rowid;
        
        folh0001.pc_excluir_lanaut(pr_cdcooper => rw_craplcm.cdcooper
                                  ,pr_dtmvtolt => rw_craplcm.dtmvtolt
                                  ,pr_cdagenci => rw_craplcm.cdagenci
                                  ,pr_nrdconta => rw_craplcm.nrdconta
								  ,pr_cdhistor => rw_craplcm.cdhistor
                                  ,pr_cdbccxlt => rw_craplcm.cdbccxlt
                                  ,pr_nrdolote => rw_craplcm.nrdolote
                                  ,pr_nrseqdig => rw_craplcm.nrseqdig
                                  ,pr_dscritic => vr_dscritic);
                                  
        IF vr_dscritic IS NOT NULL THEN
           vr_cdcritic := 0;
           RAISE vr_exc_erro;
        END IF;
        
        DELETE craplcm
         WHERE craplcm.rowid = rw_craplcm.rowid;
        
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' -->  EXCLUIDO PAGAMENTO DO BENEFICIO' ||
                                                      ' - Operador: ' || vr_cdoperad); 

        OPEN cr_craplot_validar (pr_rowid => rw_craplot.rowid);
        FETCH cr_craplot_validar INTO rw_craplot_validar;
        IF cr_craplot_validar%FOUND THEN
          -- Validar se a quantidade do lote é zero 
          IF rw_craplot_validar.qtcompln = 0 THEN
            -- Se estiver vazio, excluimos o lote
            DELETE craplot 
             WHERE craplot.rowid = rw_craplot.rowid;
             
            --Escrever No LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => 'prcins.log'
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                          ' -->  EXCLUIDO LOTE DE PAGAMENTO' ||
                                                          ' - Operador: ' || vr_cdoperad); 
          END IF;
        END IF;
        
        CLOSE cr_craplot_validar;

      ELSE 
        
        FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcopcon ) LOOP
          
          -- Exclusão de todos os pagamentos
          BEGIN
            /* Excluir todos os lotes do dia, para pagamento do INSS */
            DELETE FROM craplot  
             WHERE craplot.cdcooper = rw_crapcop.cdcooper
               AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
               AND craplot.cdbccxlt = 100
               AND craplot.nrdolote = 10132;
            
            /* Excluir todos os lançamentos de pagamento de benefício do INSS */
            DELETE FROM craplcm
             WHERE craplcm.cdcooper = rw_crapcop.cdcooper
               AND craplcm.dtmvtolt = rw_crapdat.dtmvtolt
               AND craplcm.cdhistor = 1399;
               
            folh0001.pc_excluir_lanaut_dia(pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdhistor => 1399
                                          ,pr_dscritic => vr_dscritic);   
                                          
            IF vr_dscritic IS NOT NULL THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro durante a exclusao dos lancamentos da cooperativa: ' || rw_crapcop.nmrescop || ' - ' || SQLERRM;
               --Escrever No LOG
               btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_nmarqlog     => 'prcins.log'
                                         ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                             ' --> ' || vr_dscritic || 
                                                             ' - Operador: ' || vr_cdoperad); 

               ROLLBACK;
               RAISE vr_exc_erro;              
            END IF;                              
            
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro durante a exclusao dos lancamentos da cooperativa: ' || rw_crapcop.nmrescop || ' - ' || SQLERRM;
              --Escrever No LOG
              btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_nmarqlog     => 'prcins.log'
                                        ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                            ' --> ' || vr_dscritic || 
                                                            ' - Operador: ' || vr_cdoperad); 

              ROLLBACK;
              RAISE vr_exc_erro;
          END;
          
          --Escrever No LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'prcins.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                        ' --> EXCLUSAO DE TODOS OS PAGAMENTOS DE BENEFICIO DO DIA ' ||
                                                        to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY') ||
                                                        ' - Operador: ' || vr_cdoperad || ' - Cooperativa: ' || rw_crapcop.nmrescop); 
        END LOOP;
         
      END IF;
      
      COMMIT;
                                                            
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PRCINS.pc_processa_exclui_lanmto): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_processa_exclui_lanmto;

  /* Rotina para processar a planilha de pagamento dos beneficios do INSS */
  PROCEDURE pc_processa_planilha(pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo para ser processado
                                ,pr_nmdatela   IN VARCHAR2           --> Nome da tela  
                                ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2)IS            --> Erros do processo
    /* .............................................................................
    Programa: pc_processa_planilha
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 06/10/2015                        Ultima atualizacao: 14/04/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para processar a planilha com o pagamento dos beneficios do INSS

    Alteracoes: 14/10/2015 - Ajustes efetuados:
                             > Validação de erro ao chamar a rotina pc_extrai_dados
                             (Adriano).
                             
                11/11/2015 - Ajuste para retornar outros quantificadores
                             (Adriano).
                
                29/02/2016 - Ajuste na rotina pc_solicitar para enviar o parâmetro nmdatela pois não está sendo
   				             possível gerar o relatório. A rotina do oracle está tentando
	  						 encontrar o registro crapprg com base no parâmetro cdprogra 
		  					 e não o encontra, pois ele é gravado com o nome da tela.
			  				 (Adriano - SD 409943)

                14/04/2016 - Ajuste para utilizar a procedure pc_informa_acesso que altera
                             o padrao de formatacao de data e valor do sistema, para utilizar
                             padrao brasileiro ao inves do padrao americano, quando acessado
                             pela WEB (Douglas - Chamado 424716)
    ............................................................................. */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      vr_qtplanil INTEGER;
      vr_qtproces INTEGER;
      vr_qtderros INTEGER;
      vr_vltotpro NUMBER(25,2);
      vr_vltotpla NUMBER(25,2);
      vr_vlderros NUMBER(25,2);
      vr_nmarqerr VARCHAR2(1000);
      
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_cdprogra VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PRCINS'
                                ,pr_action => null);

      /* Extrai os dados */
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_cdprogra
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
    
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
      --Escrever No LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'prcins.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> INICIO DO PROCESSO DE PAGAMENTO DA PLANILHA DO INSS' ||
                                                    ' - Operador: ' || vr_cdoperad); 
      
      INSS0001.pc_exec_pagto_benef_plani(pr_cdcooper => vr_cdcooper
                                        ,pr_nmarquiv => pr_nmarquiv
                                        ,pr_nrdcaixa => vr_nrdcaixa
                                        ,pr_cdprogra => pr_nmdatela
                                        ,pr_qtplanil => vr_qtplanil
                                        ,pr_vltotpla => vr_vltotpla
                                        ,pr_qtproces => vr_qtproces
                                        ,pr_vltotpro => vr_vltotpro
                                        ,pr_qtderros => vr_qtderros
                                        ,pr_vlderros => vr_vlderros
                                        ,pr_nmarqerr => vr_nmarqerr
                                        ,pr_dscritic => vr_dscritic);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      --Escrever No LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'prcins.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> FIM DO PROCESSO DE PAGAMENTO DA PLANILHA DO INSS' ||
                                                    ' - Operador: ' || vr_cdoperad); 
      
      -- Retorna o nome do cooperado      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>' ||
                                        '<qtplanil>' || vr_qtplanil || '</qtplanil>'||
                                        '<vltotpla>' || vr_vltotpla || '</vltotpla>'||                                        
                                        '<qtproces>' || vr_qtproces || '</qtproces>'||
                                        '<qtderros>' || vr_qtderros || '</qtderros>'||
                                        '<vlderros>' || vr_vlderros || '</vlderros>'||                                        
                                        '<vltotpro>' || vr_vltotpro || '</vltotpro>'||
                                        '<nmarqerr>' || vr_nmarqerr || '</nmarqerr>'||
                                     '</Dados></Root>');
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'prcins.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                      ' --> ERRO DURANTE O PROCESSO DE PAGAMENTO PELA PLANILHA. ' ||
                                                      ' - Erro: ' || vr_dscritic ||
                                                      ' - Operador: ' || vr_cdoperad); 
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PRCINS.pc_processa_planilha): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_processa_planilha;


  /* Rotina para processar a planilha de pagamento dos beneficios do INSS */
  PROCEDURE pc_importar_prova_vida(pr_nmdatela   IN VARCHAR2           --> Nome da tela                                  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2)IS            --> Erros do processo
    /* .............................................................................
    Programa: pc_importar_prova_vida
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 22/03/2017                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para processar a planilha de prova de vida dos beneficiaros do INSS

    Alteracoes: 
    
          20/06/2017 - Colocar no padrão erro tratado ou mensagem(alerta)
                     - (Belli Envolti) - Chamado 660286
                     
    ............................................................................. */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_cdprogra VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nmdireto VARCHAR2(100);
      
      vr_exc_erro EXCEPTION;
      
      -- Variavel para gerar LOG 20/06/2017 Chamado 660286
      vr_indicador_gera_log  VARCHAR2(3) := 'Sim';
      
    BEGIN      
	    -- Incluir nome do módulo logado -- Belli 20/06/2017
      GENE0001.pc_informa_acesso(pr_module => 'TELA_PRCINS',pr_action => 'TELA_PRCINS.pc_importar_prova_vida');
      
      pr_nmdcampo := NULL;
      pr_des_erro := NULL;

      /* Extrai os dados */
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_cdprogra
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
    
      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
            
      --Buscar Diretorio Micros da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'M' --> Usr/micros
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => 'inss');      
      
      --Escrever No LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- mensagem tratada
                                ,pr_nmarqlog     => 'prcins.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                   ' - ' || pr_nmdatela ||  ' --> ' ||
                                                   'ALERTA: ' ||
                                                    'INICIO DO PROCESSO DE IMPORTACAO DA PROVA DE VIDA DO INSS' ||
                                                    ' - Operador: ' || vr_cdoperad
                                ,pr_cdprograma   => pr_nmdatela
                                                    ); 
      
      INSS0003.pc_importar_prova_vida(pr_cdprogra => pr_nmdatela
                                     ,pr_dsdireto => vr_nmdireto
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        
          -- Variavel para gerar LOG 20/06/2017 Chamado 660286
          vr_indicador_gera_log := 'Não';
          RAISE vr_exc_erro;
      END IF;

      --Escrever No LOG
      btch0001.pc_gera_log_batch(
          pr_cdcooper     => vr_cdcooper
         ,pr_ind_tipo_log => 1 -- mensagem tratada
         ,pr_nmarqlog     => 'prcins.log'
         ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                            ' - ' || pr_nmdatela ||  ' --> ' ||
                            'ALERTA: ' ||
                             'FIM DO PROCESSO DE IMPORTACAO DA PROVA DE VIDA DO INSS' ||
                             ' - Operador: ' || vr_cdoperad
         ,pr_cdprograma   => pr_nmdatela
                             ); 
      
      -- Retorna o nome do cooperado      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>' ||
                                     '</Dados></Root>');
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Variavel para gerar LOG 20/06/2017 Chamado 660286
        if ( vr_indicador_gera_log = 'Sim' ) then
          
             --Escrever No LOG
              btch0001.pc_gera_log_batch(
               pr_cdcooper     => vr_cdcooper
              ,pr_ind_tipo_log => 2 -- Erro tratato
              ,pr_nmarqlog     => 'prcins.log'
              ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                               ' - ' || pr_nmdatela ||  ' --> ' ||
                               'ERRO: ' ||
                               'DURANTE O PROCESSO DE IMPORTACAO DA PROVA DE VIDA DO INSS' ||
                               ' - Erro: ' || vr_dscritic ||
                               ' - Operador: ' || vr_cdoperad
              ,pr_cdprograma   => pr_nmdatela
                               ); 
        end if;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PRCINS.pc_importar_prova_vida): ' || 
                       REPLACE(REPLACE(SQLERRM, '''', NULL), '"', NULL);
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_importar_prova_vida;

END TELA_PRCINS;
/
