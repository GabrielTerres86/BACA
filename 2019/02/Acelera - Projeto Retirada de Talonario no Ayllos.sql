UPDATE crapaca
   SET lstparam = 'pr_nrdconta,pr_qtreqtal'
 WHERE nmdeacao = 'SOLICITA_TALONARIO';

UPDATE crapaca
   SET lstparam = 'pr_nrdconta,pr_tprequis,pr_nrinichq,pr_nrfinchq,pr_terceiro,pr_cpfterce,pr_nmtercei,pr_nrtaloes,pr_qtreqtal,pr_verifica'
 WHERE nmdeacao = 'CHQ_ENTREGA_TALONARIO';

COMMIT;
