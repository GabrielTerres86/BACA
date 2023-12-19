BEGIN
  INSERT INTO cecred.tbspb_msg_enviada_fase
    (nrseq_mensagem,
     cdfase,
     nmmensagem,
     dhmensagem,
     insituacao,
     nrseq_mensagem_xml)
  VALUES
    (231215739920,
     55,
     'STR0037R1',
     to_date('18-12-2023 07:12:05', 'dd-mm-yyyy hh24:mi:ss'),
     'OK',
     23120073699757);
  COMMIT;
END;