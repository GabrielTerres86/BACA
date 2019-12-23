--Baca para adicionar Data de corte ao novo termo de adesao Cartao 
DECLARE
  
  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
     
BEGIN
  
  --Limpa registros
  DELETE FROM TBGEN_VERSAO_TERMO tvt WHERE tvt.dsnome_jasper = 'termo_abertura_conta_ente_publico.jasper' OR tvt.dsnome_jasper = 'termo_abertura_conta_ente_publico.jasper';

  -- Percorrer as cooperativas do cursor
  FOR rw_crapcop IN cr_crapcop LOOP
    
    BEGIN
      
      INSERT INTO TBGEN_VERSAO_TERMO (CDCOOPER, DSCHAVE_VERSAO, DTINICIO_VIGENCIA, DTFIM_VIGENCIA, DSNOME_JASPER, DTCADASTRO, DSDESCRICAO)
      VALUES (rw_crapcop.cdcooper, 'TERMO ABERTURA CONTA CORRENTE ENTE PUBLIO V1', to_date('12-12-2019', 'dd-mm-yyyy'), null, 'termo_abertura_conta_ente_publico.jasper', to_date('12-12-2019', 'dd-mm-yyyy'), 'Termo /Contrato de abertura de conta corrente para entes públicos');

      
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Item ja cadastrado: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir TBGEN_VERSAO_TERMO: '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Registos criados com sucesso!');
  
END;
