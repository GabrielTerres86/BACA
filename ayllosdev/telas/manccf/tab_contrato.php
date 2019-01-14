<?php
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 21/01/2013 
 * OBJETIVO     : Tabela os dados da tela MANCCF
 * --------------
 * ALTERAÇÕES   : 12/01/2016 - Corrigido a tag de checkbox e colocado o value pois nao imprimia a carta
 *                             no ayllosweb (Tiago/Elton SD379410)
 *
 * 		           01/08/2016 - Corrigido grid que estava com os valores "trocados", conforme
 *								solicitado no chamado 480204. (Kelvin)
 *
  *				   03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)	 * 		         
 *
 *                11/08/2016 - #481330 Ajuste de navegação e seleção do cheque (Carlos)
 *
 *                14/01/2019 - Alteracoes para balizar novo botao de inclusao de
 *                             devolucoes pela alinea 12. 
 *                             Chamado PRB0040458 - Gabriel (Mouts).	
 * --------------
 */	

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<div id="divTabela">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml(' ');  ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Bco'); ?></th>
					<th><? echo utf8ToHtml('Conta Chq.');  ?></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>					
					<th><? echo utf8ToHtml('Valor');  ?></th>					
					<th><? echo utf8ToHtml('Al');  ?></th>					
					<th><? echo utf8ToHtml('Regular.');  ?></th>					
					<th><? echo utf8ToHtml('Operador');  ?></th>										
					<th><? echo utf8ToHtml('S');  ?></th>					
					<th><? echo utf8ToHtml('T');  ?></th>					
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { 
				
					$nrseqdig = getByTagName($r->tags,'nrseqdig');
					$dtiniest = getByTagName($r->tags,'dtiniest');
					$cdbanchq = getByTagName($r->tags,'cdbanchq');
					$nrctachq = getByTagName($r->tags,'nrctachq');
					$nrdocmto = getByTagName($r->tags,'nrdocmto');
					$vlestour = getByTagName($r->tags,'vlestour');
					$cdobserv = getByTagName($r->tags,'cdobserv');
					$dtfimest = getByTagName($r->tags,'dtfimest');
					$nmoperad = getByTagName($r->tags,'nmoperad');
					$flgselec = getByTagName($r->tags,'flgselec');
					$flgctitg = getByTagName($r->tags,'flgctitg');
					$idseqttl = getByTagName($r->tags,'idseqttl');	?>
					
					<tr onmouseup="clicouCheque(<? echo $flgctitg?>)">

						<td><span><? echo $flgselec; ?></span>
							<input name="aplicacao" type="checkbox" onclick="validaSelecao(this)" value="<? echo $nrseqdig; ?>" />	
                                                       <!-- <span style="display: none; visibility: hidden"><? echo $nrseqdig; ?></span>
							<? echo $nrseqdig; ?>		-->
							<input type="hidden" id="nrseqdig" name="nrseqdig" value="<? echo $nrseqdig; ?>" />
							<input type="hidden" id="nmoperad" name="nmoperad" value="<? echo $nmoperad; ?>" />
							<input type="hidden" id="dtfimest" name="dtfimest" value="<? echo $dtfimest; ?>" />
							<input type="hidden" id="flgctitg" name="flgctitg" value="<? echo $flgctitg; ?>" />
							<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo $nrdocmto; ?>" />
							</td>
							
						<td><span><? echo $dtiniest; ?></span>
							<? echo $dtiniest; ?>		</td>
							
						<td><span><? echo $cdbanchq; ?></span>
							<? echo $cdbanchq; ?>		</td>
							
						<td><span><? echo $nrctachq; ?></span>
							<? echo mascara($nrctachq,'####.###.#'); ?>		</td>
							
						<td><span><? echo $nrdocmto; ?></span>
							<? echo mascara($nrdocmto,'###.###.#'); ?>		</td>
							
						<td><span><? echo $vlestour; ?></span>
							<? echo formataMoeda($vlestour); ?>		</td>
							
						<td><span><? echo $cdobserv; ?></span>
							<? echo $cdobserv; ?>		</td>
							
						<td class="dtfimest"><span><? echo $dtfimest; ?></span>
							<? echo $dtfimest; ?>		</td>
							
						<td class="nmoperad"><span><? echo $nmoperad; ?></span>
							<? echo SubStr($nmoperad,0,8); ?>		</td>
							
						<td><span><? echo $flgctitg; ?></span>
							<? echo $flgctitg; ?>		</td>
							
						<td><span><? echo $idseqttl; ?></span>
							<? echo $idseqttl; ?>		</td>
							
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<br style="clear:both" />	

<div id="linha">
	<ul class="complemento">
		<li id="complemento"></li>	
	</ul>
</div>

<div id="divBotoes" style="margin-bottom:10px" >
    <a href="#" class="botao" id="btTitular" onclick="mostraTitular(); return false;" tabindex="3">Titular</a>
    <a href="#" class="botao" id="btRegulariza" onclick="Regulariza(); return false;" tabindex="4">Regularizar</a>
    <a href="#" class="botao" id="btRefazer" onclick="RefazRegulariza(); return false;" tabindex="5">Reenviar regulariza&ccedil;&atilde;o</a>
    <a href="#" class="botao" id="btImprimir" onclick="Gera_Impressao(); return false;" tabindex="6">Imprimir Carta</a>
    <a href="#" class="botao" id="btCCF" onclick="Inclusao_CCF_PopUp(false); return false;" tabindex="7">Inclus&atilde;o CCF Al&iacute;nea 12</a>
    <a href="#" class="botao" name="btVoltar" id="btVoltar" onclick="btnVoltar(); return false;" tabindex="8">Voltar</a>
</div>