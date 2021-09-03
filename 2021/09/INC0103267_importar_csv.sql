declare
      vr_dslinhaarq varchar2(2000);
      vr_nrproposta tbseg_prestamista.nrproposta%type;  
      vr_nrpropost2 tbseg_prestamista.nrproposta%type;  
      vr_nrcontrato varchar2(200);
      vr_apolice    varchar2(200);
      vr_nomecooper varchar2(2000);
      vr_cpf        varchar2(200);
      vr_datastr    varchar2(200);
      vr_dtinivig  date;
      vr_dtdvenda  date;
      vr_dtinivi2  date; 
      vr_dtdeven2  date;            
      vr_produto   varchar2(200);      
      vr_premio    varchar2(200);      
      vr_capital   varchar2(200);                  
      vr_refcob    varchar2(200);                  
      vr_finalctr  varchar2(200);                        
      vr_nrlinha   number(9);
      vr_nmdirrec  varchar2(2000);
      vr_nmarqmov  varchar2(2000);
      vr_nmarq     varchar2(2000);
      vr_dscritic  varchar2(2000); 
      vr_cdcooper  tbseg_prestamista.cdcooper%type;  
      vr_nrdconta  tbseg_prestamista.nrdconta%type;  
      vr_nrctrseg  tbseg_prestamista.nrctrseg%type;  
      vr_cdapolic  tbseg_prestamista.cdapolic%type;  
      vr_idseqtra  tbseg_prestamista.idseqtra%type; 
      vr_PROGRESS_RECID crawseg.PROGRESS_RECID%type; 

      vr_exc_saida  EXCEPTION;      
      vr_arqhandle  utl_file.file_type;      
      vr_ind_arq    utl_file.file_type;
      vr_linha      VARCHAR2(32767);      
     TYPE typ_reg_arq IS RECORD(
       cpf        varchar2(200),
       nrcontrato varchar2(200),
       apolice    varchar2(200),       
       nomecooper varchar2(2000),
       nrproposta varchar2(200),
       nrpropost2 varchar2(200),
       dtinivig   date,
       dtdvenda   date,              
       dtinivi2   date,
       dtdvend2   date,              
       produto    varchar2(200),      
       premio     varchar2(200),      
       capital    varchar2(200),                  
       refcob     varchar2(200),                  
       finalctr   varchar2(200),
       cdcooper   tbseg_prestamista.cdcooper%type,
       nrdconta   tbseg_prestamista.nrdconta%type,  
       nrctrseg   tbseg_prestamista.nrctrseg%type,  
       cdapolic   tbseg_prestamista.cdapolic%type,  
       idseqtra   tbseg_prestamista.idseqtra%type,
       tpseguro   varchar2(1),        
       PROGRESS_RECID CRAWSEG.PROGRESS_RECID%TYPE
      );
    --Definicao dos tipos de tabelas
    TYPE typ_tab_arquiv IS TABLE OF typ_reg_arq INDEX BY PLS_INTEGER;
    vr_tabarquiv typ_tab_arquiv ;
