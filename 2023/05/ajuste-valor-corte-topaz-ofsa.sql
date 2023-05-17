begin

  UPDATE tbgen_analise_fraude_param a
     SET a.VLCORTE_ENVIO_OFSAA = 0
       , a.VLCORTE_ENVIO_TOPAZ = 89
   WHERE a.CDOPERACAO = 12;
  commit;

end;
/