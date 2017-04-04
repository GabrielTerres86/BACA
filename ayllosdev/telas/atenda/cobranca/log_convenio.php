<?php

/*************************************************************************
	Fonte: log_conveio.php
	Autor: Odirlei Busana - AMcom			Ultima atualizacao: 29/03/2017
	Data : Abril/2016
	
	Objetivo: Apresentar os logs do convenio selecionado .
	
	Alteracoes: 29/03/2017 - Remover validação de permissão (Douglas - Chamado 641296)

*************************************************************************/
session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de funções
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

$nrdconta    = $_POST["nrdconta"];
$inpessoa    = $_POST["inpessoa"];
$nrcnvceb    = $_POST["nrcnvceb"];
$nrconven    = $_POST["nrconven"];

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrcnvceb>".$nrcnvceb."</nrcnvceb>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "CARREGA_LOG_CONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    echo "showError('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);";
    
}else{
    
    $registros = $xmlObject->roottag->tags[0]->tags;    
}    

?>

<div id='divRegLogCeb'>
<fieldset id='tabConteudo'>
<legend><?= utf8ToHtml('Log do Convênio de Cobrança - '); echo formataNumericos("zzz.zzz.zz9",$nrconven,"."); ?></legend>

<div class='divRegistros'>
<table>

<thead>
<tr>
<th>Data/Hora</th>
<th>Descri&ccedil;&atilde;o</th>
<th>Operador</th>
</tr>

</thead>
<tbody>
<?php
foreach ($registros as $r) {


?>

    <tr>
        <td><?= getByTagName($r->tags, 'dthorlog'); ?></td>
        <td><?= getByTagName($r->tags, 'dscdolog'); ?></td>
        <td><?= getByTagName($r->tags, 'nmoperad'); ?></td>	
    </tr>
<?php
}
?>

</tbody>

</table>

</div>

</fieldset>

<div id="divBotoes">
    <input type="image" src="<? echo $UrlImagens; ?>botoes/fechar.gif" onClick="acessaOpcaoAba();" id="btnVoltar" />
</div>

</div>



<script type="text/javascript">

  controlaLayout('frmLogConv');
  $("#divConteudoOpcao").css("display","none");
  $("#divOpcaoIncluiAltera").css("display","none");
  $("#divOpcaoConsulta").css("display","none");
  $("#divLogCeb").css('display', 'block');

  blockBackground(parseInt($("#divRotina").css("z-index")));
  
</script>
