CREATE OR REPLACE PACKAGE PROGRID.WPGD0191 is
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0191                     
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jonathan Cristiano da Silva - RKAM
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Cadastro de Distância Origem x Destino.
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_recebe_cursos_aprovados(pr_dscritic OUT VARCHAR2); --> Retorno de crítica
  
END WPGD0191;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0191 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0191                     
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jonathan Cristiano da Silva - RKAM
  --  Data     : Setembro/2015.                   Ultima atualizacao: 09/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Cadastro de Distância Origem x Destino.
  --

  -- Alteracoes:  30/03/2016 - Ajustes na rotina pc_recebe_cursos_aprovados para garantir que nao estoure
  --                           os campos nos inserts PRJ243.2 (Odirlei-AMcom)
  --
  --              30/03/2016 - Adicionado gravação dos campos dsconteu e dscarhor da crapedp. (Anderson)
  --
  --              19/04/2016 - Ajustado rotina  pc_recebe_cursos_aprovados para utilizar a data base da busca no konviva
  --                           a data do sistema e não o dtmvtolt, pois como roda todos os dias estava ignorando os cooperados
  --                           que concluiam os cursos nos domingos (Odirlei-AMcom)
  --
  --              05/05/2016 - Ajustado rotina pc_recebe_cursos_aprovados para utilizar a sequence conforme as telas de cadastro
  --                           wpgd0019 e wpgd0009 (Odirlei-AMcom)
  --
  --              07/06/2016 - Ajustado pc_recebe_cursos_aprovados para ignorar eventos para os ministrantes
  --                           pois os mesmos não sao cadastrados no progrid, apenas na plataforma.
  --                           SD.461943 (Odirlei-AMcom)
  --
  --              17/11/2016 - Incluido upper na leitura da tbead_inscricao_participante.nmlogin_particip
  --                           para garantir a busca e utilizar o index correto da tabela. SD558339 (Odirlei-AMcom)
  --
  --              15/03/2017 - #551227 Padronização do nome do job e inclusão dos logs de controle de início, erro e fim 
  --                           de execução do programa pc_recebe_cursos_aprovados (Carlos)
  --
  --              23/03/2017 - Ajustes referente a Melhoria 399 - Simplificar Inscricao no Progrid (Márcio - Mouts)
  --
  --              18/04/2017 - #551227 Ajuste do nome da var vr_cdprogra para o tipo crapprg.cdprogra (Carlos)
  --
  --              09/08/2017 - #677251 Corrigido o nome do job p jbpgd_rec_cursos_aprovados e formatação de data na
  --                           rotina pc_busca_conteudo_campo para dd/mm/rrrr, usada nas tags DTINIEVT e DTFIMEVT (Carlos)
  -------------------------------------------------------------------------------------------------------------------

 -- Rotina para buscar o conteudo do campo com base no xml enviado
 PROCEDURE pc_busca_conteudo_campo(pr_retxml    IN OUT NOCOPY XMLType,    --> XML de retorno da operadora
                                   pr_nrcampo   IN VARCHAR2,              --> Campo a ser buscado no XML
                                   pr_indcampo  IN VARCHAR2,              --> Tipo de dado: S=String, D=Data, N=Numerico
                                   pr_retorno  OUT VARCHAR2,              --> Retorno do campo do xml
                                   pr_dscritic IN OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
                                  
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_tab_xml   gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
  BEGIN
    -- Busca a informacao no XML
    gene0007.pc_itera_nodos(pr_xpath      => pr_nrcampo
                           ,pr_xml        => pr_retxml
                           ,pr_list_nodos => vr_tab_xml
                           ,pr_des_erro   => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Se encontrou mais de um registro, deve dar mensagem de erro
    IF  vr_tab_xml.count > 1 THEN
      vr_dscritic := 'Mais de um registro XML encontrado.';
      RAISE vr_exc_saida;
    ELSIF vr_tab_xml.count = 1 THEN -- Se encontrou, retornar o texto
      CASE pr_indcampo
        WHEN 'D' THEN -- Se o tipo de dado for Data, transformar para data
          -- Se for tudo zeros, desconsiderar
          IF vr_tab_xml(0).tag IN ('00000000','0')  THEN
            pr_retorno := NULL;
          ELSE
            pr_retorno := to_date(vr_tab_xml(0).tag,'dd/mm/rrrr');
          END IF;
        WHEN 'N' THEN -- Se o tipo de dado for Number
          pr_retorno := replace(vr_tab_xml(0).tag,'.',',');
        WHEN 'S' THEN -- Se o tipo de dado for String
          pr_retorno := vr_tab_xml(0).tag;
      END CASE;   
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||vr_dscritic;
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_compleme => pr_nrcampo);
      pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||SQLERRM;
  END;
 
 PROCEDURE pc_recebe_cursos_aprovados(pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
   
  -- Buscar a informação da GNAPETP - Eixo Temático
  CURSOR cr_craptem(pr_dseixtem IN VARCHAR) IS
    SELECT g.cdeixtem, c.nrseqtem
      FROM gnapetp g, craptem c
     WHERE c.cdeixtem = g.cdeixtem
       AND c.dstemeix LIKE CONCAT('EAD ', pr_dseixtem);
  rw_craptem cr_craptem%ROWTYPE;
  
  -- Buscar a informação da GNAPETP
  CURSOR cr_gnapetp(pr_dseixtem IN VARCHAR) IS
    SELECT g.cdeixtem, 0 nrseqtem 
      FROM gnapetp g 
     WHERE g.dseixtem = pr_dseixtem;     
  rw_gnapetp cr_gnapetp%ROWTYPE;
  
  -- Buscar a informação da CRAPEDP - Curso a nivel Raiz
  CURSOR cr_crapedp_raiz(pr_idevento IN NUMBER, 
                         pr_cdevento IN NUMBER) IS
  SELECT cdevento
    FROM crapedp
   WHERE idevento = pr_idevento 
     AND cdevento = pr_cdevento
     AND cdcooper = 0 
     AND dtanoage = 0;
  rw_crapedp_raiz cr_crapedp_raiz%ROWTYPE;
  
  -- Buscar a informação da CRAPEDP - Curso a nivel Cooperativa
  CURSOR cr_crapedp_coop(pr_idevento IN NUMBER,
                         pr_cdevento IN NUMBER, 
                         pr_cdcooper IN NUMBER, 
                         pr_dtanoage IN NUMBER) IS
  SELECT cdevento
    FROM crapedp
   WHERE idevento = pr_idevento
     AND cdevento = pr_cdevento
     AND cdcooper = pr_cdcooper 
     AND dtanoage = pr_dtanoage;
  rw_crapedp_coop cr_crapedp_coop%ROWTYPE;
  
  -- Buscar a informação da CRAPEAP - Curso a nivel PA
  CURSOR cr_crapeap(pr_idevento IN NUMBER,
                    pr_cdevento IN NUMBER, 
                    pr_cdcooper IN NUMBER,
                    pr_cdagenci IN NUMBER, 
                    pr_dtanoage IN NUMBER) IS
  SELECT cdevento
    FROM crapeap
   WHERE idevento = pr_idevento 
     AND cdevento = pr_cdevento
     AND cdcooper = pr_cdcooper 
     AND cdagenci = pr_cdagenci 
     AND dtanoage = pr_dtanoage;
  rw_crapeap cr_crapeap%ROWTYPE;
  

  
  -- Buscar a informação da CRAPADP - NRSEQDIG
  CURSOR cr_crapadp_segdig(pr_idevento IN NUMBER,
                           pr_cdevento IN NUMBER, 
                           pr_cdcooper IN NUMBER,
                           pr_cdagenci IN NUMBER, 
                           pr_dtanoage IN NUMBER,
                           pr_dtinievt IN DATE,
                           pr_dtfimevt IN DATE) IS
   SELECT nrseqdig
    FROM crapadp
   WHERE idevento = pr_idevento
     AND cdevento = pr_cdevento
     AND cdcooper = pr_cdcooper 
     AND cdagenci = pr_cdagenci 
     AND dtanoage = pr_dtanoage
     AND dtinieve = pr_dtinievt
     AND dtfineve = pr_dtfimevt;                                   
  rw_crapadp_segdig cr_crapadp_segdig%ROWTYPE;
  
  -- Buscar a informação da CRAPADP - Curso na Turma
  CURSOR cr_crapadp(pr_idevento IN NUMBER,
                    pr_cdevento IN NUMBER, 
                    pr_cdcooper IN NUMBER,
                    pr_cdagenci IN NUMBER, 
                    pr_dtanoage IN NUMBER,
                    pr_dtinievt IN DATE,
                    pr_dtfimevt IN DATE) IS
   SELECT idevento
    FROM crapadp
   WHERE idevento = pr_idevento
     AND cdevento = pr_cdevento
     AND cdcooper = pr_cdcooper 
     AND cdagenci = pr_cdagenci 
     AND dtanoage = pr_dtanoage
     AND dtinieve = pr_dtinievt
     AND dtfineve = pr_dtfimevt;
  rw_crapadp cr_crapadp%ROWTYPE;
  
  -- Buscar a informação da CRAPSDE - Data do Evento
  CURSOR cr_crapsde(pr_idevento IN NUMBER,
                    pr_cdevento IN NUMBER, 
                    pr_cdcooper IN NUMBER,
                    pr_cdagenci IN NUMBER, 
                    pr_dtanoage IN NUMBER) IS
  SELECT cdevento
    FROM crapsde
   WHERE idevento = pr_idevento 
     AND cdevento = pr_cdevento
     AND cdcooper = pr_cdcooper 
     AND cdagenci = pr_cdagenci 
     AND dtanoage = pr_dtanoage;
  rw_crapsde cr_crapsde%ROWTYPE;
  
  -- Buscar a informação da TBEAD_INSCRICAO_PARTICIPANTE
  CURSOR cr_tbeadip(pr_nomlogin IN VARCHAR2) IS
  SELECT nrdconta,
         idseqttl,
         nmparticip,
         dsemail_particip,
         dtadmiss
    FROM tbead_inscricao_participante
   WHERE upper(nmlogin_particip) = upper(pr_nomlogin);
  rw_tbeadip cr_tbeadip%ROWTYPE;
  

  
  -- Buscar a informação da CRAPIDP - Inscritos na Turma
  CURSOR cr_crapidp(pr_idevento IN NUMBER,
                    pr_cdevento IN NUMBER, 
                    pr_cdcooper IN NUMBER,
                    pr_cdagenci IN NUMBER, 
                    pr_dtanoage IN NUMBER,
                    pr_nrdconta IN NUMBER,
                    pr_idseqttl IN NUMBER,
                    pr_dtconins IN DATE,
                    pr_nrdcpf   IN NUMBER -- Melhoria 399 
                    ) IS
  SELECT idevento
    FROM crapidp
   WHERE idevento = pr_idevento
     AND cdevento = pr_cdevento
     AND cdcooper = pr_cdcooper 
     AND cdagenci = pr_cdagenci 
     AND dtanoage = pr_dtanoage 
     AND nrdconta = pr_nrdconta 
     AND idseqttl = pr_idseqttl
     AND dtpreins = pr_dtconins
     AND dtconins = pr_dtconins
     and nrcpfcgc = pr_nrdcpf -- Melhoria 399 
     ;
  rw_crapidp cr_crapidp%ROWTYPE;
  
  -- Buscar a informação da CRAPLDP - Locais dos Eventos
  CURSOR cr_crapldp(pr_idevento IN NUMBER,
                    pr_cdcooper IN NUMBER) IS
  SELECT nrseqdig
    FROM crapldp
   WHERE idevento = pr_idevento
     AND cdcooper = pr_cdcooper 
     AND dslocali = 'EAD';
  rw_crapldp cr_crapldp%ROWTYPE;
  
  -- Busca dia atual do sistema - data generica para todas as cooperativas
  CURSOR cr_ead_data_job IS
    SELECT to_char(dtmvtolt,'yyyy-mm-dd') dtmvtolt
      FROM crapdat 
     WHERE cdcooper = 1;
  rw_ead_data_job cr_ead_data_job%ROWTYPE;
  
  BEGIN 
 
    DECLARE
      vr_script_curl    VARCHAR2(1000); --> Script CURL
      vr_comand_curl    VARCHAR2(4000); --> Comando montado do envio ao CURL
      vr_typ_saida      VARCHAR2(3);    --> Saída de erro
      vr_xml            xmltype;        --> XML de retorno
      vr_nmtagaux       VARCHAR2(200);  --> Caminho do XML - CURSOS
      vr_contador_raiz  PLS_INTEGER; --> Variavel contador de Evento Raiz 
      vr_contador_coop  PLS_INTEGER; --> Variavel contador de Evento Coop
      vr_contador_pa    PLS_INTEGER; --> Variavel contador de PA
      vr_contador_turma PLS_INTEGER; --> Variavel contador de Turma
      vr_contador_login PLS_INTEGER; --> Variavel contador de Login/Participantes
      vr_blnfound       BOOLEAN;
      vr_dtdiasis       VARCHAR2(10); --> Variavel com a data atual do sistema
      vr_dtdiajob       VARCHAR2(10); --> Variavel com ultima data de execucao da job com sucesso
      vr_caminho_xml    VARCHAR2(1000); --> Variavel com o caminho do arquivo xml
      vr_arquivo_xml    VARCHAR2(1000); --> Variavel com o caminho do arquivo xml
      
      -- Variaveis de erro
      vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
      vr_dscritic   VARCHAR2(4000); --> descricao do erro
      vr_exc_saida  EXCEPTION; --> Excecao prevista
      
      -- Variaveis de retorno
      vr_idevento PLS_INTEGER;
      vr_tpevento PLS_INTEGER;
      vr_cdevento PLS_INTEGER;
      vr_nmevento VARCHAR2(1000);
      vr_dseixtem VARCHAR2(1000);
      vr_numhoras VARCHAR2(1000);
      vr_dscursos LONG;
      vr_cdcooper PLS_INTEGER;
      vr_cdagenci PLS_INTEGER;
      vr_dtanoage PLS_INTEGER;
      vr_dtmesevt PLS_INTEGER;
      vr_dtinievt DATE;
      vr_dtfimevt DATE;
      vr_dtconins DATE;
      vr_nomlogin VARCHAR2(1000);
      vr_cdeixtem PLS_INTEGER;
      vr_nrseqtem PLS_INTEGER;
      vr_nrseqdig NUMBER := 0;
      vr_lsigneve VARCHAR2(4000) := NULL;
      -- Incluir variáveis novas conforme Melhoria M399
      --23/02/2017
      vr_nrdcpf              VARCHAR2(1000);
      vr_dseml               VARCHAR2(1000);
      vr_dslogin             VARCHAR2(1000);
      vr_nomeusuario         VARCHAR2(1000);
      vr_ceplog              VARCHAR2(1000);
      vr_endereco            VARCHAR2(1000);
      vr_numlog              VARCHAR2(1000);
      vr_complog             VARCHAR2(1000);
      vr_bairro              VARCHAR2(1000);
      vr_cidade              VARCHAR2(1000);
      vr_estado              VARCHAR2(1000);
      vr_pais                VARCHAR2(1000);
      vr_telefonecomercial   VARCHAR2(1000);
      vr_telefoneresidencial VARCHAR2(1000);
      vr_telefonecelular     VARCHAR2(1000);
      vr_numeroconta         VARCHAR2(1000);
      vr_codCooperativa      VARCHAR2(1000);
      vr_tipocooperado       VARCHAR2(1000);
      vr_inpessoa            NUMBER(1):=0;
      vr_idseqttl            NUMBER(1):=0;  
      vr_nrdddtfc            NUMBER;
      vr_nrtelefo            NUMBER;          
      vr_cdcopavl            NUMBER;
      vr_tpctrato            NUMBER;
      vr_nrctremp            NUMBER;
      vr_nrdctato            NUMBER;          
      
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'WPGD0191';
    vr_nomdojob  CONSTANT VARCHAR2(50)          := 'jbpgd_rec_cursos_aprovados';
    vr_flgerlog  BOOLEAN := FALSE; 
    
    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa

                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
    END pc_controla_log_batch;

      
    BEGIN
      
      -- Início do programa
      pc_controla_log_batch('I');
      
      -- Variavel com o caminho do arquivo xml
      vr_caminho_xml := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coopd/cecred ou /microsd/cecred
                                             ,pr_cdcooper => 3);
      
      -- Variavel com o caminho do arquivo xml
      vr_arquivo_xml := '/salvar/WPGD0191_'||to_char(sysdate,'yyyymmdd')||'.xml';

      -- Buscar script para conexão Curl
      vr_script_curl := gene0001.fn_param_sistema('CRED',0,'EAD_CURSOS_CURL');
      
      -- Busca ultima data de execucao da job com sucesso
      vr_dtdiajob := gene0001.fn_param_sistema('CRED',0,'EAD_DATA_JOB');
      
      -- Define dia anterior ao atual como busca, pois processo roda a 1 da manha
      vr_dtdiasis := to_char(SYSDATE-1,'yyyy-mm-dd');
      
      -- Preparar o comando de conexão e envio ao Curl
      vr_comand_curl := vr_script_curl
                        || ' -dtexcini '  || vr_dtdiajob
                        || ' -dtexcfim '  || vr_dtdiasis 
                        || ' > '          || vr_caminho_xml
                        || vr_arquivo_xml;
                        
      -- Chama procedure de envio e recebimento via curl
      GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_curl
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);
                                     
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro de comunição com EaD: '||vr_dscritic;
        
        RAISE vr_exc_saida;
      END IF;
      
      gene0002.pc_arquivo_para_XML(pr_nmarquiv => vr_caminho_xml || vr_arquivo_xml,
                                   pr_tipmodo  => 2,
                                   pr_xmltype => vr_xml,
                                   pr_des_reto => vr_typ_saida,
                                   pr_dscritic => vr_dscritic);
                                 
      IF (vr_typ_saida = 'NOK') THEN
        -- Comando para excluir arquivos já existentes
        GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm ' || vr_caminho_xml || vr_arquivo_xml || ' 2> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);
        
        -- Verificar retorno de erro
        IF NVL(vr_typ_saida, ' ') = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao remover arquivos: '||vr_dscritic;
          
          RAISE vr_exc_saida;
        END IF;
        
        -- Atualiza o erro encontrado na variavel de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Retorno do XML vazio';
        
        RAISE vr_exc_saida;
      END IF;
      
      -- Inicializa o contador de consultas de eventos - raiz
      vr_contador_raiz := 1;                             
      LOOP
        -- Caminho base para o node de Cursos
        vr_nmtagaux := '//LISTA_APROVADOS/LISTA_EVENTO/EVENTO['||vr_contador_raiz||']/';
        
        -- Verifica se existe dados na consulta
        IF vr_xml.existsnode(vr_nmtagaux||'CDEVENTO') = 0 THEN
          EXIT;      
        END IF;
        
        ------------- BUSCA OS DADOS DOS CURSOS -------------
        --Busca os campos do detalhe da consulta
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'IDEVENTO', 'N', vr_idevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'TPEVENTO', 'N', vr_tpevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDEVENTO', 'N', vr_cdevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'NMEVENTO', 'S', vr_nmevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDEIXTEM', 'N', vr_dseixtem, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DSCURSOS', 'S', vr_dscursos, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'NUMHORAS', 'S', vr_numhoras, vr_dscritic);
          
        --> Verificar se evento deve ser ignorado
        IF upper(vr_nmevento) LIKE '%CERTIFICAÇÃO MINISTRANTES PROGRID%' THEN          
          --> Incluir na listagem de eventos para ser ignorado
          vr_lsigneve := vr_lsigneve ||','||vr_cdevento||',';
          vr_contador_raiz := vr_contador_raiz + 1; 
          continue;        
        END IF;
        
        -- Busca Eixo Tematico para PROGRID
        IF vr_idevento = 1 THEN
            
          -- Busca as informações da GNAPETP - Eixo Tematico
          OPEN cr_craptem(pr_dseixtem => vr_dseixtem);
          FETCH cr_craptem INTO rw_craptem;
          
          -- Codigo do Eixo e Sequencial
          vr_cdeixtem := rw_craptem.cdeixtem;
          vr_nrseqtem := rw_craptem.nrseqtem;
          
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craptem%FOUND;
          
          -- Fecha cursor
          CLOSE cr_craptem;
          
        -- Busca Eixo Tematico para ASSEMBLEIAS  
        ELSE
            
          -- Busca as informações da GNAPETP
          OPEN cr_gnapetp(pr_dseixtem => vr_dseixtem);
          FETCH cr_gnapetp INTO rw_gnapetp;
          
          -- Codigo do Eixo e Sequencial
          vr_cdeixtem := rw_gnapetp.cdeixtem;
          vr_nrseqtem := rw_gnapetp.nrseqtem;
          
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_gnapetp%FOUND;
          
          -- Fecha cursor
          CLOSE cr_gnapetp;
            
        END IF;
          
        -- Se nao achou faz a criatica do Eixo Tematico
        IF NOT vr_blnfound THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Eixo Tematico não encontrada: '||vr_dseixtem ||
                         ', verifique o cadatro de "Eixo Tematico" e "Temas do Eixo Tematico" para o EAD';
        
          RAISE vr_exc_saida;
            
        ELSE
            
          -- Busca as informações da CRAPEDP
          OPEN  cr_crapedp_raiz(pr_idevento => vr_idevento, 
                                pr_cdevento => vr_cdevento);
          FETCH cr_crapedp_raiz INTO rw_crapedp_raiz;

          -- Caso não encontre registros
          IF cr_crapedp_raiz%NOTFOUND THEN
              
            BEGIN
                  
            -- Insere eventos no nivel raiz
            INSERT INTO crapedp (
              idevento,
              cdevento,
              tpevento,
              qtmaxtur,
              qtmintur,
              tppartic,
              nridamin,
              prfreque,
              cdeixtem,
              nmevento,
              nrseqtem,
              qtdiaeve,
              dsconteu,
              dscarhor
            ) VALUES (
              vr_idevento,
              vr_cdevento,
              vr_tpevento,
              1,
              1,
              5,
              1,
              100,
              vr_cdeixtem,
              substr(vr_nmevento,1,50),
              vr_nrseqtem,
              1,
              nvl(vr_dscursos,' '),
              nvl(vr_numhoras,' ')
            );
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao registrar o Curso Raiz '||vr_contador_raiz||': '||SQLERRM;
                  
                RAISE vr_exc_saida;
            END;
              
          END IF;

          -- Fecha o cursor
          CLOSE cr_crapedp_raiz;
          
        END IF;
      
        vr_contador_raiz := vr_contador_raiz + 1;
      END LOOP;
      
      -- Inicializa o contador de consultas de eventos - cooperativa
      vr_contador_coop := 1;                             
      LOOP
        -- Caminho base para o node de Cursos
        vr_nmtagaux := '//LISTA_APROVADOS/LISTA_EVENTO_COOPER/EVENTO['||vr_contador_coop||']/';
        
        -- Verifica se existe dados na consulta
        IF vr_xml.existsnode(vr_nmtagaux||'CDEVENTO') = 0 THEN  
          EXIT;      
        END IF;
        
        ------------- BUSCA OS DADOS DOS CURSOS -------------
        --Busca os campos do detalhe da consulta
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'IDEVENTO', 'N', vr_idevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'TPEVENTO', 'N', vr_tpevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDEVENTO', 'N', vr_cdevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'NMEVENTO', 'S', vr_nmevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDEIXTEM', 'N', vr_dseixtem, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDCOOPER', 'N', vr_cdcooper, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTANOAGE', 'N', vr_dtanoage, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DSCURSOS', 'S', vr_dscursos, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'NUMHORAS', 'S', vr_numhoras, vr_dscritic);
        
        --> Verificar se deve ignorar o evento
        IF instr(vr_lsigneve,','||vr_cdevento||',') > 0 THEN
          vr_contador_coop := vr_contador_coop + 1;
          continue;
        END IF;
        
        -- Busca Eixo Tematico para PROGRID
        IF vr_idevento = 1 THEN
            
          -- Busca as informações da GNAPETP - Eixo Tematico
          OPEN cr_craptem(pr_dseixtem => vr_dseixtem);
          FETCH cr_craptem INTO rw_craptem;
          
          -- Codigo do Eixo e Sequencial
          vr_cdeixtem := rw_craptem.cdeixtem;
          vr_nrseqtem := rw_craptem.nrseqtem;
          
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craptem%FOUND;
          
          -- Fecha cursor
          CLOSE cr_craptem;
          
        -- Busca Eixo Tematico para ASSEMBLEIAS  
        ELSE
            
          -- Busca as informações da GNAPETP
          OPEN cr_gnapetp(pr_dseixtem => vr_dseixtem);
          FETCH cr_gnapetp INTO rw_gnapetp;
          
          -- Codigo do Eixo e Sequencial
          vr_cdeixtem := rw_gnapetp.cdeixtem;
          vr_nrseqtem := rw_gnapetp.nrseqtem;
          
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_gnapetp%FOUND;
          
          -- Fecha cursor
          CLOSE cr_gnapetp;
            
        END IF;
          
        -- Se nao achou faz a criacao do lote TEC
        IF NOT vr_blnfound THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Eixo Tematico não encontrada: '||vr_dseixtem;
            
          RAISE vr_exc_saida; 
        ELSE
          
          -- Busca as informações da CRAPEDP
          OPEN  cr_crapedp_coop(pr_idevento => vr_idevento,
                                pr_cdevento => vr_cdevento,
                                pr_cdcooper => vr_cdcooper,
                                pr_dtanoage => vr_dtanoage);                 
          FETCH cr_crapedp_coop INTO rw_crapedp_coop;

          -- Caso não encontre registros
          IF cr_crapedp_coop%NOTFOUND THEN
              
            BEGIN
             
            -- Insere eventos no nivel cooperativa
            INSERT INTO crapedp (
              idevento,
              cdcooper,
              dtanoage,
              cdevento,
              tpevento,
              qtmaxtur,
              qtmintur,
              tppartic,
              nridamin,
              prfreque,
              cdeixtem,
              nmevento,
              nrseqtem,
              qtdiaeve,
              dsconteu,
              dscarhor
            ) VALUES (
              vr_idevento,
              vr_cdcooper,
              vr_dtanoage,
              vr_cdevento,
              vr_tpevento,
              1,
              1,
              5,
              1,
              100,
              vr_cdeixtem,
              substr(vr_nmevento,1,50),
              vr_nrseqtem,
              1,
              nvl(vr_dscursos,' '),
              nvl(vr_numhoras,' ')
            );
                
           EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao registrar o Curso e Cooperativa '||vr_contador_coop||': '||SQLERRM;
                    
              RAISE vr_exc_saida;
            END;
              
          END IF;

          -- Fecha o cursor
          CLOSE cr_crapedp_coop;
            
        END IF;
      
        vr_contador_coop := vr_contador_coop + 1;
      END LOOP;
      
      -- Inicializa o contador de consultas de eventos - PA
      vr_contador_pa:= 1;                             
      LOOP
        -- Caminho base para o node de Cursos
        vr_nmtagaux := '//LISTA_APROVADOS/LISTA_EVENTO_AGENCI/EVENTO['||vr_contador_pa||']/';
        
        -- Verifica se existe dados na consulta
        IF vr_xml.existsnode(vr_nmtagaux||'CDEVENTO') = 0 THEN  
          EXIT;      
        END IF;
        
        ------------- BUSCA OS DADOS DOS CURSOS -------------
        --Busca os campos do detalhe da consulta
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'IDEVENTO', 'N', vr_idevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDEVENTO', 'N', vr_cdevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDCOOPER', 'N', vr_cdcooper, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDAGENCI', 'N', vr_cdagenci, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTANOAGE', 'N', vr_dtanoage, vr_dscritic);

        --> Verificar se deve ignorar o evento
        IF instr(vr_lsigneve,','||vr_cdevento||',') > 0 THEN
          vr_contador_pa := vr_contador_pa + 1;
          continue;
        END IF;
        
        -- Busca as informações da CRAPEAP
        OPEN cr_crapeap(pr_idevento => vr_idevento,
                        pr_cdevento => vr_cdevento,
                        pr_cdcooper => vr_cdcooper,
                        pr_cdagenci => vr_cdagenci,
                        pr_dtanoage => vr_dtanoage);                 
        FETCH cr_crapeap INTO rw_crapeap;

        -- Caso não encontre registros
        IF cr_crapeap%NOTFOUND THEN
            
          BEGIN 
             
          -- Insere eventos no nivel PA
          INSERT INTO crapeap (
            idevento,
            cdcooper,
            dtanoage,
            cdevento,
            cdagenci,
            flgevsel,
            qtocoeve
          ) VALUES (
            vr_idevento,
            vr_cdcooper,
            vr_dtanoage,
            vr_cdevento,
            vr_cdagenci,
            1,
            1
          );
              
         EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao registrar o Curso e Cooperativa/PA '||vr_contador_pa||': '||SQLERRM;
                
            RAISE vr_exc_saida;
         END;
              
        END IF;

        -- Fecha o cursor
        CLOSE cr_crapeap;
        
        vr_contador_pa := vr_contador_pa + 1;
      END LOOP;
      
      -- Inicializa o contador de consultas de eventos - PA
      vr_contador_turma:= 1;                             
      LOOP
        -- Caminho base para o node de Cursos
        vr_nmtagaux := '//LISTA_APROVADOS/LISTA_EVENTO_TURMA/EVENTO['||vr_contador_turma||']/';
        
        -- Verifica se existe dados na consulta
        IF vr_xml.existsnode(vr_nmtagaux||'CDEVENTO') = 0 THEN  
          EXIT;      
        END IF;
        
        ------------- BUSCA OS DADOS DOS CURSOS -------------
        --Busca os campos do detalhe da consulta
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'IDEVENTO', 'N', vr_idevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDEVENTO', 'N', vr_cdevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDCOOPER', 'N', vr_cdcooper, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDAGENCI', 'N', vr_cdagenci, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTANOAGE', 'N', vr_dtanoage, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTMESEVT', 'N', vr_dtmesevt, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTINIEVT', 'D', vr_dtinievt, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTFIMEVT', 'D', vr_dtfimevt, vr_dscritic);
        
        --> Verificar se deve ignorar o evento
        IF instr(vr_lsigneve,','||vr_cdevento||',') > 0 THEN
          vr_contador_turma := vr_contador_turma + 1;
          continue;
        END IF;
        
        -- Busca as informações da CRAPADP
        OPEN  cr_crapadp(pr_idevento => vr_idevento,
                         pr_cdevento => vr_cdevento,
                         pr_cdcooper => vr_cdcooper,
                         pr_cdagenci => vr_cdagenci,
                         pr_dtanoage => vr_dtanoage,
                         pr_dtinievt => vr_dtinievt,
                         pr_dtfimevt => vr_dtfimevt);                 
        FETCH cr_crapadp INTO rw_crapadp;

        -- Caso não encontre registros
        IF cr_crapadp%NOTFOUND THEN
            
          -- Busca as informações da CRAPADP - Sequence
          vr_nrseqdig := NULL;
          vr_nrseqdig := nrseqadp.nextval();  
            
          -- Busca as informações da CRAPLDP - Locais dos Eventos
          OPEN cr_crapldp(pr_idevento => vr_idevento,
                          pr_cdcooper => vr_cdcooper);                 
          FETCH cr_crapldp INTO rw_crapldp;
            
          BEGIN
            
          -- Insere eventos na Turma
          INSERT INTO crapadp (
            idevento,
            cdcooper,
            dtanoage,
            cdevento,
            cdagenci,
            cdlocali,
            nrmeseve,
            dtinieve,
            dtfineve,
            dshroeve,
            dsdiaeve,
            idstaeve,
            qtdiaeve,
            nrmesage,
            nrseqdig
          ) VALUES (
            vr_idevento,
            vr_cdcooper,
            vr_dtanoage,
            vr_cdevento,
            vr_cdagenci,
            NVL(rw_crapldp.nrseqdig, 0),
            vr_dtmesevt,
            vr_dtinievt,
            vr_dtfimevt,
            '00H00 ÀS 24H00',
            '1,2,3,4,5,6,7',
            1,
            1,
            vr_dtmesevt,
            vr_nrseqdig
          );
              
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao registrar o Curso e Turma '||vr_contador_turma||': '||SQLERRM;
                  
              RAISE vr_exc_saida;
           END;
            
          -- Fecha o cursor
          CLOSE cr_crapldp;
            
        END IF;
          
        -- Fecha o cursor
        CLOSE cr_crapadp;
          
        -- Busca as informações da CRAPSDE
        OPEN  cr_crapsde(pr_idevento => vr_idevento,
                         pr_cdevento => vr_cdevento,
                         pr_cdcooper => vr_cdcooper,
                         pr_cdagenci => vr_cdagenci,
                         pr_dtanoage => vr_dtanoage);                 
        FETCH cr_crapsde INTO rw_crapsde;

        -- Caso não encontre registros
        IF cr_crapsde%NOTFOUND THEN
            
          BEGIN
             
          -- Insere eventos na Data do Evento
          INSERT INTO crapsde (
            idevento,
            cdcooper,
            dtanoage,
            cdevento,
            cdagenci,
            nrocoeve,
            dsdatsug,
            hrsugini,
            dtatuali
          ) VALUES (
            vr_idevento,
            vr_cdcooper,
            vr_dtanoage,
            vr_cdevento,
            vr_cdagenci,
            1,
            vr_dtinievt,
            '0800',
            vr_dtinievt
          );
            
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao registrar o Curso e Turma '||vr_contador_turma||': '||SQLERRM;
                
            RAISE vr_exc_saida;
          END;
              
        END IF;

        -- Fecha o cursor
        CLOSE cr_crapsde;
        
        vr_contador_turma := vr_contador_turma + 1;
      END LOOP;
      
      -- Inicializa o contador de consultas de eventos - PA
      vr_contador_login:= 1;                             
      LOOP
        vr_idseqttl:=0;
        vr_inpessoa:=0;
        vr_nrdctato:=0;
        vr_cdcopavl:=0;
        vr_tpctrato:=0;
        vr_nrctremp:=0;
        -- Caminho base para o node de Cursos
        vr_nmtagaux := '//LISTA_APROVADOS/LISTA_EVENTO_COOPERADO/EVENTO['||vr_contador_login||']/';
        
        -- Verifica se existe dados na consulta
        IF vr_xml.existsnode(vr_nmtagaux||'CDEVENTO') = 0 THEN  
          EXIT;      
        END IF;

        ------------- BUSCA OS DADOS DOS CURSOS -------------
        --Busca os campos do detalhe da consulta
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'IDEVENTO', 'N', vr_idevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDEVENTO', 'N', vr_cdevento, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDCOOPER', 'N', vr_cdcooper, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CDAGENCI', 'N', vr_cdagenci, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTANOAGE', 'N', vr_dtanoage, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTINIEVT', 'D', vr_dtinievt, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTFIMEVT', 'D', vr_dtfimevt, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'NOMLOGIN', 'S', vr_nomlogin, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'DTCONINS', 'S', vr_dtconins, vr_dscritic);
        -- Buscar informação de campos adicionados no XML que retorna as informações do curso
        --23/02/2017
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CPF'                 , 'S', vr_nrdcpf  , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Email'               , 'S', vr_dseml   , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Login'               , 'S', vr_dslogin , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Nome'                , 'S', vr_nomeusuario , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CEP'                 , 'S', vr_ceplog  , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Endereco'            , 'S', vr_endereco, vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Numero'              , 'S', vr_numlog  , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Complemento'         , 'S', vr_complog , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Bairro'              , 'S', vr_bairro  , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Cidade'              , 'S', vr_cidade  , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Estado'              , 'S', vr_estado  , vr_dscritic);
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'Pais'                , 'S', vr_pais    , vr_dscritic);                        
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'TelefoneComercial'   , 'S', vr_telefonecomercial    , vr_dscritic);                        
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'TelefoneResidencial' , 'S', vr_telefoneresidencial   , vr_dscritic);                        
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'TelefoneCelular'     , 'S', vr_telefonecelular       , vr_dscritic);                        
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'NumeroConta'         , 'S', vr_numeroconta           , vr_dscritic);                                                
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'CODCooperativa'      , 'S', vr_codCooperativa        , vr_dscritic);                                                
        pc_busca_conteudo_campo(vr_xml, vr_nmtagaux||'TipoCooperado'       , 'S', vr_tipocooperado         , vr_dscritic);                                                        
        
        --> Verificar se deve ignorar o evento
        IF instr(vr_lsigneve,','||vr_cdevento||',') > 0 THEN
          vr_contador_login := vr_contador_login + 1;
          continue;
        END IF;
        
        --Se a conta veio como nula, atribui 0
        IF vr_numeroconta is null THEN
           vr_numeroconta:= 0;
        END IF;
        
        -- Busca as informações da TBEAD_INSCRICAO_PARTICIPANTE
