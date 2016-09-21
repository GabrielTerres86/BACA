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
$tabela .= "<legend>" . utf8ToHtml('Propostas') . "</legend>";

$tabela .= "<div class=\'divRegistros\'>";
$tabela .= "<table>";
$tabela .= "<thead>";
$tabela .= "<tr>";
$tabela .= "<th>PA</th>";
$tabela .= "<th>Conta</th>";
$tabela .= "<th>Contrato</th>";
$tabela .= "<th>Valor Proposta</th>";
$tabela .= "<th>Qtde. Parcelas</th>";
$tabela .= "<th>Linha</th>";
$tabela .= "<th>Inclus&atilde;o</th>";
$tabela .= "<th>Parecer <br>de Cr&eacute;dito</th>";
$tabela .= "<th>Situa&ccedil;&atilde;o <br> Ayllos</th>";
$tabela .= "<th>Parecer <br> Esteira</th>";
$tabela .= "<th>Operador <br> Envio</th>";
$tabela .= "<th>Efetivada</th>";
$tabela .= "<th>Operador <br> Inclus&atilde;o</th>";
$tabela .= "<th>Origem</th>";
$tabela .= "<th>Envio <br> Esteira</th>";
$tabela .= "</tr>";

$tabela .= "</thead>";
$tabela .= "<tbody>";


foreach ($registros as $r) {

    $tabela .= "<tr>";

    $tabela .= "<td>" . getByTagName($r->tags, 'cdagenci') . "</td>";

    $tabela .= "<td><span>" . str_replace($search, '', getByTagName($r->tags, 'nrdconta')) . "</span>";
    $tabela .= mascara(getByTagName($r->tags, 'nrdconta'), '####.###-#') . "</td>";

    $tabela .= "<td><span>" . str_replace($search, '', getByTagName($r->tags, 'nrctremp')) . "</span>";
    $tabela .= mascara(getByTagName($r->tags, 'nrctremp'), '##.###.###') . "</td>";


    $tabela .= "<td>" . formataMoeda(getByTagName($r->tags, 'vlemprst')) . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'qtpreemp') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'cdlcremp') . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'dtmvtolt') . "<br>" . getByTagName($r->tags, 'hrmvtolt') . "</td>";

    $tabela .= "<td>" . str_replace('@', '<br>', getByTagName($r->tags, 'parecer_ayllos')) . "</td>";
    $tabela .= "<td>" . str_replace('@', '<br>', getByTagName($r->tags, 'situacao_ayllos')) . "</td>";
    $tabela .= "<td>" . str_replace('@', '<br>', getByTagName($r->tags, 'parecer_esteira')) . "</td>";
    $tabela .= "<td>" . str_replace('-', '<br>', getByTagName($r->tags, 'cdopeste')) . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'efetivada') . "</td>";

    $tabela .= "<td>" . str_replace('-', '<br>', getByTagName($r->tags, 'nmoperad')) . "</td>";
    $tabela .= "<td>" . str_replace('-', '<br>', getByTagName($r->tags, 'nmorigem')) . "</td>";
    $tabela .= "<td>" . getByTagName($r->tags, 'dtenvest') . "<br>" . getByTagName($r->tags, 'hrenvest') . "</td>";

    $tabela .= "</tr>";
}

$tabela .= "</tbody>";
$tabela .= "</table>";
$tabela .= "</div>";

$tabela .= "<div id=\'divPesquisaRodape\' class=\'divPesquisaRodape\'>";
	$tabela .= "<table>";	
		$tabela .= "<tr>";
			$tabela .= "<td>";
					//
					if ( isset($qtregist) and $qtregist == 0) { 
					  $nriniseq = 0; 
					}
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						$tabela .= "<a class=\'paginacaoAnt\'><<< Anterior</a>"; 
					} else {
						$tabela .= "&nbsp;";
					}
				
			$tabela .= "</td>";

			$tabela .= "<td>"; 
				if (isset($nriniseq)) { 
				  $tabela .= "Exibindo ". $nriniseq ." at&eacute; ";
				  if (($nriniseq + $nrregist) > $qtregist) { 
				    $tabela .= $qtregist; 
				  } else { 
				    $tabela .= ($nriniseq + $nrregist - 1); 
				  } 
				  $tabela .= " de ". $qtregist;
				}
			$tabela .= "</td>";

			$tabela .= "<td>";
				
					// Se a paginação não está na última página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						 $tabela .= "<a class=\'paginacaoProx\'>Pr&oacute;ximo >>></a>";
					} else {
						$tabela .= "&nbsp;";
					}
						
			$tabela .= "</td>";

		$tabela .= "</tr>";
	$tabela .= "</table>";
$tabela .= "</div>";

$tabela .= "</fieldset>";

// Monta tabela
echo "$('#divResultado').html('" . $tabela . "');";

// Efetua formatação do layout da tabela
echo 'formataResultado();';

// Desabilita campo opção
echo 'cTodosFiltro.desabilitaCampo();';

// Esconde botão Continuar
echo '$("#btContinuar","#divBotoes").hide();';

echo '$("a.paginacaoAnt").unbind("click").bind("click", function() {manterRotina('.'"'.($nriniseq - $nrregist).'","'.$nrregist.'");return false;});';
echo '$("a.paginacaoProx").unbind("click").bind("click", function() {manterRotina('.'"'.($nriniseq + $nrregist).'","'.$nrregist.'");return false;});';
