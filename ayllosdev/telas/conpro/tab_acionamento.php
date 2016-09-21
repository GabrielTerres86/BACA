<?php

/* !
 * FONTE        : tab_acionamento.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 22/03/2016 
 * OBJETIVO     : Tabela que apresenta resultado da consulta de acionamento
 * --------------
 * ALTERAÇÕES   : 
  ----------------
 */

$search = array('.', '-');
$tabela = "<fieldset id=\'tabConteudo\'>";
$tabela .= "<legend>" . utf8ToHtml('Acionamentos') . "</legend>";

$tabela .= "<div class=\'divRegistros\'>";
$tabela .= "<table>";
$tabela .= "<thead>";
$tabela .= "<tr>";
$tabela .= "<th>Acionamento</th>";
$tabela .= "<th>Proposta</th>";
$tabela .= "<th>PA</th>";
$tabela .= "<th>Operador</th>";
$tabela .= "<th>Opera&ccedil;&atilde;o</th>";
$tabela .= "<th>Data e Hora</th>";
$tabela .= "<th>Retorno</th>";
$tabela .= "</tr>";

$tabela .= "</thead>";
$tabela .= "<tbody>";


foreach ($registros as $r) {

    $tabela .= "<tr>";
	$tabela .= "<td>" . getByTagName($r->tags, 'acionamento') . "</td>";
	$tabela .= "<td>" . getByTagName($r->tags, 'nrctrprp') . "</td>";
	
    $tabela .= "<td>" . getByTagName($r->tags, 'nmagenci') . "</td>";
	$tabela .= "<td>" . getByTagName($r->tags, 'cdoperad') . "</td>";
	$tabela .= "<td>" . wordwrap(getByTagName($r->tags, 'operacao'),50, "<br/>") . "</td>";
	$tabela .= "<td>" . getByTagName($r->tags, 'dtmvtolt') . "</td>";
	$tabela .= "<td>" . getByTagName($r->tags, 'retorno') . "</td>";
	
    $tabela .= "</tr>";
}

$tabela .= "</tbody>";
$tabela .= "</table>";
$tabela .= "</div>";

$tabela .= "</fieldset>";

// Monta tabela
echo "$('#divResultadoAciona').html('" . $tabela . "');";

// Efetua formatação do layout da tabela
echo 'formataBusca();';

// Desabilita campo opção
echo 'cTodosFiltroAciona.desabilitaCampo();';

echo '$("#btContinuar", "#divBotoes").hide();';
