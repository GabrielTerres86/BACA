CREATE OR REPLACE PACKAGE CECRED.CYBE0004 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: CYBE0004
  --  Autor   : Luciano Kienolt - SUPERO
  --  Data    : Abril/2019                     Ultima Atualizacao:  
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de Enriquecimento de cadastros com bases externas
  --
  --  Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Função para montagem da string de busca da remessa de envio --
  FUNCTION fn_chbusca_bureaux(pr_rowid ROWID) return VARCHAR2;
  
  -- Funcao para montagem do nome do arquivo a retornar do Bureaux --
  FUNCTION fn_nmarquiv_ret_bureaux(pr_rowid ROWID) return VARCHAR2;
	
	-- Funcao para retornar o nome do arquivo de retorno da UNIT4
  FUNCTION fn_nmarquiv_ret_unitfour(pr_rowid IN ROWID
		                               )RETURN VARCHAR2;

  -- Funcao para retornar o nome do arquivo de retorno da NOVAVIDA
  FUNCTION fn_nmarquiv_ret_novavida(pr_rowid IN ROWID
		                               )RETURN VARCHAR2;

  -- Funcao para renomeação do nome do arquivo a retornar do Bureaux ao PPWare --
  FUNCTION fn_nmarquiv_dev_enriquece(pr_rowid ROWID) return VARCHAR2;  
    
  PROCEDURE pc_importa_arquivo_cpc(pr_des_reto   OUT VARCHAR2      --> descrição do retorno ("OK" ou "NOK")
                                  ,pr_dscritic   OUT VARCHAR2);    --> descrição do erro  
  -- 
