CREATE OR REPLACE PACKAGE CECRED.PCPS0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : PCPS0002
      Sistema  : Rotinas referentes aos arquivos da PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Monitorar e processar os arquivos de retorno da CIP
  PROCEDURE pc_monitorar_ret_PCPS(pr_nmarquiv  IN VARCHAR2
                                 ,pr_dsdsigla  IN crapscb.dsdsigla%TYPE
                                 ,pr_dsdirarq  IN crapscb.dsdirarq%TYPE
                                 ,pr_idarqret  IN BOOLEAN DEFAULT FALSE);
  
  -- Procedure para gerar os arquivos APCS
  PROCEDURE pc_gera_arquivo_APCS (pr_tparquiv   IN crapscb.tparquiv%TYPE);
  
  -- Buscar parametros e processar o arquivo especificado na tabela CRAPSCB
  PROCEDURE pc_proc_arquivo_APCS (pr_tparquiv   IN crapscb.tparquiv%TYPE);
  
  -- Comunicar pendencias de avaliação
  PROCEDURE pc_email_pa_portabilidade;

  -- Agendar os jobs do processo, conforme parametrização
	PROCEDURE pc_agenda_jobs;
  
  -- Processar os arquivos de envio de informações
  PROCEDURE pc_processa_envio_PCPS;
  
  -- Processar os arquivos recebidos com informações da CIP
  PROCEDURE pc_processa_receb_PCPS;
  
  
