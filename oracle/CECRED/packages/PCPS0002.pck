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
  
  -- Procedure para gerar os arquivos APCS
  PROCEDURE pc_gera_arquivo_APCS (pr_tparquiv   IN crapscb.tparquiv%TYPE);
  
  -- Buscar parametros e processar o arquivo especificado na tabela CRAPSCB
  PROCEDURE pc_proc_arquivo_APCS (pr_tparquiv   IN crapscb.tparquiv%TYPE);
  
  -- Comunicas pendencias de avaliação
  PROCEDURE pc_email_pa_portabilidade;
	
	PROCEDURE pc_agenda_jobs;
    
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

  ---------------------------------------------------------------------------------------------------------------*/

  --> Declaração geral de exception
  
  
  -- Buscar o numero do ISPB da Central -> Mesmo que o CNPJ Base
  CURSOR cr_crapban IS
    SELECT lpad(ban.nrispbif,8,'0') nrispbif
      FROM crapban ban
     WHERE ban.cdbccxlt = 085; -- AILOS

  -- Variáveis Globais e constantes
  vr_dsarqlg         CONSTANT VARCHAR2(30) := 'pcps_'||to_char(SYSDATE,'RRRRMM')||'.log'; -- Nome do arquivo de log mensal
  vr_nrispb_emissor           VARCHAR2(8); -- ISPB Ailos - Valor atribuido via cursor
  vr_nrispb_destina  CONSTANT VARCHAR2(8)  := '02992335'; -- ISPB CIP
  vr_datetimeformat  CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS'; -- Formato campo dataHora
  vr_dateformat      CONSTANT VARCHAR2(10) := 'YYYY-MM-DD';    -- Formato campo data
  vr_dsdominioerro   CONSTANT VARCHAR2(20) := 'ERRO_PCPS_CIP'; -- Dominio padrão para erros PCPS
  vr_dsmotivoreprv   CONSTANT VARCHAR2(30) := 'MOTVREPRVCPORTDDCTSALR';
  vr_dsmotivocancel  CONSTANT VARCHAR2(30) := 'MOTVCANCELTPORTDDCTSALR';
  vr_dsmotivoaceite  CONSTANT VARCHAR2(30) := 'MOTVACTECOMPRIOPORTDDCTSALR';
  
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
    pr_nrsolici := to_number(SUBSTR(pr_nrctpart, 15));
      
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
    pr_dsxmlarq := XMLTYPE.createXML('<APCSDOC xmlns="http://www.cip-bancos.org.br/ARQ/'||pr_dsdsigla||'.xsd"> '
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
  
/*  PROCEDURE pc_cria_conta_salario(pr_cdcooper   IN crapccs.cdcooper%TYPE
                                 ,pr_nrctaass   IN crapccs.nrdconta%TYPE -- Conta da CRAPASS
                                 ,pr_nrcpfcgc   IN crapccs.nrcpfcgc%TYPE 
                                 
                                 ,pr_dscritic  OUT VARCHAR2) IS  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_conta_salario
    --  Sistema  : Cred
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar registro de conta na CRAPCCS e caso não encontrar, criar o mesmo
    --
    -- Alteracoes: 
    --             
    ---------------------------------------------------------------------------------------------------------------
    
    -- CURSORES
    -- Buscar a conta salário
    CURSOR cr_crapccs(pr_cdcooper  crapccs.cdcooper%TYPE
                     ,pr_nrctaass  crapccs.nrdconta%TYPE 
                     ,pr_nrcpfcgc  crapccs.nrcpfcgc%TYPE ) IS
      SELECT ccs.rowid  dsdrowid
           , ccs.*
        FROM crapccs ccs
       WHERE ccs.cdcooper = pr_cdcooper
         --AND ccs.nrctaass = NVL(pr_nrctaass, ccs.nrctaass) -- VER RENATO - SOLICITAR CRIAÇÃO DO CAMPO 
         AND ccs.nrcpfcgc = pr_nrcpfcgc;
    rg_crapccs    cr_crapccs%ROWTYPE;
      
    -- VARIÁVEIS
    vr_dsxmlarq      XMLTYPE;
    vr_nmarquiv      VARCHAR2(100);
    vr_dscritic      VARCHAR2(1000);
    vr_dsmsglog      VARCHAR2(1000);
    vr_nrseqarq      NUMBER;
    vr_inddados      BOOLEAN;
    
    vr_exc_erro      EXCEPTION;
    
  BEGIN
    
    -- Busca cadastro de conta salário
    OPEN  cr_crapccs(pr_cdcooper
                    ,pr_nrctaass
                    ,pr_nrcpfcgc);
    FETCH cr_crapccs INTO rg_crapscb;
        
    -- Se não encontrar conta salário associada a conta do cooperado
    IF cr_crapccs%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapscb;
      
      -- Busca algum registro de conta salário para o CPF do cooperado
      OPEN  cr_crapccs(pr_cdcooper
                      ,NULL 
                      ,pr_nrcpfcgc);
      FETCH cr_crapccs INTO rg_crapscb;
      
      -- Se não encontrar conta salário pelo CPF
      IF cr_crapccs%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapscb;
        
        -- Deve inserir a nova conta salário para transferencia
        BEGIN
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPCSS: '
          
        END; 
             
      END IF;
      
      
      vr_dscritic := 'Parametrização do arquivo de tipo '||pr_tparquiv||' não encontrada.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar cursor
    CLOSE cr_crapscb;
  
    -- LOGS DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
        pc_gera_xml_APCS101(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_dscritic => vr_dscritic);
      WHEN 'APCS103' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_xml_APCS103(pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_dscritic => vr_dscritic);
      WHEN 'APCS105' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_xml_APCS105(pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
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
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
    -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsxmlarq.getClobVal()
                                ,pr_nmarqlog     => vr_dsarqlg);
    -- Gerar arquivo
    GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsxmlarq.getClobVal()
                                 ,pr_caminho  => rg_crapscb.dsdirarq
                                 ,pr_arquivo  => vr_nmarquiv
                                 ,pr_des_erro => vr_dscritic);
    
    -- Se houver retorno de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- LOG DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
    
    -- Commitar os dados processados
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- LOGS DE EXECUCAO
      BEGIN

        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
  */
  
  PROCEDURE pc_gera_xml_APCS101(pr_nmarqenv IN     VARCHAR2      --> Nome do arquivo 
                               ,pr_dsxmlarq IN OUT XMLTYPE       --> Conteúdo do arquivo
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_xml_APCS101
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
       WHERE ROWID = pr_dsdrowid;
       
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => 0
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
    
      /******************* INICIO - Grupo Portabilidade Conta Salário *******************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_cont => NULL);
      
      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => lpad(rg_dados.nrispb_destinataria,8,'0') );
            
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,rg_dados.nrsolicitacao);
      
      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart);
      
      /******************* INICIO - Grupo Cliente *******************/
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                   ,pr_tag_cont => NULL);
      
      -- CPF Cliente
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                   ,pr_tag_nova => 'CPFCli'
                   ,pr_tag_cont => LPAD(rg_dados.nrcpfcgc,11,'0'));
            
      -- Nome Cliente
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                   ,pr_tag_nova => 'NomCli'
                   ,pr_tag_cont => SUBSTR(rg_dados.nmprimtl,1,80));
      
      -- Se foi informado o telefone
      IF rg_dados.nrddd_telefone IS NOT NULL AND rg_dados.nrtelefone IS NOT NULL THEN
      
        -- Telefone Cliente
        BEGIN
          vr_dstelefo := '('||LPAD(rg_dados.nrddd_telefone,2,'0')||')'||rg_dados.nrtelefone;
        EXCEPTION
          WHEN OTHERS THEN
            -- Indica erro de telefone inválido
            pc_reprova_solicitacao(rg_dados.dsdrowid, 58);
            -- Passa para o próximo registros
            CONTINUE;          
        END;
        
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'TelCli'
                     ,pr_tag_cont => vr_dstelefo);
        
      END IF;
      
      -- Se foi informado e-mail
      IF rg_dados.dsdemail IS NOT NULL THEN
        
        -- E-mail Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'EmailCli'
                     ,pr_tag_cont => rg_dados.dsdemail);
        
      END IF;
      
      -- Código Autenticação do Beneficiário  - Não será enviado
      --pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
      --             ,pr_tag_nova => 'CodAuttcBenfcrio'
      --             ,pr_tag_cont => NULL);
      
      /******************* FIM - Grupo Cliente *******************/
      
      /******************* INICIO - Grupo Participante Folha Pagamento *******************/
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_cont => NULL);
      
      -- ISPB Participante Folha Pagamento
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'ISPBPartFolhaPgto'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0') );
      
      -- CNPJ Participante Folha Pagamento
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'CNPJPartFolhaPgto'
                   ,pr_tag_cont => LPAD(rg_dados.nrcnpj_banco_folha,14,'0') );
      
      -- CNPJ do Empregador
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'CNPJEmprdr'
                   ,pr_tag_cont => LPAD(rg_dados.nrcnpj_empregador,14,'0') );
      
      -- CNPJ Participante Folha Pagamento
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                   ,pr_tag_nova => 'DenSocEmprdr'
                   ,pr_tag_cont => rg_dados.dsnome_empregador );
      
      /******************* FIM - Grupo Participante Folha Pagamento *******************/
            
      /******************* INICIO - Grupo Destino *******************/
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_cont => NULL);
      
      -- ISPB Participante Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'ISPBPartDest'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_destinataria,8,'0') );
      
      -- CNPJ Participante Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'CNPJPartDest'
                   ,pr_tag_cont => LPAD(rg_dados.nrcnpj_destinataria,14,'0') );
      
      -- Tipo de Conta Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'TpCtDest'
                   ,pr_tag_cont => rg_dados.cdtipo_conta );
      
      -- Agência Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'AgCliDest'
                   ,pr_tag_cont => rg_dados.cdagencia );
      
      -- Conta Corrente Destino
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                   ,pr_tag_nova => 'CtCliDest'
                   ,pr_tag_cont => rg_dados.nrdconta );
      
      -- Conta Pagamento Destino - NÃO SERÁ ENVIADO POIS CONTA É TIPO CC - CONTA CORRENTE
      --pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
      --             ,pr_tag_nova => 'CtPagtoDest'
      --             ,pr_tag_cont => NULL );
      
      /******************* FIM - Grupo Destino *******************/
      /******************* FIM - Grupo Portabilidade Conta Salário *******************/
      
      -- Atualizar registro processado
      pc_portabilidade_OK(rg_dados.dsdrowid);
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_xml_APCS101. ' ||SQLERRM;
  END pc_gera_xml_APCS101;
  
  
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
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS101';
    
    -- CURSORES
    -- Retorna as aprovações que ocorreram no arquivo
    CURSOR cr_ret_aprova IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrctrlpart
           , nrportdpcs
        FROM DATA 
           , XMLTABLE(XMLNAMESPACES(default 'http://www.cip-bancos.org.br/ARQ/APCS101.xsd' )
                     ,('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_PortddCtSalrActo')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrctrlpart  VARCHAR2(20) PATH 'NumCtrlPart'
                            , nrportdpcs  NUMBER       PATH 'NUPortddPCS');
    
    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_ret_reprova IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro
           , nrctrlpart
        FROM DATA 
           , XMLTABLE(XMLNAMESPACES(default 'http://www.cip-bancos.org.br/ARQ/APCS101.xsd')
                     ,('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_PortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro   VARCHAR2(20) PATH '@CodErro'
                            , nrctrlpart  NUMBER       PATH 'NumCtrlPart');
    
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
    
    vr_dsmsglog      VARCHAR2(1000);
    
  BEGIN
    
    -- Percorrer todas as aprovações retornadas
    FOR rg_dados IN cr_ret_aprova LOOP
      
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
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
        
      -- Atualizar o número da portabilidade do registro
      UPDATE tbcc_portabilidade_envia t
         SET t.nrnu_portabilidade = rg_dados.nrportdpcs
       WHERE ROWID = rg_prtenvia.dsdrowid;
      
    END LOOP;
  
    -- Percorrer todas as aprovações retornadas
    FOR rg_dados IN cr_ret_reprova LOOP
      
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
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
        
      -- Atualizar o número da portabilidade do registro
      UPDATE tbcc_portabilidade_envia t
         SET t.nrnu_portabilidade = NULL
           , t.idsituacao         = 8 -- Rejeitada (dominio: SIT_PORTAB_SALARIO_ENVIA)
           , t.dtretorno          = SYSDATE
           , t.dsdominio_motivo   = vr_dsdominioerro -- Dominio dos erros da CIP
           , t.cdmotivo           = rg_dados.dscoderro
       WHERE ROWID = rg_prtenvia.dsdrowid;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS101. ' ||SQLERRM;
  END pc_proc_RET_APCS101;
  
  
  PROCEDURE pc_proc_xml_APCS102(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_nmarquiv  IN VARCHAR2      --> Nome do arquivo lido
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
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS102';
        
    -- CURSOR
    CURSOR cr_dadosret IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nridenti
           , nrnuport
           , nrcpfcgc
           , dsnomcli
           , dstelefo
           , dsdemail
           , nrispbfl
           , nrcnpjfl
           , nrcnpjep
           , nmdoempr
           , nrispbdt
           , nrcnpjdt
           , cdtipcta
           , cdagedst
           , nrctadst
           , nrctapgt
        FROM DATA
           , XMLTABLE(XMLNAMESPACES(default 'http://www.cip-bancos.org.br/ARQ/APCS102.xsd')
                     ,('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_PortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nridenti  NUMBER       PATH 'IdentdPartAdmtd'
                            , nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrcpfcgc  NUMBER       PATH 'Grupo_APCS102_Cli/CPFCli'
                            , dsnomcli  VARCHAR2(80) PATH 'Grupo_APCS102_Cli/NomCli'
                            , dstelefo  VARCHAR2(20) PATH 'Grupo_APCS102_Cli/TelCli'
                            , dsdemail  VARCHAR2(50) PATH 'Grupo_APCS102_Cli/EmailCli'
                            , nrispbfl  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/ISPBPartFolhaPgto'
                            , nrcnpjfl  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/CNPJPartFolhaPgto'
                            , nrcnpjep  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/CNPJEmprdr'
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
    vr_dsmsglog     VARCHAR2(1000);
    vr_dscritic     VARCHAR2(1000);
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
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret LOOP
      
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
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
      
      -- Se encontrar mais de um registro 
      IF rg_crapass.idqtdreg > 1 THEN
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
        IF rg_crapttl.nrcpfemp <> rg_dadosret.nrcnpjep THEN
          -- Deve marcar os registro como reprovado
          vr_idsituac := 3; -- Reprovada
          vr_dsdomrep := vr_dsmotivoreprv;
          vr_cdcodrep := 3; -- CNPJ do empregador não encontrado
          vr_dtavalia := SYSDATE;
          vr_cdoperad := '1';
        END IF;
        
        -- Verificar se o tipo de conta não permite transferencias - Se é conta salário
        IF rg_crapass.cdmodali = 2 THEN
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
        vr_cdagedst := NULL;
        vr_nrctadst := rg_dadosret.nrctapgt;
      ELSE 
        vr_cdagedst := rg_dadosret.cdagedst;
        vr_nrctadst := rg_dadosret.nrctadst;
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
                          ,rg_dadosret.nrcnpjep -- nrcnpj_empregador
                          ,rg_dadosret.nmdoempr -- dsnome_empregador
                          ,rg_dadosret.nrispbdt -- nrispb_destinataria
                          ,rg_dadosret.nrcnpjdt -- nrcnpj_destinataria
                          ,rg_dadosret.cdtipcta -- cdtipo_cta_destinataria
                          ,vr_cdagedst          -- cdagencia_destinataria
                          ,vr_nrctadst          -- nrdconta_destinataria
                          ,SYSDATE              -- dtsolicitacao
                          ,vr_idsituac          -- idsituacao
                          ,vr_dtavalia          -- dtavaliacao
                          ,vr_dsdomrep          -- dsdominio_motivo
                          ,vr_cdcodrep          -- cdmotivo
                          ,vr_cdoperad          -- cdoperador
                          ,pr_nmarquiv);        -- nmarquivo_solicitacao
                 
      
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta a mensagem de erro
          vr_dscritic := 'Erro ao inserir registro de portabilidade: '||SQLERRM;
          
          -- LOGS DE EXECUCAO
          BEGIN
            vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
  
  
  PROCEDURE pc_gera_xml_APCS103(pr_dsxmlarq IN OUT XMLTYPE       --> Conteúdo do arquivo
                               ,pr_inddados    OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_dscritic    OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_xml_APCS103
    --  Sistema  : Procedure para gerar o arquivo: 
    --                        APCS103 - Instituição Banco da Folha responde solicitação de Portabilidade 
    --                                  Aprovada ou Reprovada.
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
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
      SELECT ROWID dsdrowid
           , t.*
        FROM tbcc_portabilidade_recebe t
       WHERE t.idsituacao  > 1  -- 1 = Pendente / 2 = Aprovada / 3 = Reprovada
         AND t.dtavaliacao IS NOT NULL
         AND t.dtretorno   IS NULL;
    
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS103';

    vr_dsxmlarq      xmltype;         --> XML do arquivo
    vr_exc_erro      EXCEPTION;       --> Controle de exceção
    
    vr_nrctpart      VARCHAR2(20); 
    vr_dscritic      VARCHAR2(1000);
    
    -- Procedure para atualizar o registro de portabilidade retornado
    PROCEDURE pc_atualiza_retorno(pr_dsdrowid  IN VARCHAR2) IS
    BEGIN
      
      UPDATE tbcc_portabilidade_recebe  t
         SET t.dtretorno = SYSDATE
       WHERE ROWID = pr_dsdrowid;
       
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => 0
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
    
      /*************** INICIO - Grupo Portabilidade Conta Salário ***************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_cont => NULL);

      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => LPAD(rg_dados.nrispb_destinataria,8,'0') );
      
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,0); -- Passar zero, pois não tem contador nos recebidos, o controle é
                                             -- feito através do NU Portabilidade
      
      -- Número de Controle do Participante
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart );
      
      -- Número único da Portabilidade PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                   ,pr_tag_nova => 'NUPortddPCS'
                   ,pr_tag_cont => rg_dados.nrnu_portabilidade );
      
      -- Se a solicitação foi reprovada
      IF rg_dados.idsituacao = 3 THEN
      
        /*************** INICIO - Grupo Reprova Portabilidade Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrRepvd'
                     ,pr_tag_cont => NULL );
      
        -- Motivo Reprovação Portabilidade de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrRepvd'
                     ,pr_tag_nova => 'MotvReprvcPortddCtSalr'
                     ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0') );
    
        -- Data Cancelamento Portabilidade de Conta Salário
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrRepvd'
                     ,pr_tag_nova => 'DtReprvcPortddCtSalr'
                     ,pr_tag_cont => to_char(SYSDATE,vr_dateformat) );
      
        /*************** FIM - Grupo Reprova Portabilidade Conta Salário ***************/
      
      ELSE 
        
        /*************** INICIO - Grupo Aprova Portabilidade Conta Salário ***************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalr'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_cont => NULL );
        
      
        /******************* INICIO - Grupo Cliente *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_cont => NULL);
      
        -- CPF Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'CPFCli'
                     ,pr_tag_cont => LPAD(rg_dados.nrcpfcgc,11,'0'));
            
        -- Nome Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'NomCli'
                     ,pr_tag_cont => SUBSTR(rg_dados.nmprimtl,1,80));
      
        -- Telefone Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'TelCli'
                     ,pr_tag_cont => rg_dados.dstelefone);
      
        -- E-mail Cliente
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
                     ,pr_tag_nova => 'EmailCli'
                     ,pr_tag_cont => rg_dados.dsdemail);
      
        -- Código Autenticação do Beneficiário  - Não será enviado
        --pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Cli'
        --             ,pr_tag_nova => 'CodAuttcBenfcrio'
        --             ,pr_tag_cont => NULL);
      
        /******************* FIM - Grupo Cliente *******************/
      
        /******************* INICIO - Grupo Participante Folha Pagamento *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_cont => NULL);
      
        -- ISPB Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'ISPBPartFolhaPgto'
                     ,pr_tag_cont => LPAD(rg_dados.nrispb_banco_folha,8,'0') );
        
        -- CNPJ Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'CNPJPartFolhaPgto'
                     ,pr_tag_cont => LPAD(rg_dados.nrcnpj_banco_folha,14,'0') );
        
        -- CNPJ do Empregador
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'CNPJEmprdr'
                     ,pr_tag_cont => LPAD(rg_dados.nrcnpj_empregador,14,'0') );
        
        -- CNPJ Participante Folha Pagamento
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_FolhaPgto'
                     ,pr_tag_nova => 'DenSocEmprdr'
                     ,pr_tag_cont => rg_dados.dsnome_empregador );
        
        /******************* FIM - Grupo Participante Folha Pagamento *******************/
            
        /******************* INICIO - Grupo Destino *******************/
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_PortddCtSalrAprovd'
                     ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_cont => NULL);
        
        -- ISPB Participante Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'ISPBPartDest'
                     ,pr_tag_cont => LPAD(rg_dados.nrispb_destinataria,8,'0') );
        
        -- CNPJ Participante Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'CNPJPartDest'
                     ,pr_tag_cont => LPAD(rg_dados.nrcnpj_destinataria,14,'0') );
        
        -- Tipo de Conta Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'TpCtDest'
                     ,pr_tag_cont => rg_dados.cdtipo_cta_destinataria );
        
        -- Agência Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'AgCliDest'
                     ,pr_tag_cont => rg_dados.cdagencia_destinataria );
        
        -- Conta Corrente Destino
        pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
                     ,pr_tag_nova => 'CtCliDest'
                     ,pr_tag_cont => rg_dados.nrdconta );
        
        -- Conta Pagamento Destino - NÃO SERÁ ENVIADO POIS CONTA É TIPO CC - CONTA CORRENTE
        --pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_Dest'
        --             ,pr_tag_nova => 'CtPagtoDest'
        --             ,pr_tag_cont => NULL );
        
        /******************* FIM - Grupo Destino *******************/
        /******************* FIM - Grupo Aprova Portabilidade Conta Salário  *******************/
        
      END IF;
      
      -- Atualizar registro processado
      pc_atualiza_retorno(rg_dados.dsdrowid);
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_xml_APCS103. ' ||SQLERRM;
  END pc_gera_xml_APCS103;
  
  
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
    --             
    ---------------------------------------------------------------------------------------------------------------

    -- CONTANTES
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS103';
    
    -- CURSORES
    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_ret_reprova IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro
           , nrportdpcs
        FROM DATA 
           , XMLTABLE(XMLNAMESPACES(default 'http://www.cip-bancos.org.br/ARQ/APCS103.xsd' )
                     ,('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_PortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro  VARCHAR2(20) PATH '@CodErro'
                            , nrportdpcs VARCHAR2(50) PATH 'NUPortddPCS');
    
    -- Retornar o registro correspondente enviado
    CURSOR cr_prtreceb(pr_nrnuport   tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE) IS
      SELECT ROWID dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_prtreceb   cr_prtreceb%ROWTYPE;
    
    -- Variáveis
    vr_dsmsglog      VARCHAR2(1000);
        
  BEGIN
    
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_ret_reprova LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtreceb(rg_dados.nrportdpcs);
      FETCH cr_prtreceb INTO rg_prtreceb;
      
      -- Se não encontrar registro
      IF cr_prtreceb%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtreceb;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
      CLOSE cr_prtreceb;
               
      -- Atualizar a situação do registro para que seja reavaliado e reenviado
      UPDATE tbcc_portabilidade_recebe t
         SET t.idsituacao         = 4 -- Rejeitado (dominio: SIT_PORTAB_SALARIO_RECEBE)
           , t.dtretorno          = SYSDATE
           , t.dtavaliacao        = NULL
           , t.dsdominio_motivo   = vr_dsdominioerro -- Dominio dos erros da CIP
           , t.cdmotivo           = rg_dados.dscoderro
       WHERE ROWID = rg_prtreceb.dsdrowid;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_RET_APCS103. ' ||SQLERRM;
  END pc_proc_RET_APCS103;
  
  
  PROCEDURE pc_proc_xml_APCS104(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
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
    CURSOR cr_dadosret IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , idaprova
           , nrmotrep
           , to_date(dtreprova, vr_dateformat) dtreprova
        FROM DATA
           , XMLTABLE(('/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_PortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , idaprova  NUMBER       PATH 'Grupo_APCS104_PortddCtSalrAprovd/Grupo_APCS104_Cli/1'
                            , nrmotrep  NUMBER       PATH 'Grupo_APCS104_PortddCtSalrRepvd/MotvReprvcPortddCtSalr'
                            ,dtreprova  VARCHAR2(30) PATH 'Grupo_APCS104_PortddCtSalrRepvd/DtReprvcPortddCtSalr' );
    
    -- Buscar a solicitação da portabilidade 
    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_envia t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Variáveis 
    vr_dsmsglog     VARCHAR2(1000);
    
  BEGIN
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosret.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
                         || 'PCPS0002.pc_proc_xml_APCS104'
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
    
      -- Se o registro está indicando aprovação
      IF rg_dadosret.idaprova = 1 THEN
        
        -- Atualiza a solicitação para aprovada 
        UPDATE tbcc_portabilidade_envia t
           SET t.idsituacao = 3 -- Aprovada
             , t.dtretorno  = SYSDATE
         WHERE ROWID = rg_portab.dsdrowid;
      
      ELSE 
        
        -- Atualiza a solicitação para Reprovada
        UPDATE tbcc_portabilidade_envia t
           SET t.idsituacao       = 4 -- Reprovada
             , t.dsdominio_motivo = vr_dsmotivoreprv
             , t.cdmotivo         = rg_dadosret.nrmotrep
             , t.dtretorno        = SYSDATE -- Gravar o dia atual ao invés da data do arquivo
         WHERE ROWID = rg_portab.dsdrowid;
      
      END IF;
    
    END LOOP;
        
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS104. ' ||SQLERRM;
  END pc_proc_xml_APCS104;
  
  
  PROCEDURE pc_gera_xml_APCS105(pr_dsxmlarq  IN OUT XMLTYPE       --> XML gerado
                               ,pr_inddados     OUT BOOLEAN       --> Indica se o arquivo possui dados
                               ,pr_dscritic     OUT VARCHAR2) IS  --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_xml_APCS105
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
    
    -- Procedure para atualizar o registro de portabilidade para Aguardando Cancelamento
    PROCEDURE pc_cancelamento_solicitado(pr_dsdrowid  IN VARCHAR2) IS
    BEGIN
      
      UPDATE tbcc_portabilidade_envia  t
         SET t.idsituacao       = 6 -- Aguardando cancelamento
       WHERE ROWID = pr_dsdrowid;
       
    END;
    
    -- Rotina generica para inserir os tags - Reduzir parametros e centralizar tratamento de erros
    PROCEDURE pc_insere_tag(pr_tag_pai  IN VARCHAR2 
                           ,pr_tag_nova IN VARCHAR2
                           ,pr_tag_cont IN VARCHAR2)  IS
      
    BEGIN
      
      -- Inserir a tag
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => pr_tag_pai
                            ,pr_posicao  => 0
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
    
      /******************* INICIO - Grupo Portabilidade Conta Salário *******************/
      pc_insere_tag(pr_tag_pai  => vr_dsapcsdoc
                   ,pr_tag_nova => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_cont => NULL);

      -- Identificador Participante Administrativo - CNPJ Base
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'IdentdPartAdmtd'
                   ,pr_tag_cont => lpad(rg_dados.nrispb_destinataria,8,'0') );
      
      -- Formar o número de controle, conforme chave da tabela
      vr_nrctpart := fn_gera_NumCtrlPart(rg_dados.cdcooper
                                        ,rg_dados.nrdconta
                                        ,rg_dados.nrsolicitacao);
      
      -- Número de Controle do Participante                                  
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'NumCtrlPart'
                   ,pr_tag_cont => vr_nrctpart);
      
      -- Número único da Portabilidade PCS
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'NUPortddPCS'
                   ,pr_tag_cont => rg_dados.nrnu_portabilidade);
      
      -- Motivo Cancelamento Portabilidade de Conta Salário
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'MotvCanceltPortddCtSalr'
                   ,pr_tag_cont => LPAD(rg_dados.cdmotivo,3,'0') );
    
      -- Data Cancelamento Portabilidade de Conta Salário
      pc_insere_tag(pr_tag_pai  => 'Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr'
                   ,pr_tag_nova => 'DtCanceltPortddCtSalr'
                   ,pr_tag_cont => to_char(SYSDATE,vr_dateformat) );
          
      /******************* FIM - Grupo Portabilidade Conta Salário *******************/
      
      -- Atualizar registro processado
      pc_cancelamento_solicitado(rg_dados.dsdrowid);
      
    END LOOP;
    
    -- Retorna o XML do arquivo
    pr_dsxmlarq := vr_dsxmlarq;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_gera_xml_APCS105. ' ||SQLERRM;
  END pc_gera_xml_APCS105;
  
  
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
    -- Retorna as rejeições que ocorreram no arquivo
    CURSOR cr_ret_reprova IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT dscoderro
           , nrportdpcs
        FROM DATA 
           , XMLTABLE(XMLNAMESPACES(default 'http://www.cip-bancos.org.br/ARQ/APCS105.xsd' )
                     ,('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'RET/Grupo_'||vr_dsapcsdoc||'RET_CancelPortddCtSalrRecsd')
                      PASSING XMLTYPE(xml)
                      COLUMNS dscoderro  VARCHAR2(20) PATH '@CodErro'
                            , nrportdpcs VARCHAR2(50) PATH 'NUPortddPCS');
    
    -- Retornar o registro correspondente enviado
    CURSOR cr_prtreceb(pr_nrnuport   tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE) IS
      SELECT ROWID dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_prtreceb   cr_prtreceb%ROWTYPE;
    
    -- Variáveis
    vr_dsmsglog      VARCHAR2(1000);
        
  BEGIN
    
    
    -- Percorrer todas as rejeições
    FOR rg_dados IN cr_ret_reprova LOOP
      
      -- Buscar o registro de envio
      OPEN  cr_prtreceb(rg_dados.nrportdpcs);
      FETCH cr_prtreceb INTO rg_prtreceb;
      
      -- Se não encontrar registro
      IF cr_prtreceb%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_prtreceb;
      
        -- Registrar mensagem no log e pular para o próximo registro
        BEGIN
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
      CLOSE cr_prtreceb;
               
      -- Atualizar a situação do registro para que seja reavaliado e reenviado
      UPDATE tbcc_portabilidade_recebe t
         SET t.idsituacao         = 4 -- Rejeitado (dominio: SIT_PORTAB_SALARIO_RECEBE)
           , t.dtretorno          = SYSDATE
           , t.dtavaliacao        = NULL
           , t.dsdominio_motivo   = vr_dsdominioerro -- Dominio dos erros da CIP
           , t.cdmotivo           = rg_dados.dscoderro
       WHERE ROWID = rg_prtreceb.dsdrowid;
    
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
    CURSOR cr_dadosret IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , nrmotcnl
           , to_date(dtcancel, vr_dateformat) dtcancel
        FROM DATA
           , XMLTABLE(('/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_CanceltPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrmotcnl  NUMBER       PATH 'MotvCancelPortddCtSalr'
                            , dtcancel  VARCHAR2(30) PATH 'DtCancelPortddCtSalr' );
    
    -- Buscar a solicitação da portabilidade 
    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Variáveis 
    vr_dsmsglog     VARCHAR2(1000);
    
  BEGIN
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosret.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
         SET t.idsituacao       = 5 -- Cancelar
           , t.dsdominio_motivo = vr_dsmotivocancel
           , t.cdmotivo         = rg_dadosret.nrmotcnl
           , t.dtretorno        = rg_dadosret.dtcancel
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
    CURSOR cr_dadosret IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nrnuport
           , nrmotact
           , to_date(dtaceite, vr_dateformat) dtaceite
        FROM DATA
           , XMLTABLE(('/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_ActeComprioPortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrmotact  NUMBER       PATH 'MotvActeComprioPortddCtSalr'
                            , dtaceite  VARCHAR2(30) PATH 'DtCancelPortddCtSalr' );
    
    -- Buscar a solicitação da portabilidade 
    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM tbcc_portabilidade_recebe t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    -- Variáveis 
    vr_dsmsglog     VARCHAR2(1000);
    
  BEGIN
    
    -- Percorrer todos os dados retornados no arquivo 
    FOR rg_dadosret IN cr_dadosret LOOP
  
      -- Buscar o registro pelo código da NU portabilidade
      OPEN  cr_portab(rg_dadosret.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      -- Se não encontrar a solicitação de portabilidade
      IF cr_portab%NOTFOUND THEN
        -- LOGS DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
        
        -- Fechar o cursor
        CLOSE cr_portab;
    
        -- Processar o próximo registro
        CONTINUE;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_portab;
     
      -- Atualiza a solicitação para CANCELADA
      UPDATE tbcc_portabilidade_recebe t
         SET t.idsituacao       = 2 -- Aprovada
           , t.dsdominio_motivo = vr_dsmotivoaceite
           , t.cdmotivo         = rg_dadosret.nrmotact
           , t.dtretorno        = rg_dadosret.dtaceite
       WHERE ROWID = rg_portab.dsdrowid;
      
    END LOOP;
        
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS108. ' ||SQLERRM;
  END pc_proc_xml_APCS108;
  
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
    vr_dsxmlarq      XMLTYPE;
    vr_nmarquiv      VARCHAR2(100);
    vr_dscritic      VARCHAR2(1000);
    vr_dsmsglog      VARCHAR2(1000);
    vr_nrseqarq      NUMBER;
    vr_inddados      BOOLEAN;
    
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
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
        pc_gera_xml_APCS101(pr_nmarqenv => vr_nmarquiv
                           ,pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_dscritic => vr_dscritic);
      WHEN 'APCS103' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_xml_APCS103(pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
                           ,pr_dscritic => vr_dscritic);
      WHEN 'APCS105' THEN
        -- Gerar o conteudo do arquivo
        pc_gera_xml_APCS105(pr_dsxmlarq => vr_dsxmlarq 
                           ,pr_inddados => vr_inddados
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
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
    -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsxmlarq.getClobVal()
                                ,pr_nmarqlog     => vr_dsarqlg);
    -- Gerar arquivo
    GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsxmlarq.getClobVal()
                                 ,pr_caminho  => rg_crapscb.dsdirarq
                                 ,pr_arquivo  => vr_nmarquiv
                                 ,pr_des_erro => vr_dscritic);
    
    -- Se houver retorno de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- LOG DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
    
    -- Commitar os dados processados
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- LOGS DE EXECUCAO
      BEGIN

        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
    --             pr_tparquiv = 10 -> APCS101RET - RETORNO Solicitação de Portabilidade de Salário
    --             pr_tparquiv = 11 -> APCS102    - PCS Informa Solicitação de Portabilidade de Conta Salário
    --             pr_tparquiv = 12 -> APCS103RET - RETORNO Instituição Banco da Folha responde solicitação de 
    --                                              Portabilidade Aprovada ou Reprovada. 
    --             pr_tparquiv = 13 -> APCS104    - CIP Informa a resposta da Solicitação de Portabilidade 
    --                                              Aprovada ou Reprovada
    --             pr_tparquiv = 14 -> APCS105RET - RETORNO Participante Envia Cancelamento de Portabilidade
    --             pr_tparquiv = 15 -> APCS106    - CIP repassa a Solicitação de Cancelamento
    --  Sigla    : PCPS
    --  Autor    : Renato Darosci - Supero
    --  Data     : Setembro/2018.                   Ultima atualizacao: --/--/----
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
    vr_dsmsglog      VARCHAR2(1000);
    vr_dspesqfl      VARCHAR2(30);
    vr_dsxmlarq      CLOB;
    vr_idretorn      BOOLEAN := FALSE; -- Indica processamento de arquivo de retorno
    
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
    
    -- Verifica se está processando arquivo de retorno
    IF pr_tparquiv IN (10,12,14) THEN
      vr_idretorn := TRUE;
    END IF;
    
    -- LOGS DE EXECUCAO
    BEGIN
      -- Se for processamento de retorno
      IF vr_idretorn THEN
        vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
                       || 'PCPS0002.pc_proc_arquivo_APCS'
                       || ' --> Processando arquivo de retorno '||rg_crapscb.dsdsigla||'RET - '||rg_crapscb.dsarquiv;
      ELSE
        vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
                       || 'PCPS0002.pc_proc_arquivo_APCS'
                       || ' --> Iniciando processamento '||rg_crapscb.dsdsigla||' - '||rg_crapscb.dsarquiv;
      END IF; 
      
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
    -- Se estiver processando retorno
    IF vr_idretorn THEN
      vr_dspesqfl := rg_crapscb.dsdsigla||'*RET.*';
    ELSE
      vr_dspesqfl := rg_crapscb.dsdsigla||'*.*';
    END IF;
    
    -- Buscar todos os arquivos no diretório específico
    GENE0001.pc_lista_arquivos(pr_lista_arquivo => vr_tbarquiv
                              ,pr_path          => rg_crapscb.dsdirarq
                              ,pr_pesq          => vr_dspesqfl);
    
    -- Se não encontrar arquivos
    IF vr_tbarquiv.COUNT() = 0 THEN
      -- LOGS DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
        vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
      
      -- Carregar o conteúdo do arquivo para um CLOB
      vr_dsxmlarq := GENE0002.fn_arq_para_clob(pr_caminho => rg_crapscb.dsdirarq
                                              ,pr_arquivo => vr_tbarquiv(vr_index));
      
      -- Verifica qual o conteúdo de arquivo deve ser gerado
      CASE rg_crapscb.dsdsigla
        WHEN 'APCS101' THEN
          -- Processar retorno do arquivo
          pc_proc_RET_APCS101(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS102' THEN
          -- Processar arquivo
          pc_proc_xml_APCS102(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_nmarquiv => vr_tbarquiv(vr_index)             
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS103' THEN
          -- Processar retorno do arquivo
          pc_proc_RET_APCS103(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS104' THEN
          -- Processar arquivo
          pc_proc_xml_APCS104(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS105' THEN
          -- Processar retorno do arquivo
          pc_proc_RET_APCS105(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS106' THEN
          -- Processar arquivo
          pc_proc_xml_APCS106(pr_dsxmlarq => vr_dsxmlarq
                             ,pr_dscritic => vr_dscritic);
        ELSE
          vr_dscritic := 'Rotina não especificada para processar este arquivo.';
          RAISE vr_exc_erro;
      END CASE;
                       
      -- Se houver retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- LOG DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
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
    
    END LOOP;
    -- Commitar os dados processados
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- LOGS DE EXECUCAO
      BEGIN

        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
    vr_cdcritic    crapcri.cdcritic%TYPE;
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
        IF vr_dsdemail IS NULL THEN
          -- Registrar mensagem no log e pular para o próximo registro
          BEGIN
            vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
                           || 'PCPS0002.pc_email_pa_portabilidade'
                           || ' --> E-mail do PA não encontrado (Coop/PA): '||rg_cooper.cdcooper||'/'||vr_cdagatual;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
            
            -- Próxima agência
            vr_cdagatual := vr_tbddados.NEXT(vr_cdagatual);
            
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
          IF length(vr_dsmensag) > 30.000 THEN
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
                                  ,pr_des_destino     => 'renatodarosci@gmail.com' -- vr_dsdemail
                                  ,pr_des_assunto     => vr_dsassunt
                                  ,pr_des_corpo       => vr_dsmensag
                                  ,pr_des_anexo       => NULL --> nao envia anexo
                                  ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_des_erro        => vr_dscritic);

        -- Se houver erros
        IF vr_dscritic IS NOT NULL THEN
          -- Registrar mensagem no log e pular para o próximo registro
          BEGIN
            vr_dsmsglog := to_char(sysdate,'hh24:mi:ss')||' - '
                           || 'PCPS0002.pc_email_pa_portabilidade'
                           || ' --> Erro ao enviar e-mail para (Coop/PA): '||rg_cooper.cdcooper||'/'||vr_cdagatual||'. '||vr_dscritic;
            
            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
            
            -- Próxima agência
            vr_cdagatual := vr_tbddados.NEXT(vr_cdagatual);
            
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
		..............................................................................*/		
    
		-- Cursor responsável por retornar os horários de agendamento dos jobs
		CURSOR cr_crappco IS
		   SELECT dsconteu
			       ,cdpartar
		   	 FROM crappco
			  WHERE cdpartar IN (58, 59, 60, 62)
				  AND cdcooper = 3;
		rw_crappco cr_crappco%ROWTYPE;
		
		-- Variável interna
		vr_dsconteu    crappco.dsconteu%TYPE;
		vr_dthrexe     TIMESTAMP;
		vr_jobname     VARCHAR2(100);
		vr_lstdados    gene0002.typ_split;
		
		-- Variável de críticas
    vr_dscritic    VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro    EXCEPTION;
		
	BEGIN

    FOR rw_crappco IN cr_crappco LOOP
			--
			vr_dsconteu := rw_crappco.dsconteu;
			--
			IF vr_dsconteu IS NULL THEN
				vr_dscritic := 'Horario nao definido na crappco.';
				RAISE vr_exc_erro; -- Não podemos parar o processamento
			END IF;
			--
			vr_lstdados := gene0002.fn_quebra_string(pr_string => vr_dsconteu
																							,pr_delimit => ';');
			--
			IF rw_crappco.cdpartar = 58 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
    		  vr_dthrexe := TO_TIMESTAMP_TZ(to_date(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					--
					vr_jobname := 'JB_PCPS_ENVIA$';
					GENE0001.pc_submit_job(pr_cdcooper => 3,
																 pr_cdprogra => 'PCPS0002',
																 pr_dsplsql  => 'BEGIN PCPS0002.pc_gera_arquivo_APCS(10); PCPS0002.pc_gera_arquivo_APCS(12); PCPS0002.pc_gera_arquivo_APCS(14); END;',
																 pr_dthrexe  => vr_dthrexe,
																 pr_interva  => NULL,
																 pr_jobname  => vr_jobname,
																 pr_des_erro => vr_dscritic);
					--
					IF vr_dscritic IS NOT NULL THEN
						RAISE vr_exc_erro; -- Não podemos parar o processamento
					END IF;
					--
				END LOOP;
				--
			ELSIF rw_crappco.cdpartar = 59 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
          vr_dthrexe := TO_TIMESTAMP_TZ(to_date(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					--
					vr_jobname := 'JB_PCPS_COMPULS$';
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
				END LOOP;
				--
			ELSIF rw_crappco.cdpartar = 60 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
          vr_dthrexe := TO_TIMESTAMP_TZ(to_date(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					--
					vr_jobname := 'JB_PCPS_EMAIL$';
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
				END LOOP;
				--				
			ELSIF rw_crappco.cdpartar = 62 THEN
				--
				FOR vr_idx IN 1 .. vr_lstdados.count LOOP
          vr_dthrexe := TO_TIMESTAMP_TZ(to_date(SYSDATE ,'DD/MM/RRRR') || ' ' || vr_lstdados(vr_idx) || ' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR');
					--
					vr_jobname := 'JB_PCPS_RECEBE$';
					GENE0001.pc_submit_job(pr_cdcooper => 3,
																 pr_cdprogra => 'PCPS0002',
																 pr_dsplsql  => 'BEGIN PCPS0002.pc_proc_arquivo_APCS(10); PCPS0002.pc_proc_arquivo_APCS(11); PCPS0002.pc_proc_arquivo_APCS(12); PCPS0002.pc_proc_arquivo_APCS(13); PCPS0002.pc_proc_arquivo_APCS(14); PCPS0002.pc_proc_arquivo_APCS(15); END;',
																 pr_dthrexe  => vr_dthrexe,
																 pr_interva  => NULL,
																 pr_jobname  => vr_jobname,
																 pr_des_erro => vr_dscritic);
					--
					IF vr_dscritic IS NOT NULL THEN
						RAISE vr_exc_erro; -- Não podemos parar o processamento
					END IF;
					--
				END LOOP;
				--
			END IF;
		END LOOP;
	EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20002, 'Erro na rotina pc_agenda_jobs: '||SQLERRM);
	END pc_agenda_jobs;
  
  
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
