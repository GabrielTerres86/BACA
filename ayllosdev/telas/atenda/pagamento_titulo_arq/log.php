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
$xml .= "   <dtiniper>".$dtiniper."</dtiniper>";
$xml .= "   <dtfimper>".$dtfimper."</dtfimper>";
$xml .= "   <nmtabela>".$nmtabela."</nmtabela>";
$xml .= "   <nmdocampo>".$nmdocampo."</nmdocampo>"; 
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PGTA0001", "CONSULTARLOGS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    echo "showError('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);";    
}else{    
    $registros = $xmlObject->roottag->tags[0]->tags;
}    

?>

<div id='divRegLogCeb'>
 <form id="frmLog" name="frmlog">
	<fieldset id='tabConteudo'>

		<legend><?= utf8ToHtml('Log do Convênio'); ?></legend>
        <div>
			<label for="dtiniper"><? echo utf8ToHtml('Data inicial:') ?></label>
            <input name="dtiniper" id="dtiniper" class="campoTelaSemBorda data" value="<?php echo $dtiniper; ?>" />
			<label for="dtfimper"><? echo utf8ToHtml('Data final:') ?></label>
            <input name="dtfimper" id="dtfimper" class="campoTelaSemBorda data" value="<?php echo $dtfimper; ?>" />			
        </div>
		<br/>
		<div class='divRegistros'>
			<table>

				<thead>
					<tr>
						<th>Data/Hora</th>
						<th>Operador</th>
						<th>Programa</th>
						<th>Tipo Manipula&ccedil;&atilde;o</th>
						<th>Tabela</th>
						<th>Campo</th>
						<th>Conteudo anterior</th>
						<th>Conteudo atual</th>						
					</tr>
				</thead>
				
				<tbody>
					<?php
					foreach ($registros as $r) {
					?>
						<tr>
							<td><?= getByTagName($r->tags, 'dhgerlog'); ?></td>
							<td><?= getByTagName($r->tags, 'cdoperad').' - '.getByTagName($r->tags, 'nmoperad'); ?></td>							
							<td><?= getByTagName($r->tags, 'cdprograma'); ?></td>	
							<td><?= getByTagName($r->tags, 'dsmanipulacao'); ?></td>	
							<td><?= getByTagName($r->tags, 'nmtabela'); ?></td>	
							<td><?= getByTagName($r->tags, 'nmdcampo'); ?></td>	
							<td><?= getByTagName($r->tags, 'dsdadant'); ?></td>	
							<td><?= getByTagName($r->tags, 'dsdadatu'); ?></td>	
						</tr>
					<?php
					}
					?>
				</tbody>

			</table>

		</div>

	</fieldset>

	<div id="divBotoes">
		<input type="image" src="<? echo $UrlImagens; ?>botoes/fechar.gif" onClick="acessaOpcaoAba();return false;" id="btnVoltar" />
	</div>
  </form>
</div>



<script type="text/javascript">

  controlaLayout('frmLog');
  $("#divConteudoOpcao").css("display","none");
  $("#divOpcaoIncluiAltera").css("display","none");
  $("#divOpcaoConsulta").css("display","none");
  $("#divLog").css('display', 'block');

  blockBackground(parseInt($("#divRotina").css("z-index")));
  
</script>
