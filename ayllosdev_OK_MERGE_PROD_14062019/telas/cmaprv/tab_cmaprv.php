<?
/*!
 * FONTE        : cmaprv.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 29/09/2011
 * OBJETIVO     : Mostrar tela a tabela CMAPRV
 * --------------
 * ALTERAÇÕES   : 14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *				  
				  30/12/2014 - Padronizando a mascara do campo nrctremp.
							   10 Digitos - Campos usados apenas para visualização
							    8 Digitos - Campos usados para alterar ou incluir novos contratos
							   (Kelvin - SD 233714)
				 
                  16/03/2015 - Incluir novo campo Parecer de Credito (Jonata-RKAM) 				 
 * --------------
 */
?>
<div id="tabCmaprv">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Emprestado');  ?></th>
					<th><? echo utf8ToHtml('Linha Cred.');  ?></th>
					<th><? echo utf8ToHtml('Finalid.');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdagenci') ?></span>
								  <? echo getByTagName($r->tags,'cdagenci') ?>
								  <input type="hidden" id="qtpreemp" name="qtpreemp" value="<? echo getByTagName($r->tags,'qtpreemp') ?>" />								  
								  <input type="hidden" id="vlpreemp" name="vlpreemp" value="<? echo formataMoeda(getByTagName($r->tags,'vlpreemp')) ?>" />								  
								  <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($r->tags,'dtmvtolt') ?>" />								  
								  <input type="hidden" id="insitapv" name="insitapv" value="<? echo getByTagName($r->tags,'insitapv') ?>" />								  
								  <input type="hidden" id="cdopeap1" name="cdopeap1" value="<? echo getByTagName($r->tags,'cdopeapv') ?>-<? echo stringTabela(getByTagName($r->tags,'nmoperad'),18,'maiuscula') ?>" />								  
								  <input type="hidden" id="dtaprov1" name="dtaprov1" value="<? echo getByTagName($r->tags,'dtaprova') ?>" />								  
								  <input type="hidden" id="hrtransa" name="hrtransa" value="<? echo getByTagName($r->tags,'hrtransf') ?>" />								  
								  <input type="hidden" id="dsobscmt" name="dsobscmt" value="<? echo str_ireplace("'"," ",getByTagName($r->tags,'dsobscmt')) ?>" />								  
								  <input type="hidden" id="dsaprova" name="dsaprova" value="<? echo getByTagName($r->tags,'insitapv') ?>-<? echo getByTagName($r->tags,'dsaprova') ?>" />								  
								  <input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($r->tags,'nrdconta') ?>" />								  
								  <input type="hidden" id="nrctremp" name="nrctremp" value="<? echo getByTagName($r->tags,'nrctremp') ?>" />								  
								  <input type="hidden" id="nrctrliq" name="nrctrliq" value="<? echo getByTagName($r->tags,'nrctrliq') ?>" />								  
								  <input type="hidden" id="vlemprst" name="vlemprst" value="<? echo getByTagName($r->tags,'vlemprst') ?>" />
								  <? if (getByTagName($r->tags,'instatus') > 0) {  ?>
								  	<input type="hidden" id="instatus" name="instatus" value="<? echo getByTagName($r->tags,'instatus') ?>" />
									<input type="hidden" id="dsstatus" name="dsstatus" value="<? echo getByTagName($r->tags,'dsstatus') ?>" />
								  <? } ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
								  <? echo getByTagName($r->tags,'dtmvtolt') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
								  <? echo formataContaDV(getByTagName($r->tags,'nrdconta')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctremp') ?></span>
								  <? echo mascara(getByTagName($r->tags,'nrctremp'),'#.###.###.###') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlemprst') ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vlemprst')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdlcremp') ?></span>
								  <? echo getByTagName($r->tags,'cdlcremp') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdfinemp') ?></span>
								  <? echo getByTagName($r->tags,'cdfinemp') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					
					//
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

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>