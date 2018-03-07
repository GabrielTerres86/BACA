CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS689(pr_cdcooper  IN craptab.cdcooper%TYPE --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Crítica encontrada
                                      ,pr_dscritic OUT VARCHAR2)  IS         --> Texto de erro/critica encontrada

  /* ...........................................................................

     Programa: PC_CRPS689
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2014                     Ultima atualizacao: 04/07/2017

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Importar arquivos REM para pagamento de titulos em lote
                 Solicitacao : XXX
                 Ordem do programa na solicitacao = XXX
                 Paralelo

     Observacoes:

     Alteracoes: 04/07/2017 - Incluida busca por arquivos com extensao TXT 
	                          gerados pelo sistema MATERA (Diego).
  ............................................................................. */
  --
  procedure pc_grava_log_pgt(pr_cdcooper  cecred.tbcobran_hpt_log.cdcooper%type
                            ,pr_nrdconta  cecred.tbcobran_hpt_log.nrdconta%type
                            ,pr_nrconven  cecred.tbcobran_hpt_log.nrconven%type
                            ,pr_nrremret  cecred.tbcobran_hpt_log.nrremret%type
                            ,pr_nmarquivo cecred.tbcobran_hpt_log.nmarquivo%type
                            ,pr_dsmsglog  cecred.tbcobran_hpt_log.dsmsglog%type) is
    --
    pragma autonomous_transaction;
    --
  begin
    --
    begin
      --
      insert into cecred.tbcobran_hpt_log
        (cdcooper
        ,nrdconta
        ,nrconven
        ,tpmovimento
        ,nrremret
        ,dhgerlog
        ,cdoperad
        ,nmoperad_online
        ,cdprograma
        ,nmtabela
        ,nmarquivo
        ,dsmsglog)
      values
        (pr_cdcooper
        ,pr_nrdconta
        ,pr_nrconven
        ,1 /*remessa*/ --tpmovimento
        ,pr_nrremret
        ,sysdate --dhgerlog
        ,1 --cdoperad
        ,null --nmoperad_online
        ,'CRPS689' --cdprograma
        ,'CRAPHPT' --nmtabela
        ,pr_nmarquivo
        ,trim(substr(trim(pr_dsmsglog),1,4000)));
      --
      commit;
    exception
      when others then
        cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'CRPS689.PC_GRAVA_LOG');
        commit;
    end;
    --
  end pc_grava_log_pgt;
  --
  procedure pc_busca_arquivo_ftp(pr_cdcooper crapcop.cdcooper%type
                                ,pr_nrdconta crapcpt.nrdconta%type
                                ,pr_dsdircop crapcop.dsdircop%type
                                ,pr_caminho_cooper varchar2
                                ,pr_caminho_arq varchar2
                                ,pr_serv_ftp varchar2
                                ,pr_user_ftp varchar2
                                ,pr_pass_ftp varchar2
                                ,pr_script_ftp varchar2) is
    --
    vr_caminho_conta varchar2(200) := null;
    vr_comando_ftp   varchar2(500) := null;
    vr_typ_saida     varchar2(3);
    vr_cdcritic      crapcri.cdcritic%type;
    vr_dscritic      varchar2(4000):= null;
    --
  begin
    --
    vr_caminho_conta := pr_dsdircop||'/'||trim(to_char(pr_nrdconta))||'/REMESSA';
    --
    vr_comando_ftp := pr_script_ftp
                    ||' -recebe'
                    ||' -srv '||pr_serv_ftp
                    ||' -usr '||pr_user_ftp
                    ||' -arq ''PGT*'||trim(to_char(pr_nrdconta))||'*.REM'''
                    ||' -pass '||pr_pass_ftp
                    ||' -dir_local '''||pr_caminho_arq|| '''' -- /usr/coop/<cooperativa>/upload
                    ||' -dir_remoto '''||vr_caminho_conta|| '''' -- <cooperativa>/<conta do cooperado>/REMESSA 
                    ||' -move_remoto ''/'||vr_caminho_conta||'/PROC''' -- <cooperativa>/<conta do cooperado>/REMESSA/PROC 
                    ||' -log '||pr_caminho_cooper||'/log/pgto_por_arquivo.log' -- /usr/coop/<cooperativa>/log/cbr_por_arquivo.log
                    ||' -UC';
    --
    -- Chama procedure de envio e recebimento via ftp
    gene0001.pc_oscommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando_ftp
                         ,pr_flg_aguard  => 'S'
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    --
    -- Se ocorreu erro gerar log
    if vr_typ_saida = 'ERR' then
      --
      pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nmarquiv => 'CRPS689->COMANDO FTP'
                                    ,pr_textolog => 'Comando unix:('||vr_comando_ftp||')-Erro:'||vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      --
    end if;
    --
  exception
    when others then
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => 'CRPS689.PC_BUSCA_ARQUIVO_FTP');
      vr_dscritic := sqlerrm;
      pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nmarquiv => 'CRPS689.PC_BUSCA_ARQUIVO_FTP'
                                    ,pr_textolog => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
  end pc_busca_arquivo_ftp;
  --
  procedure pc_trata_arquivo_ftp(pr_cdcooper crapcop.cdcooper%type
                                ,pr_nrdconta crapcpt.nrdconta%type
                                ,pr_nrconven crapcpt.nrconven%type
                                ,pr_caminho_cooper varchar2
                                ,pr_caminho_arq varchar2) is
    --
    vr_listadir    varchar2(4000) := null;
    vr_cdcritic    crapcri.cdcritic%type;
    vr_dscritic    varchar2(4000) := null;
    vr_tab_arquivo gene0002.typ_split := gene0002.typ_split();
    vr_nrremret    craphpt.nrremret%type;
    vr_dscomand    varchar2(500) := null;
    vr_nmarquiv    craphpt.nmarquiv%type;
    vr_typ_saida   varchar2(3);
    --
  begin
    --
    --Listar arquivos recebidos por ftp
    gene0001.pc_lista_arquivos(pr_path     => pr_caminho_arq
                              ,pr_pesq     => 'PGT%'||trim(to_char(pr_nrdconta))||'%.REM'
                              ,pr_listarq  => vr_listadir
                              ,pr_des_erro => vr_dscritic);
    --
    -- se ocorrer erro ao recuperar lista de arquivos registra no log
    if trim(vr_dscritic) is not null then			
      pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nmarquiv => 'CRPS689->LISTA ARQUIVOS'
                                    ,pr_textolog => trim(vr_dscritic)
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
    end if;
    --
    --se existem arquivos para serem tratados
    if trim(vr_listadir) is not null then
      --
      --Carregar a lista de arquivos na temp table
      vr_tab_arquivo.delete;
      vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listadir);
      --
      -- Se retornou informacoes na temp table
      if vr_tab_arquivo.count() > 0 then
        --
        --percorre os arquivos
        for vr_ind in vr_tab_arquivo.first .. vr_tab_arquivo.last
        loop
          --
          vr_nmarquiv := vr_tab_arquivo(vr_ind);
          --
          --
          begin
            --
            vr_nrremret := to_number(substr(vr_tab_arquivo(vr_ind),15,6));
            --
          exception
            when others then
            begin
              --
              vr_nrremret := to_number(substr(vr_tab_arquivo(vr_ind),14,6));
              --
            exception
              when others then
                vr_nrremret := 0;
            end;
          end;
          --
          pc_grava_log_pgt(pr_cdcooper  => pr_cdcooper
                          ,pr_nrdconta  => pr_nrdconta
                          ,pr_nrconven  => pr_nrconven
                          ,pr_nrremret  => vr_nrremret
                          ,pr_nmarquivo => vr_nmarquiv
                          ,pr_dsmsglog  => 'Recebimento do arquivo por FTP (Etapa 1 de 3)');
          --
          -- alterar permissao do arquivo
          gene0001.pc_oscommand_shell(pr_des_comando => 'chmod 666 '||pr_caminho_arq||'/'||vr_tab_arquivo(vr_ind));
          --
          vr_nmarquiv := trim(to_char(pr_cdcooper,'000'))
                  ||'.'||trim(to_char(pr_nrdconta))
                  ||'.'||vr_nmarquiv;
          --
          -- Move o Arquivo para o diretório upload e renomeia para o padrão coop.conta.arq
          vr_dscomand := 'mv -f '||pr_caminho_arq
                            ||'/'||vr_tab_arquivo(vr_ind)
                            ||' '||pr_caminho_cooper
                            ||'/upload/'||vr_nmarquiv;
          -- Executa comando
          gene0001.pc_oscommand_shell(pr_des_comando => vr_dscomand
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
          --
          --Verificar retorno de erro
          if nvl(vr_typ_saida,' ') = 'ERR' then
            --
            pc_grava_log_pgt(pr_cdcooper  => pr_cdcooper
                            ,pr_nrdconta  => pr_nrdconta
                            ,pr_nrconven  => pr_nrconven
                            ,pr_nrremret  => vr_nrremret
                            ,pr_nmarquivo => vr_nmarquiv
                            ,pr_dsmsglog  => 'Arquivo não recebido. Erro:'||vr_dscritic);
            --
            pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nmarquiv => 'CRPS689->RENOMEIA ARQUIVO'
                                          ,pr_textolog => trim(vr_dscritic)
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
            --
          else
            --
            pc_grava_log_pgt(pr_cdcooper  => pr_cdcooper
                            ,pr_nrdconta  => pr_nrdconta
                            ,pr_nrconven  => pr_nrconven
                            ,pr_nrremret  => vr_nrremret
                            ,pr_nmarquivo => vr_nmarquiv
                            ,pr_dsmsglog  => 'Arquivo renomeado (Etapa 2 de 3)');
            --
          end if;
          --
        end loop; /*vr_tab_arquivo*/
        --
        --limpar tabela de memória tratamento dos arquivos
        vr_tab_arquivo.delete;
        --
      end if;
      --
    end if;
    --
  exception
    when others then
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => 'CRPS689.PC_TRATA_ARQUIVO_FTP');
      vr_dscritic := sqlerrm;
      pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nmarquiv => 'CRPS689.PC_TRATA_ARQUIVO_FTP'
                                    ,pr_textolog => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
  end pc_trata_arquivo_ftp;
  --
  procedure pc_recebe_ftp(pr_cdcooper crapcop.cdcooper%type
                         ,pr_dsdircop crapcop.dsdircop%type
                         ,pr_serv_ftp varchar2
                         ,pr_user_ftp varchar2
                         ,pr_pass_ftp varchar2
                         ,pr_script_ftp varchar2) is
    --
    vr_caminho_cooper varchar2(200) := null;
    vr_caminho_arq    varchar2(200) := null;
    vr_cdcritic       crapcri.cdcritic%type;
    vr_dscritic       varchar2(4000):= null;
    vr_nrdconta       crapcpt.nrdconta%type;
    --
  begin
    --
    for r_cpt in (
                  select cpt.nrdconta
                        ,cpt.nrconven
                  from crapcpt cpt
                  where cpt.cdcooper = pr_cdcooper
                    and cpt.flgativo = 1 /*ativo*/
                    and cpt.flghomol = 1 /*homologado*/
                    and cpt.idretorn = 2 /*ftp*/
                  order by
                         cpt.nrdconta
                        ,cpt.nrconven
                 )
    loop
      --
      --carrega variáveis no primeiro laço do loop e somente se houver registros a serem processados
      if vr_caminho_cooper is null then
        --
        -- Busca o diretorio da cooperativa
        vr_caminho_cooper := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsubdir => '');
                                                 
        -- Setando os diretorios auxiliares
        vr_caminho_arq := vr_caminho_cooper||'/upload/ftp';
        --
      end if;
      --
      vr_nrdconta := r_cpt.nrdconta;
      --
      pc_busca_arquivo_ftp(pr_cdcooper       => pr_cdcooper
                          ,pr_nrdconta       => vr_nrdconta
                          ,pr_dsdircop       => pr_dsdircop
                          ,pr_caminho_cooper => vr_caminho_cooper
                          ,pr_caminho_arq    => vr_caminho_arq
                          ,pr_serv_ftp       => pr_serv_ftp
                          ,pr_user_ftp       => pr_user_ftp
                          ,pr_pass_ftp       => pr_pass_ftp
                          ,pr_script_ftp     => pr_script_ftp);
      --
      pc_trata_arquivo_ftp(pr_cdcooper       => pr_cdcooper
                          ,pr_nrdconta       => vr_nrdconta
                          ,pr_nrconven       => r_cpt.nrconven 
                          ,pr_caminho_cooper => vr_caminho_cooper
                          ,pr_caminho_arq    => vr_caminho_arq);
      --
    end loop; /*r_cpt*/
    --
  exception
    when others then
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => 'CRPS689.PC_RECEBE_FTP');
      vr_dscritic := sqlerrm;
      pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => vr_nrdconta
                                    ,pr_nmarquiv => 'CRPS689.PC_RECEBE_FTP'
                                    ,pr_textolog => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
  end pc_recebe_ftp;
  --
