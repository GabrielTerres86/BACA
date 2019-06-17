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
    values (SEQACA_NRSEQACA.NEXTVAL,'GERA_PGTO_PARC_CONSIG', 'EMPR0020', 'PC_GERA_PGTO_PARC_CONSIG_WEB', 
    'pr_nrdconta,pr_cdpactra,pr_idseqttl,pr_dtmvtolt,pr_flgerlog,pr_nrctremp,pr_dtmvtoan,pr_totatual,pr_totpagto,pr_nrseqava,pr_tab_pgto_parcel ',v_nrseqrdr);
commit;
END; 
/
