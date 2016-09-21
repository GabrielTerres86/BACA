<? 
/*!
 * FONTE        : tab_transacoes.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 26/10/2011 
 * OBJETIVO     : Tabela que apresenta as transacoes
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 * --------------
 */
 
?>

<form id="frmTransacoes" name="frmTransacoes" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Lista das Transações Efetuadas em '.$dtlimite); ?></legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Horario');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Docmto');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('Operação');  ?></th>
					<th><? echo utf8ToHtml('Cartão');  ?></th>
					<th><? echo utf8ToHtml('Seq');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $registro as $r ) { 
								
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dttransa')); ?></span>
							      <? echo getByTagName($r->tags,'dttransa'); ?>
 
						</td>
						<td><span><? echo getByTagName($r->tags,'hrtransa'); ?></span>
							      <? echo getByTagName($r->tags,'hrtransa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdconta'); ?></span>
							      <? echo formataContaDV(getByTagName($r->tags,'nrdconta')); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdocmto'); ?></span>
							      <? echo getByTagName($r->tags,'nrdocmto'); ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vllanmto')); ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vllanmto')); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dstransa'); ?></span>
								  <? echo stringTabela(getByTagName($r->tags,'dstransa'),15,'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrcartao'); ?></span>
								  <? echo stringTabela(formataNumericos("9999.9999.9999.9999",getByTagName($r->tags,'nrcartao'),"."),19,'maiuscula');  ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrsequni'); ?></span>
								  <? echo getByTagName($r->tags,'nrsequni'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
	
	</fieldset>
</form>


<div id="linha1">
<ul class="complemento">
<li></li>
<li><? echo utf8ToHtml('Total de Saques:'); ?></li>
<li id="qtsaques"><?php echo $qtsaques ?></li>
<li id="vlsaques"><?php echo $vlsaques ?></li>
</ul>
</div>

<div id="linha2">
<ul class="complemento">
<li></li>
<li><? echo utf8ToHtml('Total de Estornos:'); ?></li>
<li id="qtestorn"><?php echo $qtestorn ?></li>
<li id="vlestorn"><?php echo $vlestorn ?></li>
</ul>
</div>	

<div id="divBotoes" style="margin-bottom:8px">
	<a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmTransacoes'));
	});

</script>