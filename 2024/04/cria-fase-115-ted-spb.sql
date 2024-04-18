BEGIN
  INSERT INTO cecred.tbspb_msg_recebida_fase
    (nrseq_mensagem,
     cdfase,
     nmmensagem,
     dhmensagem,
     insituacao,
     nrseq_mensagem_xml,
     dhdthr_bc)
  VALUES
    (240238011543,
     115,
     'STR0004R2',
     to_date('14-02-2024 17:14:30', 'dd-mm-yyyy hh24:mi:ss'),
     'OK',
     24020074924883,
     to_date('14-02-2024 17:14:30', 'dd-mm-yyyy hh24:mi:ss'));

  COMMIT;
END;