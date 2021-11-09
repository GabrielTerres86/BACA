begin
   declare     
 cursor cr_qbrsigilo is 
   select * 
     from tbjur_qbr_sig_extrato 
    where nrseq_quebra_sigilo = 607 
      and (idsitqbr = 3);

begin
  for rr_qbrsigilo in cr_qbrsigilo loop
    
    --1 2118 11002 - CPF/CNPJ DEBITO; 79655916000130
    IF (rr_qbrsigilo.CDBANDEP = 1 and rr_qbrsigilo.CDAGEDEP = 2118 and rr_qbrsigilo.NRCTADEP = 11002) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 79655916000130,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 1
         and CDAGEDEP = 2118
         and NRCTADEP = 11002
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;

    --399 132 1320056145 - CPF/CNPJ DEBITO; 79655916000130
    IF (rr_qbrsigilo.CDBANDEP = 399 and rr_qbrsigilo.CDAGEDEP = 132 and rr_qbrsigilo.NRCTADEP = 1320056145) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 79655916000130,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 399
         and CDAGEDEP = 132
         and NRCTADEP = 1320056145
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;

    --341 292 876323 - CPF/CNPJ DEBITO; 79655916000130
    IF (rr_qbrsigilo.CDBANDEP = 341 and rr_qbrsigilo.CDAGEDEP = 292 and rr_qbrsigilo.NRCTADEP = 876323) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 79655916000130,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 341
         and CDAGEDEP = 292
         and NRCTADEP = 876323
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;

    --237 336 104108 - CPF/CNPJ DEBITO; 79655916000130
    IF (rr_qbrsigilo.CDBANDEP = 237 and rr_qbrsigilo.CDAGEDEP = 336 and rr_qbrsigilo.NRCTADEP = 104108) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 79655916000130,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 237
         and CDAGEDEP = 336
         and NRCTADEP = 104108
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;

    --399 639 6390000590 - CPF/CNPJ DEBITO; 79655916000130
    IF (rr_qbrsigilo.CDBANDEP = 399 and rr_qbrsigilo.CDAGEDEP = 639 and rr_qbrsigilo.NRCTADEP = 6390000590) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 7965591600013,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 399
         and CDAGEDEP = 639
         and NRCTADEP = 6390000590
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;

    --399 1384 13840002329 - CPF/CNPJ DEBITO; 83475913000191
    IF (rr_qbrsigilo.CDBANDEP = 399 and rr_qbrsigilo.CDAGEDEP = 1384 and rr_qbrsigilo.NRCTADEP = 13840002329) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 83475913000191,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 399
         and CDAGEDEP = 1384
         and NRCTADEP =13840002329
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;

    --33 3599 130013712 - CPF/CNPJ DEBITO; 79655916000130
    IF (rr_qbrsigilo.CDBANDEP = 33 and rr_qbrsigilo.CDAGEDEP = 3599 and rr_qbrsigilo.NRCTADEP = 130013712) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 79655916000130,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 33
         and CDAGEDEP = 3599
         and NRCTADEP = 130013712
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;

    --0 0 18740 - CPF/CNPJ DEBITO; 12433381000181
    IF (rr_qbrsigilo.CDBANDEP = 0 and rr_qbrsigilo.CDAGEDEP = 0 and rr_qbrsigilo.NRCTADEP = 18740) THEN
      
      UPDATE tbjur_qbr_sig_extrato
         SET NRCPFCGC = 12433381000181,
             idsitqbr = 6,
             dsobsqbr = 'SCRIPT TI'         
       WHERE NRSEQ_QUEBRA_SIGILO = rr_qbrsigilo.NRSEQ_QUEBRA_SIGILO
         and CDBANDEP = 0
         and CDAGEDEP = 0
         and NRCTADEP = 18740
         and nrseqlcm = rr_qbrsigilo.nrseqlcm;
         
    END IF;
    
    end loop rr_qbrsigilo;
    
    commit;

 end;
end;
/