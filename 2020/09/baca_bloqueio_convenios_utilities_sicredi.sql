-- Dev1 executado em 11/08/2020
UPDATE crapscn SET crapscn.dtencemp = TRUNC(SYSDATE) WHERE crapscn.cdempres NOT IN ('147','149','609','K0','A0','D0','C06') AND crapscn.dtencemp IS NULL AND crapscn.dsoparre <> 'E';
COMMIT;
