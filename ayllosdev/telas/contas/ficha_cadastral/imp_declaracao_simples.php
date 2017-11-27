<?
/*!
 * FONTE        : imp_declaracao_simples.php
 * CRIAÇÃO      : Diogo Carlassara (Mouts)
 * DATA CRIAÇÃO : 28/09/2017
 * OBJETIVO     : Responsável por montar o HTML da Ficha de Declaração do Simples Nacional.
 * 
 * ALTERACOES   :
 */
?>

<?
require_once('../../../includes/funcoes.php');
require_once('../../../class/xmlfile.php');

$xmlObjeto = $GLOBALS['xmlObjeto'];

$registros 	  	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
$identificacao	= $xmlObjeto->roottag->tags[11]->tags[0]->tags;
$registro     	= $xmlObjeto->roottag->tags[12]->tags[0]->tags;

// Inicializando variáveis
//$GLOBALS['totalLinha'] 	= 69;
$GLOBALS['totalLinha'] 	= 100000;
$GLOBALS['numLinha']	= 0;
$GLOBALS['numPagina'] 	= 1;

function escreveTituloPagina( $str ) {
    if( $GLOBALS['numLinha'] + 5 > $GLOBALS['totalLinha'] ) {

        // Quebro a página e retorno o número de linha atual
        // echo "<p style='page-break-before: always;'>&nbsp;</p>";
        $GLOBALS['numLinha'] = 5;
        $GLOBALS['numPagina']++;

        echo "<p>".preencheString('PAG '.$GLOBALS['numPagina'],90,' ','D')."</p>";

    } else {

        if ( $GLOBALS['tipo'] == 'formulario' && $GLOBALS['flagRepete'] ) {
            switch ($str){
                case 'REFERENCIAS ( PESSOAIS / COMERCIAIS / BANCARIAS )':
                    if ( $GLOBALS['numLinha'] + 11 > $GLOBALS['totalLinha'] ) { $GLOBALS['numLinha'] = 70; escreveTituloPagina( $str ); return false; }
                    break;
                default: break;
            }
        }
        $GLOBALS['numLinha'] = $GLOBALS['numLinha']+4;
        echo '<br>';
    }
    echo '              '.preencheString('',76,'-').'<br>';
    echo '              '.preencheString($str,76,' ','C').'<br>';
    echo '              '.preencheString('',76,'-').'<br>';
}
?>
    <style type="text/css">
        pre {
            font-family: monospace, "Courier New", Courier;
            font-size:9pt;
        }
        p {
            page-break-before: always;
            padding: 0px;
            margin:0px;
        }
    </style>
<?
echo '<pre>';
//************************************************************CABECALHO************************************************************
$linha = preencheString('PAG '.$GLOBALS['numPagina'],76,' ','D');
escreveLinha( $linha );

escreveLinha( '+--------------------------------------------------------------------------+' );

$linha = '|'.preencheString(getByTagName($registros,'nmextcop'),74).'|';
escreveLinha( $linha );

$linha = '|'.preencheString('',74).'|';
escreveLinha( $linha );

$linha = '|CONTA/DV: '.preencheString(getByTagName($registros,'nrdconta'),19);
$linha .= 'PA: '.preencheString(getByTagName($registros,'dsagenci'),21);
$linha .= ' MATRICULA: '.preencheString(getByTagName($registros,'nrmatric'),7,' ','D').'|';
escreveLinha( $linha );

$linha = '|'.preencheString('',74).'|';
escreveLinha( $linha );

$linha = '|'.preencheString('DECLARAÇÃO',74,' ','C').'|';
escreveLinha( $linha );

escreveLinha( '+--------------------------------------------------------------------------+' );
//**********************************************************IDENTIFICACAO**********************************************************

$GLOBALS['titulo'] = 'DECLARAÇÃO';
escreveLinha( ' ' );
escreveLinha( ' ' );
escreveTituloPagina('Empresa Optante pelo Simples Nacional');
escreveLinha( ' ' );
escreveLinha( ' ' );

$linha = preencheString(getByTagName($identificacao,'nmprimtl'),76, '.');
escreveLinha( $linha );

$enderecoCompleto = getByTagName($registros,'dsendere');
$enderecoCompleto .= (trim(getByTagName($registros,'nrendere')) <> "") ? ", nº ".getByTagName($registros,'nrendere') : "";
$enderecoCompleto .= (trim(getByTagName($registros,'complend')) <> "") ? ", ".getByTagName($registros,'complend') : "";
//$enderecoCompleto .= (trim(getByTagName($registros,'nrdoapto')) <> "") ? ", ".getByTagName($registros,'nrdoapto') : "";
//$enderecoCompleto .= (trim(getByTagName($registros,'cddbloco')) <> "") ? ", ".getByTagName($registros,'cddbloco') : "";
$enderecoCompleto .= (trim(getByTagName($registros,'nmbairro')) <> "") ? ", bairro ".getByTagName($registros,'nmbairro') : "";
$enderecoCompleto .= (trim(getByTagName($registros,'nmcidade')) <> "") ? ", município de ".getByTagName($registros,'nmcidade') : "";
$enderecoCompleto .= (trim(getByTagName($registros,'cdufende')) <> "") ? " / ".getByTagName($registros,'cdufende') : "";
$enderecoCompleto .= (trim(getByTagName($registros,'nrcepend')) <> "") ? ", CEP ".getByTagName($registros,'nrcepend') : "";

