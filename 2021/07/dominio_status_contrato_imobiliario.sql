BEGIN
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','31','APROVADA');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','32','REJEITADA');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','00','EMPROCESSAMENTO');     
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','01','EMPROCESSAMENTO');   
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','02','ANALISEMANUAL');                               
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','60','ERRO');    
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','61','ERRO'); 
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','62','ERRO'); 
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','63','ERRO'); 
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','64','ERRO'); 
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','33','ERRO');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','34','ERRO');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('STATUSCONTRATOIMOBILIARIO','53','DERIVAR'); 
COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
END;