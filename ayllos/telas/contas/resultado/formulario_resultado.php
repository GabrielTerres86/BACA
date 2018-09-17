<? 
/*!
 * FONTE        : formulario_banco.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Forumlário de dados de Resultado para alteracao
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 */	
?>	
<form name="frmDadosResultados" id="frmDadosResultados" class="formulario">
	<fieldset>
		<legend><? echo utf8ToHtml('Consultas de resultados dos ultimos 12 meses ( Valores R$ )') ?></legend>
	
		<label for="vlrctbru">Receita Bruta de Vendas:</label>
		<input name="vlrctbru" id="vlrctbru" class="moeda" type="text" value="<? echo getByTagName($resultado,'vlrctbru') ?>" />
		<br />
		
		<label for="vlctdpad">Custos e Despesas Administrativas/Vendas:</label>
		<input name="vlctdpad" id="vlctdpad" class="moeda" type="text" value="<? echo getByTagName($resultado,'vlctdpad') ?>" />
		<br />
		
		<label for="vldspfin">Despesas Administrativas:</label>
		<input name="vldspfin" id="vldspfin" class="moeda" type="text" value="<? echo getByTagName($resultado,'vldspfin') ?>" />
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Prazos M&eacute;dios ( Em dias )') ?></legend>
		
		<label for="ddprzrec">Recebimentos:</label>
		<input name="ddprzrec" id="ddprzrec" class="inteiro" type="text" value="<? echo getByTagName($resultado,'ddprzrec') ?>" />
		<br />
		
		<label for="ddprzpag">Pagamentos:</label>
		<input name="ddprzpag" id="ddprzpag" class="inteiro" type="text" value="<? echo getByTagName($resultado,'ddprzpag') ?>" />
		<br style="clear:both"/>
	</fieldset>	
</form>
<div class="divFinanc">		
	<label for="dtaltjfn">Dados Resultado => Alterado:</label>
	<input name="dtaltjfn" id="dtaltjfn" type="text" value="<? echo getByTagName($resultado,'dtaltjfn') ?>" />
	
	<label for="cdoperad">Operador:</label>
	<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($resultado,'cdoperad') ?>" />
	<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($resultado,'nmoperad') ?>" />
</div>	

<div id="divBotoes">		
	<? if ( in_array($operacao,array('AC','')) ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
	<? } else if ( $operacao == 'CA' ) { ?>
	
		<? if ($flgcadas == 'M' ) { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
		<? } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<? } ?>
	
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('VA');" />
	<? } ?>
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();" />
</div>
