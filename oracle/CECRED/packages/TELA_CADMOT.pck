CREATE OR REPLACE PACKAGE tela_cadmot IS
  
  -- Listagem dos Motivos
  PROCEDURE pc_lista_motivos(pr_nrregist IN INTEGER               -- Quantidade de registros
                            ,pr_nriniseq IN INTEGER               -- Quantidade inicial
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro

  -- Listagem dos Produtos
  PROCEDURE pc_lista_produtos(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
                             

  /* Manutenção de motivos */
  PROCEDURE pc_mantem_motivo(pr_idmotivo           in NUMBER   -- ID
                            ,pr_dsmotivo           in varchar2 -- Descricao
                            ,pr_cdproduto          in varchar2 -- Produto
                            ,pr_flgreserva_sistema in varchar2 -- Reservado sistema
                            ,pr_flgativo           IN VARCHAR2 -- Ativo 1/0
                            ,pr_flgtipo            IN NUMBER   -- 0-Desbloqueio 1-Bloqueio
                            ,pr_flgexibe           IN NUMBER   -- 0-Não Exibe 1-Exibe 
                            ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                            ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                            ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK                             

END tela_cadmot;
/
CREATE OR REPLACE PACKAGE BODY tela_cadmot IS
  ---------------------------------------------------------------------------
  --
  --  Programa : tela_cadmot
  --  Sistema  : Ayllos Web
  --  Autor    : MArcos Martini
  --  Data     : Janeiro - 2019.               
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADMOT
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------
  
   /* Constante do nome do arquivo */
   vr_nmarqlog CONSTANT VARCHAR2(100) := 'cadmot';
   
   --Variaveis de Criticas
   vr_cdcritic INTEGER;
   vr_dscritic VARCHAR2(4000);
   --Variaveis de Excecoes
   vr_exc_erro  EXCEPTION;
   
   -- Variaveis de locais de mensageria
   vr_cdcooper crapcop.cdcooper%TYPE;
   vr_cdoperad VARCHAR2(100);
   vr_nmdatela VARCHAR2(100);
   vr_nmeacao  VARCHAR2(100);
   vr_cdagenci VARCHAR2(100);
   vr_nrdcaixa VARCHAR2(100);
   vr_idorigem VARCHAR2(100);   
  
  -- Função para traduzir o codigo produto em descrição
  FUNCTION fn_dsproduto(pr_cdproduto tbcc_produto.cdproduto%TYPE) RETURN VARCHAR2 IS
    CURSOR cr_produto IS
      SELECT prd.dsproduto
        FROM tbcc_produto prd
       WHERE prd.cdproduto = pr_cdproduto;
    vr_dsproduto tbcc_produto.dsproduto%TYPE;   
  BEGIN
    OPEN cr_produto;
    FETCH cr_produto
     INTO vr_dsproduto;
    CLOSE cr_produto;  
    RETURN vr_dsproduto;
  END;

  -- Função para traduzir flag 0/1 em Não/Sim
  FUNCTION fn_traduz_flag01(pr_flag IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF pr_flag = 0 THEN
      RETURN 'Não';
    ELSE
      RETURN 'Sim';
    END IF;
  END;
  
  -- Listagem dos Motivos
  PROCEDURE pc_lista_motivos(pr_nrregist IN INTEGER               -- Quantidade de registros
                            ,pr_nriniseq IN INTEGER               -- Quantidade inicial
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_motivos
    --  Sistema  : Rotinas para listar os produtos na tela
    --  Sigla    : GENE
    --  Autor    : Marcos Martini
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de Motivos a serem exibidos na tela de motivos
    --
    --  Alteracoes: 
    -- 
    -- .............................................................................
    
    -- Cursores
    CURSOR cr_motivos IS
      SELECT mot.idmotivo
            ,mot.dsmotivo
            ,mot.flgreserva_sistema 
            ,mot.flgativo
            ,prd.cdproduto
            ,prd.dsproduto
			,mot.flgexibe
            ,mot.flgtipo
            ,COUNT(1) OVER (PARTITION BY 1) qtdregis
        FROM tbgen_motivo mot
            ,tbcc_produto prd
       WHERE mot.cdproduto = prd.cdproduto
       ORDER BY prd.dsproduto;
    
    -- Variaveis locais
    vr_contador INTEGER := 0;
    vr_clobxml  CLOB;
    vr_dstexto  VARCHAR2(32767);
  
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADMOT'
                              ,pr_action => 'pc_lista_motivos');

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
    
    -- Inicializar as informações do XML de dados para o relatório
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
    
    -- Percorre todos os produtos a serem exibidos na tela
    FOR rw_motivos IN cr_motivos LOOP
      -- SOmente na primeira linha
      IF vr_contador = 0 THEN
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<?xml version="1.0" encoding="UTF-8"?>' || 
                                    '<Root><Dados qtdregis="'||rw_motivos.qtdregis||'">');    
      END IF;
      -- Incrementar o contador
      vr_contador := vr_contador + 1; 
      -- Checar paginação
      IF pr_nrregist > 0 AND ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN
        -- Enviar o registro
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<Motivos>' ||
                                  '<idmotivo>' || rw_motivos.idmotivo || '</idmotivo>' ||
                                  '<dsmotivo>' || rw_motivos.dsmotivo || '</dsmotivo>' ||
                                  '<flgreserva_sistema>' || rw_motivos.flgreserva_sistema || '</flgreserva_sistema>' ||
                                  '<cdproduto>' || rw_motivos.cdproduto || '</cdproduto>' ||
                                  '<dsproduto>' || rw_motivos.dsproduto || '</dsproduto>' ||
                                  '<flgativo>' || rw_motivos.flgativo  || '</flgativo>' ||
								  '<flgtipo>'  || rw_motivos.flgtipo  || '</flgtipo>' ||
                                  '<flgexibe>' || rw_motivos.flgexibe  || '</flgexibe>' ||
                                '</Motivos>');

      END IF;         
    END LOOP;
    
    -- Caso não tenham registros
    IF vr_contador = 0 THEN
      -- Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_dstexto
                             ,'<?xml version="1.0" encoding="UTF-8"?><Root/><Dados qtdregis="0"/>');    
    ELSE
      -- Houveram registros, então finalizamos o XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_dstexto
                             ,'</Dados></Root>'
                             ,TRUE);    	
    END IF;
    
    -- Devolver o XML
    pr_retxml := xmltype.createXML(vr_clobxml);
    --Fechar Clob e Liberar Memoria  
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);  
    
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro geral em pc_lista_motivos: ' || SQLERRM;
      pr_dscritic := 'Erro geral em pc_lista_motivos: ' || SQLERRM;
  END pc_lista_motivos;

  -- Listagem dos Produtos
  PROCEDURE pc_lista_produtos(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_produtos
    --  Sistema  : Rotinas para listar os produtos na tela
    --  Sigla    : GENE
    --  Autor    : Marcos Martini
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de produtos a serem exibidos na tela de motivos
    --
    --  Alteracoes: 
    -- 
    -- .............................................................................
    
    -- Cursores
    CURSOR cr_produtos IS
      SELECT prd.cdproduto
           , prd.dsproduto
        FROM tbcc_produto prd
       ORDER BY prd.dsproduto;
    
    -- Variaveis locais
    vr_contador INTEGER := 0;
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADMOT'
                              ,pr_action => 'pc_lista_produtos');

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
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Percorre todos os produtos a serem exibidos na tela
    FOR rw_produto IN cr_produtos LOOP
      
      -- Inserir a tag agrupadora
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inf'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      -- Inserir o código do produto
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdproduto'
                            ,pr_tag_cont => rw_produto.cdproduto
                            ,pr_des_erro => vr_dscritic);
      -- Inserir a descrição do produto
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsproduto'
                            ,pr_tag_cont => rw_produto.dsproduto
                            ,pr_des_erro => vr_dscritic);
      -- Incrementar o contador
      vr_contador := vr_contador + 1;      
    END LOOP;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro geral em pc_lista_produtos: ' || SQLERRM;
      pr_dscritic := 'Erro geral em pc_lista_produtos: ' || SQLERRM;
  END pc_lista_produtos;
  
  /* Manutenção de motivos */
  PROCEDURE pc_mantem_motivo(pr_idmotivo           in NUMBER   -- ID
                            ,pr_dsmotivo           in varchar2 -- Descricao
                            ,pr_cdproduto          in varchar2 -- Produto
                            ,pr_flgreserva_sistema in varchar2 -- Reservado sistema
                            ,pr_flgativo           IN VARCHAR2 -- Ativo 1/0
                            ,pr_flgtipo            IN NUMBER   -- 0-Desbloqueio 1-Bloqueio
                            ,pr_flgexibe           IN NUMBER   -- 0-Não Exibe 1-Exibe																											 
                            ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                            ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                            ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_mantem_motivo
    Autor    : MArcos Martini - Envolti
    Data     : Janeiro/2019                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Gravar (inserir ou alterar) informações do motivo conforme preenchimento em tela PHP

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    --Busca do motivo enviado
    Cursor cr_motivo is
      Select *
        From tbgen_motivo
       Where idmotivo = pr_idmotivo;
    rw_motivo cr_motivo%rowtype;

    --Busca outro motivo com mesma descrição no mesmo produto
    Cursor cr_outro_motivo is
      SELECT m.dsmotivo
        FROM tbgen_motivo m
       WHERE m.cdproduto = pr_cdproduto
         AND m.dsmotivo = pr_dsmotivo
         AND (pr_idmotivo IS NULL OR pr_idmotivo <> m.idmotivo);
    rw_outro_motivo cr_outro_motivo%rowtype; 
    
    -- Buscar proximo id livre
    CURSOR cr_next IS
      SELECT nvl(MAX(idmotivo),0)+1 vr_idmotivo
        FROM tbgen_motivo;
    rw_next cr_next%rowtype;

    vr_idmotivo tbgen_motivo.idmotivo%TYPE;
    
  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADMOT'
                              ,pr_action => 'pc_mantem_motivo');

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

    IF trim(pr_dsmotivo) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Descricao deve ser informada!');
      RAISE vr_exc_erro;
    END IF;

    -- Buscar o motivo enviado
    IF pr_idmotivo IS NOT NULL THEN
      OPEN cr_motivo;
      FETCH cr_motivo
       INTO rw_motivo;
      -- Se não encontrou
      IF cr_motivo%notfound THEN
        CLOSE cr_motivo;
        -- Sair com erro
        vr_cdcritic := 0;
        vr_dscritic := gene0007.fn_convert_db_web('Motivo inexistente!');
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_motivo;
      END IF;
    END IF;

    -- Efetuaremos validações de domínio para cada campo:
    IF pr_flgreserva_sistema NOT IN (0,1) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Flag Reservado Sistema inválida!');
      RAISE vr_exc_erro;
    END IF;
    
    IF pr_flgativo NOT IN (0,1) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Flag Ativo inválida!');
      RAISE vr_exc_erro;
    END IF;    

    
    -- Não pode haver outro motivo com mesma descrição
    OPEN cr_outro_motivo;
    FETCH cr_outro_motivo
     INTO rw_outro_motivo;
    IF cr_outro_motivo%found THEN
      CLOSE cr_outro_motivo;
      vr_dscritic := gene0007.fn_convert_db_web('Descricao ja utilizada para o produto');
      RAISE vr_Exc_erro;
    ELSE
      CLOSE cr_outro_motivo;
    END IF;

    -- Após todas as validações, gravar na tabela conforme o tipo da chamada:
    IF pr_idmotivo IS NOT NULL THEN
      BEGIN

        UPDATE tbgen_motivo
           SET dsmotivo = gene0007.fn_convert_web_db(pr_dsmotivo)
              ,cdproduto = pr_cdproduto
              ,flgreserva_sistema = pr_flgreserva_sistema
              ,flgativo = pr_flgativo
			  ,flgtipo  = pr_flgtipo
              ,flgexibe = pr_flgexibe
         WHERE idmotivo = pr_idmotivo;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := gene0007.fn_convert_db_web('Erro na atualiação das informações do Motivo: ')||sqlerrm;
          RAISE vr_exc_erro;
      END;

      IF pr_dsmotivo <> rw_motivo.dsmotivo THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o Motivo campo "Descricao" de ' || rw_motivo.dsmotivo
                                                   || ' para ' || pr_dsmotivo || '.');
      END IF;
      
      IF pr_cdproduto <> rw_motivo.cdproduto THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o Motivo campo "Produto" de ' || rw_motivo.cdproduto
                                                   || ' para ' || pr_cdproduto || '.');
      END IF;
      
      IF pr_flgreserva_sistema <> rw_motivo.flgreserva_sistema THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o Motivo campo "Reservado Sistema" de ' || fn_traduz_flag01(rw_motivo.flgreserva_sistema)
                                                   || ' para ' || fn_traduz_flag01(pr_flgreserva_sistema) || '.');
      END IF;
      
       IF pr_flgativo <> rw_motivo.flgativo THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o Motivo campo "Ativo" de ' || fn_traduz_flag01(rw_motivo.flgativo)
                                                   || ' para ' || fn_traduz_flag01(pr_flgativo) || '.');
      END IF;
      
    ELSE
      BEGIN
		OPEN cr_next;
        FETCH cr_next INTO rw_next;
        CLOSE cr_next;
        
        vr_idmotivo := rw_next.vr_idmotivo;						   

        INSERT INTO tbgen_motivo
                    (idmotivo
                    ,dsmotivo
                    ,cdproduto
                    ,flgreserva_sistema
                    ,flgativo
					,flgtipo
                    ,flgexibe
                    )
              VALUES(vr_idmotivo
                    ,pr_dsmotivo
                    ,pr_cdproduto
                    ,pr_flgreserva_sistema
                    ,pr_flgativo
					,pr_flgtipo
                    ,pr_flgexibe
                    );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na inserção das informações do Motivo: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      
            -- Geração de LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o Motivo com ID ' || vr_idmotivo || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o Motivo campo "Descricao" com ' || pr_dsmotivo || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o Motivo campo "Produto" com ' || pr_cdproduto || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o Motivo campo "Reservado Sistema" com ' || fn_traduz_flag01(pr_flgreserva_sistema) || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o Motivo campo "Ativo" com ' || fn_traduz_flag01(pr_flgativo) || '.');                                                 
                                                 
    END IF;

    -- Gravar no banco
    COMMIT;

    -- Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_mantem_job --> '|| SQLERRM;
      pr_des_erro:= 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_mantem_motivo;
  
END tela_cadmot;
/
