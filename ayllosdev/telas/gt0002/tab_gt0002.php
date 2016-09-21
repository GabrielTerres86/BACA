<? 
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod(); 

/*!
 * FONTE        : tab_gt0002.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 19/09/2013
 * OBJETIVO     : Tabela que apresenta os dados dos convenios por cooperativas da tela GT0002
 * --------------
 * ALTERAÇÕES   :
 
 16/05/2016 - #412560 Acentuações faltando e alinhamentos (Carlos)
 
 */	 
?>
<form class="formulario">
	<fieldset>
		<legend>Convênios</legend>
		<div id="divRegistros" class="divRegistros">		
			<table>	
				<thead>
					<tr><th>Coop.</th>
						<th align="left">Nome</th>
						<th>Convênio</th>				
						<th align="left">Nome</th>
						<th>Coop. Domínio</th>
					</tr>			
				</thead>
				<tbody>
					<?
					foreach($registros as $i) {      
				
						// Recebo todos valores em variáveis
						$cdcooper	= getByTagName($i->tags,'cdcooper');
						$nmrescop	= getByTagName($i->tags,'nmrescop');
						$cdconven 	= getByTagName($i->tags,'cdconven');
						$nmempres 	= getByTagName($i->tags,'nmempres');				
						$cdcooped 	= getByTagName($i->tags,'cdcooped');
													
					?>			
						<tr>
							<td><span><? echo $cdcooper ?></span>
								<? echo $cdcooper; ?>
								
								<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($i->tags,'cdcooper') ?>" />
								<input type="hidden" id="nmrescop" name="nmrescop" value="<? echo getByTagName($i->tags,'nmrescop') ?>" />
								<input type="hidden" id="cdconven" name="cdconven" value="<? echo getByTagName($i->tags,'cdconven') ?>" />
								<input type="hidden" id="nmempres" name="nmempres" value="<? echo getByTagName($i->tags,'nmempres') ?>" />

							</td>
												
							<td> <? echo $nmrescop ?> </td>
							<td> <? echo $cdconven ?> </td>
							<td> <? echo $nmempres ?> </td>
							<td> <? echo $cdcooped ?> </td>
																
						</tr>	
					<? } ?>			
				</tbody>
			</table>
			
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
	</fieldset>
</form>

<div id="divBotoes" style="margin-bottom:10px" >
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(2); return false;">Voltar</a>	
</div>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaGt0002(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaGt0002(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>