END PCPS0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0002 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : PCPS0002
      Sistema  : Rotinas referentes aos arquivos da PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário

      Alteracoes:

      22/03/2019 - inc0031490 Inclusão da rotina pc_internal_exception na rotina pc_email_pa_portabilidade para 
                   identificar o ponto do programa que ocasionou o erro; correção do controle do tamanho do corpo do
                   email, de 30 para 30000; correção do controle de existência de e-mail do PA (Carlos)

  ---------------------------------------------------------------------------------------------------------------*/

  --> Declaração geral de exception
  
  
  -- Buscar o numero do ISPB da Central -> Mesmo que o CNPJ Base
  CURSOR cr_crapban IS
    SELECT lpad(ban.nrispbif,8,'0') nrispbif
      FROM crapban ban
     WHERE ban.cdbccxlt = 085; -- AILOS

  -- Variáveis Globais e constantes
  vr_dsarqlg         CONSTANT VARCHAR2(30) := 'pcps_'||to_char(SYSDATE,'RRRRMM')||'.log'; -- Nome do arquivo de log mensal
  vr_dsmasklog       CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
  vr_qtminuto        CONSTANT NUMBER       := (5/24/60); -- Equivalente à 5 minutos
  vr_qtxvsegundos    CONSTANT NUMBER       := (15/24/60/60); -- Equivalente à 15 segundos
  vr_nrispb_emissor           VARCHAR2(8);  -- ISPB Ailos - Valor atribuido via cursor
  vr_nrispb_destina  CONSTANT VARCHAR2(8)  := '02992335'; -- ISPB CIP
  vr_datetimeformat  CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS'; -- Formato campo dataHora
  vr_dateformat      CONSTANT VARCHAR2(10) := 'YYYY-MM-DD';    -- Formato campo data
  vr_dsdominioerro   CONSTANT VARCHAR2(20) := 'ERRO_PCPS_CIP'; -- Dominio padrão para erros PCPS
  vr_dsmotivoreprv   CONSTANT VARCHAR2(30) := 'MOTVREPRVCPORTDDCTSALR';
  vr_dsmotivocancel  CONSTANT VARCHAR2(30) := 'MOTVCANCELTPORTDDCTSALR';
  vr_dsmotivoaceite  CONSTANT VARCHAR2(30) := 'MOTVACTECOMPRIOPORTDDCTSALR';
  vr_dsmotivoconttc  CONSTANT VARCHAR2(30) := 'MOTVCONTTC'; 
  vr_dsmotivoencerr  CONSTANT VARCHAR2(30) := 'MOTVENCRMNTCONTTC'; 
  vr_dsmotivoresrep  CONSTANT VARCHAR2(30) := 'MOTVRESPCONTTCREPVD'; 
  vr_dsmotivoresapv  CONSTANT VARCHAR2(30) := 'MOTVRESPCONTTCAPROVD';
  
  -- Montar o Número de controle do Emissor do arquivo
  FUNCTION fn_gera_NumCtrlEmis(pr_dsdsigla  IN crapscb.dsdsigla%TYPE  -- Sigla do arquivo
                              ,pr_nrseqarq  IN crapscb.nrseqarq%TYPE) -- Sequencia do arquivo
                        RETURN VARCHAR2 IS
  BEGIN
    
    -- Montar código de controle
    RETURN pr_dsdsigla || to_char(SYSDATE,'RRRRMMDD') || LPAD(pr_nrseqarq,5,'0');
    
  END;
  
  -- Montar o Número de controle do Participante para o registro
  FUNCTION fn_gera_NumCtrlPart(pr_cdcooper  IN tbcc_portabilidade_envia.cdcooper%TYPE  
                              ,pr_nrdconta  IN tbcc_portabilidade_envia.nrdconta%TYPE
                              ,pr_nrsolici  IN tbcc_portabilidade_envia.nrsolicitacao%TYPE) 
                        RETURN VARCHAR2 IS
  BEGIN
    
    -- Montar código de controle
    RETURN LPAD(pr_cdcooper, 3,'0')
        || LPAD(pr_nrdconta,12,'0')
        || LPAD(pr_nrsolici, 5,'0');
    
  END;
  
  
  -- Quebrar o Número de controle do Emissor do arquivo, retornando os respectivos valores
  PROCEDURE pc_quebra_NumCtrlPart(pr_nrctpart  IN VARCHAR2
                                 ,pr_cdcooper OUT tbcc_portabilidade_envia.cdcooper%TYPE  
                                 ,pr_nrdconta OUT tbcc_portabilidade_envia.nrdconta%TYPE
                                 ,pr_nrsolici OUT tbcc_portabilidade_envia.nrsolicitacao%TYPE) IS
                                 
  BEGIN
    
    -- Quebrar o numero de controle 
    pr_cdcooper := to_number(SUBSTR(pr_nrctpart, 0, 3));
    pr_nrdconta := to_number(SUBSTR(pr_nrctpart, 4,12));
    pr_nrsolici := to_number(SUBSTR(pr_nrctpart, 16));
      
  END pc_quebra_NumCtrlPart;
  
  PROCEDURE pc_gera_base_xml(pr_dsdsigla  IN crapscb.dsdsigla%TYPE  -- Sigla do arquivo
                            ,pr_nrseqarq  IN crapscb.nrseqarq%TYPE  -- Sequencia do arquivo
                            ,pr_dsxmlarq OUT XMLTYPE                -- Xml do arquivo
                            ,pr_nmarquiv OUT VARCHAR2 ) IS          -- Nome do arquivo
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_base_xml
    --  Sistema  : Procedure para gerar a estrutura padrão dos arquivos CIP
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Gerar a estrutura basica do XML com seus respectivos campos
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- Variáveis
    vr_nmarquiv      VARCHAR2(100);
    vr_NumCtrlEmis   VARCHAR2(20);
  
  BEGIN
    
    -- Montar o nome do arquivo
    -- Padrão: <nome_do_arquivo>_<ISPBIF>_<DataRef>_<SeqIF>
    vr_nmarquiv := pr_dsdsigla         -- nome_do_arquivo
           ||'_'|| vr_nrispb_emissor   -- ISPBIF
           ||'_'|| to_char(SYSDATE,'RRRRMMDD') -- DataRef
           ||'_'|| lpad(pr_nrseqarq,5,'0');    -- SeqIF
    
    -- Retornar o nome do arquivo 
    pr_nmarquiv := vr_nmarquiv;
    
    -- Montar e retornar o número de controle do emissor do arquivo
    vr_NumCtrlEmis := fn_gera_NumCtrlEmis(pr_dsdsigla,pr_nrseqarq);
    
    -- Cria o corpo do XML
    pr_dsxmlarq := XMLTYPE.createXML('<?xml version="1.0"?>'
                                   ||'<APCSDOC xmlns="http://www.cip-bancos.org.br/ARQ/'||pr_dsdsigla||'.xsd"> '
                                   ||'<BCARQ>'
                                   ||'  <NomArq>'||vr_nmarquiv||'</NomArq>'
	                                 ||'  <NumCtrlEmis>'||vr_NumCtrlEmis||'</NumCtrlEmis>'
	                                 ||'  <ISPBEmissor>'||vr_nrispb_emissor||'</ISPBEmissor>'
                                   ||'	<ISPBDestinatario>'||vr_nrispb_destina||'</ISPBDestinatario>'
                                   ||'  <DtHrArq>'||to_char(SYSDATE,vr_datetimeformat)||'</DtHrArq>'
                                   ||'	<DtRef>'||to_char(SYSDATE,vr_dateformat)||'</DtRef>'
                                   ||'</BCARQ>'
                                   ||'<SISARQ>'
                                   ||'</SISARQ>'
                                   ||'</APCSDOC>');
    
  END pc_gera_base_xml;  
  
  
  FUNCTION fn_remove_xmlns(pr_dsxmlarq IN CLOB) RETURN CLOB IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_remove_xmlns
    --  Sistema  : Procedure para remover o atributo xmlns 
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Dezembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a remoção do trecho que define o xmlns do xml, pois causa problemas para carregar
    --             os dados via select.
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- Variáveis
    vr_dsremove  VARCHAR2(1000);
    vr_nrposant  NUMBER;
    vr_nrposdep  NUMBER;
  
  BEGIN
    
    -- Guarda a posição de início do xmlns
    vr_nrposant := INSTR(pr_dsxmlarq,'xmlns=');
    
    -- Guarda a posição do primeiro ">" após o xmlns
    vr_nrposdep := INSTR(pr_dsxmlarq,'>',vr_nrposant);
    
    -- Separar o tag xmlns
    vr_dsremove := SUBSTR(pr_dsxmlarq, vr_nrposant, (vr_nrposdep - vr_nrposant));

    -- Remover e retornar
    RETURN REPLACE(pr_dsxmlarq,vr_dsremove,NULL);

  END fn_remove_xmlns;
  
  PROCEDURE pc_extrai_dados_arq(pr_dsxmlarq  IN CLOB      --> Conteúdo do arquivo (sem o xmlns)
                               ,pr_nmarquiv OUT VARCHAR2  --> Retornar o nome do arquivo
                               ,pr_dtarquiv OUT DATE) IS  --> Retornar a data do arquivo
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_extrai_dados_arq
    --  Sistema  : Procedure para extrair o nome e a data do arquivo
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Dezembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do XML, extraindo o nome e a data do arquivo
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
  
    CURSOR cr_dados IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , to_date(dtarquiv, vr_datetimeformat) dtarquiv
        FROM DATA
           , XMLTABLE(('APCSDOC/BCARQ')
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , dtarquiv  VARCHAR2(50)  PATH 'DtHrArq' );
   
  BEGIN
    
    -- Ler o XML
    OPEN  cr_dados;
    -- Carregar os parametros
    FETCH cr_dados INTO pr_nmarquiv 
                      , pr_dtarquiv;
    -- Fechar o cursor
    CLOSE cr_dados;                 
     
  END pc_extrai_dados_arq;
  
  -- Inserir a listagem de erros que causaram a recusa do registro
  PROCEDURE pc_insere_erro(pr_cdcooper IN tbcc_portabilidade_envia.cdcooper%TYPE
                          ,pr_nrdconta IN tbcc_portabilidade_envia.nrdconta%TYPE
                          ,pr_nrsolici IN tbcc_portabilidade_envia.nrsolicitacao%TYPE
                          ,pr_cddoerro IN VARCHAR2) IS
      
  BEGIN
    -- Inserir os casos de erro registrados
    INSERT INTO tbcc_portabilidade_env_erros(cdcooper
                                            ,nrdconta
                                            ,nrsolicitacao
                                            ,dsdominio_motivo
                                            ,cdmotivo)
                                     VALUES (pr_cdcooper      -- cdcooper
                                            ,pr_nrdconta      -- nrdconta
                                            ,pr_nrsolici      -- nrsolicitacao
                                            ,vr_dsdominioerro -- dsdominio_motivo
                                            ,pr_cddoerro);    -- cdmotivo
  EXCEPTION
    WHEN OTHERS THEN
      -- Não deve dar erro para na inclusão
      NULL;
  END pc_insere_erro;
  
  
  PROCEDURE pc_gera_XML_APCS101(pr_nmarqenv IN     VARCHAR2      --> Nome do arquivo 
                               ,pr_dsxmlarq IN OUT XMLTYPE       --> Conteúdo do arquivo
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_idfimreg    OUT BOOLEAN       --> Indica que finalizou os registros
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_XML_APCS101
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS101 - Instituição Solicita Portabilidade de Salário
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura dos dados e geração do arquivo APCS101
    --
    -- Alteracoes: 
    --  
    --       04/06/2019 - Limpar registros de erros de envios anteriores. (Renato Darosci - Supero)          
    -- 
    --       22/08/2019 - Alterar a rotina para envio de empregador PF. (Renato Darosci - Supero)
    --
    ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar os dados das solicitações que estão para ser enviadas
    CURSOR cr_dados IS 
      SELECT ROWID dsdrowid
           , t.*
        FROM tbcc_portabilidade_envia t
       WHERE t.idsituacao = 1  -- A solicitar
         FOR UPDATE ;   -- Lock dos registros para evitar atualizações no momento de processamento
        
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS101';

    vr_dsxmlarq      xmltype;         --> XML do arquivo
    vr_exc_erro      EXCEPTION;       --> Controle de exceção
    
    vr_dstelefo      VARCHAR2(13); -- Telefone pode ter no max 1 digitos no formato: (00)999000000
    vr_dscritic      VARCHAR2(1000);
    vr_nrctpart      VARCHAR2(20); -- Chave de relacionamento
    vr_nrposxml      NUMBER;
    vr_tppesepr      VARCHAR2(1);  -- Tipo pessoa empregador
    vr_dsdocepr      VARCHAR2(14); -- Documento empregador
    
    -- Procedure para atualizar o registro de solicitação para REPROVADO
    PROCEDURE pc_reprova_solicitacao(pr_dsdrowid  IN VARCHAR2
                                    ,pr_cddoerro  IN VARCHAR2) IS

    BEGIN
      
      UPDATE tbcc_portabilidade_envia  t
         SET t.idsituacao       = 4 -- Reprovada
           , t.dsdominio_motivo = vr_dsdominioerro  -- Chave de dominio do erro
           , t.cdmotivo         = pr_cddoerro       -- Código do erro 
       WHERE ROWID = pr_dsdrowid;

    END;
    
    -- Procedure para atualizar o registro de solicitação para SOLICITADA
    PROCEDURE pc_portabilidade_OK(pr_dsdrowid  IN VARCHAR2) IS
    BEGIN
      
      UPDATE tbcc_portabilidade_envia  t
         SET t.idsituacao       = 2 -- Solicitada
           , t.nmarquivo_envia  = pr_nmarqenv
           , t.nmarquivo_retorno= NULL
           , t.dsdominio_motivo = NULL -- Limpar motivos de erro no reenvio
           , t.cdmotivo         = NULL --
       WHERE ROWID = pr_dsdrowid;
      
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2
                           ,pr_posicao  IN NUMBER DEFAULT 0)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => pr_posicao
                            ,pr_tag_nova => pr_tag_nova
                            ,pr_tag_cont => pr_tag_cont
                            ,pr_des_erro => vr_dscritic);
       
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
    
    END pc_insere_tag;
      
    
  BEGIN
    
    -- Indicar que não foram inclusos dados
    pr_inddados := FALSE;
    
    -- Indica que todos os registros foram processados
    pr_idfimreg := TRUE;
    
    -- Montar a estrutura do XML
    vr_dsxmlarq := pr_dsxmlarq;
    
    -- Inserir tag base do arquivo
    pc_insere_tag(pr_tag_pai  => 'SISARQ'
                 ,pr_tag_nova => vr_dsapcsdoc
                 ,pr_tag_cont => NULL);
    
    
    -- Percorrer todas as solicitações que estão aguardando para serem enviadas
    FOR rg_dados IN cr_dados LOOP
    
      -- Indicar que foram inclusos dados
      pr_inddados := TRUE;
      
      -- Definir o indice da tag
      vr_nrposxml := NVL((vr_nrposxml+1),0);
      
      /******************* INICIO - Grupo Portabilidade Conta Salário *******************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_cont => NULL);
      
      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => lpad(rg_dados.nrispb_destinataria,8,'0') 
                   ,pr_posicao  => vr_nrposxml);
            
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,rg_dados.nrsolicitacao);
      
      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart
                   ,pr_posicao  => vr_nrposxml);
      
      /******************* INICIO - Grupo Cliente *******************/
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                   ,pr_tag_cont => NULL
                   ,pr_posicao  => vr_nrposxml);
      
      -- CPF Cliente
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                   ,pr_tag_nova => 'CPFCli'
                   ,pr_tag_cont => LPAD(rg_dados.nrcpfcgc,11,'0')
                   ,pr_posicao  => vr_nrposxml);
            
      -- Nome Cliente
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                   ,pr_tag_nova => 'NomCli'
                   ,pr_tag_cont => SUBSTR(rg_dados.nmprimtl,1,80)
                   ,pr_posicao  => vr_nrposxml);
      
      -- Se foi informado o telefone
      IF rg_dados.nrddd_telefone IS NOT NULL AND rg_dados.nrtelefone IS NOT NULL THEN
      
        -- Telefone Cliente
        BEGIN
          vr_dstelefo := '('||LPAD(rg_dados.nrddd_telefone,2,'0')||')'||rg_dados.nrtelefone;
        EXCEPTION
          WHEN OTHERS THEN
            -- Indica erro de telefone inválido
            pc_reprova_solicitacao(rg_dados.dsdrowid, 'EGEN0058');
            -- Passa para o próximo registros
            CONTINUE;          
        END;
        
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'TelCli'
                     ,pr_tag_cont => vr_dstelefo
                     ,pr_posicao  => vr_nrposxml);
        
      END IF;
      
      -- Se foi informado e-mail
      IF rg_dados.dsdemail IS NOT NULL THEN
        
        -- E-mail Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'EmailCli'
                     ,pr_tag_cont => rg_dados.dsdemail
                     ,pr_posicao  => vr_nrposxml);
        
      END IF;
      
      -- Código Autenticação do Beneficiário  - Não será enviado
      --pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
      --             ,pr_tag_nova => 'CodAuttcBenfcrio'
      --             ,pr_tag_cont => NULL);
      
      /******************* FIM - Grupo Cliente *******************/
      
      /******************* INICIO - Grupo Participante Folha Pagamento *******************/
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_cont => NULL
                   ,pr_posicao  => vr_nrposxml);
      
      -- ISPB Participante Folha Pagamento
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'ISPBPartFolhaPgto'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0') 
                   ,pr_posicao  => vr_nrposxml);
      
      -- CNPJ Participante Folha Pagamento
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'CNPJPartFolhaPgto'
                   ,pr_tag_cont => LPAD(rg_dados.nrcnpj_banco_folha,14,'0') 
                   ,pr_posicao  => vr_nrposxml);
      
      
      -- Definir e formatar dados do empregador
      IF rg_dados.tppessoa_empregador = 1 THEN
        vr_tppesepr := 'F';
        vr_dsdocepr := LPAD(rg_dados.nrcnpj_empregador,11,'0');
      ELSE 
        vr_tppesepr := 'J';
        vr_dsdocepr := LPAD(rg_dados.nrcnpj_empregador,14,'0');
      END IF;
      
      -- Tipo pessoa empregador
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'TpPessoaEmprdr'
                   ,pr_tag_cont => vr_tppesepr
                   ,pr_posicao  => vr_nrposxml);

      -- CNPJ do Empregador
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'CNPJ_CPFEmprdr'
                   ,pr_tag_cont => vr_dsdocepr
                   ,pr_posicao  => vr_nrposxml);
      
      -- CNPJ Participante Folha Pagamento
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'DenSocEmprdr'
                   ,pr_tag_cont => rg_dados.dsnome_empregador 
                   ,pr_posicao  => vr_nrposxml);
      
      /******************* FIM - Grupo Participante Folha Pagamento *******************/
            
      /******************* INICIO - Grupo Destino *******************/
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_cont => NULL
                   ,pr_posicao  => vr_nrposxml);
      
      -- ISPB Participante Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'ISPBPartDest'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_destinataria,8,'0') 
                   ,pr_posicao  => vr_nrposxml);
      
      -- CNPJ Participante Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'CNPJPartDest'
                   ,pr_tag_cont => LPAD(rg_dados.nrcnpj_destinataria,14,'0') 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Tipo de Conta Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'TpCtDest'
                   ,pr_tag_cont => rg_dados.cdtipo_conta 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Agência Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'AgCliDest'
                   ,pr_tag_cont => rg_dados.cdagencia 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Conta Corrente Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'CtCliDest'
                   ,pr_tag_cont => rg_dados.nrdconta
                   ,pr_posicao  => vr_nrposxml );
      
      -- Conta Pagamento Destino - NÃO SERÁ ENVIADO POIS CONTA É TIPO CC - CONTA CORRENTE
      --pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
      --             ,pr_tag_nova => 'CtPagtoDest'
      --             ,pr_tag_cont => NULL );
      
      /******************* FIM - Grupo Destino *******************/
      /******************* FIM - Grupo Portabilidade Conta Salário *******************/
      
      
      -- Limpar erros de envios anteriores
      DELETE tbcc_portabilidade_env_erros t
       WHERE t.cdcooper      = rg_dados.cdcooper
         AND t.nrdconta      = rg_dados.nrdconta
         AND t.nrsolicitacao = rg_dados.nrsolicitacao;
       
      -- Atualizar registro processado
      pc_portabilidade_OK(rg_dados.dsdrowid);
      
      -- Verificar o tamanho do arquivo que está sendo gerado
      IF length(vr_dsxmlarq.getClobVal()) > 30000 THEN
        -- Indica que ainda faltam registros a processar
        pr_idfimreg := FALSE;
        -- demais registros serão enviados posteriormente
        EXIT;
      END IF;
      
    END LOOP;
        
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_XML_APCS101. ' ||SQLERRM;
  END pc_gera_XML_APCS101;
  
  
  PROCEDURE pc_proc_RET_APCS101(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_RET_APCS101
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS101RET - PCS Informa resposta de solicitação de portabilidade de salário
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação com os seus
    --             respectivos NU Portabilidades.
    --
    -- Alteracoes: 
    --             22/08/2019 - Alteração para adequar a nova estrutura do arquivo e tratar erros nas 
    --                          informações do empregador PF (Renato Darosci - Supero).
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS101';
    
    -- CURSORES
    -- Retorna as aprovações que ocorreram no arquivo
    CURSOR cr_ret_aprova(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrctrlpart
           , nrportdpcs
        FROM DATA 
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_PortddCtSalrActo')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , nrportdpcs  NUMBER       PATH 'NUPortddPCS');
    
    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_ret_reprova(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro 
           , erindpart 
           , nrindpart 
           , nrctrlpart
           , erctrlpart
           , ernrcpfcgc
           , erdsnomcli
           , erdstelefo
           , erdsdemail
           , ernrispbfl
           , ernrcnpjfl
           , ertppesepr
           , ernrdocepr
           , ernmdoempr
           , ernrispbdt
           , ernrcnpjdt
           , ercdtipcta
           , ercdagedst
           , ernrctadst
           , ernrctapgt
        FROM DATA 
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_PortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro   VARCHAR2(20) PATH '@CodErro'
                            , nrindpart   VARCHAR2(50) PATH 'IdentdPartAdmtd'
                            , erindpart   VARCHAR2(20) PATH 'IdentdPartAdmtd/@CodErro' 
                            , nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , erctrlpart  VARCHAR2(20) PATH 'NumCtrlPart/@CodErro'
                            , ergrupocli  VARCHAR2(20) PATH 'Grupo_APCS101RET_Cli/@CodErro'
                            , ernrcpfcgc  VARCHAR2(20) PATH 'Grupo_APCS101RET_Cli/CPFCli/@CodErro'
                            , erdsnomcli  VARCHAR2(20) PATH 'Grupo_APCS101RET_Cli/NomCli/@CodErro'
                            , erdstelefo  VARCHAR2(20) PATH 'Grupo_APCS101RET_Cli/TelCli/@CodErro'
                            , erdsdemail  VARCHAR2(20) PATH 'Grupo_APCS101RET_Cli/EmailCli/@CodErro'
                            , ergrupofol  VARCHAR2(20) PATH 'Grupo_APCS101RET_FolhaPgto/@CodErro'
                            , ernrispbfl  VARCHAR2(20) PATH 'Grupo_APCS101RET_FolhaPgto/ISPBPartFolhaPgto/@CodErro'
                            , ernrcnpjfl  VARCHAR2(20) PATH 'Grupo_APCS101RET_FolhaPgto/CNPJPartFolhaPgto/@CodErro'
                            , ertppesepr  VARCHAR2(20) PATH 'Grupo_APCS101RET_FolhaPgto/TpPessoaEmprdr/@CodErro'
                            , ernrdocepr  VARCHAR2(20) PATH 'Grupo_APCS101RET_FolhaPgto/CNPJ_CPFEmprdr/@CodErro'
                            , ernmdoempr  VARCHAR2(20) PATH 'Grupo_APCS101RET_FolhaPgto/DenSocEmprdr/@CodErro'
                            , ergrupodst  VARCHAR2(20) PATH 'Grupo_APCS101RET_Dest/@CodErro'
                            , ernrispbdt  VARCHAR2(20) PATH 'Grupo_APCS101RET_Dest/ISPBPartDest/@CodErro'
                            , ernrcnpjdt  VARCHAR2(20) PATH 'Grupo_APCS101RET_Dest/CNPJPartDest/@CodErro'
                            , ercdtipcta  VARCHAR2(20) PATH 'Grupo_APCS101RET_Dest/TpCtDest/@CodErro'
                            , ercdagedst  VARCHAR2(20) PATH 'Grupo_APCS101RET_Dest/AgCliDest/@CodErro'
                            , ernrctadst  VARCHAR2(20) PATH 'Grupo_APCS101RET_Dest/CtCliDest/@CodErro'
                            , ernrctapgt  VARCHAR2(20) PATH 'Grupo_APCS101RET_Dest/CtPagtoDest/@CodErro');
    
    -- Retornar o registro correnpondente enviado
    CURSOR cr_prtenvia(pr_cdcooper   tbcc_portabilidade_envia.cdcooper%TYPE
                      ,pr_nrdconta   tbcc_portabilidade_envia.nrdconta%TYPE
                      ,pr_nrsolici   tbcc_portabilidade_envia.nrsolicitacao%TYPE) IS
      SELECT ROWID dsdrowid
           , t.nrnu_portabilidade
        FROM tbcc_portabilidade_envia t
       WHERE t.cdcooper      = pr_cdcooper
         AND t.nrdconta      = pr_nrdconta
         AND t.nrsolicitacao = pr_nrsolici;
    rg_prtenvia   cr_prtenvia%ROWTYPE;
         
    
    -- Variáveis
    vr_cdcooper      tbcc_portabilidade_envia.cdcooper%TYPE;
    vr_nrdconta      tbcc_portabilidade_envia.nrdconta%TYPE;
    vr_nrsolici      tbcc_portabilidade_envia.nrsolicitacao%TYPE;
    vr_dsxmlarq      CLOB;
    
    vr_dsmsglog      VARCHAR2(1000);
    vr_nmarquiv      VARCHAR2(100);
    vr_dtarquiv      DATE;
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todas as aprovações retornadas
    FOR rg_dados IN cr_ret_aprova(vr_dsxmlarq) LOOP
      
      -- Quebrar a chave para encontrar o registro referente a mesma
      pc_quebra_NumCtrlPart(pr_nrctpart => rg_dados.nrctrlpart
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => vr_nrdconta 
                           ,pr_nrsolici => vr_nrsolici);
    
      -- Buscar o registro de envio
      OPEN  cr_prtenvia(vr_cdcooper
                       ,vr_nrdconta
                       ,vr_nrsolici);
      FETCH cr_prtenvia INTO rg_prtenvia;
      
      -- Se não encontrar registro
      IF cr_prtenvia%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtenvia;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Nao encontrado registro de envio para a chave: '||rg_dados.nrctrlpart;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtenvia;
       
      -- Verificar se o registro já possui NUPORTABILIDADE
      IF rg_prtenvia.nrnu_portabilidade IS NOT NULL THEN
          
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Registro de envio ja possui NU Portabilidade: '||rg_dados.nrctrlpart;
            
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
          
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
        
      -- Atualizar o número da portabilidade do registro - APENAS
      UPDATE tbcc_portabilidade_envia t
         SET t.nrnu_portabilidade = rg_dados.nrportdpcs
       WHERE ROWID = rg_prtenvia.dsdrowid;
      
    END LOOP;
  
    -- Percorrer todas as aprovações retornadas
    FOR rg_dados IN cr_ret_reprova(vr_dsxmlarq) LOOP
      
      -- Quebrar a chave para encontrar o registro referente a mesma
      pc_quebra_NumCtrlPart(pr_nrctpart => rg_dados.nrctrlpart
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => vr_nrdconta 
                           ,pr_nrsolici => vr_nrsolici);
    
      -- Buscar o registro de envio
      OPEN  cr_prtenvia(vr_cdcooper
                       ,vr_nrdconta
                       ,vr_nrsolici);
      FETCH cr_prtenvia INTO rg_prtenvia;
      
      -- Se não encontrar registro
      IF cr_prtenvia%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtenvia;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Nao encontrado registro de envio para a chave: '||rg_dados.nrctrlpart;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtenvia;
        
      -- Atualizar o número da portabilidade do registro
      UPDATE tbcc_portabilidade_envia t
         SET t.nrnu_portabilidade = NULL
           , t.idsituacao         = 8 -- Rejeitada (dominio: SIT_PORTAB_SALARIO_ENVIA)
           , t.dtretorno          = vr_dtarquiv
           , t.nmarquivo_retorno  = vr_nmarquiv
           , t.dsdominio_motivo   = vr_dsdominioerro -- Dominio dos erros da CIP
           , t.cdmotivo           = 'EGENPCPS' -- ERRO PADRÃO, SERÁ TRATADO CAMPO A CAMPO NA TABELA FILHA
       WHERE ROWID = rg_prtenvia.dsdrowid;
      
      -- Verifica se encontrou erro
      IF rg_dados.dscoderro IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.dscoderro);
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.erindpart IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.erindpart);
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.erctrlpart IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.erctrlpart);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrcpfcgc IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrcpfcgc);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdsnomcli IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.erdsnomcli);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdstelefo IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.erdstelefo);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdsdemail IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.erdsdemail);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrispbfl IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrispbfl);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrcnpjfl IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrcnpjfl);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ertppesepr IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ertppesepr);
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrdocepr IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrdocepr);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernmdoempr IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernmdoempr);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrispbdt IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrispbdt);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrcnpjdt IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrcnpjdt);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ercdtipcta IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ercdtipcta);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ercdagedst IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ercdagedst);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrctadst IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrctadst);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrctapgt IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrsolici => vr_nrsolici
                      ,pr_cddoerro => rg_dados.ernrctapgt);
      END IF; 
      
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS101. ' ||SQLERRM;
  END pc_proc_RET_APCS101;
  
  
  PROCEDURE pc_proc_ERR_APCS101(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_ERR_APCS101
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS101ERR - PCS Solicitação de portabilidade de salário
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Novembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo com erro, retornando os registros que haviam sido enviados
    --             para a situação de solicitar;
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portabilidade_envia   T
       SET t.dsdominio_motivo = vr_dsdominioerro
         , t.cdmotivo         = vr_cderrret
         , t.idsituacao       = 1 -- Retornar para A Solicitar, pois o erro foi no arquivo 
         , t.nmarquivo_retorno= vr_nmarquiv -- Para identificar a última ocorrencia de problema
     WHERE t.idsituacao       = 2 -- Atualizar apenas as que ainda estão como solicitadas
       AND t.nmarquivo_envia  = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS101. ' ||SQLERRM;
  END pc_proc_ERR_APCS101;
  
  
  PROCEDURE pc_proc_XML_APCS102(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS102
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS102 - PCS Informa solicitação de portabilidade de conta salário
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação conforme situação.
    --
    -- Alteracoes: 
    --             04/04/2019 - Ajustar regra de validação da modalidade da conta, pois estava invertida, reprovando 
    --                          assim as solicitações para contas salário (Renato Darosci - SUPERO - INC0036168)
    --
    --             22/08/2019 - Alterado para ler o novo campo de tipo pessoa empregador e atualizar o nome da tag
    --                          do documento do empregador e tratar os novos campos. (Renato Darosci - Supero)
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS102';
        
    -- CURSOR
    CURSOR cr_dadosret(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nridenti
           , nrnuport
           , nrcpfcgc
           , dsnomcli
           , dstelefo
           , dsdemail
           , nrispbfl
           , nrcnpjfl
           , tppesepr
           , nrdocepr
           , nmdoempr
           , nrispbdt
           , nrcnpjdt
           , cdtipcta
           , cdagedst
           , nrctadst
           , nrctapgt
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_PortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nridenti  NUMBER       PATH 'IdentdPartAdmtd'
                            , nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrcpfcgc  NUMBER       PATH 'Grupo_APCS102_Cli/CPFCli'
                            , dsnomcli  VARCHAR2(80) PATH 'Grupo_APCS102_Cli/NomCli'
                            , dstelefo  VARCHAR2(20) PATH 'Grupo_APCS102_Cli/TelCli'
                            , dsdemail  VARCHAR2(50) PATH 'Grupo_APCS102_Cli/EmailCli'
                            , nrispbfl  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/ISPBPartFolhaPgto'
                            , nrcnpjfl  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/CNPJPartFolhaPgto'
                            , tppesepr  VARCHAR2(5)  PATH 'Grupo_APCS102_FolhaPgto/TpPessoaEmprdr'
                            , nrdocepr  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/CNPJ_CPFEmprdr'
                            , nmdoempr  VARCHAR2(50) PATH 'Grupo_APCS102_FolhaPgto/DenSocEmprdr'
                            , nrispbdt  NUMBER       PATH 'Grupo_APCS102_Dest/ISPBPartDest'
                            , nrcnpjdt  NUMBER       PATH 'Grupo_APCS102_Dest/CNPJPartDest'
                            , cdtipcta  VARCHAR2(5)  PATH 'Grupo_APCS102_Dest/TpCtDest'
                            , cdagedst  NUMBER       PATH 'Grupo_APCS102_Dest/AgCliDest'
                            , nrctadst  NUMBER       PATH 'Grupo_APCS102_Dest/CtCliDest'
                            , nrctapgt  NUMBER       PATH 'Grupo_APCS102_Dest/CtPagtoDest' );
    
    -- Buscar a solicitação da portabilidade 
    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_envia t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Buscar o associado pelo CPF
    CURSOR cr_crapass(pr_nrcpfcgc IN NUMBER) IS
      SELECT t.cdcooper
           , t.nrdconta
           , x.cdmodalidade_tipo cdmodali
           , COUNT(*) OVER (PARTITION BY 1) idqtdreg
        FROM tbcc_tipo_conta x 
           , crapass         t
       WHERE t.inpessoa = x.inpessoa
         AND t.cdtipcta = x.cdtipo_conta
         AND t.nrcpfcgc = pr_nrcpfcgc
         AND t.dtdemiss IS NULL;
     rg_crapass  cr_crapass%ROWTYPE;
    
    -- Buscar registro de CNPJ do empregador
    CURSOR cr_crapttl(pr_cdcooper  crapttl.cdcooper%TYPE
                     ,pr_nrdconta  crapttl.nrdconta%TYPE) IS
      SELECT t.nrcpfemp
           , t.nmextemp
        FROM crapttl t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.idseqttl = 1;
    rg_crapttl   cr_crapttl%ROWTYPE;
    
    -- Variáveis 
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_dscritic     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    vr_tppesepr     NUMBER;
    
    vr_cdcooper     crapass.cdcooper%TYPE;
    vr_nrdconta     crapass.nrdconta%TYPE;
    vr_cdagedst     tbcc_portabilidade_recebe.cdagencia_destinataria%TYPE;
    vr_nrctadst     tbcc_portabilidade_recebe.nrdconta_destinataria%TYPE;
    vr_idsituac     tbcc_portabilidade_recebe.idsituacao%TYPE;
    vr_dsdomrep     tbcc_portabilidade_recebe.dsdominio_motivo%TYPE;
    vr_cdcodrep     tbcc_portabilidade_recebe.cdmotivo%TYPE;
    vr_dtavalia     tbcc_portabilidade_recebe.dtavaliacao%TYPE;
    vr_cdoperad     tbcc_portabilidade_recebe.cdoperador%TYPE;
    vr_exc_erro     EXCEPTION;
    
  BEGIN
    
    -- Remover xmlns
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret(vr_dsxmlarq) LOOP
      
      -- Inicializar as variáveis a cada iteração
      vr_cdcooper := NULL;
      vr_nrdconta := NULL;
      vr_idsituac := 1; -- PENDENTE
      vr_dsdomrep := NULL;
      vr_cdcodrep := NULL; 
      vr_dtavalia := NULL;
      vr_cdoperad := NULL;
      rg_crapttl  := NULL;
    
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosret.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se encontrar a solicitação de portabilidade
      IF cr_portab%FOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS104'
                         || ' --> NU Portabilidade já existe na base de dados: '||rg_dadosret.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
      
      -- Buscar as contas do cooperado conforme o CPF
      OPEN  cr_crapass(rg_dadosret.nrcpfcgc);
      FETCH cr_crapass INTO rg_crapass;
      
      -- Se não encontrar registro
      IF cr_crapass%NOTFOUND THEN
        -- Deve marcar os registro como reprovado
        vr_cdcooper := 3;
        vr_nrdconta := 0;
        vr_idsituac := 3; -- Reprovada
        vr_dsdomrep := vr_dsmotivoreprv;
        vr_cdcodrep := 2; -- CPF do Beneficiário não encontrado
        vr_dtavalia := SYSDATE;
        vr_cdoperad := '1';
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_crapass;
      
      -- Se encontrar mais de um registro ou nenhum registro
      IF NVL(rg_crapass.idqtdreg,0) = 0 OR NVL(rg_crapass.idqtdreg,0) > 1 THEN
        -- Define o registro para a central, para que seja direcionado
        vr_cdcooper := 3;
        vr_nrdconta := 0;
      ELSE -- Se encontrar 1 registro
                      
        -- Definir o número da conta
        vr_cdcooper := rg_crapass.cdcooper;
        vr_nrdconta := rg_crapass.nrdconta;
      
        -- Deve verificar se há registro de CNPJ do empregador
        OPEN  cr_crapttl(vr_cdcooper
                        ,vr_nrdconta);
        FETCH cr_crapttl INTO rg_crapttl;
        
        -- Se não encontrar registros ou não existir CNPJ
        IF cr_crapttl%NOTFOUND OR rg_crapttl.nrcpfemp IS NULL THEN
          -- Deve marcar os registro como reprovado
          vr_idsituac := 3; -- Reprovada
          vr_dsdomrep := vr_dsmotivoreprv;
          vr_cdcodrep := 1; -- CNPJ do empregador não encontrado
          vr_dtavalia := SYSDATE;
          vr_cdoperad := '1';
        END IF;       
        
        -- Fechar o cursor       
        CLOSE cr_crapttl;   
        
        --  Verificar se o CNPJ do empregador e do arquivo são iguais
        IF rg_crapttl.nrcpfemp <> rg_dadosret.nrdocepr  THEN
          -- Deve marcar os registro como reprovado
          vr_idsituac := 3; -- Reprovada
          vr_dsdomrep := vr_dsmotivoreprv;
          vr_cdcodrep := 3; -- CNPJ do empregador não encontrado
          vr_dtavalia := SYSDATE;
          vr_cdoperad := '1';
        END IF;
        
        -- Verificar se o tipo de conta não permite transferencias - Se é conta salário
        IF rg_crapass.cdmodali <> 2 THEN
          -- Deve marcar os registro como reprovado
          vr_idsituac := 3; -- Reprovada
          vr_dsdomrep := vr_dsmotivoreprv;
          vr_cdcodrep := 7; -- Conta informada não permite transferencia
          vr_dtavalia := SYSDATE;
          vr_cdoperad := '1';
        END IF;
        
      END IF;
      
      
      -- Verifica o tipo de conta
      IF rg_dadosret.cdtipcta = 'PG' THEN
        vr_cdagedst := 0;
        vr_nrctadst := rg_dadosret.nrctapgt;
      ELSE 
        vr_cdagedst := rg_dadosret.cdagedst;
        vr_nrctadst := rg_dadosret.nrctadst;
      END IF;
      
      -- Verifica o tipo de pessoa do empregador
      IF rg_dadosret.tppesepr = 'F' THEN
        -- Pessoa Física
        vr_tppesepr := 1;
      ELSE 
        -- Pessoa Jurídica
        vr_tppesepr := 2;
      END IF;
      
      -- INSERIR REGISTRO DE PORTABILIDADE SOLICITADA
      BEGIN
        
        INSERT INTO tbcc_portabilidade_recebe
                          (nrnu_portabilidade
                          ,cdcooper
                          ,nrdconta
                          ,nrcpfcgc
                          ,nmprimtl
                          ,dstelefone
                          ,dsdemail
                          ,nrispb_banco_folha
                          ,nrcnpj_banco_folha
                          ,tppessoa_empregador
                          ,nrcnpj_empregador
                          ,dsnome_empregador
                          ,nrispb_destinataria
                          ,nrcnpj_destinataria
                          ,cdtipo_cta_destinataria
                          ,cdagencia_destinataria
                          ,nrdconta_destinataria
                          ,dtsolicitacao
                          ,idsituacao
                          ,dtavaliacao
                          ,dsdominio_motivo
                          ,cdmotivo
                          ,cdoperador
                          ,nmarquivo_solicitacao)
                   VALUES (rg_dadosret.nrnuport -- nrnu_portabilidade
                          ,vr_cdcooper          -- cdcooper
                          ,vr_nrdconta          -- nrdconta
                          ,rg_dadosret.nrcpfcgc -- nrcpfcgc
                          ,rg_dadosret.dsnomcli -- nmprimtl
                          ,rg_dadosret.dstelefo -- dstelefone
                          ,rg_dadosret.dsdemail -- dsdemail
                          ,rg_dadosret.nrispbfl -- nrispb_banco_folha
                          ,rg_dadosret.nrcnpjfl -- nrcnpj_banco_folha
                          ,vr_tppesepr          -- tppessoa_empregador
                          ,rg_dadosret.nrdocepr -- nrcnpj_empregador
                          ,rg_dadosret.nmdoempr -- dsnome_empregador
                          ,rg_dadosret.nrispbdt -- nrispb_destinataria
                          ,rg_dadosret.nrcnpjdt -- nrcnpj_destinataria
                          ,rg_dadosret.cdtipcta -- cdtipo_cta_destinataria
                          ,vr_cdagedst          -- cdagencia_destinataria
                          ,vr_nrctadst          -- nrdconta_destinataria
                          ,vr_dtarquiv          -- dtsolicitacao
                          ,vr_idsituac          -- idsituacao
                          ,vr_dtavalia          -- dtavaliacao
                          ,vr_dsdomrep          -- dsdominio_motivo
                          ,vr_cdcodrep          -- cdmotivo
                          ,vr_cdoperad          -- cdoperador
                          ,vr_nmarquiv);        -- nmarquivo_solicitacao
                 
      
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta a mensagem de erro
          vr_dscritic := 'Erro ao inserir registro de portabilidade: '||SQLERRM;
          
          -- LOGS DE EXECUCAO
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_proc_xml_APCS102'
                           || ' --> Erro ao incluir registro de portabilidade: '||rg_dadosret.nrnuport;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
          -- Encerra
          RAISE vr_exc_erro;
      END;
    
    END LOOP;
        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS102. ' ||SQLERRM;
  END pc_proc_xml_APCS102;
  
  
  PROCEDURE pc_gera_XML_APCS103(pr_nmarqenv IN     VARCHAR2      --> Nome do arquivo 
                               ,pr_dsxmlarq IN OUT XMLTYPE       --> Conteúdo do arquivo
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_idfimreg    OUT BOOLEAN       --> Indica que finalizou os registros
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_XML_APCS103
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS103 - Instituição Banco da Folha responde solicitação de Portabilidade 
    --                                  Aprovada ou Reprovada.
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Outubro/2018.                   Ultima atualizacao: 03/07/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura dos retornos pendentes e enviar via arquivo
    --
    -- Alteracoes: 03/07/2019 - Tratar INC0013340 (Diego).
    --   
    --             22/08/2019 - Alterar a rotina para envio de empregador PF. (Renato Darosci - Supero)          
    ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar os dados das solicitações que estão para ser enviadas
    CURSOR cr_dados IS 
      SELECT ROWID dsdrowid
           , t.*
        FROM tbcc_portabilidade_recebe t
       WHERE t.idsituacao  IN (2,3)  -- 1 = Pendente / 2 = Aprovada / 3 = Reprovada
         AND t.dtavaliacao IS NOT NULL
         AND t.dtretorno   IS NULL;
    
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS103';

    vr_dsxmlarq      xmltype;         --> XML do arquivo
    vr_exc_erro      EXCEPTION;       --> Controle de exceção
    
    vr_nrctpart      VARCHAR2(20); 
    vr_dscritic      VARCHAR2(1000);
    vr_nrposxml      NUMBER;
    vr_nrposapr      NUMBER;
    vr_nrposrep      NUMBER;
    vr_tppesepr      VARCHAR2(1);  -- Tipo pessoa empregador
    vr_dsdocepr      VARCHAR2(14); -- Documento empregador
    
    
    -- Procedure para atualizar o registro de portabilidade retornado
    PROCEDURE pc_atualiza_retorno(pr_dsdrowid  IN VARCHAR2) IS

      vr_nrnuportab   NUMBER;
    
    BEGIN
      
      UPDATE tbcc_portabilidade_recebe  t
         SET t.dtretorno          = SYSDATE
           , t.nmarquivo_resposta = pr_nmarqenv
       WHERE ROWID = pr_dsdrowid
       RETURNING t.nrnu_portabilidade INTO vr_nrnuportab;
       
      -- Apagar os registros de erros anteriores
      DELETE tbcc_portabilidade_rcb_erros t
       WHERE t.nrnu_portabilidade = vr_nrnuportab; 
       
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2
                           ,pr_posicao  IN NUMBER DEFAULT 0)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => pr_posicao
                            ,pr_tag_nova => pr_tag_nova
                            ,pr_tag_cont => pr_tag_cont
                            ,pr_des_erro => vr_dscritic);
       
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
    
    END pc_insere_tag;
    
  BEGIN
    
    -- Indicar que não foram inclusos dados
    pr_inddados := FALSE;
    
    -- Indica que todos os registros foram processados
    pr_idfimreg := TRUE;
    
    -- Montar a estrutura do XML
    vr_dsxmlarq := pr_dsxmlarq;
    
    -- Inserir tag base do arquivo
    pc_insere_tag(pr_tag_pai  => 'SISARQ'
                 ,pr_tag_nova => vr_dsapcsdoc
                 ,pr_tag_cont => NULL);
    
    -- Percorrer todas as solicitações que estão aguardando para serem enviadas
    FOR rg_dados IN cr_dados LOOP
    
      -- Indicar que foram inclusos dados
      pr_inddados := TRUE;
      
      -- Definir o indice da tag
      vr_nrposxml := NVL((vr_nrposxml+1),0);
      
      /*************** INICIO - Grupo Portabilidade Conta Salário ***************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_cont => NULL);

      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0')
                   ,pr_posicao  => vr_nrposxml );
      
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,0); -- Passar zero, pois não tem contador nos recebidos, o controle é
                                             -- feito através do NU Portabilidade
      
      -- Número de Controle do Participante
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Número único da Portabilidade PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'NUPortddPCS'
                   ,pr_tag_cont => rg_dados.nrnu_portabilidade 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Se a solicitação foi reprovada
      IF rg_dados.idsituacao = 3 THEN
      
        vr_nrposrep := NVL((vr_nrposrep+1),0);
        
        /*************** INICIO - Grupo Reprova Portabilidade Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrRepvd'
                     ,pr_tag_cont => NULL 
                     ,pr_posicao  => vr_nrposxml);
      
        -- Motivo Reprovação Portabilidade de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrRepvd'
                     ,pr_tag_nova => 'MotvReprvcPortddCtSalr'
                     ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0')
                     ,pr_posicao  => vr_nrposrep );
    
        -- Data Cancelamento Portabilidade de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrRepvd'
                     ,pr_tag_nova => 'DtReprvcPortddCtSalr'
                     ,pr_tag_cont => to_char(SYSDATE,vr_dateformat)
                     ,pr_posicao  => vr_nrposrep );
      
        /*************** FIM - Grupo Reprova Portabilidade Conta Salário ***************/
      
      ELSE 
        
        vr_nrposapr := NVL((vr_nrposapr+1),0);
      
        /*************** INICIO - Grupo Aprova Portabilidade Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposxml );
        
      
        /******************* INICIO - Grupo Cliente *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposapr);
      
        -- CPF Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'CPFCli'
                     ,pr_tag_cont => LPAD(rg_dados.nrcpfcgc,11,'0')
                     ,pr_posicao  => vr_nrposapr);
            
        -- Nome Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'NomCli'
                     ,pr_tag_cont => SUBSTR(rg_dados.nmprimtl,1,80)
                     ,pr_posicao  => vr_nrposapr);
      
        -- Se tem informação de telefone
        IF TRIM(rg_dados.dstelefone) IS NOT NULL THEN
          -- Telefone Cliente
          pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                       ,pr_tag_nova => 'TelCli'
                       ,pr_tag_cont => rg_dados.dstelefone
                       ,pr_posicao  => vr_nrposapr);
        END IF;
      
        -- Se tem informação de email
        IF TRIM(rg_dados.dsdemail) IS NOT NULL THEN
          -- E-mail Cliente
          pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                       ,pr_tag_nova => 'EmailCli'
                       ,pr_tag_cont => rg_dados.dsdemail
                       ,pr_posicao  => vr_nrposapr);
        END IF;
      
        /******************* FIM - Grupo Cliente *******************/
      
        /******************* INICIO - Grupo Participante Folha Pagamento *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposapr);
      
        -- ISPB Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'ISPBPartFolhaPgto'
                     ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0')
                     ,pr_posicao  => vr_nrposapr );
        
        -- CNPJ Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'CNPJPartFolhaPgto'
                     ,pr_tag_cont => LPAD(rg_dados.nrcnpj_banco_folha,14,'0')
                     ,pr_posicao  => vr_nrposapr );
        
        -- Definir e formatar dados do empregador
        IF rg_dados.tppessoa_empregador = 1 THEN
          vr_tppesepr := 'F';
          vr_dsdocepr := LPAD(rg_dados.nrcnpj_empregador,11,'0');
        ELSE 
          vr_tppesepr := 'J';
          vr_dsdocepr := LPAD(rg_dados.nrcnpj_empregador,14,'0');
        END IF;
        
        -- Tipo de pessoa Empregador
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'TpPessoaEmprdr'
                     ,pr_tag_cont => vr_tppesepr
                     ,pr_posicao  => vr_nrposapr );

        -- CNPJ do Empregador
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'CNPJ_CPFEmprdr'
                     ,pr_tag_cont => vr_dsdocepr
                     ,pr_posicao  => vr_nrposapr );
        
        -- CNPJ Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'DenSocEmprdr'
                     ,pr_tag_cont => rg_dados.dsnome_empregador
                     ,pr_posicao  => vr_nrposapr );
        
        /******************* FIM - Grupo Participante Folha Pagamento *******************/
            
        /******************* INICIO - Grupo Destino *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposapr);
        
        -- ISPB Participante Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'ISPBPartDest'
                     ,pr_tag_cont => LPAD(rg_dados.nrispb_destinataria,8,'0')
                     ,pr_posicao  => vr_nrposapr );
        
        -- CNPJ Participante Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'CNPJPartDest'
                     ,pr_tag_cont => LPAD(rg_dados.nrcnpj_destinataria,14,'0') 
                     ,pr_posicao  => vr_nrposapr);
        
        -- Tipo de Conta Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'TpCtDest'
                     ,pr_tag_cont => rg_dados.cdtipo_cta_destinataria 
                     ,pr_posicao  => vr_nrposapr);
        
        -- Verifica o tipo de conta
        -- INC0013340 - Na documentacao que recebemos da CIP nao tinha regra
        --              para o arquivo APCS103. Buscamos essa orientacao do layout APCS101:
        --              1. Os campos ‘Agência Destino’ e ‘Conta Corrente Destino’ devem ser obrigatorieamente preenchidos quando
        --              os campos ‘Tipo de Conta’ = ‘CC’, ‘CD’ ou ‘PP’ forem informados .
        --              2. O campo ‘Conta Pagamento Destino’ somente deve ser obrigatoriamente preenchido quando o campo ‘Tipo
        --              de Conta’ = ‘PG’ for informado.   
        IF  rg_dados.cdtipo_cta_destinataria = 'PG' THEN
            -- Conta Pagamento Destino
            pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                         ,pr_tag_nova => 'CtPagtoDest'
                         ,pr_tag_cont => rg_dados.nrdconta_destinataria
                         ,pr_posicao  => vr_nrposapr);
        ELSE
        
            -- Agência Destino
            pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                         ,pr_tag_nova => 'AgCliDest'
                         ,pr_tag_cont => rg_dados.cdagencia_destinataria
                         ,pr_posicao  => vr_nrposapr );
            
            -- Conta Corrente Destino
            pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                         ,pr_tag_nova => 'CtCliDest'
                         ,pr_tag_cont => rg_dados.nrdconta_destinataria
                         ,pr_posicao  => vr_nrposapr);
        END IF;                 
        
        /******************* FIM - Grupo Destino *******************/
        /******************* FIM - Grupo Aprova Portabilidade Conta Salário  *******************/
        
      END IF;
      
      -- Atualizar registro processado
      pc_atualiza_retorno(rg_dados.dsdrowid);
      
      -- Verificar o tamanho do arquivo que está sendo gerado
      IF length(vr_dsxmlarq.getClobVal()) > 30000 THEN
        -- Indica que ainda faltam registros a processar
        pr_idfimreg := FALSE;
        -- demais registros serão enviados posteriormente
        EXIT;
      END IF;
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_XML_APCS103. ' ||SQLERRM;
  END pc_gera_XML_APCS103;
  
  
  PROCEDURE pc_proc_RET_APCS103(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_RET_APCS103
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS103RET - PCPS informa resposta a solicitação de portabilidade de conta salário
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação com os seus
    --             respectivos NU Portabilidades.
    --
    -- Alteracoes: 
    --             22/08/2019 - Alteração para adequar a nova estrutura do arquivo e tratar erros nas 
    --                          informações do empregador PF (Renato Darosci - Supero).
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS103';
    
    -- CURSORES
    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_ret_reprova(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro 
           , erindpart 
           , nrindpart 
           , nrctrlpart
           , erctrlpart
           , nrnuportab
           , ernuportab
           , ernrcpfcgc
           , erdsnomcli
           , erdstelefo
           , erdsdemail
           , ernrispbfl
           , ernrcnpjfl
           , ertppesepr
           , ernrdocepr
           , ernmdoempr
           , ernrispbdt
           , ernrcnpjdt
           , ercdtipcta
           , ercdagedst
           , ernrctadst
           , ernrctapgt
           , ernrmotrep
           , erdtrepprt
        FROM DATA 
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_PortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro   VARCHAR2(20) PATH '@CodErro'
                            , nrindpart   VARCHAR2(50) PATH 'IdentdPartAdmtd'
                            , erindpart   VARCHAR2(20) PATH 'IdentdPartAdmtd/@CodErro' 
                            , nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , erctrlpart  VARCHAR2(20) PATH 'NumCtrlPart/@CodErro'
                            , nrnuportab  NUMBER       PATH 'NUPortddPCS'
                            , ernuportab  VARCHAR2(20) PATH 'NUPortddPCS/@CodErro'
                            , ergrupocli  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Cli/@CodErro'
                            , ernrcpfcgc  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Cli/CPFCli/@CodErro'
                            , erdsnomcli  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Cli/NomCli/@CodErro'
                            , erdstelefo  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Cli/TelCli/@CodErro'
                            , erdsdemail  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Cli/EmailCli/@CodErro'
                            , ergrupofol  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_FolhaPgto/@CodErro'
                            , ernrispbfl  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_FolhaPgto/ISPBPartFolhaPgto/@CodErro'
                            , ernrcnpjfl  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_FolhaPgto/CNPJPartFolhaPgto/@CodErro'
                            , ertppesepr  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_FolhaPgto/TpPessoaEmprdr/@CodErro'
                            , ernrdocepr  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_FolhaPgto/CNPJ_CPFEmprdr/@CodErro'
                            , ernmdoempr  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_FolhaPgto/DenSocEmprdr/@CodErro'
                            , ergrupodst  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Dest/@CodErro'
                            , ernrispbdt  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Dest/ISPBPartDest/@CodErro'
                            , ernrcnpjdt  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Dest/CNPJPartDest/@CodErro'
                            , ercdtipcta  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Dest/TpCtDest/@CodErro'
                            , ercdagedst  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Dest/AgCliDest/@CodErro'
                            , ernrctadst  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Dest/CtCliDest/@CodErro'
                            , ernrctapgt  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrAprovd/Grupo_APCS103RET_Dest/CtPagtoDest/@CodErro'
                            , ernrmotrep  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrReprvd/MotvReprvcPortddCtSalr/@CodErro'
                            , erdtrepprt  VARCHAR2(20) PATH 'Grupo_APCS103RET_PortddCtSalrReprvd/DtReprvcPortddCtSalr/@CodErro');
    
    -- Retornar o registro correspondente enviado
    CURSOR cr_prtreceb(pr_nrnuport   tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE) IS
      SELECT ROWID dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_prtreceb   cr_prtreceb%ROWTYPE;
    
    -- Variáveis
    vr_dsxmlarq   	 CLOB;
    vr_dsmsglog      VARCHAR2(1000);
    vr_nmarquiv      VARCHAR2(100);
    vr_dtarquiv      DATE;
     
    -- Inserir a listagem de erros que causaram a recusa do registro
    PROCEDURE pc_insere_erro(pr_nrnuport IN tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE
                            ,pr_cddoerro IN VARCHAR2) IS
      
    BEGIN
      -- Inserir os casos de erro registrados
      INSERT INTO tbcc_portabilidade_rcb_erros(nrnu_portabilidade
                                              ,dsdominio_motivo
                                              ,cdmotivo)
                                       VALUES (pr_nrnuport      -- nrnu_portabilidade
                                              ,vr_dsdominioerro -- dsdominio_motivo
                                              ,pr_cddoerro);    -- cdmotivo

    EXCEPTION
      WHEN OTHERS THEN
        -- Não deve dar erro para na inclusão
        NULL;
    END pc_insere_erro;
           
  BEGIN
    
    -- Remover o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);  
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_ret_reprova(vr_dsxmlarq) LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtreceb(rg_dados.nrnuportab);
      FETCH cr_prtreceb INTO rg_prtreceb;
      
      -- Se não encontrar registro
      IF cr_prtreceb%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtreceb;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Nao encontrado registro de retorno para o NU Portabilidade: '||rg_dados.nrnuportab;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtreceb;
       
      -- Atualizar o número da portabilidade do registro
      UPDATE tbcc_portabilidade_recebe t
         SET t.idsituacao         = 4 -- Rejeitada (dominio: SIT_PORTAB_SALARIO_RECEBE)
           , t.dtretorno          = vr_dtarquiv
           , t.dtavaliacao        = NULL
           , t.dsdominio_motivo   = vr_dsdominioerro -- Dominio dos erros da CIP
           , t.cdmotivo           = 'EGENPCPS' -- ERRO PADRÃO, SERÁ TRATADO CAMPO A CAMPO NA TABELA FILHA
       WHERE ROWID = rg_prtreceb.dsdrowid;
      
      -- Verifica se encontrou erro
      IF rg_dados.dscoderro IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.dscoderro);
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.erindpart IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.erindpart);
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.erctrlpart IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.erctrlpart);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernuportab IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernuportab);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrcpfcgc IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrcpfcgc);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdsnomcli IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.erdsnomcli);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdstelefo IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.erdstelefo);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdsdemail IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.erdsdemail);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrispbfl IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrispbfl);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrcnpjfl IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrcnpjfl);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ertppesepr IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ertppesepr);
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrdocepr IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrdocepr);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernmdoempr IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernmdoempr);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrispbdt IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrispbdt);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrcnpjdt IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrcnpjdt);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ercdtipcta IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ercdtipcta);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ercdagedst IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ercdagedst);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrctadst IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrctadst);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrctapgt IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrctapgt);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernrmotrep IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.ernrmotrep);
      END IF; 
        
      -- Verifica se encontrou erro
      IF rg_dados.erdtrepprt IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_nrnuport => rg_dados.nrnuportab
                      ,pr_cddoerro => rg_dados.erdtrepprt);
      END IF; 
      
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS103. ' ||SQLERRM;
  END pc_proc_RET_APCS103;
  
  
  PROCEDURE pc_proc_ERR_APCS103(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_ERR_APCS103
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS103ERR - Instituição Banco da Folha responde solicitação de Portabilidade 
    --                                     Aprovada ou Reprovada.
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Dezembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo com erro, retornando os registros que haviam sido enviados
    --             para serem reenviados;
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portabilidade_recebe   T
       SET t.dtretorno           = NULL
         , t.nmarquivo_resposta  = vr_nmarquiv
         -- Não deve mexer no motivo, pois será reenviado
         --, t.dsdominio_motivo    = vr_dsdominioerro
         --, t.cdmotivo            = vr_cderrret
     WHERE t.nmarquivo_resposta  = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS103. ' ||SQLERRM;
  END pc_proc_ERR_APCS103;
  
  
  PROCEDURE pc_proc_XML_APCS104(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS104
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS104 - CIP informa a resposta da Solicitação de Portabilidade Aprovada ou Reprovada
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação conforme situação.
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS104';
        
    -- CURSOR
    CURSOR cr_dadosapr(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , idaprova
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_PortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , idaprova  NUMBER       PATH 'Grupo_APCS104_PortddCtSalrAprovd/Grupo_APCS104_Cli/1' );
    
    CURSOR cr_dadosrep(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , nrmotrep
           , to_date(dtreprova, vr_dateformat) dtreprova
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_PortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrmotrep  NUMBER       PATH 'Grupo_APCS104_PortddCtSalrRepvd/MotvReprvcPortddCtSalr'
                            , dtreprova VARCHAR2(30) PATH 'Grupo_APCS104_PortddCtSalrRepvd/DtReprvcPortddCtSalr' );
    
    -- Buscar a solicitação da portabilidade 
    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_envia t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Variáveis 
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    
  BEGIN
    
    -- Retirar o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo com aprovações
    FOR rg_dadosapr IN cr_dadosapr(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosapr.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS104'
                         || ' --> Não encontrado NU Portabilidade '||rg_dadosapr.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
    
      -- Se o registro está indicando aprovação
      IF NVL(rg_dadosapr.idaprova,0) = 1 THEN
        
        -- Atualiza a solicitação para aprovada 
        UPDATE tbcc_portabilidade_envia t
           SET t.idsituacao        = 3 -- Aprovada
             , t.dsdominio_motivo  = NULL
             , t.cdmotivo          = NULL
             , t.dtretorno         = vr_dtarquiv
             , t.nmarquivo_retorno = vr_nmarquiv
         WHERE ROWID = rg_portab.dsdrowid;
      
      END IF;
    
    END LOOP;
    
    -- Percorrer todos os dados retornados no arquivo com reprovações
    FOR rg_dadosrep IN cr_dadosrep(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosrep.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS104'
                         || ' --> Não encontrado NU Portabilidade '||rg_dadosrep.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
      
      -- Se tem motivo de reprovação 
      IF rg_dadosrep.nrmotrep IS NOT NULL THEN
        -- Atualiza a solicitação para Reprovada
        UPDATE tbcc_portabilidade_envia t
           SET t.idsituacao        = 4 -- Reprovada
             , t.dsdominio_motivo  = vr_dsmotivoreprv
             , t.cdmotivo          = rg_dadosrep.nrmotrep
             , t.dtretorno         = vr_dtarquiv
             , t.nmarquivo_retorno = vr_nmarquiv
         WHERE ROWID = rg_portab.dsdrowid;
      END IF;
      
    END LOOP;
    
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS104. ' ||SQLERRM;
  END pc_proc_xml_APCS104;
  
  
  PROCEDURE pc_gera_XML_APCS105(pr_nmarqenv IN     VARCHAR2      --> Nome do arquivo 
                               ,pr_dsxmlarq IN OUT XMLTYPE       --> XML gerado
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_idfimreg    OUT BOOLEAN       --> Indica que finalizou os registros
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_XML_APCS105
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS105 - Cancelamento de Portabilidade de Conta Salário
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura dos cancelamentos pendentes e enviar via arquivo
    --
    -- Alteracoes: 
    --
    --       04/06/2019 - Limpar registros de erros de envios anteriores. (Renato Darosci - Supero)
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar os dados das solicitações que estão para ser enviadas
    CURSOR cr_dados IS 
      SELECT ROWID dsdrowid
           , t.*
        FROM tbcc_portabilidade_envia t
       WHERE t.idsituacao = 5  -- A cancelar
         FOR UPDATE;   -- Lock dos registros para evitar atualizações no momento de processamento
    
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS105';
    
    vr_dsxmlarq      xmltype;         --> XML do arquivo
    vr_exc_erro      EXCEPTION;       --> Controle de exceção
    
    vr_nrctpart      VARCHAR2(20); -- 
    vr_dscritic      VARCHAR2(1000);
    vr_nrposxml      NUMBER;
    
    -- Procedure para atualizar o registro de portabilidade para Aguardando Cancelamento
    PROCEDURE pc_cancelamento_solicitado(pr_dsdrowid  IN VARCHAR2) IS
    BEGIN
      
      UPDATE tbcc_portabilidade_envia  t
         SET t.idsituacao       = 6 -- Aguardando cancelamento
           , t.nmarquivo_envia  = pr_nmarqenv
       WHERE ROWID = pr_dsdrowid;
       
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2
                           ,pr_posicao  IN NUMBER DEFAULT 0)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => pr_posicao
                            ,pr_tag_nova => pr_tag_nova
                            ,pr_tag_cont => pr_tag_cont
                            ,pr_des_erro => vr_dscritic);
       
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
    
    END pc_insere_tag;
    
  BEGIN
    
    -- Indicar que não foram inclusos dados
    pr_inddados := FALSE;
    
    -- Indica que todos os registros foram processados
    pr_idfimreg := TRUE;
  
    -- Montar a estrutura do XML
    vr_dsxmlarq := pr_dsxmlarq;
    
    -- Inserir tag base do arquivo
    pc_insere_tag(pr_tag_pai  => 'SISARQ'
                 ,pr_tag_nova => vr_dsapcsdoc
                 ,pr_tag_cont => NULL);

    -- Percorrer todas as solicitações que estão aguardando para serem enviadas
    FOR rg_dados IN cr_dados LOOP
    
      -- Indicar que foram inclusos dados
      pr_inddados := TRUE;
      
      -- Definir o indice da tag
      vr_nrposxml := NVL((vr_nrposxml+1),0);
      
      /******************* INICIO - Grupo Portabilidade Conta Salário *******************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_cont => NULL);

      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => lpad(rg_dados.nrispb_destinataria,8,'0') 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,rg_dados.nrsolicitacao);
      
      -- Número de Controle do Participante                                  
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart
                   ,pr_posicao  => vr_nrposxml);
      
      -- Número único da Portabilidade PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'NUPortddPCS'
                   ,pr_tag_cont => rg_dados.nrnu_portabilidade
                   ,pr_posicao  => vr_nrposxml);
      
      -- Motivo Cancelamento Portabilidade de Conta Salário
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'MotvCanceltPortddCtSalr'
                   ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0') 
                   ,pr_posicao  => vr_nrposxml);
    
      -- Data Cancelamento Portabilidade de Conta Salário
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'DtCanceltPortddCtSalr'
                   ,pr_tag_cont => to_char(SYSDATE,vr_dateformat) 
                   ,pr_posicao  => vr_nrposxml);
          
      /******************* FIM - Grupo Portabilidade Conta Salário *******************/
      
      -- Limpar erros de envios anteriores
      DELETE tbcc_portabilidade_env_erros t
       WHERE t.cdcooper      = rg_dados.cdcooper
         AND t.nrdconta      = rg_dados.nrdconta
         AND t.nrsolicitacao = rg_dados.nrsolicitacao;
      
      -- Atualizar registro processado
      pc_cancelamento_solicitado(rg_dados.dsdrowid);
      
      -- Verificar o tamanho do arquivo que está sendo gerado
      IF length(vr_dsxmlarq.getClobVal()) > 30000 THEN
        -- Indica que ainda faltam registros a processar
        pr_idfimreg := FALSE;
        -- demais registros serão enviados posteriormente
        EXIT;
      END IF;
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_XML_APCS105. ' ||SQLERRM;
  END pc_gera_XML_APCS105;
  
  PROCEDURE pc_proc_ERR_APCS105(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_ERR_APCS105
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS105ERR - Instituição Banco da Folha responde solicitação de Cancelamento
    --                                     de Portabilidade 
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Dezembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo com erro, retornando os registros que haviam sido enviados
    --             para rejeitado;
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portabilidade_envia   T
       SET t.idsituacao       = 5 -- A Cancelar
         , t.nmarquivo_envia  = NULL
         , t.dtretorno        = SYSDATE
     WHERE t.nmarquivo_envia  = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS105. ' ||SQLERRM;
  END pc_proc_ERR_APCS105;
  
  PROCEDURE pc_proc_RET_APCS105(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_RET_APCS105
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS105RET - PCPS Informa Resposta a Cancelamento de Portabilidade de Conta Salário
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo de retorno, atualizando registros que apresentaram problemas
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS105';
    
    -- CURSORES
    -- Retorna os cancelamentos aceitos
    CURSOR cr_ret_aceito(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrportdpcs
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_CanceltPortddCtSalrActo')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrportdpcs  NUMBER       PATH 'NUPortddPCS' );
     
    -- Retorna os cancelamentos aceitos
    CURSOR cr_ret_recusa(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro
           , nrportdpcs
           , erindpart 
           , erctrlpart
           , ernuportab
           , erdsmotcan
           , erdtcancel
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_CanceltPortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro  VARCHAR2(20) PATH '@CodErro'
                            , nrportdpcs VARCHAR2(50) PATH 'NUPortddPCS'
                            , erindpart  VARCHAR2(20) PATH 'IdentdPartAdmtd/@CodErro' 
                            , erctrlpart VARCHAR2(20) PATH 'NumCtrlPart/@CodErro'
                            , ernuportab VARCHAR2(20) PATH 'NUPortddPCS/@CodErro'
                            , erdsmotcan VARCHAR2(20) PATH 'MotvCanceltPortddCtSalr/@CodErro'
                            , erdtcancel VARCHAR2(20) PATH 'DtCanceltPortddCtSalr/@CodErro' );
             
    -- Retornar o registro correspondente enviado
    CURSOR cr_prtenvia(pr_nrnuport   tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT ROWID dsdrowid
           , t.cdcooper
           , t.nrdconta
           , t.nrsolicitacao nrsolici
        FROM tbcc_portabilidade_envia t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_prtenvia   cr_prtenvia%ROWTYPE;
    
    -- Variáveis
    vr_dsmsglog      VARCHAR2(1000);

    vr_dsxmlarq      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_dtarquiv      DATE;
        
  BEGIN
    
    -- Remover XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_ret_recusa(vr_dsxmlarq) LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtenvia(rg_dados.nrportdpcs);
      FETCH cr_prtenvia INTO rg_prtenvia;
      
      -- Se não encontrar registro
      IF cr_prtenvia%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtenvia;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Nao encontrado registro de retorno para o NU Portabilidade: '||rg_dados.nrportdpcs;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtenvia;
              
      -- Atualizar a situação do registro para que seja reavaliado e reenviado
      UPDATE tbcc_portabilidade_envia t
         SET t.idsituacao         = 9 -- Rejeitado Cancelamento (dominio: SIT_PORTAB_SALARIO_RECEBE)
           , t.dtretorno          = SYSDATE
           , t.dsdominio_motivo   = vr_dsdominioerro -- Dominio dos erros da CIP
           , t.cdmotivo           = 'EGENPCPS' -- ERRO PADRÃO, SERÁ TRATADO CAMPO A CAMPO NA TABELA FILHA
           , t.nmarquivo_retorno  = vr_nmarquiv
       WHERE ROWID = rg_prtenvia.dsdrowid;
      
      -- Verifica se encontrou erro
      IF rg_dados.erdtcancel IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => rg_prtenvia.cdcooper
                      ,pr_nrdconta => rg_prtenvia.nrdconta
                      ,pr_nrsolici => rg_prtenvia.nrsolici
                      ,pr_cddoerro => rg_dados.erdtcancel);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.dscoderro IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => rg_prtenvia.cdcooper
                      ,pr_nrdconta => rg_prtenvia.nrdconta
                      ,pr_nrsolici => rg_prtenvia.nrsolici
                      ,pr_cddoerro => rg_dados.dscoderro);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erctrlpart IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => rg_prtenvia.cdcooper
                      ,pr_nrdconta => rg_prtenvia.nrdconta
                      ,pr_nrsolici => rg_prtenvia.nrsolici
                      ,pr_cddoerro => rg_dados.erctrlpart);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ernuportab IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => rg_prtenvia.cdcooper
                      ,pr_nrdconta => rg_prtenvia.nrdconta
                      ,pr_nrsolici => rg_prtenvia.nrsolici
                      ,pr_cddoerro => rg_dados.ernuportab);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdsmotcan IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => rg_prtenvia.cdcooper
                      ,pr_nrdconta => rg_prtenvia.nrdconta
                      ,pr_nrsolici => rg_prtenvia.nrsolici
                      ,pr_cddoerro => rg_dados.erdsmotcan);
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdtcancel IS NOT NULL THEN
        -- Inserir registro de erro
        pc_insere_erro(pr_cdcooper => rg_prtenvia.cdcooper
                      ,pr_nrdconta => rg_prtenvia.nrdconta
                      ,pr_nrsolici => rg_prtenvia.nrsolici
                      ,pr_cddoerro => rg_dados.erdtcancel);
      END IF; 
      
    END LOOP;
    
    -- Percorrer todos os aceites
    FOR rg_dados IN cr_ret_aceito(vr_dsxmlarq) LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtenvia(rg_dados.nrportdpcs);
      FETCH cr_prtenvia INTO rg_prtenvia;
      
      -- Se não encontrar registro
      IF cr_prtenvia%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtenvia;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Nao encontrado registro de retorno para o NU Portabilidade: '||rg_dados.nrportdpcs;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtenvia;
               
      -- Atualizar a situação do registro para que seja reavaliado e reenviado
      UPDATE tbcc_portabilidade_envia t
         SET t.idsituacao         = 7 -- Cancelada (dominio: SIT_PORTAB_SALARIO_RECEBE)
           , t.dtretorno          = SYSDATE
           , t.nmarquivo_retorno  = vr_nmarquiv
       WHERE ROWID = rg_prtenvia.dsdrowid;
    
    END LOOP;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS105. ' ||SQLERRM;
  END pc_proc_RET_APCS105;
  
  
  PROCEDURE pc_proc_xml_APCS106(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS106
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS106 - CIP repassa a Solicitação de Cancelamento
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação conforme situação.
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS106';
        
    -- CURSOR
    CURSOR cr_dadosret(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , nrmotcnl
           , to_date(dtcancel, vr_dateformat) dtcancel
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrmotcnl  NUMBER       PATH 'MotvCanceltPortddCtSalr'
                            , dtcancel  VARCHAR2(50) PATH 'DtCanceltPortddCtSalr' );
    
    -- Buscar a solicitação da portabilidade 
    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Variáveis 
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    
  BEGIN
    
    -- Remover o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosret.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS106'
                         || ' --> Não encontrado NU Portabilidade '||rg_dadosret.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
     
      -- Atualiza a solicitação para CANCELADA
      UPDATE tbcc_portabilidade_recebe t
         SET t.idsituacao            = 5 -- Cancelar
           , t.dsdominio_motivo      = vr_dsmotivocancel
           , t.cdmotivo              = rg_dadosret.nrmotcnl
           , t.dtretorno             = rg_dadosret.dtcancel
           , t.nmarquivo_solicitacao = vr_nmarquiv
       WHERE ROWID = rg_portab.dsdrowid;
      
    END LOOP;
        
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS106. ' ||SQLERRM;
  END pc_proc_xml_APCS106;
  
  
    PROCEDURE pc_proc_xml_APCS108(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                                 ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS108
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS108 - Aceite Compulsório por Falta de Resposta
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação conforme situação.
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS108';
        
    -- CURSOR
    CURSOR cr_dadosret(pr_dsxmlarq   CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , nrmotact
           , to_date(dtaceite, vr_dateformat) dtaceite
        FROM DATA
           , XMLTABLE(('APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_ActeComprioPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrmotact  NUMBER       PATH 'MotvActeComprioPortddCtSalr'
                            , dtaceite  VARCHAR2(50) PATH 'DtActeComprioPortddCtSalr' );
    
    -- Buscar a solicitação da portabilidade recebidas
    CURSOR cr_portab_recebe(pr_nrnuport  tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    
    -- Buscar a solicitação da portabilidade enviadas
    CURSOR cr_portab_envia(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_envia t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    
    -- Variáveis 
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_nrnuport     NUMBER;
    vr_dsdrowid     VARCHAR2(100);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    
  BEGIN
    
    -- Retirar o xmlns do xml
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);  
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab_recebe(rg_dadosret.nrnuport);
      FETCH cr_portab_recebe INTO vr_nrnuport, vr_dsdrowid;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab_recebe%NOTFOUND THEN
        vr_nrnuport := NULL;
        vr_dsdrowid := NULL;
        
        -- Buscar o registro pelo código da NU portabilidade
        OPEN  cr_portab_envia(rg_dadosret.nrnuport);
        FETCH cr_portab_envia INTO vr_nrnuport, vr_dsdrowid;
        
        -- Se não encontrar a solicitação de portabilidade
        IF cr_portab_envia%NOTFOUND THEN
          vr_nrnuport := NULL;
          vr_dsdrowid := NULL;
        ELSE
          
          -- Atualiza a solicitação para APROVADA
          UPDATE tbcc_portabilidade_envia t
             SET t.idsituacao        = 3 -- Aprovada
               , t.dsdominio_motivo  = vr_dsmotivoaceite
               , t.cdmotivo          = rg_dadosret.nrmotact
               , t.dtretorno         = vr_dtarquiv
               , t.nmarquivo_retorno = vr_nmarquiv
           WHERE ROWID = vr_dsdrowid;
         
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_portab_envia;
      
      ELSE 
        
        -- Atualiza a solicitação para APROVADA
        UPDATE tbcc_portabilidade_recebe t
           SET t.idsituacao         = 2 -- Aprovada
             , t.dsdominio_motivo   = vr_dsmotivoaceite
             , t.cdmotivo           = rg_dadosret.nrmotact
             , t.dtavaliacao        = rg_dadosret.dtaceite
             , t.dtretorno          = vr_dtarquiv
             , t.nmarquivo_resposta = vr_nmarquiv
         WHERE ROWID = vr_dsdrowid;
       
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab_recebe;
        
      
      -- Se não encontrar a solicitação de portabilidade
      IF vr_nrnuport IS NULL THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS108'
                         || ' --> Não encontrado NU Portabilidade '||rg_dadosret.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
    END LOOP;
        
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS108. ' ||SQLERRM;
  END pc_proc_xml_APCS108;
  PROCEDURE pc_gera_XML_APCS201(pr_nmarqenv IN     VARCHAR2      --> Nome do arquivo 
                               ,pr_dsxmlarq IN OUT XMLTYPE       --> XML gerado
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_idfimreg    OUT BOOLEAN       --> Indica que finalizou os registros
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_XML_APCS201
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS201 - Contestação de Portabilidade de Conta Salário
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura das Contestações pendentes e enviar via arquivo
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar os dados das solicitações que estão para ser enviadas
    CURSOR cr_dados IS 
      SELECT a.ROWID dsdrowid
            ,a.cdcooper
            ,a.nrdconta
            ,a.nrsolicitacao
           , t.nrispb_destinataria 
           , t.nrnu_portabilidade
           , a.cdmotivo cdmotivo_contes
           , a.dtcontestacao
           , a.nmarquivo_envia 
        FROM tbcc_portabilidade_envia t
            ,tbcc_portab_env_contestacao a
       WHERE t.cdcooper      = a.cdcooper
         AND t.nrdconta      = a.nrdconta
         AND t.nrsolicitacao = a.nrsolicitacao
         AND a.idsituacao    = 1  -- A Contestar
         FOR UPDATE;   -- Lock dos registros para evitar atualizações no momento de processamento
    
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS201';
    
    vr_dsxmlarq      xmltype;         --> XML do arquivo
    vr_exc_erro      EXCEPTION;       --> Controle de exceção
    
    vr_nrctpart      VARCHAR2(20); -- 
    vr_dscritic      VARCHAR2(1000);
    vr_nrposxml      NUMBER;
    
    -- Procedure para atualizar o registro de contestação para Aguardando Retorno Contestação
    PROCEDURE pc_envia_contestacao(pr_dsdrowid  IN VARCHAR2) IS
    BEGIN
      
      UPDATE tbcc_portab_env_contestacao  t
         SET t.idsituacao       = 2 -- Contestado
           , t.nmarquivo_envia  = pr_nmarqenv
           , t.dsdominio_motivo_retorno   = null
           , t.cdmotivo_retorno           = NULL
           , t.nmarquivo_retorno          = NULL
       WHERE ROWID = pr_dsdrowid;
       
    END;
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2
                           ,pr_posicao  IN NUMBER DEFAULT 0)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => pr_posicao
                            ,pr_tag_nova => pr_tag_nova
                            ,pr_tag_cont => pr_tag_cont
                            ,pr_des_erro => vr_dscritic);
       
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
    
    END pc_insere_tag;
    
  BEGIN
    
    -- Indicar que não foram inclusos dados
    pr_inddados := FALSE;
    
    -- Indica que todos os registros foram processados
    pr_idfimreg := TRUE;
  
    -- Montar a estrutura do XML
    vr_dsxmlarq := pr_dsxmlarq;
    
    -- Inserir tag base do arquivo
    pc_insere_tag(pr_tag_pai  => 'SISARQ'
                 ,pr_tag_nova => vr_dsapcsdoc
                 ,pr_tag_cont => NULL);

    -- Percorrer todas as solicitações que estão aguardando para serem enviadas
    FOR rg_dados IN cr_dados LOOP

      -- Indicar que foram inclusos dados
      pr_inddados := TRUE;
      
      -- Definir o indice da tag
      vr_nrposxml := NVL((vr_nrposxml+1),0);

      /******************* INICIO - Grupo Contestação Portabilidade Conta Salário *******************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_ConttcPortddCtSalr'
                   ,pr_tag_cont => NULL);

      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ConttcPortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => lpad(rg_dados.nrispb_destinataria,8,'0') 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,rg_dados.nrsolicitacao);
      
      -- Número de Controle do Participante                                  
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ConttcPortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart
                   ,pr_posicao  => vr_nrposxml);
      
      -- Número único da Portabilidade PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ConttcPortddCtSalr'
                   ,pr_tag_nova => 'NUPortddPCS'
                   ,pr_tag_cont => rg_dados.nrnu_portabilidade
                   ,pr_posicao  => vr_nrposxml);
      
      -- Motivo Contestação Portabilidade de Conta Salário
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ConttcPortddCtSalr'
                   ,pr_tag_nova => 'MotvConttc'
                   ,pr_tag_cont => LPAD(rg_dados.cdmotivo_contes,3,'0') 
                   ,pr_posicao  => vr_nrposxml);
    
      -- Data Contestação Portabilidade de Conta Salário
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ConttcPortddCtSalr'
                   ,pr_tag_nova => 'DtConttc'
                   ,pr_tag_cont => to_char(SYSDATE,vr_dateformat) 
                   ,pr_posicao  => vr_nrposxml);
          
      /******************* FIM - Grupo Portabilidade Conta Salário *******************/
      
      -- Atualizar registro processado
      pc_envia_contestacao(rg_dados.dsdrowid);
      
      -- Verificar o tamanho do arquivo que está sendo gerado
      IF length(vr_dsxmlarq.getClobVal()) > 30000 THEN
        -- Indica que ainda faltam registros a processar
        pr_idfimreg := FALSE;
        -- demais registros serão enviados posteriormente
        EXIT;
      END IF;
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_XML_APCS201. ' ||SQLERRM;
  END pc_gera_XML_APCS201;

  ----
 PROCEDURE pc_proc_ERR_APCS201(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                              ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_ERR_APCS201
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS201ERR - Instituição Banco da Folha responde solicitação de Contestação
    --                                     de Portabilidade 
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo com erro, retornando os registros que haviam sido enviados
    --             para rejeitado;
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portab_env_contestacao   T
       SET t.idsituacao                = 1 -- Solicitada
         , t.nmarquivo_retorno         = vr_nmarquiv -- Para identificar a última ocorrencia de problema
         , t.dsdominio_motivo_retorno  = vr_dsdominioerro
         , t.cdmotivo_retorno          = vr_cderrret
     WHERE t.idsituacao                = 2 -- Atualizar apenas as que ainda estão como solicitadas
       AND t.nmarquivo_envia           = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS201. ' ||SQLERRM;
  END pc_proc_ERR_APCS201;

PROCEDURE pc_proc_RET_APCS201(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                             ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
   ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_RET_APCS201
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS201RET - PCPS Informa Resposta a Contestação de Portabilidade de Conta Salário
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo de retorno, atualizando registros que apresentaram problemas
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
     vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS201';
    -- Retorna as contestações aceitas
    CURSOR cr_ret_aprova(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrctrlpart
           , nrportdpcs
           , nrcontcpcs
        FROM DATA 
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_ConttcPortddCtSalrActo')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , nrportdpcs  NUMBER       PATH 'NUPortddPCS'
                            , nrcontcpcs  VARCHAR2(21) PATH 'NUConttcPCS');

    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_ret_reprova(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro 
           , erindpart 
           , nrindpart 
           , nrctrlpart
           , erctrlpart
           , nuportddpcs
           , errportdpcs  
           , nrmotvconttc         
           , ermotvconttc
           , nrdtconttc
           , erdtconttc
        FROM DATA 
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_ConttcPortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro   VARCHAR2(20) PATH '@CodErro'
                            , nrindpart   VARCHAR2(50) PATH 'IdentdPartAdmtd'
                            , erindpart   VARCHAR2(20) PATH 'IdentdPartAdmtd/@CodErro' 
                            , nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , erctrlpart  VARCHAR2(20) PATH 'NumCtrlPart/@CodErro'
                            , nuportddpcs  VARCHAR2(20) PATH 'NUPortddPCS'
                            , errportdpcs  VARCHAR2(20) PATH 'NUPortddPCS/@CodErro'
                            , nrmotvconttc VARCHAR2(20) PATH 'MotvConttc'
                            , ermotvconttc VARCHAR2(20) PATH 'MotvConttc/@CodErro'
                            , nrdtconttc   VARCHAR2(20) PATH 'DtConttc'
                            , erdtconttc   VARCHAR2(20) PATH 'DtConttc/@CodErro');
    -- Retornar o registro correnpondente enviado
    CURSOR cr_prtenvia(pr_cdcooper   tbcc_portab_env_contestacao.cdcooper%TYPE
                      ,pr_nrdconta   tbcc_portab_env_contestacao.nrdconta%TYPE
                      ,pr_nrsolici   tbcc_portab_env_contestacao.nrsolicitacao%TYPE
                      ) IS

      SELECT ROWID dsdrowid
            ,t.dsnu_contestacao
           --, t.nrcontestacao
        FROM tbcc_portab_env_contestacao t
       WHERE t.cdcooper      = pr_cdcooper
         AND t.nrdconta      = pr_nrdconta
         AND t.nrsolicitacao = pr_nrsolici
         AND t.dsnu_contestacao is null;
    rg_prtenvia   cr_prtenvia%ROWTYPE;
         
    
    -- Variáveis
    vr_cdcooper      tbcc_portabilidade_envia.cdcooper%TYPE;
    vr_nrdconta      tbcc_portabilidade_envia.nrdconta%TYPE;
    vr_nrsolici      tbcc_portabilidade_envia.nrsolicitacao%TYPE;
    vr_dsxmlarq      CLOB;
    
    vr_dsmsglog      VARCHAR2(1000);
    vr_nmarquiv      VARCHAR2(100);
    vr_dtarquiv      DATE;
    vr_cdmotivo_retorno   tbcc_portab_env_contestacao.cdmotivo_retorno%TYPE := null;  
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todas as aprovações retornadas
    FOR rg_dados IN cr_ret_aprova(vr_dsxmlarq) LOOP
      
      -- Quebrar a chave para encontrar o registro referente a mesma
      pc_quebra_NumCtrlPart(pr_nrctpart => rg_dados.nrctrlpart
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => vr_nrdconta 
                           ,pr_nrsolici => vr_nrsolici);
    
      -- Buscar o registro de envio
      OPEN  cr_prtenvia(vr_cdcooper
                       ,vr_nrdconta
                       ,vr_nrsolici);
      FETCH cr_prtenvia INTO rg_prtenvia;
      
      -- Se não encontrar registro
      IF cr_prtenvia%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtenvia;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Nao encontrado registro de envio para a chave: '||rg_dados.nrctrlpart;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtenvia;
       
      -- Verificar se o registro já possui NUCONTESTACAO
      IF rg_prtenvia.dsnu_contestacao /*nrcontestacao*/ IS NOT NULL THEN
          
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS201'
                         || ' --> Registro de envio ja possui NU contestação: '||rg_dados.nrctrlpart;
            
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
          
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
        
      -- Atualizar o número da contestação do registro - APENAS
      UPDATE tbcc_portab_env_contestacao t
         SET t.dsnu_contestacao         = rg_dados.nrcontcpcs
       WHERE ROWID = rg_prtenvia.dsdrowid;
      
    END LOOP;
  
    -- Percorrer todas as aprovações retornadas
    FOR rg_dados IN cr_ret_reprova(vr_dsxmlarq) LOOP
      
      -- Limpar motivo do registro anterior
      vr_cdmotivo_retorno := NULL; 
        
      -- Quebrar a chave para encontrar o registro referente a mesma
      pc_quebra_NumCtrlPart(pr_nrctpart => rg_dados.nrctrlpart
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => vr_nrdconta 
                           ,pr_nrsolici => vr_nrsolici);
    
      -- Buscar o registro de envio
      OPEN  cr_prtenvia(vr_cdcooper
                       ,vr_nrdconta
                       ,vr_nrsolici);
      FETCH cr_prtenvia INTO rg_prtenvia;
      
      -- Se não encontrar registro
      IF cr_prtenvia%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtenvia;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS101'
                         || ' --> Nao encontrado registro de envio para a chave: '||rg_dados.nrctrlpart;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtenvia;
        
      -- Verifica se encontrou erro
      IF rg_dados.dscoderro IS NOT NULL THEN
        -- Inserir registro de erro
        vr_cdmotivo_retorno := rg_dados.dscoderro;
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.erindpart IS NOT NULL AND vr_cdmotivo_retorno IS NULL THEN
        -- Inserir registro de erro
        vr_cdmotivo_retorno := rg_dados.erindpart;
      END IF;
      
      -- Verifica se encontrou erro
      IF rg_dados.erctrlpart IS NOT NULL AND vr_cdmotivo_retorno IS NULL THEN
        -- Inserir registro de erro
        vr_cdmotivo_retorno := rg_dados.erctrlpart;
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.errportdpcs IS NOT NULL AND vr_cdmotivo_retorno IS NULL THEN
        -- Inserir registro de erro
        vr_cdmotivo_retorno := rg_dados.errportdpcs;
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.ermotvconttc IS NOT NULL AND vr_cdmotivo_retorno IS NULL THEN
        -- Inserir registro de erro
       vr_cdmotivo_retorno := rg_dados.ermotvconttc;
      END IF; 
      
      -- Verifica se encontrou erro
      IF rg_dados.erdtconttc IS NOT NULL AND vr_cdmotivo_retorno IS NULL THEN
        -- Inserir registro de erro
        vr_cdmotivo_retorno :=  rg_dados.erdtconttc;
      END IF; 

      -- Atualizar o número da contestação do registro
      UPDATE tbcc_portab_env_contestacao t
         SET t.dsnu_contestacao   = null
           , t.idsituacao         = 4 -- Reprovada
           , t.dtretorno          = vr_dtarquiv
           , t.cdmotivo_retorno   = vr_cdmotivo_retorno
           , t.dsdominio_motivo_retorno = vr_dsdominioerro
           , t.nmarquivo_retorno  = vr_nmarquiv
       WHERE ROWID = rg_prtenvia.dsdrowid;

    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS201. ' ||SQLERRM;
  END pc_proc_RET_APCS201;
  ---
  PROCEDURE pc_proc_XML_APCS202(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS202
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS202 - PCS Informa contestação de portabilidade de conta salário
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de contestação conforme situação.
    --
    -- Alteracoes: 
    --             22/08/2019 - Removido os campos não utilizados da consulta (Renato Darosci - Supero). 
    --             
    ---------------------------------------------------------------------------------------------------------------
    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS202';
        
    -- CURSOR
    CURSOR cr_dadosapr(pr_dsxmlarq CLOB) IS
     WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nridenti
           , nrnuport
           , nrconttc   
           , motvcont
           , dtconttc
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_ConttcPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nridenti  NUMBER       PATH 'IdentdPartAdmtd'
                            , nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrconttc  VARCHAR2(21) PATH 'NUConttcPCS'
                            , motvcont  NUMBER       PATH 'MotvConttc'
                            , dtconttc  DATE         PATH 'DtConttc' );

     -- Buscar a solicitação da contestação 
    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;

    rg_portab   cr_portab%ROWTYPE;

    -- Variáveis 
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    vr_dscritic     VARCHAR2(1000);
    vr_exc_erro     EXCEPTION;
    vr_cdoperad     tbcc_portabilidade_recebe.cdoperador%TYPE;

  BEGIN
    -- Retirar o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);

    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo com aprovações
    FOR rg_dadosret IN cr_dadosapr(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU contestação
      OPEN  cr_portab(rg_dadosret.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de contestação
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS202'
                         || ' --> Não encontrado NU Portabilidade '||rg_dadosret.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
        -- INSERIR REGISTRO DE CONTESTAÇÃO SOLICITADA
      vr_cdoperad := '1';
      BEGIN
        
         INSERT INTO tbcc_portab_rec_contestacao 
                          (nrnu_portabilidade       
                          ,dsnu_contestacao         
                          ,idsituacao               
                          ,dtcontestacao            
                          ,dsdominio_motivo         
                          ,cdmotivo                 
                          ,dtretorno                
                          ,dsdominio_motivo_retorno 
                          ,cdmotivo_retorno         
                          ,cdoperador               
                          ,nmarquivo_contestacao    
                          ,nmarquivo_retorno )       
                   VALUES (rg_dadosret.nrnuport -- nrnu_portabilidade
                          ,rg_dadosret.nrconttc
                          ,1 --Pendente                   
                          ,rg_dadosret.dtconttc
                          ,vr_dsmotivoconttc  --dsdominio_motivo
                          ,1 --cdmotivo (Pendente)                
                          ,null --dtretorno                
                          ,null --dsdominio_motivo_retorno 
                          ,null --cdmotivo_retorno         
                          ,vr_cdoperad          -- cdoperador
                          ,vr_nmarquiv          --nmarquivo_contestacao     
                          ,null       );

      
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta a mensagem de erro
          vr_dscritic := 'Erro ao inserir registro de contestação: '||SQLERRM;
          
          -- LOGS DE EXECUCAO
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_proc_xml_APCS102'
                           || ' --> Erro ao incluir registro de contestação: '||rg_dadosret.nrconttc;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
        END;  
      
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS202. ' ||SQLERRM;
  END pc_proc_xml_APCS202;
  --
  PROCEDURE pc_gera_XML_APCS203(pr_nmarqenv IN     VARCHAR2      --> Nome do arquivo 
                               ,pr_dsxmlarq IN OUT XMLTYPE       --> Conteúdo do arquivo
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_idfimreg    OUT BOOLEAN       --> Indica que finalizou os registros
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_XML_APCS203
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS203 - Instituição Banco da Folha responde solicitação de Contestação 
    --                                  Aprovada ou Reprovada.
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura dos retornos pendentes e enviar via arquivo
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar os dados das solicitações que estão para ser enviadas
    CURSOR cr_dados IS 
    SELECT t.ROWID dsdrowid
           , a.cdcooper
           , a.nrdconta
           , a.nrispb_destinataria 
           , t.nrnu_portabilidade
           , a.nrispb_banco_folha
           , t.idsituacao
           , t.dsnu_contestacao
           , t.cdmotivo cdmotivo
        FROM tbcc_portab_rec_contestacao t
            ,tbcc_portabilidade_recebe a
        WHERE a.nrnu_portabilidade = t.nrnu_portabilidade
          AND t.idsituacao  in (2,3)  -- 1 = Pendente / 2 = Aprovada / 3 = Reprovada
          AND t.dtretorno   IS NULL;

    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS203';

    vr_dsxmlarq      xmltype;         --> XML do arquivo
    vr_exc_erro      EXCEPTION;       --> Controle de exceção
    
    vr_nrctpart      VARCHAR2(20); 
    vr_dscritic      VARCHAR2(1000);
    vr_nrposxml      NUMBER;
    vr_nrposapr      NUMBER;
    vr_nrposrep      NUMBER;
    
    -- Procedure para atualizar o registro de contestação retornado
    PROCEDURE pc_atualiza_retorno(pr_dsdrowid  IN VARCHAR2) IS

      vr_nrnuportab   NUMBER;
    
    BEGIN
      
      UPDATE tbcc_portab_rec_contestacao  t
         SET t.dtretorno          = SYSDATE
           , t.nmarquivo_retorno = pr_nmarqenv
      WHERE ROWID = pr_dsdrowid

       RETURNING t.nrnu_portabilidade  INTO vr_nrnuportab;
      
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2
                           ,pr_posicao  IN NUMBER DEFAULT 0)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => pr_posicao
                            ,pr_tag_nova => pr_tag_nova
                            ,pr_tag_cont => pr_tag_cont
                            ,pr_des_erro => vr_dscritic);
       
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
    
    END pc_insere_tag;
    
  BEGIN
    
    -- Indicar que não foram inclusos dados
    pr_inddados := FALSE;
    
    -- Indica que todos os registros foram processados
    pr_idfimreg := TRUE;
    
    -- Montar a estrutura do XML
    vr_dsxmlarq := pr_dsxmlarq;
    
    -- Inserir tag base do arquivo
    pc_insere_tag(pr_tag_pai  => 'SISARQ'
                 ,pr_tag_nova => vr_dsapcsdoc
                 ,pr_tag_cont => NULL);
    
    -- Percorrer todas as solicitações que estão aguardando para serem enviadas
    FOR rg_dados IN cr_dados LOOP
    
      -- Indicar que foram inclusos dados
      pr_inddados := TRUE;
      
      -- Definir o indice da tag
      vr_nrposxml := NVL((vr_nrposxml+1),0);
      
      /*************** INICIO - Grupo Portabilidade Conta Salário ***************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr'
                   ,pr_tag_cont => NULL);

      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0')
                   ,pr_posicao  => vr_nrposxml );
      
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,0); -- Passar zero, pois não tem contador nos recebidos, o controle é
                                             -- feito através do NU Portabilidade
      
      -- Número de Controle do Participante
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Número único da Portabilidade PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr'
                   ,pr_tag_nova => 'NUPortddPCS'
                   ,pr_tag_cont => rg_dados.nrnu_portabilidade 
                   ,pr_posicao  => vr_nrposxml);

      -- Número único da Contestação PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr'
                   ,pr_tag_nova => 'NUConttcPCS'
                   ,pr_tag_cont => rg_dados.dsnu_contestacao 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Se a solicitação foi reprovada
      IF rg_dados.idsituacao = 3 THEN
        
        vr_nrposrep := NVL((vr_nrposrep+1),0);
      
        /*************** INICIO - Grupo Reprova Portabilidade Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_RespConttcRepvd'
                     ,pr_tag_cont => NULL 
                     ,pr_posicao  => vr_nrposxml);
      
        -- Motivo Reprovação Contestação de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcRepvd'
                     ,pr_tag_nova => 'MotvRespConttcRepvd'
                     ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0')
                     ,pr_posicao  => vr_nrposrep );
    
        -- Data Cancelamento Contestação de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcRepvd'
                     ,pr_tag_nova => 'DtRespConttcRepvd'
                     ,pr_tag_cont => to_char(SYSDATE,vr_dateformat)
                     ,pr_posicao  => vr_nrposrep );
      
        /*************** FIM - Grupo Reprova Portabilidade Conta Salário ***************/
      
      ELSE 
        
        vr_nrposapr := NVL((vr_nrposapr+1),0);
      
       /*************** INICIO - Grupo Aprova Contestação Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_RespConttcAprovd'
                     ,pr_tag_cont => NULL 
                     ,pr_posicao  => vr_nrposxml);
      
        -- Motivo Reprovação Contestação de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcAprovd'
                     ,pr_tag_nova => 'MotvRespConttcAprovd'
                     ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0')
                     ,pr_posicao  => vr_nrposapr );
    
        -- Data Cancelamento Contestação de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_RespConttcAprovd'
                     ,pr_tag_nova => 'DtRespConttcAprovd'
                     ,pr_tag_cont => to_char(SYSDATE,vr_dateformat)
                     ,pr_posicao  => vr_nrposapr );
       /******************* FIM - Grupo Aprova Portabilidade Conta Salário  *******************/
        
      END IF;
      
      -- Atualizar registro processado
      pc_atualiza_retorno(rg_dados.dsdrowid);
      
      -- Verificar o tamanho do arquivo que está sendo gerado
      IF length(vr_dsxmlarq.getClobVal()) > 30000 THEN
        -- Indica que ainda faltam registros a processar
        pr_idfimreg := FALSE;
        -- demais registros serão enviados posteriormente
        EXIT;
      END IF;
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_XML_APCS203. ' ||SQLERRM;
  END pc_gera_XML_APCS203;
  --
  PROCEDURE pc_proc_RET_APCS203(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_RET_APCS203
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS201RET - PCPS Informa Resposta a Contestação de Portabilidade de Conta Salário
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo de retorno, atualizando registros que apresentaram problemas
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS203';
    
    -- CURSORES
    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_rejeitada(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro 
           , nrindpart 
           , erindpart 
           , nrctrlpart
           , erctrlpart
           , nrnuportab
           , ernuportab
           , nrnuconttc
           , ernuconttc
           , nrmotrep  
           , ermotvcont
           , erdtconttc
        FROM DATA 
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_RespContccPortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro   VARCHAR2(20) PATH '@CodErro'
                            , nrindpart   VARCHAR2(50) PATH 'IdentdPartAdmtd'
                            , erindpart   VARCHAR2(20) PATH 'IdentdPartAdmtd/@CodErro' 
                            , nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , erctrlpart  VARCHAR2(20) PATH 'NumCtrlPart/@CodErro'
                            , nrnuportab  NUMBER       PATH 'NUPortddPCS'
                            , ernuportab  VARCHAR2(20) PATH 'NUPortddPCS/@CodErro'
                            , nrnuconttc  VARCHAR2(21) PATH 'NUConttcPCS'
                            , ernuconttc  VARCHAR2(20) PATH 'NUConttcPCS/@CodErro'
                            , nrmotrep    NUMBER       PATH 'Grupo_APCS203RET_RespConttcRepvd/MotvRespConttcRepvd'
                            , ermotvcont  NUMBER       PATH 'Grupo_APCS203RET_RespConttcRepvd/MotvRespConttcRepvd/@CodErro'
                            , erdtconttc  VARCHAR2(20) PATH 'Grupo_APCS203RET_RespConttcRepvd/DtRespConttcRepvd/@CodErro');
    
    -- Percorrer os registros de aceite   
    CURSOR cr_aceita(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrindpart 
           , nrctrlpart
           , nrnuportab
           , nrnuconttc
        FROM DATA 
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_RespConttcPortddCtSalrActo')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrindpart   VARCHAR2(50) PATH 'IdentdPartAdmtd'
                            , nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , nrnuportab  NUMBER       PATH 'NUPortddPCS'
                            , nrnuconttc  VARCHAR2(21) PATH 'NUConttcPCS');
    
    -- Retornar o registro correspondente enviado
    CURSOR cr_prtreceb(pr_nrnuport  tbcc_portab_rec_contestacao.nrnu_portabilidade%TYPE
                      ,pr_nrnucont  tbcc_portab_rec_contestacao.dsnu_contestacao%TYPE) IS
      SELECT t.ROWID dsdrowid
           , t.idsituacao 
           , t.dsdominio_motivo_retorno   dsdominio
           , t.cdmotivo_retorno           cdmotivo
           , r.cdcooper
           , r.nrdconta
           , r.idsituacao  idsitport
        FROM tbcc_portabilidade_recebe    r
           , tbcc_portab_rec_contestacao  t
       WHERE r.nrnu_portabilidade = t.nrnu_portabilidade
         AND t.nrnu_portabilidade = pr_nrnuport
         AND t.dsnu_contestacao   = pr_nrnucont;
    rg_prtreceb   cr_prtreceb%ROWTYPE;
    
    -- Variáveis
    vr_dsxmlarq   	 CLOB;
    vr_dsmsglog      VARCHAR2(1000);
    vr_nmarquiv      VARCHAR2(100);
    vr_cdmoterr      VARCHAR2(100);
    vr_nrdrowid      VARCHAR2(100);
    vr_dtarquiv      DATE;
     
  BEGIN
    
    -- Remover o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);  
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_rejeitada(vr_dsxmlarq) LOOP
      -- Limpar erros do registro anterior
      vr_cdmoterr := NULL;
    
      -- Buscar o registro de envio
      OPEN  cr_prtreceb(rg_dados.nrnuportab,rg_dados.nrnuconttc);
      FETCH cr_prtreceb INTO rg_prtreceb;
      
      -- Se não encontrar registro
      IF cr_prtreceb%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtreceb;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS203'
                         || ' --> Nao encontrado registro de retorno para o NU Portabilidade: '||rg_dados.nrnuportab;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
      -- Fechar o cursor
      CLOSE cr_prtreceb;
      
      DECLARE
        vr_achouerro  EXCEPTION;
      BEGIN
        -- Valida a ocorrencia de algum erro
        IF rg_dados.dscoderro IS NOT NULL THEN
          vr_cdmoterr := rg_dados.dscoderro;
          RAISE vr_achouerro;
        END IF;
        
        IF rg_dados.erindpart  IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erindpart;
          RAISE vr_achouerro;
        END IF;
        
        IF rg_dados.erctrlpart IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erctrlpart;
          RAISE vr_achouerro;
        END IF;
        
        IF rg_dados.ernuportab IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernuportab;
          RAISE vr_achouerro;
        END IF;
        
        IF rg_dados.ernuconttc IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernuconttc;
          RAISE vr_achouerro;
        END IF;
        
        IF rg_dados.ermotvcont IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ermotvcont;
          RAISE vr_achouerro;
        END IF;
        
        IF rg_dados.erdtconttc IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erdtconttc;
          RAISE vr_achouerro;
        END IF;
        
      EXCEPTION
        WHEN vr_achouerro THEN
          NULL;
      END;
      
      -- Se tem motivo de erro
      IF vr_cdmoterr IS NOT NULL THEN
        -- Atualiza a solicitação para Rejeitada
        UPDATE tbcc_portab_rec_contestacao t
           SET t.idsituacao               = 5 -- Rejeitada (dominio: SIT_PORTAB_CONTESTACAO_RECEBE)
             , t.dtretorno                = vr_dtarquiv
             , t.dsdominio_motivo_retorno = vr_dsdominioerro -- Dominio dos erros da CIP
             , t.cdmotivo_retorno         = vr_cdmoterr  
             , t.nmarquivo_retorno        = vr_nmarquiv
         WHERE ROWID = rg_prtreceb.dsdrowid;
      END IF; 
      
    END LOOP;
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_aceita(vr_dsxmlarq) LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtreceb(rg_dados.nrnuportab,rg_dados.nrnuconttc);
      FETCH cr_prtreceb INTO rg_prtreceb;
      
      -- Se não encontrar registro
      IF cr_prtreceb%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtreceb;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS203'
                         || ' --> Nao encontrado registro de retorno para o NU Portabilidade: '||rg_dados.nrnuportab;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
      -- Fechar o cursor
      CLOSE cr_prtreceb;
      
      -- Verificar se a resposta enviada foi REPROVAÇÃO
      IF rg_prtreceb.idsituacao = 3 THEN
        
        -- Deve reprovar a portabilidade
        UPDATE tbcc_portabilidade_recebe t
           SET t.idsituacao         = 3 -- Reprova
             , t.dsdominio_motivo   = rg_prtreceb.dsdominio
             , t.cdmotivo           = rg_prtreceb.cdmotivo
         WHERE t.nrnu_portabilidade = rg_dados.nrnuportab;
        
        -- Gerar log de reprovação
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => rg_prtreceb.cdcooper ,
                             pr_cdoperad => '1',
                             pr_dscritic => ' ',
                             pr_dsorigem => '',
                             pr_dstransa => 'Reprovacao por Contestacao de Portabilidade',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => rg_prtreceb.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
    
        -- Gravar o Nu Portabilidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Portabilidade',
                                  pr_dsdadant => to_char(rg_dados.nrnuportab),
                                  pr_dsdadatu => to_char(rg_dados.nrnuportab));
        
        -- Gravar NU Contestação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Contestacao',
                                  pr_dsdadant => rg_dados.nrnuconttc,
                                  pr_dsdadatu => rg_dados.nrnuconttc);
                               
        -- Gravar a Situação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Situacao',
                                  pr_dsdadant => rg_prtreceb.idsitport,
                                  pr_dsdadatu => 3 ); -- Nova situação : Reprovada
        
        -- Gravar o dominio do motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Dominio Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rg_prtreceb.dsdominio ); 
        
        -- Gravar o motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rg_prtreceb.cdmotivo ); 
      END IF;
      
    END LOOP; 
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS203. ' ||SQLERRM;
  END pc_proc_RET_APCS203;
  
  
  PROCEDURE pc_proc_ERR_APCS203(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_ERR_APCS203
    --  Sistema  : Procedure para ler o arquivo: 
    --             APCS203ERR - Instituição Banco da Folha responde solicitação de Portabilidade 
    --                                     Aprovada ou Reprovada.
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo com erro, retornando os registros que haviam sido enviados
    --             para serem reenviados;
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portab_rec_contestacao T
       SET t.dtretorno                 = NULL
         , t.nmarquivo_retorno         = NULL
     WHERE t.nmarquivo_retorno         = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS203. ' ||SQLERRM;
  END pc_proc_ERR_APCS203;
  --
  PROCEDURE pc_proc_XML_APCS204(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS204
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS404 - CIP informa a resposta da Solicitação de Contestação Aprovada ou Reprovada
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de Contestação conforme situação.
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS204';
        
    -- CURSOR
    CURSOR cr_dados(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrconttc
           , nrmotapr
           , to_date(dtaprova, vr_dateformat) dtaprova 
           , nrmotrep
           , to_date(dtreprova, vr_dateformat) dtreprova
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_RespConttcPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrconttc  VARCHAR2(21) PATH 'NUConttcPCS'
                            , nrmotapr  VARCHAR2(20) PATH 'Grupo_APCS204_RespConttcAprovd/MotvRespConttcAprovd'
                            , dtaprova  VARCHAR2(20) PATH 'Grupo_APCS204_RespConttcAprovd/DtRespConttcAprovd'
                            , nrmotrep  NUMBER       PATH 'Grupo_APCS204_RespConttcRepvd/MotvRespConttcRepvd'
                            , dtreprova VARCHAR2(30) PATH 'Grupo_APCS204_RespConttcRepvd/DtRespConttcRepvd'  );
                                                     
    -- Buscar a solicitação da contestação 
    CURSOR cr_portab(pr_nrnuport  tbcc_portab_env_contestacao.dsnu_contestacao%TYPE) IS
      SELECT t.cdcooper
           , t.nrdconta
           , t.nrsolicitacao nrsolici
           , t.nrcontestacao
           , e.nrnu_portabilidade
           , t.idsituacao
           , t.ROWID   dsdrowid
        FROM tbcc_portabilidade_envia    e
           , tbcc_portab_env_contestacao t
       WHERE e.nrsolicitacao             = t.nrsolicitacao
         AND e.nrdconta                  = t.nrdconta
         AND e.cdcooper                  = t.cdcooper
         AND to_char(t.dsnu_contestacao) = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Variáveis 
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    vr_nrdrowid     VARCHAR2(100);
    
  BEGIN
    
    -- Retirar o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo com aprovações
    FOR rg_dados IN cr_dados(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU contestação
      OPEN  cr_portab(rg_dados.nrconttc);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de contestação
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS204'
                         || ' --> Não encontrado NU Contestação '||rg_dados.nrconttc;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
    
      -- Se tem motivo de aprovação -------------------------
      IF  rg_dados.nrmotapr IS NOT NULL THEN
        
        -- Atualiza a contestação para aprovada 
        UPDATE tbcc_portab_env_contestacao t
           SET t.idsituacao               = 3 -- Aprovada
             , t.dsdominio_motivo_retorno = vr_dsmotivoresapv
             , t.cdmotivo_retorno         = rg_dados.nrmotapr
             , t.dtretorno                = vr_dtarquiv
             , t.nmarquivo_retorno        = vr_nmarquiv
         WHERE ROWID = rg_portab.dsdrowid;
      
      END IF;
      
      -- Se tem motivo de reprovação ------------------------
      IF  rg_dados.nrmotrep IS NOT NULL THEN
        
        -- Atualiza a contestação para Reprovada
        UPDATE tbcc_portab_env_contestacao t
           SET t.idsituacao               = 4 -- Reprovada
             , t.dsdominio_motivo_retorno = vr_dsmotivoresrep
             , t.cdmotivo_retorno         = rg_dados.nrmotrep
             , t.dtretorno                = rg_dados.dtreprova --vr_dtarquiv
             , t.nmarquivo_retorno        = vr_nmarquiv
         WHERE ROWID = rg_portab.dsdrowid;
        
        -- Apagar possíveis erros de envio
        DELETE FROM tbcc_portabilidade_env_erros t
         WHERE t.cdcooper      = rg_portab.cdcooper
           AND t.nrdconta      = rg_portab.nrdconta
           AND t.nrsolicitacao = rg_portab.nrsolici;
           
        -- Reprova a portabilidade de salário
        UPDATE tbcc_portabilidade_envia t
           SET t.idsituacao         = 4 -- Reprovada
             , t.dsdominio_motivo   = vr_dsmotivoresrep -- Motivo de contestacao reprovada
             , t.cdmotivo           = rg_dados.nrmotrep
         WHERE t.nrnu_portabilidade = rg_portab.nrnu_portabilidade;
      
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => rg_portab.cdcooper ,
                             pr_cdoperad => '1',
                             pr_dscritic => ' ',
                             pr_dsorigem => '',
                             pr_dstransa => 'Reprovacao por Contestacao de Portabilidade',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => rg_portab.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
    
        -- Gravar o Nu Portabilidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Portabilidade',
                                  pr_dsdadant => to_char(rg_portab.nrnu_portabilidade),
                                  pr_dsdadatu => to_char(rg_portab.nrnu_portabilidade));
                                  
        -- Gravar a Situação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Situacao',
                                  pr_dsdadant => rg_portab.idsituacao,
                                  pr_dsdadatu => 4 ); -- Nova situação : Reprovada
        
        -- Gravar o dominio do motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Dominio Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_dsmotivoresrep ); 
        
        -- Gravar o motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rg_dados.nrmotrep ); 
        
      END IF;
    
    END LOOP;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS204. ' ||SQLERRM;
  END pc_proc_xml_APCS204;
  --
  PROCEDURE pc_proc_XML_APCS205(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                                 ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS208
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS205 - encerramento da contestação da portabilidade salário por falta de
    --                        resposta do Participante Folha de Pagamento.
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Janeiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação conforme situação.
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS205';
        
    -- CURSOR
    CURSOR cr_dadosret(pr_dsxmlarq   CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nridenti
           , nrnuport
           , nrconttc   
           , nrmotact
           , to_date(dtaceite, vr_dateformat) dtaceite
        FROM DATA
           , XMLTABLE(('APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_EncrmntConttcPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nridenti  NUMBER       PATH 'dentdPartAdmtd'
                            , nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrconttc  VARCHAR2(21) PATH 'NUConttcPCS'
                            , nrmotact  NUMBER       PATH 'MotvEncrmntConttc'
                            , dtaceite  VARCHAR2(50) PATH 'DtEncrmntConttc' );

    -- Buscar a solicitação da portabilidade recebidas
    CURSOR cr_portab_recebe(pr_nrnuport  tbcc_portab_rec_contestacao.nrnu_portabilidade%TYPE
                           ,pr_nrconttc  tbcc_portab_rec_contestacao.dsnu_contestacao%TYPE ) IS
      SELECT t.dsnu_contestacao
           , ROWID   dsdrowid
        FROM tbcc_portab_rec_contestacao t
       WHERE t.nrnu_portabilidade = pr_nrnuport
         AND t.dsnu_contestacao   = pr_nrconttc;
    
    -- Buscar a solicitação da contestação enviadas
    CURSOR cr_portab_envia(pr_nrconttc  tbcc_portab_env_contestacao.dsnu_contestacao%TYPE) IS
      SELECT t.dsnu_contestacao
           , ROWID   dsdrowid
        FROM tbcc_portab_env_contestacao t
       WHERE t.dsnu_contestacao  = pr_nrconttc;
    
    -- Variáveis 
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_dsnucont     VARCHAR2(30);
    vr_dsdrowid     VARCHAR2(100);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    
  BEGIN
    
    -- Retirar o xmlns do xml
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);  
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU portabilidade/contestação
      OPEN  cr_portab_recebe(rg_dadosret.nrnuport,rg_dadosret.nrconttc);
      FETCH cr_portab_recebe INTO vr_dsnucont, vr_dsdrowid;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab_recebe%NOTFOUND THEN
        vr_dsnucont := NULL;
        vr_dsdrowid := NULL;
        
        -- Buscar o registro pelo código da NU contestação
        OPEN  cr_portab_envia(rg_dadosret.nrconttc);
        FETCH cr_portab_envia INTO vr_dsnucont, vr_dsdrowid;
        
        -- Se não encontrar a solicitação de portabilidade
        IF cr_portab_envia%NOTFOUND THEN
          vr_dsnucont := NULL;
          vr_dsdrowid := NULL;
        ELSE
          -- Atualiza a solicitação para Fechada
          UPDATE tbcc_portab_env_contestacao t
             SET t.idsituacao        = 5 -- Fechada sem resposta
               , t.dsdominio_motivo  = vr_dsmotivoencerr
               , t.cdmotivo          = rg_dadosret.nrmotact
               , t.dtretorno         = vr_dtarquiv
               , t.nmarquivo_retorno = vr_nmarquiv
           WHERE ROWID = vr_dsdrowid;
         
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_portab_envia;
      
      ELSE 
        
        -- Atualiza a solicitação para Fecha sem resposta
        UPDATE tbcc_portab_rec_contestacao t
           SET t.idsituacao         = 4 -- Fechada sem resposta
             , t.dsdominio_motivo   = vr_dsmotivoencerr 
             , t.cdmotivo           = rg_dadosret.nrmotact
             , t.dtretorno          = vr_dtarquiv
             , t.nmarquivo_retorno  = vr_nmarquiv
         WHERE ROWID = vr_dsdrowid;
       
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab_recebe;
        
      
      -- Se não encontrar a solicitação de portabilidade
      IF vr_dsnucont IS NULL THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS205'
                         || ' --> Não encontrado NU Contestação '||rg_dadosret.nrconttc;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
    END LOOP;
        
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS205. ' ||SQLERRM;
  END pc_proc_xml_APCS205;
  --
  PROCEDURE pc_gera_XML_APCS301(pr_nmarqenv IN     VARCHAR2      --> Nome do arquivo 
                               ,pr_dsxmlarq IN OUT XMLTYPE       --> Conteúdo do arquivo
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_idfimreg    OUT BOOLEAN       --> Indica que finalizou os registros
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_XML_APCS301
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS301 - Destinado ao Participante Folha regularizar as solicitações de portabilidade
    --                                  de conta salário.
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Fevereiro/2019.                   Ultima atualizacao: 03/07/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Gerar arquivo APCS301.
    --
    -- Alteracoes: 03/07/2019 - Tratar INC0013340 (Diego).
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar os dados das solicitações que estão para ser enviadas
    CURSOR cr_dados IS 
      SELECT a.ROWID dsdrowid
          ,a.idaprova_reprova
          ,a.dtregularizacao
          ,a.dsdominio_motivo
          ,a.cdmotivo
          ,t.nrispb_banco_folha
          ,t.cdcooper
          ,t.nrdconta
          ,t.nrnu_portabilidade
          ,t.nrcpfcgc
          ,t.nmprimtl
          ,t.dstelefone
          ,t.dsdemail
          ,t.nrcnpj_banco_folha
          ,t.nrcnpj_empregador
          ,t.dsnome_empregador
          ,t.nrispb_destinataria
          ,t.nrcnpj_destinataria
          ,t.cdtipo_cta_destinataria
          ,t.cdagencia_destinataria
          ,t.nrdconta_destinataria
          ,t.tppessoa_empregador
      FROM tbcc_portabilidade_recebe t
          ,tbcc_portab_regularizacao a
     WHERE t.nrnu_portabilidade      =  a.nrnu_portabilidade
       AND a.idsituacao  = 1  -- 1 = Pendente / 2 = Aprovada / 3 = Reprovada
       AND a.dtretorno IS NULL
       ORDER BY a.dtregularizacao;
    
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS301';

    vr_dsxmlarq      xmltype;         --> XML do arquivo
    vr_exc_erro      EXCEPTION;       --> Controle de exceção
    
    vr_nrctpart      VARCHAR2(20); 
    vr_dscritic      VARCHAR2(1000);
    vr_nrposxml      NUMBER;
    vr_nrposapr      NUMBER;
    vr_nrposrep      NUMBER;
    vr_tppesepr      VARCHAR2(1);  -- Tipo pessoa empregador
    vr_dsdocepr      VARCHAR2(14); -- Documento empregador
    
    -- Procedure para atualizar o registro de portabilidade retornado
    PROCEDURE pc_atualiza_retorno(pr_dsdrowid  IN VARCHAR2) IS

      vr_nrnuportab   NUMBER;
    
    BEGIN
      
      UPDATE tbcc_portab_regularizacao t
         SET t.dtretorno         = NULL
         , t.cdmotivo_retorno    = NULL
         , t.nmarquivo_retorno   = NULL
         , t.idsituacao          = 2
         , t.dsdominio_motivo_retorno = NULL
         , t.nmarquivo_regularizacao = pr_nmarqenv
       WHERE ROWID = pr_dsdrowid
       RETURNING t.nrnu_portabilidade INTO vr_nrnuportab;
       
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2
                           ,pr_posicao  IN NUMBER DEFAULT 0)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => pr_posicao
                            ,pr_tag_nova => pr_tag_nova
                            ,pr_tag_cont => pr_tag_cont
                            ,pr_des_erro => vr_dscritic);
       
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
    
    END pc_insere_tag;
    
  BEGIN
    
    -- Indicar que não foram inclusos dados
    pr_inddados := FALSE;
    
    -- Indica que todos os registros foram processados
    pr_idfimreg := TRUE;
    
    -- Montar a estrutura do XML
    vr_dsxmlarq := pr_dsxmlarq;
    
    -- Inserir tag base do arquivo
    pc_insere_tag(pr_tag_pai  => 'SISARQ'
                 ,pr_tag_nova => vr_dsapcsdoc
                 ,pr_tag_cont => NULL);
    
    -- Percorrer todas as solicitações que estão aguardando para serem enviadas
    FOR rg_dados IN cr_dados LOOP
    
      -- Indicar que foram inclusos dados
      pr_inddados := TRUE;
      
      -- Definir o indice da tag
      vr_nrposxml := NVL((vr_nrposxml+1),0);
      
      /*************** INICIO - Grupo Portabilidade Conta Salário ***************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr'
                   ,pr_tag_cont => NULL);

      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0')
                   ,pr_posicao  => vr_nrposxml );
      
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,0); -- Passar zero, pois não tem contador nos recebidos, o controle é
                                             -- feito através do NU Portabilidade
      
      -- Número de Controle do Participante
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart 
                   ,pr_posicao  => vr_nrposxml);
      
      -- Número único da Portabilidade PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr'
                   ,pr_tag_nova => 'NUPortddPCS'
                   ,pr_tag_cont => rg_dados.nrnu_portabilidade 
                   ,pr_posicao  => vr_nrposxml);
      -- Justificativa da Regularização
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr'
                   ,pr_tag_nova => 'JusttvReglzc'
                   ,pr_tag_cont => '001' -- Fixo - Erro operacional
                   ,pr_posicao  => vr_nrposxml);
      
      -- Se a solicitação foi reprovada
      IF rg_dados.idaprova_reprova = 2 THEN
      
        vr_nrposrep := NVL((vr_nrposrep+1),0);
      
        /*************** INICIO - Grupo Reprova Portabilidade Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_ReglzcRepvd'
                     ,pr_tag_cont => NULL 
                     ,pr_posicao  => vr_nrposxml);
      
        -- Motivo Reprovação Portabilidade de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcRepvd'
                     ,pr_tag_nova => 'MotvReglzcRepvd'
                     ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0')
                     ,pr_posicao  => vr_nrposrep );
    
        -- Data Cancelamento Portabilidade de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcRepvd'
                     ,pr_tag_nova => 'DtReglzcRepvd'
                     ,pr_tag_cont => to_char(SYSDATE,vr_dateformat)
                     ,pr_posicao  => vr_nrposrep );
      
        /*************** FIM - Grupo Reprova Portabilidade Conta Salário ***************/
      
      ELSE 
        
        vr_nrposapr := NVL((vr_nrposapr+1),0);
        
        /*************** INICIO - Grupo Aprova Portabilidade Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_ReglzcAprovd'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposxml );

        -- Motivo Aprova Portabilidade de Conta Salário
       /* pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcAprovd'
                     ,pr_tag_nova => 'MotvReglzcAprovd'
                     ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0')
                     ,pr_posicao  => vr_nrposxml );*/
    
        -- Data Aprova Portabilidade de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcAprovd'
                     ,pr_tag_nova => 'DtReglzcAprovd'
                     ,pr_tag_cont => to_char(SYSDATE,vr_dateformat)
                     ,pr_posicao  => vr_nrposapr );
        
      
        /******************* INICIO - Grupo Cliente *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposapr);
      
        -- CPF Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'CPFCli'
                     ,pr_tag_cont => LPAD(rg_dados.nrcpfcgc,11,'0')
                     ,pr_posicao  => vr_nrposapr);
            
        -- Nome Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'NomCli'
                     ,pr_tag_cont => SUBSTR(rg_dados.nmprimtl,1,80)
                     ,pr_posicao  => vr_nrposapr);
      
        -- Se tem informação de telefone
        IF TRIM(rg_dados.dstelefone) IS NOT NULL THEN
          -- Telefone Cliente
          pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                       ,pr_tag_nova => 'TelCli'
                       ,pr_tag_cont => rg_dados.dstelefone
                       ,pr_posicao  => vr_nrposapr);
        END IF;
      
        -- Se tem informação de email
        IF TRIM(rg_dados.dsdemail) IS NOT NULL THEN
          -- E-mail Cliente
          pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                       ,pr_tag_nova => 'EmailCli'
                       ,pr_tag_cont => rg_dados.dsdemail
                       ,pr_posicao  => vr_nrposapr);
        END IF;

        /******************* FIM - Grupo Cliente *******************/
      
        /******************* INICIO - Grupo Participante Folha Pagamento *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposapr);
      
        -- ISPB Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'ISPBPartFolhaPgto'
                     ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0')
                     ,pr_posicao  => vr_nrposapr );
        
        -- CNPJ Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'CNPJPartFolhaPgto'
                     ,pr_tag_cont => LPAD(rg_dados.nrcnpj_banco_folha,14,'0')
                     ,pr_posicao  => vr_nrposapr );
        
        -- Definir e formatar dados do empregador
        IF rg_dados.tppessoa_empregador = 1 THEN
          vr_tppesepr := 'F';
          vr_dsdocepr := LPAD(rg_dados.nrcnpj_empregador,11,'0');
        ELSE 
          vr_tppesepr := 'J';
          vr_dsdocepr := LPAD(rg_dados.nrcnpj_empregador,14,'0');
        END IF;
        
        
        -- Tipo Pessoa do Empregador
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'TpPessoaEmprdr'
                     ,pr_tag_cont => vr_tppesepr
                     ,pr_posicao  => vr_nrposapr );
        
        -- CNPJ do Empregador
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'CNPJ_CPFEmprdr'
                     ,pr_tag_cont => vr_dsdocepr
                     ,pr_posicao  => vr_nrposapr );
        
        -- CNPJ Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'DenSocEmprdr'
                     ,pr_tag_cont => rg_dados.dsnome_empregador
                     ,pr_posicao  => vr_nrposapr );
        
        /******************* FIM - Grupo Participante Folha Pagamento *******************/
            
        /******************* INICIO - Grupo Destino *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_ReglzcAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_cont => NULL
                     ,pr_posicao  => vr_nrposapr);
        
        -- ISPB Participante Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'ISPBPartDest'
                     ,pr_tag_cont => LPAD(rg_dados.nrispb_destinataria,8,'0')
                     ,pr_posicao  => vr_nrposapr );
        
        -- CNPJ Participante Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'CNPJPartDest'
                     ,pr_tag_cont => LPAD(rg_dados.nrcnpj_destinataria,14,'0') 
                     ,pr_posicao  => vr_nrposapr);
        
        -- Tipo de Conta Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'TpCtDest'
                     ,pr_tag_cont => rg_dados.cdtipo_cta_destinataria 
                     ,pr_posicao  => vr_nrposapr);
        
         -- Verifica o tipo de conta
        -- INC0013340 - Na documentacao que recebemos da CIP nao tinha regra
        --              para o arquivo APCS301. Buscamos essa orientacao do layout APCS101:
        --              1. Os campos ‘Agência Destino’ e ‘Conta Corrente Destino’ devem ser obrigatorieamente preenchidos quando
        --              os campos ‘Tipo de Conta’ = ‘CC’, ‘CD’ ou ‘PP’ forem informados .
        --              2. O campo ‘Conta Pagamento Destino’ somente deve ser obrigatoriamente preenchido quando o campo ‘Tipo
        --              de Conta’ = ‘PG’ for informado.   
        IF  rg_dados.cdtipo_cta_destinataria = 'PG' THEN
            -- Conta Pagamento Destino
            pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                         ,pr_tag_nova => 'CtPagtoDest'
                         ,pr_tag_cont => rg_dados.nrdconta_destinataria
                         ,pr_posicao  => vr_nrposapr);
        ELSE             
        
        -- Agência Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'AgCliDest'
                     ,pr_tag_cont => rg_dados.cdagencia_destinataria
                     ,pr_posicao  => vr_nrposapr );
        
        -- Conta Corrente Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'CtCliDest'
                     ,pr_tag_cont => rg_dados.nrdconta_destinataria
                     ,pr_posicao  => vr_nrposapr);
        
         END IF;            
        
        /******************* FIM - Grupo Destino *******************/
        /******************* FIM - Grupo Aprova Portabilidade Conta Salário  *******************/
        
      END IF;
      
      -- Atualizar registro processado
      pc_atualiza_retorno(rg_dados.dsdrowid);
      
      -- Verificar o tamanho do arquivo que está sendo gerado
      IF length(vr_dsxmlarq.getClobVal()) > 30000 THEN
        -- Indica que ainda faltam registros a processar
        pr_idfimreg := FALSE;
        -- demais registros serão enviados posteriormente
        EXIT;
      END IF;
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_XML_APCS301. ' ||SQLERRM;
  END pc_gera_XML_APCS301;
  --
  PROCEDURE pc_proc_RET_APCS301(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_RET_APCS301
    --  Sistema  : Procedure para ler o arquivo: 
    --                        APCS301RET - PCPS retorna resultado de processamento.
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Fevereiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação com os seus
    --             respectivos NU Portabilidades.
    --
    -- Alteracoes: 
    --             22/08/2019 - Alteração para adequar a nova estrutura do arquivo e tratar erros nas 
    --                          informações do empregador PF (Renato Darosci - Supero).
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS301';
    
    -- CURSORES
    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_ret_erros(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro 
           , erindpart 
           , nrindpart 
           , nrctrlpart
           , erctrlpart
           , nrnuportab
           , dtreglzapv
           , ernuportab
           , ernrcpfcgc
           , erdsnomcli
           , erdstelefo
           , erdsdemail
           , ernrispbfl
           , ernrcnpjfl
           , ertppesepr
           , ernrdocepr
           , ernmdoempr
           , ernrispbdt
           , ernrcnpjdt
           , ercdtipcta
           , ercdagedst
           , ernrctadst
           , ernrctapgt
           , nrmotrepvd
           , ermotvcont
           , erdtconttc
       FROM DATA                                                                        
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_ReglzcPortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro   VARCHAR2(20) PATH '@CodErro'
                            , nrindpart   VARCHAR2(50) PATH 'IdentdPartAdmtd'
                            , erindpart   VARCHAR2(20) PATH 'IdentdPartAdmtd/@CodErro' 
                            , nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , erctrlpart  VARCHAR2(20) PATH 'NumCtrlPart/@CodErro'
                            , nrnuportab  NUMBER       PATH 'NUPortddPCS'
                            , ernuportab  VARCHAR2(20) PATH 'NUPortddPCS/@CodErro'
                            , dtreglzapv  date         PATH 'Grupo_APCS301RET_ReglzcAprovd/DtReglzcAprovd'
                            , ergrupocli  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Cli/@CodErro'
                            , ernrcpfcgc  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Cli/CPFCli/@CodErro'
                            , erdsnomcli  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Cli/NomCli/@CodErro'
                            , erdstelefo  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Cli/TelCli/@CodErro'
                            , erdsdemail  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Cli/EmailCli/@CodErro'
                            , ergrupofol  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_FolhaPgto/@CodErro'
                            , ernrispbfl  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_FolhaPgto/ISPBPartFolhaPgto/@CodErro'
                            , ernrcnpjfl  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_FolhaPgto/CNPJPartFolhaPgto/@CodErro'
                            , ertppesepr  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_FolhaPgto/TpPessoaEmprdr/@CodErro'
                            , ernrdocepr  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_FolhaPgto/CNPJ_CPFEmprdr/@CodErro'
                            , ernmdoempr  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_FolhaPgto/DenSocEmprdr/@CodErro'
                            , ergrupodst  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Dest/@CodErro'
                            , ernrispbdt  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Dest/ISPBPartDest/@CodErro'
                            , ernrcnpjdt  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Dest/CNPJPartDest/@CodErro'
                            , ercdtipcta  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Dest/TpCtDest/@CodErro'
                            , ercdagedst  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Dest/AgCliDest/@CodErro'
                            , ernrctadst  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Dest/CtCliDest/@CodErro'
                            , ernrctapgt  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcAprovd/Grupo_APCS301RET_Dest/CtPagtoDest/@CodErro'
                            , nrmotrepvd  NUMBER       PATH 'Grupo_APCS301RET_ReglzcRepvd/MotvReglzcRepvd'
                            , ermotvcont  NUMBER       PATH 'Grupo_APCS301RET_ReglzcRepvd/MotvReglzcRepvd/@CodErro'
                            , erdtconttc  VARCHAR2(20) PATH 'Grupo_APCS301RET_ReglzcRepvd/DtReglzcRepvd/@CodErro'
                            
                            );
    
    -- Retorna os aceites que ocorreram no arquivo
    CURSOR cr_ret_aceite(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrindpart 
           , nrctrlpart
           , nrnuportab
       FROM DATA                                                                        
          , XMLTABLE(('/APCSDOC/SISARQ/APCS301RET/Grupo_APCS301RET_ReglzcPortddCtSalrActo')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrindpart   VARCHAR2(50) PATH 'IdentdPartAdmtd'
                            , nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , nrnuportab  NUMBER       PATH 'NUPortddPCS');
    
    -- Retornar o registro correspondente enviado
    CURSOR cr_prtreceb(pr_nrnuport   tbcc_portab_regularizacao.nrnu_portabilidade%TYPE) IS
      SELECT a.ROWID dsdrowid
           , a.idsituacao
           , a.idaprova_reprova
           , a.dtregularizacao
           , a.dsdominio_motivo
           , a.cdmotivo
           , t.nrnu_portabilidade
           , t.cdcooper
           , t.nrdconta
           , t.idsituacao idsitsol
        FROM tbcc_portabilidade_recebe t
            ,tbcc_portab_regularizacao a
       WHERE a.dtretorno        IS NULL -- Ainda não teve retorno
         AND a.idsituacao              = 2 -- Comunicada CIP
         AND t.nrnu_portabilidade      = a.nrnu_portabilidade
         AND a.nrnu_portabilidade      = pr_nrnuport;

    rg_prtreceb   cr_prtreceb%ROWTYPE;
    
    -- Variáveis
    vr_dsxmlarq   	 CLOB;
    vr_dsmsglog      VARCHAR2(1000);
    vr_nmarquiv      VARCHAR2(100);
    vr_dtarquiv      DATE;
    vr_cdmoterr      tbcc_portab_regularizacao.cdmotivo_retorno%TYPE := null;
    vr_nrdrowid      VARCHAR2(100);
    
  BEGIN
    
    -- Remover o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);  
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_ret_erros(vr_dsxmlarq) LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtreceb(rg_dados.nrnuportab);
      FETCH cr_prtreceb INTO rg_prtreceb;
      
      -- Se não encontrar registro
      IF cr_prtreceb%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtreceb;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS301'
                         || ' --> Nao encontrado registro de retorno para o NU Portabilidade: '||rg_dados.nrnuportab;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtreceb;
      
      -- Limpar o erro encontrado para o registro anterior
      vr_cdmoterr := NULL;
      
      DECLARE 
        vr_achouerro  EXCEPTION;
      BEGIN
        -- Verifica se encontrou erro
        IF rg_dados.dscoderro IS NOT NULL THEN
          vr_cdmoterr := rg_dados.dscoderro;
          RAISE vr_achouerro;
        END IF;
        
        -- Verifica se encontrou erro
        IF rg_dados.erindpart IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erindpart;
          RAISE vr_achouerro;
        END IF;
        
        -- Verifica se encontrou erro
        IF rg_dados.erctrlpart IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erctrlpart;
          RAISE vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernuportab IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernuportab;
          RAISE vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrcpfcgc IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrcpfcgc;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.erdsnomcli IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erdsnomcli;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.erdstelefo IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erdstelefo;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.erdsdemail IS NOT NULL THEN
          vr_cdmoterr := rg_dados.erdsdemail;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrispbfl IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrispbfl;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrcnpjfl IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrcnpjfl;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ertppesepr IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ertppesepr;
          raise vr_achouerro;
        END IF;
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrdocepr IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrdocepr;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernmdoempr IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernmdoempr;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrispbdt IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrispbdt;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrcnpjdt IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrcnpjdt;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ercdtipcta IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ercdtipcta;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ercdagedst IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ercdagedst;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrctadst IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrctadst;
          raise vr_achouerro;
        END IF; 
        
        -- Verifica se encontrou erro
        IF rg_dados.ernrctapgt IS NOT NULL THEN
          vr_cdmoterr := rg_dados.ernrctapgt;
          raise vr_achouerro;
        END IF; 
        
      EXCEPTION
        WHEN vr_achouerro THEN
          NULL; -- continua o processo normal
      END;
      
      IF vr_cdmoterr IS NOT NULL THEN
      
        -- Atualiza a solicitação para Reprovada
        UPDATE tbcc_portab_regularizacao t
           SET t.idsituacao               = 5 -- Regularizado Rejeitada 
             , t.dtretorno                = vr_dtarquiv
             , t.dsdominio_motivo_retorno = vr_dsdominioerro -- Dominio dos erros da CIP
             , t.cdmotivo_retorno         = vr_cdmoterr 
             , t.nmarquivo_retorno        = vr_nmarquiv
         WHERE ROWID = rg_prtreceb.dsdrowid;
        
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => rg_prtreceb.cdcooper ,
                             pr_cdoperad => '1',
                             pr_dscritic => ' ',
                             pr_dsorigem => '',
                             pr_dstransa => 'Rejeicao de Regularizacao de Portabilidade',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => rg_prtreceb.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
    
        -- Gravar o Nu Portabilidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Portabilidade',
                                  pr_dsdadant => to_char(rg_prtreceb.nrnu_portabilidade),
                                  pr_dsdadatu => to_char(rg_prtreceb.nrnu_portabilidade));
        
        -- Gravar o dominio do motivo de rejeição 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Dominio Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_dsdominioerro ); 
        
        -- Gravar o motivo de rejeição 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_cdmoterr ); 
        
      END IF; -- IF vr_cdmoterr IS NOT NULL
           
    END LOOP;
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_ret_aceite(vr_dsxmlarq) LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtreceb(rg_dados.nrnuportab);
      FETCH cr_prtreceb INTO rg_prtreceb;
      
      -- Se não encontrar registro
      IF cr_prtreceb%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtreceb;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_RET_APCS301'
                         || ' --> Nao encontrado registro de retorno para o NU Portabilidade: '||rg_dados.nrnuportab;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        
          -- Próximo registro
          CONTINUE;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
      END IF;
       
      -- Fechar o cursor
      CLOSE cr_prtreceb;
      
      -- Se foi enviado uma regularização de aprovação
      IF rg_prtreceb.idaprova_reprova = 1 THEN
        -- Atualiza a solicitação 
        UPDATE tbcc_portab_regularizacao t
           SET t.idsituacao                 = 3 -- Regularizado Aprovada
             , t.dtretorno                  = vr_dtarquiv
             , t.dsdominio_motivo_retorno   = NULL
             , t.cdmotivo_retorno           = NULL
             , t.nmarquivo_retorno          = vr_nmarquiv
         WHERE ROWID = rg_prtreceb.dsdrowid;
           
        -- Excluir todos os possiveis registros de erro
        DELETE tbcc_portabilidade_rcb_erros t
         WHERE t.nrnu_portabilidade = rg_prtreceb.nrnu_portabilidade;
           
        -- Atualiza portabilidade de salário para aprovada
        UPDATE tbcc_portabilidade_recebe t
           SET t.idsituacao         = 2 -- Aprovada
             , t.dtavaliacao        = SYSDATE 
             , t.dsdominio_motivo   = NULL
             , t.cdmotivo           = NULL 
         WHERE t.nrnu_portabilidade = rg_prtreceb.nrnu_portabilidade;
        
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => rg_prtreceb.cdcooper ,
                             pr_cdoperad => '1',
                             pr_dscritic => ' ',
                             pr_dsorigem => '',
                             pr_dstransa => 'Aprovacao por Regularizacao de Portabilidade',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => rg_prtreceb.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
    
        -- Gravar o Nu Portabilidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Portabilidade',
                                  pr_dsdadant => to_char(rg_prtreceb.nrnu_portabilidade),
                                  pr_dsdadatu => to_char(rg_prtreceb.nrnu_portabilidade));
                                  
        -- Gravar a Situação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Situacao',
                                  pr_dsdadant => rg_prtreceb.idsitsol,
                                  pr_dsdadatu => 2 ); -- Nova situação : Aprovada
        
        -- Gravar o dominio do motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Dominio Motivo',
                                  pr_dsdadant => rg_prtreceb.dsdominio_motivo,
                                  pr_dsdadatu => ' ' ); 
        
        -- Gravar o motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Motivo',
                                  pr_dsdadant => rg_prtreceb.cdmotivo,
                                  pr_dsdadatu => ' ' ); 
        
      ELSE
          
        -- Atualiza a solicitação 
        UPDATE tbcc_portab_regularizacao t
           SET t.idsituacao                 = 4 -- Regularizado Reprovada
             , t.dtretorno                  = vr_dtarquiv
             , t.dsdominio_motivo_retorno   = NULL
             , t.cdmotivo_retorno           = NULL
             , t.nmarquivo_retorno          = vr_nmarquiv
         WHERE ROWID = rg_prtreceb.dsdrowid;
           
        -- Excluir todos os possiveis registros de erro
        DELETE tbcc_portabilidade_rcb_erros t
         WHERE t.nrnu_portabilidade = rg_prtreceb.nrnu_portabilidade;
           
        -- Atualiza portabilidade de salário para reprovada
        UPDATE tbcc_portabilidade_recebe t
           SET t.idsituacao         = 3 -- Reprovada
             , t.dtavaliacao        = SYSDATE 
             , t.dsdominio_motivo   = rg_prtreceb.dsdominio_motivo
             , t.cdmotivo           = rg_prtreceb.cdmotivo
         WHERE t.nrnu_portabilidade = rg_prtreceb.nrnu_portabilidade;
       
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => rg_prtreceb.cdcooper ,
                             pr_cdoperad => '1',
                             pr_dscritic => ' ',
                             pr_dsorigem => '',
                             pr_dstransa => 'Reprovacao por Regularizacao de Portabilidade',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => rg_prtreceb.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
    
        -- Gravar o Nu Portabilidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Portabilidade',
                                  pr_dsdadant => to_char(rg_prtreceb.nrnu_portabilidade),
                                  pr_dsdadatu => to_char(rg_prtreceb.nrnu_portabilidade));
                                  
        -- Gravar a Situação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Situacao',
                                  pr_dsdadant => rg_prtreceb.idsitsol,
                                  pr_dsdadatu => 3 ); -- Nova situação : Reprovada
        
        -- Gravar o dominio do motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Dominio Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rg_prtreceb.dsdominio_motivo ); 
        
        -- Gravar o motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rg_prtreceb.cdmotivo ); 
       
      END IF; -- IF rg_prtreceb.idaprova_reprova = 1
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS301. ' ||SQLERRM;
  END pc_proc_RET_APCS301;
  --
  PROCEDURE pc_proc_ERR_APCS301(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_ERR_APCS301
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS301ERR - Instituição Banco da Folha responde regularizar as solicitações de portabilidade
    --                                  de conta salário.
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Fevereiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura dos retornos pendentes e enviar via arquivo
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portab_regularizacao   T
       SET t.nmarquivo_retorno        = vr_nmarquiv
         , t.idsituacao               = 1
         , t.dsdominio_motivo_retorno = vr_dsdominioerro
         , t.cdmotivo_retorno         = vr_cderrret
     WHERE t.idsituacao               = 2 
       AND t.nmarquivo_regularizacao  = vr_nmarqenv;
       
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS301. ' ||SQLERRM;
  END pc_proc_ERR_APCS301;
  --
  PROCEDURE pc_proc_XML_APCS302(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_xml_APCS302
    --  Sistema  : Procedure para ler o arquivo: 
    --             APCS302 - Destinado ao PCPS informar e regularizar a situação da portabilidade aos Participantes envolvidos
    --  Sigla    : PCPS
    --  Autor    : Gilberto - Supero
    --  Data     : Fevereiro/2019.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Realizar a leitura do arquivo atualizando os registros de solicitação conforme situação.
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS302';
        
    -- CURSOR
    CURSOR cr_dadosapr(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , idaprova
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , idaprova  NUMBER       PATH 'Grupo_APCS302_ReglzcAprovd/Grupo_APCS302_Cli/1' );
    
    CURSOR cr_dadosrep(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , nrmotrep
           , to_date(dtreprova, vr_dateformat) dtreprova
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_ReglzcPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrmotrep  NUMBER       PATH 'Grupo_APCS302_ReglzcRepvd/MotvReglzcRepvd'
                            , dtreprova VARCHAR2(30) PATH 'Grupo_APCS302_ReglzcRepvd/DtReglzcRepvd' );
    
    -- Buscar a solicitação da portabilidade 
    CURSOR cr_portab(pr_nrnuport  tbcc_portab_regularizacao.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , t.cdcooper
           , t.nrdconta
           , t.nrsolicitacao nrsolici
           , ROWID   dsdrowid
           , t.idsituacao
           , t.dsdominio_motivo
           , t.cdmotivo
        FROM tbcc_portabilidade_envia  t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Variáveis 
    
    vr_dsxmlarq     CLOB;
    vr_dsmsglog     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_nrdrowid     VARCHAR2(100);
    vr_dtarquiv     DATE;
    
  BEGIN
    
    -- Retirar o XMLNS
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    -- Guardar o nome e a data do arquivo
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    -- Percorrer todos os dados retornados no arquivo com aprovações
    FOR rg_dadosapr IN cr_dadosapr(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosapr.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS302'
                         || ' --> Não encontrado NU Portabilidade '||rg_dadosapr.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
    
      -- Se o registro está indicando aprovação
      IF NVL(rg_dadosapr.idaprova,0) = 1 THEN

        -- Limpar tabela de erros 
        DELETE tbcc_portabilidade_env_erros t
         WHERE t.cdcooper      = rg_portab.cdcooper 
           AND t.nrdconta      = rg_portab.nrdconta
           AND t.nrsolicitacao = rg_portab.nrsolici;
        
        -- Atualiza a solicitação para aprovada 
        UPDATE tbcc_portabilidade_envia t
           SET t.idsituacao        = 3 -- Aprovada
             , t.dsdominio_motivo  = NULL
             , t.cdmotivo          = NULL
         WHERE ROWID = rg_portab.dsdrowid;
        
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => rg_portab.cdcooper ,
                             pr_cdoperad => '1',
                             pr_dscritic => ' ',
                             pr_dsorigem => '',
                             pr_dstransa => 'Aprovacao por Regularizacao de Portabilidade',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => rg_portab.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
    
        -- Gravar o Nu Portabilidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Portabilidade',
                                  pr_dsdadant => to_char(rg_portab.nrnu_portabilidade),
                                  pr_dsdadatu => to_char(rg_portab.nrnu_portabilidade));
                                  
        -- Gravar a Situação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Situacao',
                                  pr_dsdadant => rg_portab.idsituacao,
                                  pr_dsdadatu => 3 ); -- Nova situação : Aprovada
        
        -- Gravar o dominio do motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Dominio Motivo',
                                  pr_dsdadant => rg_portab.dsdominio_motivo,
                                  pr_dsdadatu => ' ' ); 
        
        -- Gravar o motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Motivo',
                                  pr_dsdadant => rg_portab.cdmotivo,
                                  pr_dsdadatu => ' ' ); 
        
      END IF;
    
    END LOOP;
    
    -- Percorrer todos os dados retornados no arquivo com reprovações
    FOR rg_dadosrep IN cr_dadosrep(vr_dsxmlarq) LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosrep.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS302'
                         || ' --> Não encontrado NU Portabilidade '||rg_dadosrep.nrnuport;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
      
      -- Se tem motivo de reprovação 
      IF rg_dadosrep.nrmotrep IS NOT NULL THEN
        
        -- Atualiza a solicitação para Reprovada
        UPDATE tbcc_portabilidade_envia t
           SET t.idsituacao        = 4 -- Reprovada
             , t.dsdominio_motivo  = 'MOTVREGLZCREPVD' -- Motivo de regularização reprovada
             , t.cdmotivo          = rg_dadosrep.nrmotrep
         WHERE ROWID = rg_portab.dsdrowid;
      
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => rg_portab.cdcooper ,
                             pr_cdoperad => '1',
                             pr_dscritic => ' ',
                             pr_dsorigem => '',
                             pr_dstransa => 'Reprovacao por Regularizacao de Portabilidade',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => rg_portab.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
    
        -- Gravar o Nu Portabilidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Nu Portabilidade',
                                  pr_dsdadant => to_char(rg_portab.nrnu_portabilidade),
                                  pr_dsdadatu => to_char(rg_portab.nrnu_portabilidade));
                                  
        -- Gravar a Situação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Situacao',
                                  pr_dsdadant => rg_portab.idsituacao,
                                  pr_dsdadatu => 4 ); -- Nova situação : Reprovada
        
        -- Gravar o dominio do motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Dominio Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => 'MOTVREGLZCREPVD' ); 
        
        -- Gravar o motivo 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Motivo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rg_dadosrep.nrmotrep ); 
      
      END IF;
      
    END LOOP;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS302. ' ||SQLERRM;
  END pc_proc_xml_APCS302;
  --
  PROCEDURE pc_monitorar_ret_PCPS(pr_nmarquiv  IN VARCHAR2
                                 ,pr_dsdsigla  IN crapscb.dsdsigla%TYPE
                                 ,pr_dsdirarq  IN crapscb.dsdirarq%TYPE
                                 ,pr_idarqret  IN BOOLEAN DEFAULT FALSE) IS
    
		/* .............................................................................
			Programa: pc_monitorar_ret_PCPS
			Sistema : CRED
			Autor   : Renato - Supero
			Data    : 29/11/2018                Ultima atualizacao:
	  
			Dados referentes ao programa:
	 
			Frequencia: Sempre que for chamado
	   
			Objetivo  : Procedure responsável por monitorar o retorno de determinado
                  arquivo. Enquanto o mesmo não é recebido ela fica se reagendando
                  até que o mesmo seja recebido ou até que chegue ao final do dia e 
                  abortando, gerando o log com a crítica.
                  PARAMETROS:
                       * pr_nmarquiv => Deve receber o nome do arquivo enviado, sem 
                                        ter os sufixos "_RET", "_PRO" ou "_ERR".
                       * pr_dsdirarq => Deve receber o diretório do arquivo, conforme
                                        parametrizado na CRAPSCB, sem a indicação da 
                                        pasta "recebe", "recebidos", "envia" ou 
                                        "enviados". 
                       * pr_idarqret => Indica se o arquivo aguardado é o arquivo 
                                        de retorno com o prefixo "_RET". Este flag 
                                        será passado como TRUE para a rotina após o
                                        recebimento do arquivo "_PRO".
	  
			Alteracoes:
		..............................................................................*/		
    -- Tabela para receber arquivos lidos no unix
		-- Variáveis
    vr_tbarquiv    TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_dthrexec    TIMESTAMP;
    vr_jobnames    VARCHAR2(100);
    vr_dsdplsql    VARCHAR2(10000);
    vr_dtarquiv    DATE;
    vr_idarqPRO    BOOLEAN;
    vr_idarqERR    BOOLEAN;
    vr_idarqRET    BOOLEAN;
    vr_nmarqPRO    VARCHAR2(50);
    vr_nmarqERR    VARCHAR2(50);
    vr_nmarqRET    VARCHAR2(50);

    vr_dsarqLOB    CLOB; -- Dados descriptografados do arquivo
    
    -- Variável de críticas
    vr_dsmsglog    VARCHAR2(1000);
    vr_dscritic    VARCHAR2(10000);
    vr_typsaida    VARCHAR2(10);

    -- Tratamento de erros
    vr_exc_erro    EXCEPTION;
		
	BEGIN
		
	  -- Ler a data do arquivo 
    vr_dtarquiv := TO_DATE( SUBSTR(pr_nmarquiv, INSTR(pr_nmarquiv,'_',10)+1, 8) ,'YYYYMMDD');
  
    -- Se o arquivo é do dia anterior (procedimento importante para evitar JOBS "eternos")
    IF vr_dtarquiv <> TRUNC(SYSDATE) THEN
      
      -- definir crítica de retorno
      vr_dscritic := 'ATENÇÃO: Monitoramento do arquivo '||pr_nmarquiv||', não registrou retorno do mesmo pela CIP.';
    
      -- GERAR LOG E NÃO AGUARDAR MAIS O RETORNO DO ARQUIVO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> '||vr_dscritic;
        
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      -- FINALIZAR COM ROLLBACK E CRITICA
      ROLLBACK;
      
      RAISE vr_exc_erro;
    END IF; -- Fim tratamento do dia
    
    -- Buscar os arquivos
    BEGIN    
      GENE0001.pc_lista_arquivos(pr_lista_arquivo => vr_tbarquiv
                                ,pr_path          => pr_dsdirarq||'/recebe' -- Ler pasta RECEBE
                                ,pr_pesq          => pr_nmarquiv||'%');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar arquivos('||pr_dsdirarq||'/recebe): '||SQLERRM;
        RAISE vr_exc_erro;
    END;    
       
    -- Se nenhum arquivo foi encontrado
    IF vr_tbarquiv.COUNT() = 0 THEN
      -- DEVE REAGENDAR O JOB PARA REEXECUTAR EM 5 MINUTOS

      -- Em 5 minutos
      vr_dthrexec := TO_TIMESTAMP_TZ(TO_CHAR((SYSDATE + vr_qtminuto),'DD/MM/RRRR HH24:MI:SS') || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI:SS TZR');

      -- Define o nome do JOB
      vr_jobnames := 'JB_PCPS_RETORNO$';

      -- Define o bloco pl/sql 
      vr_dsdplsql := 'BEGIN '||
                     '  PCPS0002.pc_monitorar_ret_PCPS('''||pr_nmarquiv||'''' ||
                                                     ','''||pr_dsdsigla||'''' ||
                                                     ','''||pr_dsdirarq||'''' ||
                                                     '); ' || 
                     'END; ';

      -- Agenda a execução
      GENE0001.pc_submit_job(pr_cdcooper => 3
                            ,pr_cdprogra => 'PCPS0002'
                            ,pr_dsplsql  => vr_dsdplsql
                            ,pr_dthrexe  => vr_dthrexec
                            ,pr_interva  => NULL
                            ,pr_jobname  => vr_jobnames
                            ,pr_des_erro => vr_dscritic);

      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF;
      
      -- GERAR LOG E NÃO AGUARDAR MAIS O RETORNO DO ARQUIVO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> Agendado JOB '||vr_jobnames||', para processamento do retorno do arquivo: '||pr_nmarquiv;
        
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
       
    ELSE
      
      -- Inicializar as variáveis de controle.. a execução é feita com base em variáveis de controle
      -- pois pode ocorrer de a mesma execução encontrar o PRO e o RET
      vr_idarqPRO := FALSE;
      vr_idarqERR := FALSE;
      vr_idarqRET := FALSE;
      vr_nmarqPRO := NULL;
      vr_nmarqERR := NULL;
      vr_nmarqRET := NULL;
      
      -- Percorrer os arquivos retornados
      FOR ind IN vr_tbarquiv.FIRST..vr_tbarquiv.LAST LOOP
        
        -- Verifica se foi encontrado retorno de um arquivo de Erro "_ERR"
        IF    UPPER(vr_tbarquiv(ind)) = UPPER(pr_nmarquiv||'_ERR') THEN
          -- Indica que foi encontrado o arquivo ERR
          vr_idarqERR := TRUE;
          vr_nmarqERR := vr_tbarquiv(ind);

        -- Verifica se foi encontrado retorno de arquivo de Protocolo "_PRO"
        ELSIF UPPER(vr_tbarquiv(ind)) = UPPER(pr_nmarquiv||'_PRO') THEN
          -- Indica que foi encontrado o arquivo PRO
          vr_idarqPRO := TRUE;
          vr_nmarqPRO := vr_tbarquiv(ind);
          
        -- Verifica se foi encontrado o arquivo de retorno "_RET"
        ELSIF UPPER(vr_tbarquiv(ind)) = UPPER(pr_nmarquiv||'_RET') THEN
          -- Indica que foi encontrado o arquivo RET
          vr_idarqRET := TRUE;
          vr_nmarqRET := vr_tbarquiv(ind);
        
        ELSE
          
          -- Gerar crítica informando que foi encontrado um arquivo que não estava sendo esperando
          vr_dscritic := 'Erro ao buscar arquivos('||pr_dsdirarq||'/recebe): '||SQLERRM;
          RAISE vr_exc_erro;          
        
        END IF;
        
        
      END LOOP;
      
      /**********************************************************************************
      **  - Validações referentes aos arquivos encontrados
      **    Regras: 
      **       1 - Se encontrar arquivo ERR não pode encontrar arquivos RET e PRO
      **       2 - Se encontrar arquivo PRO e RET, deve processar o PRO e o RET, mas não 
      **           pode reagendar o JOB
      **       3 - Se estiver realizando a execução do processamento de um RET e não pode 
      **           encontrar arquivo PRO e ERR.
      **********************************************************************************/
      
      -- Verificar regra 1 - Se encontrar arquivo de erro e um dos demais, retorna crítica
      IF vr_idarqERR AND (vr_idarqPRO OR vr_idarqRET) THEN
        vr_dscritic := 'VERIFICAR ARQUIVOS: Existe arquivo ERR, mas encontrou arquivo PRO/RET.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Verificar regra 3 - Se for processamento de retorno, não deve encontrar PRO E ERR
      IF pr_idarqret AND (vr_idarqPRO OR vr_idarqERR) THEN
        vr_dscritic := 'VERIFICAR ARQUIVOS: Processando arquivo RET, mas encontrou arquivo PRO/ERR.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Se estiver processando arquivo RET e não encontrar RET
      IF pr_idarqret AND NOT vr_idarqRET THEN
        vr_dscritic := 'VERIFICAR ARQUIVOS: Processamento de retorno, mas não encontrou arquivo RET.';
        RAISE vr_exc_erro;
      END IF;
      
      
      -- Se encontrar o arquivo de ERRO
      IF vr_idarqERR THEN
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_monitorar_ret_PCPS'
                         || ' --> Iniciando processamento do arquivo: '||vr_nmarqERR;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        -- Executar a descriptografia do arquivo
        PCPS0003.PC_LEITURA_ARQ_PCPS(pr_nmarqori => pr_dsdirarq||'/recebe/'||vr_nmarqERR
                                    ,pr_nmarqout => pr_dsdirarq||'/recebidos/'||vr_nmarqERR||'.xml'
                                    ,pr_dscritic => vr_dscritic);
        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Carregar o conteúdo extraído do arquivo criptografado
        vr_dsarqLOB := PCPS0001.fn_arq_utf_para_clob(pr_caminho => pr_dsdirarq||'/recebidos'
                                                ,pr_arquivo => vr_nmarqERR||'.xml');  -- XML extraído
        
        -- Chama a rotina para processamento do arquivo de erro
        CASE pr_dsdsigla
          WHEN 'APCS101' THEN
            -- Processar retorno do arquivo
            pc_proc_ERR_APCS101(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS103' THEN
            -- Processar retorno do arquivo
            pc_proc_ERR_APCS103(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS105' THEN
            -- Processar retorno do arquivo
            pc_proc_ERR_APCS105(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS201' THEN -- Gilberto - Supero Janeiro/2019 
            -- Processar retorno do arquivo
            pc_proc_ERR_APCS201(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS203' THEN -- Gilberto - Supero Janeiro/2019 
            -- Processar retorno do arquivo
            pc_proc_ERR_APCS203(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS301' THEN -- Gilberto - Supero Janeiro/2019 
            -- Processar retorno do arquivo
            pc_proc_ERR_APCS301(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          ELSE
            vr_dscritic := 'Rotina não especificada para processar arquivos: '||pr_dsdsigla;
            RAISE vr_exc_erro;
        END CASE;
                         
        -- Se houver retorno de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Devemos movê-lo para a pasta envia
        GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirarq||'/recebe/'||vr_nmarqERR||' '||pr_dsdirarq||'/recebidos/'||vr_nmarqERR
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
      
        -- Testa se a saída da execução acusou erro
        IF vr_typsaida = 'ERR' THEN
          -- LOG DE EXECUCAO
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_monitorar_ret_PCPS'
                           || ' --> Erro ao copiar arquivo para pasta RECEBIDOS: '||vr_nmarqERR;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
          -- Não irá estourar critica por ser um arquivo de retorno e pode ser copiado manualmente
          vr_dscritic := NULL;
        END IF;
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_monitorar_ret_PCPS'
                         || ' --> Concluido processamento do arquivo: '||vr_nmarqERR;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Ao mover o arquivo grava os dados processados
        COMMIT;
         
      END IF; -- Fim processamento arquivo ERR
      
      -- Se encontrar o arquivo PRO
      IF vr_idarqPRO THEN
      
        /**
           ARQUIVOS "_PRO" NÃO POSSUEM PROCESSAMENTO ESPECÍFICO, SENDO ASSIM, O MESMO
           É UTILIZADO APENAS PARA INDICAR QUE O ENVIO OCORREU COM SUCESSO. QUANDO O 
           PROCESSSAMENTO DO ARQUIVO PRO OCORRER, SERÁ REALIZADO O AGENDAMENTO DE UM 
           NOVO JOB PARA LEITURA DO ARQUIVO RET(CASO ESTE JÁ NÃO TENHA SIDO ENCONTRADO
           NESTE PROCESSAMENTO) E O ARQUIVO PRO SERÁ DESCRIPTOGRAFADO E MOVIDO PARA O 
           DIRETÓRIO DE ARQUIVOS RECEBIDOS.
        **/
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_monitorar_ret_PCPS'
                         || ' --> Iniciando processamento do arquivo: '||vr_nmarqPRO;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
        -- Se o arquivo RET não está disponível ainda
        IF NOT vr_idarqRET THEN
          
          -- Deve reagendar um JOB para aguardar e processar o arquivo RET
          vr_dthrexec := TO_TIMESTAMP_TZ(TO_CHAR((SYSDATE + vr_qtminuto),'DD/MM/RRRR HH24:MI:SS') || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI:SS TZR');

          -- Define o nome do JOB
          vr_jobnames := 'JB_PCPS_RETORNO$';

          -- Define o bloco pl/sql 
          vr_dsdplsql := 'BEGIN '||
                         '  PCPS0002.pc_monitorar_ret_PCPS('''||pr_nmarquiv||'''' ||
                                                         ','''||pr_dsdsigla||'''' ||
                                                         ','''||pr_dsdirarq||'''' ||
                                                         ',TRUE); ' || 
                         'END; ';

          -- Agenda a execução
          GENE0001.pc_submit_job(pr_cdcooper => 3
                                ,pr_cdprogra => 'PCPS0002'
                                ,pr_dsplsql  => vr_dsdplsql
                                ,pr_dthrexe  => vr_dthrexec
                                ,pr_interva  => NULL
                                ,pr_jobname  => vr_jobnames
                                ,pr_des_erro => vr_dscritic);

          -- Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro; 
          END IF;
          
          -- GERAR LOG E NÃO AGUARDAR MAIS O RETORNO DO ARQUIVO
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_monitorar_ret_PCPS'
                           || ' --> Agendado JOB '||vr_jobnames||', para processamento do retorno do arquivo: '||pr_nmarquiv;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
          
        END IF; -- Arquivo RET
        
        -- Executar a descriptografia do arquivo
        PCPS0003.PC_LEITURA_ARQ_PCPS(pr_nmarqori => pr_dsdirarq||'/recebe/'||vr_nmarqPRO
                                    ,pr_nmarqout => pr_dsdirarq||'/recebidos/'||vr_nmarqPRO||'.xml'
                                    ,pr_dscritic => vr_dscritic);
        
        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Mover o arquivo PRO para a pasta de arquivos recebidos e processados
        GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirarq||'/recebe/'||vr_nmarqPRO||' '||pr_dsdirarq||'/recebidos/'||vr_nmarqPRO
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
        
        -- Testa se a saída da execução acusou erro
        IF vr_typsaida = 'ERR' THEN
          -- LOG DE EXECUCAO
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_monitorar_ret_PCPS'
                           || ' --> Erro ao copiar arquivo para pasta RECEBIDOS: '||vr_nmarqPRO;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
          -- Não irá estourar critica por ser um arquivo de retorno e pode ser copiado manualmente
          vr_dscritic := NULL;
        END IF;
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_monitorar_ret_PCPS'
                         || ' --> Concluido processamento do arquivo: '||vr_nmarqPRO;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Ao mover o arquivo grava os dados processados
        COMMIT;
        
      END IF;
      
      -- Se encontrar o arquivo RET
      IF vr_idarqRET THEN
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_monitorar_ret_PCPS'
                         || ' --> Iniciando processamento do arquivo: '||vr_nmarqRET;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        -- Executar a descriptografia do arquivo
        PCPS0003.PC_LEITURA_ARQ_PCPS(pr_nmarqori => pr_dsdirarq||'/recebe/'||vr_nmarqRET
                                    ,pr_nmarqout => pr_dsdirarq||'/recebidos/'||vr_nmarqRET||'.xml'
                                    ,pr_dscritic => vr_dscritic);
                    
        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Carregar o conteúdo extraído do arquivo criptografado
        vr_dsarqLOB := PCPS0001.fn_arq_utf_para_clob(pr_caminho => pr_dsdirarq||'/recebidos'
                                                ,pr_arquivo => vr_nmarqRET||'.xml');  -- XML extraído
        
        -- Chama a rotina para processamento do arquivo de erro
        CASE pr_dsdsigla
          WHEN 'APCS101' THEN
            -- Processar retorno do arquivo
            pc_proc_RET_APCS101(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS103' THEN
            -- Processar retorno do arquivo
            pc_proc_RET_APCS103(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS105' THEN
            -- Processar retorno do arquivo
            pc_proc_RET_APCS105(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS201' THEN -- Janeiro/2019 Gilberto/Supero
            -- Processar retorno do arquivo
            pc_proc_RET_APCS201(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS203' THEN  -- Janeiro/2019 Gilberto/Supero
            -- Processar retorno do arquivo
            pc_proc_RET_APCS203(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);
          WHEN 'APCS301' THEN  -- Fevereiro/2019 Gilberto/Supero
            -- Processar retorno do arquivo
            pc_proc_RET_APCS301(pr_dsxmlarq => vr_dsarqLOB
                               ,pr_dscritic => vr_dscritic);

          ELSE
            vr_dscritic := 'Rotina não especificada para processar arquivos: '||pr_dsdsigla;
            RAISE vr_exc_erro;
        END CASE;
                         
        -- Se houver retorno de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Realizar o MOVE do arquivo processado
        GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirarq||'/recebe/'||vr_nmarqRET||' '||pr_dsdirarq||'/recebidos/'||vr_nmarqRET
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
                                   
        -- Testa se a saída da execução acusou erro
        IF vr_typsaida = 'ERR' THEN
          -- LOG DE EXECUCAO
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_monitorar_ret_PCPS'
                           || ' --> Erro ao copiar arquivo para pasta RECEBIDOS: '||vr_nmarqRET;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
          -- Não irá estourar critica por ser um arquivo de retorno e pode ser copiado manualmente
          vr_dscritic := NULL;
        END IF;
        
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_monitorar_ret_PCPS'
                         || ' --> Concluido processamento do arquivo: '||vr_nmarqRET;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
        -- Ao mover o arquivo grava os dados processados
        COMMIT;
        
      END IF;
      
    END IF; -- Se encontrar arquivos
  
    -- Efetivar processamento realizado
    COMMIT;
    
	EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      
      -- LOG DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> Erro ao monitorar: '||vr_nmarqERR||'. '||vr_dscritic;
            
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      raise_application_error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      ROLLBACK;
      
      -- Guardar erro
      vr_dscritic := SQLERRM;
      
      -- LOG DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> Erro ao monitorar: '||vr_nmarqERR||'. '||vr_dscritic;
            
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      raise_application_error(-20002, 'Erro na rotina PC_MONITORAR_RET_PCPS: '||SQLERRM);
	END pc_monitorar_ret_PCPS;
  
  PROCEDURE pc_gera_arquivo_APCS (pr_tparquiv   IN crapscb.tparquiv%TYPE) IS  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_arquivo_APCS
    --  Sistema  : Procedure para gerar os arquivos: 
    --             pr_tparquiv = 10 -> APCS101 - Solicitação de Portabilidade de Salário
    --             pr_tparquiv = 12 -> APCS103 - Instituição Banco da Folha responde solicitação de 
    --                                           Portabilidade Aprovada ou Reprovada. 
    --             pr_tparquiv = 14 -> APCS105 - Participante Envia Cancelamento de Portabilidade
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar parametros e gerar o arquivo especificado na tabela CRAPSCB
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- CURSORES
    -- Buscar as informações do arquivo
    CURSOR cr_crapscb IS
      SELECT ROWID dsdrowid
           , scb.dsdsigla
           , scb.dsarquiv
           , scb.nrseqarq
           , scb.dsdirarq
        FROM crapscb scb
       WHERE scb.tparquiv = pr_tparquiv
         FOR UPDATE;
    rg_crapscb    cr_crapscb%ROWTYPE;
      
    -- VARIÁVEIS
    vr_dsarqLOB      CLOB; -- Arquivo com os dados gerados para ser criptografado e enviado a CIP
    
    vr_dsxmlarq      XMLTYPE;
    vr_nmarquiv      VARCHAR2(100);
    vr_dscritic      VARCHAR2(1000);
    vr_dsmsglog      VARCHAR2(1000);
    vr_nrseqarq      NUMBER;
    vr_inddados      BOOLEAN;
    vr_idfimreg      BOOLEAN;
    vr_dthrexec      TIMESTAMP;
    vr_jobnames      VARCHAR2(100);
    vr_dsdplsql      VARCHAR2(10000);
    
    vr_exc_erro      EXCEPTION;
    
  BEGIN
    
    -- Busca oos dados do arquivo
    OPEN  cr_crapscb;
    FETCH cr_crapscb INTO rg_crapscb;
    
    -- Verifica se encontrou o arquivo
    IF cr_crapscb%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapscb;
    
      vr_dscritic := 'Parametrização do arquivo de tipo '||pr_tparquiv||' não encontrada.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar cursor
    CLOSE cr_crapscb;
  
    -- LOGS DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                     || 'PCPS0002.pc_gera_arquivo_APCS'
                     || ' --> Iniciando geracao '||rg_crapscb.dsdsigla||' - '||rg_crapscb.dsarquiv;
      
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
    -- Incrementar os sequencial do arquivo
    vr_nrseqarq := NVL(rg_crapscb.nrseqarq,0) + 1;
    
    -- Se chegar a numeração limite, reinicia
    IF vr_nrseqarq > 99999 THEN
      vr_nrseqarq := 1;
    END IF;
    
    -- Montar o nome do arquivo e gerar o xml base
    pc_gera_base_xml(pr_dsdsigla => rg_crapscb.dsdsigla
                    ,pr_nrseqarq => vr_nrseqarq
                    ,pr_dsxmlarq => vr_dsxmlarq
                    ,pr_nmarquiv => vr_nmarquiv);
    
    -- LOGS DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                     || 'PCPS0002.pc_gera_arquivo_APCS'
                     || ' --> Gerando arquivo: '||vr_nmarquiv;
      
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
    -- Verifica qual o conteúdo de arquivo deve ser gerado
    CASE rg_crapscb.dsdsigla
      WHEN 'APCS101' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_XML_APCS101(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_idfimreg => vr_idfimreg
                           ,pr_dscritic => vr_dscritic);
      WHEN 'APCS103' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_XML_APCS103(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_idfimreg => vr_idfimreg
                           ,pr_dscritic => vr_dscritic);
      WHEN 'APCS105' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_XML_APCS105(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_idfimreg => vr_idfimreg
                           ,pr_dscritic => vr_dscritic);
      WHEN 'APCS201' THEN
        -- Janeiro/2019 Gilberto/Supero
        -- Gerar o conteudo do arquivo
        pc_gera_XML_APCS201(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_idfimreg => vr_idfimreg
                           ,pr_dscritic => vr_dscritic);
     WHEN 'APCS203' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_XML_APCS203(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_idfimreg => vr_idfimreg
                           ,pr_dscritic => vr_dscritic);
     WHEN 'APCS301' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_XML_APCS301(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_idfimreg => vr_idfimreg
                           ,pr_dscritic => vr_dscritic);
      ELSE
        vr_dscritic := 'Rotina não especificada para gerar este arquivo.';
        RAISE vr_exc_erro;
    END CASE;
                    
    -- Se houver retorno de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Se não encontrar dados, não gera arquivo
    IF NOT vr_inddados THEN
      -- montar a mensagem de log
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                     || 'PCPS0002.pc_gera_arquivo_APCS'
                     || ' --> Não foram encontrados dados para o arquivo.';
      
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
      
      -- Desfaz as alterações da base
      ROLLBACK;
      
      RETURN;
    END IF;
    
    -- Conteúdo CLOB do arquivo (carregar em uma variável para evitar chamar várias vezer o getClobVal)
    vr_dsarqLOB := vr_dsxmlarq.getClobVal();
    
    -- Gerar o arquivo XML para eventuais consultas e analises
    GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsarqLOB
                                 ,pr_caminho  => rg_crapscb.dsdirarq||'/enviados'
                                 ,pr_arquivo  => vr_nmarquiv||'.xml'
                                 ,pr_des_erro => vr_dscritic);
    
    -- Se houver retorno de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    /********** CRIPTOGRAFAR O ARQUIVO PARA ENVIAR A CIP **************/
    PCPS0003.PC_ESCRITA_ARQ_PCPS(pr_nmarqori => rg_crapscb.dsdirarq||'/enviados/'||vr_nmarquiv||'.xml'
                                ,pr_nmarqout => rg_crapscb.dsdirarq||'/envia/'||vr_nmarquiv
                                ,pr_dscritic => vr_dscritic);
                                
    -- Se houver retorno de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
       
    -- LOG DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                     || 'PCPS0002.pc_gera_arquivo_APCS'
                     || ' --> Arquivo gerado com sucesso: '||vr_nmarquiv;
      
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
    -- Atualizar informações do controle de arquivos
    UPDATE crapscb t
       SET t.nrseqarq = vr_nrseqarq
         , t.dtultint = SYSDATE
     WHERE ROWID = rg_crapscb.dsdrowid;
    
    -- GRAVAR AS INFORMAÇÕES POIS O ARQUIVO FOI ENVIADO E CASO OCORRAM ERROS DESSE PONTO EM 
    -- DIANTE, AS TRATATIVAS DEVEM SER FEITAS CASO-A-CASO
    COMMIT;
    
    -- Se não finalizou o envio de todas as informações pendentes
    IF NOT vr_idfimreg THEN
      
      BEGIN
        
        -- Em 15 segundos
        vr_dthrexec := TO_TIMESTAMP_TZ(TO_CHAR((SYSDATE + vr_qtxvsegundos),'DD/MM/RRRR HH24:MI:SS') || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI:SS TZR');

        -- Define o nome do JOB
        vr_jobnames := 'JB_PCPS_GERAR$';

        -- Define o bloco pl/sql 
        vr_dsdplsql := 'BEGIN '||
                       '  PCPS0002.pc_gera_arquivo_APCS('||pr_tparquiv||'); ' || 
                       'END; ';

        -- Agenda a execução
        GENE0001.pc_submit_job(pr_cdcooper => 3
                              ,pr_cdprogra => 'PCPS0002'
                              ,pr_dsplsql  => vr_dsdplsql
                              ,pr_dthrexe  => vr_dthrexec
                              ,pr_interva  => NULL
                              ,pr_jobname  => vr_jobnames
                              ,pr_des_erro => vr_dscritic);

        -- Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;
        
        -- GERAR LOG 
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_gera_arquivo_APCS'
                         || ' --> Agendado JOB '||vr_jobnames||', para gerar arquivos com solicitações pendentes. ';
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- GERAR LOG 
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_gera_arquivo_APCS'
                           || ' --> Erro ao agendar JOB '||vr_jobnames||': '||vr_dscritic;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
          -- Seguir sem registro de erro
          vr_dscritic := NULL;
        WHEN OTHERS THEN
          -- GERAR LOG 
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_gera_arquivo_APCS'
                           || ' --> Erro ao agendar JOB '||vr_jobnames||': '||SQLERRM;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
      END;
    
    END IF; -- IF NOT vr_idfimreg
    
    /**************** Criar o Job para monitorar o retorno do ERR ou PRO ****************/
    BEGIN
      
      -- Inicializar o monitorador para o arquivo gerado
      PCPS0002.pc_monitorar_ret_PCPS(pr_nmarquiv => vr_nmarquiv
                                    ,pr_dsdsigla => rg_crapscb.dsdsigla
                                    ,pr_dsdirarq => rg_crapscb.dsdirarq);
                                    
    EXCEPTION
      WHEN OTHERS THEN
        -- LOG DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_gera_arquivo_APCS'
                         || ' --> Erro ao inicializar monitorador: '||SQLERRM;
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- LOGS DE EXECUCAO
      BEGIN

        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,vr_dsmasklog)||' - '
                                                       || 'PCPS0002.pc_gera_arquivo_APCS'
                                                       || ' --> Erro ao gerar arquivo: '||vr_dscritic
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;  
    
      ROLLBACK;
      raise_application_error(-20001,'ERRO pc_gera_arquivo_APCS: '||vr_dscritic);
    WHEN OTHERS THEN
      -- Guardar o erro para log
      vr_dscritic := SQLERRM;  
    
      -- LOGS DE EXECUCAO
      BEGIN

        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,vr_dsmasklog)||' - '
                                                       || 'PCPS0002.pc_gera_arquivo_APCS'
                                                       || ' --> Erro ao gerar arquivo: '||vr_dscritic
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;    
    
      ROLLBACK;
      raise_application_error(-20000,'ERRO pc_gera_arquivo_APCS: '||vr_dscritic);
  END pc_gera_arquivo_APCS;
  
  PROCEDURE pc_proc_arquivo_APCS (pr_tparquiv   IN crapscb.tparquiv%TYPE) IS  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_proc_arquivo_APCS
    --  Sistema  : Procedure para gerar os arquivos: 
    --             pr_tparquiv = 11 -> APCS102 - PCS Informa Solicitação de Portabilidade de Conta Salário
    --             pr_tparquiv = 13 -> APCS104 - CIP Informa a resposta da Solicitação de Portabilidade 
    --                                           Aprovada ou Reprovada
    --             pr_tparquiv = 15 -> APCS106 - CIP repassa a Solicitação de Cancelamento
    --             pr_tparquiv = 16 -> APCS108 - Aceite Compulsório
    --             pr_tparquiv = 17 -> APCS109 - Cip repassa a Movimentação diária
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Dezembro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar parametros e processar o arquivo especificado na tabela CRAPSCB
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- CURSORES
    -- Buscar as informações do arquivo
    CURSOR cr_crapscb IS
      SELECT ROWID dsdrowid
           , scb.dsdsigla
           , scb.dsarquiv
           , scb.nrseqarq
           , scb.dsdirarq
        FROM crapscb scb
       WHERE scb.tparquiv = pr_tparquiv
         FOR UPDATE;
    rg_crapscb    cr_crapscb%ROWTYPE;
      
    -- VARIÁVEIS
    -- Tabela para receber arquivos lidos no unix
    vr_tbarquiv      TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_dscritic      VARCHAR2(1000);
    vr_typsaida      VARCHAR2(10);
    vr_dsmsglog      VARCHAR2(1000);
    vr_dspesqfl      VARCHAR2(30);
    vr_dsxmlarq      CLOB;
        
    vr_exc_erro      EXCEPTION;
    
  BEGIN
    
    -- Busca oos dados do arquivo
    OPEN  cr_crapscb;
    FETCH cr_crapscb INTO rg_crapscb;
    
    -- Verifica se encontrou o arquivo
    IF cr_crapscb%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapscb;
    
      vr_dscritic := 'Parametrização do arquivo de tipo '||pr_tparquiv||' não encontrada.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar cursor
    CLOSE cr_crapscb;
        
    -- LOGS DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_proc_arquivo_APCS'
                       || ' --> Iniciando processamento '||rg_crapscb.dsdsigla||' - '||rg_crapscb.dsarquiv;
      
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    -- Busca os arquivos para leitura
    vr_dspesqfl := rg_crapscb.dsdsigla||'%';
    
    -- Buscar todos os arquivos no diretório específico
    GENE0001.pc_lista_arquivos(pr_lista_arquivo => vr_tbarquiv
                              ,pr_path          => rg_crapscb.dsdirarq||'/recebe' -- Ler pasta RECEBE
                              ,pr_pesq          => vr_dspesqfl);
    
    -- Se não encontrar arquivos
    IF vr_tbarquiv.COUNT() = 0 THEN
      -- LOGS DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_proc_arquivo_APCS'
                       || ' --> Não foram encontrados arquivos para processar.';
        
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      -- Encerra a execução
      RETURN;
      
    END IF;     
    -- Percorrer todos os arquivos encontrados
    FOR vr_index IN vr_tbarquiv.FIRST..vr_tbarquiv.LAST LOOP
      -- LOGS DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_proc_arquivo_APCS'
                       || ' --> Processando arquivo: '||vr_tbarquiv(vr_index);
        
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      -- Realizar a descompactação do arquivo
      PCPS0003.PC_LEITURA_ARQ_PCPS(pr_nmarqori => rg_crapscb.dsdirarq||'/recebe/'||vr_tbarquiv(vr_index)
                                  ,pr_nmarqout => rg_crapscb.dsdirarq||'/recebidos/'||vr_tbarquiv(vr_index)||'.xml'
                                  ,pr_dscritic => vr_dscritic);
      
      -- Se houver retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Carregar o arquivo XML descriptografado 
      vr_dsxmlarq := PCPS0001.fn_arq_utf_para_clob(pr_caminho => rg_crapscb.dsdirarq||'/recebidos'
                                              ,pr_arquivo => vr_tbarquiv(vr_index)||'.xml');  -- XML extraído  
      
      -- Verifica qual o conteúdo de arquivo deve ser gerado
      CASE rg_crapscb.dsdsigla
        WHEN 'APCS102' THEN
          -- Processar arquivo
          pc_proc_xml_APCS102(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS104' THEN
          -- Processar arquivo
          pc_proc_xml_APCS104(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS106' THEN
          -- Processar arquivo
          pc_proc_xml_APCS106(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS108' THEN
          -- Processar arquivo
          pc_proc_xml_APCS108(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS109' THEN
          -- Não realiza processamento especifico, apenas descompacta e move o arquivo
          NULL;
        WHEN 'APCS202' THEN 
          --- Janeiro/2019 Gilberto/Supero 
          -- Processar arquivo
          pc_proc_xml_APCS202(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS204' THEN
          -- Processar arquivo
          pc_proc_xml_APCS204(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS205' THEN
          -- Processar arquivo
          pc_proc_xml_APCS205(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS302' THEN
          -- Processar arquivo
          pc_proc_xml_APCS302(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        ELSE
          vr_dscritic := 'Rotina não especificada para processar este arquivo.';
          RAISE vr_exc_erro;
      END CASE;
                       
      -- Se houver retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Realizar o MOVE do arquivo processado
      GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||rg_crapscb.dsdirarq||'/recebe/'||vr_tbarquiv(vr_index)
                                                    ||' '||rg_crapscb.dsdirarq||'/recebidos/'||vr_tbarquiv(vr_index)
                                 ,pr_typ_saida   => vr_typsaida
                                 ,pr_des_saida   => vr_dscritic);
      
      -- Testa se a saída da execução acusou erro
      IF vr_typsaida = 'ERR' THEN
        -- LOG DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_arquivo_APCS'
                         || ' --> Erro ao copiar arquivo para pasta RECEBIDOS: '||vr_tbarquiv(vr_index);
          
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
          
      -- LOG DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_proc_arquivo_APCS'
                       || ' --> Arquivo processado com sucesso: '||vr_tbarquiv(vr_index);
        
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      -- Commitar os dados processados
      COMMIT;
    
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- LOGS DE EXECUCAO
      BEGIN

        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,vr_dsmasklog)||' - '
                                                       || 'PCPS0002.pc_proc_arquivo_APCS'
                                                       || ' --> Erro ao gerar arquivo: '||vr_dscritic
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;  
    
      ROLLBACK;
      raise_application_error(-20001,'ERRO pc_proc_arquivo_APCS: '||vr_dscritic);
    WHEN OTHERS THEN
      -- Guardar o erro para log
      vr_dscritic := SQLERRM;  
    
      -- LOGS DE EXECUCAO
      BEGIN

        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,vr_dsmasklog)||' - '
                                                       || 'PCPS0002.pc_proc_arquivo_APCS'
                                                       || ' --> Erro ao gerar arquivo: '||vr_dscritic
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;    
    
      ROLLBACK;
      raise_application_error(-20000,'ERRO pc_proc_arquivo_APCS: '||vr_dscritic);
  END pc_proc_arquivo_APCS;
  
  
  PROCEDURE pc_email_pa_portabilidade IS -- Descrição da crítica
  
    /* .............................................................................
    Programa: pc_email_pa_portabilidade
    Sistema : Ayllos Web
    Autor   : Renato Darosci - Supero
    Data    : 19/10/2018                Ultima atualizacao:
  
    Dados referentes ao programa:
 
    Frequencia: Sempre que for chamado
   
    Objetivo  : Rotina para envio de e-mail para os PAs que estão com avaliações 
                de portabilidade pendentes
  
    Alteracoes:
  ..............................................................................*/

    -- Buscar o parametro de dias para aviso (crappat) 
    CURSOR cr_crappco IS
      SELECT TO_NUMBER(t.dsconteu)  qtdiaavs
        FROM crappco t
       WHERE t.cdpartar = 61 -- Quantidade de dias para aviso de prazo para aceite compulsorio
         AND t.cdcooper = 3;
    
    -- Buscar as cooperativas para processamento
    CURSOR cr_crapcop IS
      SELECT t.cdcooper
           , t.nmrescop
        FROM crapcop t
       WHERE t.flgativo = 1
         AND t.cdcooper <> 3 -- Não processar para central
       ORDER BY t.cdcooper;
        
    
    -- Buscar dados da agencia
    CURSOR cr_agencia(pr_cdcooper  crapage.cdcooper%TYPE
                     ,pr_cdagenci  crapage.cdagenci%TYPE) IS
      SELECT t.dsdemail
        FROM crapage t
       WHERE t.cdcooper = pr_cdcooper
         AND t.cdagenci = pr_cdagenci;
    
    -- Buscar os dados das pendencias
    CURSOR cr_dados(pr_cdcooper  NUMBER
                   ,pr_qtdiaavs  NUMBER) IS
      SELECT t.cdcooper
           , a.cdagenci
           , to_char(t.nrnu_portabilidade)            nuportab
           , trim(gene0002.fn_mask_conta(t.nrdconta)) nrdconta
           , to_char(t.dtsolicitacao,'DD/MM/RRRR')    dtsolici
        FROM crapass                   a
           , tbcc_portabilidade_recebe t
       WHERE t.cdcooper       = pr_cdcooper
         AND a.cdcooper       = t.cdcooper
         AND a.nrdconta       = t.nrdconta
         AND t.idsituacao    IN (1,4) -- Pendente/Rejeitada
         AND t.dtsolicitacao <= TRUNC(SYSDATE) - pr_qtdiaavs
       ORDER BY t.cdcooper
              , a.cdagenci 
              , t.dtsolicitacao;
  
    -- Collections
    TYPE typ_reg_port IS RECORD (nrportab  NUMBER
                                ,dsdconta  VARCHAR2(10)
                                ,dsdatsol  VARCHAR2(10));
    TYPE typ_tab_pendencias IS TABLE OF typ_reg_port       INDEX BY BINARY_INTEGER;
    TYPE typ_tab_agencias   IS TABLE OF typ_tab_pendencias INDEX BY BINARY_INTEGER;
    
    vr_tbddados    typ_tab_agencias;
  
    -- Variável de críticas
    vr_dscritic    VARCHAR2(10000);
    vr_dsmsglog    VARCHAR2(1000);

    -- Tratamento de erros
    vr_exc_erro    EXCEPTION;

    -- Variáveis do e-mail
    vr_dsassunt    VARCHAR2(10000);
    vr_dsmensag    VARCHAR2(10000);
    
    -- Variáveis
    vr_cdagatual    crapage.cdagenci%TYPE;
    vr_dsdemail     crapage.dsdemail%TYPE;
    vr_qtdiaavs     NUMBER;
    vr_nrindice     NUMBER;
    vr_dtdiautl     DATE := TRUNC(SYSDATE);
    
  BEGIN
    
    -- Verificar se é dia útil
    vr_dtdiautl := gene0005.fn_valida_dia_util(pr_cdcooper => 3 -- Validar pela Central
                                              ,pr_dtmvtolt => TRUNC(SYSDATE));
        
    -- Verifica dia
    IF vr_dtdiautl <> TRUNC(SYSDATE) THEN
      -- Não realiza envio de e-mails
      RETURN;
    END IF;
  
    -- Buscar a quantidade de dias para o aviso 
    OPEN  cr_crappco;
    FETCH cr_crappco INTO vr_qtdiaavs;
    CLOSE cr_crappco;
  
    -- Se não encontrar registros 
    IF vr_qtdiaavs IS NULL THEN
      vr_dscritic := 'Parâmetro de dias para aviso de prazo para aceite compulsório, não encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Percorrer todas as cooperativas
    FOR rg_cooper IN cr_crapcop LOOP
      
      -- Limpar a tabela
      vr_tbddados.DELETE();
    
      -- Percorrer os dados da cooperativa
      FOR rg_dados IN cr_dados(rg_cooper.cdcooper, vr_qtdiaavs) LOOP
        
        IF vr_tbddados.exists(rg_dados.cdagenci) THEN
          -- Indice por agencia
          vr_nrindice := vr_tbddados(rg_dados.cdagenci).COUNT() + 1;
        ELSE
          vr_nrindice := 1;
        END IF;
      
        vr_tbddados(rg_dados.cdagenci)(vr_nrindice).nrportab := rg_dados.nuportab;
        vr_tbddados(rg_dados.cdagenci)(vr_nrindice).dsdconta := rg_dados.nrdconta;
        vr_tbddados(rg_dados.cdagenci)(vr_nrindice).dsdatsol := rg_dados.dtsolici;
        
      END LOOP;

      -- Limpar email
      vr_dsdemail := NULL;

      -- Se não tem registros
      IF vr_tbddados.count() = 0 THEN
        CONTINUE;
      END IF;
      
      -- Percorre cada um dos registros da agencia
      vr_cdagatual := vr_tbddados.FIRST();
      
      LOOP
        
        -- Buscar os dados da agencia
        OPEN  cr_agencia(rg_cooper.cdcooper,vr_cdagatual);
        FETCH cr_agencia INTO vr_dsdemail;
        CLOSE cr_agencia;
      
        -- Se não tiver endereço de email
        IF trim(vr_dsdemail) IS NULL THEN
          -- Registrar mensagem no log e pular para o próximo registro
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_email_pa_portabilidade'
                           || ' --> E-mail do PA não encontrado (Coop/PA): '||rg_cooper.cdcooper||'/'||vr_cdagatual;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
            
            -- Próxima agência
            vr_cdagatual := vr_tbddados.NEXT(vr_cdagatual);

            IF vr_cdagatual IS NULL THEN
              EXIT;
            END IF;
            
            -- Próximo registro
            CONTINUE;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END IF;
        
        -- Montar o assunto do e-mail
        vr_dsassunt := UPPER(rg_cooper.nmrescop)||' - PA '||vr_cdagatual||' - SOLICITAÇÕES DE PORTABILIDADE PENDENTES';
        
        -- Montar o corpo do e-mail
        vr_dsmensag := '<html>'||
                       'Prezado(a) operador(a) do PA,<br><br>'||
                       'Segue abaixo a rela&ccedil;&atilde;o de solicita&ccedil;&otilde;es de portabilidade pendentes: <br><br>'||
                       '<table border = "1" style="border-collapse: collapse;" >'||
                       '<thead>'||
                       '<td style="width: 180px;" align="center">Portabilidade</td>'||
                       '<td style="width: 100px;" align="center">Conta</td>'||
                       '<td style="width: 100px;" align="center">Data</td>'||
                       '</thead>';
        
        -- Percorrer os registros da tabela
        FOR vr_idregist IN vr_tbddados(vr_cdagatual).FIRST()..vr_tbddados(vr_cdagatual).LAST() LOOP
        
          -- Incluir a linha no html do email
          vr_dsmensag := vr_dsmensag||'<tr>'||
                                      '<td align="center">'||vr_tbddados(vr_cdagatual)(vr_idregist).nrportab||'</td>'||
                                      '<td align="center">'||vr_tbddados(vr_cdagatual)(vr_idregist).dsdconta||'</td>'||
                                      '<td align="center">'||vr_tbddados(vr_cdagatual)(vr_idregist).dsdatsol||'</td>'||
                                      '</tr>';
          
          -- Controle do conteúdo, para evitar estouro de variável
          IF length(vr_dsmensag) > 30000 THEN
            EXIT; -- sai do for
          END IF;
          
        END LOOP;
                  
        vr_dsmensag := vr_dsmensag||'</table>'||
                       '<br>Para consultar as informa&ccedil;&otilde;es de portabilidade, acessar a tela SOLPOR.<br><br>'||
                       'Atenciosamente.'||
                       '</html>';
        
        -- Enviar o e-mail
        gene0003.pc_solicita_email(pr_cdcooper        => rg_cooper.cdcooper
                                  ,pr_cdprogra        => 'SOLPOR'
                                  ,pr_des_destino     => vr_dsdemail
                                  ,pr_des_assunto     => vr_dsassunt
                                  ,pr_des_corpo       => vr_dsmensag
                                  ,pr_des_anexo       => NULL --> nao envia anexo
                                  ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_des_erro        => vr_dscritic);

        -- Se houver erros
        IF vr_dscritic IS NOT NULL THEN
          -- Registrar mensagem no log e pular para o próximo registro
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_email_pa_portabilidade'
                           || ' --> Erro ao enviar e-mail para (Coop/PA): '||rg_cooper.cdcooper||'/'||vr_cdagatual||'. '||vr_dscritic;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
            
            -- Próxima agência
            vr_cdagatual := vr_tbddados.NEXT(vr_cdagatual);
            
            IF vr_cdagatual IS NULL THEN
              EXIT;
            END IF;
            
            -- Verificar se percorreu todas as agencias da coop
            EXIT WHEN vr_cdagatual = vr_tbddados.LAST();
            
            -- Próximo registro
            CONTINUE;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END IF;
        
        -- Verificar se percorreu todas as agencias da coop
        EXIT WHEN vr_cdagatual = vr_tbddados.LAST();
        vr_cdagatual := vr_tbddados.NEXT(vr_cdagatual);
      END LOOP;  -- Loop Agencia
    END LOOP; -- Loop Cooperativas

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_compleme => 'vr_cdagatual:' || vr_cdagatual || ' dsassunt' || vr_dsassunt);
      raise_application_error(-20002, 'Erro na rotina PC_EMAIL_PA_PORTABILIDADE: '||SQLERRM);
  END pc_email_pa_portabilidade;
	
	PROCEDURE pc_agenda_jobs IS
		/* .............................................................................
			Programa: pc_agenda_jobs
			Sistema : CRED
			Autor   : Augusto - Supero
			Data    : 23/10/2018                Ultima atualizacao:
	  
			Dados referentes ao programa:
	 
			Frequencia: Sempre que for chamado
	   
			Objetivo  : Procedure responsável por agendar os jobs da integração PCPS.
	  
			Alteracoes:
               05/06/2019 - Alterar para que não sejam agendados jobs com horário
                            anterior ao atual, com objetivo de evitar que dois jobs 
                            agendados atrasados, não rodem ao mesmo tempo. (Renato - Supero)
                            
               07/06/2019 - Verificar os jobs agendados por horário. (Renato - Supero)
		..............................................................................*/		
    
		-- Cursor responsável por retornar os horários de agendamento dos jobs
		CURSOR cr_crappco IS
		   SELECT dsconteu
			       ,cdpartar
		   	 FROM crappco
			  WHERE cdpartar IN (58, 59, 60, 62)
				  AND cdcooper = 3;
		rw_crappco cr_crappco%ROWTYPE;
		
    -- Busca registros de jobs 
    CURSOR cr_job_duplicado(pr_job_name IN VARCHAR2
                           ,pr_dhexcjob IN DATE) IS
      SELECT COUNT(*) qtde
        FROM dba_scheduler_jobs job
       WHERE job.owner                = 'CECRED' --Fixo
         AND job.job_name             LIKE pr_job_name||'%' -- mesmo job, mesma cooperativa e mesmo horário do dia
         AND job.next_run_date  BETWEEN (pr_dhexcjob-(15/60/24)) AND (pr_dhexcjob+(15/60/24)); -- JOBS 15 minutos antes ou depois do agendamento atual
    
    vr_qtdejobs    NUMBER;
    
		-- Variável interna
		vr_dsconteu    crappco.dsconteu%TYPE;
		vr_dthrexe     TIMESTAMP;
		vr_jobname     VARCHAR2(100);
		vr_lstdados    gene0002.typ_split;
		vr_dtutil      DATE;
		
		-- Variável de críticas
    vr_dscritic    VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro    EXCEPTION;
		
	BEGIN
		
    -- Buscar o próximo dia útil
		vr_dtutil := gene0005.fn_valida_dia_util(pr_cdcooper => 3
		                                        ,pr_dtmvtolt => trunc(SYSDATE));
	  
    -- Se não for um dia útil						
    IF vr_dtutil <> trunc(SYSDATE) THEN
		   RETURN; -- finaliza
		END IF;
    
    -- Percorre os parametros da PCO
    FOR rw_crappco IN cr_crappco LOOP
			-- 
			vr_dsconteu := rw_crappco.dsconteu;

			-- Se não há horários cadastrados
			IF vr_dsconteu IS NULL THEN
				CONTINUE; -- pula para o próximo parametro
			END IF;
			
      -- Quebra os horários cadastrados
			vr_lstdados := gene0002.fn_quebra_string(pr_string => vr_dsconteu
																							,pr_delimit => ';');
                                              
			-- Parametro: 58 - Horario para envio dos arquivos PCPS para CIP
			IF rw_crappco.cdpartar = 58 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
    		  vr_dthrexe := TO_TIMESTAMP_TZ(TO_CHAR(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					-- Verifica se o horário do job é maior que o horário atual
          IF vr_dthrexe > SYSDATE THEN
            -- Zerar contador 
            vr_qtdejobs := 0;
            -- Nome do Job
            vr_jobname := 'JB_PCPS_ENVIA$';
            -- Busca a quantidade de jobs que estão agendados para executar 15 minutos antes e após esse horário
            OPEN  cr_job_duplicado(vr_jobname, vr_dthrexe);
            FETCH cr_job_duplicado INTO vr_qtdejobs;
            CLOSE cr_job_duplicado;
            --
            -- Se não há nenhum job agendado para horário próximo
            IF NVL(vr_qtdejobs, 0) = 0 THEN           
              --
            GENE0001.pc_submit_job(pr_cdcooper => 3,
                                   pr_cdprogra => 'PCPS0002',
                                   pr_dsplsql  => 'BEGIN PCPS0002.pc_processa_envio_PCPS; END;',
                                   pr_dthrexe  => vr_dthrexe,
                                   pr_interva  => NULL,
                                   pr_jobname  => vr_jobname,
                                   pr_des_erro => vr_dscritic);
            --
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro; -- Não podemos parar o processamento
            END IF;
            --
            END IF;
          END IF; 
				END LOOP;
      
      -- Parametro: 59 - Horario de processamento do arquivo de aceite compulsorio
			ELSIF rw_crappco.cdpartar = 59 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
          vr_dthrexe := TO_TIMESTAMP_TZ(TO_CHAR(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					-- Verifica se o horário do job é maior que o horário atual
          IF vr_dthrexe > SYSDATE THEN
            -- Zerar contador 
            vr_qtdejobs := 0;
            -- Nome do Job
            vr_jobname := 'JB_PCPS_COMPULS$';
            -- Busca a quantidade de jobs que estão agendados para executar 15 minutos antes e após esse horário
            OPEN  cr_job_duplicado(vr_jobname, vr_dthrexe);
            FETCH cr_job_duplicado INTO vr_qtdejobs;
            CLOSE cr_job_duplicado;
            --
            -- Se não há nenhum job agendado para horário próximo
            IF NVL(vr_qtdejobs, 0) = 0 THEN           
              --
            GENE0001.pc_submit_job(pr_cdcooper => 3,
                                   pr_cdprogra => 'PCPS0002',
                                   pr_dsplsql  => 'BEGIN PCPS0002.pc_proc_arquivo_APCS(16); END;',
                                   pr_dthrexe  => vr_dthrexe,
                                   pr_interva  => NULL,
                                   pr_jobname  => vr_jobname,
                                   pr_des_erro => vr_dscritic);
            --
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro; -- Não podemos parar o processamento
            END IF;
            --
            END IF;
          END IF;
				END LOOP;
			
      -- Parametro: 60 - Horario para envio dos e-mails de pendencias de avaliacao de solicitacao de portabilidade
			ELSIF rw_crappco.cdpartar = 60 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
          vr_dthrexe := TO_TIMESTAMP_TZ(TO_CHAR(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					-- Verifica se o horário do job é maior que o horário atual
          IF vr_dthrexe > SYSDATE THEN
            -- Zerar contador 
            vr_qtdejobs := 0;
            -- Nome do Job
            vr_jobname := 'JB_PCPS_EMAIL$';
            -- Busca a quantidade de jobs que estão agendados para executar 15 minutos antes e após esse horário
            OPEN  cr_job_duplicado(vr_jobname, vr_dthrexe);
            FETCH cr_job_duplicado INTO vr_qtdejobs;
            CLOSE cr_job_duplicado;
            --
            -- Se não há nenhum job agendado para horário próximo
            IF NVL(vr_qtdejobs, 0) = 0 THEN           
            --
            GENE0001.pc_submit_job(pr_cdcooper => 3,
                                   pr_cdprogra => 'PCPS0002',
                                   pr_dsplsql  => 'BEGIN PCPS0002.pc_email_pa_portabilidade(); END;',
                                   pr_dthrexe  => vr_dthrexe,
                                   pr_interva  => NULL,
                                   pr_jobname  => vr_jobname,
                                   pr_des_erro => vr_dscritic);
            --
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro; -- Não podemos parar o processamento
            END IF;
            --
            END IF;
          END IF;
				END LOOP;
		
      -- Parametro: 62 - Horario para processamento dos arquivos de retorno PCPS
			ELSIF rw_crappco.cdpartar = 62 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
          vr_dthrexe := TO_TIMESTAMP_TZ(TO_CHAR(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					-- Verifica se o horário do job é maior que o horário atual
          IF vr_dthrexe > SYSDATE THEN
            -- Zerar contador 
            vr_qtdejobs := 0;
            -- Nome do Job
            vr_jobname := 'JB_PCPS_RECEBE$';
            -- Busca a quantidade de jobs que estão agendados para executar 15 minutos antes e após esse horário
            OPEN  cr_job_duplicado(vr_jobname, vr_dthrexe);
            FETCH cr_job_duplicado INTO vr_qtdejobs;
            CLOSE cr_job_duplicado;
            --
            -- Se não há nenhum job agendado para horário próximo
            IF NVL(vr_qtdejobs, 0) = 0 THEN           
            --
            GENE0001.pc_submit_job(pr_cdcooper => 3,
                                   pr_cdprogra => 'PCPS0002',
                                   pr_dsplsql  => 'BEGIN PCPS0002.pc_processa_receb_PCPS; END;',
                                   pr_dthrexe  => vr_dthrexe,
                                   pr_interva  => NULL,
                                   pr_jobname  => vr_jobname,
                                   pr_des_erro => vr_dscritic);
            --
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro; -- Não podemos parar o processamento
            END IF;
            --
            END IF;
          END IF;
				END LOOP;
				--
			END IF;
		END LOOP;
    
    -- Agendar processamento do arquivo APCS109 - Irá descompactar e mover os arquivos APCS109 do dia
    vr_dthrexe := TO_TIMESTAMP_TZ(TO_CHAR(SYSDATE ,'DD/MM/RRRR') || ' 22:30' || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
    
    -- Verifica se o horário do job é maior que o horário atual
    IF vr_dthrexe > SYSDATE THEN
      -- Zerar contador 
      vr_qtdejobs := 0;
      -- Nome do Job
      vr_jobname := 'JB_PCPS_APCS109$';
      -- Busca a quantidade de jobs que estão agendados para executar 15 minutos antes e após esse horário
      OPEN  cr_job_duplicado(vr_jobname, vr_dthrexe);
      FETCH cr_job_duplicado INTO vr_qtdejobs;
      CLOSE cr_job_duplicado;
      --
      -- Se não há nenhum job agendado para horário próximo
      IF NVL(vr_qtdejobs, 0) = 0 THEN           
      --
      GENE0001.pc_submit_job(pr_cdcooper => 3,
                             pr_cdprogra => 'PCPS0002',
                             pr_dsplsql  => 'BEGIN PCPS0002.pc_proc_arquivo_APCS(17); END;',
                             pr_dthrexe  => vr_dthrexe,
                             pr_interva  => NULL,
                             pr_jobname  => vr_jobname,
                             pr_des_erro => vr_dscritic);
      --
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro; -- Não podemos parar o processamento
      END IF;
      END IF;
    END IF;
    
	EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20002, 'Erro na rotina pc_agenda_jobs: '||SQLERRM);
	END pc_agenda_jobs;
  
  
  PROCEDURE pc_processa_envio_PCPS IS
		/* .............................................................................
			Programa: pc_processa_envio_PCPS
			Sistema : CRED
			Autor   : Renato - Supero
			Data    : 07/12/2018                Ultima atualizacao:
	  
			Dados referentes ao programa:
	 
			Frequencia: Sempre que for chamado
	   
			Objetivo  : Procedure responsável por realizar as chamadas das rotinas de 
                  envios do PCPS
	  
			Alteracoes:
		..............................................................................*/		
    
	BEGIN
		
    -- Chamar a rotina de envio de solicitações
    BEGIN
      /*********************************/
      PCPS0002.pc_gera_arquivo_APCS(10); 
      /*********************************/
   EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    
    -- Chamar a rotina de processamento de resposta de solicitações
    BEGIN
      /*********************************/
      PCPS0002.pc_gera_arquivo_APCS(12); 
      /*********************************/
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    
    -- Chamar a rotina de processamento de envio de cancelamentos
    BEGIN
      /*********************************/
      PCPS0002.pc_gera_arquivo_APCS(14); 
      /*********************************/
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    -- Alteração - Gilberto/Supero Janeiro 2019
    -- Chamar a rotina de processamento de envio de contestação
    BEGIN
      PCPS0002.pc_gera_arquivo_APCS(18); 
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    -- Chamar a rotina de processamento de envio de resposta de contestação
    BEGIN
      PCPS0002.pc_gera_arquivo_APCS(20); 
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    --
    BEGIN
      PCPS0002.pc_gera_arquivo_APCS(23); 
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
	EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro na rotina PC_PROCESSA_ENVIO_PCPS: '||SQLERRM);
	END pc_processa_envio_PCPS;
  
  
  PROCEDURE pc_processa_receb_PCPS IS
		/* .............................................................................
			Programa: pc_processa_receb_PCPS
			Sistema : CRED
			Autor   : Renato - Supero
			Data    : 07/12/2018                Ultima atualizacao:
	  
			Dados referentes ao programa:
	 
			Frequencia: Sempre que for chamado
	   
			Objetivo  : Procedure responsável por realizar as chamadas das rotinas de 
                  processamento de arquivos recebidos do PCPS
	  
			Alteracoes:
		..............................................................................*/		
    
	BEGIN
		
    -- Chamar a rotina de envio de solicitações
    BEGIN
      /*********************************/
      PCPS0002.pc_proc_arquivo_APCS(11); 
      /*********************************/
   EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
     
    -- Chamar a rotina de processamento de resposta de solicitações
    BEGIN
      /*********************************/
      PCPS0002.pc_proc_arquivo_APCS(13);
      /*********************************/
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    
    -- Chamar a rotina de processamento de envio de cancelamentos
    BEGIN
      /*********************************/
      PCPS0002.pc_proc_arquivo_APCS(15); 
      /*********************************/
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    -- Alteração - Gilberto/Supero Janeiro 2019
    -- Chamar a rotina de envio de retorno da contestação
    BEGIN
      /*********************************/
      PCPS0002.pc_proc_arquivo_APCS(19); 
      /*********************************/
   EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    -- Alteração - Gilberto/Supero Janeiro 2019
    BEGIN
      /*********************************/
      PCPS0002.pc_proc_arquivo_APCS(21);
      /*********************************/
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    -- Alteração - Gilberto/Supero Janeiro 2019
    BEGIN
      /*********************************/
      PCPS0002.pc_proc_arquivo_APCS(22);
      /*********************************/
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
    -- Alteração - Gilberto/Supero Fevereiro 2019
    BEGIN
      /*********************************/
      PCPS0002.pc_proc_arquivo_APCS(24);
      /*********************************/
    EXCEPTION
      WHEN OTHERS THEN
        -- Não apresentar erro no JOB, erros serão gerados no LOG
        NULL;
    END;
	EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro na rotina PC_PROCESSA_RECEB_PCPS: '||SQLERRM);
	END pc_processa_receb_PCPS;
  
  
BEGIN
  
  -- Buscar o Numero do ISPB para a cooperativa
  OPEN  cr_crapban;
  FETCH cr_crapban INTO vr_nrispb_emissor;
    
  -- Se não encontrar registros
  IF cr_crapban%NOTFOUND THEN
    -- Fechar o cursor
    CLOSE cr_crapban;
    
    -- Raise
    raise_application_error(-20000,'Código ISPB não encontrado.');
  END IF;
    
  -- Fechar o cursor
  CLOSE cr_crapban;
  
END PCPS0002;
/
