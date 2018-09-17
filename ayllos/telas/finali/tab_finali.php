<? 
/*!
 * FONTE        : tab_finali.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : 04/08/2015 
 * OBJETIVO     : Tabela que apresenta a consulta FINALI
 * --------------
 * ALTERACOES   : 10/08/2015 - Alterações e correções (Lunelli SD 102123)
 * --------------
 */ 

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');

isPostMethod();	

$cont_id = 0;
	
?>
<div id="tabFinali">
	<div class="divRegistros">	
		<table class="tituloRegistros" id="tbRegLinhaCred">
			<thead>
				<tr>
					<?php				
					if ($cddopcao == "I" || $cddopcao == "D") { ?>
					<th> <input type="checkbox" id="'checkTodos" name="checkTodos"> </th>
					<? } ?>	
					<th><? echo utf8ToHtml('Código'); ?></th>
					<th><? echo utf8ToHtml('Descrição'); ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach ( $registros as $r ) {
				?>
					<tr>					
						<?php				
						if ($cddopcao == "I") {						
						?>
							<td><span>&nbsp;</span>
									  &nbsp;
							</td>
							<script>
								var aux = new Array();
								var i = arrayRegLinha.length;
								aux['cdlcrhab'] = <? echo "'".getByTagName($r->tags, 'cdlcrhab')."'"; ?>;
								arrayRegLinha[i] = aux;
							</script>
						<? }						
						if ($cddopcao == "D") {						
						?>
							<td><input type="checkbox" id="cdsqelcr" name="cdsqelcr[]" value="<? echo $cont_id; ?>" /></td>
							<script>
								var aux = new Array();								
								var i = arrayRegLinha.length;
								aux['cdlcrhab'] = <? echo "'".getByTagName($r->tags, 'cdlcrhab')."'"; ?>;
								arrayRegLinha[i] = aux;
							</script>
						<? 
							$cont_id = $cont_id + 1;
						} ?>
						
						<td><span><? echo getByTagName($r->tags,'cdlcrhab'); ?></span>
							      <? echo getByTagName($r->tags,'cdlcrhab'); ?>
						</td>
						<td><span><? echo trim(getByTagName($r->tags,'dslcremp')); ?></span>
							      <? echo trim(getByTagName($r->tags,'dslcremp')); ?>
						</td>
					</tr>
			<?	} ?>	
			</tbody>
		</table>
	</div>	
</div>

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
			<td id="nrregistros">
				<?
				if (isset($nriniseq)) {
					?> Exibindo <?  echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
				}
				?>
			</td>
			<td>
				<?
				// Se a paginação não está na última página, exibe botão proximo
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

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		ConsultaDados(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		ConsultaDados(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	dsfinemp = <? echo "'".trim($dsfinemp)."'"; ?>;
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>