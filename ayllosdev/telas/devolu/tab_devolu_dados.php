<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Tabela - tela DEVOLU
 * --------------
 * ALTERAÇÕES   :
 *
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

<fieldset id="Informacoes">

<div id="tabDevoluDados" style="display:none" >
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Bco');      ?></th>
					<th><? echo utf8ToHtml('Age');      ?></th>
					<th><? echo utf8ToHtml('Conta/dv'); ?></th>
					<th><? echo utf8ToHtml('Cheque');   ?></th>
					<th><? echo utf8ToHtml('Valor');    ?></th>
					<th><? echo utf8ToHtml('Alinea');   ?></th>
					<th><? echo utf8ToHtml('Situação'); ?></th>
					<th><? echo utf8ToHtml('Operador'); ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				for ($i = 0; $i < count($devolucoes); $i++) {
                ?>
					<tr>
                        <td><span><? echo getByTagName($devolucoes[$i]->tags,'cdbccxlt'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'cdbccxlt'); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'cdagechq'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'cdagechq'); ?>
						</td>
						<td><span><? echo formataContaDV(getByTagName($devolucoes[$i]->tags,'nrdconta')); ?></span>
							      <? echo formataContaDV(getByTagName($devolucoes[$i]->tags,'nrdconta')); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'nrcheque'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'nrcheque'); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'vllanmto') ; ?></span>
								  <? echo formataMoeda(getByTagName($devolucoes[$i]->tags,'vllanmto')) ; ?>
						</td>
                        <td><span><? echo getByTagName($devolucoes[$i]->tags,'cdalinea'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'cdalinea'); ?>
						</td>
                        <td><span><? echo getByTagName($devolucoes[$i]->tags,'dssituac');?></span>
								  <? echo getByTagName($devolucoes[$i]->tags,'dssituac'); ?>
						</td>
                        <td><span><? echo getByTagName($devolucoes[$i]->tags,'nmoperad'); ?></span>
							      <? echo getByTagName($devolucoes[$i]->tags,'nmoperad'); ?>
						</td>
					</tr>
                <? } ?>
            </tbody>
		</table>
	</div>
	
	<div id="divRegistrosRodape" class="divRegistrosRodape">	
		<table>	
			<tr>
				<td>
					<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
					<? if ($nriniseq > 1){ ?>
						   <a class="paginacaoAnt"><<< Anterior</a>
					<? }else{ ?>
							&nbsp;
					<? } ?>
				</td>
				<td>
					<? if (isset($nriniseq)) { ?>
						   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
					<? } ?>
				</td>
				<td>
					<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
						  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
					<? }else{ ?>
							&nbsp;
					<? } ?>
				</td>
			</tr>
		</table>
	</div>	
	
</div>

</fieldset>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		BuscaDevolu(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		BuscaDevolu(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistrosRodape','#tabDevoluDados').formataRodapePesquisa();
	
//	formataFormularios();
//	controlaLayout("1");		
			
</script>