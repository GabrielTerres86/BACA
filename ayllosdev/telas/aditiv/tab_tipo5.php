<? 
/*!
 * FONTE        : tab_tipo5.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 14/10/2011 
 * OBJETIVO     : Tabela de exibição do TIPO 5 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('5 - Substituicao de Veiculo') ?></legend>
	
	<div id="tabTipo">
		<div class="divRegistros">	
			<table>
				<thead>
					<tr>
						<th><? echo utf8ToHtml('Data'); ?></th>
						<th><? echo utf8ToHtml('Automovel');  ?></th>
						<th><? echo utf8ToHtml('Renavan');  ?></th>
						<th><? echo utf8ToHtml('Tipo Chassi');  ?></th>
						<th><? echo utf8ToHtml('Chassi');  ?></th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $r ) { ?>
						<tr>
							<td><?php if ( $cddopcao != 'X' ) { ?>
								<span><? echo getByTagName($r->tags,'dtmvtolt') ?></span>
							    	  <? echo getByTagName($r->tags,'dtmvtolt') ?>
								<?php } ?>								
  								  <input type="hidden" id="idseqbem" name="idseqbem" value="<? echo getByTagName($r->tags,'idseqbem') ?>" />								  
  								  <input type="hidden" id="nrdplaca" name="nrdplaca" value="<? echo strtoupper(getByTagName($r->tags,'nrdplaca')) ?>" />								  
  								  <input type="hidden" id="ufdplaca" name="ufdplaca" value="<? echo strtoupper(getByTagName($r->tags,'ufdplaca')) ?>" />								  
  								  <input type="hidden" id="dscorbem" name="dscorbem" value="<? echo stringTabela(getByTagName($r->tags,'dscorbem'),30,'maiuscula') ?>" />								  
  								  <input type="hidden" id="nranobem" name="nranobem" value="<? echo getByTagName($r->tags,'nranobem') ?>" />								  
  								  <input type="hidden" id="nrmodbem" name="nrmodbem" value="<? echo getByTagName($r->tags,'nrmodbem') ?>" />								  
  								  <input type="hidden" id="uflicenc" name="uflicenc" value="<? echo strtoupper(getByTagName($r->tags,'uflicenc')) ?>" />								  
									  
							</td>
							<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dsbemfin')) ?></span>
									  <? echo stringTabela(getByTagName($r->tags,'dsbemfin'),28,'maiuscula') ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'nrrenava') ?></span>
									  <? echo getByTagName($r->tags,'nrrenava') ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'tpchassi') ?></span>
									  <? echo getByTagName($r->tags,'tpchassi') ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'dschassi') ?></span>
									  <? echo getByTagName($r->tags,'dschassi') ?>
							</td>
						</tr>
				<? } ?>	
				</tbody>
			</table>
		</div>	
	</div>
	</fieldset>
	
	<div id="linha1">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Placa:'); ?></li>
	<li id="nrdplaca"></li>
	<li><? echo utf8ToHtml('Uf Placa:'); ?></li>
	<li id="ufdplaca"></li>
	<li><? echo utf8ToHtml('Cor:'); ?></li>
	<li id="dscorbem"></li>
	</ul>
	</div>

	<div id="linha2">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Ano:'); ?></li>
	<li id="nranobem"></li>
	<li><? echo utf8ToHtml('Modelo:'); ?></li>
	<li id="nrmodbem"></li>
	
	</ul>
	</div>	

</form>




<div id="divBotoes" style="margin:5px 0 10px 0">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="mostraSenha(); return false;">Excluir</a>
</div>

<script>
formataTipo5();
</script>