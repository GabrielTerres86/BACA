create or replace function cecred.exporta_tabela_para_csv (p_query          in varchar2,
                                  p_dir            in varchar2,
                                  p_arquivo        in varchar2,
                                  p_nome_colunas   in boolean default true,
                                  p_progress_recid in boolean default false,
                                  p_formato_data   in varchar2 default 'dd/mm/yy') return number is
  -- Função para exportar o resultado da query enviada como parâmetro. A saída é um arquivo separado por ";", com extensão CSV.
  -- Parâmetros:
  --     p_query          -> Query da qual se deseja exportar o resultado. Deve ser enviada em formato texto, para execução como SQL dinâmico.
  --     p_dir            -> Diretório onde será salvo o arquivo exportado.
  --     p_arquivo        -> Nome do arquivo a ser criado. Não é necessário incluir a extensão, será sempre gerado como CSV.
  --     p_nome_colunas   -> Se for verdadeiro, inclui o nome das colunas na primeira linha. Se for falso, não inclui.
  --     p_progress_recid -> Se for falso, não inclui a coluna PROGRESS_RECID (última coluna das tabelas). Se for verdadeiro, inclui.
  --     p_formato_data   -> Formato de data desejada na saída do arquivo. Deve ser passado da mesma forma que se utilizaria em um to_char.
  --
  -- A função retorna 1 quando executar com sucesso. Aborta a execução com raise quando houver algum erro.
  --
  -- Restrições:
  --     1. Se algum dos campos a ser exportado possuir o caracter ";" no seu conteúdo, deve ser utilizado um replace na query,
  --     substituindo por outro caracter. Caso contrário, o conteúdo do campo será separado em duas (ou mais) colunas no arquivo de saída.
  --     2. O limite de bytes por linha é de 32767, por limitação do UTL_FILE.
  --
  -- Exemplos de uso:
  --
  -- declare
  --   v_query   varchar2(1000);
  --   v_result  number(1);
  -- begin
  --   v_query := 'select * from craplrg where cdcooper = 3';
  --   v_result := exporta_tabela_para_csv(p_query => v_query,
  --                                       p_dir => '/micros/cecred/daniel',
  --                                       p_arquivo => 'craplrg');
  --   --
  --   v_query := 'select cdagenci, dtmvtolt, nrdconta from craplap where cdcooper = 1 and dtmvtolt = ''30/08/2013''';
  --   v_result := exporta_tabela_para_csv(p_query => v_query,
  --                                       p_dir => '/micros/cecred/daniel',
  --                                       p_arquivo => 'craplap');
  -- end;

  cursor c_nls_date_format is
    select value
      from nls_session_parameters
     where parameter = 'NLS_DATE_FORMAT';
  v_nls_date_format   nls_session_parameters.value%type;
  --
  l_output        utl_file.file_type;
  l_theCursor     integer default dbms_sql.open_cursor;
  l_columnValue   varchar2(4000);
  l_status        integer;
  l_colCnt        number := 0;
  l_separator     varchar2(1);
  l_desctbl       dbms_sql.desc_tab;
  v_tamanho_linha number(5);
  tamanho_linha   exception;
begin
  open c_nls_date_format;
    fetch c_nls_date_format into v_nls_date_format;
  close c_nls_date_format;
  --
  l_output := utl_file.fopen( p_dir, p_arquivo||'.csv', 'w', 32767 );
  execute immediate 'alter session set nls_date_format='''||p_formato_data||'''';

  dbms_sql.parse( l_theCursor,  p_query, dbms_sql.native );
  dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );

  if p_nome_colunas then
    v_tamanho_linha := 0;
    for i in 1 .. l_colcnt loop
      -- Verifica se é a coluna progress_recid e se deve gerá-la no arquivo
      if not p_progress_recid and
         l_desctbl(i).col_name = 'PROGRESS_RECID' then
        continue;
      end if;
      -- Verifica se o conteúdo cabe no limite do utl_file
      v_tamanho_linha := v_tamanho_linha + length(l_desctbl(i).col_name) + 3;
      if v_tamanho_linha > 32767 then
        raise tamanho_linha;
      end if;
      -- Gera a informacao no arquivo
      utl_file.put( l_output, l_separator || '"' || l_descTbl(i).col_name || '"' );
      dbms_sql.define_column( l_theCursor, i, l_columnValue, 4000 );
      l_separator := ';';
    end loop;
    utl_file.new_line( l_output );
  else
    for i in 1 .. l_colCnt loop
      -- Verifica se é a coluna progress_recid e se deve gerá-la no arquivo
      if not p_progress_recid and
         l_desctbl(i).col_name = 'PROGRESS_RECID' then
        continue;
      end if;
      --
      dbms_sql.define_column( l_theCursor, i, l_columnValue, 4000 );
    end loop;
  end if;

  l_status := dbms_sql.execute(l_theCursor);

  while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
    l_separator := '';
    v_tamanho_linha := 0;
    for i in 1 .. l_colCnt loop
      -- Verifica se é a coluna progress_recid e se deve gerá-la no arquivo
      if not p_progress_recid and
         l_desctbl(i).col_name = 'PROGRESS_RECID' then
        continue;
      end if;
      -- Verifica se o conteúdo cabe no limite do utl_file
      v_tamanho_linha := v_tamanho_linha + length(l_columnvalue) + 1;
      if v_tamanho_linha > 32767 then
        raise tamanho_linha;
      end if;
      -- Gera a informação no arquivo
      dbms_sql.column_value( l_theCursor, i, l_columnValue );
      utl_file.put( l_output, l_separator || l_columnValue );
      l_separator := ';';
    end loop;
    utl_file.new_line( l_output );
  end loop;
  dbms_sql.close_cursor(l_theCursor);
  utl_file.fclose( l_output );
  -- altera permissão no arquivo
  gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 777 '||p_dir||'/'||p_arquivo||'.csv');
  --
  execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
  return(1);
exception
  when tamanho_linha then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    raise_application_error(-20000, 'Conteúdo excede o limite de 32767 bytes por linha');

  when utl_file.invalid_path then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    utl_file.fclose_all;
    raise_application_error(-20051, 'Invalid Path');

  when utl_file.invalid_mode then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    utl_file.fclose_all;
    raise_application_error(-20052, 'Invalid Mode');

  when utl_file.internal_error then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    utl_file.fclose_all;
    raise_application_error(-20053, 'Internal Error');

  when utl_file.invalid_operation then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    utl_file.fclose_all;
    raise_application_error(-20054, 'Invalid Operation');

  when utl_file.invalid_filehandle then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    utl_file.fclose_all;
    raise_application_error(-20055, 'Invalid File Handle');

  when utl_file.write_error then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    utl_file.fclose_all;
    raise_application_error(-20056, 'Write Error');

  when others then
    execute immediate 'alter session set nls_date_format='''||v_nls_date_format||'''';
    raise;
end;
/

