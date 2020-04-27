update crapprm set
       dsvlrprm = 3
 where cdacesso = 'COVID_QTDE_PARCELA_PAGAR' 
   and cdcooper in (12);
   
update crapprm set
       dsvlrprm = 0
 where cdacesso = 'COVID_QTDE_PARCELA_ADIAR' 
   and cdcooper in (12);

commit;