declare
  --leitura arquivo
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/inc0116859';
  vr_nmarqimp        VARCHAR2(100)  := 'contratos_manutencao.csv';   
  vr_nmarqlog        VARCHAR2(100)  := 'inc0116859_log.csv';   
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arqlog      utl_file.file_type;
  
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;
  vr_cdcooper        crapepr.cdcooper%type;  
  vr_nrdconta        crapepr.nrdconta%type;
  vr_nrctremp        crapepr.nrctremp%type;
  vr_lanctoaj        crapepr.vlsdevat%type;
  vr_cdhistor        craplcm.cdhistor%type;
  vr_modalida        NUMBER;
  vr_linhaarq        varchar2(1000);
    
  vr_des_reto      varchar(3);
  vr_tab_erro      GENE0001.typ_tab_erro;
  vr_cdcritic     crapcri.cdcritic%TYPE;
  vr_dscritic     crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION;
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci,
           ass.inprejuz
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass       cr_crapass%ROWTYPE;
  
  CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                   ,pr_nrdconta crapepr.nrdconta%TYPE
                   ,pr_nrctremp crapepr.nrctremp%TYPE
                   ) IS
    SELECT epr.tpemprst
          ,epr.tpdescto
          ,epr.cdlcremp
          ,epr.vlemprst
          ,epr.txmensal
          ,epr.vlsprojt
          ,epr.qttolatr
          ,wpr.dtdpagto dtprivct
          ,epr.dtmvtolt dtefetiv
      FROM crapepr epr
          ,crawepr wpr
     WHERE epr.cdcooper = wpr.cdcooper
       AND epr.nrdconta = wpr.nrdconta
       AND epr.nrctremp = wpr.nrctremp
       AND epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp
       and epr.inliquid = 0;

  rw_crapepr cr_crapepr%ROWTYPE;
  
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
  
BEGIN

  IF btch0001.cr_crapdat%ISOPEN THEN
    CLOSE btch0001.cr_crapdat;
  END IF;
    
  -- Com base na data da central
  OPEN  btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;  

  --ABRIR arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN  
    RAISE vr_exc_saida;
  END IF;   
  
   --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqlog        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arqlog      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;    
  
  /*leitura do cabeçalho*/
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                              ,pr_des_text => vr_linha);
                              
  /*Escrita do cabeçalho de log*/
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,'cdcooper;nrdconta;nrctremp;ajusteCC;pagamentoparcela;obs;');
  LOOP
      BEGIN
        -- loop para ler a linha do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linha); --> Texto lido
        EXCEPTION
           WHEN no_data_found THEN 
              EXIT;
      END;
      
      vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');

      vr_cdcooper := GENE0002.fn_char_para_number(vr_campo(1));
      vr_nrdconta := GENE0002.fn_char_para_number(vr_campo(2));
      vr_nrctremp := GENE0002.fn_char_para_number(vr_campo(4));
      vr_lanctoaj := GENE0002.fn_char_para_number(vr_campo(10));
      vr_modalida := GENE0002.fn_char_para_number(vr_campo(9));
      
      IF vr_modalida = 1  THEN 
        vr_cdhistor := 2350;
      ELSE
         vr_cdhistor := 2351;
      END IF;

      vr_linhaarq := vr_cdcooper || ';' || vr_nrdconta || ';' || vr_nrctremp || ';';

      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      
      if rw_crapass.inprejuz = 1 then
        vr_linhaarq := vr_linhaarq || ';;Conta em prejuizo;';
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,vr_linhaarq);
        CONTINUE;
      end if;

      --Nas operações de empréstimos liquidadas, realizar o histórico 2350 na conta do Cooperado;
      --Nas operações de financiamentos liquidadas, realizar o histórico 2351 na conta do Cooperado;
                                                                 
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => vr_cdcooper   --> Cooperativa conectada
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Movimento atual
                                    ,pr_cdagenci => rw_crapass.cdagenci   --> Codigo da agencia
                                    ,pr_cdbccxlt => 100           --> Numero do caixa
                                    ,pr_cdoperad => 1   --> Codigo do operador
                                    ,pr_cdpactra => rw_crapass.cdagenci   --> PA da transacao
                                    ,pr_nrdolote => 600031        --> Numero do Lote
                                    ,pr_nrdconta => vr_nrdconta   --> Número da conta
                                    ,pr_cdhistor => vr_cdhistor  --> Codigo historico
                                    ,pr_vllanmto => vr_lanctoaj   
                                    ,pr_nrparepr => 0   
                                    ,pr_nrctremp => vr_nrctremp   --> Numero do contrato de emprestimo
                                    ,pr_nrseqava => 0   --> Pagamento: Sequencia do avalista
                                    ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
                                        
      IF vr_des_reto <> 'OK' THEN
         vr_linhaarq := vr_linhaarq || ';' || vr_des_reto || ';';
         gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,vr_linhaarq);
         ROLLBACK;
         CONTINUE;
      END IF;
      
       vr_linhaarq := vr_linhaarq || 'SIM;';
      
      -- Verificar contrato se estiver liquidado não virá no cursor e passaremos para o próximo registro
      OPEN cr_crapepr(vr_cdcooper
                     ,vr_nrdconta
                     ,vr_nrctremp
                     );
      FETCH cr_crapepr INTO rw_crapepr;
      IF cr_crapepr%NOTFOUND THEN
         CLOSE cr_crapepr;
         vr_linhaarq := vr_linhaarq || ';Contrato liquidado;';
         gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,vr_linhaarq);
        CONTINUE;
      END IF;
      CLOSE cr_crapepr;

      credito.gerarPagamentoParcialPOS(pr_cdcooper => vr_cdcooper,
                                       pr_cdagenci => rw_crapass.cdagenci,
                                       pr_nrdcaixa => 1,
                                       pr_cdoperad => 1,
                                       pr_idorigem => 1,
                                       pr_nmdatela => 'INTERNETBANK',
                                       pr_nrdconta => vr_nrdconta,
                                       pr_idseqttl => 1,
                                       pr_nrctremp => vr_nrctremp,
                                       pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                       pr_dtmvtoan => rw_crapdat.dtmvtoan,
                                       pr_cdlcremp => rw_crapepr.cdlcremp,
                                       pr_vlemprst => rw_crapepr.vlemprst,
                                       pr_txmensal => rw_crapepr.txmensal,
                                       pr_dtprivct => rw_crapepr.dtprivct,
                                       pr_vlsprojt => rw_crapepr.vlsprojt,
                                       pr_qttolar  => rw_crapepr.qttolatr,
                                       pr_dtefetiv => rw_crapepr.dtefetiv,
                                       pr_ordempgo => 1,
                                       pr_totpagto => vr_lanctoaj,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);
                                       
      IF nvl(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL THEN
         vr_linhaarq := vr_linhaarq || ';' || vr_dscritic || ';';
         gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,vr_linhaarq);
         ROLLBACK;
         CONTINUE;
      END IF;
      
      vr_linhaarq := vr_linhaarq || 'SIM;';
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,vr_linhaarq);
      COMMIT;
   END LOOP;
   
   gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); 
   
   COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line( sqlerrm);
    dbms_output.put_line( sqlcode);
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
END;
