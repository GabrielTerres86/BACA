<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 18/04/2016 
 * OBJETIVO     : Rotina para controlar as operações da tela INTEAS
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
$inarquiv = (isset($_POST['inarquiv'])) ? $_POST['inarquiv'] : "";
$dtiniger = (isset($_POST['dtiniger'])) ? $_POST['dtiniger'] : "";
$dtfimger = (isset($_POST['dtfimger'])) ? $_POST['dtfimger'] : "";

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}

if ( $cddopcao == 'G') {

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tlcdcoop>". $cdcooper ."</tlcdcoop>";
	$xml .= "   <inarquiv>". $inarquiv ."</inarquiv>";
    $xml .= "   <dtiniger>". $dtiniger ."</dtiniger>";
    $xml .= "   <dtfimger>". $dtfimger ."</dtfimger>";
    $xml .= "   <dtmvtolt>". $glbvars["dtmvtolt"] ."</dtmvtolt>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "INTEAS", "GERA_ARQ_INTEAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

}

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibeErroNew($msgErro);
    exit();
}

//$registros = $xmlObj->roottag->tags[0]->tags;


if ( $cddopcao == 'G') {
    
    
	$nmarqlog = $xmlObj->roottag->tags[0]->tags[0]->cdata;
    echo 'showError("inform","Processo de geração dos arquivos inicializado com sucesso, '.
         'processo pode ser acompanhado pelo log \"'.$nmarqlog.'\".","Notifica&ccedil;&atilde;o - Ayllos","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
    
} 

function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
