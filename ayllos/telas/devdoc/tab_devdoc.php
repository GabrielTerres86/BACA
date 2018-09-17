<?php
/*!
 * FONTE        : tab_devdoc.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 01/03/2014
 * OBJETIVO     : Tabela - tela DEVDOC
 * --------------
 * ALTERAÇÕES   : 22/09/2014 - Inclusão da coluna Ag Fav (Marcos-Supero)
	*				 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
<form action="" method="post" id="frmcheckdocs" name="frmcheckdocs">
<div id="tabDevdoc">
	<p style="text-align:center;height:20px;">Lançamentos do dia <? echo $glbvars['dtmvtoan']; ?></p>
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>Dev</th>
                	<th>Mot</th>
					<th>Doc</th>
					<th>Valor</th>
					<th>Ag Fav</th>
					<th>Cta Fav</th>
					<th>Nome Favorecido</th>
					<th>Situa&ccedil;&atilde;o</th>
					<th>Operador</th>
				</tr>
			</thead>
			<tbody>
				<?
				for ($i = 0; $i < count($devolucoes); $i++) {
					$checked  = "";
					$disabled = "";
					if(getByTagName($devolucoes[$i]->tags,'flgdevol') == "yes" ){
						$checked = "checked='checked'";
					}
					if(getByTagName($devolucoes[$i]->tags,'flgpcctl') == "yes" ){
						$disabled = "disabled='disabled'";
					}
					$chave = getByTagName($devolucoes[$i]->tags,'nrdocmto')."|".
							 getByTagName($devolucoes[$i]->tags,'dtmvtolt')."|".
							 getByTagName($devolucoes[$i]->tags,'vldocmto')."|".
							 getByTagName($devolucoes[$i]->tags,'cdbandoc')."|".
							 getByTagName($devolucoes[$i]->tags,'cdagedoc')."|".
							 getByTagName($devolucoes[$i]->tags,'nrctadoc')."|".
							 getByTagName($devolucoes[$i]->tags,'cdmotdev');
					if(getByTagName($devolucoes[$i]->tags,'flgdevol') == "yes" and getByTagName($devolucoes[$i]->tags,'flgpcctl') == "no"){
						$condicao = "A DEVOLV.";
					}else if(getByTagName($devolucoes[$i]->tags,'flgdevol') == "yes" and getByTagName($devolucoes[$i]->tags,'flgpcctl') == "yes"){
						$condicao = "DEVOLVIDO";
					}else{
						$condicao = "N&Atilde;O DEVO.";
					}
                ?>	<tr id="<?php echo $chave; ?>">
						<td>
							<input type="checkbox" id="chkdevol<? echo $chave; ?>" name="chkdevol<? echo $chave; ?>" <?php echo $checked; ?> <?php echo $disabled; ?> />
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'cdmotdev'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'cdmotdev'); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'nrdocmto');?></span>
								  <? echo getByTagName($devolucoes[$i]->tags,'nrdocmto'); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'vldocmto') ; ?></span>
								  <? echo formataMoeda(getByTagName($devolucoes[$i]->tags,'vldocmto')) ; ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'cdagenci'); ?></span>
							      <? echo formataContaDV(getByTagName($devolucoes[$i]->tags,'cdagenci')); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'nrdconta'); ?></span>
							      <? echo formataContaDV(getByTagName($devolucoes[$i]->tags,'nrdconta')); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'nmfavore'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'nmfavore'); ?>
						</td>
						<td><span><? echo $condicao; ?></span>
							      <? echo $condicao; ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'nmoperad'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'nmoperad'); ?>
						</td>
					</tr>
                <? } ?>
			</tbody>
		</table>
	</div>
</div>
</form>

<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<? 
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
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

<div id="divBotoes">
	<a href="#" class="botao" id="btnContinuar" onclick="btnContinuar(); return false;" ><? echo utf8ToHtml('Salvar'); ?></a>
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		BuscaDevDoc( <? echo "'".($nriniseq - $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		BuscaDevDoc( <? echo "'".($nriniseq + $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>