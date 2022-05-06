begin

   UPDATE craplft lft
      SET lft.insitfat = 2,
          lft.dtdenvio = to_date('09/05/2022','DD/MM/YYYY')           
    WHERE lft.cdcooper IN (7,8)
      and lft.cdhistor in (3194,3196)
      AND lft.insitfat = 1;   
COMMIT;

end;