<?php
// tempo limite de execucao
set_time_limit(180);

// limite original de memoria para restaurar no final do arquivo
$original_mem = ini_get('memory_limit');

// novo limite de memoria
ini_set('memory_limit','1000M');

// Increase max_execution_time. If a large pdf fails, increase it even more.
ini_set('max_execution_time', 180);

// Increase this for old PHP versions (like 5.3.3). If a large pdf fails, increase it even more.
ini_set('pcre.backtrack_limit', 1000000);

// máscara de formatação
function mask($val, $mask){

 $maskared = '';
 $k = 0;

 for($i = 0; $i<=strlen($mask)-1; $i++) {
	 if($mask[$i] == '#') {
	 	if(isset($val[$k]))
	 		$maskared .= $val[$k++];
	 } else {
	 	if(isset($mask[$i]))
	 		$maskared .= $mask[$i];
		}
 	}
	return $maskared;
}

// formata conta
function mask_conta($val) {

	$val = (string) $val;

	$count_conta = strlen($val);

	switch ($count_conta) {
		case '1': $mask = '#'; break;
		case '2': $mask = '#.#'; break;
		case '3': $mask = '##.#'; break;
		case '4': $mask = '###.#'; break;
		case '5': $mask = '#.###.#'; break;
		case '6': $mask = '##.###.#'; break;
		case '7': $mask = '###.###.#'; break;
		case '8': $mask = '####.###.#'; break;
	}

	$maskared = mask($val, $mask);

	return $maskared;
}

// formata proposta
function mask_proposta($val) {

	$val = (string) $val;

	$count_proposta = strlen($val);

	switch ($count_proposta) {
		case '1': $mask = '#'; break;
		case '2': $mask = '##'; break;
		case '3': $mask = '###'; break;
		case '4': $mask = '#.###'; break;
		case '5': $mask = '##.###'; break;
		case '6': $mask = '###.###'; break;
		case '7': $mask = '#.###.###'; break;
		case '8': $mask = '##.###.###'; break;
	}

	$maskared = mask($val, $mask);

	return $maskared;
}



