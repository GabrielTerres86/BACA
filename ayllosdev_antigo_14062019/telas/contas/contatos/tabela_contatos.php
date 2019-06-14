<? 
/*!
 * FONTE        : tabela_contatos.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 10/05/2010 
 * OBJETIVO     : Tabela que apresenda os CONTATOS
 *
 * ALTERACOES   : 02/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */	
?>
<form name="frmReferencias" id="frmReferencias" class="formulario">
	<fieldset>
		<legend> Refer&ecirc;ncias </legend>
		<div class="divRegistrosContatos" style="overflow-y:scroll"> 
			<table id="tituloRegistros" class="tituloRegistros">
				<thead>
					<tr><th>Conta/dv</th>
						<th>Nome</th>
						<th>Telefone</th>
						<th>E-mail</th>		
						<th>DEM</th></tr>			
				</thead>		
				<tbody>
					<? foreach( $registros as $registro ) {?>
						<tr><td style="font-size:11px;"><? echo getByTagName($registro->tags,'nrdctato') ?> </td>
							<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registro->tags,'nrdrowid') ?>" />
							<td style="font-size:11px;"><? echo stringTabela(getByTagName($registro->tags,'nmdavali'),23,'maiuscula')   ?></td>
							<td style="font-size:11px;"><? echo stringTabela(getByTagName($registro->tags,'nrtelefo'),11,'maiuscula') ?></td>
							<td style="font-size:11px;"><? echo stringTabela(getByTagName($registro->tags,'dsdemail'),23,'minuscula') ?></td>			
							<td style="font-size:11px;"><? if( getByTagName($registro->tags,'dsdemiss') == 'yes'){ echo 'S'; } ?></td></tr>				
					<? } ?>			
				</tbody>
			</table>
		</div>

		<div id="divBotoes">
			<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="controlaOperacaoContatos('TA');return false;" />
			<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacaoContatos('TC');return false;" />	
			<input type="image" id="btExcluir"   src="<? echo $UrlImagens; ?>botoes/excluir.gif"   onClick="controlaOperacaoContatos('TX');return false;" />
			<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   onClick="controlaOperacaoContatos('TI');return false;" />
		</div>
	</fieldset>	
</form>