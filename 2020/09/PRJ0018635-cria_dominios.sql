


insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDA', 1, 'Fornecido/Declarado');
insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDA', 2, 'Coletado em Birô');
insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDA', 3, 'Declaração do Contador');
insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDA', 4, 'Relatório de Faturamento');

insert into cecred.tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO ) 
                                     values ('TBCADAST_PESSOA_JURIDICA', 'TPCOMPROVACAORENDA', 'Tipo de Comprovacao de Renda');




commit; 