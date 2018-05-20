 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->TÍTULOS->BORDERÔS
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- remove qualquer "lixo" de BD que possa ter  
DELETE FROM crapaca WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'DSCT0003') ;
DELETE FROM craprdr WHERE nmprogra = 'DSCT0003';

DELETE FROM crapace acn 
      WHERE acn.cddopcao IN ('P','I','R','A')
        AND acn.nmrotina = 'DSC TITS - BORDERO'
        AND acn.nmdatela = 'ATENDA'
        AND acn.idambace = 2;

-- Atualiza as permissões das telas de borderô
UPDATE craptel 
   SET cdopptel = '@,N,C,M,L,P,I,R,A,E',
       lsopptel = 'ACESSO,ANALISE,CONSULTA,IMPRESSAO,LIBERACAO,PAGAR,INCLUIR,REJEITAR,ALTERAR,EXCLUIR',
       idambtel = 2 -- Ayllos Web
 WHERE nmrotina = 'DSC TITS - BORDERO'
   AND nmdatela = 'ATENDA'
   AND cdcooper IN (SELECT cdcooper FROM crapcop cop WHERE cop.flgativo = 1);

-- Fornece as permissões de acesso dos botões novos para os usuários que já possuem permissão na tela de borderôs
INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT acn.nmdatela, 
           'P', -- Pagar
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT acn.nmdatela, 
           'I', -- Incluir
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT acn.nmdatela, 
           'R', -- Rejeitar
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT acn.nmdatela, 
           'A', -- Alterar
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

-- parâmetro que indica a virada de versão das funcionalidades do borderô
INSERT INTO crapprm (SELECT 'CRED',cdcooper,'FL_VIRADA_BORDERO','Guarda se uma cooperativa está trabalhando com os borderos novos ou velhos','0',NULL FROM crapcop where flgativo = 1);


-- Insere os registros de acesso a inteface web via mensageria
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'DSCT0003', SYSDATE);



INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'DSCT0003_BUSCAR_ASSOCIADO', 'DSCT0003', 'pc_buscar_associado_web', 'pr_nrdconta,pr_nrcpfcgc', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'DSCT0003'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'VIRADA_BORDERO', 'DSCT0003', 'pc_virada_bordero', '', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'REJEITAR_BORDERO_TITULO', 'DSCT0003', 'pc_rejeitar_bordero_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCA_BORDEROS', 'TELA_ATENDA_DSCTO_TIT', 'pc_busca_borderos_web', 'pr_nrdconta,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'ALTERAR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_altera_bordero', 'pr_tpctrlim,pr_insitlim,pr_nrdconta,pr_chave,pr_dtmvtolt,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LIBERAR_BORDERO', 'DSCT0003', 'pc_liberar_bordero_web', 'pr_nrdconta,pr_nrborder,pr_confirma', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'RESGATAR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_resgate_titulo_bordero_web', 'pr_nrctrlim,pr_nrdconta,pr_dtmvtolt,pr_dtmvtoan,pr_dtresgat,pr_inproces,pr_nrnosnum', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TITULOS_RESGATE', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_titulos_resgate_web', 'pr_nrdconta,pr_dtmvtolt,pr_nrinssac,pr_vltitulo,pr_dtvencto,pr_nrnosnum,pr_nrctrlim,pr_nrborder,pr_insitlim,pr_tpctrlim', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_DADOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_dados_bordero_web', 'pr_nrdconta,pr_nrborder,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'EFETUA_ANALISE_BORDERO', 'DSCT0003', 'pc_efetua_analise_bordero_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'INSERIR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_insere_bordero_web', 'pr_tpctrlim,pr_insitlim,pr_nrdconta,pr_chave,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_DETALHE_TITULO', 'TELA_ATENDA_DSCTO_TIT', 'pc_detalhes_tit_bordero_web', 'pr_nrdconta,pr_nrnosnum', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'SOLICITA_BIRO_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_solicita_biro_bordero', 'pr_nrdconta,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'VALIDAR_TITULOS_ALTERACAO', 'TELA_ATENDA_DSCTO_TIT', 'pc_validar_titulos_alteracao', 'pr_nrdconta,pr_nrnosnum,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TIT_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_tit_bordero_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

-- verificar script abaixo
INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_titulos_bordero_web', 'pr_nrdconta,pr_dtmvtolt,pr_nrinssac,pr_vltitulo,pr_dtvencto,pr_nrnosnum,pr_nrctrlim,pr_insitlim,pr_tpctrlim,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_TITULOS_RESUMO', 'TELA_ATENDA_DSCTO_TIT', 'pc_listar_titulos_resumo_web', 'pr_nrdconta,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_TITULOS_RESUMO_RESGATAR', 'TELA_ATENDA_DSCTO_TIT', 'pc_titulos_resumo_resgatar_web', 'pr_nrdconta,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));


commit;
end;