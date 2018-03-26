/* 
Criar arquivo /usr/coop/viacredi/log/proc_graf_ddmmrrrr.csv com as últimas 90 execuções diárias
dos programas listados em \\micros\viacredi\programas\lista.txt com o objetivo de gerar gráficos do andamento das
execuções dos mesmos.

Arquivos:
\\micros\cooperativa\programas\*.txt

Layout do conteúdo dos arquivos:
N#programa1,programa2,programa3

"N" - Identifica como considerar a execução mensal dos programas: 
  0 - pular execução mensal;
  1 - considerar exec mensal;
  2 - apenas exec mensal
  
"programa1,programa2,programa3..." - Lista dos programas (tbgen_prglog.cdprograma) a serem pesquisados
*/
CREATE OR REPLACE PROCEDURE CECRED.pc_grafico_cadeia(pr_cdcooper IN  crapcop.cdcooper%TYPE,
                                                     pr_dscritic OUT VARCHAR2) IS BEGIN
DECLARE
  
  -- Data inicial
  vr_dtini NUMBER := to_number(to_char(to_date(SYSDATE - 90, 'dd-mm-rrrr'), 'j'));
  -- Data final
  vr_dtfim NUMBER := to_number(to_char(to_date(SYSDATE,      'dd-mm-rrrr'), 'j'));
  -- Dia iterado
  vr_dia   NUMBER;
  -- Lista dos programas (\\micros\viacredi\programas\arquivoqualquer + .txt)
  vr_lista     VARCHAR2(4000); -- 'CRPS568.P;label 1,CRPS538.P;label 2...
  -- Array contendo os programas
  vr_programas    gene0002.typ_split;
  -- Array contendo os arquivos
  vr_arr_arquivos gene0002.typ_split;

  vr_mensal    PLS_INTEGER := 0;

  vr_cabecalho VARCHAR2(4000);  
  vr_linha     VARCHAR2(32000);
  vr_flgachou  BOOLEAN := FALSE;  
  vr_dia_atual DATE := to_date(vr_dtini, 'j');  
  vr_dscritic  VARCHAR2(500);
  vr_utlfileh  UTL_FILE.file_type;

  vr_arquivos VARCHAR2(32000);
  
  vr_nomearq   VARCHAR2(100);

  vr_label     VARCHAR2(100);

  -- Array contendo programa(1) e label(2), separados por ; na string vr_programas
  vr_arr_prglbl gene0002.typ_split;

  CURSOR cr_prglog(pr_dia IN DATE,
                   pr_cdprograma VARCHAR2) IS
    SELECT prl.cdprograma
         , TRUNC(prl.dhinicio) Dia
         , to_char(prl.dhinicio, 'hh24:mi:ss') Inicio
         , to_char(prl.dhfim, 'hh24:mi:ss') Termino 
      FROM tbgen_prglog prl 
     WHERE prl.cdcooper = pr_cdcooper
       AND trunc(prl.dhinicio) = trunc(pr_dia)
       AND prl.cdprograma = pr_cdprograma 
     ORDER BY prl.nrexecucao DESC;
     
  rw_prglog cr_prglog%ROWTYPE;

  -- Subrotina para escrever nos arquivos
  PROCEDURE pc_escreve_arquivo(pr_nomearq IN VARCHAR2,
                               pr_tpabertura IN VARCHAR2,
                               pr_texto IN VARCHAR2) IS BEGIN
  BEGIN
    -- Tenta abrir o arquivo de log em modo novo
    gene0001.pc_abre_arquivo(pr_nmdireto => gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                                                  pr_cdcooper => pr_cdcooper, 
                                                                  pr_nmsubdir => 'log') --> Diretório do arquivo
                            ,pr_nmarquiv => pr_nomearq  --> Nome do arquivo
                            ,pr_tipabert => pr_tpabertura --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      raise_application_error(-20001, 'Erro ao abrir arquivo: ' || vr_dscritic);
    END IF;

    BEGIN
      gene0001.pc_escr_linha_arquivo(vr_utlfileh,pr_texto);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001, 'Problema ao escrever no arquivo <'||pr_nomearq||'>: ' || sqlerrm);
    END;

    BEGIN
      gene0001.pc_fecha_arquivo(vr_utlfileh);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001, 'Problema ao fechar o arquivo <'||pr_nomearq||'>: ' || sqlerrm);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Erro ao escrever no arquivo. '||sqlerrm);
  END;
  END pc_escreve_arquivo;
  
  -- Principal
  BEGIN

    gene0001.pc_lista_arquivos(pr_path     => gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                                    pr_cdcooper => pr_cdcooper, 
                                                                    pr_nmsubdir => 'programas'), 
                               pr_pesq     => '%.txt', 
                               pr_listarq  => vr_arquivos, 
                               pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      raise_application_error(-20001, 'Erro ao listar os arquivos txt em ' || gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                                                                    pr_cdcooper => pr_cdcooper, 
                                                                                                    pr_nmsubdir => 'programas'));
    END IF;

    IF TRIM(vr_arquivos) IS NULL THEN
      raise_application_error(-20001, 'Sem arquivos txt em ' || gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                                                      pr_cdcooper => pr_cdcooper, 
                                                                                      pr_nmsubdir => 'programas'));
    END IF;

    vr_arr_arquivos := gene0002.fn_quebra_string(vr_arquivos);

    FOR nrarq IN vr_arr_arquivos.FIRST .. vr_arr_arquivos.LAST LOOP

      -- Abrir o arquivo /micros/cooperativa/programas/lista.txt
      gene0001.pc_abre_arquivo(pr_nmdireto => gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                                    pr_cdcooper => pr_cdcooper, 
                                                                    pr_nmsubdir => 'programas')
                              ,pr_nmarquiv => vr_arr_arquivos(nrarq)
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20001, 'Erro ao abrir arquivo: /micros/cooperativa/programas/lista.txt ' || vr_dscritic);
      END IF;

      -- Busca as informacoes da linha do arquivo
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                  ,pr_des_text => vr_lista);  --> Texto lido

      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

      -- Quebra a lista de programas por #
      vr_programas := gene0002.fn_quebra_string(vr_lista,'#');

      -- Atribui a definicao de execução mensal a partir da primeira parte da lista de programas     
      BEGIN
        vr_mensal := vr_programas(1);
      EXCEPTION
        WHEN OTHERS THEN
          vr_mensal := 0;
      END;

      -- Quebra a lista de programas por ;
      vr_programas := gene0002.fn_quebra_string(vr_programas(2),';');

      -- Cabeçalho
      vr_cabecalho := ';';
      FOR idx IN 1..vr_programas.count() LOOP
        vr_cabecalho := vr_cabecalho || 'Início;Fim;';
      END LOOP;
      
      vr_cabecalho := vr_cabecalho || chr(13) || 'DATA;';
      FOR idx IN 1..vr_programas.count() LOOP

        --Montar cabeçalho com o label do programa
        vr_arr_prglbl := gene0002.fn_quebra_string(vr_programas(idx),',');
        vr_label      := vr_arr_prglbl(2);      

        vr_cabecalho := vr_cabecalho || 
                        vr_label || ';' ||
                        vr_label || ';';
      END LOOP;

      -- Nome da planilha: proc_graft_nomedoarquivo_ddmmrrrr.csv
      vr_nomearq := 'proc_graf_' || vr_arr_arquivos(nrarq) || to_char(SYSDATE,'_ddmmrrrr') ||'.csv';
      
      pc_escreve_arquivo(vr_nomearq,'W',vr_cabecalho);
      
      -- Iterar dias
      FOR vr_dia in vr_dtini .. vr_dtfim LOOP     

        -- Dias das semana a considerar
        IF pr_cdcooper <> 3 THEN
          IF to_char(to_date(vr_dia, 'j'),'D') < 3 THEN -- 1,2 = dom e seg coops nao rodam
            continue;
          END IF;
        ELSE
          IF to_char(to_date(vr_dia, 'j'),'D') IN (1,7) THEN -- cecred nao roda sab e dom
            continue;
          END IF;
        END IF;
                          
        vr_linha := to_char(to_date(vr_dia, 'j'),'dd/mm/rrrr') || ';';
        FOR idx IN 1..vr_programas.count() LOOP
          vr_flgachou := FALSE;
          
          -- programa: posição 1, label: posição 2
          vr_arr_prglbl := gene0002.fn_quebra_string(vr_programas(idx),',');
          
          FOR rw_prglog IN cr_prglog(pr_dia        => to_date(vr_dia, 'j'),
                                     pr_cdprograma => trim(vr_arr_prglbl(1))) LOOP
            
            -- Pular a execução mensal?
            IF NVL(vr_mensal,0) = 0 THEN            
              -- e mudou o mês?
              IF to_char(to_date(vr_dia, 'j'),'mm') <> to_char(vr_dia_atual,'mm') THEN              
                vr_dia_atual := to_date(vr_dia, 'j');
                vr_flgachou := FALSE;
                EXIT; -- sai do loop do log              
              END IF;            
            END IF;
            
            -- Apenas a execução mensal?
            IF NVL(vr_mensal,0) = 2 THEN
              IF to_char(to_date(vr_dia, 'j'),'mm') = to_char(vr_dia_atual,'mm') THEN              
                vr_dia_atual := to_date(vr_dia, 'j');
                vr_flgachou := FALSE;
                EXIT; -- sai do loop do log              
              END IF;
            END IF;
            
            vr_flgachou := TRUE;
            vr_linha := vr_linha || rw_prglog.Inicio ||';'|| rw_prglog.Termino ||';';
            EXIT;
          END LOOP;
          
          IF vr_flgachou = FALSE THEN
            EXIT; -- sai do loop do programa
          END IF;
          
        END LOOP;
        
        IF vr_flgachou = FALSE THEN
          continue; -- Vai para próximo dia
        END IF;
        
        -- Grava linha das execuções dos programas
        pc_escreve_arquivo(vr_nomearq,'A',vr_linha);

        vr_dia_atual := to_date(vr_dia, 'j');
      END LOOP;
    END LOOP;
    ROLLBACK;
  EXCEPTION
    WHEN no_data_found THEN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
    WHEN OTHERS THEN      
      cecred.pc_internal_exception;
      pr_dscritic := vr_dscritic;
  END;

END pc_grafico_cadeia;
/
