CREATE OR REPLACE FUNCTION CECRED.fn_exibe_epr_ref (  par_tipoemprest    IN crawepr.tpemprst%TYPE
                                                     ,par_qttotalparc    IN crapepr.qtpreemp%TYPE
                                                     ,par_qtparcpag      IN crapepr.qtprepag%TYPE
                                                     ,par_qtparcalcpag   IN crapepr.qtpcalat%TYPE  ) return number is
  vr_return numeric;

  begin
  vr_return :=0;
  --Tratar tipo de emprestimo TR
  if par_tipoemprest = 0 then
       --Verifica se o contrato tem mais de 7 parcelas
       --Se tiver mais de 7 parcelas verifica se as 7 ja foram quitadas
       --Enquanto as 7 parcelas não forem quitadas os valores de Juros+60 refinanciado devem
       --ser exibidos.
      if  (par_qttotalparc > 7) and  (par_qtparcalcpag<7) then
          vr_return:=1;
      end if;

       --Verifica se o contrato tem mais de 7 parcelas
       --Se não tiver mais de 7 parcelas verifica se todas as parcelas foram quitadas
       --Enquanto todas as parcelas não forem quitadas os valores de Juros+60 refinanciado devem
       --ser exibidos.
      if (par_qttotalparc <7) and (par_qttotalparc = par_qtparcalcpag )then
          vr_return:=1;
      end if;
   end if;

   --Tratar tipo de emprestimo PP e PÓS
   if par_tipoemprest > 0 then

       --Verifica se o contrato tem mais de 7 parcelas
       --Se tiver mais de 7 parcelas verifica se as 7 ja foram quitadas
       --Enquanto as 7 parcelas não forem quitadas os valores de Juros+60 refinanciado devem
       --ser exibidos.
      if  (par_qttotalparc > 7) and  (par_qtparcpag<7) then
          vr_return:=1;
       end if;

      --Verifica se o contrato tem mais de 7 parcelas
       --Se não tiver mais de 7 parcelas verifica se todas as parcelas foram quitadas
       --Enquanto todas as parcelas não forem quitadas os valores de Juros+60 refinanciado devem
       --ser exibidos.
       if (par_qttotalparc <7) and (par_qttotalparc = par_qtparcpag )then
          vr_return:=1;
        end if;
   end if;


   RETURN NVL(vr_return,0);

  END fn_exibe_epr_ref;
/
