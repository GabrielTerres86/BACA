<?php 
/*
 * FONTE        : tab_pagto.php
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
		<legend>Transfer&ecirc;ncia</legend>
			
		<div id="divEstornos" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
						<th>Data</th>
						<th>Conta</th>
						<th>Contrato</th>
						<th>Valor</th>
						<th>Tipo</th>
					</tr>
				</thead>
				<tbody>
				<?php
				foreach ($aRegistros as $oEstorno) {
					 
				?>
					<tr >
					   
						<td><? echo getByTagName($oEstorno->tags,'dtpagto') ?></td>
						<td><? echo getByTagName($oEstorno->tags,'nrdconta') ?></td>
						<td><? echo getByTagName($oEstorno->tags,'nrctremp') ?></td>
						<td><? echo getByTagName($oEstorno->tags,'vlemprst') ?></td>			
						<td><? echo getByTagName($oEstorno->tags,'idtipo') ?>&nbsp;-&nbsp;
								<? echo getByTagName($oEstorno->tags,'dstipo') ?></td>				
					  <td><input type="hidden" id="nrdconta1" name="nrdconta1" value="<? echo getByTagName($oEstorno->tags,'nrdconta') ?>"/>
					  <input type="hidden" id="nrctremp1" name="nrctremp1" value="<? echo getByTagName($oEstorno->tags,'nrctremp') ?>"/>
						<a href="#" class="botao" id="btEstornar" onClick="carregaTelaEstornar(<? echo getByTagName($oEstorno->tags,'nrdconta') ?>, <? echo getByTagName($oEstorno->tags,'nrctremp') ?>);">Estornar</a></td>
                     								
					</tr>
				<?php
				}
				
				?>
				</tbody>
			</table>
			
		</div>
	</fieldset>
</div>