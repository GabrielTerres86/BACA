DECLARE
  
  vr_nrseqrdr   craprdr.nrseqrdr%TYPE;
  
BEGIN
  BEGIN
    SELECT t.nrseqrdr
      INTO vr_nrseqrdr
      FROM craprdr t
     WHERE t.nmprogra = 'MATRIC';
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        INSERT INTO craprdr(nrseqrdr
                           ,nmprogra
                           ,dtsolici)
                     VALUES(craprdr_nrseqrdr.nextval
                           ,'MATRIC'
                           ,SYSDATE)
                 RETURNING nrseqrdr 
                      INTO vr_nrseqrdr;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20005, 'Erro ao inserir CRAPRDR: '||SQLERRM);
      END;
    WHEN OTHERS THEN
      raise_application_error(-20004, 'Erro ao buscar CRAPRDR: '||SQLERRM);
  END;
  
  BEGIN
    INSERT INTO crapaca(nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ((SELECT NVL(MAX(a.nrseqaca),0)+1 FROM crapaca a)
                       ,'BUSCA_CONTA_PESSOA'
                       ,NULL
                       ,'buscarListaContasPessoa'
                       ,'pr_nrcpfcgc'
                       ,vr_nrseqrdr);
                
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro BUSCA_CONTA_PESSOA, j� cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20006, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
    
  BEGIN
    INSERT INTO crapaca(nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ((SELECT NVL(MAX(a.nrseqaca),0)+1 FROM crapaca a)
                       ,'DUPLICAR_CONTA_NOVA'
                       ,NULL
                       ,'duplicarContaCooperado'
                       ,'pr_nrdconta_org'
                       ,vr_nrseqrdr);
                
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro DUPLICAR_CONTA_NOVA, j� cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20007, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
    
  COMMIT;
 
END;
