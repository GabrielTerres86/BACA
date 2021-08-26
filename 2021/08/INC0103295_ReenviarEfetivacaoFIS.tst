PL/SQL Developer Test script 3.0
131
declare 
  procedure ReenviarEfetivacaoFIS(pr_idevento IN tbgen_evento_soa.idevento%type) is
    cursor cr_soa is
      select s.idevento,
             s.cdcooper,
             s.nrdconta,
             s.nrctrprp,
             s.tpevento,
             s.tproduto_evento,
             s.tpoperacao,
             s.dhoperacao,
             s.dsprocessamento,
             s.dsstatus,
             s.dhevento,
             s.dserro,
             s.nrtentativas,
             s.dsconteudo_requisicao
        from tbgen_evento_soa s
       where s.idevento = pr_idevento;
    rw_soa         cr_soa%rowtype;
    vr_pos1        number;
    vr_pos2        number;
    vr_valorbase   varchar2(200);
    vr_valorrefin  varchar2(200);
    vr_data        varchar2(200) := '2021-08-26T17:05:00';
    vr_dataatual   varchar2(200);
    vr_xmlcontent  varchar2(30000);

  begin
    open cr_soa;
    fetch cr_soa into rw_soa;
    close cr_soa;
    if rw_soa.idevento is null then
      dbms_output.put_line('Não encontrado: ' || pr_idevento);
      return;
    end if;
    vr_pos1 := INSTR(rw_soa.dsconteudo_requisicao, '                        <valor>') + 31;
    vr_pos2 := INSTR(rw_soa.dsconteudo_requisicao, '</valor><valorBase>');
    vr_valorbase := SUBSTR(rw_soa.dsconteudo_requisicao, vr_pos1, vr_pos2-vr_pos1);

    vr_pos1 := INSTR(rw_soa.dsconteudo_requisicao, '<codigo>32</codigo></produtoCategoria><saldo>') + 45;
    vr_pos2 := INSTR(rw_soa.dsconteudo_requisicao, '</saldo></posicao><usuarioDominioCecred>');
    vr_valorrefin := SUBSTR(rw_soa.dsconteudo_requisicao, vr_pos1, vr_pos2-vr_pos1);

    vr_xmlcontent := REPLACE(rw_soa.dsconteudo_requisicao, '<codigo>32</codigo></produtoCategoria><saldo>' || vr_valorrefin || '</saldo></posicao><usuarioDominioCecred>'
                                                          ,'<codigo>32</codigo></produtoCategoria><saldo>' || vr_valorbase  || '</saldo></posicao><usuarioDominioCecred>');

    vr_pos1 := INSTR(rw_soa.dsconteudo_requisicao, '</valorBase><dataProposta>') + 26;
    vr_pos2 := vr_pos1 + 19;
    vr_dataatual := SUBSTR(rw_soa.dsconteudo_requisicao, vr_pos1, vr_pos2-vr_pos1);

    vr_xmlcontent := REPLACE(vr_xmlcontent, '</valorBase><dataProposta>' || vr_dataatual || '</dataProposta>'
                                           ,'</valorBase><dataProposta>' || vr_data      || '</dataProposta>');

    -- dbms_output.put_line(vr_xmlcontent);
    INSERT INTO tbgen_evento_soa
                (cdcooper
               , nrdconta
               , nrctrprp
               , tpevento
               , tproduto_evento
               , tpoperacao
               , dhoperacao
               , dsprocessamento
               , dsstatus
               , dhevento
               , dserro
               , nrtentativas
               , dsconteudo_requisicao)
    VALUES
              (rw_soa.cdcooper
             , rw_soa.nrdconta
             , rw_soa.nrctrprp
             , rw_soa.tpevento
             , rw_soa.tproduto_evento
             , rw_soa.tpoperacao
             , SYSDATE
             , rw_soa.dsprocessamento
             , NULL
             , NULL
             , NULL
             , NULL
             , vr_xmlcontent);
  end;
begin
  ReenviarEfetivacaoFIS(4358926);
  ReenviarEfetivacaoFIS(4358881);
  ReenviarEfetivacaoFIS(4358948);
  ReenviarEfetivacaoFIS(4358886);
  ReenviarEfetivacaoFIS(4358952);
  ReenviarEfetivacaoFIS(4358987);
  ReenviarEfetivacaoFIS(4359050);
  ReenviarEfetivacaoFIS(4494815);
  ReenviarEfetivacaoFIS(4359054);
  ReenviarEfetivacaoFIS(4494760);
  ReenviarEfetivacaoFIS(4359055);
  ReenviarEfetivacaoFIS(4494761);
  ReenviarEfetivacaoFIS(4494762);
  ReenviarEfetivacaoFIS(4359064);
  ReenviarEfetivacaoFIS(4494763);
  ReenviarEfetivacaoFIS(4359065);
  ReenviarEfetivacaoFIS(4359369);
  ReenviarEfetivacaoFIS(4359108);
  ReenviarEfetivacaoFIS(4359086);
  ReenviarEfetivacaoFIS(4359088);
  ReenviarEfetivacaoFIS(4359089);
  ReenviarEfetivacaoFIS(4359144);
  ReenviarEfetivacaoFIS(4359123);
  ReenviarEfetivacaoFIS(4359152);
  ReenviarEfetivacaoFIS(4359160);
  ReenviarEfetivacaoFIS(4359166);
  ReenviarEfetivacaoFIS(4359174);
  ReenviarEfetivacaoFIS(4359175);
  ReenviarEfetivacaoFIS(4359177);
  ReenviarEfetivacaoFIS(4359341);
  ReenviarEfetivacaoFIS(4494843);
  ReenviarEfetivacaoFIS(4359200);
  ReenviarEfetivacaoFIS(4494846);
  ReenviarEfetivacaoFIS(4359222);
  ReenviarEfetivacaoFIS(4359284);
  ReenviarEfetivacaoFIS(4359286);
  ReenviarEfetivacaoFIS(4359370);
  ReenviarEfetivacaoFIS(4490830);
  ReenviarEfetivacaoFIS(4359296);
  ReenviarEfetivacaoFIS(4359303);
  ReenviarEfetivacaoFIS(4359395);
  ReenviarEfetivacaoFIS(4494848);
  ReenviarEfetivacaoFIS(4359347);
  ReenviarEfetivacaoFIS(4359349);
  COMMIT;
end;
0
0
