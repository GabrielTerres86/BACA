BEGIN
  FOR rw_crapcop IN (SELECT cop.cdcooper FROM crapcop cop WHERE cop.flgativo = 1) LOOP
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', rw_crapcop.cdcooper, 'PRST_FTP_ENDERECO', '', 'mft.chubblatinamerica.com');
    
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', rw_crapcop.cdcooper, 'PRST_FTP_LOGIN', '', 'cecred');
    
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', rw_crapcop.cdcooper, 'PRST_FTP_SENHA', '', 'ChubbBZCB2!');
  END LOOP;
  COMMIT;
END;
