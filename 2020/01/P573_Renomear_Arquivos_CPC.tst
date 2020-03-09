PL/SQL Developer Test script 3.0
86
DECLARE
  -- Local variables here
  vr_exc_erro EXCEPTION;
  vr_handle_log utl_file.file_type;
  rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
  vr_des_erro   VARCHAR2(2000);
  vr_nm_direto  VARCHAR2(2000);

  vr_dscritic  VARCHAR2(100);
  vr_typ_saida VARCHAR2(10);
  vr_comando   VARCHAR2(4000);
  vr_listadir  VARCHAR2(4000);
  vr_nmtmparq  VARCHAR2(200);
  vr_nrindice  INTEGER;

  vr_nmtmpzip VARCHAR2(200) := '%telefone_cpc_out.zip';
  vr_dtarquiv DATE;
  vr_contarqv INTEGER := 0;
  vr_nmarqzip VARCHAR2(200);

  vr_tab_arqzip gene0002.typ_split;
BEGIN
  
  -- Busca o diretório do arquivo CPC
  vr_nm_direto  := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                        ,pr_cdcooper => 3
                                        ,pr_nmsubdir => '/cyber/recebe/');


  -- Vamos ler todos os arquivos .zip
  gene0001.pc_lista_arquivos(pr_path     => vr_nm_direto,
                             pr_pesq     => vr_nmtmpzip,
                             pr_listarq  => vr_listadir,
                             pr_des_erro => vr_des_erro);

  -- Se ocorrer erro ao recuperar lista de arquivos registra no log
  IF trim(vr_des_erro) IS NOT NULL THEN
    dbms_output.put_line(vr_des_erro);
  END IF;

  -- Carregar a lista de arquivos na temp table
  vr_tab_arqzip := gene0002.fn_quebra_string(pr_string => vr_listadir);

  --Filtrar os arquivos da lista
  IF vr_tab_arqzip.count > 0 THEN
    vr_nrindice := vr_tab_arqzip.first;
    -- carrega informacoes na cratqrq
    WHILE vr_nrindice IS NOT NULL LOOP
      --Filtrar a data apartir do Nome arquivo
      vr_nmtmparq := SUBSTR(vr_tab_arqzip(vr_nrindice), 1, 8);
      --Transformar em Data
      vr_dtarquiv := TO_DATE(vr_nmtmparq, 'YYYYMMDD');
    
      --Data Arquivo entre a data anterior e proximo dia util
      IF vr_dtarquiv < to_date('22/01/2020', 'DD/MM/RRRR') THEN
        --Incrementar quantidade arquivos
        vr_contarqv := vr_contarqv + 1;
      
        -- modifica nome do arquivo zip para "processado".
        vr_comando := 'cp ' || vr_nm_direto || '/' ||
                      vr_tab_arqzip(vr_nrindice) || ' ' || vr_nm_direto || '/' ||
                      to_char((SYSDATE + 1),'YYYYMMDD') ||
                      SUBSTR(vr_tab_arqzip(vr_nrindice),
                             9,
                             length(vr_tab_arqzip(vr_nrindice))) ||
                      ' 1> /dev/null';
      
        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S',
                              pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_saida,
                              pr_des_saida   => vr_des_erro);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          dbms_output.put_line('Nao foi possivel executar comando unix (mv) do arquivo: ' ||
                               vr_nmarqzip);
        END IF;
      
        vr_nrindice := vr_tab_arqzip.next(vr_nrindice);
      ELSE
        vr_nrindice := vr_tab_arqzip.next(vr_nrindice);
      END IF;
    END LOOP;
  END IF;

END;
0
3
vr_contarqv
vr_nrindice
vr_nmtmparq
