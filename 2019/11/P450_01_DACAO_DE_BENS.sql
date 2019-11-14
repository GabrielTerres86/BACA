--CRIA��O DE DOM�NIO
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',1, 'IM�VEL');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',2, 'VE�CULO');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',3, 'M�QUINA E EQUIPAMENTO');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',4, 'OUTROS - BENS E DIREITOS');
--Categoria Da��o Bens - IM�VEL
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0101, 'Urbano Residencial');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0102, 'Urbano Comercial');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0103, 'Urbano Rural');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0104, 'Outros Im�veis');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0105, 'Planta Industrial');
--Categoria Da��o Bens - VE�CULO
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0201, 'Autom�vel');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0202, 'Caminhonete');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0203, 'Motocicleta');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0204, 'Caminh�o');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0205, 'Outros Terrestres');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0206, 'Embarca��es');
--Categoria Da��o Bens - M�QUINAS E EQUIPAMENTOS
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0301, 'Maquin�rio comercial/fabril');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0302, 'Agr�cola');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0303, 'Produto Agr�cola');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0304, 'Produto Fabril');
--Categoria Da��o Bens - OUTROS - BENS E DIREITOS
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0401, 'Diretos de Uso');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0402, 'Outros Bens e Direitos');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0403, 'Instrumentos Financeiros');
--
COMMIT;
--
--CRIA��O DE MENSAGEIRIA - GRAVAR_DACAO_BENS
DELETE FROM CRAPACA
 WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_PRESTACOES')
   AND NMDEACAO = 'GRAVAR_DACAO_BENS';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'GRAVAR_DACAO_BENS',
   'TELA_ATENDA_PRESTACOES',
   'pc_gravar_dacao_bens',
   'pr_cdcooper, pr_nrdconta, pr_ncrtremp,
 pr_tpctrpro,
 pr_tpbens_dacao,
 pr_nrmatricula,
 pr_nrregistro_imovel,
 pr_cdnacional_serventia,
 pr_dsmarbem,
 pr_dsmodbem,
 pr_nranobem,
 pr_nrmodbem,
 pr_dschassi,
 pr_ufdplaca,
 pr_dsdplaca,
 pr_nrrenava,
 pr_uflicenc,
 pr_dsrelbem,
 pr_nrnotanf,
 pr_vlrdobem,
 pr_tpcatbem',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_PRESTACOES'));
COMMIT;

