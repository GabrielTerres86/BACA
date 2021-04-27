PL/SQL Developer Test script 3.0
316
declare 
  vr_nrproposta varchar2(30);
  vr_excsaida EXCEPTION;  
  -- Local variables here
  -- Busca uma cooperativa
   CURSOR cr_crapcop IS
      SELECT c.cdcooper
            ,c.dsdircop
            ,c.nmrescop
            , (SELECT dat.dtmvtolt
                FROM crapdat dat
                WHERE dat.cdcooper = c.cdcooper) dtmvtolt
        FROM crapcop c
       WHERE c.flgativo = 1                      -- Somente ativas
         AND c.cdcooper <> 3;
   
  vr_ind_arquiv      utl_file.file_type; 
  vr_destinatario_email varchar2(500):= gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL'); -- seguros@ailos.com.br
  
  vr_nrdeanos PLS_INTEGER;
  vr_tab_nrdeanos PLS_INTEGER;
  vr_nrdmeses PLS_INTEGER;
  vr_dsdidade VARCHAR2(50);
    
    -- Tratamento de erros   
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);
    vr_exc_erro  EXCEPTION;
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'JB_ARQPRST';

    -- Cursor generico de calendario
    vr_dtmvtolt  crapdat.dtmvtolt%type;
    vr_cdcooper  crapcop.cdcooper%TYPE;
    
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    
    vr_typ_saida    VARCHAR2(100);
    vr_des_saida    VARCHAR2(2000);
  
    vr_nmdircop   VARCHAR2(4000); 
    vr_nmarquiv   varchar2(100);
    -- Declarando handle do Arquivo
    vr_ind_arquivo utl_file.file_type;
    vr_index varchar2(50);
    vr_saldo_devedor number;
    
    vr_dsdemail VARCHAR2(100);
    vr_index_815 PLS_INTEGER := 0;
    vr_des_xml CLOB;
    vr_dsadesao VARCHAR2(100);
    vr_dir_relatorio_816 VARCHAR2(100);
    vr_arqhandle utl_file.file_type;

    TYPE typ_reg_prestamista IS RECORD(
      cdcooper crapcop.cdcooper%type,
      nrdconta crapass.nrdconta%type,
      nrcpfcgc crapass.nrcpfcgc%type,
      nmprimtl crapass.nmprimtl%type,
      nrctremp crapepr.nrctremp%TYPE,
      vlemprst crapepr.vlemprst%type,
      vlsdeved crapepr.vlsdeved%TYPE,
      dtmvtolt crapdat.dtmvtolt%TYPE,
      dtempres crapdat.dtmvtolt%TYPE);
    -- Definicao de tabela que compreende os registros acima declarados
    TYPE typ_tab_prestamista IS TABLE OF typ_reg_prestamista INDEX BY varchar2(50);

    vr_tab_prst typ_tab_prestamista;
 
    CURSOR cr_tbseg_prestamista(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE
                               ,pr_nrdconta IN tbseg_prestamista.nrdconta%TYPE
                               ,pr_nrctrato IN tbseg_prestamista.nrctremp%TYPE) IS
          SELECT seg.idseqtra,
                 seg.nrctrseg
            FROM tbseg_prestamista seg
           WHERE seg.cdcooper = pr_cdcooper
             AND seg.nrdconta = pr_nrdconta
             AND seg.nrctremp = pr_nrctrato;
        rw_tbseg_prestamista cr_tbseg_prestamista%ROWTYPE;
 ----------------------------------------------------------------
 ----------------------------------------------------------------
  --Procedure que escreve linha no arquivo CLOB
 PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      --Escrever no arquivo CLOB
      dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
 END pc_escreve_xml;
 
 -- Procedure para buscar resquicios na base, assim criamos prestamistas para
    -- formas de criacao de emprestimos que nao estejam com tratamento correto
    PROCEDURE pc_confere_base_emprest(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_cdcritic OUT PLS_INTEGER
                                     ,pr_dscritic OUT VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      DECLARE
        vr_exc_saida EXCEPTION;

        CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE) IS
                      SELECT EPR.*
                      FROM (
                        SELECT epr.nrctremp
                              ,epr.nrdconta
                              ,epr.vlsdeved
                              ,SUM( epr.vlsdeved) OVER(PARTITION BY epr.cdcooper, epr.nrdconta )  Saldo_Devedor
                              ,ass.nrcpfcgc
                              ,ass.nmprimtl
                              ,ass.cdagenci
                              ,ass.cdcooper
                              ,epr.dtmvtolt
                              ,to_number(substr(( SELECT dstextab
                                          from craptab b
                                         where b.cdcooper = epr.cdcooper
                                           and b.cdempres = 11
                                           and b.nmsistem = 'CRED'
                                           AND b.tptabela = 'USUARI'
                                           and b.cdacesso = 'SEGPRESTAM'
                                           and b.tpregist = 0),
                                        27,
                                        12),'fm999999999990d00', 'nls_numeric_characters = '',.''') vlminimo
                          FROM crapepr epr
                              ,crapass ass
                              ,craplcr lcr
                         WHERE ass.cdcooper = pr_cdcooper
                           AND ass.cdcooper = epr.cdcooper
                           AND ass.nrdconta = epr.nrdconta
                           AND lcr.cdcooper = epr.cdcooper
                           AND lcr.cdlcremp = epr.cdlcremp
                           AND ass.inpessoa = 1 --> Somente fisica
                           AND epr.inliquid = 0 --> Em aberto
                           AND epr.inprejuz = 0 --> Sem prejuizo
                           AND epr.dtmvtolt >= to_date('31/01/2000', 'DD/MM/RRRR') --> Data da tab049
                           AND lcr.flgsegpr = 1
                      ) EPR WHERE Saldo_Devedor > vlminimo --> Para evitar buscar registros desnecessarios
                              AND NOT EXISTS ( SELECT seg.idseqtra
                                                 FROM tbseg_prestamista seg
                                                WHERE seg.cdcooper = epr.cdcooper
                                                  AND seg.nrdconta = epr.nrdconta
                                                  AND seg.nrctremp = epr.nrctremp);
        rw_crapepr cr_crapepr%ROWTYPE;

    BEGIN
      vr_tab_prst.delete;

      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper) LOOP

        SEGU0003.pc_efetiva_proposta_sp(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapepr.nrdconta
                                       ,pr_nrctrato => rw_crapepr.nrctremp
                                       ,pr_cdagenci => rw_crapepr.cdagenci
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => 1
                                       ,pr_nmdatela => 'ENV_PRST'
                                       ,pr_idorigem => 7
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) <> '' THEN
          -- Envio centralizado de log de erro
          RAISE vr_exc_saida;
        END IF;
        vr_saldo_devedor := rw_crapepr.Saldo_Devedor ;
        vr_index:= rw_crapepr.nrdconta ||rw_crapepr.nrctremp;
        vr_tab_prst(vr_index).cdcooper:= rw_crapepr.cdcooper;
        vr_tab_prst(vr_index).nrdconta:= rw_crapepr.nrdconta;
        vr_tab_prst(vr_index).nmprimtl:= rw_crapepr.nmprimtl;
        vr_tab_prst(vr_index).nrcpfcgc:= rw_crapepr.nrcpfcgc;
        vr_tab_prst(vr_index).nrctremp:= rw_crapepr.nrctremp;
        vr_tab_prst(vr_index).vlemprst:= rw_crapepr.vlsdeved;
        vr_tab_prst(vr_index).vlsdeved:= rw_crapepr.Saldo_Devedor;
        vr_tab_prst(vr_index).dtmvtolt:= vr_dtmvtolt ;
        vr_tab_prst(vr_index).dtempres:= rw_crapepr.dtmvtolt;

        COMMIT; -- Commit a cada registro
      END LOOP;
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          ROLLBACK;                  -- Efetuar rollback
                                                                  -- Envio centralizado de log de erro
          cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                 pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                                 pr_cdcooper           => pr_cdcooper, -- tbgen_prglog
                                 pr_tpexecucao         => 2,           -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 pr_tpocorrencia       => 0,           -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                                 pr_cdcriticidade      => 2,           -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 pr_dsmensagem         => vr_dscritic, -- tbgen_prglog_ocorrencia
                                 pr_flgsucesso         => 0,           -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                                 pr_nmarqlog           => NULL,
                                 pr_idprglog           => vr_idprglog);

        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
          pr_dscritic := vr_dscritic;

          ROLLBACK;        -- Efetuar rollback
                                                                    -- Envio centralizado de log de erro
          cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                 pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                                 pr_cdcooper           => pr_cdcooper, -- tbgen_prglog
                                 pr_tpexecucao         => 2,           -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 pr_tpocorrencia       => 0,           -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                                 pr_cdcriticidade      => 2,           -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 pr_dsmensagem         => vr_dscritic, -- tbgen_prglog_ocorrencia
                                 pr_flgsucesso         => 0,           -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                                 pr_nmarqlog           => NULL,
                                 pr_destinatario_email => vr_destinatario_email,
                                 pr_idprglog           => vr_idprglog);
      END;
    END pc_confere_base_emprest;
 
