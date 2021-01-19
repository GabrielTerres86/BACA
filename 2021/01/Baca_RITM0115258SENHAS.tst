PL/SQL Developer Test script 3.0
76
-- Created on 19/01/2021 by F0032948 
declare 
  -- Local variables here
  vr_novasenha varchar2(100) default  '';
  vr_senhamd5 varchar2(100) default  '';
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas';
  vr_nmarqimp        VARCHAR2(100)  := 'baca_senha.txt';   
  vr_ind_arquiv      utl_file.file_type;
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION; 
  
  
  CURSOR cr_dados is
    select cdr.cdcooper,cdr.nrdconta,cdc.dsemail,cdc.dstelefone,usu.idusuario,usu.dslogin,usu.dssenha,usu.flgativo,usu.flgbloque, ass.nrmatric,ass.nrcpfcgc,cdc.nmfantasia,ass.nmprimtl 
    from crapcdr cdr
    inner join tbsite_cooperado_cdc cdc on cdc.cdcooper = cdr.cdcooper and cdr.nrdconta = cdc.nrdconta
    inner join tbepr_cdc_usuario_vinculo vin on vin.idcooperado_cdc = cdc.idcooperado_cdc
    inner join tbepr_cdc_usuario usu on usu.idusuario = vin.idusuario
    inner join crapass ass on ass.cdcooper = cdr.cdcooper and ass.nrdconta = cdr.nrdconta and lpad(ass.nrcpfcgc,14,0) = lpad(usu.dslogin,14,0)
    where cdr.cdcooper = 1 and cdr.flgconve = 1 and cdr.dtcancon is null
    --and usu.dslogin = '10679260000199'
    ;
    rw_dados cr_dados%ROWTYPE;  
begin
   vr_contador:=0;
--Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;    
                     
    FOR rw_dados IN cr_dados LOOP
        vr_novasenha := lpad(ROUND(DBMS_RANDOM.VALUE(1,99))||rw_dados.nrmatric,8,0);
        
        vr_senhamd5 := lower(dbms_obfuscation_toolkit.md5(
                        input => UTL_RAW.cast_to_raw(vr_novasenha)));
        
        vr_contador:= vr_contador + 1;       
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update tbepr_cdc_usuario set dssenha = '''||rw_dados.dssenha  
    ||''' where idusuario = '''|| rw_dados.idusuario ||'''; -- '||vr_senhamd5 ||' - ' ||vr_novasenha );
      begin              
        update tbepr_cdc_usuario usu set usu.dssenha = vr_senhamd5 where usu.idusuario = rw_dados.idusuario;
      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar tbepr_cdc_usuario! idusuario: '||
                       rw_dados.idusuario;
        RAISE vr_excsaida;
    END;
    END LOOP;    
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); 
    
   COMMIT;
   -- rollback;
    
    :vr_dscritic := 'SUCESSO -> Registros atualizados: '|| vr_contador;
  exception  
   WHEN vr_excsaida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
  when others then 
       gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
       :vr_dscritic := 'ERRO ' || sqlerrm;
       rollback;
end;
1
vr_dscritic
1
SUCESSO -> Registros atualizados: 1
5
0
