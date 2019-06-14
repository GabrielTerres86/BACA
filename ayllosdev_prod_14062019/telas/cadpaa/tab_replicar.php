<?php
/* !
 * FONTE        : tab_resultado.php
 * CRIAÇÃO      : Renato Darosci
 * DATA CRIAÇÃO : 09/11/2016 
 * OBJETIVO     : Tabela que apresenta resultado da consulta realizada
 * --------------
 * ALTERAÇÕES   : 
  ----------------
 */

$search = array('.', '-');
$tabela = "<fieldset id=\'tabConteudo\'>";
$tabela .= "<legend>" . utf8ToHtml('Cooperativas') . "</legend>";
$tabela .= "<div class=\'divTabela\'>";
$tabela .= "<div class=\'divRegistros\'>";
$tabela .= "<table>";
$tabela .= "<thead>";
$tabela .= "<tr>";
$tabela .= "<th>&nbsp;</th>";
$tabela .= "<th>Selecionar</th>";
$tabela .= "</tr>";

$tabela .= "</thead>";
$tabela .= "<tbody>";

$index = 0;

foreach ($registros as $r) {
	
	$index = $index + 1;
	
    $tabela .= "<tr>";

    $tabela .= "<td><input name=\"flgcooper\" type=\"checkbox\" id=\"flgcooper" . $index . "\" style=\"border:none;float: center;\"/>";
    $tabela .= "    <input name=\"cdcooper\" type=\"hidden\" id=\"cdcooper" . $index . "\" value=\"" . getByTagName($r->tags, 'cdcooper') .  "\" /></td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'dscooper') . "</td>";

    $tabela .= "</tr>";
}

$tabela .= "</tbody>";
$tabela .= "</table>";
$tabela .= "</div>";
$tabela .= "</div>";

$tabela .= "</fieldset>";

// Monta tabela
echo "$('#divReplica').html('" . $tabela . "');";

// Efetua formatação do layout da tabela
echo 'formataResultado();';

