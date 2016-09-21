<?
/*!
 * FONTE        : form_convenio.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Mostrar tela de convenio tarifario
 * --------------
 * ALTERAÇÕES   : 25/11/2015 - Ajustando tabela para exibir uma mensagem
                               quando nao existir nenhum convênio na lista
							   (Andre Santos - SUPERO)
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

	$xml = "";
	$xml.= "<Root>";
	$xml.= "  <Cabecalho>";
	$xml.= "	    <Bo>b1wgen0166.p</Bo>";
	$xml.= "        <Proc>Busca_Convenios_Tarifarios</Proc>";
	$xml.= "  </Cabecalho>";
	$xml.= "  <Dados>";
	$xml.= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml.= "  </Dados>";
	$xml.= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	$convenio = $xmlObj->roottag->tags[0]->tags;
?>
<div id="tabConvenio" style="display:block">
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conv&ecirc;nio');  ?></th>
					<th><? echo utf8ToHtml('C&oacute;digo');  ?></th>
					<th><? echo utf8ToHtml('D 0');  ?></th>
					<th><? echo utf8ToHtml('D-1');  ?></th>
					<th><? echo utf8ToHtml('D-2');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($convenio) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="5" >
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o foram encontrados registros de conv&ecirc;nio tarif&aacute;rios.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($convenio); $i++) {
					?>
						<tr>
							<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
								<input type="hidden" id="dscontar" name="dscontar" value="<? echo getByTagName($convenio[$i]->tags,'dscontar') ?>" />
								<input type="hidden" id="cdcontar" name="cdcontar" value="<? echo getByTagName($convenio[$i]->tags,'cdcontar') ?>" />
								<span><? echo getByTagName($convenio[$i]->tags,'dscontar'); ?></span>
									  <? echo getByTagName($convenio[$i]->tags,'dscontar'); ?>
							</td>
							<td><span><? echo getByTagName($convenio[$i]->tags,'cdcontar'); ?></span>
									  <? echo getByTagName($convenio[$i]->tags,'cdcontar'); ?>
							</td>
							<td><span><? echo formataMoeda(getByTagName($convenio[$i]->tags,'vltarid0')) ; ?></span>
									  <? echo formataMoeda(getByTagName($convenio[$i]->tags,'vltarid0')) ; ?>
							</td>
							<td><span><? echo formataMoeda(getByTagName($convenio[$i]->tags,'vltarid1')) ; ?></span>
									  <? echo formataMoeda(getByTagName($convenio[$i]->tags,'vltarid1')) ; ?>
							</td>
							<td><span><? echo formataMoeda(getByTagName($convenio[$i]->tags,'vltarid2')) ; ?></span>
									  <? echo formataMoeda(getByTagName($convenio[$i]->tags,'vltarid2')) ; ?>
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
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;"/>
</div>
<br style="clear:both" />
<script type="text/javascript">
	$('#divPesquisaRodape','#divRotina').formataRodapePesquisa();
</script>