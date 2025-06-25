 
 
DROP FUNCTION IF EXISTS THIS_IS_FINE.rangoEtario;
DROP FUNCTION IF EXISTS THIS_IS_FINE.getCuatri;
DROP FUNCTION IF EXISTS THIS_IS_FINE.getRangoHorario;

  --------------------------------------
  --------- TABLAS DE DIMENSIONES ------
  --------------------------------------

  CREATE TABLE THIS_IS_FINE.[BI_tiempo] (
  [codigo_tiempo] int identity(1,1),
  [anio] int,
  [cuatrimestre] int,
  [mes] int,
  PRIMARY KEY ([codigo_tiempo])
);

CREATE TABLE THIS_IS_FINE.[BI_Ubicacion] (
  [codigo_ubicacion] int identity(1,1),
  [provincia] nvarchar(50),
  [localidad] nvarchar(50),
  PRIMARY KEY ([codigo_ubicacion])
);

CREATE TABLE THIS_IS_FINE.[BI_rango_etario] (
  [codigo_rango_etario] int identity(1,1),
  [rango] nvarchar(50),
  PRIMARY KEY ([codigo_rango_etario])
);

CREATE TABLE THIS_IS_FINE.[BI_horario_ventas] (
  [codigo_horario_ventas] int identity(1,1),
  [horario] nvarchar(50),
  PRIMARY KEY ([codigo_horario_ventas])
);

CREATE TABLE THIS_IS_FINE.BI_tipo_material(
	tipo_material_codigo INT IDENTITY(1,1),
	tipo_material NVARCHAR(255),
	material_descripcion NVARCHAR(255)
	CONSTRAINT PK_tipo_material PRIMARY KEY (tipo_material_codigo)
)

CREATE TABLE THIS_IS_FINE.[BI_hecho_compra] (
    [codigo_hecho_compra] INT IDENTITY(1,1) PRIMARY KEY,
    codigo_tiempo INT NOT NULL,         -- FK a dim_tiempo
    total_compra DECIMAL(18,2) NOT NULL
);

CREATE TABLE THIS_IS_FINE.[BI_hecho_detalle_compra] (
    [codigo_hecho_detalle_compra] INT IDENTITY(1,1) PRIMARY KEY,
    codigo_tiempo INT NOT NULL,           -- desde compra_fecha
    tipo_material_id INT NOT NULL,        -- FK a tipo_material
    sucursal_id INT NOT NULL,             -- directo, sin crear dim_sucursal
    total_gastado DECIMAL(18,2) NOT NULL
);




 --------------------------------------
  -----------   FUNCIONES  -------------
  --------------------------------------


GO
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


  --------------------------------------
  -----------   INSERTAR DATOS  --------
  --------------------------------------

----- INSERT RANGO ETARIO -----

INSERT INTO THIS_IS_FINE.[BI_rango_etario] (rango)
VALUES ('<25'), ('25-35'), ('35-50'), ('>50'), ('INDETERMINADO')

----- INSERT HORARIOS VENTA -----

INSERT INTO THIS_IS_FINE.[BI_horario_ventas] (horario)
VALUES ('08:00-14:00'),('14:00-20:00'), ('INDETERMINADO')

----- INSERT UBICACION -----

INSERT INTO THIS_IS_FINE.[BI_Ubicacion] (provincia, localidad)
SELECT DISTINCT
    p.provincia_detalle AS provincia,
    l.localidad_detalle AS localidad
FROM THIS_IS_FINE.Provincia p
JOIN THIS_IS_FINE.Localidad l ON l.localidad_provincia = p.provincia_codigo
WHERE p.provincia_detalle IS NOT NULL
  AND l.localidad_detalle IS NOT NULL;

----- INSERT TIEMPO -----

INSERT INTO THIS_IS_FINE.[BI_tiempo] (anio, cuatrimestre, mes)
SELECT DISTINCT
    YEAR(eventos.Fecha) AS anio,
    THIS_IS_FINE.getCuatri(eventos.Fecha) AS cuatrimestre,
    MONTH(eventos.Fecha) AS mes
