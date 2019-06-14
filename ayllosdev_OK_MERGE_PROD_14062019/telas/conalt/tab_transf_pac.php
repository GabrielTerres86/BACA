<? 
/*!
 * FONTE        : tab_conalt.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 13/06/2011 
 * OBJETIVO     : Tabela que apresenta as autorizações de debito em conta
 * --------------
 * ALTERAÇÕES   : 14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * 				
 *				  03/06/2014 - Adicionado replace de aspas simples. 
 *						       Estava quebrando o js. (Jorge/Gielow)
 ----------------
 */	

$search  = array('.','-');
$tabela = "<fieldset id=\'tabConteudo\'>";
$tabela .= 	"<legend>". utf8ToHtml('Transferências realizadas') ."</legend>";
	
$tabela .= 	"<div class=\'divRegistros\'>";
$tabela .= 		"<table>";
$tabela .= 			"<thead>";
$tabela .= 				"<tr>";
$tabela .= 					"<th>Conta/Dv</th>";
$tabela .= 					"<th>Associado</th>";
$tabela .= 					"<th>PA Atu</th>";
$tabela .= 					"<th>Data Alt</th>";
$tabela .= 					"<th>PA Ori</th>";
$tabela .= 					"<th>PA Des</th>";
$tabela .= 				"</tr>";

$tabela .= 			"</thead>";
$tabela .= 			"<tbody>";
				foreach( $registros as $transferencias ) { 
$tabela .= 					"<tr><td><span>". str_replace($search,'',getByTagName($transferencias->tags,'nrdconta')) ."</span>";
$tabela .=                           mascara(getByTagName($transferencias->tags,'nrdconta'),'####.###-#')."</td>";
$tabela .= 						"<td>";
$tabela .= 							"<span>". str_replace("'","",getByTagName($transferencias->tags,'nmprimtl')) ."</span>";
$tabela .= 							str_replace("'","",stringTabela(getByTagName($transferencias->tags,'nmprimtl'), 20, 'palavra'));
$tabela .= 						"</td>";
$tabela .= 						"<td>". getByTagName($transferencias->tags,'cdageatu') ."</td>";
$tabela .= 						"<td>";
$tabela .= 							"<span>". dataParaTimestamp(getByTagName($transferencias->tags,'dtaltera')) ."</span>";
$tabela .= 							getByTagName($transferencias->tags,'dtaltera');
$tabela .= 						"</td>";
$tabela .= 						"<td>". getByTagName($transferencias->tags,'cdageori') ."</td>";

$tabela .= 						"<td>". getByTagName($transferencias->tags,'cdagedes') ."</td>";
$tabela .= 					"</tr>";
				}
$tabela .= 			"</tbody>";
$tabela .= 		"</table>";
$tabela .= 	"</div>";

$tabela .= "</fieldset>";

echo "$('#divTransfTabela').html('".$tabela."');";

//monta layout da tabela
echo 'formataTabelaTransfPAC();';

// mostra o div com a tabela
echo '$("#divTransfTabela").show();';