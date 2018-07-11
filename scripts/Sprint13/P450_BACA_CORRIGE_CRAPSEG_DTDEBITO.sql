--> Atualizar data do proximo debito
   UPDATE crapseg x
      SET x.dtdebito = add_months(x.dtdebito, 1)
    WHERE x.tpseguro = 3
      AND x.dtprideb IS NULL
      AND x.cdsitseg = 1
      AND x.dtdebito < trunc(SYSDATE)  
      AND x.dtultpag >= x.dtdebito;
