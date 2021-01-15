DECLARE

  BEGIN

    DELETE FROM craplem 
          WHERE progress_recid IN (
                                    -- 04/12/2020: cdcooper = 1 AND nrdconta = 11116420 AND nrctremp = 3242906
                                    195036169,195036173,195036174

                                    -- 08/12/2020: cdcooper = 1 AND nrdconta = 7562411 AND nrctremp = 3259090
                                   ,195355860

                                    -- 09/12/2020: cdcooper = 1 AND nrdconta = 831263 AND nrctremp = 3215578
                                   ,195464345,195464346,195464347

                                    -- 09/12/2020: cdcooper = 1 AND nrdconta = 2730880 AND nrctremp = 3033456
                                   ,195449552,195449553,195449554,195449558,195449557,195449556

                                    -- 09/12/2020: cdcooper = 1 AND nrdconta = 11319569 AND nrctremp = 3086264
                                   ,195453029,195453030,195453031

                                    -- 11/12/2020: cdcooper = 1 AND nrdconta = 8380805 AND nrctremp = 3274165
                                   ,196115860,196115861

                                    -- 14/12/2020: cdcooper = 1 AND nrdconta = 1945173 AND nrctremp = 3215565
                                   ,196286046

                                    -- 14/12/2020: cdcooper = 1 AND nrdconta = 10743677 AND nrctremp = 3286042
                                   ,196314164

                                    -- 17/12/2020: cdcooper = 1 AND nrdconta = 9820558 AND nrctremp = 3040749
                                   ,196829581,196829582,196829583
                                  );

    COMMIT;
    dbms_output.put_line('Sucesso!');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
