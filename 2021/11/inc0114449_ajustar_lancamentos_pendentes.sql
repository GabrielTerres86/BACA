begin  
  UPDATE TBCC_LANCAMENTOS_PENDENTES SET
    IDSITUACAO = 'M'
  WHERE IDTRANSACAO IN (46724504, 46724950, 46724964, 46724985, 46724987, 46725000, 46725048)
    AND IDSITUACAO <> 'P';
  
  commit;

  EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
end;