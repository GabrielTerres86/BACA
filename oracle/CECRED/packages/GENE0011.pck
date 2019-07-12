create or replace package cecred.GENE0011 is

  -- Author  : T0032623 e T0032011 - Maicon Ibrahim Milke, Bruno Cardoso
  -- Created : 07/05/2019 13:37:33
  -- Purpose : Operações referentes aos parâmetros do sistema

  function UsarLimCredParaDebPlanoCotas(pr_cdcooper in crapcop.cdcooper%type) return boolean;
  function UsarLimCredParaDebAplicManual(pr_cdcooper in crapcop.cdcooper%type) return boolean;
  function UsarLimCredParaDebAplicAgend(pr_cdcooper in crapcop.cdcooper%type) return boolean;
  function UsarLimCredParaDebAplicProgram(pr_cdcooper in crapcop.cdcooper%type) return boolean;
end GENE0011;
/
create or replace package body cecred.GENE0011 is

  LIM_CRED_PLANO_COTAS constant crapprm.cdacesso%type := 'LIMITE_APLIC_PLANO_COTAS';
  LIM_CRED_APLIC_MANUAL constant crapprm.cdacesso%type := 'LIMITE_APLIC_MANUAIS';
  LIM_CRED_APLIC_AGENDADA constant crapprm.cdacesso%type := 'LIMITE_APLIC_AGENDADAS';
  LIM_CRED_APLIC_PROGRAMADA constant crapprm.cdacesso%type := 'LIMITE_APLIC_PROGRAMADAS';

  /*
    Função responsável em obter o valor de um parâmetro
  */
  function ObterParametro(pr_cdcooper crapcop.cdcooper%type, pr_nmparam crapprm.cdacesso%type) return crapprm.dsvlrprm%type is
    vr_param crapprm.dsvlrprm%type;
  begin
    select a.dsvlrprm into vr_param
      from crapprm a
     where a.cdcooper = pr_cdcooper
       and a.cdacesso = pr_nmparam;

    return (coalesce(vr_param, ''));
  end;

  function UsarLimCredParaDebPlanoCotas(pr_cdcooper in crapcop.cdcooper%type) return boolean is
  begin
    return (ObterParametro(pr_cdcooper => pr_cdcooper, pr_nmparam => LIM_CRED_PLANO_COTAS) <> 'D');
  end;

  function UsarLimCredParaDebAplicManual(pr_cdcooper in crapcop.cdcooper%type) return boolean is
  begin
    return (ObterParametro(pr_cdcooper => pr_cdcooper, pr_nmparam => LIM_CRED_APLIC_MANUAL) <> 'D');
  end;

  function UsarLimCredParaDebAplicAgend(pr_cdcooper in crapcop.cdcooper%type) return boolean is
  begin
    return (ObterParametro(pr_cdcooper => pr_cdcooper, pr_nmparam => LIM_CRED_APLIC_AGENDADA) <> 'D');
  end;
   function UsarLimCredParaDebAplicProgram(pr_cdcooper in crapcop.cdcooper%type) return boolean is
  begin
    return (ObterParametro(pr_cdcooper => pr_cdcooper, pr_nmparam => LIM_CRED_APLIC_PROGRAMADA) <> 'D');
  end;
end GENE0011;
/
