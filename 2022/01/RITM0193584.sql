
DECLARE

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/RITM0193584';
  vr_nmarqimp        VARCHAR2(100)  := 'rollback.sql';
  vr_ind_arquiv      utl_file.file_type;
  vr_excsaida        EXCEPTION;
  vr_dscritic        varchar2(5000) := ' ';
  
   -- Cursor para buscar os rep. legal/procurador que foram gerados com tpdoc errado
   CURSOR cr_contas IS
select *
  from (
        select enc.progress_recid
             , enc.dsendere
             , translate(enc.dsendere,'ÑÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÄËÏÖÜÇñáéíóúàèìòùâêîôûãõäëïöüç.!"''#$%().:[/]{}¨¡+?;ºª°§&*<>','NAEIOUAEIOUAEIOUAOAEIOUCnaeiouaeiouaeiouaoaeiouc') dsendere2
             , enc.complend
             , translate(enc.complend,'ÑÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÄËÏÖÜÇñáéíóúàèìòùâêîôûãõäëïöüç.!"''#$%().:[/]{}¨¡+?;ºª°§&*<>','NAEIOUAEIOUAEIOUAOAEIOUCnaeiouaeiouaeiouaoaeiouc') complend2
             , enc.nmbairro
             , translate(enc.nmbairro,'ÑÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÄËÏÖÜÇñáéíóúàèìòùâêîôûãõäëïöüç.!"''#$%().:[/]{}¨¡+?;ºª°§&*<>','NAEIOUAEIOUAEIOUAOAEIOUCnaeiouaeiouaeiouaoaeiouc') nmbairro2
             , enc.nmcidade
             , translate(enc.nmcidade,'ÑÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÄËÏÖÜÇñáéíóúàèìòùâêîôûãõäëïöüç.!"''#$%().:[/]{}¨¡+?;ºª°§&*<>','NAEIOUAEIOUAEIOUAOAEIOUCnaeiouaeiouaeiouaoaeiouc') nmcidade2
          from crapenc enc
             , (select a.cdcooper
                     , a.nrdconta
                from tbcadast_precadastro p
                join crapass              a on p.nrcpfcgc = a.nrcpfcgc
                where p.dtconsultacpf is not null 
                  and trunc(a.dtadmiss) >= to_date('17/11/2021', 'dd/mm/rrrr') ) cta
         where enc.cdcooper = cta.cdcooper
           and enc.nrdconta = cta.nrdconta ) dados
  where ( dados.dsendere != dados.dsendere2
     or dados.complend != dados.complend2
     or dados.nmbairro != dados.nmbairro2
     or dados.nmcidade != dados.nmcidade2 );
         
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
  END;
         
BEGIN 
  
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

   FOR rw_contas IN cr_contas LOOP
     begin 
      --endereco
      if rw_contas.dsendere != rw_contas.dsendere2 then

        update crapenc
           set dsendere = rw_contas.dsendere2
         where progress_recid = rw_contas.progress_recid;
      
        backup('update crapenc set dsendere = '''|| rw_contas.dsendere ||
                ''' where progress_recid = '|| rw_contas.progress_recid || ';');
      end if;    
      --complemento
      if rw_contas.complend != rw_contas.complend2 then

        update crapenc
           set complend = rw_contas.complend2
         where progress_recid = rw_contas.progress_recid;
      
        backup('update crapenc set complend = '''|| rw_contas.complend ||
                ''' where progress_recid = '|| rw_contas.progress_recid || ';');
      end if;          
      
      --bairro
      if rw_contas.nmbairro != rw_contas.nmbairro2 then

        update crapenc
           set nmbairro = rw_contas.nmbairro2
         where progress_recid = rw_contas.progress_recid;
      
        backup('update crapenc set nmbairro = '''|| rw_contas.nmbairro ||
                ''' where progress_recid = '|| rw_contas.progress_recid || ';');
      end if;      
      
      --cidade
      if rw_contas.nmcidade != rw_contas.nmcidade2 then

        update crapenc
           set nmcidade = rw_contas.nmcidade2
         where progress_recid = rw_contas.progress_recid;
      
        backup('update crapenc set nmcidade = '''|| rw_contas.nmcidade ||
                ''' where progress_recid = '|| rw_contas.progress_recid || ';');
      end if;                                     
             
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro progress_recid '|| rw_contas.progress_recid ||' - ERRO: ' || SQLERRM;
          RAISE vr_excsaida;
      END;
   END LOOP;

  COMMIT;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
EXCEPTION    
  WHEN vr_excsaida then
    ROLLBACK;
    raise_application_error( -20001,vr_dscritic);         
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    
  WHEN OTHERS then
    ROLLBACK;
    raise_application_error( -20001,'Erro baixando a pendencia de digitalizacao - '    ||
                                    'erro: ' || sqlerrm);         

    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
end;