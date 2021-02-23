begin
  update tbseg_contratos set indsituacao = 'V' where cdparceiro = 2 and dttermino_vigencia < sysdate and tpseguro = 'G' and indsituacao = 'A' ;
  commit;
end;    