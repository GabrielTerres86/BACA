UPDATE crapprm p
   SET p.dsvlrprm = 'C',
       p.dstexprm = 'Plano de controle dos arquivos Pagfor (A - CSV Nexxera para Sicredi / B - CNAB Connect:Direct para Sicredi / C - CSV SOA para API Bancoob)'
 WHERE p.nmsistem = 'CRED'
   AND p.cdcooper = 0
   AND p.cdacesso = 'PLN_CTRL_PAGFOR';
   
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DATA_CTRL_PAGFOR', 'Data que indica quando próxima mudança no plano de controle do Pagfor deve entrar em vigor', '16/09/2020');   
   
COMMIT;
