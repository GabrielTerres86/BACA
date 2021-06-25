PL/SQL Developer Test script 3.0
100
declare 

  vr_nrproposta      varchar2(30);
  vr_dscritic        varchar2(1000);
  vr_exc_saida       EXCEPTION;  
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/INC0094806';
  
  -- Arquivo de rollback
  vr_nmarqimp        VARCHAR2(100)  := 'INC0094806_ROLLBACK.txt';     
  vr_ind_arquiv      utl_file.file_type; 
  
  cursor cr_prestamista is 
  select cdapolic, 
         cdcooper, 
         nrdconta, 
         nrctrseg, 
         nrctremp,
         nrproposta
    from tbseg_prestamista
   where cdapolic in (270187, 274109, 275945, 277109, 273253,
                      279068, 277916, 277031, 273371, 279021,
                      272280, 274148, 275740, 283317, 276962, 
                      279057, 270377, 273501, 280053, 283783,
                      276920, 276835, 273797, 277515, 279153,
                      273300, 280398, 280987, 270295, 277225,
                      273193, 276997, 282025, 271879, 270676,
                      270536, 283269, 278417, 273074, 276952, 280266);
begin

  --Criar arquivo de Roll Back
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;
  
  for rw_prestamista in cr_prestamista loop
     
     SELECT SEGU0003.FN_NRPROPOSTA() INTO vr_nrproposta  FROM DUAL; 
               
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update tbseg_prestamista set nrproposta = '||rw_prestamista.nrproposta
                                                 ||' where cdapolic = '||rw_prestamista.cdapolic||';');
         
      begin            
        update tbseg_prestamista g 
           set g.nrproposta = vr_nrproposta
         where g.cdapolic = rw_prestamista.cdapolic;
      exception
        when others then
          vr_dscritic:= 'Erro ao gravar numero de proposta 1: '||vr_nrproposta||' - '||sqlerrm;
          raise vr_exc_saida;              
      end;
          
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crawseg set nrproposta = '||rw_prestamista.nrproposta 
                                                 ||' where cdcooper = '||rw_prestamista.cdcooper
                                                 ||' and nrdconta = ' ||rw_prestamista.nrdconta
                                                 ||' and nrctrseg = ' ||rw_prestamista.nrctrseg
                                                 ||' and nrctrato = ' ||rw_prestamista.nrctremp||';');
           
      begin            
        update crawseg g 
           set g.nrproposta = vr_nrproposta
         where g.cdcooper = rw_prestamista.cdcooper
           and g.nrdconta = rw_prestamista.nrdconta
           and g.nrctrseg = rw_prestamista.nrctrseg
           and g.nrctrato = rw_prestamista.nrctremp;      
      exception
        when others then
          vr_dscritic:= 'Erro ao gravar numero de proposta 2: '||vr_nrproposta||' - '||sqlerrm;
          raise vr_exc_saida;                
      end;
          
      -- Gravar data da utilização da proposta para que nao utilize mais o mesmo numero
      begin
        UPDATE TBSEG_NRPROPOSTA 
           SET DTSEGURO = SYSDATE 
         WHERE NRPROPOSTA = vr_nrproposta; 
      exception
        when others then
          vr_dscritic:= 'Erro ao atualizar numero de TBSEG_NRPROPOSTA: '||vr_nrproposta||' - '||sqlerrm;
          raise vr_exc_saida;              
      end;
     commit;
   end loop;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  :vr_dscritic := 'Registro atualizado com sucesso!';
EXCEPTION
  WHEN vr_exc_saida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;  
1
vr_dscritic
1
Registro atualizado com sucesso!
5
0
