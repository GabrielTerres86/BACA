insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'RATING_LOTE_ATIVO', 'Indicador de Rating por Lote se está ATIVO ou não', '1');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'RATING_RENOVACAO_ATIVO', 'Indicador de Renovação de Rating se está ATIVO ou não', '1');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'REGRA_ANL_MOTOR_PF_RAT', 'Nome da politica de RATING a ser executada no Motor de Credito IBRATAN - PF', 'PoliticaRatingPF');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'REGRA_ANL_MOTOR_PJ_RAT', 'Nome da politica de RATING a ser executada no Motor de Credito IBRATAN - PJ', 'PoliticaRatingPJ');

INSERT INTO crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
  VALUES('CRED'                                         --nmsistem
        ,0                                              --cdcooper (Geral para Todas as Cooperativas)
        ,'DT_CORTE_REFOR_RATING'                        --cdacesso
        ,'Data de Corte do Projeto Reformulação Rating' --dstexprm
        ,'13/09/2019');                                 --dsvlrprm



INSERT INTO tbgen_motivo
       (idmotivo, dsmotivo, cdproduto, flgreserva_sistema, flgativo, flgexibe, flgtipo)
    VALUES (82, 'Bloqueio pre-aprovado sem rating', 25, 0, 1, 0, 1);





COMMIT;
