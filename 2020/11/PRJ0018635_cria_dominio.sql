
insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDAPF', 1, 'Declarada');
insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDAPF', 2, 'Coletado em Birô');
insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDAPF', 3, 'Convicção de Renda');
insert into cecred.tbcadast_dominio_campo values ('TPCOMPROVACAORENDAPF', 4, 'Comprovada');

insert into cecred.tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO ) 
                                     values ('TBCADAST_PESSOA_FISICA', 'TPCOMPRENDA', 'Tipo de Comprovacao de Renda para PF');
                                     
 

                                    
insert into cecred.tbcadast_dominio_campo values ('TPRESPABERTURA', 0, 'Cooperado');
insert into cecred.tbcadast_dominio_campo values ('TPRESPABERTURA', 1, 'Procurador');

insert into cecred.tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO ) 
                                     values ('TBCADAST_PESSOA_FISICA', 'INRESPABERTURA', 'Responsável pela Abertura da Conta (Dominio: TPRESPABERTURA)');
       