--        OPEN  cr_tbeadip(pr_nomlogin => vr_nomlogin);  --Melhoria 399
--        FETCH cr_tbeadip INTO rw_tbeadip; --Melhoria 399

        -- Caso não encontre registros
--        IF cr_tbeadip%FOUND THEN --Melhoria 399

          -- Início Melhoria 399
          -- Se o tipo de cooperado na variável vr_tipocooperado não for zero, Considerar como comunidade
          IF NVL(trim(vr_tipocooperado),0) = 0 THEN  -- Comunidade
            --Se é comunidade, grava zero na conta
            vr_numeroconta:=0;
            -- Decompor o número do telefone
            IF NVL(trim(vr_telefonecelular),0) <> 0 THEN
              vr_nrdddtfc := substr(vr_telefonecelular,1,2);
              vr_nrtelefo := substr(vr_telefonecelular,3,9);        
            ELSE
              IF NVL(trim(vr_telefoneresidencial),0) <> 0 THEN
                vr_nrdddtfc := substr(vr_telefoneresidencial,1,2);
                vr_nrtelefo := substr(vr_telefoneresidencial,3,9);        
              ELSE
                IF NVL(trim(vr_telefonecomercial),0) <> 0 THEN
                  vr_nrdddtfc := substr(vr_telefonecomercial,1,2);
                  vr_nrtelefo := substr(vr_telefonecomercial,3,9);        
                ELSE
                  vr_nrdddtfc := 0;
                  vr_nrtelefo := 0;        
                END IF;
              END IF;
            END IF;
          -- Se o tipo de cooperado na variável vr_tipocooperado não for zero, verifica se a conta é de pessoa física ou jurídica
          ELSIF NVL(trim(vr_tipocooperado),0) <> 0 THEN -- Cooperado
            BEGIN
              SELECT 
                     c.inpessoa
                INTO
                     vr_inpessoa
                FROM
                     crapass c
               WHERE
                    c.cdcooper = vr_cdcooper
                and c.nrdconta = vr_numeroconta;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN      
                vr_cdcritic := 0; 
                vr_dscritic := 'Conta não encontrada ' 
                               ||vr_contador_login||':' 
                               ||'\r\nLogin: '||vr_nomlogin; 
            
                RAISE vr_exc_saida;
              WHEN OTHERS THEN
                vr_cdcritic := 0; 
                vr_dscritic := 'Erro ao selecionar na tabela crapass: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            -- Verificar sequencia da titularidade para Pessoa Física
            IF vr_inpessoa = 1 THEN -- Pessoa Física
            --busca na CRAPTEL a sequencia da titularidade
              BEGIN
                SELECT
                       ct.idseqttl,
                       decode(vr_nomeusuario,null,ct.nmextttl,vr_nomeusuario)
                INTO
                       vr_idseqttl,
                       vr_nomeusuario
                FROM
                       crapttl ct
                WHERE
                       ct.cdcooper = vr_cdcooper
                   and ct.nrdconta = vr_numeroconta
                   and ct.nrcpfcgc = vr_nrdcpf;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  vr_cdcritic := 0; 
                  vr_dscritic := 'Titular da conta não encontrada ' 
                                 ||vr_contador_login||':' 
                                 ||'\r\nLogin: '||vr_nomlogin; 
            
                  RAISE vr_exc_saida;                        
               WHEN OTHERS THEN
                 vr_cdcritic := 0; 
                 vr_dscritic := 'Erro ao selecionar na tabela crapttl: '||SQLERRM;
                 RAISE vr_exc_saida;          
              END;
              -- Busca o número do telefone -- Celular
              BEGIN
                SELECT
                       cf.nrdddtfc,
                       cf.nrtelefo
                INTO
                       vr_nrdddtfc,
                       vr_nrtelefo
                FROM
                       craptfc cf
                WHERE
                       cf.cdcooper = vr_cdcooper
                   and cf.nrdconta = vr_numeroconta
                   and cf.idseqttl = vr_idseqttl
                   and cf.tptelefo = 2 -- Celular
                   and rownum = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  -- Residencial
                  BEGIN
                    SELECT
                           cf.nrdddtfc,
                           cf.nrtelefo
                    INTO
                           vr_nrdddtfc,
                           vr_nrtelefo
                    FROM
                           craptfc cf
                    WHERE
                           cf.cdcooper = vr_cdcooper
                       and cf.nrdconta = vr_numeroconta
                       and cf.idseqttl = vr_idseqttl
                       and cf.tptelefo = 1 -- Residencial
                       and rownum = 1;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      BEGIN
                        SELECT
                               cf.nrdddtfc,
                               cf.nrtelefo
                        INTO
                               vr_nrdddtfc,
                               vr_nrtelefo
                        FROM
                               craptfc cf
                        WHERE
                               cf.cdcooper = vr_cdcooper
                           and cf.nrdconta = vr_numeroconta
                           and cf.idseqttl = vr_idseqttl
                           and cf.tptelefo = 3 -- Residencial
                           and rownum = 1;                           
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          vr_nrdddtfc :=0;
                          vr_nrtelefo :=0;                          
                      END;                  
                  END;
               WHEN OTHERS THEN
                 vr_cdcritic := 0; 
                 vr_dscritic := 'Erro ao selecionar na tabela crapttl: '||SQLERRM;
                 RAISE vr_exc_saida;          
              END;            
              -- Buscar o email
              BEGIN
                SELECT
                      cc.dsdemail
                  INTO
                       vr_dseml
                  FROM
                       CRAPCEM CC
                 WHERE
                       CC.CDCOOPER = vr_cdcooper
                   AND CC.NRDCONTA = vr_numeroconta
                   AND CC.IDSEQTTL = vr_idseqttl
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  vr_dseml:='';
                 WHEN OTHERS THEN
                   vr_cdcritic := 0; 
                   vr_dscritic := 'Erro ao selecionar na tabela CRAPCEM: '||SQLERRM;
                   RAISE vr_exc_saida;          
              END;
          
            ELSIF vr_inpessoa = 2 THEN --Pessoa Jurídica
              vr_idseqttl:=0;
              
              --validar na CRAPAVT se o CPF informado existe para tipo 6  
              BEGIN
                SELECT
                       ca.nrdctato,
                       ca.cdcooper,
                       ca.tpctrato,
                       ca.nrctremp
                INTO
                       vr_nrdctato,
                       vr_cdcopavl,
                       vr_tpctrato,
                       vr_nrctremp
                       
                FROM
                       crapavt ca
                WHERE
                       ca.cdcooper = vr_cdcooper
                   and ca.nrdconta = vr_numeroconta
                   and ca.nrcpfcgc = vr_nrdcpf
                   and ca.tpctrato = 6; -- PJ
                   --CDCOOPER, TPCTRATO, NRDCONTA, NRCTREMP, NRCPFCGC
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  vr_cdcritic := 0; 
                  vr_dscritic := 'Avalista da conta não encontrado ' 
                                 ||vr_contador_login||':' 
                                 ||'\r\nLogin: '||vr_nomlogin; 
              
                  RAISE vr_exc_saida;
                WHEN OTHERS THEN
                  vr_cdcritic := 0;                   
                  vr_dscritic := 'Erro ao selecionar na tabela crapavt: '||SQLERRM;
                  RAISE vr_exc_saida;            
              END;
              IF nvl(vr_nrdctato,0) <> 0 THEN
              --busca na CRAPTEL a sequencia da titularidade
                BEGIN
                  SELECT
                         ct.idseqttl,
                         decode(vr_nomeusuario,null,ct.nmextttl,vr_nomeusuario)
                  INTO
                         vr_idseqttl,
                         vr_nomeusuario
                  FROM
                         crapttl ct
                  WHERE
                         ct.cdcooper = vr_cdcooper
                     and ct.nrdconta = vr_nrdctato
                     and ct.nrcpfcgc = vr_nrdcpf;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    vr_cdcritic := 0; 
                    vr_dscritic := 'Titular da conta não encontrada ' 
                                   ||vr_contador_login||':' 
                                   ||'\r\nLogin: '||vr_nomlogin; 
            
                    RAISE vr_exc_saida;                        
                 WHEN OTHERS THEN
                   vr_cdcritic := 0; 
                   vr_dscritic := 'Erro ao selecionar na tabela crapttl: '||SQLERRM;
                   RAISE vr_exc_saida;          
                END;
                -- Busca o número do telefone -- Celular
                BEGIN
                  SELECT
                         cf.nrdddtfc,
                         cf.nrtelefo
                  INTO
                         vr_nrdddtfc,
                         vr_nrtelefo
                  FROM
                         craptfc cf
                  WHERE
                         cf.cdcooper = vr_cdcooper
                     and cf.nrdconta = vr_nrdctato
                     and cf.idseqttl = vr_idseqttl
                     and cf.tptelefo = 2 -- Celular
                     and rownum = 1;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    -- Residencial
                    BEGIN
                      SELECT
                             cf.nrdddtfc,
                             cf.nrtelefo
                      INTO
                             vr_nrdddtfc,
                             vr_nrtelefo
                      FROM
                             craptfc cf
                      WHERE
                             cf.cdcooper = vr_cdcooper
                         and cf.nrdconta = vr_nrdctato
                         and cf.idseqttl = vr_idseqttl
                         and cf.tptelefo = 1 -- Residencial
                         and rownum = 1;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        BEGIN
                          SELECT
                                 cf.nrdddtfc,
                                 cf.nrtelefo
                          INTO
                                 vr_nrdddtfc,
                                 vr_nrtelefo
                          FROM
                                 craptfc cf
                          WHERE
                                 cf.cdcooper = vr_cdcooper
                             and cf.nrdconta = vr_nrdctato
                             and cf.idseqttl = vr_idseqttl
                             and cf.tptelefo = 3 -- Residencial
                             and rownum = 1;                           
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                            vr_nrdddtfc :=0;
                            vr_nrtelefo :=0;                          
                        END;                  
                    END;
                 WHEN OTHERS THEN
                   vr_cdcritic := 0; 
                   vr_dscritic := 'Erro ao selecionar na tabela crapttl: '||SQLERRM;
                   RAISE vr_exc_saida;          
                END;            
                -- Buscar o email
                BEGIN
                  SELECT
                        cc.dsdemail
                    INTO
                         vr_dseml
                    FROM
                         CRAPCEM CC
                   WHERE
                         CC.CDCOOPER = vr_cdcooper
                     AND CC.NRDCONTA = vr_nrdctato
                     AND CC.IDSEQTTL = vr_idseqttl
                     AND ROWNUM = 1;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    vr_dseml:='';
                   WHEN OTHERS THEN
                     vr_cdcritic := 0; 
                     vr_dscritic := 'Erro ao selecionar na tabela CRAPCEM: '||SQLERRM;
                     RAISE vr_exc_saida;          
                END;
              ELSE
                vr_idseqttl:=0;  
                vr_dseml   :='';
                vr_nrdddtfc:=0;  
                vr_nrtelefo:=0;  
                vr_cdcopavl:=0;
                vr_tpctrato:=0;
                vr_nrctremp:=0;
              END IF;
