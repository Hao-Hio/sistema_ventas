<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sistema Ventas-Login</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="vistas/assets/plugins/fontawesome-free/css/all.min.css">
  <!-- icheck bootstrap -->
  <link rel="stylesheet" href="vistas/assets/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="vistas/assets/dist/css/adminlte.min.css">
  <!-- SweetAlert2 -->
  <link rel="stylesheet" href="vistas/assets/plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</head>
<body class="hold-transition login-page">
<div class="login-box">
  
  
  <div class="card card-outline card-primary">
        <div class="card-header text-center">
            <h1 class="h1"><b>Sistema venta</b></h1>
        </div>
  

        <div class="card-body">
        <!-- FOrmulacion de inicio de sesion -->
            <form  method="POST" class="needs-validation-login" novalidate>
                <!-- USUARIO -->
                <div class="input-group mb-3">
                    <input class="form-control" type="text" placeholder="Usuario" name="loginUsuario" required>
                    <div class="input-group-append">
                        <div class="input-group-text">
                            <span class="fa fa-user"></span>
                        </div>
                    </div>
                    <div class="invalid-feedback">Debe ingresar su usuario</div>
                </div>
                <!-- CONTRASEÑA -->
                <div class="input-group mb-3">
                    <input class="form-control" type="password" placeholder="Contraseña" name="loginPassword" required>
                    <div class="input-group-append">
                        <div class="input-group-text">
                            <span class="fa fa-lock"></span>
                        </div>
                    </div>
                    <div class="invalid-feedback">Debe ingresar su contraseña</div>
                </div>

                <!-- BOTON PARA INGRESAR AL SISTEMA -->
                <div class="row">
                    <?php
                        $login = new UsuarioControlador();
                        $login -> login();
                    ?>
                    <div class="col-md-12 text-center">
                        <button type="submit" class="btn btn-info">Iniciar Sesion</button>
                    </div>
                </div>

            </form>

        </div>
    </div>
</div>
<!-- /.login-box -->

<!-- jQuery -->
<script src="vistas/assets/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="vistas/assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="vistas/assets/dist/js/adminlte.min.js"></script>
  <!-- SweetAlert2 -->
  <script src="vistas/assets/plugins/sweetalert2/sweetalert2.min.js"></script>
</body>
</html>
