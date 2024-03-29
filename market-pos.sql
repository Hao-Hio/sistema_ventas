-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-01-2024 a las 22:25:46
-- Versión del servidor: 10.1.37-MariaDB
-- Versión de PHP: 7.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `market-pos`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ActualizarDetalleVenta` (IN `p_codigo_producto` VARCHAR(20), IN `p_cantidad` FLOAT, IN `p_id` INT)  BEGIN

declare v_nro_boleta varchar(20);
declare v_total_venta float;

/*
ACTUALIZAR EL STOCK DEL PRODUCTO QUE SE A MODIFICADO FALTA
*/

/*
ACTUALIZAR EL codigo, cantidad y total del item modificado
*/
UPDATE venta_detalle
SET codigo_producto = p_codigo_producto,
cantidad = p_cantidad,
total_venta = (p_cantidad * (SELECT precio_venta_producto FROM productos WHERE codigo_producto = p_codigo_producto))
WHERE id = p_id;

set v_nro_boleta = (SELECT nro_boleta FROM venta_detalle where id = p_id);
set v_total_venta = (SELECT SUM(total_venta) FROM venta_detalle where nro_boleta = v_nro_boleta);

UPDATE venta_cabecera
 set total_venta = v_total_venta
 WHERE nro_boleta = v_nro_boleta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_eliminar_venta` (IN `p_nro_boleta` VARCHAR(8))  BEGIN

DECLARE v_codigo VARCHAR(20);
DECLARE v_cantidad FLOAT;
DECLARE done INT DEFAULT FALSE;
DECLARE cursor_i CURSOR FOR 
SELECT codigo_producto,cantidad 
FROM venta_detalle 
where CAST(nro_boleta AS CHAR CHARACTER SET utf8)  = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_i;
read_loop: LOOP
FETCH cursor_i INTO v_codigo, v_cantidad;

	IF done THEN
	  LEAVE read_loop;
	END IF;
    
    UPDATE PRODUCTOS 
       SET stock_producto = stock_producto + v_cantidad
    WHERE CAST(codigo_producto AS CHAR CHARACTER SET utf8) = CAST(v_codigo AS CHAR CHARACTER SET utf8);

END LOOP;
CLOSE cursor_i;

DELETE FROM VENTA_DETALLE WHERE CAST(nro_boleta AS CHAR CHARACTER SET utf8) = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;
DELETE FROM VENTA_CABECERA WHERE CAST(nro_boleta AS CHAR CHARACTER SET utf8)  = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;

SELECT 'Se eliminó correctamente la venta';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarCategorias` ()  BEGIN
select * from categorias;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductos` ()  SELECT   '' as detalles,
                                                    id,
                                                    codigo_producto,
                                                    id_categoria_producto,
                                                    nombre_categoria,
                                                    descripcion_producto,
                                                    ROUND(precio_compra_producto,2) as precio_compra_producto,
                                                    ROUND(precio_venta_producto,2) as precio_venta_producto,
                                                    ROUND(utilidad,2) as utilidad,
                                                    case when c.aplica_peso = 1 then concat(stock_producto,' Kg(s)')
                                                        else concat(stock_producto,' Und(s)') end as stock_producto,
                                                    case when c.aplica_peso = 1 then concat(minimo_stock_producto,' Kg(s)')
                                                        else concat(minimo_stock_producto,' Und(s)') end as minimo_stock_producto,
                                                    case when c.aplica_peso = 1 then concat(ventas_producto,' Kg(s)') 
                                                        else concat(ventas_producto,' Und(s)') end as ventas_producto,
                                                    fecha_creacion_producto,
                                                    fecha_actualizacion_producto,
                                                    '' as acciones
                                                FROM productos p INNER JOIN categorias c on p.id_categoria_producto = c.id_categoria order by p.id desc$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosMasVendidos` ()  NO SQL
BEGIN

select  p.codigo_producto,
		p.descripcion_producto,
        sum(vd.cantidad) as cantidad,
        sum(Round(vd.total_venta,2)) as total_venta
from venta_detalle vd inner join productos p on vd.codigo_producto = p.codigo_producto
group by p.codigo_producto,
		p.descripcion_producto
order by  sum(Round(vd.total_venta,2)) DESC
limit 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosPocoStock` ()  NO SQL
BEGIN
select p.codigo_producto,
		p.descripcion_producto,
        p.stock_producto,
        p.minimo_stock_producto
from productos p
where p.stock_producto <= p.minimo_stock_producto
order by p.stock_producto asc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerDatosDashboard` ()  NO SQL
BEGIN
declare totalProductos int;
declare totalCompras float;
declare totalVentas float;
declare ganancias float;
declare productosPocoStock int;
declare ventasHoy float;

SET totalProductos = (SELECT count(*) FROM productos p);
SET totalCompras = (select sum(p.precio_compra_producto*p.stock_producto) from productos p);
set totalVentas = (select sum(vc.total_venta) from venta_cabecera vc where EXTRACT(MONTH FROM vc.fecha_venta) = EXTRACT(MONTH FROM curdate()) and EXTRACT(YEAR FROM vc.fecha_venta) = EXTRACT(YEAR FROM curdate()));
set ganancias = (select sum(vd.total_venta - (p.precio_compra_producto * vd.cantidad)) from venta_detalle vd inner join productos p on vd.codigo_producto = p.codigo_producto
                 where EXTRACT(MONTH FROM vd.fecha_venta) = EXTRACT(MONTH FROM curdate()) and EXTRACT(YEAR FROM vd.fecha_venta) = EXTRACT(YEAR FROM curdate()));
set productosPocoStock = (select count(1) from productos p where p.stock_producto <= p.minimo_stock_producto);
set ventasHoy = (select sum(vc.total_venta) from venta_cabecera vc where DATE(vc.fecha_venta) = CURDATE());

SELECT IFNULL(totalProductos,0) AS totalProductos,
	   IFNULL(ROUND(totalCompras,2),0) AS totalCompras,
       IFNULL(ROUND(totalVentas,2),0) AS totalVentas,
       IFNULL(ROUND(ganancias,2),0) AS ganancias,
       IFNULL(productosPocoStock,0) AS productosPocoStock,
       IFNULL(ROUND(ventasHoy,2),0) AS ventasHoy;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_obtenerNroBoleta` ()  NO SQL
