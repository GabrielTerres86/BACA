<? 
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 21/01/2013 
 * OBJETIVO     : Tabela os dados da tela MANCCF
 * --------------
 * ALTERAÇÕES   : 12/01/2016 - Corrigido a tag de checkbox e colocado o value pois nao imprimia a carta
 *                             no ayllosweb (Tiago/Elton SD379410)
 * --------------
 */	
?>

<?

	session_start();
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
				<!--	<th><?php //echo utf8ToHtml('Seq.');  ?></th> -->
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
					
					<tr>
						<td><span><? echo $flgselec; ?></span>
							<input name="aplicacao" type="checkbox" onclick="validaSelecao(this)" value="<? echo $nrseqdig; ?>" />	<td>
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
    <a href="#" class="botao" id="btTitular" onclick="mostraTitular(); return false;">Titular</a>
    <a href="#" class="botao" id="btRegulariza" onclick="Regulariza(); return false;">Regularizar</a>
    <a href="#" class="botao" id="btRefazer" onclick="RefazRegulariza(); return false;">Reenviar regulariza&ccedil;&atilde;o</a>
    <a href="#" class="botao" id="btImprimir" onclick="Gera_Impressao(); return false;">Imprimir Carta</a>
    <a href="#" class="botao" name="btVoltar" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
</div>