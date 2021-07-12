begin
Insert into CRAPPRM (NMSISTEM,CDCOOPER,CDACESSO,DSTEXPRM,DSVLRPRM) values ('CRED','0'
,'ENVIA_SEG_PRST_MAIL_CSV','Email para envio de arquivo com previa arquivo csv pc_envia_arq_seg_prst'
,'seguros.vida@ailos.coop.br');

   COMMIT;
   EXCEPTION 
     WHEN OTHERS THEN 
       ROLLBACK;
END;
/