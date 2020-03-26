-- Atualiza o legado dos limites com risco inclusão igual a "A" (2)
UPDATE tbrisco_operacoes
   SET inrisco_inclusao = 2
 WHERE inrisco_inclusao IS NULL
   AND tpctrato IN (1, 2, 3);

-- Atualiza mensageiria para receber mais um parâmetro na CRAPACA
UPDATE crapaca a
   SET a.lstparam = 'pr_nrcpfcgc,pr_nrdconta,pr_nrctro,pr_status,pr_datafim,pr_dataini,pr_crapbdc,pr_crapbdt,pr_craplim,pr_crawepr,pr_crapcpa,pr_contrliq,pr_tbrisco_oper_cc'
 WHERE UPPER(a.nmpackag) = UPPER('TELA_RATMOV')
   AND UPPER(a.nmproced) = UPPER('PC_IMP_HISTORICO_WEB');

--P450 - inserir parametro na TELA_RATMOV NA AÇÃO CONSULTARRAT
UPDATE crapaca T
   SET T.LSTPARAM = T.LSTPARAM || ',pr_tbrisco_oper_cc'
 WHERE T.NRSEQRDR = (SELECT R.NRSEQRDR FROM CRAPRDR R WHERE R.NMPROGRA = 'TELA_RATMOV') 
   AND T.NMDEACAO IN('CONSULTARRAT')
   AND T.LSTPARAM NOT LIKE '%pr_tbrisco_oper_cc%';

-- tbgen_dominio_campo - Conta Corrente  
insert into tbgen_dominio_campo
  (nmdominio, cddominio, dscodigo)
values
  ('TPCTRATO', 11, 'Conta Corrente');

--tbrat_param_geral
insert into tbrat_param_geral
  (cdcooper,
   inpessoa,
   tpproduto,
   qtdias_niveis_reducao,
   idnivel_risco_permite_reducao,
   qtdias_atencede_atualizacao,
   qtdias_reaproveitamento,
   qtmeses_expiracao_nota,
   qtdias_atualizacao_autom_baixo,
   qtdias_atualizacao_autom_medio,
   qtdias_atualizacao_autom_alto,
   qtdias_atualizacao_manual,
   inbiro_ibratan,
   incontingencia,
   inpermite_alterar,
   tpmodelo_rating,
   qtdias_atualiz_autom_altissimo)
  (select t.cdcooper,
         t.inpessoa,
         11, --conta-corrente
         t.qtdias_niveis_reducao,
         t.idnivel_risco_permite_reducao,
         t.qtdias_atencede_atualizacao,
         t.qtdias_reaproveitamento,
         t.qtmeses_expiracao_nota,
         t.qtdias_atualizacao_autom_baixo,
         t.qtdias_atualizacao_autom_medio,
         t.qtdias_atualizacao_autom_alto,
         t.qtdias_atualizacao_manual,
         t.inbiro_ibratan,
         t.incontingencia,
         t.inpermite_alterar,
         t.tpmodelo_rating,
         t.qtdias_atualiz_autom_altissimo
    from tbrat_param_geral t
   WHERE t.tpproduto = 1 );

-- Efetuar commit
COMMIT;
