-- Created on 13/03/2019 by F0030248 
-- Atualizar cadastro de CEP de municipios sem CEP por logradouro
declare 
  -- Local variables here
  i integer;
  
  -- Identificacao dos Enderecos
  const_origem_cadastro CONSTANT crapdne.idoricad%TYPE := 1; -- Origem do Cadastro como CORREIOS (1)  
    
  -- Tipo de registro para o nome das cidades
  TYPE typ_reg_cidade IS
    RECORD (codigo   INTEGER
           ,cep      crapdne.nrceplog%TYPE    
           ,estado   crapdne.cduflogr%TYPE
           ,nome     crapdne.nmextcid%TYPE
           ,resumido crapdne.nmrescid%TYPE
           ,temceplog INTEGER);  
           
  -- O indice da tabela sera o codigo da cidade
  TYPE typ_tab_cidade IS
    TABLE OF typ_reg_cidade
    INDEX BY PLS_INTEGER;            
           
  vr_tab_cidade typ_tab_cidade;           
  vr_dscritic VARCHAR2(1000);
  
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
      vr_temceplog INTEGER;
      vr_cep      crapdne.nrceplog%TYPE;
      
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
          vr_temceplog := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext => 5, pr_dstext => vr_setlinha, pr_delimitador => '@'));          
          
          IF vr_cep > 0 THEN
            -- Carregar os dados da Cidade para a PL_TABLE
            pr_tab_cidade(vr_codigo).codigo   := vr_codigo;
            pr_tab_cidade(vr_codigo).estado   := vr_estado;
            pr_tab_cidade(vr_codigo).nome     := vr_nome;
            pr_tab_cidade(vr_codigo).resumido := vr_resumido;
            pr_tab_cidade(vr_codigo).cep      := vr_cep;
            pr_tab_cidade(vr_codigo).temceplog := vr_temceplog;
          END IF;
          
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
        pr_dscritic := 'Erro geral na rotina da tela CADDNE.pc_proc_arq_localidade: ' || 
                        REPLACE(REPLACE(SQLERRM || ' -> ' ||
                                       dbms_utility.format_error_backtrace || ' - ' ||
                                       dbms_utility.format_error_stack,'''',NULL),'"',NULL);
    END;
  END pc_proc_arq_localidade;
  
BEGIN

  -- Criar crítica de boleto com problema de CEP do pagador
  begin
    -- Test statements here
    insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
    values (1463, '1463 - CEP do pagador incorreto. Favor atualizar o endereco do pagador e comandar novamente.', 3, 0);
  
    COMMIT;
  end;

  -- criar crítica de boleto nao protestado;  
	BEGIN
		FOR rw IN (SELECT cdcooper FROM crapcop) LOOP
			  insert into crapmot (CDCOOPER, CDDBANCO, CDOCORRE, TPOCORRE, CDMOTIVO, DSMOTIVO, DSABREVI, CDOPERAD, DTALTERA, HRTRANSA)
			  values (rw.cdcooper, 85, 26, 2, 'NP', 'Boleto nao protestado devido ao CEP do pagador incorreto.', ' ', '1', to_date('15-03-2019', 'dd-mm-yyyy'), 0);
		END LOOP;
		commit;
	END;  
  
  pc_proc_arq_localidade(pr_tab_cidade => vr_tab_cidade --> Sigla do estado que será processado
                        ,pr_dscritic   => vr_dscritic);   --> Descricao da critica
                        
  dbms_output.put_line(vr_dscritic);                        
  
  IF vr_dscritic IS NULL THEN
    
    -- processar municipios;
    BEGIN
      FORALL idx IN INDICES OF vr_tab_cidade SAVE EXCEPTIONS
        MERGE 
          INTO crapdne dne
          USING (SELECT 1 FROM dual) s
             ON (dne.nrceplog = vr_tab_cidade(idx).cep
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
             VALUES(vr_tab_cidade(idx).cep
                   ,substr('MUNICIPIO DE ' || NVL(UPPER(TRIM(vr_tab_cidade(idx).nome)),' '),1,80)
                   ,substr('MUNICIPIO DE ' || NVL(UPPER(TRIM(vr_tab_cidade(idx).nome)),' '),1,72)
                   ,'.'
                   ,' '
                   ,' '
                   ,' '
                   ,substr(NVL(UPPER(TRIM(vr_tab_cidade(idx).nome)),' '),1,40)
                   ,substr(NVL(UPPER(TRIM(vr_tab_cidade(idx).nome)),' '),1,25)
                   ,NVL(UPPER(TRIM(vr_tab_cidade(idx).estado)),' ')
                   ,const_origem_cadastro   -- Origem do Cadastro (1 - CORREIOS)
                   ,5); -- Tipo de Enderecao 5 = Municipios
    EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao inserir na tabela crapdne. '||
                         SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE)));      
    END;                           
    
  END IF;

  COMMIT;
  -- Test statements here
  
end;
