<?php
/*************************************************************************
  Fonte: desconto_convenio.php
  Autor: Fabio Stein (Supero)       Ultima atualizacao: 
  Data : Julho/2018
  
  Objetivo: Listar os convenios para desconto de reciprocidade.
  
  Alteracoes: 

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


// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");  

$ls_nrconvenio = ( (!empty($_POST['convenios'])) ? $_POST['convenios'] : '' );
$qtboletos_liquidados = ( (!empty($_POST['boletos_liquidados'])) ? $_POST['boletos_liquidados'] : 0 );
$vlliquidados = ( (!empty($_POST['volume_liquidacao'])) ? $_POST['volume_liquidacao'] : 0 );
$idfloating = ( (isset($_POST['qtdfloat'])) ? $_POST['qtdfloat'] : '');
$idvinculacao = ( (!empty($_POST['idvinculacao'])) ? $_POST['idvinculacao'] : 0 );
$vlaplicacoes = ( (!empty($_POST['vlaplicacoes'])) ? $_POST['vlaplicacoes'] : 0 );
$vldeposito = ( (!empty($_POST['vldeposito'])) ? $_POST['vldeposito'] : 0 );
$idcoo = ( (!empty($_POST['idcoo'])) ? $_POST['idcoo'] : 0 );
$idcee = ( (!empty($_POST['idcee'])) ? $_POST['idcee'] : 0 );

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
  echo 'hideMsgAguardo();';
  echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
  exit;
}

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <ls_nrconvenio>".implode(",", $ls_nrconvenio)."</ls_nrconvenio>";
$xml .= "   <qtboletos_liquidados>".converteFloat($qtboletos_liquidados)."</qtboletos_liquidados>";
$xml .= "   <vlliquidados>".converteFloat($vlliquidados)."</vlliquidados>";
$xml .= "   <idfloating>".$idfloating."</idfloating>";
$xml .= "   <idvinculacao>".$idvinculacao."</idvinculacao>";
$xml .= "   <vlaplicacoes>".converteFloat($vlaplicacoes)."</vlaplicacoes>";
$xml .= "   <vldeposito>".converteFloat($vldeposito)."</vldeposito>";
$xml .= "   <idcoo>".$idcoo."</idcoo>";
$xml .= "   <idcee>".$idcee."</idcee>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "SIMCRP", "CALCULA_RECIPROCIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
//print_r($xmlObject);

if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
  exibeErro($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

$result = $xmlObject->roottag->tags[0]->tags[0]->tags;

$vldesconto_cee =  getByTagName($result,'VLDESCONTO_CEE');
$vldesconto_coo =  getByTagName($result,'VLDESCONTO_COO');

$vldesconto_cee = floatval(str_replace(',', '.', $vldesconto_cee))*100;
$vldesconto_coo = floatval(str_replace(',', '.', $vldesconto_coo))*100;

echo 'hideMsgAguardo();';
echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
echo "$('#vldescontoconcedido_cee', '.tabelaDesconto').val('".number_format($vldesconto_cee, 2, ',', '.')."');";
echo "$('#vldescontoconcedido_coo', '.tabelaDesconto').val('".number_format($vldesconto_coo, 2, ',', '.')."');";