END CYBE0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CYBE0004 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: CYBE0004
  --  Autor   : Luciano Kienolt - SUPERO
  --  Data    : Abril/2019                    Ultima Atualizacao:  
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de Enriquecimento de cadastros com bases externas
  --
  --  Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Tratamento de erros

  vr_dscritic VARCHAR2(4000);
  vr_excerror EXCEPTION;
  
  vr_tparquiv VARCHAR2(10);
  
  vr_nmarquiv craparb.nmarquiv%TYPE;
  
  -- Busca cabeçalho da remessa quando passado Rowid
  CURSOR cr_crapcrb(pr_rowid IN ROWID) IS
    SELECT idtpreme
          ,dtmvtolt
          ,CASE WHEN SUBSTR(idtpreme,LENGTH(idtpreme),1) = 'L'  THEN
                     SUBSTR(idtpreme,1,LENGTH(idtpreme)-3)  
                WHEN SUBSTR(idtpreme,LENGTH(idtpreme),1) = 'E' THEN
                     SUBSTR(idtpreme,1,LENGTH(idtpreme)-2)  
                WHEN SUBSTR(idtpreme,LENGTH(idtpreme)-1,2) = 'ND' THEN
                     SUBSTR(idtpreme,1,LENGTH(idtpreme)-3)  
           ELSE  
                SUBSTR(idtpreme,1,LENGTH(idtpreme)-2)       
           END dstpreme   
      FROM crapcrb
     WHERE ROWID = pr_rowid;
  rw_crapcrb cr_crapcrb%ROWTYPE;  
  
  -- Busca cabeçalho da remessa quando passado Rowid
  CURSOR cr_craparb(pr_rowid IN ROWID) IS
    SELECT idtpreme
          ,dtmvtolt
          ,regexp_substr(regexp_substr(nmarquiv,'[^.]+', 1, 1),'[^_]+', 1, 1) dtgerarq
          ,CASE WHEN SUBSTR(idtpreme,LENGTH(idtpreme),1) = 'L'  THEN
                     SUBSTR(idtpreme,1,LENGTH(idtpreme)-3)  
                WHEN SUBSTR(idtpreme,LENGTH(idtpreme),1) = 'E' THEN
                     SUBSTR(idtpreme,1,LENGTH(idtpreme)-2)  
                WHEN SUBSTR(idtpreme,LENGTH(idtpreme)-1,2) = 'ND' THEN
                     SUBSTR(idtpreme,1,LENGTH(idtpreme)-3)  
           ELSE  
                SUBSTR(idtpreme,1,LENGTH(idtpreme)-2)       
           END dstpreme 
					,craparb.nmarquiv
      FROM craparb
     WHERE ROWID = pr_rowid;
  rw_craparb cr_craparb%ROWTYPE;     
  
  -- Função para montagem da string de busca da remessa de envio --
  FUNCTION fn_chbusca_bureaux(pr_rowid ROWID) return VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_chbusca_bureaux
    Autor   : Luciano Kienolt - Supero
    Data    : 14/05/2019                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para montagem do nome do arquivo da remessa a buscar do Bureaux. 

    Alteracoes :

    /* ...........................................................................*/
    DECLARE
      vr_dtbasbus VARCHAR2(8);
      
    BEGIN
      -- Inclusão do módulo e ação logado  
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0004.fn_chbusca_bureaux');
      
      -- Busca cabeçalho da remessa
      OPEN cr_crapcrb(pr_rowid);
      FETCH cr_crapcrb
       INTO rw_crapcrb;
      CLOSE cr_crapcrb;
      /* -- Essa regra existe na cybe0002 para a rotina executar apenas nos dias úteis.
			   -- Não faz sentido essa regra ser aplicada para a nomeclatura dos arquivos
			-- Somente para segundas
      IF to_char(rw_crapcrb.dtmvtolt,'d') = 2 THEN
        -- Usaremos o sábado (2 dias antes)
        vr_dtbasbus := to_char(rw_crapcrb.dtmvtolt-2,'rrrrmmdd');
      ELSE
        -- Usaremos a data atual
        vr_dtbasbus := to_char(rw_crapcrb.dtmvtolt-1,'rrrrmmdd');
      END IF;*/
      
      IF SUBSTR(rw_crapcrb.idtpreme,LENGTH(rw_crapcrb.idtpreme),1) in ('L', 'E') THEN
         vr_tparquiv := 'telefone';
      ELSE
         vr_tparquiv := 'endereco';
      END IF;

      -- Retornar o padrão
      RETURN /*vr_dtbasbus*/to_char(rw_crapcrb.dtmvtolt,'rrrrmmdd')||'_%_'||vr_tparquiv||'_%_'||rw_crapcrb.dstpreme||'_in.txt';
    END;
  END fn_chbusca_bureaux; 
  
  -- Funcao para montagem do nome do arquivo a retornar do Bureaux --
  FUNCTION fn_nmarquiv_ret_bureaux(pr_rowid IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_nmarquiv_ret_bureaux
    Autor   : Luciano Kienolt - Supero
    Data    : 14/05/2019                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para montagem do nome do arquivo a retornar do Bureaux

    Alteracoes :

    /* ...........................................................................*/
    DECLARE
      -- Buscaremos o nome do arquivo enviado (Somente há um)
      CURSOR cr_nmarquiv_c(pr_idtpreme craparb.idtpreme%TYPE
                          ,pr_dtmvtolt craparb.dtmvtolt%TYPE) IS
        SELECT regexp_substr(regexp_substr(arb.nmarquiv,'[^.]+', 1, 1),'[^_]+', 1, 1)
          FROM craparb arb
         WHERE arb.idtpreme = pr_idtpreme
           AND arb.dtmvtolt = pr_dtmvtolt
           AND arb.cdestarq = 3; --> Envio
--      vr_nmarquiv craparb.nmarquiv%TYPE;
    BEGIN
      -- Inclusão do módulo e ação logado 
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0004.fn_nmarquiv_ret_bureaux');
      
      -- Busca cabeçalho da remessa
      OPEN cr_craparb(pr_rowid);
      FETCH cr_craparb
       INTO rw_craparb;
      CLOSE cr_craparb;
      -- Busca do nome do arquivo enviado para montagem do retorno
      OPEN cr_nmarquiv_c(rw_craparb.idtpreme,rw_craparb.dtmvtolt);
      FETCH cr_nmarquiv_c
       INTO vr_nmarquiv;
      CLOSE cr_nmarquiv_c;
      
      IF SUBSTR(rw_craparb.idtpreme,LENGTH(rw_craparb.idtpreme),1) in ('L', 'E') THEN
         vr_tparquiv := 'telefone';
      ELSE
         vr_tparquiv := 'endereco';
      END IF;
            
      -- Depois adicionamos o terminador no nome a buscar
      vr_nmarquiv := vr_nmarquiv || '_%_' || vr_tparquiv || '_%_' || rw_craparb.dstpreme || '.txt';
      RETURN vr_nmarquiv;
    END;
  END fn_nmarquiv_ret_bureaux;
	
	-- Funcao para retornar o nome do arquivo de retorno da UNIT4
  FUNCTION fn_nmarquiv_ret_unitfour(pr_rowid IN ROWID
		                               )RETURN VARCHAR2 IS
    /* .............................................................................
    Programa: fn_nmarquiv_ret_unitfour
    Autor   : Nagasava - Supero
    Data    : 24/07/2019                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para retornar o nome do arquivo de retorno da UNIT4

    Alteracoes :

    /* ...........................................................................*/
		
		-- Buscar os dados da remessa
		CURSOR cr_craparb_ret(pr_rowid IN ROWID
		                     ) IS
			SELECT arb.idtpreme
						,arb.dtmvtolt
						,arb.nmarquiv
				FROM craparb arb
						,crapcrb crb
			 WHERE arb.idtpreme = crb.idtpreme
				 AND arb.dtmvtolt = crb.dtmvtolt
				 AND crb.rowid    = pr_rowid;
    --
		rw_craparb_ret cr_craparb_ret%ROWTYPE;
		--
		vr_dtmvtolt VARCHAR2(8);
		--
	BEGIN
		-- Inclusão do módulo e ação logado 
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0004.fn_nmarquiv_ret_unitfour');
      
		-- Busca dados da remessa
		OPEN cr_craparb_ret(pr_rowid);
		FETCH cr_craparb_ret
		 INTO rw_craparb_ret;
		CLOSE cr_craparb_ret;
		--
		IF rw_craparb_ret.idtpreme LIKE '%UNIT4%' THEN
			--
			vr_dtmvtolt := to_char(gene0005.fn_valida_dia_util(pr_cdcooper => 3
																												,pr_dtmvtolt => TRUNC(SYSDATE)
																												,pr_tipo => 'A'
																												),'YYYYMMDD');
			--
			IF SUBSTR(rw_craparb_ret.idtpreme,LENGTH(rw_craparb_ret.idtpreme),1) in ('L', 'E') THEN
				-- 
				vr_nmarquiv := vr_dtmvtolt || '_*_telefone_enriquecimento_unitfour_in.txt';
				--
			ELSE
				--
				vr_nmarquiv := vr_dtmvtolt || '_*_endereco_enriquecimento_unitfour_in.txt';
				--
			END IF;
			--
		END IF;
    --
		RETURN vr_nmarquiv;
		--
  END fn_nmarquiv_ret_unitfour;
	
	-- Funcao para retornar o nome do arquivo de retorno da NOVAVIDA
  FUNCTION fn_nmarquiv_ret_novavida(pr_rowid IN ROWID
		                               )RETURN VARCHAR2 IS
    /* .............................................................................
    Programa: fn_nmarquiv_ret_novavida
    Autor   : Nagasava - Supero
    Data    : 24/07/2019                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para retornar o nome do arquivo de retorno da NOVAVIDA

    Alteracoes :

    /* ...........................................................................*/
		
		-- Buscar os dados da remessa
		CURSOR cr_craparb_ret(pr_rowid IN ROWID
		                     ) IS
			SELECT arb.idtpreme
						,arb.dtmvtolt
						,arb.nmarquiv
				FROM craparb arb
						,crapcrb crb
			 WHERE arb.idtpreme = crb.idtpreme
				 AND arb.dtmvtolt = crb.dtmvtolt
				 AND arb.rowid    = pr_rowid;
    --
		rw_craparb_ret cr_craparb_ret%ROWTYPE;
		--
	BEGIN
		-- Inclusão do módulo e ação logado 
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0004.fn_nmarquiv_ret_novavida');
      
		-- Busca dados da remessa
		OPEN cr_craparb_ret(pr_rowid);
		FETCH cr_craparb_ret
		 INTO rw_craparb_ret;
		CLOSE cr_craparb_ret;
		--
		IF rw_craparb_ret.idtpreme LIKE '%NOVAVIDA%' THEN
			--
			vr_nmarquiv := rw_craparb_ret.nmarquiv;
			--
		END IF;
    --
		RETURN vr_nmarquiv;
		--
  END fn_nmarquiv_ret_novavida;
  
  -- Funcao para renomeação do nome do arquivo a retornar do Bureaux a PPWare --
  FUNCTION fn_nmarquiv_dev_enriquece(pr_rowid IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_nmarquiv_dev_enriquece
    Autor   : Luciano Kienolt - Supero
    Data    : 30/12/2014                     Ultima atualizacao:  

    Dados referentes ao programa:

    Objetivo  : Funcao para renomeação do nome do arquivo a retornar do Bureaux a PPWare

    Alteracoes : 

    /* ...........................................................................*/
    DECLARE
      -- Buscaremos o nome do arquivo enviado (Somente há um)
      CURSOR cr_nmarquiv_d(pr_idtpreme craparb.idtpreme%TYPE
                          ,pr_dtmvtolt craparb.dtmvtolt%TYPE) IS
        SELECT arb.nmarquiv
          FROM craparb arb
         WHERE arb.idtpreme = pr_idtpreme
           AND arb.dtmvtolt = pr_dtmvtolt
           AND arb.cdestarq = 4; --> Retorno
    
    BEGIN
      -- Inclusão do módulo e ação logado 
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0004.fn_nmarquiv_dev_enriquece');
      
      -- Busca informações do arquivo retornado
      OPEN cr_craparb(pr_rowid);
      FETCH cr_craparb
       INTO rw_craparb;
      CLOSE cr_craparb;
      -- Busca do nome do arquivo enviado para montagem do retorno
      OPEN cr_nmarquiv_d(rw_craparb.idtpreme,rw_craparb.dtmvtolt);
      FETCH cr_nmarquiv_d
       INTO vr_nmarquiv;
      CLOSE cr_nmarquiv_d;
      -- 
      RETURN vr_nmarquiv;
    END;
  END fn_nmarquiv_dev_enriquece; 
  
  
  PROCEDURE pc_importa_arquivo_cpc(pr_des_reto   OUT VARCHAR2      --> descrição do retorno ("OK" ou "NOK")
                                  ,pr_dscritic   OUT VARCHAR2) IS  --> descrição do erro
     /*
     Programa: pc_importa_arquivo_cpc
     Sigla   : CRED
     Autor   : Luciano Kienolt - Supero
     Data    : 20/05/2019                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para importar aquivo de atualização do Enriquecimento - CPC.
                 Arquivo a ser importado: AAAAMMDD_HHMMSS_telefone_cpc_out.txt
                 Este arquivo irá atualizar a tabela CRAPTFC com dados de telefone.

     */
     vr_exc_erro    EXCEPTION;
     vr_handle_log  utl_file.file_type;
     rw_crapdat     btch0001.cr_crapdat%rowtype;
     vr_des_erro    varchar2(2000);
     vr_des_log     varchar2(2000);
     vr_nm_arquivo  varchar2(2000);
     vr_nm_arqlog   varchar2(2000);
     vr_nm_direto   varchar2(2000);
     vr_linha_arq   varchar2(110);
     vr_inicio      boolean := true;
     vr_gerou_log   boolean := false;
     vr_nrlinha     number;

     vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE:= 'CYBE0004';
     --Variaveis Locais
     vr_nmtmpcpc  VARCHAR2(200);

     vr_dscritic    varchar2(100);
     vr_nmarqcpc    varchar2(200);
     vr_typ_saida   varchar2(10);
     vr_comando     varchar2(4000);
     vr_listadir    varchar2(4000);
     vr_des_complet varchar2(4000);
     vr_nmtmparq    varchar2(200);
     vr_dtarquiv    date;
     vr_input_file  utl_file.file_type;
     vr_nrindice  integer;
     vr_bkpndice  integer;
     vr_contarqv  integer;
     vr_nrcpfcgc  crapass.nrcpfcgc%TYPE;
     vr_nrdddtel  craptfc.nrdddtfc%TYPE;
     vr_nrtelefo  craptfc.nrtelefo%TYPE;
     vr_cdseqtfc  craptfc.cdseqtfc%TYPE;
     vr_idmarccpc varchar2(1);
     vr_dtatuali  date;
     vr_cdgestor  varchar2(8);
     vr_atu_cad   boolean;
     vr_idexiste  integer;

     --Tabela para armazenar arquivos lidos
     vr_tab_arqcpc gene0002.typ_split;

     cursor cr_verifica_cpfcgc(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) is
       select distinct 1
       from   crapass
       where  nrcpfcgc = pr_nrcpfcgc;  

     cursor cr_busca_contas(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) is
       select cdcooper
             ,nrdconta
       from   crapass
       where  nrcpfcgc = pr_nrcpfcgc;  

     rw_busca_contas cr_busca_contas%ROWTYPE;
     
     cursor cr_busca_craptfc(pr_cdcooper number
                            ,pr_nrdconta number
                            ,pr_nrdddtel number
                            ,pr_nrtelefo number) is
       select distinct 1
       from   craptfc
       where  cdcooper = pr_cdcooper
         and  nrdconta = pr_nrdconta
         and  nrdddtfc = pr_nrdddtel
         and  nrtelefo = pr_nrtelefo;                                  

     cursor cr_max_craptfc(pr_cdcooper number
                          ,pr_nrdconta number) is
       select nvl(max(cdseqtfc),0) + 1
       from   craptfc
       where  cdcooper = pr_cdcooper
         and  nrdconta = pr_nrdconta;                                  

  BEGIN
    -- Inclui nome do modulo logado  
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'CYBE0004.pc_importa_arquivo_cpc');
    
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
               FETCH btch0001.cr_crapdat INTO rw_crapdat;
               CLOSE btch0001.cr_crapdat;

    vr_nm_arqlog  := 'LOG_' || to_char(rw_crapdat.dtmvtolt, 'YYYYMMDD') || '_telefone_cpc.log';

    -- Busca o diretório do arquivo CPC
    vr_nm_direto  := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => '/cyber/recebe/');
                                          
    -- Busca o diretório de log da Cooperativa
    vr_des_complet := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => 3
                                           ,pr_nmsubdir => 'log');                                          
                                          
