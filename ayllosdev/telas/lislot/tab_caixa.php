<? 
/*!
 * FONTE        : tab_caixa.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Tabela que apresenta os dados do tipo de opção Caixa dos históricos da tela LISLOT
 *
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
<form id="frmTabela" class="formulario" >
<fieldset id="fsetCheques">	
<div id="teste" class="divRegistros">
	<table>
		<thead>
			<tr><th>Data</th>
				<th>PA</th>
				<th>Caixa</th>				
				<th>Documento</th>
				<th>Valor</th>				
			</tr>			
		</thead>
		<tbody>
			<?
			foreach($registroCaixa as $i) {      
        
				// Recebo todos valores em variáveis
				$dtmvtolt	= getByTagName($i->tags,'dtmvtolt');
				$cdagenci	= getByTagName($i->tags,'cdagenci');
				$nrdcaixa 	= getByTagName($i->tags,'nrdcaixa');			
				$nrdocmto 	= getByTagName($i->tags,'nrdocmto');
				$vldocmto 	= getByTagName($i->tags,'vldocmto');
															
			?>			
				<tr>
					<td><span><? echo $dtmvtolt ?></span>
						<? echo $dtmvtolt; ?>
						
					    <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo $cdagenci?>" />
						<input type="hidden" id="nrdcaixa" name="nrdcaixa" value="<? echo $nrdcaixa?>" />
						<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo $nrdocmto?>" />
						<input type="hidden" id="vldocmto" name="vldocmto" value="<? echo $vldocmto?>" />

					</td>
										
				    <td> <? echo $cdagenci ?> </td>
					<td> <? echo $nrdcaixa ?> </td>
					
					<td><span><? echo $nrdocmto ?></span>
						<? echo mascara($nrdocmto,'###.###.###.###.###') ?> </td>
									
					<td><span><? echo converteFloat($vldocmto,'MOEDA') ?></span>
							  <? echo formataMoeda($vldocmto); ?></td>
																		    			    
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

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaLislot(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaLislot(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>