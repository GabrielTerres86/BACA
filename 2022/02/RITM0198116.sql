BEGIN
  
  UPDATE CECRED.CRAPSQU S
     SET S.NRSEQATU = 540000
   WHERE S.NMTABELA = 'CRAPASS'
     and S.NMDCAMPO = 'NRDCONTA'
     and S.DSDCHAVE = 9;
     
     
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001,'Erro ao atualizar sequencial de contas na entidade CRAPSQU para cooperativa 9 - TRANSPOCRED - ' || SQLERRM);
    ROLLBACK;    
END;    
