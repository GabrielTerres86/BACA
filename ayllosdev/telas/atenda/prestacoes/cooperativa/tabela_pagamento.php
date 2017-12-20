<? 
/*!
 * FONTE        : tabela_pagamento.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 23/08/2011
 * OBJETIVO     : Tabela que apresenta as parcelas para antecipar o pagamento
 
   ALTERACOES   : 16/02/2012 - Pagar parcela uma de cada vez,
							   somente a primeira ou ultima disponiveis. (Gabriel)
							   
				  22/02/2013 - Mostrar desconto parcial quando adiantamento (Gabriel); 		

				  11/06/2013 - 2a. fase do Projeto de Credito (Gabriel).
				  
				  04/04/2014 - Esconder o campo Valor a Pagar, chamado: 145232 (James).
				  
				  05/06/2014 - Incluir a opcao de pagamento de avalista. (James)
				  
				  27/06/2014 - Inclusão do formulario frmAntecipapgto para tratar 
							   geração do relatorio de antecipação. (Odirlei/AMcom)

				  05/10/2017 - Inclusão da coluna para demonstrar valor do IOF em 
				  			atraso (Diogo - MoutS - Projeto 410 - RF 30)
 */
 
?>
<div id="divVlPagar "align="right">
	<form id="frmVlPagar" name="frmVlPagar">
		<label for="vlpagmto"><!--Valor a Pagar:-->&nbsp;</label><input type="hidden" id="vlpagmto" name="vlpagmto"/></br>
	</form>
