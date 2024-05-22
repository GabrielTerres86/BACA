BEGIN

update cecred.tbseg_historico_relatorio h
   set h.dtfim = to_date('30/04/2024','dd/mm/yyyy')
 where h.idhistorico_relatorio in (5,6);
 
insert into cecred.tbseg_historico_relatorio(idhistorico_relatorio, cdacesso, dstexprm, dsvlrprm, dtinicio, dtfim, fltpcusteio)
values (7,'NOVA_PROPOSTA_PREST_4','Relatório Prestamista depois da modificação da RITM0390565','proposta_prestamista_r0390565.jasper',to_date('17/06/2024','dd/mm/yyyy'),null,1);

insert into cecred.tbseg_historico_relatorio(idhistorico_relatorio, cdacesso, dstexprm, dsvlrprm, dtinicio, dtfim, fltpcusteio)
values (8,'PROP_PRST_CONTRB_1','Relatório Prestamista depois da modificação da RITM0390565','proposta_prestamista_contributario_1.jasper',to_date('17/06/2024','dd/mm/yyyy'),null,0);

COMMIT;
END;
                                              
