<? 
/*!
 * FONTE        : tab_custdesc.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 11/07/2011 
 * OBJETIVO     : Tabela que apresenta custdesc
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div id="divCustdesc">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml(''); ?></th>
					<th><? echo utf8ToHtml('Favor.'); ?></th>
					<th><? echo utf8ToHtml(''); ?></th>
					<th><? echo utf8ToHtml('Cheque'); ?></th>
				</tr>
			</thead>
			<tbody>
				
			</tbody>
		</table>
	</div>	
</div>

<div id="divCustodiaLinha1">
<ul class="complemento">
<li><? echo utf8ToHtml('Cheque em Custodia:'); ?></li>
<li id="flgcusto"></li>
<li><? echo utf8ToHtml('Liberação para:'); ?></li>
<li id="dtliber1"></li>
</ul>
</div>

<div id="divCustodiaLinha2">
<ul class="complemento">
<li><? echo utf8ToHtml('Digitação em:'); ?></li>
<li id="cdpesqu1"></li>
</ul>
</div>

<br style="clear:both" />

<div id="divCustodiaLinha3">
<ul class="complemento">
<li><? echo utf8ToHtml('Cheque em Desconto:'); ?></li>
<li id="flgdesco"></li>
<li><? echo utf8ToHtml('Liberação para:'); ?></li>
<li id="dtliber2"></li>
</ul>
</div>

<div id="divCustodiaLinha4">
<ul class="complemento">
<li><? echo utf8ToHtml('Digitação em:'); ?></li>
<li id="cdpesqu2"></li>
</ul>
</div>

<div id="divBotoes">
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="btnContinuarCustdesc(); return false;" />
</div>