<? 
/***************************************************************************************
 * FONTE        : solicita_senha_autorizacao.php				Última alteração: --/--/----
 * CRIAÇÃO      : Anderson-Alan (Supero)
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Solicita senha do cooperado ou do Supervisor para seguir fluxo 
                  sem necessidade do cooperado estar presente no PA.
 
   Alterações   : 
  
 
 **************************************************************************************/

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	$contrato    = (isset($_POST['contrato'])) ? $_POST['contrato'] : 'null';
	$cdForm      = (isset($_POST['cdForm'])) ? $_POST['cdForm'] : 'novo';

?>

<div id="divBotoesSenha">
    <br />
    <br />
    <? if ($cdForm == 'novo') { ?>
    <a href="#" class="botao" id="btnSenhaCooperado" onClick="solicitaSenha(<? echo $contrato; ?>, cTipoSenha.COOPERADO);">Senha do Cooperado</a>
	<? } ?>
    <a href="#" class="botao" id="btnSenhaSupervisor" onClick="solicitaSenha(<? echo $contrato; ?>, cTipoSenha.SUPERVISOR);">Senha do Supervisor</a>
    <? if ($cdForm == 'continuar') { ?>
    <a href="#" class="botao" id="btnSenhaSupervisor" onClick="solicitaSenha(<? echo $contrato; ?>, cTipoSenha.OPERADOR);">Senha do Operador</a>
    <? } ?>
    <br />
    <br />
</div>
<div id="divValidaSenha"></div>