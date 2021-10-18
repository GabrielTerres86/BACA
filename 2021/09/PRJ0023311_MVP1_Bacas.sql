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

    UPDATE crapaca a
       SET a.lstparam = a.lstparam||',pr_imobiliario'
     WHERE nmpackag = 'TELA_RATMOV'
       AND nmproced = 'PC_CONSULTAR_RATING';

    COMMIT;
exception 
  when others then 
    RAISE_application_error(-20500,SQLERRM);
  ROLLBACK;
end;
/

-- Dominios de campos para retorno do motor na API
BEGIN
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','00','EM PROCESSAMENTO');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','10','EM PROCESSAMENTO');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','20','EM ANALISE MANUAL');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','31','APROVADA');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','32','REJEITADA');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','33','RESTRICAO');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','34','REFAZER'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','35','DERIVAR'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','36','ERRO'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','50','EXPIRADA'); 
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','51','EXPIRADA');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','60','ANULADA');    
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','61','ANULADA');   
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','64','ANULADA');    

    COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  RAISE_application_error(-20500,SQLERRM);
  ROLLBACK;
END;
/
-- Dominios para tela prestacoes/imobiliario
BEGIN
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','1','Construcao Isolada');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','2','Condominio');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','3','Empresario');     
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','4','Cooperativa');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','5','Revenda');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','6','Adquirido');     
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','7','Aquisicao Isolada');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','8','Adquirido BNH RD 61/71');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','9','Construcao Conjunto Habitacional');   
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','10','Reforma ou Ampliacao');
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','11','Material de Construcao'); 
    
    COMMIT;

EXCEPTION
 WHEN OTHERS THEN
  RAISE_application_error(-20500,SQLERRM);
  ROLLBACK;
END;
