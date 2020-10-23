insert into crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values
  ('CRED',
   0,
   'HISTORICOSAQUEPAGUE',
   'Historicos do produto Saque Pague para serem considerados na composição do saldo',
   '2936,2937,2938,2967,2968,2969');
 /* 
    SELECT prm.dsvlrprm
            FROM crapprm prm
           WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = 0 
             AND prm.cdacesso = 'HISTORICOSAQUEPAGUE'
           ORDER BY prm.cdcooper DESC; -->
 */  
          
insert into crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values
  ('CRED',
   0,
   'HISTORICOCOMPORSALDO',
   'Historicos do produto Saque Pague para serem considerados na composição do saldo',
   '15,316,375,376,377,450,530,537,538,539,767,771,772,918,920,1109,1110,1009,1011,527,472,478,497,499,501,508,108,1060,1070,1071,1072,2139,2948,2949,3077,3078,3091,3092,3099,3100');

 /*
    SELECT prm.dsvlrprm
            FROM crapprm prm
           WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = 0 
             AND prm.cdacesso = 'HISTORICOCOMPORSALDO'
           ORDER BY prm.cdcooper DESC; -->
 */ 
    
insert into crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values
  ('CRED',
   0,
   'HISTORICOTRANFERENCIA',
   'Historicos de transferencia agendada para não serem considerados na composição do saldo',
   '375,376,377,537,538,539,771,772'); 
 
/*
    SELECT prm.dsvlrprm
            FROM crapprm prm
           WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = 0 
             AND prm.cdacesso = 'HISTORICOTRANFERENCIA'
           ORDER BY prm.cdcooper DESC; -->
 */ 
 
 
insert into crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values
  ('CRED',
   0,
   'TRANSFERENCIAINTERNA',
   'Historicos de transferencia agendada para não serem considerados na composição do saldo',
   '1009,1011');
  
/*
    SELECT prm.dsvlrprm
            FROM crapprm prm
           WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = 0 
             AND prm.cdacesso = 'TRANSFERENCIAINTER'
           ORDER BY prm.cdcooper DESC; -->
 */ 
 
  
insert into crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values
  ('CRED',
   0,
   'HISTORICOAPLICACAO',
   'Historicos de resgate de aplciação para não serem considerados na composição do saldo',
   '530,3100');
    
/*
    SELECT prm.dsvlrprm
            FROM crapprm prm
           WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = 0 
             AND prm.cdacesso = 'HISTORICOAPLICACAO'
           ORDER BY prm.cdcooper DESC; -->
 */ 
 
 
commit;
