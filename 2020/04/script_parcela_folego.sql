update crapprm set
       dsvlrprm = 4
 where cdacesso = 'COVID_QTDE_PARCELA_PAGAR' 
   and cdcooper in (6,12);

commit;
       
