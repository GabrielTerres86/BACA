begin
  update tbseg_contratos set indsituacao = 'V' where dttermino_vigencia < sysdate and tpseguro = 'G' and indsituacao = 'A';
  commit;
end;