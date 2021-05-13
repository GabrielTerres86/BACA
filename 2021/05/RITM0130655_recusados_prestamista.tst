PL/SQL Developer Test script 3.0
198
DECLARE
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/RITM0130655';
  -- Arquivo de rollback
  vr_nmarq_rollback        VARCHAR2(100)  := 'RITM0130655_ROLLBACK.txt';    
  vr_nmarquivo       varchar2(100)  := 'recusados_prestamista.csv';
  
  vr_lstdarqv          VARCHAR2(4000); 
  vr_nome_novo_arquivo VARCHAR2(70);
  vr_handle_leitura    utl_file.file_type;  
  vr_handle_escrita    utl_file.file_type;  
  vr_vet_nmarquiv      GENE0002.typ_split;
  vr_setlinha          VARCHAR2(10000);
  vr_contlinha         integer;

  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(20000) := NULL;
  vr_exc_saida  EXCEPTION; -- Falha que deverá parar o processamento                                                       
  
  vr_nrcpfcgc      number;
  vr_nome          varchar2(100);
  vr_proposta      varchar2(30);
  vr_nrctrato      number;
  vr_motivo_recusa varchar2(200);  
  
  ------ Cursores -------
   CURSOR cr_tbseg_prst(pr_nrproposta TBSEG_PRESTAMISTA.nrproposta%type ) IS
       select a.cdcooper, 
              a.nrdconta,
              a.nrctrseg, 
              a.nrctremp,
              a.cdapolic,
              a.tpregist
       from TBSEG_PRESTAMISTA a 
         where a.nrproposta = pr_nrproposta;                
       rw_tbseg_prst cr_tbseg_prst%rowtype;
 
    CURSOR cr_crawseg( pr_cdcooper crawseg.cdcooper%type,
                       pr_nrdconta crawseg.nrdconta%type,
                       pr_nrctrato crawseg.nrctrato%type,
                       pr_nrproposta crawseg.nrproposta%type) IS
    select s.cdcooper, 
           s.nrdconta, 
           s.tpseguro, 
           s.nrctrseg
      from crawseg s
     where s.cdcooper = pr_cdcooper
       and s.nrdconta = pr_nrdconta
       and s.nrctrato = pr_nrctrato
       and s.nrproposta = pr_nrproposta
       and exists(select 1
                    from crapseg g
                   where g.cdcooper = s.cdcooper
                     and g.nrdconta = s.nrdconta
                     and g.nrctrseg = s.nrctrseg
                     and g.tpseguro = 4);
    rw_crawseg cr_crawseg%rowtype;
