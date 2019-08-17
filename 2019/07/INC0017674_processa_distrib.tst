PL/SQL Developer Test script 3.0
642
-- Created on 28/06/2019 by F0030250 
declare 
  -- Local variables here
  i integer;
  vr_exc_erro    EXCEPTION;
  vr_handle_log  utl_file.file_type;
  vr_handle_log2 utl_file.file_type;
  rw_crapdat     btch0001.cr_crapdat%rowtype;
  vr_des_erro    varchar2(2000);
  vr_des_log      varchar2(2000);
  vr_nm_arquivo  varchar2(2000);
  vr_nm_arqlog   varchar2(2000);
  vr_nm_arqlog_proc   varchar2(2000);
  vr_nm_direto    varchar2(2000);
  vr_linha_arq    varchar2(110);
  vr_inicio      boolean := true;
  vr_gerou_log    boolean := false;
  vr_flgjudic    number;
  vr_flextjud    number;
  vr_flgehvip    number;
  vr_cdcooper    number;
  vr_cdorigem    number;
  vr_nrdconta    number;
  vr_cdctremp    number;
  vr_cdassess    varchar2(8);
  vr_dtdistri    DATE;
  vr_nrlinha     number;
  vr_cdassessx   varchar2(8);
  vr_existecyc   number(1) := 0;

  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CYBE0001';
  --Variaveis Locais
  vr_nmtmpzip VARCHAR2(200);
  vr_idx_txt  INTEGER;
  vr_cdcritic number;

  vr_dscritic varchar2(100);
  --vr_nmtmptxt VARCHAR2(200);
  vr_nmarqzip VARCHAR2(200);
  vr_typ_saida VARCHAR2(10);
  vr_comando   VARCHAR2(4000);
  vr_listadir  VARCHAR2(4000);
  vr_endarqtxt VARCHAR2(4000);
  vr_nmtmparq  varchar2(200);
  vr_dtarquiv  date;
  vr_input_file  utl_file.file_type;
  vr_nrindice INTEGER;
  vr_bkpndice integer;
  vr_contarqv integer;
  
  vr_dtmvtolt_aux crapdat.dtmvtolt%TYPE := to_date('11/05/2019', 'dd/mm/RRRR');
  
  TYPE typ_tab_arqzip   IS VARRAY(100) OF VARCHAR2(200);
  
  vr_tab_arqzip_sort typ_tab_arqzip := typ_tab_arqzip();

  --Tabela para armazenar arquivos lidos
  vr_tab_arqzip gene0002.typ_split;
  vr_tab_arqtxt gene0002.typ_split;
     
  cursor c_busca_crapcyc(pr_cdcooper number
                   ,pr_nrdconta number
                   ,pr_nrctremp number
                   ,pr_cdorigem number) is
       select flgjudic
       ,      flgehvip
       from   crapcyc
       where  cdcooper = pr_cdcooper
       and    cdorigem = decode(pr_cdorigem,2,3,pr_cdorigem)
       and    nrdconta = pr_nrdconta
       and    nrctremp = pr_nrctremp;                 
      
  cursor c_busca_assessoria(pr_cdassessoria varchar2) is
   select t.dstexprm
     from   crapprm t
     where  NMSISTEM = 'CRED'
       and  CDACESSO like 'CYBER_CD_SIGLA%'
       and  t.dsvlrprm = rtrim(pr_cdassessoria);
               
  pr_dtmvto crapdat.dtmvtolt%TYPE := trunc(SYSDATE);
  
  pr_des_reto VARCHAR2(1000) := NULL;
  pr_des_erro VARCHAR2(2000) := NULL;
  
