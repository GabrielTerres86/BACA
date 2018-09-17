<? 
/*!
 * FONTE        : tab_lote.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Tabela que apresenta os dados do tipo da opção lote dos históricos da tela LISLOT
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
<fieldset>	
<div id="teste" class="divRegistros">
	<table>
		<thead>
			<tr><th>Data</th>
				<th>PA</th>
				<th>Conta/Dv.</th>				
				<th>Banco/Caixa</th>
				<th>Lote</th>
				<th>Valor</th>				
				<th>Historico</th>				
			</tr>			
		</thead>
		<tbody>
			<?
			foreach($registroLote as $i) {      
        
				// Recebo todos valores em variáveis
				$dtmvtolt	= getByTagName($i->tags,'dtmvtolt');
				$cdagenci	= getByTagName($i->tags,'cdagenci');
				$nrdconta 	= getByTagName($i->tags,'nrdconta');
				$cdbccxlt 	= getByTagName($i->tags,'cdbccxlt');				
				$nrdolote 	= getByTagName($i->tags,'nrdolote');
				$vllanmto 	= getByTagName($i->tags,'vllanmto');
				$cdhistor 	= getByTagName($i->tags,'cdhistor');
	
											
			?>			
				<tr>
					<td><span><? echo $dtmvtolt ?></span>
						<? echo $dtmvtolt; ?>
						
					    <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo $cdagenci?>" />
						<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta?>" />
						<input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo $cdbccxlt?>" />
						<input type="hidden" id="nrdolote" name="nrdolote" value="<? echo $nrdolote?>" />
						<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo $vllanmto?>" />
						<input type="hidden" id="cdhistor" name="cdhistor" value="<? echo $cdhistor?>" />

					</td>
										
				    <td> <? echo $cdagenci ?> </td>
					
					<td><span><? echo $nrdconta ?></span>
						<? echo mascara($nrdconta,'####.###.#') ?></td>
						
					<td> <? echo $cdbccxlt ?> </td>
					
					<td><span><? echo $nrdolote ?></span>
						<? echo mascara($nrdolote,'###.###') ?></td>
												
					<td><span><? echo converteFloat($vllanmto,'MOEDA') ?></span>
							  <? echo formataMoeda($vllanmto); ?></td>
							  
					<td> <? echo $cdhistor ?> </td>
																		    			    
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