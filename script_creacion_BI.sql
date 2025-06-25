

-------- SCRIPT CREACION BI --------

use GD1C2025

IF OBJECT_ID('THIS_IS_FINE.BI_Hecho_factura', 'U') IS NOT NULL
    DROP TABLE THIS_IS_FINE.BI_Hecho_factura;

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



-------- CREACION TABLA DIMENSIONES --------

CREATE TABLE THIS_IS_FINE.BI_tiempo (
	tiempo_codigo INT IDENTITY(1,1),
	tiempo_anio INT,
	tiempo_cuatrimestre INT,
	tiempo_mes INT
	CONSTRAINT PK_BI_tiempo PRIMARY KEY (tiempo_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_ubicacion (
	ubicacion_codigo INT IDENTITY(1,1),
	ubicacion_provincia NVARCHAR(255),
	ubicacion_localidad NVARCHAR(255)
	CONSTRAINT PK_ubicacion PRIMARY KEY (ubicacion_codigo)   
)

CREATE TABLE THIS_IS_FINE.BI_rango_etario (
	rango_etario_codigo INT IDENTITY(1,1),
	rango NVARCHAR(50)
	CONSTRAINT PK_rango_etario PRIMARY KEY (rango_etario_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_turno_ventas (
	turno_codigo INT IDENTITY(1,1),
	turno NVARCHAR(50)
	CONSTRAINT PK_BI_turno_ventas PRIMARY KEY (turno_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_tipo_material(
	tipo_material_codigo INT IDENTITY(1,1),
	tipo_material NVARCHAR(255),
	material_descripcion NVARCHAR(255)
	CONSTRAINT PK_BI_tipo_material PRIMARY KEY (tipo_material_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_modelo_sillon(
	modelo_codigo INT IDENTITY(1,1),
	modelo_descripcion NVARCHAR(255)
	CONSTRAINT PK_BI_modelo_sillon PRIMARY KEY (modelo_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_estado_pedido(
	estado_codigo INT IDENTITY(1,1),
	estado NVARCHAR(255)
	CONSTRAINT PK_BI_estado_pedido PRIMARY KEY (estado_codigo)
)	

CREATE TABLE THIS_IS_FINE.BI_sucursal(
	sucursal_codigo INT IDENTITY(1,1),
	sucursal_ubicacion INT
	CONSTRAINT PK_BI_sucursal PRIMARY KEY (sucursal_codigo)
	CONSTRAINT FK_sucursal_ubicacion FOREIGN KEY (sucursal_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Pedido(
	pedido_id INT IDENTITY(1,1),
	pedido_codigo decimal(18,0),
	pedido_sucursal INT,
	pedido_tiempo INT,
	pedido_rango_etario INT,
	pedido_turno_ventas INT,
	pedido_estado INT,
	pedido_fecha datetime2(6),
	pedido_precio_total decimal(18,2),

	CONSTRAINT PK_Hecho_pedido PRIMARY KEY (pedido_id),

	CONSTRAINT FK_Hecho_Pedido_sucursal FOREIGN KEY (pedido_sucursal)
		REFERENCES THIS_IS_FINE.BI_sucursal (sucursal_codigo),
	CONSTRAINT FK_Hecho_Pedido_tiempo FOREIGN KEY (pedido_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_codigo),
	CONSTRAINT FK_Hecho_Pedido_rango_etario FOREIGN KEY (pedido_rango_etario)
		REFERENCES THIS_IS_FINE.BI_rango_etario (rango_etario_codigo),
	CONSTRAINT FK_Hecho_Pedido_horario_ventas FOREIGN KEY (pedido_turno_ventas)
		REFERENCES THIS_IS_FINE.BI_turno_ventas (turno_codigo),
	CONSTRAINT FK_Hecho_Pedido_estado FOREIGN KEY (pedido_estado)
		REFERENCES THIS_IS_FINE.BI_estado_pedido (estado_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Detalle_Pedido(
	detalle_pedido_id INT IDENTITY(1,1),
	pedido_id INT,
	det_pedido_sillon_modelo NVARCHAR(255),
	det_pedido_cantidad BIGINT,
	det_pedido_precio decimal(18,2),
	det_pedido_subtotal BIGINT

	CONSTRAINT PK_Hecho_Detalle_Pedido PRIMARY KEY (detalle_pedido_id),

	CONSTRAINT FK_Hecho_Pedido_id FOREIGN KEY (pedido_id)
		REFERENCES THIS_IS_FINE.BI_Hecho_Pedido (pedido_id)
)



CREATE TABLE THIS_IS_FINE.BI_Hecho_factura(
	factura_id INT IDENTITY(1,1),
	factura_pedido decimal(18,0),
	factura_sucursal INT,
	factura_tiempo INT,
	factura_modelo_sillon INT,
	factura_cantidad INT,
	factura_fecha datetime2(6),
	factura_total decimal(12,2)

	CONSTRAINT PK_Hecho_Factura PRIMARY KEY (factura_id)
	CONSTRAINT FK_Hecho_Factura_sucursal FOREIGN KEY (factura_sucursal)
		REFERENCES THIS_IS_FINE.BI_sucursal (sucursal_codigo),
	CONSTRAINT FK_Hecho_Factura_tiempo FOREIGN KEY (factura_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_codigo),
	CONSTRAINT FK_Hecho_Factura_modelo_sillon FOREIGN KEY (factura_modelo_sillon)
		REFERENCES THIS_IS_FINE.BI_modelo_sillon (modelo_codigo)
)

--------  FUNCIONES  --------

CREATE FUNCTION THIS_IS_FINE.rangoEtario (@Fecha_Nacimiento DATE)
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

CREATE FUNCTION  THIS_IS_FINE.getCuatri (@Fecha DATE)
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

CREATE FUNCTION  THIS_IS_FINE.getRangoHorario (@Hora TIME)
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

INSERT INTO THIS_IS_FINE.BI_Hecho_factura(fac)










