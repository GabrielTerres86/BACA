<?php

/* 
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
* 
*  Classe principal, carrega configs, cabeçalho, rodapé e estrutura inicial do sistema
* 
*/

class Core {

	// inicializar variáveis
	private $configs = array(
								'env'				=> 'dev',
								'error_reporting'	=> 'E_ALL',
								'header'			=> false,
								'footer'			=> false,
								'charset'			=> 'UTF-8',
								'language'			=> 'pt-br',
								'title'				=> 'Ailos',
								'localhost' 		=> false
								);

	function __construct($configs = array()) {

	    if (count($configs) > 0) {
			$this->configs = array_merge($this->configs, $configs);
		}

		// check
		if($configs['localhost'] === true){
	        session_start();
  	    }

  	    // check again
		// check if SESSION is started | PHP < 5.4.0
		if(session_id() == ''){
			session_start();
		}

		# AMBIENTE - define as configurações baseando-se no ambiente

        //Atualizar configcore para recuperar em modo localhost
        if($configs['localhost']){
            $_SESSION['configCore'] = $configs;
        }

		switch ($this->configs['env']) {

			// dev
			case 'dev':
				error_reporting(E_ALL);
				break;
			
			// prod
			case 'prod':
				error_reporting(0);
				break;
			
			// null
			default:
				die('Ambiente não definido');
				break;
		}

		// if ($this->configs['localhost'] === false) {
		// 	session_start();

		// }

		# header
		if ($this->configs['header'] === true) {
			echo $this->header();
		}
	}

	function __destruct(){

		# footer
		if ($this->configs['footer'] === true) {
			echo $this->footer();
		}
	}

	public function header() {

		if(session_id() == ''){
			session_start();
		}


		// rand para carregar JS
		$v = rand(1000,9999);
		
		?>
			<!doctype html>
			<html lang="<?=$this->configs['language'];?>">
			  <head>
			    <!-- Required meta tags -->
			    <meta charset="<?=$this->configs['charset'];?>">
			    <meta name="viewport"   content="width=device-width, initial-scale=1, shrink-to-fit=no">

			    <!-- Bootstrap CSS -->
			    <link rel="stylesheet"  href="../node_modules/bootstrap/dist/css/bootstrap.min.css">
			    <link rel="stylesheet"  href="../node_modules/@fortawesome/fontawesome-free/css/all.min.css">
				<link rel="stylesheet"  href="../public/assets/css/style.css">
				<link rel="stylesheet"  href="../public/assets/css/custom.css?v=<?=$v?>">
				<link rel="icon" 		href="../public/assets/images/favicon-96x96.png" />
                <!-- filtroBusca -->
                <link rel="stylesheet"  href="../public/assets/css/filtroBusca.css?v=<?=$v?>">

			    <title><?=$this->configs['title'].($this->configs['localhost']?' - LOCALHOST' : '');?></title>

					<script>
					<?php
						if($this->configs['localhost']){
							?>
								var thisLocalhost = true;
							<?php
						}else{
							?>
								var thisLocalhost = false;
							<?php
						}
					?>
					</script>

			  </head>
			  <body>
				<div id="loading">
					<img src="assets/images/logos/coop0.png" alt="" class="imageAilosLoading"> <br>

					<!-- <div class="spinner"></div> -->
					<div class="loader"></div>
					<!-- <i class="fas fa-spinner fa-spin fa-2x"></i> <br> <br> -->
					<br>carregando informações... <br>

				</div>

				<div class="container-scroller" id="main-content">

				    <!-- partial:partials/_navbar.html -->
				    <nav class="navbar default-layout col-lg-12 col-12 p-0 fixed-top d-flex flex-row">
				      <div class="text-center navbar-brand-wrapper d-flex align-items-top justify-content-center">
				        <a class="navbar-brand brand-logo" href="#">

						<?php 
							// mudar o logo conforme cooperativa
							$_cdCoopper = 0;

							if(isset($_SESSION['glbvars'])){

								$_cdCoopper = (int) $_SESSION['glbvars']['cdcooper'];

							}else{

								if (isset($_GET['cdcooper'] ))
									$_cdCoopper = (int) $_GET['cdcooper'];

							}
					
							if (isset($_cdCoopper)) {

								switch ($_cdCoopper) {
									case '1':  echo '<img src="assets/images/logos/coop1.png">';  break;
									case '2':  echo '<img src="assets/images/logos/coop2.png">';  break;
									case '3':  echo '<img src="assets/images/logos/coop3.png">';  break;
									case '4':  echo '<img src="assets/images/logos/coop4.png">';  break;
									case '5':  echo '<img src="assets/images/logos/coop5.png">';  break;
									case '6':  echo '<img src="assets/images/logos/coop6.png">';  break;
									case '7':  echo '<img src="assets/images/logos/coop7.png">';  break;
									case '8':  echo '<img src="assets/images/logos/coop8.png">';  break;
									case '9':  echo '<img src="assets/images/logos/coop9.png">';  break;
									case '10': echo '<img src="assets/images/logos/coop10.png">'; break;
									case '11': echo '<img src="assets/images/logos/coop11.png">'; break;
									case '12': echo '<img src="assets/images/logos/coop12.png">'; break;
									case '13': echo '<img src="assets/images/logos/coop13.png">'; break;
									case '14': echo '<img src="assets/images/logos/coop14.png">'; break;
									case '15': echo '<img src="assets/images/logos/coop15.png">'; break;
									case '16': echo '<img src="assets/images/logos/coop16.png">'; break;
									case '99': echo '<img src="assets/images/logos/coopxy.png">'; break;
									default:   echo '<img src="assets/images/logos/coop3.png">';  break;
								}							
							} else {
								echo '<img src="assets/images/logos/coop3.png">';
							}
						?>

				        </a>
				        <a class="navbar-brand brand-logo-mini" href="#">
				          <img src="assets/images/logos/coop0.png">
				        </a>
				      </div>
				      <div class="navbar-menu-wrapper d-flex align-items-center">
				        <ul class="navbar-nav navbar-nav-left header-links d-none d-md-flex" id="html_personas">
							<!-- AQUI FILTRO DE PERSONAS -->
				        </ul>

				        <button class="navbar-toggler navbar-toggler-right d-lg-none align-self-center" type="button" data-toggle="offcanvas">
				          <i class="fas fa-bars"></i>
				        </button>
				      </div>
				    </nav>

				    <!-- partial -->
				    <div class="container-fluid page-body-wrapper">
				      <!-- partial:partials/_sidebar.html -->

				      <nav class="sidebar sidebar-offcanvas" id="sidebar">

                        <!-- FILTRO DE BUSCA -->
                        <div class="filtroBuscaDiv">
                            <div id="myDropdown" class="dropdown-content">
                                <input type="text" placeholder="Busca..." id="filtroBusca" autofocus="">
                                <div id='searchElements'>
                                	<!-- AQUI RENDERIZA RESULTADOS DA BUSCA -->
                                </div>
                            </div>
                        </div>

				        <ul class="nav" id="html_categorias">
				        	<!-- AQUI RENDERIZA FILTRO DE CATEGORIAS -->
				        	<li>
							<a href="pdf.php?token=<?=$_SESSION['token_pdf'];?>" target="_blank"><button class="btn btn-primary btn-gerar-pdf col-10" style="margin-left:9%; color: #fff;"><i class="fas fa-file-pdf" style="color: #fff !important;"></i> Gerar PDF</button></a>
							</li>
				        </ul>


				      </nav>
				      <!-- partial -->
				      <div class="main-panel">

						<div class="row html_sub_filtro">
							<div class="col-12">
					          <div class="row sub-menu html_avalista"></div>
					          <div class="row sub-menu html_grupo"></div>
					          <div class="row sub-menu html_quadro"></div>
				          	</div>
				        </div>

				        <div class="content-wrapper">

<!--                            <div class="row navbar">-->
<!--                                <ul class="menu">-->
<!--                                    <li><a href="#">One</a></li>-->
<!--                                    <li><a href="#">Two</a></li>-->
<!--                                    <li><a href="#">Three</a></li>-->
<!--                                    <li><a href="#">Four</a></li>-->
<!--                                </ul>-->
<!--                            </div>-->

							<!-- <div class="row purchace-popup"> -->
								<!-- <div class="col-12 text-right"> -->
									<!-- <button class="btn btn-primary"><i class="fas fa-file-pdf"></i> Gerar PDF</button> -->
<!--  									
										<span class="d-block d-md-flex align-items-right">
											jksfhjhsjfk
										</span> 
-->
								<!-- </div> -->
							<!-- </div> -->

 							<div class="row">
								<div class="col-12" id="html_blocos">
							          
									<!-- AQUI RENDERIZA TELAS -->

								</div>
							</div>
				        </div>
		<?php
	}