----------------------------------------------------
-------------------------------------------------------              
            ELSE -- Considera como sequencia de titular 0
             vr_idseqttl:=0;  
             vr_dseml   :='';
             vr_nrdddtfc:=0;  
             vr_nrtelefo:=0;  
             vr_cdcopavl:=0;
             vr_tpctrato:=0;
             vr_nrctremp:=0;
            END IF;
          END IF;        
          -- Fim Melhoria 399                
            
          -- Busca as informações da CRAPIDP
          OPEN cr_crapidp(pr_idevento => vr_idevento,
                          pr_cdevento => vr_cdevento,
                          pr_cdcooper => vr_cdcooper,
                          pr_cdagenci => vr_cdagenci,
                          pr_dtanoage => vr_dtanoage,
--                          pr_nrdconta => rw_tbeadip.nrdconta, --Melhoria 399
                          pr_nrdconta => vr_numeroconta,
--                          pr_idseqttl => rw_tbeadip.idseqttl, --Melhoria 399
                          pr_idseqttl => vr_idseqttl,
                          pr_dtconins => vr_dtconins,
                          pr_nrdcpf   => vr_nrdcpf --Melhoria 399
                          );                 
          FETCH cr_crapidp INTO rw_crapidp;

          -- Caso não encontre registros
          IF cr_crapidp%NOTFOUND THEN 
              
            -- Busca as informações da CRAPADP - NRSEQDIG
            OPEN cr_crapadp_segdig(pr_idevento => vr_idevento,
                                   pr_cdevento => vr_cdevento,
                                   pr_cdcooper => vr_cdcooper,
                                   pr_cdagenci => vr_cdagenci,
                                   pr_dtanoage => vr_dtanoage,
                                   pr_dtinievt => vr_dtinievt,
                                   pr_dtfimevt => vr_dtfimevt);                 
            FETCH cr_crapadp_segdig INTO rw_crapadp_segdig;
            -- Fecha o cursor
            CLOSE cr_crapadp_segdig;
              
            vr_nrseqdig := NULL;
            -- Busca as informações da CRAPIDP - Sequence
            vr_nrseqdig := nrseqidp.nextval();
              
            BEGIN
              
            -- Insere Cooperados no Evento
            INSERT INTO crapidp (
              idevento,
              cdcooper,
              dtanoage,
              cdevento,
              cdagenci,
              nrdconta,
              cdgraupr,
              nminseve,
              dsdemail,
              dtpreins,
              dtconins,
              idstains,
              idseqttl,
              tpinseve,
              flgdispe,
              cdageins,
              nrseqdig,
              nrseqeve,
              dsobsins, -- Melhoria 399
              nrdddins, -- Melhoria 399
              nrtelins, -- Melhoria 399
              nrcpfcgc, -- Melhoria 399
              cdcopavl, -- Melhoria 399
              tpctrato, -- Melhoria 399
              nrctremp  -- Melhoria 399
            ) VALUES (
              vr_idevento,
              vr_cdcooper,
              vr_dtanoage,
              vr_cdevento,
              vr_cdagenci,
              vr_numeroconta, --              rw_tbeadip.nrdconta, --Melhoria 399
              9,
              vr_nomeusuario, --substr(rw_tbeadip.nmparticip,1,50), --Melhoria 399
              vr_dseml, --substr(rw_tbeadip.dsemail_particip,1,50), --Melhoria 399
              vr_dtconins,
              vr_dtconins,
              2,
              vr_idseqttl, --rw_tbeadip.idseqttl, --Melhoria 399
              1,
              1,
              vr_cdagenci,
              vr_nrseqdig,
              NVL(rw_crapadp_segdig.nrseqdig, 0),
              rtrim(ltrim(vr_endereco||' '||vr_numlog||' '||vr_complog||' '||vr_ceplog||' '||vr_bairro||' '||vr_cidade||' '||vr_estado ||' '||vr_pais ||' Tipo de Cooperado: '||vr_tipocooperado)), -- Melhoria 399
              vr_nrdddtfc, -- Melhoria 399
              vr_nrtelefo, -- Melhoria 399
              vr_nrdcpf,   -- Melhoria 399
              vr_cdcopavl,   -- Melhoria 399
              vr_tpctrato,   -- Melhoria 399
              vr_nrctremp   -- Melhoria 399
            );
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao registrar o Curso e Participante '
                               ||vr_contador_login||':'
                               ||'\r\nLogin: '||vr_nomlogin
                               ||'\r\nCooperativa: '||vr_cdcooper
                               ||'\r\nPA: '||vr_cdagenci
                               ||'\r\nCurso: '||vr_cdevento
                               ||'\r\nMotivo do erro: '||SQLERRM;
                    
                RAISE vr_exc_saida;
             END;
              
          END IF;
              
          -- Fecha o cursor
          CLOSE cr_crapidp;
            