if (strlen($enderecoCompleto) < 67){
	$linha = preencheString('com sede na '.$enderecoCompleto,76, '.');
	escreveLinha( $linha );
}
else{
	$enderecoCompleto = 'com sede na '.$enderecoCompleto;
	$qdeLinhas = ceil(strlen($enderecoCompleto) / 76);
	
	$iInicial = 0;
	for ($i = 0; $i < $qdeLinhas; $i++){
		$enderecoLinha1 = substr($enderecoCompleto, $iInicial, 76);
		$linha = preencheString($enderecoLinha1,76, '.');
	escreveLinha( $linha );
		
		$iInicial += 76;
	}	
	//$enderecoLinha1 = substr($enderecoCompleto, 0, 67);
	//$enderecoLinha2 = substr($enderecoCompleto, 67);
	//$linha = preencheString('com sede na '.$enderecoLinha1,76, '.');
	//escreveLinha( $linha );
	//$linha = preencheString($enderecoLinha2,76, '.');
	//escreveLinha( $linha );
}

$linha = preencheString( 'inscrita no CNPJ sob o nº '.getByTagName($identificacao,'nrcpfcgc').',  para  fins de redução de alí-' ,76);
escreveLinha( $linha );
$linha = preencheString( 'quota,  nas  operações de  crédito que tenham como mutuário pessoa jurídica ' ,76);
escreveLinha( $linha );
$linha = preencheString( 'optante pelo Regime Especial Unificado de Arrecadação de Tributos e Contri-' ,76);
escreveLinha( $linha );
$linha = preencheString( 'buições devidos  pelas  Microempresas e Empresas de Pequeno Porte – Simples ' ,76);
escreveLinha( $linha );
$linha = preencheString( 'Nacional, prevista no art. 7º, VI, do Decreto nº 6.306, de 14 de dezembro de' ,76);
escreveLinha( $linha );
$linha = preencheString( '2007, declara que: ' ,76);
escreveLinha( $linha );

escreveLinha( ' ' );

$linha = preencheString( 'a) se enquadra como pessoa jurídica optante pelo Simples Nacional de que ' ,76);
escreveLinha( $linha );
$linha = preencheString( 'trata a Lei Complementar nº. 123, de 14.12.2006; e ' ,76);
escreveLinha( $linha );

escreveLinha( ' ' );

$linha = preencheString( 'b) o(a) signatário é representante legal desta entidade, assumindo o ' ,76);
escreveLinha( $linha );
$linha = preencheString( 'compromisso de informar a essa instituição financeira, imediatamente, even-' ,76);
escreveLinha( $linha );
$linha = preencheString( 'tual desenquadramento da presente situação, e que está ciente de que a fal-' ,76);
escreveLinha( $linha );
$linha = preencheString( 'sidade na prestação destas informações o(a) sujeitará, juntamente com as de-' ,76);
escreveLinha( $linha );
$linha = preencheString( 'mais pessoas que a ela concorrerem, às penalidades previstas na legislação' ,76);
escreveLinha( $linha );
$linha = preencheString( 'criminal e tributária, relativas à falsidade ideológica (art. 299 do Código' ,76);
escreveLinha( $linha );
$linha = preencheString( 'Penal) e ao crime contra a ordem tributária (art. 1º da Lei nº 8.137, de de-' ,76);
escreveLinha( $linha );
$linha = preencheString( 'zembro de 1990).' ,76);
escreveLinha( $linha );

escreveLinha( ' ' );escreveLinha( ' ' );escreveLinha( ' ' );

$linha = preencheString( '____________________________________________________' ,76);
escreveLinha( $linha );

$linha = preencheString( 'Local e Data' ,76);
escreveLinha( $linha );

escreveLinha( '' );escreveLinha( '' );

$linha = preencheString( '____________________________________________________' ,76);
escreveLinha( $linha );

$linha = preencheString( 'Assinatura do Responsável' ,76);
escreveLinha( $linha );

escreveLinha( '' );escreveLinha( '' );

$linha = preencheString( '____________________________________________________' ,76);
escreveLinha( $linha );

$linha = preencheString( 'Abono da Assinatura pela instituição financeira' ,76);
escreveLinha( $linha );

echo '</pre>';
?>