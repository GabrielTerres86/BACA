<?php 
/*
 * FONTE        : tab_pagamentos.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/08/2017
 * OBJETIVO     : 
 * --------------
	* ALTERAÇÕES   :
 * --------------
*/ 

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>
<div>
  <fieldset>
	  <legend="Valores">
			<table width="100%">
			
				<?php
				foreach ($aRegistros as $oEstorno) {
					 
				?>
					<tr><td><label for="vlpagto">&nbsp;&nbsp;<?php echo utf8ToHtml('Pagamento:') ?></label></td>
					<td><input type="text" id="vlpagto" name="vlpagto" onchange="calcularSaldo()" value=""/></td></tr>
					<tr><td><label for="vlprincipal">&nbsp;&nbsp;<?php echo utf8ToHtml('Valor Principal:') ?></label></td>
					<td><input type="text" id="vlprincipal" disabled name="vlprincipal" value="<? echo getByTagName($oEstorno->tags,'vlsdprej') ?>"/></td></tr>
					<tr><td><label for="vljuros">&nbsp;&nbsp;<?php echo utf8ToHtml('Juros:') ?></label></td>
					<td><input type="text" id="vljuros" disabled name="vljuros" value="<? echo getByTagName($oEstorno->tags,'vlttjmpr') ?>"/></td></tr>
					<tr><td><label for="vlmulta">&nbsp;&nbsp;<?php echo utf8ToHtml('Multa:') ?></label></td>
					<td><input type="text" id="vlmulta" disabled  name="vlmulta" value="<? echo getByTagName($oEstorno->tags,'vlttmupr') ?>"/></td></tr>
					<tr><td><label for="vlabono">&nbsp;&nbsp;<?php echo utf8ToHtml('Abono:') ?></label></td>
					<td><input type="text" id="vlabono" name="vlabono" onchange="calcularSaldo()" value=""/></td></tr>
					<tr><td><label for="vlsaldo">&nbsp;&nbsp;<?php echo utf8ToHtml('Saldo:') ?></label></td>
					<td><input type="text" id="vlsaldo" disabled  name="vlsaldo" value=""/></td></tr>
						
				<?php
				}
				
				?>
				
			</table>
	</fieldset>		
</div>

<script>
	formataCampos();
</script>