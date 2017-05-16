<?php
/* !
 * FONTE        : tab_resultado.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2016 
 * OBJETIVO     : Tabela que apresenta resultado da consulta realizada
 * --------------
 * ALTERAÇÕES   : 
  ----------------
 */

$search = array('.', '-');
$tabela = "<fieldset id=\'tabConteudo\'>";
$tabela .= "<legend>" . utf8ToHtml('Parâmetros') . "</legend>";

$tabela .= "<div class=\'divRegistros\'>";
$tabela .= "<table>";
$tabela .= "<thead>";
$tabela .= "<tr>";
$tabela .= "<th>Cooperativa</th>";
$tabela .= "<th>Contigencia</th>";
$tabela .= "<th>Comite</th>";
$tabela .= "<th>Timeout</th>";
$tabela .= "<th>Regra</th>";
$tabela .= "<th>Dev. Cheques</th>";
$tabela .= "<th>Estouro</th>";
$tabela .= "<th>Atr. Emprest.</th>";
$tabela .= "</tr>";

$tabela .= "</thead>";
$tabela .= "<tbody>";


foreach ($registros as $r) {

	$qtsstime = (getByTagName($r->tags, 'qtsstime') > 1) ? getByTagName($r->tags, 'qtsstime').' segundos' : getByTagName($r->tags, 'qtsstime').' segundo';
	$qtmeschq = (getByTagName($r->tags, 'qtmeschq') > 1) ? getByTagName($r->tags, 'qtmeschq').' meses' : getByTagName($r->tags, 'qtmeschq').' m&ecirc;s';
	$qtmesest = (getByTagName($r->tags, 'qtmesest') > 1) ? getByTagName($r->tags, 'qtmesest').' meses' : getByTagName($r->tags, 'qtmesest').' m&ecirc;s';
	$qtmesemp = (getByTagName($r->tags, 'qtmesemp') > 1) ? getByTagName($r->tags, 'qtmesemp').' meses' : getByTagName($r->tags, 'qtmesemp').' m&ecirc;s';

    $tabela .= "<tr>";

    $tabela .= "<td>" . getByTagName($r->tags, 'nmrescop') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'contigen') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'incomite') . "</td>";
    $tabela .= "<td>" . $qtsstime 						   . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'nmregmot') . "</td>";
    $tabela .= "<td>" . $qtmeschq 						   . "</td>";
    $tabela .= "<td>" . $qtmesest 						   . "</td>";
    $tabela .= "<td>" . $qtmesemp 						   . "</td>";

    $tabela .= "</tr>";
}

$tabela .= "</tbody>";
$tabela .= "</table>";
$tabela .= "</div>";

$tabela .= "</fieldset>";

// Monta tabela
echo "$('#divConsulta').html('" . $tabela . "');";

// Efetua formatação do layout da tabela
echo 'formataResultado();';

// Esconde botão Continuar
echo '$("#btContinuar","#divBotoes").hide();';