#   PDF

    header("Content-type: text/html; charset=utf-8");
	ini_set('session.cookie_domain', '.cecred.coop.br' );
    session_start();

    // cooperativa
	if(isset($_SESSION['glbvars'])){
	    
	    $glbvars = $_SESSION['glbvars'];

	    if(!isset($glbvars["cdcooper"])){
	        $keys = array_keys($_SESSION['glbvars']);
	        $glbvars = $_SESSION['glbvars'][$keys[0]];
	    }

	    // cod cooperativa
	    $cdcooper = $glbvars['cdcooper'];

	} else {

	    // cod cooperativa
	    $cdcooper = 3;
	}

	# cooperativa
	if (isset($_SESSION['params']['cdcooper'])) {
		switch ($_SESSION['params']['cdcooper']) {
				case '1' : $aux = "COOPERATIVA DE CREDITO DO VALE DO ITAJAI - VIACREDI"; break;
				case '2' : $aux = "COOPERATIVA DE CREDITO DO NORTE CATARINENSE - ACREDICOOP"; break;
				case '3' : $aux = "COOPERATIVA CENTRAL DE CREDITO - AILOS"; break;
				case '5' : $aux = "COOPERATIVA DE CREDITO DE LIVRE ADMIS DO SUL CATAR - ACENTRA"; break;
				case '6' : $aux = "COOP DE CREDITO DOS EMPREGADOS DO SISTEMA FIESC - CREDIFIESC"; break;
				case '7' : $aux = "COOP ECON CRED MUT PROFIS CREA EST SANTA CATARINA - CREDCREA"; break;
				case '8' : $aux = "COOP DE ECON E CRED MUTUO DOS EMPREGADOS DA CELESC - CREDELESC"; break;
				case '9' : $aux = "COOP ECON CRED MUTUO DOS EMPRESARIOS TRANSP DE SC - TRANSPOCRED"; break;
				case '10': $aux = "COOPERATIVA DE CREDITO DA SERRA CATARINENSE - CREDICOMIN"; break;
				case '11': $aux = "COOPERATIVA DE CREDITO DA FOZ DO RIO ITAJAI ACU - CREDIFOZ"; break;
				case '12': $aux = "COOP CRED LIVRE ADMISSAO ASSOC GUARAMIRIM - CREVISC"; break;
				case '13': $aux = "COOPERATIVA DE CREDITO DA REGIAO DO CONTESTADO - CIVIA"; break;
				case '14': $aux = "COOP CRED DA REGIAO DO SUDOESTE DO PARANA - EVOLUA"; break;
				case '16': $aux = "COOPERATIVA DE CREDITO DO ALTO VALE DO ITAJAI - VIACREDI ALTO VALE"; break;
				default  : $aux = "COOPERATIVA CENTRAL DE CREDITO - AILOS"; break;
			}	
	} else {
		$aux = "-";
	}
	define(COOPERATIVA, $aux);

	# produto
	if (isset($_SESSION['params']['tpproduto'])) {
		switch ($_SESSION['params']['tpproduto']) {
				case '2' : $aux = "Proposta de Empréstimo e Financiamento"; break;
				case '6' : $aux = "Proposta de Limite de Desconto de Títulos"; break;
				case '4' : $aux = "Proposta de Borderô de Desconto de Títulos"; break;
				case '5' : $aux = "Proposta de Cartão de Crédito"; break;
				default  : $aux = "Não definido"; break;
			}	
	} else {
		$aux = "-";
	}
	define(PRODUTO,      $aux);

	# data da proposta (XML)
	if (isset($_SESSION['data'])) {
		define(DATA_ANALISE, $_SESSION['data']);
	} else {
		define(DATA_ANALISE, '-');
	}

	# conta
	if (isset($_SESSION['params']['nrdconta'])) {
		$conta = mask_conta($_SESSION['params']['nrdconta']);
		define(CONTA, $conta);
	} else {
		define(CONTA,        '-');
	}

	# proposta
	if (isset($_SESSION['params']['nrproposta'])) {
		$proposta = mask_proposta($_SESSION['params']['nrproposta']);
		define(PROPOSTA, $proposta);
	} else {
		define(CONTA,        '-');
	}

	# logo cooperativa

	// mudar o logo conforme cooperativa
	if (isset($_SESSION['globalCDCOOPER'])) {

		switch ($_SESSION['globalCDCOOPER']) {
	
			case '1':  $logo_coop = 'coop1_pdf.png';  break;
			case '2':  $logo_coop = 'coop2_pdf.png';  break;
			case '3':  $logo_coop = 'coop3_pdf.png';  break;
			case '4':  $logo_coop = 'coop4_pdf.png';  break;
			case '5':  $logo_coop = 'coop5_pdf.png';  break;
			case '6':  $logo_coop = 'coop6_pdf.png';  break;
			case '7':  $logo_coop = 'coop7_pdf.png';  break;
			case '8':  $logo_coop = 'coop8_pdf.png';  break;
			case '9':  $logo_coop = 'coop9_pdf.png';  break;
			case '10': $logo_coop = 'coop10_pdf.png'; break;
			case '11': $logo_coop = 'coop11_pdf.png'; break;
			case '12': $logo_coop = 'coop12_pdf.png'; break;
			case '13': $logo_coop = 'coop13_pdf.png'; break;
			case '14': $logo_coop = 'coop14_pdf.png'; break;
			case '15': $logo_coop = 'coop15_pdf.png'; break;
			case '16': $logo_coop = 'coop16_pdf.png'; break;
			case '99': $logo_coop = 'coopxy_pdf.png'; break;
			default:   $logo_coop = 'coop3_pdf.png';  break;
		}	

	} else {
		$logo_coop = 'coop3_pdf.png';
	}

    // verifica se existe um token
    if (isset($_GET['token'])) {
    
        // recebe o token
        $token = $_GET['token'];

        // verifica se existe uma sessao com o nome desse token
        if (isset($_SESSION[$token])) {

            $blocos_html = $_SESSION[$token];
            $blocos_pdf  = '';

            foreach ($blocos_html as $key => $value) {
            	$blocos_pdf .= $value;
            }

        } else { 

            echo 'sem acesso';
            die();
        }

    } else {

        echo 'sem acesso';
        die();
    }

