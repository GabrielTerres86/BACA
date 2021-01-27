begin
  delete crapcje c
   where (c.cdcooper, c.nrdconta, c.idseqttl) in
         (select cj.cdcooper, cj.nrdconta, cj.idseqttl
            from crapttl tit
           inner join crapcje cj
              on tit.cdcooper = cj.cdcooper
             and tit.nrdconta = cj.nrdconta
             and tit.idseqttl = cj.idseqttl
           where tit.inpessoa = 1
             and tit.cdestcvl in (1, 5, 7));
             
  delete crapcje c
   where (c.cdcooper, c.nrdconta, c.idseqttl) in
         (select cj.cdcooper, cj.nrdconta, 1
            from crapjur jur
           inner join crapcje cj
              on jur.cdcooper = cj.cdcooper
             and jur.nrdconta = cj.nrdconta);
  
  commit;
end;