BEGIN  
 
  -- Abrir rollback
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto  --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nmarq_rollback  --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_handle_escrita  --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> Erro
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic:= vr_dscritic || ' - '||vr_nmarq_rollback;
    RAISE vr_exc_saida;
  END IF; 
 
  -- abrir o arquivo pra importar
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto, --> Diretorio do arquivo
                           pr_nmarquiv => vr_nmarquivo, --> Nome do arquivo
                           pr_tipabert => 'R',               --> Modo de abertura (R,W,A)
                           pr_utlfileh => vr_handle_leitura, --> Handle do arquivo aberto
                           pr_des_erro => vr_dscritic);      --> Erro
            
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic:= vr_dscritic || ' - '||vr_nmarquivo;  
    RAISE vr_exc_saida;
  END IF;   
    
  vr_contlinha:= 0;
  
  --------------- Inicio leitura do arquivo ----------------
  LOOP
    BEGIN
      -- loop para ler a linha do arquivo
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_leitura, --> Handle do arquivo aberto
                                   pr_des_text => vr_setlinha); --> Texto lido
    EXCEPTION
      WHEN no_data_found THEN
        --Chegou ao final arquivo, sair do loop
        EXIT;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na leitura do arquivo: '||vr_nmarquivo||'. ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    vr_contlinha:= vr_contlinha + 1;
        
    -- ignorar primeira linha
    IF vr_contlinha = 1 THEN
      continue;
    END IF;
    
    --cpf;nome;proposta;Contrato;Motivo_Recusa
    begin
      vr_nrcpfcgc := replace(replace(gene0002.fn_busca_entrada(1,vr_setlinha,';'),'.',''),'-','');
      vr_nome := gene0002.fn_busca_entrada(2,vr_setlinha,';');
      vr_proposta:= gene0002.fn_busca_entrada(3,vr_setlinha,';');
      vr_nrctrato := gene0002.fn_busca_entrada(4,vr_setlinha,';');
      vr_motivo_recusa := gene0002.fn_busca_entrada(5,vr_setlinha,';');  
    exception
      when others then
        vr_dscritic := 'Erro na busca dos valores do arquivo: '||vr_nmarquivo||'. ' || SQLERRM;
        RAISE vr_exc_saida;
    end;
    
    ---- Inicio atualizacao de cancelamento ------     
     open cr_tbseg_prst(vr_proposta);
     fetch cr_tbseg_prst INTO rw_tbseg_prst;
           
     if cr_tbseg_prst%NOTFOUND THEN
       CLOSE cr_tbseg_prst;
     ELSE
       CLOSE cr_tbseg_prst;

       gene0001.pc_escr_linha_arquivo(vr_handle_escrita,'update tbseg_prestamista set tpregist = '||rw_tbseg_prst.tpregist
                                                      ||' where cdapolic = '||rw_tbseg_prst.cdapolic||';');         
       
       Begin                    
         UPDATE TBSEG_PRESTAMISTA set TPREGIST = 0 WHERE nrproposta = vr_proposta; 
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao cancelar recusa de numero de proposta: '||vr_proposta
                          ||' no registro tbseg_prestamista. '|| SQLERRM;                 
           raise vr_exc_saida;
       END;               
          
       --- Cancelar o seguro na crapseg;  
       open  cr_crawseg(rw_tbseg_prst.cdcooper, 
                        rw_tbseg_prst.nrdconta,
                        rw_tbseg_prst.nrctremp,
                        vr_proposta);           
       FETCH cr_crawseg INTO rw_crawseg;
          
       IF cr_crawseg%NOTFOUND THEN
         CLOSE cr_crawseg;                                   
       ELSE
         CLOSE cr_crawseg;
         
         gene0001.pc_escr_linha_arquivo(vr_handle_escrita,'update crapseg set cdsitseg = 1, dtcancel = ''''' ||
                                                          ', cdopeexc = 0'||
                                                          ', cdageexc = 0'||
                                                          ', dtinsexc = '''''||
                                                          ',cdopecnl = '''''||
                                                          ' where cdcooper = '||rw_crawseg.cdcooper||
                                                          ' and nrdconta = '|| rw_crawseg.nrdconta ||
                                                          ' and nrctrseg = '|| rw_crawseg.nrctrseg ||
                                                          ' and tpseguro = 4;');
                                   
          BEGIN
            update crapseg
               set crapseg.dtcancel = to_date(sysdate,'DD/MM/RRRR'), -- Data de cancelamento
                   crapseg.cdsitseg = 2, -- cancelado
                   crapseg.cdopeexc = 1,
                   crapseg.cdageexc = 1,
                   crapseg.dtinsexc = to_date(sysdate,'DD/MM/RRRR'),
                   crapseg.cdopecnl = 999
             where crapseg.nrctrseg = rw_crawseg.nrctrseg 
               and crapseg.nrdconta = rw_crawseg.nrdconta 
               and crapseg.cdcooper = rw_crawseg.cdcooper
               and crapseg.tpseguro = rw_crawseg.tpseguro;                                                                              
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao cancelar recusa de numero de proposta: '||vr_proposta||
                             ' registro da crapseg '|| SQLERRM;  
              raise vr_exc_saida;                          
          END;  
        END IF; 
     END IF;   
    --- Fim atualizacao de cancelamento ------
    
  END LOOP;
  ------------ Fim da leitura do arquivo -----------
  commit;
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_leitura); --> Handle do arquivo aberto;
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_escrita); --> Handle do arquivo aberto;

  :pr_dscritic := 'Arquivo importado com sucesso!';
  
EXCEPTION
  WHEN vr_exc_saida THEN
    :pr_dscritic := vr_dscritic;   
  WHEN OTHERS THEN
    :pr_dscritic := vr_dscritic ||' '||SQLERRM;
END;
1
pr_dscritic
1
Arquivo importado com sucesso!
5
6
vr_nmarquivo
vr_nrcpfcgc
vr_nome
vr_nrctrato
vr_motivo_recusa
vr_proposta
