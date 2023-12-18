BEGIN

  DELETE FROM cecred.crapace a
   WHERE a.cdcooper IN (2, 6, 9, 5, 12)
     AND nmdatela = 'RESERV'
     AND cddopcao = 'R'
     AND lower(a.cdoperad) NOT IN ('f0033078',
                                   'f0033479',
                                   'f0033754',
                                   'f0034370',
                                   'f0034476',
                                   'f0030584',
                                   'f0034469',
                                   'f0034338',
                                   'f0034665',
                                   'f0033853',
                                   'f0033863',
                                   'f0033595',
                                   'f0033301',
                                   'f0034432',
                                   'f0034452',
                                   'f0033655',
                                   'f0034775',
                                   'f0034755',
                                   'f0033495',
                                   'f0060241',
                                   'f0060131',
                                   'f0020295',
                                   'f0020174',
                                   'f0020460',
                                   'f0090190',
                                   'f0090256',
                                   'f0090317',
                                   'f0090337',
                                   'f0090424',
                                   'f0090498',
                                   'f0090534',
                                   'f0090540',
                                   'f0090582',
                                   'f0090585',
                                   'f0090755',
                                   'f0090772',
                                   'f0090773',
                                   'f0050058',
                                   'f0050173',
                                   'f0050040',
                                   'f0050485',
                                   'f0120029',
                                   'f0120033');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
