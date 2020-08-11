update crapprm set
       dsvlrprm = 6
 where cdacesso = 'COVID_QTDE_PARCELA_ADIAR' 
   and cdcooper in (8);
commit;
