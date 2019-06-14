<? 
/*!
 * FONTE        : tab_alt_conalt.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 13/06/2011 
 * OBJETIVO     : Tabela que apresenta as alterações de conta
 * --------------
 * ALTERAÇÕES   :  
 ----------------
 */	

$tabela = "<fieldset id=\'tabConteudo\'>";
$tabela .=	"<legend>". utf8ToHtml('Alterações realizadas'). "</legend>";

$tabela .=	"<div class=\'divRegistros\'>";
$tabela .=		"<table>";
$tabela .=			"<thead>";
$tabela .=				"<tr>";
$tabela .=					"<th>Em</th>";
$tabela .=					"<th>De</th>";
$tabela .=					"<th>Para</th>";
$tabela .=				"</tr>";
$tabela .=			"</thead>";

$tabela .=			"<tbody>";
				 foreach( $registros as $alteracoes ) { 
$tabela .=					"<tr>";
$tabela .=						"<td>";
$tabela .=							"<span>". dataParaTimestamp(getByTagName($alteracoes->tags,'dtalttct')). "</span>";
$tabela .=							getByTagName($alteracoes->tags,'dtalttct');
$tabela .=						"</td>";
$tabela .=						"<td>";
$tabela .=							"<span>". getByTagName($alteracoes->tags,'dstctant'). "</span>";
$tabela .=							 getByTagName($alteracoes->tags,'dstctant');
$tabela .=						"</td>";

$tabela .=						"<td>";
$tabela .=							"<span>". getByTagName($alteracoes->tags,'dstctatu'). "</span>";
$tabela .=							getByTagName($alteracoes->tags,'dstctatu');
$tabela .=						"</td>";

$tabela .=					"</tr>";
				}
$tabela .=				"</tbody>";
$tabela .=		"</table>";
$tabela .=	"</div>";

$tabela .= "</fieldset>";

echo "$('#divAltContaTabela').html('".$tabela."');"; 

//monta layout da tabela
echo 'formataTabelaAltConta();';

// mostra o div com a tabela
echo '$("#divAltContaTabela").show();';