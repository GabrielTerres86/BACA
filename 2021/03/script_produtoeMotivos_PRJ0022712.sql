--criar produto e motivos para Limite credito pre-aprovado
DECLARE 
  vr_max_prod NUMBER(5);
  
   CURSOR cr_motivos IS
    SELECT *
      FROM tbgen_motivo a
     WHERE a.cdproduto = 25
   ORDER BY a.idmotivo ;

  vr_idmotivo NUMBER(5);
  vr_cdproduto NUMBER(5);
  
BEGIN 
    SELECT MAX(cdproduto)+1 INTO vr_max_prod FROM tbcc_produto;

	
      INSERT INTO tbcc_produto
      SELECT vr_max_prod    cdproduto,
             'LIMITE CREDITO PRE-APROVADO' dsproduto,
             a.flgitem_soa,
             a.flgutiliza_interface_padrao,
             a.flgenvia_sms,
             a.flgcobra_tarifa,
             a.idfaixa_valor,
             a.flgproduto_api
      FROM tbcc_produto a
      WHERE a.cdproduto = 25;
      
      INSERT INTO tbcc_operacoes_produto (CDPRODUTO, CDOPERAC_PRODUTO, DSOPERAC_PRODUTO, TPCONTROLE)
      VALUES  (vr_max_prod, 1, 'Limite Credito Pre-Aprovado Liberado', '2');
      
    --- parte cadastramento dos motivos    
    SELECT MAX(idmotivo)
      INTO vr_idmotivo
      FROM tbgen_motivo;
      
    SELECT a.cdproduto
      INTO vr_cdproduto
      FROM tbcc_produto a
     WHERE a.dsproduto = 'LIMITE CREDITO PRE-APROVADO';
     
    FOR rw_motivo IN cr_motivos LOOP
    
      vr_idmotivo := vr_idmotivo + 1;
      INSERT INTO tbgen_motivo
        (idmotivo
        ,dsmotivo
        ,cdproduto
        ,flgreserva_sistema
        ,flgativo
        ,flgexibe
        ,flgtipo)
      VALUES
        (vr_idmotivo
        ,rw_motivo.dsmotivo
        ,vr_cdproduto -- limite credito pre-aprovado
        ,rw_motivo.flgreserva_sistema
        ,rw_motivo.flgativo
        ,rw_motivo.flgexibe
        ,rw_motivo.flgtipo);
    
    END LOOP;

    COMMIT;      
      
      
EXCEPTION
   WHEN OTHERS THEN
     dbms_output.put_line('Erro ao processar: '||SQLERRM);      
END;

