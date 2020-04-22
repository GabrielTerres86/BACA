
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
SELECT  'CRED', c.cdcooper, 'PER_SUSPENSAO_JUR_EPR', 'Periodo de suspensao de cobrança de juros de mora e multa', '01/04/2020;30/06/2020'
 FROM crapcop c;
COMMIT;
