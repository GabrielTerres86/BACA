--script pra remover o email do Marcelo Silva 
update crapprm m
  set m.dsvlrprm = 'facilities03@ailos.coop.br;fernanda.eccher@ailos.coop.br;maxsuell.duranti@ailos.coop.br'
where cdacesso = 'CRPS408_EMAIL_RRD';
commit;
