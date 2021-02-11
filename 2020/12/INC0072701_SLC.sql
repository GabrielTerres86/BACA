declare
cursor curArquivo is 
     select t.*
       from cecred.tbdomic_liqtrans_arquivo t
      where t.idarquivo in(351628
,351632
,351648
,351653
,351657
,351661
,351673
,351697
,351705
,351709
,351723
,351725
,351726
,351733
,351629
,351630
,351636
,351644
,351646
,351652
,351674
,351689
,351715
,351716
,351717
,351739
,351741
,351742
,351745
,351633
,351634
,351643
,351645
,351650
,351664
,351682
,351685
,351690
,351695
,351698
,351704
,351711
,351732
,351738
,351744
,351626
,351635
,351637
,351641
,351647
,351654
,351662
,351665
,351666
,351667
,351676
,351680
,351683
,351719
,351727
,351731
,351627
,351639
,351651
,351659
,351669
,351671
,351672
,351675
,351684
,351687
,351696
,351699
,351707
,351708
,351714
,351718
,351737
,351640
,351642
,351649
,351655
,351656
,351668
,351670
,351678
,351694
,351700
,351701
,351713
,351721
,351724
,351728
,351729
,351747
,351748
,351638
,351658
,351677
,351679
,351681
,351688
,351691
,351692
,351722
,351730
,351734
,351735
,351736
,351740
,351749
,351631
,351660
,351663
,351686
,351693
,351702
,351703
,351706
,351710
,351712
,351720
,351743
,351746
);      
      
cursor curPdv(pidArquivo number) is
     select tlp.*
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
           ,tbdomic_liqtrans_arquivo tla
      WHERE tll.idlancto = tlc.idlancto
        AND tlc.idcentraliza = tlp.idcentraliza
        AND tll.idarquivo = tla.idarquivo
        and tla.idarquivo=pidArquivo;

begin
-- Dados do cursor "curArquivo" principal deste baca.
-- Validar quais arquivos deverão ser reprocessados, porém so reprocessar os arquivos "ASLC022" que não tenham "PGT".
 
-- A grade deverá estar aberta para poder reprocessar

    for r in curArquivo loop
        
        update cecred.tbdomic_liqtrans_arquivo t
        set t.nmarquivo_retorno=null,
            t.dharquivo_retorno=null,
            t.nmarquivo_gerado=null,
            t.dharquivo_gerado=null
        where t.idarquivo=r.idarquivo;
        
        update cecred.tbdomic_liqtrans_lancto l
        set l.insituacao=0,
            l.dserro=null,
            l.dhretorno=null,
            l.insituacao_retorno=null,
            l.dhconfirmacao_retorno=null
        where l.idarquivo=r.idArquivo;
        
        for r1 in curPdv(r.idArquivo) loop
            update cecred.tbdomic_liqtrans_pdv p
            set p.cdocorrencia=null,
                p.dhretorno=null,
                p.cdocorrencia_retorno=null,
                p.dserro=null,
                p.dsocorrencia_retorno=null
            where p.idpdv=r1.idpdv;          
        end loop; 
        
    end loop;
    
    commit;
end;
