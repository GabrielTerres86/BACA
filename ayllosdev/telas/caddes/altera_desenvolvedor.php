<? 
/*!
 * FONTE        : altera_desenvolvedor.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Alteração de Desenvolvedores.
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	
	
// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A',false)) <> '')
	exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	
$cddesenvolvedor    	= ( ( !empty($_POST['cddesenvolvedor']) )      	? $_POST['cddesenvolvedor']    	  : '' );
$nrdocumento    		= ( ( !empty($_POST['nrdocumento']) )      	    ? $_POST['nrdocumento']    		  : '' );
$dsnome   				= ( ( !empty($_POST['dsnome']) )     		    ? $_POST['dsnome']   			  : '' );
$nrcep_endereco   		= ( ( !empty($_POST['nrcep_endereco']) )   	    ? $_POST['nrcep_endereco'] 		  : '' );
$dsendereco   			= ( ( !empty($_POST['dsendereco']) )   		    ? $_POST['dsendereco'] 			  : '' );
$nrendereco   			= ( ( !empty($_POST['nrendereco']) )   		    ? $_POST['nrendereco'] 			  : '' );
$dscomplemento   		= ( ( !empty($_POST['dscomplemento']) )   		? $_POST['dscomplemento'] 		  : '' );
$dsbairro   			= ( ( !empty($_POST['dsbairro']) )   		    ? $_POST['dsbairro'] 			  : '' );
$dscidade   			= ( ( !empty($_POST['dscidade']) )   		    ? $_POST['dscidade'] 			  : '' );
$dsunidade_federacao    = ( ( !empty($_POST['dsunidade_federacao']) )   ? $_POST['dsunidade_federacao']   : '' );
$dsemail    			= ( ( !empty($_POST['dsemail']) )   			? $_POST['dsemail']   			  : '' );
$nrddd_celular   		= ( ( !empty($_POST['nrddd_celular']) )   	    ? $_POST['nrddd_celular'] 		  : '' );
$nrtelefone_celular   	= ( ( !empty($_POST['nrtelefone_celular']) )    ? $_POST['nrtelefone_celular'] 	  : '' );
$dscontato_celular   	= ( ( !empty($_POST['dscontato_celular']) )     ? $_POST['dscontato_celular'] 	  : '' );
$nrddd_comercial   		= ( ( !empty($_POST['nrddd_comercial']) )       ? $_POST['nrddd_comercial']       : '' );
$nrtelefone_comercial   = ( ( !empty($_POST['nrtelefone_comercial']) )  ? $_POST['nrtelefone_comercial']  : '' );
$dscontato_comercial    = ( ( !empty($_POST['dscontato_comercial']) )   ? $_POST['dscontato_comercial']   : '' );
$inpessoa    			= ( ( !empty($_POST['inpessoa']) )   			? $_POST['inpessoa']   			  : '' );
$dsusuario_portal		= ( ( !empty($_POST['dsusuario_portal']) )   	? $_POST['dsusuario_portal']   	  : '' );

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<cddesenvolvedor>".$cddesenvolvedor."</cddesenvolvedor>";
$xml .= "		<nrdocumento>".preg_replace("/[^0-9]+/", '', $nrdocumento)."</nrdocumento>";
$xml .= "		<dsnome>".utf8_decode($dsnome)."</dsnome>";
$xml .= "		<nrcep_endereco>".str_replace('-','',$nrcep_endereco)."</nrcep_endereco>";
$xml .= "		<dsendereco>".utf8_decode($dsendereco)."</dsendereco>";
$xml .= "		<dsbairro>".utf8_decode($dsbairro)."</dsbairro>";
$xml .= "		<dscidade>".utf8_decode($dscidade)."</dscidade>";
$xml .= "		<dsunidade_federacao>".$dsunidade_federacao."</dsunidade_federacao>";
$xml .= "		<dsemail>".$dsemail."</dsemail>";
$xml .= "		<nrddd_celular>".$nrddd_celular."</nrddd_celular>";
$xml .= "		<nrtelefone_celular>".$nrtelefone_celular."</nrtelefone_celular>";
$xml .= "		<dscontato_celular>".utf8_decode($dscontato_celular)."</dscontato_celular>";
$xml .= "		<nrddd_comercial>".$nrddd_comercial."</nrddd_comercial>";
$xml .= "		<nrtelefone_comercial>".$nrtelefone_comercial."</nrtelefone_comercial>";
$xml .= "		<dscontato_comercial>".utf8_decode($dscontato_comercial)."</dscontato_comercial>";
$xml .= "		<inpessoa>".$inpessoa."</inpessoa>";
$xml .= "		<dscomplemento>".utf8_decode($dscomplemento)."</dscomplemento>";
$xml .= "		<nrendereco>".$nrendereco."</nrendereco>";
$xml .= "		<dsusuario_portal>".$dsusuario_portal."</dsusuario_portal>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "CADDES", "ALTERA_DESENVOLVEDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);
}

$result = $xmlObject->roottag->tags[0];

$cddesenvolvedor = getByTagName($result->tags, "cddesenvolvedor");
$dsfrase = getByTagName($result->tags, "dsfrase");

exibirErro('inform','Desenvolvedor alterado com sucesso.','Alerta - Aimaro','estadoInicial();',false);
