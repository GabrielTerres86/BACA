begin
  --Inclus�o de estado civil
  insert into gnetcvl
    (cdestcvl, dsestcvl, rsestcvl, progress_recid)
  values
    (0, 'NAO INFORMADO', 'NAO INFORMA.', null);

  --Inclus�o de escolaridade
  insert into gngresc
    (grescola, dsescola, progress_recid)
  values
    (0, 'NAO INFORMADO', null);

  --Inclus�o de ocupa��o
  insert into gncdocp
    (cdocupa, dsdocupa, cdnatocp, rsdocupa, progress_recid)
  values
    (0, 'NAO INFORMADO', 0, 'NAO INFORMADO', null);

  --Efetivar
  commit;
end;