select serie_boleta,
		IFNULL(LPAD(max(c.nro_correlativo_venta)+1,8,'0'),'00000001') nro_venta 
from empresa c$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerVentasMesActual` ()  NO SQL
BEGIN
SELECT date(vc.fecha_venta) as fecha_venta,
		sum(round(vc.total_venta,2)) as total_venta,
        sum(round(vc.total_venta,2)) as total_venta_ant
FROM venta_cabecera vc
where date(vc.fecha_venta) >= date(last_day(now() - INTERVAL 1 month) + INTERVAL 1 day)
and date(vc.fecha_venta) <= last_day(date(CURRENT_DATE))
group by date(vc.fecha_venta);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre_categoria` mediumtext COLLATE utf8mb4_spanish_ci,
  `aplica_peso` int(11) NOT NULL,
  `fecha_creacion_categoria` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha_actualizacion_categoria` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`, `aplica_peso`, `fecha_creacion_categoria`, `fecha_actualizacion_categoria`) VALUES
(153, 'Frutas', 1, '2022-01-23 05:37:34', '2022-01-23'),
(154, 'Verduras', 1, '2022-01-23 05:37:34', '2022-01-23'),
(155, 'Snack', 0, '2022-01-23 05:37:34', '2022-01-23'),
(156, 'Avena', 0, '2022-01-23 05:37:34', '2022-01-23'),
(157, 'Energizante', 0, '2022-01-23 05:37:34', '2022-01-23'),
(158, 'Jugo', 0, '2022-01-23 05:37:34', '2022-01-23'),
(159, 'Refresco', 0, '2022-01-23 05:37:34', '2022-01-23'),
(160, 'Mantequilla', 0, '2022-01-23 05:37:35', '2022-01-23'),
(161, 'Gaseosa', 0, '2022-01-23 05:37:35', '2022-01-23'),
(162, 'Aceite', 0, '2022-01-23 05:37:35', '2022-01-23'),
(163, 'Yogurt', 0, '2022-01-23 05:37:35', '2022-01-23'),
(164, 'Arroz', 0, '2022-01-23 05:37:35', '2022-01-23'),
(165, 'Leche', 0, '2022-01-23 05:37:35', '2022-01-23'),
(166, 'Papel Higiénico', 0, '2022-01-23 05:37:35', '2022-01-23'),
(167, 'Atún', 0, '2022-01-23 05:37:35', '2022-01-23'),
(168, 'Chocolate', 0, '2022-01-23 05:37:35', '2022-01-23'),
(169, 'Wafer', 0, '2022-01-23 05:37:35', '2022-01-23'),
(170, 'Golosina', 0, '2022-01-23 05:37:35', '2022-01-23'),
(171, 'Galletas', 0, '2022-01-23 05:37:35', '2022-01-23'),
(172, 'Cerveza', 0, '2023-11-26 05:05:42', '2023-11-26'),
(173, 'Celulares', 0, '2023-11-26 05:06:27', '2023-11-26');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `id_empresa` int(11) NOT NULL,
  `razon_social` mediumtext COLLATE utf8mb4_spanish_ci NOT NULL,
  `ruc` bigint(20) NOT NULL,
  `direccion` mediumtext COLLATE utf8mb4_spanish_ci NOT NULL,
  `marca` mediumtext COLLATE utf8mb4_spanish_ci NOT NULL,
  `serie_boleta` varchar(4) COLLATE utf8mb4_spanish_ci NOT NULL,
  `nro_correlativo_venta` varchar(8) COLLATE utf8mb4_spanish_ci NOT NULL,
  `email` mediumtext COLLATE utf8mb4_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`id_empresa`, `razon_social`, `ruc`, `direccion`, `marca`, `serie_boleta`, `nro_correlativo_venta`, `email`) VALUES
