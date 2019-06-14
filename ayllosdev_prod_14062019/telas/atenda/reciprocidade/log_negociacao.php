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

$idrecipr    = !empty($_POST["idrecipr"]) ? $_POST["idrecipr"] : '';

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <idrecipr>".$idrecipr."</idrecipr>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "CARREGA_LOG_NEGO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    echo "showError('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);";
    
}else{
    
    $registros = $xmlObject->roottag->tags[0]->tags;    
}    

?>

<div id='divRegLogNegociacao'>
    <fieldset id='tabConteudo'>
    <legend><?= utf8ToHtml('Logs da Negociação - '); echo formataNumericos("zzz.zzz.zz9",$idrecipr,"."); ?></legend>

    <div class='divRegistros'>
        <table>
            <thead>
            <tr>
            <th>Data/Hora</th>
            <th>Justificativa</th>
            <th>Status</th>
            <th>Operador</th>
            </tr>

            </thead>
            <tbody>
            <?php foreach ($registros as $r) { ?>

                <tr>
                    <td><?= utf8ToHtml(getByTagName($r->tags, 'dthorlog')); ?></td>
                    <td><?= utf8ToHtml(utf8_encode(getByTagName($r->tags, 'dscdolog'))); ?></td>
                    <td><?= utf8ToHtml(getByTagName($r->tags, 'dsstatus')); ?></td>
                    <td><?= utf8ToHtml(getByTagName($r->tags, 'nmoperad')); ?></td>	
                </tr>

            <?php } ?>

            </tbody>
        </table>

    </div>

    </fieldset>

    <div id="divBotoes">
        <input type="image" src="<? echo $UrlImagens; ?>botoes/fechar.gif" onClick="acessaOpcaoContratos();" id="btnVoltar" />
    </div>

</div>

<script type="text/javascript">

  controlaLayout('frmLogNegociacao');
  $("#divConteudoOpcao").css("display","none");
  $("#divOpcaoIncluiAltera").css("display","none");
  $("#divOpcaoConsulta").css("display","none");
  $("#divLogNegociacao").css('display', 'block');

  blockBackground(parseInt($("#divRotina").css("z-index")));
  
</script>