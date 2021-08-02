begin
    declare
      vr_dscritic  VARCHAR2(4000);
      vr_cdcritic  numeric(18);
      vr_idprglog  numeric(18);
    CURSOR cr_crapcop IS
      SELECT c.cdcooper
            ,c.dsdircop
            ,c.nmrescop                   
        FROM crapcop c
       WHERE c.flgativo = 1                        -- Somente ativas     
         AND not c.cdcooper in (1,3)                      -- nao será gerado para central
       order by c.cdcooper desc ;
  rw_crapcop cr_crapcop%ROWTYPE;                
  
  
 PROCEDURE pc_envia_arq_seg_prst_coop_temp( pr_cdcooper in crapcop.cdcooper%TYPE --> Critica encontrada
                                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                           ,pr_dscritic OUT VARCHAR2) IS --> Texto de erro/critica encontrada
 BEGIN

  DECLARE
  
    TYPE typ_reg_crrl815 IS
    RECORD (cdcooper tbseg_prestamista.cdcooper%TYPE
           ,nrdconta tbseg_prestamista.nrdconta%TYPE
           ,cdagenci crapass.cdagenci%TYPE
           ,dtmvtolt crapdat.dtmvtolt%TYPE
           ,dtinivig crapdat.dtmvtolt%TYPE
           ,dtrefcob crapdat.dtmvtolt%TYPE
           ,nmrescop crapcop.nmrescop%TYPE
           ,vlenviad NUMBER(25,2)
           ,dsregist VARCHAR2(20)
           ,inpessoa PLS_INTEGER
           ,tpregist tbseg_prestamista.tpregist%TYPE
           ,nmprimtl tbseg_prestamista.nmprimtl%TYPE
           ,nrcpfcgc tbseg_prestamista.nrcpfcgc%TYPE
           ,nrctrseg  varchar2(15)
           ,nrctremp tbseg_prestamista.nrctremp%TYPE
           ,vlprodut tbseg_prestamista.vlprodut%TYPE
           ,vlsdeved tbseg_prestamista.vlsdeved%TYPE);

    -- Definicao do tipo de tabela para o relatorio 815
    TYPE typ_tab_crrl815 IS
    TABLE OF typ_reg_crrl815
    INDEX BY VARCHAR2(30);

    vr_crrl815 typ_tab_crrl815 ; 
    vr_tab_crrl815 typ_tab_crrl815;

    TYPE pl_tipo_registros IS
    RECORD (tpregist VARCHAR2(20));

    TYPE typ_registros IS
    TABLE OF pl_tipo_registros
    INDEX BY PLS_INTEGER;

    vr_tipo_registro typ_registros;
    
    TYPE typ_reg_totais_crrl815 IS
    RECORD (vlpremio NUMBER(25,2),
            slddeved NUMBER(25,2),
            qtdadesao PLS_INTEGER,
            dsadesao VARCHAR(20));

    TYPE typ_tab_totais_crrl815 IS
    TABLE OF typ_reg_totais_crrl815
    INDEX BY VARCHAR2(100);

    vr_totais_crrl815 typ_tab_totais_crrl815;
        
    TYPE typ_reg_totDAT IS
      RECORD (vlpremio NUMBER(25,2),
              slddeved NUMBER(25,2));
    
    -- Tabela para armazenar os saldo devedores por PAC:
    TYPE typ_tab_sldevpac IS
      TABLE OF typ_reg_totDAT
        INDEX BY PLS_INTEGER; --> Número do PAC sera a chave
    vr_tab_sldevpac typ_tab_sldevpac;
    
    vr_vltotarq NUMBER(30,10);  --> total do lancamento geração arquivo prj421
    vr_flgachou BOOLEAN := FALSE;      -- Encontrou registro Sim/Não   
    vr_percpagt NUMBER(20,15);    
    -- Totalizadores
    vr_vltotdiv NUMBER(30,10):= 0;-- Total da divida
    vr_qttotdiv PLS_INTEGER := 0; -- Quantidade de associados
    vr_vlttpgto NUMBER;           -- Valor pago de seguro
    vr_vlpagseg NUMBER(18,10);    -- % pagto seguradora
    vr_vlenviad NUMBER;
    vr_dstextab  craptab.dstextab%TYPE; --> Busca na craptab
      vr_tab_vlmaximo NUMBER;
      vr_tab_vlminimo NUMBER;
      vr_tab_vltabela NUMBER(6,5);
      vr_tab_dtiniseg DATE;
      vr_ultimodiaMes DATE;
      vr_diames varchar(2);
      vr_diasem number(1);     
    -- tabela para armazenar valores de lancamento no arquivo contabil por agencia PRJ421
    TYPE typ_tab_lancarq IS 
      TABLE OF NUMBER(30,10) INDEX BY PLS_INTEGER;          
    vr_tab_lancarq typ_tab_lancarq;
    
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
    vr_destinatario_email VARCHAR2(500);
    vr_destinatario_email2 VARCHAR2(500);    
      
    vr_nmdircop   VARCHAR2(4000); 
    vr_nmarquiv   varchar2(100);
    -- Declarando handle do Arquivo
    vr_ind_arquivo utl_file.file_type;
    vr_index varchar2(50);
    vr_saldo_devedor number;
    -- Dados idade  
    vr_nrdeanos PLS_INTEGER;
    vr_tab_nrdeanos PLS_INTEGER;
    vr_nrdmeses PLS_INTEGER;
    vr_dsdidade VARCHAR2(50);
    
    vr_dsdemail VARCHAR2(100);
    vr_index_815 PLS_INTEGER := 0;
    vr_des_xml CLOB;
    vr_dsadesao VARCHAR2(100);
    vr_dir_relatorio_815 VARCHAR2(100);
    vr_dir_relatorio_816 VARCHAR2(100);
    vr_arqhandle utl_file.file_type;

      -- Nome do arquivo DAT para sistema Mathera (Sistema Contábil)
      vr_arquivo_txt         utl_file.file_type;
      vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
      vr_nom_diretorio       varchar2(200);    
      vr_dsdircop            varchar2(200);      
      vr_nmarqdat            varchar2(50);
      vr_dtmvtolt_yymmdd     VARCHAR2(8);
      vr_idx_lancarq PLS_INTEGER;
      vr_linhadet VARCHAR(4000);
      vr_typ_said VARCHAR2(4);
      -- Saldo e controle por CPF
      vr_vlsdeved NUMBER(24,10); --> Total saldo devedor
      vr_nmsegura            VARCHAR2(200); -- nome seguradora


    TYPE typ_reg_prestamista IS RECORD(
      cdcooper crapcop.cdcooper%type,
      nrdconta crapass.nrdconta%type,
      cdagenci crapass.cdagenci%type,
      nrcpfcgc crapass.nrcpfcgc%type,
      nmprimtl crapass.nmprimtl%type,
      nrctremp crapepr.nrctremp%TYPE,
      vlemprst crapepr.vlemprst%type,
      vlsdeved crapepr.vlsdeved%TYPE,
      vldevatu tbseg_prestamista.vldevatu%TYPE,
      dtmvtolt crapdat.dtmvtolt%TYPE,
      dtempres crapdat.dtmvtolt%TYPE);
    -- Definicao de tabela que compreende os registros acima declarados
    TYPE typ_tab_prestamista IS TABLE OF typ_reg_prestamista INDEX BY varchar2(50);

    vr_tab_prst typ_tab_prestamista;   
     
    ---------------------------------- CURSORES  ----------------------------------

    -- Busca uma cooperativa
    CURSOR cr_crapcop(pr_cdcooper in crapcop.cdcooper%type) IS
      SELECT c.cdcooper
            ,c.dsdircop
            ,c.nmrescop
            , (SELECT dat.dtmvtolt
                FROM crapdat dat 
                WHERE dat.cdcooper = c.cdcooper) dtmvtolt         
        FROM crapcop c
       WHERE c.flgativo = 1                      -- Somente ativas
         AND c.cdcooper = pr_cdcooper ;
    rw_crapcop cr_crapcop%ROWTYPE;
    
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
   ---------------------------------------
   ---------------------------------------
   
   procedure pc_gera_proposta (pr_cdcooper in tbseg_prestamista.cdcooper%type
                              ,pr_nrdconta in tbseg_prestamista.nrdconta%type
                              ,pr_nrctremp in tbseg_prestamista.nrctremp%type
                              ,pr_tpregist in tbseg_prestamista.tpregist%type
                              ,pr_cdapolic in tbseg_prestamista.cdapolic%type
                              ,pr_nrproposta in out varchar2
                              ,pr_cdcritic out pls_integer
                              ,pr_dscritic out varchar2) is
   begin
    declare   
      vr_exc_saida           EXCEPTION;
      begin
        pr_nrproposta := SEGU0003.FN_NRPROPOSTA(); 
           
            begin            
              update tbseg_prestamista g 
                 set g.nrproposta = pr_nrproposta
               where g.cdapolic = pr_cdapolic;
            exception
              when others then
                vr_dscritic:= 'Erro ao gravar numero de proposta pc_gera_proposta 1: '||pr_nrproposta||' - '||sqlerrm;
                raise vr_exc_saida;              
            end;
          
            begin            
              update crawseg g 
                 set g.nrproposta = pr_nrproposta
               where g.cdcooper = pr_cdcooper
                 and g.nrdconta = pr_nrdconta
                 and g.nrctrato = pr_nrctremp;      
            exception
              when others then
                vr_dscritic:= 'Erro ao gravar numero de proposta pc_gera_proposta 2: '||pr_nrproposta||' - '||sqlerrm;
                raise vr_exc_saida;                
            end;
            
           commit;
     exception
       WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            
          ROLLBACK;
       when others then
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            
          ROLLBACK;
     end;  
     
   end pc_gera_proposta;
   
   
    procedure pc_verifica_proposta(pr_cdcooper in crapcop.cdcooper%type
                                  ,pr_cdcritic out pls_integer
                                  ,pr_dscritic out varchar2) is
    begin
     declare
       -- verificar propostas duplicadas
       cursor cr_proposta is
       select a.nrproposta, count(a.nrproposta) qtd
         from tbseg_prestamista a 
        where a.cdcooper = pr_cdcooper
          and a.tpregist in(1,2,3)
           group by a.nrproposta
        having count(1) > 1;
        
        -- percorrer as proposta duplicadas
        cursor cr_tbseg_prestamista (pr_nrproposta varchar2) is
        select a.cdcooper
              ,a.nrctremp
              ,a.cdapolic
              ,a.nrdconta
              ,a.nrctrseg
          from tbseg_prestamista a
         where a.nrproposta = pr_nrproposta;
         
        -- verificar propostas zeradas
       cursor cr_proposta_zerada is
       select a.cdcooper
             ,a.nrctremp
             ,a.cdapolic
             ,a.nrdconta
             ,a.nrctrseg
         from tbseg_prestamista a 
        where a.cdcooper = pr_cdcooper
          and a.tpregist in(1, 2, 3)           
          and nvl(a.nrproposta,0) = 0;
           
       --Buscar os registros duplicados
        CURSOR cr_registros IS
        select a.*
                from tbseg_prestamista a,
                     (select max(IDSEQTRA) as IDSEQTRA,
                             cdcooper,
                             nrdconta,
                             nrctremp,
                             count(nrctremp)
                        from tbseg_prestamista c
                       where c.cdcooper = pr_cdcooper
                         and c.tpregist in (1, 3)
                       group by cdcooper, nrdconta, nrctremp
                      having count(1) > 1) b
               where a.cdcooper = b.cdcooper
                 and a.nrdconta = b.nrdconta
                 and a.nrctremp = b.nrctremp
                 and a.IDSEQTRA <> b.IDSEQTRA;
        rw_registro cr_registros%rowtype;     
          
       vr_nrproposta varchar2(15);        
       -- Variaveis
       vr_exc_saida           EXCEPTION;
     begin
     
      for rw_proposta in cr_proposta loop
          
         FOR rw_tbseg_prestamista IN cr_tbseg_prestamista(pr_nrproposta => rw_proposta.nrproposta) LOOP

           vr_nrproposta := SEGU0003.FN_NRPROPOSTA();

            begin            
              update tbseg_prestamista g 
                 set g.nrproposta = vr_nrproposta
               where g.cdapolic = rw_tbseg_prestamista.cdapolic;
            exception
              when others then
                vr_dscritic:= 'Erro ao gravar numero de proposta 1: '||vr_nrproposta||' - '||sqlerrm;
                raise vr_exc_saida;              
            end;
             
            begin            
              update crawseg g 
                 set g.nrproposta = vr_nrproposta
               where g.cdcooper = rw_tbseg_prestamista.cdcooper
                 and g.nrdconta = rw_tbseg_prestamista.nrdconta
                 and g.nrctrseg = rw_tbseg_prestamista.nrctrseg
                 and g.nrctrato = rw_tbseg_prestamista.nrctremp;
            exception
              when others then
                vr_dscritic:= 'Erro ao gravar numero de proposta 2: '||vr_nrproposta||' - '||sqlerrm;
                raise vr_exc_saida;                
            end;
            
           commit;
         end loop;
       end loop; -- Fim cr_proposta
       
       -- Verifica propostas zeradas(nao geradas)
       FOR rw_proposta_zerada IN cr_proposta_zerada LOOP

           vr_nrproposta := SEGU0003.FN_NRPROPOSTA(); 
           
            begin            
              update tbseg_prestamista g 
                 set g.nrproposta = vr_nrproposta
               where g.cdapolic = rw_proposta_zerada.cdapolic;
            exception
              when others then
                vr_dscritic:= 'Erro ao gravar numero de proposta 3: '||vr_nrproposta||' - '||sqlerrm;
                raise vr_exc_saida;              
            end;
             
            begin            
              update crawseg g 
                 set g.nrproposta = vr_nrproposta
               where g.cdcooper = rw_proposta_zerada.cdcooper
                 and g.nrdconta = rw_proposta_zerada.nrdconta
                 and g.nrctrseg = rw_proposta_zerada.nrctrseg               
                 and g.nrctrato = rw_proposta_zerada.nrctremp;      
            exception
              when others then
                vr_dscritic:= 'Erro ao gravar numero de proposta 4: '||vr_nrproposta||' - '||sqlerrm;
                raise vr_exc_saida;                
            end;
            
           commit;
         end loop; -- Fim cr_proposta_zerada
       
       -- Remove registros duplicados
       for rw_registro in cr_registros loop            
          begin            
              delete from TBSEG_PRESTAMISTA where IDSEQTRA = rw_registro.IDSEQTRA;    
          exception
            when others then
              vr_dscritic:= 'Erro ao excluir rw_registro'||' - '||sqlerrm;
              raise vr_exc_saida;              
          end;          
       end loop;
       commit;
      exception
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            
          ROLLBACK;
       when others then
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            
          ROLLBACK;
      end;     
    end pc_verifica_proposta;

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
                                        12),'fm999999999990d00',  'nls_numeric_characters = '',.''') vlminimo
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
        vr_tab_prst(vr_index).cdagenci:= rw_crapepr.cdagenci;        
        vr_tab_prst(vr_index).nmprimtl:= rw_crapepr.nmprimtl;
        vr_tab_prst(vr_index).nrcpfcgc:= rw_crapepr.nrcpfcgc;
        vr_tab_prst(vr_index).nrctremp:= rw_crapepr.nrctremp;
        vr_tab_prst(vr_index).vlemprst:= rw_crapepr.vlsdeved;
        vr_tab_prst(vr_index).vlsdeved:= rw_crapepr.Saldo_Devedor;
        vr_tab_prst(vr_index).dtmvtolt:= vr_dtmvtolt ; 
        vr_tab_prst(vr_index).dtempres:= rw_crapepr.dtmvtolt;
        
        COMMIT;                                      -- Commit a cada registro
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
    ------------------------- PROCEDIMENTOS INTERNOS -----------------------------   
    PROCEDURE pc_atualiza_tabela(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_cdcritic OUT PLS_INTEGER
                                ,pr_dscritic OUT VARCHAR2) IS
    BEGIN
      DECLARE
        -- cursor principal da tabela
        CURSOR cr_prestamista(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE) IS
        Select a.* from 
         (SELECT p.cdcooper, p.nrdconta
               , p.nrctremp, p.nrctrseg
               , t.idseqttl, p.tpregist
               , nvl(p.dtnasctl
               , ( SELECT a.dtnasctl 
                     FROM crapass a 
                    WHERE a.cdcooper = p.cdcooper  
                      AND a.nrdconta = p.nrdconta)) dtnasctl                            
               ,e.inliquid, CASE WHEN e.inliquid = 1 THEN 0 ELSE e.vlsdeved END SaldoAtualizado    
               , p.vldevatu ,p.dtnasctl dtnasctl1
               , case when ( ( CASE WHEN e.inliquid = 1 THEN 0 ELSE e.vlsdeved END) = 0 AND p.tpregist = 1 ) then 0 else p.tpregist  end  Tiporeg
               ,DECODE(t.cdsexotl, 2, '2', 1, '1', '1') cdsexotl_ttl -- sexo 2=F/1=M
               ,p.cdsexotl cdsexotl_tbseg
               ,p.cdapolic
            FROM tbseg_prestamista p
                ,crapepr e
                ,crapttl t
           WHERE p.cdcooper = pr_cdcooper
             AND e.cdcooper = p.cdcooper
             AND e.nrdconta = p.nrdconta
             AND e.nrctremp = p.nrctremp
             AND t.cdcooper = p.cdcooper
             AND t.nrdconta = p.nrdconta
             AND t.idseqttl = 1
             and p.vldevatu <> 0 -- garantimos que nao vamos rodar um contrato já liquidado mais de uma vez        
         ) a WHERE 
               NOT (ROUND(vldevatu,2) = ROUND(SaldoAtualizado,2)
                AND dtnasctl1 = dtnasctl
                AND tpregist = Tiporeg
                AND cdsexotl_ttl = cdsexotl_tbseg);             
                 
        rw_prestamista cr_prestamista%ROWTYPE; 
        -- Variaveis
        vr_exc_saida           EXCEPTION;        
      BEGIN
        
        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP

          BEGIN 
            UPDATE tbseg_prestamista p
               SET p.vldevatu = rw_prestamista.SaldoAtualizado
                 , p.dtnasctl = rw_prestamista.dtnasctl
                 , p.tpregist = rw_prestamista.Tiporeg
                 , p.cdsexotl = rw_prestamista.cdsexotl_ttl
             WHERE p.cdcooper = pr_cdcooper
               AND p.nrdconta = rw_prestamista.nrdconta
               AND p.nrctrseg = rw_prestamista.nrctrseg
               AND p.nrctremp = rw_prestamista.nrctremp
               and p.cdapolic = rw_prestamista.cdapolic;

          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END; 
          
          COMMIT;         -- commitamos a atualizacao a cada registro para evitar demasiadas cargas de memoria  e evitar longos locks
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
          
          ROLLBACK;                    -- Efetuar rollback
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
    END pc_atualiza_tabela;
    
    PROCEDURE pc_replica_cancelado(pr_cdcooper  IN tbseg_prestamista.cdcooper%TYPE
                                  ,pr_nrdconta  IN tbseg_prestamista.nrdconta%TYPE
                                  ,pr_nrctremp  IN tbseg_prestamista.nrctremp%TYPE
                                  ,pr_dtemprst  in tbseg_prestamista.dtdevend%type                                  
                                  ,pr_cdapolic   OUT tbseg_prestamista.cdapolic%TYPE
                                  ,pr_nrproposta out tbseg_prestamista.nrproposta%type
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada)
    PRAGMA AUTONOMOUS_TRANSACTION;  
    BEGIN 
      DECLARE
        CURSOR cr_prest(pr_cdcooper  IN tbseg_prestamista.cdcooper%TYPE
                       ,pr_nrdconta  IN tbseg_prestamista.nrdconta%TYPE
                       ,pr_nrctremp  IN tbseg_prestamista.nrctremp%TYPE) IS
          SELECT * 
            FROM tbseg_prestamista t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.nrctremp = pr_nrctremp
             and t.tpregist = 2;
        rw_prest cr_prest%ROWTYPE;
        
        vr_dsdemail VARCHAR2(100);
        VR_NRPROPOSTA varchar2(15);
      BEGIN
        OPEN cr_prest(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
        FETCH cr_prest INTO rw_prest;
        CLOSE cr_prest;
        
        vr_dsdemail := rw_prest.dsdemail;
        SEGU0003.pc_limpa_email(vr_dsdemail);
        
        VR_NRPROPOSTA := SEGU0003.FN_NRPROPOSTA();      

        INSERT INTO tbseg_prestamista (
            cdcooper
           ,nrdconta
           ,nrctrseg
           ,tpregist
           ,cdapolic
           ,nrcpfcgc
           ,nmprimtl
           ,dtnasctl
           ,cdsexotl
           ,dsendres
           ,dsdemail
           ,nmbairro
           ,nmcidade
           ,cdufresd
           ,nrcepend
           ,nrtelefo
           ,dtdevend
           ,dtinivig
           ,nrctremp
           ,cdcobran
           ,cdadmcob
           ,tpfrecob
           ,tpsegura
           ,cdprodut
           ,cdplapro
           ,vlprodut
           ,tpcobran
           ,vlsdeved
           ,vldevatu
           ,dtrefcob
           ,dtfimvig
           ,dtdenvio
           ,nrproposta
          ) VALUES (
            rw_prest.cdcooper
           ,rw_prest.nrdconta
           ,rw_prest.nrctrseg
           ,3 -- ja seta o proximo estado como endosso
           ,fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0) -- novo certificado
           ,rw_prest.nrcpfcgc
           ,gene0007.fn_caract_especial(rw_prest.nmprimtl)
           ,rw_prest.dtnasctl
           ,rw_prest.cdsexotl
           ,gene0007.fn_caract_especial(rw_prest.dsendres)
           ,vr_dsdemail
           ,gene0007.fn_caract_especial(rw_prest.nmbairro)
           ,gene0007.fn_caract_especial(rw_prest.nmcidade)
           ,rw_prest.cdufresd
           ,rw_prest.nrcepend
           ,rw_prest.nrtelefo
           ,pr_dtemprst -- data de venda
           ,sysdate -- inicio da vigencia
           ,rw_prest.nrctremp
           ,rw_prest.cdcobran
           ,rw_prest.cdadmcob
           ,rw_prest.tpfrecob
           ,rw_prest.tpsegura
           ,rw_prest.cdprodut
           ,rw_prest.cdplapro
           ,rw_prest.vlprodut
           ,rw_prest.tpcobran
           ,rw_prest.vlsdeved
           ,rw_prest.vldevatu
           ,rw_prest.dtrefcob
           ,rw_prest.dtfimvig
           ,vr_dtmvtolt      
           ,VR_NRPROPOSTA    
         ) RETURNING cdapolic INTO pr_cdapolic;
         
         begin 
           UPDATE crawseg 
              SET nrproposta = VR_NRPROPOSTA
           WHERE cdcooper = pr_cdcooper
             and nrdconta = pr_nrdconta
             and nrctrato = pr_nrctremp;
         exception 
           when others then
             vr_dscritic:= 'Erro ao atualizar crawseg (replica_cancelado) '||sqlerrm;
             raise vr_exc_erro;
         end;
               
         pr_nrproposta := VR_NRPROPOSTA;
         
         COMMIT;
      EXCEPTION
        when vr_exc_erro then
          pr_cdcritic:= nvl(vr_cdcritic,0);
          pr_dscritic:= vr_dscritic;          
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao criar certificado para reenvio de cancelado - Cooper:' || pr_cdcooper || ' - Conta: ' || pr_nrdconta || ' - pc_replica_cancelado';
      END;
    END pc_replica_cancelado;
    
    -- Procedure principal responsavel pela execução das cooperativas
    PROCEDURE pc_gera_arquivo_coop(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada)
    BEGIN
      DECLARE
        vr_exc_saida  EXCEPTION;
        vr_tipo_saida VARCHAR2(100);
        
        vr_nrsequen  NUMBER(5);
        vr_endereco  VARCHAR2(100);    
        vr_login     VARCHAR2(100);
        vr_senha     VARCHAR2(100);
        vr_seqtran   INTEGER;
        vr_vlsdatua  NUMBER;
        vr_vlminimo  NUMBER;
        vr_vlsdeved  NUMBER := 0;
        vr_tpregist  INTEGER;
        vr_NRPROPOSTA tbseg_prestamista.NRPROPOSTA%TYPE;
        vr_cdapolic  tbseg_prestamista.cdapolic%TYPE;
        vr_cdapolic_canc  tbseg_prestamista.cdapolic%TYPE;
        vr_dtdevend  tbseg_prestamista.dtdevend%TYPE;
        vr_dtinivig  tbseg_prestamista.dtinivig%TYPE;
        vr_flgnvenv  BOOLEAN;
        vr_nrdmeses NUMBER;
        vr_contrcpf tbseg_prestamista.nrcpfcgc%TYPE;

        vr_vltotenv NUMBER;
        vr_vlmaximo NUMBER;
        vr_dscorpem VARCHAR2(2000);
        vr_nmrescop crapcop.nmrescop%TYPE;
        vr_apolice  VARCHAR2(20);
        -- Variaveis para o arquivo
        vr_nmdircop  VARCHAR2(100);
        vr_nmarquiv  VARCHAR2(100);
        vr_linha_txt VARCHAR2(32600);
        vr_ultimoDia DATE;
        vr_pgtosegu  NUMBER;
        vr_vlprodvl  NUMBER;
        vr_dtfimvig  date;
        
        -- Declarando handle do Arquivo
        vr_ind_arquivo utl_file.file_type;
        
        -- Busca da idade limite
        CURSOR cr_craptsg(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT nrtabela
            FROM craptsg
           WHERE cdcooper = pr_cdcooper
             AND tpseguro = 4
             AND tpplaseg = 1
             AND cdsegura = SEGU0001.busca_seguradora; -- CODITO DA SEGURADORA 
    
        -- Cursor principal prestamista
        CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT p.idseqtra
                ,p.cdcooper
                ,p.nrdconta
                ,ass.cdagenci
                ,p.nrctrseg
                ,p.tpregist
                ,p.cdapolic
                ,p.nrcpfcgc
                ,p.nmprimtl
                ,p.dtnasctl
                ,p.cdsexotl
                ,p.dsendres
                ,p.dsdemail
                ,p.nmbairro
                ,p.nmcidade
                ,p.cdufresd
                ,p.nrcepend
                ,p.nrtelefo
                ,p.dtdevend
                ,p.dtinivig
                ,p.nrctremp
                ,p.cdcobran
                ,p.cdadmcob
                ,p.tpfrecob
                ,p.tpsegura
                ,p.cdplapro
                ,p.vlprodut
                ,p.tpcobran
                ,p.vlsdeved
                ,p.vldevatu
                ,p.dtfimvig
                ,c.inliquid
                ,c.dtmvtolt data_emp
                ,p.nrproposta
                ,lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
                ,SUM(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf
                ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
            FROM tbseg_prestamista p, crapepr c, crapass ass
           WHERE p.cdcooper = pr_cdcooper    
             AND c.cdcooper = p.cdcooper
             AND c.nrdconta = p.nrdconta
             AND c.nrctremp = p.nrctremp             
             AND ass.cdcooper = c.cdcooper
             AND ass.nrdconta = c.nrdconta             
             AND p.tpregist <> 0      -- ignorar os tratamentos de cancelamento primario reenviado e adesao de liquidados
             ORDER BY p.nrcpfcgc ASC , p.cdapolic;
        rw_prestamista cr_prestamista%ROWTYPE;
                
      BEGIN
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        cecred.pc_log_programa(pr_dstiplog   => 'I',
                               pr_cdprograma => vr_cdprogra,
                               pr_cdcooper   => pr_cdcooper,
                               pr_tpexecucao => 2, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_idprglog   => vr_idprglog);
        vr_seqtran := 1;
        
        SELECT nmrescop
          INTO vr_nmrescop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
        
        -- Se não encontrar
        IF vr_dstextab IS NULL THEN
          vr_vlminimo := 0;
        ELSE
          vr_vlmaximo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
          vr_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 27, 12));
        END IF;      
        
        -- Sequencia do arquivo
        vr_nrsequen := to_number(substr(vr_dstextab, 139, 5)) + 1;

        vr_apolice  := SUBSTR(vr_dstextab,146,16); -- numero apolice

        -- Dados da conexao FTP
        vr_endereco := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_ENDERECO');
        vr_login    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_LOGIN');
        vr_senha    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_SENHA');

        vr_pgtosegu := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
      
        -- Ultimo dia do mes anterior (mes referente de cobranca)                                                   
        vr_ultimoDia := trunc(sysdate,'MONTH')-1;    
        
        -- diretorio da cooperativa
        vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', --> /usr/coop
                                             pr_cdcooper => pr_cdcooper);
        -- nome do arqquivo da cooperativa
        vr_nmarquiv := 'AILOS_'||replace(vr_nmrescop,' ','_')||'_'
                     ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '_') || '_' ||
                       gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';                                             
      
        -- Abre arquivo em modo de escrita (W)
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'       --> Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarquiv                  --> Nome do arquivo
                                ,pr_tipabert => 'W'                          --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arquivo               --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);                --> Erro
        IF vr_dscritic IS NOT NULL THEN         
          RAISE vr_exc_erro;       -- Levantar Excecao
        END IF;
      
        -- Atualiza sequencia (posições 139 a 144 do string)
        BEGIN
          UPDATE craptab
             SET craptab.dstextab = substr(craptab.dstextab, 1, 138) ||
                                    gene0002.fn_mask(vr_nrsequen, '99999') ||
                                    substr(craptab.dstextab, 144)
           WHERE craptab.cdcooper = pr_cdcooper
             AND craptab.nmsistem = 'CRED'
             AND craptab.tptabela = 'USUARI'
             AND craptab.cdempres = 11
             AND craptab.cdacesso = 'SEGPRESTAM'
             AND craptab.tpregist = 0;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        vr_contrcpf := NULL;

        -- Buscar idade limite
        OPEN cr_craptsg(pr_cdcooper => pr_cdcooper);
        FETCH cr_craptsg
         INTO vr_tab_nrdeanos;
        -- Se não tiver encontrado
        IF cr_craptsg%NOTFOUND THEN
          -- Usar 0
          vr_tab_nrdeanos := 0;
        END IF;

        CLOSE cr_craptsg;

        -- Definiçoes do programa
        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP

          vr_vlsdeved := rw_prestamista.saldo_cpf;
          vr_vlsdatua := rw_prestamista.vldevatu;
          vr_tpregist := rw_prestamista.tpregist;  
          vr_cdapolic := rw_prestamista.cdapolic;
          vr_NRPROPOSTA := nvl(rw_prestamista.NRPROPOSTA,0);
          vr_dtdevend := rw_prestamista.dtdevend;
          vr_dtinivig := rw_prestamista.dtinivig;
          vr_dtfimvig := rw_prestamista.dtfimvig;
          vr_flgnvenv := FALSE;         
          
          if rw_prestamista.dtfimvig is null then
            vr_dtfimvig := rw_prestamista.dtfimctr;
          end if;                           
          
          -- Se ainda sim estiver zerada vamos gerar uma proposta
          if vr_nrproposta = 0 then
            pc_gera_proposta (pr_cdcooper
                             ,rw_prestamista.nrdconta
                             ,rw_prestamista.nrctremp
                             ,vr_tpregist
                             ,vr_cdapolic
                             ,vr_NRPROPOSTA
                             ,vr_cdcritic
                             ,vr_dscritic);
          end if;
          
          -- Se data da venda for o proximo mês devemos enviar somente no proximo mês
          if trunc(vr_dtdevend) >= trunc(sysdate) and vr_tpregist = 1 then                          
            continue;
          end if;
          
          -- Validar Idade minima e Maxima
          -- Rotina responsavel por calcular a quantidade de anos e meses entre as datas
          CADA0001.pc_busca_idade(pr_dtnasctl => rw_prestamista.dtnasctl -- Data de Nascimento
                                 ,pr_dtmvtolt => vr_dtmvtolt -- Data da utilizacao atual
                                 ,pr_nrdeanos => vr_nrdeanos         -- Numero de Anos
                                 ,pr_nrdmeses => vr_nrdmeses         -- Numero de meses
                                 ,pr_dsdidade => vr_dsdidade         -- Descricao da idade
                                 ,pr_des_erro => vr_dscritic);       -- Mensagem de Erro   
                    
          -- saldo devedor menor que o parametrizado e o cancelamento ainda nao foi feito
          IF (vr_vlsdeved < vr_vlminimo AND vr_tpregist = 3) THEN
            -- cancelamento
            vr_tpregist := 2;
          ELSE 
            -- se o status era cancelado e o valor voltou a passar do minimo, criamos um novo certificado que será processado posteriormente como envio novo
            IF vr_vlsdeved >= vr_vlminimo AND vr_tpregist = 2 and vr_vlsdatua > 0 THEN            
              if vr_nrdeanos > vr_tab_nrdeanos or
                 vr_nrdeanos < 14 then             
                 if vr_nrdeanos > vr_tab_nrdeanos then
                    vr_tpregist:= 0; -- mudamos pra pendente e não enviamos até que ele complete a idade minima
                   BEGIN                
                      UPDATE tbseg_prestamista
                         SET tpregist = vr_tpregist
                       WHERE cdcooper = pr_cdcooper
                         AND nrdconta = rw_prestamista.nrdconta
                         AND nrctrseg = rw_prestamista.nrctrseg
                         AND nrctremp = rw_prestamista.nrctremp
                         AND cdapolic = vr_cdapolic;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                        RAISE vr_exc_saida;
                    END;  
                 end if;
                 continue;
              end if;  
              -- mesmo sendo pragma o cursor aberto nao vera o novo insert, por isso setamos as infos diferentes para nova adesao atualizada
              pc_replica_cancelado(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => rw_prestamista.nrdconta,
                                   pr_nrctremp => rw_prestamista.nrctremp,
                                   pr_dtemprst => rw_prestamista.data_emp, 
                                   pr_cdapolic => vr_cdapolic_canc, -- retorno da apolice nova
                                   pr_nrproposta => vr_nrproposta,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := vr_dscritic 
                               || ' Cooperativa: ' || pr_cdcooper 
                               || ' - Conta: ' || rw_prestamista.nrdconta 
                               || ' - Contrato Prestamista: ' || rw_prestamista.nrctrseg
                               || ' - Contrato Emprestimo: ' || rw_prestamista.nrctremp;
                RAISE vr_exc_saida;
              END IF;
              -- novos sets
              vr_dtdevend := rw_prestamista.data_emp; -- venda
              vr_dtinivig := sysdate; -- vigencia
              vr_tpregist := 1; -- adesao
              
              vr_flgnvenv := TRUE; -- nova adesao de cancelado, deve ser ignorado nas proximas execucoes para evitar de popular a tabela mais uma vez
            ELSIF vr_vlsdeved < vr_vlminimo AND vr_tpregist IN(2, 1) THEN

              IF vr_tpregist = 1 THEN
                BEGIN 
                  UPDATE tbseg_prestamista
                     SET dtdenvio = vr_dtmvtolt  --rw_crapcop.dtmvtolt
                   WHERE cdcooper = pr_cdcooper
                     AND nrdconta = rw_prestamista.nrdconta
                     AND nrctrseg = rw_prestamista.nrctrseg
                     AND nrctremp = rw_prestamista.nrctremp
                     AND cdapolic = vr_cdapolic;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;   
              END IF;
              
              CONTINUE; -- nao processamos cancelados e adesoes com devedor abaixo do minimo 
            END IF;
          END IF;
          
          -- controla o cpf para agrupar os valores enviados
          IF vr_contrcpf IS NULL OR vr_contrcpf <> rw_prestamista.nrcpfcgc THEN 
            vr_contrcpf := rw_prestamista.nrcpfcgc; -- novo cpf do loop
            vr_vlenviad := vr_vlsdatua; -- novo contrato 
            vr_vltotenv := vr_vlsdatua; -- inicia novo totalizador
            
            -- Tratamento de valor maximo para quem tiver apenas 1 emprestimo acima do valor maximo
            IF vr_vlenviad > vr_vlmaximo THEN
              vr_vlenviad := vr_vlmaximo; -- ate que o saldo fique abaixo do valor maximo enviamos o valor maximo   
                           
              vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                              Cooperativa: ' || vr_nmrescop || '<br />
                              Conta: '       || rw_prestamista.nrdconta || '<br />
                              Nome: '        || rw_prestamista.nmprimtl || '<br />
                              Contrato Empréstimo: '|| rw_prestamista.nrctremp || '<br />
                              Proposta seguro: '    || rw_prestamista.nrctrseg || '<br />
                              Valor Empréstimo: '   || rw_prestamista.vldevatu || '<br />
                              Valor saldo devedor total: '|| vr_vlsdeved || '<br />
                              Valor Limite Máximo: ' || vr_vlmaximo;
              
              -- Envia email
              gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                         pr_des_destino => vr_destinatario_email,
                                         pr_des_assunto => 'Valor limite maximo excedido ',
                                         pr_des_corpo   => vr_dscorpem,
                                         pr_des_anexo   => NULL,
                                         pr_flg_enviar  => 'S',
                                         pr_des_erro    => vr_dscritic); 
              IF vr_vlenviad <= 0 THEN
                continue;
              END IF;                         
            END IF;  
          ELSE
            vr_vltotenv := vr_vltotenv + vr_vlsdatua;
            IF vr_vltotenv > vr_vlmaximo THEN
              vr_vlenviad := vr_vlmaximo - (vr_vltotenv - vr_vlsdatua); -- enviamos a diferença para preencher até o maximo
              
              vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                              Cooperativa: ' || vr_nmrescop || '<br />
                              Conta: '       || rw_prestamista.nrdconta || '<br />
                              Nome: '        || rw_prestamista.nmprimtl || '<br />
                              Contrato Empréstimo: '|| rw_prestamista.nrctremp || '<br />
                              Proposta seguro: '    || rw_prestamista.nrctrseg || '<br />
                              Valor Empréstimo: '   || rw_prestamista.vldevatu || '<br />
                              Valor saldo devedor total: '|| vr_vlsdeved || '<br />
                              Valor Limite Máximo: ' || vr_vlmaximo;
              
              -- Envia email
              gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                         pr_des_destino => vr_destinatario_email,
                                         pr_des_assunto => 'Valor limite maximo excedido ',
                                         pr_des_corpo   => vr_dscorpem,
                                         pr_des_anexo   => NULL,
                                         pr_flg_enviar  => 'S',
                                         pr_des_erro    => vr_dscritic); 
              IF vr_vlenviad <= 0 THEN
                continue;
              END IF;
            ELSE 
              vr_vlenviad := vr_vlsdatua; -- envia o valor cheio
            END IF;
          END IF;                 
          

          -- Se idade for acima do limite 70 anos ou for abaixo do minino 14 nao devemos enviar
          if vr_nrdeanos > vr_tab_nrdeanos or
             vr_nrdeanos < 14 then             
             if vr_nrdeanos > vr_tab_nrdeanos then
               if vr_tpregist = 1 then 
                 vr_tpregist:= 0; 
                 continue; -- se for 1 Novo, mudamos pra zero e nao enviamos
               elsif vr_tpregist = 3 then 
                 vr_tpregist:= 2;-- se for 3 endosso, vamos enviar o cancelamento
               elsif vr_tpregist = 2 then 
                 continue; -- se ja estiver cancelado, vamos pular o registro
               end if;
             elsif vr_nrdeanos < 14 then
               vr_tpregist:= 1; -- mudamos pra pendente e não enviamos até que ele complete a idade minima
               BEGIN                
                  UPDATE tbseg_prestamista
                     SET tpregist = vr_tpregist
                   WHERE cdcooper = pr_cdcooper
                     AND nrdconta = rw_prestamista.nrdconta
                     AND nrctrseg = rw_prestamista.nrctrseg
                     AND nrctremp = rw_prestamista.nrctremp
                     AND cdapolic = vr_cdapolic;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;                  
                continue;
             end if;
          end if;        
          
          -- Se valor da linha for zerado quer dizer que o emprestimo desse cara foi liquidado e enviamos o 
          -- cancelamento desse registro
          if (vr_vlenviad = 0 or rw_prestamista.inliquid = 1) and vr_tpregist = 3 then
            vr_tpregist := 2;
          elsif (vr_vlenviad = 0 or rw_prestamista.inliquid = 1) and rw_prestamista.tpregist in( 1,2) then 
            vr_tpregist:= 0; -- mudamos pra 0 pra nao enviar mais das proximas vezes
             BEGIN                
                UPDATE tbseg_prestamista
                   SET tpregist = vr_tpregist
                 WHERE cdcooper = pr_cdcooper
                   AND nrdconta = rw_prestamista.nrdconta
                   AND nrctrseg = rw_prestamista.nrctrseg
                   AND nrctremp = rw_prestamista.nrctremp
                   AND cdapolic = vr_cdapolic;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;    
            continue;          
          end if;
          
          -- Calcular o valor do Premio a cada envio
          vr_vlprodvl := vr_vlenviad * (vr_pgtosegu/100); -- Produto – Valor 
          
          -- Caso o valor minimo for abaixo de 0,01 vamos enviar um valor minimo de 0,01 conforme acordado com a Icatu
          if vr_vlprodvl < 0.01 then
            vr_vlprodvl:= 0.01;
          end if;  
          -- Caso o valor minimo for abaixo de 0,01 vamos enviar um valor minimo de 0,01 conforme acordado com a Icatu
          if vr_vlenviad < 0.01 then
            vr_vlenviad:= 0.01;
          end if;
          
          vr_linha_txt := '';
          -- informacoes para impressao
          vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0); -- Sequencial Transação
          vr_linha_txt := vr_linha_txt || LPAD(vr_tpregist, 2, 0); -- Tipo Registro
          vr_linha_txt := vr_linha_txt || LPAD(vr_apolice, 15, 0); -- Nº Apólice / Certificado
          vr_linha_txt := vr_linha_txt || RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' '); -- CPF / CNPJ - sem formatacao
          vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' '); -- Cód.Empregado
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl)), 70, ' '); -- Nome completo do cliente
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(rw_prestamista.dtnasctl, 'YYYY-MM-DD'), 10, 0); -- Data Nascimento
          vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista.cdsexotl, 2, 0); -- Sexo
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))), 60, ' '); -- Endereço
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmbairro,' '))), 30, ' '); -- Bairro
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))), 30, ' '); -- Cidade
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdufresd), ' '),2,' '); -- UF
          vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrcepend, 'zzzzz-zz9'), 10, ' '); -- CEP
          
          IF length(rw_prestamista.nrtelefo) = 11 THEN
            vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)99999-9999'), 15, ' '); -- Telefone Residencial
          ELSIF length(rw_prestamista.nrtelefo) = 10 THEN
            vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)9999-9999'), 15, ' '); -- Telefone Residencial
          ELSE
            vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrtelefo, '99999-9999'), 15, ' '); -- Telefone Residencial
          END IF;
          
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Comercial
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Celular
          
          vr_dsdemail := rw_prestamista.dsdemail;
          SEGU0003.pc_limpa_email(vr_dsdemail);
          
          vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' '); -- E-mail Fulfillment
          vr_linha_txt := vr_linha_txt || RPAD(nvl(vr_dsdemail, ' '), 50, ' '); -- E-mail
          vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' '); -- Cód.Campanha
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód.Vendedor
          vr_linha_txt := vr_linha_txt || RPAD( vr_NRPROPOSTA, 30, ' '); -- Nº Proposta
          vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtdevend, 'YYYY-MM-DD'), 10, 0); -- Data Transação (Data da venda) / Data Cancelamento
          vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtinivig, 'YYYY-MM-DD'), 10, 0); -- Inicio Vigência
          vr_linha_txt := vr_linha_txt || LPAD(' ', 2, ' '); -- Razão Cancelam/Suspensão
                                                          
          --1 contrato para cada adesão
          vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.nrctremp), 0), 10, 0); -- Referencia 6 - nrctremp
          
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##2
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##3
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##4
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##5
          
          vr_linha_txt := vr_linha_txt || RPAD(LPAD(rw_prestamista.cdcooper, 4, 0), 50, ' '); -- Referencia 7 - Cooperativa 491
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- Referencia 3 - Nº da Sorte
          vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcobran), ' '); -- Meio Cobrança
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdadmcob), ' '), 3, ' '); -- Cód.Administr.Cobrança BY e BC
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód. Banco
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód.Agência
          vr_linha_txt := vr_linha_txt || RPAD(' ', 2, ' '); -- Cód.Admin.Cartão Crédito
          vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); -- Nº Conta Corrente
          vr_linha_txt := vr_linha_txt || RPAD(' ', 5, ' '); -- Validade Cartão Crédito
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Data Cobrança          
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpfrecob), ' '), 2, ' '); -- Frequência Cobrança
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpsegura), ' '), 2, ' '); -- Tipo Segurado
          vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcooperativa), ' '); -- Produto - Cód.Produto
          vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdplapro), ' '); -- Produto - Plano
          
          vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlprodvl,'fm99999990d00'), ',', '.'), 12, 0); -- Produto – Valor
          vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.tpcobran), ' '), 1, ' '); -- Tipo de Cobrança
          vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlenviad,'fm999999999999990d00'), ',', '.'), 30, 0); -- Valor do Saldo Devedor Atualizado
          vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_ultimoDia, 'YYYY-MM-DD'), 10, 0); -- Data Referência para Cobrança
          vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtfimvig, 'YYYY-MM-DD'), 10, 0); -- Data final de vigência contrato
          
          -- Opcionais nao enviados
          vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); -- Data/Hora Autorização – SITEF
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 1 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 2 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 3 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 4 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');-- PSD 5 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 6 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 7 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 8 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 9 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 89, ' '); -- Código Identificador do Cartão de Crédito (cardHash) – Software Express
          vr_linha_txt := vr_linha_txt || LPAD(' ', 15, ' '); -- authorizerId
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 1 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 1 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 1 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 2 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 2 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 2 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 3 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 3 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 3 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 4 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 4 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 4 - Porcentagem
          -- Opcionais nao enviados
          
          vr_linha_txt := vr_linha_txt || chr(13);
          
          vr_index_815 := vr_index_815 + 1;
          vr_tab_crrl815(vr_index_815) := NULL;
          vr_tab_crrl815(vr_index_815).dtmvtolt := vr_dtmvtolt ; --rw_crapcop.dtmvtolt;
          vr_tab_crrl815(vr_index_815).nmrescop := vr_nmrescop;
          vr_tab_crrl815(vr_index_815).nmprimtl := rw_prestamista.nmprimtl;
          vr_tab_crrl815(vr_index_815).nrdconta := rw_prestamista.nrdconta;
          vr_tab_crrl815(vr_index_815).cdagenci := rw_prestamista.cdagenci;          
          vr_tab_crrl815(vr_index_815).nrctrseg := vr_NRPROPOSTA;
          vr_tab_crrl815(vr_index_815).nrctremp := rw_prestamista.nrctremp;
          vr_tab_crrl815(vr_index_815).nrcpfcgc := rw_prestamista.nrcpfcgc;
          vr_tab_crrl815(vr_index_815).vlprodut := vr_vlprodvl;
          vr_tab_crrl815(vr_index_815).vlenviad := vr_vlenviad;
          vr_tab_crrl815(vr_index_815).vlsdeved := vr_vlsdeved;
          vr_tab_crrl815(vr_index_815).dtinivig := vr_dtinivig;
          vr_tab_crrl815(vr_index_815).dtrefcob := vr_ultimoDia;
          vr_tab_crrl815(vr_index_815).tpregist := vr_tpregist;
          vr_tab_crrl815(vr_index_815).dsregist := vr_tipo_registro(vr_tpregist).tpregist;
          
          -- adesao seta o proximo como endosso e a proxima execucao trata se sera cancelamento
          IF vr_tpregist = 1 THEN 
            vr_tpregist := 3;
          END IF;
            
          IF vr_flgnvenv THEN           
            BEGIN 
              UPDATE tbseg_prestamista
                 SET tpregist = vr_tpregist
                    ,dtdenvio = vr_dtmvtolt  --rw_crapcop.dtmvtolt
                    ,vlprodut = vr_vlprodvl
                    ,dtrefcob = vr_ultimoDia
                    ,dtdevend = vr_dtdevend
                    ,dtfimvig = vr_dtfimvig
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = rw_prestamista.nrdconta
                 AND nrctrseg = rw_prestamista.nrctrseg
                 AND nrctremp = rw_prestamista.nrctremp
                 AND cdapolic = vr_cdapolic_canc;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                RAISE vr_exc_saida;
            END;   
            vr_tpregist := 0; -- sera ignorado na proxima execucao
          END IF;
            
          BEGIN 
            UPDATE tbseg_prestamista
               SET tpregist = vr_tpregist
                  ,dtdenvio = vr_dtmvtolt  --rw_crapcop.dtmvtolt
                  ,vlprodut = vr_vlprodvl
                  ,dtrefcob = vr_ultimoDia
                  ,dtdevend = vr_dtdevend
                  ,dtfimvig = vr_dtfimvig
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = rw_prestamista.nrdconta
               AND nrctrseg = rw_prestamista.nrctrseg
               AND nrctremp = rw_prestamista.nrctremp
               AND cdapolic = vr_cdapolic;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;   
        
          -- Escrever Linha do Arquivo 
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
        
          vr_seqtran := vr_seqtran + 1;
        END LOOP;
        vr_crrl815 := vr_tab_crrl815;

        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

        -- UX2DOS
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                    ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv        --> Caminho e nome do arquivo a ser convertido
                                    ,pr_nmarqenv => vr_nmarquiv           --> Nome desejado para o arquivo convertido
                                    ,pr_des_erro => vr_dscritic);                 --> Retorno da critica

        IF vr_dscritic IS NOT NULL THEN    --Se ocorreu erro          
          RAISE vr_exc_erro;               --Levantar Excecao
        END IF;
        
        -- Enviamos para o ftp parametrizado na tela tab049
        SEGU0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarquiv,         --> Nome arquivo a enviar
                                           pr_idoperac => 'E',                 --> Envio de arquivo
                                           pr_nmdireto => vr_nmdircop || '/arq/', --> Diretório do arquivo a enviar
                                           pr_idenvseg => 'S',                 --> Indicador de utilizacao de protocolo seguro (SFTP)
                                           pr_ftp_site => vr_endereco,         --> Site de acesso ao FTP
                                           pr_ftp_user => vr_login,            --> Usuário para acesso ao FTP
                                           pr_ftp_pass => vr_senha,            --> Senha para acesso ao FTP
                                           pr_ftp_path => 'Envio', --> Pasta no FTP para envio do arquivo
                                           pr_dscritic => vr_dscritic);      --> Retorno descricao da critica

        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || pr_cdcooper || ' - ' || vr_dscritic;
          -- Escreve log de erro, mas continua com o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Processamento de ftp retornou erro: '||vr_dscritic);
        END IF;
        -- Mover o arquivo processado para a pasta "salvar" 
        if nvl(vr_nmarquiv,' ') <> ' ' then          
           gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquiv||' '||vr_nmdircop||'/salvar',
                                       pr_typ_saida   => vr_tipo_saida,
                                       pr_des_saida   => vr_dscritic);
        end if;                            
        -- Testa erro
        IF vr_tipo_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || pr_cdcooper || ' - ' ||vr_dscritic;
          -- Escreve log de erro, mas continua com o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
        END IF;
      
        --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        cecred.pc_log_programa(pr_dstiplog   => 'F',
                               pr_cdprograma => vr_cdprogra,
                               pr_cdcooper   => pr_cdcooper,
                               pr_tpexecucao => 2, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_idprglog   => vr_idprglog);
        
        -- Commitamos depois que o arquivo tiver sido enviado, 
        -- em caso de erros não perdemos o cenário de envios pendentes, 
        -- fazendo-o na próxima execução de sucesso
        COMMIT;   
        
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
        
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          -- Efetuar rollback
          ROLLBACK;
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

          -- Por fim, envia o email
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
          pr_dscritic := vr_dscritic;
          -- Efetuar rollback
          ROLLBACK;
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
          -- Por fim, envia o email
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
      END;
    END pc_gera_arquivo_coop;
    
    --Procedure que escreve linha no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
    END pc_escreve_xml;

    procedure pc_gera_arq_previa(pr_cdcooper  IN tbseg_prestamista.cdcooper%TYPE) is 
      -- gerar arquivo csv 
         vr_nmarqcsv  VARCHAR2(100);
         vr_linha_csv VARCHAR2(32600);
         vr_dscorpem VARCHAR2(2000);
         vr_endereco  VARCHAR2(100);    
         vr_login     VARCHAR2(100);
         vr_senha     VARCHAR2(100);         
         vr_tipo_saida VARCHAR2(100);
         vr_geroucsv  numeric(1);
         vr_nmrescop crapcop.nmrescop%TYPE;
         vr_ultimoDia DATE;
         vr_ind_arqcsv  utl_file.file_type;
         CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT p.idseqtra
                ,p.cdcooper
                ,p.nrdconta
                ,p.nrctrseg
                ,p.tpregist
                ,p.cdapolic
                ,p.nrcpfcgc
                ,p.nmprimtl
                ,p.dtnasctl
                ,p.cdsexotl
                ,p.dsendres
                ,p.dsdemail
                ,p.nmbairro
                ,p.nmcidade
                ,p.cdufresd
                ,p.nrcepend
                ,p.nrtelefo
                ,p.dtdevend
                ,p.dtinivig
                ,p.nrctremp
                ,p.cdcobran
                ,p.cdadmcob
                ,p.tpfrecob
                ,p.tpsegura
                ,p.cdprodut
                ,p.cdplapro
                ,p.vlprodut
                ,p.tpcobran
                ,p.vlsdeved
                ,p.vldevatu
                ,p.dtrefcob
                ,p.dtfimvig
                ,p.dtdenvio
                ,c.inprejuz
                ,c.inliquid
                ,p.nrproposta
                , lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
                ,  SUM(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf
                ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
                ,(select max(e.dtmvtolt) from crapepr e where e.cdcooper = p.cdcooper and e.nrdconta = p.nrdconta and e.inliquid = 0) data_emp
            FROM tbseg_prestamista p, crapepr c
           WHERE p.cdcooper = pr_cdcooper    
             AND c.cdcooper = p.cdcooper
             AND c.nrdconta = p.nrdconta
             AND c.nrctremp = p.nrctremp
             AND p.dtdevend >= trunc(sysdate) - 7 
             AND p.tpregist <> 0      -- ignorar os tratamentos de cancelamento primario reenviado e adesao de liquidados
             ORDER BY p.nrcpfcgc ASC, p.cdapolic;
         rw_prestamista cr_prestamista%ROWTYPE;      
      BEGIN        
        SELECT nmrescop INTO vr_nmrescop FROM crapcop  WHERE cdcooper = pr_cdcooper;       
         
        vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper);
     
        --   Abre Arquivo CSV   . 
        vr_ultimoDia := trunc(sysdate); ---,'MONTH'
        vr_nmarqcsv := 'Previa_'||REPLACE(to_char(vr_ultimoDia , 'DD/MM/YY'), '/', '')
                                 ||'_'||vr_nmrescop ||'.csv';                          
                                   
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'       --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarqcsv                  --> Nome do arquivo
                              ,pr_tipabert => 'W'                          --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arqcsv               --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);                --> Erro                              
        IF vr_dscritic IS NOT NULL THEN         
          RAISE vr_exc_erro;       -- Levantar Excecao
        END IF;
        vr_geroucsv := 0;                        
        vr_linha_csv := 'Tip.Reg;Data.Env;Coop.;Nome;CPF/CNPJ;CONTA/DV;Ctr.Seguro;Ctr.Emp;Premio;Sld.Devedor;Dat.Inicio;Sld.Dev.CPF; '|| chr(13);
        GENE0001.pc_escr_linha_arquivo(vr_ind_arqcsv,vr_linha_csv);               
        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP
            vr_linha_csv := ''; 
          --- gerar linha para arquivo CSV           ---   STRY0014505            
          
            vr_linha_csv :=             rw_prestamista.tpregist|| ';'||                                                     ---•  “Tip.Reg”
                                        to_char(sysdate,'DD/MM/YYYY')|| ';'||                                   ---•  “Data.Env”     
                                        vr_nmrescop|| ';'||                                                     ---•  “Coop.“           
                                        UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl))|| ';'||     ---•  “Nome“
                                        RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' ') || ';'||---•  “CPF/CNPJ“
                                        rw_prestamista.nrdconta             || ';'||                                        ---•  “CONTA/DV“
                                        rw_prestamista.NRPROPOSTA           || ';'||                                        ---•  “Ctr.Seguro “    vr_NRPROPOSTA      
                                        rw_prestamista.nrctremp             || ';'||                                        ---•  “Ctr.Emp “
                                        rw_prestamista.vlprodut             || ';'||                                        ---•  “Premio “        vr_vlprodvl
                                        rw_prestamista.vldevatu             || ';'||                                        ---•  “Sld.Devedor “   vr_vlsdatua
                                        rw_prestamista.dtinivig             || ';'||                                        ---•  “Dat.Inicio “    vr_dtinivig
                                        rw_prestamista.saldo_cpf            || ';'||                                        ---•  “Sld.Dev.CPF”    vr_vlsdeved                                                     
                                        chr(13);
          GENE0001.pc_escr_linha_arquivo(vr_ind_arqcsv,vr_linha_csv);               
          vr_geroucsv := 1;
        end loop;   
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqcsv ); 
               
        vr_dscorpem := 'Arquivo CSV de Prévia com <br /><br /> '||
                             ' Cooperativa: ' || vr_nmrescop || '<br />';
                      
        if vr_geroucsv = 1 then
            gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,           -- Envia o email
                                       pr_des_destino => vr_destinatario_email2, -- seguros.vida@ailos.coop.br    ---parametro ENVIA_SEG_PRST_MAIL_CSV

                                       pr_des_assunto => 'Seguros prestamistas gerados na semana ',
                                       pr_des_corpo   => vr_dscorpem,
                                       pr_des_anexo   => vr_nmdircop || '/arq/' || vr_nmarqcsv,
                                       pr_flg_enviar  => 'S',
                                       pr_des_erro    => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN    --Se ocorreu erro          
              RAISE vr_exc_erro;               --Levantar Excecao
            END IF;          
        end if;
        
        -- Dados da conexao FTP
        vr_endereco := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_ENDERECO');
        vr_login    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_LOGIN');
        vr_senha    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_SENHA');

        -- Enviamos para o ftp parametrizado na tela tab049
        SEGU0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarqcsv,         --> Nome arquivo a enviar
                                           pr_idoperac => 'E',                 --> Envio de arquivo
                                           pr_nmdireto => vr_nmdircop || '/arq/', --> Diretório do arquivo a enviar
                                           pr_idenvseg => 'S',                 --> Indicador de utilizacao de protocolo seguro (SFTP)
                                           pr_ftp_site => vr_endereco,         --> Site de acesso ao FTP
                                           pr_ftp_user => vr_login,            --> Usuário para acesso ao FTP
                                           pr_ftp_pass => vr_senha,            --> Senha para acesso ao FTP
                                           pr_ftp_path => 'Envio', --> Pasta no FTP para envio do arquivo
                                           pr_dscritic => vr_dscritic);      --> Retorno descricao da critica

        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || pr_cdcooper || ' - ' || vr_dscritic;
          -- Escreve log de erro, mas continua com o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Processamento de ftp retornou erro: '||vr_dscritic);
        END IF;

        -- Mover o arquivo processado para a pasta "salvar" 
        if nvl(vr_nmarqcsv,' ') <> ' ' then                    
           gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarqcsv||' '||vr_nmdircop||'/salvar',
                                       pr_typ_saida   => vr_tipo_saida,
                                       pr_des_saida   => vr_dscritic);
        end if;                            
        -- Testa erro
        IF vr_tipo_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || pr_cdcooper || ' - ' ||vr_dscritic;
          -- Escreve log de erro, mas continua com o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
        END IF;                                           
                
    end;


  BEGIN
    ---INICIO 
  vr_destinatario_email := gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL'); -- seguros@ailos.com.br
  vr_destinatario_email2 := gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_MAIL_CSV'); -- seguros@ailos.com.br  
      
  --- Verificar propostas duplicadas
  pc_verifica_proposta(pr_cdcooper => pr_cdcooper
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
                         
  if trim(vr_dscritic) is not null then
     vr_dscritic:= 'Erro pc_verifica_proposta: '||vr_dscritic;
     RAISE vr_exc_erro;
  end if;      
   
  IF cr_crapcop%ISOPEN then
    close cr_crapcop;
  end if;  
  
  -- Leitura dos valores de mínimo e máximo
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                            pr_nmsistem => 'CRED',
                                            pr_tptabela => 'USUARI',
                                            pr_cdempres => 11,
                                            pr_cdacesso => 'SEGPRESTAM',
                                            pr_tpregist => 0);

  -- Se não encontrar
  IF vr_dstextab IS NULL THEN
    -- Usar valores padrão
    vr_tab_vlminimo := 0;
    vr_tab_vlmaximo := 999999999.99;
  ELSE
    -- Usar informações conforme o posicionamento
    -- Valor mínimo da posição 27 a 39
    vr_tab_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,27,12));
    -- Valor máximo da posição 14 a 26
    vr_tab_vlmaximo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
    -- Data de inicio dos seguros da posição 40 a 50
    vr_tab_dtiniseg := to_date(SUBSTR(vr_dstextab,40,10),'dd/mm/yyyy');
    -- Valor de tabela da posição 51 a 58
    vr_tab_vltabela := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
  END IF; 
 
  select nmsegura into vr_nmsegura from crapcsg where cdcooper = pr_cdcooper and cdsegura = 514; 
  
  open cr_crapcop(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  IF cr_crapcop%found THEN
   
    vr_tab_crrl815.delete;
    vr_crrl815.delete;    
    vr_tipo_registro.delete;
    vr_totais_crrl815.delete;
    vr_tab_sldevpac.delete;
      
    vr_tipo_registro(0).tpregist := 'NOT FOUND';
    vr_tipo_registro(1).tpregist := 'ADESAO';
    vr_tipo_registro(2).tpregist := 'CANCELAMENTO';
    vr_tipo_registro(3).tpregist := 'ENDOSSO';    
    
    -- Todo sabado deve verificar os prestamsitas a serem criados
    vr_diasem := TO_CHAR(SYSDATE,'D'); ---7;
    IF TO_CHAR(SYSDATE,'D') = vr_diasem THEN 
      
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
                                    ,pr_des_erro  => pr_dscritic);
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;

        pc_gera_arq_previa(rw_crapcop.cdcooper );
      END IF;  
           
      vr_diames := '01';
      -- so deve seguir se for o primeiro dia do mes
      IF TO_CHAR(trunc(SYSDATE),'DD') <> vr_diames THEN 
        RETURN; -- Nao deve seguir com o programa
      END IF; 
      
      -- primeiro atualizamos o saldo devedor de todos contratos da tabela
     pc_atualiza_tabela( pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
     
      vr_dtmvtolt := rw_crapcop.dtmvtolt;
      vr_cdcooper := rw_crapcop.cdcooper; -- Para log em caso de exceção imprevista
      -- Geramos os txts das cooperativas
      pc_gera_arquivo_coop(pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
       
      vr_index_815 := '';
      vr_dtmvtolt := rw_crapcop.dtmvtolt;       
      vr_totais_crrl815.delete;
      
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        vr_vltotarq := 0;

        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl815><dados>');  
        vr_index_815 :=  vr_crrl815.first;
        WHILE vr_index_815 IS NOT NULL LOOP
          if not vr_crrl815(vr_index_815).vlenviad is null then
            vr_vlenviad := vr_crrl815(vr_index_815).vlenviad;
          else 
            vr_vlenviad := 0;
          end if; 
          pc_escreve_xml(
                '<registro>'||
                         '<dtmvtolt>' || TO_CHAR(vr_crrl815(vr_index_815).dtmvtolt , 'DD/MM/RRRR') || '</dtmvtolt>' ||
                         '<nmrescop>' || vr_crrl815(vr_index_815).nmrescop || '</nmrescop>' ||
                         '<nmprimtl>' || vr_crrl815(vr_index_815).nmprimtl || '</nmprimtl>' ||
                         '<nrdconta>' || TRIM(gene0002.fn_mask_conta(vr_crrl815(vr_index_815).nrdconta)) || '</nrdconta>' ||
                         '<cdagenci>' ||                     TO_CHAR(vr_crrl815(vr_index_815).cdagenci)  || '</cdagenci>' ||                           
                         '<nrctrseg>' || TRIM(                       vr_crrl815(vr_index_815).nrctrseg) || '</nrctrseg>' ||
                         '<nrctremp>' || TRIM(gene0002.fn_mask_contrato(vr_crrl815(vr_index_815).nrctremp)) || '</nrctremp>' ||
                         '<nrcpfcgc>' || TRIM(gene0002.fn_mask_cpf_cnpj(vr_crrl815(vr_index_815).nrcpfcgc, 1)) || '</nrcpfcgc>' ||
                         '<vlprodut>' || to_char(vr_crrl815(vr_index_815).vlprodut, 'FM99G999G999G999G999G999G999G990D00') || '</vlprodut>' ||
                         '<vlenviad>' || to_char(vr_vlenviad, 'FM99G999G999G999G999G999G999G990D00') || '</vlenviad>' ||
                         '<vlsdeved>' || to_char(vr_crrl815(vr_index_815).vlsdeved, 'FM99G999G999G999G999G999G999G990D00') || '</vlsdeved>' ||
                         '<dtrefcob>' || NVL(TO_CHAR( vr_crrl815(vr_index_815).dtrefcob, 'DD/MM/RRRR') , '') || '</dtrefcob>' ||
                         '<dsregist>' ||              vr_crrl815(vr_index_815).dsregist || '</dsregist>' ||
                         '<dtinivig>' || NVL(TO_CHAR( vr_crrl815(vr_index_815).dtinivig , 'DD/MM/RRRR') , '') || '</dtinivig>'
                 ||'</registro>');
         
          vr_dsadesao := vr_crrl815(vr_index_815).dsregist;

          IF NOT vr_tab_sldevpac.EXISTS(vr_crrl815(vr_index_815).cdagenci) THEN
             vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved := 0;
             vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio := 0;
          END IF;
          -- Acumular o SubTotais do PA 
          vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved := vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved 
                                                                    + vr_vlenviad;
          vr_vltotarq := vr_vltotarq + vr_vlenviad;

          IF vr_totais_crrl815.EXISTS(vr_dsadesao) = FALSE THEN
            vr_totais_crrl815(vr_dsadesao).qtdadesao := 1;
            vr_totais_crrl815(vr_dsadesao).slddeved := vr_vlenviad;
            vr_totais_crrl815(vr_dsadesao).vlpremio := vr_crrl815(vr_index_815).vlprodut;
            vr_totais_crrl815(vr_dsadesao).dsadesao := vr_dsadesao;
          ELSE
            vr_totais_crrl815(vr_dsadesao).slddeved := vr_totais_crrl815(vr_dsadesao).slddeved +
                                                       vr_vlenviad;
            vr_totais_crrl815(vr_dsadesao).vlpremio := vr_totais_crrl815(vr_dsadesao).vlpremio +
                                                       vr_crrl815(vr_index_815).vlprodut;
            vr_totais_crrl815(vr_dsadesao).qtdadesao := vr_totais_crrl815(vr_dsadesao).qtdadesao + 1;
          END IF;
          
                      -- Acumular o total de divida e de associados
          vr_vltotdiv := vr_vltotdiv + vr_crrl815(vr_index_815).vlprodut;
          vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio := vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio 
                                                                       + vr_crrl815(vr_index_815).vlprodut;
                    
          vr_index_815 := vr_crrl815.next(vr_index_815);
          vr_flgachou := TRUE;
        END LOOP;
        pc_escreve_xml('</dados>');

        pc_escreve_xml('<totais>');        
        vr_index := vr_totais_crrl815.first;
        WHILE vr_index IS NOT NULL LOOP
          IF vr_totais_crrl815.EXISTS(vr_index) = TRUE THEN                  
            pc_escreve_xml('<registro>'||
                             '<dsadesao>' ||         NVL(vr_totais_crrl815(vr_index).dsadesao, ' ') || '</dsadesao>' ||
                             '<vlpremio>' || to_char(NVL(vr_totais_crrl815(vr_index).vlpremio, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</vlpremio>' ||
                             '<slddeved>' || to_char(NVL(vr_totais_crrl815(vr_index).slddeved, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</slddeved>' ||
                             '<qtdadesao>' ||        NVL(vr_totais_crrl815(vr_index).qtdadesao, 0) || '</qtdadesao>'||
                           '</registro>');

          END IF;
          vr_index := vr_totais_crrl815.next(vr_index);
        END LOOP;

        pc_escreve_xml(  '</totais>');
                         
       

        vr_percpagt  := round(vr_tab_vltabela/100,10);
        -- Se achou algum registro
        IF vr_flgachou THEN
        
          vr_tab_lancarq.delete;
              
         -----Totais por PA 
          pc_escreve_xml(  '<totpac vltotdiv="'||to_char(vr_vltotarq,'fm999g999g999g990d00')||   '">');
          
          -- Se achou algum registro
          IF vr_tab_sldevpac.COUNT > 0 THEN
            FOR vr_cdagenci IN vr_tab_sldevpac.FIRST..vr_tab_sldevpac.LAST LOOP
              IF vr_tab_sldevpac.EXISTS(vr_cdagenci) THEN
                   pc_escreve_xml('<registro>'
                                 ||  '<cdagenci>'||LPAD(vr_cdagenci,3,' ')||'</cdagenci>'
                                 ||  '<sldevpac>'||to_char(vr_tab_sldevpac(vr_cdagenci).slddeved,'fm999g999g999g990d00')||'</sldevpac>'
                               ||'</registro>');  
                vr_tab_lancarq(vr_cdagenci) := vr_tab_sldevpac(vr_cdagenci).vlpremio;

              END IF;
            END LOOP;
            pc_escreve_xml(  '</totpac>');          
          END IF;          
        END IF;        
        pc_escreve_xml('</crrl815>');
            
--obsoleto  esta repetido  gene0001.pc_fecha_arquivo(vr_arqhandle);
        
        vr_dir_relatorio_815 := gene0001.fn_diretorio('C', rw_crapcop.cdcooper, 'rl') || '/crrl815.lst';
        -- entra apenas se existir algum conteudo para imprimir
        IF vr_crrl815.EXISTS(rw_crapcop.cdcooper) = TRUE THEN
          gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                 --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapcop.dtmvtolt         --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml                  --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl815'                  --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl815.jasper'            --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                        --> Nao tem parametros
                                     ,pr_dsarqsaid => vr_dir_relatorio_815        --> Arquivo final
                                     ,pr_cdrelato  => 815
                                     ,pr_flg_gerar => 'S'
                                     ,pr_qtcoluna  => 234
                                     ,pr_sqcabrel  => 1
                                     ,pr_nmformul  => '234col'
                                     ,pr_flg_impri => 'S'
                                     ,pr_nrcopias  => 1
                                     ,pr_nrvergrl  => 1
                                     ,pr_des_erro  => pr_dscritic);

          IF pr_dscritic IS NOT NULL THEN            
            RAISE vr_exc_erro;            -- Gerar exceção
          END IF;
        END IF;
 
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
-----------------GERAR ARQUIVO DAT para sistema Mathera (Sistema Contábil) -----------------
     -- gerar arquivo contabil
     vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nmsubdir => 'contab');
     -- Busca o diretório final para copiar arquivos
     vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
   

     vr_ultimodiaMes := trunc(vr_dtmvtolt,'MONTH') -1 ;
     
     vr_dtmvtolt_yymmdd := to_char(vr_ultimodiaMes, 'yyyymmdd'); -- Nome do arquivo a ser gerado
     vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_PRESTAMISTA.txt';
     vr_linhadet        := '';
     gene0001.pc_abre_arquivo(   -- Abre o arquivo para escrita
                                 pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                 pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                 pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                 pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                 pr_des_erro => vr_dscritic);        --> Retorno de Critica de erro

     if vr_dscritic is not null then
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
     end if;
        
     
      -- gerar arquivo aqui -- varrer pl table
      IF vr_tab_lancarq.count > 0 THEN
         vr_idx_lancarq := vr_tab_lancarq.first;
         
         /* Escrita arquivo o total*/
         vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_ultimodiaMes,'ddmmyy'))||
                             ',8304,4963,'||
                             trim(to_char(vr_vltotdiv,'999999999999.99'))|| --valor deve ir positivo para o arquivo
                             ',5210,'||
                             '"VLR. REF. PROVISAO P/ PAGAMENTO DE SEGURO PRESTAMISTA - '|| vr_nmsegura ||' - REF. ' 
                             || to_CHAR(vr_ultimodiaMes,'MM/YYYY') ||'"';

         gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         
         --escreve no arquivo rateio por PA                    
         WHILE vr_idx_lancarq IS NOT NULL LOOP                      
            vr_linhadet := lpad(vr_idx_lancarq,3,0) || ',' || 
                TRIM(to_char(round(vr_tab_lancarq(vr_idx_lancarq),2),'999999999999.99')); 
                
            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);                        
            vr_idx_lancarq := vr_tab_lancarq.next(vr_idx_lancarq);             
         END LOOP;
       
      END IF;
      
      gene0001.pc_fecha_arquivo(vr_arquivo_txt);      
      vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_PRESTAMISTA.txt';
              
      gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||        -- Copia o arquivo gerado para o diretório final convertendo para DOS
                   vr_nom_diretorio||'/'||vr_nmarqdat||' > '||
                   vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
                
      if vr_typ_said = 'ERR' then
         vr_cdcritic := 1040;
         gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
      end if;
      -------Fim Geracao arquivo DAT ----------------                     
        
  END IF;  
  CLOSE cr_crapcop;
  COMMIT;   

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Efetuar retorno do erro não tratado
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pr_dscritic := vr_dscritic;
      ROLLBACK;

      -- Envio centralizado de log de erro
      cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                             pr_cdcooper           => vr_cdcooper, -- tbgen_prglog
                             pr_tpexecucao         => 2,           -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia       => 0,           -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade      => 2,           -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem         => vr_dscritic, -- tbgen_prglog_ocorrencia
                             pr_flgsucesso         => 0,           -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => vr_destinatario_email,
                             pr_idprglog           => vr_idprglog);
      -- Por fim, envia o email
      gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                 pr_des_destino => vr_destinatario_email,
                                 pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                 pr_des_corpo   => pr_dscritic,
                                 pr_des_anexo   => NULL,
                                 pr_flg_enviar  => 'S',
                                 pr_des_erro    => vr_dscritic); 
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pr_dscritic := vr_dscritic;
      ROLLBACK;

      -- Envio centralizado de log de erro
      cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                             pr_cdcooper           => vr_cdcooper, -- tbgen_prglog
                             pr_tpexecucao         => 2,           -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia       => 0,           -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade      => 2,           -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem         => vr_dscritic, -- tbgen_prglog_ocorrencia
                             pr_flgsucesso         => 0,           -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => vr_destinatario_email,
                             pr_idprglog           => vr_idprglog);
      -- Por fim, envia o email
      gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                 pr_des_destino => vr_destinatario_email,
                                 pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                 pr_des_corpo   => pr_dscritic,
                                 pr_des_anexo   => NULL,
                                 pr_flg_enviar  => 'S',
                                 pr_des_erro    => vr_dscritic);

  END;

END pc_envia_arq_seg_prst_coop_temp;
  
  
begin
    FOR rw_crapcop IN cr_crapcop LOOP
       Begin
          vr_dscritic := null;
          vr_cdcritic := 0;
          pc_envia_arq_seg_prst_coop_temp(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          
--          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
  --          RAISE exception;
    --      END IF;
       EXCEPTION         
         WHEN OTHERS THEN
                                                   -- Efetuar retorno do erro não tratado
              vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
                                                   --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
              ROLLBACK;
                                                   -- Envio centralizado de log de erro
              cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                     pr_cdprograma         => 'JB_ARQPRST', -- tbgen_prglog
                                     pr_cdcooper           =>  rw_crapcop.cdcooper, -- tbgen_prglog
                                     pr_tpexecucao         => 2,           -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                     pr_tpocorrencia       => 0,           -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                                     pr_cdcriticidade      => 2,           -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                     pr_dsmensagem         => vr_dscritic, -- tbgen_prglog_ocorrencia
                                     pr_flgsucesso         => 0,           -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                                     pr_nmarqlog           => NULL,
                                     pr_destinatario_email => '',
                                     pr_idprglog           => vr_idprglog);
         END;                            
          
    END LOOP;
    
end;


end;
