-- BACAS IMOBILIARIO MVP (PRJ0023311)
-- PRIMEIRA ENTREGA

-- CRAPACA TELA PRESTACOES IMOBILIARIO
begin
    INSERT INTO crapaca
      (NMDEACAO
      ,NMPROCED
      ,LSTPARAM
      ,NRSEQRDR)
    VALUES
      ('BUSCA_EMP_IMOB_CAPA'
      ,'CREDITO.pc_busca_imob_capa'
      ,'pr_cdcooper, pr_nrdconta'
      ,71);

    INSERT INTO crapaca
      (NMDEACAO
      ,NMPROCED
      ,LSTPARAM
      ,NRSEQRDR)
    VALUES
      ('BUSCA_EMPRESTIMOS_IMOB'
      ,'CREDITO.pc_consulta_emprestimo_imobiliario'
      ,'pr_cdcooper, pr_nrdconta, pr_nrctremp'
      ,71);
      
    INSERT INTO crapaca
      (NMDEACAO
      ,NMPROCED
      ,LSTPARAM
      ,NRSEQRDR)
    VALUES
      ('BUSCA_LOG_CONTRATO_IMOB'
      ,'CREDITO.pc_busca_log_contrato_imob'
      ,'pr_cdcooper, pr_nrdconta ,pr_nrctremp, pr_nriniseq, pr_nrregist'
      ,71);  

    COMMIT;
exception when others then 
	ROLLBACK;
end;
/
-- Dominios de campos para retorno do motor
BEGIN
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','00','EM PROCESSAMENTO');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','10','EM PROCESSAMENTO');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','20','EM ANALISE MANUAL');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','31','APROVADA');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','32','REJEITADA');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','33','RESTRICAO');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','34','REFAZER'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','35','DERIVAR');    
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','60','ERRO');    
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','61','ERRO'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','62','ERRO'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','63','ERRO'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','64','ERRO'); 

    COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
END;
