begin

   UPDATE gncvuni
      SET gncvuni.flgproce = 1
    WHERE gncvuni.cdcooper = 7
      and gncvuni.flgproce = 0
      and gncvuni.dtmvtolt = to_date('09/05/2022','DD/MM/YYYY');

COMMIT;

end;