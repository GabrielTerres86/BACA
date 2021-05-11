PL/SQL Developer Test script 3.0
100
-- Created on 10/05/2021 by F0030367 
declare 

  vr_nrproposta      varchar2(30);
  vr_dscritic        varchar2(1000);
  vr_exc_saida       EXCEPTION;  
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/INC0089201';
  -- Arquivo de rollback
  vr_nmarqimp        VARCHAR2(100)  := 'INC0089201_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type; 
  
  cursor cr_prestamista is 
  select cdapolic, 
         cdcooper, 
         nrdconta, 
         nrctrseg, 
         nrctremp,
         nrproposta
    from tbseg_prestamista
   where cdapolic = 268189;   
   rw_prestamista cr_prestamista%ROWTYPE;
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

  -- Test statements here
  open cr_prestamista;
  fetch cr_prestamista into rw_prestamista;
  
  if cr_prestamista%found then
     
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
   end if;
   CLOSE cr_prestamista;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  :vr_dscritic := 'Registro atualziado com sucesso!';
EXCEPTION
  WHEN vr_exc_saida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;  

1
vr_dscritic
1
Registro atualziado com sucesso!
5
0
