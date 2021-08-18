BEGIN

  DELETE FROM crapsda sda
        WHERE sda.cdcooper = 11
          AND sda.dtmvtolt >= to_date('10/08/2021','dd/mm/rrrr');

  COMMIT;

END;