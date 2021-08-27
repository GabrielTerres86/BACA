-- BACAS IMOBILIARIO MVP (PRJ0023311)

-- Dominios de campos para retorno do motor
BEGIN
	DELETE 
	  FROM tbgen_dominio_campo
	 WHERE NMDOMINIO = 'STATUSCONTRATOIMOBILIARIO';
	 
	 COMMIT;
 
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
