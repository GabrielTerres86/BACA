<?

/* 
 * FONTE        : valida_cpf.php
 * CRIAÇÃO      : Gabriel Ramirez
 * DATA CRIAÇÃO : 14/04/2011 
 * OBJETIVO     : Validar os CPF das testemunhas.
 * 
 * ALTERACOES   : 26/07/2011 - Incluir parametro de cobranca registrada
 *							   (Gabriel).
 *
 *				  06/06/2012 - Adicionado confirmacao de impressao em funcao imprimirTermoAdesao() e termo()
 *							   (Jorge).
 *
 *                29/12/2015 - Incluso tratamento para impressão do cancelamento de contrato (Daniel)
*/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

$nrdconta = $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"];
$nmrotina = $_POST["nmrotina"];
$nmdtest1 = $_POST["nmdtest1"];
$cpftest1 = $_POST["cpftest1"];
$nmdtest2 = $_POST["nmdtest2"];
$cpftest2 = $_POST["cpftest2"];
$flgregis = trim($_POST["flgregis"]);


// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0078.p</Bo>';
$xml .= '		<Proc>valida-cpf-testemunhas</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagecxa>0</cdagecxa>';
$xml .= '		<nrdcaixa>0</nrdcaixa>';
$xml .= '		<cdopecxa>'.$glbvars['cdoperad'].'</cdopecxa>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<nmdtest1>'.$nmdtest1.'</nmdtest1>';
$xml .= '		<cpftest1>'.$cpftest1.'</cpftest1>';
$xml .= '		<nmdtest2>'.$nmdtest2.'</nmdtest2>';
$xml .= '		<cpftest2>'.$cpftest2.'</cpftest2>';
$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
$xml .= '		<dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = getDataXML($xml);	
// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
}


if ($nmrotina == "imprimirTermoCancelamento" || $nmrotina == "imprimirTermoCancelamentoProtesto") {
	
	$dsdtitul = "1";
		
	// Da rotina COBRANCA / ATENDA - Cancelamento Convênio
	if ($nmrotina == "imprimirTermoCancelamento") {
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));imprimirTermoAdesao(\"'.$flgregis.'\",\"'.$dsdtitul.'\",\"2\");realizaExclusao();","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));","sim.gif","nao.gif");';
	}
	// Da rotina COBRANCA / ATENDA - Cancelamento Protesto
	else {
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));imprimirTermoAdesao(\"'.$flgregis.'\",\"'.$dsdtitul.'\",\"3\");","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));","sim.gif","nao.gif");';
	}

	
} else {

	// Da rotina COBRANCA / ATENDA 
	if ($nmrotina == "imprimirTermoAdesao") {
		$dsdtitul = "1";
		
		//confirmação para gerar impressao
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));imprimirTermoAdesao(\"'.$flgregis.'\",\"'.$dsdtitul.'\");","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));","sim.gif","nao.gif");';

	}
	// Da rotina DDA / CONTAS
	else { 
		//confirmação para gerar impressao
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","termo(\''.$nmrotina.'\');","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));","sim.gif","nao.gif");';
	}
	
}

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

?>

