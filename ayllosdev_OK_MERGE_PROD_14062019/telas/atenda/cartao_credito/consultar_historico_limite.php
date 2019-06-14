<?php 

	/************************************************************************
	  Fonte: consultar_historico_limite.php
	  Autor: Renato Darosci
	  Data : Agosto/2017                 Última Alteração: --/--/----

	  Objetivo: Mostrar a listagem dos históricos de alteração de limite 

	  Alterações: 

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	/*if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);
	}*/

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcctitg"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcctitg = $_POST["nrcctitg"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se número do cartão é um inteiro valido
	if (!validaInteiro($nrcctitg)) {
		exibeErro("Cart&atilde;o inv&aacute;lido.");
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrcctitg>".$nrcctitg."</nrcctitg>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "HISLIMCRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		exibeErro($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$historico = $xmlObj->roottag->tags[0]->tags[0]->tags;
	$reenvio = (getByTagName($xmlObj->roottag->tags[0]->tags, "reenvio") == "1");

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<div id="divHistorico">
	<div id="divConteudoHistorico">
		<div class="divRegistros">
			<table>
				<thead>
					<tr>
						<th class="hdata">Data da Altera&ccedil;&atilde;o</th>
						<th class='hproposta'>Proposta</th>
						<th class='hsituacao'>Situa&ccedil;&atilde;o</th>
						<th class='htipo'>Tipo</th>
						<th class='hvlant'>Valor Anterior</th>
						<th class='hvlatu'>Valor Atualizado</th>
					</tr>			
				</thead>
				<tbody>
					<?  for ($i = 0; $i < count($historico); $i++) { ?>
						<tr id="<?php echo $i; ?>">
							<td class='data'><?php echo getByTagName($historico[$i]->tags,"DTALTERA"); ?></td>
							<td class='proposta'><?php echo getByTagName($historico[$i]->tags,"NRPROPOSTA_EST"); ?></td>
							<td class='situacao'><?php echo getByTagName($historico[$i]->tags,"SITUACAO"); ?></td>
							<td class='tipo'><?php echo getByTagName($historico[$i]->tags,"DSTIPALT"); ?></td>
							<td class='vlant'><?php echo getByTagName($historico[$i]->tags,"VLLIMOLD"); ?></td>
							<td class='vlatu'><?php echo getByTagName($historico[$i]->tags,"VLLIMNEW"); ?></td>
							
						</tr>				
					<? } ?>			
				</tbody>
			</table>
		</div>
		
		<div id="divBotoes">
			<a href="#" class="botao" id="btvoltar" onClick="voltaDiv(2,1,4,385);return false;">Voltar</a>
			<? if($reenvio) { ?>
			<a href="#" class="botao" id="btreenviar" onClick="validaReenvioAltLimite(<?=$nrcctitg?>);return false;">Reenviar &uacute;ltima proposta</a>
			<? } ?>
		</div>
		
	</div>
</div>
<script type="text/javascript">
	$('#divOpcoesDaOpcao1').css('display','none');
	$('#divOpcoesDaOpcao2').css('display','block');
	
	controlaLayout('divConteudoHistorico');
	
	formatColumn("data",80);
	formatColumn("proposta",80);
	formatColumn("situacao",80);
	formatColumn("tipo",75);
	formatColumn("vlant",115);
	
	function formatColumn(cssclass, size){
		$('.h'+cssclass).css('width',size+'px');
		$('.'+cssclass).css('width',size+'px');
	}
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>
