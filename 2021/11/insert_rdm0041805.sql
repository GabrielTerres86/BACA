select gene0001.fn_param_sistema('CRED',1,'QTD_GRUPOS_CRPS008') from dual;
-- Insert de parametro referente ao grupo do CRPS008
INSERT into crapprm(nmsistem,
                    cdcooper,
                    cdacesso,
                    dstexprm,
                    dsvlrprm) VALUES('CRED',1,'QTD_GRUPOS_CRPS008','Quantidade de grupos no paralelismo do CRPS008',200);
COMMIT;
