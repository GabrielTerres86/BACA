-- Paulo Martins - Mouts 
-- SCTASK0048406 
DECLARE 
 
vr_index INTEGER;
vr_countCommit number := 0;

vr_cdoperad  crapope.cdoperad%TYPE;
vr_cdcritic  crapcri.cdcritic%TYPE;
vr_dscritic  crapcri.dscritic%TYPE;
vr_des_erro  crapcri.dscritic%TYPE;
vr_exc_saida EXCEPTION;
VR_TYP_SAIDA VARCHAR2(100);
VR_DES_SAIDA VARCHAR2(1000);
VR_EXC_ERRO  EXCEPTION;

vr_arq_path  VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
vr_rowid     ROWID;

vr_des_xml         CLOB;
vr_texto_completo  VARCHAR2(32600);
vr_hutlfile utl_file.file_type;

/* Tipo para armazenamento as criticas identificadas */
TYPE typ_rec_ass IS
  RECORD(cdcooper crapass.cdcooper%TYPE
        ,nrdconta crapass.nrdconta%TYPE
        ,inpessoa crapass.inpessoa%TYPE
        ,pacote   number);
          
TYPE typ_tab_ass IS
  TABLE OF typ_rec_ass
  INDEX BY PLS_INTEGER;

vr_tab_ass typ_tab_ass;

-- Cursor genérico de calendário
rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

 cursor c_cop is
 select cdcooper
   from crapcop 
  where cdcooper in (5,10);
  
  r_cop c_cop%rowtype;


PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                         pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
BEGIN
  gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
END;