begin
   BEGIN
      vr_nmdirrec := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0103267';
      vr_nmarqmov := 'propostas_icatu.csv';                           
      vr_nmarq    := 'ROLLBACK_INC0103267.sql';
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirrec
                              ,pr_nmarquiv => vr_nmarqmov
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_arqhandle
                              ,pr_des_erro => vr_dscritic );

      if vr_dscritic is not null then
          vr_dscritic  := 'Erro na abertura do arquivo --> '|| vr_nmdirrec||'/' ||vr_nmarqmov ||' --> '||vr_dscritic ;
          RAISE vr_exc_saida;
      end if;


       vr_nrlinha := 0;
          loop
              vr_nrlinha := vr_nrlinha + 1;
              begin
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                           ,pr_des_text => vr_dslinhaarq );
              exception
                  when others then
                    vr_dslinhaarq := '';
              end;
               
              if nvl(trim(vr_dslinhaarq),' ') = ' ' then
                 exit;
              end if;                
              vr_dslinhaarq := replace (vr_dslinhaarq,'"','');
              vr_cpf        := gene0002.fn_busca_entrada(1,vr_dslinhaarq,';');
              vr_nrcontrato := gene0002.fn_busca_entrada(2,vr_dslinhaarq,';');              
              vr_apolice    := gene0002.fn_busca_entrada(4,vr_dslinhaarq,';');
              vr_nomecooper := gene0002.fn_busca_entrada(5,vr_dslinhaarq,';');             
              vr_nrproposta := gene0002.fn_busca_entrada(6,vr_dslinhaarq,';');             
              vr_datastr    := gene0002.fn_busca_entrada(7,vr_dslinhaarq,';');
              vr_datastr    := TRIM(vr_datastr);
              vr_datastr := replace(vr_datastr,'/','');
              vr_datastr := replace(vr_datastr,'-','');
              begin
                 vr_dtdvenda  := to_date(vr_datastr,'ddmmrrrr');
              exception
                when others then
                 vr_dtdvenda  := null;
              end;   
              vr_datastr    := gene0002.fn_busca_entrada(8,vr_dslinhaarq,';');
              vr_datastr    := TRIM(vr_datastr);
              vr_datastr := replace(vr_datastr,'/','');
              vr_datastr := replace(vr_datastr,'-','');
              begin
                 vr_dtinivig  := to_date(vr_datastr,'ddmmrrrr');
              exception
                when others then
                 vr_dtinivig  := null;
              end;
                                              
              vr_produto   := gene0002.fn_busca_entrada(9,vr_dslinhaarq,';');             
              vr_premio    := gene0002.fn_busca_entrada(10,vr_dslinhaarq,';');             
              vr_capital   := gene0002.fn_busca_entrada(11,vr_dslinhaarq,';');             
              vr_refcob    := gene0002.fn_busca_entrada(12,vr_dslinhaarq,';');             
              vr_finalctr  := gene0002.fn_busca_entrada(13,vr_dslinhaarq,';');             
             
              select lpad(decode(vr_produto , 1,5,  2,7,  3,10,  4,11,  5,14, 6 ,9, 7,16
                                                     , 8,2  ,9,8 ,10, 6, 11,12, 12,13, 13,1      )   ,6,'0')
                      into vr_cdcooper  from dual ;
                      
              vr_nrpropost2 := null;
              vr_nrdconta   := null;
              vr_nrctrseg   := null;                
              vr_PROGRESS_RECID := null;                
                                
              begin
                  select   cdapolic,       idseqtra,    nrdconta,    nrctrseg  into 
                           vr_cdapolic, vr_idseqtra, vr_nrdconta, vr_nrctrseg
                   from tbseg_prestamista 
                  where nrctremp = vr_nrcontrato 
                    and cdcooper = vr_cdcooper
                    and nrproposta = vr_nrproposta;            
              exception
                  when others then
                   vr_dscritic := 'nao econtrado: ' || SQLERRM;
                   vr_nrpropost2 := null;
                   vr_nrdconta   := null;
                   vr_nrctrseg   := null;
              end;        
              
              begin
                select     PROGRESS_RECID 
                into    vr_PROGRESS_RECID from crawseg
                 where nrproposta = vr_nrproposta        
                  and cdcooper   = vr_cdcooper
                  and nrctrseg   = vr_nrctrseg
                  and nrctrato   = vr_nrcontrato
                  and nrdconta    = vr_nrdconta
                  and tpseguro    = 4;
              exception
                    when others then
                     vr_dscritic := 'nao econtrado: ' || SQLERRM;
                     vr_nrpropost2 := null;
                     vr_nrdconta   := null;
                     vr_nrctrseg   := null;
              end; 
                    
              if (vr_nrlinha > 1) THEN
                if vr_nrcontrato = vr_tabarquiv(vr_nrlinha-1).nrcontrato  then
                   IF vr_dtinivig >= to_date('01/08/2021','DD/MM/YYYY')  then                            
                      if vr_tabarquiv(vr_nrlinha-1).dtinivig < to_date('01/08/2021','DD/MM/YYYY') then 
                         vr_nrpropost2 := vr_nrproposta;
                         vr_nrproposta := vr_tabarquiv(vr_nrlinha-1).nrproposta;
                         vr_dtinivi2   := vr_dtinivig ;
                         vr_dtdeven2   := vr_dtdvenda ; 
                         vr_dtinivig   := vr_tabarquiv(vr_nrlinha-1).dtinivig;
                         vr_dtdvenda   := vr_tabarquiv(vr_nrlinha-1).dtdvenda;
                      end if;                                
                   ELSE 
                      if vr_tabarquiv(vr_nrlinha-1).dtinivig >= to_date('01/08/2021','DD/MM/YYYY') then 
                      --corrige var2 para data p/ rollbak 
                         vr_tabarquiv(vr_nrlinha-1).dtinivi2   := vr_tabarquiv(vr_nrlinha-1).dtinivig;
                         vr_tabarquiv(vr_nrlinha-1).dtdvend2   := vr_tabarquiv(vr_nrlinha-1).dtdvenda;
                         vr_tabarquiv(vr_nrlinha-1).nrpropost2 := vr_tabarquiv(vr_nrlinha-1).nrproposta;
                       --troca var2 para data p/ rollbak 
                         vr_tabarquiv(vr_nrlinha-1).dtinivig   := vr_dtinivig;
                         vr_tabarquiv(vr_nrlinha-1).dtdvenda   := vr_dtdvenda  ;
                         vr_tabarquiv(vr_nrlinha-1).nrproposta := vr_nrproposta;
                         vr_nrpropost2 := null;
                      end if;                                       
                   END IF;
                   
                end if;  
              end if;  
                             
              vr_tabarquiv(vr_nrlinha).cpf          := vr_cpf       ;
              vr_tabarquiv(vr_nrlinha).nrcontrato   := vr_nrcontrato;
              vr_tabarquiv(vr_nrlinha).apolice      := vr_apolice   ;  
              vr_tabarquiv(vr_nrlinha).nomecooper   := vr_nomecooper;
              vr_tabarquiv(vr_nrlinha).nrproposta   := vr_nrproposta;
              vr_tabarquiv(vr_nrlinha).dtinivig     := vr_dtinivig  ;
              vr_tabarquiv(vr_nrlinha).dtdvenda     := vr_dtdvenda  ;              
              vr_tabarquiv(vr_nrlinha).dtinivi2     := vr_dtinivi2  ;
              vr_tabarquiv(vr_nrlinha).dtdvend2     := vr_dtdeven2  ;              
              vr_tabarquiv(vr_nrlinha).produto      := vr_produto   ;
              vr_tabarquiv(vr_nrlinha).premio       := vr_premio    ;
              vr_tabarquiv(vr_nrlinha).capital      := vr_capital   ;            
              vr_tabarquiv(vr_nrlinha).refcob       := vr_refcob    ;             
              vr_tabarquiv(vr_nrlinha).finalctr     := vr_finalctr  ;
              vr_tabarquiv(vr_nrlinha).nrpropost2   := vr_nrpropost2;                
              vr_tabarquiv(vr_nrlinha).cdcooper     := vr_cdcooper;                
              vr_tabarquiv(vr_nrlinha).nrdconta     := vr_nrdconta;
              vr_tabarquiv(vr_nrlinha).nrctrseg     := vr_nrctrseg;
              vr_tabarquiv(vr_nrlinha).cdapolic     := vr_cdapolic;
              vr_tabarquiv(vr_nrlinha).idseqtra     := vr_idseqtra; 
              vr_tabarquiv(vr_nrlinha).PROGRESS_RECID := vr_PROGRESS_RECID;
          end loop;

      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirrec 
                              ,pr_nmarquiv => vr_nmarq                
                              ,pr_tipabert => 'W'                    
                              ,pr_utlfileh => vr_ind_arq             
                              ,pr_des_erro => vr_dscritic);          
      IF vr_dscritic IS NOT NULL THEN         
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdirrec || vr_nmarq;     
         RAISE vr_exc_saida;
      END IF;
      
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');
          
      FOR I IN vr_tabarquiv.first .. vr_tabarquiv.last LOOP                               
         vr_dscritic := '';       
         IF (vr_tabarquiv(I).nrpropost2 is not null )
           and (vr_tabarquiv(I).PROGRESS_RECID is not null) 
           and  (vr_tabarquiv(I).dtinivig < to_date('01/08/2021','DD/MM/YYYY')) then
                   
             update tbseg_prestamista 
              set nrproposta   = vr_tabarquiv(I).nrproposta 
                 , DTDEVEND    = vr_tabarquiv(I).dtdvenda
                 , DTINIVIG    = vr_tabarquiv(I).dtinivig
              where nrproposta = vr_tabarquiv(I).nrpropost2  
               and  cdcooper   = vr_tabarquiv(I).cdcooper;              
                    
              update crawseg set nrproposta =  vr_tabarquiv(I).nrproposta
                               , dtinivig   =  vr_tabarquiv(I).dtinivig 
              where PROGRESS_RECID = vr_tabarquiv(I).PROGRESS_RECID ;
              if vr_tabarquiv(I).idseqtra is not null then
                vr_linha := 
                 '  update tbseg_prestamista '||
                 ' set nrproposta = '          ||vr_tabarquiv(I).nrpropost2|| 
                 '    , DTDEVEND  = to_date('''||vr_tabarquiv(I).dtdvend2||''',''DD/MM/YYYY'')'||
                 '    , DTINIVIG  = to_date('''||vr_tabarquiv(I).dtinivi2||''',''DD/MM/YYYY'')'||
                 ' where idseqtra    = '||vr_tabarquiv(I).idseqtra||' ;'; 
                GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);  
              end if;
                     
             vr_linha := 
               '  update crawseg set nrproposta = '||vr_tabarquiv(I).nrpropost2||
               '                     , dtinivig = to_date('''||vr_tabarquiv(I).dtinivi2||''',''DD/MM/YYYY'')'||
               ' where PROGRESS_RECID = '||vr_tabarquiv(I).PROGRESS_RECID ||';  ';
             GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                 
         END IF;   
      END LOOP;

      commit;
      
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');                 
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' EXCEPTION ');                    
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'  WHEN OTHERS THEN ');                 
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'   ROLLBACK;');                    
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');                 
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');                                     
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    
       
    EXCEPTION 
    WHEN vr_exc_saida THEN
      ROLLBACK;
    WHEN OTHERS THEN
      vr_dscritic := 'Erro Geral: ' || SQLERRM;
      ROLLBACK;
    END;    
    if vr_dscritic is not null then
       DBMS_OUTPUT.PUT_line(vr_dscritic);
    end if;  
end;
/
