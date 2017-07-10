create or replace view cecred.vwsoa_token_zenvia as
Select DSVLRPRM FROM CRAPPRM WHERE NMSISTEM = 'CRED' AND CDCOOPER = 0 AND CDACESSO = 'TOKEN.ZENVIA';