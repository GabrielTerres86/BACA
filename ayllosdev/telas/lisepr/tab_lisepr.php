<?
/*!
 * FONTE        : tab_lisepr.php
 * CRIAÇÃO      : André Santos / SUPERO				Última alteração: 25/02/2015
 * DATA CRIAÇÃO : 19/07/2013
 * OBJETIVO     : Tabela - tela LISEPR
 * --------------
 * ALTERAÇÕES   :
 *				  05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
 
				  25/02/2015 - Validação e correção da conversão realizada pela SUPERO
							  (Adriano).
 * --------------
 */
?>

<?
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<div id="tabLisepr" style="display:block" >

		<div class="divRegistros">
			<table class="tituloRegistros">
				<thead>
					<tr>
						<th><? echo utf8ToHtml('PA'); ?></th>
						<th><? echo utf8ToHtml('Conta/dv'); ?></th>
						<th><? echo utf8ToHtml('Contrato');  ?></th>
						<th><? echo utf8ToHtml('Data Emp');  ?></th>
						<th><? echo utf8ToHtml('Valor');  ?></th>
						<th><? echo utf8ToHtml('Saldo');  ?></th>
						<th><? echo utf8ToHtml('Linha');  ?></th>
					</tr>
				</thead>
				<tbody>
					<?
					if ( count($emprestimo) == 0 ) {
						$i = 0;
						// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
						?> <tr><tr><td colspan="6" style="font-size:12px; text-align:center;">N&atilde;o foram encontrados registros com os par&acirc;metros informados.</td></tr></tr>
					<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
					} else {
						for ($i = 0; $i < count($emprestimo); $i++) {							 
						?>
							<tr>
								<td><span><? echo getByTagName($emprestimo[$i]->tags,'cdagenci'); ?></span>
										  <? echo getByTagName($emprestimo[$i]->tags,'cdagenci'); ?>
									<input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($emprestimo[$i]->tags,'nmprimtl') ?>" />
									<input type="hidden" id="dtmvtprp" name="dtmvtprp" value="<? echo getByTagName($emprestimo[$i]->tags,'dtmvtprp') ?>" />
									<input type="hidden" id="diaprmed" name="diaprmed" value="<? echo getByTagName($emprestimo[$i]->tags,'diaprmed') ?>" />									
								</td>
								<td><span><? echo formataContaDV(getByTagName($emprestimo[$i]->tags,'nrdconta')); ?></span>
										  <? echo formataContaDV(getByTagName($emprestimo[$i]->tags,'nrdconta')); ?>
								</td>
								<td><span><? echo formataNumericos("zz.zzz.zzz",getByTagName($emprestimo[$i]->tags,'nrctremp'),"."); ?></span>
										  <? echo formataNumericos("zz.zzz.zzz",getByTagName($emprestimo[$i]->tags,'nrctremp'),"."); ?>
								</td>
								<td><span><? echo getByTagName($emprestimo[$i]->tags,'dtmvtolt'); ?></span>
										  <? echo getByTagName($emprestimo[$i]->tags,'dtmvtolt'); ?>
								</td>
								<td><span><? echo $vlemprst?></span>
										  <? echo formataMoeda(getByTagName($emprestimo[$i]->tags,'vlemprst')) ; ?>
								</td>
								<td><span><? echo $vlsdeved?></span>
										  <? echo formataMoeda(getByTagName($emprestimo[$i]->tags,'vlsdeved')) ; ?>
								</td>
								<td><span><? echo getByTagName($emprestimo[$i]->tags,'cdlcremp'); ?></span>
										  <? echo getByTagName($emprestimo[$i]->tags,'cdlcremp'); ?>
								</td>
							</tr>
						<? } ?>
				<? } ?>
				<tr>
					<input type="hidden" id="qtdregis" name="qtdregis" value="<? echo $qtregist; ?>" />
					<input type="hidden" id="totvlrep" name="totvlrep" value="<? echo formataMoeda($vlrtotal); ?>" />
				</tr>
				</tbody>
			</table>
		</div>
		<div id="divPesquisaRodape" class="divPesquisaRodape">
			<table>
				<tr>
					<td>
						<?
							//
							if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;

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
							if ($nriniseq) {
								?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
						<?  } ?>
					</td>
					<td>
						<?
							// Se a paginação não está na ultima página, exibe botão proximo
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
		
		<div id="linha1">
			<ul class="complemento">
				<li><? echo utf8ToHtml('Nome:'); ?></li>
				<li id="nmprimtl"></li>
			</ul>
		</div>
		<div id="linha2">
			<ul class="complemento">
				<li><? echo utf8ToHtml('Data Prog:'); ?></li>
				<li id="dtmvtprp"></li>
				<li><? echo utf8ToHtml('Qtd:'); ?></li>
				<li id="qtdregis"></li>
			</ul>
		</div>
		<div id="linha3">
			<ul class="complemento">
				<li><? echo utf8ToHtml('Prazo Med:'); ?></li>
				<li id="diaprmed"></li>
				<li><? echo utf8ToHtml('Valor TOTAL:'); ?></li>
				<li id="totvlrep"></li>
			</ul>
		</div>
	
</div>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaEmprestimo(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaEmprestimo(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>