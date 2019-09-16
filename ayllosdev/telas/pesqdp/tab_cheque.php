<? 
/*!
 * FONTE        : tab_cheque.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Tabela que apresenta os cheques da tela PESQDP
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 *				  16/06/2014 - Adicionado campo "Age.Dst." na tabela de cheques. (Reinert)
 *				  26/08/2015 - Ajuste no formato da conta do cheque. SD 300189 (Kelvin)
 *				  30/05/2019 - Adicionado campo vlacerto via buscaSumLncChq P565 (Jackson Barcellos AMcom)
 * --------------
 */	

function buscaSumLncChq($glbvars,$nrdconta,$nrdocmto){
	$ret  = 0;
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "CHEQUE", "SUMLNCCHQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjeto 	= getObjectXML($xmlResult);		

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$ret = "";
	} 
		
	$ret = $xmlObjeto->roottag->tags[0]->cdata;

	return $ret;
}
 
?>
<form id="frmTabela" class="formulario" >
	<fieldset id="fsetCheques">
	<legend>Cheques</legend>
	<div id="teste" class="divRegistros">
		<table>
			<thead>
				<tr><th>Banco</th>					
					<th>PA</th>
					<th>Age.Dst.</th>
					<th>Conta/DV</th>
					<th>Cheque</th>
					<th>Valor</th>				
				</tr>			
			</thead>
			<tbody>
				<?
				foreach($registros as $i) {      
			
					// Recebo todos valores em variáveis
					
					if ($tipocons)
					  {	$nmresbcc = getByTagName($i->tags,'nmresbcc'); }
					else{ $nmresbcc = getByTagName($i->tags,'nmextbcc'); }
					   					
					$cdagenci	= getByTagName($i->tags,'cdagenci');
					$cdagedst	= getByTagName($i->tags,'cdagedst');
					$nrdconta 	= getByTagName($i->tags,'nrdconta');
					$nrcheque	= getByTagName($i->tags,'nrcheque');
					$nrdocmto	= getByTagName($i->tags,'nrdocmto');
					$vlcheque	= getByTagName($i->tags,'vlcheque');
					$nrddigc3	= getByTagName($i->tags,'nrddigc3');					
												
				?>			
					<tr>
																								
						<td><span><? echo $nmresbcc ?></span>
						<? echo substr($nmresbcc,0,30) ?></td>						
						<td> <? echo $cdagenci ?> </td>
						<td> <? echo $cdagedst ?> </td>
						<td><span><? echo $nrdconta ?></span>
						<? echo mascara($nrdconta,'####.###.#') ?></td>
						<td> <span><? echo $nrcheque ?> </span>
							<? echo mascara($nrcheque,'###.###') ?></td>				    
						<td><span><? echo converteFloat($vlcheque,'MOEDA') ?></span>
								  <? echo formataMoeda($vlcheque) ?></td>

						<input type="hidden" id="cdagechq" name="cdagechq" value="<? echo getByTagName($i->tags,'cdagechq') ?>" />
						<input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($i->tags,'cdbccxlt') ?>" /><input type="hidden" id="nrdigchq" name="nrdigchq" value="<? echo getByTagName($i->tags,'nrdigchq') ?>" />
						<input type="hidden" id="nrddigc3" name="nrddigc3" value="<? echo $nrddigc3 ?>" />						
						<input type="hidden" id="dsdocmc7" name="dsdocmc7" value="<? echo getByTagName($i->tags,'dsdocmc7') ?>" />
						<input type="hidden" id="nrcheque" name="nrcheque" value="<? echo mascara($nrcheque,'###.###')      ?>" />
						<input type="hidden" id="nrctachq" name="nrctachq" value="<? echo mascara(getByTagName($i->tags,'nrctachq'),'###.###.###.#')   ?>" />
						<input type="hidden" id="vlcheque" name="vlcheque" value="<? echo formataMoeda($vlcheque)           ?>" />
						<input type="hidden" id="cdcmpchq" name="cdcmpchq" value="<? echo getByTagName($i->tags,'cdcmpchq') ?>" />
						<input type="hidden" id="dsbccxlt" name="dsbccxlt" value="<? echo getByTagName($i->tags,'dsbccxlt') ?>" />
						<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo mascara(getByTagName($i->tags,'nrdconta'),'####.###.#') ?>" />
						<input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($i->tags,'nmprimtl') ?>" />
						<input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($i->tags,'cdagenci') ?>" />
						<input type="hidden" id="nmextage" name="nmextage" value="<? echo getByTagName($i->tags,'nmextage') ?>" />
						
						<? 
							$aux = buscaSumLncChq($glbvars,$nrdconta,$nrcheque.$nrddigc3); 
							if ($aux == 0){
								$aux = buscaSumLncChq($glbvars,$nrdconta,$nrcheque); 
							}
						?>
						<input type="hidden" id="vlacerto" name="vlacerto" value="<? echo $aux; ?>" />
								  
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
		buscaCheque(<? echo "'".($nriniseq - $nrregist)."'"?>,2);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaCheque(<? echo "'".($nriniseq + $nrregist)."'"?>,2);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>