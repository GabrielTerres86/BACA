BEGIN
  FOR st_req IN (SELECT R.DTHREQUIS,
                        R.DTHRESPOSTA,
                        R.DSSERVICO,
                        R.DSVERBO_HTTP,
                        R.DSCABECALHO_REQUIS,
                        R.DSCONTEUDO_REQUIS,
                        R.DSCABECALHO_RESPOSTA,
                        R.DSCONTEUDO_RESPOSTA,
                        R.NRTIMEOUT_REQUIS,
                        R.CDHTTP_RESPOSTA,
                        R.CDCRITIC
                   FROM SEGURO.TBSEG_REQ_WEBSERVICE R) LOOP
    INSERT INTO CECRED.TBGEN_REQ_WEBSERVICE(DHREQUIS,
                                            DHRESPOSTA,
                                            DSSERVICO,
                                            DSVERBO_HTTP,
                                            DSCABECALHO_REQUIS,
                                            DSCONTEUDO_REQUIS,
                                            DSCABECALHO_RESPOSTA,
                                            DSCONTEUDO_RESPOSTA,
                                            NRTIMEOUT_REQUIS,
                                            CDHTTP_RESPOSTA,
                                            CDCRITIC) 
    VALUES (st_req.DTHREQUIS,
            st_req.DTHRESPOSTA,
            st_req.DSSERVICO,
            st_req.DSVERBO_HTTP,
            st_req.DSCABECALHO_REQUIS,
            st_req.DSCONTEUDO_REQUIS,
            st_req.DSCABECALHO_RESPOSTA,
            st_req.DSCONTEUDO_RESPOSTA,
            st_req.NRTIMEOUT_REQUIS,
            st_req.CDHTTP_RESPOSTA,
            st_req.CDCRITIC);
    COMMIT;
  END LOOP;
END;
/
