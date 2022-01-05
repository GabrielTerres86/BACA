begin

UPDATE gncvuni SET gncvuni.flgproce = 0 WHERE gncvuni.dtmvtolt = to_date('06/12/2021','DD/MM/YYYY') and gncvuni.dsmovtos like '%20211206%';

COMMIT;

end;