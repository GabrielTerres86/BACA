begin
  insert into cecred.craptab
       select nmsistem,
              tptabela,
              cdempres,
              'IRENDA2023',
              tpregist,
              dstextab,
              cdcooper,
              (select max(progress_recid)+1 from craptab where nmsistem = 'CRED')
         from craptab
        where nmsistem = 'CRED'
          AND CDACESSO = 'IRENDA2022'
          AND CDCOOPER = 11;
  commit;
end;
