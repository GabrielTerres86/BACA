-- Squad Risco - Pagamento com Aval na CT

-- ACA usada e revisada apenas em dep_vista\busca_contrato.php e dep_vista\pagamento_por_aval.php
UPDATE crapaca
   SET lstparam = 'pr_cdcooper,pr_nrdconta,pr_incpreju,pr_inbordero'
 WHERE UPPER(nmproced) = 'PC_CONSULTA_CONTRATOS_ATIVOS'
   AND UPPER(nmdeacao) = 'BUSCA_CONTRATOS_ATIV_PRJ';

-- ACA usada e revisada apenas em dep_vista\paga_emprestimo.php
UPDATE crapaca
   SET lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_vlrabono,pr_vlrpagto,pr_nrseqava'
 WHERE UPPER(nmproced) = 'PC_PAGA_EMPRESTIMO_CT'
   AND UPPER(nmdeacao) = 'PAGA_EMPRESTIMO_CT';

-- ACA usada e revisada em:
-- atenda\descontos\manter_rotina.php
-- atenda\limite_credito\acionamentos.php
UPDATE crapaca
   SET lstparam = 'pr_nrdconta,pr_nrborder,pr_vlaboprj,pr_vlpagmto,pr_flpgtava'
 WHERE UPPER(nmproced) = 'PC_PAGAR_PREJUIZO_WEB'
   AND UPPER(nmdeacao) = 'PAGAR_PREJUIZO';

-- NRSEQRDR já existente na craprdr
INSERT INTO crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
     VALUES ('PESQUISARAVALISTASOPERACOES','PREJ0006','pesquisaravalopeprejuweb', 'pr_nrdconta,pr_nrctremp,pr_tpprodut', 2005);

-- NRSEQRDR já existente na craprdr
INSERT INTO crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
     VALUES ('CONSULTA_SIT_DESCT_TIT', 'TELA_ATENDA_DEPOSVIS', 'pc_consulta_sit_empr', 'pr_cdcooper, pr_nrdconta, pr_nrctrlim', 1166);

COMMIT;