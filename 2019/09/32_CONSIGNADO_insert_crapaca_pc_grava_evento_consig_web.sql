DECLARE  
  v_nrseqrdr number := null;  
BEGIN  
   begin 
     SELECT nrseqrdr 
       INTO v_nrseqrdr
       FROM craprdr  
      WHERE nmprogra = 'ATENDA';
   EXCEPTION
      WHEN no_data_found THEN
        INSERT INTO craprdr (NRSEQRDR,nmprogra,dtsolici) 
        VALUES (SEQRDR_NRSEQRDR.NEXTVAL,'ATENDA',SYSDATE);
   END;   
    insert into cecred.crapaca(nrseqaca,nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
    values (SEQACA_NRSEQACA.NEXTVAL,'GRAVA_EVENTO_CONSIG', 'EMPR0020', 'pc_grava_evento_consig_web', 
    NULL,v_nrseqrdr);
commit;
END; 
/
