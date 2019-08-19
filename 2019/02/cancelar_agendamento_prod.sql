 UPDATE craplau lau
          SET lau.insitlau = 3 -- cancelado
             ,lau.dtdebito = lau.dtmvtopg 
             
        WHERE lau.progress_recid = 25499828;

  COMMIT;
