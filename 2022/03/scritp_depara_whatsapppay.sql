BEGIN
           
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (488, 'TRANSFERENCIA MAESTRO NACIONAL (WA PAY)', 3901, 0);

    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (493, 'ESTORNO RECEBIMENTO MAESTRO NACIONAL (WA PAY)', 3902, 0);
      

    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (492, 'RECEBIMENTO MAESTRO NACIONAL (WA PAY)', 3903, 0);
      

    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (489, 'REEMBOLSO MAESTRO NACIONAL (WA PAY)', 3904, 0);                    
         
        
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (488, 3901, 0);

    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (493, 3902, 0);
      
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (492, 3903, 0);
      
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (489, 3904, 0);   

   COMMIT;      
      
END;
