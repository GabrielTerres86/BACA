BEGIN 
 update tbgen_trans_pend tp
    set tp.idsituacao_transacao = 4,
        tp.dtalteracao_situacao = TRUNC(SYSDATE)
  where tp.cdtransacao_pendente in (5015485, 5016138, 5016973, 5016980, 5018037, 5019166, 5019281, 5019285, 5020058, 5021038);
  
 commit;
END;