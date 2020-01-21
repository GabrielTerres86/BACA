--p450 - Estoria 26431- Excluir Job, pois será substituido por 2 novos 
dbms_scheduler.drop_job(job_name => 'CECRED.JBATUALIZARATING');
commit;

-- Dominios
insert into tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('INNIVEL_RATING',1,'Baixo');
insert into tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('INNIVEL_RATING',2,'Medio');
insert into tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('INNIVEL_RATING',3,'Alto');
insert into tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('INNIVEL_RATING',4,'Altissimo');
insert into tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('INORIGEM_RATING',6,'MANUAL');
commit;

/* 27456:Alteração 3040 - Microcredito modalidade 0403 */
insert into crapprm values ('CRED',0,'3040_MICROCREDITO','Ativa Demanda Regulatoria Microcredito 3040 - modalidades 0212 e 0403 (S/N)','S',NULL);
commit;

--p450 - estoria 26475
update crapaca a set a.lstparam = a.lstparam || ' ,pr_qtdias_atual_autom_altissi'
 where a.nmpackag = 'TELA_PARRAT'
   and a.nmproced = 'PC_ALTERAR'
   and a.lstparam NOT LIKE '%,pr_qtdias_atual_autom_altissi%';
commit;

-- padroniza a lista de parâmetros sem espaçamentos
update crapaca a set a.lstparam = REPLACE(a.lstparam, ' ')
 where a.nmpackag = 'TELA_PARRAT'
   and a.nmproced = 'PC_ALTERAR';
commit;

--P450 -  estoria 26475 - dados iniciais no novo campo da parrat
update tbrat_param_geral set qtdias_atualiz_autom_altissimo = 180; -- dias
commit;

-- P450 - CDC em Contingencia CDC sem integrasas = 0
update tbrisco_operacoes set flintegrar_sas = 1 where inorigem_rating = 7 and flintegrar_sas = 0;
commit;

-- P450 - WEBSERVICE
update crapaca set lstparam = lstparam || ',pr_scorerat,pr_segmento'
 where nmproced = 'pc_retorno_analise_aut'
   and nmpackag = 'WEBS0001'
   and lstparam NOT LIKE '%,pr_scorerat,pr_segmento%';
commit;

update crapaca set lstparam = lstparam || ',pr_segmento'
 where nmproced = 'pc_processa_analise'
   and nmpackag = 'EMPR0012'
   and lstparam NOT LIKE '%,pr_segmento%';
commit;

-- Alterar Rating
update crapaca a
   set a.nmproced = 'PC_ANALISAR_RATING'
      ,a.NMDEACAO = 'ANALISARRATING'
      ,a.lstparam = 'pr_nrcpfcgc,pr_nrdconta,pr_nrctrato,pr_tpctrato,pr_botao_chamada'
 where a.nmproced = 'PC_ALTERAR_RATING'
   and a.nmpackag = 'TELA_RATMOV'
   and a.NMDEACAO = 'ALTERARRATING';
commit;

update crapaca a
   set a.lstparam = 'pr_cdcoprat,pr_nmdatela,pr_nmrotina'
 where a.nmpackag = 'TELA_PARRAT'
   and a.Nmdeacao = 'CONSULTA_PARAM_RATING';
commit;

insert into crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr) values ('ALTERARRATING','TELA_RATMOV','PC_ALTERAR_RATING','pr_nrdconta,pr_nrctrato,pr_tpctrato,pr_rating_sugerido,pr_justificativa,pr_nmdatela,pr_nmrotina',1824);
commit;

-- OPÇÃO T - DSC CHQS - LIMITE - Remover opção Antiga
update craptel
   set cdopptel = replace(cdopptel,',T',NULL)
      ,lsopptel = replace(lsopptel, ',ALTERAR RATING', NULL)
 where UPPER(NMDATELA) like UPPER('%ATENDA%')  --CDCOOPER, UPPER(NMDATELA), UPPER(NMROTINA)
   and UPPER(NMROTINA) like UPPER('DSC CHQS - LIMITE');
commit;

-- OPÇÃO Z - DSC CHQS - LIMITE
update craptel
   set cdopptel = cdopptel || ',Z',
       lsopptel = lsopptel || ',ALTERAR RATING'
 where UPPER(NMDATELA) like UPPER('%ATENDA%')
   and UPPER(NMROTINA) like UPPER('DSC CHQS - LIMITE')
   and ( cdopptel not like '%Z%');
commit;

-- OPÇÃO Z - DSC TITS - LIMITE
update craptel
   set cdopptel = cdopptel || ',Z',
       lsopptel = lsopptel || ',ALTERAR RATING'
 where UPPER(NMDATELA) like UPPER('%ATENDA%')
   and UPPER(NMROTINA) like UPPER('DSC TITS - LIMITE')
   and ( cdopptel not like '%Z%');
commit;

-- OPÇÃO Z - DSC TITS - PROPOSTA
update craptel
   set cdopptel = cdopptel || ',Z',
       lsopptel = lsopptel || ',ALTERAR RATING'
 where UPPER(NMDATELA) like UPPER('%ATENDA%')
   and UPPER(NMROTINA) like UPPER('DSC TITS - PROPOSTA')
   and ( cdopptel not like '%Z%');
commit;

-- OPÇÃO Z - EMPRESTIMOS
update craptel
   set cdopptel = cdopptel || ',Z',
       lsopptel = lsopptel || ',ALTERAR RATING'
 where UPPER(NMDATELA) like UPPER('%ATENDA%')
   and UPPER(NMROTINA) like UPPER('EMPRESTIMOS')
   and ( cdopptel not like '%Z%');
commit;

-- OPÇÃO Z - LIMITE CRED
update craptel
   set cdopptel = cdopptel || ',Z',
       lsopptel = lsopptel || ',ALTERAR RATING'
 where UPPER(NMDATELA) like UPPER('%ATENDA%')
   and UPPER(NMROTINA) like UPPER('LIMITE CRED')
   and ( cdopptel not like '%Z%');
commit;
