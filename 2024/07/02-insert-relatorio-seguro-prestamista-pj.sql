BEGIN

INSERT INTO CECRED.tbseg_historico_relatorio (IDHISTORICO_RELATORIO,CDACESSO,DSTEXPRM,DSVLRPRM,DTINICIO,FLTPCUSTEIO,TPPESSOA)
VALUES (9,'PROP_PRESTAMISTA_PJ_1','Relatório Prestamista Contributário PJ','proposta_prestamista_contributario_pj_01.jasper',TRUNC(SYSDATE),0,2);


COMMIT;
END;