CREATE OR REPLACE PROCEDURE CECRED.pc_crps212 (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER --> Flag padrao para utilizacao de restart
                                       ,pr_stprogra OUT PLS_INTEGER --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS
                                      
/* ..........................................................................
   Programa: pc_crps212.p                           Antigo: Fontes/crps212.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/97.                        Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 002.
               Gerar arquivo de estouro de convenios.

   Alteracoes: 03/11/97 - Mandar arquivos direto para Hering (Odair).

               05/11/97 - Por o campo nrdocmto no arquivo (Odair)

               15/12/97 - Gerar arquivo para os convenios 18 e 19 (Odair)

               09/03/98 - Gerar arquivo para os convenios 24 e 25
                          e passar novo parametro para o transrh (Deborah).

               14/09/98 - Alterado para transmitir os convenios 16 e 30 
                          (Deborah).

               08/10/98 - Alterado para transmitir os convenios 32 e 33
                          (Deborah).

               12/07/1999 - Melhorar o display de transmissao (Deborah).

               05/01/2000 - Padronizar as criticas (Deborah).
               
               12/12/2002 - Alterado para enviar arquivos de convenios
                            automaticamente (Junior).
                            
               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder    
                        
               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               22/12/2006 - Alteracao envio de arquivos(Mirtes)  

               12/04/2007 - Retirar rotina de email em comentario (David).

               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)

               21/01/2015 - Migração Progress/Oracle (Jéssica - DB1).

............................................................................. */


------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    --Constantes
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS212';
               
    --Variaveis para retorno de erro
    vr_cdcritic        INTEGER:= 0;
    vr_dscritic        VARCHAR2(4000);

    --Variaveis de Excecao
    vr_exc_final       EXCEPTION;
    vr_exc_saida       EXCEPTION;
    vr_exc_fimprg      EXCEPTION;


------------------------------- VARIAVEIS ------------------------------   
           
    -- variaveis para manipulação dos arquivos
    vr_typ_saida    VARCHAR2(100);
    vr_comando      VARCHAR2(4000);
                   
    -- variavel clob para montar relatorio
    vr_des_xml      CLOB;  
    --Variaveis de Indice para temp-tables
    
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    -- assunto da mensagem
    vr_asunteml VARCHAR2(2000);
     
    vr_nrseqint  NUMBER(10);
    vr_vltotlan  NUMBER(15,2);
    vr_vllanmto  NUMBER(15,2);

    -- registros do arquivo
    vr_nmarqher  VARCHAR2(500);
    vr_nmarquiv  VARCHAR2(1000);
    vr_linha     VARCHAR2(5000);
    vr_linha_aux VARCHAR2(4000);
    vr_linha1    VARCHAR2(4000);
    
    -- diretorio padrçao da coop
    vr_nom_direto   VARCHAR2(5000);
          
------------------------------- CURSORES ---------------------------------

    -- Buscar os dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) is
      SELECT crapcop.nmrescop,
             crapcop.nrtelura,
             crapcop.dsdircop,
             crapcop.cdbcoctl,
             crapcop.cdagectl,
             crapcop.nrctactl,
             crapcop.cdcooper
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;  
  
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cursor para controle de convenios
	  CURSOR cr_crapctc (pr_cdcooper crapcop.cdcooper%TYPE
		                  ,pr_dtresumo IN crapctc.dtresumo%TYPE) IS
			SELECT crapctc.nrconven,
						 crapctc.dtrefere,
						 crapctc.cdempres,
             crapctc.dtresumo			
			  FROM crapctc
			 WHERE crapctc.cdcooper = pr_cdcooper
				 AND crapctc.dtresumo = pr_dtresumo
				 AND crapctc.cdempres = 0;
		rw_crapctc cr_crapctc%ROWTYPE;

    -- Consulta de convenios integrados por empresa
    CURSOR cr_crapcnv (pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_nrconven IN crapctc.nrconven%TYPE) IS
      SELECT crapcnv.nrconven,
             crapcnv.intipest,
             crapcnv.dsdemail
        FROM crapcnv
       WHERE crapcnv.cdcooper = pr_cdcooper
         AND crapcnv.nrconven = pr_nrconven;
    rw_crapcnv cr_crapcnv%ROWTYPE;     

    -- Verificar se existe aviso de débito em conta corrente não processado
    CURSOR cr_crapavs(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtrefere IN crapctc.dtrefere%TYPE
                     ,pr_nrconven IN crapctc.nrconven%TYPE) IS
      SELECT crapavs.tpdaviso,
             crapavs.dtrefere,
             crapavs.nrconven,
             crapavs.vllanmto,
             crapavs.vldebito,
             crapavs.nrdconta,
             crapavs.cdhistor,
             crapavs.dtintegr,
             crapavs.nrdocmto
        FROM crapavs
       WHERE crapavs.cdcooper = pr_cdcooper
         AND crapavs.dtrefere = pr_dtrefere
         AND crapavs.nrconven = pr_nrconven
         AND (crapavs.tpdaviso = 1
          OR crapavs.tpdaviso = 3);
    rw_crapavs cr_crapavs%ROWTYPE;
   

