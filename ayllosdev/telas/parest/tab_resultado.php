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
$tabela .= "<legend>" . utf8ToHtml('Parâmetros da Esteira de Crédito') . "</legend>";

$tabela .= "<div class=\'divRegistros\'>";
$tabela .= "<table>";
$tabela .= "<thead>";
$tabela .= "<tr>";
$tabela .= "<th>Coop.</th>";
$tabela .= "<th>Contig.</th>";
$tabela .= "<th>Comite</th>";
$tabela .= "<th>Analise Aut.</th>";
$tabela .= "<th>Regra PF</th>";
$tabela .= "<th>Regra PJ</th>";
$tabela .= "</tr>";

$tabela .= "</thead>";
$tabela .= "<tbody>";


foreach ($registros as $r) {

	  $tabela .= "<tr>";

    $tabela .= "<td>" . getByTagName($r->tags, 'nmrescop') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'contigen') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'incomite') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'anlautom') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'nmregmpf') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'nmregmpj') . "</td>";
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