FROM (
    SELECT pedido_fecha AS Fecha FROM THIS_IS_FINE.Pedido
    UNION
    SELECT envio_fecha AS Fecha FROM THIS_IS_FINE.Envio
    UNION
    SELECT compra_fecha AS Fecha FROM THIS_IS_FINE.Compra
    UNION
    SELECT factura_fecha AS Fecha FROM THIS_IS_FINE.Factura
	UNION
	SELECT envio_fecha_programada AS Fecha FROM THIS_IS_FINE.Envio
) AS eventos
WHERE eventos.Fecha IS NOT NULL;

----- INSERT HECHO COMPRA -----

INSERT INTO THIS_IS_FINE.[BI_hecho_compra] (codigo_tiempo, total_compra)
SELECT 
    t.codigo_tiempo,
    c.compra_total
FROM THIS_IS_FINE.Compra c
JOIN THIS_IS_FINE.BI_tiempo t
  ON t.anio = YEAR(c.compra_fecha) AND t.mes = MONTH(c.compra_fecha);

----- INSERT HECHO DETALLE COMPRA -----

INSERT INTO THIS_IS_FINE.[BI_hecho_detalle_compra] (
    codigo_tiempo,
    tipo_material_id,
    sucursal_id,
    total_gastado
)
SELECT
    tiempo.codigo_tiempo,
    tm.tipo_material_id,
    compra.compra_sucursal,
    SUM(dc.detalle_compra_subtotal)
FROM THIS_IS_FINE.detalle_compra dc
JOIN THIS_IS_FINE.Compra compra ON compra.compra_numero = dc.detalle_compra_numero
JOIN THIS_IS_FINE.Material material ON dc.detalle_compra_material = material.id_material
JOIN THIS_IS_FINE.BI_tipo_material tm ON material.material_tipo = tm.tipo_material_id
JOIN THIS_IS_FINE.[BI_tiempo] tiempo ON tiempo.anio = YEAR(compra.compra_fecha) AND tiempo.mes = MONTH(compra.compra_fecha)
GROUP BY tiempo.codigo_tiempo, tm.tipo_material_id, compra.compra_sucursal;


  --------------------------------------
  --------------   VISTAS  -------------
  --------------------------------------

  -- 7 Promedio de compras--

  CREATE VIEW THIS_IS_FINE.v_promedio_compras_mensual AS
SELECT
    tiempo.anio,
    tiempo.mes,
    ROUND(AVG(hecho_compra.total_compra), 2) AS promedio_mensual
FROM THIS_IS_FINE.BI_hecho_compra hecho_compra
JOIN THIS_IS_FINE.BI_tiempo tiempo ON hecho_compra.codigo_tiempo = tiempo.codigo_tiempo
GROUP BY tiempo.anio, tiempo.mes;

-- 8 Compras por tipo de material--
CREATE VIEW THIS_IS_FINE.v_total_compra_material_sucursal_cuatrimestre AS
SELECT
    tiempo.anio,
    tiempo.cuatrimestre,
    tm.tipo_material_detalle,
    hecho_detalle_compra.sucursal_id,
    SUM(hecho_detalle_compra.total_gastado) AS total_gastado
FROM THIS_IS_FINE.BI_hecho_detalle_compra hecho_detalle_compra
JOIN THIS_IS_FINE.BI_tiempo tiempo ON hecho_detalle_compra.codigo_tiempo = tiempo.codigo_tiempo
JOIN THIS_IS_FINE.tipo_material tm ON hecho_detalle_compra.tipo_material_id = tm.tipo_material_id
GROUP BY
    tiempo.anio,
    tiempo.cuatrimestre,
    tm.tipo_material_detalle,
    hecho_detalle_compra.sucursal_id;

/*
Aclaraciones de Sucursal:
Como solo uso sucursal id no creo una dimension por un solo meta dato
Por lo tanto lo saco directamente de la tabla de compra.
Aclaración de Material:
Uso directamente la tabla material .

Faltan drop de view.
Falta realizar pruebas. 

*/

