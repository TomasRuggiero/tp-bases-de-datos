/* SCRIPT TP GDD MIGRACION DE DATOS */ 

use GD1C2025;

create schema THIS_IS_FINE

drop table if exists THIS_IS_FINE.Provincia;

drop table if exists THIS_IS_FINE.Localidad;

create table THIS_IS_FINE.Cliente (
	cliente_codigo INT PRIMARY KEY,
	cliente_dni NVARCHAR(100),
	cliente_nombre NVARCHAR(100),
	cliente_apellido NVARCHAR(100),
	cliente_fecha_nacimiento datetime2(6),
	cliente_mail NVARCHAR(100),
	cliente_telefono NVARCHAR(100),
	cliente_direccion NVARCHAR(100)
	-- Agregar FK a Localidad
)

create table THIS_IS_FINE.Provincia (
	provincia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	provincia_detalle NVARCHAR(255)
)

create table THIS_IS_FINE.Localidad (
	localidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	localidad_detalle NVARCHAR(255),
	localidad_provincia INTEGER
	-- Agregar FK a Provincia
)

/*
ALTER TABLE THIS_IS_FINE.Localidad
ADD CONSTRAINT FK_localidad_provincia FOREIGN KEY (localidad_provincia)
REFERENCES THIS_IS_FINE.Provincia(provincia_codigo);
*/



create table THIS_IS_FINE.Proveedor (
	proveedor_codigo INTEGER PRIMARY KEY,
	proveedor_cuit NVARCHAR(100),
	proveedor_razon_social NVARCHAR(100),
	proveedor_direccion NVARCHAR(100),
	proveedor_telefono	NVARCHAR(100),
	proveedor_mail NVARCHAR(100)
	-- Agregar FK a Localidad
)

create table THIS_IS_FINE.Factura (
	factura_numero bigint PRIMARY KEY,
	factura_fecha datetime2(6),
	-- FK a Cliente
	factura_total decimal(38,2),
	--Fk a Sucursal
)

create table THIS_IS_FINE.Sucursal (
	sucursal_numero nvarchar(255) PRIMARY KEY, -- discutir si esta bien 
	-- FK a Localidad
	sucursal_direccion nvarchar(255),
	sucursal_telefono nvarchar(255),
	sucursal_mail nvarchar(255)
)

create table THIS_IS_FINE.detalle_factura (
	--Fk a Factura
	--FK a pedido
	fact_det_precio decimal(18,2),
	fact_det_cantidad decimal(18,0),
	fact_det_subtotal decimal(18,2)
)

create table THIS_IS_FINE.Pedido (
	pedido_numero decimal(18,0) PRIMARY KEY,
	pedido_fecha datetime2(6),
	--FK a Sucursal 
	pedido_estado nvarchar(255),
	--FK a cliente
	pedido_total decimal(18,2)
)

create table THIS_IS_FINE.detalle_pedido (
	--FK a Pedido 
	-- FK a sillon
	-- PK es (pedido, sillon)
	pedido_det_cantidad bigint,
	pedido_det_precio decimal(18,2),
	--pedido_det_subtotal discutir que hacer con esto
)

create table THIS_IS_FINE.pedido_cancelacion (
	cancel_pedido_codigo int PRIMARY KEY,
	cancel_pedido_fecha datetime2(6),
	--FK a pedido
)

create table THIS_IS_FINE.Sillon (
	sillon_codigo bigint PRIMARY KEY,
	-- FK a sillon modelo
	-- FK a sillon medida
)

create table THIS_IS_FINE.modelo_sillon (
	modelo_codigo bigint PRIMARY KEY,
	modelo_descripcion nvarchar(255),
	modelo_precio decimal(18,2)
)

create table THIS_IS_FINE.medida_sillon (
	medida_codigo int PRIMARY KEY,
	medida_alto decimal(18,2),
	medida_ancho decimal(18,2),
	medida_profundidad decimal(18,2),
	medida_precio decimal(18,2)
)

create table THIS_IS_FINE.Compra (
	compra_codigo decimal(18,0) PRIMARY KEY,
	-- FK a Sucursal
	-- FK a Envio
	-- FK a Proveedor
	compra_fecha datetime2(6),
	compra_total decimal(18,2)
)

create table THIS_IS_FINE.detalle_compra (
	-- FK a Compra
	-- FK a Material
	compra_precio_unitario decimal(18,2),
	compra_cantidad decimal(18,0),
	compra_subtotal decimal(18,0)
)

create table THIS_IS_FINE.sillon_material (
	--FK a sillon
	-- Fk a material
	material_cantidad decimal(18,2)
)

/* A DISCUTIR: 
	- Que hacemos con tipo_material.
	- No estamos reflejando bien la relacion muchos a muchos de sillon-material, deberiamos partir la relacion con tabla intermedia
	sino no podemos reflejar de que materiales se hizo el sillon 
	- tipos de datos para las PKs
*/


/*Insertar provincia de la tabla maestra a tabla provincia*/
INSERT INTO THIS_IS_FINE.Provincia (provincia_detalle)
SELECT DISTINCT provincia
FROM (
    SELECT Sucursal_Provincia AS provincia FROM gd_esquema.Maestra
    UNION
    SELECT Cliente_Provincia FROM gd_esquema.Maestra
    UNION
    SELECT Proveedor_Provincia FROM gd_esquema.Maestra
) AS provincias
WHERE provincia IS NOT NULL;

/*insertando localidades de proveedor*/
INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
SELECT DISTINCT
    maestra.Proveedor_Localidad,
    Prov.provincia_codigo
FROM gd_esquema.Maestra maestra
JOIN THIS_IS_FINE.Provincia Prov
  ON Prov.provincia_detalle = maestra.Proveedor_Provincia
WHERE maestra.Proveedor_Provincia IS NOT NULL
  AND maestra.Proveedor_Localidad IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM THIS_IS_FINE.Localidad Loc
      WHERE Loc.localidad_detalle = maestra.Proveedor_Localidad and Loc.localidad_provincia = Prov.provincia_codigo
  	)

/*insertando localidades de sucursal*/
INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
SELECT DISTINCT
    maestra.Sucursal_Localidad,
    Prov.provincia_codigo
FROM gd_esquema.Maestra maestra
JOIN THIS_IS_FINE.Provincia Prov
  ON Prov.provincia_detalle = maestra.Sucursal_Provincia
WHERE maestra.Sucursal_Provincia IS NOT NULL
  AND maestra.Sucursal_Localidad IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM THIS_IS_FINE.Localidad Loc
      WHERE Loc.localidad_detalle = maestra.Sucursal_Localidad and Loc.localidad_provincia = Prov.provincia_codigo
  	)

/*insertando localidades de cliente*/
INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
SELECT DISTINCT
    maestra.Cliente_Localidad,
    Prov.provincia_codigo
FROM gd_esquema.Maestra maestra
JOIN THIS_IS_FINE.Provincia Prov
  ON Prov.provincia_detalle = maestra.Cliente_Provincia
WHERE maestra.Cliente_Provincia IS NOT NULL
  AND maestra.Cliente_Localidad IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM THIS_IS_FINE.Localidad Loc
      WHERE Loc.localidad_detalle = maestra.Cliente_Localidad and Loc.localidad_provincia = Prov.provincia_codigo
	)













