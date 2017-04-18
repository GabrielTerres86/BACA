<?php

/* !
 * FONTE        : busca_acionamento.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 22/03/2016 
 * OBJETIVO     : Rotina para controlar a busca de acionamentos
 * --------------
 * ALTERAÇÕES   : 18/04/2017 - Alterações referentes ao projeto 337 - Motor de Crédito. (Reinert)
 * -------------- 
 */
 
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();
?> 


<div id='divResultadoAciona'>
<fieldset id='tabConteudo'>
<legend><b><?= utf8ToHtml('Acionamentos Proposta: '); echo formataNumericos("zzz.zz9",$nrctremp,"."); ?></b></legend>

<div class='divRegistros'>
<table>
<thead>
<tr>
<th>Acionamento</th>
<th>PA</th>
<th>Operador</th>
<th>Opera&ccedil;&atilde;o</th>
<th>Data e Hora</th>
<th>Retorno</th>
</tr>

</thead>
<tbody>

<?php
foreach ($registros as $r) {
?>
    <tr>
		<td><?= getByTagName($r->tags, 'acionamento'); ?></td>
		<td><?= getByTagName($r->tags, 'nmagenci'); ?></td>
		<td><?= getByTagName($r->tags, 'cdoperad'); ?></td>
		<td><?if (getByTagName($r->tags, 'dslinklg') == '-'){ echo wordwrap(getByTagName($r->tags, 'operacao'),40, "<br />\n"); }else{ echo '<a href="'.getByTagName($r->tags, 'dslinklg').'" target="_blank" style="font-size: inherit">'.wordwrap(getByTagName($r->tags, 'operacao'),40, "<br />\n").'</a>'; }?></td>
		<td><?= getByTagName($r->tags, 'dtmvtolt'); ?></td>
		<td><?= wordwrap(getByTagName($r->tags, 'retorno'),40, "<br />\n"); ?></td>
	
    </tr>
	<?php
}
?>

</tbody>
</table>
</div>

</fieldset>

<div id="divBotoesAcionamento" style="margin-top:5px;">
	<a href="#" class="botao" id="btVoltar" onclick="controlaOperacao('TESTE');bloqueiaFundo(divRotina);">Voltar</a>
</div>

</div>