begin
  --
  declare
    -- CURSORES
    -- Buscar informações da cooperativa
    CURSOR cr_crapcop(p_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
           , crapcop.dsdircop
           , crapcop.nmrescop
           , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
           , crapcop.cdagectl
        FROM crapcop
       WHERE crapcop.cdcooper = p_cdcooper;

    -- Buscar informações da cooperativa
    CURSOR cr_todas_coop IS
      SELECT crapcop.cdcooper
           , crapcop.dsdircop
           , crapcop.nmrescop
           , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
           , crapcop.cdagectl
        FROM crapcop
       WHERE crapcop.flgativo = 1
         AND crapcop.cdcooper <> 3
       ORDER BY crapcop.cdcooper;

    -- Busca a data do movimento
    CURSOR cr_crapdat(p_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapdat.dtmvtolt
        FROM crapdat crapdat
       WHERE crapdat.cdcooper = p_cdcooper;

    -- REGISTROS
    rw_crapcop          cr_crapcop%ROWTYPE;
    rw_crapdat          cr_crapdat%ROWTYPE;

    -- TIPOS
    -- Tabela de memória para ordenar os arquivos
    TYPE typ_sortarq IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);

    -- VARIÁVEIS
    -- Código do programa
    vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS689';
    -- Retorno de Remessa
    vr_nrremess      craphpt.nrremret%TYPE;
    vr_nrremret      craphpt.nrremret%TYPE;
    -- Lista de arquivos
    vr_array_arquivo gene0002.typ_split;
    vr_sort_arquivos typ_sortarq;
    vr_list_arquivos VARCHAR2(10000);
    vr_list_arquivos_matera VARCHAR2(10000);
    vr_list_arquivos_SOA    VARCHAR2(10000);
    -- Variável para formar chaves para collections
    vr_dschave       VARCHAR2(100);
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_typ_said      VARCHAR2(50);
    vr_des_erro      VARCHAR2(500);
    -- Diretório das cooperativas
    vr_dsdireto      VARCHAR2(200);
    vr_dsdirsoa      VARCHAR2(200);
    -- Mascara para busca de arquivos
    vr_dsmascar        VARCHAR2(200);
    -- Numero da conta conforme o arq
    vr_nrdconta      crapass.nrdconta%TYPE;
    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_exc_fimprg    EXCEPTION;
    vr_exc_proxcoop  EXCEPTION;
    -- variáveis de paramatros ftp
    vr_serv_ftp     VARCHAR2(100);
    vr_user_ftp     VARCHAR2(100);
    vr_pass_ftp     VARCHAR2(100);
    vr_script_ftp   VARCHAR2(200);

  BEGIN

    /********** TRATAMENTOS INICIAIS **********/
    -- Incluir nome do modulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS689',
                               pr_action => vr_cdprogra);

    -- Verifica se a cooperativa esta cadastrada
    OPEN  cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          vr_dscritic := NULL;
          RAISE vr_exc_saida;
       END IF;
    CLOSE cr_crapcop;

    -- Busca a data do movimento
    OPEN cr_crapdat(pr_cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;

    -- Buscar as datas do movimento
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
       -- Se não encontrar o registro de movimento
       IF btch0001.cr_crapdat%NOTFOUND THEN
          -- 001 - Sistema sem data de movimento.
          vr_cdcritic := 1;
          vr_dscritic := NULL;
          -- Fechar o cursor pois haverá raise
          CLOSE btch0001.cr_crapdat;
          -- Log de crítica
          RAISE vr_exc_saida;
       END IF;
    CLOSE btch0001.cr_crapdat;

    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 -- Fixo
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se retornou algum erro
    IF vr_cdcritic <> 0 THEN -- Comentar para executar testes
      -- Gerar exceção
      vr_dscritic := NULL;
      -- Log de critica
      RAISE vr_exc_saida;
    END IF;

    /*busca os parametros do FTP - inicio*/
    -- Busca nome do servidor
    vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => '0'
                                            ,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP'); 
    -- Busca nome de usuario                                                
    vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => '0'
                                            ,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');
    -- Busca senha do usuario
    vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => '0'
                                            ,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');																							
    -- Busca caminho do script																				
    vr_script_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');	
    /*busca os parametros do FTP - fim*/

    -- Buscar diretórios de arquivos
    -- Padrão de todas as cooperativas
    FOR rw_crapcop IN cr_todas_coop LOOP

      BEGIN

        pc_recebe_ftp(pr_cdcooper   => rw_crapcop.cdcooper
                     ,pr_dsdircop   => rw_crapcop.dsdircop
                     ,pr_serv_ftp   => vr_serv_ftp
                     ,pr_user_ftp   => vr_user_ftp
                     ,pr_pass_ftp   => vr_pass_ftp
                     ,pr_script_ftp => vr_script_ftp);

        -- inicializar variaveis de critica
        vr_cdcritic := 0;
        vr_dscritic := NULL;
        pr_cdcritic := 0;
        pr_dscritic := NULL;
        
        vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Coop
                                            ,pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_nmsubdir => '/upload');
                                            
        -- Diretorio de upload do barramento SOA
        vr_dsdirsoa := gene0001.fn_diretorio('C',0)                                ||
                       gene0001.fn_param_sistema('CRED',0,'PATH_DOWNLOAD_ARQUIVO') ||
                       '/'                                                         ||
                       rw_crapcop.dsdircop                                         ||
                       '/upload/';                                            
        
        -- Retorna a lista dos arquivos REM do diretório,
        -- conforme padrão "cdcooper.nrdconta.nome.REM" (Ex.: 001.329.arq_upload.REM)
        -- Ex.: --  vr_dsmascar      := '001.3696553.PGT%.REM';
        vr_dsmascar := lpad(rw_crapcop.cdcooper,3,'0') ||'.%.PGT%.REM'; 
        
        vr_list_arquivos := NULL;

        -- Retorna a lista dos arquivos do diretório de upload do barramento SOA
        gene0001.pc_lista_arquivos(pr_path     => vr_dsdirsoa
                                  ,pr_pesq     => vr_dsmascar
                                  ,pr_listarq  => vr_list_arquivos
                                  ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           vr_cdcritic := 0;
           RAISE vr_exc_proxcoop;
        END IF;        
        
        IF vr_list_arquivos IS NOT NULL THEN
           -- Listar os arquivos em um array
           vr_array_arquivo := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos
                                                        ,pr_delimit => ',');
                                                        
           -- Ordenar pelo nome do arquivo
           -- Percorrer todos os arquivos selecionados
           FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP
             -- Move os arquivo Processado para Pasta Salvar
             GENE0001.pc_OScommand_Shell('mv ' || vr_dsdirsoa || vr_array_arquivo(ind) || ' ' || vr_dsdireto || '/'
                                        ,pr_typ_saida => vr_typ_said
                                        ,pr_des_saida => vr_des_erro);
               
             -- Testar erro
             IF vr_typ_said = 'ERR' THEN
               -- Define a mensagem de erro
               vr_dscritic := 'Erro ao mover arquivos recebidos via SOA => '||vr_array_arquivo(ind)||'.'||chr(10)||vr_des_erro;
               -- Envio centralizado de log de erro
               PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_nrdconta => 0
                                             ,pr_nmarquiv => 'PC_CRPS689'
                                             ,pr_textolog => vr_dscritic
                                             ,pr_cdcritic => pr_cdcritic
                                             ,pr_dscritic => pr_dscritic);
             END IF;
           END LOOP;           
        END IF;                          

        vr_list_arquivos := NULL;

        -- Retorna a lista dos arquivos do diretório, conforme padrão *cdcooper*.*.rem
        gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                                  ,pr_pesq     => vr_dsmascar
                                  ,pr_listarq  => vr_list_arquivos
                                  ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           vr_cdcritic := 0;
           RAISE vr_exc_proxcoop;
        END IF;

        -- Busca arquivos gerados no sistema MATERA
        vr_dsmascar := lpad(rw_crapcop.cdcooper,3,'0') ||'.%.PGT%.TXT';

        vr_list_arquivos_matera := NULL;

        gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                                  ,pr_pesq     => vr_dsmascar
                                  ,pr_listarq  => vr_list_arquivos_matera
                                  ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           vr_cdcritic := 0;
           RAISE vr_exc_proxcoop;
        END IF;

        IF   vr_list_arquivos_matera IS NOT NULL  THEN
           IF   vr_list_arquivos IS NOT NULL  THEN
                vr_list_arquivos := vr_list_arquivos ||',' || vr_list_arquivos_matera;
           ELSE
                vr_list_arquivos := vr_list_arquivos_matera;
           END IF;
        END IF;                         
        
        -- Verifica se retornou arquivos
        IF vr_list_arquivos IS NOT NULL THEN
           -- Listar os arquivos em um array
           vr_array_arquivo := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos
                                                        ,pr_delimit => ',');
           -- Ordenar pelo nome do arquivo
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
           vr_dschave := NULL;

        ELSE -- Nao retornou lista de arquivo
           -- Limpa as variáveis para não gerar crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Nao ha arquivos de remessa para serem importados';
            -- Vai para a proxima cooperativa
            RAISE vr_exc_proxcoop;
        END IF;

        -- Percorrer todos os arquivos encontrados na pasta
        FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP
           BEGIN
              -- Verifica o nrdconta que vem no nome do arquivo, salva na variavel
              vr_nrdconta := gene0002.fn_busca_entrada(2,vr_array_arquivo(ind),'.');

              -- Validar o arquivo da lista da Pasta - PGTA0001
              PGTA0001.pc_validar_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper           --> Codigo da cooperativa
                                         ,pr_nrdconta => gene0002.fn_mask(vr_nrdconta,'zzzzzzzzz9')  --> Numero Conta do cooperado
                                         ,pr_nrconven => 1                     --> Numero do Convenio
                                         ,pr_nmarquiv => vr_array_arquivo(ind) --> Nome do Arquivo
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data do Movimento
                                         ,pr_idorigem => 3                     --> Origem (1-Ayllos, 3-Internet, 7-FTP) --Está no Ayllos, mas o arquivo veio pelo Int.Banking
                                         ,pr_cdoperad => '996'                 --> Codigo Operador
                                         ,pr_nrremess => vr_nrremess
                                         ,pr_cdcritic => vr_cdcritic           --> Código do erro
                                         ,pr_dscritic => vr_dscritic);         --> Descricao do erro

              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                 vr_dscritic :=  ' --> PAGTO TIT ARQUIVO[VALIDAR] - Arquivo:'
                                 || vr_array_arquivo(ind) || ': '
                                 || vr_dscritic ;
                 RAISE vr_exc_saida; -- Passa para o proximo arquivo
              END IF;

              -- Processar o arquivo da lista da Pasta - PGTA0001
              PGTA0001.pc_processar_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper   --> Codigo da cooperativa
                                            ,pr_nrdconta => gene0002.fn_mask(vr_nrdconta,'zzzzzzzzz9')  --> Numero Conta do cooperado
                                            ,pr_nrconven => 1                     --> Numero do Convenio
                                            ,pr_nmarquiv => vr_array_arquivo(ind) --> Nome do Arquivo
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data do Movimento
                                            ,pr_idorigem => 3                     --> Origem (1-Ayllos, 3-Internet, 7-FTP) --Está no Ayllos, mas o arquivo veio pelo Int.Banking
                                            ,pr_cdoperad => '996'                 --> Codigo Operador
                                            ,pr_nrremess => vr_nrremess
                                            ,pr_nrremret => vr_nrremret           --> OUT - Nr retorno
                                            ,pr_cdcritic => vr_cdcritic           --> OUT Código do erro
                                            ,pr_dscritic => vr_dscritic);         --> OUT Descricao do erro

              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                 vr_dscritic :=  ' --> PAGTO TIT ARQUIVO[PROCESSAR] - Arquivo:'
                                 || vr_array_arquivo(ind) || ': '
                                 || vr_dscritic;
                 RAISE vr_exc_saida; -- Passa para o proximo arquivo
              END IF;

              COMMIT; -- O COMMIT ficou por Arquivo - Significa que deu sucesso no tratamento.

           EXCEPTION
              WHEN vr_exc_saida THEN
                 -- Envio centralizado de log de erro
                 PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nrdconta => 0
                                               ,pr_nmarquiv => 'PC_CRPS689'
                                               ,pr_textolog => vr_dscritic
                                               ,pr_cdcritic => pr_cdcritic
                                               ,pr_dscritic => pr_dscritic);

                 ROLLBACK; -- DESFAZ o que foi processado no ARQUIVO

                 /****************************************/
                 CONTINUE; -- PULAR PARA O PRÓXIMO ARQUIVO
                 /****************************************/
              WHEN OTHERS THEN
                 -- Define a mensagem de erro
                 vr_dscritic := 'Erro ao ler o arquivo => '||vr_array_arquivo(ind)||'.'||chr(10)||SQLERRM;
                 -- Envio centralizado de log de erro

                 PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nrdconta => 0
                                               ,pr_nmarquiv => 'PC_CRPS689'
                                               ,pr_textolog => vr_dscritic
                                               ,pr_cdcritic => pr_cdcritic
                                               ,pr_dscritic => pr_dscritic);

                 ROLLBACK; -- DESFAZ o que foi processado no ARQUIVO

                 /****************************************/
                 CONTINUE; -- PULAR PARA O PRÓXIMO ARQUIVO
                 /****************************************/
           END;
        END LOOP;

      EXCEPTION
         WHEN vr_exc_proxcoop THEN
            /* continua na proxima cooperativa */
            PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nrdconta => 0
                                          ,pr_nmarquiv => 'PC_CRPS689'
                                          ,pr_textolog => vr_dscritic
                                          ,pr_cdcritic => pr_cdcritic
                                          ,pr_dscritic => pr_dscritic);

            /********************************************/
            CONTINUE; -- PULAR PARA A PRÓXIMA COOPERATIVA
            /********************************************/

         WHEN OTHERS THEN
            RAISE vr_exc_fimprg;
      END;

    END LOOP;
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
  exception
     WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descrição
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
           -- Envio centralizado de log de erro
           PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_nrdconta => 0
                                         ,pr_nmarquiv => 'PC_CRPS689'
                                         ,pr_textolog => vr_dscritic
                                         ,pr_cdcritic => pr_cdcritic
                                         ,pr_dscritic => pr_dscritic);

           IF vr_dscritic IS NOT NULL THEN
              -- Gerar excecao
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           END IF;
           -- Devolvemos código e critica encontradas
           pr_cdcritic := NVL(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
     WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descrição
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure PC_CRPS689. Erro: '||SQLERRM;
        -- Envio centralizado de log de erro
        PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_nrdconta => 0
                                      ,pr_nmarquiv => 'PC_CRPS689'
                                      ,pr_textolog => pr_dscritic
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic);

    --
  end;
  --
END PC_CRPS689;
/
