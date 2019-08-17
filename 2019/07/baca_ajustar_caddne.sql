DECLARE
  -- Local variables here
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;  
  erro EXCEPTION;
BEGIN
  
    DELETE FROM crapaca aca 
     WHERE aca.nmdeacao = 'CARGA_CEP'
       AND aca.nmpackag = 'TELA_CADDNE'
       AND aca.nmproced = 'pc_executa_carga';                             
       
    DELETE FROM crapaca aca 
     WHERE aca.nmdeacao = 'BUSCA_PARAM'
       AND aca.nmpackag = 'TELA_CADDNE'
       AND aca.nmproced = 'PC_BUSCA_PARAM';               
       
    DELETE FROM crapaca aca 
     WHERE aca.nmdeacao = 'EXECUTA_CARGA'
       AND aca.nmpackag = 'TELA_CADDNE'
       AND aca.nmproced = 'PC_EXECUTA_CARGA';                         
  
  BEGIN
    DELETE craprdr rdr WHERE rdr.nmprogra = 'CRAPDNE';    
    DELETE craprdr rdr WHERE rdr.nmprogra = 'TELA_CADDNE';     
    INSERT INTO CRAPRDR VALUES (NULL,'TELA_CADDNE',SYSDATE) returning nrseqrdr into vr_nrseqrdr;
  exception
    when OTHERS then
      dbms_output.put_line('Erro CRAPRDR. Erro = '||sqlerrm);
      raise erro;
  end;
  
  BEGIN
    SELECT nrseqrdr 
      INTO vr_nrseqrdr
      FROM craprdr rdr 
     WHERE rdr.nmprogra = 'TELA_CADDNE';
  exception
    when OTHERS then
      dbms_output.put_line('Erro CRAPRDR. Erro = '||sqlerrm);
      raise erro;
  end;
  
  BEGIN
  
    dbms_output.put_line('nrseqrdr='||vr_nrseqrdr);    
        
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('EXECUTA_CARGA', 'TELA_CADDNE', 'PC_EXECUTA_CARGA', 'pr_proc_arq_unid_oper,pr_proc_arq_grande_usuario,pr_proc_arq_cpc,pr_proc_arq_sigla_estado', vr_nrseqrdr);
    
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('BUSCA_PARAM', 'TELA_CADDNE', 'PC_BUSCA_PARAM', null, vr_nrseqrdr);    
    
  exception
    when OTHERS then
      dbms_output.put_line('Erro CRAPACA. Erro = '||sqlerrm);
      raise erro;
  end;
  
  commit;
exception
  when ERRO then
    null;
end;