// echo $blocos_pdf;

// die();

/**
 * Define the following constant to ignore the default configuration file.
 */
define ('K_TCPDF_EXTERNAL_CONFIG', true);

/**
 * Installation path (/var/www/tcpdf/).
 * By default it is automatically calculated but you can also set it as a fixed string to improve performances.
 */
//define ('K_PATH_MAIN', '');

/**
 * URL path to tcpdf installation folder (http://localhost/tcpdf/).
 * By default it is automatically set but you can also set it as a fixed string to improve performances.
 */
//define ('K_PATH_URL', '');

/**
 * Path for PDF fonts.
 * By default it is automatically set but you can also set it as a fixed string to improve performances.
 */
//define ('K_PATH_FONTS', K_PATH_MAIN.'fonts/');

/**
 * Default images directory.
 * By default it is automatically set but you can also set it as a fixed string to improve performances.
 */
define ('K_PATH_IMAGES', dirname(__FILE__).'/assets/images/logos/');

/**
 * Deafult image logo used be the default Header() method.
 * Please set here your own logo or an empty string to disable it.
 */
define ('PDF_HEADER_LOGO', $logo_coop);
// echo K_PATH_IMAGES;
// echo '<br>';
// echo PDF_HEADER_LOGO;
// die();
/**
 * Header logo image width in user units.
 */
define ('PDF_HEADER_LOGO_WIDTH', 55);

/**
 * Cache directory for temporary files (full path).
 */
define ('K_PATH_CACHE', sys_get_temp_dir().'/');

/**
 * Generic name for a blank image.
 */
define ('K_BLANK_IMAGE', '_blank.png');

/**
 * Page format.
 */
define ('PDF_PAGE_FORMAT', 'A4');

/**
 * Page orientation (P=portrait, L=landscape).
 */
define ('PDF_PAGE_ORIENTATION', 'P');

/**
 * Document creator.
 */
define ('PDF_CREATOR', 'Central Ailos');

/**
 * Document author.
 */
define ('PDF_AUTHOR', 'Central Ailos');

/**
 * Header title.
 */
define ('PDF_HEADER_TITLE', '');

/**
 * Header description string.
 */
$texto_header = "Cooperativa: " . COOPERATIVA . "\nProduto: " . PRODUTO . "\nData de Envio para Análise: " . DATA_ANALISE . "\nConta: " . CONTA . "\nProposta: " . PROPOSTA . "\n ";
define ('PDF_HEADER_STRING', $texto_header);

/**
 * Document unit of measure [pt=point, mm=millimeter, cm=centimeter, in=inch].
 */
define ('PDF_UNIT', 'mm');

/**
 * Header margin.
 */
define ('PDF_MARGIN_HEADER', 2);

/**
 * Footer margin.
 */
define ('PDF_MARGIN_FOOTER', 10);

/**
 * Top margin.
 */
define ('PDF_MARGIN_TOP', 36);

/**
 * Bottom margin.
 */
define ('PDF_MARGIN_BOTTOM', 20);

/**
 * Left margin.
 */
define ('PDF_MARGIN_LEFT', 12);

/**
 * Right margin.
 */
define ('PDF_MARGIN_RIGHT', 12);

/**
 * Default main font name.
 */
define ('PDF_FONT_NAME_MAIN', 'helvetica');

/**
 * Default main font size.
 */
define ('PDF_FONT_SIZE_MAIN', 8);

/**
 * Default data font name.
 */
define ('PDF_FONT_NAME_DATA', 'helvetica');

/**
 * Default data font size.
 */
define ('PDF_FONT_SIZE_DATA', 2);

/**
 * Default monospaced font name.
 */
define ('PDF_FONT_MONOSPACED', 'courier');

/**
 * Ratio used to adjust the conversion of pixels to user units.
 */
define ('PDF_IMAGE_SCALE_RATIO', 1.10);

/**
 * Magnification factor for titles.
 */
define('HEAD_MAGNIFICATION', 1);

/**
 * Height of cell respect font height.
 */
