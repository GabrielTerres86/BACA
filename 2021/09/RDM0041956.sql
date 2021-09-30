BEGIN 

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 1, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', '1');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 5, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 6, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 8, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 9, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 10, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 12, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 13, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 14, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 16, 'FLG_PAG_FGTS_CXON', 'Trava de bloqueio de arrecadação FGTS Caixa Online (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');

  UPDATE crapaca 
     set lstparam = 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_codfebraban,pr_cdsegmento,pr_nmfantasia,pr_rzsocial,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_vltarint,pr_vltarcxa,pr_vltartaa,pr_vltardeb,pr_forma_arrecadacao,pr_layout_arrecadacao,pr_tam_optante,pr_origem_inclusao,pr_cod_arquivo,pr_cdcooper,pr_banco,pr_intpconvenio,pr_envia_relatorio_mensal,pr_arq_unico,pr_tipo_envio,pr_diretorio_accesstage,pr_vencto_contrato,pr_envia_relatorio_para,pr_seq_arrecadacao,pr_arq_arrecadacao,pr_envia_arq_parcial,pr_seq_parcial,pr_arq_parcial,pr_hr_arq_fgts,pr_valida_vncto,pr_dias_tolera,pr_seq_integracao,pr_arq_integracao,pr_seq_cadastro_retorno,pr_arq_cadastro_optante,pr_arq_retorno,pr_layout_debito,pr_usa_agencia,pr_acata_duplicacao,pr_inclui_debito_facil,pr_envia_alterta_pos,pr_declaracao,pr_valida_cpfcnpj,pr_debita_sem_saldo,pr_envia_data_repasse,pr_identifica_fatura,pr_gera_reg_j,pr_hist_pagto,pr_hist_deb_auto,pr_hist_rep_ailos,pr_conta_deb_filiada,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo'
   WHERE nmpackag = 'TELA_CONVEN' 
     AND nmproced = 'pc_grava_conv_ailos' 
     AND nmdeacao = 'GRAVAR_DADOS_CONVEN_AILOS'; 

  update craptel tel 
     set tel.cdopptel = cdopptel || ',S'
       , tel.lsopptel = tel.lsopptel || ',REPROCESSAMENTO FGTS' 
   where tel.nmdatela = 'TAB057';

  commit;

END; 