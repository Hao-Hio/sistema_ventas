<div class="content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-6">
                <h4 class="m-0">Administrar Modulos y perfiles</h4>
            </div>
            <div class="col-md-6">
                <ol class="breadcrumb float-md-right">
                    <li class="breadcrumb-item"><a href="index.php">Inicio</a></li>
                    <li class="breadcrumb-item">Administrar modulos y perfiles</li>

                </ol>
            </div>
        </div>
    </div>
</div>

<div class="content">
    <div class="container-fuiid">

        <ul class="nav nav-tabs" id="tabs-asignar-modulos-perfil" role="tablist">

            <li class="nav-item">
                <a class="nav-link" id="content-perfiles-tab" data-toggle="pill" href="#content-perfiles" role="tab" aria-controls="content-perfiles" aria-selected="false">Perfiles</a>
            </li>

            <li class="nav-item">
                <a class="nav-link" id="content-modulos-tab" data-toggle="pill" href="#content-modulos" role="tab" aria-controls="content-modulos" aria-selected="false">Modulos</a>
            </li>

            <li class="nav-item">
                <a class="nav-link active" id="content-modulo-perfil-tab" data-toggle="pill" href="#content-modulo-perfil" role="tab" aria-controls="content-modulo-perfil" aria-selected="false">Asignar modulo a perfil</a>
            </li>

        </ul>

        <div class="tab-content" id="tabsContent-asignar-modulos-perfil">

            <div class="tab-pane fade mt-4 px-4" id="content-perfiles" role="tabpanel" aria-labelledby="content-perfiles-tab">
                <h4>Administrar Perfiles</h4>
            </div>

            <!--============================================================================================================================================
            CONTENIDO PARA MODULOS 
            =============================================================================================================================================-->
            <div class="tab-pane fade  mt-4 px-4" id="content-modulos" role="tabpanel" aria-labelledby="content-modulos-tab">

                <div class="row">

                    <!--LISTADO DE MODULOS -->
                    <div class="col-md-6">

                        <div class="card card-info card-outline shadow">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-list"></i> Listado de Módulos</h3>

                            </div>

                            <div class="card-body">

                                <table id="tblModulos" class="display nowrap table-striped shadow rounded" style="width:100%">

                                    <thead class="bg-info text-left">
                                        <th class="text-center">Acciones</th>
                                        <th>id</th>
                                        <th>orden</th>
                                        <th>Módulo</th>
                                        <th>Módulo Padre</th>
                                        <th>Vista</th>
                                        <th>Icono</th>
                                        <th>F. Creación</th>
                                        <th>F. Actualización</th>
                                    </thead>
                                    <tbody class="small text left">

                                    </tbody>

                                </table>

                            </div>

                        </div>

                    </div><!--/. col-md-6 -->

                    <!--FORMULARIO PARA REGISTRO Y EDICION -->
                    <div class="col-md-3">

                        <div class="card card-info card-outline shadow">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-edit"></i> Registro de Módulos</h3>

                            </div>

                            <div class="card-body">

                                <form method="post" class="needs-validation-registro-modulo" novalidate id="frm_registro_modulo">

                                    <div class="row">

                                        <div class="col-md-12">

                                            <div class="form-group mb-2">

                                                <label for="iptModulo" class="m-0 p-0 col-sm-12 col-form-label-sm">
                                                    <span class="small">Módulo</span><span class="text-danger">*</span>
                                                </label>

                                                <div class="input-group m-0">
                                                    <input type="text" class="form-control form-control-sm" id="iptModulo" name="iptModulo" placeholder="Ingrese el módulo" required>
                                                    <div class="input-group-append">
                                                        <span class="input-group-text bg-info"><i class="fas fa-laptop text-white fs-6"></i></span>
                                                    </div>
                                                    <div class="invalid-feedback">Debe ingresar el módulo</div>
                                                </div>

                                            </div>

                                        </div>

                                        <div class="col-md-12">

                                            <div class="form-group mb-2">

                                                <label for="iptVistaModulo" class="m-0 p-0 col-sm-12 col-form-label-sm">
                                                    <span class="small">Vista PHP</span>
                                                </label>

                                                <div class="input-group m-0">
                                                    <input type="text" class="form-control form-control-sm" id="iptVistaModulo" name="iptVistaModulo">
                                                    <div class="input-group-append">
                                                        <span class="input-group-text bg-info"><i class="fas fa-code text-white fs-6"></i></span>
                                                    </div>

                                                </div>
                                            </div>

                                        </div>

                                        <div class="col-md-12">

                                            <div class="form-group mb-2">

                                                <label for="iptIconoModulo" class="m-0 p-0 col-sm-12 col-form-label-sm">
                                                    <span class="small">Icono</span><span class="text-danger">*</span>
                                                </label>

                                                <div class="input-group m-0">
                                                    <input type="text" placeholder="<i class='far fa-circle'></i>" class="form-control form-control-sm" id="iptIconoModulo" name="iptIconoModulo" required>
                                                    <div class="input-group-append">
                                                        <span class="input-group-text bg-info" id="spn_icono_modulo"><i class="far fa-circle text-white fs-6"></i></span>
                                                    </div>
                                                    <div class="invalid-feedback">Debe ingresar el Icono del módulo</div>
                                                </div>

                                            </div>

                                        </div>

                                        <div class="col-md-12">

                                            <div class="form-group m-0 mt-2">

                                                <button type="button" class="btn btn-success w-100" id="btnRegistrarModulo">Guardar Módulo</button>

                                            </div>

                                        </div>

                                    </div>

                                </form>

                            </div>

                        </div>

                    </div><!--/. col-md-3 -->

                    <!--ARBOL DE MODULOS PARA REORGANIZAR -->
                    <div class="col-md-3">

                        <div class="card card-info card-outline shadow">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-edit"></i> Organizar Módulos</h3>

                            </div>

                            <div class="card-body">

                                <div class="">

                                    <div>Modulos del Sistema</div>

                                    <div class="" id="arbolModulos"></div>

                                </div>

                                <hr>

                                <div class="row">

                                    <div class="col-md-12">

                                        <div class="text-center">

                                            <button id="btnReordenarModulos" class="btn btn-success mt-3 " style="width: 45%;">Organizar Módulos</button>

                                            <button id="btnReiniciar" class="btn btn-warning mt-3 " style="width: 45%;">Estado Inicial</button>

                                        </div>

                                    </div>

                                </div>

                            </div>

                        </div>

                    </div><!--/. col-md-3 -->

                </div><!--/.row -->

            </div><!-- /#content-modulos -->

            <div class="tab-pane fade active show mt-4 px-4" id="content-modulo-perfil" role="tabpanel" aria-labelledby="content-modulo-perfil-tab">
                <div class="row">
                    <div class="col-md-8">
                        <div class="card card-info card-outline shadow">

                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-list"></i> Listado de Perfiles</h3>
                            </div>

                            <div class="card-body">
                                <table id="tbl_perfiles_asignar" class="display nowrap table-striped w-100 shadow rounded">
                                    <thead class="bg-info text-left">
                                        <th>ID perfil</th>
                                        <th>Perfil</th>
                                        <th>Estado</th>
                                        <th>F.Creacion</th>
                                        <th>F.Actualizacion</th>
                                        <th class="text-center">Opciones</th>
                                    </thead>

                                    <tbody class="small text-left">

                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card card-info card-outline shadow" style="display:block" id="card-modulos">

                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-laptop"></i>Modulo del Sistema</h3>
                            </div>

                            <div class="card-body" id="card-body-modulos">
                                <div class="row m-2">

                                    <div class="col-md-6">
                                        <button class="btn btn-success btn-small m-0 p-0 w-100" id="marcar_modulos">Marcar todo</button>
                                    </div>

                                    <div class="col-md-6">
                                        <button class="btn btn-danger btn-small m-0 p-0 w-100" id="desmarcar_modulos">Desmarcar todo</button>
                                    </div>

                                    <div id="modulos" class="demo"></div>

                                    <div class="row m-2">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>Selecione el modulo de inicio</label>
                                                <select class="custom-select" id="select_modulos">

                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-12">
                                            <button class="btn btn-success btn-small w-50 text-center" id="asignar_modulos">Asigar</button>
                                        </div>
                                    </div>

                                </div>

                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </div>

    </div>
