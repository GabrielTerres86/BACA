INSERT INTO tbcrd_utilizacao_cartao
    (dtmvtolt
    ,nrconta_cartao
    ,cdcooper
    ,nrdconta
    ,qttransa_debito
    ,qttransa_credito
    ,vltransa_debito
    ,vltransa_credito)
    SELECT dtmvtolt
          ,nrconta_cartao
          ,1 cdcooper
          ,8523924 nrdconta
          ,qttransa_debito
          ,qttransa_credito
          ,vltransa_debito
          ,vltransa_credito
      FROM (SELECT tbcc.dtmvtolt
                  ,tbcc.nrconta_cartao
                  ,tbcc.qttransa_debito
                  ,tbcc.qttransa_credito
                  ,tbcc.vltransa_debito
                  ,tbcc.vltransa_credito
              FROM tbcrd_intermed_utlz_cartao tbcc
             WHERE tbcc.nrconta_cartao = 7563239272604
               AND tbcc.dtmvtolt BETWEEN '01/01/2020' AND '31/01/2021'
               AND tbcc.dtmvtolt <> '30/05/2020');
			   
COMMIT;