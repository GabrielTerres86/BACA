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
$tabela .= "<th class=\"hr_title_pa\">PA</th>";
$tabela .= "<th class=\"hr_title_conta\">Conta</th>";
$tabela .= "<th class=\"hr_title_contrato\">Contrato</th>";
$tabela .= "<th class=\"hr_title_valor_proposta\">Valor Proposta</th>";
if ($tpproduto!=4)
{
	$tabela .= "<th class=\"hr_title_qtd_parc empINfo\">Qtde. Parcelas</th>";
	$tabela .= "<th class=\"hr_title_linha empINfo\">Linha</th>";
}
$tabela .= "<th class=\"hr_title_inclusao\">Inclus&atilde;o</th>";
if ($tpproduto!=4)
{
	$tabela .= "<th class=\"hr_title_parecer empINfo\">Parecer <br>de Cr&eacute;dito</th>";
}
$tabela .= "<th class=\"hr_title_situacao\">Situa&ccedil;&atilde;o <br> Ayllos</th>";
$tabela .= "<th class=\"hr_title_parecer_est\">Parecer <br> Esteira</th>";
if ($tpproduto!=4)
{
	$tabela .= "<th class=\"hr_title_oper_env empINfo\">Operador <br> Envio</th>";
}
$tabela .= "<th class=\"hr_title_efetivada\">Efetivada</th>";
$tabela .= "<th class=\"hr_title_oper_inclusao\">Operador <br> Inclus&atilde;o</th>";
$tabela .= "<th class=\"hr_title_origem\">Origem</th>";
if ($tpproduto!=4)
{
	$tabela .= "<th class=\"hr_title_env_esteira empINfo\">Envio <br> Esteira</th>";
}
$tabela .= "</tr>";

$tabela .= "</thead>";
$tabela .= "<tbody>";


foreach ($registros as $r) {

    $tabela .= "<tr>";

    $tabela .= "<td class=\"td_title_pa\">" . getByTagName($r->tags, 'cdagenci') . "</td>";

    $tabela .= "<td class=\"td_title_conta\"><span>" . str_replace($search, '', getByTagName($r->tags, 'nrdconta')) . "</span>";
    $tabela .= mascara(getByTagName($r->tags, 'nrdconta'), '####.###-#') . "</td>";

    $tabela .= "<td class=\"td_title_contrato \"><span>" . str_replace($search, '', getByTagName($r->tags, 'nrctremp')) . "</span>";
    $tabela .= mascara(getByTagName($r->tags, 'nrctremp'), '##.###.###') . "</td>";

    $tabela .= "<td class=\"td_title_valor_proposta\">" . formataMoeda(getByTagName($r->tags, 'vlemprst')) . "</td>";
	if ($tpproduto!=4)
	{
		$tabela .= "<td class=\"td_title_qtd_parc empINfo\">" . getByTagName($r->tags, 'qtpreemp') . "</td>";
		$tabela .= "<td class=\"td_title_linha empINfo\">" . getByTagName($r->tags, 'cdlcremp') . "</td>";
	}
    
    $tabela .= "<td class=\"td_title_inclusao\">" . getByTagName($r->tags, 'dtmvtolt') . "<br>" . getByTagName($r->tags, 'hrmvtolt') . "</td>";
	if ($tpproduto!=4)
	{
		$tabela .= "<td class=\"td_title_parecer empINfo\">" . str_replace('@', '<br>', getByTagName($r->tags, 'parecer_ayllos')) . "</td>";
	}
    $tabela .= "<td class=\"td_title_situacao\">" . str_replace('@', '<br>', getByTagName($r->tags, 'situacao_ayllos')) . "</td>";
    $tabela .= "<td  class=\"td_title_parecer_est\">" . str_replace('@', '<br>', getByTagName($r->tags, 'parecer_esteira')) . "</td>";
	if ($tpproduto!=4)
	{
		$tabela .= "<td class=\"td_title_oper_env empINfo\" >" . str_replace('-', '<br>', getByTagName($r->tags, 'cdopeste')) . "</td>";
	}
    $tabela .= "<td class=\"td_title_efetivada \">" . getByTagName($r->tags, 'efetivada') . "</td>";

    $tabela .= "<td class=\"td_title_oper_inclusao\">" . str_replace('-', '<br>', getByTagName($r->tags, 'nmoperad')) . "</td>";
    $tabela .= "<td class=\"td_title_origem\">" . str_replace('-', '<br>', getByTagName($r->tags, 'nmorigem')) . "</td>";
	if ($tpproduto!=4)
	{
		$tabela .= "<td class=\"td_title_env_esteira empINfo\">" . getByTagName($r->tags, 'dtenvest') . "<br>" . getByTagName($r->tags, 'hrenvest') . "</td>";
	}

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
