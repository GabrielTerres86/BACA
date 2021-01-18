-- INC0070801 - Erro arquivo B3

 update tbcapt_custodia_lanctos 
    set idsituacao = 9 
  where  idlancamento in (19862975,
                          19783590,
                          20265468,
                          20374586,
                          20608884,
						  20837830);
                         
COMMIT;                         