--        ELSE --Melhoria 399
--          vr_cdcritic := 0; --Melhoria 399
--          vr_dscritic := 'Participante não encontrado ' --Melhoria 399
--                         ||vr_contador_login||':' --Melhoria 399
--                         ||'\r\nLogin: '||vr_nomlogin; --Melhoria 399
            
--          RAISE vr_exc_saida; --Melhoria 399
--        END IF; --Melhoria 399
          
        -- Fecha o cursor
--        CLOSE cr_tbeadip; --Melhoria 399
        
        vr_contador_login := vr_contador_login + 1;
      END LOOP;
      
      -- FINALIZA OS CURSOS COM DATA DE FECHAMENTO MENOR QUE DA DATA ATUAL
      BEGIN
        UPDATE crapadp 
           SET idstaeve = 4
         WHERE cdevento >= 50000 
           AND to_char(dtfineve,'yyyy-mm-dd') < vr_dtdiasis 
           AND idstaeve = 1;
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Erro no encerramento dos Cursos: '||SQLERRM;
          RAISE vr_exc_saida;
      END; 
      
      -- ATUALIZA DATA DA JOB EXECUTADA COM SUCESSO
      BEGIN
        UPDATE crapprm 
           SET dsvlrprm = vr_dtdiasis 
         WHERE 
           nmsistem = 'CRED' AND 
           cdcooper = 0      AND 
           cdacesso = 'EAD_DATA_JOB';
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a Data da JOB: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- INSERE DADOS NAS TABELAS
      COMMIT;
      
      -- Fim do programa
      pc_controla_log_batch('F');

    EXCEPTION
      WHEN vr_exc_saida THEN

          -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, 
                                                 pr_dscritic => vr_dscritic);

        -- Devolvemos código e critica encontradas das variaveis locais
        pr_dscritic := vr_dscritic;
        
        -- RETORNA DADOS NAS TABELAS
        ROLLBACK;
        
        IF UPPER(vr_dscritic) <> 'RETORNO DO XML VAZIO' THEN

          -- Comando para enviar e-mail a OQS
          GENE0003.pc_solicita_email(pr_cdcooper        => 1 --> Cooperativa conectada
                                    ,pr_cdprogra        => 'WPGD0191' --> Programa conectado
                                    ,pr_des_destino     => 'educacao@progrid.coop.br' --> Um ou mais detinatários separados por ';' ou ','
                                    ,pr_des_assunto     => 'Log EaD - Sistema de Relacionamento' --> Assunto do e-mail
                                    ,pr_des_corpo       => pr_dscritic --> Corpo (conteudo) do e-mail
                                    ,pr_des_anexo       => vr_caminho_xml || vr_arquivo_xml --> Um ou mais anexos separados por ';' ou ','
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_log_batch   => 'N' --> Incluir no log a informação do anexo?
                                    ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
        END IF;

        --> manter tabela de email                  
        COMMIT;
      WHEN OTHERS THEN

        cecred.pc_internal_exception;

        -- RETORNA DADOS NAS TABELAS
        ROLLBACK;
        
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro na Rotina WPGD0191.pc_recebe_cursos_aprovados --> '||SQLERRM; 
        
        -- Logar erro no programa
        pc_controla_log_batch('E', pr_dscritic);
        
        IF UPPER(TRIM(vr_dscritic)) <> 'RETORNO DO XML VAZIO' THEN
          -- Comando para enviar e-mail a OQS
          GENE0003.pc_solicita_email(pr_cdcooper        => 1 --> Cooperativa conectada
                                    ,pr_cdprogra        => 'WPGD0191' --> Programa conectado
                                    ,pr_des_destino     => 'educacao@progrid.coop.br' --> Um ou mais detinatários separados por ';' ou ','
                                    ,pr_des_assunto     => 'LOG: EaD - Sistema de Relacionamento' --> Assunto do e-mail
                                    ,pr_des_corpo       => pr_dscritic --> Corpo (conteudo) do e-mail
                                    ,pr_des_anexo       => vr_caminho_xml || vr_arquivo_xml --> Um ou mais anexos separados por ';' ou ','
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_log_batch   => 'N' --> Incluir no log a informação do anexo?
                                    ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
        END IF;
        --> manter tabela de email                  
        COMMIT;
    END;
 
 END pc_recebe_cursos_aprovados;
 
-----------------------------------------------------                       
END WPGD0191;
/
