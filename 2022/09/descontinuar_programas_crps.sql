BEGIN
  UPDATE crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE CDCOOPER <> 3 AND UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS182';
  UPDATE crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE CDCOOPER <> 3 AND UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS253';
  UPDATE crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE CDCOOPER <> 3 AND UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS270';
  UPDATE crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE CDCOOPER <> 3 AND UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS292';
  UPDATE crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE CDCOOPER <> 3 AND UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS413';
  UPDATE crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE CDCOOPER <> 3 AND UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS441';
  UPDATE crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE CDCOOPER <> 3 AND UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS695';
  COMMIT;
END;
