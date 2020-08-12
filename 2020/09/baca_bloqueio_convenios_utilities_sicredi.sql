UPDATE crapscn SET crapscn.dtencemp = to_date('16/09/2020','dd/mm/rrrr') WHERE crapscn.cdempres NOT IN ('147','149','609','K0','A0','D0','C06') AND crapscn.dtencemp IS NULL AND crapscn.dsoparre <> 'E';
COMMIT;
