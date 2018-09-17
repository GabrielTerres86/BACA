<?php 

	//***************************************************************************//
	//*** Fonte: formulario_preposto.php                                      ***//
	//*** Autor: David                                                        ***//
	//*** Data : Fevereito/2009               Ultima Atualização: 06/01/2012  ***//
	   //***                                                                  ***//
	//*** Objetivo  : Formulário de Prepostos de Cartão Magnético             ***//
	//***                                                                     ***//	 
	//*** Alterações:														  ***//
	//*** 		13/07/2011 - Alterado para layout padrão (Rogerius - DB1).    ***//	
	//***																	  ***//
	//***																	  ***//
	//***			  06/01/2012 - Ajuste para alterar senha do cartao        ***//
	//***						   ao solicitar entrega (Adriano).   	      ***//
	//***																      ***//
	//***************************************************************************//
	
?>

<div id="divPrepostoCartaoMag">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta'); ?></th>
					<th><? echo utf8ToHtml('Nome');  ?></th>
					<th><? echo utf8ToHtml('CPF');  ?></th>
					<th><? echo utf8ToHtml('Cargo');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				$cor          = "";
				$nomePreposto = "";
				$cpfPreposto  = 0;
				$idPreposto   = 0;

				for ($i = 0; $i < $qtPreposto; $i++) { 
				if ($cor == "#F4F3F0") {
					$cor = "#FFFFFF";
				} else {
					$cor = "#F4F3F0";
				}
													
				if (strtolower($preposto[$i]->tags[5]->cdata) == "yes") {
					$nomePreposto = $preposto[$i]->tags[1]->cdata;										
					$cpfPreposto  = $preposto[$i]->tags[2]->cdata;
					$idPreposto   = $i + 1;
				}
				$aux =  $i + 1;
				$seleciona = "selecionaPreposto('".$aux."','".$qtPreposto."','".$preposto[$i]->tags[1]->cdata."','".$preposto[$i]->tags[2]->cdata."');";
				?>
				<tr id="trPreposto<?php echo $i + 1; ?>" onFocus="<? echo $seleciona ?>" onClick="<? echo $seleciona ?>">
					<td><span><?php echo $preposto[$i]->tags[0]->cdata ?></span>
							  <?php echo formataNumericos("zzzz.zzz-z",$preposto[$i]->tags[0]->cdata,".-"); ?>
					</td>
					<td><span><?php echo $preposto[$i]->tags[1]->cdata; ?></span>
							  <?php echo $preposto[$i]->tags[1]->cdata; ?>
					</td>
					<td><span><?php echo $preposto[$i]->tags[3]->cdata; ?></span>
							  <?php echo $preposto[$i]->tags[3]->cdata; ?>
					</td>
					<td><span><?php echo $preposto[$i]->tags[4]->cdata; ?></span>
							  <?php echo $preposto[$i]->tags[4]->cdata; ?>
					</td>
				</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	<form action="" name="frmSelecaoPreposto" id="frmSelecaoPreposto" method="post" class="formulario">
		<label for="nmprepo1">Preposto Atual:</label>
		<input id="nmprepo1"  type="text" value="<?php echo $nomePreposto; ?>" />
		
		<br />
		
		<label for="nmprepos">Preposto Novo:</label>
		<input type="text" name="nmprepos" id="nmprepos" />
	</form>
	
	<div id="divBotoes">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="voltarDivPrincipal(185,490);return false;">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="confirmaAtualizacaoPreposto('<?php echo $cddopcao; ?>','<?php echo $operacao; ?>');return false;">										
	</div>
</div>


<script type="text/javascript">
// Formata o layout
formataPreposto();

// Seleciona preposto atual
selecionaPreposto(<?php echo $idPreposto; ?>,<?php echo $qtPreposto; ?>,"",<?php echo $cpfPreposto; ?>);

// Armazena CPF do preposto atual
cpfpreat = <?php echo $cpfPreposto; ?>;
</script>