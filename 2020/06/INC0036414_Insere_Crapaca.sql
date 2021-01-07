DECLARE
  
  vr_nrseqrdr   craprdr.nrseqrdr%TYPE;
  
BEGIN
  BEGIN
    SELECT t.nrseqrdr
      INTO vr_nrseqrdr
      FROM craprdr t
     WHERE t.nmprogra = 'TELA_TIPCTA';
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        INSERT INTO craprdr(nmprogra
                           ,dtsolici)
                     VALUES('TELA_TIPCTA'
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
    INSERT INTO crapaca(nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ('BUSCAR_PROCESSOS'
                       ,'TELA_TIPCTA'
                       ,'pc_lista_proc_altera_tipcta'
                       ,'pr_cdcooper,pr_dtproces,pr_idsituac'
                       ,vr_nrseqrdr);
                
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro BUSCAR_PROCESSOS, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20005, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
  
  BEGIN
    INSERT INTO crapaca(nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ('LISTAR_DETALHES_PROCESSOS'
                       ,'TELA_TIPCTA'
                       ,'pc_lista_detalhes_proc'
                       ,'pr_idprglog,pr_nrregist,pr_nriniseq'
                       ,vr_nrseqrdr);
                
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro LISTAR_DETALHES_PROCESSOS, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20006, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
  
  BEGIN
    INSERT INTO crapaca(nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ('EXPORTAR_DETALHES_PROCESSOS'
                       ,'TELA_TIPCTA'
                       ,'pc_exporta_detalhes_proc'
                       ,'pr_idprglog'
                       ,vr_nrseqrdr);
                
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro EXPORTAR_DETALHES_PROCESSOS, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20007, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
  COMMIT;
 
END;
