
declare 
  vr_ind_arq  utl_file.file_type;
  vr_linha VARCHAR2(32767);
  vr_dscritic VARCHAR2(2000);
  vr_nmdir        VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0100137';  
  vr_nmarq VARCHAR2(100)  := 'ROLLBACK_INC0100137.sql';   
  vr_datadia date;
  vr_exc_saida  EXCEPTION;  
cursor cr_tbseg_prst is 
  Select nrproposta, cdcooper, nrctrseg, nrdconta, dtrecusa, situacao, tprecusa, CdMotrec, tpregist
  From tbseg_prestamista a where nrproposta in
      (770353134345 ,770352595837 ,770351134720 ,770351954582 ,770351006846 ,770352188581 ,770351758961 ,770351322314 
      ,770352362565 ,770352039861 ,770351324228 ,770352022020 ,770352390852 ,770352149500 ,770351891556 ,770353082108 
      ,770352002399 ,770352007706 ,770351892323 ,770351172568 ,770352789984 ,770352789984 ,770352308439 ,770351043601 
      ,770352260053 ,770351323221 ,770352340111 ,770352219444 ,770352397890 ,770351788780 ,770352420107 ,770352148512 
      ,770352558915 ,770352345261 ,770351317558 ,770350734058 ,770352127906 ,770351042168 ,770352685577 ,770351146265 
      ,770352772895 ,770352675776 ,770351082933 ,770351884657 ,770352821420 ,770350687408 ,770351087013 ,770351656603 
      ,770351405112 ,770353699067, 770353388525 ,770351040106 ,770352007668 ,770352599921 ,770350699635 ,770352595756 
      ,770352574406 ,770352013030 ,770351440058 ,770353080865 ,770352013781 ,770351366370 ,770351324210 ,770352551805 
      ,770351880422 ,770351027045 ,770351027002 ,770352490245 ,770351425075 ,770352263877 ,770351903392 ,770351006552 
      ,770352481890 ,770350890181 ,770353805436 ,770351542993 ,770350840931 ,770352022560 ,770351196360 ,770350899456 
      ,770353409948 ,770352483168 ,770350840940 ,770351312769 ,770351696630 ,770352527858 ,770352474592 ,770353402048 
      ,770351520442 ,770351696710 ,770351031395 ,770353233521 ) Order by 1  ;
  rw_tbseg cr_tbseg_prst%rowtype ;

 Cursor cr_crapseg(
   pr_cdcooper crapseg.cdcooper%type,   
   pr_nrdconta crapseg.nrdconta%type,
   pr_nrctrseg crapseg.nrctrseg%type ) is
  select cdcooper, nrdconta, nrctrseg, tpseguro
  , dtfimvig, dtcancel, cdsitseg, cdopeexc, cdageexc, dtinsexc, cdopecnl from crapseg
   where crapseg.nrctrseg = pr_nrctrseg  
     and crapseg.nrdconta = pr_nrdconta  
     and crapseg.cdcooper = pr_cdcooper  
     and crapseg.tpseguro = 4 ; 
  rw_crapseg cr_crapseg%rowtype;
  begin 
    begin
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir 
                                ,pr_nmarquiv => vr_nmarq                
                                ,pr_tipabert => 'W'                    
                                ,pr_utlfileh => vr_ind_arq             
                                ,pr_des_erro => vr_dscritic);          
        IF vr_dscritic IS NOT NULL THEN         
           vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdir || vr_nmarq;     
           RAISE vr_exc_saida;
        END IF;
        
     vr_datadia:= to_date(sysdate, 'dd/mm/yyyy');
        
     GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');                      
     for  rw_tbseg in cr_tbseg_prst loop 
     
       vr_linha :='';
       
       Open cr_crapseg(rw_tbseg.cdcooper, rw_tbseg.nrdconta, rw_tbseg.nrctrseg);
       fetch cr_crapseg INTO rw_crapseg;
       
       if cr_crapseg%NOTFOUND THEN  
          close cr_crapseg;      
          continue; 
       else 
         vr_linha :=           'update crapseg '
                             ||' set dtfimvig = to_date('''||rw_crapseg.dtfimvig||''',''DD/MM/YYYY'' ) , '
                             ||'     dtcancel = to_date('''||rw_crapseg.dtcancel||''',''DD/MM/YYYY'' ) , ' 
                             ||'  cdsitseg = '||nvl(trim(TO_CHAR( rw_crapseg.cdsitseg)),'NULL')  ||', '
                             ||'  cdageexc = '||nvl(trim(TO_CHAR( rw_crapseg.cdageexc)),' ')  ||', '
                             ||'  dtinsexc = to_date('''||rw_crapseg.dtinsexc||''',''DD/MM/YYYY'' ) , ' 
                             ||'  cdopecnl = '||nvl(trim(TO_CHAR(  rw_crapseg.cdopecnl)),'NULL') 
                             ||'  where nrctrseg = '||rw_crapseg.nrctrseg  
                             ||'  and nrdconta = '||rw_crapseg.nrdconta  
                             ||'  and cdcooper = '||rw_crapseg.cdcooper  
                             ||'  and tpseguro = '||rw_crapseg.tpseguro||' ; ';        
         GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);               
       end if; 
       
       vr_linha :='';
       close cr_crapseg;  
              
       vr_linha :=  ' UPDATE TBSEG_PRESTAMISTA set situacao = '|| nvl(TO_CHAR(rw_tbseg.situacao),'NULL')
                  ||', dtrecusa = to_date('''|| rw_tbseg.dtrecusa ||''',''DD/MM/YYYY'' ) '
                  ||', tprecusa = '||nvl(trim(TO_CHAR(rw_tbseg.tprecusa)),'NULL')
                  ||', CdMotrec = '||nvl(trim(TO_CHAR(rw_tbseg.CdMotrec)),'NULL')
                  ||', tpregist = '||nvl(trim(TO_CHAR(rw_tbseg.tpregist)),'NULL')
                  ||' WHERE nrproposta = '||rw_tbseg.nrproposta||'; ';
       GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);                    
       
       
         UPDATE TBSEG_PRESTAMISTA set situacao = 0 
         , dtrecusa = to_date('01/08/2021','DD/MM/YYYY' )
         , tprecusa = 8
         , CdMotrec = 193
         , tpregist = 0    
         WHERE nrproposta = rw_tbseg.nrproposta; 
         
         UPDATE crapseg
           set crapseg.dtfimvig = to_date('01/08/2021','DD/MM/YYYY')
           ,   crapseg.dtcancel = vr_datadia
           ,   crapseg.cdsitseg = 5
           ,   crapseg.cdopeexc = 1
           ,   crapseg.cdageexc = 1
           ,   crapseg.dtinsexc = vr_datadia
           ,   crapseg.cdopecnl = 1  
           where crapseg.nrctrseg = rw_crapseg.nrctrseg  
            and crapseg.nrdconta = rw_crapseg.nrdconta   
            and crapseg.cdcooper = rw_crapseg.cdcooper   
            and crapseg.tpseguro = 4 ;   
     commit;       
    
    end loop;
    GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' commit;');                 
    GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' EXCEPTION ');                    
    GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'  WHEN OTHERS THEN ');                 
    GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'   ROLLBACK;');                    
    GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');                 
    GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');                 
                    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );      
   
    
    EXCEPTION 
       WHEN vr_exc_saida THEN
            vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            dbms_output.put_line(vr_dscritic);  
            ROLLBACK;
       when others then
            vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            dbms_output.put_line(vr_dscritic);              
            ROLLBACK;
    END;      

END ;
