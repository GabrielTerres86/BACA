BEGIN
UPDATE cecred.crapprm SET dsvlrprm = '/v1/beneficiarios/representantes/' WHERE cdcooper = 0 AND upper(nmsistem) = 'CRED' AND upper(cdacesso) = 'URL_API_INSS_GET_NB_RL';
COMMIT;
END;