<? 
/*!
 * FONTE        : cadastra_desenvolvedor.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Cadastro de Desenvolvedores.
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	
	
// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I',false)) <> '')
	exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
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
$isPlataformaAPI     	= ((  !empty($_POST['isPlataformaAPI']) )		? $_POST['isPlataformaAPI']   	  : 0 );


// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
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
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "CADDES", "CADASTRA_DESENVOLVEDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);
}

$result = $xmlObject->roottag->tags[0];

$cddesenvolvedor = getByTagName($result->tags, "cddesenvolvedor");
$dsfrase = getByTagName($result->tags, "dsfrase");
$dsuuid = getByTagName($result->tags, "dsuuid");

if ($isPlataformaAPI == 0){
	exibirErro('inform','Desenvolvedor cadastrado com sucesso.','Alerta - Aimaro','carregaFormFraseDesenvolvedor(\''.$dsfrase.'\', '.$cddesenvolvedor.', \''.$dsuuid.'\');$(\'.divBotoesPrincipal\').remove();controlaLayout(\'ID\');',false);
}else{
	$retorno = "parent.retornoCadastroDesenvolvedor('cddesenvolvedor;".$cddesenvolvedor."|nrtelefone;".$nrtelefone_celular."|dscontato;".utf8_decode($dscontato_celular)."|dsemail;".$dsemail."|nrdocumento;".$nrdocumento."|dsempresa;".utf8_decode($dsnome)."');";
	exibirErro('inform','Desenvolvedor cadastrado com sucesso.','Alerta - Aimaro',$retorno,false);
}