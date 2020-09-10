BEGIN
  -- Viacredi - CC 10792988 , CTRT 2101947
  UPDATE crapprm prm
     SET prm.dsvlrprm = prm.dsvlrprm || ',(10792988,2101947)'
   WHERE prm.cdcooper = 1
     AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';

   BEGIN
     -- Civia - CC 3257408, CTRT 72238
     insert into crapprm (NMSISTEM
                         , CDCOOPER
                         , CDACESSO
                         , DSTEXPRM
                         , DSVLRPRM)
     values ('CRED'
            , 13
            , 'CTA_CTR_ACAO_JUDICIAL'
            , 'Lista de contas e contratos específicos que não podem debitar na conta corrente devido a ação judicial |formato=(cta,ctr)| (SD#618307)'
            , '(3257408,72238)');

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  COMMIT;
END;