	public function footer() {

						// rand para carregar JS
						$v = rand(1000,9999);

				  	    // check again
						// check if SESSION is started | PHP < 5.4.0
						if(session_id() == ''){
							session_start();
						}

						?>

				      </div>
				      <!-- main-panel ends -->
				    </div>
				    <!-- page-body-wrapper ends -->
				  </div>
				  <!-- container-scroller -->


				<div id="side-by-side-bottom" class="row justify-content-center">
					<!-- rodapé que mostra as categorias selecionadas -->
				</div>

				<div id="side-by-side-decide" class="row justify-content-center">
					<!-- tela que mostra qual lado deve ser mostrada a categoria -->
				</div>

				<div id="side-by-side">
					<!-- exibição lado a lado -->
				</div>

				<div id="clone-gerar-pdf">
					a<!-- bloco usado para gerar pdf -->
				</div>

				<!-- BTN para auxiliar na homologação da tela -->
				<a href="getDataJson.php?token=<?=$_SESSION['token_json']?>" target="_blank">
					<button class="btn-json"><span>dev:</span> JSON</button>
				</a>

			    <script src="../node_modules/jquery/dist/jquery.min.js"></script>
			    <script src="../public/assets/js/popper.min.js"></script>
				<script src="../public/assets/js/off-canvas.js"></script>
				<script src="../public/assets/js/misc.js"></script>
                <!-- <script src="../public/assets/3rdparty/jsPDF-1.3.2/libs/html2canvas/dist/html2canvas.js"></script> -->
                <!-- <script src="../public/assets/3rdparty/jsPDF-1.3.2/libs/canvg_context2d/canvg.js"></script> -->
				<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.5.3/jspdf.debug.js" integrity="sha384-NaWTHo/8YCBYJ59830LTz/P4aQZK1sS0SneOgAvhsIl3zBu8r9RevNg5lHCHAuQ/" crossorigin="anonymous"></script> -->

				

				<!-- <script src="../public/assets/js/dashboard.js"></script> -->

				<script src="../public/assets/js/functions.js?v=<?=$v?>"></script>
				<script src="../public/assets/js/SideBySide.js?v=<?=$v?>"></script>
                <script src="../public/assets/js/filtroBusca.js?v=<?=$v?>"></script>
                <script src="../public/assets/js/filtros.js?v=<?=$v?>"></script>
				<script src="../public/assets/js/app.js?v=<?=$v?>"></script>


                <script src="../public/assets/js/plugins/select2.full.min.js"></script>

			  </body>
			</html>
		<?php
	}
}
?>