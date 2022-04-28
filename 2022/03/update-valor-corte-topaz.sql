declare
begin  
UPDATE cecred.tbgen_analise_fraude_param
   SET vlcorte_envio_topaz = 98
WHERE cdoperacao in (16,17);
commit;
end;
/