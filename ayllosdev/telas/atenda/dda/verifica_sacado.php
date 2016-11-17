<? 

/* 
 * FONTE        : verifica_sacado.php
 * CRIA��O      : Gabriel Ramirez
 * DATA CRIA��O : 18/04/2011 
 * OBJETIVO     : Verificar a situacao do sacado 
 * 
 * ALTERACOES   : 06/06/2012 - Adicionado confirmacao de impressao em funcao titulosBloqueados()
 *							   (Jorge).
 *				  03/12/2014 - De acordo com a circula 3.656 do Banco Central,
 *							   substituir nomenclaturas Cedente por Benefici�rio e  
 *							   Sacado por Pagador. Chamado 229313 (Jean Reddiga - RKAM)
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


// Monta o xml de requisi��o
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0078.p</Bo>';
$xml .= '		<Proc>verifica-sacado</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagecxa>0</cdagecxa>';
$xml .= '		<nrdcaixa>0</nrdcaixa>';
$xml .= '		<cdopecxa>'.$glbvars['cdoperad'].'</cdopecxa>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = getDataXML($xml);	
// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr�tica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

$flgverif = $xmlObjeto->roottag->tags[0]->attributes["FLGVERIF"];

if ($flgverif == "yes") {
	exibeErro("O titular ainda � pagador eletr�nico.");
}


//confirma��o para gerar impressao
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","titulosBloqueados();","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));","sim.gif","nao.gif");';

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

?>

