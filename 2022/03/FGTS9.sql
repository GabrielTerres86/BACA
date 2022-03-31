begin

UPDATE gncvuni SET gncvuni.flgproce = 0 WHERE gncvuni.tpdcontr = 1 and gncvuni.progress_recid >= 37613791;
COMMIT;

end;