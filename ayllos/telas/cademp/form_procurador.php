<?
/*!
 * FONTE        : form_procurador.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Mostrar tela CADEMP
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

	$cdempres = $_POST["cdempres"];

	$xml = "";
	$xml.= "<Root>";
	$xml.= "  <Cabecalho>";
	$xml.= "	    <Bo>b1wgen0166.p</Bo>";
	$xml.= "        <Proc>Busca_Procuradores_Emp</Proc>";
	$xml.= "  </Cabecalho>";
	$xml.= "  <Dados>";
	$xml.= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml.= "        <cdempres>".$cdempres."</cdempres>";
	$xml.= "  </Dados>";
	$xml.= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	$procurador = $xmlObj->roottag->tags[0]->tags;
?>
<div id="tabProcurador" style="display:block">
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Sel');  ?></th>
					<th><? echo utf8ToHtml('Conta/dv');  ?></th>
					<th><? echo utf8ToHtml('Nome');  ?></th>
					<th><? echo utf8ToHtml('C.P.F.');  ?></th>
					<th><? echo utf8ToHtml('Vigencia');  ?></th>
					<th><? echo utf8ToHtml('Cargo');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($procurador) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="11" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o foram encontrados procuradores dessa empresa.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($procurador); $i++) {
					?>
						<tr>
							<td><span><input type="checkbox" id="chk" name="chk_" value="<? echo getByTagName($procurador[$i]->tags,'nrdctato'); ?>" ></span>
							    <input type="checkbox" id="chk" name="chk_<? echo $i ?>" value="<? echo getByTagName($procurador[$i]->tags,'nrdctato'); ?>" >
							</td>
							<td><span><? echo formataContaDV(getByTagName($procurador[$i]->tags,'nrdctato')); ?></span>
									  <? echo formataContaDV(getByTagName($procurador[$i]->tags,'nrdctato')); ?>
							</td>
							<td><span><? echo getByTagName($procurador[$i]->tags,'nmprimtl'); ?></span>
									  <? echo getByTagName($procurador[$i]->tags,'nmprimtl'); ?>
							</td>
							<td><span><? echo formatar(getByTagName($procurador[$i]->tags,'nrcpfcgc'),'cpf',true); ?></span>
									  <? echo formatar(getByTagName($procurador[$i]->tags,'nrcpfcgc'),'cpf',true); ?>
							</td>
							<td><span><? echo getByTagName($procurador[$i]->tags,'dtvalida') ; ?></span>
									  <? echo getByTagName($procurador[$i]->tags,'dtvalida') ; ?>
							</td>
							<td><span><? echo getByTagName($procurador[$i]->tags,'dsproftl') ; ?></span>
									  <? echo getByTagName($procurador[$i]->tags,'dsproftl') ; ?>
							</td>
						</tr>
					<? } ?>
			<? } ?>
			</tbody>
		</table>
	</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>
			<tr>
				<td>
					<?
						if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
						if ($nriniseq > 1) {
							?> <a class='paginacaoAnt'><<< Anterior</a> <?
						} else {
							?> &nbsp; <?
						}
					?>
				</td>
				<td>
					<?
						if ($nriniseq) {
							?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
					<?  } ?>
				</td>
				<td>
					<?
						if ($qtregist > ($nriniseq + $nrregist - 1)) {
							?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
						} else {
							?> &nbsp; <?
						}
					?>
				</td>
			</tr>
		</table>
	</div>
</div>
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/ok.gif" onClick="selecionaRegistro();"/>
</div>
<br style="clear:both" />
<script type="text/javascript">
	$('#divPesquisaRodape','#divRotina').formataRodapePesquisa();
</script>