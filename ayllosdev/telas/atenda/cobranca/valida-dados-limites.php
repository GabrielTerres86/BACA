<?php 

/*************************************************************************
	Fonte: valida-dados-limites.php
	Autor: Gabriel						Ultima atualizacao: 10/05/2013
	Data : Dezembro/2010
	
	Objetivo: Valida os dados da tela de habilitacao.
	
	Alteracoes: 08/09/2011 - Ajuste para chamada da lista ListaNegra
						    (Adriano).
							
				10/05/2013 - Retirado campo de valor maximo do boleto. 
						     vllbolet (Jorge)

*************************************************************************/
session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
	exibeErro($msgError);		
}	

$nrdconta = $_POST["nrdconta"];
$dsorgarq = trim($_POST["dsorgarq"]);
$inarqcbr = $_POST["inarqcbr"];
$cddemail = $_POST["cddemail"];
$flgconti = trim($_POST["flgconti"]);
$titulares = $_POST["titulares"];
$cddopcao = $_POST["cddopcao"];
$vllbolet = 0; // retirado vlr limite

// Monta xml
$xmlValidaDadosLimite  = "";
$xmlValidaDadosLimite .= "<Root>";
$xmlValidaDadosLimite .= " <Cabecalho>";
$xmlValidaDadosLimite .= "  <Bo>b1wgen0082.p</Bo>";
$xmlValidaDadosLimite .= "  <Proc>valida-dados-limites</Proc>";
$xmlValidaDadosLimite .= " </Cabecalho>";
$xmlValidaDadosLimite .= " <Dados>";
$xmlValidaDadosLimite .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlValidaDadosLimite .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlValidaDadosLimite .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlValidaDadosLimite .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; 
$xmlValidaDadosLimite .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlValidaDadosLimite .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";           
$xmlValidaDadosLimite .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlValidaDadosLimite .= "   <idseqttl>1</idseqttl>";  
$xmlValidaDadosLimite .= "   <dsorgarq>".$dsorgarq."</dsorgarq>";
$xmlValidaDadosLimite .= "   <vllbolet>".$vllbolet."</vllbolet>";  
$xmlValidaDadosLimite .= "   <inarqcbr>".$inarqcbr."</inarqcbr>";   
$xmlValidaDadosLimite .= "   <cddemail>".$cddemail."</cddemail>";
$xmlValidaDadosLimite .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlValidaDadosLimite .= " </Dados>";
$xmlValidaDadosLimite .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlValidaDadosLimite);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosCobranca = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDadosCobranca->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosCobranca->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

echo 'hideMsgAguardo();';
 
if ($flgconti == "true") { // Se chama confirmacao 
   echo 'confirmaHabilitacao("'.$cddopcao.'");';
}
else { // Chama titulares 
	echo 'chamaTitulares("H","'.$titulares.'");';
}

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

?>