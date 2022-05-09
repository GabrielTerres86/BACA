begin

   UPDATE craplft lft
      SET lft.insitfat = 2,
          lft.dtdenvio = to_date('09/05/2022','DD/MM/YYYY')           
    WHERE lft.cdcooper = 7
      and lft.cdhistor = 3194
      AND lft.insitfat = 1
      AND lft.vllanmto = 12.66;
COMMIT;

end;