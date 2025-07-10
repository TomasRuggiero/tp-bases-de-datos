

-------- SCRIPT CREACION BI --------

use GD1C2025


IF OBJECT_ID('THIS_IS_FINE.BI_Hecho_Envio', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_Hecho_Envio;

IF OBJECT_ID('THIS_IS_FINE.BI_Hecho_Compra', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_Hecho_Compra;

IF OBJECT_ID('THIS_IS_FINE.BI_Hecho_Venta', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_Hecho_Venta;

IF OBJECT_ID('THIS_IS_FINE.BI_Hecho_Pedido', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_Hecho_Pedido;

IF OBJECT_ID('THIS_IS_FINE.BI_sucursal', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_sucursal;

IF OBJECT_ID('THIS_IS_FINE.BI_estado_pedido', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_estado_pedido;

IF OBJECT_ID('THIS_IS_FINE.BI_modelo_sillon', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_modelo_sillon;

IF OBJECT_ID('THIS_IS_FINE.BI_tipo_material', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_tipo_material;

IF OBJECT_ID('THIS_IS_FINE.BI_turno_ventas', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_turno_ventas;

IF OBJECT_ID('THIS_IS_FINE.BI_rango_etario', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_rango_etario;

IF OBJECT_ID('THIS_IS_FINE.BI_ubicacion', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_ubicacion;

IF OBJECT_ID('THIS_IS_FINE.BI_tiempo', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_tiempo;

----  PARA ELIMINAR LAS FKS EN CASO DE QUERER DROPEAR LAS TABLAS  ----
-- Eliminar FOREIGN KEYS que referencian tablas del esquema THIS_IS_FINE
-- Paso 1: Eliminar FOREIGN KEYS que referencian tablas del esquema THIS_IS_FINE
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += 'ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + fk.name + '];' + CHAR(13)
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.tables rt ON fk.referenced_object_id = rt.object_id
JOIN sys.schemas rs ON rt.schema_id = rs.schema_id
WHERE rs.name = 'THIS_IS_FINE';

EXEC sp_executesql @sql;

-- Paso 2: Eliminar PRIMARY KEYS definidas en tablas del esquema THIS_IS_FINE
DECLARE @sql2 NVARCHAR(MAX) = N'';  -- Nueva variable para evitar conflictos

SELECT @sql2 += 'ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + kc.name + '];' + CHAR(13)
FROM sys.key_constraints kc
JOIN sys.tables t ON kc.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE kc.type = 'PK'
  AND s.name = 'THIS_IS_FINE';

EXEC sp_executesql @sql2;


-------- CREACION TABLA DIMENSIONES --------

CREATE TABLE THIS_IS_FINE.BI_tiempo (
	tiempo_id INT IDENTITY(1,1),
	tiempo_anio INT,
	tiempo_cuatrimestre INT,
	tiempo_mes INT
	CONSTRAINT PK_BI_tiempo PRIMARY KEY (tiempo_id)
)

CREATE TABLE THIS_IS_FINE.BI_ubicacion (
	ubicacion_id INT IDENTITY(1,1),
	ubicacion_provincia NVARCHAR(255),
	ubicacion_localidad NVARCHAR(255)
	CONSTRAINT PK_ubicacion PRIMARY KEY (ubicacion_id)   
)

CREATE TABLE THIS_IS_FINE.BI_rango_etario (
	rango_etario_id INT IDENTITY(1,1),
	rango NVARCHAR(50)
	CONSTRAINT PK_rango_etario PRIMARY KEY (rango_etario_id)
)

CREATE TABLE THIS_IS_FINE.BI_turno_ventas (
	turno_id INT IDENTITY(1,1),
	turno NVARCHAR(50)
	CONSTRAINT PK_BI_turno_ventas PRIMARY KEY (turno_id)
)

CREATE TABLE THIS_IS_FINE.BI_tipo_material(
	tipo_material_id INT IDENTITY(1,1),
	tipo_material NVARCHAR(255),
	material_descripcion NVARCHAR(255)
	CONSTRAINT PK_BI_tipo_material PRIMARY KEY (tipo_material_id)
)

CREATE TABLE THIS_IS_FINE.BI_modelo_sillon(
	modelo_id INT IDENTITY(1,1),
	modelo_descripcion NVARCHAR(255)
	CONSTRAINT PK_BI_modelo_sillon PRIMARY KEY (modelo_id)
)

CREATE TABLE THIS_IS_FINE.BI_estado_pedido(
	estado_id INT IDENTITY(1,1),
	estado NVARCHAR(255)
	CONSTRAINT PK_BI_estado_pedido PRIMARY KEY (estado_id)
)	

---- HECHOS ----

CREATE TABLE THIS_IS_FINE.BI_Hecho_Pedido(
	ubicacion INT,
	tiempo INT,
	turno_ventas INT,
	estado INT,

	cantidad_sillones INT,
	cantidad_pedidos INT,
	pedido_total DECIMAL(18,2),

	CONSTRAINT FK_Hecho_Pedido_ubicacion FOREIGN KEY (ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id),
	CONSTRAINT FK_Hecho_Pedido_tiempo FOREIGN KEY (tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Pedido_horario_ventas FOREIGN KEY (turno_ventas)
		REFERENCES THIS_IS_FINE.BI_turno_ventas (turno_id),
	CONSTRAINT FK_Hecho_Pedido_estado FOREIGN KEY (estado)
		REFERENCES THIS_IS_FINE.BI_estado_pedido (estado_id),
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Venta(
	ubicacion INT,
	tiempo INT,
	modelo_sillon INT,
	rango_etario INT,

	sillones_vendidos INT,
	cantidad_ventas INT,
	total_vendido decimal(18,2),
	promedio_fabricacion DECIMAL(5,2)

	CONSTRAINT FK_Hecho_Venta_ubicacion FOREIGN KEY (ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id),
	CONSTRAINT FK_Hecho_Venta_tiempo FOREIGN KEY (tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Venta_modelo_sillon FOREIGN KEY (modelo_sillon)
		REFERENCES THIS_IS_FINE.BI_modelo_sillon (modelo_id),
	CONSTRAINT FK_Hecho_Venta_rango_etario FOREIGN KEY (rango_etario)
		REFERENCES THIS_IS_FINE.BI_rango_etario (rango_etario_id)
)


CREATE TABLE THIS_IS_FINE.BI_Hecho_Envio (
	envio_tiempo_programado INT,
	envio_tiempo_enviado INT,
	envio_ubicacion INT,

	envios_totales INT,
	envios_en_fecha INT,
	envio_total DECIMAL(18,2),
	
	CONSTRAINT FK_Hecho_Envio_tiempo_programado FOREIGN KEY (envio_tiempo_programado)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Envio_tiempo_enviado FOREIGN KEY (envio_tiempo_enviado)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Envio_ubicacion FOREIGN KEY (envio_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Compra (
	compra_tiempo INT,
	compra_material INT,
	compra_ubicacion INT,
	compra_subtotal DECIMAL(12,2),
	cantidad_compras INT,
	promedio_compra DECIMAL(12,2)
	
	CONSTRAINT FK_Hecho_Compra_Tiempo FOREIGN KEY (compra_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Compra_Material FOREIGN KEY (compra_material)
		REFERENCES THIS_IS_FINE.BI_tipo_material (tipo_material_id),
	CONSTRAINT FK_Hecho_Compra_ubicacion FOREIGN KEY (compra_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id),
)
---- LO DEJO POR SI YA TIENEN CARGADA LA TABLA COMO ESTABA ANTES (SIN CANTIDAD)
--TER TABLE THIS_IS_FINE.BI_Hecho_Compra
--D compra_cantidad DECIMAL(18,0)

--------  FUNCIONES  --------
GO
CREATE OR ALTER FUNCTION THIS_IS_FINE.rangoEtario (@Fecha_Nacimiento DATE)
RETURNS nvarchar(50)
AS
BEGIN
   DECLARE @EdadActual INT
	DECLARE @Rango nvarchar(50)

	SET @EdadActual = DATEDIFF(DAYOFYEAR, @Fecha_Nacimiento, GETDATE()) / 365

	SET @Rango =
		CASE 
			WHEN @EdadActual < 25 THEN '<25'
			WHEN @EdadActual >= 25 AND @EdadActual < 35 THEN '25-35'
			WHEN @EdadActual >= 35 AND @EdadActual < 50 THEN '35-50'
			WHEN @EdadActual >= 50 THEN '>50'
			else 'INDETERMINADO'
		END

	RETURN @Rango
END;
GO

CREATE OR ALTER FUNCTION  THIS_IS_FINE.getCuatri (@Fecha DATE)
RETURNS SMALLINT
AS BEGIN
	DECLARE @Cuatrimestre SMALLINT

	SET @Cuatrimestre =
		CASE 
			WHEN MONTH(@Fecha) BETWEEN 1 AND 4 THEN 1
			WHEN MONTH(@Fecha) BETWEEN 5 AND 8 THEN 2
			else 3
		END

	RETURN @Cuatrimestre
END
GO

CREATE OR ALTER  FUNCTION THIS_IS_FINE.getRangoHorario (@Hora TIME)
RETURNS nvarchar(50)
AS
BEGIN
    RETURN CASE
        WHEN @Hora BETWEEN '08:00:00' AND '13:59:59' THEN '08:00-14:00'
        WHEN @Hora BETWEEN '14:00:00' AND '19:59:59' THEN '14:00-20:00'
        ELSE 'INDETERMINADO'
    END;
END;

--------  INSERCION DE DATOS  --------

SELECT * FROM THIS_IS_FINE.detalle_pedido

----- INSERT UBICACIONES -----

INSERT INTO THIS_IS_FINE.BI_ubicacion(ubicacion_provincia, ubicacion_localidad)
SELECT provincia_detalle, localidad_detalle
FROM THIS_IS_FINE.Localidad
JOIN THIS_IS_FINE.Provincia ON localidad_provincia = provincia_codigo

----- INSERT RANGOS ETARIOS -----

INSERT INTO THIS_IS_FINE.[BI_rango_etario] (rango)
VALUES ('<25'), ('25-35'), ('35-50'), ('>50'), ('INDETERMINADO')

----- INSERT HORARIOS VENTA -----

INSERT INTO THIS_IS_FINE.BI_turno_ventas (turno)
VALUES ('08:00-14:00'),('14:00-20:00'), ('INDETERMINADO')

----- INSERT TIEMPO -----

INSERT INTO THIS_IS_FINE.BI_tiempo(tiempo_anio, tiempo_cuatrimestre, tiempo_mes)
(
	SELECT DISTINCT YEAR(eventos.fecha), THIS_IS_FINE.getCuatri(eventos.fecha), MONTH(eventos.fecha)
	FROM (
		SELECT compra_fecha AS fecha FROM THIS_IS_FINE.Compra
		UNION 
		SELECT envio_fecha AS fecha FROM THIS_IS_FINE.Envio
		UNION
		SELECT factura_fecha AS fecha FROM THIS_IS_FINE.Factura
		UNION
		SELECT pedido_fecha AS fecha FROM THIS_IS_FINE.Pedido
		UNION
		SELECT pedido_cancelacion_fecha FROM THIS_IS_FINE.pedido_de_cancelacion
	) AS eventos
	WHERE eventos.fecha IS NOT NULL
)

----- INSERT TIPO MATERIAL -----

INSERT INTO THIS_IS_FINE.BI_tipo_material (tipo_material)
SELECT tipo_material_detalle
FROM THIS_IS_FINE.tipo_material



----- INSERT SILLON MODELO  -----

INSERT INTO THIS_IS_FINE.BI_modelo_sillon (modelo_descripcion)
SELECT sillon_modelo_descripcion
FROM THIS_IS_FINE.sillon_modelo

----- INSERT ESTADO PEDIDO -----

INSERT INTO THIS_IS_FINE.BI_estado_pedido (estado)
SELECT DISTINCT pedido_estado
FROM THIS_IS_FINE.Pedido

----- INSERT HECHO PEDIDO -----

INSERT INTO THIS_IS_FINE.BI_Hecho_Pedido(
	ubicacion, 
	tiempo,  
	turno_ventas,
	estado,
	cantidad_sillones,
	cantidad_pedidos,
	pedido_total
)
SELECT ubicacion.ubicacion_id, 
	tiempo.tiempo_id, 
	turno.turno_id, 
	estado.estado_id,
	SUM(detalle.pedido_det_cantidad) as pedido_cantidad_sillones,
	COUNT(DISTINCT pedido.pedido_numero),
	SUM(detalle.pedido_det_subtotal) as pedido_total

FROM THIS_IS_FINE.Pedido pedido
JOIN THIS_IS_FINE.detalle_pedido detalle ON detalle.pedido_numero = pedido.pedido_numero
JOIN THIS_IS_FINE.Sucursal sucursal ON sucursal.sucursal_id = pedido.pedido_sucursal
JOIN THIS_IS_FINE.Localidad localidad ON sucursal_localidad = localidad.localidad_codigo
JOIN THIS_IS_FINE.Provincia provincia ON localidad.localidad_provincia = provincia.provincia_codigo
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON provincia.provincia_detalle = ubicacion.ubicacion_provincia AND localidad.localidad_detalle = ubicacion.ubicacion_localidad
JOIN THIS_IS_FINE.BI_tiempo tiempo ON YEAR(pedido.pedido_fecha) = tiempo.tiempo_anio 
	AND THIS_IS_FINE.getCuatri(pedido.pedido_fecha) = tiempo.tiempo_cuatrimestre AND MONTH(pedido.pedido_fecha) = tiempo.tiempo_mes
JOIN THIS_IS_FINE.BI_turno_ventas turno ON THIS_IS_FINE.getRangoHorario(CONVERT(TIME, pedido.pedido_fecha)) = turno.turno
JOIN THIS_IS_FINE.BI_estado_pedido estado ON pedido.pedido_estado = estado.estado
GROUP BY ubicacion.ubicacion_id, tiempo.tiempo_id, turno.turno_id, estado.estado_id

----- INSERT HECHO COMPRA -----

INSERT INTO THIS_IS_FINE.BI_Hecho_Compra( 
	compra_tiempo,
	compra_material,
	cantidad_compras,
	compra_ubicacion,
	compra_subtotal,
	promedio_compra
)
SELECT 
	tiempo_id, 
	BI_material.tipo_material_id, 
	SUM(detalle.detalle_compra_cantidad), 
	ubicacion_id, 
	SUM(detalle.detalle_compra_subtotal), 
	AVG(compra.compra_total)
FROM THIS_IS_FINE.Compra compra 
JOIN THIS_IS_FINE.detalle_compra detalle ON detalle.detalle_compra_numero = compra.compra_numero
JOIN THIS_IS_FINE.Material material ON material.id_material = detalle.detalle_compra_material
JOIN THIS_IS_FINE.tipo_material tipoMaterial ON tipoMaterial.tipo_material_id = material.material_tipo
JOIN THIS_IS_FINE.BI_tipo_material BI_material ON BI_material.tipo_material = tipoMaterial.tipo_material_detalle
JOIN THIS_IS_FINE.BI_tiempo ON YEAR(compra.compra_fecha) = tiempo_anio
	AND THIS_IS_FINE.getCuatri(compra.compra_fecha) = tiempo_cuatrimestre AND MONTH(compra.compra_fecha) = tiempo_mes
JOIN THIS_IS_FINE.Sucursal ON compra.compra_sucursal = sucursal_id
JOIN THIS_IS_FINE.Localidad loc ON sucursal_localidad = loc.localidad_codigo
JOIN THIS_IS_FINE.Provincia prov ON loc.localidad_provincia = prov.provincia_codigo
JOIN THIS_IS_FINE.BI_ubicacion ON prov.provincia_detalle = ubicacion_provincia AND loc.localidad_detalle = ubicacion_localidad
GROUP BY tiempo_id, BI_material.tipo_material_id, ubicacion_id

---- INSERT HECHO ENVIO ----
SELECT * FROM THIS_IS_FINE.Envio

INSERT INTO THIS_IS_FINE.BI_Hecho_Envio(
    envio_tiempo_programado,
	envio_tiempo_enviado,
	envio_ubicacion,
	envios_totales,
	envio_total,
	envios_en_fecha)
SELECT t1.tiempo_id,
       t2.tiempo_id,
	   ubicacion_id,
	   COUNT(*),
	   SUM(envio_total),
	   SUM(CASE WHEN envio_fecha_programada = envio_fecha THEN 1 ELSE 0 END) AS envios_en_fecha
FROM THIS_IS_FINE.Envio
JOIN THIS_IS_FINE.BI_tiempo t1 ON YEAR(envio_fecha_programada) = t1.tiempo_anio
	AND THIS_IS_FINE.getCuatri(envio_fecha_programada) = t1.tiempo_cuatrimestre AND MONTH(envio_fecha_programada) = t1.tiempo_mes
JOIN THIS_IS_FINE.BI_tiempo t2 ON YEAR(envio_fecha) = t2.tiempo_anio
	AND THIS_IS_FINE.getCuatri(envio_fecha) = t2.tiempo_cuatrimestre AND MONTH(envio_fecha) = t2.tiempo_mes
JOIN THIS_IS_FINE.Factura f on f.factura_numero = envio_factura_numero
JOIN THIS_IS_FINE.Cliente c on c.cliente_codigo = f.factura_cliente
JOIN THIS_IS_FINE.Localidad loc ON cliente_localidad = loc.localidad_codigo
JOIN THIS_IS_FINE.Provincia prov ON loc.localidad_provincia = prov.provincia_codigo
JOIN THIS_IS_FINE.BI_ubicacion ON prov.provincia_detalle = ubicacion_provincia AND loc.localidad_detalle = ubicacion_localidad
GROUP BY t1.tiempo_id, t2.tiempo_id, ubicacion_id

---- INSERT HECHO VENTA -----

DELETE FROM THIS_IS_FINE.BI_Hecho_Venta

INSERT INTO THIS_IS_FINE.BI_Hecho_Venta(
	ubicacion,
	tiempo,
	modelo_sillon,
	rango_etario,
	sillones_vendidos,
	total_vendido,
	cantidad_ventas,
	promedio_fabricacion)
SELECT
       ubicacion_id,
	   tiempo_id,
	   BI_sillon.modelo_id,
	   rango_etario.rango_etario_id,
	   SUM(df.detalle_factura_cantidad),
	   SUM(df.detalle_factura_subtotal),
	   COUNT(DISTINCT factura_numero),
	   AVG(CAST(DATEDIFF(DAY, ped.pedido_fecha, fac.factura_fecha) AS FLOAT))
FROM THIS_IS_FINE.Factura fac
JOIN THIS_IS_FINE.BI_tiempo ON YEAR(fac.factura_fecha) = tiempo_anio
	AND THIS_IS_FINE.getCuatri(fac.factura_fecha) = tiempo_cuatrimestre AND MONTH(fac.factura_fecha) = tiempo_mes
JOIN THIS_IS_FINE.Sucursal sucursal ON sucursal.sucursal_id = fac.factura_sucursal
JOIN THIS_IS_FINE.Localidad localidad ON sucursal_localidad = localidad.localidad_codigo
JOIN THIS_IS_FINE.Provincia provincia ON localidad.localidad_provincia = provincia.provincia_codigo
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON provincia.provincia_detalle = ubicacion.ubicacion_provincia
	AND localidad.localidad_detalle = ubicacion.ubicacion_localidad
JOIN THIS_IS_FINE.detalle_factura df ON fac.factura_numero = df.detalle_factura_numero
JOIN THIS_IS_FINE.detalle_pedido detPed ON detPed.detalle_pedido_id = df.detalle_factura_pedido
JOIN THIS_IS_FINE.Pedido ped ON ped.pedido_numero = detPed.pedido_numero
JOIN THIS_IS_FINE.Sillon sillon ON detPed.sillon_id = sillon.sillon_id
JOIN THIS_IS_FINE.sillon_modelo sModelo ON sModelo.sillon_modelo_codigo = sillon.sillon_modelo
JOIN THIS_IS_FINE.BI_modelo_sillon BI_sillon ON BI_sillon.modelo_descripcion = sModelo.sillon_modelo_descripcion
JOIN THIS_IS_FINE.Cliente cliente ON fac.factura_cliente = cliente.cliente_codigo
JOIN THIS_IS_FINE.BI_rango_etario rango_etario ON THIS_IS_FINE.rangoEtario(cliente.cliente_fecha_nacimiento) = rango_etario.rango
WHERE fac.factura_fecha >= ped.pedido_fecha
GROUP BY ubicacion_id, tiempo_id, BI_sillon.modelo_id, rango_etario.rango_etario_id


------  VISTAS  ------
GO
---- VISTA 1: GANANCIAS----

CREATE OR ALTER VIEW THIS_IS_FINE.BI_Ganancias_mensuales_por_sucursal AS
SELECT 
	CAST(tiempo.tiempo_anio AS VARCHAR(4)) + '-' + 
	RIGHT('0' + CAST(tiempo.tiempo_mes AS VARCHAR(2)), 2) AS [anio-mes],
	ubi.ubicacion_localidad AS sucursal_localidad,
	ubi.ubicacion_provincia AS sucursal_provincia,
	ISNULL(ventas.total_vendido, 0) - ISNULL(compras.total_comprado, 0) AS ganancia_mensual
FROM (
	SELECT 
		venta.tiempo,
		venta.ubicacion,
		SUM(venta.total_vendido) AS total_vendido
	FROM THIS_IS_FINE.BI_Hecho_Venta venta
	GROUP BY venta.tiempo, venta.ubicacion
) ventas
JOIN THIS_IS_FINE.BI_tiempo tiempo ON tiempo.tiempo_id = ventas.tiempo
JOIN THIS_IS_FINE.BI_ubicacion ubi ON ubi.ubicacion_id = ventas.ubicacion
LEFT JOIN (
	SELECT 
		compra.compra_tiempo AS tiempo,
		compra.compra_ubicacion AS ubicacion,
		SUM(compra.compra_subtotal) AS total_comprado
	FROM THIS_IS_FINE.BI_Hecho_Compra compra
	GROUP BY compra.compra_tiempo, compra.compra_ubicacion
) compras ON compras.tiempo = ventas.tiempo AND compras.ubicacion = ventas.ubicacion

--- Vista 2 FACTURA PROMEDIO MENSUAL ----

CREATE OR ALTER VIEW THIS_IS_FINE.BI_FacturaPromedioMensual AS
SELECT
    t.tiempo_anio AS anio,
    t.tiempo_cuatrimestre AS cuatrimestre,
    u.ubicacion_provincia AS provincia,
	SUM(venta.total_vendido) / SUM(venta.cantidad_ventas) AS promedio_mensual
FROM THIS_IS_FINE.BI_Hecho_Venta venta
JOIN THIS_IS_FINE.BI_tiempo t ON  venta.tiempo = t.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion u ON venta.ubicacion = u.ubicacion_id
GROUP BY
    t.tiempo_anio,
    t.tiempo_cuatrimestre,
    u.ubicacion_provincia;
GO

---- VISTA 3: RENDIMIENTO DE MODELOS ----
CREATE OR ALTER VIEW THIS_IS_FINE.BI_Rendimiento_Modelos AS
SELECT
    modelo_descripcion AS modelo,
    CAST(tiempo_cuatrimestre AS VARCHAR) + '-' + CAST(tiempo_anio AS VARCHAR) AS [cuatrimestre-año],
    localidad AS localidad,
    rango AS [rango-etario],
    sillones_vendidos AS [sillones-vendidos]
FROM (
    SELECT
        modelo.modelo_descripcion,
        tiempo.tiempo_cuatrimestre,
        tiempo.tiempo_anio,
        ubicacion.ubicacion_localidad AS localidad,
        rEtario.rango,
        venta.sillones_vendidos,
        ROW_NUMBER() OVER (
            PARTITION BY 
                tiempo.tiempo_cuatrimestre, 
                tiempo.tiempo_anio, 
                ubicacion.ubicacion_localidad,
                rEtario.rango_etario_id
            ORDER BY venta.sillones_vendidos DESC
        ) AS rn
    FROM THIS_IS_FINE.BI_Hecho_Venta venta
    JOIN THIS_IS_FINE.BI_modelo_sillon modelo ON venta.modelo_sillon = modelo.modelo_id
    JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON venta.ubicacion = ubicacion.ubicacion_id
    JOIN THIS_IS_FINE.BI_tiempo tiempo ON tiempo.tiempo_id = venta.tiempo
    JOIN THIS_IS_FINE.BI_rango_etario rEtario ON venta.rango_etario = rEtario.rango_etario_id
) AS ranked
WHERE rn <= 3

---- VISTA 4: VOLUMEN DE PEDIDOS ----

CREATE OR ALTER VIEW THIS_IS_FINE.Volumen_Pedidos AS 
SELECT 
	COUNT(*) AS Cantidad_Pedidos,
	ubicacion.ubicacion_localidad AS sucursal_localidad,
	ubicacion.ubicacion_provincia AS sucursal_provincia,
	turno AS turno,
	FORMAT(DATEFROMPARTS(tiempo.tiempo_anio, tiempo.tiempo_mes, 1), 'yyyy-MM') AS [mes_anio]
FROM THIS_IS_FINE.BI_Hecho_Pedido pedido
JOIN THIS_IS_FINE.BI_tiempo tiempo ON pedido.tiempo = tiempo.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON pedido.ubicacion = ubicacion.ubicacion_id
JOIN THIS_IS_FINE.BI_turno_ventas ON pedido.turno_ventas = turno_id
GROUP BY ubicacion.ubicacion_localidad, ubicacion.ubicacion_provincia, turno, tiempo.tiempo_mes, tiempo.tiempo_anio

---- VISTA 5: CONVERSION DE PEDIDOS ----

CREATE OR ALTER VIEW THIS_IS_FINE.BI_PorcentajePedidosPorEstado AS
SELECT
	ubicacion.ubicacion_localidad AS [sucursal-localidad],
	ubicacion.ubicacion_provincia AS [sucursal-provincia],
	FORMAT(DATEFROMPARTS(tiempo.tiempo_anio, tiempo.tiempo_cuatrimestre, 1), 'yyyy-MM') AS [mes_anio],
	pedido.estado,
    FORMAT(SUM(pedido.cantidad_pedidos) * 100.0 / NULLIF(SUM(SUM(pedido.cantidad_pedidos)) OVER (
    PARTITION BY ubicacion.ubicacion_localidad, ubicacion.ubicacion_provincia, tiempo.tiempo_anio, tiempo.tiempo_cuatrimestre
	), 0), 'N2') + '%' AS porcentaje_pedidos
FROM THIS_IS_FINE.BI_Hecho_Pedido pedido
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON pedido.ubicacion = ubicacion.ubicacion_id
JOIN THIS_IS_FINE.BI_tiempo tiempo ON pedido.tiempo = tiempo.tiempo_id
GROUP BY
    ubicacion.ubicacion_localidad,
	ubicacion.ubicacion_provincia,
    tiempo.tiempo_anio,
    tiempo.tiempo_cuatrimestre,
    pedido.estado;

---- VISTA 6: TIEMPO PROMEDIO DE FABRICACI�N ----

CREATE OR ALTER VIEW THIS_IS_FINE.BI_TiempoPromedioFabricacion AS
SELECT
    ubi.ubicacion_localidad AS [sucursal-localidad],
	ubi.ubicacion_provincia AS [sucursal-provincia],
    FORMAT(DATEFROMPARTS(tiempo.tiempo_anio, tiempo.tiempo_cuatrimestre, 1), 'yyyy-MM') AS [mes_anio],
    FORMAT(SUM(venta.promedio_fabricacion * venta.sillones_vendidos) / NULLIF(SUM(venta.sillones_vendidos), 0), 'N2') + ' días' AS tiempo_promedio_en_dias
FROM THIS_IS_FINE.BI_Hecho_Venta venta
JOIN THIS_IS_FINE.BI_tiempo tiempo ON venta.tiempo = tiempo.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion ubi ON ubi.ubicacion_id = venta.ubicacion
GROUP BY
    ubi.ubicacion_localidad,
	ubi.ubicacion_provincia,
    tiempo.tiempo_anio,
    tiempo.tiempo_cuatrimestre;

---- VISTA 7: PROMEDIO DE COMPRAS ----

CREATE OR ALTER VIEW THIS_IS_FINE.BI_PromedioMensualCompras AS
SELECT
    tiempo.tiempo_anio,
    tiempo.tiempo_mes,
	'$' + FORMAT(AVG(DISTINCT hc.promedio_compra), 'N2') AS promedio_mensual_compras
FROM THIS_IS_FINE.BI_Hecho_Compra hc
JOIN THIS_IS_FINE.BI_tiempo tiempo ON hc.compra_tiempo = tiempo.tiempo_id
GROUP BY tiempo.tiempo_anio, tiempo.tiempo_mes;

---- VISTA 8: COMPRA POR TIPO DE MATERIAL ----

CREATE OR ALTER VIEW THIS_IS_FINE.VW_compra_tipo_material_ubicacion_cuatrimestre AS
SELECT 
    tipo_material.tipo_material AS [tipo-material],
    ubicacion_sucursal.ubicacion_provincia AS [sucursal-provincia],
    ubicacion_sucursal.ubicacion_localidad AS [sucursal-localidad],
    tiempo.tiempo_anio AS [anio],
    tiempo.tiempo_cuatrimestre AS [cuatrimestre],
    '$' + FORMAT(SUM(compra.compra_subtotal), 'N2') AS [total-gastado]
FROM THIS_IS_FINE.BI_Hecho_Compra compra
JOIN THIS_IS_FINE.BI_tipo_material tipo_material ON compra.compra_material = tipo_material.tipo_material_id
JOIN THIS_IS_FINE.BI_ubicacion ubicacion_sucursal ON compra.compra_ubicacion = ubicacion_sucursal.ubicacion_id
JOIN THIS_IS_FINE.BI_tiempo tiempo ON compra.compra_tiempo = tiempo.tiempo_id
GROUP BY 
    tipo_material.tipo_material,
    ubicacion_sucursal.ubicacion_provincia,
    ubicacion_sucursal.ubicacion_localidad,
    tiempo.tiempo_anio,
    tiempo.tiempo_cuatrimestre;

---- VISTA 9: PORCENTAJE DE CUMPLIMIENTO DE ENV�OS -----

CREATE OR ALTER VIEW THIS_IS_FINE.Porcentaje_Cumplimiento_Envios AS
SELECT
	t.tiempo_anio AS anio,
	t.tiempo_mes AS mes,
	FORMAT(SUM(envios_en_fecha) * 100.0 / NULLIF(SUM(envios_totales), 0), 'N2') + '%' AS porcentaje_cumplimiento
FROM THIS_IS_FINE.BI_tiempo t
JOIN THIS_IS_FINE.BI_Hecho_Envio e ON e.envio_tiempo_programado = t.tiempo_id
GROUP BY t.tiempo_anio, t.tiempo_mes

---- VISTA 10: LOCALIDADES QUE PAGAN MAYOR COSTO DE ENVIO -----     

CREATE OR ALTER VIEW THIS_IS_FINE.Localidades_Envios_Mas_Caros AS
SELECT TOP 3 
	u.ubicacion_localidad AS localidad,
	u.ubicacion_provincia AS provincia, --traigo tambi�n la provincia porque podr�an existir localidades con el mismo nombre en distintas provincias
	'$' + FORMAT(AVG(e.envio_total), 'N2') AS promedio_costo_envio
FROM THIS_IS_FINE.BI_Hecho_Envio e
JOIN THIS_IS_FINE.BI_ubicacion u ON e.envio_ubicacion = u.ubicacion_id
GROUP BY u.ubicacion_localidad, u.ubicacion_provincia
ORDER BY AVG(e.envio_total) DESC

