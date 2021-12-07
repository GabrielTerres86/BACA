begin
UPDATE gncvuni SET gncvuni.flgproce = 0
WHERE gncvuni.dtmvtolt = '06/12/2021' and gncvuni.dsmovtos like '%20211206%';

COMMIT;

end;

