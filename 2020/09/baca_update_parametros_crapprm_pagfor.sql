UPDATE crapprm p
   SET p.dsvlrprm = 'C',
       p.dstexprm = 'Plano de controle dos arquivos Pagfor (A - CSV Nexxera para Sicredi / B - CNAB Connect:Direct para Sicredi / C - CSV SOA para API Bancoob)'
 WHERE p.nmsistem = 'CRED'
   AND p.cdcooper = 0
   AND p.cdacesso = 'PLN_CTRL_PAGFOR';
COMMIT;
