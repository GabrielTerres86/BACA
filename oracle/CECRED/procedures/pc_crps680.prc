CREATE OR REPLACE PROCEDURE CECRED.pc_crps680(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_nmtelant IN VARCHAR2                --> Nome da tela
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /* ..........................................................................
   Programa: PC_CRPS680
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Marco/2014.                  Ultima atualizacao: 20/11/2017
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 1.
               Gerar arq devolucoes de DOCs e atualizar as tabela gncpddc
               e crapddc.
   
   Alteracoes: 12/08/2014 - Ajustes na geracao do arquivo DCR605 para 
                            tratar a Unificacao das SIRC's; 018.
                            (Chamado 146058) - (Fabricio)
                            
               23/09/2014 - Incluir tratamentos para incorporação Concredi pela Via
                            e Credimilsul pela SCRCred (Marcos-Supero) 
                            
               04/11/2015 - Removido tratamento que validava se a cooperativa era
                            cecred e criava linha no arquivo com o campo  crapcop.cdagectl
                            fixo conforme relatado no chamado 335857 (Kelvin).             
                            
               30/06/2017 - Adicionar order by no cursor da crapddc, para que a 
                            ordenacao dos registros seja a mesma do partition
                            (Douglas - Chamado 703575)
                            
               20/11/2017 - Ajuste no formato da data no header e no trailer do arquivo,
                            conforme solicitado no chamado 786061. (Kelvin).
                              
  ............................................................................ */


------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
         , cop.nmrescop
         , cop.cdagectl
         , cop.cdbcoctl
         , cop.nrdivctl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%ROWTYPE;

  -- Busca registros devolucao na crapddc
  CURSOR cr_crapddc(pr_dtmvtoan crapddc.dtmvtolt%TYPE) IS
    SELECT ddc.nrdocmto,
           ddc.dtmvtolt,
           ddc.vldocmto,
           ddc.cdcooper,
           ddc.cdagenci,
           ddc.nrdconta,
           ddc.nmfavore,
           ddc.nrcpffav,
           ddc.cdcritic,
           ddc.cdbandoc,
           ddc.cdagedoc,
           ddc.nrctadoc,
           ddc.nmemiten,
           ddc.nrcpfemi,
           ddc.cdmotdev,
           ddc.cdoperad,
           ddc.flgpcctl,
           ddc.dslayout,
           ddc.cdcmpori,
           ROW_NUMBER() OVER(PARTITION BY DECODE(pr_cdcooper,3,0,ddc.cdagenci)                                          
                                ORDER BY  DECODE(pr_cdcooper,3,0,ddc.cdagenci)) AS seqlauto,
           Count(1) OVER (PARTITION BY    DECODE(pr_cdcooper,3,0,ddc.cdagenci)) AS seqlast 
      FROM crapddc ddc
     WHERE ddc.cdcooper = pr_cdcooper
       AND ddc.dtmvtolt = pr_dtmvtoan
       AND ddc.flgdevol = 1  --> Checados a devolver
       AND ddc.flgpcctl = 0  --> Não processados na Central
     ORDER BY  DECODE(pr_cdcooper,3,0,ddc.cdagenci);
  
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS680';
  -- Data de movimento, mês de referencia e demais datas de controle
  vr_dtmvtolt     DATE;
  vr_dtmvtoan     DATE;
  -- Variáveis de dados gerais do programa
  vr_seqarqui     PLS_INTEGER;
  vr_vltotreg     NUMBER(16,2);
  vr_vldocmto     NUMBER(16,2);
  vr_qtdregis     PLS_INTEGER;
  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_typ_saida    VARCHAR2(100);
  vr_des_saida    VARCHAR2(2000);
  vr_exc_fimprg   EXCEPTION;
  vr_exc_saida    EXCEPTION;
  vr_cdcritic     PLS_INTEGER;
  vr_dscritic     VARCHAR2(4000);
  vr_dsdireto     VARCHAR2(2000);
  vr_dsarquiv     VARCHAR2(2000);
  vr_dssalvar     VARCHAR2(2000);
  vr_nmarquiv     VARCHAR2(2000);
  vr_ind_arquiv   utl_file.file_type; --> declarando handle do arquivo
  vr_dsheader     VARCHAR2(2000);                                    --> HEADER  do arquivo
  vr_dsdetarq     VARCHAR2(2000)  := 0;                              --> DETALHE do arquivo
  vr_dstraile     VARCHAR2(2000);                                    --> TRAILER do arquivo
  
  --------------------------- ROTINAS INTERNAS ----------------------------
  -- Função troca mes de dois digitos por uma letra
  FUNCTION fn_letra_mes(pr_nrodomes IN NUMBER) RETURN VARCHAR2 IS
  BEGIN    
    CASE pr_nrodomes
      WHEN 10 THEN RETURN 'O';
      WHEN 11 THEN RETURN 'N';
      WHEN 12 THEN RETURN 'D';
      ELSE RETURN TO_CHAR(pr_nrodomes);
    END CASE;         
  END fn_letra_mes;

  -- Retorna nome do arquivo conforme regras ou null haja erro 
  FUNCTION fn_monta_nome_arq(pr_cdagectl IN crapcop.cdagectl%TYPE,
                             pr_dtmvtolt IN DATE    ) RETURN VARCHAR2 IS                                
  BEGIN
    -- Regra para montagem do nome do arquivo 
    RETURN   '3' 
          || LPAD(TO_CHAR(pr_cdagectl),4,'0') 
          || fn_letra_mes(to_char(pr_dtmvtolt,'MM'))
          || to_char(pr_dtmvtolt,'dd')
          || '.DVS';
  END fn_monta_nome_arq;
  
BEGIN -- Principal
  
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);

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
  END IF;

  -- Apenas fechar o cursor
  CLOSE cr_crapcop;

  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Guarda a data
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;
  END IF;

  -- Fechar o cursor
  CLOSE btch0001.cr_crapdat;

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);

  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- buscar caminho de arquivos
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M', pr_cdcooper => pr_cdcooper, pr_nmsubdir => 'abbc');
  vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper, pr_nmsubdir => 'arq');
  vr_dssalvar := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper, pr_nmsubdir => 'salvar');
  
  -- Selecionar todos os registros de Devoluções de DOC
  FOR rw_crapddc IN cr_crapddc(pr_dtmvtoan => vr_dtmvtoan) LOOP
    -- Para o primeiro registro agrupado da agência
    IF rw_crapddc.seqlauto = 1 THEN
      -- Montar o nome do arquivo 
      IF pr_cdcooper = 3 THEN
        -- Usar agência da Central
        vr_nmarquiv := fn_monta_nome_arq(pr_cdagectl => rw_crapcop.cdagectl
                                        ,pr_dtmvtolt => vr_dtmvtolt);
      ELSE
        -- Usar a agência da tabela (gerada no processamento do arquivo DOC  
        vr_nmarquiv := fn_monta_nome_arq(pr_cdagectl => rw_crapddc.cdagenci
                                        ,pr_dtmvtolt => vr_dtmvtolt);
      END IF;
                                        
      -- criar handle de arquivo 
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsarquiv        --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv        --> Nome do arquivo
                              ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                              ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);      --> erro
      -- em caso de crítica
      IF vr_dscritic IS NOT NULL THEN
        -- levantar excecao
        RAISE vr_exc_saida;
      END IF;
      -- Zerar controladores
      vr_seqarqui := 0;
      vr_qtdregis := 0;
      vr_vldocmto := 0;
      vr_vltotreg := 0;  
      
      -- Incrementar contador de linhas   
      vr_seqarqui := vr_seqarqui + 1;
      
      -- monta HEADER do arquivo
      vr_dsheader := LPAD('0',20,'0')                     || 
                     'DCR605'                             ||
                     LPAD(TO_CHAR(rw_crapcop.cdbcoctl),3,'0')  ||
                     TO_CHAR(rw_crapcop.nrdivctl)         ||
                     TO_CHAR(vr_dtmvtolt,'RRRRMMDD')      ||
                     '018'                                ||
                     '2'                                  || -- Troca=1 Devolucao=2 
                     '000'                                ||
                     '0001'                               ||
                     TO_CHAR(vr_dtmvtolt,'RRRRMMDD')      ||
                     TO_CHAR(SYSDATE,'HHMM')              ||
                     LPAD(' ',8,' ')                      || -- Filler x(8)
                     ' '                                  ||
                     LPAD(' ',177,' ')                    || 
                     LPAD(TO_CHAR(nvl(vr_seqarqui,0)),8,'0');
                       
      -- escrever HEADER do arquivo
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsheader);
      
    END IF;

    -- Criacao registro gncpddc
    BEGIN      
      INSERT INTO gncpddc(nrdocmto,
                          dtmvtolt,
                          vldocmto,
                          cdtipreg,
                          cdcooper,
                          cdagenci,
                          nrdconta,
                          nmfavore,
                          nrcpffav,
                          cdcritic,
                          cdbandoc,
                          cdagedoc,
                          nrctadoc,
                          nmemiten,
                          nrcpfemi,
                          cdmotdev,
                          cdoperad,
                          dtliquid,
                          nmarquiv,
                          hrtransa,
                          flgconci,
                          flgpcctl,
                          dslayout,
                          cdcmpori)
                  VALUES (rw_crapddc.nrdocmto,
                          rw_crapddc.dtmvtolt,
                          rw_crapddc.vldocmto,
                          3,
                          rw_crapddc.cdcooper,
                          rw_crapddc.cdagenci,
                          rw_crapddc.nrdconta,
                          rw_crapddc.nmfavore,
                          rw_crapddc.nrcpffav,
                          rw_crapddc.cdcritic,
                          rw_crapddc.cdbandoc,
                          rw_crapddc.cdagedoc,
                          rw_crapddc.nrctadoc,
                          rw_crapddc.nmemiten,
                          rw_crapddc.nrcpfemi,
                          rw_crapddc.cdmotdev,
                          rw_crapddc.cdoperad,
                          rw_crapddc.dtmvtolt,
                          vr_nmarquiv,
                          gene0002.fn_busca_time(),
                          1, --flgdevol -- Devolvido
                          1, --flgpcctl -- Processado na Central
                          rw_crapddc.dslayout,
                          rw_crapddc.cdcmpori);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir gncpddc: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    -- Copiar registro de DETALHE para efetuar alguns ajustes anter do envio
    vr_dsdetarq := rw_crapddc.dslayout; 
    
    -- Incrementar contador de linhas   
    vr_seqarqui := vr_seqarqui + 1;
    
    vr_dsdetarq := SUBSTR(vr_dsdetarq,1,247) || LPAD(TO_CHAR(vr_seqarqui),8,'0');
    
    -- Incrementar total    
    vr_vltotreg := vr_vltotreg + TO_NUMBER(nvl(TRIM(SUBSTR(vr_dsdetarq,31,18)),0));
    
    -- Escrever DETALHE do arquivo
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsdetarq);    
    
    -- Incrementar contador de registros e de linhas
    vr_qtdregis := vr_qtdregis + 1;
    
    -- Para o ultimo registro da agência
    IF rw_crapddc.seqlast = rw_crapddc.seqlauto THEN
      
      -- Incrementar contador de linhas   
      vr_seqarqui := vr_seqarqui + 1;
     
      -- Montar o TRAILER
      vr_dstraile := LPAD('9',20,'9')                     ||
                     'DCR605'                             ||
                     LPAD(TO_CHAR(nvl(rw_crapcop.cdbcoctl,0)),3,'0')  ||
                     TO_CHAR(rw_crapcop.nrdivctl)         ||
                     TO_CHAR(vr_dtmvtolt,'RRRRMMDD')      ||
                     '018'                                ||
                     '2'                                  ||  -- Troca=1 Devolucao=2 
                     '000'                                ||
                     '0001'                               ||
                     TO_CHAR(vr_dtmvtolt,'RRRRMMDD')      ||
                     TO_CHAR(SYSDATE,'HHMM')              ||
                     LPAD(' ',8,' ')                      ||  -- Filler x(8)
                     ' '                                  ||
                     LPAD(TO_CHAR(nvl(vr_qtdregis,0)),8,'0')  ||  -- Qtd de registros 9(8)
                     LPAD(TO_CHAR(nvl(vr_vltotreg,0)),18,'0') ||  -- Valor tot registros 9(18)
                     LPAD(' ',151,' ')                    ||
                     LPAD(TO_CHAR(nvl(vr_seqarqui,0)),8,'0'); -- Seq de arquivo 9(8)
                     
      -- Escrever TRAILER do arquivo
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dstraile);
      
      -- Fechar o arquivo aberto
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> handle do arquivo aberto;  

      -- Converte o relatorio para um arquivo temporario para o formato DOS 
      gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_dsarquiv ||'/'||vr_nmarquiv||' > '||vr_dsdireto||'/'||vr_nmarquiv  -- ||' 2> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);
       
      -- Se retornar algum erro
      IF NVL(vr_typ_saida, 'OK') = 'ERR' THEN
        -- Escreve log de erro, mas continua com o processo
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || 'Comando ux2dos retornou erro: '||vr_typ_saida||' - '||vr_des_saida);
      END IF;
       
      -- Mover o arquivo do diretorio arq para o salvar
      gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_dsarquiv ||'/'||vr_nmarquiv||' '||vr_dssalvar||'/'||vr_nmarquiv||'_'||gene0002.fn_busca_time||' 2> /dev/null');
                     
    END IF;                  
    
  END LOOP;

  -- Atualizar todos os crapddc - Devoluções DOC como Processados na Central
  BEGIN
    UPDATE crapddc 
       SET crapddc.flgpcctl = 1                      --> Processado na Central
          ,crapddc.dtgerarq = vr_dtmvtolt            --> Data do processo
          ,crapddc.hrgerarq = GENE0002.fn_busca_time --> Hora(sssss) de processo
      WHERE crapddc.cdcooper = pr_cdcooper
        AND crapddc.dtmvtolt = vr_dtmvtoan; 
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar crapddc: '||SQLERRM;
      RAISE vr_exc_saida;
  END;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic );
    END IF;

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;  
END pc_crps680;
/
