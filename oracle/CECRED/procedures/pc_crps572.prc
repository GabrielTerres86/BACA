CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS572(pr_cdcooper  IN craptab.cdcooper%TYPE --> Cooperativa solicitada
                                      	     ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                      	     ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      	     ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      	     ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Crítica encontrada
                                      	     ,pr_dscritic OUT VARCHAR2)  IS         --> Texto de erro/critica encontrada
  /* ...........................................................................

     Programa: PC_CRPS572                          ANTIGO: Fontes/crps572.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Irlan
     Data    : Jun/2009.                     Ultima atualizacao: 22/08/2017

     Dados referentes ao programa:

     Frequencia: Mensal.
     Objetivo  : Importar arquivos XML 3046 referente a consulta de Op. Finan_
                 ceiras no SFN.
                 Solicitacao : 86
                 Ordem do programa na solicitacao = 55
                 Paralelo

     Observacoes:

     Alteracoes:  02/08/2010 - Incluir a chamada ao fimprg.p quando nao tiver
                               arquivo a ser importado (Irlan).

                  22/08/2010 - Ajuste no tratamento da importaçao de
                               múltiplos arquivos (Irlan).

                  01/03/2011 - Ajuste da conversao da data do XML para a data
                               de referencia da tabela (Henrique).

                  30/09/2011 - Ajuste para atender ao novo layout "3046"
                               (Adriano).

                  08/03/2012 - Incluído execucao do fimprg.p quando entrar na
                               critica "Arquivo ja importado" (Irlan)

                  09/08/2012 - Alteraçoes no processamento do documento 3046
                               (Gabriel).

                  06/05/2013 - Incluso tratamento para efetuar commit ao processar
                               10000 registros na procedure cria_crapvop e
                               cria_crapopf (Daniel).

                  27/11/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).

                  18/12/2013 - Ajustar padrões (Renato - Supero).

                  23/01/2014 - Ajustar tratamento da leitura de arquivos, para
                               continuar o processamento de outro arquivo, caso
                               algum apresente erro. (Renato-Supero)

                  22/04/2014 - Ajustar para inserir na CRAPVOP quando o nó do
                               cliente nao possuir filhos (Andrino - RKAM)
                               
                  05/05/2014 - Correções para leitura do XML.
                               Otimização de performance para manipulação do XML (Petter - Supero).
                               
                  04/03/2015 - Alterado programa para tratar corretamente a carga de 
                               dados das tabelas de memória, pois haviam diversas 
                               informações que estavam sendo perdidas. Conforme foi
                               relatado no SD 252426  ( Renato - Supero )
                               
                  20/04/2015 - Alteracao para encaminhar a critica "Erro ao importar 
                               arquivo xml 3046" por email, removendo-a desta forma 
                               do log do processo. (Jaison/Gielow - SD: 273558)

                  31/01/2017 - Ajustar mensagens de erro escritas no log do proc_batch, pois 
                               as mensagens não estavam sendo apresentadas (Renato-Supero)

                  17/04/2017 - #462629 Otimização do programa. Melhoria de performance na execução dos
                               cursores cr_crapcop_ass e cr_crapvop (Carlos)

                  22/08/2017 - Gravar informações do Header do arquivo 3046 na tabela cecred.tbbi_opf_header
                               (Lucas Ranghetti #549788)
  ............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop IS
    SELECT crapcop.dsdircop
         , crapcop.nmrescop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

  -- Popular o registro de memória de pessoas jurídicas
  CURSOR cr_crapcop_ass IS
    SELECT DISTINCT
           crapass.nrcpfcgc
         , SUBSTR(to_char(crapass.nrcpfcgc,'FM00000000000000'),1,8) stnrcnpj
      FROM crapcop
         , crapass
     WHERE crapass.cdcooper  = crapcop.cdcooper
       AND crapass.inpessoa > 1
       AND crapass.dtdemiss IS NULL;

  -- Buscar o cadastro da operação financeira
  CURSOR cr_crapopf(pr_dtrefere  crapopf.dtrefere%TYPE ) IS
    SELECT crapopf.nrcpfcgc
         , crapopf.dtrefere
      FROM crapopf
     WHERE  crapopf.dtrefere >= pr_dtrefere;

  -- Buscar o vencimento das operações financeiras
  CURSOR cr_crapvop(pr_dtrefere  crapvop.dtrefere%TYPE) IS
    SELECT crapvop.nrcpfcgc
         , crapvop.dtrefere
         , crapvop.cdvencto
         , crapvop.vlvencto
         , crapvop.cdmodali
         , crapvop.flgmoest
      FROM crapvop
     WHERE crapvop.dtrefere >= pr_dtrefere;

  -- REGISTROS
  rw_crapcop          cr_crapcop%ROWTYPE;

  -- TIPOS
  -- Record para guardar informações de pessoas juridicas
  TYPE rec_copass IS RECORD (nrcpfcgc  crapass.nrcpfcgc%TYPE
                            ,stnrcnpj  VARCHAR2(8)
                            ,inpessoa  crapass.inpessoa%TYPE);
  -- Tabela de memória de pessoas juridicas
  TYPE typ_copass  IS TABLE OF rec_copass INDEX BY VARCHAR2(14); -- Lista com indice pelo CNPJ completo
  TYPE typ_cpbase  IS TABLE OF typ_copass INDEX BY VARCHAR2(10); -- Lista indexada pela base do CNPJ
  
  -- Record para dados do XML
  TYPE rec_crapvop IS RECORD (nrcpfcgc crapvop.nrcpfcgc%TYPE
                             ,dtrefere crapvop.dtrefere%TYPE
                             ,cdmodali crapvop.cdmodali%TYPE
                             ,cdvencto crapvop.cdvencto%TYPE
                             ,flgmoest crapvop.flgmoest%TYPE
                             ,vlvencto crapvop.vlvencto%TYPE);
  -- Tabela de memória para dados do XML
  TYPE typ_crapvop IS TABLE OF rec_crapvop  INDEX BY BINARY_INTEGER;
  TYPE typ_tab_crapvop IS TABLE OF rec_crapvop INDEX BY VARCHAR2(400);
  -- Tabela de memória para receber oss atributos do nodo e ordená-los
  TYPE typ_sortatt IS TABLE OF crapvop.vlvencto%TYPE INDEX BY BINARY_INTEGER; -- REcebera o cdvento como indice
  -- Tabela de memória para os registros processados da cpfcgc
  TYPE typ_cpfcgc  IS TABLE OF rec_copass INDEX BY BINARY_INTEGER;
  
  -- Registro para as OPs
  TYPE rec_crapopf IS RECORD (nrcpfcgc   NUMBER
                             ,dtrefere   DATE
                             ,qtopesfn   NUMBER
                             ,qtifssfn   NUMBER
                             ,qtsbjsfn   NUMBER
                             ,vlsbjsfn   NUMBER
                             ,percdocp   NUMBER
                             ,percvolp   NUMBER
                             ,inpessoa   NUMBER
                             ,idopf_header NUMBER);
  -- Tabela de memória para as OPs
  TYPE typ_crapopf IS TABLE OF rec_crapopf INDEX BY VARCHAR2(100);
  TYPE typ_crapopfi IS TABLE OF rec_crapopf INDEX BY PLS_INTEGER;
  TYPE typ_tab_crapopf IS TABLE OF rec_crapopf INDEX BY VARCHAR2(400);
  -- Tabela de memória para ordenar os arquivos
  TYPE typ_sortarq IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS572';
  -- Datas de movimento e controle
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  -- Lista de arquivos
  vr_array_arquivo gene0002.typ_split;
  vr_sort_arquivos typ_sortarq;
  vr_list_arquivos VARCHAR2(10000);
  -- Tabela de pessoas jurídicas
  vr_crawass       typ_cpbase; -- O nome da variável é o mesmo do progress para facilitar o entendimento
  
  --Tipo do Cursor para Bulk Collect
  TYPE typ_crapcop_ass_bulk IS TABLE OF cr_crapcop_ass%ROWTYPE;
  vr_crapcop_ass_bulk typ_crapcop_ass_bulk;
  
  --Tipo do Cursor para Bulk Collect
  TYPE typ_crapvop_bulk IS TABLE OF cr_crapvop%ROWTYPE;
  vr_crapvop_bulk typ_crapvop_bulk;
  
  vr_inawass       VARCHAR2(14);
  -- Tabela de memória para dados do XML
  vr_crapvop       typ_crapvop;
  vr_sortatt       typ_sortatt;
  vr_incodvenc     NUMBER;
  -- Tabela auxiliar de cpf e cnpj
  vr_cpfcgc        typ_cpfcgc;
  -- Tabela de memória para as OPs
  vr_crapopf       typ_crapopf;
  vr_crapopfi      typ_crapopfi;
  -- Variável para formar chaves para collections
  vr_dschave       VARCHAR2(100);
  vr_indOPv        PLS_INTEGER;
  vr_ixVOP         PLS_INTEGER := 0;
  vr_ixOPF         PLS_INTEGER := 0;
  vr_ixOPFv        VARCHAR2(100);
  -- Variáveis para leitura do XML
  vr_clobarq       CLOB;
  vr_filexml       UTL_FILE.FILE_TYPE;
  vr_dslinha       VARCHAR2(32767);
  vr_bufferxml     VARCHAR2(32767);
  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  -- Arquivo de log do processamento
  vr_nmarqdat      CONSTANT VARCHAR2(15) := 'proc3046.log';
  vr_filelog       utl_file.file_type;
  -- Diretório das cooperativas
  vr_dsdireto      VARCHAR2(200);
  vr_dsdirzip      VARCHAR2(200);
  -- Tipo de saída do comando Host
  vr_typ_said      VARCHAR2(100);
  -- Endereços de e-mail
  vr_des_destino   VARCHAR2(500);
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  -- Flag que indica o final do arquivo
  eof              BOOLEAN := FALSE;
  -- PL Table para tabelas acessadas constantemente
  vr_tab_crapvop   typ_tab_crapvop;
  vr_tab_crapopf   typ_tab_crapopf;

  PROCEDURE pc_grava_header_3046(pr_nmarquivo          IN VARCHAR2
                                ,pr_nrcnpj_if          IN NUMBER
                                ,pr_dtbase             IN DATE
                                ,pr_nrprotocolo        IN NUMBER
                                ,pr_dhgeracao          IN VARCHAR2
                                ,pr_peif_dados_individ IN NUMBER
                                ,pr_pevol_operacoes_if IN NUMBER
                                ,pr_idopf_header      OUT NUMBER
                                ,pr_dscritic          OUT VARCHAR2) IS
  BEGIN 


BEGIN
      INSERT INTO cecred.tbbi_opf_header
        (nmarquivo,
         dhprocesso,
         nrcnpj_if,
         dtbase,
         nrprotocolo,
         dhgeracao,
         peif_dados_individ,
         pevol_operacoes_if)
      VALUES
        (pr_nmarquivo,
         SYSDATE,
         pr_nrcnpj_if,
         pr_dtbase,
         pr_nrprotocolo,
         to_Date(pr_dhgeracao,'rrrr-mm-dd hh24:mi:ss'),
         pr_peif_dados_individ,
         pr_pevol_operacoes_if)
      RETURNING idopf_header INTO pr_idopf_header;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic:= 'Erro ao inserir os dados do Header do Arquivo 3046 - cecred.tbbi_opf_header: '||SQLERRM;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || pr_dscritic );
    END;
  END pc_grava_header_3046;

BEGIN

  /********** TRATAMENTOS INICIAIS **********/
  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS572',
                             pr_action => vr_cdprogra);

  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop;
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

  -- Buscar as datas do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- 001 - Sistema sem data de movimento.
    vr_cdcritic := 1;

    CLOSE btch0001.cr_crapdat;
    -- Log de crítica
    RAISE vr_exc_saida;
  ELSE
    -- Atualizar as variáveis referente a datas
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1 -- Fixo
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);

  -- Se retornou algum erro
  IF vr_cdcritic <> 0 THEN
    -- Log de critica
    RAISE vr_exc_saida;
  END IF;

  -- Buscar diretórios de arquivos
  -- Padrão
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper);
  -- Arquivos ZIP
  vr_dsdirzip := gene0001.fn_diretorio(pr_tpdireto => 'M', pr_cdcooper => pr_cdcooper, pr_nmsubdir => '/contab');

  /********** BUSCAR E DESCOMPACTAR OS ARQUIVOS ZIP **********/  
  -- Retorna a lista dos arquivos ZIPS do diretório, conforme padrão *SCR2.3046*.zip
  gene0001.pc_lista_arquivos(pr_path     => vr_dsdirzip
                            ,pr_pesq     => '%SCR2.3046%.zip'
                            ,pr_listarq  => vr_list_arquivos
                            ,pr_des_erro => vr_dscritic);

  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;

  -- Verifica se retornou arquivos
  IF vr_list_arquivos IS NOT NULL THEN
    -- Listar os arquivos em um array
    vr_array_arquivo := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos, pr_delimit => ',');

    -- Percorre os arquivos retornados
    FOR ind IN NVL(vr_array_arquivo.FIRST,0)..NVL(vr_array_arquivo.LAST,-1) LOOP
      -- Descompactar o arquivo listado
      gene0002.pc_zipcecred(pr_cdcooper => pr_cdcooper,
                            pr_tpfuncao => 'E', --Extract
                            pr_dsorigem => vr_dsdirzip || '/' || vr_array_arquivo(ind),
                            pr_dsdestin => vr_dsdirzip, 
                            pr_dspasswd => NULL,
                            pr_flsilent => 'S',
                            pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;

      -- Mover o arquivo compactado
      GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_dsdirzip || '/' || vr_array_arquivo(ind) || ' ' || vr_dsdireto || '/salvar'
                                 ,pr_flg_aguard  => 'S'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);
    END LOOP;

    -- Limpa a lista de arquivos
    vr_array_arquivo.DELETE;
  END IF;
  
  /********** BUSCAR TODOS OS ARQUIVOS DESCOMPACTADOS **********/
  vr_list_arquivos := NULL;

  -- Retorna a lista dos arquivos ZIPS do diretório, conforme padrão *SCR2.3046*.zip
  gene0001.pc_lista_arquivos(pr_path     => vr_dsdirzip
                            ,pr_pesq     => '%SCR2.3046%.xml'
                            ,pr_listarq  => vr_list_arquivos
                            ,pr_des_erro => vr_dscritic);
  
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;

  -- Verifica se retornou arquivos
  IF vr_list_arquivos IS NOT NULL THEN
    -- Listar os arquivos em um array
    vr_array_arquivo := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos, pr_delimit => ',');

    /* Ordenar pelo nome do arquivo */
    -- Percorrer todos os arquivos selecionados
    FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP
      -- Adicionar o arquivo nos array usando o nome como chave
      vr_sort_arquivos(vr_array_arquivo(ind)) := vr_array_arquivo(ind);
    END LOOP;

    -- Limpar o array de arquivos
    vr_array_arquivo.DELETE;

    -- Primeiro registro
    vr_dschave := vr_sort_arquivos.FIRST;

    -- Percorrer o array sort e incluir os arquivos no array de arquivos
    LOOP
      -- Criar a posição no array
      vr_array_arquivo.EXTEND;
      -- Acresce mais um registro no array
      vr_array_arquivo(vr_array_arquivo.COUNT) := vr_sort_arquivos(vr_dschave);

      --Sair quando o ultimo indice for processado
      EXIT WHEN vr_dschave = vr_sort_arquivos.LAST;
      -- Buscar o próximo registro
      vr_dschave := vr_sort_arquivos.NEXT(vr_dschave);
    END LOOP;

    -- Limpando os dados em memória
    vr_sort_arquivos.DELETE;
  ELSE
    -- Limpa as variáveis para não gerar crítica
    vr_cdcritic := 0;
    vr_dscritic := NULL;

    -- Finaliza o programa
    RAISE vr_exc_fimprg;
  END IF;

  -- Definir o arquivo de log
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto||'/log'
                          ,pr_nmarquiv => vr_nmarqdat
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_filelog
                          ,pr_des_erro => vr_dscritic);

  -- Se retornar critica
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  -- Popular o registro de memória de pessoas jurídicas
  OPEN cr_crapcop_ass;  
  --Carregar Bulk Collect
  LOOP
    FETCH cr_crapcop_ass BULK COLLECT INTO vr_crapcop_ass_bulk LIMIT 30000;  
    EXIT WHEN vr_crapcop_ass_bulk.COUNT = 0;

    -- Popular o registro de memória de pessoas jurídicas
    FOR idx IN vr_crapcop_ass_bulk.FIRST .. vr_crapcop_ass_bulk.LAST LOOP      
    -- Guarda o registro na tabela de memória, ordenando em primeiro nível por estabelecimento apenas
      vr_crawass(vr_crapcop_ass_bulk(idx).stnrcnpj)(vr_crapcop_ass_bulk(idx).nrcpfcgc).nrcpfcgc := vr_crapcop_ass_bulk(idx).nrcpfcgc;
      vr_crawass(vr_crapcop_ass_bulk(idx).stnrcnpj)(vr_crapcop_ass_bulk(idx).nrcpfcgc).stnrcnpj := vr_crapcop_ass_bulk(idx).stnrcnpj;
      vr_crawass(vr_crapcop_ass_bulk(idx).stnrcnpj)(vr_crapcop_ass_bulk(idx).nrcpfcgc).inpessoa := 2;
  END LOOP;

  END LOOP;
  
  --Fechar Cursor
  CLOSE cr_crapcop_ass;

  -- Buscar os endereços de e-mail para enviar o arquivo
  vr_des_destino := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_cdacesso => 'PROC3046_LOG_EMAIL');

  -- Percorrer todos os arquivos XML encontrados
  FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP 
    -- Abrir o arquivo
    vr_filexml := utl_file.fopen(vr_dsdirzip || '/', vr_array_arquivo(ind), 'r');
    eof := FALSE;

    -- Abrir Clob para gravação 
    DBMS_LOB.createtemporary(vr_clobarq , TRUE , DBMS_LOB.session);
    DBMS_LOB.open(vr_clobarq, DBMS_LOB.LOB_ReadWrite);

    -- Percorrer todas as linhas do arquivo
    WHILE NOT(eof) LOOP
      BEGIN      
        -- Lê a linha do arquivo
        utl_file.get_line(vr_filexml, vr_dslinha);
      EXCEPTION
        WHEN no_data_found THEN
          vr_dslinha := NULL;
          eof := TRUE;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro lendo arquivo: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Somente gravar linhas que contenham conteudo
      IF vr_dslinha IS NOT NULL THEN      
        -- Gravar informações em buffer
        vr_bufferxml := vr_bufferxml || vr_dslinha;
        
        -- Escrever a linha no clob utilizando buffer
        gene0002.pc_clob_buffer(pr_dados   => vr_bufferxml
                               ,pr_btam    => 32000
                               ,pr_gravfim => FALSE
                               ,pr_clob    => vr_clobarq);
      END IF;
    END LOOP;
    
    -- Escrever a última linha no clob utilizando buffer
    IF LENGTH(vr_bufferxml) > 3 THEN
      gene0002.pc_clob_buffer(pr_dados   => vr_bufferxml
                             ,pr_btam    => 32000
                             ,pr_gravfim => TRUE
                             ,pr_clob    => vr_clobarq);
    END IF;
    
    -- Fecha o arquivo
    utl_file.fclose(vr_filexml);

    /*********** BLOCO PARA TRATAR O XML ***********/
    DECLARE
      -- Variáveis para tratamento do XML
      vr_node_list       xmldom.DOMNodeList;
      vr_parser          xmlparser.Parser;
      vr_doc             xmldom.DOMDocument;
      vr_attrmap         DBMS_XMLDOM.DOMNamedNodeMap;  --> Mapa de atributos do elemento
      vr_lenght          NUMBER;
      vr_node_name       VARCHAR2(100);
      vr_item_node       xmldom.DOMNode;
      vr_node_root       xmldom.DOMNode; -- Doc3046
      vr_node_cli        xmldom.DOMNode; -- Cli
      vr_node_op         xmldom.DOMNode; -- Op
      vr_node_venc       xmldom.DOMNode; -- Venc

      -- Controles
      vr_load_root       BOOLEAN := FALSE; -- Doc3046
      vr_load_cli        BOOLEAN := FALSE; -- Cli
      vr_load_op         BOOLEAN := FALSE; -- Op

      vr_aux  VARCHAR2(200);
      -- Variáveis para trabalhar com os valores do XML
      vr_xml_dtrefere    DATE;
      vr_xml_percdocp    NUMBER;
      vr_xml_percvolp    NUMBER;
      vr_xml_cnpjinst    NUMBER;
      vr_xml_protocol    NUMBER;
      vr_xml_dtgeraca    VARCHAR2(50);
      vr_xml_nmarquiv    VARCHAR2(100);
      vr_idopf_header    NUMBER;

      vr_xml_qtopesfn    NUMBER;
      vr_xml_qtifssfn    NUMBER;
      vr_xml_qtsbjsfn    NUMBER;
      vr_xml_vlsbjsfn    NUMBER;
      vr_xml_stcpfcgc    VARCHAR2(20);
      vr_xml_flgpj       BOOLEAN;
      vr_xml_cdmodali    VARCHAR2(10);
      vr_xml_flgmoest    BOOLEAN;

    BEGIN    
      -- Inicializar variável
      vr_indOPv := 0;

      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      vr_parser := xmlparser.newParser;
      xmlparser.parseClob(vr_parser, vr_clobarq);
      
      -- Limpar memória alocado ao CLOB, já que o mesmo já foi enviado ao XMLType
      DBMS_LOB.close(vr_clobarq);
      DBMS_LOB.freetemporary(vr_clobarq);
      
      -- Capturar o parser XML
      vr_doc := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);

      -- Faz o get de toda a lista de elementos
      vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
      vr_lenght := xmldom.getLength(vr_node_list);

      -- Percorrer os elementos
      FOR i IN 0..vr_lenght-1 LOOP
        -- Pega o item
        vr_item_node := xmldom.item(vr_node_list, i);

        -- Captura o nome do nodo
        vr_node_name := xmldom.getNodeName(vr_item_node);

        -- Verifica qual nodo esta sendo lido
        IF UPPER(vr_node_name) = 'DOC3046' THEN
          vr_node_root := vr_item_node;
          vr_node_cli  := NULL;
          vr_node_op   := NULL;
          vr_node_venc := NULL;
          vr_load_root := TRUE;
          CONTINUE; -- Descer para o próximo filho
        ELSIF UPPER(vr_node_name) = 'CLI' THEN
          vr_node_cli  := vr_item_node;
          vr_node_op   := NULL;
          vr_node_venc := NULL;
          vr_load_cli  := TRUE;
          -- Verifica se eh um no sem filhos
          IF UPPER(xmldom.getNodeName(xmldom.item(vr_node_list, i+1))) = 'CLI' OR
             i = vr_lenght-1 THEN
            NULL;
          ELSE
            CONTINUE; -- Descer para o próximo filho
          END IF;
        ELSIF UPPER(vr_node_name) = 'OP' THEN
          vr_node_op   := vr_item_node;
          vr_node_venc := NULL;
          vr_load_op   := TRUE;
          CONTINUE; -- Descer para o próximo filho
        ELSIF UPPER(vr_node_name) = 'VENC' THEN
          vr_node_venc := vr_item_node;
        ELSE
          CONTINUE; -- Descer para o próximo filho
        END IF;

        -- Se houve o load de um novo NODO: Doc3046
        IF vr_load_root THEN
          -- Buscar valor: DtBase
          vr_xml_dtrefere := LAST_DAY(TO_DATE(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_root),'DtBase'), 'YYYY-MM'));
          -- Buscar valor: PercDocProcess
          vr_xml_percdocp := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_root),'PercDocProcess'),'9999.99');
          -- Buscar valor: VolPercProcess
          vr_xml_percvolp := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_root),'VolPercProcess'),'99999999999.99');
          -- Buscar valor: CNPJ
          vr_xml_cnpjinst := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_root),'CNPJ'),'99999999999999');
          -- Buscar valor: Protocolo
          vr_xml_protocol := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_root),'Protocolo'),'999999999999999');
          -- Buscar valor: DtGeracao
          vr_xml_dtgeraca := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_root),'DtGeracao');
          -- Nome do Arquivo processado
          vr_xml_nmarquiv := vr_array_arquivo(ind);
          
          -- Gravar Header do arquivo 3046 na cecred.tbbi_opf_header
          pc_grava_header_3046(pr_nmarquivo => vr_xml_nmarquiv
                              ,pr_nrcnpj_if => vr_xml_cnpjinst      
                              ,pr_dtbase => vr_xml_dtrefere          
                              ,pr_nrprotocolo => vr_xml_protocol
                              ,pr_dhgeracao => vr_xml_dtgeraca
                              ,pr_peif_dados_individ => vr_xml_percdocp
                              ,pr_pevol_operacoes_if => vr_xml_percvolp
                              ,pr_idopf_header => vr_idopf_header
                              ,pr_dscritic => vr_dscritic);
          
          -- Seta como lido
          vr_load_root := FALSE;
        END IF;

        -- Se houve o load de um novo NODO: Cli
        IF vr_load_cli THEN
          -- Buscar valor: Tp
          IF xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_cli),'Tp') = '2' THEN
            -- Atualizar o indicador para true
            vr_xml_flgpj := TRUE;
          ELSE
            -- Atualizar o indicador para false
            vr_xml_flgpj := FALSE;
          END IF;
          -- Buscar valor: Cd
          vr_xml_stcpfcgc := xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_cli),'Cd');
          -- Buscar valor: QtdOp
          vr_xml_qtopesfn := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_cli),'QtdOp'));
          -- Buscar valor: QtdIf
          vr_xml_qtifssfn := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_cli),'QtdIf'));
          -- Buscar valor: QtdOpJud
          vr_xml_qtsbjsfn := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_cli),'QtdOpJud'));
          -- Buscar valor: RespTotJud
          vr_xml_vlsbjsfn := TO_NUMBER(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_cli),'RespTotJud'),'99999999999.99');

          -- Seta como lido
          vr_load_cli := FALSE;
        END IF;

        -- Limpa a tabela de memória
        vr_cpfcgc.delete;

        -- Se a flag estiver como TRUE
        IF vr_xml_flgpj THEN
          -- Se há registros de associados na tabela
          IF vr_crawass.COUNT() > 0 AND
            -- Verifica se existe o CNPJ base que está no XML
            vr_crawass.EXISTS(vr_xml_stcpfcgc) THEN
              -- Buscar o primeiro indice
              vr_inawass := vr_crawass(vr_xml_stcpfcgc).FIRST;
              -- Percorrer todos os registros
              LOOP
                -- Grava o novo registro
                vr_cpfcgc(vr_cpfcgc.count()+1).nrcpfcgc := vr_crawass(vr_xml_stcpfcgc)(vr_inawass).nrcpfcgc;
                vr_cpfcgc( vr_cpfcgc.count() ).inpessoa := vr_crawass(vr_xml_stcpfcgc)(vr_inawass).inpessoa;
                
                EXIT WHEN vr_inawass = vr_crawass(vr_xml_stcpfcgc).LAST;
                -- Buscar o proximo registro para ser gravado
                vr_inawass := vr_crawass(vr_xml_stcpfcgc).NEXT(vr_inawass);
              END LOOP; -- Fim loop registros
          END IF; -- Fim COUNT > 0
        ELSE
          -- Grava o novo registro
          vr_cpfcgc(vr_cpfcgc.count() + 1).nrcpfcgc := TO_NUMBER(vr_xml_stcpfcgc);
          vr_cpfcgc(vr_cpfcgc.count()).inpessoa := 1;
        END IF;

        -- Percorre os registros inseridos
        FOR indcgc IN NVL(vr_cpfcgc.FIRST,0)..NVL(vr_cpfcgc.LAST, -1) LOOP
          -- Montar a chave de acesso da tabela
          vr_ixOPFv := LPAD(vr_cpfcgc(indcgc).nrcpfcgc, 25, '0') || TO_CHAR(vr_xml_dtrefere, 'DDMMRRRR');

          -- Atualizar o registro e caso o mesmo não exista cria!
          vr_crapopf(vr_ixOPFv).nrcpfcgc := vr_cpfcgc(indcgc).nrcpfcgc;
          vr_crapopf(vr_ixOPFv).dtrefere := vr_xml_dtrefere;
          vr_crapopf(vr_ixOPFv).qtopesfn := vr_xml_qtopesfn;
          vr_crapopf(vr_ixOPFv).qtifssfn := vr_xml_qtifssfn;
          vr_crapopf(vr_ixOPFv).qtsbjsfn := vr_xml_qtsbjsfn;
          vr_crapopf(vr_ixOPFv).vlsbjsfn := vr_xml_vlsbjsfn;
          vr_crapopf(vr_ixOPFv).percdocp := vr_xml_percdocp;
          vr_crapopf(vr_ixOPFv).percvolp := vr_xml_percvolp;
          vr_crapopf(vr_ixOPFv).inpessoa := vr_cpfcgc(indcgc).inpessoa;
          vr_crapopf(vr_ixOPFv).idopf_header := vr_idopf_header;
        END LOOP;

        -- Se houve o load de um novo NODO: Op
        IF vr_load_op THEN
          -- Buscar valor: Mod
          vr_xml_cdmodali := LPAD(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_op),'Mod'), 4, '0');
          -- Buscar valor: VincME
          IF NVL(xmldom.getAttribute(xmlDom.MAKEELEMENT(vr_node_op),'VincME'), 'N') = 'S' THEN
            -- Atualizar o indicador para true
            vr_xml_flgmoest := TRUE;
          ELSE
            -- Atualizar o indicador para false
            vr_xml_flgmoest := FALSE;
          END IF;

          -- Seta como lido
          vr_load_op := FALSE;
        END IF;

        -- Retornar a lista de atributos do nodo
        vr_attrmap := xmldom.getAttributes(vr_node_venc);
        -- Limpar a tabela de memória que receberá os itens a serem ordenados
        vr_sortatt.DELETE;

        -- Percorre toda a lista de atributos do nodo Venc a atribui ao registro de memória para ordenação
        FOR ind IN 0..dbms_xmldom.getlength(vr_attrmap)-1 LOOP
          -- Buscar o nome do atributo
          vr_aux := dbms_xmldom.getnodename(dbms_xmldom.item(vr_attrmap,ind));

          -- Quebra o nome do atributo e usa como indice para guardar o valor
          vr_sortatt(TO_NUMBER(SUBSTR(vr_aux,2))) := gene0002.fn_char_para_number(dbms_xmldom.getnodevalue(dbms_xmldom.item(vr_attrmap,ind)));
        END LOOP;

        -- Se encontrar registro... percorre todos
        IF vr_sortatt.COUNT() > 0 THEN
          -- Indice inicial
          vr_incodvenc := vr_sortatt.FIRST();
          LOOP
            -- Percorre os registros inseridos
            FOR indcgc IN NVL(vr_cpfcgc.FIRST, 0)..NVL(vr_cpfcgc.LAST, -1) LOOP
              -- Gerar contagem para o índice
              vr_ixVOP := vr_ixVOP + 1;

              -- Popular a tabela de memória com os dados já encontrados
              vr_crapvop(vr_ixVOP).nrcpfcgc := vr_cpfcgc(indcgc).nrcpfcgc; -- vr_xml_stcpfcgc
              vr_crapvop(vr_ixVOP).dtrefere := vr_xml_dtrefere;
              vr_crapvop(vr_ixVOP).cdmodali := vr_xml_cdmodali;
              vr_crapvop(vr_ixVOP).flgmoest :=  sys.diutil.bool_to_int(vr_xml_flgmoest);
              vr_crapvop(vr_ixVOP).cdvencto := vr_incodvenc;
              vr_crapvop(vr_ixVOP).vlvencto := vr_sortatt(vr_incodvenc);
            END LOOP;

            -- Sai após processar o último
            EXIT WHEN vr_incodvenc = vr_sortatt.LAST();
            -- próximo
            vr_incodvenc := vr_sortatt.NEXT(vr_incodvenc);
          END LOOP;
        END IF;
      END LOOP;
      
      -- Eliminar documento DOM
      xmldom.freeDocument(vr_doc);

      -- Guarda a primeira chave para acesso ao registro de memória
      -- Carregar PL Table com dados da tabela CRAPOPF
      FOR regs IN cr_crapopf(vr_xml_dtrefere) LOOP
        vr_tab_crapopf(LPAD(regs.nrcpfcgc, 25, '0') || TO_CHAR(regs.dtrefere, 'DDMMRRRR')).nrcpfcgc := regs.nrcpfcgc;
        vr_tab_crapopf(LPAD(regs.nrcpfcgc, 25, '0') || TO_CHAR(regs.dtrefere, 'DDMMRRRR')).dtrefere := regs.dtrefere;
      END LOOP;
      
      vr_ixOPFv := vr_crapopf.FIRST();

      -- Percorre o registro de memória
      LOOP
        EXIT WHEN vr_ixOPFv IS NULL;
        
        -- Verifica a data e o número do cgc
        IF vr_crapopf(vr_ixOPFv).dtrefere = vr_xml_dtrefere 
          -- Buscar o registro da crapopf se encontrar registros na CRAPOPF
          AND vr_tab_crapopf.exists(LPAD(vr_crapopf(vr_ixOPFv).nrcpfcgc, 25, '0') || TO_CHAR(vr_crapopf(vr_ixOPFv).dtrefere, 'DDMMRRRR')) THEN
          
            -- Eliminar registro da PL Table
            vr_crapopf.delete(vr_ixOPFv);
            
            -- Escreve no log do arquivo
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_filelog
                                          ,pr_des_text => TO_CHAR(vr_dtmvtolt,'dd/mm/yyyy')||' '||
                                                          TO_CHAR(SYSDATE,'hh24:mi:ss')    ||' => '||
                                                          'CRAPOPF: Arquivo '||vr_dsdirzip||'/'||vr_array_arquivo(ind)||' '||
                                                          'DATABASE: '||TO_CHAR(vr_crapopf(vr_ixOPFv).dtrefere,'dd/mm/yyyy')||' '||
                                                          'CPF_CNPJ: '||TO_CHAR(vr_crapopf(vr_ixOPFv).nrcpfcgc)||' ERRO: Registro ja existente');
          END IF;

        -- Buscar a próxima chave
        vr_ixOPFv := vr_crapopf.NEXT(vr_ixOPFv);
      END LOOP;
      
      -- Limpar PL Table
      vr_tab_crapopf.delete;
      
      -- Migrar registros de PL Table caracter para indexador inteiro
      vr_ixOPFv := vr_crapopf.first;
      WHILE vr_ixOPFv IS NOT NULL LOOP
        vr_ixOPF := vr_ixOPF + 1;
        vr_crapopfi(vr_ixOPF) := vr_crapopf(vr_ixOPFv);
        vr_ixOPFv := vr_crapopf.next(vr_ixOPFv);
      END LOOP;
      
      -- Limpar PL Table
      vr_crapopf.delete;

      vr_ixOPF := 0;
      BEGIN
        FORALL vr_ixOPF IN INDICES OF vr_crapopfi SAVE EXCEPTIONS
          INSERT INTO crapopf(nrcpfcgc
                             ,dtrefere
                             ,qtopesfn
                             ,qtifssfn
                             ,qtsbjsfn
                             ,vlsbjsfn
                             ,percdocp
                             ,percvolp
                             ,inpessoa
                             ,idopf_header)
                       VALUES(NVL(vr_crapopfi(vr_ixOPF).nrcpfcgc, 0) 
                             ,vr_crapopfi(vr_ixOPF).dtrefere        
                             ,NVL(vr_crapopfi(vr_ixOPF).qtopesfn, 0) 
                             ,NVL(vr_crapopfi(vr_ixOPF).qtifssfn, 0) 
                             ,NVL(vr_crapopfi(vr_ixOPF).qtsbjsfn, 0) 
                             ,NVL(vr_crapopfi(vr_ixOPF).vlsbjsfn, 0)
                             ,NVL(vr_crapopfi(vr_ixOPF).percdocp, 0)
                             ,NVL(vr_crapopfi(vr_ixOPF).percvolp, 0)
                             ,NVL(vr_crapopfi(vr_ixOPF).inpessoa, 0)
                             ,NVL(vr_crapopfi(vr_ixOPF).idopf_header, 0));
      EXCEPTION
        WHEN others THEN
          vr_dscritic := 'Erro ao incluir registro CRAPOPF: ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(1). ERROR_CODE));
          RAISE vr_exc_saida;
      END;
      
      -- Limpar PL Table
      vr_crapopfi.delete;

      -- Criar PL Table para dados originais da CRAPVOP
      OPEN cr_crapvop(vr_xml_dtrefere);        
      LOOP        
        FETCH cr_crapvop BULK COLLECT INTO vr_crapvop_bulk LIMIT 100000;
        EXIT WHEN vr_crapvop_bulk.COUNT = 0;
        -- Popular o registro de memória
        FOR idx IN vr_crapvop_bulk.FIRST .. vr_crapvop_bulk.LAST LOOP      

          vr_tab_crapvop(LPAD(vr_crapvop_bulk(idx).nrcpfcgc, 25, '0') ||
                         TO_CHAR(vr_crapvop_bulk(idx).dtrefere, 'DDMMRRRR') ||
                         LPAD(vr_crapvop_bulk(idx).cdmodali, 10, '0') ||
                         LPAD(vr_crapvop_bulk(idx).cdvencto, 10, '0') ||
                         LPAD(vr_crapvop_bulk(idx).flgmoest, 3, '0')).vlvencto := vr_crapvop_bulk(idx).vlvencto;
        END LOOP;
      END LOOP;
      
      CLOSE cr_crapvop;
      
      -- Criar os registros da CRAPVOP
      -- Capturar o primeiro índice
      vr_ixVOP := vr_crapvop.first;

      LOOP
        -- Controlar saída do LOOP ao processar o último registro da PL Table
        EXIT WHEN vr_ixVOP IS NULL;
        
        -- Verifica a data e o número do cgc
        IF vr_crapvop(vr_ixVOP).dtrefere = vr_xml_dtrefere
          -- Se encontrar registros na CRAPVOP
          AND vr_tab_crapvop.exists(LPAD(vr_crapvop(vr_ixVOP).nrcpfcgc, 25, '0') ||
                                   TO_CHAR(vr_crapvop(vr_ixVOP).dtrefere, 'DDMMRRRR') ||
                                   LPAD(vr_crapvop(vr_ixVOP).cdmodali, 10, '0') ||
                                   LPAD(vr_crapvop(vr_ixVOP).cdvencto, 10, '0') ||
                                   LPAD(vr_crapvop(vr_ixVOP).flgmoest, 3, '0')) THEN
            -- Eliminar registro da PL Table antes da gravação
            vr_crapvop.delete(vr_ixVOP);
            
            -- Escreve no log do arquivo
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_filelog
                                          ,pr_des_text => TO_CHAR(vr_dtmvtolt,'dd/mm/yyyy') || ' ' || TO_CHAR(SYSDATE,'hh24:mi:ss') || ' => ' ||
                                                          'CRAPVOP: Arquivo ' || vr_dsdirzip || '/' || vr_array_arquivo(ind) || ' ' ||
                                                          'DATABASE: ' || TO_CHAR(vr_crapvop(vr_ixVOP).dtrefere, 'DD/MM/RRRR') || ' ' ||
                                                          'CPF_CNPJ: ' || TO_CHAR(vr_crapvop(vr_ixVOP).nrcpfcgc) || ' ' ||
                                                          'MODALIDADE: ' || vr_crapvop(vr_ixVOP).cdmodali || ' ' ||
                                                          'VENCIMENTO: ' || TO_CHAR(vr_crapvop(vr_ixVOP).cdvencto, 'FM000') || ' ' ||
                                                          'MOEDA_EST: ' || REPLACE(REPLACE(vr_crapvop(vr_ixVOP).flgmoest, 1, 'yes'), 0, 'no') || ' ERRO: Registro ja existente'); 
          END IF;
        
        -- Capturar próximo índice
        vr_ixVOP := vr_crapvop.next(vr_ixVOP);
      END LOOP;
      
      -- Limpar PL Table
      vr_tab_crapvop.delete;
      
      -- Inserir registros na CRAPVOP otimizado para performance
      vr_ixVOP := 0;
      BEGIN
        FORALL vr_ixVOP IN INDICES OF vr_crapvop SAVE EXCEPTIONS
          INSERT INTO crapvop(nrcpfcgc
                             ,dtrefere
                             ,cdvencto
                             ,vlvencto
                             ,cdmodali
                             ,flgmoest)
                       VALUES(NVL(vr_crapvop(vr_ixVOP).nrcpfcgc, 0) 
                             ,vr_crapvop(vr_ixVOP).dtrefere 
                             ,NVL(vr_crapvop(vr_ixVOP).cdvencto, 0) 
                             ,NVL(vr_crapvop(vr_ixVOP).vlvencto, 0)  
                             ,NVL(vr_crapvop(vr_ixVOP).cdmodali, ' ')  
                             ,NVL(vr_crapvop(vr_ixVOP).flgmoest, 0));
      EXCEPTION
        WHEN others THEN
          -- Gerar erro
          vr_dscritic := 'Erro ao incluir registro CRAPVOP: ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(1). ERROR_CODE));
          RAISE vr_exc_saida;
      END;
      
      -- Limpar PL Table
      vr_crapvop.delete;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
                                  
        -- Limpar a variável de crítica
        vr_dscritic := NULL;
                                 
        -- Desfazer alterações deste arquivo
        ROLLBACK;
        -- Pular para próximo arquivo
        CONTINUE;
      WHEN OTHERS THEN
        
        cecred.pc_internal_exception(pr_cdcooper);
      
        -- Verifica se retornou endereços de e-mail para envio do arquivo
        IF vr_des_destino IS NULL THEN
          -- Mensagem de erro
          vr_dscritic := 'Destinatários de e-mail não encontrado. Arquivo disponível em: '||vr_dsdireto||'/log/'||vr_nmarqdat;
          -- Não gerar critica
          vr_cdcritic := 0;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
        ELSE
          -- Enviar e-mail com o log gerado
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => vr_cdprogra
                                    ,pr_des_destino     => vr_des_destino
                                    ,pr_des_assunto     => 'Proc3046.log'
                                    ,pr_des_corpo       => 'Erro ao importar arquivo xml 3046 => ' || vr_array_arquivo(ind) || '.' || chr(10) || SQLERRM
                                    ,pr_des_anexo       => vr_dsdireto || '/converte/' || vr_nmarqdat
                                    ,pr_flg_remove_anex => 'N'
                                    ,pr_des_erro        => vr_dscritic);

          -- Verificar se houve erro ao solicitar e-mail
          IF vr_dscritic IS NOT NULL THEN
            -- Não gerar critica
            vr_cdcritic := 0;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
          END IF;
        END IF;
                                  
        -- Limpar a variável de crítica
        vr_dscritic := NULL;
                         
        -- Desfazer alterações deste arquivo
        ROLLBACK;
        -- Pular para próximo arquivo
        CONTINUE;
    END;

    -- Copia o arquivo para pasta salvar e eliminar da pasta atual
    GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdirzip||'/'||vr_array_arquivo(ind)||' '||vr_dsdireto||'/salvar'
                               ,pr_flg_aguard  => 'S'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_dscritic);
    
    -- Efetuar gravação ao processar cada arquivo, pois o mesmo foi movido a salvar
    COMMIT;

  END LOOP; -- Loop dos arquivos

  -- Fechar/salvar o arquivo de log
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_filelog);

  -- Verifica se retornou endereços de e-mail para envio do arquivo
  IF vr_des_destino IS NULL THEN
    -- Mensagem de erro
    vr_dscritic := 'Destinatários de e-mail não encontrado. Arquivo disponível em: '||vr_dsdireto||'/log/'||vr_nmarqdat;
    -- Não gerar critica
    vr_cdcritic := 0;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
  ELSE
    -- Converte o arquivo para enviar
    gene0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                ,pr_nmarquiv => vr_dsdireto || '/log/' || vr_nmarqdat
                                ,pr_nmarqenv => vr_nmarqdat
                                ,pr_des_erro => vr_dscritic);
                                
    IF vr_dscritic IS NULL THEN
      -- Enviar e-mail com o log gerado
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_des_destino
                                ,pr_des_assunto     => 'Proc3046.log'
                                ,pr_des_corpo       => NULL
                                ,pr_des_anexo       => vr_dsdireto || '/converte/' || vr_nmarqdat
                                ,pr_flg_remove_anex => 'N'
                                ,pr_des_erro        => vr_dscritic);
    END IF;
    
    -- Verificar se houve erro ao solicitar e-mail
    IF vr_dscritic IS NOT NULL THEN
      -- Não gerar critica
      vr_cdcritic := 0;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
    END IF;
  END IF; -- IF vr_des_destino IS NULL

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informações atualizada
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN

      -- Buscar a descrição
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

    -- Se foi gerada critica para envio ao log
    IF vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 
                                ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic);
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;

  WHEN vr_exc_saida THEN

    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);

    -- Buscar a descrição
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);

    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN

    cecred.pc_internal_exception(pr_cdcooper);

    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS572;
/