--------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
    BEGIN
      --Escrever no arquivo CLOB
      dbms_lob.writeappend(vr_des_xml,length(pr_des_dados||chr(13)),pr_des_dados||chr(13));
    END;
   
---------------------------------------
-- Inicio Bloco Principal pc_crps212
---------------------------------------

    BEGIN
         
      --Limpar parametros saida
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);
                            
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcop;
        -- Gerar exceção
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(SYSDATE,
                                                      'hh24:mi:ss') ||
                                                  ' - ' || vr_cdprogra ||
                                                ' --> ' || vr_dscritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;
                            
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validacoes iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 0
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdcritic => vr_cdcritic);
                            
      --Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
        --Sair do programa
        RAISE vr_exc_saida;  
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop/Win12
                                           ,pr_cdcooper => pr_cdcooper);
      
      FOR rw_crapctc IN cr_crapctc(pr_cdcooper, 
                                   pr_dtresumo => rw_crapdat.dtmvtolt) LOOP 

        -- inicializar lob
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Verifica a tabela crapcnv
        OPEN cr_crapcnv(pr_cdcooper, /*vr_nrconven*/ pr_nrconven => rw_crapctc.nrconven);
         FETCH cr_crapcnv
          INTO rw_crapcnv;
         -- Verificar se existe informação, e gerar erro caso não exista
         IF cr_crapcnv%NOTFOUND THEN
           -- Fechar o cursor
           CLOSE cr_crapcnv;
           -- Gerar critica 563 e parar o processo
            vr_cdcritic := 563;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Escrever no log e parar o processo
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || 'CONVENIO' || to_char(rw_crapctc.nrconven,'fm00'));
            -- Zerar a critica
            vr_cdcritic := 0;
            -- Sair
           RAISE vr_exc_saida;
         ELSE
           CLOSE cr_crapcnv;
         END IF;

        IF rw_crapcnv.intipest <> 1 THEN
          CONTINUE;
        END IF;

        vr_nrseqint := 0;
        vr_vltotlan := 0;

        vr_nmarqher := 'cv' || TO_CHAR(TO_DATE(rw_crapctc.dtrefere, 'MM/DD/YYYY'),'MM') ||
                       TO_CHAR(TO_DATE(rw_crapctc.dtrefere, 'MM/DD/YYYY'),'YYYY')||'.'||
                       TRIM(TO_CHAR(rw_crapctc.nrconven,'000'));

        vr_nmarquiv := 'cv' || TO_CHAR(TO_DATE(rw_crapctc.dtrefere, 'MM/DD/YYYY'),'MM') ||
                       TO_CHAR(TO_DATE(rw_crapctc.dtrefere, 'MM/DD/YYYY'),'YYYY') || '.' ||
                       TRIM(TO_CHAR(rw_crapctc.nrconven,'000'));

        vr_linha1 := '1 '
                  || TO_CHAR(TO_DATE(rw_crapctc.dtrefere,'MM/DD/YYYY'),'DD')
                  || TO_CHAR(TO_DATE(rw_crapctc.dtrefere,'MM/DD/YYYY'),'MM')
                  || TO_CHAR(TO_DATE(rw_crapctc.dtrefere,'MM/DD/YYYY'),'YYYY');

        -- Escrevendo no CLOB
        pc_escreve_clob(vr_linha1);
                               
        FOR rw_crapavs IN cr_crapavs(pr_cdcooper, 
                                     pr_dtrefere => rw_crapctc.dtrefere,
                                     pr_nrconven => rw_crapctc.nrconven) LOOP

          IF rw_crapavs.vllanmto = rw_crapavs.vldebito THEN
            CONTINUE;
          END IF;

          vr_nrseqint := vr_nrseqint + 1;
          vr_vllanmto := rw_crapavs.vllanmto - rw_crapavs.vldebito;
          vr_vltotlan := vr_vltotlan + vr_vllanmto;

          vr_linha := '0 '
                  || GENE0002.fn_mask(vr_nrseqint,'999999') || ' '
                  || GENE0002.fn_mask(rw_crapavs.nrdconta,'99999999') || ' '
                  || TRIM(to_char(vr_vllanmto,'000000000d00')) || ' '
                  || GENE0002.fn_mask(rw_crapavs.cdhistor,'999') || ' '
                  || TO_CHAR(TO_DATE(rw_crapavs.dtintegr,'MM/DD/YYYY'),'DD/MM/YYYY') || '           '
                  || GENE0002.fn_mask(rw_crapavs.nrdocmto,'999999999');

          -- Escrevendo no CLOB
          pc_escreve_clob(vr_linha);

        END LOOP;  -- crapavs

        vr_linha_aux := '9 999999 99999999 ' || TRIM(to_char(vr_vltotlan,'000000000d00')) || ' ' || '999'|| ' '
                  || TO_CHAR(TO_DATE(rw_crapctc.dtrefere,'MM/DD/YYYY'),'DD/MM/YYYY') || ' 999999999';

        pc_escreve_clob(vr_linha_aux);

        vr_asunteml:= 'ARQUIVO DE CONVENIOS'; 
              
        -- Escreve o clob no arquivo físico
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                     ,pr_caminho  => vr_nom_direto||'/arq'
                                     ,pr_arquivo  => vr_nmarquiv
                                     ,pr_des_erro => vr_dscritic);

        -- Realizar a conversão do arquivo
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                    ,pr_nmarquiv => vr_nom_direto||'/arq/'||vr_nmarquiv
                                    ,pr_nmarqenv => vr_nmarquiv
                                    ,pr_des_erro => vr_dscritic);  
        
        /*  Copiar arquivo para a pasta salvar  */
        vr_comando:= 'cp '||vr_nom_direto||'/arq/'||vr_nmarquiv||' '||vr_nom_direto||'/salvar/'||' 2> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Testar erro
        IF vr_typ_saida = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarquiv ||' para a pasta salvar';
          RAISE vr_exc_saida;
        END IF;   

        -- chama solicitacao de envio de email
        gene0003.pc_solicita_email( pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_des_destino => rw_crapcnv.dsdemail
                                   ,pr_des_assunto => vr_asunteml
                                   ,pr_des_corpo => NULL
                                   ,pr_des_anexo => vr_nom_direto||'/converte/'||vr_nmarquiv
                                   ,pr_flg_enviar => 'S'
                                   ,pr_des_erro => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN -- se deu erro finaliza
          vr_dscritic := ' Erro ao enviar email. '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF; 

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml); 

     
      
      END LOOP;                                                                                
                                                  
----------------- ENCERRAMENTO DO PROGRAMA -------------------
                                                     
      --Verificar se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
                                                
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

      --Salvar informacoes no banco de dados
      COMMIT;
      EXCEPTION
        WHEN vr_exc_fimprg THEN
          -- Se foi retornado apenas codigo
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descricao da critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Se foi gerada critica para envio ao log
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
          END IF;
          -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
          btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);
          --Limpar parametros
          pr_cdcritic:= 0;
          pr_dscritic:= NULL;
          -- Efetuar commit pois gravaremos o que foi processado ate entao
          COMMIT;
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas codigo
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descricao
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos codigo e critica encontradas
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
          -- Efetuar rollback
          ROLLBACK;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro nao tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
          -- Efetuar rollback
          ROLLBACK; 
  
    END pc_crps212;
/