</div>

<script>
    /*================================================================
        VARIABLES GLObALES
        ================================================================*/
    var tbl_perfiles_asignar, tbl_modulos, modulos_usuario, modulos_sistema;

    $(document).ready(function() {


        /*================================================================
        FUNCIONES PARA LAS CARGAS INICIALES  DE DATABLES, ARBOL DE MODULOS Y REAJUSTE DE CABECERAS DE DATATABLES
        ================================================================*/
        cargarDataTables();
        ajustarHeadersDataTables($('#tblModulos'));
        iniciarArbolModulos();

        /*================================================================
        VARIABLES PARA REGISTRAR EL PERFIL Y LOS MODULOS SELECCIONADOS
        ================================================================*/
        var idPerfil = 0;
        var selectedElmsIds = [];

        $('#tbl_perfiles_asignar tbody').on('click', '.btnSeleccionarPerfil', function() {

            var data = tbl_perfiles_asignar.row($(this).parents('tr')).data();

            if ($(this).parents('tr').hasClass('selected')) {

                $(this).parents('tr').removeClass('selected');

                $('#modulos').jstree("deselect_all", false);

                $("#select_modulos option").remove();

                idPerfil = 0;

            } else {
                tbl_perfiles_asignar.$('tr.selected').removeClass('selected');

                $(this).parents('tr').addClass('selected');

                idPerfil = data[0];

                //alert(idPerfil);

                $.ajax({
                    async: false,
                    url: "ajax/modulo.ajax.php",
                    method: 'POST',
                    data: {
                        accion: 2,
                        id_perfil: idPerfil
                    },
                    dataType: 'json',
                    success: function(respuesta) {
                        console.log(respuesta);

                        modulos_usuario = respuesta;

                        seleccionarModulosPerfil(idPerfil);
                    }
                });
            }
        });

        $("#modulos").on("changed.jstree", function(evt, data) {

            $("#select_modulos option").remove();

            var selectedElms = $("#modulos").jstree("get_selected", true);
            console.log(selectedElms);

            $.each(selectedElms, function() {

                for (let i = 0; i < modulos_sistema.length; i++) {
                    if (modulos_sistema[i]["id"] == this.id && modulos_sistema[i]["vista"]) {
                        $('#select_modulos').append($('<option>', {
                            value: this.id,
                            text: this.text
                        }));
                    }

                }
            })

            if ($("#select_modulos").has('option').length <= 0) {

                $('#select_modulos').append($('<option>', {
                    value: 0,
                    text: "No hay modulos seleccionados"
                }));
            }
        })

        /*================================================================
        EVENTO PARA MARCAR TODOS LOS CHECKBOX DEL ARBOL DE MODULOS
        ================================================================*/
        $("#marcar_modulos").on('click', function() {
            $('#modulos').jstree('select_all');
        })

        /*================================================================
        EVENTO PARA DESMARCAR TODOS LOS CHECKBOX DEL ARBOL DE MODULOS
        ================================================================*/
        $("#desmarcar_modulos").on('click', function() {

            $('#modulos').jstree('deselect_all', false);
            $("#select_modulos option").remove();

            $('#select_modulos').append($('<option>', {
                value: 0,
                text: "No hay modulos seleccionados"
            }));
        })

        /*================================================================
        REGISTRO EN BASE DE DATOS DE LOS MODULOS ASOCIADOS AL PERFIL
        ================================================================*/
        $("#asignar_modulos").on('click', function() {

            selectedElmsIds = []
            var selectedElms = $('#modulos').jstree("get_selected", true);

            $.each(selectedElms, function() {

                selectedElmsIds.push(this.id);

                if (this.parent != "#") {
                    selectedElmsIds.push(this.parent);
                }
            });

            //quitamos valores repetidos
            let modulosSelecionados = [...new Set(selectedElmsIds)];

            let modulo_inicio = $("#select_modulos").val();

            // console.log(modulosSelecionados);
            if (idPerfil != 0 && modulosSelecionados.length > 0) {
                registrarPerfilModulo(modulosSelecionados, idPerfil, modulo_inicio);
            } else {
                Swal.fire({
                    position: 'center',
                    icon: 'warning',
                    title: 'Debes selecionar el perfil y modulo a registrar',
                    showConfirmButton: false,
                    timer: 2000
                })
            }

        })

        /*================================================================
        ================================================================
                        MANTENIMIENTO DE MODULO
        ================================================================
        ================================================================*/

        fnCargarArbolModulos();

        /*================================================================
        ORGANIZAR MODULOS DEL SISTEMA
        ================================================================*/
        $("#btnReordenarModulos").on('click', function() {
            fnOrganizarModulos();
        })

        /*================================================================
        REINICIAR MODULOS DEL SISTEMA EN EL JSTREE
        ================================================================*/
        $("#btnReiniciar").on('click', function() {
            actualizarArbolModulos();
        })

        /*================================================================
        VISTA PREVIA DEL ICONO dela avista
        ================================================================*/
        $("#iptIconoModulo").change(function() {

            $("#spn_icono_modulo").html($("#iptIconoModulo").val())
            //console.log($('#snp_icono_modulo').attr('class'))
            //console.log($('#iptIconoModulo').val())

            if ($("#iptIconoModulo").val().length === 0) {

                $("#snp_icono_modulo").html("<i class='fa fas-circle fs-6 text-white'></i>")
            }
        })

        /*================================================================
        EVENTOS QUE GUARDAN LOS DATOS DEL MODULO <i class="fa fas-yin-yang"></i>
        ================================================================*/
        document.getElementById("btnRegistrarModulo").addEventListener("click", function() {
            fnRegistrarModulo();
        })

    }) // FIN DEL DOCUMENT READY

    function cargarDataTables() {
        tbl_perfiles_asignar = $('#tbl_perfiles_asignar').DataTable({
            ajax: {
                async: false,
                url: 'ajax/perfil.ajax.php',
                type: 'POST',
                dataType: 'json',
                dataSrc: "",
                data: {
                    accion: 1
                }
            },
            columnDefs: [{
                    targets: 2,
                    sortable: false,
                    createdCell: function(td, cellData, rowData, row, col) {

                        if (parseInt(rowData[2]) == 1) {
                            $(td).html("Activo")
                        } else {
                            $(td).html("Inactivo")
                        }
                    }
                },
                {
                    targets: 5,
                    sortable: false,
                    render: function(data, type, full, meta) {
                        return "<center>" +
                            "<span class='btnSeleccionarPerfil text-primary px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Seleccionar perfil'> " +
                            "<i class='fas fa-check fs-5'></i>" +
                            "</span>" +
                            "</center>";
                    }
                }
            ],
            language: {
                url: "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
            }
        });

        tbl_modulos = $('#tblModulos').DataTable({

            ajax: {
                async: false,
                url: 'ajax/modulo.ajax.php',
                type: 'POST',
                dataType: 'json',
                dataSrc: "",
                data: {
                    'accion': 3
                }
            },
            columnDefs: [{
                    targets: 7,
                    visible: false,
                },
                {
                    targets: 8,
                    visible: false,
                },
                {
                    targets: 0,
                    sortable: false,
                    render: function(data, type, full, meta) {
                        return "<center>" +
                            "<span class='fas fa-edit fs-6 btnSeleccionarModulo text-primary px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Seleccionar modulo'> " +
                            "</span>" +
                            "<span class='fas fa-trash fs-6 btnEliminarModulo text-danger px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Eliminar modulo'> " +
                            "</span>"
                        "</center>";
                    }
                }
            ],
            scrollX: true,
            order: [
                [2, 'asc']
            ],
            lengthMenu: [0, 5, 10, 15, 20, 50],
            pageLength: 20,
            language: {
                url: "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
            }
        });

    }

    function ajustarHeadersDataTables(element) {

        var observer = window.ResizeObserver ? new ResizeObserver(function(entries) {
            entries.forEach(function(entry) {
                $(entry.target).DataTable().columns.adjust();
            });
        }) : null;

        // Function to add a datatable to the ResizeObserver entries array
        resizeHandler = function($table) {
            if (observer)
                observer.observe($table[0]);
        };

        // Initiate additional resize handling on datatable
        resizeHandler(element);
    }

    function iniciarArbolModulos() {
        $.ajax({
            async: false,
            url: 'ajax/modulo.ajax.php',
            method: 'POST',
            data: {
                accion: 1
            },
            dataType: 'json',
            success: function(respuesta) {

                modulos_sistema = respuesta;
                console.log(respuesta);

                //INICIAR LA DEMO 
                $('#modulos').jstree({
                    'core': {
                        "check_callback": true,
                        'data': respuesta
                    },
                    'checkbox': {
                        "keep_selected_style": true
                    },
                    'types': {
                        "default": {
                            "icon": "fas fa-laptop text-warning"
                        }
                    },
                    "plugins": ["wholerow", "checkbox", "types", "changed"]
                }).bind("loaded.jstree", function(event, data) {
                    $(this).jstree("open_all");
                });
            }
        })
    }

    /* function seleccionarModulosPerfil(pin_idPerfil) {

         $('#modulos').jstree('deselect_all');

         for (let i = 0; i < modulos_sistema.length; i++) {

             if (modulos_sistema[i]["id"] == modulos_usuario[i]["id"] && modulos_usuario[i]["sel"] == 1) {

                 $("#modulos").jstree("select_node", modulos_sistema[i]["id"]);

             

             }

         }
     }*/

    function seleccionarModulosPerfil(pin_idPerfil) {
        $('#modulos').jstree('deselect_all');

        modulos_usuario.forEach(moduloUsuario => {
            const moduloSistema = modulos_sistema.find(modulo => modulo.id === moduloUsuario.id);

            if (moduloSistema && moduloUsuario.SEL === "1") {
                $("#modulos").jstree("select_node", moduloSistema.id);
            }
        });

        //Ocultamos la opcion de modulos y perfiles para el perfil de administrador
        if (pin_idPerfil == 1) { //SOLO PERFIL ADMINISTRADOR
            $("#modulos").jstree(true).hide_node(13);
        } else {
            $("#modulos").jstree(true).show_all();
        }
    }

    function registrarPerfilModulo(modulosSeleccionados, idPerfil, idModulo_inicio) {

        $.ajax({
            async: false,
            url: 'ajax/perfil_modulo.ajax.php',
            method: 'POST',
            data: {
                accion: 1,
                id_modulosSeleccionados: modulosSeleccionados,
                id_Perfil: idPerfil,
                id_modulo_inicio: idModulo_inicio
            },
            dataType: 'json',
            success: function(respuesta) {
                if (respuesta > 0) {
                    Swal.fire({
                        position: 'center',
                        icon: 'success',
                        title: 'Se registro correctamente',
                        showConfirmButton: false,
                        timer: 2000
                    })

                    $("#select_modulos option").remove();
                    $('#modulos').jstree("deselect_all", false);
                    tbl_perfiles_asignar.ajax.reload();

                } else {
                    Swal.fire({
                        position: 'center',
                        icon: 'error',
                        title: 'Error al registrar',
                        showConfirmButton: false,
                        timer: 2000
                    })

                }
            }
        });
    }

    function actualizarArbolModulosPerfiles() {
        $.ajax({
            async: false,
            url: 'ajax/modulo.ajax.php',
            method: 'POST',
            data: {
                accion: 1
            },
            dataType: 'json',
            success: function(respuesta) {
                modulos_sistema = respuesta;

                $("#modulos").jstree(true).settings.core.data = respuesta;
                $("#modulos").jstree(true).refresh();
            }
        });
    }

    /*================================================================
        ================================================================
                        MANTENIMIENTO DE MODULO
        ================================================================
        ================================================================*/

    function fnCargarArbolModulos() {

        var dataSource;

        $.ajax({
            async: false,
            url: 'ajax/modulo.ajax.php',
            method: 'POST',
            data: {
                accion: 1
            },
            dataType: 'json',
            success: function(respuesta) {
                dataSource = respuesta;
            }
        });

        $('#arbolModulos').jstree({
            "core": {
                "check_callback": true,
                "data": dataSource
            },
            "types": {
                "default": {
                    "icon": "fas fa-laptop"
                },
                "file": {
                    "icon": "fas fa-laptop"
                }
            },
            "plugins": ["types", "dnd"]
        }).bind('ready.jstree', function(e, data) {
            $('#arbolModulos').jstree('open_all')
        })

    }

    function actualizarArbolModulos() {

        $.ajax({
            async: false,
            url: 'ajax/modulo.ajax.php',
            method: 'POST',
            data: {
                accion: 1
            },
            dataType: 'json',
            success: function(respuesta) {
                $("#arbolModulos").jstree(true).settings.core.data = respuesta;
                $("#arbolModulos").jstree(true).refresh();
            }
        });
    }

    function fnOrganizarModulos() {
        var array_modulos = [];

        var reg_id, reg_padre_id, reg_orden;

        var v = $('#arbolModulos').jstree(true).get_json('#', {
            'flat': true
        });

        for (let i = 0; i < v.length; i++) {
            var z = v[i];

            // console.log(z);

            reg_id = z["id"];
            reg_padre_id = z["parent"];
            reg_orden = i;

            array_modulos[i] = reg_id + ';' + reg_padre_id + ';' + reg_orden;

        }
        //REGISTRAMOS EL NUEVO ORDEN DE MODULO 
        $.ajax({
            async: false,
            url: 'ajax/modulo.ajax.php',
            method: 'POST',
            data: {
                accion: 4,
                modulos: array_modulos
            },
            dataType: 'json',
            success: function(respuesta) {
                if (respuesta > 0) {

                    Swal.fire({
                        position: 'center',
                        icon: 'success',
                        title: 'Se registro correctamente',
                        showConfirmButton: false,
                        timer: 1200
                    })

                    tbl_modulos.ajax.reload();

                    actualizarArbolModulosPerfiles();
                } else {
                    Swal.fire({
                        position: 'center',
                        icon: 'error',
                        title: 'Error al registrar',
                        showConfirmButton: false,
                        timer: 1200
                    })
                }
            }
        });

    }

    function fnRegistrarModulo() {

        var forms = document.getElementsByClassName('needs-validation-registro-modulo');

        var validation = Array.prototype.filter.call(forms, function(form) {

            if (form.checkValidity() === true) {

                console.log("listo para ")

                Swal.fire({
                        title: "Seguro de registrar este modulo?",
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonColor: "#3085d6",
                        cancelButtonColor: "#d33",
                        confirmButtonText: "Si,deseo registrarlo",
                        cancelButtonText: "Cancelar",
                    })
                    .then(result => {
                        if (result.isConfirmed) {

                            $("#iptIconoModulo").val($('#spn_icono_modulo i').attr('class'));
                            //console.log($('#frm_registro_modulo').serialize());
                            $.ajax({
                                async: false,
                                url: "ajax/modulo.ajax.php",
                                method: 'POST',
                                data: {
                                    accion: 5,
                                    datos: $('#frm_registro_modulo').serialize()
                                },
                                dataType: 'json',
                                success: function(respuesta) {
                                    //console.log(respuesta);
                                    Swal.fire({
                                        position: 'center',
                                        icon: "success",
                                        title: respuesta,
                                        showConfirmButton: false,
                                        timer: 1500
                                    })

                                    tbl_modulos.ajax.reload();
                                    actualizarArbolModulos();
                                    actualizarArbolModulosPerfiles();

                                    $('#iptModulo').val("");
                                    $('#iptVistaModulo').val("");
                                    $('#iptIconoModulo').val("");

                                    $('.needs-validation-registro-modulo').removeClass("was-validated");

                                }
                            })

                        }

                    });

            }
            form.classList.add('was-validated');
        })

    }
</script>