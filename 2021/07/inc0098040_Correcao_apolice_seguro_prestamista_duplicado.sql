declare
  vr_nrproposta      varchar2(30);
  vr_dscritic        varchar2(1000);
  vr_exc_saida       EXCEPTION;  
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/INC0098040';
  
  -- Arquivo de rollback
  vr_nmarqimp        VARCHAR2(100)  := 'INC0098040_ROLLBACK.txt';     
  vr_ind_arquiv      utl_file.file_type; 
  
cursor cr_apolic is
  select p.cdapolic
    from tbseg_prestamista p
   where (p.nrcpfcgc = 5278300973  and p.nrproposta = 770353994018)
      or (p.nrcpfcgc = 8354717992  and p.nrproposta = 770354084848)
      or (p.nrcpfcgc = 82851620010 and p.nrproposta = 770354275066)
      or (p.nrcpfcgc = 93966881934 and p.nrproposta = 770354071215)
      or (p.nrcpfcgc = 433397942   and p.nrproposta = 770353898620)
      or (p.nrcpfcgc = 95537260972 and p.nrproposta = 770354145928)
      or (p.nrcpfcgc = 10679776940 and p.nrproposta = 770354290880)
      or (p.nrcpfcgc = 2635456950  and p.nrproposta = 770353978497)
      or (p.nrcpfcgc = 6668324983  and p.nrproposta = 770353956582)
      or (p.nrcpfcgc = 8475306985  and p.nrproposta = 770354259125)
      or (p.nrcpfcgc = 9484333966  and p.nrproposta = 770354170655)
      or (p.nrcpfcgc = 11299747906 and p.nrproposta = 770354147750)
      or (p.nrcpfcgc = 12092139908 and p.nrproposta = 770353942271)
      or (p.nrcpfcgc = 73034053991 and p.nrproposta = 770354142228)
      or (p.nrcpfcgc = 996304940   and p.nrproposta = 770354056461)
      or (p.nrcpfcgc = 4264188911  and p.nrproposta = 770353998218)
      or (p.nrcpfcgc = 7432825904  and p.nrproposta = 770354428148)
      or (p.nrcpfcgc = 8208056960  and p.nrproposta = 770354078295)
      or (p.nrcpfcgc = 9032236946  and p.nrproposta = 770353993194)
      or (p.nrcpfcgc = 9032236946  and p.nrproposta = 770354265419)
      or (p.nrcpfcgc = 9489128988  and p.nrproposta = 770354124556)
      or (p.nrcpfcgc = 11208073958 and p.nrproposta = 770354207788);
  
  cursor cr_prestamista(p_cdapolic tbseg_prestamista.cdapolic%type) is 
  select cdapolic, 
         cdcooper, 
         nrdconta, 
         nrctrseg, 
         nrctremp,
         nrproposta
    from tbseg_prestamista
   where cdapolic = p_cdapolic;
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
  
  for rw_apolic in cr_apolic loop
    for rw_prestamista in cr_prestamista(rw_apolic.cdapolic) loop
       
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
   end loop;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  vr_dscritic := 'Registro atualizado com sucesso!';
  dbms_output.put_line(vr_dscritic);
EXCEPTION
  WHEN vr_exc_saida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    vr_dscritic := 'ERRO ' || vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    rollback;
end; 
/
