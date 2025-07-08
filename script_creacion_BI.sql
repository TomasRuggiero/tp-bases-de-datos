

-------- SCRIPT CREACION BI --------

use GD1C2025

SELECT * FROM THIS_IS_FINE.

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
	hecho_pedido_ubicacion INT,
	hecho_pedido_tiempo INT,
	--hecho_pedido_rango_etario INT, Me parece que no va
	pedido_turno_ventas INT,
	pedido_estado INT,
	pedido_modelo_sillon INT,
	pedido_cantidad_sillones INT,
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
use GD1C2025

CREATE TABLE THIS_IS_FINE.BI_Hecho_Venta(
	hecho_venta_id INT IDENTITY(1,1),
	ubicacion INT,
	tiempo INT,
	modelo_sillon INT,
	rango_etario INT,

	sillones_vendidos INT,
	importe_promedio decimal(18,2),
	total_vendido decimal(18,2),

	CONSTRAINT PK_Hecho_Venta PRIMARY KEY (hecho_venta_id),
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
	compra_tiempo INT,
	compra_material INT,
	compra_ubicacion INT,
	compra_total DECIMAL(12,2),
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
GO

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
CREATE OR ALTER FUNCTION THIS_IS_FINE.getPorcentajeEnvios(
     @anio INT,
	 @mes INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @cantidadEnviosTotales INT;
	DECLARE @cantidadEnviosCumplidos INT;
	DECLARE @porcentaje DECIMAL(5,2)
	DECLARE @porcentajeTexto NVARCHAR(50);

	SELECT @cantidadEnviosTotales = COUNT(*)
	FROM THIS_IS_FINE.BI_Hecho_Envio e
	JOIN THIS_IS_FINE.BI_tiempo t ON e.envio_tiempo_programado = t.tiempo_id
	WHERE t.tiempo_anio = @anio AND t.tiempo_mes = @mes;

	SELECT @cantidadEnviosCumplidos = COUNT(*)
	FROM THIS_IS_FINE.BI_Hecho_Envio e
	JOIN THIS_IS_FINE.BI_tiempo t1 ON e.envio_tiempo_programado = t1.tiempo_id
	JOIN THIS_IS_FINE.BI_tiempo t2 ON e.envio_tiempo_enviado = t2.tiempo_id
	WHERE t1.tiempo_anio = @anio AND t1.tiempo_mes = @mes
	   AND t1.tiempo_anio = t2.tiempo_anio
	   AND t1.tiempo_mes = t2.tiempo_mes
	   AND t1.tiempo_cuatrimestre = t2.tiempo_cuatrimestre
    
	IF @cantidadEnviosTotales = 0
	    SET @porcentaje = 0
    ELSE 
	    SET @porcentaje = CAST(@cantidadEnviosCumplidos * 100.0 / @cantidadEnviosTotales AS DECIMAL(5,2));
    
	SET @porcentajeTexto = CAST(@porcentaje AS NVARCHAR(50)) + '%';

	RETURN @porcentajeTexto;
END
GO

GO
CREATE OR ALTER FUNCTION THIS_IS_FINE.getTiempoPromedioFabricacion(
      @ubicacion_id INT,
	  @anio INT,
	  @cuatrimestre INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
      DECLARE @promedio DECIMAL(5,2)

	  SELECT @promedio = AVG(DATEDIFF(DAY,
	        CONVERT(DATE, CONCAT(tiempo_pedido.tiempo_anio,'-', tiempo_pedido.tiempo_mes, '-01')),
			CONVERT(DATE, CONCAT(tiempo_factura.tiempo_anio, '-', tiempo_factura.tiempo_mes, '-01'))
      ))
	  FROM THIS_IS_FINE.BI_Hecho_Pedido pedido
	  JOIN THIS_IS_FINE.BI_tiempo tiempo_pedido
	      ON pedido.pedido_tiempo = tiempo_pedido.tiempo_id
      JOIN THIS_IS_FINE.detalle_pedido dp
	      ON dp.pedido_numero = pedido.pedido_codigo
      JOIN THIS_IS_FINE.detalle_factura df
	      ON df.detalle_factura_pedido = dp.detalle_pedido_id
      JOIN THIS_IS_FINE.BI_Hecho_Venta venta
	      ON venta.venta_factura = df.detalle_factura_numero
      JOIN THIS_IS_FINE.BI_tiempo tiempo_factura
	      ON venta.venta_tiempo = tiempo_factura.tiempo_id
      WHERE pedido.pedido_ubicacion = @ubicacion_id
	     AND tiempo_pedido.tiempo_anio = @anio
		 AND tiempo_pedido.tiempo_cuatrimestre = @cuatrimestre;

      RETURN @promedio
END;
GO

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
	cantidad_compras,
	compra_ubicacion,
	compra_total,
	promedio_compra
)
SELECT tiempo_id, BI_material.tipo_material_id, COUNT(DISTINCT compra.compra_numero), ubicacion_id, SUM(compra.compra_total), AVG(compra.compra_total)
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

DELETE FROM THIS_IS_FINE.BI_Hecho_Venta
---- INSERT HECHO VENTA -----
INSERT INTO THIS_IS_FINE.BI_Hecho_Venta(
	ubicacion,
	tiempo,
	modelo_sillon,
	rango_etario,
	sillones_vendidos,
	total_vendido,
	importe_promedio)
SELECT
       ubicacion_id,
	   tiempo_id,
	   BI_sillon.modelo_id,
	   rango_etario.rango_etario_id,
	   COUNT(df.detalle_factura_cantidad),
	   SUM(factura_total),
	   AVG(factura_total)
FROM THIS_IS_FINE.Factura
JOIN THIS_IS_FINE.BI_tiempo ON YEAR(factura_fecha) = tiempo_anio
	AND THIS_IS_FINE.getCuatri(factura_fecha) = tiempo_cuatrimestre AND MONTH(factura_fecha) = tiempo_mes
JOIN THIS_IS_FINE.Sucursal sucursal ON sucursal.sucursal_id = factura_sucursal
JOIN THIS_IS_FINE.Localidad localidad ON sucursal_localidad = localidad.localidad_codigo
JOIN THIS_IS_FINE.Provincia provincia ON localidad.localidad_provincia = provincia.provincia_codigo
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON provincia.provincia_detalle = ubicacion.ubicacion_provincia
	AND localidad.localidad_detalle = ubicacion.ubicacion_localidad
JOIN THIS_IS_FINE.detalle_factura df ON factura_numero = df.detalle_factura_numero
JOIN THIS_IS_FINE.detalle_pedido detPed ON detPed.detalle_pedido_id = df.detalle_factura_pedido
JOIN THIS_IS_FINE.Sillon sillon ON detPed.sillon_id = sillon.sillon_id
JOIN THIS_IS_FINE.sillon_modelo sModelo ON sModelo.sillon_modelo_codigo = sillon.sillon_modelo
JOIN THIS_IS_FINE.BI_modelo_sillon BI_sillon ON BI_sillon.modelo_descripcion = sModelo.sillon_modelo_descripcion
JOIN THIS_IS_FINE.Cliente cliente ON Factura.factura_cliente = cliente.cliente_codigo
JOIN THIS_IS_FINE.BI_rango_etario rango_etario ON THIS_IS_FINE.rangoEtario(cliente.cliente_fecha_nacimiento) = rango_etario.rango
GROUP BY ubicacion_id, tiempo_id, BI_sillon.modelo_id, rango_etario.rango_etario_id


------  VISTAS  ------

--DELETE FROM THIS_IS_FINE.BI_Hecho_Venta

---- VISTA 1: GANANCIAS----
GO
CREATE OR alter VIEW THIS_IS_FINE.BI_Ganancias AS
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

GO

--- Vista 2 ----
CREATE OR ALTER VIEW THIS_IS_FINE.BI_FacturaPromedioMensual AS
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

---- VISTA 3: RENDIMIENTO DE MODELOS ----
GO
CREATE OR ALTER VIEW THIS_IS_FINE.BI_Rendimiento_Modelos 
AS
SELECT 
	modelo.modelo_descripcion,
	CAST(tiempo.tiempo_cuatrimestre AS VARCHAR) + '-' + CAST(tiempo.tiempo_anio AS VARCHAR) AS [cuatrimestre-año],
	ubicacion.ubicacion_localidad,
	rEtario.rango
FROM THIS_IS_FINE.BI_modelo_sillon modelo
JOIN THIS_IS_FINE.BI_Hecho_Venta venta ON venta.venta_modelo_sillon = modelo.modelo_id
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON venta.venta_ubicacion = ubicacion.ubicacion_id
JOIN THIS_IS_FINE.BI_tiempo tiempo ON tiempo_id = venta.venta_tiempo
JOIN THIS_IS_FINE.BI_rango_etario rEtario ON rEtario.rango_etario_id =  venta.venta_rango_etario
WHERE modelo.modelo_id IN (
    SELECT TOP 3 modelo_id
    FROM THIS_IS_FINE.BI_modelo_sillon
    JOIN THIS_IS_FINE.BI_Hecho_Venta ON venta_modelo_sillon = modelo_id
    GROUP BY modelo_id
    ORDER BY SUM(venta_cantidad) DESC
)
GROUP BY ubicacion.ubicacion_localidad,tiempo.tiempo_cuatrimestre, tiempo.tiempo_anio, rEtario.rango, modelo.modelo_descripcion



---- VISTA 4: VOLUMEN DE PEDIDOS ----

GO
CREATE OR ALTER VIEW THIS_IS_FINE.Volumen_Pedidos AS 
SELECT 
	COUNT(DISTINCT pedido.pedido_codigo) AS Cantidad_Pedidos,
	ubicacion.ubicacion_localidad AS sucursal_localidad,
	ubicacion.ubicacion_provincia AS sucursal_provincia,
	turno AS turno,
	CAST(tiempo.tiempo_mes AS VARCHAR) + '-' + CAST(tiempo.tiempo_anio AS VARCHAR) AS [mes-año]
FROM THIS_IS_FINE.BI_Hecho_Pedido pedido
JOIN THIS_IS_FINE.BI_tiempo tiempo ON pedido.pedido_tiempo = tiempo.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON pedido.pedido_ubicacion = ubicacion.ubicacion_id
JOIN THIS_IS_FINE.BI_rango_etario rangoEtario ON rangoEtario.rango_etario_id = pedido.pedido_rango_etario
JOIN THIS_IS_FINE.BI_turno_ventas ON pedido.pedido_turno_ventas = turno_id
GROUP BY ubicacion.ubicacion_localidad, ubicacion.ubicacion_provincia, turno, tiempo.tiempo_mes, tiempo.tiempo_anio

---- VISTA 5: CONVERSION DE PEDIDOS ----
GO
CREATE OR ALTER VIEW THIS_IS_FINE.Conversion_Pedidos AS
SELECT 
	THIS_IS_FINE.getPorcentajePorEstado(estado.estado) AS porcentaje,
	estado.estado AS estado,
	tiempo_cuatrimestre AS cuatrimestre,
	ubicacion.ubicacion_localidad AS sucursal_localidad,
	ubicacion.ubicacion_provincia AS sucursal_provincia
FROM THIS_IS_FINE.BI_Hecho_Pedido pedido
JOIN THIS_IS_FINE.BI_estado_pedido estado ON estado.estado_id = pedido.pedido_estado
JOIN THIS_IS_FINE.BI_tiempo tiempo ON pedido.pedido_tiempo = tiempo.tiempo_id
JOIN THIS_IS_FINE.BI_ubicacion ubicacion ON ubicacion.ubicacion_id = pedido.pedido_ubicacion
GROUP BY estado.estado, tiempo_cuatrimestre, ubicacion.ubicacion_localidad, ubicacion.ubicacion_provincia

---- VISTA 6: TIEMPO PROMEDIO DE FABRICACIÓN ----
GO
CREATE OR ALTER VIEW THIS_IS_FINE.PromedioTiempoFabriacion AS
SELECT 
    u.ubicacion_localidad AS sucursal_localidad,
	u.ubicacion_provincia AS sucursal_provincia,
	t.tiempo_anio,
	t.tiempo_cuatrimestre,
	THIS_IS_FINE.getTiempoPromedioFabricacion(u.ubicacion_id, t.tiempo_anio, t.tiempo_cuatrimestre)
	AS tiempo_promedio_fabricacion
FROM THIS_IS_FINE.BI_ubicacion u
CROSS JOIN (
     SELECT DISTINCT tiempo_anio, tiempo_cuatrimestre
	 FROM THIS_IS_FINE.BI_tiempo
)t
WHERE THIS_IS_FINE.getTiempoPromedioFabricacion(u.ubicacion_id, t.tiempo_anio, t.tiempo_cuatrimestre) IS NOT NULL
GO

GO
---- VISTA 7: PROMEDIO DE COMPRAS ----
GO
CREATE OR ALTER VIEW THIS_IS_FINE.v_promedio_compras_mensual AS
SELECT
    tiempo.tiempo_anio AS anio,
    tiempo.tiempo_mes AS mes,
    ROUND(AVG(compra.compra_total), 2) AS promedio_mensual
FROM THIS_IS_FINE.BI_Hecho_Compra compra
JOIN THIS_IS_FINE.BI_tiempo tiempo ON compra.compra_tiempo = tiempo.tiempo_id
GROUP BY tiempo.tiempo_anio, tiempo.tiempo_mes;

---- VISTA 8: COMPRA POR TIPO DE MATERIAL ----
GO
CREATE OR ALTER VIEW THIS_IS_FINE.VW_compra_tipo_material_ubicacion_cuatrimestre AS
SELECT 
    tipo_material.tipo_material,
    ubicacion_sucursal.ubicacion_provincia,
    ubicacion_sucursal.ubicacion_localidad,
    tiempo.tiempo_anio,
    tiempo.tiempo_cuatrimestre,
    SUM(compra.compra_total) AS total_gastado
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

---- VISTA 9: PORCENTAJE DE CUMPLIMIENTO DE ENVÍOS -----
GO
CREATE OR ALTER VIEW THIS_IS_FINE.Porcentaje_Cumplimiento_Envios AS
SELECT
    DISTINCT
	t.tiempo_anio AS anio,
	t.tiempo_mes AS mes,
	THIS_IS_FINE.getPorcentajeEnvios(t.tiempo_anio, t.tiempo_mes) AS porcentaje_cumplimiento
FROM THIS_IS_FINE.BI_tiempo t
JOIN THIS_IS_FINE.BI_Hecho_Envio e ON e.envio_tiempo_programado = t.tiempo_id

---- VISTA 10: LOCALIDADES QUE PAGAN MAYOR COSTO DE ENVIO -----     
GO
CREATE OR ALTER VIEW THIS_IS_FINE.Envio_Localidad AS
SELECT TOP 3 
	u.ubicacion_localidad AS localidad,
	u.ubicacion_provincia AS provincia, --traigo también la provincia porque podrían existir localidades con el mismo nombre en distintas provincias
	AVG(e.envio_total) AS promedio_costo_envio
FROM THIS_IS_FINE.BI_Hecho_Envio e
JOIN THIS_IS_FINE.BI_ubicacion u ON e.envio_ubicacion = u.ubicacion_id
GROUP BY u.ubicacion_localidad, u.ubicacion_provincia
ORDER BY promedio_costo_envio DESC

GO








