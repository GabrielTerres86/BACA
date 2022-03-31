begin

UPDATE gncvuni SET gncvuni.flgproce = 0 WHERE gncvuni.tpdcontr = 1 and gncvuni.dtmvtolt = dtmvtolt = to_date('30/03/2022','DD/MM/YYYY');
COMMIT;

end;