create or replace package cecred.APLI0009 is

  -- Author  : T0032623 - Maicon Ibrahim Milke e Bruno Cardoso
  -- Created : 07/05/2019 13:37:33
  -- Purpose : Operações referentes aos parâmetros do sistema

  function UsarLimCredParaDebPlanoCotas(pr_cdcooper in crapcop.cdcooper%type)
    return boolean;
  function UsarLimCredParaDebAplicManual(pr_cdcooper in crapcop.cdcooper%type)
    return boolean;
  function UsarLimCredParaDebAplicAgend(pr_cdcooper in crapcop.cdcooper%type)
    return boolean;
  function UsarLimCredParaDebAplicProgram(pr_cdcooper in crapcop.cdcooper%type)
    return boolean;
end APLI0009;



										BODY

create or replace package body cecred.APLI0009 is

  LIM_CRED_PLANO_COTAS      constant crapprm.cdacesso%type := 'LIMITE_APLIC_PLANO_COTAS';
  LIM_CRED_APLIC_MANUAL     constant crapprm.cdacesso%type := 'LIMITE_APLIC_MANUAIS';
  LIM_CRED_APLIC_AGENDADA   constant crapprm.cdacesso%type := 'LIMITE_APLIC_AGENDADAS';
  LIM_CRED_APLIC_PROGRAMADA constant crapprm.cdacesso%type := 'LIMITE_APLIC_PROGRAMADAS';
  NMSISTEM                  constant crapprm.nmsistem%type := 'CRED';

  /*
    Função responsável em obter o valor de um parâmetro
  */

  function UsarLimCredParaDebPlanoCotas(pr_cdcooper in crapcop.cdcooper%type)
    return boolean is
  begin
    return(gene0001.fn_param_sistema(pr_nmsistem => NMSISTEM,
                                     pr_cdcooper => pr_cdcooper,
                                     pr_cdacesso => LIM_CRED_PLANO_COTAS) <> 'D');
  end;

  function UsarLimCredParaDebAplicManual(pr_cdcooper in crapcop.cdcooper%type)
    return boolean is
  begin
    return(gene0001.fn_param_sistema(pr_nmsistem => NMSISTEM,
                                     pr_cdcooper => pr_cdcooper,
                                     pr_cdacesso => LIM_CRED_APLIC_MANUAL) <> 'D');
  end;

  function UsarLimCredParaDebAplicAgend(pr_cdcooper in crapcop.cdcooper%type)
    return boolean is
  begin
    return(gene0001.fn_param_sistema(pr_nmsistem => NMSISTEM,
                                     pr_cdcooper => pr_cdcooper,
                                     pr_cdacesso => LIM_CRED_APLIC_AGENDADA) <> 'D');
  end;
  function UsarLimCredParaDebAplicProgram(pr_cdcooper in crapcop.cdcooper%type)
    return boolean is
  begin
    return(gene0001.fn_param_sistema(pr_nmsistem => NMSISTEM,
                                     pr_cdcooper => pr_cdcooper,
                                     pr_cdacesso => LIM_CRED_APLIC_PROGRAMADA) <> 'D');
  end;
end APLI0009;