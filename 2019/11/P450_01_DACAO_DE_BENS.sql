--CRIAÇÃO DE DOMÍNIO
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',1, 'IMÓVEL');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',2, 'VEÍCULO');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',3, 'MÁQUINA E EQUIPAMENTO');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',4, 'OUTROS - BENS E DIREITOS');
--Categoria Dação Bens - IMÓVEL
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0101, 'Urbano Residencial');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0102, 'Urbano Comercial');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0103, 'Urbano Rural');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0104, 'Outros Imóveis');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0105, 'Planta Industrial');
--Categoria Dação Bens - VEÍCULO
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0201, 'Automóvel');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0202, 'Caminhonete');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0203, 'Motocicleta');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0204, 'Caminhão');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0205, 'Outros Terrestres');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0206, 'Embarcações');
--Categoria Dação Bens - MÁQUINAS E EQUIPAMENTOS
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0301, 'Maquinário comercial/fabril');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0302, 'Agrícola');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0303, 'Produto Agrícola');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0304, 'Produto Fabril');
--Categoria Dação Bens - OUTROS - BENS E DIREITOS
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0401, 'Diretos de Uso');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0402, 'Outros Bens e Direitos');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0403, 'Instrumentos Financeiros');
--
COMMIT;
--
--CRIAÇÃO DE MENSAGEIRIA - GRAVAR_DACAO_BENS
DELETE FROM CRAPACA
 WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_PRESTACOES')
   AND NMDEACAO = 'GRAVAR_DACAO_BENS';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'GRAVAR_DACAO_BENS',
   'TELA_ATENDA_PRESTACOES',
   'pc_gravar_dacao_bens_web',
   'pr_nrdconta, pr_nrctremp, pr_tpctrpro',  
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_PRESTACOES'));
COMMIT;
--
--CRIAÇÃO DE MENSAGEIRIA - VALIDAR_DACAO_BENS
DELETE FROM CRAPACA
 WHERE NRSEQRDR = (SELECT NRSEQRDR FROM CRAPRDR WHERE NMPROGRA = 'TELA_ATENDA_PRESTACOES')
   AND NMDEACAO = 'VALIDAR_DACAO_BENS';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'VALIDAR_DACAO_BENS',
   'TELA_ATENDA_PRESTACOES',
   'pc_validar_dacao_bens_web',
   'pr_nrdconta, pr_nrctremp, pr_tpctrpro', 
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_PRESTACOES'));
COMMIT;
--PERMISSÕES DE ACESSO A OPÇÃO R 'RECEBIMENTO DE BENS'
UPDATE CRAPTEL
   SET CDOPPTEL = CDOPPTEL || ',R', 
       LSOPPTEL = LSOPPTEL || ',RECEBIMENTO BENS'
 WHERE UPPER(NMDATELA) LIKE UPPER('%ATENDA%')
   AND UPPER(NMROTINA) LIKE UPPER('PRESTACOES')
   AND (CDOPPTEL NOT LIKE '%R%');
COMMIT;
--