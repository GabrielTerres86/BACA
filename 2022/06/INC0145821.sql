declare 

  CURSOR cr_contas IS
    select *
    from cecred.tbcadast_pessoa_historico
    where tpoperacao = 3
    and idcampo = 91
    and dsvalor_anterior = '89036640-'
    and  dhalteracao  between to_date('30/05/2022 14:30:00','DD/MM/YYYY HH24:MI:SS' )
                          and to_date('30/05/2022 14:35:00','DD/MM/YYYY HH24:MI:SS' );
      
    rw_contas cr_contas%ROWTYPE;
    
    
  CURSOR cr_dados(p_idpessoa number, p_dhalteracao date) IS
    select *
    from cecred.tbcadast_pessoa_historico
    where idpessoa = p_idpessoa
    and  dhalteracao =  p_dhalteracao
    and tpoperacao = 3;
      
    rw_dados cr_dados%ROWTYPE;  
    
    vr_endereco tbcadast_pessoa_endereco%rowtype;   
    
    vr_nrseq_endereco integer;
  
BEGIN
  
  
  FOR rw_contas IN cr_contas LOOP
    
     FOR rw_dados IN cr_dados(rw_contas.idpessoa, rw_contas.dhalteracao ) LOOP
       
       vr_endereco.idpessoa := rw_contas.idpessoa;
       if rw_dados.idcampo = 84 then
          vr_endereco.NRSEQ_ENDERECO := rw_dados.dsvalor_anterior;
         elsif rw_dados.idcampo = 85 then
          vr_endereco.TPENDERECO := 10;  
         elsif rw_dados.idcampo = 86 then
          vr_endereco.NMLOGRADOURO := rw_dados.dsvalor_anterior;           
         elsif rw_dados.idcampo = 87 then
          vr_endereco.nrlogradouro := rw_dados.dsvalor_anterior;           
         elsif rw_dados.idcampo = 88 then
          vr_endereco.dscomplemento := rw_dados.dsvalor_anterior; 
         elsif rw_dados.idcampo = 89 then
          vr_endereco.nmbairro := rw_dados.dsvalor_anterior; 
         elsif rw_dados.idcampo = 90 then
          vr_endereco.idcidade := 14461; 
         elsif rw_dados.idcampo = 91 then
          vr_endereco.nrcep := 89036640; 
         elsif rw_dados.idcampo = 92 then
          vr_endereco.tpimovel := substr(rw_dados.dsvalor_anterior,0,instr(rw_dados.dsvalor_anterior,'-')-1);   
         elsif rw_dados.idcampo = 93 then
          vr_endereco.Vldeclarado := gene0002.fn_char_para_number(rw_dados.dsvalor_anterior); 
         elsif rw_dados.idcampo = 95 then
          vr_endereco.Dtinicio_Residencia := TO_DATE( rw_dados.dsvalor_anterior, 'DD/MM/YYYY');                            
         elsif rw_dados.idcampo = 96 then
          vr_endereco.TPORIGEM_CADASTRO := substr(rw_dados.dsvalor_anterior,0,instr(rw_dados.dsvalor_anterior,'-')-1);  
         elsif rw_dados.idcampo = 97 then
          vr_endereco.CDOPERAD_ALTERA := rw_dados.dsvalor_anterior;  
      end if;        

     end loop;
     
        begin
          
          select nrseq_endereco
            into vr_nrseq_endereco
            from cecred.tbcadast_pessoa_endereco
           where idpessoa =  rw_contas.idpessoa
             and nrseq_endereco = vr_endereco.NRSEQ_ENDERECO;
             
           select max(nrseq_endereco ) + 1
            into vr_nrseq_endereco
            from cecred.tbcadast_pessoa_endereco
           where idpessoa =  rw_contas.idpessoa;
           
         vr_endereco.NRSEQ_ENDERECO := vr_nrseq_endereco;
         
        exception
           when no_data_found then
              null;
        end;
        
     
        INSERT INTO cecred.TBCADAST_PESSOA_ENDERECO  VALUES   vr_endereco ; 
        

     
  END LOOP;
  
  commit; 
          
  EXCEPTION 
     WHEN others then
       ROLLBACK; 
       raise_application_error( -20000,'erro:' || sqlerrm );	   
  
                           
end;

