<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Julho/2017
 * OBJETIVO     : Mostrar opcao Principal da rotina de conta destino para envio de TED capital da tela de MATRIC
 *
 * ALTERACOES   : 
 */
?> 
<?
    session_start();
	
	require_once('../config.php');
	require_once('../funcoes.php');
	require_once('../controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"C")) <> '') {

        exibirErro('error',$msgError,'Alerta - Aimaro','');
    }
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']))  exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Guardo o número da conta e titular em variáveis
	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "CADA0003", "BUSCAR_CONTA_DESTINO_TED_CAPITAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjContaDestino = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjContaDestino->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjContaDestino->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
							
	}
	
	$registro = $xmlObjContaDestino->roottag->tags[0]->tags;	
	$tpoperac = count($registro) == 0 ? 'I' : 'C';
	
?>

<script type="text/javascript">
	
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
			
</script>  
 
<?
	
	include('form_dados.php');
	
?>	