begin
  -- Test statements here
  BEGIN
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
               FETCH btch0001.cr_crapdat INTO rw_crapdat;
               CLOSE btch0001.cr_crapdat;

    vr_nm_arquivo := to_char(pr_dtmvto, 'YYYYMMDD_HH24MISS') || '_contratos_distrib_out.txt';
    vr_nm_arqlog  := 'LOG_' || to_char(pr_dtmvto, 'YYYYMMDD_HH24MISS') || '_contratos_distrib.txt';
    
    vr_nm_arqlog_proc := 'LOG_PROC_DISTRIB_INC0017674.txt';

    vr_nm_direto  := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => '/cyber/recebe/');
    vr_nm_arquivo := vr_nm_direto || '/' || vr_nm_arquivo;
    vr_nm_arqlog  := vr_nm_direto || '/' || vr_nm_arqlog;
    vr_nm_arqlog_proc := vr_nm_direto || '/' || vr_nm_arqlog_proc;
    
    /* Abrir o arquivo de LOG */
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog_proc
                              ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_handle_log2     --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);

      if vr_des_erro is not null then
         vr_des_erro := 'Erro LOG: ' || vr_des_erro;
         raise vr_exc_erro;
      end if;
    --==================================================================================
    -- TRATAR ARQUIVO ZIP
    --==================================================================================
    vr_nmtmpzip:= '%contratos_distrib_out.zip';

    /* Vamos ler todos os arquivos .zip */
    gene0001.pc_lista_arquivos(pr_path     => vr_nm_direto
                             ,pr_pesq     => vr_nmtmpzip
                             ,pr_listarq  => vr_listadir
                             ,pr_des_erro => vr_des_erro);

    -- se ocorrer erro ao recuperar lista de arquivos registra no log
    IF trim(vr_des_erro) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_des_erro);
    END IF;

    --Carregar a lista de arquivos na temp table
    vr_tab_arqzip:= gene0002.fn_quebra_string(pr_string => vr_listadir);

    --Filtrar os arquivos da lista
    IF vr_tab_arqzip.count > 0 THEN
      vr_nrindice:= vr_tab_arqzip.first;
      -- carrega informacoes na cratqrq
      WHILE vr_nrindice IS NOT NULL LOOP
       --Filtrar a data apartir do Nome arquivo
       vr_nmtmparq:= SUBSTR(vr_tab_arqzip(vr_nrindice),1,8);
       --Transformar em Data
       vr_dtarquiv:= TO_DATE(vr_nmtmparq,'YYYYMMDD');
       
       IF vr_dtarquiv > to_date('10/05/2019', 'dd/mm/RRRR') AND vr_dtarquiv < rw_crapdat.dtmvtopr THEN
         --Incrementar quantidade arquivos
         vr_contarqv:= vr_tab_arqzip.count + 1;
         --Proximo Registro
         vr_nrindice:= vr_tab_arqzip.next(vr_nrindice);
       ELSE
         --Diminuir quantidade arquivos
         vr_contarqv:= vr_tab_arqzip.count - 1;
         --Salvar Proximo Registro
         vr_bkpndice:= vr_tab_arqzip.next(vr_nrindice);
         --Retirar o arquivo da lista
         vr_tab_arqzip.DELETE(vr_nrindice);
         --Setar o proximo (backup) no indice
         vr_nrindice:= vr_bkpndice;
       END IF;
      END LOOP;
    END IF;
    
    i := 0;
    
    -- ordena a lista
    WHILE vr_dtmvtolt_aux <= rw_crapdat.dtmvtolt LOOP
    
      vr_nrindice := vr_tab_arqzip.first;
      
      WHILE vr_nrindice IS NOT NULL LOOP
        
        /* tratamento por causa da feira de oportunidade que aconteceu - 2 distrib de 16/07 para processar */
        IF vr_dtmvtolt_aux = to_date('16/07/2019', 'dd/mm/RRRR') THEN
          i := i + 1;
          vr_tab_arqzip_sort.extend;
          vr_tab_arqzip_sort(i) := '20190716_012503_contratos_distrib_out.zip';
          
          i := i + 1;
          vr_tab_arqzip_sort.extend;
          vr_tab_arqzip_sort(i) := '20190716_094927_contratos_distrib_out.zip';
          
          EXIT;
        END IF;
        
        IF to_date(SUBSTR(vr_tab_arqzip(vr_nrindice),1,8), 'YYYYMMDD') = vr_dtmvtolt_aux THEN
          i := i + 1;
          vr_tab_arqzip_sort.extend;
          vr_tab_arqzip_sort(i) := vr_tab_arqzip(vr_nrindice);
          
          EXIT;
        ELSE
          --Proximo Registro
          vr_nrindice:= vr_tab_arqzip.next(vr_nrindice);
        END IF;
      END LOOP;
      vr_dtmvtolt_aux := vr_dtmvtolt_aux + 1;
    END LOOP;
    
    /* ----- fim ordena lista ----- */

    -- Buscar Primeiro arquivo da temp table
    vr_nrindice:= vr_tab_arqzip_sort.FIRST;
    --Processar os arquivos lidos
    WHILE vr_nrindice IS NOT NULL LOOP
      --Nome Arquivo zip
      vr_nmarqzip:= vr_tab_arqzip_sort(vr_nrindice);

      --Nome do arquivo sem extensao
      vr_nmtmparq:= SUBSTR(vr_nmarqzip,1,LENGTH(vr_nmarqzip)-4);

      /* Montar Comando para eliminar arquivos do diretorio */
      vr_comando:= 'rm '||vr_nm_direto ||'/'||vr_nmtmparq||'/*.txt 1> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_comando
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_des_erro);

      /* Remover o diretorio caso exista */
      vr_comando:= 'rmdir '||vr_nm_direto||'/'||vr_nmtmparq||' 1> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_comando
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_des_erro);

      /*  Executar Extracao do arquivo zip */
      vr_comando:= 'unzip '||vr_nm_direto||'/'||vr_nmarqzip ||' -d ' || vr_nm_direto||'/'||vr_nmtmparq;

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_comando
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_des_erro);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
       vr_des_erro := 'Nao foi possivel executar comando unix. '||vr_comando||' - '||vr_des_erro;
       RAISE vr_exc_erro;
      END IF;

      /* Lista todos os arquivos .txt do diretorio criado */
      vr_endarqtxt:= vr_nm_direto||'/'||vr_nmtmparq;

      --Buscar todos os arquivos extraidos na nova pasta
      gene0001.pc_lista_arquivos(pr_path     => vr_endarqtxt
                               ,pr_pesq     => '%contratos_distrib_out.txt'
                               ,pr_listarq  => vr_listadir
                               ,pr_des_erro => vr_dscritic);

      -- se ocorrer erro ao recuperar lista de arquivos registra no log
      IF trim(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic);
      END IF;

      --Carregar a lista de arquivos na temp table
      vr_tab_arqtxt:= gene0002.fn_quebra_string(pr_string => vr_listadir);

      --Se possuir arquivos no diretorio
      IF vr_tab_arqtxt.COUNT > 0 THEN

       --Selecionar primeiro arquivo
       vr_idx_txt:= vr_tab_arqtxt.FIRST;
       --Percorrer todos os arquivos lidos
       WHILE vr_idx_txt IS NOT NULL LOOP

         --Nome do arquivo
         vr_nm_arquivo := vr_tab_arqtxt(vr_idx_txt);
         --Montar Mensagem para log
         vr_cdcritic:= 219;
         --Buscar mensagem
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Imprimir mensagem no log
         btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic || ' --> '||vr_nm_arquivo);
         vr_idx_txt:= vr_tab_arqtxt.NEXT(vr_idx_txt);
       end loop;

      end if;
      -- modifica nome do arquivo zip para "processado".
       vr_comando:= 'mv '||vr_nm_direto ||'/'||vr_nmtmparq||'.zip '||
                    vr_nm_direto ||'/'||vr_nmtmparq||'_processado.pro 1> /dev/null';
       --Executar o comando no unix
       GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
       --Se ocorreu erro dar RAISE
       IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
         RAISE vr_exc_erro;
       END IF;
       
       /* --------------------------------------------------- */
       
       vr_nm_arquivo := vr_endarqtxt || '/' || vr_nm_arquivo;

      /* verificar se o arquivo existe */
      if not gene0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) then
         vr_des_erro := 'Erro rotina PC_IMPORTA_ARQUIVO_CYBER: Arquivo inexistente!' || sqlerrm;
         raise vr_exc_erro;
      end if;

      /* Abrir o arquivo */
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo
                              ,pr_tipabert => 'R'                --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);

      if vr_des_erro is not null then
         raise vr_exc_erro;
      end if;

      /* Abrir o arquivo de LOG */
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog
                              ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_handle_log      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);

      if vr_des_erro is not null then
         vr_des_erro := 'Erro LOG: ' || vr_des_erro;
         raise vr_exc_erro;
      end if;

      /* Processar linhas do arquivo */
      vr_nrlinha := 1;

      IF utl_file.IS_OPEN(vr_input_file) then
         BEGIN
           LOOP
             vr_gerou_log := false;

             gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                         ,pr_des_text => vr_linha_arq);



            -- Verifica registro Header
            if  vr_inicio
            and substr(vr_linha_arq, 1, 1) <> 'H' then -- nao possui registro Header
                vr_des_erro := 'Layout do arquivo inválido, não possui registro Header';
                raise vr_exc_erro;
            end if;

           /* -- Verifica data de geração
            if vr_inicio
            and substr(vr_linha_arq, 40,8) <> to_char(pr_dtmvto,'MMDDYYYY') then
                vr_des_erro := 'Data de geração do arquivo inválida!';
                raise vr_exc_erro;
            end if;*/

            IF substr(vr_linha_arq, 1,1)='T' THEN
               EXIT;
            END IF;

            if substr(vr_linha_arq,1,3) = '   ' then -- se for registro detalhe
              -- ler numero da cooperativa
              vr_cdcooper := substr(vr_linha_arq, 55, 4);
              -- ler modalidade de emprestimo
              vr_cdorigem := substr(vr_linha_arq, 59, 1);
              -- ler numero da conta
              vr_nrdconta := substr(vr_linha_arq, 60, 8);
              -- ler contrato
              vr_cdctremp := substr(vr_linha_arq, 68, 8);
              -- ler código da assessoria

              vr_cdassessx := rtrim(substr(vr_linha_arq, 76, 8));

              -- ler data da distribuicao para assessoria
              vr_dtdistri := to_date(substr(vr_linha_arq, 84, 8),'MMDDYYYY');

              /* verifica campos obrigatórios */
              if vr_cdcooper is null then
                 vr_des_erro := 'Erro no arquivo, campo Código da Cooperativa não está preenchido!';
                 raise vr_exc_erro;
              end if;

              if vr_cdorigem is null then
                 vr_des_erro := 'Erro no arquivo, campo modalidade de empréstimo não está preenchido!';
                 raise vr_exc_erro;
              end if;

              if vr_nrdconta is null then
                 vr_des_erro := 'Erro no arquivo, campo número da conta não está preenchido!';
                 raise vr_exc_erro;
              end if;

              if vr_cdctremp is null then
                 vr_des_erro := 'Erro no arquivo, campo número do contrato não está preenchido!';
                 raise vr_exc_erro;
              end if;

              open c_busca_assessoria(pr_cdassessoria => vr_cdassessx);
              fetch c_busca_assessoria into vr_cdassess;
                         
              if c_busca_assessoria%Notfound then
                           
                  if nvl(vr_cdassessx,'        ') = '        ' then
                     vr_cdassess := 0;
                  else
                     vr_cdassess := 99;
                end if;
                close c_busca_assessoria;
              else
                close c_busca_assessoria;
              end if;
                       
              /*
                 Atualizar a tabela CRAPCYC

               Regras: 1) Verificar se o contrato existe, caso contario, gerar LOG
                       2) Se o contrato estiver marcado como Judicial ou VIP (CIN) não pode ser alterado pela carga
                       2) Caso contrário efetuar a atualização do cadastro (CRAPCYC) de acordo com o contrato da
                      carga CYBER, alterando o código da assessoria e os flags judicial, extrajudicial e
                    VIP de acordo com o cadastro da assessoria

              */

              vr_flgjudic := 0;
              vr_flextjud := 0;

              /* Regra 1 - verifica o contrato */
                        
              open c_busca_crapcyc(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => vr_nrdconta
                                  ,pr_nrctremp => vr_cdctremp
                                  ,pr_cdorigem => vr_cdorigem);
              fetch c_busca_crapcyc into vr_flgjudic, vr_flgehvip;
                        
              if c_busca_crapcyc%notfound then
                   close c_busca_crapcyc;
                   vr_des_log := 'Erro Linha: ' || vr_nrlinha || ' -> Contrato: (Coop:' || vr_cdcooper || ', origem: ' || vr_cdorigem ||
                                                  ', conta:' || vr_nrdconta || ', contrato: ' || vr_cdctremp ||
                                  ') não encontrado! ';
                               -- Grava arquivo de LOG
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                               ,pr_des_text => vr_des_log);
                 BEGIN
                    INSERT INTO CRAPCYC
                      (CDCOOPER
                      ,CDORIGEM
                      ,NRDCONTA
                      ,NRCTREMP
                      ,CDOPEINC
                      ,CDASSESS
                      ,CDMOTCIN)
                      VALUES
                      (VR_CDCOOPER
                      ,decode(VR_CDORIGEM,2,3,vr_cdorigem)
                      ,VR_NRDCONTA
                      ,vr_cdctremp
                      ,' '
                      ,0
                      ,0);
                  EXCEPTION
                    WHEN OTHERS THEN
                         vr_des_erro := 'Erro no INSERT da CRAPCYC: '|| sqlerrm;
                         raise vr_exc_erro;
                  END;
              else 
                 close c_busca_crapcyc;
              end if;
                
              /* Regra 2: Se for contrato judicial ou VIP não permite carregar, mas não gera alerta */
              if vr_flgjudic = 1
              or vr_flgehvip = 1 then
                  vr_gerou_log := true;
              end if;

              if  not vr_gerou_log  --vr_des_log  is null
              and nvl(vr_cdassess,0) <> 0 then

                 -- Busca data de movimento
                  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
                  FETCH btch0001.cr_crapdat INTO rw_crapdat;
                  CLOSE btch0001.cr_crapdat;

                 -- Grava a CRAPCYC com o codigo de asessoria e com os flags de marcacao de cobranca
                 BEGIN
                    UPDATE CRAPCYC
                    SET    CDASSESS = decode(vr_cdassess,0 ,null, vr_cdassess)
                    ,      FLGJUDIC = vr_flgjudic
                    ,      FLEXTJUD = 1 --vr_flextjud
                    ,      FLGEHVIP = vr_flgehvip
                    ,      DTENVCBR = decode(vr_flgjudic, 1, DTENVCBR, vr_dtdistri)
                    ,      CDOPERAD = 'cyber'
                    ,      dtaltera = rw_crapdat.dtmvtolt
                    ,      dtinclus = nvl(dtinclus, decode(vr_flgjudic, 1, DTENVCBR, vr_dtdistri)   )
                    ,      cdopeinc = decode(cdopeinc,' ', 'cyber', cdopeinc)
                    WHERE  cdcooper = vr_cdcooper
                    and    cdorigem = decode(vr_cdorigem,2,3,vr_cdorigem)  -- se vier como 2 (descontos) considerar origem 3
                    and    nrdconta = vr_nrdconta
                    and    nrctremp = vr_cdctremp;
                 EXCEPTION
                    WHEN OTHERS THEN
                     vr_des_erro := 'Erro de atualizacao da CRAPCYC: '|| sqlerrm;
                     raise vr_exc_erro;
                 END;

                 -- atualiza CRAPCYB
                 BEGIN
                    UPDATE CRAPCYB
                    SET    FLGJUDIC = vr_flgjudic
                    ,      FLEXTJUD = 1
                    ,      FLGEHVIP = vr_flgehvip
                    ,      DTMANCAD = rw_crapdat.dtmvtolt
                    WHERE  cdcooper = vr_cdcooper
                    and    cdorigem = vr_cdorigem
                    and    nrdconta = vr_nrdconta
                    and    nrctremp = vr_cdctremp;
                 EXCEPTION
                    WHEN OTHERS THEN
                     vr_des_erro := 'Erro de atualizacao da CRAPCYB: '|| sqlerrm;
                     raise vr_exc_erro;
                 END;

              end if;

              if  nvl(vr_cdassess,0) = 0
              and not vr_gerou_log then -- vr_des_log is null then
                  BEGIN
                    UPDATE CRAPCYB
                    SET    dtmancad = rw_crapdat.dtmvtolt
                    ,      flextjud = 0
                    WHERE  cdcooper = vr_cdcooper
                    and    cdorigem = vr_cdorigem
                    and    nrdconta = vr_nrdconta
                    and    nrctremp = vr_cdctremp;
                 EXCEPTION
                    WHEN OTHERS THEN
                     vr_des_erro := 'Erro de atualizacao da CRAPCYB: '|| sqlerrm;
                     raise vr_exc_erro;
                 END;

                 BEGIN
                    UPDATE CRAPCYC
                    SET    CDASSESS = 0
                    ,      DTENVCBR = decode(vr_flgjudic, 1, DTENVCBR, vr_dtdistri)
                    ,      CDOPERAD = 'cyber'
                    ,      DTALTERA = rw_crapdat.dtmvtolt
                    ,      flextjud = 0
                    WHERE  cdcooper = vr_cdcooper
                    and    cdorigem = decode(vr_cdorigem,2,3,vr_cdorigem) -- se vier como 2 (descontos) considerar origem 3
                    and    nrdconta = vr_nrdconta
                    and    nrctremp = vr_cdctremp;
                 EXCEPTION
                    WHEN OTHERS THEN
                     vr_des_erro := 'Erro de atualizacao da CRAPCYC: '|| sqlerrm;
                     raise vr_exc_erro;
                 END;

              end if;
            end if;

            vr_inicio  := false;
            vr_des_log := null;
            vr_nrlinha :=  vr_nrlinha + 1;

           END LOOP;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
            -- Fim das linhas do arquivo
            NULL;
        END;
      END IF;

      COMMIT;

      -- verifica se gerou arquivo de LOG
      if vr_gerou_log then
         vr_des_erro := 'Verifique as informacoes geradas no arquivo de LOG';
         raise vr_exc_erro;
      end if;
      -- Fecha arquivos
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
       
       
       /* --------------------------------------------------- */
       
--       dbms_output.put_line('arquivo processado: ' || vr_nm_arquivo);
       
       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log2
                                     ,pr_des_text => 'arquivo processado: ' || vr_nm_arquivo|| chr(10) || chr(13));

      --Proximo arquivo zip da/ lista
      vr_nrindice:= vr_tab_arqzip_sort.NEXT(vr_nrindice);
    end loop;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- fechar arquivos
        if utl_file.IS_OPEN(vr_input_file) then
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        end if;

        if utl_file.IS_OPEN(vr_handle_log) then
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
        end if;

        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        pr_des_erro := vr_des_erro;
                                   
        dbms_output.put_line('Erro: ' || pr_des_erro);
                                   
        ROLLBACK;
        
      WHEN OTHERS THEN
        -- fechar arquivos
        if utl_file.IS_OPEN(vr_input_file) then
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        end if;

        if utl_file.IS_OPEN(vr_handle_log) then
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
        end if;

        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        pr_des_erro := vr_des_erro;
                                   
        dbms_output.put_line('Erro: ' || pr_des_erro);
                                   
        ROLLBACK;
    END;
    --================================================================================
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log2);
end;
0
2
vr_tab_arqzip_sort(1)
vr_tab_arqzip_sort(2)
