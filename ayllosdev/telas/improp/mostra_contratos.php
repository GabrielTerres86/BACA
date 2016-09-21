<?
	
	/***********************************************************************
	
	  Fonte: mostra_contratos.php                                               
	  Autor: Gabriel                                                  
	  Data : Novembro/2010                       Última Alteração: 23/07/2013		   
	                                                                   
	  Objetivo  : Mostrar os contratos da tela Improp.              
	                                                                 
	  Alterações: 23/07/2013 - Paginar a tela de 10 em 10 registros (Gabriel) 	  
	              05/09/2013 - Alteração da sigla PAC para PA (Carlos)
	  
	
	***********************************************************************/

	// Contador para verificar a qt de contratos 
	$i = 0;
	
	?>
		
	var strHTML = ''; 
	strHTML += '<div id="divResultado">';
	strHTML += ' <form class="formulario">';
	strHTML += '    <fieldset>';
	strHTML += '    <div class="divRegistros">';
	strHTML	+= '	<table>';
	strHTML += '	<thead>';
	strHTML += '		<tr>';
	strHTML += '			<th> PA </th>';
	strHTML += '			<th> Conta/dv </th>';
	strHTML += '			<th> Opera&ccedil;&atilde;o </th>';
	strHTML += '			<th> Contrato </th>';
	strHTML += '			<th> Valor </th>';
	strHTML += '			<th> Data/Hora </th>';
	strHTML += '			<th> <input name="flgtodas" id="flgtodas" type="checkbox" class="checkbox" value="1" > </th>';
	strHTML += '		</tr>';
	strHTML += '	</thead>';
	strHTML += '	<tbody>';
				<? 
				foreach ( $contratos as $contrato ) { 
				?>
	strHTML += '		<tr>';
	strHTML += '			<td><span><? echo formataNumericos("zz9",getByTagName($contrato->tags,"cdagenci")); ?></span>';
	strHTML += '			          <? echo formataNumericos("zz9",getByTagName($contrato->tags,"cdagenci")); ?>';
	strHTML += '			</td>';
	strHTML += '			<td><span><? echo formataContaDV(getByTagName($contrato->tags,"nrdconta")); ?></span>';
	strHTML += '					  <? echo formataContaDV(getByTagName($contrato->tags,"nrdconta")); ?>';
	strHTML += '			</td>';
	strHTML += '			<td><span><? echo getByTagName($contrato->tags,"dsoperac"); ?></span>';
	strHTML += '					  <? echo getByTagName($contrato->tags,"dsoperac"); ?>';
	strHTML += '			</td>';
	strHTML += '			<td><span><? echo formataNumericos("zz.zzz.zzz",getByTagName($contrato->tags,"nrctrato"),".");  ?></span>';
	strHTML += '					  <? echo formataNumericos("zz.zzz.zzz",getByTagName($contrato->tags,"nrctrato"),".");  ?>';
	strHTML += '			</td>';
	strHTML += '			<td><span><? echo number_format(str_replace(",",".",getByTagName($contrato->tags,"vloperac")),2,",","."); ?></span>';
	strHTML += '					  <? echo number_format(str_replace(",",".",getByTagName($contrato->tags,"vloperac")),2,",","."); ?>';
	strHTML += '			</td>';
	strHTML += '			<td><span><? echo substr(getByTagName($contrato->tags,"dtmvtolt"),0,strpos(getByTagName($contrato->tags,"dtmvtolt"),",")); ?></span>';
	strHTML += '					  <? echo substr(getByTagName($contrato->tags,"dtmvtolt"),0,strpos(getByTagName($contrato->tags,"dtmvtolt"),",")); ?>';
	strHTML += '			</td>';	
	strHTML += '		<td>';
						<?php if ($cddopcao != "C") {  ?>		
	strHTML += '			 <input name= "dsdimpri[]" id= "dsdimpri" type="checkbox" class="checkbox" value="<? echo getByTagName($contrato->tags,'nomedarq'); ?>" >';			
						<?   } ?>
	strHTML += '		</td>';
						<? $i++; ?>				
				<? } ?>						
	strHTML += '	</tr>';
			<?  ?>	
	strHTML += '</tbody>';
	strHTML += '</table>';
	
	strHTML += '<div id="divPesquisaRodape" class="divPesquisaRodape">';
	strHTML += '<table>';	
	strHTML += '<tr>';
	strHTML += '<td>';
	<?
		if (isset($qtregist) && $qtregist == 0) $nriniseq = 0;
				
			if ($nriniseq > 1) { 
	?> 
	strHTML += '<a class="paginacaoAnt"><<< Anterior</a>';
	<? 
		} else {
	?> 
	strHTML += '&nbsp;'; 
	<?
		}
	?>
	strHTML += '</td>';
	strHTML += '<td>';
	<?
		if (isset($nriniseq)) { 
	?> 
	strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? if (( $nriniseq + $nrregist  ) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?> ';
	<?
		}
	?>
	strHTML += '</td>';
	strHTML += '<td>';
	<?
		if ($qtregist > ($nriniseq + $nrregist - 1)) {
	?> 
	strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>';
	<?
		} else {
	?>
	strHTML += '&nbsp;';
	<?
		}
	?>			
	strHTML += '</td>';
	strHTML += '</tr>';
	strHTML += '</table>';
    strHTML += '</div>';
	
	
	strHTML += '</div>';
	strHTML += '</fieldset>';
	strHTML += '</form>';
	strHTML += '</div>';

<?

	echo '$("#divContratos").html(strHTML);';		
	
	echo '$("a.paginacaoProx").unbind("click").bind("click" , function() {
		listaContratos("'. ($nriniseq + $nrregist) .'");		
	});';	
	
	echo '$("a.paginacaoAnt").unbind("click").bind("click", function() {
		listaContratos("'. ($nriniseq - $nrregist) .'");
	});';
	
	echo '$("#divPesquisaRodape","#divTela").formataRodapePesquisa();';
	
?>

