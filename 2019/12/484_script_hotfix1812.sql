begin

  delete from tbevento_grupos where cdcooper in (13,14);
  delete from tbevento_pessoa_grupos where cdcooper in (13,14);
  delete from tbgen_notif_automatica_prm where cdorigem_mensagem = 11 and cdoriegm_mensagem = 3;
  update tbgen_notif_automatica_prm
     set nrdias_semana = '1,2,3,4,5,6,7'
       , nrsemanas_repeticao = '1,2,3,4,5'
   where cdorigem_mensagem = 11
     and cdmotivo_mensagem = 3;

  commit;

end;  