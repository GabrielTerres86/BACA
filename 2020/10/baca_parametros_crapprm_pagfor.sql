UPDATE crapprm prm
   SET prm.dsvlrprm = 'C',
       prm.dstexprm = 'Plano de controle dos arquivos Pagfor (A - CSV Nexxera para Sicredi / B - CNAB Connect:Direct para Sicredi / C - CSV SOA para API Bancoob e Connect:Direct para TIVIT)'
 WHERE prm.nmsistem = 'CRED'
   AND prm.cdcooper = 0
   AND prm.cdacesso = 'PLN_CTRL_PAGFOR';
   
UPDATE crapprm prm 
   SET prm.dsvlrprm = '5'     
 WHERE prm.cdcooper = 0 
   AND prm.nmsistem = 'CRED' 
   AND prm.cdacesso = 'HRINTERV_ENV_REM_PAGFOR';
 
UPDATE crapprm prm 
   SET prm.dsvlrprm = '1000'  
 WHERE prm.cdcooper = 0 
   AND prm.nmsistem = 'CRED' 
   AND prm.cdacesso = 'QTD_MAX_REG_PAGFOR';

UPDATE crapprm prm 
   SET prm.dsvlrprm = '25200' 
 WHERE prm.cdcooper = 0 
   AND prm.nmsistem = 'CRED' 
   AND prm.cdacesso = 'HRINI_ENV_REM_PAGFOR'; 
   
INSERT INTO crapprm (NMSISTEM, 
                     CDCOOPER, 
                     CDACESSO, 
                     DSTEXPRM, 
                     DSVLRPRM)
             VALUES ('CRED', 
                     0, 
                     'DATA_CTRL_PAGFOR', 
                     'Data que indica quando próxima mudança no plano de controle do Pagfor deve entrar em vigor', 
                     '21/10/2020');   
   
COMMIT;