(1, 'Maga & Tito Market', 10467291241, 'Avenida Brasil 1347 - Jesus María', 'Maga & Tito Market', 'B001', '00000078', 'magaytito@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modulos`
--

CREATE TABLE `modulos` (
  `id` int(11) NOT NULL,
  `modulo` varchar(45) DEFAULT NULL,
  `padre_id` int(11) DEFAULT NULL,
  `vista` varchar(45) DEFAULT NULL,
  `icon_menu` varchar(45) DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `orden` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `modulos`
--

INSERT INTO `modulos` (`id`, `modulo`, `padre_id`, `vista`, `icon_menu`, `fecha_creacion`, `fecha_actualizacion`, `orden`) VALUES
(1, 'Tablero Principal', 0, 'dashboard.php', 'fas fa-tachometer-alt', '2023-12-11 15:30:23', '2023-12-12 20:13:08', '0'),
(2, 'Ventas', 0, '', 'fas fa-store-alt', '2023-12-11 15:30:38', '2023-12-12 20:13:08', '3'),
(3, 'Punto de Venta', 2, 'ventas.php', 'far fa-circle', '2023-12-11 15:31:28', '2023-12-12 20:13:08', '4'),
(4, 'Administrar Ventas', 2, 'administrar_ventas.php', 'far fa-circle', '2023-12-11 15:31:11', '2023-12-12 20:13:08', '5'),
(5, 'Productos', 0, NULL, 'fas fa-cart-plus', '2023-12-11 00:00:00', '2023-12-12 20:13:08', '6'),
(6, 'Inventario', 5, 'productos.php', 'far fa-circle', '2023-12-11 15:31:11', '2023-12-11 20:32:30', '7'),
(7, 'Carga Masiva', 5, 'carga_masiva_productos.php', 'far fa-circle', '2023-12-11 15:31:09', '2023-12-11 20:32:32', '8'),
(8, 'Categorías', 5, 'categorias.php', 'far fa-circle', '2023-12-11 15:31:07', '2023-12-11 20:32:35', '9'),
(9, 'Compras', 0, 'compras.php', 'fas fa-dolly', '2023-12-11 15:31:04', '2023-12-12 20:15:32', '10'),
(10, 'Reportes', 0, 'reportes.php', 'fas fa-chart-line', '2023-12-11 00:00:00', '2023-12-12 20:15:32', '11'),
(11, 'Configuración', 0, 'configuracion.php', 'fas fa-cogs', '2023-12-11 15:31:00', '2023-12-12 20:13:09', '12'),
(12, 'Usuarios', 0, 'usuarios.php', 'fas fa-users', '2023-12-11 15:30:57', '2023-12-12 20:13:08', '1'),
(13, 'Modulos y Perfiles', 0, 'modulos_perfiles.php', 'fas fa-tablet-alt', '2023-12-11 15:30:55', '2023-12-12 20:13:09', '13'),
(14, 'Caja', 0, 'caja.php', 'fas fa-money-bill-alt', '2023-12-11 15:30:51', '2023-12-12 20:13:08', '2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfiles`
--

CREATE TABLE `perfiles` (
  `id_perfil` int(11) NOT NULL,
  `descripcion` varchar(45) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL,
  `fecha_actualizacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `perfiles`
--

INSERT INTO `perfiles` (`id_perfil`, `descripcion`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 'Administrador', 1, '2023-12-04 18:55:29', '2023-12-04 18:55:43'),
(2, 'Vendedor', 1, '2023-12-04 18:55:36', '2023-12-04 18:55:47'),
(3, 'Programador', 1, '2023-12-11 08:32:36', '2023-12-11 08:32:36');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil_modulo`
--

CREATE TABLE `perfil_modulo` (
  `idperfil_modulo` int(11) NOT NULL,
  `id_perfil` int(11) DEFAULT NULL,
  `id_modulo` int(11) DEFAULT NULL,
  `vista_inicio` tinyint(4) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `perfil_modulo`
--

INSERT INTO `perfil_modulo` (`idperfil_modulo`, `id_perfil`, `id_modulo`, `vista_inicio`, `estado`) VALUES
(1, 1, 1, 1, 1),
(3, 1, 3, NULL, 1),
(6, 1, 6, NULL, 1),
(7, 1, 7, NULL, 1),
(8, 1, 8, NULL, 1),
(9, 1, 9, NULL, 1),
(10, 1, 10, NULL, 1),
(11, 1, 11, NULL, 1),
(12, 1, 12, NULL, 1),
(13, 1, 13, NULL, 1),
(15, 1, 4, NULL, 1),
(16, 1, 5, NULL, 1),
(17, 1, 2, NULL, 1),
(71, 2, 3, 0, 1),
(72, 2, 2, 0, 1),
(73, 2, 4, 1, 1),
(74, 2, 6, 0, 1),
(75, 2, 5, 0, 1),
(76, 2, 7, 0, 1),
(77, 2, 8, 0, 1),
(78, 2, 14, 0, 1),
(79, 3, 14, 0, 1),
(80, 3, 9, 0, 1),
(81, 3, 11, 0, 1),
(82, 3, 10, 0, 1),
(83, 3, 12, 0, 1),
(84, 3, 13, 0, 1),
(85, 3, 5, 0, 1),
(86, 3, 6, 1, 1),
(87, 3, 7, 0, 1),
(88, 3, 8, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `codigo_producto` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `id_categoria_producto` int(11) DEFAULT NULL,
  `descripcion_producto` mediumtext COLLATE utf8mb4_spanish_ci,
  `precio_compra_producto` float NOT NULL,
  `precio_venta_producto` float NOT NULL,
  `precio_mayor_producto` float DEFAULT NULL,
  `precio_oferta_producto` float DEFAULT NULL,
  `utilidad` float NOT NULL,
  `stock_producto` float DEFAULT NULL,
  `minimo_stock_producto` float DEFAULT NULL,
  `ventas_producto` float DEFAULT NULL,
  `fecha_creacion_producto` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha_actualizacion_producto` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `codigo_producto`, `id_categoria_producto`, `descripcion_producto`, `precio_compra_producto`, `precio_venta_producto`, `precio_mayor_producto`, `precio_oferta_producto`, `utilidad`, `stock_producto`, `minimo_stock_producto`, `ventas_producto`, `fecha_creacion_producto`, `fecha_actualizacion_producto`) VALUES
(676, '7750106002608', 171, 'gn rellenitas 36g chocolate', 0.47, 0.658, 0.458, 0.258, 0.188, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(677, '7750106002592', 171, 'gn rellenitas 36g coco', 0.47, 0.658, 0.458, 0.258, 0.188, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(678, '7750106002615', 171, 'gn rellenitas 36g coco', 0.47, 0.658, 0.458, 0.258, 0.188, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(679, '7750885012928', 171, 'frac vanilla 45.5g', 0.52, 0.728, 0.528, 0.328, 0.208, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(680, '7750885012881', 171, 'frac chocolate 45.5g', 0.52, 0.728, 0.528, 0.328, 0.208, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(681, '7750885012904', 171, 'frac chasica 45.5g', 0.52, 0.728, 0.528, 0.328, 0.208, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(682, '7590011251100', 171, 'oreo original 36g', 0.57, 0.798, 0.598, 0.398, 0.228, 30, 10, 0, '2022-02-06 15:55:50', '2022-01-23'),
(683, '7752748010423', 170, 'chin chin 32g', 0.875, 1.225, 1.025, 0.825, 0.35, 16, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(684, '7750885016483', 169, 'tuyo 22g', 0.5, 0.7, 0.5, 0.3, 0.2, 20, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(685, '7613036679312', 169, 'morochas wafer 37g', 1, 1.4, 1.2, 1, 0.4, 12, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(686, '7750885010269', 168, 'cancun', 0.75, 1.05, 0.85, 0.65, 0.3, 24, 10, 1, '2022-02-16 20:46:18', '2022-01-23'),
(687, '7622300279783', 171, 'vainilla field 37g', 0.33, 0.462, 0.262, 0.062, 0.132, 24, 10, 0, '2022-02-06 15:55:50', '2022-01-23'),
(688, '7622300513917', 171, 'soda field 34g', 0.37, 0.518, 0.318, 0.118, 0.148, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(689, '7622300124526', 171, 'ritz queso 34g', 0.68, 0.952, 0.752, 0.552, 0.272, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(690, '7622300116521', 171, 'ritz original', 0.43, 0.602, 0.402, 0.202, 0.172, 24, 10, 0, '2022-02-06 15:55:50', '2022-01-23'),
(691, '7590011205158', 171, 'club social 26g', 0.53, 0.742, 0.542, 0.342, 0.212, 36, 10, 0, '2022-02-06 15:55:50', '2022-01-23'),
(692, '7622300117207', 171, 'hony bran 33g', 0.9, 1.26, 1.06, 0.86, 0.36, 18, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(693, '7751158000437', 167, 'Filete de atún Florida ', 5.4, 7.56, 7.36, 7.16, 2.16, 12, 5, 0, '2022-02-06 15:55:50', '2022-01-23'),
(694, '7759185001977', 166, 'Noble pq 2 unid', 1.3, 1.82, 1.62, 1.42, 0.52, 10, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(695, '7751493009928', 166, 'Suave pq 4 unid', 4.58, 6.412, 6.212, 6.012, 1.832, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(696, '7613036552806', 165, 'Ideal cremosita 395g', 3, 4.2, 4, 3.8, 1.2, 22, 12, 5, '2022-02-16 20:45:28', '2022-01-23'),
(697, '7750518000711', 166, 'Paracas pq 4 unid', 5, 7, 6.8, 6.6, 2, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(698, '7751493000154', 166, 'Suave pq 2 unid', 1.99, 2.786, 2.586, 2.386, 0.796, 10, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(699, '7759185000642', 166, 'Elite Megarrollo', 2.19, 3.066, 2.866, 2.666, 0.876, 12, 6, 2, '2022-02-16 20:45:28', '2022-01-23'),
(700, '7759185004800', 166, 'Nova pq 2 unid', 3.99, 5.586, 5.386, 5.186, 1.596, 6, 2, 0, '2022-02-06 15:55:50', '2022-01-23'),
(701, '7754725000281', 164, 'Valle Norte 750g', 3.1, 4.34, 4.14, 3.94, 1.24, 15, 5, 17, '2022-02-16 20:36:01', '2022-01-23'),
(702, '7758950000900', 164, 'Faraon amarillo 1k', 3.39, 4.746, 4.546, 4.346, 1.356, 10, 5, 1, '2022-02-16 20:46:18', '2022-01-23'),
(703, '7613036552837', 165, 'Ideal Light 395g', 2.8, 3.92, 3.72, 3.52, 1.12, 28, 12, 14, '2022-02-16 20:46:18', '2022-01-23'),
(704, '7751271029155', 165, 'Pura vida 395g', 2.6, 3.64, 3.44, 3.24, 1.04, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(705, '7751271021975', 165, 'Gloria evaporada entera ', 3.2, 4.48, 4.28, 4.08, 1.28, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(706, '7755139161759', 164, 'Costeño 750g', 3.69, 5.166, 4.966, 4.766, 1.476, 20, 10, 0, '2022-02-06 15:55:50', '2022-01-23'),
(707, '7751271029186', 163, 'Gloria fresa 180ml', 1.5, 2.1, 1.9, 1.7, 0.6, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(708, '7751271027557', 163, 'Lúcuma 1L Gloria', 5.9, 8.26, 8.06, 7.86, 2.36, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(709, '7750151111959', 163, 'Durazno 1L laive', 5.7, 7.98, 7.78, 7.58, 2.28, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(710, '7750151111942', 163, 'Fresa 1L Laive', 5.7, 7.98, 7.78, 7.58, 2.28, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(711, '7751271029209', 163, 'Gloria durazno 180ml', 1.5, 2.1, 1.9, 1.7, 0.6, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(712, '7750151005548', 163, 'Fresa 370ml Laive', 2.19, 3.066, 2.866, 2.666, 0.876, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(713, '7751271027526', 163, 'Fresa 1L Gloria', 5.9, 8.26, 8.06, 7.86, 2.36, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(714, '7751271012348', 163, 'Frutado fresa vasito', 1.39, 1.946, 1.746, 1.546, 0.556, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(715, '7751271027663', 163, 'Gloria durazno 500ml', 3.79, 5.306, 5.106, 4.906, 1.516, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(716, '7751271012355', 163, 'Frutado durazno vasito', 1.39, 1.946, 1.746, 1.546, 0.556, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(717, '7751271027670', 163, 'Gloria Vainilla Francesa 500ml', 3.79, 5.306, 5.106, 4.906, 1.516, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(718, '7751271027656', 163, 'Gloria Fresa 500ml', 3.79, 5.306, 5.106, 4.906, 1.516, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(719, '7751271013734', 163, 'Milkito fresa 1L', 5.9, 8.26, 8.06, 7.86, 2.36, 3, 1, 0, '2022-02-06 15:55:50', '2022-01-23'),
(720, '7751271027557', 163, 'Gloria Durazno 1L', 5.9, 8.26, 8.06, 7.86, 2.36, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(721, '7751158010443', 167, 'Florida Trozos ', 5.15, 7.21, 7.01, 6.81, 2.06, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(722, '7750408076161', 167, 'Filete de atún Campomar', 5.08, 7.112, 6.912, 6.712, 2.032, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(723, '7759450000209', 167, 'A1 Trozos ', 5.17, 7.238, 7.038, 6.838, 2.068, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(724, '7750408001675', 167, 'Trozos de atún Campomar', 4.66, 6.524, 6.324, 6.124, 1.864, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(725, '7862100603030', 167, 'Real Trozos', 4.63, 6.482, 6.282, 6.082, 1.852, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(726, '7751158010603', 167, 'Florida Filete Ligth', 5.63, 7.882, 7.682, 7.482, 2.252, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(727, '7759450002333', 167, 'A1 Filete Ligth', 6.08, 8.512, 8.312, 8.112, 2.432, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(728, '7759450112780', 167, 'A1 Filete', 4.65, 6.51, 6.31, 6.11, 1.86, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(729, '7750151007214', 165, 'Laive Ligth caja 480ml', 2.8, 3.92, 3.72, 3.52, 1.12, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(730, '7750151007221', 165, 'Laive sin lactosa caja 480ml', 3.17, 4.438, 4.238, 4.038, 1.268, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(731, '7751271017367', 163, 'Griego gloria', 3.65, 5.11, 4.91, 4.71, 1.46, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(732, '7751271012263', 163, 'Battimix', 2.89, 4.046, 3.846, 3.646, 1.156, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(733, '7750243064095', 162, 'Sao 1L', 12.1, 16.94, 16.74, 16.54, 4.84, 8, 1, 4, '2022-02-16 20:46:07', '2022-01-23'),
(734, '7750243042338', 162, 'Cocinero 1L', 12.4, 17.36, 17.16, 16.96, 4.96, 3, 1, 0, '2022-02-06 15:55:50', '2022-01-23'),
(735, '7750243042949', 162, 'Primor 1L', 11.79, 16.506, 16.306, 16.106, 4.716, 3, 1, 0, '2022-02-06 15:55:50', '2022-01-23'),
(736, '7759222002097', 162, 'Deleite 1L', 9.8, 13.72, 13.52, 13.32, 3.92, 4, 2, 0, '2022-02-06 15:55:50', '2022-01-23'),
(737, '7750236330169', 161, 'Inca Kola 1.5L', 5.9, 8.26, 8.06, 7.86, 2.36, 7, 3, 14, '2022-02-16 20:45:28', '2022-01-23'),
(738, '7750182000222', 161, 'Sprite 3L', 7.49, 10.486, 10.286, 10.086, 2.996, 1, 2, 5, '2022-02-16 20:39:36', '2022-01-23'),
(739, '7750182002363', 161, 'Fanta Kola Inglesa 500ml', 1.39, 1.946, 1.746, 1.546, 0.556, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(740, '7751580000364', 161, 'Pepsi 750ml', 2.8, 3.92, 3.72, 3.52, 1.12, 12, 6, 1, '2022-02-16 20:46:18', '2022-01-23'),
(741, '7750670000185', 161, 'Sabor Oro 1.7L', 3.5, 4.9, 4.7, 4.5, 1.4, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(742, '7751912148467', 161, 'Seven Up 500ml', 1.8, 2.52, 2.32, 2.12, 0.72, 20, 10, 0, '2022-02-06 15:55:50', '2022-01-23'),
(743, '7750670014250', 161, 'Big cola 400ml', 1, 1.4, 1.2, 1, 0.4, 15, 10, 4, '2022-02-16 20:34:43', '2022-01-23'),
(744, '7751580000715', 161, 'Pepsi 355ml', 1.5, 2.1, 1.9, 1.7, 0.6, 12, 10, 3, '2022-02-16 20:46:07', '2022-01-23'),
(745, '7751580000968', 161, 'Pepsi 3L', 8, 11.2, 11, 10.8, 3.2, 4, 2, 0, '2022-02-06 15:55:50', '2022-01-23'),
(746, '7751580000807', 161, 'Pepsi 1.5L', 4.4, 6.16, 5.96, 5.76, 1.76, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(747, '7750182155663', 161, 'Coca Cola 1.5L', 5.9, 8.26, 8.06, 7.86, 2.36, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(748, '7750182220378', 161, 'Fanta Naranja 500ml', 1.39, 1.946, 1.746, 1.546, 0.556, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(749, '7750182006095', 161, 'Coca cola 600ml', 2.6, 3.64, 3.44, 3.24, 1.04, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(750, '7750182006088', 161, 'Inca Kola 600ml', 2.6, 3.64, 3.44, 3.24, 1.04, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(751, '7750151003902', 160, 'Laive 200gr', 8.9, 12.46, 12.26, 12.06, 3.56, 1, 3, 5, '2022-02-13 04:55:58', '2022-01-23'),
(752, '7751271011150', 160, 'Gloria Pote con sal', 9.19, 12.866, 12.666, 12.466, 3.676, 1, 2, 3, '2022-02-16 20:33:04', '2022-01-23'),
(753, '7802800716777', 159, 'Zuko Emoliente', 0.67, 0.938, 0.738, 0.538, 0.268, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(754, '7802800716821', 159, 'Zuko Piña', 0.9, 1.26, 1.06, 0.86, 0.36, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(755, '7802800716838', 159, 'Zuko Durazno', 0.9, 1.26, 1.06, 0.86, 0.36, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(756, '7750670011839', 158, 'Pulp Durazno 315ml', 1, 1.4, 1.2, 1, 0.4, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(757, '9002490100070', 157, 'Red Bull 250ml', 5.33, 7.462, 7.262, 7.062, 2.132, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(758, '7758574003202', 156, 'Quaker 120gr', 1.29, 1.806, 1.606, 1.406, 0.516, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(759, '7750885006460', 156, '3 ositos quinua', 1.9, 2.66, 2.46, 2.26, 0.76, 6, 3, 0, '2022-02-06 15:55:50', '2022-01-23'),
(760, '7750243166201', 171, 'Chocobum', 0.62, 0.868, 0.668, 0.468, 0.248, 18, 9, 0, '2022-02-06 15:55:50', '2022-01-23'),
(761, '7750243053037', 171, 'Margarita', 0.53, 0.742, 0.542, 0.342, 0.212, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(762, '7501006559019', 155, 'Canchita mantequilla ', 3.25, 4.55, 4.35, 4.15, 1.3, 6, 3, 1, '2022-02-16 20:46:18', '2022-01-23'),
(763, '7501006559002', 155, 'Canchita natural', 3.25, 4.55, 4.35, 4.15, 1.3, 3, 2, 0, '2022-02-06 15:55:50', '2022-01-23'),
(764, '7752748005924', 171, 'Picaras', 0.6, 0.84, 0.64, 0.44, 0.24, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(765, '7613034978059', 171, 'Wafer sublime', 0.92, 1.288, 1.088, 0.888, 0.368, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(766, '7613035963948', 171, 'Morocha 30g', 0.85, 1.19, 0.99, 0.79, 0.34, 24, 12, 0, '2022-02-06 15:55:50', '2022-01-23'),
(767, '7750885016469', 171, 'Choco donuts', 0.56, 0.784, 0.584, 0.384, 0.224, 18, 9, 0, '2022-02-06 15:55:50', '2022-01-23'),
(768, '38000846731', 155, 'Pringles papas', 2.8, 3.92, 3.72, 3.52, 1.12, 12, 6, 0, '2022-02-06 15:55:50', '2022-01-23'),
(769, '7613035049628', 171, 'Sublime clásico', 1.06, 1.48, 1.28, 1.08, 0.42, 30, 12, 0, '2022-02-09 23:41:26', '2022-01-23'),
(770, 'FR-100001', 153, 'Manzana Delicia', 5, 7.3, 7.1, 6.9, 2.3, 12, 4, 3, '2023-12-08 23:18:33', '2022-02-06'),
(771, '1', 159, 'Spark', 3, 5, NULL, NULL, 2, 0, 4, 39, '2023-12-24 20:44:40', '2023-11-25'),
(772, '2', 168, 'Beso de Moza', 2, 5, NULL, NULL, 3, 1, 5, 43, '2023-12-27 02:02:00', '2023-11-26'),
(773, '3', 159, 'Four Loko', 5, 10, 9, 8, 5, 11, 6, 29, '2024-01-28 21:19:58', '2023-11-26'),
(774, '4', 172, 'Corona 700 ml', 7, 9.5, NULL, NULL, 2.5, 7, 6, 6, '2023-12-18 03:31:50', '2023-12-13');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(100) DEFAULT NULL,
  `apellido_usuario` varchar(100) DEFAULT NULL,
  `usuario` varchar(100) DEFAULT NULL,
  `clave` text,
  `id_perfil_usuario` int(11) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_usuario`, `apellido_usuario`, `usuario`, `clave`, `id_perfil_usuario`, `estado`) VALUES
(1, 'Tutoriales', 'PHPeru', 'tperu', '$2a$07$azybxcags23425sdg23sdeanQZqjaf6Birm2NvcYTNtJw24CsO5uq', 1, 1),
(2, 'Paolo', 'Guerrero', 'pguerrero', '$2a$07$azybxcags23425sdg23sdeanQZqjaf6Birm2NvcYTNtJw24CsO5uq', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_cabecera`
--

CREATE TABLE `venta_cabecera` (
  `id_boleta` int(11) NOT NULL,
  `nro_boleta` varchar(8) COLLATE utf8mb4_spanish_ci NOT NULL,
  `descripcion` mediumtext COLLATE utf8mb4_spanish_ci,
  `subtotal` float NOT NULL,
  `igv` float NOT NULL,
  `total_venta` float DEFAULT NULL,
  `fecha_venta` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `venta_cabecera`
--

INSERT INTO `venta_cabecera` (`id_boleta`, `nro_boleta`, `descripcion`, `subtotal`, `igv`, `total_venta`, `fecha_venta`) VALUES
(46, '00000014', 'Venta realizada con Nro Boleta: 00000014', 0, 0, 69, '2022-01-02 02:54:10'),
(47, '00000015', 'Venta realizada con Nro Boleta: 00000015', 0, 0, 17.5, '2022-01-03 02:54:10'),
(48, '00000016', 'Venta realizada con Nro Boleta: 00000016', 0, 0, 16.2, '2022-01-04 02:54:10'),
(49, '00000017', 'Venta realizada con Nro Boleta: 00000017', 0, 0, 5, '2022-01-05 02:54:10'),
(50, '00000018', 'Venta realizada con Nro Boleta: 00000018', 0, 0, 1.8, '2022-01-06 02:54:10'),
(51, '00000019', 'Venta realizada con Nro Boleta: 00000019', 0, 0, 21.2, '2022-01-07 02:54:10'),
(52, '00000020', 'Venta realizada con Nro Boleta: 00000020', 0, 0, 29.5, '2022-01-08 02:54:10'),
(53, '00000021', 'Venta realizada con Nro Boleta: 00000021', 0, 0, 9.2, '2022-01-09 02:54:10'),
(54, '00000022', 'Venta realizada con Nro Boleta: 00000022', 0, 0, 1.25, '2022-01-10 02:54:10'),
(55, '00000023', 'Venta realizada con Nro Boleta: 00000023', 0, 0, 1.8, '2022-01-11 02:54:10'),
(56, '00000024', 'Venta realizada con Nro Boleta: 00000024', 0, 0, 65.8, '2022-01-12 02:54:10'),
(57, '00000025', 'Venta realizada con Nro Boleta: 00000025', 0, 0, 75.58, '2022-02-13 04:53:50'),
(58, '00000026', 'Venta realizada con Nro Boleta: 00000026', 0, 0, 68.85, '2022-02-13 04:55:58'),
(68, '00000036', 'Venta realizada con Nro Boleta: 00000036', 0, 0, 23.24, '2022-02-16 20:46:07'),
(71, '00000039', 'Venta realizada con Nro Boleta: 00000039', 0, 0, 45, '2023-11-26 18:54:43'),
(72, '00000040', 'Venta realizada con Nro Boleta: 00000040', 0, 0, 55, '2023-11-26 21:55:27'),
(75, '00000043', 'Venta realizada con Nro Boleta: 00000043', 0, 0, 20, '2023-11-27 16:34:18'),
(77, '00000045', 'Venta realizada con Nro Boleta: 00000045', 0, 0, 5, '2023-11-27 16:34:39'),
(78, '00000046', 'Venta realizada con Nro Boleta: 00000046', 0, 0, 35, '2023-11-27 17:14:01'),
(79, '00000047', 'Venta realizada con Nro Boleta: 00000047', 0, 0, 10, '2023-11-27 22:45:31'),
(80, '00000048', 'Venta realizada con Nro Boleta: 00000048', 0, 0, 30, '2023-11-29 04:04:00'),
(81, '00000049', 'Venta realizada con Nro Boleta: 00000049', 0, 0, 15, '2023-12-01 05:50:46'),
(82, '00000050', 'Venta realizada con Nro Boleta: 00000050', 0, 0, 24.6, '2023-12-02 23:32:32'),
(83, '00000051', 'Venta realizada con Nro Boleta: 00000051', 0, 0, 15, '2023-12-03 02:07:18'),
(84, '00000052', 'Venta realizada con Nro Boleta: 00000052', 0, 0, 10, '2023-12-04 23:32:03'),
(85, '00000053', 'Venta realizada con Nro Boleta: 00000053', 0, 0, 25, '2023-12-06 01:39:20'),
(86, '00000054', 'Venta realizada con Nro Boleta: 00000054', 0, 0, 30, '2023-12-07 00:09:01'),
(87, '00000055', 'Venta realizada con Nro Boleta: 00000055', 0, 0, 15, '2023-12-07 19:05:11'),
(88, '00000056', 'Venta realizada con Nro Boleta: 00000056', 0, 0, 12.3, '2023-12-08 23:18:33'),
(89, '00000057', 'Venta realizada con Nro Boleta: 00000057', 0, 0, 10, '2023-12-09 00:10:38'),
(90, '00000058', 'Venta realizada con Nro Boleta: 00000058', 0, 0, 30, '2023-12-09 21:43:08'),
(91, '00000059', 'Venta realizada con Nro Boleta: 00000059', 0, 0, 20, '2023-12-11 03:21:19'),
(92, '00000060', 'Venta realizada con Nro Boleta: 00000060', 0, 0, 30, '2023-12-11 20:34:37'),
(93, '00000061', 'Venta realizada con Nro Boleta: 00000061', 0, 0, 33.5, '2023-12-13 04:29:52'),
(94, '00000062', 'Venta realizada con Nro Boleta: 00000062', 0, 0, 20, '2023-12-18 03:31:16'),
(95, '00000063', 'Venta realizada con Nro Boleta: 00000063', 0, 0, 28.5, '2023-12-18 03:31:49'),
(96, '00000064', 'Venta realizada con Nro Boleta: 00000064', 0, 0, 20, '2023-12-19 00:12:21'),
(97, '00000065', 'Venta realizada con Nro Boleta: 00000065', 0, 0, 40, '2023-12-20 03:31:43'),
(98, '00000066', 'Venta realizada con Nro Boleta: 00000066', 0, 0, 5, '2023-12-20 03:58:20'),
(103, '00000071', 'Venta realizada con Nro Boleta: 00000071', 0, 0, 16, '2023-12-20 05:52:40'),
(106, '00000074', 'Venta realizada con Nro Boleta: 00000074', 0, 0, 20, '2023-12-20 17:52:20'),
(107, '00000075', 'Venta realizada con Nro Boleta: 00000075', 0, 0, 20, '2023-12-24 20:44:40'),
(108, '00000076', 'Venta realizada con Nro Boleta: 00000076', 0, 0, 45, '2023-12-27 02:02:00'),
(110, '00000078', 'Venta realizada con Nro Boleta: 00000078', 0, 0, 10, '2024-01-28 21:19:30');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle`
--

CREATE TABLE `venta_detalle` (
  `id` int(11) NOT NULL,
  `nro_boleta` varchar(8) COLLATE utf8mb4_spanish_ci NOT NULL,
  `codigo_producto` bigint(20) NOT NULL,
  `cantidad` float NOT NULL,
  `total_venta` float NOT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `venta_detalle`
--

INSERT INTO `venta_detalle` (`id`, `nro_boleta`, `codigo_producto`, `cantidad`, `total_venta`, `fecha_venta`) VALUES
(521, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(522, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(523, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(524, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(525, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(526, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(527, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(528, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(529, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(530, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(531, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(532, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(533, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(534, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(535, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(536, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(537, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(538, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(539, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(540, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(541, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(542, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(543, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(544, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(545, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(546, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(547, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(548, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(549, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(550, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(551, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(552, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(553, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(554, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(555, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(556, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(557, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(558, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(559, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(560, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(561, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(562, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(563, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(564, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(565, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(566, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(567, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(568, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(569, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(570, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(571, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(572, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(573, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(574, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(575, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(576, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(577, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(578, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(579, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(580, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(581, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(582, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(583, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(584, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(585, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(586, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(587, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(588, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(589, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(590, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(591, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(592, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(593, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(594, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(595, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(596, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(597, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(598, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(599, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(600, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(601, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(602, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(603, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(604, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(605, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(606, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(607, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(608, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(609, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(610, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(611, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(612, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(613, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(614, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(615, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(616, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(617, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(618, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(619, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(620, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(621, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(622, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(623, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(624, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(625, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(626, '00000014', 7755139002809, 3, 69, '2022-01-02 02:54:10'),
(627, '00000015', 7754725000281, 5, 17.5, '2022-01-03 02:54:10'),
(628, '00000016', 7751271021975, 1, 3.3, '2022-01-04 02:54:10'),
(629, '00000016', 7750182006088, 1, 2.5, '2022-01-04 02:54:10'),
(630, '00000016', 7750151003902, 1, 8.8, '2022-01-04 02:54:10'),
(631, '00000016', 7750885012928, 1, 0.8, '2022-01-04 02:54:10'),
(632, '00000016', 7750106002608, 1, 0.8, '2022-01-04 02:54:10'),
(633, '00000017', 7751271027656, 1, 5, '2022-01-05 02:54:10'),
(634, '00000018', 7750182002363, 1, 1.8, '2022-01-06 02:54:10'),
(635, '00000019', 7754725000281, 4, 14, '2022-01-07 02:54:10'),
(636, '00000019', 7750182002363, 4, 7.2, '2022-01-07 02:54:10'),
(637, '00000020', 7759222002097, 1, 9.5, '2022-01-08 02:54:10'),
(638, '00000020', 7755139002809, 1, 20, '2022-01-08 02:54:10'),
(639, '00000021', 10001, 4, 9.2, '2022-01-09 02:54:10'),
(640, '00000022', 10002, 0.25, 1.25, '2022-01-10 02:54:10'),
(641, '00000023', 7750182002363, 1, 1.8, '2022-01-11 02:54:10'),
(642, '00000024', 10001, 1, 2.3, '2022-01-12 02:54:10'),
(643, '00000024', 7501006559019, 1, 3.5, '2022-01-12 02:54:10'),
(644, '00000024', 7755139002809, 3, 60, '2022-01-12 02:54:10'),
(645, '00000025', 7751271011150, 2, 25.74, '2022-02-13 04:53:50'),
(646, '00000025', 7613036552806, 2, 8.4, '2022-02-13 04:53:50'),
(647, '00000025', 7750151003902, 2, 24.92, '2022-02-13 04:53:50'),
(648, '00000025', 7750236330169, 2, 16.52, '2022-02-13 04:53:50'),
(649, '00000026', 7750151003902, 3, 37.38, '2022-02-13 04:55:58'),
(650, '00000026', 7750182000222, 3, 31.47, '2022-02-13 04:55:58'),
(677, '00000036', 7751580000715, 3, 6.3, '2022-02-16 20:46:07'),
(678, '00000036', 7750243064095, 1, 16.94, '2022-02-16 20:46:07'),
(681, '00000039', 2, 3, 15, '2023-11-26 18:54:43'),
(682, '00000039', 1, 2, 10, '2023-11-26 18:54:43'),
(683, '00000039', 3, 3, 30, '2023-11-26 18:54:06'),
(684, '00000040', 3, 4, 40, '2023-11-26 21:55:27'),
(685, '00000040', 2, 3, 15, '2023-11-26 21:55:27'),
(690, '00000043', 3, 2, 20, '2023-11-27 16:34:18'),
(692, '00000045', 1, 1, 5, '2023-11-27 16:34:39'),
(693, '00000046', 2, 4, 20, '2023-11-27 18:08:10'),
(694, '00000046', 1, 1, 5, '2023-11-27 17:14:02'),
(695, '00000046', 3, 1, 10, '2023-11-27 17:14:02'),
(696, '00000047', 3, 1, 10, '2023-11-27 23:18:10'),
(697, '00000048', 2, 1, 5, '2023-11-29 04:04:01'),
(698, '00000048', 1, 5, 25, '2023-11-29 04:04:01'),
(699, '00000049', 2, 1, 5, '2023-12-01 05:50:46'),
(700, '00000049', 1, 2, 10, '2023-12-01 05:50:47'),
(701, '00000050', 2, 1, 5, '2023-12-02 23:32:32'),
(702, '00000050', 1, 1, 5, '2023-12-02 23:32:32'),
(703, '00000050', 0, 2, 14.6, '2023-12-02 23:32:32'),
(704, '00000051', 1, 2, 10, '2023-12-03 02:07:18'),
(705, '00000051', 2, 1, 5, '2023-12-03 02:07:19'),
(706, '00000052', 1, 1, 5, '2023-12-04 23:32:03'),
(707, '00000052', 2, 1, 5, '2023-12-04 23:32:03'),
(708, '00000053', 2, 5, 25, '2023-12-06 01:39:20'),
(709, '00000054', 1, 1, 5, '2023-12-07 00:09:01'),
(710, '00000054', 2, 5, 25, '2023-12-07 00:09:02'),
(711, '00000055', 2, 3, 15, '2023-12-07 19:05:11'),
(712, '00000056', 2, 1, 5, '2023-12-08 23:18:33'),
(713, '00000056', 0, 1, 7.3, '2023-12-08 23:18:33'),
(714, '00000057', 1, 2, 10, '2023-12-09 00:10:38'),
(715, '00000058', 1, 2, 10, '2023-12-09 21:43:08'),
(716, '00000058', 3, 1, 10, '2023-12-09 21:43:09'),
(717, '00000058', 2, 2, 10, '2023-12-09 21:43:09'),
(718, '00000059', 1, 1, 5, '2023-12-11 03:21:19'),
(719, '00000059', 2, 1, 5, '2023-12-11 03:21:19'),
(720, '00000059', 3, 1, 10, '2023-12-11 03:21:19'),
(721, '00000060', 2, 5, 25, '2023-12-11 20:34:37'),
(722, '00000060', 1, 1, 5, '2023-12-11 20:34:37'),
(723, '00000061', 2, 1, 5, '2023-12-13 04:29:52'),
(724, '00000061', 4, 3, 28.5, '2023-12-13 04:29:52'),
(725, '00000062', 1, 1, 5, '2023-12-18 03:31:17'),
(726, '00000062', 2, 1, 5, '2023-12-18 03:31:17'),
(727, '00000062', 3, 1, 10, '2023-12-18 03:31:17'),
(728, '00000063', 4, 3, 28.5, '2023-12-18 03:31:50'),
(729, '00000064', 2, 1, 5, '2023-12-19 00:12:22'),
(730, '00000064', 1, 1, 5, '2023-12-19 00:12:22'),
(731, '00000064', 3, 1, 10, '2023-12-19 00:12:22'),
(732, '00000065', 2, 1, 5, '2023-12-20 03:31:43'),
(733, '00000065', 3, 3, 30, '2023-12-20 03:33:46'),
(734, '00000065', 1, 1, 5, '2023-12-20 03:31:43'),
(735, '00000066', 2, 1, 5, '2023-12-20 03:58:20'),
(742, '00000071', 3, 2, 16, '2023-12-20 05:52:40'),
(745, '00000074', 3, 2, 20, '2023-12-20 17:52:20'),
(746, '00000075', 1, 1, 5, '2023-12-24 20:44:40'),
(747, '00000075', 2, 1, 5, '2023-12-24 20:44:40'),
(748, '00000075', 3, 1, 10, '2023-12-24 20:44:40'),
(749, '00000076', 2, 1, 5, '2023-12-27 02:02:00'),
(750, '00000076', 3, 4, 40, '2023-12-27 02:03:20'),
(752, '00000078', 3, 1, 10, '2024-01-28 21:19:30');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`id_empresa`);

--
-- Indices de la tabla `modulos`
--
ALTER TABLE `modulos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  ADD PRIMARY KEY (`id_perfil`);

--
-- Indices de la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  ADD PRIMARY KEY (`idperfil_modulo`),
  ADD KEY `id_perfil` (`id_perfil`),
  ADD KEY `id_modulo` (`id_modulo`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`,`codigo_producto`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `id_perfil_usuario` (`id_perfil_usuario`);

--
-- Indices de la tabla `venta_cabecera`
--
ALTER TABLE `venta_cabecera`
  ADD PRIMARY KEY (`id_boleta`);

--
-- Indices de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=174;

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `id_empresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  MODIFY `id_perfil` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  MODIFY `idperfil_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=775;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `venta_cabecera`
--
ALTER TABLE `venta_cabecera`
  MODIFY `id_boleta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111;

--
-- AUTO_INCREMENT de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=753;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  ADD CONSTRAINT `id_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfiles` (`id_perfil`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_perfil_usuario`) REFERENCES `perfiles` (`id_perfil`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
