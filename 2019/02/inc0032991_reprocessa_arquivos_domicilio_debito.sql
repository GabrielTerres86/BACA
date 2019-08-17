DECLARE

--Cursor para encontrar quais arquivos devem ser reprocessados
cursor curArquivo is      
select t.*
       from cecred.tbdomic_liqtrans_arquivo t
      where t.tparquivo = 2
         AND t.idarquivo IN (SELECT distinct(a.idarquivo)
                              FROM tbdomic_liqtrans_arquivo a
                                  ,tbdomic_liqtrans_lancto b
                                  ,tbdomic_liqtrans_centraliza c
                                  ,tbdomic_liqtrans_pdv d
                             WHERE trunc(a.dhrecebimento) = '14/02/2019' 
                              AND upper(a.nmarquivo_origem) LIKE '%ASLC024%'
                              AND b.idarquivo = a.idarquivo
                              AND c.idlancto = b.idlancto
                              AND d.idcentraliza = c.idcentraliza
                              AND d.dserro LIKE '%ESLC0029%')
                                order BY 1;
     
--Cursor para encontrar os registros que terão o status alterado para que possam ser reprocessados
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
 
 vr_qtArquivo  INTEGER :=0;
 vr_qtRegistro INTEGER :=0;
 vr_qtTotRegistro INTEGER :=0;
 
begin
    for r in curArquivo loop
        
        vr_qtArquivo := vr_qtArquivo + 1;
        vr_qtRegistro := 0;
                
        update cecred.tbdomic_liqtrans_arquivo t
        set t.nmarquivo_retorno=null,
            t.dharquivo_retorno=null,
            t.nmarquivo_gerado=null,
            t.dharquivo_gerado=null
        where t.idarquivo=r.idarquivo;
        
        update cecred.tbdomic_liqtrans_lancto l
        set l.insituacao=0, /*Para arquivos de crédito e débito deve sempre atualizar para 0. Caso contrário não entra na rotina
                            que atualiza o cdocorrencia das pdv.*/
            l.dserro=null,
            l.dhretorno=null,
            l.insituacao_retorno=null,
            l.dhconfirmacao_retorno=null
        where l.idarquivo=r.idArquivo;
        
        for r1 in curPdv(r.idArquivo) LOOP
            
            vr_qtTotRegistro := vr_qtTotRegistro + 1;
            vr_qtRegistro := vr_qtRegistro + 1;
            
            update cecred.tbdomic_liqtrans_pdv p
            set p.cdocorrencia=null,
                p.dhretorno=null,
                p.cdocorrencia_retorno=null,
                p.dserro=null,
                p.dsocorrencia_retorno=null
            where p.idpdv=r1.idpdv;          
        end loop; 
        
        dbms_output.put_line('Arquivo: ' || r.nmarquivo_origem || ' | Total de registros: ' || vr_qtRegistro || '.');
        
    end loop;
    
    dbms_output.put_line('');
    dbms_output.put_line('    Quantidade total de arquivos: ' || vr_qtArquivo ||'.');    
    dbms_output.put_line('Quantidade de total de registros: ' || vr_qtTotRegistro ||'.');
    
    commit;
    
end;