PROCEDURE pc_incluir_pacote(pr_cdcooper           IN INTEGER               --> codigo cooperativa
                           ,pr_idorigem           IN INTEGER               --> Origem da transação
                           ,pr_cdoperad           IN crapope.cdoperad%TYPE --> Codigo Opelrador
                           ,pr_cdpacote           IN INTEGER               --> codigo do pacote
                           ,pr_dtdiadebito        IN INTEGER               --> Dia do debito
                           ,pr_perdesconto_manual IN INTEGER               --> % desconto manual
                           ,pr_qtdmeses_desconto  IN INTEGER               --> qtd de meses de desconto
                           ,pr_nrdconta           IN crapass.nrdconta%TYPE --> nr da conta
                           ,pr_idparame_reciproci IN INTEGER               --> codigo de reciprocidade
                           ,pr_inpessoa           IN INTEGER               --> Tipo pessoa
                           ,pr_dtultdia           IN crapdat.dtultdia%TYPE --> Ultimo dia mes
                           ,pr_dtmvtolt           IN crapdat.dtmvtolt%TYPE --> Data corrente
                           ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic           OUT VARCHAR2             --> Descrição da crítica
                           ,pr_des_erro           OUT VARCHAR2             --> Saida OK/NOK
                           ,pr_rowid              OUT ROWID) IS            --> Rowid do registro inserido
    
    -- Busca valor da tarifa
    CURSOR cr_vltarifa (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdpacote IN tbtarif_pacotes_coop.cdpacote%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
      SELECT to_char(fco.vltarifa, 'fm999g999g999g990d00') vltarifa
        FROM tbtarif_pacotes tpac
            ,tbtarif_pacotes_coop tcoop
            ,crapfco fco
            ,crapfvl fvl
       WHERE tcoop.cdcooper = pr_cdcooper
         AND tcoop.cdpacote = pr_cdpacote
         AND tcoop.flgsituacao = 1
         AND tcoop.dtinicio_vigencia <= pr_dtmvtolt
         AND tpac.cdpacote = tcoop.cdpacote 
         AND tpac.tppessoa = pr_inpessoa
         AND fco.cdcooper = tcoop.cdcooper
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.flgvigen = 1
         AND fvl.cdtarifa = tpac.cdtarifa_lancamento;
    rw_vltarifa cr_vltarifa%ROWTYPE;
    
    -- Busca tipo de pessoa
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    --Variáveis auxiliares
    vr_existe_pacote      VARCHAR2(1);
    vr_dtinicio_vigencia  DATE;
    vr_idparame_reciproci tbrecip_parame_calculo.idparame_reciproci%TYPE;
    vr_indicador_geral    GENE0002.typ_split;
    vr_indicador_dados    GENE0002.typ_split;
    vr_dstransa           VARCHAR2(1000);
    vr_nrdrowid           ROWID;
    vr_flgfound           BOOLEAN;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    vr_tbtarif_pacotes TELA_ADEPAC.typ_tab_tbtarif_pacotes;

  BEGIN
  
    pr_des_erro := 'OK';
  
    vr_cdcooper := pr_cdcooper;
    vr_cdoperad := pr_cdoperad;
    vr_idorigem := pr_idorigem;
  
    
    -- Pega o primeiro dia do proximo mes
    vr_dtinicio_vigencia := to_date('01/04/2019','DD/MM/RRRR');
  
  /*  
    OPEN cr_vltarifa (pr_cdcooper => vr_cdcooper
                     ,pr_cdpacote => pr_cdpacote
                     ,pr_dtmvtolt => pr_dtmvtolt
                     ,pr_inpessoa => pr_inpessoa);
    FETCH cr_vltarifa INTO rw_vltarifa;
    vr_flgfound := cr_vltarifa%FOUND;
    CLOSE cr_vltarifa;
    IF NOT vr_flgfound THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Valor da tarifa não encontrado';
      RAISE vr_exc_erro;
    END IF;
  */
    
    vr_dstransa := 'Adesão serviços cooperativos';
    
    --Insere novo pacote
    BEGIN
      INSERT INTO tbtarif_contas_pacote (cdcooper
                                        ,nrdconta
                                        ,cdpacote
                                        ,dtadesao
                                        ,dtinicio_vigencia
                                        ,nrdiadebito
                                        ,indorigem
                                        ,flgsituacao
                                        ,perdesconto_manual
                                        ,qtdmeses_desconto
                                        ,cdreciprocidade
                                        ,cdoperador_adesao
                                        ,dtcancelamento)
                                VALUES (vr_cdcooper
                                       ,pr_nrdconta
                                       ,pr_cdpacote
                                       ,pr_dtmvtolt
                                       ,vr_dtinicio_vigencia
                                       ,pr_dtdiadebito
                                       ,1 -- Ayllos
                                       ,1 -- Ativo
                                       ,pr_perdesconto_manual
                                       ,pr_qtdmeses_desconto
                                       ,pr_idparame_reciproci
                                       ,vr_cdoperad
                                       ,NULL)
                RETURNING ROWID INTO pr_rowid;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        pr_rowid := NULL;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir novo servico cooperativo. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    
    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Codigo do servico'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => pr_cdpacote);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => '0,00');
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Dia do debito'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => pr_dtdiadebito);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Inicio da vigencia'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => to_char(vr_dtinicio_vigencia,'DD/MM/RRRR'));
    
    -- Efetua commit
--    COMMIT;
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_INCLUIR_PACOTE: ' || SQLERRM;
      
    
  END pc_incluir_pacote;
  
  
