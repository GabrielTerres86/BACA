BEGIN
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) VALUES ('CRED',0,'DIR_SCCI_SEGUROS_RECEBE','Diretorio que recebe os arquivos da Prognum','/usr/sistemas/SCCI/Seguros');
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) VALUES ('CRED',0,'DIR_SCCI_SEGUROS_RECEBID','Diretorio que possui os arquivos recebidos e processados da Prognum','/usr/sistemas/SCCI/Seguros/Sucesso');
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) VALUES ('CRED',0,'DIR_SCCI_SEGUROS_ERRO', 'Diretorio que possui os arquivos recebidos e processados com erro da Prognum','/usr/sistemas/SCCI/Seguros/Erro');
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) VALUES ('CRED',0,'EMAIL_INTEGRA_PROGNUM','Email para envio de avisos de erro ao importar arquivo crédtio imobiliário PROGNUM','verificar@ailos.coop.br');
 COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
BEGIN     
  INSERT INTO crapaca
    (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ((SELECT MAX(NRSEQACA) + 1 FROM crapaca),
     'BUSCASEGCREDIMOB',
     'TELA_ATENDA_SEGURO',
     'pc_detalha_cred_imobiliario',
     'pr_nrdconta, pr_cdcooper, pr_idcontrato',
     (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_SEGURO'));
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
BEGIN
  INSERT INTO crapprg
    (nmsistem,
     cdprogra,
     dsprogra##1,
     dsprogra##2,
     dsprogra##3,
     dsprogra##4,
     nrsolici,
     nrordprg,
     inctrprg,
     cdrelato##1,
     cdrelato##2,
     cdrelato##3,
     cdrelato##4,
     cdrelato##5,
     inlibprg,
     cdcooper,
     qtminmed)
  VALUES
    ('CRED',
     'JB_COMIMOB',
     'COMISSÃO DO CRÉDITO IMOBILIÁRIO',
     'RELATÓRIO DE COMISSÃO DO CRÉDITO IMOBILIÁRIO DO MÊS ANTERIOR',
     NULL,
     NULL,
     9999,
     850,
     1,
     850,
     0,
     0,
     0,
     0,
     1,
     3,
     NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    ROLLBACK;
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'DELPHOS_FTP_ENDERECO',
     'Endereço de conexão FTP',
     'ftp.delphos.com.br');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;    
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'DELPHOS_FTP_LOGIN',
     'Nome do usuário',
     'sftpdphailos');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'DELPHOS_FTP_SENHA',
     'Senha do usuário',
     'ailos@2020');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
BEGIN
  INSERT INTO cecred.craprel
    (cdrelato,
     nrviadef,
     nrviamax,
     nmrelato,
     nrmodulo,
     nmdestin,
     nmformul,
     indaudit,
     cdcooper,
     periodic,
     tprelato,
     inimprel,
     ingerpdf)
  values
    (850,
     '1',
     '999',
     'Comissao Seg. Cred. Imobiliario',
     '1',
     'Credito Imobiliario',
     '234col',
     '0',
     '3',
     'Mensal',
     '1',
     '1',
     '1');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
