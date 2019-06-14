<?php
/*!
 * FONTE        : tab_titular.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 21/01/2013 
 * OBJETIVO     : Tabela que apresenta os titulares para seleção
 * --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */	

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>


<div id="divTitular">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th>Seg.</th>
					<th>T&iacute;tular</th>					
				</tr>
			</thead>
			<tbody>			
				<? foreach( $registros as $r ) { ?>
					<tr>						
						<td><? echo getByTagName($r->tags,'idseqttl') ?>
							<input type="hidden" id="idseqttl" name="idseqttl" value="<? echo getByTagName($r->tags,'idseqttl') ?>" /></td>
						<td><? echo getByTagName($r->tags,'nmextttl') ?></td>						
					</tr>
				<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNrdconta.focus(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaTitular(); return false;">Continuar</a>
</div>