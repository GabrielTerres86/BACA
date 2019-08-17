begin 

/*

Boa tarde,

Por uma migração e erro da CETIP(B3) perdemos o aceso para envios de lote de todas as cooperativas, estamos em contato com o parceiro porém não temos expectativa de correção.

Como medida paliativa, vamos solicitar as cooperativas que alienem manualmente os veículos, a fim de não estagnar os créditos. Para tanto, gostaria de verificar com a sustentação se existe a possibilidade de alterar todas os veículos que estão como "Em processamento" na tela GRAVAM e alterar para "Não Enviado" para que seja possível alienação manual da cooperativa.

A alteração é necessária, pois o status "Em processamento" não permite qualquer alteração.

Peço por gentileza ser tratado urgente, a cooperativa Viacredi Alto Vale tem um caso em que o Cooperado viajou hoje para retirar o veículo, pois ele já foi alienado ontem (11/04), mas como não tivemos o retorno do lote, continua "Em processamento" na Gravam e não conseguem alienar/efetivar o contrato.

Atenciosamente,
Eduardo Gonçalves dos Santos

*/

  /* Processado com Critica */
  update crapbpr c
     set c.cdsitgrv = 3
   WHERE c.progress_recid IN
         ( 5739333
          ,5739391
          ,5736343
          ,5734872
          ,5734872
          ,5734872
          ,5734872
          ,5729113
          ,5729113
          ,5653990
          ,5616154
          ,5735456
          ,5741269
          ,5751168
          ,5755863
          ,5752729
          ,5756232
          ,5727877
          ,5727877
          ,5712188
          ,5756261
          ,5754728
          ,5756229
          ,5743441
          ,5755738
          ,5741853
          ,5741853
          ,5741853
          ,5756800
          ,5756813
          ,5736424
          ,5736424
          ,5736424
          ,5736424
          ,5750053
          ,5750053
          ,5752148
          ,5751594
          ,5753583
          ,5733783
          ,5744044
          ,5744044
          ,5744044
          ,5744044
          ,5749660
          ,5755581
          ,5739370
          ,5741521
          ,5752153
          ,5755773
          ,5742361
          ,5747078
          ,5753620
          ,5745310
          ,5755822
          ,5752759
          ,5751045
          ,5751045
          ,5733209
          ,5751720
          ,5750932
          ,5756253
          ,5739567
          ,5757336
          ,5724741
          );
 
   
  update crapgrv c
   set c.dtretgrv = trunc(sysdate)
   WHERE c.dtretgrv is NULL
     AND c.progress_recid IN 
     ( 4645631
      ,4649444
      ,4648874
      ,4644974
      ,4645545
      ,4645587
      ,4648875
      ,4645560
      ,4645610
      ,4649436
      ,4649462
      ,4649458
      ,4649432
      ,4648876
      ,4645613
      ,4649433
      ,4645638
      ,4644987
      ,4648888
      ,4649443
      ,4649441
      ,4645634
      ,4645641
      ,4649424
      ,4649463
      ,4645537
      ,4645580
      ,4645628
      ,4649085
      ,4649435
      ,4641731
      ,4645536
      ,4645579
      ,4645630
      ,4645558
      ,4645609
      ,4645629
      ,4649453
      ,4645627
      ,4649434
      ,4641744
      ,4645541
      ,4645572
      ,4645642
      ,4645637
      ,4649440
      ,4645632
      ,4649442
      ,4649438
      ,4649437
      ,4645625
      ,4645608
      ,4645633
      ,4649423
      ,4645640
      ,4649454
      ,4645571
      ,4645643
      ,4645612
      ,4645607
      ,4649086
      ,4649445
      ,4649459
      ,4649439
      ,4649169
      );

  commit;

exception
  
  when others then
  
    rollback;

end;
