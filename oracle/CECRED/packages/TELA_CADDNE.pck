CREATE OR REPLACE PACKAGE CECRED.TELA_CADDNE IS

  PROCEDURE pc_proc_arq_correio(pr_fluniope  IN INTEGER  --> Processar o arquivo UNID OPER (0-NAO/1-SIM)
                               ,pr_flgrausu  IN INTEGER  --> Processar o arquivo GRANDE USUARIO (0-NAO/1-SIM)
                               ,pr_flcpc     IN INTEGER  --> Processar o arquivo CAIXA POSTAL COMUNITARIA (0-NAO/1-SIM)
                               ,pr_nmestado  IN VARCHAR2 --> Nome do Estado que sera importado
                               ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com erros

END TELA_CADDNE;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADDNE IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADDNE
  --  Sistema  : Ayllos Web
  --  Autor    : Douglas Quisinski
  --  Data     : Setembro - 2016                  Ultima atualizacao: 16/03/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADDNE
  --
  -- Alteracoes: 
  --
  -- 16/03/2019 - Importar cód.ibge e municípios com CEP único (Cechet)
  --
  ---------------------------------------------------------------------------

  -- Identificacao dos Enderecos
  const_origem_cadastro CONSTANT crapdne.idoricad%TYPE := 1; -- Origem do Cadastro como CORREIOS (1)

  -- Quantidade de registros para realizar o COMMIT 
  vr_qtd_reg_commit CONSTANT INTEGER := 10000;

  -- Tipo de registro para o nome das cidades
  TYPE typ_reg_cidade IS
    RECORD (codigo   INTEGER
           ,estado   crapdne.cduflogr%TYPE
           ,nome     crapdne.nmextcid%TYPE
           ,resumido crapdne.nmrescid%TYPE
           ,cep      crapdne.nrceplog%TYPE
           ,codibge  crapmun.cdcidbge%TYPE);
  -- O indice da tabela sera o codigo da cidade
  TYPE typ_tab_cidade IS
    TABLE OF typ_reg_cidade
    INDEX BY PLS_INTEGER;

  -- Tipo de registro para o nome dos bairros
  TYPE typ_reg_bairro IS
    RECORD (codigo   INTEGER
           ,estado   crapdne.cduflogr%TYPE
           ,nome     crapdne.nmextbai%TYPE
           ,resumido crapdne.nmresbai%TYPE);
  -- O indice da tabela sera o codigo da bairros
  TYPE typ_tab_bairro IS
    TABLE OF typ_reg_bairro
    INDEX BY PLS_INTEGER;

  -- Tipo de registro para o nome dos logradouros
  TYPE typ_reg_logradouro IS
    RECORD (estado       crapdne.cduflogr%TYPE
           ,nome_rua     crapdne.nmextlog%TYPE
           ,complemento  crapdne.dscmplog%TYPE
           ,cep          crapdne.nrceplog%TYPE
           ,tipo         crapdne.dstiplog%TYPE
           ,nome_rua_res crapdne.nmreslog%TYPE
           ,bairro_nome  crapdne.nmextbai%TYPE
           ,bairro_res   crapdne.nmresbai%TYPE
           ,cidade_nome  crapdne.nmextcid%TYPE
           ,cidade_res   crapdne.nmrescid%TYPE
           ,codibge      crapmun.cdcidbge%TYPE);
  -- O indice da tabela sera o codigo da logradouro
  TYPE typ_tab_logradouro IS
    TABLE OF typ_reg_logradouro
    INDEX BY PLS_INTEGER;

  PROCEDURE pc_insere_endereco(pr_tab_logradouro IN OUT typ_tab_logradouro --> Tabela de Ruas
                              ,pr_idtipdne       IN INTEGER
                              ,pr_dscritic      OUT VARCHAR2) IS   --> Descricao da critica

  BEGIN

    /* .............................................................................

    Programa: pc_insere_localidade
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 04/11/2016 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Inserir os Enderecos
    
    Alteracoes: 04/11/2016 - Adicionar NVL para os campos de texto no cadastro 
                             de endereço ao importar os arquivos do correio
                             (Douglas - Chamado 542799)
                             
                16/03/2017 - Adicionar UPPER para os campos de texto no cadastro 
                             de endereço ao importar os arquivos do correio
                             (Douglas - Chamado 601436)
    ..............................................................................*/
    BEGIN
      --Inserir dados do endereco na tabela em um unico momento
      BEGIN
        FORALL idx IN INDICES OF pr_tab_logradouro SAVE EXCEPTIONS
          INSERT INTO crapdne(nrceplog
                             ,nmextlog
                             ,nmreslog
                             ,dscmplog
                             ,dstiplog
                             ,nmextbai
                             ,nmresbai
                             ,nmextcid
                             ,nmrescid
                             ,cduflogr
                             ,idoricad
                             ,idtipdne)
                       VALUES(pr_tab_logradouro(idx).cep
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).nome_rua)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).nome_rua_res)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).complemento)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).tipo)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).bairro_nome)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).bairro_res)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).cidade_nome)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).cidade_res)),' ')
                             ,NVL(UPPER(TRIM(pr_tab_logradouro(idx).estado)),' ')
                             ,const_origem_cadastro   -- Origem do Cadastro (1 - CORREIOS)
                             ,pr_idtipdne); -- Tipo de Enderecao
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic:=  'Erro ao inserir na tabela crapdne. '||
                         SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
      END;

      -- Limpar a tabela
      pr_tab_logradouro.DELETE;
      
      -- Comitar os registros
      COMMIT;
      
    EXCEPTION
      
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na insercao dos enderecos: ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
  END pc_insere_endereco;


  PROCEDURE pc_proc_arq_localidade(pr_tab_cidade IN OUT typ_tab_cidade --> Sigla do estado que será processado
                                  ,pr_dscritic      OUT VARCHAR2) IS   --> Descricao da critica

  BEGIN

    /* .............................................................................

    Programa: pc_proc_arq_localidade
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para processar os arquivos LOG_LOCALIDADE.TXT
    
    Mascara   : O arquivo possui os campos separados por '@'
                Lista dos campos:
                1 - Codigo da Cidade
                2 - Sigla do Estado
                3 - Nome da Cidade
                4 - DESCONHECIDO
                5 - DESCONHECIDO
                6 - DESCONHECIDO
                7 - DESCONHECIDO
                8 - Nome Resumido da Cidade
                9 - DESCONHECIDO

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Diretorio onde estao os arquivos do correio que serao processados
      vr_dsdirarq CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',0,'ROOT_ARQUIVO_CORREIOS');
      vr_nmarqprc CONSTANT VARCHAR2(50) := 'LOG_LOCALIDADE.TXT';

      -- Campos do arquivo de cidade
      vr_codigo   INTEGER;
      vr_estado   VARCHAR(2);
      vr_nome     VARCHAR2(600);
      vr_resumido VARCHAR2(600);
      vr_cep      crapdne.nrceplog%TYPE;
      vr_codibge  crapmun.cdcidbge%TYPE;
      
      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis para processamento do arquivo
      vr_input_file  UTL_FILE.FILE_TYPE;
      vr_setlinha    VARCHAR2(32500);

    BEGIN
      -- Verificar se o arquivo LOG_LOCALIDADE.TXT existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || vr_nmarqprc) THEN 
        -- Se o arquivo nao existe levantamos o erro
        vr_dscritic := 'Arquivo ' || vr_nmarqprc || ' nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      -- Abrir o arquivo 
      gene0001.pc_abre_arquivo (pr_nmcaminh => vr_dsdirarq || vr_nmarqprc --> Diretório do arquivo
                               ,pr_tipabert => 'R'                        --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file              --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);              --> Descricao do erro

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        -- Laco para leitura de linhas do arquivo
        LOOP
          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Retirar quebra de linha
          vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
          -- Retirar os espacos em branco
          vr_setlinha := TRIM(vr_setlinha);
          
          vr_codigo   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 1, pr_dstext => vr_setlinha, pr_delimitador => '@'));
          vr_estado   := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 2, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,2));
          vr_nome     := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 3, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,40));
          vr_resumido := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 8, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,25));
          vr_cep      := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 4, pr_dstext => vr_setlinha, pr_delimitador => '@'));
          vr_codibge  := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 9, pr_dstext => vr_setlinha, pr_delimitador => '@'));
          
          -- Carregar os dados da Cidade para a PL_TABLE
          pr_tab_cidade(vr_codigo).codigo   := vr_codigo;
          pr_tab_cidade(vr_codigo).estado   := vr_estado;
          pr_tab_cidade(vr_codigo).nome     := vr_nome;
          pr_tab_cidade(vr_codigo).resumido := vr_resumido;
          pr_tab_cidade(vr_codigo).cep      := vr_cep;
          pr_tab_cidade(vr_codigo).codibge  := vr_codibge;
          
        END LOOP; -- Loop Arquivo
        
        -- processar municipios;
        BEGIN
          FORALL idx IN INDICES OF pr_tab_cidade SAVE EXCEPTIONS
            MERGE 
              INTO crapdne dne
              USING (SELECT 1 FROM dual) s
                 ON (dne.nrceplog = pr_tab_cidade(idx).cep
                AND  dne.idoricad = 1) 
    --          WHEN MATCHED THEN
    --            dbms_output.put_line('CEP ' || vr_tab_cidade(idx).cep || ' - ja existe');
              WHEN NOT MATCHED THEN             
                INSERT (nrceplog
                       ,nmextlog
                       ,nmreslog
                       ,dscmplog
                       ,dstiplog
                       ,nmextbai
                       ,nmresbai
                       ,nmextcid
                       ,nmrescid
                       ,cduflogr
                       ,idoricad
                       ,idtipdne)
                 VALUES(pr_tab_cidade(idx).cep
                       ,substr('MUNICIPIO DE ' || NVL(UPPER(TRIM(pr_tab_cidade(idx).nome)),' '),1,80)
                       ,substr('MUNICIPIO DE ' || NVL(UPPER(TRIM(pr_tab_cidade(idx).nome)),' '),1,72)
                       ,'.'
                       ,' '
                       ,' '
                       ,' '
                       ,substr(NVL(UPPER(TRIM(pr_tab_cidade(idx).nome)),' '),1,40)
                       ,substr(NVL(UPPER(TRIM(pr_tab_cidade(idx).nome)),' '),1,25)
                       ,NVL(UPPER(TRIM(pr_tab_cidade(idx).estado)),' ')
                       ,const_origem_cadastro   -- Origem do Cadastro (1 - CORREIOS)
                       ,5); -- Tipo de Enderecao 5 = Municipios
        EXCEPTION
            WHEN OTHERS THEN
              dbms_output.put_line('Erro ao inserir na tabela crapdne. '||
                             SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE)));      
        END;                                           

      EXCEPTION 
        WHEN no_data_found THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

        WHEN OTHERS THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
          vr_dscritic:= 'Erro geral no carregamento do arquivo ' || vr_nmarqprc || ': ' ||
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina da tela CADDNE.pc_proc_arq_localidade: ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
  END pc_proc_arq_localidade;

  PROCEDURE pc_proc_arq_bairro(pr_tab_bairro IN OUT typ_tab_bairro --> Tabela de Bairros
                              ,pr_dscritic      OUT VARCHAR2) IS   --> Descricao da critica

  BEGIN

    /* .............................................................................

    Programa: pc_proc_arq_bairro
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para processar os arquivos LOG_BAIRRO.TXT
    
    Mascara   : O arquivo possui os campos separados por '@'
                Lista dos campos:
                1 - Codigo do Bairro
                2 - Sigla do Estado
                3 - DESCONHECIDO
                4 - Nome do Bairro
                5 - Nome Resumido do Bairro 

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Diretorio onde estao os arquivos do correio que serao processados
      vr_dsdirarq CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',0,'ROOT_ARQUIVO_CORREIOS');
      vr_nmarqprc CONSTANT VARCHAR2(50) := 'LOG_BAIRRO.TXT';

      -- Campos do arquivo de cidade
      vr_codigo   INTEGER;
      vr_estado   VARCHAR(2);
      vr_nome     VARCHAR2(600);
      vr_resumido VARCHAR2(600);
      
      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis para processamento do arquivo
      vr_input_file  UTL_FILE.FILE_TYPE;
      vr_setlinha    VARCHAR2(32500);

    BEGIN
      -- Verificar se o arquivo LOG_LOCALIDADE.TXT existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || vr_nmarqprc) THEN 
        -- Se o arquivo nao existe levantamos o erro
        vr_dscritic := 'Arquivo ' || vr_nmarqprc || ' nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      -- Abrir o arquivo 
      gene0001.pc_abre_arquivo (pr_nmcaminh => vr_dsdirarq || vr_nmarqprc --> Diretório do arquivo
                               ,pr_tipabert => 'R'                        --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file              --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);              --> Descricao do erro

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        -- Laco para leitura de linhas do arquivo
        LOOP
          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Retirar quebra de linha
          vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
          -- Retirar os espacos em branco
          vr_setlinha := TRIM(vr_setlinha);
          
          vr_codigo   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 1, pr_dstext => vr_setlinha, pr_delimitador => '@'));
          vr_estado   := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 2, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,2));
          vr_nome     := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 4, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,72));
          vr_resumido := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 5, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,40));
          
          -- Carregar os dados da Cidade para a PL_TABLE
          pr_tab_bairro(vr_codigo).codigo   := vr_codigo;
          pr_tab_bairro(vr_codigo).estado   := vr_estado;
          pr_tab_bairro(vr_codigo).nome     := vr_nome;
          pr_tab_bairro(vr_codigo).resumido := vr_resumido;
          
        END LOOP; -- Loop Arquivo

      EXCEPTION 
        WHEN no_data_found THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

        WHEN OTHERS THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
          vr_dscritic:= 'Erro geral no carregamento do arquivo ' || vr_nmarqprc || ': ' ||
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina da tela CADDNE.pc_proc_arq_bairro: ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
  END pc_proc_arq_bairro;


  PROCEDURE pc_proc_arq_unid_oper(pr_tab_cidade IN typ_tab_cidade --> Tabela de Cidades
                                 ,pr_tab_bairro IN typ_tab_bairro --> Tabela de Bairros
                                 ,pr_dscritic  OUT VARCHAR2) IS   --> Descricao da critica

  BEGIN

    /* .............................................................................

    Programa: pc_proc_arq_unid_oper
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para processar os arquivos LOG_UNID_OPER.TXT
    
    Mascara   : O arquivo possui os campos separados por '@'
                Lista dos campos:
                1 - Codigo 
                2 - Sigla do Estado
                3 - Codigo da Cidade
                4 - Codigo do Bairro
                5 - DESCONHECIDO
                6 - Complemento
                7 - Nome da Rua
                8 - CEP
                9 - DESCONHECIDO
               10 - Nome Resumido da Rua

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Diretorio onde estao os arquivos do correio que serao processados
      vr_dsdirarq CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',0,'ROOT_ARQUIVO_CORREIOS');
      vr_nmarqprc CONSTANT VARCHAR2(50) := 'LOG_UNID_OPER.TXT';

      -- Identificacao dos Enderecos
      vr_idtipdne CONSTANT crapdne.idtipdne%TYPE := 3; -- Tipo de Endereco UNID. OPER

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);
      
      -- Arquivo de ERRO na leitura das linhas
      vr_erro_leitura    BOOLEAN;
      vr_clob_leitura    CLOB;
      vr_dstexto_leitura VARCHAR2(32700);
      
      -- Arquivo de ERRO na insercao dos enderecos
      vr_erro_insert    BOOLEAN;
      vr_clob_insert    CLOB;
      vr_dstexto_insert VARCHAR2(32700);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis para processamento do arquivo
      vr_input_file  UTL_FILE.FILE_TYPE;
      vr_setlinha    VARCHAR2(32500);
      
      -- Campos 
      vr_cidade_cod   INTEGER;
      vr_bairro_cod   INTEGER;
      
      -- PL TABLE de Logradouros 
      vr_tab_logradouro typ_tab_logradouro;
      vr_ind            INTEGER;

    BEGIN
      -- Verificar se o arquivo LOG_UNID_OPER.TXT existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || vr_nmarqprc) THEN 
        -- Se o arquivo nao existe levantamos o erro
        vr_dscritic := 'Arquivo ' || vr_nmarqprc || ' nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      vr_erro_leitura := FALSE;
      vr_erro_insert  := FALSE;

      -- Abrir o arquivo 
      gene0001.pc_abre_arquivo (pr_nmcaminh => vr_dsdirarq || vr_nmarqprc --> Diretório do arquivo
                               ,pr_tipabert => 'R'                        --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file              --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);              --> Descricao do erro

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      DELETE FROM crapdne
            WHERE crapdne.idoricad = const_origem_cadastro  -- Origem do Cadastro
              AND crapdne.idtipdne = vr_idtipdne; -- Cadastro de Enderecos
      -- Realizamos o commit 
      COMMIT;

      -- Limpar a tabela
      vr_tab_logradouro.DELETE;
      
      BEGIN
        -- Laco para leitura de linhas do arquivo
        LOOP
          -- Verificar se foram processados a quantidade para para realizar o commit
          IF vr_tab_logradouro.COUNT() = vr_qtd_reg_commit THEN
            pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                              ,pr_idtipdne       => vr_idtipdne
                              ,pr_dscritic       => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              -- Atualizar o controle de erros
              vr_erro_insert := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                     ,pr_texto_completo => vr_dstexto_insert
                                     ,pr_texto_novo     => vr_dscritic || chr(10)); 
              vr_dscritic := NULL;
            END IF;
          END IF;

          -- Atualizar o totalizador
          vr_ind := vr_tab_logradouro.COUNT() + 1;

          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Retirar quebra de linha
          vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
          -- Retirar os espacos em branco
          vr_setlinha := TRIM(vr_setlinha);

          -- Buscar os dados da RUA
          BEGIN
            -- Codigo da Cidade e do Bairro
            vr_cidade_cod   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 3, pr_dstext => vr_setlinha, pr_delimitador => '@'));
            vr_bairro_cod   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 4, pr_dstext => vr_setlinha, pr_delimitador => '@'));

            -- Carregar os dados do Logradouro para a PL_TABLE
            vr_tab_logradouro(vr_ind).estado       := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 2, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,2));
            vr_tab_logradouro(vr_ind).complemento  := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 6, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,90));
            vr_tab_logradouro(vr_ind).nome_rua     := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 7, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,80));
            vr_tab_logradouro(vr_ind).cep          := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 8, pr_dstext => vr_setlinha, pr_delimitador => '@'));
            vr_tab_logradouro(vr_ind).nome_rua_res := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 10, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,72));
            vr_tab_logradouro(vr_ind).tipo         := ' ';

            -- verificar se o bairro existe
            IF pr_tab_bairro.EXISTS(vr_bairro_cod) THEN
              vr_tab_logradouro(vr_ind).bairro_nome  := SUBSTR(pr_tab_bairro(vr_bairro_cod).nome,1,72);
              vr_tab_logradouro(vr_ind).bairro_res   := SUBSTR(pr_tab_bairro(vr_bairro_cod).resumido,1,40);
            ELSE 
              vr_tab_logradouro(vr_ind).bairro_nome  := ' ';
              vr_tab_logradouro(vr_ind).bairro_res   := ' ';
            END IF;
            
            -- verificar se a cidade existe
            IF pr_tab_cidade.EXISTS(vr_cidade_cod) THEN
              vr_tab_logradouro(vr_ind).cidade_nome  := SUBSTR(pr_tab_cidade(vr_cidade_cod).nome,1,40);
              vr_tab_logradouro(vr_ind).cidade_res   := SUBSTR(pr_tab_cidade(vr_cidade_cod).resumido,1,25);
              vr_tab_logradouro(vr_ind).codibge      := pr_tab_cidade(vr_cidade_cod).codibge;
            ELSE 
              vr_tab_logradouro(vr_ind).cidade_nome  := ' ';
              vr_tab_logradouro(vr_ind).cidade_res   := ' ';
              vr_tab_logradouro(vr_ind).codibge      := 0;              
            END IF;
            
          EXCEPTION
            WHEN OTHERS THEN
              -- Atualizar o controle de erros
              vr_erro_leitura := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                                     ,pr_texto_completo => vr_dstexto_leitura
                                     ,pr_texto_novo     => vr_setlinha || '  #  ' || 
                                                           SQLERRM     || chr(10));  
              -- Ignora a linha e vai para o proximo registro
              CONTINUE;
          END;
          
        END LOOP; -- Loop Arquivo

      EXCEPTION 
        WHEN no_data_found THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

        WHEN OTHERS THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
          vr_dscritic:= 'Erro geral no processamento do arquivo: ' || vr_nmarqprc || ': ' ||
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
          RAISE vr_exc_saida;
      END;
      
      -- Verificar se foram processados a quantidade para para realizar o commit
      IF vr_tab_logradouro.COUNT() > 0 THEN
        -- Insert dos enderecos
        pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                          ,pr_idtipdne       => vr_idtipdne
                          ,pr_dscritic       => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Atualizar o controle de erros
          vr_erro_insert := TRUE;
          -- Erro na busca dos dados
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                 ,pr_texto_completo => vr_dstexto_insert
                                 ,pr_texto_novo     => vr_dscritic || chr(10)); 
          vr_dscritic := NULL;
        END IF;
      END IF;      
      
      IF vr_erro_leitura THEN
        -- Fecha o XML de erro de leitura
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                               ,pr_texto_completo => vr_dstexto_leitura
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_leitura
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_LEITURA_UNID_OPER.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      IF vr_erro_insert THEN
        -- Fecha o XML de erro de insert
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                               ,pr_texto_completo => vr_dstexto_insert
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_insert
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_INSERT_UNID_OPER.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      -- Se chegou aqui, commitar os registros
      COMMIT;
      
      -- Remover o arquivo depois de processar
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq || vr_nmarqprc);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina da tela CADDNE.pc_proc_arq_unid_oper : ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
    
  END pc_proc_arq_unid_oper;


  PROCEDURE pc_proc_arq_grande_usuario(pr_tab_cidade IN typ_tab_cidade --> Tabela de Cidades
                                      ,pr_tab_bairro IN typ_tab_bairro --> Tabela de Bairros
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

  BEGIN

    /* .............................................................................

    Programa: pc_proc_arq_grande_usuario
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para processar os arquivos LOG_GRANDE_USUARIO.TXT

    Mascara   : O arquivo possui os campos separados por '@'
                Lista dos campos:
                1 - Codigo 
                2 - Sigla do Estado
                3 - Codigo da Cidade
                4 - Codigo do Bairro
                5 - DESCONHECIDO
                6 - Complemento
                7 - Nome da Rua
                8 - CEP
                9 - Nome Resumido da Rua

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Diretorio onde estao os arquivos do correio que serao processados
      vr_dsdirarq CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',0,'ROOT_ARQUIVO_CORREIOS');
      vr_nmarqprc CONSTANT VARCHAR2(50) := 'LOG_GRANDE_USUARIO.TXT';

      -- Identificacao dos Enderecos
      vr_idtipdne CONSTANT crapdne.idtipdne%TYPE := 2; -- Tipo de Endereco GRANDE USUARIO

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);
      
      -- Arquivo de ERRO na leitura das linhas
      vr_erro_leitura    BOOLEAN;
      vr_clob_leitura    CLOB;
      vr_dstexto_leitura VARCHAR2(32700);
      
      -- Arquivo de ERRO na insercao dos enderecos
      vr_erro_insert    BOOLEAN;
      vr_clob_insert    CLOB;
      vr_dstexto_insert VARCHAR2(32700);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis para processamento do arquivo
      vr_input_file  UTL_FILE.FILE_TYPE;
      vr_setlinha    VARCHAR2(32500);
      
      -- Campos 
      vr_cidade_cod   INTEGER;
      vr_bairro_cod   INTEGER;
      
      -- PL TABLE de Logradouros 
      vr_tab_logradouro typ_tab_logradouro;
      vr_ind            INTEGER;

    BEGIN
      -- Verificar se o arquivo LOG_GRANDE_USUARIO.TXT existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || vr_nmarqprc) THEN 
        -- Se o arquivo nao existe levantamos o erro
        vr_dscritic := 'Arquivo ' || vr_nmarqprc || ' nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      vr_erro_leitura := FALSE;
      vr_erro_insert  := FALSE;

      -- Abrir o arquivo 
      gene0001.pc_abre_arquivo (pr_nmcaminh => vr_dsdirarq || vr_nmarqprc --> Diretório do arquivo
                               ,pr_tipabert => 'R'                        --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file              --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);              --> Descricao do erro

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      DELETE FROM crapdne
            WHERE crapdne.idoricad = const_origem_cadastro  -- Origem do Cadastro
              AND crapdne.idtipdne = vr_idtipdne; -- Cadastro de Enderecos
      -- Realizamos o commit 
      COMMIT;

      -- Limpar a tabela
      vr_tab_logradouro.DELETE;
      
      BEGIN
        -- Laco para leitura de linhas do arquivo
        LOOP
          -- Verificar se foram processados a quantidade para para realizar o commit
          IF vr_tab_logradouro.COUNT() = vr_qtd_reg_commit THEN
            pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                              ,pr_idtipdne       => vr_idtipdne
                              ,pr_dscritic       => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              -- Atualizar o controle de erros
              vr_erro_insert := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                     ,pr_texto_completo => vr_dstexto_insert
                                     ,pr_texto_novo     => vr_dscritic || chr(10)); 
              vr_dscritic := NULL;
            END IF;
          END IF;

          -- Atualizar o totalizador
          vr_ind := vr_tab_logradouro.COUNT() + 1;

          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Retirar quebra de linha
          vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
          -- Retirar os espacos em branco
          vr_setlinha := TRIM(vr_setlinha);

          -- Buscar os dados da RUA
          BEGIN
            -- Codigo da Cidade e do Bairro
            vr_cidade_cod   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 3, pr_dstext => vr_setlinha, pr_delimitador => '@'));
            vr_bairro_cod   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 4, pr_dstext => vr_setlinha, pr_delimitador => '@'));

            vr_tab_logradouro(vr_ind).estado       := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 2, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,2));
            vr_tab_logradouro(vr_ind).complemento  := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 6, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,90));
            vr_tab_logradouro(vr_ind).nome_rua     := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 7, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,80));
            vr_tab_logradouro(vr_ind).cep          := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 8, pr_dstext => vr_setlinha, pr_delimitador => '@'));
            vr_tab_logradouro(vr_ind).nome_rua_res := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 10, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,72));

            -- Se nao veio o nome resumido da rua, adiciona o nome da rua
            IF TRIM(vr_tab_logradouro(vr_ind).nome_rua_res) IS NULL THEN
              vr_tab_logradouro(vr_ind).nome_rua_res := vr_tab_logradouro(vr_ind).nome_rua;
            END IF;
            
            -- verificar se o bairro existe
            IF pr_tab_bairro.EXISTS(vr_bairro_cod) THEN
              vr_tab_logradouro(vr_ind).bairro_nome  := SUBSTR(pr_tab_bairro(vr_bairro_cod).nome,1,72);
              vr_tab_logradouro(vr_ind).bairro_res   := SUBSTR(pr_tab_bairro(vr_bairro_cod).resumido,1,40);
            ELSE 
              vr_tab_logradouro(vr_ind).bairro_nome  := ' ';
              vr_tab_logradouro(vr_ind).bairro_res   := ' ';
            END IF;
            
            -- verificar se a cidade existe
            IF pr_tab_cidade.EXISTS(vr_cidade_cod) THEN
              vr_tab_logradouro(vr_ind).cidade_nome  := SUBSTR(pr_tab_cidade(vr_cidade_cod).nome,1,40);
              vr_tab_logradouro(vr_ind).cidade_res   := SUBSTR(pr_tab_cidade(vr_cidade_cod).resumido,1,25);
              vr_tab_logradouro(vr_ind).codibge      := pr_tab_cidade(vr_cidade_cod).codibge;              
            ELSE 
              vr_tab_logradouro(vr_ind).cidade_nome  := ' ';
              vr_tab_logradouro(vr_ind).cidade_res   := ' ';
              vr_tab_logradouro(vr_ind).codibge      := 0;              
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Atualizar o controle de erros
              vr_erro_leitura := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                                     ,pr_texto_completo => vr_dstexto_leitura
                                     ,pr_texto_novo     => vr_setlinha || '  #  ' || 
                                                           SQLERRM     || chr(10));  
          END;
        END LOOP; -- Loop Arquivo

      EXCEPTION 
        WHEN no_data_found THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

        WHEN OTHERS THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
          vr_dscritic:= 'Erro geral no processamento do arquivo: ' || vr_nmarqprc || ': ' ||
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
          RAISE vr_exc_saida;
      END;
      
      -- Verificar se foram processados a quantidade para para realizar o commit
      IF vr_tab_logradouro.COUNT() > 0 THEN
        -- Insert dos enderecos
        pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                          ,pr_idtipdne       => vr_idtipdne
                          ,pr_dscritic       => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Atualizar o controle de erros
          vr_erro_insert := TRUE;
          -- Erro na busca dos dados
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                 ,pr_texto_completo => vr_dstexto_insert
                                 ,pr_texto_novo     => vr_dscritic || chr(10)); 
          vr_dscritic := NULL;
        END IF;
      END IF; 
            
      IF vr_erro_leitura THEN
        -- Fecha o XML de erro de leitura
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                               ,pr_texto_completo => vr_dstexto_leitura
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_leitura
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_LEITURA_GRANDE_USUARIO.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      IF vr_erro_insert THEN
        -- Fecha o XML de erro de insert
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                               ,pr_texto_completo => vr_dstexto_insert
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_insert
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_INSERT_GRANDE_USUARIO.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      -- Se chegou aqui, commitar os registros
      COMMIT;
      
      -- Remover o arquivo depois de processar
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq || vr_nmarqprc);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina da tela CADDNE.pc_proc_arq_grande_usuario: ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
  END pc_proc_arq_grande_usuario;

  PROCEDURE pc_proc_arq_cpc(pr_tab_cidade IN typ_tab_cidade --> Tabela de Cidades
                           ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

  BEGIN

    /* .............................................................................

    Programa: pc_proc_arq_cpc
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para processar os arquivos LOG_CPC.TXT

    Mascara   : O arquivo possui os campos separados por '@'
                Lista dos campos:
                1 - Codigo 
                2 - Sigla do Estado
                3 - Codigo da Cidade
                4 - Nome Resumido da Rua 
                5 - Nome da Rua 
                6 - CEP

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Diretorio onde estao os arquivos do correio que serao processados
      vr_dsdirarq CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',0,'ROOT_ARQUIVO_CORREIOS');
      vr_nmarqprc CONSTANT VARCHAR2(50) := 'LOG_CPC.TXT';

      -- Identificacao dos Enderecos
      vr_idtipdne CONSTANT crapdne.idtipdne%TYPE := 4; -- Tipo de Endereco Caixa Postal Comunitaria - CPC

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);
      
      -- Arquivo de ERRO na leitura das linhas
      vr_erro_leitura    BOOLEAN;
      vr_clob_leitura    CLOB;
      vr_dstexto_leitura VARCHAR2(32700);
      
      -- Arquivo de ERRO na insercao dos enderecos
      vr_erro_insert    BOOLEAN;
      vr_clob_insert    CLOB;
      vr_dstexto_insert VARCHAR2(32700);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis para processamento do arquivo
      vr_input_file  UTL_FILE.FILE_TYPE;
      vr_setlinha    VARCHAR2(32500);
      
      -- Campos 
      vr_cidade_cod   INTEGER;
      
      -- PL TABLE de Logradouros 
      vr_tab_logradouro typ_tab_logradouro;
      vr_ind            INTEGER;

    BEGIN
      -- Verificar se o arquivo LOG_UNID_OPER.TXT existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || vr_nmarqprc) THEN 
        -- Se o arquivo nao existe levantamos o erro
        vr_dscritic := 'Arquivo ' || vr_nmarqprc || ' nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      vr_erro_leitura := FALSE;
      vr_erro_insert  := FALSE;

      -- Abrir o arquivo 
      gene0001.pc_abre_arquivo (pr_nmcaminh => vr_dsdirarq || vr_nmarqprc --> Diretório do arquivo
                               ,pr_tipabert => 'R'                        --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file              --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);              --> Descricao do erro

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      DELETE FROM crapdne
            WHERE crapdne.idoricad = const_origem_cadastro  -- Origem do Cadastro
              AND crapdne.idtipdne = vr_idtipdne; -- Cadastro de Enderecos
      -- Realizamos o commit 
      COMMIT;

      -- Limpar a tabela
      vr_tab_logradouro.DELETE;
      
      BEGIN
        -- Laco para leitura de linhas do arquivo
        LOOP
          -- Verificar se foram processados a quantidade para para realizar o commit
          IF vr_tab_logradouro.COUNT() = vr_qtd_reg_commit THEN
            pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                              ,pr_idtipdne       => vr_idtipdne
                              ,pr_dscritic       => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              -- Atualizar o controle de erros
              vr_erro_insert := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                     ,pr_texto_completo => vr_dstexto_insert
                                     ,pr_texto_novo     => vr_dscritic || chr(10)); 
              vr_dscritic := NULL;
            END IF;
          END IF;

          -- Atualizar o totalizador
          vr_ind := vr_tab_logradouro.COUNT() + 1;

          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Retirar quebra de linha
          vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
          -- Retirar os espacos em branco
          vr_setlinha := TRIM(vr_setlinha);

          -- Buscar os dados da RUA
          BEGIN
            -- Codigo da Cidade 
            vr_cidade_cod   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 3, pr_dstext => vr_setlinha, pr_delimitador => '@'));

            vr_tab_logradouro(vr_ind).estado       := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 2, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,2));
            vr_tab_logradouro(vr_ind).nome_rua_res := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 4, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,72));
            vr_tab_logradouro(vr_ind).complemento  := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 4, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,90));
            vr_tab_logradouro(vr_ind).nome_rua     := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 5, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,80));
            vr_tab_logradouro(vr_ind).cep          := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 6, pr_dstext => vr_setlinha, pr_delimitador => '@'));

            -- verificar se a cidade existe
            IF pr_tab_cidade.EXISTS(vr_cidade_cod) THEN
              vr_tab_logradouro(vr_ind).cidade_nome  := SUBSTR(pr_tab_cidade(vr_cidade_cod).nome,1,40);
              vr_tab_logradouro(vr_ind).cidade_res   := SUBSTR(pr_tab_cidade(vr_cidade_cod).resumido,1,25);
              vr_tab_logradouro(vr_ind).codibge      := pr_tab_cidade(vr_cidade_cod).codibge;              
            ELSE 
              vr_tab_logradouro(vr_ind).cidade_nome  := ' ';
              vr_tab_logradouro(vr_ind).cidade_res   := ' ';
              vr_tab_logradouro(vr_ind).codibge      := 0;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Atualizar o controle de erros
              vr_erro_leitura := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                                     ,pr_texto_completo => vr_dstexto_leitura
                                     ,pr_texto_novo     => vr_setlinha || '  #  ' || 
                                                           SQLERRM     || chr(10));  
          END;
          
        END LOOP; -- Loop Arquivo

      EXCEPTION 
        WHEN no_data_found THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

        WHEN OTHERS THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
          vr_dscritic:= 'Erro geral no processamento do arquivo: ' || vr_nmarqprc || ': ' ||
                        REPLACE(REPLACE(SQLERRM,'''',NULL),'"',NULL);
          RAISE vr_exc_saida;
      END;
      
      -- Verificar se foram processados a quantidade para para realizar o commit
      IF vr_tab_logradouro.COUNT() > 0 THEN
        -- Insert dos enderecos
        pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                          ,pr_idtipdne       => vr_idtipdne
                          ,pr_dscritic       => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Atualizar o controle de erros
          vr_erro_insert := TRUE;
          -- Erro na busca dos dados
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                 ,pr_texto_completo => vr_dstexto_insert
                                 ,pr_texto_novo     => vr_dscritic || chr(10)); 
          vr_dscritic := NULL;
        END IF;
      END IF; 
      
      IF vr_erro_leitura THEN
        -- Fecha o XML de erro de leitura
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                               ,pr_texto_completo => vr_dstexto_leitura
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_leitura
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_LEITURA_CPC.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      IF vr_erro_insert THEN
        -- Fecha o XML de erro de insert
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                               ,pr_texto_completo => vr_dstexto_insert
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_insert
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_INSERT_CPC.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      -- Se chegou aqui, commitar os registros
      COMMIT;
       
      -- Remover o arquivo depois de processar
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq || vr_nmarqprc);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina da tela CADDNE.pc_proc_arq_cpc: ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
  END pc_proc_arq_cpc;

  PROCEDURE pc_proc_arq_estado(pr_tab_cidade IN typ_tab_cidade --> Tabela de Cidades
                              ,pr_tab_bairro IN typ_tab_bairro --> Tabela de Bairros
                              ,pr_dssigla   IN VARCHAR2     --> Sigla do estado que será processado
                              ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

  BEGIN

    /* .............................................................................

    Programa: pc_proc_arq_estado
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para processar os arquivos LOG_LOGRADOURO_*.TXT
    
    Mascara   : O arquivo possui os campos separados por '@'
                Lista dos campos:
                1 - Codigo da Rua
                2 - Sigla do Estado
                3 - Codigo da Cidade
                4 - Codigo do Bairro
                5 - DESCONHECIDO
                6 - Nome da Rua
                7 - Complemento
                8 - CEP
                9 - Tipo da Rua
               10 - DESCONHECIDO
               11 - Nome Resumido da Rua

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Diretorio onde estao os arquivos do correio que serao processados
      vr_dsdirarq CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',0,'ROOT_ARQUIVO_CORREIOS');
      vr_nmarqprc VARCHAR2(50) := 'LOG_LOGRADOURO_'|| pr_dssigla ||'.TXT';

      -- Identificacao dos Enderecos
      vr_idtipdne CONSTANT crapdne.idtipdne%TYPE := 1; -- Cadastro de Enderecos

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);
      
      -- Arquivo de ERRO na leitura das linhas
      vr_erro_leitura    BOOLEAN;
      vr_clob_leitura    CLOB;
      vr_dstexto_leitura VARCHAR2(32700);
      
      -- Arquivo de ERRO na insercao dos enderecos
      vr_erro_insert    BOOLEAN;
      vr_clob_insert    CLOB;
      vr_dstexto_insert VARCHAR2(32700);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis para processamento do arquivo
      vr_input_file  UTL_FILE.FILE_TYPE;
      vr_setlinha    VARCHAR2(32500);
      
      -- Campos 
      vr_cidade_cod   INTEGER;
      vr_bairro_cod   INTEGER;
      
      -- PL TABLE de Logradouros 
      vr_tab_logradouro typ_tab_logradouro;
      vr_ind            INTEGER;
      
    BEGIN
      -- Verificar se o arquivo LOG_LOGRADOURO_*.TXT existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || vr_nmarqprc) THEN 
        -- Se o arquivo nao existe levantamos o erro
        vr_dscritic := 'Arquivo ' || vr_nmarqprc || ' nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      vr_erro_leitura := FALSE;
      vr_erro_insert  := FALSE;

      -- Abrir o arquivo 
      gene0001.pc_abre_arquivo (pr_nmcaminh => vr_dsdirarq || vr_nmarqprc --> Diretório do arquivo
                               ,pr_tipabert => 'R'                        --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file              --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);              --> Descricao do erro

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      DELETE FROM crapdne
            WHERE UPPER(crapdne.cduflogr) = pr_dssigla
              AND crapdne.idoricad = const_origem_cadastro  -- Origem do Cadastro
              AND crapdne.idtipdne = vr_idtipdne; -- Cadastro de Enderecos
      -- Realizamos o commit 
      COMMIT;

      -- Limpar a tabela
      vr_tab_logradouro.DELETE;
      
      BEGIN
        -- Laco para leitura de linhas do arquivo
        LOOP
          -- Verificar se foram processados a quantidade para para realizar o commit
          IF vr_tab_logradouro.COUNT() = vr_qtd_reg_commit THEN
            pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                              ,pr_idtipdne       => vr_idtipdne
                              ,pr_dscritic       => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              -- Atualizar o controle de erros
              vr_erro_insert := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                     ,pr_texto_completo => vr_dstexto_insert
                                     ,pr_texto_novo     => vr_dscritic || chr(10)); 
              vr_dscritic := NULL;
            END IF;
          END IF;

          -- Atualizar o totalizador
          vr_ind := vr_tab_logradouro.COUNT() + 1;

          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Retirar quebra de linha
          vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
          -- Retirar os espacos em branco
          vr_setlinha := TRIM(vr_setlinha);

          -- Buscar os dados da RUA
          BEGIN
            -- Codigo da Cidade e do Bairro
            vr_cidade_cod   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 3, pr_dstext => vr_setlinha, pr_delimitador => '@'));
            vr_bairro_cod   := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 4, pr_dstext => vr_setlinha, pr_delimitador => '@'));

            vr_tab_logradouro(vr_ind).estado       := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 2, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,2));
            vr_tab_logradouro(vr_ind).nome_rua     := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 6, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,80));
            vr_tab_logradouro(vr_ind).complemento  := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 7, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,90));
            vr_tab_logradouro(vr_ind).cep          := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 8, pr_dstext => vr_setlinha, pr_delimitador => '@'));
            vr_tab_logradouro(vr_ind).tipo         := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 9, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,25));
            vr_tab_logradouro(vr_ind).nome_rua_res := gene0007.fn_caract_acento(SUBSTR(gene0002.fn_busca_entrada(pr_postext => 11, pr_dstext => vr_setlinha, pr_delimitador => '@'),1,72));

            -- verificar se o bairro existe
            IF pr_tab_bairro.EXISTS(vr_bairro_cod) THEN
              vr_tab_logradouro(vr_ind).bairro_nome  := SUBSTR(pr_tab_bairro(vr_bairro_cod).nome,1,72);
              vr_tab_logradouro(vr_ind).bairro_res   := SUBSTR(pr_tab_bairro(vr_bairro_cod).resumido,1,40);
            ELSE 
              vr_tab_logradouro(vr_ind).bairro_nome  := ' ';
              vr_tab_logradouro(vr_ind).bairro_res   := ' ';
            END IF;
            
            -- verificar se a cidade existe
            IF pr_tab_cidade.EXISTS(vr_cidade_cod) THEN
              vr_tab_logradouro(vr_ind).cidade_nome  := SUBSTR(pr_tab_cidade(vr_cidade_cod).nome,1,40);
              vr_tab_logradouro(vr_ind).cidade_res   := SUBSTR(pr_tab_cidade(vr_cidade_cod).resumido,1,25);
              vr_tab_logradouro(vr_ind).codibge      := pr_tab_cidade(vr_cidade_cod).codibge;              
            ELSE 
              vr_tab_logradouro(vr_ind).cidade_nome  := ' ';
              vr_tab_logradouro(vr_ind).cidade_res   := ' ';
              vr_tab_logradouro(vr_ind).codibge      := 0;              
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Atualizar o controle de erros
              vr_erro_leitura := TRUE;
              -- Erro na busca dos dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                                     ,pr_texto_completo => vr_dstexto_leitura
                                     ,pr_texto_novo     => vr_setlinha || '  #  ' || 
                                                           SQLERRM     || chr(10));  
          END;
          
        END LOOP; -- Loop Arquivo

      EXCEPTION 
        WHEN no_data_found THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

        WHEN OTHERS THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
          vr_dscritic:= 'Erro geral no processamento do estado ' || pr_dssigla || ': ' ||
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
          RAISE vr_exc_saida;
      END;
      
      -- Verificar se foram processados a quantidade para para realizar o commit
      IF vr_tab_logradouro.COUNT() > 0 THEN
        -- Insert dos enderecos
        pc_insere_endereco(pr_tab_logradouro => vr_tab_logradouro
                          ,pr_idtipdne       => vr_idtipdne
                          ,pr_dscritic       => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Atualizar o controle de erros
          vr_erro_insert := TRUE;
          -- Erro na busca dos dados
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                                 ,pr_texto_completo => vr_dstexto_insert
                                 ,pr_texto_novo     => vr_dscritic || chr(10)); 
          vr_dscritic := NULL;
        END IF;
      END IF; 
      
      IF vr_erro_leitura THEN
        -- Fecha o XML de erro de leitura
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_leitura
                               ,pr_texto_completo => vr_dstexto_leitura
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_leitura
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_LEITURA_' || pr_dssigla || '.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      IF vr_erro_insert THEN
        -- Fecha o XML de erro de insert
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_insert
                               ,pr_texto_completo => vr_dstexto_insert
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);  

        -- Converte o CLOB para arquivo
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_insert
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => 'ERRO_INSERT_' || pr_dssigla || '.TXT'
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      -- Se chegou aqui, commitar os registros
      COMMIT;
      
      -- Remover o arquivo depois de processar
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq || vr_nmarqprc);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina da tela CADDNE.pc_proc_arq_estado: ' || 
                       '(' || pr_dssigla || ') - ' ||
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
  END pc_proc_arq_estado;

  PROCEDURE pc_proc_arq_correio(pr_fluniope  IN INTEGER  --> Processar o arquivo UNID OPER (0-NAO/1-SIM)
                               ,pr_flgrausu  IN INTEGER  --> Processar o arquivo GRANDE USUARIO (0-NAO/1-SIM)
                               ,pr_flcpc     IN INTEGER  --> Processar o arquivo CAIXA POSTAL COMUNITARIA (0-NAO/1-SIM)
                               ,pr_nmestado  IN VARCHAR2 --> Nome do Estado que sera importado
                               ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com erros
  BEGIN

    /* .............................................................................

    Programa: pc_proc_arq_correio
    Sistema : Ayllos Web
    Autor   : Douglas Quisinski
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para processar os arquivos de endereco dos correios

    Alteracoes: 
    ..............................................................................*/

    DECLARE
      -- Lista de estados que devem ser processados
      vr_dsallest CONSTANT VARCHAR2(200) := 'AC;AL;AP;AM;BA;CE;DF;ES;GO;MA;MT;MS;MG;PA;PB;PR;PE;PI;RJ;RN;RS;RO;RR;SC;SP;SE;TO;EX';

      vr_dsestprc VARCHAR2(200);
      vr_lista_estados GENE0002.typ_split;

      -- Tabela de cidades
      vr_tab_cidade typ_tab_cidade;
      -- Tabela de bairros
      vr_tab_bairro typ_tab_bairro;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
    BEGIN
      pr_tab_erro.DELETE;  
      
      -- Primeiro precisamos carregar o nome de todas as cidades
      pc_proc_arq_localidade(pr_tab_cidade => vr_tab_cidade --> Tabela de Cidades
                            ,pr_dscritic   => vr_dscritic); --> Critica
      -- Verificar se houve critica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Abortar o processo
        RAISE vr_exc_saida;
      END IF;

      -- Precissamos carregar o nome de todos os bairros
      pc_proc_arq_bairro(pr_tab_bairro => vr_tab_bairro --> Tabela de Bairros
                        ,pr_dscritic   => vr_dscritic); --> Critica
      -- Verificar se houve critica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Abortar o processo
        RAISE vr_exc_saida;
      END IF;
    
      -- Verificar se o arquivo UNID. OPER. deve ser processado
      IF pr_fluniope  = 1 THEN
        -- Processar o arquivo LOG_UNID_OPER.TXT
        pc_proc_arq_unid_oper(pr_tab_cidade => vr_tab_cidade --> Tabela de Cidades
                             ,pr_tab_bairro => vr_tab_bairro --> Tabela de Bairros
                             ,pr_dscritic   => vr_dscritic); --> Descricao da Critica

        -- Verificar se houve critica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Adicionar a critica no retorno de erros
          gene0001.pc_gera_erro(pr_cdcooper => 3, -- CECRED
                                pr_cdagenci => 0,
                                pr_nrdcaixa => 0,
                                pr_nrsequen => pr_tab_erro.COUNT() + 1, --> Fixo
                                pr_cdcritic => NVL(vr_cdcritic, 0),
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
          
          -- Limpar a critica local
          vr_dscritic:= NULL;
        END IF;
      END IF;
      
      -- Verificar se o arquivo GRANDE USUARIO deve ser processado
      IF pr_flgrausu = 1 THEN
        -- Processar o arquivo LOG_GRANDE_USUARIO.TXT
        pc_proc_arq_grande_usuario(pr_tab_cidade => vr_tab_cidade --> Tabela de Cidades
                                  ,pr_tab_bairro => vr_tab_bairro --> Tabela de Bairros
                                  ,pr_dscritic   => vr_dscritic); --> Descricao da Critica

        -- Verificar se houve critica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Adicionar a critica no retorno de erros
          gene0001.pc_gera_erro(pr_cdcooper => 3, -- CECRED
                                pr_cdagenci => 0,
                                pr_nrdcaixa => 0,
                                pr_nrsequen => pr_tab_erro.COUNT() + 1, --> Fixo
                                pr_cdcritic => NVL(vr_cdcritic, 0),
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
          -- Limpar a critica local
          vr_dscritic:= NULL;
        END IF;
      END IF;
      
      -- Verificar se o arquivo CAIXA POSTAL COMUNITARIA deve ser processado
      IF pr_flcpc = 1 THEN
        -- Processar o arquivo LOG_CPC.TXT
        pc_proc_arq_cpc(pr_tab_cidade => vr_tab_cidade --> Tabela de Cidades
                       ,pr_dscritic   => vr_dscritic); --> Descricao da Critica

        -- Verificar se houve critica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Adicionar a critica no retorno de erros
          gene0001.pc_gera_erro(pr_cdcooper => 3, -- CECRED
                                pr_cdagenci => 0,
                                pr_nrdcaixa => 0,
                                pr_nrsequen => pr_tab_erro.COUNT() + 1, --> Fixo
                                pr_cdcritic => NVL(vr_cdcritic, 0),
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
          -- Limpar a critica local
          vr_dscritic:= NULL;
        END IF;
      END IF;
    
      -- Verificar se vai ser processado o arquivo de estados
      IF UPPER(NVL(TRIM(pr_nmestado),' ')) != 'NADA' THEN
      
        -- Verificar se o estado foi informado
        IF TRIM(pr_nmestado) IS NULL THEN
          -- Utilizar a lista com todos os estados
          vr_dsestprc := vr_dsallest;
        ELSE
          -- Utilizar apenas os estados que foram informados
          vr_dsestprc := pr_nmestado;
        END IF;

        -- Separar a lista de estados que serao processados
        vr_lista_estados := gene0002.fn_quebra_string(vr_dsestprc,';');
        -- Percorrer todos os estados 
        FOR vr_estado IN vr_lista_estados.FIRST..vr_lista_estados.LAST LOOP
          -- Processar o arquivo LOG_LOGRADOURO_*.TXT
          pc_proc_arq_estado(pr_tab_cidade => vr_tab_cidade --> Tabela de Cidades
                            ,pr_tab_bairro => vr_tab_bairro --> Tabela de Bairros
                            ,pr_dssigla    => vr_lista_estados(vr_estado) --> Sigla do estado que sera processado
                            ,pr_dscritic   => vr_dscritic); --> Descricao da Critica
                               
          -- Verificar se houve critica
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Adicionar a critica no retorno de erros
            gene0001.pc_gera_erro(pr_cdcooper => 3, -- CECRED
                                  pr_cdagenci => 0,
                                  pr_nrdcaixa => 0,
                                  pr_nrsequen => pr_tab_erro.COUNT() + 1, --> Fixo
                                  pr_cdcritic => NVL(vr_cdcritic, 0),
                                  pr_dscritic => vr_dscritic,
                                  pr_tab_erro => pr_tab_erro);
            -- Limpar a critica local
            vr_dscritic:= NULL;
          END IF;
        END LOOP;
      END IF;
      
      -- Finalizou o processo todo
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Adicionar a critica no retorno de erros
        gene0001.pc_gera_erro(pr_cdcooper => 3, -- CECRED
                              pr_cdagenci => 0,
                              pr_nrdcaixa => 0,
                              pr_nrsequen => pr_tab_erro.COUNT() + 1, --> Fixo
                              pr_cdcritic => NVL(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);         
        
      WHEN OTHERS THEN
        -- Critica de erro
        vr_dscritic := 'Erro geral na rotina da tela CADDNE: ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
        -- Adicionar a critica no retorno de erros
        gene0001.pc_gera_erro(pr_cdcooper => 3, -- CECRED
                              pr_cdagenci => 0,
                              pr_nrdcaixa => 0,
                              pr_nrsequen => pr_tab_erro.COUNT() + 1, --> Fixo
                              pr_cdcritic => NVL(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);         
    END;
  END pc_proc_arq_correio;

END TELA_CADDNE;
/
