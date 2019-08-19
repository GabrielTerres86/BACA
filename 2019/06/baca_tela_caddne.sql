declare
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  erro exception;
BEGIN
  
  BEGIN
    DELETE craprdr rdr WHERE rdr.nmprogra = 'CRAPDNE';
    
    INSERT INTO CRAPRDR VALUES (NULL,'CRAPDNE',SYSDATE) returning nrseqrdr into vr_nrseqrdr;
  exception
    when OTHERS then
      dbms_output.put_line('Erro CRAPRDR. Erro = '||sqlerrm);
      raise erro;
  end;
  
  BEGIN
  
    dbms_output.put_line('nrseqrdr='||vr_nrseqrdr);    
    
    DELETE FROM crapaca aca 
     WHERE aca.nmdeacao = 'CARGA_CEP'
       AND aca.nmpackag = 'TELA_CADDNE'
       AND aca.nmproced = 'pc_executa_carga';
       
    INSERT INTO CRAPACA VALUES (NULL,'CARGA_CEP','TELA_CADDNE','pc_executa_carga',
      'pr_proc_arq_unid_oper, pr_proc_arq_grande_usuario, pr_proc_arq_cpc, pr_proc_arq_sigla_estado, pr_cdoperad',
      vr_nrseqrdr);
      
  exception
    when OTHERS then
      dbms_output.put_line('Erro CRAPACA. Erro = '||sqlerrm);
      raise erro;
  end;

  BEGIN  
    DELETE FROM crapprm prm
     WHERE prm.nmsistem = 'CRED'
       AND prm.cdcooper = 0
       AND prm.cdacesso = 'CARGA_CEP';
       
    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'CARGA_CEP', 'Horário para agendamento do Job de atualização da base de CEP (CRAPDNE)', '01:00');
  exception
    when OTHERS then
      dbms_output.put_line('Erro CRAPPRM. Erro = '||sqlerrm);
      raise erro;
  end;
  
  commit;
exception
  when ERRO then
    null;
end;

