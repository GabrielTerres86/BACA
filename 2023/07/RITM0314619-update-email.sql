begin 
  
update cecred.crapprm p
   set p.dsvlrprm = 'seguroprestamista@ailos.coop.br'
 where p.dsvlrprm = 'seguros.vida@ailos.coop.br';
 
commit;
end; 