BEGIN 

  -- Iniciar Variáveis     
  vr_arq_path := gene0001.fn_diretorio(pr_tpdireto => 'M',pr_cdcooper => 0)||'cpd/bacas/SCTASK0048406/';

  IF NOT GENE0001.FN_EXIS_DIRETORIO(vr_arq_path) THEN
    -- Efetuar a criação do mesmo
    GENE0001.PC_OSCOMMAND_SHELL(PR_DES_COMANDO => 'mkdir ' || vr_arq_path ||
                                                  ' 1> /dev/null',
                                PR_TYP_SAIDA   => VR_TYP_SAIDA,
                                PR_DES_SAIDA   => VR_DES_SAIDA);
    --Se ocorreu erro dar RAISE
    IF VR_TYP_SAIDA = 'ERR' THEN
      VR_DSCRITIC := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                     VR_DES_SAIDA;
      RAISE VR_EXC_ERRO;
    END IF;
    -- Adicionar permissão total na pasta
    GENE0001.PC_OSCOMMAND_SHELL(PR_DES_COMANDO => 'chmod 777 ' ||
                                                  vr_arq_path ||
                                                  ' 1> /dev/null',
                                PR_TYP_SAIDA   => VR_TYP_SAIDA,
                                PR_DES_SAIDA   => VR_DES_SAIDA);
    --Se ocorreu erro dar RAISE
    IF VR_TYP_SAIDA = 'ERR' THEN
      VR_DSCRITIC := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                     VR_DES_SAIDA;
      RAISE VR_EXC_ERRO;
    END IF;
  END IF;

  



  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
  
  for r_cop in c_cop loop

    vr_tab_ass.DELETE;
    vr_index := 0;
    
    BEGIN 
    SELECT b.cdcooper, 
           b.nrdconta,
           b.inpessoa,
           decode(b.inpessoa,1,61,2,62) pacote
           BULK COLLECT INTO vr_tab_ass
      FROM crapass b
     WHERE b.cdcooper = r_cop.cdcooper
       AND b.inpessoa in (1,2)
       AND b.dtdemiss is null
       AND NOT EXISTS (SELECT 1
                         FROM tbtarif_contas_pacote c
                         WHERE c.cdcooper = b.cdcooper
                           AND c.nrdconta = b.nrdconta
                           AND c.flgsituacao = 1
                           AND c.dtcancelamento IS NULL);    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vr_dscritic := 'Dados não encontrados';
        RAISE vr_exc_saida;
      WHEN OTHERS THEN
        ROLLBACK;
    END;  
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(r_cop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    
    FOR vr_index IN 1..vr_tab_ass.COUNT LOOP
      
      pc_incluir_pacote(pr_cdcooper           => vr_tab_ass(vr_index).cdcooper --> codigo cooperativa
                       ,pr_idorigem           => 5                --> Origem da transação
                       ,pr_cdoperad           => '1'              --> Codigo Operador
                       ,pr_cdpacote           => vr_tab_ass(vr_index).pacote --> codigo do pacote
                       ,pr_dtdiadebito        => 1                --> Dia do debito
                       ,pr_perdesconto_manual => 0                --> % desconto manual
                       ,pr_qtdmeses_desconto  => 0                --> qtd de meses de desconto
                       ,pr_nrdconta           => vr_tab_ass(vr_index).nrdconta --> nr da conta
                       ,pr_idparame_reciproci => 0                --> codigo de reciprocidade
                       ,pr_inpessoa           => vr_tab_ass(vr_index).inpessoa --> tipo pessoa
                       ,pr_dtultdia           => rw_crapdat.dtultdia --> Ultimo dia
                       ,pr_dtmvtolt           => rw_crapdat.dtmvtolt --> Data corrente
                       ,pr_cdcritic           => vr_cdcritic      --> Código da crítica
                       ,pr_dscritic           => vr_dscritic      --> Descrição da crítica
                       ,pr_des_erro           => vr_des_erro      --> OK/NOK
                       ,pr_rowid              => vr_rowid);       --> Rowid do registro inserido
                       
                       
      IF vr_des_erro = 'NOK' OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
         dbms_output.put_line(vr_dscritic);
         ROLLBACK;
      END IF;
      
      --Caso a procedure encontre valor duplicado na hora de inserir
      --o rowid vira nulo
      IF vr_rowid IS NULL THEN
         CONTINUE;
      END IF;
      
      pc_escreve_xml( 'DELETE FROM TBTARIF_CONTAS_PACOTE WHERE ROWID = '''|| vr_rowid || '''' || ';' || chr(10) );               
      
      vr_countCommit := vr_countCommit+1;
      if vr_countCommit = 1000 then
        vr_countCommit := 1;
        commit;
      end if; 

    END LOOP;
    
  end loop; 

  pc_escreve_xml(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, 'BKP_PACOTE_TARIFA.txt', NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);  

  COMMIT;
  --ROLLBACK;
EXCEPTION
  WHEN vr_exc_saida THEN
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);  
    dbms_output.put_line(vr_dscritic);
    
    ROLLBACK;
  WHEN OTHERS THEN
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);  
     dbms_output.put_line('Erro: '||sqlerrm);
  
    ROLLBACK;  
END;