--    vr_nm_arquivo := vr_nm_direto || '/' || vr_nm_arquivo;
    vr_nm_arqlog  := vr_des_complet || '/' || vr_nm_arqlog;
    --==================================================================================
    -- TRATAR ARQUIVO TXT
    --==================================================================================
    vr_nmtmpcpc:= '%telefone_cpc_out.txt';

    /* Vamos ler todos os arquivos %telefone_cpc_out.txt */
    gene0001.pc_lista_arquivos(pr_path     => vr_nm_direto
                              ,pr_pesq     => vr_nmtmpcpc
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
    vr_tab_arqcpc:= gene0002.fn_quebra_string(pr_string => vr_listadir);

    --Filtrar os arquivos da lista
    IF vr_tab_arqcpc.count > 0 THEN
      vr_nrindice:= vr_tab_arqcpc.first;
      -- carrega informacoes na cratqrq
      WHILE vr_nrindice IS NOT NULL LOOP
        --Filtrar a data a partir do Nome arquivo
        vr_nmtmparq:= SUBSTR(vr_tab_arqcpc(vr_nrindice),1,8);
        --Transformar em Data
        vr_dtarquiv:= TO_DATE(vr_nmtmparq,'YYYYMMDD');
        --Data Arquivo entre a data anterior e proximo dia util
				-- Não irá validar a data, pois poderá receber arquivos com data retroativa
        --IF vr_dtarquiv > rw_crapdat.dtmvtoan AND vr_dtarquiv < rw_crapdat.dtmvtopr THEN
          --Incrementar quantidade arquivos
          vr_contarqv:= vr_tab_arqcpc.count + 1;
          --Proximo Registro
          vr_nrindice:= vr_tab_arqcpc.next(vr_nrindice);
        /*ELSE
          --Diminuir quantidade arquivos
          vr_contarqv:= vr_tab_arqcpc.count - 1;
          --Salvar Proximo Registro
          vr_bkpndice:= vr_tab_arqcpc.next(vr_nrindice);
          --Retirar o arquivo da lista
          vr_tab_arqcpc.DELETE(vr_nrindice);
          --Setar o proximo (backup) no indice
          vr_nrindice:= vr_bkpndice;
        END IF;*/
      END LOOP;
    END IF;

    -- Buscar Primeiro arquivo da temp table
    vr_nrindice:= vr_tab_arqcpc.FIRST;
    --Processar os arquivos lidos
    WHILE vr_nrindice IS NOT NULL LOOP
      --Nome Arquivo txt
      vr_nmarqcpc:= vr_tab_arqcpc(vr_nrindice);

      --Nome do arquivo sem extensao
      vr_nmtmparq:= SUBSTR(vr_nmarqcpc,1,LENGTH(vr_nmarqcpc)-4);

      vr_nm_arquivo := vr_nm_direto || '/' || vr_nmarqcpc;

      /* Abrir o arquivo */
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo
                              ,pr_tipabert => 'R'                --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);

      IF vr_des_erro is not null THEN
        vr_des_erro := 'Erro Abrir arquivo: ' || vr_nm_arquivo ;
         raise vr_exc_erro;
      END IF;

      /* Abrir o arquivo de LOG */
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog
                              ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_handle_log      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);

      IF vr_des_erro is not null THEN
        vr_des_erro := 'Erro LOG: ' || vr_des_erro;
        raise vr_exc_erro;
      END IF;

      /* Processar linhas do arquivo */
      vr_nrlinha := 1;

      IF utl_file.IS_OPEN(vr_input_file) THEN
        BEGIN
          LOOP
            vr_gerou_log := false;

            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_linha_arq);

            -- Verifica registro Header
            IF  vr_inicio
            AND substr(vr_linha_arq, 1, 1) <> 'H' THEN -- nao possui registro Header
                vr_des_erro := 'Layout do arquivo inválido, não possui registro Header';
                raise vr_exc_erro;
            END IF;

            IF substr(vr_linha_arq, 1,1) = 'T' THEN
               EXIT;
            END IF;
 
            IF substr(vr_linha_arq,1,3) = '701' THEN -- se for registro detalhe
              -- Número de cliente
              vr_nrcpfcgc := substr(vr_linha_arq, 4, 25);
              -- Codigo de area
              vr_nrdddtel := substr(vr_linha_arq, 29, 5);
              -- Número Telefone
              vr_nrtelefo := substr(vr_linha_arq, 34, 13);
              -- Marcação CPC
              vr_idmarccpc := substr(vr_linha_arq, 47, 1);
              -- Data de atualização CPC
              vr_dtatuali := to_date(substr(vr_linha_arq, 48, 8),'MMDDYYYY');
              -- Gestor
              vr_cdgestor := rtrim(substr(vr_linha_arq, 56, 8));
             
              /* verifica campos obrigatórios */
              vr_atu_cad := TRUE;            
              IF vr_nrcpfcgc IS NULL THEN
                 vr_des_log := 'Erro Linha: ' || vr_nrlinha || 
                               ' ==> campo Numero de cliente não está preenchido!';
                 vr_atu_cad := FALSE;
              END IF;
 
              IF vr_nrdddtel IS NULL THEN
                 vr_des_log := 'Erro Linha: ' || vr_nrlinha || 
                               ' ==> campo Codigo de area não está preenchido! Numero Cliente = ' ||
                                vr_nrcpfcgc;
                 vr_atu_cad := FALSE;
              END IF;

              IF vr_nrtelefo IS NULL THEN
                 vr_des_log := 'Erro Linha: ' || vr_nrlinha || 
                               ' ==> campo Número Telefone não está preenchido! Numero Cliente = ' ||
                                vr_nrcpfcgc;
                 vr_atu_cad := FALSE;
              END IF;

              IF vr_idmarccpc IS NULL 
              OR vr_idmarccpc NOT IN ('S', 'N') THEN
                 vr_des_log := 'Erro Linha: ' || vr_nrlinha ||
                               ' ==> campo CPC não está preenchido ou invalido! Numero Cliente = ' ||
                                vr_nrcpfcgc;
                 vr_atu_cad := FALSE;
              END IF;
             
              IF NOT vr_atu_cad THEN
                -- Grava arquivo de LOG
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => vr_des_log);
                
                CONTINUE;
              END IF;
             
              vr_atu_cad := FALSE;
              IF vr_idmarccpc = 'S' THEN
                vr_atu_cad := TRUE;
              END IF;

              /*
              Atualizar a tabela CRAPTFC
 
              Regras: 1) Se Marcação CPC = N -  não pode ser alterado pela carga
                      2) Verificar se o CPFCGC existe, caso contario, gerar LOG
                      3) Caso contrário efetuar a atualização do cadastro (CRAPTFC) de acordo com o CPFCGC do
                         Titular.
             */

              /* Regra 1 - Marcação CPC */
              IF vr_atu_cad THEN
                /* Regra 2 - verifica o CPFCGC */ 
                open cr_verifica_cpfcgc(pr_nrcpfcgc => vr_nrcpfcgc);
                fetch cr_verifica_cpfcgc into vr_idexiste;
             
                IF cr_verifica_cpfcgc%notfound THEN
                  vr_des_log := 'Erro Linha: ' || vr_nrlinha || ' ==> CPF/CGC: ' || vr_nrcpfcgc || 
                                ' não encontrado! ';
                  -- Grava arquivo de LOG
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                ,pr_des_text => vr_des_log);
                  CONTINUE;                                                
                END IF;
                close cr_verifica_cpfcgc; 
                              
                -- Busca os dados da remessa
                FOR rw_busca_contas IN cr_busca_contas(vr_nrcpfcgc) LOOP
                  
                  open cr_max_craptfc(pr_cdcooper => rw_busca_contas.cdcooper
                                     ,pr_nrdconta => rw_busca_contas.nrdconta);
                  fetch cr_max_craptfc into vr_cdseqtfc;
                  close cr_max_craptfc; 
                                           
                  open cr_busca_craptfc(pr_cdcooper => rw_busca_contas.cdcooper
                                       ,pr_nrdconta => rw_busca_contas.nrdconta
                                       ,pr_nrdddtel => vr_nrdddtel
                                       ,pr_nrtelefo => vr_nrtelefo);
                  fetch cr_busca_craptfc into vr_idexiste;
                 
                  IF cr_busca_craptfc%notfound THEN
                    -- insere CRAPTFC                
                    BEGIN
                      INSERT INTO CRAPTFC
                        (CDCOOPER
                        ,NRDCONTA
                        ,IDSEQTTL 
                        ,CDSEQTFC
                        ,NRDDDTFC
                        ,PRGQFALT
                        ,NRTELEFO
                        ,TPTELEFO 
                        ,IDORIGEM) 
                        VALUES
                        (rw_busca_contas.CDCOOPER
                        ,rw_busca_contas.NRDCONTA
                        ,1 -- Ativo
                        ,vr_cdseqtfc
                        ,vr_nrdddtel
                        ,'A' -- Ayllos
                        ,vr_nrtelefo
                        ,4 -- Contato
                        ,3); -- Terceiros
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_des_erro := 'Erro no INSERT da CRAPTFC: '|| sqlerrm;
                        raise vr_exc_erro;
                    END;
                  ELSE
                    -- atualiza CRAPTFC apenas se telefone estiver com status <> ATIVO
                    BEGIN
                      UPDATE CRAPTFC
                      SET    IDSITTFC = 1 -- Ativo
                      ,      IDORIGEM = 3 -- Terceiros
                      WHERE  cdcooper = rw_busca_contas.CDCOOPER
                      and    nrdconta = rw_busca_contas.NRDCONTA
                      and    idsittfc <> 1;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_des_erro := 'Erro de atualizacao da CRAPTFC: '|| sqlerrm;
                        raise vr_exc_erro;
                    END;
                  END IF;

                  close cr_busca_craptfc; 
                    
                  COMMIT;                                                 

                END LOOP;                           
                 
              END IF;
                 
            END IF;

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
    
     -- Fecha arquivos
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);    
    
     -- modifica nome do arquivo txt para "processado".
     vr_comando:= 'mv '||vr_nm_direto ||'/'||vr_nmtmparq||'.txt '||
                  vr_nm_direto ||'/'||vr_nmtmparq||'.pro 1> /dev/null';
     --Executar o comando no unix
     GENE0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_comando
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_dscritic);
     --Se ocorreu erro dar RAISE
     IF vr_typ_saida = 'ERR' THEN
       vr_des_erro := 'Nao foi possivel executar comando unix. '||vr_comando;
       RAISE vr_exc_erro;
     END IF;

     --Proximo arquivo txt da/ lista
     vr_nrindice:= vr_tab_arqcpc.NEXT(vr_nrindice);
     end loop;
     --================================================================================    

     -- verifica se gerou arquivo de LOG
     IF vr_gerou_log THEN
        vr_des_erro := 'Verifique as informacoes geradas no arquivo de LOG';
        raise vr_exc_erro;
     END IF;
     -- Fecha arquivos
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
      -- Retorno OK
     pr_des_reto := 'OK';     

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
      pr_dscritic := vr_des_erro;

  END pc_importa_arquivo_cpc;
    
END  CYBE0004;
/