define('K_CELL_HEIGHT_RATIO', 1.6);

/**
 * Title magnification respect main font size.
 */
define('K_TITLE_MAGNIFICATION', 1);

/**
 * Reduction factor for small font.
 */
define('K_SMALL_RATIO', 2/3);

/**
 * Set to true to enable the special procedure used to avoid the overlappind of symbols on Thai language.
 */
define('K_THAI_TOPCHARS', true);

/**
 * If true allows to call TCPDF methods using HTML syntax
 * IMPORTANT: For security reason, disable this feature if you are printing user HTML content.
 */
define('K_TCPDF_CALLS_IN_HTML', true);

/**
 * If true and PHP version is greater than 5, then the Error() method throw new exception instead of terminating the execution.
 */
define('K_TCPDF_THROW_EXCEPTION_ERROR', true);

//============================================================+
// END OF CONFIG
//============================================================+

require_once('assets/3rdparty/TCPDF-master/tcpdf.php');

// create new PDF document
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// set document information
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('CENTRAL AILOS');
$pdf->SetTitle('Tela Única de Análise de Crédito');
$pdf->SetSubject('');
$pdf->SetKeywords('proposta, análise, única, ailos, cooperativa, central');

// set default header data
$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);

// set header and footer fonts
$pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, '', PDF_FONT_SIZE_MAIN));
$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));

// set default monospaced font
$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// set margins
$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
$pdf->SetHeaderMargin(PDF_MARGIN_HEADER);
$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);

// set auto page breaks
$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

// set image scale factor
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// set some language-dependent strings (optional)
if (@file_exists(dirname(__FILE__).'/lang/bra.php')) {
	require_once(dirname(__FILE__).'/lang/bra.php');
	$pdf->setLanguageArray($l);
}

// set font
$pdf->SetFont('dejavusans', '', 8);
$pdf->SetCellPadding(0);
// add a page
$pdf->AddPage();

// writeHTML($html, $ln=true, $fill=false, $reseth=false, $cell=false, $align='')
// writeHTMLCell($w, $h, $x, $y, $html='', $border=0, $ln=0, $fill=0, $reseth=true, $align='', $autopadding=true)

// create some HTML content

$html = '<html><head><style>

	.erroTagXML {
		color:red;
	}

	* {
		line-height: 7px;
		margin: 0;
		padding: 0;
	}

	.primeira-linha {
		color: #222;
		font-weight: bold;
		font-size: 7px;
	}

	table {
		font-family: arial;
		font-size: 6px;
		line-height: 10px;
	}

	td {
		border: 0px solid #fff;
	}

	.tabela-pdf{
		border: 2px	solid #ddd;
	}

	.tabela-pdf td{
		border: 1px	solid #fff;
	}

	.tabela-pdf .zebra1{
		background-color: #f5f5f5;
	}

	.tabela-pdf .zebra2{
		background-color: #eee;
	}

	.titulo-categoria-pdf {
		color: #003377;
		font-size: 11px;
	}

	.title-erro {
		color: red;

	}

	.title-table i{
		color: #666;
	}

	.text-gray {

	}

	.tag-personalizada {

	}

	.tag-informacao {
		color: blue;
	}

	.tag-atencao {
		color: orange;
	}

	.tag-desconhecida {
		color: red;

	}

	.tag-h1 {
		font-size: 9px;
		line-height: 45px;
	}

	.tag-h2 {
		font-size: 8px;
		line-height: 35px;
	}

	.tag-h3 {
		font-size: 7px;
		line-height: 20px;
	}

</style><head><body>';

$html .= $blocos_pdf;

// echo $blocos_pdf;
// die();

// output the HTML content
$pdf->writeHTML($html, true, false, true, false, '');

// reset pointer to the last page
$pdf->lastPage();

// gerar nome
$time = mktime();
$sort = rand(1,99999);
$nome = $time.$sort;
$nome = md5($nome);
$nome = $nome.'.pdf';

//Close and output PDF document
$pdf->Output($nome, 'I');

// at the end of the script set it to it's original value 
// (if you forget this PHP will do it for you when performing garbage collection)
ini_set('memory_limit',$original_mem);
