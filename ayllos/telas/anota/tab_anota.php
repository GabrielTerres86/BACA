<? 
/*!
 * FONTE        : tab_anota.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 16/02/2011 
 * OBJETIVO     : Tabela que apresenda as anotações da conta selecionada
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<fieldset id='tabConteudo'>
	<legend><? echo utf8ToHtml('Anotações') ?></legend>
			
	<div class="divRegistros">
		<table>
			<thead>
				<tr><th>Operador</th>
					<th>Pri</th>
					<th>Data</th>
					<th>Hora</th>
					<th>Texto</th></tr>			
			</thead>
			<tbody>
				<? foreach( $registros as $anotacao ) { ?>
					<tr><td><span><? echo getByTagName($anotacao->tags,'nmoperad') ?></span>
							<? echo stringTabela(getByTagName($anotacao->tags,'nmoperad'),15,'maiuscula') ?>
							<input type="hidden" id="nrseqdig" name="nrseqdig" value="<? echo getByTagName($anotacao->tags,'nrseqdig') ?>" /></td>
						<td><? if(getByTagName($anotacao->tags,'flgprior') == 'yes'){echo 'Sim';}else{echo utf8ToHtml('Não');} ?></td>
						<td><span><? echo dataParaTimestamp(getByTagName($anotacao->tags,'dtmvtolt')) ?></span>
						    <? echo getByTagName($anotacao->tags,'dtmvtolt') ?></td>
						<td><span><? echo getByTagName($anotacao->tags,'hrtransa') ?></span>
						    <? echo getByTagName($anotacao->tags,'hrtransc') ?></td>
						<td><? echo stringTabela(getByTagName($anotacao->tags,'dsobserv'),25,'maiuscula') ?></td></tr>				
				<? } ?>			
			</tbody>
		</table>
	</div> 

	<div id="divBotoes">
		<?if ( $operacao == 'FC' ) {?>
			<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="controlaOperacao('');"   />
			<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacao('TC');" />
			<input type="image" id="btImprimir"  src="<? echo $UrlImagens; ?>botoes/imprimir.gif" onClick="controlaOperacao('IM');" />
		<?}else if ( $operacao == 'FA' ){?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="controlaOperacao('');"   />
			<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('TA');" />
		<?}else if ( $operacao == 'FE' ){?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="controlaOperacao('');"   />
			<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('EV');" />
		<?}else if ( $operacao == 'FI' ){?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="controlaOperacao('');"   />
			<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('TI');" />
		<?}?>
	</div>
</fieldset>