</div>
<div id="divTabela">	
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>			
					<th> <input type="checkbox" id="'checkTodos" name="checkTodos"> </th>
    				<th><label for="nrparepr" class="txtNormalBold">Nr. Parc.</label></th>
					<th><label for="dtvencto" class="txtNormalBold">Dt. Venc.</label></th>
					<th><label for="vlparepr" class="txtNormalBold">Vl. Parc.</label></th>
					<th><label for="vlpagpar" class="txtNormalBold">Vl. Pago</label></th>
					<th><label for="vlmtapar" class="txtNormalBold">Multa</label></th>
					<th><label for="vljinpar" class="txtNormalBold">Jr. Normais</label></th>
					<th><label for="vlmrapar" class="txtNormalBold">Jr. Mora</label></th>
					<!--<th><label for="vliofcpl" class="txtNormalBold">IOF Atraso</label></th>-->
					<th><label for="vldespar" class="txtNormalBold">Desc.</label></th>
					<th><label for="vlatupar" class="txtNormalBold">Vl. Atual</label></th>
					<th style="width:96px;"><label for="vlpagpar" class="txtNormalBold" >Vl. a Pagar</label></th>
				
					
				</tr>
			</thead>
			<tbody>
				<? 
					$parcela = 1; 
					$vlatupar = 0.00;
					$total = count($prestacoes);
					foreach($prestacoes as $registro ) {
					
						$vlparepr = number_format(str_replace(",",".",getByTagName($registro->tags,'vlparepr')),2,",",".");
						$vlatupar = number_format(str_replace(",",".",getByTagName($registro->tags,'vlatupar')),2,",",".");
						$nrparepr = getByTagName($registro->tags,'nrparepr');
						$flgantec = getByTagName($registro->tags,'flgantec');
				?>
					<tr>		
						<td>  						
							<input type="checkbox" id="check_<? echo $nrparepr;  ?>" name="checkParcelas[]"  > 
						</td>						
						<td><? echo $nrparepr; ?></td>
						<td><? echo getByTagName($registro->tags,'dtvencto'); ?></td>
						<td><? echo $vlparepr; ?></td>
						<td><? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vlpagpar')),2,",","."); ?></td>
						<td><? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vlmtapar')),2,",","."); ?></td>
						<td><? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vljinpar')),2,",","."); ?></td>
						<td><? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vlmrapar')),2,",","."); ?></td>
						<!--<td>< echo number_format(floatval(str_replace(",",".",getByTagName($registro->tags,'vliofcpl'))),2,",","."); ?></td>-->
						<td id="vldespar_<? echo $nrparepr; ?>" ><? echo  "0,00"; /*number_format(str_replace(",",".",getByTagName($registro->tags,'vldespar')),2,",","."); */  ?></td>
						<td><? echo $vlatupar; ?></td>			
						<td style="width:70px;"><input type="text" id="vlpagpar_<? echo $nrparepr; ?>" name="vlpagpar[]" size="10" onblur="verificaDesconto( $(this) , '<? echo $flgantec; ?>' , <? echo $nrparepr; ?>); return false;" value = "<? echo number_format(0); ?>" >
									
						<? /*if ($flgantec == 'yes')*/ { ?>						
							<td style="width:10px;"><input type="image" id="btDesconto" src="<?php echo $UrlImagens; ?>geral/refresh.png" onClick="desconto(<? echo $nrparepr ?> ); return false;" /> </td>
						<? } ?>
						
						<input type="hidden" id="vlmtapar_<? echo $nrparepr; ?>" name="vlmtapar[]" value="<? echo getByTagName($registro->tags,'vlmtapar'); ?>">
						<input type="hidden" id="vlmrapar_<? echo $nrparepr; ?>" name="vlmrapar[]" value="<? echo getByTagName($registro->tags,'vlmrapar'); ?>">
						<input type="hidden" id="vliofcpl_<? echo $nrparepr; ?>" name="vliofcpl[]" value="<? echo getByTagName($registro->tags,'vliofcpl'); ?>">
						<input type="hidden" id="vlatupar_<? echo $nrparepr; ?>" name="vlatupar[]" value="<? echo $vlatupar; ?>">
						<input type="hidden" id="cdcooper_<? echo $nrparepr; ?>" name="cdcooper[]" value="<? echo getByTagName($registro->tags,'cdcooper'); ?>">
						<input type="hidden" id="nrdconta_<? echo $nrparepr; ?>" name="nrdconta[]" value="<? echo getByTagName($registro->tags,'nrdconta'); ?>">
						<input type="hidden" id="nrctremp_<? echo $nrparepr; ?>" name="nrctremp[]" value="<? echo getByTagName($registro->tags,'nrctremp'); ?>">
						<input type="hidden" id="nrparepr_<? echo $nrparepr; ?>" name="nrparepr[]" value="<? echo $nrparepr; ?>">
						<input type="hidden" id="parcela_<?  echo $parcela ?>" name="parcela[]" value="<? echo $nrparepr; ?>">	
						<input type="hidden" id="dtvencto_<? echo $nrparepr ?>" name="dtvencto[]" value="<? echo getByTagName($registro->tags,'dtvencto'); ?>">						
						<input type="hidden" id="vlpagan_<?  echo $nrparepr ?>" name="vlpagan[]" value = "<? echo number_format(0); ?>">
		
					</td>
					</tr>
				<? 
					$parcela++;
					} 								
				?>
			</tbody>
		</table>
	</div>
</div>
<div id="divVlParc " align="left" >
	<form id="frmVlParc" name="frmVlParc" >
		<label for="totatual">Total Valor Atual:</label><input type="text" id="totatual" name="totatual" value="" />
		<label for="totpagto">Total a Pagar:</label><input type="text" id="totpagto" name="totpagto"/></br>
		<label for="vldifpar">Diferen&ccedil;a:</label><input type="text" id="vldifpar" name="vldifpar"/>
		<label for="pagtaval">Pagamento Aval:&nbsp;</label><input type="checkbox" name="pagtaval" id="pagtaval" />		
	</form>
</div>
<div id="divBotoes">
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao(''); return false;" />
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaPagamento(); return false;" />
</div>
<form class="formulario" id="frmAntecipapgto">
  <input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
</form>
