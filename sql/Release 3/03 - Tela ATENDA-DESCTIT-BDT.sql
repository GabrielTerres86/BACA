 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->TÍTULOS->BORDERÔS
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- remove qualquer "lixo" de BD que possa ter  
delete from crapaca where nrseqrdr = (select nrseqrdr from craprdr where nmprogra = 'DSCT0003') ;
delete from craprdr where nmprogra = 'DSCT0003';

-- Insere os registros de acesso a inteface web via mensageria
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'DSCT0003', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'DSCT0003_BUSCAR_ASSOCIADO', 'DSCT0003', 'pc_buscar_associado_web', 'pr_nrdconta,pr_nrcpfcgc', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'DSCT0003'));

commit;
end;