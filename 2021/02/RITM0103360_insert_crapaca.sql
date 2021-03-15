begin
  insert into crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values
    ('IMPBVT_IMPORTA_ARQUIVO_SITUACAO',
     'TELA_IMPBVT',
     'pc_importar_arquivo_situacao',
     'pr_dsarquivo,pr_dsdireto',
     1904);

  commit;
end;
