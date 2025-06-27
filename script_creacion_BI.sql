

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
	pedido_id INT IDENTITY(1,1),
	pedido_codigo decimal(18,0),
	pedido_ubicacion INT,
	pedido_tiempo INT,
	pedido_rango_etario INT,
	pedido_turno_ventas INT,
	pedido_estado INT,
	pedido_modelo_sillon int,
	pedido_cantidad_sillon INT,
	pedido_sillon_precio DECIMAL(18,2),
	pedido_subtotal BIGINT,
	pedido_precio_total DECIMAL(18,2),

	CONSTRAINT PK_Hecho_pedido PRIMARY KEY (pedido_id),

	CONSTRAINT FK_Hecho_Pedido_ubicacion FOREIGN KEY (pedido_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id),
	CONSTRAINT FK_Hecho_Pedido_tiempo FOREIGN KEY (pedido_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Pedido_rango_etario FOREIGN KEY (pedido_rango_etario)
		REFERENCES THIS_IS_FINE.BI_rango_etario (rango_etario_id),
	CONSTRAINT FK_Hecho_Pedido_horario_ventas FOREIGN KEY (pedido_turno_ventas)
		REFERENCES THIS_IS_FINE.BI_turno_ventas (turno_id),
	CONSTRAINT FK_Hecho_Pedido_estado FOREIGN KEY (pedido_estado)
		REFERENCES THIS_IS_FINE.BI_estado_pedido (estado_id),
	CONSTRAINT FK_Hecho_Pedido_modelo_sillon FOREIGN KEY (pedido_modelo_sillon)
		REFERENCES THIS_IS_FINE.BI_modelo_sillon (modelo_id)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Venta(
	venta_id INT IDENTITY(1,1),
	venta_factura INT, 
	venta_ubicacion INT,
	venta_tiempo INT,
	venta_modelo_sillon INT,
	venta_cantidad INT,
	venta_total decimal(18,2)

	CONSTRAINT PK_Hecho_Venta PRIMARY KEY (venta_id)
	CONSTRAINT FK_Hecho_Venta_ubicacion FOREIGN KEY (venta_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id),
	CONSTRAINT FK_Hecho_Venta_tiempo FOREIGN KEY (venta_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Venta_modelo_sillon FOREIGN KEY (venta_modelo_sillon)
		REFERENCES THIS_IS_FINE.BI_modelo_sillon (modelo_id)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Envio (
	envio_id INT IDENTITY(1,1),
	envio_tiempo_programado INT,
	envio_tiempo_enviado INT,
	envio_ubicacion INT,
	envio_total DECIMAL(18,2),

	CONSTRAINT PK_BI_Hecho_Envio PRIMARY KEY (envio_id),
	
	CONSTRAINT FK_Hecho_Envio_tiempo_programado FOREIGN KEY (envio_tiempo_programado)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Envio_tiempo_enviado FOREIGN KEY (envio_tiempo_enviado)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Envio_ubicacion FOREIGN KEY (envio_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Compra (
	compra_id INT IDENTITY(1,1),
	compra_tiempo INT,
	compra_material INT,
	compra_ubicacion INT,
	compra_subtotal DECIMAL(12,2),
	compra_total DECIMAL(12,2),
	compra_cantidad DECIMAL(18,0),

	CONSTRAINT PK_BI_Hecho_Compra PRIMARY KEY (compra_id),
	
	CONSTRAINT FK_Hecho_Compra_Tiempo FOREIGN KEY (compra_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_id),
	CONSTRAINT FK_Hecho_Compra_Material FOREIGN KEY (compra_material)
		REFERENCES THIS_IS_FINE.BI_tipo_material (tipo_material_id),
	CONSTRAINT FK_Hecho_Compra_ubicacion FOREIGN KEY (compra_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_id),
)

---- LO DEJO POR SI YA TIENEN CARGADA LA TABLA COMO ESTABA ANTES (SIN CANTIDAD)
-- ALTER TABLE THIS_IS_FINE.BI_Hecho_Compra
-- ADD compra_cantidad DECIMAL(18,0)
GO

--------  FUNCIONES  --------

CREATE or alter FUNCTION THIS_IS_FINE.rangoEtario (@Fecha_Nacimiento DATE)
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

CREATE or alter FUNCTION THIS_IS_FINE.getCuatri (@Fecha DATE)
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

CREATE or alter FUNCTION THIS_IS_FINE.getRangoHorario (@Hora TIME)
RETURNS nvarchar(50)
AS
BEGIN
    RETURN CASE
        WHEN @Hora BETWEEN '08:00:00' AND '13:59:59' THEN '08:00-14:00'
        WHEN @Hora BETWEEN '14:00:00' AND '19:59:59' THEN '14:00-20:00'
        ELSE 'INDETERMINADO'
    END;
END;
GO

CREATE OR ALTER FUNCTION THIS_IS_FINE.getPorcentajePorEstado(@estado NVARCHAR(255))
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @cantidadPedidosTotales INT;
	DECLARE @cantidadPedidosPorEstado INT;
	DECLARE @porcentaje DECIMAL(5,2); -- ejemplo: 73.45
	DECLARE @porcentajeTexto NVARCHAR(50);

	SELECT @cantidadPedidosTotales = COUNT(DISTINCT pedido_codigo)
	FROM THIS_IS_FINE.BI_Hecho_Pedido;

	SELECT @cantidadPedidosPorEstado = COUNT(DISTINCT pedido_codigo)
	FROM THIS_IS_FINE.BI_Hecho_Pedido
	JOIN THIS_IS_FINE.BI_estado_pedido ON pedido_estado = estado_id
	WHERE estado = @estado;

	IF @cantidadPedidosTotales = 0
	BEGIN
		SET @porcentaje = 0;
	END
	ELSE
	BEGIN
		SET @porcentaje = 
			CAST(@cantidadPedidosPorEstado AS DECIMAL(12,2)) * 100.0 / 
			CAST(@cantidadPedidosTotales AS DECIMAL(12,2));
	END

	SET @porcentajeTexto = CAST(@porcentaje AS NVARCHAR(50)) + '%';

	RETURN @porcentajeTexto;
END
GO

--------  INSERCION DE DATOS  --------

----- INSERT UBICACIONES -----

INSERT INTO THIS_IS_FINE.BI_ubicacion(ubicacion_provincia, ubicacion_localidad)
SELECT provincia_detalle, localidad_detalle
FROM THIS_IS_FINE.Localidad
JOIN THIS_IS_FINE.Provincia ON localidad_provincia = provincia_codigo

----- INSERT RANGOS ETARIOS -----

INSERT INTO THIS_IS_FINE.[BI_rango_etario] (rango)
VALUES ('<25'), ('25-35'), ('35-50'), ('>50'), ('INDETERMINADO')

----- INSERT HORARIOS VENTA -----
SELECT * FROM THIS_IS_FINE.BI_turno_ventas
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

SELECT * FROM THIS_IS_FINE.BI_tipo_material

----- INSERT SILLON MODELO  -----

INSERT INTO THIS_IS_FINE.BI_modelo_sillon (modelo_descripcion)
SELECT sillon_modelo_descripcion
FROM THIS_IS_FINE.sillon_modelo

select * from THIS_IS_FINE.BI_modelo_sillon

----- INSERT ESTADO PEDIDO -----

INSERT INTO THIS_IS_FINE.BI_estado_pedido (estado)
SELECT DISTINCT pedido_estado
FROM THIS_IS_FINE.Pedido

----- INSERT HECHO PEDIDO -----

DELETE FROM THIS_IS_FINE.BI_Hecho_Pedido

INSERT INTO THIS_IS_FINE.BI_Hecho_Pedido(
	pedido_codigo, 
	pedido_ubicacion, 
	pedido_tiempo, 
	pedido_rango_etario, 
	pedido_turno_ventas,
	pedido_estado,
	pedido_modelo_sillon,
	pedido_cantidad_sillon,
	pedido_sillon_precio,--
	pedido_subtotal,--
	pedido_precio_total
)
SELECT pedido.pedido_numero, ubicacion.ubicacion_id, 
	tiempo.tiempo_id, rango.rango_etario_id, turno.turno_id, 
	estado.estado_id, BI_modelo.modelo_id, detalle.pedido_det_cantidad,
	detalle.pedido_det_precio, detalle.pedido_det_subtotal, pedido.pedido_total

FROM THIS_IS_FINE.Pedido pedido
JOIN THIS_IS_FINE.detalle_pedido detalle ON detalle.pedido_numero = pedido.pedido_numero
JOIN THIS_IS_FINE.Cliente cliente ON cliente.cliente_codigo = pedido.pedido_cliente
JOIN THIS_IS_FINE.Sillon sillon ON detalle.sillon_id = sillon.sillon_id
JOIN THIS_IS_FINE.sillon_modelo modelo ON sillon.sillon_modelo = modelo.sillon_modelo_codigo
JOIN THIS_IS_FINE.BI_modelo_sillon BI_modelo ON modelo.sillon_modelo_descripcion = BI_modelo.modelo_descripcion
JOIN THIS_IS_FINE.Sucursal sucursal ON sucursal.sucursal_id = pedido.pedido_sucursal
JOIN THIS_IS_FINE.Localidad localidad ON sucursal_localidad = localidad.localidad_codigo
JOIN THIS_IS_FINE.Provincia provincia ON localidad.localidad_provincia = provincia.provincia_codigo
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON provincia.provincia_detalle = ubicacion.ubicacion_provincia AND localidad.localidad_detalle = ubicacion.ubicacion_localidad
JOIN THIS_IS_FINE.BI_tiempo tiempo ON YEAR(pedido.pedido_fecha) = tiempo.tiempo_anio 
	AND THIS_IS_FINE.getCuatri(pedido.pedido_fecha) = tiempo.tiempo_cuatrimestre AND MONTH(pedido.pedido_fecha) = tiempo.tiempo_mes
JOIN THIS_IS_FINE.BI_rango_etario rango ON THIS_IS_FINE.rangoEtario(cliente.cliente_fecha_nacimiento) = rango.rango
JOIN THIS_IS_FINE.BI_turno_ventas turno ON THIS_IS_FINE.getRangoHorario(CONVERT(TIME, pedido.pedido_fecha)) = turno.turno
JOIN THIS_IS_FINE.BI_estado_pedido estado ON pedido.pedido_estado = estado.estado

----- INSERT HECHO COMPRA -----

INSERT INTO THIS_IS_FINE.BI_Hecho_Compra( 
	compra_tiempo,
	compra_material,
	compra_cantidad,
	compra_ubicacion,
	compra_subtotal,
	compra_total)
SELECT tiempo_id, BI_material.tipo_material_id, detalle.detalle_compra_cantidad, ubicacion_id, detalle.detalle_compra_subtotal, compra.compra_total
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

---- INSERT HECHO ENVIO ----

INSERT INTO THIS_IS_FINE.BI_Hecho_Envio(
    envio_tiempo_programado,
	envio_tiempo_enviado,
	envio_ubicacion,
	envio_total)
SELECT t1.tiempo_id,
       t2.tiempo_id,
	   ubicacion_id,
	   (envio_importe_traslado + envio_importe_subida) as envio_total
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

---- INSERT HECHO VENTA -----

INSERT INTO THIS_IS_FINE.BI_Hecho_Venta(
    venta_factura, 
	venta_ubicacion,
	venta_tiempo,
	venta_modelo_sillon,
	venta_cantidad,
	venta_total)
SELECT factura_numero
       ubicacion_id,
	   tiempo_id,
	   modelo.sillon_modelo_codigo,
	   dp.detalle_factura_cantidad,
	   factura_total
FROM THIS_IS_FINE.Factura
JOIN THIS_IS_FINE.BI_tiempo ON YEAR(factura_fecha) = tiempo_anio
	AND THIS_IS_FINE.getCuatri(factura_fecha) = tiempo_cuatrimestre AND MONTH(factura_fecha) = tiempo_mes
JOIN THIS_IS_FINE.Sucursal sucursal ON sucursal.sucursal_id = factura_sucursal
JOIN THIS_IS_FINE.Localidad localidad ON sucursal_localidad = localidad.localidad_codigo
JOIN THIS_IS_FINE.Provincia provincia ON localidad.localidad_provincia = provincia.provincia_codigo
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON provincia.provincia_detalle = ubicacion.ubicacion_provincia
AND localidad.localidad_detalle = ubicacion.ubicacion_localidad
JOIN THIS_IS_FINE.detalle_factura dp ON factura_numero = dp.detalle_factura_numero
JOIN THIS_IS_FINE.Sillon s ON dp.detalle_factura_sillon = s.sillon_id
JOIN THIS_IS_FINE.sillon_modelo modelo ON s.sillon_modelo = modelo.sillon_modelo_codigo




------  VISTAS  ------

---- VISTA GANANCIAS ----

CREATE or alter VIEW THIS_IS_FINE.BI_Ganancias AS
SELECT 
    t.tiempo_anio as anio,
    t.tiempo_mes as mes,
    u.ubicacion_localidad as sucursal_localidad,
    u.ubicacion_provincia as sucursal_provincia,
    ISNULL(SUM(p.pedido_precio_total), 0) - ISNULL(SUM(c.compra_total), 0) AS ganancia
FROM THIS_IS_FINE.BI_tiempo t
JOIN THIS_IS_FINE.BI_Hecho_Pedido p
    ON p.pedido_tiempo = t.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion u
    ON p.pedido_ubicacion = u.ubicacion_id
LEFT JOIN THIS_IS_FINE.BI_Hecho_Compra c
    ON c.compra_tiempo = t.tiempo_id
    AND c.compra_ubicacion = u.ubicacion_id
GROUP BY 
    t.tiempo_anio,
    t.tiempo_mes,
    u.ubicacion_localidad,
    u.ubicacion_provincia;
GO

select * from THIS_IS_FINE.BI_Ganancias
GO

--- Vista 2 ----
CREATE or ALTER VIEW THIS_IS_FINE.BI_FacturaPromedioMensual AS
SELECT
    t.tiempo_anio AS anio,
    t.tiempo_cuatrimestre AS cuatrimestre,
    u.ubicacion_provincia AS provincia,
    AVG(p.pedido_precio_total) AS factura_promedio
FROM THIS_IS_FINE.BI_Hecho_Pedido p
JOIN THIS_IS_FINE.BI_tiempo t ON p.pedido_tiempo = t.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion u ON p.pedido_ubicacion = u.ubicacion_id
GROUP BY
    t.tiempo_anio,
    t.tiempo_cuatrimestre,
    u.ubicacion_provincia;
GO

select * from THIS_IS_FINE.BI_FacturaPromedioMensual


---- VISTA 4: VOLUMEN DE PEDIDOS ----

SELECT * FROM THIS_IS_FINE.BI_Hecho_Pedido
GO

CREATE or alter VIEW THIS_IS_FINE.Volumen_Pedidos AS 
SELECT 
	COUNT(DISTINCT pedido.pedido_codigo) AS Cantidad_Pedidos,
	ubicacion.ubicacion_localidad AS sucursal_localidad,
	ubicacion.ubicacion_provincia AS sucursal_provincia,
	turno AS turno,
	CAST(tiempo.tiempo_mes AS VARCHAR) + '-' + CAST(tiempo.tiempo_anio AS VARCHAR) AS [mes-a�o]
FROM THIS_IS_FINE.BI_Hecho_Pedido pedido
JOIN THIS_IS_FINE.BI_tiempo tiempo ON pedido.pedido_tiempo = tiempo.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON pedido.pedido_ubicacion = ubicacion.ubicacion_id
JOIN THIS_IS_FINE.BI_rango_etario rangoEtario ON rangoEtario.rango_etario_id = pedido.pedido_rango_etario
JOIN THIS_IS_FINE.BI_turno_ventas ON pedido.pedido_turno_ventas = turno_id
GROUP BY ubicacion.ubicacion_localidad, ubicacion.ubicacion_provincia, turno, tiempo.tiempo_mes, tiempo.tiempo_anio
GO

select * from THIS_IS_FINE.Volumen_Pedidos













