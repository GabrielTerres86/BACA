<?
/*
 * FONTE        : form_fluxo_investimento_cecred.php
 * CRIAÇÃO      : Tiago Machado 
 * DATA CRIAÇÃO : 09/08/2012												ÚLTIMA ALTERAÇÃO: 17/08/2012
 * OBJETIVO     : form de saida('I') da opcao fluxo na tela PREVIS da CENTRAL.
 * --------------
 * ALTERAÇÕES   : 17/08/2012 - Ajustes projeto Fluxo Financeiro (Adriano).
 * --------------
 */
?>


	<fieldset id="fsetinvestcecred" name="fsetinvestcecred">
		<legend> <? echo utf8ToHtml('Investimento') ?> </legend>	
		
		<label for="lbcooper">COOPERATIVA</label>
		<label for="lboperad">OPERADOR</label>
		<label for="lbvlrinv">VALOR</label>
		<label for="lbmovime">MOVIMENTAÇÃO</label>

		<br style="clear:both"/>
		
		<?php
		$i = 0;	
		
		foreach($nmrescop as $nmcooper){			
					
			?>		
			<label for="nmrescop" style="width:270px;"><?php echo $nmcooper; ?></label> 		
			
			<label for="operador"></label>
			<input name="operador" id="operador" type="text" value="<?php echo $nmoperad[$i]; ?>" /> 
			
			<?php		
					
			if($vlresgat[$i] > 0){?>
			
				<label for="vlresapl<?echo $i;?>"></label>
				<input name="vlresapl<?echo $i;?>" id="vlresapl<?echo $i;?>" type="text" value="<?php echo formataMoeda( ($vlresgat[$i] * -1) ); ?>" />
				<label for="tpomovto"></label>
				<input name="tpomovto" id="tpomovto" type="text" value="<?php echo 'Resgate'; ?>" />

				<br style="clear:both"/>
				
				<?php
				
				$totmovto = $totmovto + ($vlresgat[$i] * -1);
			
			}else{
			
				if($vlaplica[$i] > 0){?>		
				
					<label for="vlresapl<?echo $i;?>"></label>
					<input name="vlresapl<?echo $i;?>" id="vlresapl<?echo $i;?>" type="text" value="<?php echo formataMoeda($vlaplica[$i]); ?>" />
					<label for="tpomovto"></label>
					<input name="tpomovto" id="tpomovto" type="text" value="<?php echo 'Aplicação'; ?>" />

					<br style="clear:both"/>
			
					<?php		
					
					$totmovto = $totmovto + $vlaplica[$i];
					
				} else {?>			
				
						<label for="vlresapl<?echo $i;?>"></label>
						<input name="vlresapl<?echo $i;?>" id="vlresapl<?echo $i;?>" type="text" value="<?php echo formataMoeda(0); ?>" />
						<label for="tpomovto"></label>
						<input name="tpomovto" id="tpomovto" type="text" value="<?php echo '-'; ?>" />

						<br style="clear:both"/>
				
						<?php			
				}
			}
			
			$i++;
			
		}?>
		
		<label style="width:270px;">Total operações:</label> 
		<label for="totmovto"></label> 
		<input name="totmovto" id="totmovto" type="text" value="<?php echo formataMoeda($totmovto); ?>" />
		
		<br style="clear:both"/>
		
	</fieldset>		
