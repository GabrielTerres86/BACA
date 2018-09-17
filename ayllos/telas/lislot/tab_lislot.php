<? 
/*!
 * FONTE        : tab_lislot.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Tabela que apresenta os dados dos históricos da tela LISLOT
 *
 *				  05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
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
				<th>Conta</th>				
				<th>Titular</th>
				<th>Documento</th>
				<th>Valor</th>				
			</tr>			
		</thead>
		<tbody>
			<?
			foreach($registros as $i) {      
        
				// Recebo todos valores em variáveis
				$dtmvtolt	= getByTagName($i->tags,'dtmvtolt');
				$cdagenci	= getByTagName($i->tags,'cdagenci');
				$nrdconta 	= getByTagName($i->tags,'nrdconta');
				$nmprimtl 	= getByTagName($i->tags,'nmprimtl');				
				$nrdocmto 	= getByTagName($i->tags,'nrdocmto');
				$vllanmto 	= getByTagName($i->tags,'vllanmto');
															
			?>			
				<tr>
					<td><span><? echo $dtmvtolt ?></span>
						<? echo $dtmvtolt; ?>
						
					    <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo $cdagenci?>" />
						<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta?>" />
						<input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo $nmprimtl?>" />
						<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo $nrdocmto?>" />
						<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo $vllanmto?>" />

					</td>
										
				    <td> <? echo $cdagenci ?> </td>
					
					<td><span><? echo $nrdconta ?></span>
						<? echo mascara($nrdconta,'####.###.#') ?></td>
						
					<td> <? echo $nmprimtl ?> </td>
					
					<td><span><? echo $nrdocmto ?></span>
						<? echo mascara($nrdocmto,'###.###.###.###.###') ?> </td>
									
					<td><span><? echo converteFloat($vllanmto,'MOEDA') ?></span>
							  <? echo formataMoeda($vllanmto); ?></td>
																		    			    
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