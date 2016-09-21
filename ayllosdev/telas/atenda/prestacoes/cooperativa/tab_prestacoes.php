<? 
/*!
 * FONTE        : tab_prestacoes.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 01/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta Prestacoes
 * --------------
 * ALTERAÇÕES   : 05/06/2014 - Ajuste para armazenar o nome do avalista. (James)
 *
 *				  28/07/2014 - Ajustado campo  <th> "contato" para "contrato" (Daniel)	
 *
 *			      03/11/2014 - Incluso botao Transf. p/ Prejuizo (Daniel)
 *
 *                25/11/2014 - Incluido um campo hidden "cdorigem". (Jaison)
 *				
 * 				  06/01/2015 - Padronizando a mascara do campo nrctremp.
 *	   	                       10 Digitos - Campos usados apenas para visualização
 *			                   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *				               (Kelvin - SD 233714)
 *
 *                27/05/2015 - Inclusao do botao "Portabilidade". (Jaison/Diego - SD: 290027)
 * --------------
 */
 
?>

<?php
 	session_start();
	//require_once('../../includes/config.php');
	//require_once('../../includes/funcoes.php');
	//require_once('../../includes/controla_secao.php');	
	//require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<div id="tabPrestacao">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Lin'); 		  ?></th>
					<th><? echo utf8ToHtml('Fin');        ?></th>
					<th><? echo utf8ToHtml('Contrato');    ?></th>
					<th><? echo utf8ToHtml('Produto');    ?></th>
					<th><? echo utf8ToHtml('Data');  	  ?></th>
					<th><? echo utf8ToHtml('Emprestado'); ?></th>
					<th><? echo utf8ToHtml('Parc');  	  ?></th>
					<th><? echo utf8ToHtml('Valor');  	  ?></th>
					<th><? echo utf8ToHtml('Saldo');  	  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $banco ) { $tipo = (getByTagName($banco->tags,'tpemprst') == "0") ? "Price TR" : "Price Pre-fixado"  ?>
				<tr>
				    <td><? echo getByTagName($banco->tags,'cdlcremp') ?>
						<input type="hidden" id="nrctremp" name="nrctremp" value="<? echo getByTagName($banco->tags,'nrctremp') ?>" />
						<input type="hidden" id="inprejuz" name="inprejuz" value="<? echo getByTagName($banco->tags,'inprejuz') ?>" />
						<input type="hidden" id="tplcremp" name="tplcremp" value="<? echo getByTagName($banco->tags,'tplcremp') ?>" />
						<input type="hidden" id="nrdrecid" name="nrdrecid" value="<? echo getByTagName($banco->tags,'nrdrecid') ?>" />
						<input type="hidden" id="qtpromis" name="qtpromis" value="<? echo getByTagName($banco->tags,'qtpromis') ?>" />
						<input type="hidden" id="flgimppr" name="flgimppr" value="<? echo getByTagName($banco->tags,'flgimppr') ?>" />
						<input type="hidden" id="flgimpnp" name="flgimpnp" value="<? echo getByTagName($banco->tags,'flgimpnp') ?>" />
						<input type="hidden" id="tpemprst" name="tpemprst" value="<? echo getByTagName($banco->tags,'tpemprst') ?>" />
						<input type="hidden" id="dsdavali" name="dsdavali" value="<? echo getByTagName($banco->tags,'dsdavali') ?>" />
                        <input type="hidden" id="cdorigem" name="cdorigem" value="<? echo getByTagName($banco->tags,'cdorigem') ?>" />
						<input type="hidden" id="liquidia" name="liquidia" value="<? echo getByTagName($banco->tags,'liquidia') ?>" />
						<input type="hidden" id="vlemprst" name="vlemprst" value="<? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlemprst')),2,",",".");?>" />
						<input type="hidden" id="portabil" name="portabil" value="<? echo getByTagName($banco->tags,'portabil') ?>" />						
					</td>
					<td><? echo getByTagName($banco->tags,'cdfinemp') ?></td>
					<td><? echo formataNumericos("z.zzz.zzz.zzz",getByTagName($banco->tags,'nrctremp'),"."); ?></td>
					<td><? echo stringTabela($tipo,40,'maiuscula'); ?></td> 
					<td><? echo getByTagName($banco->tags,'dtmvtolt') ?></td>
					<td><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlemprst')),2,",",".");?></td>
					<td><? echo getByTagName($banco->tags,'qtpreemp') ?></td>
					<td><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlpreemp')),2,",",".");  ?></td>
					<td><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlsdeved')),2,",",".");  ?></td>
					
				</tr>				
				<? } ?>
			</tbody>
		</table>
	</div>	
</div>


<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					
					//
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<? // jorge echo $nriniseq." | ".$nrregist." | ".$qtregist." ";
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<div id="divBotoes">
    <a href="#" class="botao" id="btVoltar"        onClick="encerraRotina('true');">Voltar</a>
	<a href="#" class="botao" id="btConsultar"     onClick="direcionaConsulta();">Consultar</a>
	<a href="#" class="botao" id="btPagar" 	       onClick="validarLiquidacao();">Pagar</a>
 	<a href="#" class="botao" id="bttranfPreju"    onClick="confirmaPrejuizo()">Transferir Prejuízo</a>
	<a href="#" class="botao" id="btdesfazPreju"   onClick="confirmaDesfazPrejuizo()">Desfazer Prejuízo</a>
	<a href="#" class="botao" id="btCancelar"      onClick="controlaOperacao('D_EFETIVA');">Desfazer Efetivação</a>
    <a href="#" class="botao" id="btPortabilidade" onClick="controlaOperacao('PORTAB_CRED');">Portabilidade</a>
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		acessaOpcaoAba( qtOpcoesTela, 0, '<? echo $opcoesTela[0]; ?>', <? echo "'".($nriniseq - $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		acessaOpcaoAba( qtOpcoesTela, 0, '<? echo $opcoesTela[0]; ?>', <? echo "'".($nriniseq + $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divConteudoOpcao').formataRodapePesquisa();

</script>