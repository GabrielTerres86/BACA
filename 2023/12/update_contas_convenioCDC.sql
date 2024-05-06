DECLARE
   CURSOR cur_pessoas IS
    SELECT pes.idpessoa, cdc.CDCOOPER, ass.NRCPFCGC, cdc.NRDCONTA as nrdconta_cdc
    FROM CECRED.TBSITE_COOPERADO_CDC cdc
    INNER JOIN crapass ass ON ass.cdcooper = cdc.cdcooper AND ass.nrdconta = cdc.nrdconta and ass.dtdemiss is null
    inner join crapcdr cdr on ass.cdcooper = cdr.cdcooper AND ass.nrdconta = cdr.nrdconta and cdr.flgconve =1 
    INNER JOIN CECRED.TBCADAST_PESSOA pes ON cdc.CDCOOPER = pes.CDCOOPER AND cdc.NRDCONTA <> pes.NRDCONTA AND ass.nrcpfcgc = pes.nrcpfcgc;
    
BEGIN
   FOR pessoa IN cur_pessoas
   LOOP
      UPDATE CECRED.TBCADAST_PESSOA
         SET CECRED.TBCADAST_PESSOA.NRDCONTA = pessoa.NRDCONTA_cdc
       WHERE CECRED.TBCADAST_PESSOA.CDCOOPER = pessoa.CDCOOPER AND CECRED.TBCADAST_PESSOA.NRCPFCGC = pessoa.NRCPFCGC AND CECRED.TBCADAST_PESSOA.NRDCONTA <> pessoa.NRDCONTA_cdc;
   END LOOP;
   COMMIT;
END;