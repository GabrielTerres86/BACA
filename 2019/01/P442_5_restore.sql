begin
  delete from tbgen_fipe_tabela;
  delete from tbgen_fipe_modelo;
  delete from tbgen_fipe_marca; 
  delete from tbgen_fipe_ano;

  insert into tbgen_fipe_ano t
   SELECT INMARCAFIPE, INMODELOFIPE, NRANOFIPE, MIN(dsanofipe) dsanofipe, MAX(dsanocompletofipe) dsanocompletofipe
    FROM cecred.tbgen_fipe_ano_tmp
   GROUP BY INMARCAFIPE, INMODELOFIPE, NRANOFIPE;
    
  insert into tbgen_fipe_marca t
   select *
    from tbgen_fipe_marca_tmp;

  insert into tbgen_fipe_modelo t
   select *
    from tbgen_fipe_modelo_tmp;

  INSERT INTO tbgen_fipe_tabela t
   SELECT INMARCAFIPE, INMODELOFIPE, NRANOFIPE, CDTABELAFIPE
        ,MIN(dsmarcafipe) dsmarcafipe
        ,MIN(dscombustivel) dscombustivel
        ,MAX(vltabelafipe) vltabelafipe
    FROM cecred.tbgen_fipe_tabela_tmp
   GROUP BY INMARCAFIPE, INMODELOFIPE, NRANOFIPE, CDTABELAFIPE;
      
  commit;
end;  
/