

INSERT INTO tbgen_batch_param 
(idparametro,qtparalelo,qtreg_transacao,cdcooper,cdprograma) 
(SELECT ((SELECT nvl(Max(idparametro),0) FROM tbgen_batch_param )+ROWNUM) ,10,0,cdcooper,'CRPS734' FROM crapcop WHERE flgativo=1);


INSERT INTO tbgen_batch_param 
(idparametro,qtparalelo,qtreg_transacao,cdcooper,cdprograma) 
(SELECT ((SELECT nvl(Max(idparametro),0) FROM tbgen_batch_param )+ROWNUM) ,10,0,cdcooper,'PAGADOR' FROM crapcop WHERE flgativo=1);

INSERT INTO tbgen_batch_param 
(idparametro,qtparalelo,qtreg_transacao,cdcooper,cdprograma) 
(SELECT ((SELECT nvl(Max(idparametro),0) FROM tbgen_batch_param )+ROWNUM) ,10,0,cdcooper,'CRPS735' FROM crapcop WHERE flgativo=1);

INSERT INTO tbgen_batch_param 
(idparametro,qtparalelo,qtreg_transacao,cdcooper,cdprograma) 
(SELECT ((SELECT nvl(Max(idparametro),0) FROM tbgen_batch_param )+ROWNUM) ,10,0,cdcooper,'CRPS736' FROM crapcop WHERE flgativo=1);