begin

  for rw_crapcop in cr_crapcop loop

      vr_dtmvtolt := rw_crapcop.dtmvtolt;
      vr_cdcooper := rw_crapcop.cdcooper; -- Para log em caso de exceção imprevista

      -- Validamos/vinculamos contratos que ainda não foram adicionados na base
      pc_confere_base_emprest(pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl816><dados>');
      vr_index := vr_tab_prst.first;
      WHILE vr_index IS NOT NULL LOOP
         OPEN cr_tbseg_prestamista(pr_cdcooper => vr_tab_prst(vr_index).cdcooper
                                  ,pr_nrdconta => vr_tab_prst(vr_index).nrdconta
                                  ,pr_nrctrato => vr_tab_prst(vr_index).nrctremp);
          FETCH cr_tbseg_prestamista INTO rw_tbseg_prestamista;
          IF cr_tbseg_prestamista%NOTFOUND THEN
            CLOSE cr_tbseg_prestamista;
            vr_index := vr_tab_prst.next(vr_index);
            CONTINUE;
          ELSE
            CLOSE cr_tbseg_prestamista;
          END IF;

          IF cr_tbseg_prestamista%ISOPEN THEN
            CLOSE cr_tbseg_prestamista;
          END IF;

          pc_escreve_xml('<registro>'
          ||'<nmrescop>' || rw_crapcop.nmrescop || '</nmrescop>' ||
                         '<nrdconta>' || gene0002.fn_mask_conta(vr_tab_prst(vr_index).nrdconta) || '</nrdconta>' ||
                         '<nrcpfcgc>' || gene0002.fn_mask_cpf_cnpj(vr_tab_prst(vr_index).nrcpfcgc, 1) || '</nrcpfcgc>' ||
                         '<nmprimtl>' || vr_tab_prst(vr_index).nmprimtl || '</nmprimtl>' ||
                         '<nrctremp>' || TRIM(gene0002.fn_mask_contrato(vr_tab_prst(vr_index).nrctremp)) || '</nrctremp>' ||
                         '<nrctrseg>' || TRIM(gene0002.fn_mask_contrato(rw_tbseg_prestamista.nrctrseg)) || '</nrctrseg>' ||
                         '<dtmvtolt>' || TO_CHAR(vr_tab_prst(vr_index).dtmvtolt , 'DD/MM/RRRR') || '</dtmvtolt>' ||
                         '<dtempres>' || TO_CHAR(vr_tab_prst(vr_index).dtempres  , 'DD/MM/RRRR') || '</dtempres>' ||
                         '<vlemprst>' || to_char(vr_tab_prst(vr_index).vlemprst,'fm99999999999990d00') || '</vlemprst>' ||
                         '<vlsdeved>' || to_char(vr_tab_prst(vr_index).vlsdeved,'fm99999999999990d00') || '</vlsdeved>'
          ||'</registro>');

          vr_index := vr_tab_prst.next(vr_index);
       END LOOP;

       pc_escreve_xml(  '</dados>'||
                      '</crrl816>');
       gene0001.pc_fecha_arquivo(vr_arqhandle);

       vr_dir_relatorio_816 := gene0001.fn_diretorio('C', rw_crapcop.cdcooper, 'rl') || '/crrl816.lst';

       gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra                 --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapcop.dtmvtolt         --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml                  --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl816'                  --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl816.jasper'            --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                        --> Nao tem parametros
                                  ,pr_dsarqsaid => vr_dir_relatorio_816        --> Arquivo final
                                  ,pr_cdrelato  => 816
                                  ,pr_flg_gerar => 'S'
                                  ,pr_qtcoluna  => 234
                                  ,pr_sqcabrel  => 1
                                  ,pr_nmformul  => '234col'
                                  ,pr_flg_impri => 'S'
                                  ,pr_nrcopias  => 1
                                  ,pr_nrvergrl  => 1
                                  ,pr_des_erro  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_erro;
      END IF;
     
    -- Commit a cada cooperativa
    commit; 
  end loop;  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';

EXCEPTION
  WHEN vr_excsaida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
1
vr_dscritic
0
5
2
rw_crapcop.cdcooper
rw_crapcop.nmrescop
